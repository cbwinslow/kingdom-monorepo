# Proxy Stack

Comprehensive collection of reverse proxies, load balancers, and proxy servers for various use cases.

## Components

### Reverse Proxies & Load Balancers
- **Nginx** (port 80, 443) - High-performance reverse proxy
- **Traefik** (port 8080, 8443, dashboard: 8888) - Modern reverse proxy with automatic HTTPS
- **HAProxy** (port 9080, 9443, stats: 8404) - Enterprise load balancer
- **Caddy** (port 10080, 10443, admin: 2019) - Automatic HTTPS server
- **Envoy** (port 10000, admin: 9901) - Cloud-native proxy

### Forward Proxies
- **Squid** (port 3128) - Caching proxy server
- **Privoxy** (port 8118) - Privacy-focused proxy
- **Dante** (port 1080) - SOCKS5 proxy
- **tinyproxy** (port 8888) - Lightweight HTTP proxy
- **mitmproxy** (proxy: 8282, web UI: 8281) - SSL-capable debugging proxy

### Test Services
- **whoami** - Test backend service
- **httpbin** - HTTP testing service
- **proxy-tester** - Testing and debugging tools

## Quick Start

```bash
# Create configuration directories
mkdir -p nginx/conf.d nginx/ssl nginx/cache nginx/logs
mkdir -p traefik/letsencrypt traefik/config traefik/logs
mkdir -p haproxy/ssl haproxy/errors
mkdir -p caddy/data caddy/config caddy/logs
mkdir -p squid/cache squid/logs
mkdir -p privoxy/config privoxy/logs
mkdir -p dante mitmproxy envoy/logs

# Create .env file
cat > .env <<EOF
ACME_EMAIL=admin@example.com
TRAEFIK_LOG_LEVEL=INFO
EOF

# Start all services
docker-compose up -d

# Start specific proxy
docker-compose up -d nginx traefik
```

## Access URLs

- Nginx: http://localhost
- Traefik Dashboard: http://localhost:8888
- Traefik Service: http://localhost:8080
- HAProxy: http://localhost:9080
- HAProxy Stats: http://localhost:8404
- Caddy: http://localhost:10080
- Caddy Admin: http://localhost:2019
- mitmproxy Web: http://localhost:8281
- whoami (via Traefik): http://whoami.localhost:8080
- httpbin (via Traefik): http://httpbin.localhost:8080

## Configuration Examples

### Nginx Configuration

Create `nginx/conf.d/app.conf`:

```nginx
upstream backend {
    least_conn;
    server app1:8080;
    server app2:8080;
    server app3:8080;
}

server {
    listen 80;
    server_name example.com;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Caching
        proxy_cache my_cache;
        proxy_cache_valid 200 1h;
        proxy_cache_bypass $http_cache_control;
        add_header X-Cache-Status $upstream_cache_status;
    }
}
```

### Traefik Dynamic Configuration

Create `traefik/config/dynamic.yml`:

```yaml
http:
  routers:
    my-router:
      rule: "Host(`app.example.com`)"
      service: my-service
      entryPoints:
        - websecure
      tls:
        certResolver: myresolver

  services:
    my-service:
      loadBalancer:
        servers:
          - url: "http://app1:8080"
          - url: "http://app2:8080"
        healthCheck:
          path: /health
          interval: 10s
```

### HAProxy Configuration

Create `haproxy/haproxy.cfg`:

```cfg
global
    maxconn 4096
    log stdout format raw local0

defaults
    mode http
    timeout connect 5s
    timeout client 50s
    timeout server 50s
    log global
    option httplog

frontend http-in
    bind *:80
    acl is_api path_beg /api
    use_backend api-servers if is_api
    default_backend web-servers

backend web-servers
    balance roundrobin
    option httpchk GET /health
    server web1 app1:8080 check
    server web2 app2:8080 check

backend api-servers
    balance leastconn
    option httpchk GET /api/health
    server api1 api1:3000 check
    server api2 api2:3000 check

listen stats
    bind *:8404
    stats enable
    stats uri /
    stats refresh 10s
```

### Caddy Configuration

Create `caddy/Caddyfile`:

```caddy
{
    email admin@example.com
    admin :2019
}

example.com {
    reverse_proxy app1:8080 app2:8080 {
        lb_policy least_conn
        health_uri /health
        health_interval 10s
    }
    
    encode gzip
    log {
        output file /var/log/caddy/access.log
    }
}

api.example.com {
    reverse_proxy api:3000
    
    @websocket {
        header Connection *Upgrade*
        header Upgrade websocket
    }
    reverse_proxy @websocket api:3001
}
```

### Squid Configuration

Create `squid/squid.conf`:

```conf
# Access control
acl localnet src 192.168.0.0/16
acl localnet src 172.16.0.0/12
acl localnet src 10.0.0.0/8

acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 443
acl CONNECT method CONNECT

# Deny requests to unsafe ports
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports

# Allow localhost and local network
http_access allow localnet
http_access allow localhost
http_access deny all

# Squid listens on port 3128
http_port 3128

# Cache settings
cache_dir ufs /var/spool/squid 10000 16 256
maximum_object_size 50 MB
cache_mem 256 MB

# Logging
access_log /var/log/squid/access.log
cache_log /var/log/squid/cache.log
```

### Envoy Configuration

Create `envoy/envoy.yaml`:

