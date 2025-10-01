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
EOF

echo "✅ 고급 부하 테스트 대시보드 생성 완룜"

echo "3. Grafana 대시보드 프로비저닝 설정 확인..."
# dashboard.yml 파일 확인 및 생성
if [ ! -f "$DASHBOARD_DIR/dashboard.yml" ]; then
    echo "   - dashboard.yml 파일 생성 중..."
    cat > "$DASHBOARD_DIR/dashboard.yml" << 'EOF'
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
else
    echo "   - dashboard.yml 파일 이미 존재"
fi

echo "4. Grafana 컨테이너 재시작..."
# Grafana 컨테이너 재시작으로 대시보드 로드
if docker ps | grep -q grafana; then
    echo "   - Grafana 컨테이너 재시작 중..."
    docker restart grafana > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "   ✅ Grafana 재시작 성공"
    else
        echo "   ⚠️ Grafana 재시작 실패 - 수동으로 재시작해주세요"
    fi
else
    echo "   ⚠️ Grafana 컨테이너를 찾을 수 없습니다"
    echo "   모니터링 스택을 먼저 시작해주세요"
fi

echo "5. 대시보드 파일 검증..."
if [ -f "$DASHBOARD_DIR/load-test-dashboard.json" ]; then
    FILE_SIZE=$(stat -f%z "$DASHBOARD_DIR/load-test-dashboard.json" 2>/dev/null || stat -c%s "$DASHBOARD_DIR/load-test-dashboard.json" 2>/dev/null)
    echo "   ✅ 대시보드 파일 생성 완료: ${FILE_SIZE} bytes"
else
    echo "   ❌ 대시보드 파일 생성 실패"
fi

echo "6. 부하 테스트 시나리오 스크립트 생성..."
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
echo "=== 고급 부하 테스트 대시보드 생성 완료 ==="
echo ""
echo "생성된 파일:"
echo "- $DASHBOARD_DIR/load-test-dashboard.json"
echo "- $MONITORING_DIR/load_test_scenarios.sh"
echo "- $DASHBOARD_DIR/dashboard.yml (프로비저닝 설정)"
echo ""
echo "확인 방법:"
echo "1. Grafana 접속: http://localhost:3001 (admin/admin)"
echo "2. 왼쪽 메뉴에서 'Dashboards' 클릭"
echo "3. 'Load Test & Performance Dashboard' 찾기"
echo ""
echo "대시보드가 보이지 않는 경우:"
echo "1. Grafana 로그 확인: docker logs grafana"
echo "2. 수동 재시작: docker restart grafana"
echo "3. 파일 권한 확인: ls -la $DASHBOARD_DIR/"
echo ""
echo "테스트 방법:"
echo "1. 부하 테스트 실행: ./load_test_scenarios.sh"
echo "2. 에러 테스트 실행: ./test_error_scenarios.sh"
echo "3. Grafana에서 실시간 메트릭 확인"
echo ""
echo ""
echo "대시보드 특징:"
echo "- ✅ 실시간 요청률 모니터링"
echo "- ✅ 응답시간 백분위수 추적 (P50, P95, P99)"
echo "- ✅ 엔드포인트별 에러율 분석"
echo "- ✅ 시스템 리소스 사용량 모니터링"
echo "- ✅ HTTP 상태코드 분포 시각화"
echo "- ✅ 동시 사용자 수 추정"
echo "- ✅ 데이터베이스 연결 수 모니터링"
echo "- ✅ 메시지 큐 크기 추적"