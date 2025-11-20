# Cloudflare Tunnels Guide

Cloudflare Tunnel (formerly Argo Tunnel) creates secure, outbound-only connections from your infrastructure to Cloudflare without opening inbound ports.

## Overview

Cloudflare Tunnel allows you to:
- Expose local services securely without opening firewall ports
- Connect private networks to Cloudflare's edge
- Protect applications behind Zero Trust access policies
- Achieve high availability with multiple tunnel replicas

## Architecture

```
[Your Application] → [cloudflared] → [Cloudflare Edge] → [Internet Users]
   (Private)          (Tunnel)         (Public)
```

## Setup

### 1. Install cloudflared

#### macOS
```bash
brew install cloudflare/cloudflare/cloudflared
```

#### Linux
```bash
# Debian/Ubuntu
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# RPM-based (CentOS/RHEL/Fedora)
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-x86_64.rpm
sudo rpm -i cloudflared-linux-x86_64.rpm
```

#### Windows
```powershell
winget install --id Cloudflare.cloudflared
```

### 2. Authenticate cloudflared

```bash
cloudflared tunnel login
```

This opens a browser window to authenticate with your Cloudflare account and downloads a certificate to `~/.cloudflared/cert.pem`.

### 3. Create a Tunnel

Using the toolkit:
```bash
npm run tunnel:create my-app-tunnel
```

Or directly with cloudflared:
```bash
cloudflared tunnel create my-app-tunnel
```

This creates:
- A tunnel with a unique ID
- A credentials file at `~/.cloudflared/<TUNNEL-ID>.json`

### 4. Configure the Tunnel

Create a configuration file `~/.cloudflared/config.yml`:

```yaml
tunnel: my-app-tunnel
credentials-file: /home/user/.cloudflared/<TUNNEL-ID>.json

ingress:
  # Route example.com to local service on port 8080
  - hostname: example.com
    service: http://localhost:8080
  
  # Route subdomain to different service
  - hostname: api.example.com
    service: http://localhost:3000
  
  # Route with path-based routing
  - hostname: app.example.com
    path: /api/*
    service: http://localhost:4000
  
  # SSH access through tunnel
  - hostname: ssh.example.com
    service: ssh://localhost:22
  
  # Catch-all rule (required)
  - service: http_status:404
```

### 5. Create DNS Records

Route traffic through the tunnel:

```bash
# Using the toolkit
npm run tunnel:route my-app-tunnel example.com

# Or with cloudflared
cloudflared tunnel route dns my-app-tunnel example.com
```

This creates a CNAME record pointing to your tunnel.

### 6. Run the Tunnel

```bash
# Using the toolkit
npm run tunnel:run my-app-tunnel

# Or with cloudflared
cloudflared tunnel run my-app-tunnel

# Or use the config file
cloudflared tunnel --config ~/.cloudflared/config.yml run
```

## Advanced Configuration

### Running as a Service

#### Linux (systemd)

```bash
sudo cloudflared service install
sudo systemctl start cloudflared
sudo systemctl enable cloudflared
```

#### Windows (Service)

```powershell
cloudflared service install
sc start cloudflared
```

#### macOS (launchd)

```bash
sudo cloudflared service install
sudo launchctl start com.cloudflare.cloudflared
```

### High Availability

Run multiple `cloudflared` instances for redundancy:

```bash
# On server 1
cloudflared tunnel run my-app-tunnel

# On server 2 (same tunnel, different instance)
cloudflared tunnel run my-app-tunnel
```

Cloudflare automatically load balances between healthy replicas.

### Configuration Options

Full `config.yml` example with all options:

