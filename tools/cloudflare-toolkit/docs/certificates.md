# Certificate Management Guide

Comprehensive guide for managing SSL/TLS certificates with Cloudflare.

## Overview

Cloudflare provides multiple certificate management options:

1. **Universal SSL** - Free automatic SSL for all customers
2. **Dedicated Certificates** - Custom certificates with advanced options
3. **Custom Certificates** - Upload your own certificates
4. **Origin Certificates** - Certificates for origin server encryption
5. **Client Certificates** - mTLS for API authentication

## SSL/TLS Encryption Modes

### Off (Not Recommended)
No encryption between visitors and Cloudflare.

### Flexible SSL
- Encrypts traffic between visitors and Cloudflare
- No encryption between Cloudflare and origin
- Good for: Testing, origins that don't support SSL

### Full SSL
- Encrypts traffic end-to-end
- Uses any certificate on origin (including self-signed)
- Good for: Most production deployments

### Full SSL (Strict)
- Encrypts traffic end-to-end
- Requires valid certificate on origin
- Good for: Maximum security

### Choosing the Right Mode

```bash
# Set SSL mode via API
npm run ssl:set-mode strict

# Or using the library
const { SSLManager } = require('../lib/ssl-manager.js');
const sslManager = new SSLManager();
await sslManager.setMode('full_strict');
```

## Universal SSL

### Features
- Free for all Cloudflare accounts
- Automatically provisioned for all zones
- Covers apex and first-level subdomains
- 90-day validity (auto-renewed)

### Certificate Coverage

```
example.com
*.example.com
www.example.com
```

### Provisioning Time
- Usually 5-10 minutes for new domains
- Can take up to 24 hours in some cases

### Check Status

```bash
# Using the toolkit
npm run ssl:status

# Check provisioning status
curl -X GET "https://api.cloudflare.com/client/v4/zones/{zone_id}/ssl/universal/settings" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN"
```

## Origin Certificates

Origin certificates are issued by Cloudflare CA to encrypt traffic between Cloudflare and your origin server.

### Benefits
- Free and trusted by Cloudflare
- 15-year validity (no renewal needed)
- Covers multiple hostnames
- Easy to generate

### Creating Origin Certificates

#### Via Dashboard
1. Go to SSL/TLS → Origin Server
2. Click "Create Certificate"
3. Choose hostnames
4. Select validity period
5. Click "Create"

#### Via API

```bash
# Create origin certificate
npm run ssl:create-origin-cert example.com api.example.com

# Or using curl
curl -X POST "https://api.cloudflare.com/client/v4/certificates" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "hostnames": ["example.com", "*.example.com"],
    "requested_validity": 5475,
    "request_type": "origin-rsa",
    "csr": ""
  }'
```

### Installing Origin Certificate

#### Nginx

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;

    ssl_certificate /etc/ssl/cloudflare/cert.pem;
    ssl_certificate_key /etc/ssl/cloudflare/key.pem;

    # Cloudflare Origin Pull certificate (optional but recommended)
    ssl_client_certificate /etc/ssl/cloudflare/origin-pull-ca.pem;
    ssl_verify_client on;

    # Strong SSL settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
    ssl_prefer_server_ciphers off;

    location / {
        proxy_pass http://localhost:8080;
    }
}
```

#### Apache

```apache
<VirtualHost *:443>
    ServerName example.com
    
    SSLEngine on
    SSLCertificateFile /etc/ssl/cloudflare/cert.pem
    SSLCertificateKeyFile /etc/ssl/cloudflare/key.pem
    
    # Cloudflare Origin Pull (optional but recommended)
    SSLVerifyClient require
    SSLVerifyDepth 1
    SSLCACertificateFile /etc/ssl/cloudflare/origin-pull-ca.pem
    
    # Strong SSL settings
    SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256
    SSLHonorCipherOrder off
    
    ProxyPass / http://localhost:8080/
    ProxyPassReverse / http://localhost:8080/
