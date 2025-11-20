# SSH Bastion Stack

Secure SSH bastion hosts, jump servers, and remote access gateways with comprehensive logging and monitoring.

## Components

- **bastion** (port 2222) - Primary SSH bastion host
- **jump-host** (port 2223) - Secondary jump host with audit logging
- **teleport** (ports 3023-3025, 3080) - Modern SSH bastion with web UI
- **guacamole** (port 8080) - Clientless remote desktop gateway
- **guacd** - Guacamole proxy daemon
- **guacamole-db** - PostgreSQL database for Guacamole
- **audit-logger** - System audit logging with auditd
- **session-recorder** - SSH session recording
- **connection-monitor** - Real-time connection monitoring
- **fail2ban** - Intrusion prevention system
- **key-manager** - SSH key management utilities

## Quick Start

### 1. Setup Environment

Create `.env` file:

```bash
# Bastion user
BASTION_USER=bastion

# Jump host password
JUMP_ROOT_PASSWORD=changeme_secure_password

# Guacamole database
GUACAMOLE_DB_PASSWORD=guacamole_secure_password
```

### 2. Generate SSH Keys

```bash
# Create directories
mkdir -p ssh_keys/generated ssh_keys/authorized
mkdir -p config jump-host/config jump-host/logs jump-host/keys
mkdir -p teleport/config teleport/logs
mkdir -p audit/logs audit/rules
mkdir -p recordings monitor/logs fail2ban/data logs

# Generate SSH key pair
ssh-keygen -t ed25519 -f ssh_keys/generated/bastion_key -C "bastion@example.com"

# Add public key to authorized_keys
cat ssh_keys/generated/bastion_key.pub > ssh_keys/authorized/authorized_keys

# Set permissions
chmod 600 ssh_keys/generated/bastion_key ssh_keys/authorized/authorized_keys
chmod 644 ssh_keys/generated/bastion_key.pub
```

### 3. Copy Public Key

```bash
# Copy authorized_keys to config
cp ssh_keys/authorized/authorized_keys config/authorized_keys
```

### 4. Initialize Guacamole Database

Download and prepare the init script:

```bash
# Get initdb script
docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --postgres > guacamole/initdb.sql
```

### 5. Start Services

```bash
docker-compose up -d

# View logs
docker-compose logs -f bastion

# Check status
docker-compose ps
```

## Usage

### Connect to Bastion Host

```bash
# Connect with key
ssh -i ssh_keys/generated/bastion_key -p 2222 bastion@localhost

# Using SSH config
cat >> ~/.ssh/config <<EOF
Host bastion
    HostName localhost
    Port 2222
    User bastion
    IdentityFile ~/path/to/ssh_keys/generated/bastion_key
EOF

ssh bastion
```

### Using as Jump Host

```bash
# Direct connection through bastion
ssh -J bastion@localhost:2222 user@internal-server

# SSH config with ProxyJump
cat >> ~/.ssh/config <<EOF
Host internal-server
    HostName 10.0.1.100
    User admin
    ProxyJump bastion@localhost:2222
EOF

ssh internal-server
```

### Port Forwarding Through Bastion

```bash
# Local port forwarding
ssh -L 8080:internal-server:80 -p 2222 bastion@localhost

# Dynamic SOCKS proxy
ssh -D 1080 -p 2222 bastion@localhost

# Remote port forwarding
ssh -R 9090:localhost:9090 -p 2222 bastion@localhost
```

### Using Teleport

```bash
# Access web UI
open http://localhost:3080

# Connect via tsh client
tsh login --proxy=localhost:3080
tsh ssh user@host
```

### Using Guacamole

1. Access web UI: http://localhost:8080/guacamole
2. Default credentials: guacadmin/guacadmin
3. Add SSH connections in Settings → Connections

## Session Recording

### Record with asciinema

```bash
# Start recording
docker exec session-recorder asciinema rec /recordings/session-$(date +%Y%m%d-%H%M%S).cast

# View recordings
ls recordings/

# Play recording
docker exec session-recorder asciinema play /recordings/session-20240101-120000.cast
```

### Audit Logs

```bash
# View audit logs
docker-compose logs audit-logger

# Check audit log file
tail -f audit/logs/audit.log

# Search for SSH connections
grep ssh_connections audit/logs/audit.log
```

## Monitoring

### Connection Monitor

```bash
# View connection status
cat monitor/logs/connections.log

# Real-time monitoring
docker-compose logs -f connection-monitor
```

### Active Sessions

```bash
# List active SSH sessions on bastion
docker exec bastion who

# Show detailed session info
docker exec bastion w

# Last logins
docker exec bastion last
```

## Security Features

### Fail2ban

Fail2ban automatically bans IPs with too many failed login attempts:

```bash
# Check fail2ban status
docker exec ssh-fail2ban fail2ban-client status

# Check SSH jail status
docker exec ssh-fail2ban fail2ban-client status sshd

# Unban an IP
docker exec ssh-fail2ban fail2ban-client set sshd unbanip 192.168.1.100
```

### Key Management

```bash
# Generate new key pair
docker exec key-manager ssh-keygen -t ed25519 -f /keys/generated/new_key -C "comment"

# Convert key formats
docker exec key-manager ssh-keygen -p -f /keys/generated/key -m pem

# Get fingerprint
docker exec key-manager ssh-keygen -lf /keys/generated/key.pub
```

### Hardening SSH Configuration

