# Quick Start Guide

Get up and running with CBW Dotfiles in 5 minutes!

## Installation

### One-Line Install

```bash
cd kingdom-monorepo/cbw-dotfiles && ./install.sh && source ~/.bashrc
```

### Verify Installation

```bash
dotfiles_count    # Should show: Total functions available: 796
dotfiles_help     # Display help menu
```

## Most Used Functions

### Navigation (Save Tons of Time!)

```bash
# Create directory and cd into it
mkcd my-project/src/components

# Go up multiple directories
up 3

# Jump to git repository root
cdgr

# Bookmark current directory
bookmark myproject

# Jump to bookmark from anywhere
goto myproject
```

### File Operations (Daily Essentials)

```bash
# Extract any archive format
extract file.tar.gz

# Backup file with timestamp
backup important.txt

# Find files by name
ff "*.js"

# Find 10 largest files
largest 10

# Find recently modified files
recent 20

# Find duplicate files
finddupes
```

### Git (80+ Commands)

```bash
# Quick commit and push
gacp "Quick fix for bug"

# Undo last commit (keep changes)
gundo

# Amend last commit
gamend

# Clean up merged branches
gcleanup

# Pretty log
gl

# Show authors
gauthors

# Show commit stats
gstats
```

### Docker (90+ Commands)

```bash
# List containers
dps

# Shell into container
dex container_name

# View logs (follow)
dlf container_name

# Clean everything
dclean

# Docker compose up
dcup

# Docker compose logs
dclogsf
```

### Kubernetes (100+ Commands)

```bash
# Get pods
kgp

# Shell into pod
kex pod-name

# View logs
klf pod-name

# Scale deployment
kscale deployment-name 3

# Get all resources
kga

# Show failing pods
kfailing
```

### System Utilities

```bash
# Kill process on port
killport 3000

# Show public IP
myip

# System information
sysinfo

# Disk usage
diskusage

# Memory info
meminfo

# Top CPU processes
topcpu

# Top memory processes
topmem
```

### Development Tools

```bash
# Clean node_modules and reinstall
npm_clean

# Create Python virtualenv
venv_create

# Run all tests
test_all

# Show code statistics
code_stats

# Format JSON
format_json data.json

# API testing
curl_post https://api.example.com/endpoint '{"key":"value"}'

# Copy SSH key to clipboard
sshkey_copy

# Generate password
genpass 20
```

### Text Processing

```bash
# Convert to lowercase
lowercase "HELLO WORLD"

# CSV to JSON
csv2json data.csv

# Word frequency
word_freq document.txt

# Extract emails
extract_emails file.txt

# Remove duplicates
dedup file.txt

# Add line numbers
add_line_numbers file.txt
```

### AWS Cloud

```bash
# List EC2 instances
ec2_list

# Sync to S3
s3_sync local_folder/ s3://bucket/

# Tail Lambda logs
lambda_logs function-name

# List RDS instances
rds_list

# Switch AWS profile
aws_profile production

# Get caller identity
aws_whoami

# Show billing
aws_billing
```

### Network Tools

```bash
# Port scan
portscan example.com 1 1000

# Check SSL certificate
ssl_cert example.com

# DNS check across multiple servers
dns_check example.com

# Get HTTP headers
http_headers https://example.com

# Check latency
latency example.com

# Speed test
speedtest
```

### Media Processing

```bash
# Convert image
img_convert input.png output.jpg

# Resize image
img_resize input.jpg 800x600 output.jpg

# Video to GIF
vid_to_gif input.mp4 output.gif

# Compress video
vid_compress video.mp4

# Merge PDFs
pdf_merge file1.pdf file2.pdf file3.pdf

# Download YouTube video
yt_download "https://youtube.com/watch?v=..."

# Download as audio only
yt_audio "https://youtube.com/watch?v=..."
```

## Power User Tips

### 1. Combine Functions

```bash
# Find, backup, and remove large files
largest 10 && backup large_file.txt && rm large_file.txt

# Quick project setup
mkcd my-project && git init && npm init -y && npm_clean
```

