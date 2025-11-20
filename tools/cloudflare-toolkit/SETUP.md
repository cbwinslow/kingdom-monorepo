# Cloudflare Toolkit Setup Guide

Complete setup guide for the Cloudflare Toolkit.

## Prerequisites

1. **Node.js 18+** and **npm 9+**
   ```bash
   node --version  # Should be v18.0.0 or higher
   npm --version   # Should be 9.0.0 or higher
   ```

2. **Cloudflare Account**
   - Sign up at https://dash.cloudflare.com/sign-up
   - Add at least one domain to your account

3. **Cloudflare API Token or API Key**
   - Option A (Recommended): Create an API Token
     - Go to https://dash.cloudflare.com/profile/api-tokens
     - Click "Create Token"
     - Use a template or create custom token with required permissions
   
   - Option B (Legacy): Use Global API Key
     - Go to https://dash.cloudflare.com/profile/api-tokens
     - View Global API Key

4. **cloudflared CLI** (for tunnel management)
   ```bash
   # macOS
   brew install cloudflare/cloudflare/cloudflared

   # Linux
   wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
   sudo dpkg -i cloudflared-linux-amd64.deb

   # Windows
   winget install --id Cloudflare.cloudflared
   ```

## Installation

### 1. Navigate to the toolkit directory

```bash
cd tools/cloudflare-toolkit
```

### 2. Install dependencies

```bash
npm install
```

This will install:
- `cloudflare` - Official Cloudflare SDK
- `dotenv` - Environment variable management
- `inquirer` - Interactive CLI prompts
- `chalk` - Terminal styling
- `ora` - Loading spinners

### 3. Configure credentials

Choose one of the following methods:

#### Method A: Interactive Setup (Recommended)

```bash
npm run api:store
```

This will:
- Prompt for your authentication method (API Token or API Key)
- Prompt for Account ID and Zone ID
- Encrypt and store credentials securely
- Set up a master password for credential encryption

#### Method B: Environment Variables

```bash
# Copy the example configuration
cp config/example.env config/.env

# Edit the file with your credentials
nano config/.env
```

Fill in your credentials:
```env
# Use API Token (recommended)
CLOUDFLARE_API_TOKEN=your_api_token_here

# OR use API Key (legacy)
# CLOUDFLARE_API_KEY=your_global_api_key
# CLOUDFLARE_EMAIL=your_email@example.com

# Required
CLOUDFLARE_ACCOUNT_ID=your_account_id_here
CLOUDFLARE_ZONE_ID=your_zone_id_here
```

### 4. Verify setup

```bash
npm run api:verify
```

This will:
- Verify your API credentials
- Display account information
- Display zone information (if zone ID is set)
- Confirm everything is configured correctly

If verification succeeds, you're ready to use the toolkit!

## Finding Your IDs

### Account ID

1. Go to https://dash.cloudflare.com/
2. Select any domain
3. Look at the URL: `https://dash.cloudflare.com/{account_id}/...`
4. Or scroll down in the Overview tab to find your Account ID

### Zone ID

1. Go to https://dash.cloudflare.com/
2. Select your domain
3. Scroll down in the Overview tab
4. Find "Zone ID" in the API section on the right

## Quick Start Examples

### Tunnel Management

```bash
# Authenticate cloudflared (one-time setup)
cloudflared tunnel login

# Create a tunnel
npm run tunnel:create my-app-tunnel

# Create DNS route
npm run tunnel:route my-app-tunnel app.example.com

# List tunnels
npm run tunnel:list

# Run tunnel (after configuring ~/.cloudflared/config.yml)
npm run tunnel:run my-app-tunnel
```

### Worker Deployment

```bash
# Create a simple worker script
cat > /tmp/worker.js << 'EOF'
export default {
  async fetch(request) {
    return new Response('Hello from Worker!');
  }
};
EOF

# Deploy the worker
npm run worker:deploy my-worker /tmp/worker.js

# List workers
npm run worker:list
```

### WAF Configuration

```bash
# Create a firewall rule (interactive)
npm run waf:create-rule

# List all rules
npm run waf:list-rules
```

### CDN Cache Management

```bash
# Purge specific URLs
npm run cdn:purge-cache --urls "https://example.com/page1.html,https://example.com/page2.html"

# Purge all cache (use with caution!)
npm run cdn:purge-cache --all
```

### Pages Deployment

```bash
# Build your site first
npm run build  # or whatever your build command is

# Deploy to Pages
npm run pages:deploy my-site ./dist

# List Pages projects
npm run pages:list
```

## Using as a Library

You can also use the toolkit as a library in your own Node.js projects:

```javascript
import {
  TunnelManager,
  WorkerManager,
  WAFManager,
  CDNManager
} from './lib/index.js';

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

// Purge cache
const cdnManager = new CDNManager();
await cdnManager.purgeUrls(['https://example.com/page.html']);
```

## Security Best Practices

1. **Never commit credentials**
   - The `.env` and `.credentials.enc` files are already in `.gitignore`
   - Always use environment variables or encrypted storage

2. **Use API Tokens instead of API Keys**
   - API Tokens have scoped permissions
   - They can be revoked without affecting other tokens
   - They can have expiration dates

3. **Set minimal permissions**
   - Only grant the permissions your token needs
   - Create separate tokens for different use cases

4. **Rotate credentials regularly**
   ```bash
   npm run api:rotate
   ```

5. **Enable 2FA** on your Cloudflare account

6. **Monitor API usage** regularly in the dashboard

## Troubleshooting

### "Cloudflare credentials required" error

Make sure you've configured credentials using one of the methods above.

### "cloudflared: command not found"

Install the cloudflared CLI using the instructions in Prerequisites.

### "Permission denied" errors

Your API token may not have the required permissions. Create a new token with:
- Zone:DNS:Edit (for DNS operations)
- Zone:Zone Settings:Edit (for WAF/CDN)
- Account:Workers Scripts:Edit (for Workers)
- Account:Cloudflare Tunnel:Edit (for Tunnels)
- Account:Pages:Edit (for Pages)

### "Zone ID required" errors

Some operations require a Zone ID. Add it to your configuration:
```bash
npm run api:store  # and include Zone ID when prompted
```

Or set it in your `.env` file:
```env
CLOUDFLARE_ZONE_ID=your_zone_id_here
```

### Import/Module errors

Make sure you're using Node.js 18+ which supports ES modules:
```bash
node --version  # Should be v18.0.0 or higher
```

## Next Steps

- Read the [comprehensive documentation](./docs/)
  - [Cloudflare Tunnels](./docs/tunnels.md)
  - [Worker Development](./docs/workers.md)
  - [Pages Deployment](./docs/pages.md)
  - [WAF Configuration](./docs/waf.md)
  - [CDN Management](./docs/cdn.md)
  - [SSL/TLS Certificates](./docs/certificates.md)
  - [API Key Management](./docs/api-keys.md)

- Try the [examples](./examples/)
  - [Basic Tunnel Setup](./examples/tunnel-basic.js)
  - [Worker with Routes](./examples/worker-with-routes.js)
  - [WAF Security](./examples/waf-security.js)
  - [CDN Cache Strategy](./examples/cdn-cache.js)

- Explore all available commands:
  ```bash
  npm run  # Shows all available scripts
  ```

## Support

- Cloudflare Documentation: https://developers.cloudflare.com/
- Cloudflare Community: https://community.cloudflare.com/
- Cloudflare API Docs: https://developers.cloudflare.com/api/

## Contributing

This toolkit is part of the Kingdom Monorepo. Follow the general contribution guidelines in the repository root.
