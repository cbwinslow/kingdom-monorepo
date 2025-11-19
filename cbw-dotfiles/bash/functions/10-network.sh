#!/usr/bin/env bash
# Network and Connectivity Tools

# Ping with timestamp
ping_ts() {
    ping "$1" | while read line; do echo "$(date): $line"; done
}

# Ping until success
ping_until() {
    while ! ping -c 1 "$1" &> /dev/null; do
        echo "Waiting for $1..."
        sleep 1
    done
    echo "$1 is reachable!"
}

# Check if host is up
is_up() {
    ping -c 1 "$1" &> /dev/null && echo "$1 is up" || echo "$1 is down"
}

# Port scan
portscan() {
    local host="$1"
    local start="${2:-1}"
    local end="${3:-1000}"
    for port in $(seq "$start" "$end"); do
        timeout 1 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null && echo "Port $port is open"
    done
}

# Check specific port
check_port_open() {
    timeout 1 bash -c "echo >/dev/tcp/$1/$2" 2>/dev/null && echo "Port $2 is open on $1" || echo "Port $2 is closed on $1"
}

# Get HTTP headers
http_headers() {
    curl -I "$1"
}

# Get HTTP response time
http_time() {
    curl -w "@-" -o /dev/null -s "$1" << 'EOF'
    time_namelookup:  %{time_namelookup}\n
       time_connect:  %{time_connect}\n
    time_appconnect:  %{time_appconnect}\n
   time_pretransfer:  %{time_pretransfer}\n
      time_redirect:  %{time_redirect}\n
 time_starttransfer:  %{time_starttransfer}\n
                    ----------\n
         time_total:  %{time_total}\n
EOF
}

# Download speed test
download_speed() {
    curl -o /dev/null https://speed.hetzner.de/100MB.bin 2>&1 | grep -oP '\d+[kMG]'
}

# Check SSL certificate
ssl_cert() {
    echo | openssl s_client -servername "$1" -connect "$1":443 2>/dev/null | openssl x509 -noout -dates
}

# SSL expiry
ssl_expiry() {
    echo | openssl s_client -servername "$1" -connect "$1":443 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2
}

# Whois lookup
whois_lookup() {
    whois "$1"
}

# Reverse DNS lookup
reverse_dns() {
    dig -x "$1" +short
}

# Get all DNS records
dns_all() {
    dig "$1" ANY +noall +answer
}

# DNS propagation check
dns_check() {
    local domain="$1"
    echo "Checking DNS propagation for $domain"
    for server in 8.8.8.8 8.8.4.4 1.1.1.1 1.0.0.1; do
        echo "Server $server:"
        dig @"$server" "$domain" +short
    done
}

# Get MX records
mx_records() {
    dig "$1" MX +short
}

# Get TXT records
txt_records() {
    dig "$1" TXT +short
}

# Get NS records
ns_records() {
    dig "$1" NS +short
}

# Get A records
a_records() {
    dig "$1" A +short
}

# Get AAAA records
aaaa_records() {
    dig "$1" AAAA +short
}

# Get CNAME records
cname_records() {
    dig "$1" CNAME +short
}

# Traceroute with timestamps
trace_ts() {
    traceroute "$1" | while read line; do echo "$(date): $line"; done
}

# MTR (My Traceroute)
mtr_run() {
    mtr -c 10 "$1"
}

# Network interfaces
net_interfaces() {
    ip addr show 2>/dev/null || ifconfig
}

# Active connections
net_active() {
    netstat -ant | grep ESTABLISHED
}

# Connection count
conn_count() {
    netstat -an | grep ESTABLISHED | wc -l
}

# Listening services
net_listening() {
    netstat -tulpn 2>/dev/null | grep LISTEN
}

# Network statistics
net_stats() {
    netstat -s
}

# Bandwidth monitor
bandwidth_monitor() {
    iftop -t -s 5 2>/dev/null || echo "Install iftop for bandwidth monitoring"
}

# Get gateway
gateway() {
    ip route | grep default | awk '{print $3}'
}

# Get DNS servers
dns_servers() {
    cat /etc/resolv.conf | grep nameserver | awk '{print $2}'
}

# Flush DNS cache
flush_dns() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sudo dscacheutil -flushcache
        sudo killall -HUP mDNSResponder
    else
        sudo systemd-resolve --flush-caches 2>/dev/null || sudo /etc/init.d/nscd restart
    fi
    echo "DNS cache flushed"
}

# Get subnet mask
subnet_mask() {
    ifconfig "$1" | grep netmask | awk '{print $4}'
}

