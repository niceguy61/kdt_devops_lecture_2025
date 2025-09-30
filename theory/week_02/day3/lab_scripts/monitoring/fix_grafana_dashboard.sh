#!/bin/bash

# Grafana 대시보드 문제 해결 스크립트

echo "=== Grafana 대시보드 문제 해결 시작 ==="

echo "1. 현재 Grafana 상태 확인..."
docker logs grafana --tail 10

echo ""
echo "2. 대시보드 파일 확인..."
ls -la monitoring/grafana/provisioning/dashboards/

echo ""
echo "3. Grafana 컨테이너 재시작..."
docker restart grafana

echo "대시보드 로딩 대기 중..."
sleep 15

echo ""
echo "4. Grafana API로 대시보드 확인..."
curl -s -u admin:admin http://localhost:3001/api/search | jq .

echo ""
echo "5. 수동으로 대시보드 생성..."

# API를 통해 직접 대시보드 생성
curl -X POST \
  -H "Content-Type: application/json" \
  -u admin:admin \
  -d '{
    "dashboard": {
      "id": null,
      "title": "Error Test App Manual",
      "tags": ["error-app"],
      "timezone": "browser",
      "panels": [
        {
          "id": 1,
          "title": "Application Errors",
          "type": "graph",
          "targets": [
            {
              "expr": "rate(application_errors_total[5m])",
              "legendFormat": "{{error_type}}"
            }
          ],
          "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0}
        },
        {
          "id": 2,
          "title": "Database Connections",
          "type": "singlestat",
          "targets": [
            {
              "expr": "database_connections_active",
              "legendFormat": "Connections"
            }
          ],
          "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0}
        }
      ],
      "time": {"from": "now-1h", "to": "now"},
      "refresh": "5s"
    },
    "overwrite": true
  }' \
  http://localhost:3001/api/dashboards/db

echo ""
echo ""
echo "=== 문제 해결 완료 ==="
echo ""
echo "Grafana 접속 방법:"
echo "1. http://localhost:3001"
echo "2. admin/admin 로그인"
echo "3. 왼쪽 메뉴 → Dashboards"
echo "4. 'Error Test App Manual' 대시보드 확인"
echo ""
echo "만약 여전히 안 보인다면:"
echo "1. + 버튼 → Import 클릭"
echo "2. 'Upload JSON file' 또는 직접 JSON 입력"
echo "3. 또는 + 버튼 → Dashboard → Add new panel로 수동 생성"