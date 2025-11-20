# CDN Management Guide

Optimize content delivery and caching with Cloudflare's global CDN.

## Overview

Cloudflare's CDN provides:
- **300+ data centers** worldwide
- **Automatic caching** of static content
- **Smart routing** via Argo
- **Content optimization** (minification, compression)
- **Image optimization** (Polish, Mirage)
- **Load balancing** across origins

## Cache Configuration

### Cache Levels

```bash
# Set cache level
npm run cdn:set-cache-level aggressive  # aggressive, basic, simplified

# aggressive: Cache all static content
# basic: Cache most static content (default)
# simplified: Ignore query strings
```

### Browser Cache TTL

```bash
# Set browser cache TTL
npm run cdn:set-browser-ttl 14400  # 4 hours in seconds

# Common values:
# 1800 = 30 minutes
# 3600 = 1 hour
# 14400 = 4 hours
# 86400 = 1 day
# 604800 = 1 week
```

### Edge Cache TTL (Page Rules)

```javascript
import { CDNManager } from './lib/cdn-manager.js';

const cdn = new CDNManager();

// Set edge cache TTL for specific paths
await cdn.createPageRule({
  targets: [{
    target: 'url',
    constraint: {
      operator: 'matches',
      value: 'example.com/static/*'
    }
  }],
  actions: [{
    id: 'edge_cache_ttl',
    value: 86400 // 1 day
  }],
  priority: 1,
  status: 'active'
});
```

## Cache Rules

### Cache Everything

```bash
# Cache all content for a path
npm run cdn:cache-everything "/api/*"

# Using the library
```

```javascript
import { CDNManager } from './lib/cdn-manager.js';

const cdn = new CDNManager();

await cdn.createCacheRule({
  description: 'Cache API responses',
  expression: '(http.request.uri.path contains "/api")',
  action: {
    cache: true,
    cache_ttl: 300, // 5 minutes
    cache_key: {
      cache_by_device_type: false,
      cache_deception_armor: true,
      ignore_query_strings: {
        all: false,
        list: ['utm_source', 'utm_campaign']
      }
    }
  }
});
```

### Bypass Cache

```javascript
// Don't cache admin pages
await cdn.createCacheRule({
  description: 'Bypass cache for admin',
  expression: '(http.request.uri.path contains "/admin")',
  action: {
    cache: false
  }
});

// Don't cache authenticated requests
await cdn.createCacheRule({
  description: 'Bypass cache for authenticated users',
  expression: '(http.cookie contains "session")',
  action: {
    cache: false
  }
});
```

### Custom Cache Keys

```javascript
// Cache by query parameters
await cdn.createCacheRule({
  description: 'Cache by specific parameters',
  expression: '(http.request.uri.path eq "/search")',
  action: {
    cache: true,
    cache_key: {
      include_query_string: {
        include: ['q', 'page', 'sort']
      },
      custom_key: {
        query_string: {
          include: ['q', 'page']
        },
        header: {
          include: ['Accept-Language']
        }
      }
    }
  }
});

// Cache variations by device type
await cdn.createCacheRule({
  description: 'Cache by device',
  expression: '(http.host eq "example.com")',
  action: {
    cache: true,
    cache_key: {
      cache_by_device_type: true
    }
  }
});
```

## Purge Cache

### Purge Everything

```bash
# Purge entire cache
npm run cdn:purge-all

# WARNING: This affects all cached content!
```

### Purge by URL

```bash
# Purge specific URLs
npm run cdn:purge-urls \
  "https://example.com/page1.html" \
  "https://example.com/page2.html"

# Purge with wildcards (Enterprise)
npm run cdn:purge-urls \
  "https://example.com/images/*" \
  "https://example.com/css/*"
```

### Purge by Tag (Enterprise)

