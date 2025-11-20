# Web Application Firewall (WAF) Guide

Configure and manage Cloudflare's Web Application Firewall to protect your applications.

## Overview

Cloudflare WAF protects against:
- SQL injection
- Cross-site scripting (XSS)
- DDoS attacks
- Bot attacks
- OWASP Top 10 vulnerabilities
- Zero-day exploits

**Available on**: Pro, Business, and Enterprise plans

## WAF Features

### 1. Managed Rules (Business/Enterprise)
Pre-configured rule sets maintained by Cloudflare.

### 2. Rate Limiting
Limit requests per time period from a single IP or endpoint.

### 3. Custom Rules
Create your own firewall rules using Cloudflare's Rules Language.

### 4. Firewall Rules (Legacy)
Expression-based rules for traffic filtering.

### 5. IP Access Rules
Allow, block, or challenge specific IPs or ranges.

## Firewall Rules

### Creating Rules via Toolkit

```bash
# Create a custom rule
npm run waf:create-rule

# Block specific country
npm run waf:block-country CN RU

# Allow specific IPs
npm run waf:allow-ips "203.0.113.0/24,198.51.100.5"

# Challenge suspicious traffic
npm run waf:challenge-rule --expression "(cf.threat_score > 50)"
```

### Rule Expressions

```javascript
// Block specific user agents
(http.user_agent contains "badbot")

// Allow only specific countries
not (ip.geoip.country in {"US" "CA" "GB"})

// Block requests to admin paths
(http.request.uri.path contains "/admin" and not ip.src in {1.2.3.4})

// Rate limiting expression
(http.request.uri.path eq "/api/login")

// Block SQL injection attempts
(http.request.uri.query contains "union select" or 
 http.request.uri.query contains "drop table")

// Challenge high threat score
(cf.threat_score > 10)

// Block specific ASNs
(ip.geoip.asnum in {12345 67890})

// Combine multiple conditions
(http.host eq "example.com" and 
 http.request.method eq "POST" and 
 http.request.uri.path eq "/api/sensitive")
```

### Rule Actions

- **Block**: Return 403 Forbidden
- **Allow**: Bypass all subsequent rules
- **Challenge**: Show CAPTCHA
- **JS Challenge**: JavaScript challenge
- **Managed Challenge**: Cloudflare-managed challenge
- **Log**: Log matching requests (no action)
- **Bypass**: Skip specific rule sets

### Creating Rules via API

```javascript
// lib/waf-manager.js usage
import { WAFManager } from './lib/waf-manager.js';

const waf = new WAFManager();

// Create firewall rule
await waf.createRule({
  description: 'Block known bad bots',
  expression: '(http.user_agent contains "badbot")',
  action: 'block',
  priority: 1
});

// Create with multiple conditions
await waf.createRule({
  description: 'Protect admin area',
  expression: `(
    http.request.uri.path contains "/admin" and
    not ip.src in {1.2.3.4 5.6.7.8} and
    cf.threat_score > 5
  )`,
  action: 'challenge'
});
```

## Rate Limiting

### Simple Rate Limit

```bash
# Limit login attempts
npm run waf:rate-limit \
  --path "/api/login" \
  --limit 5 \
  --period 60 \
  --action block

# Limit API calls per IP
npm run waf:rate-limit \
  --path "/api/*" \
  --limit 100 \
  --period 60 \
  --action challenge
```

### Advanced Rate Limiting

```javascript
import { WAFManager } from './lib/waf-manager.js';

const waf = new WAFManager();

// Rate limit by IP
await waf.createRateLimit({
  description: 'API rate limit per IP',
  match: {
    request: {
      url_pattern: 'example.com/api/*',
      methods: ['GET', 'POST']
    }
  },
  threshold: 100,
  period: 60,
  action: {
    mode: 'challenge',
    timeout: 86400 // 24 hours
  },
  characteristics: ['ip.src']
});

// Rate limit by API key
await waf.createRateLimit({
  description: 'API rate limit per key',
  match: {
    request: {
      url_pattern: 'api.example.com/*'
    },
    response: {
      status: [200, 201, 202]
    }
  },
  threshold: 1000,
  period: 3600,
  action: {
    mode: 'block',
    response: {
      content_type: 'application/json',
      body: '{"error": "Rate limit exceeded"}'
    }
  },
  characteristics: ['http.request.headers["x-api-key"]'],
  counting_expression: '(http.request.method eq "POST")'
});

// Distributed rate limiting
await waf.createRateLimit({
  description: 'Global API rate limit',
  match: {
    request: {
      url_pattern: 'api.example.com/*'
    }
  },
  threshold: 10000,
  period: 60,
  action: {
    mode: 'simulate' // Log only, don't block
  },
  characteristics: ['cf.colo.id'] // Per data center
});
```

## Managed Rules

### Enable Managed Rules (Enterprise)

