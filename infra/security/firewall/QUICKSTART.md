# Firewall Quick Start Guide

Fast setup guide for comprehensive firewall rules with geographic blocking.

## Choose Your Firewall System

### Option 1: UFW (Ubuntu, Debian, Linux Mint)

```bash
# Navigate to firewall directory
cd infra/security/firewall/ufw

# Step 1: Setup basic firewall rules
sudo bash setup-ufw.sh

# Step 2: Enable geographic blocking (optional but recommended)
sudo bash geo-block-setup.sh

# Verify setup
sudo ufw status verbose
```

### Option 2: Firewalld (RHEL, CentOS, Fedora, Rocky Linux)

```bash
# Navigate to firewall directory
cd infra/security/firewall/firewalld

# Step 1: Setup basic firewall rules
sudo bash setup-firewalld.sh

# Step 2: Enable geographic blocking (optional but recommended)
sudo bash geo-block-setup.sh

# Verify setup
sudo firewall-cmd --list-all
```

## What Gets Configured

### ✅ Incoming (Inbound)
- SSH (22) - Remote access
- HTTP (80, 8080) - Web traffic
- HTTPS (443, 8443) - Secure web traffic
- DNS (53) - Name resolution
- Mail (25, 587, 465, 993, 995) - Email services
- ICMP - Ping

### ✅ Outgoing (Outbound)
- DNS (53) - Name resolution
- HTTP/HTTPS (80, 443) - Updates and APIs
- SSH (22) - Outgoing connections
- NTP (123) - Time sync
- SMTP (25, 587) - Outgoing email
- ICMP - Ping

### 🚫 Blocked Regions (Outbound Only)
- Russia
- China
- South America (all countries)
- Africa (all countries)

## Post-Installation

### Test Your Connection
```bash
# Test SSH (should work)
ssh localhost

# Test HTTP (should work)
curl -I https://google.com

# Test blocked region (should timeout/fail)
# Example: curl --connect-timeout 5 http://<chinese-ip>
```

### View Active Rules
```bash
# UFW
sudo ufw status numbered

# Firewalld
sudo firewall-cmd --list-all
sudo firewall-cmd --direct --get-all-rules
```

### Check Geographic Blocks
```bash
# List all geoblock IPsets
sudo ipset list -name | grep geoblock

# See details of a specific block
sudo ipset list geoblock-russia
```

## Maintenance Commands

### Update Geographic IP Lists (Monthly Recommended)
```bash
# UFW
sudo /usr/local/bin/update-geo-blocks

# Firewalld
sudo /usr/local/bin/update-firewalld-geo-blocks
```

### Disable Firewall (Emergency)
```bash
# UFW
sudo ufw disable

# Firewalld
sudo systemctl stop firewalld
```

### Re-enable Firewall
```bash
# UFW
sudo ufw enable

# Firewalld
sudo systemctl start firewalld
```

## Common Customizations

### Add a Custom Port
```bash
# UFW
sudo ufw allow <port>/tcp comment 'My Service'

# Firewalld
sudo firewall-cmd --add-port=<port>/tcp --permanent
sudo firewall-cmd --reload
```

### Remove Geographic Block for a Country
```bash
# UFW
sudo iptables -D OUTPUT -m set --match-set geoblock-<country> dst -j DROP
sudo ipset destroy geoblock-<country>

# Firewalld
sudo firewall-cmd --permanent --direct --remove-rule ipv4 filter OUTBOUND_FILTER 10 -m set --match-set geoblock-<country> dst -j DROP
sudo firewall-cmd --reload
```

## Need Help?

See [README.md](README.md) for:
- Detailed documentation
- Troubleshooting guide
- Security considerations
- Advanced configuration

## Important Notes

⚠️ **Before Production**: Test in a non-production environment first

⚠️ **SSH Access**: Ensure port 22 is allowed before enabling firewall

⚠️ **Backup**: Save your configuration before making changes

⚠️ **Testing**: Always test connectivity after applying rules

⚠️ **Updates**: Keep IP lists updated monthly for effective geo-blocking
