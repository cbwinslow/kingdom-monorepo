# API Key Management Guide

Comprehensive guide for managing Cloudflare API keys and tokens securely.

## Overview

Cloudflare provides two authentication methods:

1. **API Tokens** - Recommended, scoped permissions
2. **API Keys** - Legacy, global access (not recommended for new projects)

## API Tokens vs API Keys

### API Tokens (Recommended)
- **Scoped permissions**: Access only what's needed
- **Time-limited**: Can set expiration dates
- **Auditable**: Track usage per token
- **Revocable**: Invalidate without affecting other tokens
- **Best for**: Automation, CI/CD, third-party integrations

### API Keys (Legacy)
- **Global access**: Full account permissions
- **No expiration**: Valid indefinitely
- **Single key**: One key for all operations
- **Best for**: Manual operations (use with caution)

## Creating API Tokens

### Via Dashboard

1. Log in to Cloudflare Dashboard
2. Go to My Profile → API Tokens
3. Click "Create Token"
4. Choose a template or create custom token
5. Set permissions and resources
6. Set IP filtering and TTL (optional)
7. Click "Continue to Summary"
8. Review and create

### Via Toolkit

```bash
# Interactive token creation
npm run api:create-token

# Create token with specific permissions
npm run api:create-token \
  --name "Deploy Worker" \
  --permissions "Workers Scripts:Edit" \
  --zone example.com
```

### Via API

```bash
curl -X POST "https://api.cloudflare.com/client/v4/user/tokens" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Deploy Worker",
    "policies": [{
      "id": "f267e341f3dd4697bd3b9f71dd96247f",
      "effect": "allow",
      "resources": {
        "com.cloudflare.api.account.zone.*": "*"
      },
      "permission_groups": [{
        "id": "c8fed203ed3043cba015a93ad1616f1f",
        "name": "Workers Scripts Write"
      }]
    }]
  }'
```

## Token Permission Templates

### Read-Only Access
```json
{
  "name": "Read-Only Token",
  "policies": [{
    "effect": "allow",
    "resources": {
      "com.cloudflare.api.account.zone.*": "*"
    },
    "permission_groups": [
      {"id": "zone_settings_read"},
      {"id": "dns_records_read"},
      {"id": "analytics_read"}
    ]
  }]
}
```

### DNS Management
```json
{
  "name": "DNS Management",
  "policies": [{
    "effect": "allow",
    "resources": {
      "com.cloudflare.api.account.zone.{zone_id}": "*"
    },
    "permission_groups": [
      {"id": "dns_records_read"},
      {"id": "dns_records_edit"}
    ]
  }]
}
```

### Worker Deployment
```json
{
  "name": "Worker Deployment",
  "policies": [{
    "effect": "allow",
    "resources": {
      "com.cloudflare.api.account.{account_id}": "*"
    },
    "permission_groups": [
      {"id": "workers_scripts_write"},
      {"id": "workers_routes_write"}
    ]
  }]
}
```

### Pages Deployment
```json
{
  "name": "Pages Deployment",
  "policies": [{
    "effect": "allow",
    "resources": {
      "com.cloudflare.api.account.{account_id}": "*"
    },
    "permission_groups": [
      {"id": "pages_write"}
    ]
  }]
}
```

### WAF Management
```json
{
  "name": "WAF Management",
  "policies": [{
    "effect": "allow",
    "resources": {
      "com.cloudflare.api.account.zone.{zone_id}": "*"
    },
    "permission_groups": [
      {"id": "firewall_services_write"},
      {"id": "zone_settings_read"}
    ]
  }]
}
```

## Secure Storage

### Environment Variables

```bash
# .env file (NEVER commit this)
CLOUDFLARE_API_TOKEN=your_token_here
CLOUDFLARE_ACCOUNT_ID=your_account_id
CLOUDFLARE_ZONE_ID=your_zone_id
CLOUDFLARE_EMAIL=your@email.com
```

### Using the Toolkit

```bash
# Store credentials securely (encrypted)
npm run api:store

# This will prompt for:
# - API Token or API Key + Email
# - Account ID
# - Zone ID (optional)
```

### Encryption

The toolkit stores credentials encrypted at `config/.credentials.enc`:

