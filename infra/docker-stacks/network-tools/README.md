# Network Tools Stack

A comprehensive collection of network diagnostic, monitoring, and testing tools in Docker containers.

## Components

- **netshoot** - Swiss army knife for network troubleshooting
- **dnsmasq** (port 53, UI: 5380) - DNS server
- **ntopng** (port 3050) - Network traffic monitoring and analysis
- **speedtest** (port 3060-3061) - Internet speed testing
- **nmap-web** - Network scanner
- **tinyproxy** (port 8888) - HTTP/HTTPS proxy
- **dante** (port 1080) - SOCKS5 proxy
- **tcpdump** - Packet capture tool
- **bmon** - Bandwidth monitor
- **iperf3** (port 5201) - Network performance testing
- **hey** - HTTP load testing
- **httpie** - Advanced curl with better UX
- **dns-tools** - DNS utilities (dig, drill, nslookup)
- **masscan** - Fast port scanner
- **traceroute** - Route tracing and ping tools
- **wscat** - WebSocket testing client
- **grpcurl** - gRPC testing client
- **netdata** (port 19999) - Real-time performance monitoring
- **smokeping** (port 8480) - Network latency monitoring
- **network-multitool** (port 8070) - Multi-purpose network tool

## Quick Start

```bash
# Start all services
docker-compose up -d

# Start specific service
docker-compose up -d netshoot

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

## Access URLs

- dnsmasq UI: http://localhost:5380 (admin/admin)
- ntopng: http://localhost:3050
- Speedtest: http://localhost:3060
- Netdata: http://localhost:19999
- Smokeping: http://localhost:8480
- Network Multitool: http://localhost:8070

## Usage Examples

### Using netshoot

```bash
# Interactive shell
docker exec -it netshoot bash

# Quick network test
docker exec netshoot ping google.com
docker exec netshoot traceroute google.com
docker exec netshoot nslookup google.com
docker exec netshoot curl https://httpbin.org/ip

# Advanced network diagnostics
docker exec netshoot netstat -tulpn
docker exec netshoot ss -tulpn
docker exec netshoot ip addr show
docker exec netshoot ip route show
```

### DNS Testing

```bash
# Test DNS resolution
docker exec dns-tools dig google.com
docker exec dns-tools drill google.com
docker exec dns-tools nslookup google.com

# Query specific DNS server
docker exec dns-tools dig @8.8.8.8 google.com
docker exec dns-tools dig @1.1.1.1 google.com +short

# Reverse DNS lookup
docker exec dns-tools dig -x 8.8.8.8

# DNS trace
docker exec dns-tools dig +trace google.com
```

### Port Scanning

```bash
# Scan with nmap
docker exec nmap-web nmap -sV localhost
docker exec nmap-web nmap -p 1-1000 192.168.1.1

# Fast scan with masscan
docker exec masscan masscan -p1-65535 192.168.1.0/24 --rate=10000
```

### Network Performance Testing

```bash
# Start iperf3 server (already running in container)
# On client machine:
iperf3 -c localhost -p 5201

# Or from another container:
docker run --rm -it --network network-tools_network-tools \
  networkstatic/iperf3 -c iperf3 -p 5201

# Test UDP performance
docker run --rm -it --network network-tools_network-tools \
  networkstatic/iperf3 -c iperf3 -u -b 100M

# Reverse mode
docker run --rm -it --network network-tools_network-tools \
  networkstatic/iperf3 -c iperf3 -R
```

### HTTP Load Testing

```bash
# Load test with hey
docker exec hey hey -n 1000 -c 10 https://example.com

# Custom headers
docker exec hey hey -n 100 -H "Authorization: Bearer token" https://api.example.com

# POST request
docker exec hey hey -n 100 -m POST -d '{"key":"value"}' https://api.example.com
```

### HTTP Requests

```bash
# Using httpie
docker exec httpie http GET https://httpbin.org/get
docker exec httpie http POST https://httpbin.org/post key=value
docker exec httpie http --download https://example.com/file.zip

