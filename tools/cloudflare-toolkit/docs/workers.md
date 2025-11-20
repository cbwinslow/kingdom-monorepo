# Cloudflare Workers Guide

Deploy serverless JavaScript code at the edge with Cloudflare Workers.

## Overview

Cloudflare Workers run your code at Cloudflare's edge network across 300+ cities worldwide, providing:

- **Low Latency**: Execute close to users
- **High Performance**: V8 isolates, not containers
- **Automatic Scaling**: Handle any traffic volume
- **No Cold Starts**: Always-warm execution
- **Global Distribution**: Deployed everywhere instantly

## Quick Start

### Basic Worker

```javascript
// worker.js
export default {
  async fetch(request, env, ctx) {
    return new Response('Hello World!', {
      headers: { 'Content-Type': 'text/plain' }
    });
  }
};
```

### Deploy

```bash
# Using the toolkit
npm run worker:deploy hello-world ./worker.js

# Using wrangler CLI
npx wrangler deploy
```

## Worker Structure

### ES Modules Format (Recommended)

```javascript
export default {
  async fetch(request, env, ctx) {
    // Handle HTTP requests
    return new Response('OK');
  },

  async scheduled(event, env, ctx) {
    // Handle cron triggers
    console.log('Cron executed');
  },

  async queue(batch, env, ctx) {
    // Handle queue messages
    for (const message of batch.messages) {
      console.log(message.body);
    }
  },

  async email(message, env, ctx) {
    // Handle email routing
    await message.forward('user@example.com');
  }
};
```

### Service Worker Format (Legacy)

```javascript
addEventListener('fetch', (event) => {
  event.respondWith(handleRequest(event.request));
});

async function handleRequest(request) {
  return new Response('Hello World!');
}
```

## Request Handling

### Basic Request/Response

```javascript
export default {
  async fetch(request) {
    const { pathname, searchParams } = new URL(request.url);
    const method = request.method;
    const headers = request.headers;

    return new Response(JSON.stringify({
      pathname,
      method,
      params: Object.fromEntries(searchParams)
    }), {
      headers: { 'Content-Type': 'application/json' }
    });
  }
};
```

### Reading Request Body

```javascript
export default {
  async fetch(request) {
    if (request.method === 'POST') {
      const contentType = request.headers.get('content-type');

      if (contentType?.includes('application/json')) {
        const json = await request.json();
        return Response.json({ received: json });
      }

      if (contentType?.includes('text/plain')) {
        const text = await request.text();
        return new Response(`You sent: ${text}`);
      }

      if (contentType?.includes('form')) {
        const formData = await request.formData();
        return Response.json(Object.fromEntries(formData));
      }
    }

    return new Response('Send a POST request');
  }
};
```

### Routing

```javascript
export default {
  async fetch(request) {
    const url = new URL(request.url);
    const path = url.pathname;

    // Route matching
    if (path === '/') {
      return new Response('Home');
    }

    if (path === '/api/users') {
      return handleUsers(request);
    }

    if (path.startsWith('/api/')) {
      return handleAPI(request);
    }

    // Pattern matching
    const userMatch = path.match(/^\/users\/(\d+)$/);
    if (userMatch) {
      const userId = userMatch[1];
      return handleUser(userId);
    }

    return new Response('Not Found', { status: 404 });
  }
};
```

## Working with KV Storage

### Binding KV Namespace

```toml
# wrangler.toml
[[kv_namespaces]]
binding = "MY_KV"
id = "your-kv-namespace-id"
```

### Using KV

```javascript
export default {
  async fetch(request, env) {
    // Get value
    const value = await env.MY_KV.get('key');

    // Get with metadata
    const { value, metadata } = await env.MY_KV.getWithMetadata('key');

    // Put value
    await env.MY_KV.put('key', 'value');

    // Put with expiration (TTL in seconds)
    await env.MY_KV.put('key', 'value', { expirationTtl: 3600 });

    // Put with metadata
    await env.MY_KV.put('key', 'value', {
      metadata: { userId: 123, tags: ['important'] }
    });

    // Delete
    await env.MY_KV.delete('key');

    // List keys
    const keys = await env.MY_KV.list({ prefix: 'user:' });

    return Response.json({ value });
  }
};
```

## Working with Durable Objects

### Define Durable Object

```javascript
export class Counter {
  constructor(state, env) {
    this.state = state;
    this.count = 0;
  }

  async fetch(request) {
    // Get current count
    this.count = (await this.state.storage.get('count')) || 0;

    // Increment
    this.count++;

    // Save
    await this.state.storage.put('count', this.count);

    return Response.json({ count: this.count });
  }
}

export default {
  async fetch(request, env) {
    // Get Durable Object instance
    const id = env.COUNTER.idFromName('global-counter');
    const stub = env.COUNTER.get(id);

    // Forward request to Durable Object
    return stub.fetch(request);
  }
};
```

