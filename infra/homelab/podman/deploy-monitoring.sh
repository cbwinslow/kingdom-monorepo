#!/bin/bash
# Deploy monitoring stack with Podman

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if podman is installed
if ! command -v podman &> /dev/null; then
    log_error "Podman is not installed. Please install it first."
    exit 1
fi

log_info "Creating monitoring stack with Podman..."

# Create network
log_info "Creating monitoring network..."
podman network create monitoring 2>/dev/null || log_info "Network already exists"

# Create volumes
log_info "Creating volumes..."
podman volume create prometheus-data
podman volume create grafana-data

# Deploy Prometheus
log_info "Deploying Prometheus..."
podman run -d \
    --name prometheus \
    --network monitoring \
    -p 9090:9090 \
    -v prometheus-data:/prometheus \
    -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml:ro \
    --restart unless-stopped \
    prom/prometheus:latest

# Deploy Grafana
log_info "Deploying Grafana..."
podman run -d \
    --name grafana \
    --network monitoring \
    -p 3000:3000 \
    -e "GF_SECURITY_ADMIN_PASSWORD=admin" \
    -v grafana-data:/var/lib/grafana \
    --restart unless-stopped \
    grafana/grafana:latest

# Deploy Node Exporter
log_info "Deploying Node Exporter..."
podman run -d \
    --name node-exporter \
    --network monitoring \
    -p 9100:9100 \
    -v "/proc:/host/proc:ro" \
    -v "/sys:/host/sys:ro" \
    -v "/:/rootfs:ro" \
    --restart unless-stopped \
    prom/node-exporter:latest \
    --path.procfs=/host/proc \
    --path.sysfs=/host/sys \
    --path.rootfs=/rootfs

# Wait for services to start
log_info "Waiting for services to start..."
sleep 5

# Check status
log_info "Checking service status..."
podman ps --filter name=prometheus --filter name=grafana --filter name=node-exporter

# Display access information
echo ""
echo -e "${GREEN}Monitoring stack deployed successfully!${NC}"
echo ""
echo "Access services at:"
echo "  Prometheus: http://localhost:9090"
echo "  Grafana:    http://localhost:3000 (admin/admin)"
echo "  Node Exp:   http://localhost:9100/metrics"
echo ""
echo "Useful commands:"
echo "  podman ps                           # List containers"
echo "  podman logs -f <container>          # View logs"
echo "  podman stop prometheus grafana      # Stop services"
echo "  podman start prometheus grafana     # Start services"
echo ""
