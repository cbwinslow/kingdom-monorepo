# Wazuh Server-Agent Setup

Complete guide for deploying Wazuh SIEM/XDR platform with server and agent architecture.

## Architecture

```
┌─────────────────────┐
│  Wazuh Manager      │  Port 1514 (agent communication)
│  (Central Server)   │  Port 1515 (agent enrollment)
│  + Elasticsearch    │  Port 443/9200 (API/Elasticsearch)
│  + Kibana          │  Port 5601 (Web UI)
└─────────────────────┘
          │
          │ Agents report to manager
          │
    ┌─────┴─────┬─────────┬──────────┐
    │           │         │          │
┌───┴───┐  ┌────┴───┐ ┌───┴────┐ ┌──┴─────┐
│Agent 1│  │Agent 2 │ │Agent 3 │ │Agent N │
│Linux  │  │Windows │ │MacOS   │ │Docker  │
└───────┘  └────────┘ └────────┘ └────────┘
```

## Server Installation

### Method 1: Docker Compose (Recommended)

Create `wazuh/docker-compose.yml`:

```yaml
version: '3.8'

services:
  wazuh.manager:
    image: wazuh/wazuh-manager:4.7.0
    hostname: wazuh-manager
    restart: always
    ports:
      - "1514:1514"
      - "1515:1515"
      - "514:514/udp"
      - "55000:55000"
    environment:
      - INDEXER_URL=https://wazuh.indexer:9200
      - INDEXER_USERNAME=admin
      - INDEXER_PASSWORD=SecretPassword
      - FILEBEAT_SSL_VERIFICATION_MODE=full
      - SSL_CERTIFICATE_AUTHORITIES=/etc/ssl/root-ca.pem
      - SSL_CERTIFICATE=/etc/ssl/filebeat.pem
      - SSL_KEY=/etc/ssl/filebeat.key
    volumes:
      - wazuh_api_configuration:/var/ossec/api/configuration
      - wazuh_etc:/var/ossec/etc
      - wazuh_logs:/var/ossec/logs
      - wazuh_queue:/var/ossec/queue
      - wazuh_var_multigroups:/var/ossec/var/multigroups
      - wazuh_integrations:/var/ossec/integrations
      - wazuh_active_response:/var/ossec/active-response/bin
      - wazuh_agentless:/var/ossec/agentless
      - wazuh_wodles:/var/ossec/wodles
      - filebeat_etc:/etc/filebeat
      - filebeat_var:/var/lib/filebeat

  wazuh.indexer:
    image: wazuh/wazuh-indexer:4.7.0
    hostname: wazuh-indexer
    restart: always
    ports:
      - "9200:9200"
    environment:
      - "OPENSEARCH_JAVA_OPTS=-Xms1g -Xmx1g"
      - "bootstrap.memory_lock=true"
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 65536
        hard: 65536
    volumes:
      - wazuh-indexer-data:/var/lib/wazuh-indexer

  wazuh.dashboard:
    image: wazuh/wazuh-dashboard:4.7.0
    hostname: wazuh-dashboard
    restart: always
    ports:
      - "443:5601"
    environment:
      - INDEXER_USERNAME=admin
      - INDEXER_PASSWORD=SecretPassword
      - WAZUH_API_URL=https://wazuh.manager
      - DASHBOARD_USERNAME=kibanaserver
      - DASHBOARD_PASSWORD=kibanaserver
      - API_USERNAME=wazuh-wui
      - API_PASSWORD=MyS3cr37P450r.*-
    volumes:
      - wazuh-dashboard-config:/usr/share/wazuh-dashboard/data/wazuh/config
      - wazuh-dashboard-custom:/usr/share/wazuh-dashboard/plugins/wazuh/public/assets/custom
    depends_on:
      - wazuh.indexer
      - wazuh.manager

volumes:
  wazuh_api_configuration:
  wazuh_etc:
  wazuh_logs:
  wazuh_queue:
  wazuh_var_multigroups:
  wazuh_integrations:
  wazuh_active_response:
  wazuh_agentless:
  wazuh_wodles:
  filebeat_etc:
  filebeat_var:
  wazuh-indexer-data:
  wazuh-dashboard-config:
  wazuh-dashboard-custom:
```

Start the server:
```bash
docker-compose up -d
```

### Method 2: Bare Metal Installation

```bash
# Install Wazuh repository
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list

# Update and install
apt-get update
apt-get install wazuh-manager

# Start service
systemctl daemon-reload
systemctl enable wazuh-manager
systemctl start wazuh-manager
```

## Agent Installation

### Linux Agent

```bash
# Download and install
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list

apt-get update
apt-get install wazuh-agent

# Configure manager address
echo "WAZUH_MANAGER='192.168.1.100'" > /var/ossec/etc/ossec.conf

# Start agent
systemctl daemon-reload
systemctl enable wazuh-agent
systemctl start wazuh-agent
```

### Windows Agent

1. Download installer from: https://packages.wazuh.com/4.x/windows/wazuh-agent-4.7.0-1.msi

2. Install with PowerShell:
```powershell
.\wazuh-agent-4.7.0-1.msi /q WAZUH_MANAGER="192.168.1.100"
```

3. Start service:
```powershell
NET START WazuhSvc
```

### Docker Container Agent

