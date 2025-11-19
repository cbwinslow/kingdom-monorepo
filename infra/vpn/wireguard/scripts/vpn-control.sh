#!/bin/bash

# WireGuard VPN Control Script
# Control WireGuard VPN connections (start, stop, restart, status)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default interface name
INTERFACE="${2:-wg0}"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: This script must be run as root (use sudo)${NC}"
   exit 1
fi

# Function to display usage
usage() {
    echo "Usage: $0 {start|stop|restart|status|enable|disable} [interface]"
    echo ""
    echo "Commands:"
    echo "  start      - Start the VPN connection"
    echo "  stop       - Stop the VPN connection"
    echo "  restart    - Restart the VPN connection"
    echo "  status     - Show VPN connection status"
    echo "  enable     - Enable VPN to start on boot"
    echo "  disable    - Disable VPN from starting on boot"
    echo ""
    echo "Arguments:"
    echo "  interface  - WireGuard interface name (default: wg0)"
    echo ""
    echo "Examples:"
    echo "  $0 start              # Start default wg0 interface"
    echo "  $0 status wg1         # Check status of wg1 interface"
    echo "  $0 restart            # Restart default wg0 interface"
    exit 1
}

# Function to start VPN
start_vpn() {
    echo -e "${YELLOW}Starting WireGuard VPN ($INTERFACE)...${NC}"
    if systemctl is-active --quiet wg-quick@$INTERFACE; then
        echo -e "${BLUE}VPN is already running${NC}"
    else
        systemctl start wg-quick@$INTERFACE
        sleep 1
        if systemctl is-active --quiet wg-quick@$INTERFACE; then
            echo -e "${GREEN}✓ VPN started successfully${NC}"
            show_status
        else
            echo -e "${RED}✗ Failed to start VPN${NC}"
            exit 1
        fi
    fi
}

# Function to stop VPN
stop_vpn() {
    echo -e "${YELLOW}Stopping WireGuard VPN ($INTERFACE)...${NC}"
    if systemctl is-active --quiet wg-quick@$INTERFACE; then
        systemctl stop wg-quick@$INTERFACE
        sleep 1
        if ! systemctl is-active --quiet wg-quick@$INTERFACE; then
            echo -e "${GREEN}✓ VPN stopped successfully${NC}"
        else
            echo -e "${RED}✗ Failed to stop VPN${NC}"
            exit 1
        fi
    else
        echo -e "${BLUE}VPN is not running${NC}"
    fi
}

# Function to restart VPN
restart_vpn() {
    echo -e "${YELLOW}Restarting WireGuard VPN ($INTERFACE)...${NC}"
    systemctl restart wg-quick@$INTERFACE
    sleep 1
    if systemctl is-active --quiet wg-quick@$INTERFACE; then
        echo -e "${GREEN}✓ VPN restarted successfully${NC}"
        show_status
    else
        echo -e "${RED}✗ Failed to restart VPN${NC}"
        exit 1
    fi
}

# Function to show VPN status
show_status() {
    echo ""
    echo -e "${BLUE}=== VPN Status ===${NC}"
    
    # Check if interface exists
    if [ ! -f "/etc/wireguard/$INTERFACE.conf" ]; then
        echo -e "${RED}Configuration file not found: /etc/wireguard/$INTERFACE.conf${NC}"
        exit 1
    fi
    
    # Service status
    echo -e "\n${YELLOW}Service Status:${NC}"
    if systemctl is-active --quiet wg-quick@$INTERFACE; then
        echo -e "  State: ${GREEN}Active (Running)${NC}"
    else
        echo -e "  State: ${RED}Inactive (Stopped)${NC}"
    fi
    
    if systemctl is-enabled --quiet wg-quick@$INTERFACE 2>/dev/null; then
        echo -e "  Boot: ${GREEN}Enabled${NC}"
    else
        echo -e "  Boot: ${YELLOW}Disabled${NC}"
    fi
    
    # WireGuard status
    if ip link show $INTERFACE &> /dev/null; then
        echo -e "\n${YELLOW}Interface Details:${NC}"
        wg show $INTERFACE
        
        echo -e "\n${YELLOW}IP Address:${NC}"
        ip addr show $INTERFACE | grep -E "inet |inet6 " | awk '{print "  " $1 " " $2}'
        
        echo -e "\n${YELLOW}Routing:${NC}"
        ip route show dev $INTERFACE | head -5 | awk '{print "  " $0}'
    else
        echo -e "\n${YELLOW}Interface $INTERFACE is not active${NC}"
    fi
}

# Function to enable VPN on boot
enable_vpn() {
    echo -e "${YELLOW}Enabling WireGuard VPN ($INTERFACE) on boot...${NC}"
    systemctl enable wg-quick@$INTERFACE
    echo -e "${GREEN}✓ VPN will start automatically on boot${NC}"
}

# Function to disable VPN on boot
disable_vpn() {
    echo -e "${YELLOW}Disabling WireGuard VPN ($INTERFACE) from boot...${NC}"
    systemctl disable wg-quick@$INTERFACE
    echo -e "${GREEN}✓ VPN will not start automatically on boot${NC}"
}

# Main logic
case "$1" in
    start)
        start_vpn
        ;;
    stop)
        stop_vpn
        ;;
    restart)
        restart_vpn
        ;;
    status)
        show_status
        ;;
    enable)
        enable_vpn
        ;;
    disable)
        disable_vpn
        ;;
    *)
        usage
        ;;
esac

exit 0
