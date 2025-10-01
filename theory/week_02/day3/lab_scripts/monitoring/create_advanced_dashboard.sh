#!/bin/bash

# Week 2 Day 3: 고급 부하 테스트 대시보드 생성 스크립트
# 사용법: ./create_advanced_dashboard.sh

echo "=== 고급 부하 테스트 대시보드 생성 ==="

# 현재 디렉토리 확인 및 경로 설정
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DASHBOARD_DIR="$SCRIPT_DIR/grafana/provisioning/dashboards"
MONITORING_DIR="$SCRIPT_DIR"

echo "1. 디렉토리 구조 확인 및 생성..."
echo "   - 스크립트 디렉토리: $SCRIPT_DIR"
echo "   - 대시보드 디렉토리: $DASHBOARD_DIR"

# 디렉토리 생성
mkdir -p "$DASHBOARD_DIR"
mkdir -p "$MONITORING_DIR"

if [ ! -d "$DASHBOARD_DIR" ]; then
    echo "   ❌ 대시보드 디렉토리 생성 실패: $DASHBOARD_DIR"
    exit 1
fi

echo "   ✅ 디렉토리 준비 완료"

echo "2. Grafana에 고급 대시보드 추가..."
# Grafana에 고급 대시보드 추가
cat > "$DASHBOARD_DIR/load-test-dashboard.json" << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "Load Test & Performance Dashboard",
    "tags": ["load-test", "performance", "error-app"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Real-time Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total{job=\"error-app\"}[1m])",
            "legendFormat": "{{method}} {{route}}"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0},
        "yAxes": [
          {"label": "Requests/sec", "min": 0}
        ]
      },
      {
        "id": 2,
        "title": "Response Time Percentiles",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.50, rate(http_request_duration_seconds_bucket{job=\"error-app\"}[5m]))",
            "legendFormat": "50th percentile"
          },
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket{job=\"error-app\"}[5m]))",
            "legendFormat": "95th percentile"
          },
          {
            "expr": "histogram_quantile(0.99, rate(http_request_duration_seconds_bucket{job=\"error-app\"}[5m]))",
            "legendFormat": "99th percentile"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0},
        "yAxes": [
          {"label": "Seconds", "min": 0}
        ]
      },
      {
        "id": 3,
        "title": "Error Rate by Endpoint",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(application_errors_total{job=\"error-app\"}[5m])",
            "legendFormat": "{{endpoint}} - {{error_type}}"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 8},
        "yAxes": [
          {"label": "Errors/sec", "min": 0}
        ]
      },
      {
        "id": 4,
        "title": "System Resource Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(process_cpu_seconds_total{job=\"error-app\"}[5m]) * 100",
            "legendFormat": "CPU %"
          },
          {
            "expr": "process_resident_memory_bytes{job=\"error-app\"} / 1024 / 1024",
            "legendFormat": "Memory MB"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 8}
      },
      {
        "id": 5,
        "title": "Database Connections",
        "type": "singlestat",
        "targets": [
          {
            "expr": "database_connections_active",
            "legendFormat": "Active Connections"
          }
        ],
        "gridPos": {"h": 6, "w": 6, "x": 0, "y": 16},
        "valueName": "current",
        "colorBackground": true,
        "thresholds": "30,40"
      },
      {
        "id": 6,
        "title": "Message Queue Size",
        "type": "singlestat",
        "targets": [
          {
            "expr": "message_queue_size",
            "legendFormat": "Queue Size"
          }
        ],
        "gridPos": {"h": 6, "w": 6, "x": 6, "y": 16},
        "valueName": "current",
        "colorBackground": true,
        "thresholds": "30,50"
      },
      {
        "id": 7,
        "title": "Load Test Scenarios",
        "type": "table",
        "targets": [
          {
            "expr": "sum by (route) (rate(http_requests_total{job=\"error-app\"}[5m]))",
            "format": "table",
            "instant": true
          }
        ],
        "gridPos": {"h": 6, "w": 12, "x": 12, "y": 16}
      },
      {
        "id": 8,
        "title": "HTTP Status Code Distribution",
        "type": "piechart",
        "targets": [
          {
            "expr": "sum by (status) (rate(http_requests_total{job=\"error-app\"}[5m]))",
            "legendFormat": "{{status}}"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 22}
      },
      {
        "id": 9,
        "title": "Concurrent Users Simulation",
        "type": "graph",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total{job=\"error-app\"}[1m])) * 60",
            "legendFormat": "Estimated Concurrent Users"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 22},
        "yAxes": [
          {"label": "Users", "min": 0}
        ]
      }
    ],
    "time": {"from": "now-15m", "to": "now"},
    "refresh": "5s",
    "templating": {
      "list": [
        {
          "name": "endpoint",
          "type": "query",
          "query": "label_values(http_requests_total{job=\"error-app\"}, route)",
          "refresh": 1,
          "includeAll": true,
          "multi": true
        }
      ]
    }
  }
}
EOF

