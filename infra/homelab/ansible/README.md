# Ansible Homelab Automation

Ansible playbooks and roles for automated homelab infrastructure deployment.

## Prerequisites

### On Control Machine (your laptop/workstation)

```bash
# Install Ansible
sudo apt update
sudo apt install ansible

# Or using pip
pip install ansible

# Install required collections
ansible-galaxy collection install community.general
ansible-galaxy collection install community.docker
```

### On Target Hosts

- Ubuntu 20.04+ or Debian 11+
- SSH access with key-based authentication
- User with sudo privileges

## Quick Start

### 1. Configure Inventory

Edit `inventory/hosts.yml` and update:
- Host IP addresses
- SSH user
- Host groups

```yaml
servers:
  hosts:
    homelab-server-01:
      ansible_host: 192.168.1.100
      ansible_user: your_user
```

### 2. Configure Variables

Edit `group_vars/all.yml` to customize:
- System packages
- User accounts
- Security settings
- Docker configuration
- Monitoring settings

### 3. Test Connection

```bash
ansible all -m ping
```

### 4. Run Playbooks

#### Full setup (everything)
```bash
ansible-playbook playbooks/site.yml
```

#### Docker only
```bash
ansible-playbook playbooks/docker-only.yml
```

#### Specific hosts
```bash
ansible-playbook playbooks/site.yml --limit homelab-server-01
```

#### Check mode (dry run)
```bash
ansible-playbook playbooks/site.yml --check
```

## Available Roles

### common
- System updates and upgrades
- Common package installation
- User management
- SSH hardening
- Firewall configuration
- Fail2ban setup

### docker
- Docker Engine installation
- Docker Compose installation
- Docker daemon configuration
- User group management

### monitoring
- Prometheus setup
- Grafana installation
- Node Exporter deployment
- Alert configuration

### security
- Additional security hardening
- Automated security updates
- Intrusion detection
- Log monitoring

## Directory Structure

```
ansible/
├── ansible.cfg              # Ansible configuration
├── inventory/
│   └── hosts.yml           # Host inventory
├── group_vars/
│   └── all.yml            # Global variables
├── host_vars/             # Host-specific variables
├── playbooks/
│   ├── site.yml          # Main playbook
│   └── docker-only.yml   # Docker-only playbook
└── roles/
    ├── common/
    ├── docker/
    ├── monitoring/
    └── security/
```

## Common Tasks

### Add a new host

1. Add to `inventory/hosts.yml`:
```yaml
servers:
  hosts:
    new-server:
      ansible_host: 192.168.1.105
      ansible_user: homelab
```

2. Test connection:
```bash
ansible new-server -m ping
```

3. Run playbook:
```bash
ansible-playbook playbooks/site.yml --limit new-server
```

### Update all servers

```bash
ansible-playbook playbooks/site.yml --tags update
```

### Install only Docker

```bash
ansible-playbook playbooks/docker-only.yml
```

### Run specific role

```bash
ansible-playbook playbooks/site.yml --tags monitoring
```

## Advanced Usage

### Using SSH key

```bash
# Generate SSH key if needed
ssh-keygen -t rsa -b 4096

# Copy to target hosts
ssh-copy-id user@hostname

# Test
ssh user@hostname
```

### Using vault for secrets

```bash
# Create encrypted file
ansible-vault create group_vars/vault.yml

# Edit encrypted file
ansible-vault edit group_vars/vault.yml

# Run playbook with vault
ansible-playbook playbooks/site.yml --ask-vault-pass
```

### Using tags

```bash
# List all tags
ansible-playbook playbooks/site.yml --list-tags

# Run specific tags
ansible-playbook playbooks/site.yml --tags "common,docker"

# Skip tags
ansible-playbook playbooks/site.yml --skip-tags "monitoring"
```

## Troubleshooting

### Connection issues

```bash
# Verbose output
ansible-playbook playbooks/site.yml -vvv

# Test SSH connection
ssh -vvv user@hostname

# Check inventory
ansible-inventory --list
```

### Permission issues

```bash
# Test sudo
ansible all -m shell -a "sudo whoami" -K

# Check user groups
ansible all -m shell -a "groups"
```

### Module not found

```bash
# Install collections
ansible-galaxy collection install community.general
ansible-galaxy collection install community.docker
```

## Best Practices

1. **Version Control**: Keep your playbooks in git
2. **Use Variables**: Store configuration in variables files
3. **Idempotency**: Write playbooks that can be run multiple times
4. **Tags**: Use tags for selective execution
5. **Testing**: Use `--check` mode before running
6. **Documentation**: Document custom roles and variables
7. **Secrets**: Use ansible-vault for sensitive data
8. **Backups**: Always backup before major changes

## Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Ansible Galaxy](https://galaxy.ansible.com/)

## Contributing

When adding new roles:
1. Follow the standard role structure
2. Include README in role directory
3. Add tags for selective execution
4. Test thoroughly
5. Update this documentation
