# WireGuard VPN Setup and Management

This directory contains scripts and configurations for setting up and managing WireGuard VPN connections.

## Directory Structure

```
wireguard/
├── configs/              # VPN configuration files
│   └── wg0.conf.template # Template configuration file
├── scripts/              # Management scripts
│   ├── setup-wireguard.sh    # Install and configure WireGuard
│   ├── vpn-control.sh        # Control VPN connections
│   ├── vpn-maintain.sh       # Monitor and maintain connections
│   └── configure-network.sh  # Configure network settings
└── README.md            # This file
```

## Quick Start

### 1. Generate Keys

First, generate your WireGuard keys:

```bash
# Generate private key
wg genkey | tee privatekey

# Generate public key from private key
cat privatekey | wg pubkey > publickey

# Display keys
echo "Private Key: $(cat privatekey)"
echo "Public Key: $(cat publickey)"
```

### 2. Create Configuration

Copy the template and configure your VPN:

```bash
cd configs/
cp wg0.conf.template wg0.conf
```

Edit `wg0.conf` and replace:
- `YOUR_PRIVATE_KEY_HERE` with your private key
- `SERVER_PUBLIC_KEY_HERE` with your VPN server's public key
- `vpn.example.com:51820` with your VPN server's endpoint
- Adjust IP addresses and other settings as needed

**Important:** Keep your private key secure! Set proper permissions:
```bash
chmod 600 wg0.conf
```

### 3. Install WireGuard

Run the setup script to install WireGuard and configure your system:

```bash
cd scripts/
sudo ./setup-wireguard.sh
```

This script will:
- Install WireGuard and required tools
- Copy your configuration to `/etc/wireguard/`
- Enable IP forwarding
- Set up the WireGuard service

### 4. Start VPN Connection

```bash
# Start the VPN
sudo ./vpn-control.sh start

# Check status
sudo ./vpn-control.sh status

# Enable automatic start on boot
sudo ./vpn-control.sh enable
```

### 5. Configure Network Settings (Optional)

If you need to configure DNS or routing for your wired connection:

```bash
# Apply VPN network configuration
sudo ./configure-network.sh apply

# Show current network configuration
sudo ./configure-network.sh show

# Remove VPN network configuration (restore original)
sudo ./configure-network.sh remove
```

## Script Documentation

### setup-wireguard.sh

Installs and configures WireGuard on your system.

**Usage:**
```bash
sudo ./setup-wireguard.sh [interface]
```

**Examples:**
```bash
# Setup default wg0 interface
sudo ./setup-wireguard.sh

# Setup custom interface
sudo ./setup-wireguard.sh wg1
```

**Supported Operating Systems:**
- Ubuntu/Debian
- Fedora/RHEL/CentOS
- Arch Linux

### vpn-control.sh

Control WireGuard VPN connections (start, stop, restart, status).

**Usage:**
```bash
sudo ./vpn-control.sh {start|stop|restart|status|enable|disable} [interface]
```

**Commands:**
- `start` - Start the VPN connection
- `stop` - Stop the VPN connection
- `restart` - Restart the VPN connection
- `status` - Show detailed VPN status
- `enable` - Enable VPN to start on boot
- `disable` - Disable VPN from starting on boot

**Examples:**
```bash
# Start VPN
sudo ./vpn-control.sh start

# Check status
sudo ./vpn-control.sh status

# Restart with custom interface
sudo ./vpn-control.sh restart wg1

# Enable automatic start
sudo ./vpn-control.sh enable
```

### vpn-maintain.sh

Monitor and maintain WireGuard VPN connections.

**Usage:**
```bash
sudo ./vpn-maintain.sh {check|restart|stats|monitor} [interface] [interval]
```

**Commands:**
- `check` - Check VPN connection health
- `restart` - Check health and restart if unhealthy
- `stats` - Show detailed VPN statistics
- `monitor` - Continuously monitor VPN health

**Examples:**
```bash
# Check VPN health
sudo ./vpn-maintain.sh check

# Auto-restart if unhealthy
sudo ./vpn-maintain.sh restart

# Monitor continuously (every 60 seconds)
sudo ./vpn-maintain.sh monitor

# Monitor custom interface every 30 seconds
sudo ./vpn-maintain.sh monitor wg1 30

# Show detailed statistics
sudo ./vpn-maintain.sh stats
```

**Health Checks:**
- Service status (running/stopped)
- Interface status (up/down)
- Last handshake time (should be < 3 minutes)
- Data transfer statistics

### configure-network.sh

Configure wired network connection settings to use VPN.

**Usage:**
```bash
sudo ./configure-network.sh {apply|remove|show} [vpn-interface] [wired-interface]
```

**Commands:**
- `apply` - Configure network to use VPN (DNS and routing)
- `remove` - Remove VPN network configuration
- `show` - Show current network configuration

**Examples:**
```bash
# Apply VPN configuration (auto-detect wired interface)
sudo ./configure-network.sh apply

# Apply with specific interfaces
sudo ./configure-network.sh apply wg0 eth0

# Show current configuration
sudo ./configure-network.sh show

# Remove VPN configuration
sudo ./configure-network.sh remove
```

**Features:**
- Auto-detects wired network interface
- Configures DNS from VPN config
- Backs up original DNS settings
- Shows current routing and network status

## Configuration File Format

The WireGuard configuration file (`wg0.conf`) uses the following format:

