# Getting Started with Homelab Server Setup

Complete guide to setting up your homelab server from scratch.

## Overview

This repository provides multiple deployment methods for homelab software:
1. **Bare Metal**: Direct installation scripts
2. **Ansible**: Infrastructure as Code automation
3. **Docker**: Container-based deployment
4. **Docker Compose**: Multi-container stacks
5. **Podman**: Daemonless container alternative

## Prerequisites

### Hardware Requirements

**Minimum**:
- CPU: 2 cores
- RAM: 4GB
- Storage: 50GB
- Network: 1 Gbps Ethernet

**Recommended**:
- CPU: 4+ cores
- RAM: 16GB+
- Storage: 500GB+ (SSD recommended)
- Network: 1 Gbps Ethernet
- Separate storage for media/backups

### Software Requirements

- Ubuntu Server 20.04+ or Debian 11+
- SSH access
- Sudo privileges
- Static IP address (recommended)

## Initial Server Setup

### 1. Install Operating System

Download Ubuntu Server: https://ubuntu.com/download/server

**Installation Tips**:
- Choose minimal installation
- Enable SSH server
- Create a user account
- Configure static IP if possible

### 2. Update System

```bash
sudo apt update
sudo apt upgrade -y
sudo reboot
```

### 3. Configure Network

#### Set Static IP (optional but recommended)

Edit `/etc/netplan/00-installer-config.yaml`:
```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 1.1.1.1
          - 1.0.0.1
```

Apply changes:
```bash
sudo netplan apply
```

### 4. Basic Security Hardening

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y ufw fail2ban

# Configure firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw enable

# Start fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### 5. SSH Key Setup (from your local machine)

```bash
# Generate SSH key if you don't have one
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy key to server
ssh-copy-id username@192.168.1.100

# Test connection
ssh username@192.168.1.100
```

## Deployment Methods

### Method 1: Bare Metal Installation

Best for: Learning, single services, maximum performance

```bash
# Clone repository
git clone https://github.com/cbwinslow/kingdom-monorepo.git
cd kingdom-monorepo/infra/homelab/bare-metal

# Install Docker
sudo ./install-docker.sh

# Install Portainer
sudo ./install-portainer.sh

# Install other services
sudo ./install-prometheus.sh
sudo ./install-pihole.sh
```

### Method 2: Ansible Automation

Best for: Multiple servers, reproducible deployments, IaC

```bash
# On your local machine (control node)
cd infra/homelab/ansible

# Edit inventory
vim inventory/hosts.yml

# Edit variables
vim group_vars/all.yml

# Test connection
ansible all -m ping

# Run full setup
ansible-playbook playbooks/site.yml

# Or specific playbook
ansible-playbook playbooks/docker-only.yml
```

### Method 3: Docker Compose Stacks

Best for: Quick deployment, easy management, isolation

```bash
# Install Docker first
sudo ./bare-metal/install-docker.sh

# Choose a stack
cd docker-compose/monitoring

# Configure environment
cp .env.example .env
vim .env

# Start stack
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

### Method 4: Podman

Best for: Rootless containers, security, Docker alternative

```bash
# Install Podman
sudo ./bare-metal/install-podman.sh

