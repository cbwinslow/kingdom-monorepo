# Cloudflare Pages Guide

Deploy your static sites and JAMstack applications with Cloudflare Pages.

## Overview

Cloudflare Pages is a platform for deploying:
- Static websites
- JAMstack applications
- Single Page Applications (SPAs)
- Server-Side Rendered (SSR) sites with Functions

**Features:**
- Automatic builds from Git
- Unlimited bandwidth
- Built-in CI/CD
- Preview deployments for branches
- Instant rollbacks
- Custom domains with SSL
- Edge Functions (Workers)

## Quick Start

### Deploy via Dashboard

1. Go to Pages in Cloudflare Dashboard
2. Click "Create a project"
3. Connect your Git provider (GitHub/GitLab)
4. Select repository
5. Configure build settings
6. Deploy

### Deploy via Wrangler CLI

```bash
# Install wrangler
npm install -g wrangler

# Build your site
npm run build

# Deploy
npx wrangler pages deploy ./dist --project-name=my-site

# Deploy with commit message
npx wrangler pages deploy ./dist \
  --project-name=my-site \
  --commit-message="Update homepage"
```

### Deploy via Toolkit

```bash
# Create Pages project
npm run pages:create my-site

# Deploy directory
npm run pages:deploy my-site ./dist

# Deploy with branch
npm run pages:deploy my-site ./dist --branch=production
```

## Framework Support

### React

```json
{
  "build": {
    "command": "npm run build",
    "output": "build"
  }
}
```

```bash
# Create React app
npx create-react-app my-app
cd my-app

# Build
npm run build

# Deploy
npx wrangler pages deploy ./build --project-name=my-app
```

### Next.js

```javascript
// next.config.js
module.exports = {
  output: 'export', // For static export
  // Or keep default for SSR with Pages Functions
};
```

```bash
# Build
npm run build

# Deploy (static)
npx wrangler pages deploy ./out --project-name=my-app

# Deploy (with SSR)
npx wrangler pages deploy ./ --project-name=my-app
```

### Vue.js

```javascript
// vite.config.js
export default {
  build: {
    outDir: 'dist'
  }
};
```

```bash
# Build
npm run build

# Deploy
npx wrangler pages deploy ./dist --project-name=my-app
```

### Svelte

```bash
# Build
npm run build

# Deploy
npx wrangler pages deploy ./build --project-name=my-app
```

### Astro

```javascript
// astro.config.mjs
import { defineConfig } from 'astro/config';
import cloudflare from '@astrojs/cloudflare';

export default defineConfig({
  output: 'hybrid', // or 'server'
  adapter: cloudflare()
});
```

```bash
# Build
npm run build

# Deploy
npx wrangler pages deploy ./dist --project-name=my-app
```

### Gatsby

```bash
# Build
npm run build

# Deploy
npx wrangler pages deploy ./public --project-name=my-app
```

### Hugo

```toml
# config.toml
baseURL = "https://my-site.pages.dev"
publishDir = "public"
```

```bash
# Build
hugo

# Deploy
npx wrangler pages deploy ./public --project-name=my-site
```

## Build Configuration

### Environment Variables

```bash
# Set build environment variables
npx wrangler pages project create my-site

# Add environment variables
npx wrangler pages secret put DATABASE_URL --project-name=my-site
# Enter value: postgresql://...

# List secrets
npx wrangler pages secret list --project-name=my-site
```

### Build Settings

```toml
# wrangler.toml for Pages
name = "my-site"
pages_build_output_dir = "./dist"

[build]
command = "npm run build"
cwd = ""

[build.environment]
NODE_VERSION = "18"
NPM_VERSION = "9"
```

### Custom Build Commands

```json
{
  "name": "my-site",
  "scripts": {
    "build": "vite build && npm run postbuild",
    "postbuild": "node scripts/generate-sitemap.js"
  }
}
```

## Pages Functions

Add serverless functions to your static site using Workers.

### File-based Routing

```
functions/
├── api/
│   ├── users.js          → /api/users
│   ├── users/[id].js     → /api/users/:id
│   └── posts/
│       └── [[path]].js   → /api/posts/*
├── _middleware.js        → Runs for all routes
└── index.js              → /
```

### Basic Function

```javascript
// functions/api/hello.js
export async function onRequest(context) {
  return new Response('Hello from Pages Function!');
}
```

### With Parameters

