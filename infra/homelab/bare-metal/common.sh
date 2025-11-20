#!/bin/bash
# Common functions for bare metal installations

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root or with sudo"
        exit 1
    fi
}

# Check if running as non-root (when root is not needed)
check_non_root() {
    if [[ $EUID -eq 0 ]]; then
        log_warning "This script should not be run as root"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Detect OS
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        OS_VERSION=$VERSION_ID
    else
        log_error "Cannot detect OS"
        exit 1
    fi
    log_info "Detected OS: $OS $OS_VERSION"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install package based on OS
install_package() {
    local package=$1
    
    if command_exists apt-get; then
        apt-get update -qq
        apt-get install -y "$package"
    elif command_exists dnf; then
        dnf install -y "$package"
    elif command_exists yum; then
        yum install -y "$package"
    elif command_exists pacman; then
        pacman -Sy --noconfirm "$package"
    else
        log_error "No supported package manager found"
        return 1
    fi
}

# Create directory with proper permissions
create_directory() {
    local dir=$1
    local owner=${2:-root}
    local group=${3:-root}
    local perms=${4:-755}
    
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        chown "$owner:$group" "$dir"
        chmod "$perms" "$dir"
        log_success "Created directory: $dir"
    else
        log_info "Directory already exists: $dir"
    fi
}

# Generate random password
generate_password() {
    local length=${1:-32}
    openssl rand -base64 "$length" | tr -d "=+/" | cut -c1-"$length"
}

# Backup file before modification
backup_file() {
    local file=$1
    if [[ -f "$file" ]]; then
        cp "$file" "${file}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backed up $file"
    fi
}

# Wait for service to be ready
wait_for_service() {
    local service=$1
    local max_wait=${2:-60}
    local count=0
    
    log_info "Waiting for $service to be ready..."
    while ! systemctl is-active --quiet "$service" && [[ $count -lt $max_wait ]]; do
        sleep 1
        ((count++))
    done
    
    if [[ $count -ge $max_wait ]]; then
        log_error "Service $service did not start in time"
        return 1
    fi
    log_success "Service $service is ready"
}

# Check if port is in use
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        log_warning "Port $port is already in use"
        return 1
    fi
    return 0
}

# Download file with retry
download_file() {
    local url=$1
    local output=$2
    local retries=${3:-3}
    
    for i in $(seq 1 $retries); do
        if wget -q "$url" -O "$output"; then
            log_success "Downloaded $url"
            return 0
        fi
        log_warning "Download attempt $i failed, retrying..."
        sleep 2
    done
    
    log_error "Failed to download $url after $retries attempts"
    return 1
}

# Add user to group
add_user_to_group() {
    local user=$1
    local group=$2
    
    if ! getent group "$group" > /dev/null; then
        groupadd "$group"
        log_info "Created group: $group"
    fi
    
    if ! groups "$user" | grep -q "\b$group\b"; then
        usermod -aG "$group" "$user"
        log_success "Added $user to group $group"
    else
        log_info "User $user already in group $group"
    fi
}

# Configure firewall rule
configure_firewall() {
    local port=$1
    local proto=${2:-tcp}
    
    if command_exists ufw; then
        ufw allow "$port/$proto"
        log_success "UFW: Allowed $port/$proto"
    elif command_exists firewall-cmd; then
        firewall-cmd --permanent --add-port="$port/$proto"
        firewall-cmd --reload
        log_success "Firewalld: Allowed $port/$proto"
    else
        log_warning "No firewall management tool found"
    fi
}

# Enable and start systemd service
enable_service() {
    local service=$1
    
    systemctl daemon-reload
    systemctl enable "$service"
    systemctl start "$service"
    
    if systemctl is-active --quiet "$service"; then
        log_success "Service $service is running"
    else
        log_error "Failed to start service $service"
        return 1
    fi
}

# Create systemd service file
create_systemd_service() {
    local service_name=$1
    local description=$2
    local exec_start=$3
    local user=${4:-root}
    local working_dir=${5:-/}
    
    cat > "/etc/systemd/system/${service_name}.service" <<EOF
[Unit]
Description=$description
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=$user
WorkingDirectory=$working_dir
ExecStart=$exec_start
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    
    log_success "Created systemd service: $service_name"
}

# Check system requirements
check_requirements() {
    local min_ram_gb=${1:-2}
    local min_disk_gb=${2:-10}
    
    # Check RAM
    local total_ram
    total_ram=$(free -g | awk '/^Mem:/{print $2}')
    if [[ $total_ram -lt $min_ram_gb ]]; then
        log_error "Insufficient RAM: ${total_ram}GB (minimum: ${min_ram_gb}GB)"
        return 1
    fi
    
    # Check disk space
    local free_disk
    free_disk=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    if [[ $free_disk -lt $min_disk_gb ]]; then
        log_error "Insufficient disk space: ${free_disk}GB (minimum: ${min_disk_gb}GB)"
        return 1
    fi
    
    log_success "System requirements check passed"
}

# Get user input with default value
prompt_with_default() {
    local prompt=$1
    local default=$2
    local var_name=$3
    
    read -p "$prompt [$default]: " input
    eval "$var_name=\"${input:-$default}\""
}

# Confirm action
confirm_action() {
    local prompt=${1:-"Are you sure?"}
    read -p "$prompt (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Get public IP address
get_public_ip() {
    curl -s ifconfig.me || curl -s icanhazip.com || echo "Unable to detect"
}

# Get local IP address
get_local_ip() {
    ip route get 1 | awk '{print $(NF-2);exit}'
}

# Export all functions
export -f log_info log_success log_warning log_error
export -f check_root check_non_root detect_os command_exists
export -f install_package create_directory generate_password backup_file
export -f wait_for_service check_port download_file add_user_to_group
export -f configure_firewall enable_service create_systemd_service
export -f check_requirements prompt_with_default confirm_action
export -f get_public_ip get_local_ip
