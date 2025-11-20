# Cloudflare Toolkit

A comprehensive toolkit for managing Cloudflare infrastructure, including tunnels, Workers, Pages, WAF, CDN, and more.

## Features

- **Tunnel Management**: Create, configure, and manage Cloudflare Tunnels
- **Certificate Management**: Secure handling of SSL/TLS certificates
- **API Key Management**: Secure storage and rotation of Cloudflare API keys
- **Worker Deployment**: Simplified deployment of Cloudflare Workers
- **Pages Deployment**: Easy deployment to Cloudflare Pages
- **WAF Configuration**: Web Application Firewall rule management
- **CDN Management**: Cache and CDN configuration utilities

## Quick Start

### Prerequisites

- Node.js 18+ and npm 9+
- Cloudflare account with API access
- `cloudflared` CLI (for tunnel management)

### Installation

```bash
# From the repository root
cd tools/cloudflare-toolkit
npm install

# Install cloudflared CLI (if not already installed)
# macOS
brew install cloudflare/cloudflare/cloudflared

# Linux
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# Windows
winget install --id Cloudflare.cloudflared
```

### Configuration

1. Set up your Cloudflare API credentials:

```bash
# Copy the example configuration
cp config/example.env config/.env

# Edit with your credentials
# Required:
# - CLOUDFLARE_API_TOKEN or CLOUDFLARE_API_KEY + CLOUDFLARE_EMAIL
# - CLOUDFLARE_ACCOUNT_ID
# - CLOUDFLARE_ZONE_ID (for domain-specific operations)
```

2. For tunnel management, authenticate cloudflared:

```bash
cloudflared tunnel login
```

## Usage

### Tunnel Management

```bash
# Create a new tunnel
npm run tunnel:create my-app-tunnel

# List all tunnels
npm run tunnel:list

# Configure tunnel routes
npm run tunnel:route my-app-tunnel app.example.com

# Delete a tunnel
npm run tunnel:delete my-app-tunnel

# Run tunnel
npm run tunnel:run my-app-tunnel
```

### API Key Management

```bash
# Store API key securely
npm run api:store

# Rotate API key
npm run api:rotate

# List API tokens
npm run api:list-tokens

# Verify API access
npm run api:verify
```

### Worker Deployment

```bash
# Deploy a worker
npm run worker:deploy my-worker ./path/to/worker.js

# List workers
npm run worker:list

# Update worker
npm run worker:update my-worker

# Delete worker
npm run worker:delete my-worker
```

### Pages Deployment

```bash
# Deploy to Pages
npm run pages:deploy my-site ./build

# List Pages projects
npm run pages:list

# Create new Pages project
npm run pages:create my-site
```

### WAF Management

```bash
# Create WAF rule
npm run waf:create-rule

# List WAF rules
npm run waf:list-rules

# Enable/disable rule
npm run waf:toggle-rule <rule-id>

# Create rate limiting rule
npm run waf:rate-limit
```

### CDN Management

```bash
# Purge cache
npm run cdn:purge-cache

# Configure cache rules
npm run cdn:cache-rules

# Set up custom cache TTL
npm run cdn:set-ttl
```

## Documentation

- [Cloudflare Tunnels Guide](./docs/tunnels.md)
- [Certificate Management](./docs/certificates.md)
- [API Key Security](./docs/api-keys.md)
- [Worker Development Guide](./docs/workers.md)
- [Pages Deployment Guide](./docs/pages.md)
- [WAF Configuration](./docs/waf.md)
- [CDN Optimization](./docs/cdn.md)

## Library Usage

You can also use the toolkit as a library in your own Node.js projects:

```javascript
const {
  TunnelManager,
  WorkerManager,
  PagesManager,
  WAFManager,
  CDNManager
} = require('./lib');

// Create a tunnel
const tunnelManager = new TunnelManager();
await tunnelManager.create('my-tunnel');

// Deploy a worker
const workerManager = new WorkerManager();
await workerManager.deploy('my-worker', './worker.js');

// Configure WAF
const wafManager = new WAFManager();
await wafManager.createRule({
  expression: '(http.request.uri.path contains "/admin")',
  action: 'challenge'
});
```

## Examples

See the [examples](./examples) directory for complete usage examples:

- [Basic Tunnel Setup](./examples/tunnel-basic.js)
- [Worker with Routes](./examples/worker-with-routes.js)
- [Pages with Custom Domain](./examples/pages-custom-domain.js)
- [WAF Security Rules](./examples/waf-security.js)
- [CDN Cache Strategy](./examples/cdn-cache.js)

## Security Best Practices

1. **Never commit API keys** - Always use environment variables
2. **Use API tokens with minimal permissions** - Create scoped tokens
3. **Rotate credentials regularly** - Use the rotation scripts
4. **Enable 2FA** on your Cloudflare account
5. **Use Zero Trust Access** for tunnel authentication
6. **Monitor audit logs** regularly

## Contributing

This toolkit is part of the Kingdom Monorepo. Follow the general contribution guidelines.

## License

See the root LICENSE file for details.
