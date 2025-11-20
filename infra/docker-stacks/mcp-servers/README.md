# MCP Servers Stack

A comprehensive Docker Compose stack running multiple Model Context Protocol (MCP) servers with their required dependencies.

## Components

### Database MCP Servers
- **PostgreSQL** (port 5432) + **postgres-mcp** - PostgreSQL database access
- **MySQL** (port 3306) + **mysql-mcp** - MySQL database access
- **MongoDB** (port 27017) + **mongodb-mcp** - MongoDB database access
- **sqlite-mcp** - SQLite database access

### File & Git MCP Servers
- **filesystem-mcp** - Local filesystem access
- **git-mcp** - Git repository operations
- **github-mcp** - GitHub API integration

### Communication MCP Servers
- **slack-mcp** - Slack integration
- **brave-search-mcp** - Web search capabilities
- **fetch-mcp** - HTTP/HTTPS requests

### Utility MCP Servers
- **memory-mcp** - Persistent memory storage
- **puppeteer-mcp** - Web scraping and automation
- **docker-mcp** - Docker container management
- **prometheus-mcp** - Prometheus metrics queries
- **sequential-thinking-mcp** - Advanced reasoning
- **time-mcp** - Time and timezone information

### Cloud Service MCP Servers
- **gdrive-mcp** - Google Drive integration
- **google-maps-mcp** - Google Maps API
- **sentry-mcp** - Sentry error tracking
- **everart-mcp** - AI image generation

### Python-based MCP Servers
- **time-mcp** - Python time server
- **python-fs-mcp** - Python filesystem server

## Quick Start

### 1. Environment Setup

Create a `.env` file in this directory:

```bash
# Database credentials
POSTGRES_USER=mcp_user
POSTGRES_PASSWORD=secure_password
POSTGRES_DB=mcp_db

MYSQL_ROOT_PASSWORD=root_password
MYSQL_DATABASE=mcp_db
MYSQL_USER=mcp_user
MYSQL_PASSWORD=secure_password

MONGO_USER=mcp_user
MONGO_PASSWORD=secure_password

# API Keys
GITHUB_TOKEN=ghp_your_github_token
SLACK_BOT_TOKEN=xoxb-your-slack-token
SLACK_TEAM_ID=T1234567890
BRAVE_API_KEY=BSA_your_brave_api_key
GOOGLE_MAPS_API_KEY=your_google_maps_key
SENTRY_AUTH_TOKEN=your_sentry_token
SENTRY_ORG=your_org
EVERART_API_KEY=your_everart_key

# URLs
PROMETHEUS_URL=http://prometheus:9090
```

### 2. Create Required Directories

```bash
# Create data directories
mkdir -p data/{sqlite,filesystem,repos,python-fs}
mkdir -p credentials

# Set permissions
chmod 755 data/*
```

### 3. Google Drive Credentials (Optional)

If using Google Drive MCP server:

```bash
# Place your Google service account credentials
cp /path/to/your/credentials.json credentials/credentials.json
chmod 600 credentials/credentials.json
```

### 4. Start Services

```bash
# Start all MCP servers
docker-compose up -d

# Start specific servers
docker-compose up -d postgres postgres-mcp filesystem-mcp

# View logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f postgres-mcp
```

### 5. Verify Services

```bash
# Check running containers
docker-compose ps

# Test database connectivity
docker exec mcp-postgres pg_isready
docker exec mcp-mysql mysqladmin ping
docker exec mcp-mongodb mongosh --eval "db.adminCommand('ping')"

# Check MCP server logs
docker-compose logs postgres-mcp
docker-compose logs filesystem-mcp
```

## Usage Examples

### Connecting to MCP Servers

#### From Claude Desktop

Edit `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS):

```json
{
  "mcpServers": {
    "postgres": {
      "command": "docker",
      "args": ["exec", "-i", "postgres-mcp-server", "npx", "-y", "@modelcontextprotocol/server-postgres", "postgresql://mcp_user:secure_password@localhost:5432/mcp_db"]
    },
    "filesystem": {
      "command": "docker",
      "args": ["exec", "-i", "filesystem-mcp-server", "cat"]
    }
  }
}
```

#### From Custom Agent

```python
import subprocess
import json

