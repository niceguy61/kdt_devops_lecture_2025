#!/bin/bash

# Week 2 Day 3 Lab 2: 분산 추적 테스트 및 검증
# 사용법: ./test_distributed_tracing.sh

echo "=== 분산 추적 테스트 및 검증 시작 ==="

cd ~/docker-tracing-lab

# 서비스 상태 확인
echo "1. 서비스 상태 확인 중..."
echo "Docker Compose 서비스 상태:"
docker-compose ps

echo ""
echo "서비스 헬스체크:"
services=("api-gateway:3001" "user-service:3002" "order-service:3003" "jaeger:16686" "grafana:3000" "prometheus:9090")

for service in "${services[@]}"; do
    IFS=':' read -r name port <<< "$service"
    if curl -s "http://localhost:$port/health" > /dev/null 2>&1 || curl -s "http://localhost:$port" > /dev/null 2>&1; then
        echo "✅ $name (port $port) - 정상"
    else
        echo "❌ $name (port $port) - 응답 없음"
    fi
done

echo ""
echo "2. 기본 트래픽 생성 중..."

# 단일 서비스 호출 테스트
echo "📞 단일 서비스 호출 테스트:"
for i in {1..5}; do
    echo "  사용자 $i 조회 중..."
    curl -s "http://localhost:3001/api/users/$i" | jq -r '.name // "Error"' 2>/dev/null || echo "Error"
    sleep 1
done

echo ""
echo "3. 복합 서비스 호출 테스트 (분산 추적 생성)..."

# 복합 요청으로 분산 추적 생성
echo "🔄 복합 서비스 호출 테스트:"
for i in {1..3}; do
    echo "  사용자 $i의 주문 정보 조회 중..."
    curl -s "http://localhost:3001/api/user-orders/$i" | jq -r '.user.name // "Error"' 2>/dev/null || echo "Error"
    sleep 2
done

echo ""
echo "4. 주문 생성 테스트 (POST 요청)..."