```ini
[Interface]
PrivateKey = <your-private-key>
Address = 10.0.0.2/24
DNS = 1.1.1.1, 1.0.0.1

[Peer]
PublicKey = <server-public-key>
Endpoint = vpn.example.com:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
```

**Key Parameters:**

- `PrivateKey` - Your device's private key (keep secret!)
- `Address` - Your VPN IP address and subnet
- `DNS` - DNS servers to use when connected (optional)
- `PublicKey` - VPN server's public key
- `Endpoint` - VPN server address and port
- `AllowedIPs` - IP ranges to route through VPN
  - `0.0.0.0/0, ::/0` routes ALL traffic through VPN
  - `10.0.0.0/24` only routes specific subnet (split-tunnel)
- `PersistentKeepalive` - Keep connection alive (seconds)

## Common Tasks

### Check VPN Status
```bash
# Using control script
sudo ./vpn-control.sh status

# Using wg command directly
sudo wg show

# Check system service
sudo systemctl status wg-quick@wg0
```

### View Logs
```bash
# View service logs
sudo journalctl -u wg-quick@wg0 -f

# View recent errors
sudo journalctl -u wg-quick@wg0 --since "1 hour ago"
```

### Test VPN Connection
```bash
# Check public IP (should show VPN server IP)
curl ifconfig.me

# Test DNS resolution
nslookup google.com

# Test connectivity
ping -c 4 8.8.8.8
```

### Update Configuration
```bash
# Edit configuration
sudo nano /etc/wireguard/wg0.conf

# Restart to apply changes
sudo ./vpn-control.sh restart
```

### Remove WireGuard
```bash
# Stop and disable VPN
sudo ./vpn-control.sh stop
sudo ./vpn-control.sh disable

# Remove configuration
sudo rm /etc/wireguard/wg0.conf

# Uninstall (Ubuntu/Debian)
sudo apt-get remove wireguard wireguard-tools
```

## Troubleshooting

### VPN Won't Start

1. Check configuration file syntax:
   ```bash
   sudo wg-quick up wg0
   ```

2. Verify keys are correct (no extra spaces/newlines)

3. Check firewall settings:
   ```bash
   # Allow WireGuard port (if you're the server)
   sudo ufw allow 51820/udp
   ```

### No Internet Connection Through VPN

1. Check DNS settings:
   ```bash
   cat /etc/resolv.conf
   ```

2. Verify routing:
   ```bash
   ip route show
   ```

3. Test VPN endpoint connectivity:
   ```bash
   ping <vpn-server-ip>
   ```

### Connection Drops Frequently

1. Check handshake status:
   ```bash
   sudo wg show wg0
   ```

2. Monitor for issues:
   ```bash
   sudo ./vpn-maintain.sh monitor
   ```

3. Check system logs:
   ```bash
   sudo journalctl -u wg-quick@wg0 -f
   ```

### Can't Resolve DNS

1. Check DNS configuration in `/etc/wireguard/wg0.conf`
2. Verify `resolvconf` is installed:
   ```bash
   sudo apt-get install resolvconf
   ```
3. Manually test DNS:
   ```bash
   nslookup google.com 1.1.1.1
   ```

## Automation

### Auto-Start on Boot

Enable the VPN to start automatically:
```bash
sudo ./vpn-control.sh enable
```

### Automatic Health Monitoring

Create a cron job to check VPN health every 5 minutes:

```bash
# Edit crontab
sudo crontab -e

# Add this line:
*/5 * * * * /path/to/scripts/vpn-maintain.sh restart >> /var/log/vpn-health.log 2>&1
```

### Systemd Timer for Health Checks

Create a systemd timer for regular health checks:

```bash
# Create service file
sudo cat > /etc/systemd/system/vpn-health-check.service << EOF
[Unit]
Description=WireGuard VPN Health Check

[Service]
Type=oneshot
ExecStart=/path/to/scripts/vpn-maintain.sh restart
EOF

# Create timer file
sudo cat > /etc/systemd/system/vpn-health-check.timer << EOF
[Unit]
Description=Run VPN health check every 5 minutes

[Timer]
OnBootSec=5min
OnUnitActiveSec=5min

[Install]
WantedBy=timers.target
EOF

# Enable and start timer
sudo systemctl daemon-reload
sudo systemctl enable vpn-health-check.timer
sudo systemctl start vpn-health-check.timer
```

## Security Best Practices

1. **Keep Private Keys Secure**
   - Never share your private key
   - Set proper file permissions: `chmod 600 /etc/wireguard/*.conf`
   - Don't commit keys to version control

2. **Use Strong Keys**
   - WireGuard uses Curve25519 keys (always 32 bytes)
   - Generate fresh keys for each device

3. **Regular Updates**
   - Keep WireGuard and your system updated
   - Monitor security advisories

4. **Firewall Configuration**
   - Only open necessary ports
   - Use UFW or iptables to restrict access

5. **Monitor Connections**
   - Regularly check VPN status
   - Review logs for suspicious activity
   - Use the maintenance script to monitor health

## Additional Resources

- [WireGuard Official Documentation](https://www.wireguard.com/)
- [WireGuard Quick Start Guide](https://www.wireguard.com/quickstart/)
- [WireGuard on GitHub](https://github.com/WireGuard)

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review WireGuard logs: `sudo journalctl -u wg-quick@wg0`
3. Verify configuration syntax
4. Consult WireGuard documentation

## License

These scripts are provided as-is for managing WireGuard VPN connections.
