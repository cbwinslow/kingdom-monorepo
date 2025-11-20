#!/bin/bash
# Install Pi-hole DNS ad blocker

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

log_info "Starting Pi-hole installation..."

# Check if running as root
check_root

# Check system requirements
check_requirements 1 5

# Configuration
PIHOLE_DIR="/etc/pihole"
WEBPASSWORD=""

# Prompt for configuration
echo ""
log_info "Pi-hole Configuration"
prompt_with_default "Web interface password (leave empty to generate)" "" WEBPASSWORD

if [[ -z "$WEBPASSWORD" ]]; then
    WEBPASSWORD=$(generate_password 16)
    log_info "Generated password: $WEBPASSWORD"
fi

# Install dependencies
log_info "Installing dependencies..."
install_package curl
install_package git

# Create directory
create_directory "$PIHOLE_DIR"

# Download and run installer
log_info "Downloading Pi-hole installer..."
cd /tmp
curl -sSL https://install.pi-hole.net -o pihole-install.sh

# Create setupVars.conf for unattended install
log_info "Creating configuration..."
cat > /tmp/setupVars.conf <<EOF
PIHOLE_INTERFACE=eth0
IPV4_ADDRESS=$(get_local_ip)/24
IPV6_ADDRESS=
QUERY_LOGGING=true
INSTALL_WEB_SERVER=true
INSTALL_WEB_INTERFACE=true
LIGHTTPD_ENABLED=true
CACHE_SIZE=10000
DNS_FQDN_REQUIRED=true
DNS_BOGUS_PRIV=true
DNSMASQ_LISTENING=local
WEBPASSWORD=$WEBPASSWORD
BLOCKING_ENABLED=true
PIHOLE_DNS_1=1.1.1.1
PIHOLE_DNS_2=1.0.0.1
EOF

# Run installer
log_info "Running Pi-hole installer (this may take a few minutes)..."
bash pihole-install.sh --unattended

# Wait for installation to complete
sleep 5

# Check if service is running
if systemctl is-active --quiet pihole-FTL; then
    log_success "Pi-hole service is running"
else
    log_error "Pi-hole service failed to start"
    exit 1
fi

# Configure firewall
configure_firewall 53 tcp
configure_firewall 53 udp
configure_firewall 80 tcp

# Add popular blocklists
log_info "Adding additional blocklists..."
pihole -a -addlist https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
pihole -g

# Get server IP
LOCAL_IP=$(get_local_ip)

# Display information
echo ""
log_success "Pi-hole Installation Complete!"
echo ""
echo "Web Interface: http://${LOCAL_IP}/admin"
echo "Password: $WEBPASSWORD"
echo ""
log_info "DNS Configuration:"
echo "  Set your router's DNS to: $LOCAL_IP"
echo "  Or configure each device to use: $LOCAL_IP"
echo ""
log_info "Useful commands:"
echo "  pihole status              - Check status"
echo "  pihole -g                  - Update blocklists"
echo "  pihole restartdns          - Restart DNS service"
echo "  pihole -c                  - Monitor in real-time"
echo "  pihole -a -p               - Change web password"
echo ""
log_warning "Save your password securely: $WEBPASSWORD"