```yaml
version: '3.8'

services:
  wazuh-agent:
    image: wazuh/wazuh-agent:4.7.0
    hostname: docker-host-01
    environment:
      - WAZUH_MANAGER=192.168.1.100
      - WAZUH_AGENT_NAME=docker-host-01
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /:/rootfs:ro
```

## Agent Registration

### On Wazuh Manager

```bash
# Register agent
/var/ossec/bin/manage_agents -a -n agent-name -i 001

# Extract agent key
/var/ossec/bin/manage_agents -e 001

# Restart manager
systemctl restart wazuh-manager
```

### On Agent

```bash
# Import key
/var/ossec/bin/manage_agents -i <key>

# Restart agent
systemctl restart wazuh-agent

# Check status
systemctl status wazuh-agent
/var/ossec/bin/agent_control -l
```

## Configuration

### Server Configuration (`/var/ossec/etc/ossec.conf`)

```xml
<ossec_config>
  <global>
    <jsonout_output>yes</jsonout_output>
    <alerts_log>yes</alerts_log>
    <logall>no</logall>
    <logall_json>no</logall_json>
    <email_notification>no</email_notification>
  </global>

  <remote>
    <connection>secure</connection>
    <port>1514</port>
    <protocol>tcp</protocol>
  </remote>

  <alerts>
    <log_alert_level>3</log_alert_level>
    <email_alert_level>12</email_alert_level>
  </alerts>

  <!-- File Integrity Monitoring -->
  <syscheck>
    <disabled>no</disabled>
    <frequency>43200</frequency>
    <scan_on_start>yes</scan_on_start>
    <directories check_all="yes">/etc,/usr/bin,/usr/sbin</directories>
    <directories check_all="yes">/bin,/sbin</directories>
  </syscheck>

  <!-- Rootkit Detection -->
  <rootcheck>
    <disabled>no</disabled>
    <check_files>yes</check_files>
    <check_trojans>yes</check_trojans>
    <check_dev>yes</check_dev>
    <check_sys>yes</check_sys>
    <check_pids>yes</check_pids>
    <check_ports>yes</check_ports>
    <check_if>yes</check_if>
  </rootcheck>
</ossec_config>
```

### Agent Configuration (`/var/ossec/etc/ossec.conf`)

```xml
<ossec_config>
  <client>
    <server>
      <address>192.168.1.100</address>
      <port>1514</port>
      <protocol>tcp</protocol>
    </server>
    <notify_time>10</notify_time>
    <time-reconnect>60</time-reconnect>
  </client>

  <!-- Log Files to Monitor -->
  <localfile>
    <log_format>syslog</log_format>
    <location>/var/log/auth.log</location>
  </localfile>

  <localfile>
    <log_format>syslog</log_format>
    <location>/var/log/syslog</location>
  </localfile>

  <localfile>
    <log_format>apache</log_format>
    <location>/var/log/apache2/access.log</location>
  </localfile>
</ossec_config>
```

## Firewall Configuration

### On Server
```bash
# Allow agent connections
ufw allow 1514/tcp
ufw allow 1515/tcp
ufw allow 514/udp

# Allow web interface
ufw allow 443/tcp
ufw allow 5601/tcp
```

### On Agents
```bash
# Allow outbound to manager
ufw allow out to 192.168.1.100 port 1514
```

## Verification

### Check Server Status
```bash
systemctl status wazuh-manager
/var/ossec/bin/wazuh-control status
```

### List Connected Agents
```bash
/var/ossec/bin/agent_control -l
/var/ossec/bin/agent_control -i 001
```

### View Logs
```bash
tail -f /var/ossec/logs/ossec.log
tail -f /var/ossec/logs/alerts/alerts.log
```

### Web Interface
Access: https://server-ip:5601
- Username: admin
- Password: admin (change immediately)

## Common Use Cases

### Monitor Docker Containers
```xml
<localfile>
  <log_format>json</log_format>
  <location>/var/lib/docker/containers/*/*.log</location>
</localfile>
```

### Monitor Failed SSH Attempts
```xml
<localfile>
  <log_format>syslog</log_format>
  <location>/var/log/auth.log</location>
</localfile>
```

### Custom Rules
Create `/var/ossec/etc/rules/local_rules.xml`:
```xml
<group name="custom,">
  <rule id="100001" level="5">
    <if_sid>5716</if_sid>
    <srcip>!192.168.1.0/24</srcip>
    <description>SSH authentication from outside local network</description>
  </rule>
</group>
```

## Troubleshooting

### Agent not connecting
1. Check firewall rules
2. Verify manager IP in agent config
3. Check agent key registration
4. Review logs: `/var/ossec/logs/ossec.log`

### High CPU usage
1. Reduce scan frequency
2. Exclude directories from monitoring
3. Adjust log collection settings

### Missing alerts
1. Check alert levels
2. Verify log file permissions
3. Review configuration syntax

## Resources

- [Wazuh Documentation](https://documentation.wazuh.com/)
- [Wazuh Rules](https://documentation.wazuh.com/current/user-manual/ruleset/index.html)
- [Community](https://groups.google.com/g/wazuh)

## Security Best Practices

1. Change default passwords immediately
2. Use SSL/TLS for all connections
3. Regular updates and patches
4. Implement proper access controls
5. Monitor the monitor (meta-monitoring)
6. Regular backup of configurations
7. Network segmentation
8. Least privilege principle
