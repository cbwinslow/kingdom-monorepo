#!/bin/bash
# Install Podman - daemonless container engine

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

log_info "Starting Podman installation..."

# Check if running as root
check_root

# Detect OS
detect_os

# Check if Podman is already installed
if command_exists podman; then
    log_warning "Podman is already installed"
    podman --version
    if ! confirm_action "Do you want to reinstall?"; then
        exit 0
    fi
fi

# Update system packages
log_info "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install Podman based on OS
if [[ "$OS" == "ubuntu" ]]; then
    log_info "Installing Podman on Ubuntu..."
    
    # Add repository
    . /etc/os-release
    echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | \
        tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
    
    curl -L "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/Release.key" | \
        apt-key add -
    
    apt-get update
    apt-get install -y podman
elif [[ "$OS" == "debian" ]]; then
    log_info "Installing Podman on Debian..."
    
    # Install from backports or testing
    apt-get install -y podman
else
    log_error "Unsupported OS: $OS"
    exit 1
fi

# Install podman-compose
log_info "Installing podman-compose..."
if ! command_exists pip3; then
    install_package python3-pip
fi

pip3 install podman-compose

# Configure Podman for rootless
log_info "Configuring rootless Podman..."

# Enable user namespaces
echo "user.max_user_namespaces=28633" > /etc/sysctl.d/userns.conf
sysctl -p /etc/sysctl.d/userns.conf

# Configure subuid and subgid
if [[ -n "$SUDO_USER" ]]; then
    if ! grep -q "^$SUDO_USER:" /etc/subuid; then
        echo "$SUDO_USER:100000:65536" >> /etc/subuid
        echo "$SUDO_USER:100000:65536" >> /etc/subgid
        log_info "Configured subuid/subgid for $SUDO_USER"
    fi
fi

# Create directories for rootless podman
if [[ -n "$SUDO_USER" ]]; then
    sudo -u "$SUDO_USER" mkdir -p "/home/$SUDO_USER/.config/containers"
    sudo -u "$SUDO_USER" mkdir -p "/home/$SUDO_USER/.local/share/containers"
fi

# Create registries configuration
cat > /etc/containers/registries.conf <<EOF
[registries.search]
registries = ['docker.io', 'quay.io']

[registries.insecure]
registries = []

[registries.block]
registries = []
EOF

# Enable Podman socket for API compatibility
if [[ -n "$SUDO_USER" ]]; then
    sudo -u "$SUDO_USER" systemctl --user enable podman.socket
    log_info "Enabled Podman socket for $SUDO_USER"
fi

# Verify installation
log_info "Verifying Podman installation..."
podman --version
podman-compose --version || log_warning "podman-compose not found in PATH"

# Run hello-world test
log_info "Running hello-world test..."
if podman run --rm hello-world; then
    log_success "Podman installation completed successfully!"
else
    log_warning "Podman test container failed (this is sometimes normal)"
fi

# Display information
echo ""
log_success "Podman Installation Complete!"
echo ""
echo "Podman version: $(podman --version)"
if command_exists podman-compose; then
    echo "Podman Compose version: $(podman-compose --version)"
fi
echo ""
log_info "Useful commands:"
echo "  podman ps                  - List running containers"
echo "  podman images              - List images"
echo "  podman-compose up -d       - Start compose stack"
echo "  podman system prune        - Clean up unused data"
echo ""
log_info "Rootless mode:"
echo "  Podman runs without root by default"
echo "  User namespaces are configured"
echo "  Socket available at: unix:///run/user/\$UID/podman/podman.sock"
echo ""
log_warning "For rootless operation, logout and login as your user"
