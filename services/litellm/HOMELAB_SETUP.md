# LiteLLM Proxy - cbwdellr720 Homelab Setup Guide

This guide provides detailed instructions for deploying LiteLLM proxy on your homelab server (cbwdellr720).

## Prerequisites

- SSH access to cbwdellr720
- Docker and Docker Compose installed
- Sudo/root access for system configuration
- At least one LLM provider API key

## Initial Setup

### 1. SSH into the Server

```bash
ssh your-username@cbwdellr720
# or if using IP address
ssh your-username@192.168.1.x
```

### 2. Prepare the Installation Directory

```bash
# If repository is not cloned yet
cd ~
git clone https://github.com/cbwinslow/kingdom-monorepo.git

# Or update existing installation
cd ~/kingdom-monorepo
git pull origin main

# Navigate to LiteLLM directory
cd services/litellm
```

### 3. Run Setup Script

```bash
# Make setup script executable (if not already)
chmod +x setup.sh

# Run the interactive setup
./setup.sh
```

The setup script will:
- Check for Docker and Docker Compose
- Create `.env` file with secure credentials
- Generate random master key and passwords
- Prompt for LLM provider API keys
- Start all services

**Important:** Save the credentials displayed during setup!

### 4. Verify Installation

```bash
# Check running services
docker-compose ps

# View logs
docker-compose logs -f litellm

# Test health endpoint
curl http://localhost:4000/health
```

Expected output: `{"status": "healthy"}`

## Network Configuration

### Option A: Local Network Access Only

If you only need access from machines on the same network:

1. **Find Server IP Address:**
   ```bash
   hostname -I
   # or
   ip addr show
   ```

2. **Configure Firewall (if UFW is enabled):**
   ```bash
   # Allow port 4000 from local network
   sudo ufw allow from 192.168.1.0/24 to any port 4000
   
   # Or allow from specific IP
   sudo ufw allow from 192.168.1.100 to any port 4000
   ```

3. **Test from Another Machine:**
   ```bash
   curl http://cbwdellr720:4000/health
   # or using IP
   curl http://192.168.1.x:4000/health
   ```

### Option B: External Access with Reverse Proxy

For secure external access, set up a reverse proxy with SSL:

#### Using Nginx

1. **Install Nginx:**
   ```bash
   sudo apt update
   sudo apt install nginx
   ```

2. **Create Nginx Configuration:**
   ```bash
   sudo nano /etc/nginx/sites-available/litellm
   ```

   Add this configuration:
   ```nginx
   server {
       listen 80;
       server_name litellm.cbwdellr720.local;
       
       # Redirect HTTP to HTTPS
       return 301 https://$server_name$request_uri;
   }
   
   server {
       listen 443 ssl http2;
       server_name litellm.cbwdellr720.local;
       
       # SSL certificates (adjust paths as needed)
       ssl_certificate /etc/ssl/certs/litellm.crt;
       ssl_certificate_key /etc/ssl/private/litellm.key;
       
       # SSL configuration
       ssl_protocols TLSv1.2 TLSv1.3;
       ssl_ciphers HIGH:!aNULL:!MD5;
       ssl_prefer_server_ciphers on;
       
       # Proxy settings
       location / {
           proxy_pass http://localhost:4000;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
           proxy_cache_bypass $http_upgrade;
           
           # Timeouts for long requests
           proxy_read_timeout 600s;
           proxy_connect_timeout 600s;
           proxy_send_timeout 600s;
       }
   }
   ```

3. **Enable Configuration:**
   ```bash
   sudo ln -s /etc/nginx/sites-available/litellm /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl reload nginx
   ```

4. **Update Firewall:**
   ```bash
   sudo ufw allow 'Nginx Full'
   ```

#### Using Caddy (Simpler Alternative)

1. **Install Caddy:**
   ```bash
   sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
   curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
   curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
   sudo apt update
   sudo apt install caddy
   ```

2. **Create Caddyfile:**
   ```bash
   sudo nano /etc/caddy/Caddyfile
   ```

   Add:
   ```
   litellm.cbwdellr720.local {
       reverse_proxy localhost:4000
   }
   ```

3. **Reload Caddy:**
   ```bash
   sudo systemctl reload caddy
   ```

Caddy automatically handles SSL certificates via Let's Encrypt!

## Auto-Start on Boot

To ensure LiteLLM starts automatically when the server reboots:

### 1. Copy Systemd Service File

```bash
sudo cp litellm.service /etc/systemd/system/
```

### 2. Edit Service File

```bash
sudo nano /etc/systemd/system/litellm.service
```

Update these lines:
- `WorkingDirectory`: Set to your actual path (e.g., `/home/youruser/kingdom-monorepo/services/litellm`)
- `User`: Set to your username
- `Group`: Set to your username (usually same as user)

### 3. Enable and Start Service

```bash
# Reload systemd to recognize new service
sudo systemctl daemon-reload

# Enable service to start on boot
sudo systemctl enable litellm.service

# Start service now
sudo systemctl start litellm.service

# Check status
sudo systemctl status litellm.service
```

### 4. Service Management Commands

```bash
# Start
sudo systemctl start litellm

# Stop
sudo systemctl stop litellm

# Restart
sudo systemctl restart litellm

# View logs
sudo journalctl -u litellm -f

# Disable auto-start
sudo systemctl disable litellm
```

## Configuration Management

### Environment Variables

Edit `.env` file to update configuration:

```bash
cd ~/kingdom-monorepo/services/litellm
nano .env
```

After changes, restart:
```bash
docker-compose restart litellm
# or if using systemd
sudo systemctl restart litellm
```