# Connect to MCP server via Docker
def connect_to_mcp_server(container_name):
    process = subprocess.Popen(
        ["docker", "exec", "-i", container_name, "cat"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    return process

# Example usage
postgres_mcp = connect_to_mcp_server("postgres-mcp-server")
```

### Database Operations

#### PostgreSQL

```bash
# Connect to PostgreSQL
docker exec -it mcp-postgres psql -U mcp_user -d mcp_db

# Create table
docker exec mcp-postgres psql -U mcp_user -d mcp_db -c "
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);
"

# Insert data
docker exec mcp-postgres psql -U mcp_user -d mcp_db -c "
INSERT INTO users (name, email) VALUES ('John Doe', 'john@example.com');
"

# Query via MCP (through AI agent)
# AI agent can use postgres-mcp to query: "SELECT * FROM users"
```

#### MySQL

```bash
# Connect to MySQL
docker exec -it mcp-mysql mysql -u mcp_user -p mcp_db

# Create table
docker exec mcp-mysql mysql -u mcp_user -p${MYSQL_PASSWORD} mcp_db -e "
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10,2)
);
"
```

#### MongoDB

```bash
# Connect to MongoDB
docker exec -it mcp-mongodb mongosh -u mcp_user -p mcp_password --authenticationDatabase admin

# Insert document
docker exec mcp-mongodb mongosh -u mcp_user -p mcp_password --authenticationDatabase admin --eval "
db.users.insertOne({name: 'Jane Doe', email: 'jane@example.com'})
"
```

#### SQLite

```bash
# Access SQLite database
docker exec -it sqlite-mcp-server sh

# Create database and table
sqlite3 /data/database.db "
CREATE TABLE notes (
    id INTEGER PRIMARY KEY,
    title TEXT,
    content TEXT
);
INSERT INTO notes (title, content) VALUES ('First Note', 'Hello World');
"
```

### Filesystem Operations

```bash
# Add files to filesystem
echo "Hello World" > data/filesystem/hello.txt
echo "# README" > data/filesystem/README.md

# AI agent can now access these files via filesystem-mcp
```

### Git Operations

```bash
# Clone a repository
cd data/repos
git clone https://github.com/example/repo.git

# AI agent can now access Git history and operations
```

### Memory Storage

```bash
# View memory storage
docker exec memory-mcp-server ls -la /root/.mcp-memory/

# Memory is persisted across restarts
```

## Integration with AI Agents

### Example: Python Agent

```python
import subprocess
import json

