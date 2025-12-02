#!/bin/bash

# Reset to before first commit
git reset --soft ba68164^

# Create new clean initial commit
git commit -m "Initial commit: DevOps Monitoring Stack with CI/CD

- Lightweight all-in-one Docker image (Prometheus + Grafana + Alertmanager)
- GitHub Actions workflow for automated builds to GHCR
- Node Exporter and cAdvisor integration
- Email and Slack alerting
- Production-ready configurations
- Comprehensive documentation"

# Get current changes
git cherry-pick 991706f --no-commit
git commit -m "Fix: Add id to build step for attestation"

git cherry-pick HEAD@{1} --no-commit
git add -A
git commit -m "Update: Remove attestation step and exclude IDE files"

echo "Git history rewritten! Force push with: git push origin main --force"