```bash
# Enable Cloudflare Managed Ruleset
npm run waf:enable-managed-rules

# Enable OWASP Core Ruleset
npm run waf:enable-owasp

# Configure sensitivity
npm run waf:set-sensitivity low  # low, medium, high
```

### Managed Rule Configuration

```javascript
import { WAFManager } from './lib/waf-manager.js';

const waf = new WAFManager();

// Enable managed ruleset
await waf.enableManagedRuleset('cloudflare_managed');

// Override specific rules
await waf.overrideManagedRule('cloudflare_managed', 'rule_id_123', {
  action: 'log', // Instead of block
  enabled: true
});

// Disable specific rules
await waf.disableManagedRule('cloudflare_managed', 'rule_id_456');
```

## IP Access Rules

### Allow/Block IPs

```bash
# Block single IP
npm run waf:block-ip 192.0.2.1

# Block IP range
npm run waf:block-ip 192.0.2.0/24

# Allow trusted IPs
npm run waf:allow-ip 203.0.113.0/24 --note "Office network"

# Challenge suspicious IP
npm run waf:challenge-ip 198.51.100.5

# List IP rules
npm run waf:list-ip-rules

# Remove IP rule
npm run waf:remove-ip-rule <rule-id>
```

### Country Blocking

```bash
# Block specific countries
npm run waf:block-countries CN RU KP

# Allow only specific countries
npm run waf:allow-only-countries US CA GB

# Remove country restrictions
npm run waf:remove-country-rules
```

## Security Level

```bash
# Set security level
npm run waf:set-security-level high  # off, low, medium, high, under_attack

# Under Attack Mode (aggressive protection)
npm run waf:under-attack-mode on
```

## Bot Management

### Bot Fight Mode (Free/Pro)

```bash
# Enable bot fight mode
npm run waf:enable-bot-fight

# Configure bot settings
npm run waf:configure-bots \
  --challenge-bots true \
  --verified-bots-allowed true
```

### Super Bot Fight Mode (Business)

```javascript
import { WAFManager } from './lib/waf-manager.js';

const waf = new WAFManager();

await waf.configureSuperBotFight({
  fight_mode: true,
  enable_js: true,
  using_latest_model: true,
  optimize_wordpress: true,
  
  // Bot categories
  definitely_automated: 'block',
  likely_automated: 'challenge',
  verified_bots: 'allow',
  
  // Detection methods
  static_resource_protection: true,
  ai_bots: 'block'
});
```

### Bot Management (Enterprise)

```javascript
await waf.configureBotManagement({
  fight_mode: true,
  enable_js: true,
  suppress_session_score: false,
  
  // AI/ML features
  use_latest_model: true,
  auto_update_model: true,
  
  // Custom rules
  custom_rules: [{
    expression: '(cf.bot_management.score < 30)',
    action: 'block'
  }]
});
```

## DDoS Protection

### L7 DDoS Protection

```bash
# Enable advanced DDoS protection
npm run waf:enable-ddos-protection

# Configure sensitivity
npm run waf:set-ddos-sensitivity high

# Create DDoS override
npm run waf:ddos-override \
  --path "/api/*" \
  --sensitivity low
```

### HTTP DDoS Attack Protection

```javascript
import { WAFManager } from './lib/waf-manager.js';

const waf = new WAFManager();

await waf.configureDDoS({
  enabled: true,
  sensitivity: 'high', // low, medium, high
  
  // Override rules for specific paths
  overrides: [{
    expression: '(http.request.uri.path contains "/api")',
    sensitivity: 'medium',
    action: 'challenge'
  }]
});
```

## Advanced Protection

### WAF Attack Score

```javascript
// Use WAF Attack Score in rules
const expression = `(
  cf.waf.score.sqli > 50 or
  cf.waf.score.xss > 50 or
  cf.waf.score.rce > 50
)`;

await waf.createRule({
  description: 'Block high attack scores',
  expression,
  action: 'block'
});
```

### Leaked Credentials Check

```bash
# Enable exposed credentials check
npm run waf:enable-credential-check

# Configure action
npm run waf:credential-check-action managed_challenge
```

### Sensitive Data Detection

```javascript
await waf.createRule({
  description: 'Protect sensitive data',
  expression: `(
    http.request.body.raw contains "credit_card" or
    http.request.body.raw matches "\\d{4}-\\d{4}-\\d{4}-\\d{4}"
  )`,
  action: 'block'
});
```

## Testing & Validation

### Test Mode

```bash
# Enable simulate mode (log only, don't block)
npm run waf:test-mode on

# View matched rules in logs
npm run waf:view-logs --filter "action=simulate"

# Disable test mode
npm run waf:test-mode off
```

### Rule Testing

```javascript
import { WAFManager } from './lib/waf-manager.js';

const waf = new WAFManager();

// Test rule expression
const testResult = await waf.testRule({
  expression: '(http.user_agent contains "test")',
  testRequests: [
    {
      url: 'https://example.com/test',
      method: 'GET',
      headers: { 'User-Agent': 'test-bot' }
    }
  ]
});

console.log('Matches:', testResult.matches);
```