# Use podman-compose with existing docker-compose files
cd docker-compose/monitoring
podman-compose up -d
```

## Recommended Deployment Strategy

### For Beginners

1. Start with Docker installation:
   ```bash
   sudo ./bare-metal/install-docker.sh
   ```

2. Install Portainer for GUI management:
   ```bash
   sudo ./bare-metal/install-portainer.sh
   ```

3. Deploy your first stack:
   ```bash
   cd docker-compose/monitoring
   cp .env.example .env
   docker-compose up -d
   ```

4. Access services and explore

### For Intermediate Users

1. Use Ansible for automated setup:
   ```bash
   ansible-playbook playbooks/site.yml
   ```

2. Deploy multiple stacks:
   ```bash
   # Monitoring
   cd docker-compose/monitoring && docker-compose up -d
   
   # Media server
   cd ../media && docker-compose up -d
   
   # Networking
   cd ../networking && docker-compose up -d
   ```

3. Configure reverse proxy for easy access

### For Advanced Users

1. Custom Ansible roles for your needs
2. Mix bare metal and containers
3. Implement high availability
4. Custom monitoring and alerting
5. Automated backups
6. Infrastructure as Code

## Common First Services to Deploy

### 1. Monitoring Stack

**Why**: Understand your system's health
**Services**: Prometheus, Grafana, Node Exporter
**Deployment**:
```bash
cd docker-compose/monitoring
cp .env.example .env
docker-compose up -d
```
**Access**: http://server-ip:3000

### 2. Network Services

**Why**: Ad blocking, DNS, reverse proxy
**Services**: Pi-hole, Nginx Proxy Manager
**Deployment**:
```bash
cd docker-compose/networking
cp .env.example .env
docker-compose up -d pihole nginx-proxy-manager
```
**Access**: 
- Pi-hole: http://server-ip:8081/admin
- NPM: http://server-ip:81

### 3. Container Management

**Why**: Easy container management with GUI
**Services**: Portainer
**Deployment**:
```bash
sudo ./bare-metal/install-portainer.sh
```
**Access**: https://server-ip:9443

## Post-Deployment Steps

### 1. Configure DNS

**Option A: Router-level** (recommended)
- Set router's primary DNS to your server IP
- All devices use Pi-hole/AdGuard automatically

**Option B: Device-level**
- Configure each device's DNS manually
- Set to your server's IP address

### 2. Set Up Reverse Proxy

Using Nginx Proxy Manager:
1. Access: http://server-ip:81
2. Add proxy hosts for each service
3. Enable SSL with Let's Encrypt
4. Access services via friendly URLs

### 3. Configure Backups

```bash
# Install restic
sudo apt install restic

# Initialize repository
restic init --repo /backup/location

# Create backup script
cat > ~/backup.sh <<'EOF'
#!/bin/bash
export RESTIC_REPOSITORY=/backup/location
export RESTIC_PASSWORD=your-password

restic backup /var/lib/docker/volumes
restic backup /etc
restic backup ~/important-configs

restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6
restic prune
EOF

chmod +x ~/backup.sh

# Schedule with cron
crontab -e
# Add: 0 2 * * * /home/user/backup.sh
```

### 4. Monitoring Setup

1. Access Grafana: http://server-ip:3000
2. Login (admin/admin)
3. Import dashboards:
   - Node Exporter Full: 1860
   - Docker metrics: 179
4. Configure alerts (email, Slack, etc.)

## Troubleshooting

### Service won't start
```bash
# Check logs
docker logs container-name
journalctl -u service-name -f

# Check ports
sudo lsof -i :port
sudo netstat -tulpn | grep :port

# Restart service
docker-compose restart
systemctl restart service-name
```

### Cannot access web interface
```bash
# Check firewall
sudo ufw status
sudo ufw allow port/tcp

# Check service is running
docker ps
systemctl status service-name

# Check from server
curl localhost:port
```

### Out of disk space
```bash
# Check usage
df -h
du -sh /var/lib/docker/volumes/*

# Clean Docker
docker system prune -a
docker volume prune

# Clean logs
sudo journalctl --vacuum-time=3d
```

## Next Steps

1. **Explore Services**: Try different stacks
2. **Customize**: Adjust configurations for your needs
3. **Secure**: Implement SSL, strong passwords, 2FA
4. **Monitor**: Set up alerts and notifications
5. **Backup**: Automate backup procedures
6. **Document**: Keep notes on your setup
7. **Share**: Help others in the community

## Resources

- [r/homelab](https://reddit.com/r/homelab) - Community
- [r/selfhosted](https://reddit.com/r/selfhosted) - Self-hosting community
- [Awesome Selfhosted](https://github.com/awesome-selfhosted/awesome-selfhosted)
- [HomelabOS](https://homelabos.com/)
- [Docker Documentation](https://docs.docker.com/)
- [Ansible Documentation](https://docs.ansible.com/)

## Getting Help

1. Check service-specific README files
2. Review logs for error messages
3. Search issues on GitHub
4. Ask in r/homelab or r/selfhosted
5. Check official documentation
6. Open an issue in this repository

## Contributing

Found improvements or want to add services?
1. Fork the repository
2. Add your changes
3. Test thoroughly
4. Submit a pull request

Happy homelabbing! 🚀
