# Docker Stacks

Comprehensive collection of Docker Compose stacks for various infrastructure and development needs.

## Available Stacks

### 1. [Monitoring Stack](./monitoring/)
Complete observability platform with metrics, logs, traces, and alerting.

**Components:** Prometheus, Grafana, Loki, Promtail, AlertManager, Jaeger, Tempo, Elasticsearch, Kibana, Uptime Kuma, Node Exporter, cAdvisor

**Use Cases:**
- Infrastructure monitoring
- Application performance monitoring (APM)
- Log aggregation and analysis
- Distributed tracing
- Uptime monitoring
- Alerting and notifications

**Quick Start:**
```bash
cd monitoring
docker-compose up -d
# Access Grafana at http://localhost:3000 (admin/admin)
# Access Prometheus at http://localhost:9090
```

---

### 2. [Network Tools Stack](./network-tools/)
Swiss army knife of network diagnostic, monitoring, and testing tools.

**Components:** netshoot, ntopng, dnsmasq, iperf3, nmap, tcpdump, speedtest, proxies, netdata, smokeping, grpcurl, wscat

**Use Cases:**
- Network troubleshooting
- Performance testing
- Port scanning
- Packet capture
- DNS management
- Bandwidth monitoring
- API testing (HTTP, gRPC, WebSocket)

**Quick Start:**
```bash
cd network-tools
docker-compose up -d
# Interactive troubleshooting: docker exec -it netshoot bash
# Access Netdata at http://localhost:19999
```

---

### 3. [MCP Servers Stack](./mcp-servers/)
Model Context Protocol servers with database backends for AI agent integration.

**Components:** PostgreSQL MCP, MySQL MCP, MongoDB MCP, SQLite MCP, Filesystem MCP, Git MCP, GitHub MCP, Slack MCP, Memory MCP, Docker MCP, Brave Search MCP

**Use Cases:**
- AI agent tool integration
- Database access for LLMs
- File system operations
- Git/GitHub integration
- External API access
- Persistent memory for agents

**Quick Start:**
```bash
cd mcp-servers
cp .env.example .env  # Edit with your API keys
docker-compose up -d postgres postgres-mcp filesystem-mcp
```

---

### 4. [MCP Gateway Stack](./mcp-gateway/)
HTTP/SSE gateway for exposing MCP servers over the web.

**Components:** MCP Gateway, Redis, Nginx, WebSocket clients, Prometheus exporter

**Use Cases:**
- Remote MCP server access
- Web-based AI agent integration
- Load balancing MCP servers
- Session management
- Metrics and monitoring

**Quick Start:**
```bash
cd mcp-gateway
docker-compose up -d
# Access gateway at http://localhost:3000
# SSE endpoint: http://localhost:3000/sse
```

---

### 5. [Proxy Stack](./proxy/)
Enterprise-grade reverse proxies, load balancers, and forward proxies.

**Components:** Nginx, Traefik, HAProxy, Caddy, Envoy, Squid, Privoxy, Dante (SOCKS5), tinyproxy, mitmproxy

**Use Cases:**
- Reverse proxy and load balancing
- SSL/TLS termination
- HTTP/HTTPS caching
- Forward proxy for outbound traffic
- SOCKS5 proxy
- Traffic inspection and debugging
- API gateway

**Quick Start:**
```bash
cd proxy
docker-compose up -d nginx traefik
# Nginx: http://localhost
# Traefik Dashboard: http://localhost:8888
```

---

### 6. [SSH Bastion Stack](./ssh-bastion/)
Secure SSH access, jump hosts, and remote desktop gateways.

**Components:** OpenSSH Bastion, Jump Host, Teleport, Guacamole, Fail2ban, Session Recorder, Audit Logger, Key Manager

**Use Cases:**
- Secure SSH access to private networks
- Jump host for server access
- Web-based SSH/RDP access
- Session recording and auditing
- Intrusion prevention
- SSH key management

**Quick Start:**
```bash
cd ssh-bastion
# Generate SSH keys first
ssh-keygen -t ed25519 -f ssh_keys/generated/bastion_key
cat ssh_keys/generated/bastion_key.pub > config/authorized_keys
docker-compose up -d bastion
# Connect: ssh -i ssh_keys/generated/bastion_key -p 2222 bastion@localhost
```

---

### 7. [WireGuard VPN Stack](./wireguard-vpn/)
Modern VPN solutions with multiple protocols and management interfaces.