</VirtualHost>
```

#### Node.js

```javascript
const https = require('https');
const fs = require('fs');

const options = {
  cert: fs.readFileSync('/etc/ssl/cloudflare/cert.pem'),
  key: fs.readFileSync('/etc/ssl/cloudflare/key.pem'),
  
  // Cloudflare Origin Pull (optional)
  ca: fs.readFileSync('/etc/ssl/cloudflare/origin-pull-ca.pem'),
  requestCert: true,
  rejectUnauthorized: true
};

https.createServer(options, (req, res) => {
  res.writeHead(200);
  res.end('Secure connection!\n');
}).listen(8443);
```

### Origin Pull Certificate

Authenticate that requests are coming from Cloudflare:

```bash
# Download Cloudflare Origin Pull CA
curl -o /etc/ssl/cloudflare/origin-pull-ca.pem \
  https://developers.cloudflare.com/ssl/static/authenticated_origin_pull_ca.pem

# Enable Authenticated Origin Pulls via API
npm run ssl:enable-origin-pull
```

## Custom Certificates

Upload your own certificates (Business and Enterprise plans).

### Requirements
- Must be in PEM format
- Private key must be unencrypted
- Valid certificate chain
- Not expired
- Key size: 2048 bits minimum (RSA) or 256 bits (ECDSA)

### Uploading Custom Certificate

```bash
# Upload via toolkit
npm run ssl:upload-custom \
  --cert /path/to/cert.pem \
  --key /path/to/key.pem \
  --bundle /path/to/bundle.pem

# Or via API
curl -X POST "https://api.cloudflare.com/client/v4/zones/{zone_id}/custom_certificates" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "certificate": "-----BEGIN CERTIFICATE-----\n...",
    "private_key": "-----BEGIN PRIVATE KEY-----\n...",
    "bundle_method": "ubiquitous"
  }'
```

### Bundle Methods

- **ubiquitous**: Compatible with all browsers (recommended)
- **optimal**: Modern browsers, better performance
- **force**: Use only provided bundle

## Client Certificates (mTLS)

Mutual TLS for API authentication.

### Creating Client Certificates

```bash
# Generate client certificate
npm run ssl:create-client-cert myapi

# Or manually
openssl req -x509 -newkey rsa:4096 -keyout client-key.pem \
  -out client-cert.pem -days 365 -nodes \
  -subj "/CN=myapi.example.com"
```

### Upload to Cloudflare

```bash
# Upload client certificate
npm run ssl:upload-client-cert \
  --cert client-cert.pem \
  --name "API Client Certificate"

# Create mTLS rule
npm run ssl:create-mtls-rule \
  --hostname api.example.com \
  --cert-id <certificate-id>
```

### Using Client Certificates

```bash
# curl with client certificate
curl https://api.example.com/secure \
  --cert client-cert.pem \
  --key client-key.pem

# Node.js
const https = require('https');
const fs = require('fs');

const options = {
  hostname: 'api.example.com',
  port: 443,
  path: '/secure',
  method: 'GET',
  cert: fs.readFileSync('client-cert.pem'),
  key: fs.readFileSync('client-key.pem')
};

https.request(options, (res) => {
  // Handle response
}).end();
```

## Certificate Management Scripts

### Automatic Renewal

```bash
#!/bin/bash
# renew-origin-cert.sh

CERT_FILE="/etc/ssl/cloudflare/cert.pem"
DAYS_UNTIL_EXPIRY=$(openssl x509 -in $CERT_FILE -noout -enddate | \
  awk -F= '{print $2}' | xargs -I {} date -d {} +%s | \
  awk -v now=$(date +%s) '{print int(($1 - now) / 86400)}')

if [ $DAYS_UNTIL_EXPIRY -lt 30 ]; then
    echo "Certificate expires in $DAYS_UNTIL_EXPIRY days, renewing..."
    npm run ssl:create-origin-cert example.com
    systemctl reload nginx
    echo "Certificate renewed and Nginx reloaded"
