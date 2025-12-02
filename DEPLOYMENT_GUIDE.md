# 🚀 Quick Deployment Guide

## ✅ Code Pushed Successfully!

Your monitoring stack is now on GitHub and building automatically!

## 📊 Check Build Status

1. **GitHub Actions**: https://github.com/ChandanMohonto/devops-monitoring-observability-stack/actions
2. **Container Registry**: https://github.com/ChandanMohonto?tab=packages

Wait for the build to complete (3-5 minutes) ⏳

## 🧪 Test Locally

### Option 1: Test Development Setup (Separate Containers)

```bash
# Use separate containers for each service
docker-compose up -d

# Check status
docker ps

# Access services
# Grafana: http://localhost:3000 (admin/Admin123!)
# Prometheus: http://localhost:9090
# Alertmanager: http://localhost:9093
# Node Exporter: http://localhost:9100
# cAdvisor: http://localhost:8080
```

### Option 2: Test Production Image (All-in-One + Node Exporter + cAdvisor)

**After GitHub Actions build completes:**

```bash
# Pull from GHCR
docker pull ghcr.io/chandanmohonto/devops-monitoring-observability-stack:latest

# Deploy with production config
docker-compose -f docker-compose.production.yml up -d

# Check all services
docker ps

# Health checks
curl http://localhost:9090/-/healthy  # Prometheus
curl http://localhost:9093/-/healthy  # Alertmanager
curl http://localhost:3000/api/health # Grafana
curl http://localhost:9100/metrics    # Node Exporter
curl http://localhost:8080/metrics    # cAdvisor
```

## 🔍 Verify Monitoring Stack

### 1. Check Prometheus Targets

Go to: http://localhost:9090/targets

Should see all **UP**:
- ✅ prometheus (localhost:9090)
- ✅ alertmanager (alertmanager:9093)
- ✅ grafana (grafana:3000)
- ✅ node-exporter (node-exporter:9100)
- ✅ cadvisor (cadvisor:8080)

### 2. Check Grafana

1. Go to: http://localhost:3000
2. Login: `admin` / `Admin123!` (from .env)
3. Go to: Configuration → Data Sources
4. Verify Prometheus is connected ✅

### 3. Import Dashboards

In Grafana:
1. Click "+" → Import
2. Import these IDs:
   - **1860** - Node Exporter Full
   - **193** - Docker Container Metrics
   - **2** - Prometheus Stats

### 4. Test Alerting

```bash
# View alert rules
curl http://localhost:9090/api/v1/rules | jq

# Check alertmanager
curl http://localhost:9093/api/v2/status | jq

# Trigger test alert (high CPU simulation)
# Wait and check email/Slack
```

## ☁️ Deploy to AWS EC2

### Step 1: Launch EC2 Instance

- **AMI**: Amazon Linux 2023 or Ubuntu 22.04
- **Type**: t3.medium (2 vCPU, 4GB RAM minimum)
- **Storage**: 30GB GP3
- **Security Groups**:
  - SSH: 22 (your IP)
  - HTTP: 80 (0.0.0.0/0)
  - HTTPS: 443 (0.0.0.0/0)
  - Grafana: 3000 (0.0.0.0/0 or your IP)
  - Prometheus: 9090 (internal only)
  - Alertmanager: 9093 (internal only)

### Step 2: Connect and Install Docker

```bash
# SSH to EC2
ssh -i your-key.pem ec2-user@<EC2-PUBLIC-IP>

# Update system
sudo yum update -y

# Install Docker
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify
docker --version
docker-compose --version
```

### Step 3: Deploy Monitoring Stack

```bash
# Clone repository
git clone https://github.com/ChandanMohonto/devops-monitoring-observability-stack.git
cd devops-monitoring-observability-stack

# Create production .env
cp .env.example .env
nano .env  # Edit with your credentials

# Pull and run
docker-compose -f docker-compose.production.yml up -d

# Check status
docker ps
docker logs monitoring-stack
```