# 주문 생성 요청
echo "📦 주문 생성 테스트:"
for i in {1..3}; do
    product_list=("laptop" "mouse" "keyboard" "monitor" "headphones")
    product=${product_list[$((RANDOM % ${#product_list[@]}))]}
    quantity=$((RANDOM % 3 + 1))
    
    echo "  사용자 $i - $product x$quantity 주문 생성 중..."
    curl -s -X POST "http://localhost:3001/api/orders" \
        -H "Content-Type: application/json" \
        -d "{\"user_id\": $i, \"product\": \"$product\", \"quantity\": $quantity}" \
        | jq -r '.status // "Error"' 2>/dev/null || echo "Error"
    sleep 1
done

echo ""
echo "5. 오류 시나리오 테스트..."

# 의도적 오류 생성
echo "❌ 오류 시나리오 테스트:"
echo "  존재하지 않는 사용자 조회 (404 오류):"
curl -s "http://localhost:3001/api/users/999" | jq -r '.error // "No error"' 2>/dev/null || echo "Connection error"

echo "  잘못된 주문 데이터 (400 오류):"
curl -s -X POST "http://localhost:3001/api/orders" \
    -H "Content-Type: application/json" \
    -d '{"invalid": "data"}' \
    | jq -r '.error // "No error"' 2>/dev/null || echo "Connection error"

echo ""
echo "6. 부하 테스트 (분산 추적 데이터 생성)..."

# 부하 테스트로 더 많은 추적 데이터 생성
echo "🚀 부하 테스트 실행 중 (30초)..."
end_time=$((SECONDS + 30))

while [ $SECONDS -lt $end_time ]; do
    # 랜덤 사용자 조회
    user_id=$((RANDOM % 5 + 1))
    curl -s "http://localhost:3001/api/users/$user_id" > /dev/null &
    
    # 랜덤 주문 생성
    if [ $((RANDOM % 3)) -eq 0 ]; then
        curl -s -X POST "http://localhost:3001/api/orders" \
            -H "Content-Type: application/json" \
            -d "{\"user_id\": $user_id, \"product\": \"test\", \"quantity\": 1}" > /dev/null &
    fi
    
    # 복합 요청
    if [ $((RANDOM % 4)) -eq 0 ]; then
        curl -s "http://localhost:3001/api/user-orders/$user_id" > /dev/null &
    fi
    
    sleep 0.5
done

# 백그라운드 프로세스 정리
wait

echo ""
echo "7. 관측성 도구 접속 정보..."

echo ""
echo "=== 🎯 관측성 도구 접속 정보 ==="
echo ""
echo "📊 Grafana 대시보드:"
echo "  URL: http://localhost:3000"
echo "  계정: admin / admin"
echo "  대시보드:"
echo "    - Complete Observability Stack (메트릭 + 추적 통합)"
echo "    - Microservices Detail (서비스별 상세 메트릭)"
echo "    - Jaeger Integration (분산 추적 연동)"
echo ""
echo "🔍 Jaeger 분산 추적:"
echo "  URL: http://localhost:16686"
echo "  기능:"
echo "    - Service Map: 서비스 의존성 시각화"
echo "    - Trace Search: 특정 추적 검색"
echo "    - Timeline View: 요청 처리 시간 분석"
echo "    - Error Tracking: 오류 발생 지점 추적"
echo ""
echo "📈 Prometheus 메트릭:"
echo "  URL: http://localhost:9090"
echo "  주요 메트릭:"
echo "    - http_requests_total: 총 요청 수"
echo "    - http_request_duration_seconds: 응답 시간"
echo "    - user_service_db_queries_total: DB 쿼리 수"
echo ""
echo "🔧 OpenTelemetry Collector:"
echo "  Metrics: http://localhost:8889/metrics"
echo "  OTLP gRPC: localhost:4317"
echo "  OTLP HTTP: localhost:4318"
echo ""

echo "8. 분산 추적 분석 가이드..."

echo ""
echo "=== 🔍 분산 추적 분석 가이드 ==="
echo ""
echo "1. Jaeger UI에서 확인할 내용:"
echo "   ✅ Service Map에서 서비스 간 의존성 확인"
echo "   ✅ 개별 Trace에서 요청 처리 시간 분석"
echo "   ✅ 오류 발생 시 Error Span 확인"
echo "   ✅ 데이터베이스 쿼리 성능 분석"
echo ""
echo "2. Grafana에서 확인할 내용:"
echo "   ✅ 전체 시스템 Request Rate 및 Response Time"
echo "   ✅ 서비스별 Error Rate 모니터링"
echo "   ✅ 데이터베이스 쿼리 성능 메트릭"
echo "   ✅ 시스템 전반의 Health Status"
echo ""
echo "3. 성능 최적화 포인트:"
echo "   🎯 가장 느린 Span 식별 및 최적화"
echo "   🎯 데이터베이스 쿼리 최적화"
echo "   🎯 서비스 간 통신 최적화"
echo "   🎯 캐싱 전략 수립"
echo ""

echo "9. 실습 완료 확인..."

echo ""
echo "=== ✅ 실습 완료 체크리스트 ==="
echo ""
echo "다음 항목들을 확인해보세요:"
echo ""
echo "□ Jaeger UI에서 분산 추적 데이터 확인"
echo "□ Service Map에서 api-gateway → user-service → postgres 흐름 확인"
echo "□ 개별 Trace에서 각 서비스의 처리 시간 확인"
echo "□ Grafana에서 통합 관측성 대시보드 확인"
echo "□ Prometheus에서 메트릭 데이터 확인"
echo "□ 오류 시나리오의 추적 데이터 분석"
echo "□ 성능 병목 지점 식별"
echo ""

echo "=== 🎓 분산 추적 테스트 완료 ==="
echo ""
echo "🎉 축하합니다! OpenTelemetry와 Jaeger를 활용한"
echo "   완전한 관측성 시스템을 성공적으로 구축했습니다."
echo ""
echo "💡 추가 학습 제안:"
echo "   - 커스텀 메트릭 추가"
echo "   - 알림 규칙 설정"
echo "   - 대시보드 커스터마이징"
echo "   - 성능 최적화 실험"