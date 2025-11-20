# WireGuard VPN Stack

Comprehensive VPN solution stack with WireGuard, OpenVPN, IPsec, and modern mesh VPN technologies.

## Components

- **wireguard** (port 51820/udp) - Fast, modern VPN
- **wireguard-ui** (port 5000) - Web management interface
- **openvpn** (port 1194/udp) - Traditional VPN solution
- **openvpn-admin** (port 8080) - OpenVPN management UI
- **ipsec-vpn** (ports 500, 4500/udp) - IPsec/L2TP VPN
- **softether** (multiple ports) - Multi-protocol VPN
- **pritunl** (ports 1194, 9700, 9443) - Enterprise VPN with UI
- **pritunl-mongo** - MongoDB for Pritunl
- **tailscale** - Mesh VPN network
- **nebula** - Overlay mesh network
- **pihole** (port 53, UI: 8053) - DNS server for VPN
- **ntopng** (port 3050) - Traffic analyzer
- **speedtest** (ports 3000-3001) - Speed testing
- **vpn-monitor** - Status monitoring
- **vpn-client-test** - Testing container

## Quick Start

### WireGuard Setup

```bash
# Create .env file
cat > .env <<EOF
SERVERURL=your.domain.com  # Or 'auto' for auto-detection
SERVERPORT=51820
PEERS=10  # Number of client configs to generate
INTERNAL_SUBNET=10.13.13.0

# WireGuard UI
WGUI_USERNAME=admin
WGUI_PASSWORD=secure_password
SESSION_SECRET=random_secret_string

# Pi-hole
PIHOLE_PASSWORD=admin
SERVERIP=10.13.13.1
EOF

# Start WireGuard
docker-compose up -d wireguard wireguard-ui

# View logs
docker-compose logs -f wireguard

# Get client configurations
ls config/peer*/peer*.conf
```

### Access WireGuard UI

1. Open http://localhost:5000
2. Login with WGUI_USERNAME/WGUI_PASSWORD
3. Create and manage client connections

### Connect Client

```bash
# Copy client config
docker exec wireguard cat /config/peer1/peer1.conf > peer1.conf

# On Linux client
sudo wg-quick up ./peer1.conf

# Check status
sudo wg show

# Disconnect
sudo wg-quick down ./peer1.conf
```

### OpenVPN Setup

```bash
# Initialize OpenVPN
docker-compose run --rm openvpn ovpn_genconfig -u udp://your.domain.com
docker-compose run --rm openvpn ovpn_initpki

# Generate client certificate
docker-compose run --rm openvpn easyrsa build-client-full client1 nopass

# Get client config
docker-compose run --rm openvpn ovpn_getclient client1 > client1.ovpn

# Start OpenVPN
docker-compose up -d openvpn
```

## Client Configuration

### WireGuard Client (Windows/Mac/Linux)

1. Download WireGuard client
2. Import config file (peer*.conf)
3. Activate connection

### WireGuard Client (Mobile)

1. Install WireGuard app
2. Scan QR code:
```bash
docker exec wireguard /app/show-peer 1
```

### OpenVPN Client

```bash
# Linux
sudo openvpn --config client1.ovpn

# Using NetworkManager
nmcli connection import type openvpn file client1.ovpn
```

## VPN Features

### WireGuard Features
- Modern cryptography (ChaCha20, Poly1305)
- Minimal attack surface
- High performance
- Stealth mode
- Mobile-friendly

### OpenVPN Features
- Cross-platform support
- Strong security
- Flexible configuration
- Port 443 support
- Certificate-based auth

### IPsec Features
- Native OS support
- Hardware acceleration
- L2TP/IPsec combo
- IKEv2 support
- Split tunneling

### Tailscale Features
- Zero-config mesh VPN
- NAT traversal
- End-to-end encryption
- ACLs and permissions
- Multi-platform

## Monitoring

### Check VPN Status

```bash
# WireGuard status
docker exec wireguard wg show

# Active connections
docker exec wireguard wg show wg0

# Connection stats
docker exec wireguard wg show wg0 dump
```

### Monitor Traffic

```bash
# View ntopng
open http://localhost:3050

# Check connection logs
docker-compose logs vpn-monitor
cat monitor/logs/status.log
```

### Speed Test

```bash
# Access speed test UI
open http://localhost:3000

# Or use iperf3
docker exec vpn-client-test iperf3 -c iperf.example.com
```

