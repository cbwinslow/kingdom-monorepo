# Media Server Stack

Complete media server solution with Plex/Jellyfin, Sonarr, Radarr, Transmission, and Jackett.

## Services

- **Plex** (host network mode): Media server with transcoding
- **Jellyfin** (port 8096): Open-source media server alternative
- **Sonarr** (port 8989): TV series management
- **Radarr** (port 7878): Movie management
- **Transmission** (port 9091): BitTorrent client
- **Jackett** (port 9117): Torrent indexer proxy

## Quick Start

1. Copy environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and configure paths:
   ```bash
   vim .env
   ```

3. Create media directories:
   ```bash
   mkdir -p media/{tv,movies,music} downloads
   ```

4. Start services:
   ```bash
   docker-compose up -d
   ```

## Initial Setup

### Plex
1. Access: http://localhost:32400/web
2. Create account or sign in
3. Add libraries pointing to `/tv`, `/movies`, `/music`
4. Configure remote access if needed

### Jellyfin
1. Access: http://localhost:8096
2. Complete initial setup wizard
3. Add libraries pointing to `/data/tvshows`, `/data/movies`
4. Configure users and preferences

### Sonarr
1. Access: http://localhost:8989
2. Settings → Media Management → Add root folder: `/tv`
3. Settings → Indexers → Add Jackett indexers
4. Settings → Download Clients → Add Transmission
5. Add series to monitor

### Radarr
1. Access: http://localhost:7878
2. Settings → Media Management → Add root folder: `/movies`
3. Settings → Indexers → Add Jackett indexers
4. Settings → Download Clients → Add Transmission
5. Add movies to monitor

### Transmission
1. Access: http://localhost:9091
2. Login with credentials from `.env`
3. Configure download settings
4. Note: Downloads go to `/downloads`

### Jackett
1. Access: http://localhost:9117
2. Add indexers (search for your preferred trackers)
3. Copy API key for Sonarr/Radarr
4. Test each indexer

## Integration

### Connect Sonarr/Radarr to Transmission

1. In Sonarr/Radarr: Settings → Download Clients → Add
2. Choose Transmission
3. Host: `transmission`
4. Port: `9091`
5. Username/Password from `.env`
6. Category: `tv` or `movies`

### Connect Sonarr/Radarr to Jackett

1. Get Jackett API key from Jackett dashboard
2. In Sonarr/Radarr: Settings → Indexers → Add → Torznab → Custom
3. Copy Torznab Feed URL from Jackett
4. Paste API key
5. Test and save

## Directory Structure

```
media/
├── config/              # Service configurations
│   ├── plex/
│   ├── jellyfin/
│   ├── sonarr/
│   ├── radarr/
│   ├── transmission/
│   └── jackett/
├── media/               # Media files
│   ├── tv/
│   ├── movies/
│   └── music/
└── downloads/           # Download directory
    ├── complete/
    └── incomplete/
```

## Permissions

Ensure proper permissions for media directories:
```bash
sudo chown -R 1000:1000 media downloads
sudo chmod -R 755 media downloads
```

## Backup

Important directories to backup:
- `./plex/config/Library/Application Support/Plex Media Server/`
- `./jellyfin/config/`
- `./sonarr/config/`
- `./radarr/config/`

## Troubleshooting

### Plex not accessible
- Check firewall allows port 32400
- Verify network_mode: host is working
- Check Plex server logs

### Permission denied errors
- Verify PUID/PGID match your user
- Check directory ownership
- Ensure directories exist

### Sonarr/Radarr can't download
- Verify Transmission is running
- Check download client connection
- Verify indexers are working
- Check Jackett connectivity

### Slow transcoding
- Consider hardware transcoding (Plex Pass)
- Adjust quality settings
- Check CPU usage

## Advanced Configuration

### Hardware Transcoding (Intel QuickSync)

Add to Plex service:
```yaml
devices:
  - /dev/dri:/dev/dri
```

### VPN for Transmission

Use `haugene/transmission-openvpn` image instead:
```yaml
transmission:
  image: haugene/transmission-openvpn:latest
  environment:
    - OPENVPN_PROVIDER=YOUR_PROVIDER
    - OPENVPN_USERNAME=username
    - OPENVPN_PASSWORD=password
```

### Reverse Proxy

Use Nginx Proxy Manager or Traefik to access services via subdomains:
- plex.homelab.local
- jellyfin.homelab.local
- sonarr.homelab.local

## Resources

- [Plex Documentation](https://support.plex.tv/)
- [Jellyfin Documentation](https://jellyfin.org/docs/)
- [Sonarr Wiki](https://wiki.servarr.com/sonarr)
- [Radarr Wiki](https://wiki.servarr.com/radarr)
- [r/selfhosted](https://reddit.com/r/selfhosted)
