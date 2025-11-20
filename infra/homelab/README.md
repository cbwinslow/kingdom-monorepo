# Homelab Server Installation Scripts

Comprehensive collection of installation and configuration scripts for standard homelab server software.

## Overview

This directory contains multiple deployment methods for popular homelab software:
- **Bare Metal**: Direct installation scripts for Ubuntu/Debian systems
- **Ansible**: Automated playbooks for infrastructure as code
- **Docker**: Individual Docker container configurations
- **Docker Compose**: Multi-container application stacks
- **Podman**: Daemonless container deployment options

## Quick Start

### Prerequisites
```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install basic dependencies
sudo apt install -y curl wget git vim htop
```

### Choose Your Deployment Method

1. **Bare Metal Installation**
   ```bash
   cd bare-metal
   ./install-<software>.sh
   ```

2. **Ansible Deployment**
   ```bash
   cd ansible
   ansible-playbook -i inventory.yml site.yml
   ```

3. **Docker Compose Stack**
   ```bash
   cd docker-compose
   docker-compose up -d
   ```

4. **Podman Deployment**
   ```bash
   cd podman
   ./deploy-<software>.sh
   ```

## Software Categories

### Monitoring & Observability
- **Prometheus**: Metrics collection and monitoring
- **Grafana**: Visualization and analytics
- **Netdata**: Real-time performance monitoring
- **Wazuh**: Security monitoring and threat detection

### Container Management
- **Portainer**: Docker/Kubernetes management UI
- **Rancher**: Multi-cluster Kubernetes management

### Storage & Backup
- **MinIO**: S3-compatible object storage
- **Restic**: Fast, secure backup program
- **Duplicati**: Encrypted backup solution

### Network Services
- **Pi-hole**: Network-wide ad blocking
- **AdGuard Home**: DNS-based ad blocker
- **Nginx Proxy Manager**: Reverse proxy with SSL

### Media Server
- **Plex**: Media server
- **Jellyfin**: Free software media server
- **Transmission**: BitTorrent client

### Productivity
- **Nextcloud**: File sync and share
- **Home Assistant**: Home automation

### Development Tools
- **GitLab**: DevOps platform
- **Jenkins**: CI/CD automation
- **SonarQube**: Code quality analysis

### Security
- **Vault**: Secrets management
- **Authelia**: Authentication and authorization

### Databases
- **PostgreSQL**: Relational database
- **MySQL/MariaDB**: Relational database
- **Redis**: In-memory data store

### Reverse Proxy & Load Balancing
- **Traefik**: Modern reverse proxy
- **HAProxy**: High-performance load balancer

## Directory Structure

```
homelab/
├── bare-metal/          # Direct installation scripts
│   ├── install-*.sh     # Individual software installers
│   └── common.sh        # Shared functions
├── ansible/             # Ansible playbooks
│   ├── inventory/       # Inventory files
│   ├── playbooks/       # Main playbooks
│   ├── roles/           # Ansible roles
│   └── group_vars/      # Variable definitions
├── docker/              # Individual Docker configurations
│   └── */               # Per-software directories
├── docker-compose/      # Docker Compose stacks
│   ├── monitoring/      # Monitoring stack
│   ├── media/           # Media server stack
│   ├── productivity/    # Productivity tools
│   └── security/        # Security tools
├── podman/              # Podman configurations
│   └── */               # Per-software directories
├── configs/             # Configuration templates
│   └── */               # Per-software configs
└── docs/                # Additional documentation
    ├── server-setup.md  # Server node configurations
    └── troubleshooting.md
```

## Server-Node Setups

Some software requires multi-node configurations:

### Wazuh Server-Agent Setup
See `docs/wazuh-setup.md` for:
- Central Wazuh server installation
- Agent deployment on multiple nodes
- Configuration for monitoring various systems

### Kubernetes Cluster
See `docs/k8s-cluster.md` for:
- Master node setup
- Worker node configuration
- Network and storage setup

## Configuration Management

All software configurations are templated in the `configs/` directory. Variables can be customized in:
- `configs/common.env` - Shared environment variables
- `configs/<software>/` - Software-specific configurations

## Security Best Practices

1. **Change Default Passwords**: Always update default credentials
2. **Use Strong Passwords**: Generate with `openssl rand -base64 32`
3. **Enable Firewalls**: Configure UFW or firewalld
4. **SSL/TLS**: Use Let's Encrypt for certificates
5. **Regular Updates**: Keep software and systems updated
6. **Network Segmentation**: Use VLANs where appropriate
7. **Backup Regularly**: Automate backups with restic or duplicati

## Troubleshooting

Common issues and solutions in `docs/troubleshooting.md`

## Contributing

When adding new software:
1. Create installation scripts for all deployment methods
2. Add configuration templates
3. Update this README
4. Include documentation with examples

## Resources

- [Awesome Selfhosted](https://github.com/awesome-selfhosted/awesome-selfhosted)
- [r/homelab](https://reddit.com/r/homelab)
- [HomelabOS](https://homelabos.com/)

## License

See main repository LICENSE
