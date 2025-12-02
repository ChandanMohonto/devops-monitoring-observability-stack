# 🚀 DevOps Monitoring & Observability Stack

Lightweight all-in-one monitoring solution with **Prometheus**, **Grafana**, **Alertmanager**, **Node Exporter**, and **cAdvisor**.

![GitHub Workflow Status](https://github.com/ChandanMohonto/devops-monitoring-observability-stack/actions/workflows/docker-build.yml/badge.svg)

## 📋 Components

- **Prometheus** - Metrics collection and time-series database
- **Grafana** - Visualization and dashboards
- **Alertmanager** - Alert routing (Email + Slack)
- **Node Exporter** - System/host metrics
- **cAdvisor** - Container metrics

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│   All-in-One Container (Alpine-based)  │
│  ┌──────────┐ ┌──────────┐ ┌─────────┐ │
│  │Prometheus│ │Grafana   │ │Alertmgr │ │
│  │  :9090   │ │  :3000   │ │ :9093   │ │
│  └──────────┘ └──────────┘ └─────────┘ │
└─────────────────────────────────────────┘
         │              │
    ┌────┴────┐    ┌────┴────┐
    │  Node   │    │cAdvisor │
    │Exporter │    │ :8080   │
    │ :9100   │    └─────────┘
    └─────────┘
```

## 🚀 Quick Start

### Local Development

```bash
# Clone repository
git clone git@github.com:ChandanMohonto/devops-monitoring-observability-stack.git
cd devops-monitoring-observability-stack

# Copy and configure environment variables
cp .env .env.local
nano .env.local  # Edit with your credentials

# Start with docker-compose (separate containers)
docker-compose up -d

# OR use production image from GHCR
docker-compose -f docker-compose.production.yml up -d
```

### Access Services

- **Grafana**: http://localhost:3000 (admin/your-password)
- **Prometheus**: http://localhost:9090
- **Alertmanager**: http://localhost:9093
- **Node Exporter**: http://localhost:9100/metrics
- **cAdvisor**: http://localhost:8080

## 🔧 Configuration

### Environment Variables

Create `.env` file with your configuration:

```bash
# Grafana Admin
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=YourSecurePassword

# SMTP Configuration (Gmail example)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_FROM=monitoring@yourdomain.com
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password

# Email Recipients
EMAIL_MAIN=team@yourdomain.com
EMAIL_CRITICAL=oncall@yourdomain.com,manager@yourdomain.com
EMAIL_WARNING=team@yourdomain.com
EMAIL_INFRA=devops@yourdomain.com

# Slack Integration
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
SLACK_CHANNEL_CRITICAL=#critical-alerts
SLACK_CHANNEL_WARNING=#monitoring-alerts
SLACK_CHANNEL_INFRA=#infrastructure

# Prometheus
PROMETHEUS_RETENTION=15d
```

### Gmail App Password Setup

1. Enable 2-Factor Authentication in your Google Account
2. Go to: https://myaccount.google.com/apppasswords
3. Create app password for "Mail"
4. Use generated password in `SMTP_PASSWORD`

### Slack Webhook Setup

1. Go to: https://api.slack.com/messaging/webhooks
2. Create incoming webhook
3. Copy webhook URL to `SLACK_WEBHOOK_URL`

## 📦 Deployment Options

### Option 1: Separate Containers (Development)

```bash
docker-compose up -d
```

**Pros:** Easy debugging, can restart individual services
**Cons:** More containers to manage

### Option 2: All-in-One Container (Production)

```bash
docker-compose -f docker-compose.production.yml up -d
```

**Pros:** Single container, lightweight (~450MB), easier deployment
**Cons:** All services restart together

### Option 3: Build Your Own Image

```bash
# Build image
docker build -t my-monitoring-stack .

# Run container
docker run -d \
  --name monitoring \
  -p 9090:9090 -p 9093:9093 -p 3000:3000 \
  -e GRAFANA_ADMIN_USER=admin \
  -e GRAFANA_ADMIN_PASSWORD=secure123 \
  -e SMTP_HOST=smtp.gmail.com \
  -e SMTP_USERNAME=your-email@gmail.com \
  -e SMTP_PASSWORD=your-app-password \
  -e EMAIL_MAIN=admin@example.com \
  my-monitoring-stack
```

## ☁️ AWS Deployment

### Using EC2

```bash
# SSH to EC2 instance
ssh -i your-key.pem ec2-user@your-instance-ip

# Install Docker
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Clone and deploy
git clone git@github.com:ChandanMohonto/devops-monitoring-observability-stack.git
cd devops-monitoring-observability-stack
cp .env.example .env
nano .env  # Configure

docker-compose -f docker-compose.production.yml up -d
```

### Using ECS/Fargate

```bash
# Tag and push to GHCR
docker pull ghcr.io/chandanmohonto/devops-monitoring-observability-stack:latest

# Create ECS task definition with environment variables
# Deploy to Fargate cluster
```

### Security Group Settings

Open these ports:
- `3000` - Grafana (HTTPS recommended)
- `9090` - Prometheus (internal only)
- `9093` - Alertmanager (internal only)

## 🔍 Monitoring Targets

The stack automatically monitors:

### System Metrics (via Node Exporter)
- CPU usage
- Memory usage
- Disk space
- Network I/O
- System load

### Container Metrics (via cAdvisor)
- Container CPU usage
- Container memory usage
- Container network I/O
- Container filesystem usage

### Application Metrics (via Prometheus)
- Service uptime
- Response times
- Error rates
- Custom metrics

## 🚨 Alert Rules

Pre-configured alerts:

| Alert | Severity | Condition |
|-------|----------|-----------|
| HighCPUUsage | Warning | CPU > 80% for 5min |
| CriticalCPUUsage | Critical | CPU > 95% for 2min |
| HighMemoryUsage | Warning | Memory > 80% for 5min |
| CriticalMemoryUsage | Critical | Memory > 95% for 2min |
| DiskSpaceWarning | Warning | Disk > 80% for 10min |
| DiskSpaceCritical | Critical | Disk > 90% for 5min |
| NodeDown | Critical | Node down for 2min |
| ServiceDown | Critical | Service down for 2min |

## 🔄 CI/CD Pipeline

GitHub Actions automatically:
1. ✅ Builds Docker image on push
2. ✅ Runs security scans (Trivy)
3. ✅ Tests health checks
4. ✅ Pushes to GHCR
5. ✅ Creates multi-arch images (amd64/arm64)

## 📊 Grafana Dashboards

Import these dashboard IDs:

- **Node Exporter Full**: 1860
- **Docker Container Metrics**: 193
- **Prometheus Stats**: 2
- **Alertmanager**: 9578

## 🛠️ Maintenance

### View Logs

```bash
# All-in-one container
docker logs monitoring-stack

# Specific service (docker-compose)
docker logs prometheus
docker logs grafana
docker logs alertmanager
```

### Backup Data

```bash
# Backup volumes
docker run --rm \
  -v monitoring_prometheus-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/prometheus-backup.tar.gz /data

# Restore
docker run --rm \
  -v monitoring_prometheus-data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/prometheus-backup.tar.gz -C /
```

### Update Image

```bash
# Pull latest
docker pull ghcr.io/chandanmohonto/devops-monitoring-observability-stack:latest

# Restart
docker-compose -f docker-compose.production.yml up -d
```

## 🧪 Testing

```bash
# Test Prometheus
curl http://localhost:9090/-/healthy

# Test Alertmanager
curl http://localhost:9093/-/healthy

# Test Grafana
curl http://localhost:3000/api/health

# Test Node Exporter
curl http://localhost:9100/metrics

# Test cAdvisor
curl http://localhost:8080/metrics
```

## 🐛 Troubleshooting

### Prometheus can't scrape targets

Check prometheus.yml targets match your service names:
```yaml
scrape_configs:
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']  # Docker network name
```

### Alertmanager not sending emails

1. Verify SMTP credentials in `.env`
2. Check Gmail app password is correct
3. View alertmanager logs: `docker logs alertmanager`

### Grafana can't connect to Prometheus

Update datasource URL in `grafana/provisioning/datasources/prometheus.yml`:
```yaml
url: http://localhost:9090  # For all-in-one
url: http://prometheus:9090  # For docker-compose
```

## 📝 Production Checklist

- [ ] Change default Grafana admin password
- [ ] Configure SMTP with valid credentials
- [ ] Set up Slack webhooks
- [ ] Configure proper email recipients
- [ ] Enable HTTPS with reverse proxy (nginx/Caddy)
- [ ] Set up persistent volumes
- [ ] Configure backup strategy
- [ ] Review and adjust alert thresholds
- [ ] Set up log retention policies
- [ ] Configure firewall rules
- [ ] Enable authentication on Prometheus/Alertmanager

## 🔐 Security Best Practices

1. **Never commit `.env` file to git**
2. Use strong passwords for Grafana
3. Enable HTTPS with Let's Encrypt
4. Restrict Prometheus/Alertmanager access
5. Use secrets management (AWS Secrets Manager, Vault)
6. Regular security updates
7. Monitor access logs

## 📄 License

MIT License - See LICENSE file

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📞 Support

- **Issues**: https://github.com/ChandanMohonto/devops-monitoring-observability-stack/issues
- **Email**: qa@mykey.co.it

---

**Made with ❤️ for DevOps Engineers**
