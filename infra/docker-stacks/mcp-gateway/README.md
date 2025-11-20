# MCP Gateway Stack

HTTP/SSE gateway for Model Context Protocol (MCP) servers, enabling web-based access to MCP services.

## Components

- **mcp-gateway** (port 3000) - HTTP/SSE gateway for MCP servers
- **redis** (port 6379) - Session management and caching
- **nginx** (port 80, 443) - Reverse proxy with SSL termination
- **wscat** - WebSocket testing client
- **curl** - SSE testing client
- **gateway-exporter** (port 9091) - Prometheus metrics exporter

## Quick Start

### 1. Create Environment File

Create `.env` file:

```bash
# Redis
REDIS_PASSWORD=secure_redis_password

# Logging
LOG_LEVEL=info

# Session
SESSION_SECRET=your_session_secret_here_change_this
```

### 2. Create Configuration Directory

```bash
mkdir -p config nginx/conf.d nginx/ssl logs
```

### 3. Configure Nginx

Create `nginx/conf.d/default.conf`:

```nginx
upstream mcp_gateway {
    server mcp-gateway:3000;
}

server {
    listen 80;
    server_name localhost;

    location / {
        proxy_pass http://mcp_gateway;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # SSE specific settings
        proxy_buffering off;
        proxy_cache off;
        proxy_read_timeout 86400s;
        proxy_send_timeout 86400s;
    }

    location /health {
        proxy_pass http://mcp_gateway/health;
    }
}
```

### 4. Start Services

```bash
docker-compose up -d

# View logs
docker-compose logs -f mcp-gateway

# Check health
curl http://localhost:3000/health
```

## Usage

### Test SSE Connection

```bash
# Using curl
docker exec mcp-curl curl -N http://mcp-gateway:3000/sse

# From host
curl -N http://localhost:3000/sse
```

### Test WebSocket Connection

```bash
# Interactive WebSocket connection
docker exec -it mcp-wscat wscat -c ws://mcp-gateway:3000/ws

# Send message
> {"type": "ping"}
```

### Connect from AI Agent

```javascript
// JavaScript client
const eventSource = new EventSource('http://localhost:3000/sse');

eventSource.onmessage = (event) => {
  console.log('Received:', event.data);
};

eventSource.onerror = (error) => {
  console.error('SSE error:', error);
};
```

```python
# Python client
import sseclient
import requests

response = requests.get('http://localhost:3000/sse', stream=True)
client = sseclient.SSEClient(response)

for event in client.events():
    print(f'Received: {event.data}')
```

## Monitoring

### Prometheus Metrics

```bash
# View metrics
curl http://localhost:9091/metrics

# Example output:
# mcp_gateway_requests_total 42
# mcp_gateway_errors_total 0
# mcp_gateway_active_connections 3
```

### Gateway Health

```bash
# Check health
curl http://localhost:3000/health

# Expected response:
# {"status": "healthy"}
```

## Configuration

### Gateway Configuration

Create `config/gateway.json`:

```json
{
  "port": 3000,
  "logLevel": "info",
  "cors": {
    "enabled": true,
    "origins": ["*"]
  },
  "rateLimit": {
    "enabled": true,
    "max": 100,
    "window": "15m"
  },
  "session": {
    "secret": "change-this-secret",
    "maxAge": 3600000
  }
}
```

### SSL Configuration

For production, add SSL certificates:

```bash
# Generate self-signed certificate (for testing)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/nginx.key \
  -out nginx/ssl/nginx.crt \
  -subj "/CN=localhost"

# Update nginx config for HTTPS
```

Create `nginx/conf.d/ssl.conf`:

```nginx
server {
    listen 443 ssl http2;
    server_name localhost;

    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://mcp-gateway:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_buffering off;
        proxy_cache off;
        proxy_read_timeout 86400s;
        proxy_send_timeout 86400s;
    }
}
```

## Integration with MCP Servers

### Connect to Local MCP Server

```javascript
// Gateway connects to stdio MCP server
const gateway = require('@modelcontextprotocol/gateway');

gateway.addServer('filesystem', {
  command: 'npx',
  args: ['-y', '@modelcontextprotocol/server-filesystem', '/data']
});

gateway.start();
```

### Proxy Through Gateway

```json
{
  "mcpServers": {
    "remote-filesystem": {
      "url": "http://localhost:3000/sse",
      "transport": "sse"
    }
  }
}
```

## Troubleshooting

### Gateway Won't Start

```bash
# Check logs
docker-compose logs mcp-gateway

# Check port availability
netstat -tulpn | grep 3000
```

### SSE Connection Issues

```bash
# Test with curl
curl -v -N http://localhost:3000/sse

# Check nginx logs
docker-compose logs nginx

# Verify buffering is disabled in nginx
```

### Redis Connection Errors

```bash
# Test Redis connection
docker exec mcp-gateway-redis redis-cli ping

# Test with password
docker exec mcp-gateway-redis redis-cli -a your_password ping
```

## Security

### Production Recommendations

1. **Use HTTPS** with valid SSL certificates
2. **Enable authentication** for gateway access
3. **Rate limiting** to prevent abuse
4. **CORS configuration** to restrict origins
5. **Redis password** for session store
6. **Network isolation** using Docker networks
7. **Regular updates** of container images

### Authentication Example

```nginx
# Add basic auth to nginx
location / {
    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.htpasswd;
    
    proxy_pass http://mcp_gateway;
    # ... other proxy settings
}
```

Generate password file:

```bash
# Install htpasswd
apt-get install apache2-utils

# Create password file
htpasswd -c nginx/.htpasswd admin
```

## Scaling

### Multiple Gateway Instances

```yaml
services:
  mcp-gateway:
    # ... existing config
    deploy:
      replicas: 3
```

### Load Balancing with Nginx

```nginx
upstream mcp_gateway {
    least_conn;
    server mcp-gateway-1:3000;
    server mcp-gateway-2:3000;
    server mcp-gateway-3:3000;
}
```

## Performance Tuning

### Nginx Optimization

```nginx
worker_processes auto;
worker_connections 4096;

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    
    # Enable gzip
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_types text/plain text/css application/json application/javascript;
}
```

### Redis Optimization

```bash
# Increase max connections
redis-server --maxclients 10000

# Use Redis Cluster for scaling
```

## Monitoring Integration

### Prometheus Scrape Config

```yaml
scrape_configs:
  - job_name: 'mcp-gateway'
    static_configs:
      - targets: ['localhost:9091']
```

### Grafana Dashboard

Create dashboard with metrics:
- Request rate
- Error rate
- Active connections
- Response time
- Redis operations

## References

- [MCP Specification](https://modelcontextprotocol.io)
- [Server-Sent Events (SSE)](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events)
- [WebSocket Protocol](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Redis Documentation](https://redis.io/documentation)
