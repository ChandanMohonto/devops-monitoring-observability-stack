# 🚀 Super Simple Deploy - 3 Options

Your friends can use your monitoring stack **without building anything**!

---

## ⚡ Option 1: Direct Docker Run (Fastest - 1 Command)

**No git clone needed!** Just pull and run:

### Local:

```bash
docker run -d \
  --name monitoring \
  -p 9090:9090 -p 9093:9093 -p 3000:3000 \
  -e GRAFANA_ADMIN_USER=admin \
  -e GRAFANA_ADMIN_PASSWORD=MyPassword123 \
  -e SMTP_HOST=smtp.gmail.com \
  -e SMTP_PORT=587 \
  -e SMTP_FROM=monitoring@example.com \
  -e SMTP_USERNAME=your-email@gmail.com \
  -e SMTP_PASSWORD=your-app-password \
  -e EMAIL_MAIN=your-email@gmail.com \
  -e EMAIL_CRITICAL=your-email@gmail.com \
  -e EMAIL_WARNING=your-email@gmail.com \
  -e EMAIL_INFRA=your-email@gmail.com \
  -e SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK \
  ghcr.io/chandanmohonto/devops-monitoring-observability-stack:latest
```

**Access:** http://localhost:3000 (admin/MyPassword123)

---

## 🎯 Option 2: Docker Compose (Recommended - Includes Node Exporter + cAdvisor)

### Step 1: Get Files

```bash
# Clone repo (just for config files)
git clone https://github.com/ChandanMohonto/devops-monitoring-observability-stack.git
cd devops-monitoring-observability-stack
```

### Step 2: Configure

```bash
# Copy and edit .env
cp .env.example .env
nano .env  # Change GRAFANA_ADMIN_PASSWORD
```

### Step 3: Run (Auto-pulls from GHCR)

```bash
docker-compose -f docker-compose.production.yml up -d
```

**That's it!** Docker automatically pulls the image from GHCR.

**Access:** http://localhost:3000

---

## 📥 Option 3: Download Config Only (No Git)

If you don't want to clone the repo:

### Step 1: Create Directory

```bash
mkdir monitoring && cd monitoring
```

### Step 2: Download Files

```bash
# Download docker-compose file
curl -O https://raw.githubusercontent.com/ChandanMohonto/devops-monitoring-observability-stack/main/docker-compose.production.yml

# Download .env example
curl -O https://raw.githubusercontent.com/ChandanMohonto/devops-monitoring-observability-stack/main/.env.example

# Rename
mv .env.example .env
```

### Step 3: Configure and Run

```bash
nano .env  # Edit settings
docker-compose -f docker-compose.production.yml up -d
```

---

## ☁️ AWS Quick Deploy

**One-liner install on fresh EC2:**

```bash
curl -fsSL https://get.docker.com | sh && \
sudo usermod -aG docker $USER && \
newgrp docker && \
docker run -d \
  --name monitoring \
  --restart unless-stopped \
  -p 9090:9090 -p 9093:9093 -p 3000:3000 \
  -e GRAFANA_ADMIN_USER=admin \
  -e GRAFANA_ADMIN_PASSWORD=SecurePass123 \
  -e EMAIL_MAIN=admin@example.com \
  ghcr.io/chandanmohonto/devops-monitoring-observability-stack:latest
```

**Access:** http://YOUR-EC2-IP:3000

---

## 🔄 What Happens Automatically?

When you run `docker-compose up` or `docker pull`:

1. ✅ Docker connects to GHCR
2. ✅ Downloads pre-built image (~450MB)
3. ✅ Starts all services
4. ✅ Ready in 1-2 minutes!

**NO BUILD REQUIRED!** 🎉

---

## 📦 Manual Pull (If Needed)

```bash
# Pull latest image
docker pull ghcr.io/chandanmohonto/devops-monitoring-observability-stack:latest

# Verify
docker images | grep monitoring

# Run
docker run -d --name monitoring -p 3000:3000 ghcr.io/chandanmohonto/devops-monitoring-observability-stack:latest
```

---

## 🎯 Comparison

| Method | Pros | Cons |
|--------|------|------|
| **Option 1: Direct Run** | Fastest, 1 command | No Node Exporter/cAdvisor |
| **Option 2: Docker Compose** | Complete stack, easy updates | Need repo or files |
| **Option 3: Download Files** | No git needed, complete stack | Extra download step |

---

## 🔍 Check What's Running

```bash
# See containers
docker ps

# See images
docker images

# Check logs
docker logs monitoring -f

# Health check
curl http://localhost:9090/-/healthy
curl http://localhost:3000/api/health
```

---

## 🔄 Update to Latest

```bash
# Stop current
docker stop monitoring
docker rm monitoring

# Pull latest
docker pull ghcr.io/chandanmohonto/devops-monitoring-observability-stack:latest

# Run again
docker run -d --name monitoring ... (same command as before)
```

Or with docker-compose:
```bash
docker-compose -f docker-compose.production.yml pull
docker-compose -f docker-compose.production.yml up -d
```

---

## 📊 Complete Stack with Node Exporter + cAdvisor

If you want system and container metrics:

```bash
# Option 2 or 3 (docker-compose) gives you:
- monitoring-stack (Prometheus + Grafana + Alertmanager)
- node-exporter (system metrics)
- cadvisor (container metrics)

# All from pre-built images - NO building!
```

---

## 🎓 Share This Command

**For friends who just want to test:**

```bash
docker run -d --name monitoring -p 3000:3000 \
  -e GRAFANA_ADMIN_PASSWORD=test123 \
  ghcr.io/chandanmohonto/devops-monitoring-observability-stack:latest
```

**Access:** http://localhost:3000 (admin/test123)

**That's it!** One command, no building! 🚀

---

## ❓ Why No Build?

✅ Image is **pre-built by GitHub Actions**
✅ Automatically pushed to **GHCR**
✅ Always **up-to-date**
✅ **Multi-platform** (AMD64 + ARM64)
✅ **Ready to use** immediately

Your friends just **pull and run**! 🎯