```javascript
// functions/api/users/[id].js
export async function onRequest(context) {
  const { id } = context.params;
  
  const user = await context.env.DB
    .prepare('SELECT * FROM users WHERE id = ?')
    .bind(id)
    .first();
  
  return Response.json(user);
}
```

### HTTP Methods

```javascript
// functions/api/posts.js
export async function onRequestGet(context) {
  // Handle GET /api/posts
  const posts = await getPosts();
  return Response.json(posts);
}

export async function onRequestPost(context) {
  // Handle POST /api/posts
  const post = await context.request.json();
  await createPost(post);
  return Response.json({ success: true });
}

export async function onRequestPut(context) {
  // Handle PUT /api/posts
  return Response.json({ method: 'PUT' });
}

export async function onRequestDelete(context) {
  // Handle DELETE /api/posts
  return Response.json({ method: 'DELETE' });
}
```

### Middleware

```javascript
// functions/_middleware.js
export async function onRequest(context) {
  // Add CORS headers
  const response = await context.next();
  response.headers.set('Access-Control-Allow-Origin', '*');
  return response;
}

// Auth middleware for specific path
// functions/admin/_middleware.js
export async function onRequest(context) {
  const token = context.request.headers.get('Authorization');
  
  if (!token || !verifyToken(token)) {
    return new Response('Unauthorized', { status: 401 });
  }
  
  return context.next();
}
```

### Advanced Middleware

```javascript
// functions/_middleware.js
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization'
};

export async function onRequest(context) {
  // Handle CORS preflight
  if (context.request.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  // Logging
  console.log(`${context.request.method} ${context.request.url}`);
  const start = Date.now();

  try {
    // Process request
    const response = await context.next();
    
    // Add headers
    Object.entries(corsHeaders).forEach(([key, value]) => {
      response.headers.set(key, value);
    });
    
    // Log response time
    console.log(`Response time: ${Date.now() - start}ms`);
    
    return response;
  } catch (error) {
    console.error('Error:', error);
    return new Response('Internal Server Error', { status: 500 });
  }
}
```

### Using Bindings

```toml
# wrangler.toml
[[kv_namespaces]]
binding = "MY_KV"
id = "your-kv-namespace-id"

[[d1_databases]]
binding = "DB"
database_name = "my-database"
database_id = "your-database-id"
```

```javascript
// functions/api/data.js
export async function onRequest(context) {
  // Access KV
  const value = await context.env.MY_KV.get('key');
  
  // Access D1
  const users = await context.env.DB
    .prepare('SELECT * FROM users')
    .all();
  
  return Response.json({ value, users });
}
```

## Custom Domains

### Add Custom Domain

```bash
# Via Wrangler
npx wrangler pages domain add example.com --project-name=my-site

# Via Toolkit
npm run pages:add-domain my-site example.com
```

### DNS Configuration

```bash
# Add CNAME record
# Name: @ (or subdomain)
# Target: my-site.pages.dev

# Or use Cloudflare nameservers for automatic configuration
```

### SSL Certificate

SSL certificates are automatically provisioned for custom domains.

## Redirects & Headers

### _redirects File

```
# _redirects
/old-page  /new-page  301
/blog/*    /articles/:splat  302
/api/*     https://api.example.com/:splat  200
```

### _headers File

```
# _headers
/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin

/api/*
  Access-Control-Allow-Origin: *
  Cache-Control: no-cache

/assets/*
  Cache-Control: public, max-age=31536000, immutable
```

### Advanced Redirects

```javascript
// functions/_middleware.js
export async function onRequest(context) {
  const url = new URL(context.request.url);
  
  // Redirect www to non-www
  if (url.hostname.startsWith('www.')) {
    return Response.redirect(
      url.href.replace('www.', ''),
      301
    );
  }
  
  // Redirect old paths
  if (url.pathname === '/old-blog') {
    return Response.redirect('/blog', 301);
  }
  
  return context.next();
}
```

## Preview Deployments

Every branch gets a preview URL:

```
# Main branch
https://my-site.pages.dev

# Feature branch
https://feature-branch.my-site.pages.dev

# Pull request
https://pr-123.my-site.pages.dev
```

### Configure Branch Deployments

```bash
# Set production branch
npx wrangler pages project create my-site \
  --production-branch=main

# Set preview branches pattern
# Matches: feature/*, hotfix/*
npx wrangler pages project update my-site \
  --branch-preview-pattern="feature/*,hotfix/*"
```

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy to Cloudflare Pages

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Build
        run: npm run build
      
      - name: Deploy to Cloudflare Pages
        uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
          command: pages deploy ./dist --project-name=my-site