# Using curl
docker exec httpie curl -X GET https://httpbin.org/get
docker exec httpie curl -X POST https://httpbin.org/post -d '{"key":"value"}'
docker exec httpie wget https://example.com/file.zip
```

### Packet Capture

```bash
# Capture all traffic
docker exec tcpdump tcpdump -i any -w /data/capture.pcap

# Capture specific port
docker exec tcpdump tcpdump -i any port 80 -w /data/http.pcap

# Capture specific host
docker exec tcpdump tcpdump -i any host 192.168.1.1 -w /data/host.pcap

# Read captured file
docker exec tcpdump tcpdump -r /data/capture.pcap

# Captures are saved to ./captures directory
```

### Traceroute and Ping

```bash
# Traceroute
docker exec traceroute traceroute google.com
docker exec traceroute mtr google.com

# Ping
docker exec traceroute ping -c 4 google.com

# Advanced ping
docker exec traceroute ping -c 10 -i 0.5 google.com
```

### WebSocket Testing

```bash
# Connect to WebSocket
docker exec -it wscat wscat -c ws://echo.websocket.org

# With headers
docker exec -it wscat wscat -c wss://example.com/ws -H "Authorization: Bearer token"
```

### gRPC Testing

```bash
# List services
docker exec grpcurl grpcurl -plaintext localhost:50051 list

# Describe service
docker exec grpcurl grpcurl -plaintext localhost:50051 describe my.Service

# Make request
docker exec grpcurl grpcurl -plaintext -d '{"name": "world"}' \
  localhost:50051 my.Service/SayHello
```

### Proxy Usage

```bash
# Use HTTP proxy
curl -x http://localhost:8888 https://httpbin.org/ip

# Use SOCKS5 proxy
curl -x socks5://localhost:1080 https://httpbin.org/ip

# Configure system proxy
export http_proxy=http://localhost:8888
export https_proxy=http://localhost:8888
export socks_proxy=socks5://localhost:1080
```

### Bandwidth Monitoring

```bash
# View bandwidth usage with bmon
docker attach bmon

# View with netdata (web UI)
# Navigate to http://localhost:19999
```

## Configuration Files

### dnsmasq Configuration

Create `dnsmasq/dnsmasq.conf`:

```conf
# Listen on all interfaces
listen-address=0.0.0.0

# Never forward plain names
domain-needed

# Never forward addresses in non-routed address spaces
bogus-priv

# Don't read /etc/resolv.conf
no-resolv

# Use Google DNS
server=8.8.8.8
server=8.8.4.4

# Cache size
cache-size=1000

# Log queries
log-queries

# Custom DNS records
address=/local.dev/192.168.1.100
address=/api.local/192.168.1.101
```

### tinyproxy Configuration

Create `tinyproxy/tinyproxy.conf`:

```conf
Port 8888
Listen 0.0.0.0
Timeout 600
MaxClients 100
MinSpareServers 5
MaxSpareServers 20
StartServers 10
LogLevel Info
PidFile "/var/run/tinyproxy/tinyproxy.pid"
LogFile "/var/log/tinyproxy/tinyproxy.log"
ViaProxyName "tinyproxy"

# Allow all
Allow 0.0.0.0/0

# Add headers
AddHeader "X-Proxy" "tinyproxy"
```

### dante SOCKS5 Configuration

Create `dante/sockd.conf`:

```conf
logoutput: stderr

internal: 0.0.0.0 port = 1080
external: eth0

clientmethod: none
socksmethod: none

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
}

socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    protocol: tcp udp
}
```

## Common Use Cases

### 1. Troubleshooting Network Connectivity

```bash
# Check if host is reachable
docker exec netshoot ping -c 4 target.host

# Check DNS resolution
docker exec dns-tools dig target.host

# Check route to host
docker exec traceroute traceroute target.host

