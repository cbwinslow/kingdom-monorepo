#!/bin/bash
# Install Docker and Docker Compose on Ubuntu/Debian systems

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

log_info "Starting Docker installation..."

# Check if running as root
check_root

# Detect OS
detect_os

# Check if Docker is already installed
if command_exists docker; then
    log_warning "Docker is already installed"
    docker --version
    if ! confirm_action "Do you want to reinstall?"; then
        exit 0
    fi
fi

# Update system packages
log_info "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install prerequisites
log_info "Installing prerequisites..."
install_package ca-certificates
install_package curl
install_package gnupg
install_package lsb-release

# Add Docker's official GPG key
log_info "Adding Docker GPG key..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
log_info "Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
log_info "Installing Docker Engine..."
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker service
log_info "Enabling Docker service..."
enable_service docker

# Add current user to docker group
if [[ -n "$SUDO_USER" ]]; then
    add_user_to_group "$SUDO_USER" docker
    log_info "User $SUDO_USER added to docker group (logout required)"
fi

# Configure Docker daemon
log_info "Configuring Docker daemon..."
create_directory /etc/docker root root 755

cat > /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF

# Restart Docker to apply configuration
systemctl restart docker

# Verify installation
log_info "Verifying Docker installation..."
docker --version
docker compose version

# Run hello-world test
log_info "Running hello-world test..."
if docker run --rm hello-world; then
    log_success "Docker installation completed successfully!"
else
    log_error "Docker test failed"
    exit 1
fi

# Display information
echo ""
log_success "Docker Installation Complete!"
echo ""
echo "Docker version: $(docker --version)"
echo "Docker Compose version: $(docker compose version)"
echo ""
log_info "Useful commands:"
echo "  docker ps                  - List running containers"
echo "  docker images              - List images"
echo "  docker compose up -d       - Start compose stack"
echo "  docker system prune        - Clean up unused data"
echo ""

if [[ -n "$SUDO_USER" ]]; then
    log_warning "User $SUDO_USER has been added to the docker group"
    log_warning "Please logout and login again for group changes to take effect"
fi
