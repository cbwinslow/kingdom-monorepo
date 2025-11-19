# Monitoring Stack

A comprehensive monitoring stack with metrics, logs, traces, and alerting capabilities.

## Components

- **Prometheus** (port 9090) - Metrics collection and storage
- **Grafana** (port 3000) - Metrics visualization and dashboards
- **Loki** (port 3100) - Log aggregation system
- **Promtail** - Log shipper for Loki
- **Node Exporter** (port 9100) - Host system metrics
- **cAdvisor** (port 8080) - Container metrics
- **AlertManager** (port 9093) - Alert routing and management
- **Tempo** (port 3200) - Distributed tracing backend
- **Jaeger** (port 16686) - Distributed tracing UI
- **Elasticsearch** (port 9200) - Search and analytics engine
- **Kibana** (port 5601) - Elasticsearch visualization
- **Uptime Kuma** (port 3001) - Uptime monitoring

## Quick Start

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

## Access URLs

- Grafana: http://localhost:3000 (admin/admin)
- Prometheus: http://localhost:9090
- AlertManager: http://localhost:9093
- Jaeger UI: http://localhost:16686
- Kibana: http://localhost:5601
- cAdvisor: http://localhost:8080
- Uptime Kuma: http://localhost:3001

## Configuration Files

### Prometheus Configuration

Create `prometheus/prometheus.yml`:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: 'docker-monitoring'

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']

rule_files:
  - "alerts.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

  - job_name: 'docker'
    static_configs:
      - targets: ['host.docker.internal:9323']
