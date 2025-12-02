# 📝 Monitoring Stack - Cheat Sheet

Quick reference for common tasks.

---

## 🚀 Quick Deploy

### Local
```bash
git clone https://github.com/ChandanMohonto/devops-monitoring-observability-stack.git
cd devops-monitoring-observability-stack
cp .env.example .env
nano .env  # Edit password
docker-compose -f docker-compose.production.yml up -d
```

### AWS
```bash
# On EC2:
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
# Logout and login
git clone https://github.com/ChandanMohonto/devops-monitoring-observability-stack.git
cd devops-monitoring-observability-stack
cp .env.example .env && nano .env
docker-compose -f docker-compose.production.yml up -d
```

---

## 🔗 Access URLs

```
Grafana:        http://localhost:3000  (admin/your-password)
Prometheus:     http://localhost:9090
Alertmanager:   http://localhost:9093
Node Exporter:  http://localhost:9100/metrics
cAdvisor:       http://localhost:8080
```

For AWS: Replace `localhost` with your EC2 public IP.

---

## 📊 Grafana Dashboard IDs

```
1860  - Node Exporter Full (Best for system metrics)
193   - Docker Container & Host Metrics
2     - Prometheus 2.0 Stats
11074 - Alternative Node Exporter Dashboard
12486 - Alertmanager Dashboard
```

**Import:** Grafana → + → Import → Enter ID → Select Prometheus

---

## 🛠️ Docker Commands

```bash
# View logs
docker-compose -f docker-compose.production.yml logs -f

# Restart all
docker-compose -f docker-compose.production.yml restart

# Stop all
docker-compose -f docker-compose.production.yml down

# Update images
docker-compose -f docker-compose.production.yml pull
docker-compose -f docker-compose.production.yml up -d

# Check status
docker ps
docker stats
```

---

## 🔍 Health Checks

```bash
curl http://localhost:9090/-/healthy    # Prometheus
curl http://localhost:9093/-/healthy    # Alertmanager
curl http://localhost:3000/api/health   # Grafana
curl http://localhost:9100/metrics      # Node Exporter
curl http://localhost:8080/metrics      # cAdvisor
```

---

## 📧 Email Setup (Gmail)

1. Enable 2FA: https://myaccount.google.com/security
2. App Password: https://myaccount.google.com/apppasswords
3. Add to `.env`:
```bash
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_FROM=your-email@gmail.com
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=xxxx-xxxx-xxxx-xxxx  # 16-char app password
EMAIL_MAIN=your-email@gmail.com
```

---

## 💬 Slack Setup

1. Create webhook: https://api.slack.com/messaging/webhooks
2. Add to `.env`:
```bash
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/T.../B.../xxx
SLACK_CHANNEL_CRITICAL=#critical-alerts
```

---

## 🚨 Common PromQL Queries

```promql
# CPU usage %
100 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage %
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Disk usage %
(1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100

# Container memory
container_memory_usage_bytes{name!=""}

# Network traffic
rate(node_network_receive_bytes_total[5m])
```

---

## 🔐 AWS Security Group

**Required Ports:**

| Port | Service | Source |
|------|---------|--------|
| 22 | SSH | Your IP |
| 80 | HTTP | 0.0.0.0/0 |
| 443 | HTTPS | 0.0.0.0/0 |
| 3000 | Grafana | 0.0.0.0/0 |
| 9090 | Prometheus | Internal only |
| 9093 | Alertmanager | Internal only |

---

## 🔄 Backup & Restore

```bash
# Backup
docker run --rm \
  -v monitoring_prometheus-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/backup-$(date +%Y%m%d).tar.gz /data

# Restore
docker run --rm \
  -v monitoring_prometheus-data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/backup-YYYYMMDD.tar.gz -C /
```

---

## 🆘 Troubleshooting

### Grafana not accessible
```bash
docker logs monitoring-stack
sudo ufw allow 3000/tcp  # If firewall blocking
```

### Prometheus targets DOWN
```bash
docker-compose -f docker-compose.production.yml restart
docker network inspect monitoring_observability
```

### Email alerts not working
```bash
# Check SMTP
docker exec -it monitoring-stack sh
nc -zv smtp.gmail.com 587

# Check logs
docker logs monitoring-stack | grep alertmanager
```

### High memory usage
```bash
# Edit .env
PROMETHEUS_RETENTION=7d

# Restart
docker-compose -f docker-compose.production.yml restart
```

---

## 📦 Image Info

**Registry:** `ghcr.io/chandanmohonto/devops-monitoring-observability-stack:latest`

**Size:** ~450MB

**Platforms:** linux/amd64, linux/arm64

**Includes:**
- Prometheus 2.48.0
- Grafana 10.2.3
- Alertmanager 0.26.0

---

## 🎯 Production Checklist

- [ ] Change Grafana password
- [ ] Configure email alerts
- [ ] Configure Slack (optional)
- [ ] Import dashboards (1860, 193)
- [ ] Set up HTTPS (nginx + certbot)
- [ ] Configure firewall
- [ ] Test alerts
- [ ] Set up backups
- [ ] Monitor for 1 week
- [ ] Tune alert thresholds

---

## 📞 Support

- **Repo:** https://github.com/ChandanMohonto/devops-monitoring-observability-stack
- **Issues:** https://github.com/ChandanMohonto/devops-monitoring-observability-stack/issues
- **Email:** qa@mykey.co.it

---

**Quick Links:**
- [Full Documentation](README.md)
- [Deployment Guide](QUICKSTART.md)
- [AWS Deployment](DEPLOYMENT_GUIDE.md)
