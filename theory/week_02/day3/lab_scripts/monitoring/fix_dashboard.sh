#!/bin/bash

# Week 2 Day 3: 대시보드 JSON 구조 문제 해결 스크립트
# 사용법: ./fix_dashboard.sh

echo "=== 대시보드 JSON 구조 문제 해결 ==="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DASHBOARD_DIR="$SCRIPT_DIR/grafana/provisioning/dashboards"

echo "1. 기존 문제가 있는 대시보드 파일 제거..."
rm -f "$DASHBOARD_DIR/load-test-dashboard.json"
rm -f "$DASHBOARD_DIR/error-app-dashboard.json"
rm -f "$DASHBOARD_DIR/container-dashboard.json"

echo "2. 올바른 구조의 Load Test 대시보드 생성..."
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
      "type": "timeseries",
      "targets": [
        {
          "expr": "rate(http_requests_total{job=\"error-app\"}[1m])",
          "legendFormat": "{{method}} {{route}}"
        }
      ],
      "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0},
      "fieldConfig": {
        "defaults": {
          "unit": "reqps",
          "min": 0
        }
      }
    },
    {
      "id": 2,
      "title": "Response Time Percentiles",
      "type": "timeseries",
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
      "fieldConfig": {
        "defaults": {
          "unit": "s",
          "min": 0
        }
      }
    },
    {
      "id": 3,
      "title": "Error Rate by Endpoint",
      "type": "timeseries",
      "targets": [
        {
          "expr": "rate(application_errors_total{job=\"error-app\"}[5m])",
          "legendFormat": "{{endpoint}} - {{error_type}}"
        }
      ],
      "gridPos": {"h": 8, "w": 12, "x": 0, "y": 8},
      "fieldConfig": {
        "defaults": {
          "unit": "reqps",
          "min": 0
        }
      }
    },
    {
      "id": 4,
      "title": "HTTP Status Code Distribution",
      "type": "piechart",
      "targets": [
        {
          "expr": "sum by (status) (rate(http_requests_total{job=\"error-app\"}[5m]))",
          "legendFormat": "{{status}}"
        }
      ],
      "gridPos": {"h": 8, "w": 12, "x": 12, "y": 8}
    }
  ],
  "time": {"from": "now-15m", "to": "now"},
  "refresh": "5s",
  "schemaVersion": 37,
  "version": 1
}
EOF

echo "3. 올바른 구조의 Error Test App 대시보드 생성..."
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
      "type": "timeseries",
      "targets": [
        {
          "expr": "database_connections_active",
          "legendFormat": "Active Connections"
        }
      ],
      "gridPos": {"h": 8, "w": 12, "x": 0, "y": 8},
      "fieldConfig": {
        "defaults": {
          "min": 0,
          "max": 50
        }
      }
    },
    {
      "id": 4,
      "title": "Message Queue Size",
      "type": "timeseries",
      "targets": [
        {
          "expr": "message_queue_size",
          "legendFormat": "Queue Size"
        }
      ],
      "gridPos": {"h": 8, "w": 12, "x": 12, "y": 8},
      "fieldConfig": {
        "defaults": {
          "min": 0,
          "max": 100
        }
      }
    }
  ],
  "time": {"from": "now-30m", "to": "now"},
  "refresh": "5s",
  "schemaVersion": 37,
  "version": 1
}
EOF

echo "4. 기본 Container 대시보드 생성..."
cat > "$DASHBOARD_DIR/container-dashboard.json" << 'EOF'
{
  "id": null,
  "title": "Container Monitoring Dashboard",
  "tags": ["container", "monitoring", "docker"],
  "timezone": "browser",
  "panels": [
    {
      "id": 1,
      "title": "Container CPU Usage",
      "type": "timeseries",
      "targets": [
        {
          "expr": "rate(container_cpu_usage_seconds_total[5m]) * 100",
          "legendFormat": "{{name}}"
        }
      ],
      "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0},
      "fieldConfig": {
        "defaults": {
          "unit": "percent",
          "min": 0
        }
      }
    },
    {
      "id": 2,
      "title": "Container Memory Usage",
      "type": "timeseries",
      "targets": [
        {
          "expr": "container_memory_usage_bytes / 1024 / 1024",
          "legendFormat": "{{name}}"
        }
      ],
      "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0},
      "fieldConfig": {
        "defaults": {
          "unit": "MB",
          "min": 0
        }
      }
    }
  ],
  "time": {"from": "now-1h", "to": "now"},
  "refresh": "10s",
  "schemaVersion": 37,
  "version": 1
}
EOF

echo "5. Grafana 컨테이너 재시작..."
docker restart grafana > /dev/null 2>&1
echo "   ✅ Grafana 재시작 완료"

echo "6. 30초 대기 후 상태 확인..."
sleep 30

echo "7. 대시보드 파일 검증..."
for file in "load-test-dashboard.json" "error-app-dashboard.json" "container-dashboard.json"; do
    if [ -f "$DASHBOARD_DIR/$file" ]; then
        FILE_SIZE=$(stat -f%z "$DASHBOARD_DIR/$file" 2>/dev/null || stat -c%s "$DASHBOARD_DIR/$file" 2>/dev/null)
        echo "   ✅ $file: ${FILE_SIZE} bytes"
    else
        echo "   ❌ $file: 생성 실패"
    fi
done

echo ""
echo "=== 대시보드 JSON 구조 문제 해결 완료 ==="
echo ""
echo "✅ 수정된 사항:"
echo "- JSON 구조에서 불필요한 'dashboard' 래퍼 제거"
echo "- Grafana 최신 버전 호환 패널 타입 사용"
echo "- 스키마 버전 및 버전 정보 추가"
echo ""
echo "📋 확인 방법:"
echo "1. Grafana 접속: http://localhost:3001"
echo "2. 로그인: admin/admin"
echo "3. 왼쪽 메뉴 → Dashboards"
echo "4. 다음 대시보드들이 표시되어야 함:"
echo "   - Load Test & Performance Dashboard"
echo "   - Error Test App Monitoring"
echo "   - Container Monitoring Dashboard"
echo ""
echo "🔍 문제가 지속되면:"
echo "- Grafana 로그 확인: docker logs grafana"
echo "- 브라우저 새로고침 (Ctrl+F5)"