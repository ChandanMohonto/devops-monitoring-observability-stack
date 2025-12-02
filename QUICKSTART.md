# 🚀 Quick Start Guide - Monitoring Stack

Simple guide to run the complete monitoring solution locally or on AWS.

## 📋 What You Get

- **Prometheus** - Metrics collection (http://localhost:9090)
- **Grafana** - Dashboards (http://localhost:3000)
- **Alertmanager** - Email/Slack alerts (http://localhost:9093)
- **Node Exporter** - System metrics (http://localhost:9100)
- **cAdvisor** - Container metrics (http://localhost:8080)

---

## 🏠 Run Locally (5 Minutes)

### Prerequisites

- Docker installed ([Get Docker](https://docs.docker.com/get-docker/))
- Docker Compose installed (included with Docker Desktop)

### Step 1: Clone Repository

```bash
git clone https://github.com/ChandanMohonto/devops-monitoring-observability-stack.git
cd devops-monitoring-observability-stack
```

### Step 2: Configure Environment

```bash
# Copy example config
cp .env.example .env

# Edit configuration (use any text editor)
nano .env   # Linux/Mac
notepad .env  # Windows
```

**Minimum required changes in `.env`:**

```bash
# Change the Grafana password
GRAFANA_ADMIN_PASSWORD=YourSecurePassword123

# Add your email (optional, for alerts)
SMTP_FROM=your-email@gmail.com
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-gmail-app-password
EMAIL_MAIN=your-email@gmail.com
```

### Step 3: Start Everything

```bash
# Pull and start all services
docker-compose -f docker-compose.production.yml up -d

# Check status
docker ps
```

### Step 4: Access Services

| Service | URL | Login |
|---------|-----|-------|
| **Grafana** | http://localhost:3000 | admin / (your password) |
| **Prometheus** | http://localhost:9090 | No login |
| **Alertmanager** | http://localhost:9093 | No login |
| **Node Exporter** | http://localhost:9100/metrics | No login |
| **cAdvisor** | http://localhost:8080 | No login |

### Step 5: Import Dashboards

1. Go to Grafana: http://localhost:3000
2. Login with: `admin` / `your-password`
3. Click **+** → **Import**
4. Import these dashboard IDs:
   - **1860** - Node Exporter Full (system metrics)
   - **193** - Docker Container & Host Metrics
   - **2** - Prometheus 2.0 Stats

**Done!** Your monitoring stack is running! 🎉

---

## ☁️ Deploy on AWS (15 Minutes)

### Step 1: Launch EC2 Instance

**Recommended Settings:**
- **AMI**: Ubuntu 22.04 LTS or Amazon Linux 2023
- **Instance Type**: `t3.medium` (2 vCPU, 4GB RAM)
- **Storage**: 30GB GP3
- **Security Group**: Open these ports
  - SSH (22) - Your IP only
  - HTTP (80) - Anywhere
  - HTTPS (443) - Anywhere
  - Custom TCP (3000) - Anywhere (for Grafana)

### Step 2: Connect to EC2

```bash
# SSH to your instance
ssh -i your-key.pem ubuntu@<YOUR-EC2-PUBLIC-IP>

# Or for Amazon Linux
ssh -i your-key.pem ec2-user@<YOUR-EC2-PUBLIC-IP>
```

### Step 3: Install Docker

**For Ubuntu 22.04:**

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Logout and login again
exit
```

**For Amazon Linux 2023:**

```bash
# Update system
sudo yum update -y

# Install Docker
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Logout and login again
exit
```

### Step 4: Deploy Monitoring Stack

```bash
# SSH back to EC2
ssh -i your-key.pem ubuntu@<YOUR-EC2-PUBLIC-IP>

# Clone repository
git clone https://github.com/ChandanMohonto/devops-monitoring-observability-stack.git
cd devops-monitoring-observability-stack

# Configure environment
cp .env.example .env
nano .env  # Edit with your settings

# Start services
docker-compose -f docker-compose.production.yml up -d

# Verify all running
docker ps
```

### Step 5: Access from Browser

Open in your browser:
```
http://<YOUR-EC2-PUBLIC-IP>:3000
```

Login: `admin` / `your-password`

---

## 🔧 Configuration Guide

### Gmail App Password Setup (For Email Alerts)

1. Enable 2-Factor Authentication on your Google Account
2. Go to: https://myaccount.google.com/apppasswords
3. Select "Mail" and your device
4. Copy the 16-character password
5. Use it in `.env` as `SMTP_PASSWORD`

### Slack Webhook Setup (For Slack Alerts)

1. Go to: https://api.slack.com/messaging/webhooks
2. Create a new webhook
3. Select your channel (e.g., #monitoring)
4. Copy the webhook URL
5. Add to `.env` as `SLACK_WEBHOOK_URL`

### Environment Variables Explained

```bash
# Grafana Admin
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=ChangeMe123!  # Change this!

# Email Settings (Gmail example)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_FROM=monitoring@yourdomain.com
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password  # Gmail app password

# Who receives alerts
EMAIL_MAIN=team@company.com
EMAIL_CRITICAL=oncall@company.com,manager@company.com
EMAIL_WARNING=team@company.com
EMAIL_INFRA=devops@company.com

# Slack (optional)
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
SLACK_CHANNEL_CRITICAL=#critical-alerts
SLACK_CHANNEL_WARNING=#monitoring
SLACK_CHANNEL_INFRA=#infrastructure
```

---

## 📊 Using Grafana

### Import Pre-built Dashboards

1. Login to Grafana
2. Click **+** (left sidebar) → **Import**
3. Enter dashboard ID:

**Recommended Dashboards:**

| ID | Name | Description |
|----|------|-------------|
| 1860 | Node Exporter Full | Complete system metrics |
| 193 | Docker & Host Metrics | Container monitoring |
| 2 | Prometheus Stats | Prometheus health |
| 11074 | Node Exporter for Prometheus | Alternative system dashboard |
| 12486 | Alertmanager | Alert management |

4. Select **Prometheus** as data source
5. Click **Import**

### Create Custom Dashboard

1. Click **+** → **Dashboard** → **Add new panel**
2. Write PromQL query, example:
   ```promql
   # CPU usage
   100 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

   # Memory usage
   (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

   # Disk usage
   (1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100
   ```
3. Save dashboard

---

## 🚨 Alerts Configuration

### Pre-configured Alerts

The stack comes with these alerts:

| Alert | When It Fires | Severity |
|-------|---------------|----------|
| HighCPUUsage | CPU > 80% for 5min | Warning |
| CriticalCPUUsage | CPU > 95% for 2min | Critical |
| HighMemoryUsage | Memory > 80% for 5min | Warning |
| CriticalMemoryUsage | Memory > 95% for 2min | Critical |
| DiskSpaceWarning | Disk > 80% for 10min | Warning |
| DiskSpaceCritical | Disk > 90% for 5min | Critical |
| NodeDown | Node down for 2min | Critical |

### View Active Alerts

- **Prometheus**: http://localhost:9090/alerts
- **Alertmanager**: http://localhost:9093/#/alerts

### Test Email Alerts

```bash
# Trigger a test alert by simulating high CPU
docker run --rm -it alpine sh -c "while true; do :; done"

# Wait 5-10 minutes and check your email
# Stop with Ctrl+C
```

---

## 🛠️ Common Commands

### Check Logs

```bash
# All services
docker-compose -f docker-compose.production.yml logs -f

# Specific service
docker logs monitoring-stack -f
docker logs node-exporter -f
docker logs cadvisor -f
```

### Restart Services

```bash
# Restart all
docker-compose -f docker-compose.production.yml restart

# Restart specific service
docker restart monitoring-stack
```

### Stop Everything

```bash
docker-compose -f docker-compose.production.yml down
```

### Update to Latest Version

```bash
# Pull latest image
docker-compose -f docker-compose.production.yml pull

# Restart with new image
docker-compose -f docker-compose.production.yml up -d
```

### Backup Data

```bash
# Backup Prometheus data
docker run --rm \
  -v monitoring_prometheus-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/prometheus-backup-$(date +%Y%m%d).tar.gz /data

# Backup Grafana data
docker run --rm \
  -v monitoring_grafana-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/grafana-backup-$(date +%Y%m%d).tar.gz /data
```

---

## 🔍 Verification Checklist

After deployment, verify everything works:

### ✅ Step 1: Check All Containers Running

```bash
docker ps
```

Should see:
- `monitoring-stack`
- `node-exporter`
- `cadvisor`

### ✅ Step 2: Check Prometheus Targets

Go to: http://localhost:9090/targets

All targets should be **UP** (green):
- prometheus
- alertmanager
- grafana
- node-exporter
- cadvisor

### ✅ Step 3: Check Grafana Connection

1. Go to: http://localhost:3000
2. Login: admin / your-password
3. Configuration → Data Sources
4. Should see **Prometheus** with green checkmark

### ✅ Step 4: Verify Metrics Collection

Go to Prometheus: http://localhost:9090/graph

Try these queries:
```promql
up
node_cpu_seconds_total
container_memory_usage_bytes
```

Should see data!

---

## 🆘 Troubleshooting

### Problem: Can't access Grafana

**Solution:**
```bash
# Check if container is running
docker ps | grep monitoring-stack

# Check logs
docker logs monitoring-stack

# Check port is open
netstat -tulpn | grep 3000

# For AWS: Check Security Group allows port 3000
```

### Problem: Prometheus shows targets as DOWN

**Solution:**
1. Check docker network:
   ```bash
   docker network ls
   docker network inspect monitoring_observability
   ```

2. Check service names in docker-compose match prometheus.yml

3. Restart services:
   ```bash
   docker-compose -f docker-compose.production.yml restart
   ```

### Problem: Email alerts not working

**Solution:**
1. Verify Gmail app password (not regular password!)
2. Check `.env` file has correct SMTP settings
3. Test SMTP connection:
   ```bash
   docker exec -it monitoring-stack sh
   nc -zv smtp.gmail.com 587
   ```
4. Check alertmanager logs:
   ```bash
   docker logs monitoring-stack | grep alertmanager
   ```

### Problem: High memory usage

**Solution:**
```bash
# Reduce Prometheus retention (in .env)
PROMETHEUS_RETENTION=7d  # Instead of 15d

# Restart
docker-compose -f docker-compose.production.yml restart
```

### Problem: Can't pull image from GHCR

**Solution:**
```bash
# Make sure image is public or you're logged in
docker login ghcr.io -u YOUR-GITHUB-USERNAME

# Pull manually
docker pull ghcr.io/chandanmohonto/devops-monitoring-observability-stack:latest
```

---

## 🔐 Security Best Practices

### For Production:

1. **Change default passwords**
   ```bash
   GRAFANA_ADMIN_PASSWORD=VeryStrongPassword123!
   ```

2. **Use HTTPS** (Install Nginx + Let's Encrypt)
   ```bash
   sudo apt install nginx certbot python3-certbot-nginx -y
   sudo certbot --nginx -d monitoring.yourdomain.com
   ```

3. **Restrict access** (Update Security Group)
   - Prometheus (9090) - Internal only
   - Alertmanager (9093) - Internal only
   - Grafana (3000) - HTTPS only

4. **Enable firewall**
   ```bash
   sudo ufw allow 22/tcp
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw enable
   ```

5. **Regular updates**
   ```bash
   # Update image weekly
   docker-compose -f docker-compose.production.yml pull
   docker-compose -f docker-compose.production.yml up -d
   ```

---

## 📞 Need Help?

- **GitHub Issues**: https://github.com/ChandanMohonto/devops-monitoring-observability-stack/issues
- **Email**: qa@mykey.co.it
- **Documentation**: See README.md for detailed info

---

## 🎯 What's Next?

1. ✅ Set up email/Slack alerts
2. ✅ Import Grafana dashboards
3. ✅ Configure alert thresholds for your environment
4. ✅ Set up HTTPS for production
5. ✅ Configure automated backups
6. ✅ Add custom metrics from your applications

**Happy Monitoring!** 🚀
