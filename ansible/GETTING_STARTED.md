# Getting Started

This guide will walk you through your first system discovery and restoration.

## Prerequisites

- Ansible 2.9 or higher
- Python 3.6 or higher
- Root/sudo access on target systems
- SSH access for remote systems

## Installation

Ansible should already be installed. Verify:

```bash
ansible --version
```

If not installed:

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install ansible

# RHEL/CentOS
sudo yum install ansible

# macOS
brew install ansible

# Using pip
pip install ansible
```

## Quick Start: Local System Backup

### Step 1: Navigate to the ansible directory

```bash
cd /path/to/kingdom-monorepo/ansible
```

### Step 2: Run discovery on your local system

```bash
ansible-playbook playbooks/discover_system.yml
```

This will:
- Collect comprehensive system information
- Save data to `/tmp/system_discovery/hostname_timestamp/`
- Take 2-5 minutes depending on system size

### Step 3: Generate a report

```bash
ansible-playbook playbooks/generate_report.yml
```

View the report:

```bash
# Linux
xdg-open /tmp/system_reports/*_report_*.html

# macOS
open /tmp/system_reports/*_report_*.html

# Or use a browser
firefox /tmp/system_reports/*_report_*.html
```

### Step 4: Review the collected data

```bash
# List all discovered data
ls -lh /tmp/system_discovery/hostname_timestamp/

# View system information
cat /tmp/system_discovery/hostname_timestamp/system_info.yml

# View installed packages
less /tmp/system_discovery/hostname_timestamp/packages.txt

# View network configuration
less /tmp/system_discovery/hostname_timestamp/network.txt
```

## Testing Restoration (Dry Run)

Before actually restoring to a new system, test with dry-run:

```bash
ansible-playbook playbooks/restore_system.yml \
  -e "restore_discovery_path=/tmp/system_discovery/hostname_timestamp" \
  -e "dry_run=true"
```

This will:
- Show what would be restored
- Not make any actual changes
- Help you understand what will happen

## Remote System Discovery

### Step 1: Configure inventory

Edit `inventory/hosts.yml`:

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

### Step 2: Test connectivity

```bash
ansible -i inventory/hosts.yml myserver -m ping
```

### Step 3: Run discovery

```bash
ansible-playbook playbooks/discover_system.yml \
  -i inventory/hosts.yml \
  -l myserver
```

## Common Use Cases

### Use Case 1: Backup Before Upgrades

```bash
# Before major system upgrade
cd ansible/
ansible-playbook playbooks/discover_system.yml
# Upgrade system...
# If something breaks, you have the configuration backed up
```

### Use Case 2: Clone a Server

```bash
# 1. Discover source server
ansible-playbook playbooks/discover_system.yml -i inventory/hosts.yml -l source_server

# 2. Copy discovery data to safe location
cp -r /tmp/system_discovery/source_server_* ~/backups/

# 3. Restore to new server (dry run first)
ansible-playbook playbooks/restore_system.yml \
  -i inventory/hosts.yml -l new_server \
  -e "restore_discovery_path=/tmp/system_discovery/source_server_timestamp" \
  -e "dry_run=true"

# 4. Actual restoration
ansible-playbook playbooks/restore_system.yml \
  -i inventory/hosts.yml -l new_server \
  -e "restore_discovery_path=/tmp/system_discovery/source_server_timestamp"
```

### Use Case 3: Document Your Infrastructure

```bash
# Discover all servers
ansible-playbook playbooks/discover_system.yml -i inventory/hosts.yml

# Generate reports for all
ansible-playbook playbooks/generate_report.yml

# Archive reports
tar -czf infrastructure_docs_$(date +%Y%m%d).tar.gz /tmp/system_reports/
```

### Use Case 4: Selective Restoration

Only restore specific components:

```bash
# Only packages and users
ansible-playbook playbooks/restore_system.yml \
  -e "restore_discovery_path=/tmp/system_discovery/hostname_timestamp" \
  -e "restore_packages=true" \
  -e "restore_users=true" \
  -e "restore_ssh=false" \
  -e "restore_config_files=false" \
  -e "restore_cron_jobs=false"
```

## Understanding the Output

### Discovery Output Structure

```
/tmp/system_discovery/hostname_timestamp/
├── system_info.yml          # OS, kernel, hardware
├── packages.txt             # All installed packages
├── users_groups.txt         # Users, groups, sudoers
├── filesystem.txt           # Disks, partitions, mounts
├── network.txt              # Network interfaces, routing
├── ssh_config.txt           # SSH server/client config
├── services.txt             # Running services
├── ports.txt                # Open ports, firewall
├── environment.txt          # Environment variables
├── ceph.txt                 # Ceph cluster info
├── mcp_servers.txt          # MCP server configs
├── firewall.txt             # Firewall rules
├── cron_jobs.txt            # Scheduled tasks
├── installed_software.txt   # Detailed software inventory
└── config_files/            # Configuration file backups
    ├── sshd_config
    ├── hosts
    ├── nginx.tar.gz
    └── ...
```

### What Gets Captured

✅ **Fully Captured:**
- Operating system and version
- All installed packages
- User accounts and groups
- Filesystem layout
- Network configuration
- SSH setup
- Running services
- Open ports
- Configuration files

⚠️ **Partially Captured:**
- Application-specific configs (requires review)
- Custom scripts (requires review)
- Container configurations

❌ **Not Captured:**
- Passwords (only hashes)
- Running process state
- Temporary data
- Application data in /var
- Database contents

## Safety Tips

### Before Running Discovery

- Ensure you have sufficient disk space
- Consider privacy of the data collected
- Review what will be captured

### Before Running Restoration

1. **Always use dry_run first**
   ```bash
   -e "dry_run=true"
   ```

2. **Enable backups**
   ```bash
   -e "backup_existing=true"
   ```

3. **Test on non-production systems first**

4. **Have console access** to target system (in case SSH breaks)

5. **Keep network/firewall restoration disabled** by default

### After Restoration

- [ ] Verify SSH still works
- [ ] Check network connectivity
- [ ] Verify services are running
- [ ] Test critical applications
- [ ] Review and enable firewall rules manually
- [ ] Reboot if necessary

## Troubleshooting

### "Permission denied" errors

```bash
ansible-playbook playbooks/discover_system.yml --ask-become-pass
```

### "Host unreachable" for remote systems

```bash
# Test connectivity
ansible -i inventory/hosts.yml hostname -m ping

# Check SSH config
ssh -vvv user@hostname
```

### "Discovery data not found"

```bash
# List available discovery data
ls -lh /tmp/system_discovery/

# Use exact path
ansible-playbook playbooks/generate_report.yml \
  -e "discovery_timestamp=20231215T120000" \
  -e "report_hostname=myhost"
```

### Restoration fails

1. Check the discovery data exists
2. Run with verbose mode: `-v` or `-vvv`
3. Review the logs
4. Try selective restoration instead of full restoration

## Next Steps

- Read [README.md](README.md) for detailed documentation
- Check [EXAMPLES.md](EXAMPLES.md) for more use cases
- Review [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for command reference
- Customize discovery/restoration options in role defaults

## Getting Help

1. Check the documentation files
2. Run playbooks with `-v` for verbose output
3. Review the collected discovery data manually
4. Test on non-production systems first

## Best Practices

1. **Schedule regular discoveries** of production systems
2. **Store discovery data safely** (encrypted, version controlled)
3. **Document customizations** made after restoration
4. **Test restoration procedures** periodically
5. **Keep Ansible updated** for latest features and fixes
6. **Review security implications** of stored configuration data

## Security Considerations

- Discovery data contains sensitive information (users, hashes, configs)
- Store discovery data securely
- Limit access to discovery data
- Consider encrypting discovery archives
- Review before sharing discovery data
- Be careful with network/firewall restoration

## Performance Tips

- Discovery typically takes 2-5 minutes
- Use `-e "discover_ceph=false"` to skip Ceph if not used
- Restoration speed depends on package count
- Large systems may take 30-60 minutes to fully restore

## Contributing

Found a bug or want to add features? Contributions welcome!

1. Test thoroughly on non-production systems
2. Document your changes
3. Update relevant documentation files
4. Submit a pull request

## License

See LICENSE file for details.