## Monitoring & Analytics

### View Firewall Events

```bash
# View recent firewall events
npm run waf:view-events

# Filter by action
npm run waf:view-events --action block

# Filter by rule
npm run waf:view-events --rule-id <rule-id>

# Export events
npm run waf:export-events --since "24h" --output events.json
```

### Analytics

```javascript
import { WAFManager } from './lib/waf-manager.js';

const waf = new WAFManager();

// Get firewall analytics
const analytics = await waf.getAnalytics({
  since: new Date(Date.now() - 24 * 60 * 60 * 1000), // Last 24 hours
  metrics: ['requests', 'threats', 'actions'],
  dimensions: ['action', 'country', 'ruleId']
});

console.log('Total requests:', analytics.requests);
console.log('Threats blocked:', analytics.threats);
console.log('Top rules:', analytics.topRules);
```

## Best Practices

### 1. Start with Log Mode
Test rules in simulate mode before blocking.

### 2. Layer Your Defenses
```javascript
// Layer 1: Block known bad actors
await waf.createRule({
  description: 'Block known bad IPs',
  expression: '(ip.src in {1.2.3.4 5.6.7.8})',
  action: 'block',
  priority: 1
});

// Layer 2: Challenge suspicious traffic
await waf.createRule({
  description: 'Challenge high threat score',
  expression: '(cf.threat_score > 10)',
  action: 'challenge',
  priority: 2
});

// Layer 3: Rate limit
await waf.createRateLimit({
  description: 'Rate limit API',
  threshold: 100,
  period: 60,
  action: { mode: 'challenge' }
});

// Layer 4: Managed rules
await waf.enableManagedRuleset('cloudflare_managed');
```

### 3. Use Allowlists
Allow trusted traffic to bypass rules:

```javascript
await waf.createRule({
  description: 'Allow office IPs',
  expression: '(ip.src in {203.0.113.0/24})',
  action: 'allow', // Bypass all subsequent rules
  priority: 0 // Highest priority
});
```

### 4. Monitor False Positives
```bash
# Review blocked requests
npm run waf:review-blocks --since "1h"

# Adjust rules if needed
npm run waf:update-rule <rule-id> --action challenge
```

### 5. Regular Audits
```bash
# Review all active rules
npm run waf:audit

# Check for unused rules
npm run waf:find-unused

# Export configuration
npm run waf:export-config > waf-config.json
```

### 6. Use Variables
```javascript
const TRUSTED_IPS = ['203.0.113.0/24', '198.51.100.0/24'];
const ADMIN_PATHS = ['/admin', '/wp-admin', '/dashboard'];

await waf.createRule({
  expression: `(
    http.request.uri.path in {${ADMIN_PATHS.map(p => `"${p}"`).join(' ')}} and
    not ip.src in {${TRUSTED_IPS.join(' ')}}
  )`,
  action: 'challenge'
});
```

### 7. Geographic Protection
```javascript
// Protect admin area by geography
await waf.createRule({
  description: 'Admin area geographic protection',
  expression: `(
    http.request.uri.path contains "/admin" and
    not ip.geoip.country in {"US" "CA" "GB"}
  )`,
  action: 'block'
});
```

## Common Patterns

### Protect Login Page
```bash
npm run waf:protect-login \
  --path "/login" \
  --rate-limit 5 \
  --period 300 \
  --block-duration 3600
```

### Protect API Endpoints
```bash
npm run waf:protect-api \
  --prefix "/api" \
  --rate-limit 100 \
  --require-auth true
```

### Block Automated Tools
```javascript
await waf.createRule({
  description: 'Block automated tools',
  expression: `(
    http.user_agent contains "curl" or
    http.user_agent contains "wget" or
    http.user_agent contains "python-requests" or
    http.user_agent eq ""
  )`,
  action: 'block'
});
```

## Troubleshooting

### Rule Not Working
```bash
# Check rule syntax
npm run waf:validate-rule --expression "your expression"

# Test against sample request
npm run waf:test-rule <rule-id> --url "https://example.com/test"

# Check rule order
npm run waf:list-rules --show-priority
```

### Too Many False Positives
```bash
# Switch to challenge mode
npm run waf:update-rule <rule-id> --action challenge

# Or log mode to monitor
npm run waf:update-rule <rule-id> --action log
```

### Performance Impact
- Use specific expressions instead of regex where possible
- Limit the number of active rules
- Use managed rulesets for common protections
- Monitor rule execution time in analytics

## Resources

- [WAF Documentation](https://developers.cloudflare.com/waf/)
- [Rules Language Reference](https://developers.cloudflare.com/ruleset-engine/rules-language/)
- [WAF Attack Score](https://developers.cloudflare.com/waf/about/waf-attack-score/)
- [Rate Limiting](https://developers.cloudflare.com/waf/rate-limiting-rules/)
