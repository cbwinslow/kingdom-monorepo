# Ansible System Configuration Management

Comprehensive Ansible scripts for reverse engineering and recreating system configurations on fresh VMs.

## Overview

This workspace provides a complete infrastructure-as-code solution for:
- **Discovery**: Reverse engineer a system's complete configuration
- **Reporting**: Generate detailed configuration reports
- **Restoration**: Recreate the exact configuration on a new VM

## Features

### System Discovery

The discovery playbook collects comprehensive information about:

- **System Information**: OS, kernel, hardware, CPU, memory
- **Packages**: All installed packages (apt, yum, pip, npm, snap, flatpak)
- **Users & Groups**: User accounts, groups, permissions, sudoers
- **Filesystem**: Partitions, mount points, LVM, RAID, disk usage
- **Network**: Interfaces, routing, DNS, traffic statistics
- **SSH Configuration**: Server/client config, keys, authorized_keys
- **Services**: systemd services, Docker containers, Kubernetes pods
- **Ports & Firewall**: Open ports, iptables, UFW, firewalld
- **Configuration Files**: System and application configs from /etc
- **Ceph Clusters**: Ceph status, OSD, monitors, pools
- **MCP Servers**: Model Context Protocol server configurations
- **Cron Jobs**: Scheduled tasks and timers
- **Installed Software**: Programming languages, databases, web servers

### Reporting

Generate detailed HTML or Markdown reports with:
- Complete system overview
- All discovered configuration data
- File inventory with descriptions
- Next steps for restoration

### System Restoration

Safely restore configurations on new VMs with:
- Package installation (apt, yum, pip)
- User and group creation
- SSH configuration
- Configuration file restoration
- Safety features: dry-run, backups, confirmation prompts

## Quick Start

### 1. Discover System Configuration

Run on the system you want to capture:

```bash
# Local system
ansible-playbook playbooks/discover_system.yml

# Remote system
ansible-playbook playbooks/discover_system.yml -i inventory/hosts.yml -l target_host
```

Discovery data will be saved to `/tmp/system_discovery/hostname_timestamp/`

### 2. Generate Report

```bash
# Generate HTML report
ansible-playbook playbooks/generate_report.yml

# Generate Markdown report
ansible-playbook playbooks/generate_report.yml -e "report_format=markdown"
```

Reports will be saved to `/tmp/system_reports/`

### 3. Restore on New VM

```bash
# Dry run first (recommended)
ansible-playbook playbooks/restore_system.yml \
  -e "restore_discovery_path=/tmp/system_discovery/hostname_timestamp" \
  -e "dry_run=true"

# Actual restoration
ansible-playbook playbooks/restore_system.yml \
  -e "restore_discovery_path=/tmp/system_discovery/hostname_timestamp"

# Remote restoration
ansible-playbook playbooks/restore_system.yml \
  -i inventory/hosts.yml -l new_vm \
  -e "restore_discovery_path=/tmp/system_discovery/hostname_timestamp"
```

## Directory Structure

```
ansible/
├── ansible.cfg                 # Ansible configuration
├── inventory/
│   └── hosts.yml              # Inventory file
├── playbooks/
│   ├── discover_system.yml    # Main discovery playbook
│   ├── generate_report.yml    # Report generation playbook
│   └── restore_system.yml     # System restoration playbook
├── roles/
│   ├── discovery/             # System discovery role
│   │   ├── tasks/
│   │   │   ├── main.yml
│   │   │   ├── system_info.yml
│   │   │   ├── packages.yml
│   │   │   ├── users.yml
│   │   │   ├── filesystem.yml
│   │   │   ├── network.yml
│   │   │   ├── ssh.yml
│   │   │   ├── services.yml
│   │   │   ├── ports.yml
│   │   │   ├── config_files.yml
│   │   │   ├── ceph.yml
│   │   │   ├── mcp_servers.yml
│   │   │   ├── firewall.yml
│   │   │   ├── cron_jobs.yml
│   │   │   └── installed_software.yml
│   │   └── defaults/
│   │       └── main.yml
│   ├── reporting/             # Report generation role
│   │   ├── tasks/
│   │   ├── templates/
│   │   │   ├── report.html.j2
│   │   │   └── report.md.j2
│   │   └── defaults/
│   └── system_restore/        # System restoration role
│       ├── tasks/
│       │   ├── main.yml
│       │   ├── restore_packages.yml
│       │   ├── restore_users.yml
│       │   ├── restore_ssh.yml
│       │   ├── restore_config_files.yml
│       │   ├── restore_cron_jobs.yml
│       │   ├── restore_network.yml
│       │   ├── restore_firewall.yml
│       │   └── restore_services.yml
│       ├── handlers/
│       └── defaults/
└── README.md
```

## Configuration

### Inventory Setup

Edit `inventory/hosts.yml` to add your target systems:

```yaml
all:
  children:
    target_systems:
      hosts:
        myserver:
          ansible_host: 192.168.1.100
          ansible_user: admin
          ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

### Discovery Options

Edit `roles/discovery/defaults/main.yml` to enable/disable discovery modules:

```yaml
discover_packages: true
discover_users: true
discover_filesystem: true
discover_network: true
discover_ssh: true
discover_services: true
discover_ports: true
discover_config_files: true
discover_ceph: true
discover_mcp_servers: true
# ... and more
```

### Restoration Safety

Edit `roles/system_restore/defaults/main.yml` or use `-e` flags:

```yaml
restore_packages: true
restore_users: true
restore_network: false  # Disabled for safety
restore_ssh: true
restore_services: false  # Disabled for safety
restore_config_files: true
restore_firewall: false  # Disabled for safety
restore_cron_jobs: true

dry_run: false
backup_existing: true
backup_dir: "/tmp/system_restore_backup"
```

## Advanced Usage

### Custom Discovery Path

```bash
ansible-playbook playbooks/discover_system.yml \
  -e "discovery_output_dir=/custom/path"
```

### Selective Restoration

```bash
# Only restore packages and users
ansible-playbook playbooks/restore_system.yml \
  -e "restore_discovery_path=/tmp/system_discovery/hostname_timestamp" \
  -e "restore_packages=true" \
  -e "restore_users=true" \
  -e "restore_ssh=false" \
  -e "restore_config_files=false" \
  -e "restore_cron_jobs=false"
```

### Remote System Discovery

```bash
# Add to inventory
ansible-playbook playbooks/discover_system.yml -i inventory/hosts.yml -l myserver
```

## Safety Features

- **Dry Run Mode**: Test restoration without making changes
- **Automatic Backups**: Backup existing configs before restoration
- **Confirmation Prompts**: Require user confirmation before restoration
- **Selective Restoration**: Choose exactly what to restore
- **Error Handling**: Continue on errors, don't abort entire restoration

## Limitations

- Network restoration disabled by default (can break connectivity)
- Firewall restoration disabled by default (can block access)
- Service restoration disabled by default (may cause issues)
- Some complex configurations require manual review
- Binary data and application-specific data not captured

## Requirements

- Ansible 2.9 or higher
- Python 3.6 or higher
- Root/sudo access on target systems
- SSH access for remote systems

## Contributing

Contributions welcome! Please test thoroughly on non-production systems.

## License

See LICENSE file for details.
