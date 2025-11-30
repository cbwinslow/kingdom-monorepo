#!/bin/bash
# UFW Firewall Configuration Script
# This script sets up comprehensive firewall rules for UFW
# Including service ports and geographic blocking

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting UFW Firewall Configuration...${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root or with sudo${NC}"
    exit 1
fi

# Install UFW if not present
if ! command -v ufw &> /dev/null; then
    echo -e "${YELLOW}UFW not found. Installing...${NC}"
    apt-get update
    apt-get install -y ufw
fi

# Disable UFW to make changes
echo -e "${YELLOW}Disabling UFW to apply configuration...${NC}"
ufw --force disable

# Reset UFW to default state
echo -e "${YELLOW}Resetting UFW to default state...${NC}"
ufw --force reset

# Set default policies
echo -e "${GREEN}Setting default policies...${NC}"
ufw default deny incoming
ufw default deny outgoing
ufw default deny forward

# Allow loopback interface
echo -e "${GREEN}Allowing loopback interface...${NC}"
ufw allow in on lo
ufw allow out on lo

# ============================================
# INCOMING RULES - Allow necessary services
# ============================================

echo -e "${GREEN}Configuring incoming service rules...${NC}"

# SSH - Essential for remote management
ufw allow in 22/tcp comment 'SSH'

# HTTP/HTTPS - Web services
ufw allow in 80/tcp comment 'HTTP'
ufw allow in 443/tcp comment 'HTTPS'

# Alternative HTTP ports
ufw allow in 8080/tcp comment 'HTTP Alt'
ufw allow in 8443/tcp comment 'HTTPS Alt'

# DNS - Allow incoming DNS queries if running DNS server
ufw allow in 53/tcp comment 'DNS TCP'
ufw allow in 53/udp comment 'DNS UDP'

# Mail services (if needed)
ufw allow in 25/tcp comment 'SMTP'
ufw allow in 587/tcp comment 'SMTP Submission'
ufw allow in 465/tcp comment 'SMTPS'
ufw allow in 993/tcp comment 'IMAPS'
ufw allow in 995/tcp comment 'POP3S'

# Database services (restrict these if not needed publicly)
# ufw allow in 5432/tcp comment 'PostgreSQL'
# ufw allow in 3306/tcp comment 'MySQL'
# ufw allow in 27017/tcp comment 'MongoDB'
# ufw allow in 6379/tcp comment 'Redis'

# Docker/Container services
# ufw allow in 2375/tcp comment 'Docker'
# ufw allow in 2376/tcp comment 'Docker TLS'

# Monitoring and metrics
# ufw allow in 9090/tcp comment 'Prometheus'
# ufw allow in 3000/tcp comment 'Grafana'

# Allow ICMP (ping) for diagnostics
ufw allow in proto icmp comment 'ICMP Ping'

# ============================================
# OUTGOING RULES - Allow necessary services
# ============================================

echo -e "${GREEN}Configuring outgoing service rules...${NC}"

# DNS - Essential for name resolution
ufw allow out 53/tcp comment 'DNS TCP out'
ufw allow out 53/udp comment 'DNS UDP out'

# HTTP/HTTPS - For updates and external APIs
ufw allow out 80/tcp comment 'HTTP out'
ufw allow out 443/tcp comment 'HTTPS out'

# SSH - For outgoing SSH connections
ufw allow out 22/tcp comment 'SSH out'

# NTP - Time synchronization
ufw allow out 123/udp comment 'NTP'

# SMTP - Outgoing mail
ufw allow out 25/tcp comment 'SMTP out'
ufw allow out 587/tcp comment 'SMTP Submission out'

# Allow outgoing ICMP
ufw allow out proto icmp comment 'ICMP out'

# ============================================
# GEOGRAPHIC BLOCKING
# ============================================

echo -e "${YELLOW}Note: Geographic blocking requires additional setup${NC}"
echo -e "${YELLOW}See geo-block-setup.sh for IP-based geographic blocking${NC}"

# Enable UFW
echo -e "${GREEN}Enabling UFW...${NC}"
ufw --force enable

# Show status
echo -e "${GREEN}UFW Configuration Complete!${NC}"
echo -e "${GREEN}Current UFW Status:${NC}"
ufw status verbose

echo ""
echo -e "${YELLOW}Important Notes:${NC}"
echo -e "1. Review the rules and adjust based on your specific needs"
echo -e "2. Database ports are commented out by default for security"
echo -e "3. Run geo-block-setup.sh to implement geographic blocking"
echo -e "4. Test connectivity after applying rules"
echo -e "5. Keep UFW rules updated as services change"
