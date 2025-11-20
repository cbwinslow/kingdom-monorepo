# Homelab Troubleshooting Guide

Common issues and their solutions for homelab server deployments.

## Table of Contents
- [Installation Issues](#installation-issues)
- [Docker/Container Issues](#dockercontainer-issues)
- [Network Issues](#network-issues)
- [Service-Specific Issues](#service-specific-issues)
- [Performance Issues](#performance-issues)
- [Security Issues](#security-issues)

## Installation Issues

### Script fails with "Permission denied"

**Symptoms**: Cannot execute installation scripts

**Solution**:
```bash
# Make script executable
chmod +x install-script.sh

# Run with sudo if needed
sudo ./install-script.sh
```

### Package not found during installation

**Symptoms**: `E: Unable to locate package`

**Solution**:
```bash
# Update package lists
sudo apt update

# If still fails, check OS version
lsb_release -a

# Check if package exists
apt-cache search package-name
```

### Ansible connection refused

**Symptoms**: SSH connection fails in Ansible

**Solution**:
```bash
# Test SSH manually
ssh user@hostname

# Check SSH key
ssh-copy-id user@hostname

# Verify inventory
ansible-inventory --list

# Test ping
ansible all -m ping -vvv
```

## Docker/Container Issues

### Docker daemon not running

**Symptoms**: `Cannot connect to the Docker daemon`

**Solution**:
```bash
# Check status
sudo systemctl status docker

# Start Docker
sudo systemctl start docker

# Enable on boot
sudo systemctl enable docker

# Check logs
sudo journalctl -u docker -f
```

### Container won't start

**Symptoms**: Container exits immediately

**Solution**:
```bash
# Check logs
docker logs container-name

# Inspect container
docker inspect container-name

# Check resources
docker stats

# Try running interactively
docker run -it image-name /bin/bash
```

### Port already in use

**Symptoms**: `Bind for 0.0.0.0:port failed: port is already allocated`

**Solution**:
```bash
# Find what's using the port
sudo lsof -i :port
sudo netstat -tulpn | grep :port

# Stop the service
sudo systemctl stop service-name

# Or change port in docker-compose.yml
ports:
  - "8081:80"  # Use 8081 instead
```

### Permission denied in container

**Symptoms**: Cannot write to mounted volume

**Solution**:
```bash
# Check ownership
ls -l /path/to/volume

# Fix permissions
sudo chown -R user:user /path/to/volume
sudo chmod -R 755 /path/to/volume

# Or use PUID/PGID in container
environment:
  - PUID=1000
  - PGID=1000
```

### Out of disk space

**Symptoms**: `No space left on device`

**Solution**:
```bash
# Check disk usage
df -h

# Check Docker usage
docker system df

# Clean up
docker system prune -a
docker volume prune

# Remove old logs
sudo journalctl --vacuum-time=3d

# Clean apt cache
sudo apt clean
```

### Container networking issues

**Symptoms**: Containers can't communicate

**Solution**:
```bash
# Check networks
docker network ls
docker network inspect network-name

# Ensure containers on same network
docker-compose down
docker-compose up -d

# Check DNS
docker exec container-name ping other-container
docker exec container-name nslookup other-container
```

## Network Issues

### Cannot access web interface

**Symptoms**: Connection refused/timeout

**Solution**:
```bash
# Check service is running
docker ps
sudo systemctl status service-name

# Check from server
curl localhost:port

# Check firewall
sudo ufw status
sudo ufw allow port/tcp

# Check if port is listening
sudo netstat -tulpn | grep :port
```

### DNS not resolving

**Symptoms**: Cannot resolve hostnames

**Solution**:
```bash
# Check DNS settings
cat /etc/resolv.conf

# Test DNS
nslookup google.com
dig google.com

# Test specific DNS server
nslookup google.com 1.1.1.1

# Check Pi-hole/AdGuard
# - Verify it's running
# - Check query log
# - Temporarily use 1.1.1.1 for testing
```

### Slow network performance

**Symptoms**: High latency, slow transfers

**Solution**:
```bash
# Check network stats
ifconfig
ip addr show

# Check for errors
ethtool eth0

# Test bandwidth
iperf3 -s  # On server
iperf3 -c server-ip  # On client

# Check MTU
ping -M do -s 1472 server-ip
```

### VPN not connecting

**Symptoms**: WireGuard/OpenVPN connection fails

**Solution**:
```bash
# Check VPN service
docker logs wireguard
sudo systemctl status openvpn

# Check firewall
sudo ufw allow port/udp

# Verify config
wg show  # For WireGuard

# Check keys
ls -l /path/to/keys

# Test from outside network
# Use mobile data or different network
```

## Service-Specific Issues

### Pi-hole not blocking ads

**Symptoms**: Ads still appearing

**Solution**:
```bash
# Verify DNS is set correctly
nslookup doubleclick.net

# Update blocklists
pihole -g

# Check if blocking is enabled
pihole status

# Test blocking
dig ads.google.com @pihole-ip

# Check query log
pihole -t  # Tail log
```

### Grafana dashboard empty

**Symptoms**: No data in Grafana

**Solution**:
```bash
# Check Prometheus targets
curl http://localhost:9090/targets

# Verify datasource in Grafana
# Settings → Data Sources → Test

# Check Prometheus queries
# Explore → Run query

# Restart Grafana
docker restart grafana
```

### Nextcloud slow or unresponsive

**Symptoms**: Page loads slowly

**Solution**:
```bash
# Check logs
docker logs nextcloud

# Run maintenance
docker exec -u www-data nextcloud php occ maintenance:repair

# Clear cache
docker exec -u www-data nextcloud php occ files:scan --all

# Check database
docker logs nextcloud-db

# Increase PHP memory
# Add to docker-compose.yml:
environment:
  - PHP_MEMORY_LIMIT=512M
```

### Plex transcoding issues

**Symptoms**: Stuttering, buffering

**Solution**:
```bash
# Check CPU usage
top
htop

# Enable hardware transcoding
# Plex Pass required
# Add device mapping:
devices:
  - /dev/dri:/dev/dri

# Lower quality settings
# Plex → Settings → Transcoder
# - Limit transcoding speed

# Check logs
docker logs plex
```

## Performance Issues

### High CPU usage

**Symptoms**: System slow, high load

**Solution**:
```bash
# Check processes
top
htop

# Check Docker containers
docker stats

# Check specific container
docker top container-name

# Limit container resources
docker run --cpus="1.5" --memory="1g" image

# Or in docker-compose:
deploy:
  resources:
    limits:
      cpus: '1.5'
      memory: 1G
```

### High memory usage

**Symptoms**: Out of memory errors

**Solution**:
```bash
# Check memory
free -h
vmstat

# Check swap
swapon --show

# Check container memory
docker stats

# Add swap if needed
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### Disk I/O bottleneck

**Symptoms**: Slow disk operations

**Solution**:
```bash
# Check I/O
iostat -x 1
iotop

# Check SMART status
sudo smartctl -a /dev/sda

# Use SSD for Docker
# Move Docker to SSD:
sudo systemctl stop docker
sudo mv /var/lib/docker /path/to/ssd/docker
sudo ln -s /path/to/ssd/docker /var/lib/docker
sudo systemctl start docker

# Adjust commit interval
# Add to /etc/fstab:
# commit=60
```

## Security Issues

### Port scanning attacks

**Symptoms**: Fail2ban alerts, suspicious logs

**Solution**:
```bash
# Check fail2ban
sudo fail2ban-client status
sudo fail2ban-client status sshd

# Review logs
sudo tail -f /var/log/auth.log

# Harden SSH
sudo vim /etc/ssh/sshd_config
# Set:
# PermitRootLogin no
# PasswordAuthentication no
# Port 2222  # Non-standard port

# Restart SSH
sudo systemctl restart sshd
```

### Suspicious activity

**Symptoms**: Unusual processes, network activity

**Solution**:
```bash
# Check processes
ps aux | grep -v root

# Check open ports
sudo netstat -tulpn

# Check established connections
sudo netstat -tunap

# Check login history
last
lastb  # Failed logins

# Check logs
sudo journalctl -p err -S today
sudo grep -i failed /var/log/auth.log

# Run rootkit checker
sudo apt install rkhunter
sudo rkhunter --check
```

### SSL/TLS certificate issues

**Symptoms**: Certificate errors in browser

**Solution**:
```bash
# Check certificate expiry
openssl s_client -connect domain.com:443 -servername domain.com < /dev/null | openssl x509 -noout -dates

# Renew Let's Encrypt
# For Nginx Proxy Manager: automatic
# For certbot:
sudo certbot renew
sudo systemctl reload nginx

# Check certificate files
sudo ls -l /etc/letsencrypt/live/domain.com/
```

## General Troubleshooting Steps

### 1. Check Logs
```bash
# System logs
sudo journalctl -f
sudo journalctl -u service-name -f

# Docker logs
docker logs -f container-name

# Application logs
tail -f /var/log/app.log
```

### 2. Restart Services
```bash
# Docker container
docker restart container-name

# Systemd service
sudo systemctl restart service-name

# Docker Compose stack
docker-compose restart
```

### 3. Check Configuration
```bash
# Verify syntax
docker-compose config

# Check environment
docker exec container-name env

# Inspect configuration
docker inspect container-name
```

### 4. Test Connectivity
```bash
# Ping
ping host

# Port test
telnet host port
nc -zv host port

# HTTP test
curl -v http://host:port
```

### 5. Review Documentation
- Check service-specific README
- Review Docker Hub image documentation
- Search GitHub issues
- Check community forums

## Getting Help

If issues persist:

1. **Gather information**:
   - System specs
   - OS version
   - Service versions
   - Error messages
   - Relevant logs

2. **Search resources**:
   - Project documentation
   - GitHub issues
   - Stack Overflow
   - Reddit (r/homelab, r/selfhosted)

3. **Ask for help**:
   - Provide full context
   - Include relevant logs
   - Describe what you've tried
   - Be specific about the problem

4. **Create issue**:
   - Use issue template
   - Include reproduction steps
   - Add environment details
   - Attach logs if relevant

## Preventive Measures

### Regular Maintenance
```bash
# Update system weekly
sudo apt update && sudo apt upgrade -y

# Update containers monthly
docker-compose pull
docker-compose up -d

# Clean up monthly
docker system prune
```

### Monitoring
- Set up Prometheus + Grafana
- Configure alerts
- Monitor disk space
- Track resource usage

### Backups
- Automated daily backups
- Test restore procedures
- Store backups off-site
- Document backup strategy

### Documentation
- Keep setup notes
- Document changes
- Maintain configuration files
- Record issues and solutions

## Useful Commands Reference

```bash
# System
systemctl status service
journalctl -u service -f
df -h
free -h
top

# Docker
docker ps -a
docker logs -f container
docker stats
docker system df
docker system prune

# Network
ip addr
ss -tulpn
ping host
curl -v url

# Logs
tail -f /var/log/syslog
journalctl -f
docker logs container
```

Remember: Most issues can be resolved by checking logs, restarting services, or consulting documentation!
