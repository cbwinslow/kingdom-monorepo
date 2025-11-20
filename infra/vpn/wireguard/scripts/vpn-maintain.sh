#!/bin/bash

# WireGuard VPN Maintenance Script
# Monitor and maintain WireGuard VPN connections

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default interface name
INTERFACE="${1:-wg0}"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: This script must be run as root (use sudo)${NC}"
   exit 1
fi

# Function to check if interface is up
is_interface_up() {
    ip link show $INTERFACE &> /dev/null
}

# Function to check if VPN has connectivity
check_vpn_connectivity() {
    # Get the endpoint from the config
    local endpoint=$(wg show $INTERFACE endpoints 2>/dev/null | awk '{print $2}' | head -1)
    
    if [ -z "$endpoint" ]; then
        return 1
    fi
    
    # Extract IP from endpoint
    local endpoint_ip=$(echo $endpoint | cut -d':' -f1)
    
    # Try to ping the endpoint
    if ping -c 1 -W 2 -I $INTERFACE $endpoint_ip &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to get handshake time
get_last_handshake() {
    wg show $INTERFACE latest-handshakes 2>/dev/null | awk '{print $2}' | head -1
}

# Function to check connection health
check_health() {
    echo -e "${BLUE}=== VPN Connection Health Check ===${NC}"
    echo ""
    
    # Check if service is running
    if ! systemctl is-active --quiet wg-quick@$INTERFACE; then
        echo -e "${RED}✗ VPN service is not running${NC}"
        return 1
    fi
    echo -e "${GREEN}✓ VPN service is running${NC}"
    
    # Check if interface exists
    if ! is_interface_up; then
        echo -e "${RED}✗ VPN interface $INTERFACE is not up${NC}"
        return 1
    fi
    echo -e "${GREEN}✓ VPN interface is up${NC}"
    
    # Check last handshake
    local last_handshake=$(get_last_handshake)
    if [ -z "$last_handshake" ]; then
        echo -e "${RED}✗ No handshake detected${NC}"
        return 1
    fi
    
    local current_time=$(date +%s)
    local time_since_handshake=$((current_time - last_handshake))
    
    if [ $time_since_handshake -gt 180 ]; then
        echo -e "${YELLOW}⚠ Last handshake was ${time_since_handshake}s ago (>3min)${NC}"
        return 1
    else
        echo -e "${GREEN}✓ Recent handshake (${time_since_handshake}s ago)${NC}"
    fi
    
    # Check peer transfer
    local rx_bytes=$(wg show $INTERFACE transfer 2>/dev/null | awk '{print $2}' | head -1)
    local tx_bytes=$(wg show $INTERFACE transfer 2>/dev/null | awk '{print $3}' | head -1)
    
    if [ ! -z "$rx_bytes" ] && [ ! -z "$tx_bytes" ]; then
        local rx_mb=$((rx_bytes / 1024 / 1024))
        local tx_mb=$((tx_bytes / 1024 / 1024))
        echo -e "${GREEN}✓ Data transfer: RX ${rx_mb}MB / TX ${tx_mb}MB${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}=== Connection is healthy ===${NC}"
    return 0
}

# Function to restart if unhealthy
auto_restart() {
    echo -e "${YELLOW}Checking VPN health...${NC}"
    
    if check_health; then
        echo -e "${GREEN}VPN is healthy, no action needed${NC}"
        return 0
    else
        echo ""
        echo -e "${YELLOW}VPN appears unhealthy, attempting restart...${NC}"
        systemctl restart wg-quick@$INTERFACE
        sleep 3
        
        if check_health; then
            echo -e "${GREEN}✓ VPN successfully restarted and healthy${NC}"
            return 0
        else
            echo -e "${RED}✗ VPN restart failed or still unhealthy${NC}"
            return 1
        fi
    fi
}

# Function to show detailed statistics
show_stats() {
    echo -e "${BLUE}=== VPN Statistics ===${NC}"
    echo ""
    
    if ! is_interface_up; then
        echo -e "${RED}VPN interface $INTERFACE is not up${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Interface: $INTERFACE${NC}"
    wg show $INTERFACE
    
    echo ""
    echo -e "${YELLOW}Network Statistics:${NC}"
    ip -s link show $INTERFACE
    
    echo ""
    echo -e "${YELLOW}Routes:${NC}"
    ip route show dev $INTERFACE
}

# Function to monitor continuously
monitor() {
    local interval="${2:-60}"
    echo -e "${BLUE}=== VPN Monitoring (checking every ${interval}s) ===${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
    echo ""
    
    while true; do
        echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC}"
        check_health
        echo ""
        sleep $interval
    done
}

# Display usage
usage() {
    echo "Usage: $0 {check|restart|stats|monitor} [interface] [interval]"
    echo ""
    echo "Commands:"
    echo "  check      - Check VPN connection health"
    echo "  restart    - Check health and restart if unhealthy"
    echo "  stats      - Show detailed VPN statistics"
    echo "  monitor    - Continuously monitor VPN health"
    echo ""
    echo "Arguments:"
    echo "  interface  - WireGuard interface name (default: wg0)"
    echo "  interval   - Monitoring interval in seconds (default: 60)"
    echo ""
    echo "Examples:"
    echo "  $0 check                    # Check default wg0 interface"
    echo "  $0 restart wg1              # Restart wg1 if unhealthy"
    echo "  $0 monitor wg0 30           # Monitor wg0 every 30 seconds"
    exit 1
}

# Main logic
case "$1" in
    check)
        check_health
        ;;
    restart)
        auto_restart
        ;;
    stats)
        show_stats
        ;;
    monitor)
        INTERFACE="${2:-wg0}"
        monitor "$INTERFACE" "${3:-60}"
        ;;
    *)
        usage
        ;;
esac

exit 0
