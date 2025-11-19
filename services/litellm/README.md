# LiteLLM Proxy

A unified proxy server for managing multiple LLM providers (OpenAI, Anthropic, Google, etc.) with a single API interface.

## Features

- 🔄 **Unified API**: Single interface for all LLM providers
- 🔑 **API Key Management**: Create and manage multiple API keys
- 📊 **Monitoring**: Built-in logging and observability with Langfuse
- 💾 **Caching**: Redis-based response caching
- 🔁 **Fallbacks**: Automatic fallback to alternative models
- ⚖️ **Load Balancing**: Usage-based routing across models
- 🌐 **Web UI**: Interactive dashboard for management
- 🐳 **Docker Support**: Easy deployment with Docker Compose

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- API keys for at least one LLM provider (OpenAI, Anthropic, Google, etc.)

### Local Machine Setup

1. **Navigate to the LiteLLM directory:**
   ```bash
   cd services/litellm
   ```

2. **Copy the environment template:**
   ```bash
   cp .env.example .env
   ```

3. **Edit `.env` and add your API keys:**
   ```bash
   # Required: Set a master key for authentication
   LITELLM_MASTER_KEY=sk-your-secret-master-key-here
   
   # Required: Set UI credentials
   LITELLM_UI_USERNAME=admin
   LITELLM_UI_PASSWORD=your-secure-password
   
   # Add at least one LLM provider API key
   OPENAI_API_KEY=sk-your-openai-api-key
   ANTHROPIC_API_KEY=sk-ant-your-anthropic-api-key
   ```

4. **Start the services:**
   ```bash
   docker-compose up -d
   ```

5. **Verify the services are running:**
   ```bash
   docker-compose ps
   ```

6. **Access the proxy:**
   - API Endpoint: `http://localhost:4000`
   - Web UI: `http://localhost:4000/ui`
   - Health Check: `http://localhost:4000/health`

### Testing the Proxy

Test with curl:
```bash
curl -X POST http://localhost:4000/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $LITELLM_MASTER_KEY" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

Or use Python:
```python
import openai

client = openai.OpenAI(
    api_key="your-litellm-master-key",
    base_url="http://localhost:4000"
)

response = client.chat.completions.create(
    model="gpt-3.5-turbo",
    messages=[{"role": "user", "content": "Hello!"}]
)
print(response.choices[0].message.content)
```

## Homelab Server Setup (cbwdellr720)

### Prerequisites

- SSH access to cbwdellr720
- Docker and Docker Compose installed on the server
- Firewall rules configured (if needed)

### Deployment Steps

1. **SSH into the homelab server:**
   ```bash
   ssh user@cbwdellr720
   ```

2. **Clone the repository (if not already present):**
   ```bash
   git clone https://github.com/cbwinslow/kingdom-monorepo.git
   cd kingdom-monorepo/services/litellm
   ```
   
   Or pull latest changes:
   ```bash
   cd kingdom-monorepo
   git pull
   cd services/litellm
   ```

3. **Setup environment variables:**
   ```bash
   cp .env.example .env
   nano .env  # or vim .env
   ```
   
   Important settings for server deployment:
   ```bash
   # Use a strong master key
   LITELLM_MASTER_KEY=sk-$(openssl rand -hex 32)
   
   # Set secure UI credentials
   LITELLM_UI_USERNAME=admin
   LITELLM_UI_PASSWORD=$(openssl rand -base64 24)
   
   # Add your LLM provider keys
   OPENAI_API_KEY=sk-...
   ANTHROPIC_API_KEY=sk-ant-...
   
   # Server configuration
   LITELLM_HOST=0.0.0.0
   LITELLM_PORT=4000
   ```

4. **Start the services:**
   ```bash
   docker-compose up -d
   ```

5. **Verify deployment:**
   ```bash
   # Check service status
   docker-compose ps
   
   # Check logs
   docker-compose logs -f litellm
   
   # Test health endpoint
   curl http://localhost:4000/health
   ```

6. **Configure firewall (if needed):**
   ```bash
   # Allow port 4000 for LiteLLM proxy
   sudo ufw allow 4000/tcp
   
   # Or for specific IP range only
   sudo ufw allow from 192.168.1.0/24 to any port 4000
   ```

7. **Setup systemd service (optional - for auto-start):**
   
   Create `/etc/systemd/system/litellm.service`:
   ```ini
   [Unit]
   Description=LiteLLM Proxy Service
   Requires=docker.service
   After=docker.service
   
   [Service]
   Type=oneshot
   RemainAfterExit=yes
   WorkingDirectory=/home/user/kingdom-monorepo/services/litellm
   ExecStart=/usr/bin/docker-compose up -d
   ExecStop=/usr/bin/docker-compose down
   
   [Install]
   WantedBy=multi-user.target
   ```
   
   Enable and start:
   ```bash
   sudo systemctl enable litellm
   sudo systemctl start litellm
   ```

### Accessing from Other Machines

Once deployed on cbwdellr720, access from other machines on the network:

```bash
# Replace with cbwdellr720's IP address
export LITELLM_URL="http://192.168.1.x:4000"
export LITELLM_API_KEY="your-master-key"

curl -X POST $LITELLM_URL/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $LITELLM_API_KEY" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "Hello from remote!"}]
  }'
