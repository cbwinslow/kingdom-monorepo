# Quick Reference Guide

## Common Commands

### Discovery

```bash
# Local system
ansible-playbook playbooks/discover_system.yml

# Remote system
ansible-playbook playbooks/discover_system.yml -i inventory/hosts.yml -l hostname

# Custom output directory
ansible-playbook playbooks/discover_system.yml -e "discovery_output_dir=/custom/path"
```

### Reporting

```bash
# HTML report
ansible-playbook playbooks/generate_report.yml

# Markdown report
ansible-playbook playbooks/generate_report.yml -e "report_format=markdown"
```

### Restoration

```bash
# Dry run (recommended first)
ansible-playbook playbooks/restore_system.yml \
  -e "restore_discovery_path=/path/to/discovery" \
  -e "dry_run=true"

# Full restoration
ansible-playbook playbooks/restore_system.yml \
  -e "restore_discovery_path=/path/to/discovery"

# Selective restoration
ansible-playbook playbooks/restore_system.yml \
  -e "restore_discovery_path=/path/to/discovery" \
  -e "restore_packages=true" \
  -e "restore_users=false"
```

## Key Variables

### Discovery Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `discovery_output_dir` | `/tmp/system_discovery` | Where to save discovery data |
| `discover_packages` | `true` | Discover installed packages |
| `discover_users` | `true` | Discover users and groups |
| `discover_filesystem` | `true` | Discover filesystem and disks |
| `discover_network` | `true` | Discover network configuration |
| `discover_ssh` | `true` | Discover SSH configuration |
| `discover_services` | `true` | Discover services and daemons |
| `discover_ports` | `true` | Discover open ports |
| `discover_config_files` | `true` | Discover config files |
| `discover_ceph` | `true` | Discover Ceph clusters |
| `discover_mcp_servers` | `true` | Discover MCP servers |
| `discover_firewall` | `true` | Discover firewall rules |
| `discover_cron_jobs` | `true` | Discover cron jobs |

### Restoration Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `restore_discovery_path` | *required* | Path to discovery data |
| `restore_packages` | `true` | Restore packages |
| `restore_users` | `true` | Restore users and groups |
| `restore_network` | `false` | Restore network config (⚠️ dangerous) |
| `restore_ssh` | `true` | Restore SSH config |
| `restore_services` | `false` | Restore services (⚠️ careful) |
| `restore_config_files` | `true` | Restore config files |
| `restore_firewall` | `false` | Restore firewall (⚠️ dangerous) |
| `restore_cron_jobs` | `true` | Restore cron jobs |
| `dry_run` | `false` | Test without making changes |
| `backup_existing` | `true` | Backup before restoration |
| `backup_dir` | `/tmp/system_restore_backup` | Where to save backups |

### Reporting Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `report_output_dir` | `/tmp/system_reports` | Where to save reports |
| `report_format` | `html` | Report format (html or markdown) |

## File Locations

### Discovery Output

```
/tmp/system_discovery/
└── hostname_timestamp/
    ├── system_info.yml
    ├── packages.txt
    ├── users_groups.txt
    ├── filesystem.txt
    ├── network.txt
    ├── ssh_config.txt
    ├── services.txt
    ├── ports.txt
    ├── environment.txt
    ├── ceph.txt
    ├── mcp_servers.txt
    ├── firewall.txt
    ├── cron_jobs.txt
    ├── installed_software.txt
    └── config_files/
        ├── sshd_config
        ├── hosts
        ├── nginx.tar.gz
        └── ...
```

### Reports

```
/tmp/system_reports/
├── hostname_report_timestamp.html
└── hostname_report_timestamp.md
```

### Backups (during restoration)

```
/tmp/system_restore_backup/
├── sshd_config.backup
└── ...
```

## Supported Operating Systems

- ✅ Ubuntu 18.04, 20.04, 22.04, 24.04
- ✅ Debian 10, 11, 12
- ✅ CentOS 7, 8
- ✅ RHEL 7, 8, 9
- ✅ Rocky Linux 8, 9
- ✅ AlmaLinux 8, 9

## Supported Package Managers

- **System**: apt, yum, dnf, rpm
- **Python**: pip, pip3
- **Node.js**: npm
- **Snap**: snap
- **Flatpak**: flatpak

## What Gets Discovered

### ✅ Fully Supported

- OS and kernel information
- Installed packages
- Users and groups
- Filesystem and partitions
- Network interfaces and routing
- SSH configuration
- Running services
- Open ports
- Firewall rules (iptables, UFW, firewalld)
- Environment variables
- Cron jobs

### ⚠️ Partially Supported

- Configuration files (requires manual review)
- Ceph clusters (if installed)
- MCP servers (if configured)
- Docker containers
- Kubernetes pods

### ❌ Not Supported

- Running processes state
- Active connections
- In-memory data
- Temporary files
- Application-specific data
- Binary data

## Safety Checklist

Before running restoration:

- [ ] Run discovery and review the data
- [ ] Test with `dry_run=true` first
- [ ] Enable `backup_existing=true`
- [ ] Start with selective restoration
- [ ] Keep network restoration disabled
- [ ] Keep firewall restoration disabled
- [ ] Keep services restoration disabled initially
- [ ] Have console/physical access to target system
- [ ] Test on non-production system first
- [ ] Document any manual changes needed

## Troubleshooting Quick Fixes

```bash
# Can't connect to remote host
ansible all -i inventory/hosts.yml -m ping

# Permission denied
ansible-playbook playbooks/discover_system.yml --ask-become-pass

# Python not found
ansible-playbook playbooks/discover_system.yml -e "ansible_python_interpreter=/usr/bin/python3"

# Discovery data not found
ls -la /tmp/system_discovery/

# View discovery data
cat /tmp/system_discovery/hostname_timestamp/system_info.yml

# Check restoration logs
ansible-playbook playbooks/restore_system.yml -e "..." -v
```

## Tags

All playbooks support Ansible tags:

```bash
# Run only discovery
ansible-playbook playbooks/discover_system.yml --tags discovery

# Run only reporting
ansible-playbook playbooks/generate_report.yml --tags reporting

# Run only restoration
ansible-playbook playbooks/restore_system.yml --tags restore
```

## Ansible Options

Useful Ansible command-line options:

```bash
-i inventory/hosts.yml    # Specify inventory
-l hostname              # Limit to specific host
-e "var=value"           # Extra variables
-v, -vv, -vvv           # Verbosity
--check                  # Dry run (like dry_run=true)
--diff                   # Show differences
--ask-become-pass        # Prompt for sudo password
--ask-pass               # Prompt for SSH password
--tags tag1,tag2         # Run specific tags
--skip-tags tag1,tag2    # Skip specific tags
```

## Getting Help

```bash
# View playbook variables
ansible-playbook playbooks/discover_system.yml --help

# List all tasks
ansible-playbook playbooks/discover_system.yml --list-tasks

# List all tags
ansible-playbook playbooks/discover_system.yml --list-tags

# List all hosts
ansible-playbook playbooks/discover_system.yml --list-hosts -i inventory/hosts.yml
```

## Emergency Recovery

If restoration breaks the system:

```bash
# Restore from backup
cp /tmp/system_restore_backup/sshd_config /etc/ssh/sshd_config
systemctl restart sshd

# Use console access if SSH is broken
# Boot into recovery mode
# Restore backups manually

# Rollback packages (Debian/Ubuntu)
apt-mark showhold  # See held packages
apt-mark unhold package_name
apt-get install package_name=version

# Rollback packages (RHEL/CentOS)
yum history list
yum history undo <transaction_id>
```