**Components:** WireGuard, WireGuard UI, OpenVPN, IPsec, SoftEther, Pritunl, Tailscale, Nebula, Pi-hole DNS

**Use Cases:**
- Secure remote access VPN
- Site-to-site VPN
- Mesh networking
- Split tunneling
- DNS filtering
- Mobile VPN access
- Multi-protocol VPN

**Quick Start:**
```bash
cd wireguard-vpn
cat > .env <<EOF
SERVERURL=your.domain.com
PEERS=5
WGUI_USERNAME=admin
WGUI_PASSWORD=secure_password
EOF
docker-compose up -d wireguard wireguard-ui
# Access UI: http://localhost:5000
# Get client configs: ls config/peer*/
```

---

### 8. [AI Agents Stack](./ai-agents/)
Complete AI agent infrastructure with LLMs, vector databases, and workflow tools.

**Components:** LiteLLM, Ollama, LangChain, CrewAI, AutoGPT, AgentGPT, n8n, Flowise, LangFlow, Qdrant, Weaviate, ChromaDB, Redis, MinIO, Jupyter

**Use Cases:**
- Running local LLMs
- Building AI agents
- Vector similarity search
- Workflow automation
- Multi-agent systems
- RAG (Retrieval Augmented Generation)
- AI development and testing

**Quick Start:**
```bash
cd ai-agents
cp .env.example .env  # Add your API keys
docker-compose up -d openai-api ollama ollama-webui qdrant
# Ollama Web UI: http://localhost:3000
# n8n: http://localhost:5678
# Flowise: http://localhost:3002
```

---

## General Usage

### Starting a Stack

```bash
# Navigate to stack directory
cd <stack-name>

# Start all services
docker-compose up -d

# Start specific services
docker-compose up -d service1 service2

# View logs
docker-compose logs -f

# Check status
docker-compose ps
```

### Stopping a Stack

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (WARNING: deletes data)
docker-compose down -v

# Stop and remove images
docker-compose down --rmi all
```

### Updating Services

```bash
# Pull latest images
docker-compose pull

# Recreate containers with new images
docker-compose up -d --force-recreate

# Update specific service
docker-compose pull service-name
docker-compose up -d --force-recreate service-name
```

## Environment Variables

Most stacks require environment variables for configuration. Each stack includes:

1. **README.md** - Detailed documentation
2. **.env.example** - Example environment file (create your own .env)
3. **docker-compose.yml** - Service definitions

### Creating Environment Files

```bash
# Copy example file
cp .env.example .env

# Edit with your values
nano .env

# Never commit .env files to version control
echo ".env" >> .gitignore
```

## Networking

### Stack Isolation

Each stack creates its own Docker network for service communication:

- `monitoring_monitoring`
- `network-tools_network-tools`
- `mcp-network`
- `proxy-network`
- `bastion-network`
- `vpn-network`
- `ai-network`

### Cross-Stack Communication

To enable communication between stacks:

```yaml
# In docker-compose.yml
networks:
  default:
    external: true
    name: shared-network
```

Or connect to external network:

```yaml
networks:
  monitoring_monitoring:
    external: true
```

## Security Best Practices

### 1. Environment Variables
- Never commit `.env` files
- Use strong, random passwords
- Rotate credentials regularly
- Use secrets management in production

### 2. Network Security
- Use separate networks for isolation
- Limit exposed ports
- Use firewall rules
- Enable HTTPS/TLS

### 3. Container Security
- Regular image updates
- Use official images
- Scan for vulnerabilities
- Run as non-root when possible
- Use read-only filesystems where applicable

### 4. Access Control
- Enable authentication on all services
- Use strong passwords
- Implement 2FA where available
- Regular access audits

### 5. Monitoring and Logging
- Enable audit logging
- Monitor for anomalies
- Set up alerts
- Regular log review

## Resource Management

### Memory Limits

```yaml
services:
  service-name:
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```

### Volume Management

```bash
# List volumes
docker volume ls

# Remove unused volumes
docker volume prune

# Backup volume
docker run --rm -v volume_name:/data -v $(pwd):/backup alpine tar czf /backup/backup.tar.gz /data

# Restore volume
docker run --rm -v volume_name:/data -v $(pwd):/backup alpine tar xzf /backup/backup.tar.gz -C /
```

## Troubleshooting

### Common Issues

#### Port Already in Use
```bash
# Find process using port
lsof -i :PORT_NUMBER
netstat -tulpn | grep PORT_NUMBER