# Check open ports
docker exec nmap-web nmap -p- target.host
```

### 2. Testing API Endpoints

```bash
# GET request
docker exec httpie http GET https://api.example.com/endpoint

# POST with JSON
docker exec httpie http POST https://api.example.com/endpoint \
  key=value header:Authorization:"Bearer token"

# Load testing
docker exec hey hey -n 1000 -c 50 https://api.example.com/endpoint
```

### 3. Monitoring Network Performance

```bash
# Real-time monitoring
# Access netdata UI at http://localhost:19999

# Network latency
# Access smokeping UI at http://localhost:8480

# Bandwidth usage
docker attach bmon
```

### 4. Analyzing Network Traffic

```bash
# Start capture
docker exec tcpdump tcpdump -i any -w /data/capture.pcap

# Stop capture (Ctrl+C)

# Analyze with netshoot
docker exec netshoot tcpdump -r /data/capture.pcap

# Or download and analyze with Wireshark
# File is in ./captures/capture.pcap
```

### 5. Testing Network Speed

```bash
# Open browser to http://localhost:3060

# Or use iperf3
docker run --rm -it --network network-tools_network-tools \
  networkstatic/iperf3 -c iperf3 -t 30
```

## Security Considerations

**Warning**: These tools are powerful and should be used responsibly.

1. **Never use these tools** on networks you don't own or have permission to test
2. **Port scanning** may be illegal in some jurisdictions
3. **Packet capture** may expose sensitive data
4. **Proxies** should be properly secured in production
5. **DNS server** should have access controls
6. **Limit container capabilities** when possible
7. **Use in isolated networks** for testing
8. **Don't expose ports** to the internet without proper security

## Troubleshooting

### Container won't start

```bash
# Check logs
docker-compose logs [service-name]

# Check if ports are already in use
netstat -tulpn | grep [port]
```

### Permission denied errors

Some tools require elevated privileges:

```bash
# Ensure capabilities are added
cap_add:
  - NET_ADMIN
  - NET_RAW
```

### Can't capture packets

```bash
# Ensure running with proper permissions
docker exec --privileged tcpdump tcpdump -i any
```

### DNS not resolving

```bash
# Test DNS server
docker exec dns-tools dig @localhost google.com

# Check dnsmasq config
docker exec dnsmasq cat /etc/dnsmasq.conf
```

## Best Practices

1. **Use specific tools** for specific tasks
2. **Clean up captures** regularly to save disk space
3. **Monitor resource usage** of monitoring tools
4. **Document findings** from network analysis
5. **Use version control** for configurations
6. **Regular updates** of container images
7. **Test in staging** before production
8. **Keep logs** for audit purposes

## Additional Tools Available

Each container comes with additional utilities:

- **netshoot**: curl, wget, tcpdump, nmap, iperf, netcat, socat, drill, etc.
- **network-multitool**: nginx, curl, wget, netcat, nmap, iperf3, and more
- **dns-tools**: dig, drill, nslookup, host

## Performance Tips

1. **Limit concurrent containers** to available resources
2. **Use host networking** for performance testing when safe
3. **Increase capture buffer** for high-traffic packet capture
4. **Use SSD storage** for packet captures
5. **Adjust cache sizes** for DNS and monitoring tools

## Integration with Other Stacks

### With Monitoring Stack

```yaml
# Add to monitoring stack's prometheus.yml
scrape_configs:
  - job_name: 'netdata'
    static_configs:
      - targets: ['netdata:19999']
```

### With MCP Servers

Network tools can be used to diagnose MCP server connectivity issues.

## References

- [netshoot GitHub](https://github.com/nicolaka/netshoot)
- [ntopng Documentation](https://www.ntop.org/guides/ntopng/)
- [iperf3 Documentation](https://iperf.fr/iperf-doc.php)
- [nmap Reference Guide](https://nmap.org/book/man.html)
- [tcpdump Manual](https://www.tcpdump.org/manpages/tcpdump.1.html)
- [netdata Documentation](https://learn.netdata.cloud/)
