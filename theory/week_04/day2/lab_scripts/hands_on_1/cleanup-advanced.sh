#!/bin/bash

# Week 4 Day 2 Hands-on 1: 고급 기능 정리
# 사용법: ./cleanup-advanced.sh

echo "=== Hands-on 1 고급 기능 정리 시작 ==="

# 추가된 컨테이너들 정리
echo "1. 추가된 컨테이너들 정리 중..."
containers_to_remove=(
    "auth-service"
    "prometheus" 
    "grafana"
    "node-exporter"
    "chaos-service"
    "user-service-v2"
)

for container in "${containers_to_remove[@]}"; do
    if docker ps -a | grep -q "$container"; then
        echo "  - $container 정리 중..."
        docker stop "$container" 2>/dev/null || true
        docker rm "$container" 2>/dev/null || true
    fi
done

# Kong 플러그인 정리
echo "2. Kong 플러그인 정리 중..."
plugin_ids=$(curl -s http://localhost:8001/plugins | jq -r '.data[] | select(.name != "prometheus") | .id' 2>/dev/null)

if [ ! -z "$plugin_ids" ]; then
    echo "$plugin_ids" | while read plugin_id; do
        if [ ! -z "$plugin_id" ]; then
            curl -s -X DELETE "http://localhost:8001/plugins/$plugin_id" > /dev/null
            echo "  - 플러그인 $plugin_id 제거"
        fi
    done
else
    echo "  - 제거할 플러그인 없음"
fi

# Kong 업스트림 정리
echo "3. Kong 업스트림 정리 중..."
curl -s -X DELETE http://localhost:8001/upstreams/user-service-upstream 2>/dev/null || true

# Kong 서비스 원복
echo "4. Kong 서비스 원복 중..."
curl -s -X PATCH http://localhost:8001/services/user-service \
  --data "host=user-service" \
  --data "port=3001" > /dev/null

# Kong 소비자 정리
echo "5. Kong 소비자 정리 중..."
curl -s -X DELETE http://localhost:8001/consumers/microservices-client 2>/dev/null || true

# 생성된 디렉토리 정리 (선택적)
echo "6. 생성된 파일들 정리 중..."
read -p "생성된 서비스 파일들을 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf ~/microservices-lab/services/auth-service
    rm -rf ~/microservices-lab/services/user-service-v2
    rm -rf ~/microservices-lab/services/chaos-service
    rm -rf ~/microservices-lab/monitoring
    echo "  ✅ 서비스 파일들 삭제 완료"
else
    echo "  ℹ️ 서비스 파일들 유지 (수동 삭제 가능)"
fi

# 상태 확인
echo "7. 정리 후 상태 확인 중..."

# 남은 컨테이너 확인
echo ""
echo "=== 남은 컨테이너 (Lab 1 기본 환경) ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(consul|kong|user-service|product-service|order-service|db|cache)" || echo "기본 서비스들이 정리되었습니다."

# Kong 설정 확인
echo ""
echo "=== Kong 설정 상태 ==="
service_count=$(curl -s http://localhost:8001/services | jq '.data | length' 2>/dev/null || echo "0")
route_count=$(curl -s http://localhost:8001/routes | jq '.data | length' 2>/dev/null || echo "0")
plugin_count=$(curl -s http://localhost:8001/plugins | jq '.data | length' 2>/dev/null || echo "0")

echo "- 서비스: $service_count 개"
echo "- 라우트: $route_count 개" 
echo "- 플러그인: $plugin_count 개"

echo ""
echo "=== Hands-on 1 고급 기능 정리 완료 ==="
echo ""
echo "정리된 항목:"
echo "- ✅ JWT 인증 서비스"
echo "- ✅ 모니터링 시스템 (Prometheus, Grafana)"
echo "- ✅ User Service v2 (카나리 배포)"
echo "- ✅ Chaos Service (장애 테스트)"
echo "- ✅ Kong 고급 플러그인들"
echo "- ✅ Kong 업스트림 설정"
echo ""
echo "유지된 항목 (Lab 1 기본 환경):"
echo "- ✅ 기본 마이크로서비스들"
echo "- ✅ Consul 서비스 디스커버리"
echo "- ✅ Kong API Gateway 기본 설정"
echo ""
echo "Lab 1 환경도 정리하려면:"
echo "  cd ../lab1 && ./cleanup.sh"