```yaml
tunnel: my-app-tunnel
credentials-file: /path/to/credentials.json

# Tunnel-wide settings
originRequest:
  connectTimeout: 30s
  noTLSVerify: false
  http2Origin: true
  httphostHeader: example.com
  
  # Connection pooling
  keepAliveConnections: 100
  keepAliveTimeout: 90s
  
  # Timeouts
  tcpKeepAlive: 30s
  noHappyEyeballs: false
  
  # Proxy settings (optional)
  proxyAddress: 127.0.0.1
  proxyPort: 8080
  proxyType: socks5

# Logging
loglevel: info
logfile: /var/log/cloudflared.log

# Metrics
metrics: 0.0.0.0:2000
metrics-update-freq: 30s

# Ingress rules
ingress:
  # Web application
  - hostname: app.example.com
    service: http://localhost:8080
    originRequest:
      connectTimeout: 10s
      noTLSVerify: false
  
  # WebSocket support
  - hostname: ws.example.com
    service: ws://localhost:8081
  
  # gRPC support
  - hostname: grpc.example.com
    service: grpc://localhost:9090
  
  # Static files
  - hostname: static.example.com
    service: hello_world
  
  # Unix socket
  - hostname: unix.example.com
    service: unix:/var/run/app.sock
  
  # TCP service (SSH)
  - hostname: ssh.example.com
    service: ssh://localhost:22
  
  # Bastion for arbitrary TCP
  - hostname: bastion.example.com
    service: bastion
  
  # Default catch-all
  - service: http_status:404
```

## Zero Trust Access

Protect your tunneled applications with Cloudflare Access:

### 1. Enable Access in Cloudflare Dashboard

Go to Access → Applications → Add an Application

### 2. Create Access Policy

```bash
# Allow specific emails
cloudflare-access policy create \
  --application-id <APP-ID> \
  --name "Allow team" \
  --decision allow \
  --include email:user@example.com
```

### 3. Configure Authentication

Supported identity providers:
- Google
- GitHub
- Azure AD
- Okta
- Generic SAML/OIDC
- One-time PIN (OTP)

## Monitoring and Troubleshooting

### View Tunnel Status

```bash
# List all tunnels
cloudflared tunnel list

# Get tunnel info
cloudflared tunnel info my-app-tunnel

# Check tunnel health
curl http://localhost:2000/metrics
```

### Common Issues

#### 1. Connection Failed

```bash
# Check if tunnel is running
ps aux | grep cloudflared

# Check logs
journalctl -u cloudflared -f

# Verify credentials
ls -la ~/.cloudflared/
```

#### 2. DNS Not Resolving

```bash
# Verify DNS record
dig example.com

# Check tunnel routes
cloudflared tunnel route dns my-app-tunnel example.com
```

#### 3. Origin Unreachable

```bash
# Test local service
curl http://localhost:8080

# Check firewall rules
sudo iptables -L

# Verify config.yml
cat ~/.cloudflared/config.yml
```

### Logs

```bash
# View live logs
tail -f /var/log/cloudflared.log

# Increase log verbosity
cloudflared tunnel --loglevel debug run my-app-tunnel
```

## Security Best Practices

1. **Use Zero Trust Access**: Always protect tunnels with Access policies
2. **Rotate Credentials**: Regularly rotate tunnel credentials
3. **Least Privilege**: Create tunnels with minimal required permissions
4. **Monitor Access Logs**: Review Access logs in the dashboard
5. **Network Segmentation**: Keep origin services in isolated networks
6. **Enable mTLS**: Use mutual TLS for origin authentication

## Performance Optimization

1. **Connection Pooling**: Use `keepAliveConnections` to reuse connections
2. **HTTP/2**: Enable `http2Origin` for multiplexing
3. **Compression**: Enable origin compression
4. **Geographic Distribution**: Run replicas in multiple regions
5. **CDN Caching**: Use Cache Rules for static content

## Migration from Other Solutions

### From ngrok

```bash
# ngrok command
ngrok http 8080

# Cloudflare Tunnel equivalent
cloudflared tunnel --url http://localhost:8080
```

### From SSH Tunneling

```bash
# SSH tunnel
ssh -R 80:localhost:8080 ssh.example.com

# Cloudflare Tunnel
# Configure in config.yml and run:
cloudflared tunnel run
```

## Cleanup

```bash
# Stop tunnel
sudo systemctl stop cloudflared

# Delete route
cloudflared tunnel route dns my-app-tunnel example.com --delete

# Delete tunnel
cloudflared tunnel delete my-app-tunnel

# Remove credentials
rm ~/.cloudflared/<TUNNEL-ID>.json
```

## Resources

- [Official Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [Tunnel Examples](https://github.com/cloudflare/cloudflared/tree/master/examples)
- [Community Support](https://community.cloudflare.com/)
