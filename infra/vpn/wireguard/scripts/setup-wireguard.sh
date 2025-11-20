#!/bin/bash

# WireGuard VPN Setup Script
# This script installs and configures WireGuard on the system

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")/configs"
WG_CONFIG_DIR="/etc/wireguard"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: This script must be run as root (use sudo)${NC}"
   exit 1
fi

echo -e "${GREEN}=== WireGuard VPN Setup ===${NC}"
echo ""

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo -e "${RED}Error: Cannot detect operating system${NC}"
    exit 1
fi

# Install WireGuard based on OS
echo -e "${YELLOW}Installing WireGuard...${NC}"
case $OS in
    ubuntu|debian)
        apt-get update
        apt-get install -y wireguard wireguard-tools resolvconf
        ;;
    fedora|rhel|centos)
        dnf install -y wireguard-tools resolvconf
        ;;
    arch)
        pacman -S --noconfirm wireguard-tools resolvconf
        ;;
    *)
        echo -e "${RED}Error: Unsupported operating system: $OS${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}✓ WireGuard installed successfully${NC}"
echo ""

# Check if config directory exists
if [ ! -d "$WG_CONFIG_DIR" ]; then
    mkdir -p "$WG_CONFIG_DIR"
    chmod 700 "$WG_CONFIG_DIR"
fi

# Check for configuration file
CONFIG_NAME="wg0"
if [ ! -z "$1" ]; then
    CONFIG_NAME="$1"
fi

LOCAL_CONFIG="$CONFIG_DIR/$CONFIG_NAME.conf"
SYSTEM_CONFIG="$WG_CONFIG_DIR/$CONFIG_NAME.conf"

if [ -f "$LOCAL_CONFIG" ]; then
    echo -e "${YELLOW}Found configuration: $LOCAL_CONFIG${NC}"
    echo -e "${YELLOW}Copying to system configuration directory...${NC}"
    cp "$LOCAL_CONFIG" "$SYSTEM_CONFIG"
    chmod 600 "$SYSTEM_CONFIG"
    echo -e "${GREEN}✓ Configuration installed${NC}"
elif [ -f "$SYSTEM_CONFIG" ]; then
    echo -e "${GREEN}✓ System configuration already exists: $SYSTEM_CONFIG${NC}"
else
    echo -e "${YELLOW}No configuration file found.${NC}"
    echo -e "${YELLOW}Please create a configuration file at:${NC}"
    echo -e "  $LOCAL_CONFIG"
    echo -e "${YELLOW}You can use the template at:${NC}"
    echo -e "  $CONFIG_DIR/$CONFIG_NAME.conf.template"
    echo ""
    echo -e "${YELLOW}To generate keys, run:${NC}"
    echo -e "  wg genkey | tee privatekey | wg pubkey > publickey"
    echo ""
    exit 0
fi

# Enable IP forwarding (useful for routing)
echo -e "${YELLOW}Configuring system for VPN...${NC}"
sysctl -w net.ipv4.ip_forward=1 > /dev/null
sysctl -w net.ipv6.conf.all.forwarding=1 > /dev/null

# Make IP forwarding persistent
if ! grep -q "net.ipv4.ip_forward=1" /etc/sysctl.conf; then
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
fi
if ! grep -q "net.ipv6.conf.all.forwarding=1" /etc/sysctl.conf; then
    echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf
fi

echo -e "${GREEN}✓ System configured${NC}"
echo ""

# Enable and start WireGuard
echo -e "${YELLOW}Enabling WireGuard service...${NC}"
systemctl enable wg-quick@$CONFIG_NAME
echo -e "${GREEN}✓ WireGuard service enabled${NC}"
echo ""

echo -e "${GREEN}=== Setup Complete ===${NC}"
echo ""
echo -e "${YELLOW}To start the VPN connection, run:${NC}"
echo -e "  sudo systemctl start wg-quick@$CONFIG_NAME"
echo -e "${YELLOW}Or use the control script:${NC}"
echo -e "  sudo $SCRIPT_DIR/vpn-control.sh start $CONFIG_NAME"
echo ""
echo -e "${YELLOW}To check status:${NC}"
echo -e "  sudo wg show"
echo -e "  sudo systemctl status wg-quick@$CONFIG_NAME"