### Step 4: Configure Nginx Reverse Proxy (HTTPS)

```bash
# Install Nginx
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

# Install Certbot for SSL
sudo yum install certbot python3-certbot-nginx -y

# Get SSL certificate
sudo certbot --nginx -d monitoring.yourdomain.com

# Nginx config for Grafana
sudo nano /etc/nginx/conf.d/grafana.conf
```

Add:
```nginx
server {
    listen 80;
    server_name monitoring.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name monitoring.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/monitoring.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/monitoring.yourdomain.com/privkey.pem;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# Reload Nginx
sudo nginx -t
sudo systemctl reload nginx
```

## 🏭 Production Deployment Checklist

Before going to production:

### Security
- [ ] Changed Grafana admin password
- [ ] Configured firewall rules (only 80/443 public)
- [ ] Set up HTTPS with Let's Encrypt
- [ ] Restricted Prometheus/Alertmanager to internal only
- [ ] Rotated all exposed credentials

### Monitoring
- [ ] Verified all Prometheus targets are UP
- [ ] Tested email alerts
- [ ] Tested Slack notifications
- [ ] Imported Grafana dashboards
- [ ] Set up alert thresholds for your environment

### Backups
- [ ] Configured volume backups
- [ ] Tested restore procedure
- [ ] Set up automated backups (daily)

### High Availability (Optional)
- [ ] Set up load balancer
- [ ] Configure multiple replicas
- [ ] Set up persistent storage (EBS/EFS)

## 🔧 Maintenance Commands

```bash
# View logs
docker logs monitoring-stack -f
docker logs node-exporter -f
docker logs cadvisor -f

# Restart services
docker-compose -f docker-compose.production.yml restart

# Update to latest image
docker-compose -f docker-compose.production.yml pull
docker-compose -f docker-compose.production.yml up -d

# Backup data
docker run --rm -v monitoring_prometheus-data:/data -v $(pwd):/backup alpine tar czf /backup/prometheus-backup-$(date +%Y%m%d).tar.gz /data

# Stop all
docker-compose -f docker-compose.production.yml down

# Stop and remove volumes (DESTRUCTIVE!)
docker-compose -f docker-compose.production.yml down -v
```

## 📊 Monitoring Best Practices

1. **Set Alert Thresholds Based on Your System**
   - Adjust CPU/memory alerts in `alert-rules.yml`
   - Monitor baseline for 1 week
   - Set thresholds at 80% of max observed

2. **Regular Maintenance**
   - Weekly: Review dashboards
   - Monthly: Update images
   - Quarterly: Review and tune alerts

3. **Backup Strategy**
   - Daily: Prometheus data
   - Weekly: Grafana dashboards
   - Monthly: Full system backup

## 🆘 Troubleshooting

### Services Not Starting

```bash
# Check logs
docker logs monitoring-stack

# Check disk space
df -h

# Check memory
free -h

# Restart
docker-compose -f docker-compose.production.yml restart
```

### Prometheus Can't Scrape Targets

- Check docker network: `docker network ls`
- Verify service names match in prometheus.yml
- Check firewall rules

### Alertmanager Not Sending Emails

1. Verify SMTP settings in .env
2. Test SMTP connection:
```bash
docker exec -it monitoring-stack sh
nc -zv smtp.gmail.com 587
```
3. Check Gmail app password is correct
4. Review logs: `docker logs monitoring-stack | grep alertmanager`

### Grafana Can't Connect to Prometheus

- Update datasource URL to match your setup
- For all-in-one: `http://localhost:9090`
- For docker-compose: `http://prometheus:9090`

## 📞 Support

- **GitHub Issues**: https://github.com/ChandanMohonto/devops-monitoring-observability-stack/issues
- **Documentation**: Check README.md

---

**🎉 Your monitoring stack is production-ready!**
