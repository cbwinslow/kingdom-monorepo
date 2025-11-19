#!/usr/bin/env bash
# System Operations and Utilities

# Show disk usage
diskusage() {
    df -h
}

# Show memory usage
meminfo() {
    free -h
}

# Show CPU info
cpuinfo() {
    lscpu 2>/dev/null || sysctl -n machdep.cpu.brand_string
}

# Show system uptime
uptime_info() {
    uptime
}

# Show current processes
procs() {
    ps aux | grep -v grep | grep -i "$1"
}

# Kill process by name
killproc() {
    pkill -f "$1"
}

# Kill process by port
killport() {
    local port="$1"
    local pid=$(lsof -ti:"$port")
    if [ -n "$pid" ]; then
        kill -9 "$pid"
        echo "Killed process on port $port"
    else
        echo "No process found on port $port"
    fi
}

# List processes by CPU usage
topcpu() {
    ps aux --sort=-%cpu | head -n "${1:-10}"
}

# List processes by memory usage
topmem() {
    ps aux --sort=-%mem | head -n "${1:-10}"
}

# Show open ports
ports() {
    netstat -tuln 2>/dev/null || ss -tuln
}

# Check if port is open
check_port() {
    nc -zv localhost "$1" 2>&1
}

# Show listening ports
listening() {
    lsof -iTCP -sTCP:LISTEN -n -P
}

# Show network connections
netconns() {
    netstat -an | grep ESTABLISHED
}

# Show public IP
myip() {
    curl -s https://api.ipify.org
}

# Show local IP
localip() {
    ifconfig | grep "inet " | grep -v 127.0.0.1 | cut -d\  -f2
}

# Show all IPs
allips() {
    ifconfig | grep "inet " | awk '{print $2}'
}

# Ping with count
pingc() {
    ping -c "${2:-5}" "$1"
}

# DNS lookup
lookup() {
    nslookup "$1"
}

# DNS dig
diginfo() {
    dig "$1" +short
}

# Trace route
traceroute_info() {
    traceroute "$1"
}

# Show who is logged in
whoson() {
    who
}

# Show last login
lastlogin() {
    last | head -20
}

# Show system info
sysinfo() {
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "OS: $(uname -s)"
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "Uptime: $(uptime | awk '{print $3,$4}' | sed 's/,$//')"
    echo "CPU: $(lscpu 2>/dev/null | grep "Model name" | cut -d: -f2 | xargs || sysctl -n machdep.cpu.brand_string)"
    echo "Memory: $(free -h 2>/dev/null | awk '/^Mem:/ {print $2}' || sysctl hw.memsize | awk '{print $2/1024/1024/1024 " GB"}')"
    echo "Disk: $(df -h / | awk 'NR==2 {print $2}')"
}

# Show environment variables
showenv() {
    env | sort
}

# Set environment variable permanently
setenv_perm() {
    echo "export $1=\"$2\"" >> ~/.bashrc
    export "$1"="$2"
    echo "Environment variable $1 set permanently"
}

# Show path
showpath() {
    echo "$PATH" | tr ':' '\n'
}

# Add to path
addpath() {
    export PATH="$1:$PATH"
    echo "Added $1 to PATH"
}

# Reload shell config
reload() {
    if [ -f ~/.bashrc ]; then
        source ~/.bashrc
        echo "Reloaded ~/.bashrc"
    elif [ -f ~/.bash_profile ]; then
        source ~/.bash_profile
        echo "Reloaded ~/.bash_profile"
    elif [ -f ~/.zshrc ]; then
        source ~/.zshrc
        echo "Reloaded ~/.zshrc"
    fi
}

# Create alias
mkalias() {
    echo "alias $1='$2'" >> ~/.bash_aliases
    source ~/.bash_aliases 2>/dev/null
    echo "Alias $1 created"
}

# List aliases
lsalias() {
    alias | sort
}

# Remove alias
rmalias() {
    unalias "$1"
    sed -i "/alias $1=/d" ~/.bash_aliases 2>/dev/null
    echo "Alias $1 removed"
}

# Show system load
load() {
    uptime | awk '{print $10, $11, $12}'
}

# Monitor system resources
monitor() {
    watch -n 1 "echo '=== CPU Usage ===' && top -bn1 | grep 'Cpu(s)' && echo '' && echo '=== Memory Usage ===' && free -h && echo '' && echo '=== Disk Usage ===' && df -h /"
}

# Show battery status (macOS)
battery() {
    pmset -g batt 2>/dev/null || upower -i /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null
}

# Temperature (if sensors available)
temp() {
    sensors 2>/dev/null || echo "sensors command not found. Install lm-sensors"
}

# Clear RAM cache (requires sudo)
clearcache() {
    sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches"
    echo "Cache cleared"
}

# Show zombie processes
zombies() {
    ps aux | awk '{if ($8=="Z") print}'
}

# Show disk I/O
diskio() {
    iostat -x 1 5 2>/dev/null || echo "iostat not found. Install sysstat"
}

# Show network bandwidth
bandwidth() {
    iftop -n -P 2>/dev/null || echo "iftop not found. Install iftop"
}

