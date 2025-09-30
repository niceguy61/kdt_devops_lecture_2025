#!/bin/bash

# Week 2 Day 3 Lab 1 - Phase 3: 모니터링 테스트 스크립트
# 사용법: ./test_monitoring.sh

echo "=== 모니터링 시스템 테스트 시작 ==="
echo ""

echo "1. 모니터링 서비스 상태 확인 중..."

# 서비스 상태 확인
cd monitoring 2>/dev/null || echo "monitoring 디렉토리로 이동할 수 없습니다"

if [ -f "docker-compose.monitoring.yml" ]; then
    echo "=== 모니터링 서비스 상태 ==="
    docker-compose -f docker-compose.monitoring.yml ps
else
    echo "❌ 모니터링 스택이 설정되지 않았습니다"
    exit 1
fi

cd ..

echo ""
echo "2. 서비스 헬스 체크 수행 중..."

# Prometheus 헬스 체크
PROMETHEUS_HEALTH=$(curl -s http://localhost:9090/-/healthy 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "✅ Prometheus 헬스 체크 통과"
else
    echo "❌ Prometheus 헬스 체크 실패"
fi

# Grafana 헬스 체크
GRAFANA_HEALTH=$(curl -s http://localhost:3001/api/health 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "✅ Grafana 헬스 체크 통과"
else
    echo "❌ Grafana 헬스 체크 실패"
fi

# cAdvisor 헬스 체크
CADVISOR_HEALTH=$(curl -s http://localhost:8080/healthz 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "✅ cAdvisor 헬스 체크 통과"
else
    echo "❌ cAdvisor 헬스 체크 실패"
fi

echo ""
echo "3. Prometheus 타겟 상태 확인 중..."

# Prometheus 타겟 확인
TARGETS_RESPONSE=$(curl -s http://localhost:9090/api/v1/targets 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "✅ Prometheus 타겟 API 응답 정상"
    
    # 활성 타겟 수 확인
    if command -v jq &> /dev/null; then
        ACTIVE_TARGETS=$(echo "$TARGETS_RESPONSE" | jq '.data.activeTargets | length' 2>/dev/null)
        UP_TARGETS=$(echo "$TARGETS_RESPONSE" | jq '.data.activeTargets | map(select(.health == "up")) | length' 2>/dev/null)
        echo "   - 전체 타겟: $ACTIVE_TARGETS"
        echo "   - 정상 타겟: $UP_TARGETS"
    else
        echo "   - jq가 설치되지 않아 상세 정보를 확인할 수 없습니다"
    fi
else
    echo "❌ Prometheus 타겟 API 응답 실패"
fi

echo ""
echo "4. 애플리케이션 메트릭 수집 확인 중..."

# 애플리케이션 메트릭 확인
APP_METRICS=$(curl -s http://localhost:3000/metrics 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "✅ 애플리케이션 메트릭 수집 정상"
    
    # 주요 메트릭 확인
    HTTP_REQUESTS=$(echo "$APP_METRICS" | grep -c "http_requests_total" || echo "0")
    HTTP_DURATION=$(echo "$APP_METRICS" | grep -c "http_request_duration_seconds" || echo "0")
    NODEJS_METRICS=$(echo "$APP_METRICS" | grep -c "nodejs_" || echo "0")
    
    echo "   - HTTP 요청 메트릭: $HTTP_REQUESTS"
    echo "   - HTTP 응답시간 메트릭: $HTTP_DURATION"
    echo "   - Node.js 메트릭: $NODEJS_METRICS"
else
    echo "❌ 애플리케이션 메트릭 수집 실패"
fi

echo ""
echo "5. 부하 생성 및 메트릭 테스트..."

# Apache Bench로 부하 생성
if command -v ab &> /dev/null; then
    echo "부하 생성 중 (1000 요청, 10 동시)..."
    ab -n 1000 -c 10 -q http://localhost:3000/load-test > /dev/null 2>&1 &
    AB_PID=$!
    
    # 부하 생성 중 메트릭 확인
    sleep 5
    echo "부하 생성 중 메트릭 확인..."
    
    # HTTP 요청 수 확인
    HTTP_TOTAL=$(curl -s http://localhost:3000/metrics | grep "http_requests_total" | head -1 | awk '{print $2}' 2>/dev/null || echo "0")
    echo "   - 총 HTTP 요청 수: $HTTP_TOTAL"
    
    # 부하 생성 완료 대기
    wait $AB_PID 2>/dev/null
    echo "✅ 부하 테스트 완료"
else
    echo "Apache Bench가 설치되지 않아 부하 테스트를 건너뜁니다"
fi

echo ""
echo "6. Prometheus 쿼리 테스트..."

# 기본 Prometheus 쿼리 테스트
echo "=== Prometheus 쿼리 테스트 ==="

# HTTP 요청 비율 쿼리
HTTP_RATE_QUERY="rate(http_requests_total[5m])"
HTTP_RATE_RESULT=$(curl -s "http://localhost:9090/api/v1/query?query=$(echo $HTTP_RATE_QUERY | sed 's/ /%20/g')" 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "✅ HTTP 요청 비율 쿼리 성공"
else
    echo "❌ HTTP 요청 비율 쿼리 실패"
fi

# 메모리 사용량 쿼리
MEMORY_QUERY="container_memory_usage_bytes"
MEMORY_RESULT=$(curl -s "http://localhost:9090/api/v1/query?query=$MEMORY_QUERY" 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "✅ 메모리 사용량 쿼리 성공"
else
    echo "❌ 메모리 사용량 쿼리 실패"
fi

echo ""
echo "7. 알림 규칙 상태 확인..."

# 알림 규칙 상태 확인
RULES_RESPONSE=$(curl -s http://localhost:9090/api/v1/rules 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "✅ 알림 규칙 API 응답 정상"
    
    if command -v jq &> /dev/null; then
        RULE_GROUPS=$(echo "$RULES_RESPONSE" | jq '.data.groups | length' 2>/dev/null)
        echo "   - 알림 규칙 그룹 수: $RULE_GROUPS"
    fi
else
    echo "❌ 알림 규칙 API 응답 실패"
fi

echo ""
echo "8. 전체 시스템 상태 요약..."

# 전체 상태 요약
echo "=== 모니터링 시스템 상태 요약 ==="

# 서비스 상태 체크
PROMETHEUS_STATUS="❌"
GRAFANA_STATUS="❌"
CADVISOR_STATUS="❌"
APP_METRICS_STATUS="❌"

curl -s http://localhost:9090/-/healthy >/dev/null 2>&1 && PROMETHEUS_STATUS="✅"
curl -s http://localhost:3001/api/health >/dev/null 2>&1 && GRAFANA_STATUS="✅"
curl -s http://localhost:8080/healthz >/dev/null 2>&1 && CADVISOR_STATUS="✅"
curl -s http://localhost:3000/metrics >/dev/null 2>&1 && APP_METRICS_STATUS="✅"

echo "서비스 상태:"
echo "  - Prometheus: $PROMETHEUS_STATUS"
echo "  - Grafana: $GRAFANA_STATUS"
echo "  - cAdvisor: $CADVISOR_STATUS"
echo "  - 애플리케이션 메트릭: $APP_METRICS_STATUS"

# 접속 정보 안내
echo ""
echo "접속 정보:"
echo "  - Prometheus: http://localhost:9090"
echo "  - Grafana: http://localhost:3001 (admin/admin)"
echo "  - cAdvisor: http://localhost:8080"
echo "  - 애플리케이션: http://localhost:3000"

echo ""
echo "Grafana 대시보드 설정 가이드:"
echo "1. http://localhost:3001 접속 (admin/admin)"
echo "2. 좌측 메뉴에서 'Dashboards' 클릭"
echo "3. 'Import' 버튼 클릭"
echo "4. Dashboard ID '193' 입력 (Docker 모니터링 대시보드)"
echo "5. 'Load' 클릭 후 Prometheus 데이터소스 선택"

echo ""
echo "=== 모니터링 시스템 테스트 완료 ==="
echo ""