### Adding More API Keys

To add additional LLM provider keys:

1. Edit `.env`:
   ```bash
   nano .env
   ```

2. Add your keys:
   ```bash
   OPENAI_API_KEY=sk-...
   ANTHROPIC_API_KEY=sk-ant-...
   GEMINI_API_KEY=...
   ```

3. Update `config.yaml` if adding new models

4. Restart services:
   ```bash
   docker-compose restart litellm
   ```

### Updating Models

Edit `config.yaml` to add or modify models:

```bash
nano config.yaml
```

After editing, restart:
```bash
docker-compose restart litellm
```

## Monitoring and Maintenance

### Viewing Logs

```bash
# Using Docker Compose
cd ~/kingdom-monorepo/services/litellm
docker-compose logs -f

# Using systemd
sudo journalctl -u litellm -f

# Last 100 lines
docker-compose logs --tail=100 litellm
```

### Accessing Web UI

From local network:
- `http://cbwdellr720:4000/ui`
- `http://192.168.1.x:4000/ui`

Login with credentials from setup (default username: `admin`)

### Database Backup

Regular backups are important:

```bash
cd ~/kingdom-monorepo/services/litellm

# Create backup
docker-compose exec -T postgres pg_dump -U litellm litellm > backup-$(date +%Y%m%d).sql

# Or use Makefile
make backup
```

### Updates

To update to the latest LiteLLM version:

```bash
cd ~/kingdom-monorepo/services/litellm

# Pull latest images
docker-compose pull

# Restart with new images
docker-compose up -d
```

### Resource Monitoring

Check resource usage:

```bash
# Overall Docker stats
docker stats

# Specific containers
docker stats litellm-proxy litellm-postgres litellm-redis
```

## Using from Client Machines

### Environment Setup

On your development machine:

```bash
# Add to ~/.bashrc or ~/.zshrc
export LITELLM_URL="http://cbwdellr720:4000"
export LITELLM_API_KEY="your-master-key-here"

# Or create a config file
cat > ~/.litellm.env << EOF
LITELLM_URL=http://cbwdellr720:4000
LITELLM_API_KEY=your-master-key-here
EOF
```

### Python Example

```python
import openai
import os

# Configure client
client = openai.OpenAI(
    api_key=os.environ['LITELLM_API_KEY'],
    base_url=os.environ['LITELLM_URL']
)

# Make request
response = client.chat.completions.create(
    model="gpt-3.5-turbo",
    messages=[{"role": "user", "content": "Hello!"}]
)

print(response.choices[0].message.content)
```

### cURL Example

```bash
curl -X POST $LITELLM_URL/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $LITELLM_API_KEY" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "Hello from cbwdellr720!"}]
  }'
```

## Troubleshooting

### Services Won't Start

```bash
# Check Docker daemon
sudo systemctl status docker

# Check container logs
docker-compose logs postgres
docker-compose logs redis
docker-compose logs litellm

# Verify .env file exists
ls -la .env

# Check port availability
sudo netstat -tlnp | grep 4000
```

### Connection Refused from Other Machines

```bash
# Verify service is listening on all interfaces
docker-compose exec litellm netstat -tlnp | grep 4000

# Check firewall
sudo ufw status

# Verify network connectivity
ping cbwdellr720

# Check if port is open
telnet cbwdellr720 4000
```

### High Resource Usage

```bash
# Check container stats
docker stats

# Adjust Docker resources if needed
# Edit docker-compose.yml to add resource limits:
services:
  litellm:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
```

### Database Issues

```bash
# Reset database (WARNING: deletes data)
docker-compose down -v
docker-compose up -d

# Check PostgreSQL logs
docker-compose logs postgres

# Access database directly
docker-compose exec postgres psql -U litellm
```

## Security Checklist

- [ ] Strong master key set (at least 32 characters)
- [ ] UI password changed from default
- [ ] Firewall rules configured
- [ ] SSL/TLS enabled for external access
- [ ] Regular database backups scheduled
- [ ] Provider API keys secured
- [ ] Network access restricted to trusted IPs
- [ ] System updates applied regularly
- [ ] Logs monitored for suspicious activity

## Advanced Configuration

### Multiple Model Instances

For load balancing across multiple API keys:

```yaml
model_list:
  - model_name: gpt-4
    litellm_params:
      model: openai/gpt-4
      api_key: os.environ/OPENAI_KEY_1
  
  - model_name: gpt-4
    litellm_params:
      model: openai/gpt-4
      api_key: os.environ/OPENAI_KEY_2
```

### Custom Domains

Add to `/etc/hosts` on client machines:

```
192.168.1.x  litellm.cbwdellr720.local
```

### Integration with Ollama

If running Ollama on cbwdellr720:

```bash
# Start Ollama
systemctl start ollama

# Verify models available
ollama list

# Update config.yaml with correct api_base
```

## Quick Reference Commands

```bash
# Start services
cd ~/kingdom-monorepo/services/litellm && docker-compose up -d

# Stop services
docker-compose down

# Restart services
docker-compose restart

# View logs
docker-compose logs -f

# Check status
docker-compose ps

# Update services
docker-compose pull && docker-compose up -d

# Backup database
make backup

# Test API
curl http://localhost:4000/health
```

## Support

For issues:
1. Check logs: `docker-compose logs -f`
2. Review this guide
3. Check LiteLLM documentation: https://docs.litellm.ai/
4. GitHub issues: https://github.com/BerriAI/litellm/issues

For homelab-specific questions, document them in the `docs/` directory of the monorepo.