```javascript
// lib/credential-store.js
const crypto = require('crypto');
const fs = require('fs');

class CredentialStore {
  constructor(configPath = 'config/.credentials.enc') {
    this.configPath = configPath;
    this.algorithm = 'aes-256-gcm';
  }

  encrypt(data, password) {
    const salt = crypto.randomBytes(16);
    const key = crypto.scryptSync(password, salt, 32);
    const iv = crypto.randomBytes(16);
    const cipher = crypto.createCipheriv(this.algorithm, key, iv);
    
    let encrypted = cipher.update(JSON.stringify(data), 'utf8', 'hex');
    encrypted += cipher.final('hex');
    const authTag = cipher.getAuthTag();
    
    return {
      encrypted,
      salt: salt.toString('hex'),
      iv: iv.toString('hex'),
      authTag: authTag.toString('hex')
    };
  }

  decrypt(encryptedData, password) {
    const salt = Buffer.from(encryptedData.salt, 'hex');
    const key = crypto.scryptSync(password, salt, 32);
    const iv = Buffer.from(encryptedData.iv, 'hex');
    const authTag = Buffer.from(encryptedData.authTag, 'hex');
    
    const decipher = crypto.createDecipheriv(this.algorithm, key, iv);
    decipher.setAuthTag(authTag);
    
    let decrypted = decipher.update(encryptedData.encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    
    return JSON.parse(decrypted);
  }

  async store(credentials, password) {
    const encrypted = this.encrypt(credentials, password);
    fs.writeFileSync(this.configPath, JSON.stringify(encrypted, null, 2));
  }

  async load(password) {
    const encrypted = JSON.parse(fs.readFileSync(this.configPath, 'utf8'));
    return this.decrypt(encrypted, password);
  }
}

module.exports = CredentialStore;
```

### System Keyring (Advanced)

For production systems, use system keyring:

```bash
# macOS Keychain
security add-generic-password \
  -a cloudflare \
  -s api_token \
  -w "your_token_here"

# Retrieve
security find-generic-password \
  -a cloudflare \
  -s api_token \
  -w

# Linux (using secret-tool)
secret-tool store --label='Cloudflare API Token' \
  service cloudflare \
  username api_token

# Retrieve
secret-tool lookup service cloudflare username api_token
```

## Token Rotation

### Manual Rotation

```bash
# Create new token
npm run api:create-token --name "Worker Deploy (New)"

# Update environment/configs with new token
# Verify new token works
npm run api:verify

# Delete old token
npm run api:delete-token <old-token-id>
```

### Automated Rotation

```bash
# Rotate token automatically
npm run api:rotate

# This will:
# 1. Create new token with same permissions
# 2. Update stored credentials
# 3. Verify new token works
# 4. Delete old token
# 5. Update environment files
```

### Rotation Script

```javascript
// scripts/api-rotate.js
import Cloudflare from 'cloudflare';
import { CredentialStore } from '../lib/credential-store.js';
import inquirer from 'inquirer';
import chalk from 'chalk';
import ora from 'ora';

async function rotateToken() {
  const store = new CredentialStore();
  const spinner = ora();

  try {
    // Get master password
    const { password } = await inquirer.prompt([{
      type: 'password',
      name: 'password',
      message: 'Enter master password:',
      mask: '*'
    }]);

    // Load current credentials
    spinner.start('Loading current credentials...');
    const currentCreds = await store.load(password);
    spinner.succeed();

    // Initialize Cloudflare client
    const cf = new Cloudflare({
      apiToken: currentCreds.apiToken
    });

    // Get current token info
    spinner.start('Fetching current token details...');
    const currentToken = await cf.userTokens.verify();
    spinner.succeed();

    // Create new token with same permissions
    spinner.start('Creating new token...');
    const newToken = await cf.userTokens.create({
      name: `${currentToken.name} (Rotated ${new Date().toISOString()})`,
      policies: currentToken.policies
    });
    spinner.succeed();

    // Verify new token
    spinner.start('Verifying new token...');
    const cfNew = new Cloudflare({ apiToken: newToken.id });
    await cfNew.userTokens.verify();
    spinner.succeed();

    // Store new credentials
    spinner.start('Storing new credentials...');
    await store.store({
      ...currentCreds,
      apiToken: newToken.id,
      rotatedAt: new Date().toISOString()
    }, password);
    spinner.succeed();

    // Delete old token
    spinner.start('Deleting old token...');
    await cfNew.userTokens.delete(currentToken.id);
    spinner.succeed();

    console.log(chalk.green('✓ Token rotated successfully'));
    console.log(chalk.yellow('⚠ Update any external systems using this token'));

  } catch (error) {
    spinner.fail('Rotation failed');
    console.error(chalk.red('Error:'), error.message);
    process.exit(1);
  }
}

rotateToken();
```

