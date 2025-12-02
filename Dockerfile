# ============================================
# Lightweight Monitoring Stack - Alpine Based
# Prometheus + Grafana + Alertmanager
# Final Size: ~450MB
# ============================================

FROM alpine:3.19 AS base
RUN apk add --no-cache wget tar ca-certificates

# ============================================
# Stage 1: Download Prometheus
# ============================================
FROM base AS prometheus-builder
WORKDIR /tmp
RUN wget -q https://github.com/prometheus/prometheus/releases/download/v2.48.0/prometheus-2.48.0.linux-amd64.tar.gz \
    && tar -xzf prometheus-2.48.0.linux-amd64.tar.gz \
    && mv prometheus-2.48.0.linux-amd64 /opt/prometheus

# ============================================
# Stage 2: Download Alertmanager
# ============================================
FROM base AS alertmanager-builder
WORKDIR /tmp
RUN wget -q https://github.com/prometheus/alertmanager/releases/download/v0.26.0/alertmanager-0.26.0.linux-amd64.tar.gz \
    && tar -xzf alertmanager-0.26.0.linux-amd64.tar.gz \
    && mv alertmanager-0.26.0.linux-amd64 /opt/alertmanager

# ============================================
# Stage 3: Download Grafana
# ============================================
FROM base AS grafana-builder
WORKDIR /tmp
RUN wget -q https://dl.grafana.com/oss/release/grafana-10.2.3.linux-amd64.tar.gz \
    && tar -xzf grafana-10.2.3.linux-amd64.tar.gz \
    && mv grafana-v10.2.3 /opt/grafana

# ============================================
# Final Stage - Combine Everything
# ============================================
FROM alpine:3.19

# Metadata labels for GHCR
LABEL org.opencontainers.image.source="https://github.com/ChandanMohonto/devops-monitoring-observability-stack"
LABEL org.opencontainers.image.description="Lightweight All-in-One Monitoring Stack: Prometheus + Grafana + Alertmanager"
LABEL org.opencontainers.image.licenses="MIT"
LABEL maintainer="qa@mykey.co.it"
LABEL version="1.0.0"

# Install runtime dependencies (minimal)
RUN apk add --no-cache \
    curl \
    bash \
    supervisor \
    gettext \
    ca-certificates \
    tzdata \
    && rm -rf /var/cache/apk/*

# Copy binaries from build stages
COPY --from=prometheus-builder /opt/prometheus /opt/prometheus
COPY --from=alertmanager-builder /opt/alertmanager /opt/alertmanager
COPY --from=grafana-builder /opt/grafana /opt/grafana

# Create directory structure
RUN mkdir -p \
    /etc/prometheus \
    /etc/alertmanager \
    /etc/grafana/provisioning/datasources \
    /etc/grafana/provisioning/dashboards \
    /var/lib/prometheus \
    /var/lib/alertmanager \
    /var/lib/grafana \
    /var/log/supervisor \
    /var/log/prometheus \
    /var/log/alertmanager \
    /var/log/grafana

# Copy configuration files
COPY prometheus.yml /etc/prometheus/prometheus.yml
COPY alert-rules.yml /etc/prometheus/alert-rules.yml
COPY alertmanager.yml.template /etc/alertmanager/alertmanager.yml.template
COPY grafana.ini.template /etc/grafana/grafana.ini.template
COPY grafana/provisioning/datasources/prometheus.yml /etc/grafana/provisioning/datasources/prometheus.yml
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /entrypoint.sh

# Set permissions
RUN chmod +x /entrypoint.sh \
    && chmod -R 755 /var/lib/grafana \
    && chmod -R 755 /var/log

# Expose ports
EXPOSE 9090 9093 3000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:9090/-/healthy && \
        curl -f http://localhost:9093/-/healthy && \
        curl -f http://localhost:3000/api/health || exit 1

WORKDIR /opt

ENTRYPOINT ["/entrypoint.sh"]