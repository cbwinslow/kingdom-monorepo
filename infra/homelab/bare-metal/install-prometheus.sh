#!/bin/bash
# Install Prometheus monitoring system

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

log_info "Starting Prometheus installation..."

# Check if running as root
check_root

# Configuration
PROMETHEUS_VERSION="2.48.0"
PROMETHEUS_USER="prometheus"
PROMETHEUS_PORT="9090"
INSTALL_DIR="/opt/prometheus"
DATA_DIR="/var/lib/prometheus"
CONFIG_DIR="/etc/prometheus"

# Create user
if ! id "$PROMETHEUS_USER" &>/dev/null; then
    useradd --no-create-home --shell /bin/false $PROMETHEUS_USER
    log_success "Created user: $PROMETHEUS_USER"
fi

# Create directories
create_directory "$INSTALL_DIR" "$PROMETHEUS_USER" "$PROMETHEUS_USER" 755
create_directory "$DATA_DIR" "$PROMETHEUS_USER" "$PROMETHEUS_USER" 755
create_directory "$CONFIG_DIR" "$PROMETHEUS_USER" "$PROMETHEUS_USER" 755

# Download Prometheus
log_info "Downloading Prometheus $PROMETHEUS_VERSION..."
cd /tmp
PROMETHEUS_URL="https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"
download_file "$PROMETHEUS_URL" "prometheus.tar.gz"

# Extract and install
log_info "Installing Prometheus..."
tar -xzf prometheus.tar.gz
cd prometheus-${PROMETHEUS_VERSION}.linux-amd64

cp prometheus promtool $INSTALL_DIR/
cp -r consoles console_libraries $INSTALL_DIR/

chown -R $PROMETHEUS_USER:$PROMETHEUS_USER $INSTALL_DIR

# Create configuration file
log_info "Creating Prometheus configuration..."
cat > $CONFIG_DIR/prometheus.yml <<EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets: []

rule_files:
  # - "rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']

  # - job_name: 'custom_service'
  #   static_configs:
  #     - targets: ['localhost:8080']
EOF

chown $PROMETHEUS_USER:$PROMETHEUS_USER $CONFIG_DIR/prometheus.yml

# Create systemd service
log_info "Creating systemd service..."
cat > /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=$PROMETHEUS_USER
Group=$PROMETHEUS_USER
Type=simple
ExecStart=$INSTALL_DIR/prometheus \\
  --config.file=$CONFIG_DIR/prometheus.yml \\
  --storage.tsdb.path=$DATA_DIR \\
  --web.console.templates=$INSTALL_DIR/consoles \\
  --web.console.libraries=$INSTALL_DIR/console_libraries \\
  --web.listen-address=0.0.0.0:$PROMETHEUS_PORT

Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
enable_service prometheus

# Configure firewall
configure_firewall "$PROMETHEUS_PORT" tcp

# Cleanup
cd /
rm -rf /tmp/prometheus*

# Get server IP
LOCAL_IP=$(get_local_ip)

# Display information
echo ""
log_success "Prometheus Installation Complete!"
echo ""
echo "Access Prometheus at: http://${LOCAL_IP}:${PROMETHEUS_PORT}"
echo ""
log_info "Configuration file: $CONFIG_DIR/prometheus.yml"
log_info "Data directory: $DATA_DIR"
echo ""
log_info "Useful commands:"
echo "  sudo systemctl status prometheus    - Check status"
echo "  sudo systemctl restart prometheus   - Restart service"
echo "  sudo journalctl -u prometheus -f    - View logs"
echo ""
log_warning "Don't forget to install node_exporter for system metrics!"
