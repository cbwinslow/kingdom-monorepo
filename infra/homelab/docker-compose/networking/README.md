# Networking Stack

Essential networking services including Pi-hole, AdGuard Home, Nginx Proxy Manager, Traefik, and WireGuard VPN.

## Services

- **Pi-hole** (ports 53, 8081): Network-wide ad blocking DNS server
- **AdGuard Home** (ports 5353, 3000): Alternative DNS-based ad blocker
- **Nginx Proxy Manager** (ports 80, 443, 81): Easy reverse proxy with SSL
- **Traefik** (ports 8082, 8445, 8083): Modern reverse proxy and load balancer
- **WireGuard** (port 51820): Fast, modern VPN

## Quick Start

1. Copy environment file:
   ```bash
   cp .env.example .env
   ```

2. Configure your environment:
   ```bash
   vim .env
   ```

3. Create directories:
   ```bash
   mkdir -p pihole/{etc-pihole,etc-dnsmasq.d} npm/{data,letsencrypt} traefik/{letsencrypt,config} wireguard/config adguard/{work,conf}
   ```

4. Start services:
   ```bash
   # Start Pi-hole or AdGuard (choose one)
   docker-compose up -d pihole
   # OR
   docker-compose up -d adguard

   # Start proxy manager
   docker-compose up -d nginx-proxy-manager
   # OR
   docker-compose up -d traefik

   # Start VPN (optional)
   docker-compose up -d wireguard
   ```

## Pi-hole Setup

**Access**: http://localhost:8081/admin

**Configuration**:
1. Login with password from `.env`
2. Settings → DNS → Set upstream DNS servers
3. Settings → DHCP → Enable if needed
4. Whitelist/Blacklist domains as needed
5. Install blocklists from https://firebog.net

**Client Configuration**:

**Router-level** (recommended):
- Set router's DNS to Pi-hole IP
- All devices automatically use Pi-hole

**Device-level**:
- Set DNS to `192.168.1.100` (Pi-hole IP)

**Testing**:
```bash
nslookup doubleclick.net 192.168.1.100
# Should return 0.0.0.0
```

## AdGuard Home Setup

**Access**: http://localhost:3000

**Configuration**:
1. Complete initial setup wizard
2. Set admin username/password
3. Configure DNS settings
4. Add blocklists
5. Configure upstream DNS servers

**Advantages over Pi-hole**:
- Modern web interface
- Better mobile support
- HTTPS/DNS-over-TLS built-in
- Parental controls

## Nginx Proxy Manager Setup

**Access**: http://localhost:81

**Default Credentials**:
- Email: admin@example.com
- Password: changeme

**First Steps**:
1. Login and change password
2. Settings → SSL → Request Let's Encrypt cert
3. Add proxy hosts for your services

**Example Proxy Host**:
```
Domain: nextcloud.homelab.local
Forward: http://nextcloud:80
SSL: Enable with Let's Encrypt
```

**Services to Proxy**:
- Nextcloud: `nextcloud.homelab.local`
- Grafana: `grafana.homelab.local`
- Plex: `plex.homelab.local`

## Traefik Setup

**Access**: http://localhost:8083

**Configuration**:

Create `traefik/config/dynamic.yml`:
```yaml
http:
  routers:
    nextcloud:
      rule: "Host(`nextcloud.homelab.local`)"
      service: nextcloud
      entryPoints:
        - websecure
      tls:
        certResolver: letsencrypt

  services:
    nextcloud:
      loadBalancer:
        servers:
          - url: "http://nextcloud:80"
```

**Auto-discovery with Docker Labels**:
```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.myservice.rule=Host(`myservice.homelab.local`)"
  - "traefik.http.services.myservice.loadbalancer.server.port=80"
```

## WireGuard VPN Setup

**Configuration**:
1. Start WireGuard container
2. View logs for QR codes:
   ```bash
   docker logs wireguard
   ```
3. Scan QR code with WireGuard mobile app
4. Or download config files:
   ```bash
   cat wireguard/config/peer1/peer1.conf
   ```

**Client Configuration**:

**Mobile**: Use WireGuard app and scan QR code

**Desktop**: 
1. Install WireGuard client
2. Import config file
3. Activate tunnel

**Testing Connection**:
```bash
# After connecting
ping 10.13.13.1
curl ifconfig.me
```

**Access homelab while away**:
- Connect to WireGuard
- Access services via internal IPs
- Use Pi-hole DNS while connected

## Integration Examples

### Pi-hole + WireGuard

Configure WireGuard clients to use Pi-hole DNS:
```ini
[Interface]
DNS = 10.13.13.1
```

### Nginx Proxy Manager + All Services

Create proxy hosts for all your homelab services:
1. Internal access: `service.homelab.local`
2. External access: `service.yourdomain.com`
3. SSL certificates automatically managed

### Traefik + Docker Services

Add labels to any Docker service:
```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.whoami.rule=Host(`whoami.localhost`)"
```

## DNS Configuration

### Local DNS Records

**Pi-hole**:
1. Local DNS → DNS Records
2. Add: `homelab.local` → `192.168.1.100`
3. Add subdomain wildcards

**AdGuard**:
1. Filters → DNS rewrites
2. Add custom DNS records

**Example Records**:
```
nextcloud.homelab.local → 192.168.1.100
grafana.homelab.local   → 192.168.1.100
plex.homelab.local      → 192.168.1.100
*.homelab.local         → 192.168.1.100
```

## Security Considerations

### Pi-hole/AdGuard
- Change default password
- Restrict admin interface to local network
- Regular blocklist updates
- Monitor query logs for anomalies

### Proxy Managers
- Use strong passwords
- Enable HTTPS everywhere
- Regular SSL certificate renewal
- Rate limiting for external access

### WireGuard
- Keep client configs secure
- Rotate keys periodically
- Limit peer count
- Monitor active connections

## Troubleshooting

### Pi-hole not blocking ads
1. Check DNS is properly configured on client
2. Verify blocklists are up to date
3. Test with: `nslookup ads.example.com pihole-ip`
4. Check Pi-hole query log

### Nginx Proxy Manager SSL errors
1. Verify domain points to your IP
2. Check ports 80/443 are open
3. Ensure Let's Encrypt rate limits not exceeded
4. Try DNS challenge instead of HTTP

### WireGuard won't connect
1. Check firewall allows UDP 51820
2. Verify public IP/domain is correct
3. Check kernel module loaded: `lsmod | grep wireguard`
4. Review WireGuard logs

### Traefik services not accessible
1. Verify Docker labels are correct
2. Check Traefik dashboard for routes
3. Ensure container networks are connected
4. Review Traefik logs

## Backup

### Pi-hole
```bash
docker exec pihole pihole -a -t
# Or backup directories
tar czf pihole-backup.tar.gz pihole/
```

### Configurations
```bash
tar czf networking-backup.tar.gz npm/ traefik/ wireguard/ adguard/
```

## Resources

- [Pi-hole Documentation](https://docs.pi-hole.net/)
- [AdGuard Home Wiki](https://github.com/AdguardTeam/AdGuardHome/wiki)
- [Nginx Proxy Manager](https://nginxproxymanager.com/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [WireGuard Documentation](https://www.wireguard.com/)