### Configuration

```toml
# wrangler.toml
[[durable_objects.bindings]]
name = "COUNTER"
class_name = "Counter"
script_name = "my-worker"

[[migrations]]
tag = "v1"
new_classes = ["Counter"]
```

## Working with R2 Storage

```javascript
export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const key = url.pathname.slice(1);

    if (request.method === 'GET') {
      // Get object
      const object = await env.MY_BUCKET.get(key);
      if (!object) {
        return new Response('Not Found', { status: 404 });
      }
      return new Response(object.body);
    }

    if (request.method === 'PUT') {
      // Upload object
      await env.MY_BUCKET.put(key, request.body);
      return new Response('Uploaded');
    }

    if (request.method === 'DELETE') {
      // Delete object
      await env.MY_BUCKET.delete(key);
      return new Response('Deleted');
    }

    // List objects
    const list = await env.MY_BUCKET.list({ prefix: 'images/' });
    return Response.json(list);
  }
};
```

## Cron Triggers

```toml
# wrangler.toml
[triggers]
crons = ["0 0 * * *", "*/30 * * * *"]
```

```javascript
export default {
  async scheduled(event, env, ctx) {
    // Runs on cron schedule
    console.log('Cron job executed at', event.scheduledTime);

    // Perform background task
    ctx.waitUntil(performCleanup());
  }
};

async function performCleanup() {
  // Cleanup old data, send reports, etc.
}
```

## Environment Variables & Secrets

```toml
# wrangler.toml
[vars]
ENVIRONMENT = "production"
API_URL = "https://api.example.com"
```

```bash
# Set secrets (not in wrangler.toml!)
npx wrangler secret put API_KEY
# Enter the secret value: ********
```

```javascript
export default {
  async fetch(request, env) {
    // Access environment variables
    const apiUrl = env.API_URL;
    const apiKey = env.API_KEY; // Secret

    const response = await fetch(apiUrl, {
      headers: { 'Authorization': `Bearer ${apiKey}` }
    });

    return response;
  }
};
```

## Advanced Examples

### API Gateway

```javascript
import { Router } from 'itty-router';

const router = Router();

// Middleware
const withAuth = (request, env) => {
  const token = request.headers.get('Authorization')?.replace('Bearer ', '');
  if (!token || token !== env.API_KEY) {
    return new Response('Unauthorized', { status: 401 });
  }
};

// Routes
router
  .get('/api/users', withAuth, async (request, env) => {
    const users = await env.DB.prepare('SELECT * FROM users').all();
    return Response.json(users);
  })
  .post('/api/users', withAuth, async (request, env) => {
    const user = await request.json();
    const result = await env.DB.prepare(
      'INSERT INTO users (name, email) VALUES (?, ?)'
    ).bind(user.name, user.email).run();
    return Response.json({ id: result.lastInsertRowid });
  })
  .get('/api/users/:id', withAuth, async (request, env) => {
    const { id } = request.params;
    const user = await env.DB.prepare(
      'SELECT * FROM users WHERE id = ?'
    ).bind(id).first();
    return Response.json(user || {});
  })
  .delete('/api/users/:id', withAuth, async (request, env) => {
    const { id } = request.params;
    await env.DB.prepare('DELETE FROM users WHERE id = ?').bind(id).run();
    return new Response('Deleted');
  })
  .all('*', () => new Response('Not Found', { status: 404 }));

export default {
  fetch: router.fetch
};
```

### Reverse Proxy

```javascript
export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    // Route to different origins based on path
    if (url.pathname.startsWith('/api/')) {
      return fetch('https://api.example.com' + url.pathname, request);
    }

    if (url.pathname.startsWith('/images/')) {
      return fetch('https://cdn.example.com' + url.pathname, request);
    }

    // Default origin
    return fetch('https://www.example.com' + url.pathname, request);
  }
};
```

### Image Resizing

```javascript
export default {
  async fetch(request) {
    const url = new URL(request.url);
    const width = url.searchParams.get('width') || 800;
    const quality = url.searchParams.get('quality') || 85;

    // Fetch original image
    const imageRequest = new Request(url.origin + url.pathname, {
      cf: {
        image: {
          width: parseInt(width),
          quality: parseInt(quality),
          format: 'auto'
        }
      }
    });

    return fetch(imageRequest);
  }
};
```

### Rate Limiting

