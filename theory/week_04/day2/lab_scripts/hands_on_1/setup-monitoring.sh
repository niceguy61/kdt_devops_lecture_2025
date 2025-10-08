#!/bin/bash

# Week 4 Day 2 Hands-on 1: 모니터링 시스템 구축
# 사용법: ./setup-monitoring.sh

echo "=== 모니터링 시스템 구축 시작 ==="

# 기존 모니터링 컨테이너 정리
echo "1. 기존 모니터링 컨테이너 정리 중..."
docker stop prometheus grafana 2>/dev/null || true
docker rm prometheus grafana 2>/dev/null || true

# 모니터링 디렉토리 생성
echo "2. 모니터링 디렉토리 생성 중..."
mkdir -p ~/microservices-lab/monitoring/prometheus
mkdir -p ~/microservices-lab/monitoring/grafana

# Prometheus 설정 파일 생성
echo "3. Prometheus 설정 파일 생성 중..."
cat > ~/microservices-lab/monitoring/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  # Prometheus 자체 모니터링
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # Kong Gateway 메트릭
  - job_name: 'kong'
    static_configs:
      - targets: ['kong-gateway:8001']
    metrics_path: '/metrics'
    scrape_interval: 10s

  # Consul 서비스 디스커버리
  - job_name: 'consul-services'
    consul_sd_configs:
      - server: 'consul-server:8500'
        services: []
    relabel_configs:
      - source_labels: [__meta_consul_service]
        target_label: service
      - source_labels: [__meta_consul_service_id]
        target_label: instance
      - source_labels: [__meta_consul_tags]
        target_label: tags
        regex: '(.+)'

  # 마이크로서비스들 (정적 설정)
  - job_name: 'microservices'
    static_configs:
      - targets: 
          - 'user-service:3001'
          - 'product-service:3002'
          - 'order-service:3003'
          - 'auth-service:3004'
    metrics_path: '/metrics'
    scrape_interval: 10s

  # Node Exporter (시스템 메트릭)
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093
EOF

# Prometheus 알림 규칙 생성
cat > ~/microservices-lab/monitoring/prometheus/alert_rules.yml << 'EOF'
groups:
- name: microservices_alerts
  rules:
  - alert: ServiceDown
    expr: up == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Service {{ $labels.instance }} is down"
      description: "{{ $labels.instance }} has been down for more than 1 minute."

  - alert: HighResponseTime
    expr: http_request_duration_seconds > 0.5
    for: 2m
    labels:
      severity: warning
    annotations:
      summary: "High response time on {{ $labels.instance }}"
      description: "Response time is above 500ms for 2 minutes."

  - alert: HighErrorRate
    expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "High error rate on {{ $labels.instance }}"
      description: "Error rate is above 10% for 1 minute."
EOF

# Prometheus 컨테이너 실행
echo "4. Prometheus 컨테이너 실행 중..."
docker run -d \
  --name prometheus \
  --network microservices-net \
  -p 9090:9090 \
  -v ~/microservices-lab/monitoring/prometheus:/etc/prometheus \
  prom/prometheus:latest \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/prometheus \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.console.templates=/etc/prometheus/consoles \
  --web.enable-lifecycle

# Node Exporter 실행 (시스템 메트릭)
echo "5. Node Exporter 실행 중..."
docker run -d \
  --name node-exporter \
  --network microservices-net \
  -p 9100:9100 \
  prom/node-exporter:latest

# Grafana 컨테이너 실행
echo "6. Grafana 컨테이너 실행 중..."
docker run -d \
  --name grafana \
  --network microservices-net \
  -p 3000:3000 \
  -e GF_SECURITY_ADMIN_PASSWORD=admin \
  -e GF_USERS_ALLOW_SIGN_UP=false \
  -v ~/microservices-lab/monitoring/grafana:/var/lib/grafana \
  grafana/grafana:latest

# 서비스 시작 대기
echo "7. 모니터링 서비스 시작 대기 중..."
sleep 20

# Grafana 데이터소스 설정
echo "8. Grafana 데이터소스 설정 중..."
curl -s -X POST http://admin:admin@localhost:3000/api/datasources \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Prometheus",
    "type": "prometheus",
    "url": "http://prometheus:9090",
    "access": "proxy",
    "isDefault": true,
    "basicAuth": false
  }' > /dev/null

# Grafana 대시보드 생성
echo "9. Grafana 대시보드 생성 중..."
curl -s -X POST http://admin:admin@localhost:3000/api/dashboards/db \
  -H "Content-Type: application/json" \
  -d '{
    "dashboard": {
      "id": null,
      "title": "Microservices Overview",
      "tags": ["microservices", "api-gateway"],
      "timezone": "browser",
      "panels": [
        {
          "id": 1,
          "title": "Service Status",
          "type": "stat",
          "targets": [
            {
              "expr": "up",
              "legendFormat": "{{service}}"
            }
          ],
          "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0}
        },
        {
          "id": 2,
          "title": "Request Rate",
          "type": "graph",
          "targets": [
            {
              "expr": "rate(http_requests_total[5m])",
              "legendFormat": "{{service}}"
            }
          ],
          "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0}
        }
      ],
      "time": {"from": "now-1h", "to": "now"},
      "refresh": "5s"
    },
    "overwrite": true
  }' > /dev/null

# Kong Prometheus 플러그인 활성화
echo "10. Kong Prometheus 플러그인 활성화 중..."
curl -s -X POST http://localhost:8001/plugins \
  --data "name=prometheus" > /dev/null

# 상태 확인
echo "11. 모니터링 시스템 상태 확인 중..."

# Prometheus 상태 확인
if curl -s http://localhost:9090/-/healthy | grep -q "Prometheus is Healthy"; then
    echo "✅ Prometheus 정상 실행"
else
    echo "❌ Prometheus 시작 실패"
fi

# Grafana 상태 확인
if curl -s http://localhost:3000/api/health | grep -q "ok"; then
    echo "✅ Grafana 정상 실행"
else
    echo "❌ Grafana 시작 실패"
fi

# Node Exporter 상태 확인
if curl -s http://localhost:9100/metrics | grep -q "node_"; then
    echo "✅ Node Exporter 정상 실행"
else
    echo "❌ Node Exporter 시작 실패"
fi

echo ""
echo "=== 모니터링 시스템 구축 완료 ==="
echo ""
echo "접속 정보:"
echo "- Prometheus: http://localhost:9090"
echo "- Grafana: http://localhost:3000 (admin/admin)"
echo "- Node Exporter: http://localhost:9100/metrics"
echo ""
echo "Grafana 대시보드:"
echo "1. 로그인: admin / admin"
echo "2. 데이터소스: Prometheus (자동 설정됨)"
echo "3. 대시보드: Microservices Overview"
echo ""
echo "주요 메트릭:"
echo "- 서비스 상태: up"
echo "- 요청 비율: rate(http_requests_total[5m])"
echo "- 응답 시간: http_request_duration_seconds"
echo "- 에러 비율: rate(http_requests_total{status=~\"5..\"}[5m])"