fi
```

### Certificate Monitoring

```bash
#!/bin/bash
# monitor-certs.sh

# Check certificate expiry
check_cert() {
    local domain=$1
    local expiry_date=$(echo | openssl s_client -servername $domain \
      -connect $domain:443 2>/dev/null | \
      openssl x509 -noout -enddate | cut -d= -f2)
    
    local expiry_epoch=$(date -d "$expiry_date" +%s)
    local now_epoch=$(date +%s)
    local days_remaining=$(( ($expiry_epoch - $now_epoch) / 86400 ))
    
    echo "$domain: $days_remaining days until expiry"
    
    if [ $days_remaining -lt 30 ]; then
        echo "WARNING: Certificate for $domain expires soon!"
        # Send alert
    fi
}

# Check all domains
check_cert "example.com"
check_cert "api.example.com"
check_cert "app.example.com"
```

### Certificate Backup

```bash
#!/bin/bash
# backup-certs.sh

BACKUP_DIR="/var/backups/cloudflare-certs"
DATE=$(date +%Y%m%d)

mkdir -p $BACKUP_DIR/$DATE

# Backup origin certificates
cp /etc/ssl/cloudflare/cert.pem $BACKUP_DIR/$DATE/
cp /etc/ssl/cloudflare/key.pem $BACKUP_DIR/$DATE/
cp /etc/ssl/cloudflare/origin-pull-ca.pem $BACKUP_DIR/$DATE/

# Encrypt backup
tar -czf - $BACKUP_DIR/$DATE | \
  openssl enc -aes-256-cbc -e -out $BACKUP_DIR/certs-$DATE.tar.gz.enc \
  -pass pass:$BACKUP_PASSWORD

# Clean up old backups (keep 90 days)
find $BACKUP_DIR -name "certs-*.tar.gz.enc" -mtime +90 -delete
```

## Best Practices

### 1. Use Full (Strict) SSL Mode
Always use Full (Strict) mode in production for end-to-end encryption.

### 2. Enable Authenticated Origin Pulls
Verify requests are from Cloudflare.

### 3. Use Strong Cipher Suites
```nginx
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
```

### 4. Enable HSTS
```bash
npm run ssl:enable-hsts
```

### 5. Monitor Certificate Expiry
Set up automated monitoring and alerts.

### 6. Rotate Certificates Regularly
Even though origin certificates last 15 years, rotate them periodically.

### 7. Secure Private Keys
```bash
# Proper permissions
chmod 600 /etc/ssl/cloudflare/key.pem
chown root:root /etc/ssl/cloudflare/key.pem
```

### 8. Use Certificate Pinning (Advanced)
For critical APIs, implement certificate pinning.

## Troubleshooting

### SSL Handshake Errors

```bash
# Test SSL connection
openssl s_client -connect example.com:443 -servername example.com

# Check certificate chain
openssl s_client -connect example.com:443 -showcerts

# Verify certificate
openssl x509 -in cert.pem -text -noout
```

### Origin Connection Issues

```bash
# Test origin SSL
curl -vk https://origin-ip:443

# Check Cloudflare can reach origin
curl -H "Host: example.com" https://origin-ip:443

# Verify origin certificate
openssl s_client -connect origin-ip:443 -servername example.com
```

### Common Errors

#### Error 525: SSL Handshake Failed
- Check origin has valid SSL certificate
- Verify SSL mode is appropriate
- Check firewall allows Cloudflare IPs

#### Error 526: Invalid SSL Certificate
- Origin certificate is expired or invalid
- Change to Full mode instead of Full (Strict)
- Install valid certificate on origin

#### Error 521: Web Server Is Down
- Origin server is unreachable
- Check firewall and security groups
- Verify origin IP in DNS settings

## Resources

- [Cloudflare SSL Documentation](https://developers.cloudflare.com/ssl/)
- [SSL Best Practices](https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes/)
- [Certificate Transparency](https://developers.cloudflare.com/ssl/edge-certificates/additional-options/certificate-transparency/)
