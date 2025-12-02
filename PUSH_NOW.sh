#!/bin/bash

echo "========================================"
echo "🚀 Pushing to GitHub"
echo "========================================"
echo ""

# Set Git identity
git config user.name "Chandan Mohonto"
git config user.email "chandan.mahanta.bd@gmail.com"
echo "✅ Git identity configured"
echo ""

# Add remote
git remote add origin git@github.com:ChandanMohonto/devops-monitoring-observability-stack.git 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ Remote added"
else
    echo "⚠️  Remote already exists"
fi
echo ""

# Rename branch to main
git branch -M main
echo "✅ Branch renamed to main"
echo ""

# Push to GitHub
echo "📤 Pushing to GitHub..."
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "✅ SUCCESS! Code pushed to GitHub"
    echo "========================================"
    echo ""
    echo "🎯 Next Steps:"
    echo "1. Check GitHub Actions: https://github.com/ChandanMohonto/devops-monitoring-observability-stack/actions"
    echo "2. Wait for build to complete (3-5 minutes)"
    echo "3. Check packages: https://github.com/ChandanMohonto?tab=packages"
    echo ""
    echo "⚠️  IMPORTANT: Revoke your exposed token at https://github.com/settings/tokens"
    echo ""
else
    echo ""
    echo "========================================"
    echo "❌ PUSH FAILED"
    echo "========================================"
    echo ""
    echo "Possible reasons:"
    echo "1. SSH key not set up - Generate one: ssh-keygen -t ed25519"
    echo "2. Repository doesn't exist - Create it at GitHub first"
    echo "3. No permission - Check you have push access"
    echo ""
    echo "Try HTTPS instead:"
    echo "git push -u https://github.com/ChandanMohonto/devops-monitoring-observability-stack.git main"
    echo ""
fi