class MCPClient:
    def __init__(self, container_name):
        self.container_name = container_name
        
    def send_request(self, method, params=None):
        request = {
            "jsonrpc": "2.0",
            "id": 1,
            "method": method,
            "params": params or {}
        }
        
        process = subprocess.Popen(
            ["docker", "exec", "-i", self.container_name, "cat"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        
        stdout, stderr = process.communicate(json.dumps(request))
        return json.loads(stdout)

# Usage
postgres_client = MCPClient("postgres-mcp-server")
result = postgres_client.send_request("execute_query", {
    "query": "SELECT * FROM users"
})
print(result)
```

### Example: Node.js Agent

```javascript
const { spawn } = require('child_process');

class MCPClient {
  constructor(containerName) {
    this.containerName = containerName;
  }
  
  async sendRequest(method, params = {}) {
    return new Promise((resolve, reject) => {
      const docker = spawn('docker', ['exec', '-i', this.containerName, 'cat']);
      
      const request = {
        jsonrpc: '2.0',
        id: 1,
        method: method,
        params: params
      };
      
      let response = '';
      
      docker.stdout.on('data', (data) => {
        response += data.toString();
      });
      
      docker.on('close', () => {
        try {
          resolve(JSON.parse(response));
        } catch (error) {
          reject(error);
        }
      });
      
      docker.stdin.write(JSON.stringify(request));
      docker.stdin.end();
    });
  }
}

// Usage
const filesystemClient = new MCPClient('filesystem-mcp-server');
filesystemClient.sendRequest('read_file', { path: '/data/hello.txt' })
  .then(result => console.log(result));
```

## Configuration

### Scaling Individual Services

```bash
# Scale MCP servers
docker-compose up -d --scale postgres-mcp=3

# Each instance will need separate configuration
```

### Resource Limits

Add to service definitions:

```yaml
services:
  postgres-mcp:
    # ... other config
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```

### Health Checks

```yaml
services:
  postgres-mcp:
    # ... other config
    healthcheck:
      test: ["CMD", "npx", "-y", "@modelcontextprotocol/server-postgres", "--version"]
      interval: 30s
      timeout: 10s
      retries: 3
```

## Security Best Practices

1. **Environment Variables**: Never commit `.env` file
2. **Credentials**: Use Docker secrets in production
3. **Network Isolation**: Use separate networks for different concerns
4. **Read-Only Filesystems**: Mount volumes as read-only when possible
5. **User Permissions**: Run containers as non-root users
6. **API Keys**: Rotate regularly and use secrets management
7. **Database Access**: Use least-privilege accounts
8. **Container Updates**: Regularly update base images

### Example: Using Docker Secrets

```yaml
services:
  github-mcp:
    secrets:
      - github_token
    environment:
      GITHUB_TOKEN_FILE: /run/secrets/github_token

secrets:
  github_token:
    file: ./secrets/github_token.txt
```

## Monitoring

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f postgres-mcp

# Last N lines
docker-compose logs --tail=100 postgres-mcp

# Since timestamp
docker-compose logs --since 2024-01-01T00:00:00 postgres-mcp
```

### Resource Usage

```bash
# Container stats
docker stats $(docker-compose ps -q)

# Detailed info
docker-compose ps
docker-compose top
```

### Integration with Monitoring Stack

If you have the monitoring stack running:

```yaml
# Add to docker-compose.yml
services:
  postgres-mcp:
    # ... other config
    labels:
      - "prometheus.scrape=true"
      - "prometheus.port=9090"
    networks:
      - mcp-network
      - monitoring_monitoring
      
networks:
  monitoring_monitoring:
    external: true
```

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker-compose logs [service-name]

# Check container status
docker-compose ps

# Inspect container
docker inspect [container-name]
```

### Database Connection Issues

```bash
# Test PostgreSQL
docker exec mcp-postgres pg_isready

# Test MySQL
docker exec mcp-mysql mysqladmin ping -h localhost -u mcp_user -p${MYSQL_PASSWORD}

# Test MongoDB
docker exec mcp-mongodb mongosh --eval "db.adminCommand('ping')"
```

### MCP Server Not Responding

```bash
# Check if process is running
docker exec [mcp-container] ps aux

# Restart service
docker-compose restart [service-name]

# Check network connectivity
docker exec [mcp-container] ping postgres
```

### Permission Errors

```bash
# Fix filesystem permissions
sudo chown -R $(id -u):$(id -g) data/

# Fix container permissions
docker-compose exec filesystem-mcp chmod -R 755 /data
```

### Out of Memory

```bash
# Check memory usage
docker stats --no-stream

# Increase limits in docker-compose.yml
```

## Maintenance

### Backup Databases

```bash
# PostgreSQL
docker exec mcp-postgres pg_dump -U mcp_user mcp_db > backup_postgres.sql

# MySQL
docker exec mcp-mysql mysqldump -u mcp_user -p${MYSQL_PASSWORD} mcp_db > backup_mysql.sql

# MongoDB
docker exec mcp-mongodb mongodump --out=/backup
```

### Restore Databases

```bash
# PostgreSQL
cat backup_postgres.sql | docker exec -i mcp-postgres psql -U mcp_user mcp_db

# MySQL
cat backup_mysql.sql | docker exec -i mcp-mysql mysql -u mcp_user -p${MYSQL_PASSWORD} mcp_db

# MongoDB
docker exec mcp-mongodb mongorestore /backup
```

### Update Services

```bash
# Pull latest images
docker-compose pull

# Recreate containers
docker-compose up -d --force-recreate

# Clean old images
docker image prune -a
```

### Clean Up

```bash
# Stop all services
docker-compose down

# Remove volumes (WARNING: deletes data)
docker-compose down -v

# Remove images
docker-compose down --rmi all
```

## Advanced Configuration

### Custom MCP Server

Add your custom MCP server:

```yaml
services:
  custom-mcp:
    build: ./custom-mcp
    container_name: custom-mcp-server
    volumes:
      - ./custom-mcp/config:/config
    environment:
      - CUSTOM_VAR=value
    networks:
      - mcp-network
    restart: unless-stopped
```

### Load Balancing Multiple Instances

```yaml
services:
  postgres-mcp:
    # ... config
    deploy:
      replicas: 3
      
  mcp-loadbalancer:
    image: nginx:alpine
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    ports:
      - "8080:80"
    depends_on:
      - postgres-mcp
```

## Production Deployment

### Recommendations

1. **Use Docker Swarm or Kubernetes** for orchestration
2. **External databases** with managed services
3. **Persistent volumes** with backup solutions
4. **Load balancers** for high availability
5. **Monitoring and alerting** integration
6. **CI/CD pipelines** for updates
7. **Secret management** systems (Vault, AWS Secrets Manager)
8. **Network policies** for security
9. **Resource quotas** and limits
10. **Regular security audits**

### Example: Docker Swarm Stack

```yaml
version: '3.8'

services:
  postgres-mcp:
    image: node:20-alpine
    command: npx -y @modelcontextprotocol/server-postgres
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
    secrets:
      - postgres_password
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/postgres_password

secrets:
  postgres_password:
    external: true
```

## References

- [MCP Specification](https://modelcontextprotocol.io)
- [Official MCP Servers](https://github.com/modelcontextprotocol/servers)
- [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk)
- [MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