Create `config/sshd_config`:

```conf
# Basic settings
Port 2222
Protocol 2
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no

# Security
X11Forwarding no
AllowTcpForwarding yes
PermitTunnel no
GatewayPorts no
ClientAliveInterval 300
ClientAliveCountMax 2
MaxAuthTries 3
MaxSessions 10

# Logging
SyslogFacility AUTH
LogLevel VERBOSE

# Allowed users
AllowUsers bastion

# Allowed authentication methods
AuthenticationMethods publickey

# Host keys
HostKey /config/ssh_host_ed25519_key
HostKey /config/ssh_host_rsa_key

# Ciphers and algorithms
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org
```

## Advanced Configuration

### Two-Factor Authentication

```bash
# Install Google Authenticator in bastion
docker exec bastion apk add google-authenticator

# Setup 2FA for user
docker exec -it bastion google-authenticator -t -d -f -r 3 -R 30 -w 3
```

### Certificate-Based Authentication

```bash
# Generate CA key
ssh-keygen -t ed25519 -f ca_key -C "SSH CA"

# Sign user key
ssh-keygen -s ca_key -I user_cert -n bastion -V +52w user_key.pub

# Configure bastion to trust CA
echo "TrustedUserCAKeys /config/ca_key.pub" >> config/sshd_config
```

### Jump Host Chaining

```bash
# Connect through multiple jump hosts
ssh -J bastion@localhost:2222,jump@internal-jump user@final-destination

# SSH config
Host final-destination
    HostName 10.0.2.100
    User admin
    ProxyJump bastion@localhost:2222,jump@10.0.1.50
```

## Teleport Advanced Usage

### Create Teleport User

```bash
# Access teleport container
docker exec -it ssh-teleport sh

# Create user
tctl users add admin --roles=editor,access --logins=root,admin

# List users
tctl users ls
```

### Configure Teleport Roles

```yaml
# teleport/config/roles.yaml
kind: role
version: v5
metadata:
  name: developer
spec:
  allow:
    logins: [dev, developer]
    node_labels:
      'env': 'development'
    rules:
      - resources: [session]
        verbs: [list, read]
```

## Guacamole Configuration

### Add SSH Connection

1. Login to Guacamole web UI
2. Settings → Connections → New Connection
3. Configure:
   - Name: Internal Server
   - Protocol: SSH
   - Hostname: 10.0.1.100
   - Port: 22
   - Username: admin
   - Private Key: (paste key)

### LDAP Integration

```yaml
# guacamole/extensions
environment:
  LDAP_HOSTNAME: ldap.example.com
  LDAP_PORT: 389
  LDAP_USER_BASE_DN: ou=users,dc=example,dc=com
```

## Troubleshooting

### SSH Connection Refused

```bash
# Check if bastion is running
docker-compose ps bastion

# Check logs
docker-compose logs bastion

# Test port
nc -zv localhost 2222

# Check from container
docker exec bastion netstat -tlnp | grep 2222
```

### Key Permission Issues

```bash
# Fix key permissions
chmod 600 ssh_keys/generated/*
chmod 644 ssh_keys/generated/*.pub
chmod 600 config/authorized_keys

# Verify in container
docker exec bastion ls -la /config
```

### Guacamole Connection Failed

```bash
# Check guacd
docker-compose logs guacd

# Test guacd connection
docker exec ssh-guacamole nc -zv guacd 4822

# Verify database
docker exec ssh-guacamole-db psql -U guacamole_user -d guacamole_db -c "\dt"
```

## Backup and Recovery

### Backup SSH Keys

```bash
# Backup all keys
tar czf ssh_keys_backup_$(date +%Y%m%d).tar.gz ssh_keys/

# Secure backup (encrypted)
tar czf - ssh_keys/ | gpg -c > ssh_keys_backup_$(date +%Y%m%d).tar.gz.gpg
```

### Backup Guacamole Database

```bash
docker exec ssh-guacamole-db pg_dump -U guacamole_user guacamole_db > guacamole_backup.sql
```

### Restore

```bash
# Restore SSH keys
tar xzf ssh_keys_backup_20240101.tar.gz

# Restore Guacamole database
cat guacamole_backup.sql | docker exec -i ssh-guacamole-db psql -U guacamole_user guacamole_db
```

## Best Practices

1. **Use key-based authentication** only, disable passwords
2. **Regular key rotation** (every 90 days)
3. **Monitor and audit** all SSH sessions
4. **Implement IP whitelisting** when possible
5. **Use strong ciphers** and modern algorithms
6. **Regular security updates** of all components
7. **Backup configurations** and keys regularly
8. **Use certificate-based auth** for large deployments
9. **Implement 2FA** for additional security
10. **Session recording** for compliance and auditing

## Compliance

### PCI DSS Requirements

- Multi-factor authentication (2FA)
- Session recording and audit logging
- Regular key rotation
- Access control and monitoring

### SOC 2 Requirements

- Audit trails for all access
- Encryption in transit
- Access review and approval
- Incident response procedures

## References

- [OpenSSH Documentation](https://www.openssh.com/manual.html)
- [Teleport Documentation](https://goteleport.com/docs/)
- [Apache Guacamole](https://guacamole.apache.org/doc/gug/)
- [Fail2ban Manual](https://www.fail2ban.org/wiki/index.php/MANUAL_0_8)
- [SSH Best Practices](https://www.ssh.com/academy/ssh/best-practices)