# Get MAC address
mac_address() {
    ifconfig "$1" | grep ether | awk '{print $2}'
}

# Network speed test
speedtest() {
    if command -v speedtest-cli > /dev/null; then
        speedtest-cli
    else
        echo "Install speedtest-cli"
    fi
}

# Wake on LAN
wake() {
    wakeonlan "$1"
}

# ARP scan
arp_scan() {
    arp -a
}

# Network quality test
net_quality() {
    ping -c 100 "$1" | tail -1 | awk '{print $4}' | cut -d'/' -f2
}

# Jitter test
jitter_test() {
    ping -c 50 "$1" | grep time= | awk '{print $7}' | cut -d'=' -f2 | sort -n | awk '{a[i++]=$1} END {print (a[int(i*0.95)]-a[int(i*0.05)])}'
}

# Packet loss test
packet_loss() {
    ping -c 100 "$1" | grep 'packet loss' | awk '{print $6}'
}

# Get external IP
external_ip() {
    curl -s https://api.ipify.org
}

# Get IPv6
external_ipv6() {
    curl -s https://api6.ipify.org
}

# Get IP info
ip_info() {
    curl -s "https://ipinfo.io/$1"
}

# Geolocation
geo_ip() {
    curl -s "https://ipapi.co/$1/json/" | python3 -m json.tool
}

# HTTP benchmark
http_bench() {
    ab -n 1000 -c 10 "$1"
}

# TCP dump
tcp_dump() {
    sudo tcpdump -i any -n host "$1"
}

# Monitor network traffic
net_traffic() {
    sudo tcpdump -i any -n
}

# Capture packets
capture_packets() {
    sudo tcpdump -i "$1" -w capture.pcap
}

# Network reset (macOS)
net_reset() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sudo ifconfig en0 down && sudo ifconfig en0 up
    else
        sudo systemctl restart NetworkManager
    fi
}

# WiFi networks
wifi_list() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s
    else
        nmcli device wifi list
    fi
}

# Connect to WiFi
wifi_connect() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        networksetup -setairportnetwork en0 "$1" "$2"
    else
        nmcli device wifi connect "$1" password "$2"
    fi
}

# Show current WiFi
wifi_current() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I
    else
        nmcli device show | grep GENERAL.CONNECTION
    fi
}

# WiFi signal strength
wifi_signal() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep agrCtlRSSI | awk '{print $2}'
    else
        nmcli device wifi | grep '^*' | awk '{print $7}'
    fi
}

# Network routes
net_routes() {
    netstat -rn
}

# Add route
add_route() {
    sudo route add "$1" "$2"
}

# Delete route
del_route() {
    sudo route delete "$1"
}

# Firewall status
firewall_status() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
    else
        sudo ufw status
    fi
}

# Block IP
block_ip() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "block drop from $1 to any" | sudo pfctl -ef -
    else
        sudo ufw deny from "$1"
    fi
}

# Unblock IP
unblock_ip() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sudo pfctl -F all
    else
        sudo ufw delete deny from "$1"
    fi
}

# Test internet connectivity
internet_test() {
    if ping -c 1 8.8.8.8 &> /dev/null; then
        echo "Internet is working"
    else
        echo "No internet connection"
    fi
}

# Get latency
latency() {
    ping -c 10 "$1" | tail -1 | awk '{print $4}' | cut -d'/' -f2
}

# Monitor specific host
monitor_host() {
    watch -n 1 "ping -c 1 $1 | grep time="
}

# Network interfaces up
interfaces_up() {
    ip link show | grep UP | cut -d: -f2 | xargs
}

# Network interfaces down
interfaces_down() {
    ip link show | grep DOWN | cut -d: -f2 | xargs
}

# Interface up
interface_up() {
    sudo ip link set "$1" up
}

# Interface down
interface_down() {
    sudo ip link set "$1" down
}

# Get network mask
netmask() {
    ifconfig "$1" | grep netmask | awk '{print $4}'
}

# Get broadcast address
broadcast() {
    ifconfig "$1" | grep broadcast | awk '{print $6}'
}

# HTTP status code
http_status_check() {
    curl -s -o /dev/null -w "%{http_code}" "$1"
}

# Batch ping
batch_ping() {
    for ip in "$@"; do
        ping -c 1 "$ip" &> /dev/null && echo "$ip is up" || echo "$ip is down"
    done
}

# URL availability
url_available() {
    if curl -s --head "$1" | head -n 1 | grep "HTTP/1.[01] [23].." > /dev/null; then
        echo "$1 is available"
    else
        echo "$1 is not available"
    fi
}
