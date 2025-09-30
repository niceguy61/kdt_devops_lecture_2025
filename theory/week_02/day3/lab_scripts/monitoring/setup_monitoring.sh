#!/bin/bash

# Week 2 Day 3 Lab 1: 모니터링 스택 자동 구축 스크립트
# 사용법: ./setup_monitoring.sh

echo "=== 모니터링 스택 구축 시작 ==="

# 모니터링 디렉토리 생성
mkdir -p monitoring/{grafana/provisioning/{dashboards,datasources},prometheus}

echo "1. Prometheus 설정 파일 생성..."

# Prometheus 설정 파일
cat > monitoring/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alerts.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'app'
    static_configs:
      - targets: ['host.docker.internal:3000']
    metrics_path: '/metrics'
    scrape_interval: 10s

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']
    scrape_interval: 10s

  - job_name: 'redis'
    static_configs:
      - targets: ['host.docker.internal:6379']
    scrape_interval: 15s
EOF

echo "✅ Prometheus 설정 완료"

echo ""
echo "2. 알림 규칙 설정..."

# 알림 규칙 파일
cat > monitoring/alerts.yml << 'EOF'
groups:
- name: app_alerts
  rules:
  - alert: HighCPUUsage
    expr: rate(container_cpu_usage_seconds_total{name=~".*optimized-app.*"}[5m]) * 100 > 80
    for: 2m
    labels:
      severity: warning
    annotations:
      summary: "High CPU usage detected"
      description: "CPU usage is above 80% for more than 2 minutes"

  - alert: HighMemoryUsage
    expr: (container_memory_usage_bytes{name=~".*optimized-app.*"} / container_spec_memory_limit_bytes{name=~".*optimized-app.*"}) * 100 > 90
    for: 2m
    labels:
      severity: critical
    annotations:
      summary: "High memory usage detected"
      description: "Memory usage is above 90%"

  - alert: HighErrorRate
    expr: rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.05
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "High error rate detected"
      description: "Error rate is above 5%"

  - alert: HighResponseTime
    expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 0.5
    for: 2m
    labels:
      severity: warning
    annotations:
      summary: "High response time detected"
      description: "95th percentile response time is above 500ms"

  - alert: ContainerDown
    expr: up{job="app"} == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Application container is down"
      description: "The application container has been down for more than 1 minute"
EOF

echo "✅ 알림 규칙 설정 완료"

echo ""
echo "3. Grafana 데이터소스 설정..."

# Grafana 데이터소스 설정
cat > monitoring/grafana/provisioning/datasources/prometheus.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
EOF

echo "✅ Grafana 데이터소스 설정 완료"

echo ""
echo "4. Grafana 대시보드 설정..."

# Grafana 대시보드 프로비저닝 설정
cat > monitoring/grafana/provisioning/dashboards/dashboard.yml << 'EOF'
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards
EOF

# 컨테이너 모니터링 대시보드 JSON
cat > monitoring/grafana/provisioning/dashboards/container-dashboard.json << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "Container Monitoring Dashboard",
    "tags": ["docker", "containers"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "HTTP Requests per Second",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{method}} {{status}}"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0}
      },
      {
        "id": 2,
        "title": "Response Time (95th percentile)",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0}
      },
      {
        "id": 3,
        "title": "Container CPU Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(container_cpu_usage_seconds_total{name=~\".*optimized-app.*\"}[5m]) * 100",
            "legendFormat": "CPU %"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 8}
      },
      {
        "id": 4,
        "title": "Container Memory Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "container_memory_usage_bytes{name=~\".*optimized-app.*\"} / 1024 / 1024",
            "legendFormat": "Memory MB"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 8}
      }
    ],
    "time": {"from": "now-1h", "to": "now"},
    "refresh": "5s"
  }
}
EOF

echo "✅ Grafana 대시보드 설정 완료"

echo ""
echo "5. Docker Compose 모니터링 스택 설정..."

# 모니터링 스택 Docker Compose 파일
cat > monitoring/docker-compose.monitoring.yml << 'EOF'
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - ./alerts.yml:/etc/prometheus/alerts.yml
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=7d'
      - '--web.enable-lifecycle'
      - '--web.enable-admin-api'
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
      - GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource
    volumes:
      - grafana-data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
    deploy:
      resources:
        limits:
          memory: 256M
          cpus: '0.25'
    restart: unless-stopped
    depends_on:
      - prometheus

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    privileged: true
    devices:
      - /dev/kmsg
    deploy:
      resources:
        limits:
          memory: 128M
          cpus: '0.25'
    restart: unless-stopped

volumes:
  prometheus-data:
  grafana-data:

networks:
  default:
    name: monitoring-network
EOF

echo "✅ Docker Compose 설정 완료"

echo ""
echo "6. 모니터링 스택 시작..."

cd monitoring

# 기존 컨테이너 정리 (있다면)
docker-compose -f docker-compose.monitoring.yml down -v > /dev/null 2>&1

# 모니터링 스택 시작
docker-compose -f docker-compose.monitoring.yml up -d

echo "모니터링 서비스 시작 중..."
sleep 15

# 서비스 상태 확인
echo ""
echo "7. 서비스 상태 확인..."
docker-compose -f docker-compose.monitoring.yml ps

echo ""
echo "8. 연결 테스트..."

# Prometheus 연결 테스트
if curl -s http://localhost:9090/-/healthy > /dev/null; then
    echo "✅ Prometheus 정상 동작 (http://localhost:9090)"
else
    echo "❌ Prometheus 연결 실패"
fi

# Grafana 연결 테스트
if curl -s http://localhost:3001/api/health > /dev/null; then
    echo "✅ Grafana 정상 동작 (http://localhost:3001)"
else
    echo "❌ Grafana 연결 실패"
fi

# cAdvisor 연결 테스트
if curl -s http://localhost:8080/healthz > /dev/null; then
    echo "✅ cAdvisor 정상 동작 (http://localhost:8080)"
else
    echo "❌ cAdvisor 연결 실패"
fi

echo ""
echo "9. 메트릭 수집 확인..."

# Prometheus 타겟 상태 확인
sleep 5
TARGETS_UP=$(curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | select(.health=="up") | .labels.job' 2>/dev/null | wc -l)
echo "활성 타겟 수: ${TARGETS_UP}개"

cd ..

echo ""
echo "=== 모니터링 스택 구축 완료 ==="
echo ""
echo "접속 정보:"
echo "- Prometheus: http://localhost:9090"
echo "- Grafana: http://localhost:3001 (admin/admin)"
echo "- cAdvisor: http://localhost:8080"
echo ""
echo "Grafana 설정:"
echo "1. http://localhost:3001 접속 후 admin/admin으로 로그인"
echo "2. 데이터소스는 자동으로 설정됨 (Prometheus)"
echo "3. 대시보드는 자동으로 프로비저닝됨"
echo ""
echo "다음 단계: 애플리케이션 메트릭 수집 및 알림 테스트"