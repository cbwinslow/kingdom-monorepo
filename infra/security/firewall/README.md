# Firewall Configuration

Comprehensive firewall rules for UFW and firewalld to secure services while blocking outbound connections to uncommon geographic regions.

## Overview

This firewall configuration provides:
- **Secure service port rules** for common services (SSH, HTTP/HTTPS, DNS, mail, etc.)
- **Geographic blocking** for outbound connections to Russia, China, South America, and Africa
- **Default deny policies** with explicit allow rules for necessary services
- **Support for both UFW and firewalld** firewall systems

## Directory Structure

```
firewall/
├── README.md                           # This file
├── ufw/                                # UFW configuration
│   ├── setup-ufw.sh                   # Main UFW setup script
│   └── geo-block-setup.sh             # Geographic blocking for UFW
└── firewalld/                         # Firewalld configuration
    ├── setup-firewalld.sh             # Main firewalld setup script
    └── geo-block-setup.sh             # Geographic blocking for firewalld
```

## Prerequisites

- Root or sudo access
- Internet connection for downloading IP ranges
- One of the following:
  - UFW-compatible system (Ubuntu, Debian, etc.)
  - Firewalld-compatible system (RHEL, CentOS, Fedora, etc.)

## Installation

### For UFW (Ubuntu/Debian)

1. **Install UFW** (if not already installed):
   ```bash
   sudo apt-get update
   sudo apt-get install ufw
   ```

2. **Run the setup script**:
   ```bash
   cd infra/security/firewall/ufw
   sudo bash setup-ufw.sh
   ```

3. **Enable geographic blocking**:
   ```bash
   sudo bash geo-block-setup.sh
   ```

### For Firewalld (RHEL/CentOS/Fedora)

1. **Install firewalld** (if not already installed):
   ```bash
   sudo dnf install firewalld  # or yum install firewalld
   ```

2. **Run the setup script**:
   ```bash
   cd infra/security/firewall/firewalld
   sudo bash setup-firewalld.sh
   ```

3. **Enable geographic blocking**:
   ```bash
   sudo bash geo-block-setup.sh
   ```

## Service Ports Allowed

### Incoming Connections
- **22/tcp** - SSH (remote management)
- **80/tcp** - HTTP (web services)
- **443/tcp** - HTTPS (secure web services)
- **8080/tcp** - HTTP alternative
- **8443/tcp** - HTTPS alternative
- **53/tcp, 53/udp** - DNS (if running DNS server)
- **25/tcp** - SMTP (mail)
- **587/tcp** - SMTP Submission
- **465/tcp** - SMTPS
- **993/tcp** - IMAPS
- **995/tcp** - POP3S
- **ICMP** - Ping for diagnostics

### Outgoing Connections
- **53/tcp, 53/udp** - DNS (name resolution)
- **80/tcp** - HTTP (updates, APIs)
- **443/tcp** - HTTPS (secure connections)
- **22/tcp** - SSH (outgoing connections)
- **123/udp** - NTP (time synchronization)
- **25/tcp** - SMTP (outgoing mail)
- **587/tcp** - SMTP Submission
- **ICMP** - Ping

### Optional Services (Commented Out by Default)
Database services are commented out for security. Uncomment them in the scripts if needed:
- **5432/tcp** - PostgreSQL
- **3306/tcp** - MySQL
- **27017/tcp** - MongoDB
- **6379/tcp** - Redis
- **2375/tcp** - Docker
- **2376/tcp** - Docker TLS
- **9090/tcp** - Prometheus
- **3000/tcp** - Grafana

## Geographic Blocking

The geographic blocking scripts download IP ranges from public sources and block outbound connections to:

### Blocked Regions
- **Russia** (RU)
- **China** (CN)
- **South America**: Argentina, Brazil, Chile, Colombia, Ecuador, Peru, Venezuela, Uruguay, Paraguay, Bolivia, Suriname, Guyana
- **Africa**: South Africa, Nigeria, Egypt, Kenya, Morocco, Tunisia, Ghana, Ethiopia, Algeria, Angola, Uganda, Tanzania, Cameroon, Ivory Coast, Senegal, Zambia, Zimbabwe, Libya

