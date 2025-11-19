#!/bin/bash
# Install Portainer for Docker container management

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

log_info "Starting Portainer installation..."

# Check if running as root
check_root

# Check if Docker is installed
if ! command_exists docker; then
    log_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Configuration
PORTAINER_VERSION="latest"
PORTAINER_PORT="9443"
PORTAINER_HTTP_PORT="9000"
DATA_DIR="/var/lib/portainer"

# Prompt for configuration
prompt_with_default "Portainer HTTPS port" "$PORTAINER_PORT" PORTAINER_PORT
prompt_with_default "Portainer HTTP port" "$PORTAINER_HTTP_PORT" PORTAINER_HTTP_PORT
prompt_with_default "Data directory" "$DATA_DIR" DATA_DIR

# Check if port is available
if ! check_port "$PORTAINER_PORT"; then
    log_error "Port $PORTAINER_PORT is already in use"
    exit 1
fi

# Create data directory
create_directory "$DATA_DIR"

# Pull Portainer image
log_info "Pulling Portainer image..."
docker pull portainer/portainer-ce:$PORTAINER_VERSION

# Stop and remove existing Portainer container if exists
if docker ps -a | grep -q portainer; then
    log_info "Removing existing Portainer container..."
    docker stop portainer || true
    docker rm portainer || true
fi

# Run Portainer
log_info "Starting Portainer container..."
docker run -d \
    -p $PORTAINER_HTTP_PORT:9000 \
    -p $PORTAINER_PORT:9443 \
    --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $DATA_DIR:/data \
    portainer/portainer-ce:$PORTAINER_VERSION

# Wait for container to be healthy
log_info "Waiting for Portainer to start..."
sleep 5

# Check if container is running
if docker ps | grep -q portainer; then
    log_success "Portainer is running!"
else
    log_error "Portainer failed to start"
    docker logs portainer
    exit 1
fi

# Configure firewall
configure_firewall "$PORTAINER_PORT" tcp
configure_firewall "$PORTAINER_HTTP_PORT" tcp

# Get server IP
LOCAL_IP=$(get_local_ip)
PUBLIC_IP=$(get_public_ip)

# Display information
echo ""
log_success "Portainer Installation Complete!"
echo ""
echo "Access Portainer at:"
echo "  HTTPS: https://${LOCAL_IP}:${PORTAINER_PORT}"
echo "  HTTP:  http://${LOCAL_IP}:${PORTAINER_HTTP_PORT}"
if [[ "$PUBLIC_IP" != "Unable to detect" ]]; then
    echo "  Public: https://${PUBLIC_IP}:${PORTAINER_PORT}"
fi
echo ""
log_info "First-time setup:"
echo "  1. Navigate to the Portainer URL"
echo "  2. Create an admin user (first login)"
echo "  3. Choose 'Docker' as environment"
echo ""
log_warning "Initial setup must be completed within 5 minutes of first start"
