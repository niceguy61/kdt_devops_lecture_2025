#!/bin/bash

# Week 4 Day 2 Hands-on 1: 전체 고급 기능 자동 구축
# 사용법: ./setup-all-advanced.sh

echo "=========================================="
echo "  Week 4 Day 2 Hands-on 1: 고급 기능 구축"
echo "  프로덕션급 마이크로서비스 플랫폼"
echo "=========================================="
echo ""

# 시작 시간 기록
start_time=$(date +%s)

# Lab 1 기반 확인
echo "🔍 Step 0/4: Lab 1 기반 환경 확인"
if ! docker ps | grep -q "kong-gateway"; then
    echo "❌ Lab 1이 실행되지 않았습니다. 먼저 Lab 1을 완료해주세요."
    echo "   cd ../lab1 && ./setup-all-services.sh"
    exit 1
fi
echo "✅ Lab 1 기반 환경 확인 완료"
echo ""

# 1. JWT 인증 시스템 구축
echo "🔐 Step 1/4: JWT 인증 시스템 구축"
./setup-jwt-auth.sh
if [ $? -ne 0 ]; then
    echo "❌ JWT 인증 시스템 구축 실패"
    exit 1
fi
echo ""

# 2. 모니터링 시스템 구축
echo "📊 Step 2/4: 모니터링 시스템 구축"
./setup-monitoring.sh
if [ $? -ne 0 ]; then
    echo "❌ 모니터링 시스템 구축 실패"
    exit 1
fi
echo ""

# 3. 고급 라우팅 & 로드밸런싱
echo "🚀 Step 3/4: 고급 라우팅 & 로드밸런싱"
./setup-advanced-routing.sh
if [ $? -ne 0 ]; then
    echo "❌ 고급 라우팅 설정 실패"
    exit 1
fi
echo ""

# 4. 서킷 브레이커 & 헬스체크
echo "⚖️ Step 4/4: 서킷 브레이커 & 헬스체크"
./setup-circuit-breaker.sh
if [ $? -ne 0 ]; then
    echo "❌ 서킷 브레이커 설정 실패"
    exit 1
fi
echo ""

# 완료 시간 계산
end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))

echo "=========================================="
echo "🎉 고급 마이크로서비스 플랫폼 구축 완료!"
echo "⏱️  소요 시간: ${minutes}분 ${seconds}초"
echo "=========================================="
echo ""

# 최종 상태 확인
echo "🔍 최종 상태 확인 중..."
echo ""

# 실행 중인 컨테이너 확인
echo "=== 실행 중인 컨테이너 ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(consul|kong|user-service|product-service|order-service|auth-service|prometheus|grafana|chaos-service|node-exporter)"

echo ""
echo "=== 서비스 헬스체크 ==="

# 각 서비스 헬스체크
services=("user-service:3001" "product-service:3002" "order-service:3003" "auth-service:3004" "chaos-service:3006")
for service in "${services[@]}"; do
    name=$(echo $service | cut -d: -f1)
    port=$(echo $service | cut -d: -f2)
    
    if curl -s http://localhost:$port/health > /dev/null; then
        echo "✅ $name: 정상"
    else
        echo "❌ $name: 비정상"
    fi
done

# 모니터링 서비스 확인
if curl -s http://localhost:9090/-/healthy > /dev/null; then
    echo "✅ Prometheus: 정상"
else
    echo "❌ Prometheus: 비정상"
fi

if curl -s http://localhost:3000/api/health > /dev/null; then
    echo "✅ Grafana: 정상"
else
    echo "❌ Grafana: 비정상"
fi

# Kong 상태 확인
if curl -s http://localhost:8001/ > /dev/null; then
    echo "✅ Kong Gateway: 정상"
else
    echo "❌ Kong Gateway: 비정상"
fi

echo ""
echo "=== 접속 정보 ==="
echo "🌐 기본 서비스:"
echo "  - Consul UI: http://localhost:8500/ui"
echo "  - Kong Admin: http://localhost:8001"
echo "  - Kong Manager: http://localhost:8002"
echo ""
echo "📊 모니터링:"
echo "  - Prometheus: http://localhost:9090"
echo "  - Grafana: http://localhost:3000 (admin/admin)"
echo "  - Node Exporter: http://localhost:9100/metrics"
echo ""
echo "🔐 인증 서비스:"
echo "  - Auth Service: http://localhost:3004"
echo "  - 로그인: POST http://localhost:3004/auth/login"
echo "  - 토큰 검증: POST http://localhost:3004/auth/verify"
echo ""
echo "🎮 장애 테스트:"
echo "  - Chaos Service: http://localhost:3006"
echo "  - 장애 제어: POST http://localhost:3006/chaos/*"
echo ""
echo "🔗 API 엔드포인트 (Kong을 통한 접근):"
echo "  - 사용자 API: http://localhost:8000/api/users"
echo "  - 상품 API: http://localhost:8000/api/products"
echo "  - 주문 API: http://localhost:8000/api/orders"
echo "  - 장애 테스트: http://localhost:8000/api/chaos/test"
echo ""

# 고급 기능 테스트
echo "=== 고급 기능 테스트 ==="

echo "📋 JWT 토큰 생성 테스트:"
token_response=$(curl -s -X POST http://localhost:3004/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}')

if echo "$token_response" | grep -q "token"; then
    token=$(echo "$token_response" | jq -r '.token' 2>/dev/null)
    echo "  ✅ JWT 토큰 생성 성공: ${token:0:30}..."
else
    echo "  ❌ JWT 토큰 생성 실패"
fi

echo ""
echo "🔄 로드밸런싱 테스트 (5회 요청):"
for i in {1..5}; do
    response=$(curl -s http://localhost:8000/api/users)
    if echo "$response" | grep -q '"version"'; then
        version=$(echo "$response" | jq -r '.version // "v1"' 2>/dev/null || echo "v1")
        server=$(echo "$response" | jq -r '.metadata.server // "user-service-v1"' 2>/dev/null || echo "user-service-v1")
        echo "  요청 $i: $version ($server)"
    else
        echo "  요청 $i: v1 (user-service-v1)"
    fi
done

echo ""
echo "📊 Prometheus 메트릭 수집 확인:"
if curl -s http://localhost:9090/api/v1/query?query=up | grep -q "success"; then
    echo "  ✅ Prometheus 메트릭 수집 정상"
else
    echo "  ❌ Prometheus 메트릭 수집 실패"
fi

echo ""
echo "=========================================="
echo "🚀 Hands-on 1 실습 준비 완료!"
echo ""
echo "다음 단계:"
echo "1. 인증 테스트: JWT 토큰으로 API 호출"
echo "2. 모니터링 확인: Grafana 대시보드 탐색"
echo "3. 장애 시뮬레이션: Chaos Service로 장애 테스트"
echo "4. 성능 테스트: 로드밸런싱 및 캐싱 효과 확인"
echo "5. 실습 정리: ./cleanup-advanced.sh"
echo "=========================================="