### How It Works
1. Downloads aggregated IP ranges from [IPdeny.com](https://www.ipdeny.com/ipblocks/)
2. Creates IPsets for each country/region
3. Adds firewall rules to drop outbound connections to these IP ranges
4. Sets up automatic restoration on system boot
5. Provides update scripts for refreshing IP lists

## Maintenance

### Updating IP Lists

Geographic IP ranges change over time. Update them regularly (recommended monthly):

**For UFW:**
```bash
sudo /usr/local/bin/update-geo-blocks
```

**For Firewalld:**
```bash
sudo /usr/local/bin/update-firewalld-geo-blocks
```

### Automatic Updates

Set up a cron job to update IP lists automatically (runs at 3 AM on the 1st of each month):

```bash
echo '0 3 1 * * /usr/local/bin/update-geo-blocks' | sudo crontab -
```

Or for firewalld:
```bash
echo '0 3 1 * * /usr/local/bin/update-firewalld-geo-blocks' | sudo crontab -
```

### Checking Firewall Status

**UFW:**
```bash
sudo ufw status verbose
```

**Firewalld:**
```bash
sudo firewall-cmd --list-all
sudo firewall-cmd --list-all-zones
```

### Listing Geographic Blocks

Check active IPsets:
```bash
sudo ipset list -name | grep geoblock
```

View details of a specific IPset:
```bash
sudo ipset list geoblock-russia
```

## Customization

### Adding Services

**UFW:**
Edit `setup-ufw.sh` and add:
```bash
ufw allow in <port>/<protocol> comment 'Service Name'
ufw allow out <port>/<protocol> comment 'Service Name'
```

**Firewalld:**
Edit `setup-firewalld.sh` and add:
```bash
firewall-cmd --zone=public --add-port=<port>/<protocol> --permanent
```

### Removing Geographic Blocks

To remove blocks for a specific country:

**UFW:**
```bash
sudo iptables -D OUTPUT -m set --match-set geoblock-<country> dst -j DROP
sudo ipset destroy geoblock-<country>
```

**Firewalld:**
```bash
sudo firewall-cmd --permanent --remove-rich-rule="rule family='ipv4' destination ipset='geoblock-<country>' drop"
sudo firewall-cmd --permanent --delete-ipset=geoblock-<country>
sudo firewall-cmd --reload
```

### Allowing Specific IPs Despite Geo-Blocking

If you need to allow specific IPs from blocked regions:

**UFW:**
```bash
sudo ufw insert 1 allow out to <IP_ADDRESS>
```

**Firewalld:**
```bash
sudo firewall-cmd --permanent --direct --add-rule ipv4 filter OUTBOUND_FILTER 1 -d <IP_ADDRESS> -j ACCEPT
sudo firewall-cmd --reload
```

## Security Considerations

1. **Test Before Production**: Always test firewall rules in a non-production environment first
2. **Document Changes**: Keep records of all firewall rule modifications
3. **Monitor Logs**: Regularly review firewall logs for suspicious activity
4. **Update Regularly**: Keep IP lists and firewall software up to date
5. **Backup Configuration**: Save firewall configurations before making changes
6. **Emergency Access**: Ensure you have console access in case SSH is blocked

### UFW Backup
```bash
sudo cp -r /etc/ufw /etc/ufw.backup
```

### Firewalld Backup
```bash
sudo cp -r /etc/firewalld /etc/firewalld.backup
```

## Troubleshooting

### Cannot Connect After Setup

1. Check if the required port is allowed:
   ```bash
   # UFW
   sudo ufw status numbered
   
   # Firewalld
   sudo firewall-cmd --list-all
   ```

2. Temporarily disable to test:
   ```bash
   # UFW
   sudo ufw disable
   
   # Firewalld
   sudo systemctl stop firewalld
   ```

3. Add missing rule and re-enable

### Geographic Blocking Not Working

1. Verify ipsets are loaded:
   ```bash
   sudo ipset list -name | grep geoblock
   ```

2. Check iptables rules:
   ```bash
   sudo iptables -L -n -v | grep geoblock
   ```

3. Test connection to blocked region:
   ```bash
   curl -v --connect-timeout 5 http://<IP_FROM_BLOCKED_REGION>
   ```

### IPset Service Not Starting on Boot

1. Check service status:
   ```bash
   sudo systemctl status ipset-restore.service
   # or
   sudo systemctl status firewalld-ipset-restore.service
   ```

2. View service logs:
   ```bash
   sudo journalctl -u ipset-restore.service
   # or
   sudo journalctl -u firewalld-ipset-restore.service
   ```

3. Manually restore:
   ```bash
   sudo /etc/ufw/ipset-restore.sh
   # or
   sudo /etc/firewalld/ipset-restore.sh
   ```

## Performance Considerations

- Large IPsets may impact performance slightly
- Consider using aggregated IP ranges (already implemented)
- Monitor system resources after implementation
- Optimize rules by placing most frequently matched rules first

## Legal and Ethical Considerations

**Important**: Geographic blocking should be implemented thoughtfully:
- Ensure compliance with your organization's policies
- Consider legitimate use cases that may be affected
- Document business justification for blocking
- Review regularly to ensure blocks are still necessary
- Be aware of international laws regarding internet filtering

## References

- [UFW Documentation](https://help.ubuntu.com/community/UFW)
- [Firewalld Documentation](https://firewalld.org/documentation/)
- [IPset Documentation](http://ipset.netfilter.org/)
- [IPdeny IP Blocks](https://www.ipdeny.com/ipblocks/)

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review firewall logs: `/var/log/ufw.log` or `journalctl -u firewalld`
3. Consult your system administrator
4. Review official documentation for your firewall system

## License

These scripts are provided as-is for use in the Kingdom Monorepo project.
