# Productivity Stack

Comprehensive productivity tools including Nextcloud, Home Assistant, Code Server, and BookStack.

## Services

- **Nextcloud** (port 8080): File sync, calendar, contacts, and more
- **Home Assistant** (host mode, port 8123): Home automation platform
- **Code Server** (port 8443): VS Code in the browser
- **BookStack** (port 6875): Documentation and wiki platform

## Quick Start

1. Copy environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with secure passwords:
   ```bash
   vim .env
   ```

3. Create data directories:
   ```bash
   mkdir -p nextcloud-data workspace homeassistant/config bookstack/config code-server/config
   ```

4. Start services:
   ```bash
   docker-compose up -d
   ```

## Service Details

### Nextcloud

**Access**: http://localhost:8080

**Features**:
- File synchronization and sharing
- Calendar and contacts
- Document collaboration
- Task management
- Photo management
- Video calling

**Initial Setup**:
1. Admin credentials from `.env`
2. Database is auto-configured
3. Install recommended apps
4. Configure external storage if needed

**Desktop/Mobile Apps**:
- Download from: https://nextcloud.com/install/#install-clients

### Home Assistant

**Access**: http://localhost:8123

**Features**:
- Home automation hub
- Device integration (lights, sensors, cameras)
- Automation rules
- Energy monitoring
- Voice control integration

**Initial Setup**:
1. Create account on first access
2. Configure location and units
3. Add integrations for your devices
4. Create automations

**Popular Integrations**:
- Philips Hue
- Google Home
- Amazon Alexa
- MQTT
- Zigbee/Z-Wave

### Code Server

**Access**: https://localhost:8443

**Features**:
- Full VS Code experience in browser
- Extensions support
- Terminal access
- Collaborative coding
- Remote development

**Usage**:
1. Login with password from `.env`
2. Open workspace folder
3. Install extensions as needed
4. Use terminal for commands

### BookStack

**Access**: http://localhost:6875

**Features**:
- Documentation platform
- Wiki-style organization
- Markdown support
- Search functionality
- Access control

**Initial Setup**:
1. Default login: admin@admin.com / password
2. Change admin password immediately
3. Configure email settings
4. Create books and pages
5. Set up user permissions

## Integration Examples

### Nextcloud + Home Assistant

1. In Home Assistant, install Nextcloud integration
2. Configure OAuth in Nextcloud
3. Monitor Nextcloud stats in HA dashboard

### Code Server + Nextcloud

Mount Nextcloud data in Code Server:
```yaml
code-server:
  volumes:
    - ./nextcloud-data:/nextcloud:ro
```

## Backup Strategy

### Nextcloud
```bash
# Backup database
docker exec nextcloud-db pg_dump -U nextcloud nextcloud > nextcloud-db.sql

# Backup data
tar czf nextcloud-data-backup.tar.gz nextcloud-data/
```

### Home Assistant
```bash
# Configuration backup
tar czf homeassistant-backup.tar.gz homeassistant/config/
```

### BookStack
```bash
# Database backup
docker exec bookstack-db mysqldump -u bookstack -p bookstackapp > bookstack-db.sql

# Files backup
tar czf bookstack-backup.tar.gz bookstack/config/
```

## Maintenance

### Update Nextcloud
```bash
docker-compose pull nextcloud
docker-compose up -d nextcloud
```

### Clear Nextcloud Cache
```bash
docker exec -u www-data nextcloud php occ maintenance:mode --on
docker exec -u www-data nextcloud php occ files:scan --all
docker exec -u www-data nextcloud php occ maintenance:mode --off
```

### Update Home Assistant
```bash
docker-compose pull homeassistant
docker-compose up -d homeassistant
```

## Troubleshooting

### Nextcloud trusted domain error

Edit `.env` and add your domain/IP:
```bash
NEXTCLOUD_DOMAIN=your-domain.com localhost 192.168.1.100
```

Or use docker exec:
```bash
docker exec -u www-data nextcloud php occ config:system:set trusted_domains 1 --value=your-domain.com
```

### Nextcloud slow performance

1. Enable Redis caching (already configured)
2. Adjust PHP memory limits
3. Enable APCu caching
4. Use external storage sparingly

### Home Assistant devices not found

1. Check network mode is set to `host`
2. Verify devices are on same network
3. Check device compatibility
4. Review HA logs

### Code Server connection issues

1. Check firewall allows port 8443
2. Verify password is correct
3. Try incognito/private browsing
4. Check browser console for errors

## Security Best Practices

1. **Change all default passwords** immediately
2. **Use strong passwords** (generated)
3. **Enable HTTPS** with reverse proxy
4. **Regular updates** of all services
5. **Backup regularly** and test restores
6. **Limit network access** where possible
7. **Enable 2FA** in Nextcloud
8. **Review logs** periodically

## Advanced Configuration

### Enable HTTPS for Nextcloud

Use Nginx Proxy Manager or add to docker-compose:
```yaml
nginx-proxy:
  image: nginxproxymanager/nginx-proxy-manager:latest
  ports:
    - "80:80"
    - "443:443"
```

### Nextcloud Office Integration

Install Collabora Online:
```yaml
collabora:
  image: collabora/code:latest
  ports:
    - "9980:9980"
  environment:
    - domain=nextcloud\\.yourdomain\\.com
```

### Home Assistant Add-ons

Use supervised installation for add-ons, or deploy additional containers:
- Node-RED for visual automation
- ESPHome for ESP device management
- Mosquitto for MQTT broker

## Resources

- [Nextcloud Documentation](https://docs.nextcloud.com/)
- [Home Assistant Documentation](https://www.home-assistant.io/docs/)
- [Code Server Documentation](https://coder.com/docs/code-server/)
- [BookStack Documentation](https://www.bookstackapp.com/docs/)
