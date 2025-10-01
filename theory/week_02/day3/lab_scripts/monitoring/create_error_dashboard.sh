#!/bin/bash

# Week 2 Day 3 Lab 1: Error Test App 대시보드 생성 스크립트
# 사용법: ./create_error_dashboard.sh

echo "=== Error Test App 대시보드 생성 시작 ==="

# 현재 디렉토리 확인 및 경로 설정
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DASHBOARD_DIR="$SCRIPT_DIR/grafana/provisioning/dashboards"

echo "1. 디렉토리 구조 확인 및 생성..."
echo "   - 스크립트 디렉토리: $SCRIPT_DIR"
echo "   - 대시보드 디렉토리: $DASHBOARD_DIR"

# 디렉토리 생성 (이미 있어도 에러 없음)
mkdir -p "$DASHBOARD_DIR"

if [ ! -d "$DASHBOARD_DIR" ]; then
    echo "   ❌ 대시보드 디렉토리 생성 실패: $DASHBOARD_DIR"
    exit 1
fi

echo "   ✅ 디렉토리 준비 완료"

echo "2. Error Test App 전용 대시보드 생성..."
# Error Test App 전용 대시보드 생성
cat > "$DASHBOARD_DIR/error-app-dashboard.json" << 'EOF'
{
  "id": null,
  "title": "Error Test App Monitoring",
    "tags": ["error-app", "monitoring", "alerts"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Application Errors by Type",
        "type": "stat",
        "targets": [
          {
            "expr": "sum by (error_type) (rate(application_errors_total[5m]))",
            "legendFormat": "{{error_type}}"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0},
        "fieldConfig": {
          "defaults": {
            "color": {"mode": "palette-classic"},
            "unit": "reqps"
          }
        }
      },
      {
        "id": 2,
        "title": "HTTP Status Codes",
        "type": "piechart",
        "targets": [
          {
            "expr": "sum by (status) (rate(http_requests_total{job=\"error-app\"}[5m]))",
            "legendFormat": "{{status}}"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0}
      },
      {
        "id": 3,
        "title": "Database Connections",
        "type": "graph",
        "targets": [
          {
            "expr": "database_connections_active",
            "legendFormat": "Active Connections"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 8},
        "yAxes": [
          {
            "min": 0,
            "max": 50
          }
        ],
        "alert": {
          "conditions": [
            {
              "query": {"params": ["A", "5m", "now"]},
              "reducer": {"params": [], "type": "last"},
              "evaluator": {"params": [40], "type": "gt"}
            }
          ],
          "executionErrorState": "alerting",
          "for": "1m",
          "frequency": "10s",
          "handler": 1,
          "name": "High DB Connections",
          "noDataState": "no_data"
        }
      },
      {
        "id": 4,
        "title": "Message Queue Size",
        "type": "graph",
        "targets": [
          {
            "expr": "message_queue_size",
            "legendFormat": "Queue Size"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 8},
        "yAxes": [
          {
            "min": 0,
            "max": 100
          }
        ]
      },
      {
        "id": 5,
        "title": "Error Rate Over Time",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(application_errors_total[5m])",
            "legendFormat": "{{error_type}} - {{endpoint}}"
          }
        ],
        "gridPos": {"h": 8, "w": 24, "x": 0, "y": 16},
        "yAxes": [
          {
            "min": 0,
            "unit": "reqps"
          }
        ]
      },
      {
        "id": 6,
        "title": "Response Time Distribution",
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
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 24},
        "yAxes": [
          {
            "min": 0,
            "unit": "s"
          }
        ]
      },
      {
        "id": 7,
        "title": "Request Rate by Endpoint",
        "type": "graph",
        "targets": [
          {
            "expr": "sum by (route) (rate(http_requests_total{job=\"error-app\"}[5m]))",
            "legendFormat": "{{route}}"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 24},
        "yAxes": [
          {
            "min": 0,
            "unit": "reqps"
          }
        ]
      }
    ],
    "time": {"from": "now-30m", "to": "now"},
    "refresh": "5s",
    "templating": {
      "list": []
    },
    "annotations": {
      "list": [
        {
          "name": "Alerts",
          "datasource": "Prometheus",
          "enable": true,
          "expr": "ALERTS{alertname=~\".*Error.*|.*Database.*|.*Queue.*\"}",
          "iconColor": "red",
          "titleFormat": "{{alertname}}",
          "textFormat": "{{instance}}: {{description}}"
        }
      ]
    }
}
EOF

echo "✅ Error Test App 대시보드 생성 완료"

# Grafana 설정 리로드를 위해 컨테이너 재시작
echo "Grafana 설정 리로드 중..."
docker restart grafana > /dev/null 2>&1

sleep 10

echo ""
echo "=== Error Test App 대시보드 생성 완료 ==="
echo ""
echo "Grafana 접속 방법:"
echo "1. http://localhost:3001 접속"
echo "2. admin/admin으로 로그인"
echo "3. 왼쪽 메뉴에서 'Dashboards' 클릭"
echo "4. 'Error Test App Monitoring' 대시보드 선택"
echo ""
echo "대시보드에서 볼 수 있는 메트릭:"
echo "- Application Errors by Type (에러 타입별 통계)"
echo "- HTTP Status Codes (HTTP 상태 코드 분포)"
echo "- Database Connections (DB 연결 수)"
echo "- Message Queue Size (메시지 큐 크기)"
echo "- Error Rate Over Time (시간별 에러율)"
echo "- Response Time Distribution (응답 시간 분포)"
echo "- Request Rate by Endpoint (엔드포인트별 요청률)"
echo ""
echo "테스트 방법:"
echo "1. ./test_error_scenarios.sh 실행"
echo "2. Grafana 대시보드에서 실시간 메트릭 확인"
echo "3. 알림 패널에서 발생한 알림 확인"