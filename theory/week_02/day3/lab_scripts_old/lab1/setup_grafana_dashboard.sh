#!/bin/bash

# Week 2 Day 3 Lab 1: Grafana 대시보드 자동 구성
# 사용법: ./setup_grafana_dashboard.sh

echo "=== Grafana 대시보드 자동 구성 시작 ==="

# 1. Grafana 설정 디렉토리 생성
echo "1. Grafana 설정 디렉토리 생성 중..."
mkdir -p config/grafana/{dashboards,datasources,provisioning}

# 2. 데이터소스 설정
echo "2. 데이터소스 설정 생성 중..."
cat > config/grafana/provisioning/datasources.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true

  - name: Elasticsearch
    type: elasticsearch
    access: proxy
    url: http://elasticsearch:9200
    database: "logs-*"
    interval: Daily
    timeField: "@timestamp"
    editable: true
EOF

# 3. 대시보드 프로비저닝 설정
echo "3. 대시보드 프로비저닝 설정 생성 중..."
cat > config/grafana/provisioning/dashboards.yml << 'EOF'
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

# 4. 컨테이너 모니터링 대시보드 생성
echo "4. 컨테이너 모니터링 대시보드 생성 중..."
cat > config/grafana/dashboards/container-monitoring.json << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "Container Monitoring Dashboard",
    "tags": ["docker", "containers"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "CPU Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(container_cpu_usage_seconds_total[5m]) * 100",
            "legendFormat": "{{name}}"
          }
        ],
        "yAxes": [
          {
            "label": "Percent",
            "max": 100,
            "min": 0
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0}
      },
      {
        "id": 2,
        "title": "Memory Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "container_memory_usage_bytes / 1024 / 1024",
            "legendFormat": "{{name}}"
          }
        ],
        "yAxes": [
          {
            "label": "MB"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0}
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "5s"
  }
}
EOF

# 5. Grafana 컨테이너 실행
echo "5. Grafana 컨테이너 실행 중..."
docker run -d \
  --name grafana \
  --restart=unless-stopped \
  -p 3000:3000 \
  -e GF_SECURITY_ADMIN_PASSWORD=admin \
  -e GF_USERS_ALLOW_SIGN_UP=false \
  -v grafana-data:/var/lib/grafana \
  -v $(pwd)/config/grafana/provisioning:/etc/grafana/provisioning \
  -v $(pwd)/config/grafana/dashboards:/var/lib/grafana/dashboards \
  --link prometheus:prometheus \
  --memory=512m \
  grafana/grafana:latest

# 6. Grafana 시작 대기
echo "6. Grafana 시작 대기 중..."
sleep 30

# 7. Grafana 상태 확인
echo "7. Grafana 상태 확인 중..."
if curl -f http://localhost:3000 >/dev/null 2>&1; then
    echo "✅ Grafana 정상 실행 중"
else
    echo "❌ Grafana 실행 실패"
    docker logs grafana --tail 20
fi

echo ""
echo "=== Grafana 대시보드 구성 완료 ==="
echo ""
echo "접속 정보:"
echo "- Grafana: http://localhost:3000"
echo "- 사용자명: admin"
echo "- 비밀번호: admin"
echo ""
echo "다음 단계: ./setup_elk_stack.sh 실행"