# Change port in docker-compose.yml
ports:
  - "NEW_PORT:CONTAINER_PORT"
```

#### Container Won't Start
```bash
# Check logs
docker-compose logs service-name

# Check container status
docker-compose ps

# Inspect container
docker inspect container-name

# Check resource usage
docker stats
```

#### Permission Errors
```bash
# Fix ownership
sudo chown -R $(id -u):$(id -g) ./data

# Fix permissions
chmod -R 755 ./data
```

#### Network Issues
```bash
# Check networks
docker network ls

# Inspect network
docker network inspect network-name

# Test connectivity
docker exec container1 ping container2
```

### Debug Mode

```bash
# Run with verbose logging
docker-compose up --verbose

# Run in foreground
docker-compose up

# Execute command in container
docker exec -it container-name sh

# Access logs
docker-compose logs -f --tail=100 service-name
```

## Production Deployment

### Checklist

- [ ] Use production-grade secrets management
- [ ] Enable SSL/TLS for all services
- [ ] Set up automated backups
- [ ] Configure monitoring and alerting
- [ ] Implement log rotation
- [ ] Set resource limits
- [ ] Use health checks
- [ ] Configure restart policies
- [ ] Test disaster recovery
- [ ] Document runbooks
- [ ] Set up CI/CD pipelines
- [ ] Regular security audits

### Orchestration

For production deployments, consider:

- **Docker Swarm** - Built-in orchestration
- **Kubernetes** - Enterprise container orchestration
- **Nomad** - Flexible workload orchestrator

### Example Docker Swarm Stack

```yaml
version: '3.8'
services:
  app:
    image: myapp:latest
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
    secrets:
      - db_password
    networks:
      - app-network

secrets:
  db_password:
    external: true

networks:
  app-network:
    driver: overlay
```

## Maintenance

### Regular Tasks

**Daily:**
- Check service health
- Monitor resource usage
- Review critical logs

**Weekly:**
- Update Docker images
- Review security alerts
- Check backup status
- Analyze performance metrics

**Monthly:**
- Security audit
- Rotate credentials
- Clean up unused resources
- Update documentation
- Test disaster recovery

### Backup Strategy

```bash
#!/bin/bash
# backup-all-stacks.sh

BACKUP_DIR="/backups/$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

# Backup each stack's volumes and configs
for stack in monitoring network-tools mcp-servers mcp-gateway proxy ssh-bastion wireguard-vpn ai-agents; do
    echo "Backing up $stack..."
    cd $stack
    
    # Backup configs
    tar czf $BACKUP_DIR/${stack}-config.tar.gz config/ 2>/dev/null || true
    
    # Backup docker volumes
    docker-compose config --volumes | while read volume; do
        docker run --rm \
            -v ${stack}_${volume}:/data \
            -v $BACKUP_DIR:/backup \
            alpine tar czf /backup/${stack}-${volume}.tar.gz /data
    done
    
    cd ..
done

echo "Backup complete: $BACKUP_DIR"
```

## Integration Examples

### Monitoring Stack + Application Stack

```yaml
# Add to application's docker-compose.yml
services:
  app:
    labels:
      - "prometheus.scrape=true"
      - "prometheus.port=9090"
    networks:
      - app-network
      - monitoring_monitoring

networks:
  monitoring_monitoring:
    external: true
```

### VPN + SSH Bastion

Connect VPN clients to SSH bastion:

```bash
# In WireGuard client config
AllowedIPs = 10.13.13.0/24, 172.25.0.0/16
```

### AI Agents + MCP Servers

Configure AI agents to use MCP servers:

```json
{
  "mcpServers": {
    "postgres": {
      "command": "docker",
      "args": ["exec", "-i", "postgres-mcp-server", "cat"]
    }
  }
}
```

## Contributing

To add a new stack:

1. Create directory: `mkdir -p new-stack`
2. Add `docker-compose.yml`
3. Create comprehensive `README.md`
4. Add `.env.example` with all required variables
5. Include usage examples and troubleshooting
6. Test thoroughly
7. Update this main README

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Container Security](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)

## Support

For issues, questions, or contributions:
- Open an issue in the repository
- Check individual stack README files
- Review Docker Compose logs
- Consult official documentation for each component

## License

See LICENSE file in repository root.
