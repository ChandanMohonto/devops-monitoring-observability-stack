# 🚀 Secure Push to GitHub Instructions

## ⚠️ IMPORTANT SECURITY STEPS FIRST!

### 1. Revoke Any Exposed Tokens
If you shared any GitHub tokens publicly, **delete them immediately:**

1. Go to: https://github.com/settings/tokens
2. Find and revoke any exposed tokens
3. Click "Delete" ❌
4. **Do NOT create a new token** - GitHub Actions uses `GITHUB_TOKEN` automatically!

### 2. Verify Secrets Are Protected

```bash
# Confirm .env is NOT in git
git check-ignore .env
# Should output: .gitignore:2:.env	.env

# Verify no secrets in staged files
git diff --cached | grep -i "password\|token\|secret" || echo "✅ No secrets found"
```

## 📤 Push to GitHub

### Option 1: Using SSH (Recommended)

```bash
# Set your Git identity
git config user.name "Chandan Mohonto"
git config user.email "chandan.mahanta.bd@gmail.com"

# Add remote
git remote add origin git@github.com:ChandanMohonto/devops-monitoring-observability-stack.git

# Push to main branch
git branch -M main
git push -u origin main
```

### Option 2: Using HTTPS

```bash
# Add remote with HTTPS
git remote add origin https://github.com/ChandanMohonto/devops-monitoring-observability-stack.git

# Push (will prompt for credentials)
git branch -M main
git push -u origin main
```

### If Repository Already Exists

```bash
# Force push (ONLY if you're sure!)
git push -u origin main --force

# OR merge with existing
git pull origin main --allow-unrelated-histories
git push -u origin main
```

## 🔐 Configure GitHub Secrets (Optional)

If you want to use different credentials for CI/CD:

1. Go to: https://github.com/ChandanMohonto/devops-monitoring-observability-stack/settings/secrets/actions
2. Click "New repository secret"
3. Add these (optional):
   - `DOCKER_USERNAME` - Your Docker Hub username
   - `DOCKER_TOKEN` - Docker Hub access token

**Note:** For GHCR (GitHub Container Registry), the workflow automatically uses `GITHUB_TOKEN` - no setup needed!

## ✅ Verify Push Success

After pushing, check:

1. **GitHub Actions**: https://github.com/ChandanMohonto/devops-monitoring-observability-stack/actions
   - The workflow should start automatically
   - It will build, test, and push to GHCR

2. **Container Registry**: https://github.com/ChandanMohonto?tab=packages
   - Your image will appear here after successful build

3. **Security Scanning**: Check for vulnerabilities in Actions tab

## 🎯 After Successful Push

Your image will be available at:
```
ghcr.io/chandanmohonto/devops-monitoring-observability-stack:latest
```

### Pull and Run

```bash
# Pull from GHCR
docker pull ghcr.io/chandanmohonto/devops-monitoring-observability-stack:latest

# Run with docker-compose
docker-compose -f docker-compose.production.yml up -d
```

## 🔒 Security Checklist

- [x] .env file is gitignored
- [x] No hardcoded secrets in code
- [x] GitHub token revoked
- [x] Example .env.example created
- [ ] Revoke exposed GitHub token ⚠️
- [ ] Change Grafana admin password in production
- [ ] Rotate SMTP password after testing
- [ ] Update Slack webhook if compromised

## 🆘 Troubleshooting

### "Permission denied" error
```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "chandan.mahanta.bd@gmail.com"

# Add to GitHub
cat ~/.ssh/id_ed25519.pub
# Copy and add at: https://github.com/settings/keys
```

### "Repository not found"
- Make sure repo exists: https://github.com/ChandanMohonto/devops-monitoring-observability-stack
- Check you have push access

### GitHub Actions failing
- Check workflow logs in Actions tab
- Verify GITHUB_TOKEN permissions in Settings > Actions > General

---

**🚨 REMEMBER: Your token and passwords were exposed. Rotate them after testing!**