```yaml
static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 10000
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          route_config:
            name: local_route
            virtual_hosts:
            - name: backend
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: service_backend
          http_filters:
          - name: envoy.filters.http.router
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router

  clusters:
  - name: service_backend
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: service_backend
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: app1
                port_value: 8080
        - endpoint:
            address:
              socket_address:
                address: app2
                port_value: 8080

admin:
  address:
    socket_address:
      address: 0.0.0.0
      port_value: 9901
```

## Usage Examples

### Test with curl

```bash
# Test Nginx
curl http://localhost

# Test Traefik
curl http://localhost:8080

# Test with custom host header
curl -H "Host: whoami.localhost" http://localhost:8080

# Test HAProxy
curl http://localhost:9080

# View HAProxy stats
curl http://localhost:8404
```

### Using HTTP Proxy

```bash
# Use Squid proxy
curl -x http://localhost:3128 https://httpbin.org/ip

# Use tinyproxy
curl -x http://localhost:8888 https://httpbin.org/ip

# Set environment variable
export http_proxy=http://localhost:3128
export https_proxy=http://localhost:3128
curl https://httpbin.org/ip
```

### Using SOCKS5 Proxy

```bash
# Use Dante SOCKS5
curl -x socks5://localhost:1080 https://httpbin.org/ip

# With authentication (if configured)
curl -x socks5://user:pass@localhost:1080 https://httpbin.org/ip
```

### SSL Interception with mitmproxy

```bash
# Install CA certificate
docker cp proxy-mitmproxy:/home/mitmproxy/.mitmproxy/mitmproxy-ca-cert.pem .

# Use proxy
curl -x http://localhost:8282 --cacert mitmproxy-ca-cert.pem https://httpbin.org/ip

# View web interface
open http://localhost:8281
```

## Load Balancing Algorithms

### Round Robin (Nginx)
```nginx
upstream backend {
    server app1:8080;
    server app2:8080;
}
```

### Least Connections (Nginx)
```nginx
upstream backend {
    least_conn;
    server app1:8080;
    server app2:8080;
}
```

### IP Hash (Nginx)
```nginx
upstream backend {
    ip_hash;
    server app1:8080;
    server app2:8080;
}
```

### Weighted (HAProxy)
```cfg
backend web-servers
    server web1 app1:8080 weight 3
    server web2 app2:8080 weight 1
```

## Health Checks

### Nginx Health Check

```nginx
upstream backend {
    server app1:8080 max_fails=3 fail_timeout=30s;
    server app2:8080 max_fails=3 fail_timeout=30s;
}
```

### Traefik Health Check

```yaml
http:
  services:
    my-service:
      loadBalancer:
        healthCheck:
          path: /health
          interval: 10s
          timeout: 3s
```

### HAProxy Health Check

```cfg
backend web-servers
    option httpchk GET /health
    http-check expect status 200
    server web1 app1:8080 check inter 5s
```

## Security

### Rate Limiting (Nginx)

```nginx
limit_req_zone $binary_remote_addr zone=mylimit:10m rate=10r/s;

server {
    location / {
        limit_req zone=mylimit burst=20;
        proxy_pass http://backend;
    }
}
```

### IP Whitelisting (Nginx)

```nginx
geo $whitelist {
    default 0;
    10.0.0.0/8 1;
    192.168.0.0/16 1;
}

server {
    if ($whitelist = 0) {
        return 403;
    }
    # ... rest of config
}
```

### TLS Configuration

```nginx
server {
    listen 443 ssl http2;
    
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    # HSTS
    add_header Strict-Transport-Security "max-age=31536000" always;
}
```

## Monitoring

### Nginx Status

```nginx
location /nginx_status {
    stub_status on;
    access_log off;
    allow 127.0.0.1;
    deny all;
}
```

### Traefik Metrics

Traefik exposes Prometheus metrics automatically:
```bash
curl http://localhost:8888/metrics
```

### HAProxy Stats Page

Access at: http://localhost:8404

Or via API:
```bash
curl http://localhost:8404/stats?stats;csv
```

## Troubleshooting

### Check Proxy Logs

```bash
# Nginx
docker-compose logs nginx

# Traefik
docker-compose logs traefik

# HAProxy
docker-compose logs haproxy
```

### Test Backend Connectivity

```bash
# From proxy container
docker exec proxy-nginx curl http://whoami

# Check DNS resolution
docker exec proxy-nginx nslookup whoami
```

### Debug with Test Tool

```bash
# Interactive shell
docker exec -it proxy-tester sh

# Test connections
curl http://nginx
curl http://traefik:8080
nc -zv haproxy 80
```

## Performance Tuning

### Nginx Worker Processes

```nginx
worker_processes auto;
worker_rlimit_nofile 65535;
events {
    worker_connections 4096;
    use epoll;
}
```

### Connection Pooling

```nginx
upstream backend {
    server app:8080;
    keepalive 32;
}
```

### Caching

```nginx
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m max_size=1g inactive=60m;

location / {
    proxy_cache my_cache;
    proxy_cache_valid 200 1h;
    proxy_cache_key "$scheme$request_method$host$request_uri";
}
```

## References

- [Nginx Documentation](https://nginx.org/en/docs/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [HAProxy Documentation](http://www.haproxy.org/#docs)
- [Caddy Documentation](https://caddyserver.com/docs/)
- [Envoy Documentation](https://www.envoyproxy.io/docs/envoy/latest/)
- [Squid Documentation](http://www.squid-cache.org/Doc/)
