#!/bin/bash

# Week 2 Day 3 Lab 1 - Phase 3: 모니터링 시스템 구축 스크립트
# 사용법: ./setup_monitoring.sh

echo "=== 모니터링 시스템 구축 시작 ==="
echo ""

# 모니터링 디렉토리 생성
echo "1. 모니터링 설정 디렉토리 생성 중..."
mkdir -p monitoring/{prometheus,grafana/provisioning/{datasources,dashboards}}

echo "✅ 디렉토리 구조 생성 완료"

echo ""
echo "2. Prometheus 설정 파일 생성 중..."

# Prometheus 설정 파일 생성
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
EOF

echo "✅ Prometheus 설정 파일 생성 완료"

echo ""
echo "3. 알림 규칙 파일 생성 중..."

# 알림 규칙 파일 생성
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

  - alert: RedisDown
    expr: up{job="redis"} == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Redis is down"
      description: "Redis instance is not responding"
EOF

echo "✅ 알림 규칙 파일 생성 완료"

echo ""
echo "4. Grafana 데이터소스 설정 생성 중..."

# Grafana 데이터소스 설정
cat > monitoring/grafana/provisioning/datasources/datasources.yml << 'EOF'
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
echo "5. Grafana 대시보드 프로비저닝 설정 생성 중..."

# Grafana 대시보드 프로비저닝 설정
cat > monitoring/grafana/provisioning/dashboards/dashboards.yml << 'EOF'
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
      path: /var/lib/grafana/dashboards
EOF

echo "✅ Grafana 대시보드 설정 완료"

echo ""
echo "6. Docker Compose 모니터링 스택 파일 생성 중..."

# 모니터링 스택 Docker Compose 파일 생성
cat > monitoring/docker-compose.monitoring.yml << 'EOF'
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:latest
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
        reservations:
          memory: 256M
          cpus: '0.25'
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:9090/-/healthy"]
      interval: 30s
      timeout: 10s
      retries: 3

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
      - GF_INSTALL_PLUGINS=grafana-piechart-panel
    volumes:
      - grafana-data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
    deploy:
      resources:
        limits:
          memory: 256M
          cpus: '0.25'
        reservations:
          memory: 128M
          cpus: '0.1'
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    deploy:
      resources:
        limits:
          memory: 128M
          cpus: '0.25'
        reservations:
          memory: 64M
          cpus: '0.1'
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:8080/healthz"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  prometheus-data:
  grafana-data:

networks:
  default:
    driver: bridge
EOF

echo "✅ 모니터링 스택 Docker Compose 파일 생성 완료"

echo ""
echo "7. 모니터링 스택 시작 중..."

# 모니터링 스택 시작
cd monitoring
docker-compose -f docker-compose.monitoring.yml up -d

if [ $? -eq 0 ]; then
    echo "✅ 모니터링 스택 시작 성공"
else
    echo "❌ 모니터링 스택 시작 실패"
    exit 1
fi

echo ""
echo "8. 서비스 상태 확인 중..."

# 서비스 준비 대기
echo "서비스 준비 중..."
sleep 20

# 서비스 상태 확인
echo "=== 모니터링 서비스 상태 ==="
docker-compose -f docker-compose.monitoring.yml ps

cd ..

echo ""
echo "=== 모니터링 시스템 구축 완료 ==="
echo ""
echo "접속 정보:"
echo "- Prometheus: http://localhost:9090"
echo "- Grafana: http://localhost:3001 (admin/admin)"
echo "- cAdvisor: http://localhost:8080"
echo ""
echo "다음 단계: 메트릭 수집 및 대시보드 설정"
echo ""