```javascript
export default {
  async fetch(request, env) {
    const ip = request.headers.get('CF-Connecting-IP');
    const key = `rate-limit:${ip}`;

    // Get current count
    const count = parseInt(await env.MY_KV.get(key) || '0');

    // Check limit
    if (count >= 100) {
      return new Response('Rate limit exceeded', {
        status: 429,
        headers: { 'Retry-After': '60' }
      });
    }

    // Increment counter
    await env.MY_KV.put(key, (count + 1).toString(), {
      expirationTtl: 60 // 60 seconds
    });

    // Process request
    return new Response('OK');
  }
};
```

## Deployment

### Using Toolkit

```bash
# Deploy worker
npm run worker:deploy my-worker ./worker.js

# Deploy with routes
npm run worker:deploy my-worker ./worker.js \
  --route "example.com/*" \
  --route "*.example.com/*"

# Deploy to specific environment
npm run worker:deploy my-worker ./worker.js --env production
```

### Using Wrangler

```bash
# Initialize project
npx wrangler init my-worker

# Develop locally
npx wrangler dev

# Deploy
npx wrangler deploy

# Deploy to specific environment
npx wrangler deploy --env production

# Tail logs
npx wrangler tail

# View deployments
npx wrangler deployments list
```

### Configuration

```toml
# wrangler.toml
name = "my-worker"
main = "src/index.js"
compatibility_date = "2024-01-01"
account_id = "your-account-id"

# Routes
routes = [
  { pattern = "example.com/*", zone_name = "example.com" },
  { pattern = "api.example.com/*", zone_name = "example.com" }
]

# Environment variables
[vars]
ENVIRONMENT = "production"

# KV Namespaces
[[kv_namespaces]]
binding = "MY_KV"
id = "your-kv-namespace-id"

# Durable Objects
[[durable_objects.bindings]]
name = "MY_OBJECT"
class_name = "MyObject"
script_name = "my-worker"

# R2 Buckets
[[r2_buckets]]
binding = "MY_BUCKET"
bucket_name = "my-bucket"

# D1 Databases
[[d1_databases]]
binding = "DB"
database_name = "my-database"
database_id = "your-database-id"

# Environment-specific config
[env.production]
vars = { ENVIRONMENT = "production" }
routes = [
  { pattern = "example.com/*", zone_name = "example.com" }
]

[env.staging]
vars = { ENVIRONMENT = "staging" }
routes = [
  { pattern = "staging.example.com/*", zone_name = "example.com" }
]
```

## Testing

### Unit Tests

```javascript
// worker.test.js
import { describe, it, expect } from 'vitest';
import worker from './worker.js';

describe('Worker', () => {
  it('returns hello world', async () => {
    const request = new Request('https://example.com/');
    const env = {};
    const ctx = {
      waitUntil: () => {},
      passThroughOnException: () => {}
    };

    const response = await worker.fetch(request, env, ctx);
    expect(response.status).toBe(200);
    expect(await response.text()).toBe('Hello World!');
  });
});
```

### Integration Tests

```bash
# Run tests
npx vitest

# Run with wrangler
npx wrangler dev --test
```

## Monitoring & Debugging

### Logs

```bash
# Stream logs
npx wrangler tail

# Filter logs
npx wrangler tail --status error

# View specific worker
npx wrangler tail my-worker
```

### Analytics

```javascript
export default {
  async fetch(request, env, ctx) {
    const start = Date.now();

    try {
      const response = await handleRequest(request);
      
      // Log metrics
      ctx.waitUntil(logMetrics({
        path: new URL(request.url).pathname,
        method: request.method,
        status: response.status,
        duration: Date.now() - start
      }));

      return response;
    } catch (error) {
      // Log errors
      ctx.waitUntil(logError(error));
      return new Response('Internal Server Error', { status: 500 });
    }
  }
};
```

## Best Practices

1. **Keep Workers Small**: < 1MB after compression
2. **Use Environment Variables**: Never hardcode secrets
3. **Implement Error Handling**: Always catch and log errors
4. **Use ctx.waitUntil()**: For background tasks
5. **Cache Effectively**: Use Cache API for static content
6. **Minimize Dependencies**: Smaller = faster cold starts
7. **Use KV for Global State**: Don't rely on global variables
8. **Test Locally**: Use `wrangler dev` before deploying
9. **Monitor Performance**: Track response times and errors
10. **Version Your Workers**: Use deployments for rollbacks

## Resources

- [Workers Documentation](https://developers.cloudflare.com/workers/)
- [Examples Repository](https://github.com/cloudflare/workers-sdk/tree/main/templates)
- [Tutorials](https://developers.cloudflare.com/workers/tutorials/)