# Start HTTP server
serve_http() {
    local port="${1:-8000}"
    python3 -m http.server "$port" 2>/dev/null || python -m SimpleHTTPServer "$port"
}

# Generate random password
genpass() {
    local length="${1:-16}"
    openssl rand -base64 "$length" | tr -d "=+/" | cut -c1-"$length"
}

# Generate UUID
genuuid() {
    uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid
}

# Get file mime type
mimetype() {
    file --mime-type -b "$1"
}

# Show hardware info
hardware() {
    lshw -short 2>/dev/null || system_profiler SPHardwareDataType 2>/dev/null
}

# Show USB devices
usb() {
    lsusb 2>/dev/null || system_profiler SPUSBDataType 2>/dev/null
}

# Show PCI devices
pci() {
    lspci 2>/dev/null || system_profiler SPPCIDataType 2>/dev/null
}

# Show kernel modules
modules() {
    lsmod | less
}

# Show services status
services() {
    systemctl list-units --type=service --all 2>/dev/null || service --status-all 2>/dev/null
}

# Start service
startservice() {
    sudo systemctl start "$1" 2>/dev/null || sudo service "$1" start
}

# Stop service
stopservice() {
    sudo systemctl stop "$1" 2>/dev/null || sudo service "$1" stop
}

# Restart service
restartservice() {
    sudo systemctl restart "$1" 2>/dev/null || sudo service "$1" restart
}

# Service status
statusservice() {
    sudo systemctl status "$1" 2>/dev/null || sudo service "$1" status
}

# Enable service
enableservice() {
    sudo systemctl enable "$1"
    echo "Service $1 enabled"
}

# Disable service
disableservice() {
    sudo systemctl disable "$1"
    echo "Service $1 disabled"
}

# Show journal logs
logs() {
    journalctl -xe 2>/dev/null || tail -f /var/log/syslog 2>/dev/null
}

# Show boot logs
bootlogs() {
    journalctl -b 2>/dev/null || dmesg | less
}

# Show user info
userinfo() {
    id
}

# List users
listusers() {
    cut -d: -f1 /etc/passwd | sort
}

# List groups
listgroups() {
    cut -d: -f1 /etc/group | sort
}

# Add user to group
addusergroup() {
    sudo usermod -aG "$2" "$1"
    echo "Added $1 to group $2"
}

# Show cron jobs
crons() {
    crontab -l
}

# Edit cron jobs
editcron() {
    crontab -e
}

# Backup cron jobs
backupcron() {
    crontab -l > ~/crontab_backup_$(date +%Y%m%d).txt
    echo "Cron backup saved"
}

# Show scheduled tasks
scheduled() {
    systemctl list-timers --all 2>/dev/null || atq 2>/dev/null
}

# System reboot
reboot_system() {
    sudo reboot
}

# System shutdown
shutdown_system() {
    sudo shutdown -h now
}

# Check command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Show which command
whichcmd() {
    which "$1"
}

# Show all paths for command
whereis_cmd() {
    whereis "$1"
}

# Show file type
filetype() {
    file "$1"
}

# Calculate MD5 checksum
md5() {
    md5sum "$1" 2>/dev/null || md5 "$1"
}

# Calculate SHA256 checksum
sha256() {
    sha256sum "$1" 2>/dev/null || shasum -a 256 "$1"
}

# Compare checksums
checksum_verify() {
    local file="$1"
    local expected="$2"
    local actual=$(sha256sum "$file" 2>/dev/null | awk '{print $1}' || shasum -a 256 "$file" | awk '{print $1}')
    if [ "$actual" = "$expected" ]; then
        echo "✓ Checksum verified"
        return 0
    else
        echo "✗ Checksum mismatch"
        return 1
    fi
}

# Show date and time
datetime() {
    date "+%Y-%m-%d %H:%M:%S %Z"
}

# Convert timestamp to date
ts2date() {
    date -d "@$1" 2>/dev/null || date -r "$1"
}

# Get current timestamp
timestamp() {
    date +%s
}

# Stopwatch
stopwatch() {
    local start=$(date +%s)
    echo "Stopwatch started. Press Ctrl+C to stop."
    trap 'local end=$(date +%s); echo "Elapsed: $((end-start)) seconds"; return' INT
    while true; do
        local current=$(date +%s)
        echo -ne "Elapsed: $((current-start)) seconds\r"
        sleep 1
    done
}

# Timer
timer() {
    local seconds="$1"
    local end=$(($(date +%s) + seconds))
    while [ "$(date +%s)" -lt "$end" ]; do
        echo -ne "$(($end - $(date +%s))) seconds remaining\r"
        sleep 1
    done
    echo "Time's up!"
}

# System bell
bell() {
    echo -e "\a"
}

# Repeat command
repeat() {
    local times="$1"
    shift
    for ((i=1; i<=times; i++)); do
        "$@"
    done
}

# Run command until it succeeds
until_success() {
    while ! "$@"; do
        echo "Command failed. Retrying in 5 seconds..."
        sleep 5
    done
    echo "Command succeeded!"
}

# Run command until it fails
until_fail() {
    while "$@"; do
        echo "Command succeeded. Running again in 5 seconds..."
        sleep 5
    done
    echo "Command failed!"
}
