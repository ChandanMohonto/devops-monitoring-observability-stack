#!/bin/bash
set -e

echo "=========================================="
echo "🚀 Starting MYKEY Monitoring Stack"
echo "=========================================="

# ==========================================
# Set default environment variables
# ==========================================
export SMTP_HOST=${SMTP_HOST:-smtp.gmail.com}
export SMTP_PORT=${SMTP_PORT:-587}
export SMTP_FROM=${SMTP_FROM:-monitoring@example.com}
export SMTP_USERNAME=${SMTP_USERNAME:-monitoring@example.com}
export SMTP_PASSWORD=${SMTP_PASSWORD:-changeme}
export SLACK_WEBHOOK_URL=${SLACK_WEBHOOK_URL:-https://hooks.slack.com/services/CHANGE/ME}
export EMAIL_MAIN=${EMAIL_MAIN:-admin@example.com}
export EMAIL_CRITICAL=${EMAIL_CRITICAL:-admin@example.com}
export EMAIL_WARNING=${EMAIL_WARNING:-admin@example.com}
export EMAIL_INFRA=${EMAIL_INFRA:-admin@example.com}
export SLACK_CHANNEL_CRITICAL=${SLACK_CHANNEL_CRITICAL:-#critical-alerts}
export SLACK_CHANNEL_WARNING=${SLACK_CHANNEL_WARNING:-#monitoring-alerts}
export SLACK_CHANNEL_INFRA=${SLACK_CHANNEL_INFRA:-#infrastructure}
export GRAFANA_ADMIN_USER=${GRAFANA_ADMIN_USER:-admin}
export GRAFANA_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD:-admin}

# ==========================================
# Process Alertmanager configuration
# ==========================================
echo "📝 Processing Alertmanager configuration..."
if [ -f "/etc/alertmanager/alertmanager.yml.template" ]; then
    envsubst < /etc/alertmanager/alertmanager.yml.template > /etc/alertmanager/alertmanager.yml
    echo "✅ Alertmanager config created"
else
    echo "❌ Error: alertmanager.yml.template not found!"
    exit 1
fi

# ==========================================
# Process Grafana configuration
# ==========================================
echo "📝 Processing Grafana configuration..."
if [ -f "/etc/grafana/grafana.ini.template" ]; then
    envsubst < /etc/grafana/grafana.ini.template > /etc/grafana/grafana.ini
    echo "✅ Grafana config created"
else
    echo "❌ Error: grafana.ini.template not found!"
    exit 1
fi

# ==========================================
# Verify configurations
# ==========================================
echo ""
echo "🔍 Verifying configurations..."
if [ -f "/etc/prometheus/prometheus.yml" ]; then
    echo "✅ Prometheus config found"
else
    echo "❌ Prometheus config missing!"
    exit 1
fi

if [ -f "/etc/alertmanager/alertmanager.yml" ]; then
    echo "✅ Alertmanager config ready"
else
    echo "❌ Alertmanager config not created!"
    exit 1
fi

if [ -f "/etc/grafana/grafana.ini" ]; then
    echo "✅ Grafana config ready"
else
    echo "❌ Grafana config not created!"
    exit 1
fi

# ==========================================
# Display startup info
# ==========================================
echo ""
echo "=========================================="
echo "📊 Monitoring Stack Configuration"
echo "=========================================="
echo "Prometheus:    http://localhost:9090"
echo "Alertmanager:  http://localhost:9093"
echo "Grafana:       http://localhost:3000"
echo "Admin User:    ${GRAFANA_ADMIN_USER}"
echo "=========================================="
echo ""

# ==========================================
# Start supervisord
# ==========================================
echo "🎯 Starting all services with supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf