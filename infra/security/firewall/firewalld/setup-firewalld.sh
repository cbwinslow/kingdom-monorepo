#!/bin/bash
# Firewalld Configuration Script
# This script sets up comprehensive firewall rules for firewalld
# Including service ports and geographic blocking

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Firewalld Configuration...${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root or with sudo${NC}"
    exit 1
fi

# Install firewalld if not present
if ! command -v firewall-cmd &> /dev/null; then
    echo -e "${YELLOW}Firewalld not found. Installing...${NC}"
    if command -v dnf &> /dev/null; then
        dnf install -y firewalld
    elif command -v yum &> /dev/null; then
        yum install -y firewalld
    elif command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y firewalld
    else
        echo -e "${RED}Could not determine package manager. Please install firewalld manually.${NC}"
        exit 1
    fi
fi

# Start and enable firewalld
echo -e "${GREEN}Starting firewalld service...${NC}"
systemctl start firewalld
systemctl enable firewalld

# Set default zone
echo -e "${GREEN}Setting default zone to public...${NC}"
firewall-cmd --set-default-zone=public

# ============================================
# CONFIGURE PUBLIC ZONE (Default)
# ============================================

echo -e "${GREEN}Configuring public zone with service rules...${NC}"

# Remove all existing services first
echo -e "${YELLOW}Removing default services...${NC}"
firewall-cmd --zone=public --remove-service=dhcpv6-client 2>/dev/null || true
firewall-cmd --zone=public --remove-service=ssh 2>/dev/null || true

# Add essential services
echo -e "${GREEN}Adding essential services...${NC}"

# SSH - Essential for remote management
firewall-cmd --zone=public --add-service=ssh --permanent
firewall-cmd --zone=public --add-port=22/tcp --permanent

# HTTP/HTTPS - Web services
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --zone=public --add-service=https --permanent
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=443/tcp --permanent

# Alternative HTTP ports
firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --zone=public --add-port=8443/tcp --permanent

# DNS - Allow if running DNS server
firewall-cmd --zone=public --add-service=dns --permanent
firewall-cmd --zone=public --add-port=53/tcp --permanent
firewall-cmd --zone=public --add-port=53/udp --permanent

# Mail services
firewall-cmd --zone=public --add-service=smtp --permanent
firewall-cmd --zone=public --add-service=smtps --permanent
firewall-cmd --zone=public --add-service=smtp-submission --permanent
firewall-cmd --zone=public --add-port=25/tcp --permanent
firewall-cmd --zone=public --add-port=587/tcp --permanent
firewall-cmd --zone=public --add-port=465/tcp --permanent
firewall-cmd --zone=public --add-port=993/tcp --permanent
firewall-cmd --zone=public --add-port=995/tcp --permanent

# NTP - Time synchronization
firewall-cmd --zone=public --add-service=ntp --permanent
firewall-cmd --zone=public --add-port=123/udp --permanent

# Database services (uncomment if needed)
# firewall-cmd --zone=public --add-service=postgresql --permanent
# firewall-cmd --zone=public --add-port=5432/tcp --permanent
# firewall-cmd --zone=public --add-service=mysql --permanent
# firewall-cmd --zone=public --add-port=3306/tcp --permanent
# firewall-cmd --zone=public --add-port=27017/tcp --permanent  # MongoDB
# firewall-cmd --zone=public --add-port=6379/tcp --permanent   # Redis

# Docker/Container services (uncomment if needed)
# firewall-cmd --zone=public --add-port=2375/tcp --permanent  # Docker
# firewall-cmd --zone=public --add-port=2376/tcp --permanent  # Docker TLS

# Monitoring services (uncomment if needed)
# firewall-cmd --zone=public --add-port=9090/tcp --permanent  # Prometheus
# firewall-cmd --zone=public --add-port=3000/tcp --permanent  # Grafana

# Allow ICMP (ping)
firewall-cmd --zone=public --add-icmp-block-inversion --permanent
firewall-cmd --zone=public --remove-icmp-block=echo-request --permanent

# ============================================
# CONFIGURE INTERNAL ZONE (for trusted networks)
# ============================================

echo -e "${GREEN}Configuring internal zone for trusted networks...${NC}"

# Add common services to internal zone
firewall-cmd --zone=internal --add-service=ssh --permanent
firewall-cmd --zone=internal --add-service=http --permanent
firewall-cmd --zone=internal --add-service=https --permanent
firewall-cmd --zone=internal --add-service=dns --permanent

# Add database services to internal zone (safer than public)
firewall-cmd --zone=internal --add-service=postgresql --permanent
firewall-cmd --zone=internal --add-service=mysql --permanent
firewall-cmd --zone=internal --add-port=27017/tcp --permanent  # MongoDB
firewall-cmd --zone=internal --add-port=6379/tcp --permanent   # Redis

# ============================================
# SET DEFAULT POLICIES
# ============================================

echo -e "${GREEN}Setting default policies...${NC}"

# Set target for public zone to default (accept established, drop new)
firewall-cmd --zone=public --set-target=default --permanent

# Enable masquerading for outbound connections (if needed for NAT)
# firewall-cmd --zone=public --add-masquerade --permanent

# ============================================
# DIRECT RULES FOR OUTBOUND FILTERING
# ============================================

echo -e "${GREEN}Configuring outbound filtering...${NC}"

# By default, firewalld allows all outbound connections
# We need to add direct rules to filter outbound traffic

# Create custom chain for outbound filtering
firewall-cmd --permanent --direct --add-chain ipv4 filter OUTBOUND_FILTER
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -j OUTBOUND_FILTER

# Allow established and related connections
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTBOUND_FILTER 0 -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow loopback
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTBOUND_FILTER 0 -o lo -j ACCEPT

# Allow DNS
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTBOUND_FILTER 0 -p udp --dport 53 -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTBOUND_FILTER 0 -p tcp --dport 53 -j ACCEPT

# Allow HTTP/HTTPS
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTBOUND_FILTER 0 -p tcp --dport 80 -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTBOUND_FILTER 0 -p tcp --dport 443 -j ACCEPT

# Allow SSH outbound
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTBOUND_FILTER 0 -p tcp --dport 22 -j ACCEPT

# Allow NTP
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTBOUND_FILTER 0 -p udp --dport 123 -j ACCEPT

# Allow SMTP outbound
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTBOUND_FILTER 0 -p tcp --dport 25 -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTBOUND_FILTER 0 -p tcp --dport 587 -j ACCEPT

# Allow ICMP outbound
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTBOUND_FILTER 0 -p icmp -j ACCEPT

# Default drop for outbound (will be modified by geo-blocking script)
# Note: This is permissive by default. Run geo-block-setup.sh to restrict
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTBOUND_FILTER 999 -j ACCEPT

# ============================================
# LOGGING (Optional)
# ============================================

# Enable logging for dropped packets (uncomment if needed)
# firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" log prefix="FIREWALLD-DROP: " level="warning" limit value="10/m" drop' --permanent

# Reload firewall to apply changes
echo -e "${GREEN}Reloading firewall configuration...${NC}"
firewall-cmd --reload

# Show configuration
echo -e "${GREEN}Firewalld Configuration Complete!${NC}"
echo ""
echo -e "${GREEN}Active zones:${NC}"
firewall-cmd --get-active-zones
echo ""
echo -e "${GREEN}Default zone:${NC}"
firewall-cmd --get-default-zone
echo ""
echo -e "${GREEN}Public zone configuration:${NC}"
firewall-cmd --zone=public --list-all
echo ""
echo -e "${GREEN}Services in public zone:${NC}"
firewall-cmd --zone=public --list-services

echo ""
echo -e "${YELLOW}Important Notes:${NC}"
echo -e "1. Review the rules and adjust based on your specific needs"
echo -e "2. Database ports are available in internal zone only by default"
echo -e "3. Run geo-block-setup.sh to implement geographic blocking"
echo -e "4. Test connectivity after applying rules"
echo -e "5. Keep firewall rules updated as services change"
echo -e "6. Use 'firewall-cmd --runtime-to-permanent' to save runtime changes"