```javascript
import { CDNManager } from './lib/cdn-manager.js';

const cdn = new CDNManager();

// Set cache tags in origin response
// Cache-Tag: user-123, product-456

// Purge by tags
await cdn.purgeTags(['user-123', 'product-456']);

// Purge in Worker
export default {
  async fetch(request, env) {
    const response = await fetch(request);
    
    // Add cache tags
    response.headers.set('Cache-Tag', 'product-123,category-tech');
    
    return response;
  }
};
```

### Purge by Cache-Tag Header

```bash
# Purge by cache tags
npm run cdn:purge-tags "user-123,product-456"
```

### Purge by Hostname

```bash
# Purge all content for a hostname
npm run cdn:purge-hostname example.com
```

### Purge by Prefix (Enterprise)

```bash
# Purge by URL prefix
npm run cdn:purge-prefix "https://example.com/blog/"
```

## Content Optimization

### Auto Minify

```bash
# Enable minification
npm run cdn:enable-minify --js --css --html

# Disable minification
npm run cdn:disable-minify --js
```

```javascript
import { CDNManager } from './lib/cdn-manager.js';

const cdn = new CDNManager();

await cdn.configureMinification({
  js: true,
  css: true,
  html: true
});
```

### Brotli Compression

```bash
# Enable Brotli
npm run cdn:enable-brotli
```

### Rocket Loader

```bash
# Enable Rocket Loader (async JS loading)
npm run cdn:enable-rocket-loader

# Options: off, manual, automatic
npm run cdn:set-rocket-loader automatic
```

### Mirage (Image Lazy Loading)

```bash
# Enable Mirage (Pro+)
npm run cdn:enable-mirage
```

### Polish (Image Optimization)

```bash
# Enable Polish (Pro+)
npm run cdn:enable-polish lossless  # off, lossless, lossy

# Enable WebP
npm run cdn:enable-webp
```

## Image Optimization

### Image Resizing

```javascript
// Worker-based image resizing
export default {
  async fetch(request) {
    const url = new URL(request.url);
    
    // Extract image URL and resize parameters
    const width = url.searchParams.get('width') || 800;
    const quality = url.searchParams.get('quality') || 85;
    const format = url.searchParams.get('format') || 'auto';
    
    // Fetch and transform image
    const imageRequest = new Request(url.origin + url.pathname, {
      cf: {
        image: {
          width: parseInt(width),
          quality: parseInt(quality),
          format: format,
          fit: 'scale-down',
          metadata: 'none',
          sharpen: 1.0
        }
      }
    });
    
    return fetch(imageRequest);
  }
};
```

### Image Delivery

```html
<!-- Automatic format selection -->
<img src="/image.jpg" cf-auto-format>

<!-- Responsive images -->
<img src="/image.jpg?width=400" 
     srcset="/image.jpg?width=400 400w,
             /image.jpg?width=800 800w,
             /image.jpg?width=1200 1200w"
     sizes="(max-width: 400px) 400px,
            (max-width: 800px) 800px,
            1200px">
```

## Argo Smart Routing

```bash
# Enable Argo (improves performance)
npm run cdn:enable-argo

# Argo Tiered Caching (Enterprise)
npm run cdn:enable-tiered-cache
```

```javascript
import { CDNManager } from './lib/cdn-manager.js';

const cdn = new CDNManager();

await cdn.enableArgo({
  smart_routing: true,
  tiered_caching: true // Enterprise only
});
```

## Load Balancing

### Create Load Balancer

```bash
# Create load balancer
npm run cdn:create-lb \
  --name "api-lb" \
  --hostname "api.example.com" \
  --origins "origin1.example.com,origin2.example.com"
```

```javascript
import { CDNManager } from './lib/cdn-manager.js';

const cdn = new CDNManager();

// Create load balancer
await cdn.createLoadBalancer({
  name: 'api-lb',
  default_pools: ['pool-1', 'pool-2'],
  fallback_pool: 'pool-fallback',
  region_pools: {
    'WNAM': ['pool-us-west'], // Western North America
    'ENAM': ['pool-us-east']  // Eastern North America
  },
  steering_policy: 'geo', // random, geo, dynamic_latency
  session_affinity: 'cookie',
  session_affinity_ttl: 3600
});

// Create origin pool
await cdn.createOriginPool({
  name: 'pool-1',
  origins: [
    {
      name: 'origin-1',
      address: '1.2.3.4',
      weight: 1,
      enabled: true
    },
    {
      name: 'origin-2',
      address: '5.6.7.8',
      weight: 1,
      enabled: true
    }
  ],
  monitor: 'health-check-1',
  notification_email: 'ops@example.com'
});
```

