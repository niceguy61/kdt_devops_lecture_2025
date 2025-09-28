#!/bin/bash

# Week 2 Day 3 Lab 1: 모니터링 시스템 종합 테스트
# 사용법: ./test_monitoring_system.sh

echo "=== 모니터링 시스템 종합 테스트 시작 ==="

# 1. 서비스 상태 확인
echo "1. 서비스 상태 확인 중..."

check_service() {
    local service_name=$1
    local port=$2
    local endpoint=${3:-""}
    
    if curl -f -s http://localhost:$port$endpoint >/dev/null 2>&1; then
        echo "✅ $service_name: 정상 동작"
        return 0
    else
        echo "❌ $service_name: 응답 없음"
        return 1
    fi
}

# 각 서비스 상태 확인
check_service "Prometheus" "9090" "/-/healthy"
check_service "Grafana" "3000"
check_service "AlertManager" "9093" "/-/healthy"
check_service "Elasticsearch" "9200" "/_cluster/health"
check_service "Kibana" "5601"
check_service "cAdvisor" "8080"
check_service "Node Exporter" "9100" "/metrics"
check_service "Webhook Server" "5000" "/health"

# 2. Prometheus 타겟 상태 확인
echo ""
echo "2. Prometheus 타겟 상태 확인 중..."
TARGETS_RESPONSE=$(curl -s http://localhost:9090/api/v1/targets 2>/dev/null)

if [ $? -eq 0 ]; then
    UP_TARGETS=$(echo "$TARGETS_RESPONSE" | grep -o '"health":"up"' | wc -l)
    DOWN_TARGETS=$(echo "$TARGETS_RESPONSE" | grep -o '"health":"down"' | wc -l)
    
    echo "✅ 활성 타겟: $UP_TARGETS개"
    if [ $DOWN_TARGETS -gt 0 ]; then
        echo "⚠️ 비활성 타겟: $DOWN_TARGETS개"
    fi
else
    echo "❌ Prometheus API 응답 실패"
fi

# 3. 메트릭 데이터 확인
echo ""
echo "3. 메트릭 데이터 확인 중..."

# CPU 메트릭 확인
CPU_METRICS=$(curl -s "http://localhost:9090/api/v1/query?query=rate(container_cpu_usage_seconds_total[5m])" 2>/dev/null | grep -o '"result":\[.*\]' | grep -o '\[.*\]')

if [ -n "$CPU_METRICS" ] && [ "$CPU_METRICS" != "[]" ]; then
    echo "✅ CPU 메트릭: 수집 중"
else
    echo "⚠️ CPU 메트릭: 데이터 없음"
fi

# 메모리 메트릭 확인
MEMORY_METRICS=$(curl -s "http://localhost:9090/api/v1/query?query=container_memory_usage_bytes" 2>/dev/null | grep -o '"result":\[.*\]' | grep -o '\[.*\]')

if [ -n "$MEMORY_METRICS" ] && [ "$MEMORY_METRICS" != "[]" ]; then
    echo "✅ 메모리 메트릭: 수집 중"
else
    echo "⚠️ 메모리 메트릭: 데이터 없음"
fi

# 4. Elasticsearch 인덱스 확인
echo ""
echo "4. Elasticsearch 로그 인덱스 확인 중..."
ES_INDICES=$(curl -s "http://localhost:9200/_cat/indices/logs-*?h=index,docs.count" 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$ES_INDICES" ]; then
    echo "✅ 로그 인덱스:"
    echo "$ES_INDICES"
else
    echo "⚠️ 로그 인덱스: 생성되지 않음 (로그 데이터 대기 중)"
fi

# 5. 로그 데이터 샘플 확인
echo ""
echo "5. 로그 데이터 샘플 확인 중..."
LOG_SAMPLE=$(curl -s "http://localhost:9200/logs-*/_search?size=1" 2>/dev/null | grep -o '"hits":{"total":{"value":[0-9]*' | grep -o '[0-9]*$')

if [ -n "$LOG_SAMPLE" ] && [ "$LOG_SAMPLE" -gt 0 ]; then
    echo "✅ 로그 문서: $LOG_SAMPLE개 수집됨"
else
    echo "⚠️ 로그 문서: 아직 수집되지 않음"
fi

# 6. 부하 테스트 및 알림 테스트
echo ""
echo "6. 부하 테스트 및 알림 테스트..."
read -p "부하 테스트를 실행하여 알림을 트리거하시겠습니까? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "부하 테스트 실행 중..."
    
    # 웹 서비스 확인
    if docker ps | grep -q wordpress-app; then
        TARGET="localhost:8080"
    elif docker ps | grep -q nginx-proxy; then
        TARGET="localhost:80"
    else
        echo "⚠️ 테스트할 웹 서비스를 찾을 수 없습니다."
        TARGET=""
    fi
    
    if [ -n "$TARGET" ]; then
        # 부하 생성
        echo "대상: $TARGET"
        for i in {1..30}; do
            curl -s $TARGET > /dev/null &
        done
        
        # CPU 집약적 작업
        docker run --rm --cpus=0.8 --memory=50m alpine \
            sh -c 'for i in $(seq 1 500000); do echo $i > /dev/null; done' &
        
        echo "부하 테스트 실행 중... (30초 대기)"
        sleep 30
        
        # 알림 확인
        echo "알림 상태 확인 중..."
        ALERTS=$(curl -s http://localhost:9093/api/v1/alerts 2>/dev/null | grep -o '"state":"firing"' | wc -l)
        
        if [ "$ALERTS" -gt 0 ]; then
            echo "🚨 활성 알림: $ALERTS개"
            echo "Webhook 로그 확인:"
            docker logs webhook --tail 10
        else
            echo "⏭️ 현재 활성 알림 없음"
        fi
    fi
else
    echo "부하 테스트를 건너뜁니다."
fi

# 7. 대시보드 접근성 테스트
echo ""
echo "7. 대시보드 접근성 테스트 중..."

# Grafana 로그인 테스트
GRAFANA_LOGIN=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"user":"admin","password":"admin"}' \
    http://localhost:3000/login 2>/dev/null)

if echo "$GRAFANA_LOGIN" | grep -q "message"; then
    echo "✅ Grafana: 로그인 가능"
else
    echo "⚠️ Grafana: 로그인 테스트 실패"
fi

# Kibana 상태 확인
KIBANA_STATUS=$(curl -s http://localhost:5601/api/status 2>/dev/null | grep -o '"level":"available"')

if [ -n "$KIBANA_STATUS" ]; then
    echo "✅ Kibana: 사용 가능"
else
    echo "⚠️ Kibana: 아직 초기화 중"
fi

# 8. 종합 결과 리포트
echo ""
echo "=== 모니터링 시스템 종합 테스트 완료 ==="
echo ""

# 점수 계산
TOTAL_CHECKS=8
PASSED_CHECKS=0

# 각 서비스별 점수 계산 (간단한 예시)
curl -f -s http://localhost:9090/-/healthy >/dev/null 2>&1 && ((PASSED_CHECKS++))
curl -f -s http://localhost:3000 >/dev/null 2>&1 && ((PASSED_CHECKS++))
curl -f -s http://localhost:9093/-/healthy >/dev/null 2>&1 && ((PASSED_CHECKS++))
curl -f -s http://localhost:9200/_cluster/health >/dev/null 2>&1 && ((PASSED_CHECKS++))
curl -f -s http://localhost:5601 >/dev/null 2>&1 && ((PASSED_CHECKS++))
curl -f -s http://localhost:8080 >/dev/null 2>&1 && ((PASSED_CHECKS++))
curl -f -s http://localhost:9100/metrics >/dev/null 2>&1 && ((PASSED_CHECKS++))
curl -f -s http://localhost:5000/health >/dev/null 2>&1 && ((PASSED_CHECKS++))

SCORE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))

echo "📊 시스템 상태 점수: $SCORE% ($PASSED_CHECKS/$TOTAL_CHECKS)"
echo ""

if [ $SCORE -ge 80 ]; then
    echo "🎉 우수: 모니터링 시스템이 정상적으로 구축되었습니다!"
elif [ $SCORE -ge 60 ]; then
    echo "✅ 양호: 대부분의 구성 요소가 정상 동작합니다."
else
    echo "⚠️ 개선 필요: 일부 구성 요소에 문제가 있습니다."
fi

echo ""
echo "🔗 접속 링크:"
echo "- Prometheus: http://localhost:9090"
echo "- Grafana: http://localhost:3000 (admin/admin)"
echo "- AlertManager: http://localhost:9093"
echo "- Kibana: http://localhost:5601"
echo "- cAdvisor: http://localhost:8080"
echo ""
echo "📝 추가 명령어:"
echo "- 알림 로그: docker logs webhook -f"
echo "- 서비스 상태: docker ps"
echo "- 부하 테스트: ./load-test.sh"