```

### Prometheus Alerts

Create `prometheus/alerts.yml`:

```yaml
groups:
  - name: instance
    interval: 30s
    rules:
      - alert: InstanceDown
        expr: up == 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Instance {{ $labels.instance }} down"
          description: "{{ $labels.instance }} has been down for more than 5 minutes"

      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage on {{ $labels.instance }}"
          description: "CPU usage is above 80% for 5 minutes"

      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 90
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage on {{ $labels.instance }}"
          description: "Memory usage is above 90%"

      - alert: DiskSpaceRunningLow
        expr: (node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100 < 10
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Disk space running low on {{ $labels.instance }}"
          description: "Less than 10% disk space remaining"
```

### Loki Configuration

Create `loki/loki-config.yml`:

```yaml
auth_enabled: false

server:
  http_listen_port: 3100
  grpc_listen_port: 9096

common:
  path_prefix: /loki
  storage:
    filesystem:
      chunks_directory: /loki/chunks
      rules_directory: /loki/rules
  replication_factor: 1
  ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: inmemory

schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

ruler:
  alertmanager_url: http://alertmanager:9093
```

### Promtail Configuration

Create `promtail/promtail-config.yml`:

```yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  - job_name: system
    static_configs:
      - targets:
          - localhost
        labels:
          job: varlogs
          __path__: /var/log/*log

  - job_name: docker
    docker_sd_configs:
      - host: unix:///var/run/docker.sock
        refresh_interval: 5s
    relabel_configs:
      - source_labels: ['__meta_docker_container_name']
        regex: '/(.*)'
        target_label: 'container'
```

### AlertManager Configuration

Create `alertmanager/config.yml`:

```yaml
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname', 'cluster']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
  receiver: 'default'
  routes:
    - match:
        severity: critical
      receiver: critical

receivers:
  - name: 'default'
    webhook_configs:
      - url: 'http://webhook-receiver:5001/webhook'
        send_resolved: true

  - name: 'critical'
    webhook_configs:
      - url: 'http://webhook-receiver:5001/webhook/critical'
        send_resolved: true

inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'cluster']
```

### Tempo Configuration

Create `tempo/tempo.yaml`:

```yaml
server:
  http_listen_port: 3200

distributor:
  receivers:
    otlp:
      protocols:
        http:
        grpc:

ingester:
  max_block_duration: 5m

compactor:
  compaction:
    block_retention: 1h

storage:
  trace:
    backend: local
    local:
      path: /tmp/tempo/traces
    wal:
      path: /tmp/tempo/wal
```

### Grafana Provisioning

Create `grafana/provisioning/datasources/datasources.yml`:

```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true

  - name: Loki
    type: loki
    access: proxy
    url: http://loki:3100
    editable: true

  - name: Tempo
    type: tempo
    access: proxy
    url: http://tempo:3200
    editable: true

  - name: Elasticsearch
    type: elasticsearch
    access: proxy
    url: http://elasticsearch:9200
    database: "[logs-]YYYY.MM.DD"
    jsonData:
      esVersion: "8.0.0"
      timeField: "@timestamp"
    editable: true
```

## Usage Examples

### Query Prometheus Metrics

```bash
# Current CPU usage
curl 'http://localhost:9090/api/v1/query?query=100-(avg(irate(node_cpu_seconds_total{mode="idle"}[5m]))*100)'

# Memory usage
curl 'http://localhost:9090/api/v1/query?query=node_memory_MemAvailable_bytes'

# Container CPU usage
curl 'http://localhost:9090/api/v1/query?query=rate(container_cpu_usage_seconds_total[5m])'
```

### Query Loki Logs

```bash
# Get logs from a container
curl -G -s "http://localhost:3100/loki/api/v1/query_range" \
  --data-urlencode 'query={container="my-container"}' \
  --data-urlencode 'limit=100'

# Search for error logs
curl -G -s "http://localhost:3100/loki/api/v1/query_range" \
  --data-urlencode 'query={job="docker"} |= "error"' \
  --data-urlencode 'limit=100'
```

### Send Traces to Tempo

```python
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)

otlp_exporter = OTLPSpanExporter(endpoint="http://localhost:4317", insecure=True)
span_processor = BatchSpanProcessor(otlp_exporter)
trace.get_tracer_provider().add_span_processor(span_processor)

with tracer.start_as_current_span("my-operation"):
    # Your code here
    pass
```

## Monitoring Best Practices

1. **Set appropriate retention periods** for metrics and logs
2. **Configure alerting rules** based on your SLAs
3. **Use labels consistently** across all metrics
4. **Monitor the monitoring stack** itself
5. **Regular backup** of configuration and data
6. **Use dashboards** for different use cases (infrastructure, application, business)
7. **Implement log rotation** to manage disk usage
8. **Set up authentication** in production environments
9. **Use TLS/SSL** for all external connections
10. **Regular review** of alert rules and thresholds

## Troubleshooting

### Prometheus not scraping targets

```bash
# Check Prometheus targets
curl http://localhost:9090/api/v1/targets

# Check Prometheus configuration
docker exec prometheus promtool check config /etc/prometheus/prometheus.yml
```

### Grafana not showing data

1. Verify datasource connection in Grafana UI
2. Check Prometheus/Loki logs for errors
3. Verify network connectivity between containers

### High disk usage

```bash
# Check disk usage
docker system df -v

# Clean up old data
docker-compose down
docker volume prune
```

### Container not starting

```bash
# Check logs
docker-compose logs [service-name]

# Check container status
docker-compose ps
```

## Scaling Considerations

For production deployments:

1. **Use external storage** (S3, GCS) for Loki and Tempo
2. **Deploy multiple Prometheus instances** with federation
3. **Use Thanos** or **Cortex** for long-term Prometheus storage
4. **Deploy Loki in microservices mode** for high throughput
5. **Use external databases** (PostgreSQL) for Grafana
6. **Implement proper resource limits** for all containers
7. **Use Kubernetes** for orchestration and auto-scaling

## Security Hardening

```yaml
# Add to services for security
security_opt:
  - no-new-privileges:true
read_only: true
tmpfs:
  - /tmp
cap_drop:
  - ALL
cap_add:
  - NET_BIND_SERVICE
```

## Additional Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Loki Documentation](https://grafana.com/docs/loki/)
- [Tempo Documentation](https://grafana.com/docs/tempo/)
- [Jaeger Documentation](https://www.jaegertracing.io/docs/)
