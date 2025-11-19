# Usage Examples

This document provides practical examples for using the Ansible system configuration management tools.

## Example 1: Backup Your Local Development Machine

```bash
# Navigate to the ansible directory
cd ansible/

# Run discovery on localhost
ansible-playbook playbooks/discover_system.yml

# Generate an HTML report
ansible-playbook playbooks/generate_report.yml

# View the report
firefox /tmp/system_reports/*_report_*.html
# or
open /tmp/system_reports/*_report_*.html
```

## Example 2: Migrate a Server Configuration

```bash
# Step 1: Discover configuration from source server
ansible-playbook playbooks/discover_system.yml \
  -i inventory/hosts.yml \
  -l source_server

# Step 2: Copy discovery data to a safe location
cp -r /tmp/system_discovery/source_server_* ~/backups/

# Step 3: Restore on new server (dry run first)
ansible-playbook playbooks/restore_system.yml \
  -i inventory/hosts.yml \
  -l new_server \
  -e "restore_discovery_path=/tmp/system_discovery/source_server_20231215T120000" \
  -e "dry_run=true"

# Step 4: Actual restoration
ansible-playbook playbooks/restore_system.yml \
  -i inventory/hosts.yml \
  -l new_server \
  -e "restore_discovery_path=/tmp/system_discovery/source_server_20231215T120000"
```

## Example 3: Document Multiple Servers

```bash
# Add servers to inventory/hosts.yml
# Then discover all servers

ansible-playbook playbooks/discover_system.yml \
  -i inventory/hosts.yml \
  -l web_servers

# Generate reports for all
ansible-playbook playbooks/generate_report.yml

# Reports will be in /tmp/system_reports/
ls -lh /tmp/system_reports/
```

## Example 4: Selective Package Installation

```bash
# Only install packages from a discovered system
ansible-playbook playbooks/restore_system.yml \
  -e "restore_discovery_path=/tmp/system_discovery/hostname_timestamp" \
  -e "restore_packages=true" \
  -e "restore_users=false" \
  -e "restore_ssh=false" \
  -e "restore_config_files=false" \
  -e "restore_cron_jobs=false"
```

## Example 5: Create System Snapshot Before Changes

```bash
# Before making major changes, capture current state
ansible-playbook playbooks/discover_system.yml \
  -e "discovery_output_dir=$HOME/system_snapshots"

# Make your changes...

# If something goes wrong, restore from snapshot
ansible-playbook playbooks/restore_system.yml \
  -e "restore_discovery_path=$HOME/system_snapshots/hostname_timestamp"
```

## Example 6: Scheduled Automated Backups

Create a cron job for regular system snapshots:

```bash
# Add to crontab
0 2 * * 0 cd /path/to/ansible && ansible-playbook playbooks/discover_system.yml -e "discovery_output_dir=/backups/weekly"
```

## Example 7: Compare Two Systems

```bash
# Discover both systems
ansible-playbook playbooks/discover_system.yml -i inventory/hosts.yml -l server1
ansible-playbook playbooks/discover_system.yml -i inventory/hosts.yml -l server2

# Compare package lists
diff /tmp/system_discovery/server1_*/packages.txt \
     /tmp/system_discovery/server2_*/packages.txt

# Compare user lists
diff /tmp/system_discovery/server1_*/users_groups.txt \
     /tmp/system_discovery/server2_*/users_groups.txt
```

## Example 8: Extract Specific Information

```bash
# After discovery, extract specific data

# Get list of installed Python packages
grep -A 1000 "Pip Packages:" /tmp/system_discovery/*/packages.txt | grep -v "Pip Packages:"

# Get list of users with UID >= 1000
grep -A 1000 "^Users:" /tmp/system_discovery/*/users_groups.txt | awk -F: '$3 >= 1000 {print $1}'

# Get network interface IPs
grep -A 5 "inet " /tmp/system_discovery/*/network.txt
```

## Example 9: Incremental Restoration

Sometimes you want to restore configuration in stages:

```bash
# Stage 1: Packages only
ansible-playbook playbooks/restore_system.yml \
  -e "restore_discovery_path=/tmp/system_discovery/hostname_timestamp" \
  -e "restore_packages=true" \
  -e "restore_users=false" \
  -e "restore_ssh=false"

# Stage 2: Users and SSH
ansible-playbook playbooks/restore_system.yml \
  -e "restore_discovery_path=/tmp/system_discovery/hostname_timestamp" \
  -e "restore_packages=false" \
  -e "restore_users=true" \
  -e "restore_ssh=true"

# Stage 3: Config files
ansible-playbook playbooks/restore_system.yml \
  -e "restore_discovery_path=/tmp/system_discovery/hostname_timestamp" \
  -e "restore_packages=false" \
  -e "restore_users=false" \
  -e "restore_config_files=true"
```

## Example 10: Custom Report Format

```bash
# Generate markdown report instead of HTML
ansible-playbook playbooks/generate_report.yml \
  -e "report_format=markdown"

# View in terminal
cat /tmp/system_reports/*_report_*.md

# Or convert to PDF
pandoc /tmp/system_reports/*_report_*.md -o system_report.pdf
```

## Example 11: Remote Discovery with Jump Host

If you need to go through a jump/bastion host:

```bash
# Edit ansible.cfg or use environment variable
export ANSIBLE_SSH_ARGS="-o ProxyCommand='ssh -W %h:%p jump_host'"

ansible-playbook playbooks/discover_system.yml \
  -i inventory/hosts.yml \
  -l remote_server
```

## Example 12: Discovery with Specific Modules Only

```bash
# Only discover network and SSH
ansible-playbook playbooks/discover_system.yml \
  -e "discover_packages=false" \
  -e "discover_users=false" \
  -e "discover_filesystem=false" \
  -e "discover_network=true" \
  -e "discover_ssh=true" \
  -e "discover_services=false"
```

## Troubleshooting

### Issue: Permission Denied

```bash
# Make sure you're running with become
ansible-playbook playbooks/discover_system.yml --ask-become-pass
```

### Issue: Discovery Data Not Found

```bash
# List available discovery directories
ls -lh /tmp/system_discovery/

# Specify exact path
ansible-playbook playbooks/generate_report.yml \
  -e "discovery_timestamp=20231215T120000" \
  -e "report_hostname=myhost"
```

### Issue: Restoration Fails

```bash
# Always test with dry_run first
ansible-playbook playbooks/restore_system.yml \
  -e "restore_discovery_path=/tmp/system_discovery/hostname_timestamp" \
  -e "dry_run=true" \
  -v

# Check the discovery data
ls -la /tmp/system_discovery/hostname_timestamp/
cat /tmp/system_discovery/hostname_timestamp/packages.txt
```

## Best Practices

1. **Always use dry_run first** when restoring to a new system
2. **Keep discovery data safe** - store in version control or backup location
3. **Review generated reports** before restoration
4. **Test on non-production systems** first
5. **Document customizations** made after restoration
6. **Schedule regular discoveries** for important systems
7. **Compare discovery data** over time to track changes
8. **Use selective restoration** instead of full restoration when possible

## Integration with CI/CD

Example GitLab CI/CD pipeline:

```yaml
system_backup:
  script:
    - cd ansible
    - ansible-playbook playbooks/discover_system.yml
    - tar -czf system_backup_$(date +%Y%m%d).tar.gz /tmp/system_discovery/
  artifacts:
    paths:
      - system_backup_*.tar.gz
    expire_in: 90 days
  schedule:
    - cron: "0 2 * * 0"
```

Example GitHub Actions:

```yaml
name: System Backup
on:
  schedule:
    - cron: '0 2 * * 0'
  workflow_dispatch:

jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install Ansible
        run: pip install ansible
      - name: Run Discovery
        run: |
          cd ansible
          ansible-playbook playbooks/discover_system.yml
      - name: Upload Artifact
        uses: actions/upload-artifact@v2
        with:
          name: system-backup
          path: /tmp/system_discovery/
```