```

### Reverse Proxy Setup (Optional)

For HTTPS and domain access, configure Nginx or Traefik:

**Nginx example:**
```nginx
server {
    listen 443 ssl;
    server_name litellm.cbwdellr720.local;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        proxy_pass http://localhost:4000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Configuration

### Available Models

The default configuration includes:

**OpenAI:**
- gpt-4
- gpt-4-turbo
- gpt-3.5-turbo

**Anthropic:**
- claude-3-opus
- claude-3-sonnet
- claude-3-haiku

**Google:**
- gemini-pro

**Local (via Ollama):**
- llama2
- mistral

### Adding Custom Models

Edit `config.yaml` to add more models:

```yaml
model_list:
  - model_name: my-custom-model
    litellm_params:
      model: provider/model-name
      api_key: os.environ/MY_API_KEY
      api_base: https://api.provider.com  # optional
```

### Caching Configuration

Redis caching is enabled by default. To disable:

```yaml
litellm_settings:
  cache: false
```

### Rate Limiting

Configure per-model rate limits in `config.yaml`:

```yaml
litellm_settings:
  model_max_retries: 3
  model_retry_delay: 10
  request_timeout: 600
```

## Management

### Viewing Logs

```bash
# All services
docker-compose logs -f

# Just LiteLLM
docker-compose logs -f litellm

# Last 100 lines
docker-compose logs --tail=100 litellm
```

### Restarting Services

```bash
# Restart all services
docker-compose restart

# Restart just LiteLLM
docker-compose restart litellm
```

### Updating Configuration

After editing `config.yaml`:

```bash
docker-compose restart litellm
```

### Stopping Services

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (WARNING: deletes data)
docker-compose down -v
```

### Backup Database

```bash
# Backup PostgreSQL
docker-compose exec postgres pg_dump -U litellm litellm > backup.sql

# Restore
docker-compose exec -T postgres psql -U litellm litellm < backup.sql
```

## Monitoring

### Web UI

Access the web interface at `http://localhost:4000/ui` (or your server's IP).

Features:
- View model usage statistics
- Manage API keys
- Monitor request logs
- Test models interactively

### Langfuse Integration

To enable Langfuse for advanced monitoring:

1. Sign up at [langfuse.com](https://langfuse.com)
2. Get your API keys
3. Add to `.env`:
   ```bash
   LANGFUSE_PUBLIC_KEY=pk-...
   LANGFUSE_SECRET_KEY=sk-...
   LANGFUSE_HOST=https://cloud.langfuse.com
   ```
4. Restart the proxy

## Troubleshooting

### Container won't start

```bash
# Check logs
docker-compose logs litellm

# Check PostgreSQL connectivity
docker-compose exec postgres pg_isready -U litellm

# Check Redis connectivity
docker-compose exec redis redis-cli ping
```

### API requests failing

1. Verify master key is set correctly
2. Check that provider API keys are valid
3. Review logs: `docker-compose logs -f litellm`
4. Test health endpoint: `curl http://localhost:4000/health`

### Port already in use

Change the port in `.env`:
```bash
LITELLM_PORT=4001
```

Then restart:
```bash
docker-compose down
docker-compose up -d
```

### Database connection errors

Ensure PostgreSQL is healthy:
```bash
docker-compose ps postgres
docker-compose logs postgres
```

Reset database (WARNING: deletes data):
```bash
docker-compose down -v
docker-compose up -d
```

## Security Best Practices

1. **Strong Master Key**: Use a randomly generated key
   ```bash
   openssl rand -hex 32
   ```

2. **Environment Variables**: Never commit `.env` file to git
   
3. **Network Access**: Limit access using firewall rules

4. **HTTPS**: Use reverse proxy with SSL for production

5. **API Key Rotation**: Regularly rotate provider API keys

6. **UI Access**: Change default admin credentials immediately

7. **Database Backup**: Regular backups of PostgreSQL data

## Advanced Usage

### Virtual Keys

Create separate API keys for different users or applications:

```bash
curl -X POST http://localhost:4000/key/generate \
  -H "Authorization: Bearer $LITELLM_MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "models": ["gpt-3.5-turbo", "claude-3-haiku"],
    "max_budget": 100,
    "duration": "30d"
  }'
```

### Load Balancing

Multiple instances of the same model:

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

### Custom Fallbacks

Per-request fallback models:

```python
response = client.chat.completions.create(
    model="gpt-4",
    messages=[{"role": "user", "content": "Hello!"}],
    fallbacks=["gpt-3.5-turbo", "claude-3-haiku"]
)
```

## Resources

- [LiteLLM Documentation](https://docs.litellm.ai/)
- [Supported Models](https://docs.litellm.ai/docs/providers)
- [GitHub Repository](https://github.com/BerriAI/litellm)
- [Discord Community](https://discord.com/invite/wuPM9dRgDw)

## Support

For issues specific to this setup:
1. Check logs: `docker-compose logs -f`
2. Review configuration in `config.yaml`
3. Verify environment variables in `.env`
4. Check LiteLLM documentation for provider-specific issues

For general LiteLLM support:
- GitHub Issues: https://github.com/BerriAI/litellm/issues
- Discord: https://discord.com/invite/wuPM9dRgDw