```

### GitLab CI

```yaml
# .gitlab-ci.yml
deploy:
  image: node:18
  stage: deploy
  script:
    - npm ci
    - npm run build
    - npx wrangler pages deploy ./dist --project-name=my-site
  only:
    - main
  variables:
    CLOUDFLARE_API_TOKEN: $CLOUDFLARE_API_TOKEN
    CLOUDFLARE_ACCOUNT_ID: $CLOUDFLARE_ACCOUNT_ID
```

### CircleCI

```yaml
# .circleci/config.yml
version: 2.1

jobs:
  deploy:
    docker:
      - image: cimg/node:18.0
    steps:
      - checkout
      - run: npm ci
      - run: npm run build
      - run: npx wrangler pages deploy ./dist --project-name=my-site

workflows:
  deploy:
    jobs:
      - deploy:
          filters:
            branches:
              only: main
```

## Analytics & Monitoring

### Web Analytics

```html
<!-- Add to your site -->
<script defer src='https://static.cloudflareinsights.com/beacon.min.js' 
        data-cf-beacon='{"token": "your-token-here"}'></script>
```

### Real User Monitoring

Automatically enabled for all Pages projects. View metrics in the dashboard.

### Custom Metrics

```javascript
// functions/_middleware.js
export async function onRequest(context) {
  const start = Date.now();
  
  const response = await context.next();
  
  // Log custom metrics
  context.waitUntil(
    logMetrics({
      path: new URL(context.request.url).pathname,
      duration: Date.now() - start,
      status: response.status
    })
  );
  
  return response;
}
```

## Advanced Usage

### Multi-Environment Setup

```bash
# Production
npx wrangler pages deploy ./dist \
  --project-name=my-site \
  --branch=production

# Staging
npx wrangler pages deploy ./dist \
  --project-name=my-site-staging \
  --branch=staging

# Development
npx wrangler pages dev ./dist
```

### Dynamic Rendering

```javascript
// functions/[[path]].js
import { renderPage } from '../src/renderer.js';

export async function onRequest(context) {
  const url = new URL(context.request.url);
  
  // Server-side render for bots
  const userAgent = context.request.headers.get('user-agent');
  if (isBot(userAgent)) {
    const html = await renderPage(url.pathname);
    return new Response(html, {
      headers: { 'Content-Type': 'text/html' }
    });
  }
  
  // Return static HTML for browsers
  return context.next();
}
```

### API Proxy

```javascript
// functions/api/[[path]].js
export async function onRequest(context) {
  const url = new URL(context.request.url);
  const apiPath = url.pathname.replace('/api', '');
  
  // Proxy to backend API
  const apiUrl = `https://backend.example.com${apiPath}${url.search}`;
  
  const response = await fetch(apiUrl, {
    method: context.request.method,
    headers: {
      'Authorization': context.env.API_KEY,
      'Content-Type': 'application/json'
    },
    body: context.request.body
  });
  
  return response;
}
```

## Best Practices

1. **Optimize Assets**: Use image optimization, minify CSS/JS
2. **Use CDN Caching**: Leverage Cloudflare's global network
3. **Implement CSP**: Set Content Security Policy headers
4. **Enable Analytics**: Monitor performance and user behavior
5. **Use Preview Deploys**: Test changes before production
6. **Version Assets**: Use content hashing for cache busting
7. **Implement Monitoring**: Track errors and performance
8. **Use Functions Sparingly**: Keep most content static
9. **Optimize Bundle Size**: Smaller = faster
10. **Test Locally**: Use `wrangler pages dev`

## Troubleshooting

### Build Failures

```bash
# Check build logs
npx wrangler pages deployment list --project-name=my-site

# View specific deployment
npx wrangler pages deployment view <deployment-id>
```

### Function Errors

```bash
# Stream function logs
npx wrangler pages deployment tail --project-name=my-site
```

### Rollback

```bash
# List deployments
npx wrangler pages deployment list --project-name=my-site

# Rollback to previous deployment
npx wrangler pages deployment rollback <deployment-id>
```

## Resources

- [Pages Documentation](https://developers.cloudflare.com/pages/)
- [Framework Guides](https://developers.cloudflare.com/pages/framework-guides/)
- [Functions Documentation](https://developers.cloudflare.com/pages/functions/)
