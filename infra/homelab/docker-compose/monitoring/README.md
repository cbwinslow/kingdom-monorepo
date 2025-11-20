# Monitoring Stack

Complete monitoring solution with Prometheus, Grafana, Node Exporter, cAdvisor, and Alertmanager.

## Services

- **Prometheus** (port 9090): Metrics collection and storage
- **Grafana** (port 3000): Visualization and dashboards
- **Node Exporter** (port 9100): System metrics
- **cAdvisor** (port 8080): Container metrics
- **Alertmanager** (port 9093): Alert management

## Quick Start

1. Copy the environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and set your credentials:
   ```bash
   vim .env
   ```

3. Start the stack:
   ```bash
   docker-compose up -d
   ```

4. Access the services:
   - Grafana: http://localhost:3000
   - Prometheus: http://localhost:9090
   - Alertmanager: http://localhost:9093

## Initial Setup

### Grafana

1. Login with credentials from `.env` (default: admin/admin)
2. Change the admin password
3. Prometheus datasource is automatically configured
4. Import dashboards:
   - Node Exporter Full: ID 1860
   - Docker Container & Host Metrics: ID 179
   - Prometheus Stats: ID 3662

### Prometheus

1. Check targets: http://localhost:9090/targets
2. All targets should be "UP"
3. Query metrics using PromQL

### Alertmanager

1. Configure notification channels in `alertmanager/alertmanager.yml`
2. Add alert rules in `prometheus/rules/`
3. Restart services: `docker-compose restart`

## Adding Custom Metrics

### Add a new service to monitor

1. Edit `prometheus/prometheus.yml`:
   ```yaml
   scrape_configs:
     - job_name: 'my-service'
       static_configs:
         - targets: ['my-service:port']
   ```

2. Reload Prometheus config:
   ```bash
   curl -X POST http://localhost:9090/-/reload
   ```

### Add alert rules

1. Create a file in `prometheus/rules/`:
   ```yaml
   groups:
     - name: example
       rules:
         - alert: HighCPU
           expr: node_cpu_seconds_total > 80
           for: 5m
           labels:
             severity: warning
           annotations:
             summary: High CPU usage detected
   ```

2. Reload Prometheus config

## Maintenance

### View logs
```bash
docker-compose logs -f [service_name]
```

### Restart services
```bash
docker-compose restart
```

### Stop services
```bash
docker-compose down
```

### Update images
```bash
docker-compose pull
docker-compose up -d
```

### Backup data
```bash
# Backup volumes
docker run --rm -v monitoring_prometheus-data:/data -v $(pwd):/backup alpine tar czf /backup/prometheus-backup.tar.gz /data
docker run --rm -v monitoring_grafana-data:/data -v $(pwd):/backup alpine tar czf /backup/grafana-backup.tar.gz /data
```

## Troubleshooting

### Prometheus targets are down
- Check network connectivity
- Verify service is running
- Check firewall rules

### Grafana can't connect to Prometheus
- Verify Prometheus is running
- Check datasource configuration
- Review Grafana logs

### High memory usage
- Reduce retention time in docker-compose.yml
- Decrease scrape interval
- Limit number of metrics

## Security Recommendations

1. Change default Grafana password
2. Enable authentication for Prometheus
3. Use reverse proxy with SSL
4. Restrict network access
5. Regular backups
6. Update images regularly

## Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Node Exporter](https://github.com/prometheus/node_exporter)
- [Awesome Prometheus Alerts](https://awesome-prometheus-alerts.grep.to/)