### 2. Use Bookmarks for Projects

```bash
cd ~/dev/important-project
bookmark imp
# Later from anywhere:
goto imp
```

### 3. Git Workflow

```bash
# Start feature
gcb feature/new-feature

# Work work work...
gac "Add new feature"

# Push
gp

# Done? Merge and cleanup
gco main && gpl && gm feature/new-feature && gcleanup
```

### 4. Docker Development

```bash
# Quick container inspection
dps                    # See what's running
dex myapp             # Jump in
dl myapp              # Check logs
drestart myapp        # Restart if needed
```

### 5. Kubernetes Debugging

```bash
# Quick pod debugging
kgp | grep myapp      # Find pod
kl myapp-pod-xxx      # Check logs
kex myapp-pod-xxx     # Jump in
kdp myapp-pod-xxx     # Describe pod
```

## Cheat Sheet

### Most Common Commands (Top 50)

```bash
# Navigation
mkcd, up, cdgr, cdpr, goto

# Files
extract, backup, ff, fd, findtext, largest, recent

# Git
gacp, gac, gc, gundo, gamend, gcleanup, gl, gst

# Docker
dps, dex, dl, dst, drm, dcup, dcdown

# Kubernetes
kgp, kl, kex, kscale, kga

# System
killport, myip, sysinfo, diskusage, meminfo

# Dev
npm_clean, test_all, venv_create, code_stats

# Text
lowercase, uppercase, csv2json, word_freq

# AWS
ec2_list, s3_sync, lambda_logs

# Network
portscan, ssl_cert, dns_check
```

## Aliases Quick Reference

```bash
# Navigation
..              # cd ..
...             # cd ../..
~               # cd ~

# List
l               # ls -lah
ll              # ls -lh
la              # ls -lAh

# Git
g               # git
gst             # git status
ga              # git add
gc              # git commit -m

# Docker
d               # docker
dc              # docker-compose

# Kubernetes
k               # kubectl

# System
c               # clear
please          # sudo

# Python
py              # python3
pip             # pip3

# Utilities
serve           # Python HTTP server
weather         # Show weather
publicip        # Show public IP
```

## Learning Path

### Day 1: Navigation & Files
- Master: `mkcd`, `up`, `cdgr`, `bookmark`, `goto`
- Learn: `extract`, `backup`, `ff`, `largest`

### Day 2: Git Mastery
- Master: `gacp`, `gundo`, `gamend`, `gl`
- Learn: `gcleanup`, `gauthors`, `gstats`

### Day 3: Containers
- Master: `dps`, `dex`, `dl`, `dcup`
- Learn: `kgp`, `kl`, `kex`

### Day 4: System & Development
- Master: `killport`, `myip`, `npm_clean`, `test_all`
- Learn: `sysinfo`, `code_stats`, `venv_create`

### Week 2: Explore Specialized Functions
- Text processing
- AWS operations
- Network tools
- Media processing

## Getting Help

```bash
# Show all categories
dotfiles_help

# Count functions
dotfiles_count

# List all functions
dotfiles_list

# View function file
cat ~/path/to/cbw-dotfiles/bash/functions/01-navigation.sh
```

## Update Dotfiles

```bash
# Update from git
dotfiles_update

# Check version
dotfiles_version

# Reload configuration
reload
```

## Troubleshooting

### Functions not available?

```bash
# Source the bashrc
source ~/path/to/cbw-dotfiles/bashrc

# Or add to your ~/.bashrc
echo 'source ~/path/to/cbw-dotfiles/bashrc' >> ~/.bashrc
```

### Need a specific tool?

```bash
# Check if command exists
command -v docker
command -v kubectl
command -v aws

# Install missing tools as needed
```

## Next Steps

1. ✅ Install dotfiles
2. ✅ Learn top 20 functions (this guide)
3. 📖 Read FUNCTIONS.md for complete reference
4. 🎯 Customize for your workflow
5. 🚀 Boost your productivity!

---

**Remember**: Type `dotfiles_help` anytime for quick reference!

**Pro Tip**: Create your own functions in `bash/functions/12-custom.sh`