### Health Checks

```javascript
// Create health check monitor
await cdn.createHealthCheck({
  type: 'https',
  method: 'GET',
  path: '/health',
  port: 443,
  interval: 60, // seconds
  timeout: 5,
  retries: 2,
  expected_codes: '200',
  follow_redirects: false,
  allow_insecure: false,
  header: {
    'Host': ['api.example.com'],
    'User-Agent': ['Cloudflare-Health-Check']
  }
});
```

## Cache Analytics

```bash
# View cache statistics
npm run cdn:cache-stats

# View cache hit ratio
npm run cdn:cache-hit-ratio --since "24h"

# Export analytics
npm run cdn:export-analytics --since "7d" --output cache-analytics.json
```

```javascript
import { CDNManager } from './lib/cdn-manager.js';

const cdn = new CDNManager();

// Get cache analytics
const analytics = await cdn.getCacheAnalytics({
  since: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // Last 7 days
  metrics: ['requests', 'bandwidth', 'cacheHitRatio'],
  dimensions: ['cacheStatus', 'contentType']
});

console.log('Cache hit ratio:', analytics.cacheHitRatio);
console.log('Bandwidth saved:', analytics.bandwidthSaved);
console.log('Top cached content:', analytics.topCached);
```

## Advanced Caching Strategies

### Stale-While-Revalidate

```javascript
// Worker implementation
export default {
  async fetch(request, env, ctx) {
    const cache = caches.default;
    
    // Try cache first
    let response = await cache.match(request);
    
    if (response) {
      const age = (Date.now() - new Date(response.headers.get('date'))) / 1000;
      
      // If content is stale (> 5 minutes), revalidate in background
      if (age > 300) {
        ctx.waitUntil(
          fetch(request).then(freshResponse => {
            cache.put(request, freshResponse.clone());
          })
        );
      }
      
      return response;
    }
    
    // Fetch and cache
    response = await fetch(request);
    ctx.waitUntil(cache.put(request, response.clone()));
    
    return response;
  }
};
```

### Cache Stampede Prevention

```javascript
// Use cache lock pattern
export default {
  async fetch(request, env, ctx) {
    const cache = caches.default;
    const cacheKey = new Request(request.url, { method: 'GET' });
    
    // Try cache
    let response = await cache.match(cacheKey);
    if (response) return response;
    
    // Use KV for distributed lock
    const lockKey = `lock:${new URL(request.url).pathname}`;
    const lock = await env.LOCKS.get(lockKey);
    
    if (lock) {
      // Another request is fetching, wait and retry
      await new Promise(resolve => setTimeout(resolve, 100));
      response = await cache.match(cacheKey);
      if (response) return response;
    }
    
    // Acquire lock
    await env.LOCKS.put(lockKey, '1', { expirationTtl: 10 });
    
    try {
      // Fetch from origin
      response = await fetch(request);
      
      // Cache response
      ctx.waitUntil(cache.put(cacheKey, response.clone()));
      
      return response;
    } finally {
      // Release lock
      await env.LOCKS.delete(lockKey);
    }
  }
};
```

### Vary by Header

```javascript
// Cache different versions based on headers
export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const acceptHeader = request.headers.get('Accept') || '';
    const acceptLanguage = request.headers.get('Accept-Language') || 'en';
    
    // Create cache key including relevant headers
    const cacheKey = new Request(
      `${url.origin}${url.pathname}?accept=${acceptHeader}&lang=${acceptLanguage}`,
      {
        method: 'GET',
        headers: request.headers
      }
    );
    
    const cache = caches.default;
    let response = await cache.match(cacheKey);
    
    if (!response) {
      response = await fetch(request);
      
      // Add Vary header
      response = new Response(response.body, response);
      response.headers.set('Vary', 'Accept, Accept-Language');
      response.headers.set('Cache-Control', 'public, max-age=3600');
      
      await cache.put(cacheKey, response.clone());
    }
    
    return response;
  }
};
```

