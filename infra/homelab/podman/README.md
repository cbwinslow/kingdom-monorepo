# Podman Deployment Scripts

Rootless container deployment using Podman as a Docker alternative.

## What is Podman?

Podman is a daemonless container engine for developing, managing, and running OCI Containers. Key advantages:
- **Rootless**: Run containers without root privileges
- **Daemonless**: No background daemon required
- **Docker compatible**: Drop-in replacement for most Docker commands
- **Systemd integration**: Native systemd service support
- **Pod support**: Kubernetes-like pod functionality

## Installation

```bash
cd ../bare-metal
sudo ./install-podman.sh
```

## Usage

### Deploy Monitoring Stack

```bash
cd podman
./deploy-monitoring.sh
```

This deploys:
- Prometheus (port 9090)
- Grafana (port 3000)
- Node Exporter (port 9100)

### Using Podman Commands

Podman commands are nearly identical to Docker:

```bash
# List containers
podman ps

# List images
podman images

# Run a container
podman run -d --name nginx -p 8080:80 nginx

# Stop container
podman stop nginx

# Remove container
podman rm nginx

# View logs
podman logs -f nginx

# Execute command in container
podman exec -it nginx bash

# Inspect container
podman inspect nginx
```

### Using Podman Compose

Podman Compose is compatible with docker-compose files:

```bash
# Use any docker-compose.yml
podman-compose up -d

# Or with compose file from docker-compose directory
cd ../docker-compose/monitoring
podman-compose up -d

# Stop services
podman-compose down
```

### Rootless Containers

Run containers as your regular user (no sudo):

```bash
# As regular user
podman run -d --name nginx -p 8080:80 nginx

# Check containers
podman ps

# No daemon required!
```

### Systemd Integration

Create systemd service for a container:

```bash
# Generate systemd unit file
podman generate systemd --new --files --name nginx

# Copy to user systemd directory
mkdir -p ~/.config/systemd/user/
mv container-nginx.service ~/.config/systemd/user/

# Enable and start
systemctl --user enable container-nginx.service
systemctl --user start container-nginx.service

# Enable linger (containers survive logout)
loginctl enable-linger $USER
```

### Pods (Kubernetes-like)

Create a pod with multiple containers:

```bash
# Create pod
podman pod create --name mypod -p 8080:80

# Add containers to pod
podman run -d --pod mypod --name nginx nginx
podman run -d --pod mypod --name php php:fpm

# Containers share network namespace
# Access via localhost within pod
```

## Migration from Docker

### Command Mapping

```bash
# Docker → Podman
docker ps           → podman ps
docker run          → podman run
docker build        → podman build
docker-compose up   → podman-compose up
docker system prune → podman system prune
```

### Alias Docker to Podman

```bash
# Add to ~/.bashrc or ~/.zshrc
alias docker=podman
alias docker-compose=podman-compose
```

### Socket Compatibility

Enable Docker-compatible socket:

```bash
systemctl --user enable podman.socket
systemctl --user start podman.socket

# Socket at: unix:///run/user/$UID/podman/podman.sock

# Use with Docker clients
export DOCKER_HOST=unix:///run/user/$UID/podman/podman.sock
```

## Examples

### Simple Web Server

```bash
podman run -d \
    --name nginx \
    -p 8080:80 \
    -v ./html:/usr/share/nginx/html:ro \
    nginx:alpine
```

### Database with Volume

```bash
podman volume create postgres-data

podman run -d \
    --name postgres \
    -e POSTGRES_PASSWORD=secret \
    -v postgres-data:/var/lib/postgresql/data \
    -p 5432:5432 \
    postgres:15-alpine
```

### Multi-container Application

```bash
# Create network
podman network create myapp

# Database
podman run -d \
    --name db \
    --network myapp \
    -e POSTGRES_PASSWORD=secret \
    postgres:15-alpine

# Application
podman run -d \
    --name app \
    --network myapp \
    -p 8080:8080 \
    -e DB_HOST=db \
    myapp:latest
```

## Advantages of Podman

### Security
- Rootless by default
- No daemon running as root
- Better isolation
- User namespace separation

### Compatibility
- OCI compliant
- Docker image compatible
- Works with existing Dockerfiles
- Compatible with docker-compose

### Modern Features
- Native systemd integration
- Pod support
- Kubernetes YAML generation
- Better resource management

## Troubleshooting

### Cannot bind privileged port (< 1024)

**Solution 1**: Use port forwarding
```bash
# Map to high port
podman run -p 8080:80 nginx
```

**Solution 2**: Enable rootless port binding
```bash
echo "net.ipv4.ip_unprivileged_port_start=80" | sudo tee /etc/sysctl.d/port.conf
sudo sysctl -p /etc/sysctl.d/port.conf
```

### Podman-compose not found

```bash
pip3 install --user podman-compose
# Or
sudo pip3 install podman-compose
```

### Permission denied

Check subuid/subgid:
```bash
cat /etc/subuid
cat /etc/subgid

# Should have entries for your user
```

### Containers don't start on boot

Enable linger:
```bash
loginctl enable-linger $USER
```

### Socket connection issues

```bash
systemctl --user enable podman.socket
systemctl --user start podman.socket
export DOCKER_HOST=unix:///run/user/$UID/podman/podman.sock
```

## Resources

- [Podman Documentation](https://docs.podman.io/)
- [Podman Desktop](https://podman-desktop.io/)
- [Podman Compose](https://github.com/containers/podman-compose)
- [Migration Guide](https://podman.io/getting-started/migration)
- [Tutorial](https://github.com/containers/podman/tree/main/docs/tutorials)

## When to Use Podman vs Docker

### Use Podman when:
- Security is a priority
- You want rootless containers
- No daemon overhead desired
- Systemd integration needed
- Kubernetes-style pods useful

### Use Docker when:
- Team uses Docker
- Docker-specific features needed
- Ecosystem tool compatibility required
- Docker Desktop features wanted

Both work great for homelab! Choose based on your preferences and requirements.