echo "✅ 고급 부하 테스트 대시보드 생성 완료"

echo "3. 부하 테스트 시나리오 스크립트 생성..."
# 부하 테스트 시나리오 스크립트 생성
cat > "$MONITORING_DIR/load_test_scenarios.sh" << 'EOF'
#!/bin/bash

echo "=== Error Test App 부하 테스트 시나리오 ==="

# 시나리오 1: 정상 트래픽
echo "1. 정상 트래픽 시뮬레이션 (30초)..."
ab -n 300 -c 5 -t 30 http://localhost:4000/ > /dev/null 2>&1 &

# 시나리오 2: 에러 발생 트래픽
echo "2. 에러 발생 트래픽 (20초)..."
sleep 5
for i in {1..20}; do
  curl -s http://localhost:4000/error/500 > /dev/null &
  curl -s http://localhost:4000/error/random > /dev/null &
  sleep 1
done

# 시나리오 3: CPU 집약적 부하
echo "3. CPU 집약적 부하 테스트 (15초)..."
sleep 10
for i in {1..5}; do
  curl -s http://localhost:4000/load/cpu > /dev/null &
done

# 시나리오 4: 메모리 집약적 부하
echo "4. 메모리 집약적 부하 테스트 (10초)..."
sleep 5
for i in {1..3}; do
  curl -s http://localhost:4000/load/memory > /dev/null &
done

# 시나리오 5: 데이터베이스 연결 시뮬레이션
echo "5. 데이터베이스 연결 시뮬레이션..."
for i in {1..10}; do
  curl -s http://localhost:4000/db/connect > /dev/null
  sleep 2
done

# 시나리오 6: 메시지 큐 부하
echo "6. 메시지 큐 부하 테스트..."
curl -s -X POST -H "Content-Type: application/json" -d '{"count":25}' http://localhost:4000/queue/add > /dev/null
sleep 5
curl -s -X POST http://localhost:4000/queue/process > /dev/null

echo "✅ 모든 부하 테스트 시나리오 완료"
echo ""
echo "Grafana에서 다음 대시보드를 확인하세요:"
echo "- Error Test App Monitoring"
echo "- Load Test & Performance Dashboard"
echo "- Container Monitoring Dashboard"
EOF

chmod +x "$MONITORING_DIR/load_test_scenarios.sh"

echo ""
echo "생성된 파일:"
echo "- monitoring/grafana/provisioning/dashboards/load-test-dashboard.json"
echo "- monitoring/load_test_scenarios.sh"
echo ""
echo "사용법:"
echo "1. 모니터링 스택 재시작: cd monitoring && docker-compose -f docker-compose.monitoring.yml restart grafana"
echo "2. 부하 테스트 실행: ./monitoring/load_test_scenarios.sh"
echo "3. Grafana에서 'Load Test & Performance Dashboard' 확인"
echo ""
echo "대시보드 특징:"
echo "- 실시간 요청률 모니터링"
echo "- 응답시간 백분위수 추적"
echo "- 엔드포인트별 에러율 분석"
echo "- 시스템 리소스 사용량 모니터링"
echo "- HTTP 상태코드 분포 시각화"
echo "- 동시 사용자 수 추정"