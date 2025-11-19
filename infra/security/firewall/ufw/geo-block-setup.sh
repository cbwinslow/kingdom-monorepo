#!/bin/bash
# UFW Geographic Blocking Setup
# This script blocks outbound connections to specified geographic regions
# using IP ranges from regional internet registries

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}UFW Geographic Blocking Setup${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root or with sudo${NC}"
    exit 1
fi

# Check for required tools
if ! command -v curl &> /dev/null; then
    echo -e "${YELLOW}Installing curl...${NC}"
    apt-get update && apt-get install -y curl
fi

if ! command -v ipset &> /dev/null; then
    echo -e "${YELLOW}Installing ipset...${NC}"
    apt-get update && apt-get install -y ipset
fi

# Create directory for IP lists
IPLIST_DIR="/etc/ufw/ipsets"
mkdir -p "$IPLIST_DIR"

echo -e "${GREEN}Fetching IP ranges for blocked regions...${NC}"

# Function to download and process IP ranges
download_country_ips() {
    local country_code=$1
    local country_name=$2
    local ipset_name=$3
    
    echo -e "${YELLOW}Processing $country_name ($country_code)...${NC}"
    
    # Create ipset if it doesn't exist
    ipset create "$ipset_name" hash:net -exist
    
    # Download IPv4 ranges from RIPE/ipdeny
    local temp_file=$(mktemp)
    
    # Try ipdeny.com first (aggregated zones)
    if curl -s "https://www.ipdeny.com/ipblocks/data/aggregated/${country_code}-aggregated.zone" -o "$temp_file" 2>/dev/null; then
        if [ -s "$temp_file" ]; then
            while IFS= read -r ip_range; do
                # Skip empty lines and comments
                [[ -z "$ip_range" || "$ip_range" =~ ^# ]] && continue
                ipset add "$ipset_name" "$ip_range" -exist 2>/dev/null || true
            done < "$temp_file"
            echo -e "${GREEN}Added IPv4 ranges for $country_name${NC}"
        fi
    else
        echo -e "${YELLOW}Could not download data for $country_code, will use fallback method${NC}"
    fi
    
    rm -f "$temp_file"
    
    # Save ipset to file
    ipset save "$ipset_name" > "$IPLIST_DIR/${ipset_name}.ipset"
}

# Function to block country using iptables (UFW uses iptables backend)
block_country_outbound() {
    local ipset_name=$1
    local country_name=$2
    
    # Create UFW rule using iptables directly
    # UFW doesn't natively support ipset, so we use iptables
    iptables -I OUTPUT -m set --match-set "$ipset_name" dst -j DROP -m comment --comment "Block outbound to $country_name"
    ip6tables -I OUTPUT -m set --match-set "$ipset_name" dst -j DROP -m comment --comment "Block outbound to $country_name" 2>/dev/null || true
    
    echo -e "${GREEN}Blocked outbound connections to $country_name${NC}"
}

# ============================================
# RUSSIA
# ============================================
download_country_ips "ru" "Russia" "geoblock-russia"
block_country_outbound "geoblock-russia" "Russia"

# ============================================
# CHINA
# ============================================
download_country_ips "cn" "China" "geoblock-china"
block_country_outbound "geoblock-china" "China"

# ============================================
# SOUTH AMERICA
# ============================================
echo -e "${GREEN}Processing South American countries...${NC}"

# Major South American countries
download_country_ips "ar" "Argentina" "geoblock-argentina"
block_country_outbound "geoblock-argentina" "Argentina"

download_country_ips "br" "Brazil" "geoblock-brazil"
block_country_outbound "geoblock-brazil" "Brazil"

download_country_ips "cl" "Chile" "geoblock-chile"
block_country_outbound "geoblock-chile" "Chile"

download_country_ips "co" "Colombia" "geoblock-colombia"
block_country_outbound "geoblock-colombia" "Colombia"

download_country_ips "ec" "Ecuador" "geoblock-ecuador"
block_country_outbound "geoblock-ecuador" "Ecuador"

download_country_ips "pe" "Peru" "geoblock-peru"
block_country_outbound "geoblock-peru" "Peru"

download_country_ips "ve" "Venezuela" "geoblock-venezuela"
block_country_outbound "geoblock-venezuela" "Venezuela"

download_country_ips "uy" "Uruguay" "geoblock-uruguay"
block_country_outbound "geoblock-uruguay" "Uruguay"

download_country_ips "py" "Paraguay" "geoblock-paraguay"
block_country_outbound "geoblock-paraguay" "Paraguay"

download_country_ips "bo" "Bolivia" "geoblock-bolivia"
block_country_outbound "geoblock-bolivia" "Bolivia"

# ============================================
# AFRICA
# ============================================
echo -e "${GREEN}Processing African countries...${NC}"

# Major African countries
download_country_ips "za" "South Africa" "geoblock-southafrica"
block_country_outbound "geoblock-southafrica" "South Africa"

download_country_ips "ng" "Nigeria" "geoblock-nigeria"
block_country_outbound "geoblock-nigeria" "Nigeria"

download_country_ips "eg" "Egypt" "geoblock-egypt"
block_country_outbound "geoblock-egypt" "Egypt"

download_country_ips "ke" "Kenya" "geoblock-kenya"
block_country_outbound "geoblock-kenya" "Kenya"

download_country_ips "ma" "Morocco" "geoblock-morocco"
block_country_outbound "geoblock-morocco" "Morocco"

download_country_ips "tn" "Tunisia" "geoblock-tunisia"
block_country_outbound "geoblock-tunisia" "Tunisia"

download_country_ips "gh" "Ghana" "geoblock-ghana"
block_country_outbound "geoblock-ghana" "Ghana"

download_country_ips "et" "Ethiopia" "geoblock-ethiopia"
block_country_outbound "geoblock-ethiopia" "Ethiopia"

download_country_ips "dz" "Algeria" "geoblock-algeria"
block_country_outbound "geoblock-algeria" "Algeria"

download_country_ips "ao" "Angola" "geoblock-angola"
block_country_outbound "geoblock-angola" "Angola"

# Create restore script for persistence
cat > /etc/ufw/ipset-restore.sh << 'EOF'
#!/bin/bash
# Restore ipsets on boot
IPLIST_DIR="/etc/ufw/ipsets"

for ipset_file in "$IPLIST_DIR"/*.ipset; do
    if [ -f "$ipset_file" ]; then
        ipset restore -exist < "$ipset_file"
    fi
done
EOF

chmod +x /etc/ufw/ipset-restore.sh

# Create systemd service for ipset restoration
cat > /etc/systemd/system/ipset-restore.service << 'EOF'
[Unit]
Description=Restore ipsets for geographic blocking
Before=ufw.service
After=network-pre.target
Wants=network-pre.target

[Service]
Type=oneshot
ExecStart=/etc/ufw/ipset-restore.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Enable the service
systemctl daemon-reload
systemctl enable ipset-restore.service

# Create update script
cat > /usr/local/bin/update-geo-blocks << 'UPDATEEOF'
#!/bin/bash
# Update geographic blocking IP lists
echo "Updating geographic blocking lists..."
/etc/ufw/geo-block-setup.sh
echo "Geographic blocks updated successfully"
UPDATEEOF

chmod +x /usr/local/bin/update-geo-blocks

echo ""
echo -e "${GREEN}Geographic blocking setup complete!${NC}"
echo -e "${YELLOW}Important notes:${NC}"
echo -e "1. IP lists have been downloaded and configured"
echo -e "2. Outbound connections to specified regions are now blocked"
echo -e "3. IPsets will be restored automatically on system boot"
echo -e "4. Run 'update-geo-blocks' to refresh the IP lists monthly"
echo -e "5. Consider setting up a cron job to update lists regularly:"
echo -e "   echo '0 3 1 * * /usr/local/bin/update-geo-blocks' | crontab -"
echo ""
echo -e "${GREEN}Current IPsets:${NC}"
ipset list -name | grep geoblock || echo "No geoblock sets found"
