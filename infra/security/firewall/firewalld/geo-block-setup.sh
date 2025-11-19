#!/bin/bash
# Firewalld Geographic Blocking Setup
# This script blocks outbound connections to specified geographic regions
# using ipsets and firewalld rich rules

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Firewalld Geographic Blocking Setup${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root or with sudo${NC}"
    exit 1
fi

# Check for required tools
if ! command -v firewall-cmd &> /dev/null; then
    echo -e "${RED}Firewalld not found. Please run setup-firewalld.sh first${NC}"
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo -e "${YELLOW}Installing curl...${NC}"
    if command -v dnf &> /dev/null; then
        dnf install -y curl
    elif command -v yum &> /dev/null; then
        yum install -y curl
    elif command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y curl
    fi
fi

if ! command -v ipset &> /dev/null; then
    echo -e "${YELLOW}Installing ipset...${NC}"
    if command -v dnf &> /dev/null; then
        dnf install -y ipset
    elif command -v yum &> /dev/null; then
        yum install -y ipset
    elif command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y ipset
    fi
fi

# Create directory for IP lists
IPLIST_DIR="/etc/firewalld/ipsets"
mkdir -p "$IPLIST_DIR"

echo -e "${GREEN}Fetching IP ranges for blocked regions...${NC}"

# Function to create firewalld ipset XML file
create_firewalld_ipset() {
    local ipset_name=$1
    local country_name=$2
    
    cat > "$IPLIST_DIR/${ipset_name}.xml" << EOF
<?xml version="1.0" encoding="utf-8"?>
<ipset type="hash:net">
  <short>${ipset_name}</short>
  <description>IP ranges for ${country_name} - Geographic blocking</description>
</ipset>
EOF
}

# Function to download and process IP ranges
download_country_ips() {
    local country_code=$1
    local country_name=$2
    local ipset_name=$3
    
    echo -e "${YELLOW}Processing $country_name ($country_code)...${NC}"
    
    # Create firewalld ipset XML
    create_firewalld_ipset "$ipset_name" "$country_name"
    
    # Create ipset for immediate use
    ipset create "$ipset_name" hash:net -exist 2>/dev/null || ipset flush "$ipset_name"
    
    # Download IPv4 ranges from ipdeny
    local temp_file=$(mktemp)
    
    if curl -s "https://www.ipdeny.com/ipblocks/data/aggregated/${country_code}-aggregated.zone" -o "$temp_file" 2>/dev/null; then
        if [ -s "$temp_file" ]; then
            local count=0
            while IFS= read -r ip_range; do
                # Skip empty lines and comments
                [[ -z "$ip_range" || "$ip_range" =~ ^# ]] && continue
                
                # Add to ipset
                ipset add "$ipset_name" "$ip_range" -exist 2>/dev/null || true
                
                # Add to firewalld ipset XML (entries section)
                if [ $count -eq 0 ]; then
                    # Add entries section after description
                    sed -i '/<\/description>/a\  <entry>'"$ip_range"'</entry>' "$IPLIST_DIR/${ipset_name}.xml"
                else
                    sed -i '/<\/description>/a\  <entry>'"$ip_range"'</entry>' "$IPLIST_DIR/${ipset_name}.xml"
                fi
                ((count++))
            done < "$temp_file"
            
            echo -e "${GREEN}Added $count IPv4 ranges for $country_name${NC}"
        else
            echo -e "${YELLOW}No data downloaded for $country_code${NC}"
        fi
    else
        echo -e "${YELLOW}Could not download data for $country_code${NC}"
    fi
    
    rm -f "$temp_file"
    
    # Save ipset
    ipset save "$ipset_name" > "$IPLIST_DIR/${ipset_name}.ipset" 2>/dev/null || true
}

# Function to block country using firewalld
block_country_outbound() {
    local ipset_name=$1
    local country_name=$2
    
    # Add ipset to firewalld (permanent)
    firewall-cmd --permanent --new-ipset="$ipset_name" --type=hash:net 2>/dev/null || true
    
    # Load entries from file
    local temp_entries=$(mktemp)
    ipset list "$ipset_name" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' > "$temp_entries" || true
    
    while IFS= read -r entry; do
        firewall-cmd --permanent --ipset="$ipset_name" --add-entry="$entry" 2>/dev/null || true
    done < "$temp_entries"
    
    rm -f "$temp_entries"
    
    # Create rich rule to drop outbound traffic to this ipset
    firewall-cmd --permanent --add-rich-rule="rule family='ipv4' destination ipset='$ipset_name' drop" 2>/dev/null || true
    
    # Apply immediately using direct rule
    firewall-cmd --direct --add-rule ipv4 filter OUTBOUND_FILTER 10 -m set --match-set "$ipset_name" dst -j DROP 2>/dev/null || true
    firewall-cmd --permanent --direct --add-rule ipv4 filter OUTBOUND_FILTER 10 -m set --match-set "$ipset_name" dst -j DROP 2>/dev/null || true
    
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

download_country_ips "sr" "Suriname" "geoblock-suriname"
block_country_outbound "geoblock-suriname" "Suriname"

download_country_ips "gy" "Guyana" "geoblock-guyana"
block_country_outbound "geoblock-guyana" "Guyana"

# ============================================
# AFRICA
# ============================================
echo -e "${GREEN}Processing African countries...${NC}"

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

download_country_ips "ug" "Uganda" "geoblock-uganda"
block_country_outbound "geoblock-uganda" "Uganda"

download_country_ips "tz" "Tanzania" "geoblock-tanzania"
block_country_outbound "geoblock-tanzania" "Tanzania"

download_country_ips "cm" "Cameroon" "geoblock-cameroon"
block_country_outbound "geoblock-cameroon" "Cameroon"

download_country_ips "ci" "Ivory Coast" "geoblock-ivorycoast"
block_country_outbound "geoblock-ivorycoast" "Ivory Coast"

download_country_ips "sn" "Senegal" "geoblock-senegal"
block_country_outbound "geoblock-senegal" "Senegal"

download_country_ips "zm" "Zambia" "geoblock-zambia"
block_country_outbound "geoblock-zambia" "Zambia"

download_country_ips "zw" "Zimbabwe" "geoblock-zimbabwe"
block_country_outbound "geoblock-zimbabwe" "Zimbabwe"

download_country_ips "ly" "Libya" "geoblock-libya"
block_country_outbound "geoblock-libya" "Libya"

# Create restore script for persistence
cat > /etc/firewalld/ipset-restore.sh << 'EOF'
#!/bin/bash
# Restore ipsets on boot for firewalld
IPLIST_DIR="/etc/firewalld/ipsets"

for ipset_file in "$IPLIST_DIR"/*.ipset; do
    if [ -f "$ipset_file" ]; then
        ipset restore -exist < "$ipset_file"
    fi
done
EOF

chmod +x /etc/firewalld/ipset-restore.sh

# Create systemd service for ipset restoration
cat > /etc/systemd/system/firewalld-ipset-restore.service << 'EOF'
[Unit]
Description=Restore ipsets for firewalld geographic blocking
Before=firewalld.service
After=network-pre.target
Wants=network-pre.target

[Service]
Type=oneshot
ExecStart=/etc/firewalld/ipset-restore.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Enable the service
systemctl daemon-reload
systemctl enable firewalld-ipset-restore.service

# Reload firewalld
echo -e "${GREEN}Reloading firewalld...${NC}"
firewall-cmd --reload

# Create update script
cat > /usr/local/bin/update-firewalld-geo-blocks << 'UPDATEEOF'
#!/bin/bash
# Update firewalld geographic blocking IP lists
echo "Updating geographic blocking lists for firewalld..."
cd /etc/firewalld && bash geo-block-setup.sh
echo "Geographic blocks updated successfully"
UPDATEEOF

chmod +x /usr/local/bin/update-firewalld-geo-blocks

echo ""
echo -e "${GREEN}Geographic blocking setup complete!${NC}"
echo -e "${YELLOW}Important notes:${NC}"
echo -e "1. IP lists have been downloaded and configured"
echo -e "2. Outbound connections to specified regions are now blocked"
echo -e "3. IPsets will be restored automatically on system boot"
echo -e "4. Run 'update-firewalld-geo-blocks' to refresh the IP lists monthly"
echo -e "5. Consider setting up a cron job to update lists regularly:"
echo -e "   echo '0 3 1 * * /usr/local/bin/update-firewalld-geo-blocks' | crontab -"
echo ""
echo -e "${GREEN}Current IPsets:${NC}"
ipset list -name | grep geoblock || echo "No geoblock sets found"
echo ""
echo -e "${GREEN}Firewalld direct rules:${NC}"
firewall-cmd --direct --get-all-rules | grep geoblock || echo "Direct rules applied"