## Security

### Best Practices

1. **Strong pre-shared keys** for all VPN types
2. **Certificate-based auth** for OpenVPN
3. **Regular key rotation** (every 90 days)
4. **Enable kill switch** on clients
5. **Use DNS over VPN** (Pi-hole)
6. **Monitor connections** regularly
7. **Limit peer access** with firewall rules
8. **Regular security updates**

### Firewall Rules

```bash
# Allow VPN traffic
iptables -A INPUT -p udp --dport 51820 -j ACCEPT
iptables -A INPUT -p udp --dport 1194 -j ACCEPT
iptables -A INPUT -p udp --dport 500 -j ACCEPT
iptables -A INPUT -p udp --dport 4500 -j ACCEPT

# Enable NAT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

### Split Tunneling

WireGuard config for split tunneling:

```ini
[Interface]
PrivateKey = <private-key>
Address = 10.13.13.2/32
DNS = 10.13.13.1

[Peer]
PublicKey = <server-public-key>
Endpoint = your.domain.com:51820
# Only route VPN subnet, not all traffic
AllowedIPs = 10.13.13.0/24
PersistentKeepalive = 25
```

## Troubleshooting

### WireGuard Not Connecting

```bash
# Check server status
docker exec wireguard wg show

# Check logs
docker-compose logs wireguard

# Verify port forwarding
nc -zuv your.domain.com 51820

# Check kernel module
docker exec wireguard lsmod | grep wireguard
```

### OpenVPN Authentication Failed

```bash
# Check certificate
openssl x509 -in client1.crt -text -noout

# Verify CA
openssl verify -CAfile ca.crt client1.crt

# Check logs
docker-compose logs openvpn
```

### DNS Not Working

```bash
# Check Pi-hole status
docker-compose logs pihole

# Test DNS
docker exec vpn-client-test nslookup google.com 10.13.13.1

# Check DNS forwarding
docker exec pihole cat /etc/dnsmasq.d/01-pihole.conf
```

## Advanced Configuration

### Multi-Hop VPN

Chain VPN connections for additional privacy:

```bash
# Connect to VPN1
wg-quick up vpn1

# Then connect through VPN2
openvpn --config vpn2.ovpn
```

### Site-to-Site VPN

Connect two networks with WireGuard:

```ini
# Site A config
[Interface]
Address = 10.13.13.1/24
ListenPort = 51820

[Peer]
PublicKey = <site-b-public-key>
Endpoint = site-b.example.com:51820
AllowedIPs = 10.14.14.0/24
```

### VPN Load Balancing

```bash
# Use multiple WireGuard instances
docker-compose up -d --scale wireguard=3

# Configure load balancer (nginx)
stream {
    upstream vpn_backend {
        server wireguard-1:51820;
        server wireguard-2:51820;
        server wireguard-3:51820;
    }
    
    server {
        listen 51820 udp;
        proxy_pass vpn_backend;
    }
}
```

## Performance Tuning

### WireGuard Optimization

```bash
# Increase MTU
ip link set mtu 1420 dev wg0

# Adjust buffer sizes
sysctl -w net.core.rmem_max=2500000
sysctl -w net.core.wmem_max=2500000
```

### OpenVPN Optimization

```conf
# Add to server config
sndbuf 524288
rcvbuf 524288
push "sndbuf 524288"
push "rcvbuf 524288"
fast-io
comp-lzo no
```

## Backup and Recovery

### Backup Configurations

```bash
# Backup WireGuard configs
tar czf wireguard-backup-$(date +%Y%m%d).tar.gz config/

# Backup OpenVPN
tar czf openvpn-backup-$(date +%Y%m%d).tar.gz openvpn/

# Secure backup (encrypted)
tar czf - config/ | gpg -c > vpn-backup-$(date +%Y%m%d).tar.gz.gpg
```

### Restore

```bash
# Restore and restart
tar xzf wireguard-backup-20240101.tar.gz
docker-compose restart wireguard
```

## References

- [WireGuard Documentation](https://www.wireguard.com/quickstart/)
- [OpenVPN Documentation](https://openvpn.net/community-resources/)
- [Tailscale Documentation](https://tailscale.com/kb/)
- [Pi-hole Documentation](https://docs.pi-hole.net/)
- [Nebula Documentation](https://nebula.defined.net/docs/)
