#!/bin/bash

# Grafana 대시보드 수정 및 재시작 스크립트

echo "=== Grafana 대시보드 수정 및 재시작 ==="

cd monitoring

echo "1. Grafana 컨테이너 재시작..."
docker-compose -f docker-compose.monitoring.yml restart grafana

echo "2. Grafana 시작 대기 (15초)..."
sleep 15

echo "3. Grafana 연결 테스트..."
if curl -s http://localhost:3001/api/health > /dev/null; then
    echo "✅ Grafana 정상 동작"
else
    echo "❌ Grafana 연결 실패"
    exit 1
fi

echo "4. 대시보드 확인..."
DASHBOARDS=$(curl -s -u admin:admin http://localhost:3001/api/search | jq length 2>/dev/null || echo "0")
echo "   - 설정된 대시보드: ${DASHBOARDS}개"

if [ "$DASHBOARDS" -gt 0 ]; then
    echo "   - 대시보드 목록:"
    curl -s -u admin:admin http://localhost:3001/api/search | jq -r '.[].title' 2>/dev/null | sed 's/^/     /'
fi

echo ""
echo "✅ 대시보드 수정 완료"
echo ""
echo "접속 정보:"
echo "- Grafana: http://localhost:3001 (admin/admin)"
echo "- 사용 가능한 대시보드:"
echo "  * Error Test App Monitoring"
echo "  * Container Monitoring Dashboard"
echo ""
echo "테스트 명령어:"
echo "- 에러 발생: curl http://localhost:4000/error/500"
echo "- 부하 생성: for i in {1..50}; do curl http://localhost:4000/ & done"
echo "- 메트릭 확인: curl http://localhost:4000/metrics"

cd ..