## Token Management

### List Tokens

```bash
# List all tokens
npm run api:list-tokens

# Output:
# Token Name          | ID           | Created      | Last Used    | Status
# ------------------- | ------------ | ------------ | ------------ | ------
# Deploy Worker       | a1b2c3...    | 2024-01-01   | 2024-01-15   | Active
# DNS Management      | d4e5f6...    | 2024-01-05   | 2024-01-14   | Active
```

### Verify Token

```bash
# Verify current token
npm run api:verify

# Verify specific token
npm run api:verify --token <token-value>
```

### Revoke Token

```bash
# Revoke a token
npm run api:delete-token <token-id>

# Revoke all tokens (emergency)
npm run api:revoke-all
```

## Security Best Practices

### 1. Use API Tokens, Not Keys
Always prefer API tokens with scoped permissions.

### 2. Principle of Least Privilege
Grant only the minimum required permissions:

```bash
# ✓ Good: Specific permissions
npm run api:create-token \
  --permissions "Workers Scripts:Write" \
  --zone example.com

# ✗ Bad: Global access
npm run api:create-token \
  --permissions "All"
```

### 3. Set Expiration Dates
For temporary access, set token expiration:

```bash
npm run api:create-token \
  --name "Contractor Access" \
  --ttl 30d
```

### 4. IP Whitelisting
Restrict token usage to specific IPs:

```bash
npm run api:create-token \
  --name "CI/CD Token" \
  --allowed-ips "203.0.113.0/24,198.51.100.5"
```

### 5. Never Commit Secrets
```bash
# .gitignore
.env
.env.*
config/.credentials*
*.key
*.pem
secrets/
```

### 6. Regular Audits
```bash
# Audit token usage
npm run api:audit

# Check for unused tokens
npm run api:cleanup-unused
```

### 7. Use Different Tokens for Different Environments
```bash
# Development
CLOUDFLARE_API_TOKEN=dev_token_here

# Staging
CLOUDFLARE_API_TOKEN=staging_token_here

# Production
CLOUDFLARE_API_TOKEN=prod_token_here
```

### 8. Monitor Token Usage
Set up alerts for:
- Unusual API usage
- Failed authentication attempts
- Token usage from unexpected IPs
- Changes to critical resources

### 9. Rotate Regularly
```bash
# Rotate tokens every 90 days
0 0 1 */3 * /path/to/npm run api:rotate
```

### 10. Secure CI/CD
```bash
# GitHub Actions
# Store as encrypted secrets
- name: Deploy Worker
  env:
    CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
  run: npm run worker:deploy

# GitLab CI
# Store as protected variables
deploy:
  script:
    - npm run worker:deploy
  only:
    - main
```

## Emergency Response

### Token Compromised

1. **Immediately revoke the token**:
```bash
npm run api:delete-token <token-id>
```

2. **Create new token with different permissions**:
```bash
npm run api:create-token --name "Emergency Replacement"
```

3. **Audit recent activity**:
```bash
npm run api:audit --since "1 hour ago"
```

4. **Check for unauthorized changes**:
```bash
# Review DNS changes
cloudflare-cli dns list

# Review firewall rules
cloudflare-cli firewall list

# Review worker deployments
cloudflare-cli workers list
```

5. **Update all systems using the token**

6. **Enable additional security**:
```bash
# Enable 2FA if not already enabled
# Review account access logs
# Update security policies
```

## Troubleshooting

### Invalid Token Error
```bash
# Verify token format
echo $CLOUDFLARE_API_TOKEN | wc -c
# Should be around 40 characters

# Test token
curl -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN"
```

### Insufficient Permissions
```bash
# Check token permissions
npm run api:verify --verbose

# Required permission for operation:
# Workers Scripts:Write on Account scope
```

### Rate Limiting
```bash
# Check rate limit status
npm run api:rate-limits

# Implement exponential backoff
# Use multiple tokens for high-volume operations
```

## Resources

- [API Token Documentation](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/)
- [API Reference](https://developers.cloudflare.com/api/)
- [Security Best Practices](https://developers.cloudflare.com/fundamentals/api/get-started/api-token-best-practices/)
