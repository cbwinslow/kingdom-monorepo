# Docker Stacks Quick Start Guide

Get started quickly with the kingdom-monorepo Docker stacks.

## Prerequisites

- Docker Engine 20.10+ 
- Docker Compose V2+
- At least 8GB RAM recommended
- For GPU workloads (AI agents): NVIDIA Docker runtime

## Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/cbwinslow/kingdom-monorepo.git
cd kingdom-monorepo/infra/docker-stacks
```

### 2. Choose Your Stack

Pick the stack(s) you need:

| Stack | Use Case | Services | RAM |
|-------|----------|----------|-----|
| [monitoring](./monitoring/) | Observability | 12 | 4GB |
| [network-tools](./network-tools/) | Network diagnostics | 20 | 2GB |
| [mcp-servers](./mcp-servers/) | AI agent tools | 25 | 4GB |
| [mcp-gateway](./mcp-gateway/) | MCP HTTP gateway | 6 | 1GB |
| [proxy](./proxy/) | Reverse proxy & LB | 13 | 2GB |
| [ssh-bastion](./ssh-bastion/) | Secure SSH access | 11 | 2GB |
| [wireguard-vpn](./wireguard-vpn/) | VPN solutions | 15 | 3GB |
| [ai-agents](./ai-agents/) | AI/LLM infrastructure | 20 | 8GB+ |

### 3. Configure Environment

```bash
cd <stack-name>

# Copy example environment file
cp .env.example .env

# Edit with your values
nano .env
```

### 4. Start Services

```bash
# Start all services in the stack
docker-compose up -d

# Or start specific services
docker-compose up -d service1 service2

# View logs
docker-compose logs -f

# Check status
docker-compose ps
```

## Popular Configurations

### Minimal Monitoring Setup

```bash
cd monitoring
docker-compose up -d prometheus grafana node-exporter cadvisor
```

Access:
- Grafana: http://localhost:3000 (admin/admin)
- Prometheus: http://localhost:9090

### Network Troubleshooting

```bash
cd network-tools
docker-compose up -d netshoot dns-tools traceroute

# Interactive shell
docker exec -it netshoot bash
```

### Local AI Development

```bash
cd ai-agents
cat > .env <<EOF
OPENAI_API_KEY=sk-your-key-here
EOF

docker-compose up -d ollama ollama-webui qdrant n8n
```

Access:
- Ollama Web UI: http://localhost:3000
- n8n: http://localhost:5678
- Qdrant: http://localhost:6333

### MCP Servers for AI Agents

```bash
cd mcp-servers
cat > .env <<EOF
POSTGRES_USER=agent
POSTGRES_PASSWORD=secure_password
GITHUB_TOKEN=ghp_your_token
EOF

docker-compose up -d postgres postgres-mcp filesystem-mcp github-mcp
```

### VPN Server

```bash
cd wireguard-vpn
cat > .env <<EOF
SERVERURL=vpn.yourdomain.com
PEERS=5
WGUI_USERNAME=admin
WGUI_PASSWORD=secure_password
EOF

docker-compose up -d wireguard wireguard-ui
```

Access UI: http://localhost:5000

### Reverse Proxy

```bash
cd proxy
docker-compose up -d traefik

# Access dashboard
open http://localhost:8888
```

## Common Commands

### Managing Services

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (WARNING: deletes data)
docker-compose down -v

# Restart a service
docker-compose restart service-name

# Update images
docker-compose pull
docker-compose up -d --force-recreate

# View resource usage
docker stats

# Clean up unused resources
docker system prune -a
```

### Debugging

```bash
# View logs
docker-compose logs -f service-name

# Execute command in container
docker exec -it container-name sh

# Inspect container
docker inspect container-name

# Check container health
docker-compose ps
```

### Backup

```bash
# Backup volumes
docker run --rm \
  -v stack_volume:/data \
  -v $(pwd)/backup:/backup \
  alpine tar czf /backup/volume-backup.tar.gz /data

# Backup configuration
tar czf config-backup.tar.gz .env config/ data/
```

## Next Steps

1. **Read the full README** in each stack directory for detailed documentation
2. **Configure security** - change default passwords, enable HTTPS
3. **Set up monitoring** - integrate with your existing infrastructure
4. **Automate backups** - schedule regular backups of important data
5. **Test disaster recovery** - ensure you can restore from backups
6. **Review logs regularly** - monitor for errors and security issues

## Troubleshooting

### Port Already in Use

```bash
# Find process using port
lsof -i :PORT

# Change port in docker-compose.yml
ports:
  - "NEW_PORT:CONTAINER_PORT"
```

### Container Won't Start

```bash
# Check logs
docker-compose logs service-name

# Check Docker daemon
sudo systemctl status docker

# Check disk space
df -h
```

### Performance Issues

```bash
# Check resource usage
docker stats

# Increase resources in Docker Desktop
# Settings → Resources → Advanced

# Add resource limits to docker-compose.yml
deploy:
  resources:
    limits:
      cpus: '2'
      memory: 4G
```

### Network Connectivity

```bash
# List networks
docker network ls

# Inspect network
docker network inspect network-name

# Test connectivity between containers
docker exec container1 ping container2
```

## Production Deployment

For production use:

1. **Use secrets management** (Docker secrets, Vault, etc.)
2. **Enable SSL/TLS** for all public services
3. **Set up automated backups**
4. **Configure monitoring and alerting**
5. **Implement log aggregation**
6. **Use orchestration** (Docker Swarm, Kubernetes)
7. **Regular security updates**
8. **Document runbooks**
9. **Test disaster recovery**
10. **Compliance and auditing**

## Getting Help

- **Stack README**: Each stack has detailed documentation
- **Docker Logs**: `docker-compose logs -f`
- **GitHub Issues**: Report problems or request features
- **Docker Documentation**: https://docs.docker.com/

## Contributing

Contributions are welcome! To add a new stack:

1. Create directory with descriptive name
2. Add docker-compose.yml
3. Create comprehensive README.md
4. Add .env.example
5. Test thoroughly
6. Update main README.md

## Security Notice

⚠️ **These stacks are provided as-is for development and testing.**

For production use:
- Change all default passwords
- Use strong, unique credentials
- Enable authentication on all services
- Use HTTPS/TLS
- Regular security updates
- Follow security best practices

## License

See repository LICENSE file.