## Cache Best Practices

### 1. Set Appropriate TTLs

```javascript
const TTL_RULES = {
  '/static/': 31536000,      // 1 year (immutable)
  '/images/': 86400,          // 1 day
  '/api/public': 300,         // 5 minutes
  '/api/dynamic': 0,          // Don't cache
  '/': 3600                   // 1 hour
};
```

### 2. Use Cache Tags

```javascript
// Add cache tags to responses
export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const response = await fetch(request);
    
    // Tag by resource type
    const tags = [];
    if (url.pathname.includes('/products/')) {
      tags.push('products', `product-${url.pathname.split('/').pop()}`);
    }
    if (url.pathname.includes('/users/')) {
      tags.push('users', `user-${url.pathname.split('/').pop()}`);
    }
    
    if (tags.length > 0) {
      response.headers.set('Cache-Tag', tags.join(','));
    }
    
    return response;
  }
};
```

### 3. Implement Cache Warming

```bash
# Warm cache for important URLs
npm run cdn:warm-cache urls.txt
```

```javascript
// warm-cache.js
import { CDNManager } from './lib/cdn-manager.js';
import fs from 'fs';

const cdn = new CDNManager();

async function warmCache(urls) {
  for (const url of urls) {
    try {
      await fetch(url, {
        headers: {
          'User-Agent': 'Cache-Warmer',
          'Cache-Control': 'no-cache' // Force origin fetch
        }
      });
      console.log(`Warmed: ${url}`);
    } catch (error) {
      console.error(`Failed to warm ${url}:`, error.message);
    }
  }
}

const urls = fs.readFileSync('urls.txt', 'utf-8').split('\n').filter(Boolean);
warmCache(urls);
```

### 4. Monitor Cache Performance

```javascript
// Track cache metrics
export default {
  async fetch(request, env, ctx) {
    const cache = caches.default;
    const start = Date.now();
    
    const cached = await cache.match(request);
    const cacheHit = !!cached;
    
    const response = cached || await fetch(request);
    
    // Log metrics
    ctx.waitUntil(
      env.ANALYTICS.put(`metrics:${Date.now()}`, JSON.stringify({
        url: request.url,
        cacheHit,
        duration: Date.now() - start,
        timestamp: new Date().toISOString()
      }))
    );
    
    // Add cache status header
    response.headers.set('X-Cache-Status', cacheHit ? 'HIT' : 'MISS');
    
    return response;
  }
};
```

### 5. Implement Origin Shield

```bash
# Enable Tiered Cache (Enterprise)
npm run cdn:enable-tiered-cache
```

## Troubleshooting

### Cache Not Working

```bash
# Check cache status headers
curl -I https://example.com/page.html | grep -i cache

# Expected headers:
# CF-Cache-Status: HIT/MISS/EXPIRED/BYPASS
# Cache-Control: public, max-age=3600
```

### Low Cache Hit Ratio

```bash
# Analyze cache misses
npm run cdn:analyze-misses

# Common issues:
# - Query strings vary
# - Cookies present
# - No Cache-Control headers
# - Dynamic content
```

### Stale Content

```bash
# Purge specific URLs
npm run cdn:purge-urls "https://example.com/old-page.html"

# Set shorter TTL
npm run cdn:set-browser-ttl 1800  # 30 minutes
```

## Resources

- [Cache Documentation](https://developers.cloudflare.com/cache/)
- [Cache Rules](https://developers.cloudflare.com/cache/how-to/cache-rules/)
- [Image Optimization](https://developers.cloudflare.com/images/)
- [Load Balancing](https://developers.cloudflare.com/load-balancing/)
