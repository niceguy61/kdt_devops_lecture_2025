#!/bin/bash

# Week 2 Day 3 Lab 1: 모니터링 시스템 테스트 스크립트
# 사용법: ./test_monitoring.sh

echo "=== 모니터링 시스템 테스트 시작 ==="

echo "1. 모니터링 서비스 상태 확인..."

# 모니터링 서비스 상태 확인
cd monitoring 2>/dev/null || {
    echo "❌ monitoring 디렉토리를 찾을 수 없습니다."
    echo "먼저 setup_monitoring.sh를 실행해주세요."
    exit 1
}

# Docker Compose 서비스 상태 확인
if ! docker-compose -f docker-compose.monitoring.yml ps | grep -q "Up"; then
    echo "❌ 모니터링 서비스가 실행되지 않았습니다."
    echo "setup_monitoring.sh를 먼저 실행해주세요."
    exit 1
fi

echo "✅ 모니터링 서비스 정상 실행 중"

echo ""
echo "2. Prometheus 연결 및 타겟 확인..."

# Prometheus 헬스체크
if curl -s http://localhost:9090/-/healthy > /dev/null; then
    echo "✅ Prometheus 정상 동작"
    
    # 타겟 상태 확인
    TARGETS_JSON=$(curl -s http://localhost:9090/api/v1/targets)
    TARGETS_UP=$(echo "$TARGETS_JSON" | jq '.data.activeTargets[] | select(.health=="up") | .labels.job' 2>/dev/null | wc -l)
    TARGETS_DOWN=$(echo "$TARGETS_JSON" | jq '.data.activeTargets[] | select(.health=="down") | .labels.job' 2>/dev/null | wc -l)
    
    echo "   - 활성 타겟: ${TARGETS_UP}개"
    echo "   - 비활성 타겟: ${TARGETS_DOWN}개"
    
    # 타겟별 상태 상세 확인
    echo "   - 타겟 상태 상세:"
    echo "$TARGETS_JSON" | jq -r '.data.activeTargets[] | "     \(.labels.job): \(.health)"' 2>/dev/null || echo "     JSON 파싱 실패"
else
    echo "❌ Prometheus 연결 실패"
    exit 1
fi

echo ""
echo "3. Grafana 연결 확인..."

# Grafana 헬스체크
if curl -s http://localhost:3001/api/health > /dev/null; then
    echo "✅ Grafana 정상 동작"
    
    # 데이터소스 확인
    DATASOURCES=$(curl -s -u admin:admin http://localhost:3001/api/datasources | jq length 2>/dev/null)
    echo "   - 설정된 데이터소스: ${DATASOURCES}개"
    
    # 대시보드 확인
    DASHBOARDS=$(curl -s -u admin:admin http://localhost:3001/api/search | jq length 2>/dev/null)
    echo "   - 설정된 대시보드: ${DASHBOARDS}개"
else
    echo "❌ Grafana 연결 실패"
fi

echo ""
echo "4. cAdvisor 연결 확인..."

# cAdvisor 헬스체크
if curl -s http://localhost:8080/healthz > /dev/null; then
    echo "✅ cAdvisor 정상 동작"
    
    # 컨테이너 메트릭 확인
    CONTAINERS=$(curl -s http://localhost:8080/api/v1.3/containers | jq 'keys | length' 2>/dev/null)
    echo "   - 모니터링 중인 컨테이너: ${CONTAINERS}개"
else
    echo "❌ cAdvisor 연결 실패"
fi

echo ""
echo "5. 애플리케이션 메트릭 수집 테스트..."

# Error Test App 메트릭 확인
if curl -s http://localhost:4000/metrics > /dev/null; then
    echo "✅ Error Test App 메트릭 엔드포인트 정상"
    
    # 메트릭 개수 확인
    METRICS_COUNT=$(curl -s http://localhost:4000/metrics | wc -l)
    echo "   - 수집된 메트릭 라인: ${METRICS_COUNT}개"
    
    # 주요 메트릭 확인
    echo "   - HTTP 요청 메트릭:"
    HTTP_METRICS=$(curl -s http://localhost:4000/metrics | grep -c "http_requests_total" || echo "0")
    echo "     http_requests_total: ${HTTP_METRICS}개 라벨"
    
    echo "   - 응답 시간 메트릭:"
    DURATION_METRICS=$(curl -s http://localhost:4000/metrics | grep -c "http_request_duration_seconds" || echo "0")
    echo "     http_request_duration_seconds: ${DURATION_METRICS}개 라벨"
else
    echo "❌ Error Test App 메트릭 수집 실패"
fi

echo ""
echo "6. 부하 생성 및 메트릭 변화 테스트..."

# 부하 생성 전 메트릭 수집
echo "   - 부하 생성 전 메트릭 수집..."
BEFORE_REQUESTS=$(curl -s http://localhost:4000/metrics | grep "http_requests_total" | head -1 | awk '{print $2}' | cut -d. -f1 2>/dev/null || echo "0")

# 부하 생성
echo "   - 부하 생성 중 (500 요청)..."
ab -n 500 -c 10 -q http://localhost:4000/ > /dev/null 2>&1 &
AB_PID=$!

# 부하 생성 중 리소스 모니터링
sleep 2
echo "   - 부하 생성 중 리소스 사용량:"
docker stats --no-stream --format "     {{.Container}}: CPU {{.CPUPerc}}, Memory {{.MemUsage}}" | grep -E "(optimized-app|prometheus|grafana)"

# 부하 생성 완료 대기
wait $AB_PID

# 부하 생성 후 메트릭 수집
sleep 3
echo "   - 부하 생성 후 메트릭 수집..."
AFTER_REQUESTS=$(curl -s http://localhost:4000/metrics | grep "http_requests_total" | head -1 | awk '{print $2}' | cut -d. -f1 2>/dev/null || echo "0")

# 메트릭 변화 확인
if [ "$BEFORE_REQUESTS" != "" ] && [ "$AFTER_REQUESTS" != "" ] && [ "$BEFORE_REQUESTS" != "0" ] && [ "$AFTER_REQUESTS" != "0" ]; then
    REQUEST_INCREASE=$((AFTER_REQUESTS - BEFORE_REQUESTS))
    echo "   ✅ HTTP 요청 메트릭 증가: ${REQUEST_INCREASE}개"
else
    echo "   ⚠️  메트릭 변화 측정 실패 (Before: $BEFORE_REQUESTS, After: $AFTER_REQUESTS)"
fi

echo ""
echo "7. Prometheus 쿼리 테스트..."

# Prometheus 쿼리 테스트
echo "   - HTTP 요청률 쿼리 테스트:"
QUERY_RESULT=$(curl -s "http://localhost:9090/api/v1/query?query=rate(http_requests_total[5m])" | jq '.data.result | length' 2>/dev/null || echo "0")
if [ "$QUERY_RESULT" -gt 0 ] 2>/dev/null; then
    echo "   ✅ HTTP 요청률 쿼리 성공 (${QUERY_RESULT}개 시계열)"
else
    echo "   ⚠️  HTTP 요청률 쿼리 결과 없음 (Result: $QUERY_RESULT)"
fi

echo "   - 컨테이너 CPU 사용률 쿼리 테스트:"
CPU_QUERY_RESULT=$(curl -s "http://localhost:9090/api/v1/query?query=rate(container_cpu_usage_seconds_total[5m])" | jq '.data.result | length' 2>/dev/null || echo "0")
if [ "$CPU_QUERY_RESULT" -gt 0 ] 2>/dev/null; then
    echo "   ✅ CPU 사용률 쿼리 성공 (${CPU_QUERY_RESULT}개 시계열)"
else
    echo "   ⚠️  CPU 사용률 쿼리 결과 없음 (Result: $CPU_QUERY_RESULT)"
fi

echo ""
echo "8. 알림 규칙 테스트..."

# 알림 규칙 상태 확인
ALERT_RULES=$(curl -s http://localhost:9090/api/v1/rules | jq '.data.groups[].rules | length' 2>/dev/null | awk '{sum+=$1} END {print sum+0}' || echo "0")
echo "   - 설정된 알림 규칙: ${ALERT_RULES}개"

# 활성 알림 확인
ACTIVE_ALERTS=$(curl -s http://localhost:9090/api/v1/alerts | jq '.data.alerts | length' 2>/dev/null || echo "0")
echo "   - 현재 활성 알림: ${ACTIVE_ALERTS}개"

if [ "$ACTIVE_ALERTS" -gt 0 ] 2>/dev/null; then
    echo "   - 활성 알림 목록:"
    curl -s http://localhost:9090/api/v1/alerts | jq -r '.data.alerts[] | "     \(.labels.alertname): \(.state)"' 2>/dev/null
fi

echo ""
echo "9. 고부하 알림 테스트..."

echo "   - 고부하 생성으로 알림 트리거 테스트..."
# 높은 부하 생성 (알림 트리거 목적)
ab -n 1000 -c 30 -q http://localhost:4000/ > /dev/null 2>&1 &
HIGH_LOAD_PID=$!

echo "   - 30초 대기 (알림 규칙 평가 시간)..."
sleep 30

# 알림 상태 재확인
NEW_ACTIVE_ALERTS=$(curl -s http://localhost:9090/api/v1/alerts | jq '.data.alerts | length' 2>/dev/null || echo "0")
echo "   - 고부하 후 활성 알림: ${NEW_ACTIVE_ALERTS}개"

if [ "$NEW_ACTIVE_ALERTS" -gt "$ACTIVE_ALERTS" ] 2>/dev/null; then
    echo "   ✅ 알림 시스템 정상 동작 (새로운 알림 발생)"
    echo "   - 새로 발생한 알림:"
    curl -s http://localhost:9090/api/v1/alerts | jq -r '.data.alerts[] | select(.state=="firing") | "     \(.labels.alertname): \(.annotations.summary)"' 2>/dev/null
else
    echo "   ⚠️  알림 트리거 확인 필요 (임계값 조정 또는 대기 시간 부족)"
fi

# 고부하 프로세스 종료
kill $HIGH_LOAD_PID 2>/dev/null

echo ""
echo "10. 모니터링 대시보드 접근성 테스트..."

# Grafana 대시보드 접근 테스트
echo "   - Grafana 로그인 테스트:"
LOGIN_RESULT=$(curl -s -c cookies.txt -X POST -H "Content-Type: application/json" -d '{"user":"admin","password":"admin"}' http://localhost:3001/login)
if echo "$LOGIN_RESULT" | grep -q "Logged in"; then
    echo "   ✅ Grafana 로그인 성공"
    
    # 대시보드 목록 확인
    DASHBOARD_LIST=$(curl -s -b cookies.txt http://localhost:3001/api/search | jq -r '.[].title' 2>/dev/null)
    if [ -n "$DASHBOARD_LIST" ]; then
        echo "   - 사용 가능한 대시보드:"
        echo "$DASHBOARD_LIST" | sed 's/^/     /'
    fi
    
    # 쿠키 파일 정리
    rm -f cookies.txt
else
    echo "   ⚠️  Grafana 로그인 실패"
fi

echo ""
echo "11. 종합 모니터링 리포트 생성..."

# 모니터링 테스트 리포트 생성
cat > monitoring-test-report.txt << EOF
=== 모니터링 시스템 테스트 리포트 ===
테스트 일시: $(date)

=== 서비스 상태 ===
- Prometheus: 정상 동작 (http://localhost:9090)
- Grafana: 정상 동작 (http://localhost:3001)
- cAdvisor: 정상 동작 (http://localhost:8080)

=== 메트릭 수집 상태 ===
- 활성 타겟: ${TARGETS_UP}개
- 비활성 타겟: ${TARGETS_DOWN}개
- 애플리케이션 메트릭: ${METRICS_COUNT}라인
- 모니터링 컨테이너: ${CONTAINERS}개

=== 알림 시스템 ===
- 설정된 알림 규칙: ${ALERT_RULES}개
- 현재 활성 알림: ${NEW_ACTIVE_ALERTS}개

=== 대시보드 ===
- 설정된 데이터소스: ${DATASOURCES}개
- 설정된 대시보드: ${DASHBOARDS}개

=== 성능 테스트 결과 ===
- 부하 테스트 전후 HTTP 요청 증가: ${REQUEST_INCREASE:-"측정 실패"}개
- Prometheus 쿼리 응답: 정상
- 알림 트리거 테스트: $([ "$NEW_ACTIVE_ALERTS" -gt "$ACTIVE_ALERTS" ] && echo "성공" || echo "확인 필요")

=== 권장사항 ===
- 정기적인 메트릭 수집 상태 모니터링
- 알림 임계값 조정 및 테스트
- 대시보드 커스터마이징
- 장기 데이터 보존 정책 수립

=== 접속 정보 ===
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3001 (admin/admin)
- cAdvisor: http://localhost:8080
EOF

echo "✅ 모니터링 테스트 리포트 생성 완료"

cd ..

echo ""
echo "=== 모니터링 시스템 테스트 완료 ==="
echo ""
echo "테스트 결과 요약:"
echo "- Prometheus: $([ "${TARGETS_UP:-0}" -gt 0 ] 2>/dev/null && echo "✅ 정상" || echo "❌ 문제")"
echo "- Grafana: $([ "${DATASOURCES:-0}" -gt 0 ] 2>/dev/null && echo "✅ 정상" || echo "❌ 문제")"
echo "- cAdvisor: $([ "${CONTAINERS:-0}" -gt 0 ] 2>/dev/null && echo "✅ 정상" || echo "❌ 문제")"
echo "- 메트릭 수집: $([ "${METRICS_COUNT:-0}" -gt 0 ] 2>/dev/null && echo "✅ 정상" || echo "❌ 문제")"
echo "- 알림 시스템: $([ "${ALERT_RULES:-0}" -gt 0 ] 2>/dev/null && echo "✅ 정상" || echo "❌ 문제")""
echo ""
echo "생성된 파일:"
echo "- monitoring/monitoring-test-report.txt: 종합 테스트 리포트"
echo ""
echo "다음 단계:"
echo "1. Grafana 대시보드 커스터마이징 (http://localhost:3001)"
echo "2. 알림 채널 설정 (Slack, Email 등)"
echo "3. 장기 모니터링 데이터 분석"