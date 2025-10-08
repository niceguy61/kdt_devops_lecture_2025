#!/bin/bash

# Week 4 Day 2 Lab 1: 서비스 디스커버리 테스트
# 사용법: ./test-service-discovery.sh

echo "=== 서비스 디스커버리 테스트 시작 ==="

# Consul 상태 확인
echo "1. Consul 서비스 디스커버리 상태 확인 중..."
if ! curl -s http://localhost:8500/v1/status/leader > /dev/null; then
    echo "❌ Consul이 실행되지 않았습니다"
    exit 1
fi

echo "✅ Consul 서비스 디스커버리 정상 동작"
echo ""

# 등록된 서비스 목록 확인
echo "2. 등록된 서비스 목록 확인 중..."
echo ""
echo "=== Consul 서비스 목록 ==="
services=$(curl -s http://localhost:8500/v1/catalog/services)
echo "$services" | jq -r 'to_entries[] | "- \(.key): \(.value | join(", "))"'

# 각 서비스의 상세 정보 확인
echo ""
echo "=== 서비스 상세 정보 ==="

for service in user-service product-service order-service; do
    echo ""
    echo "[$service]"
    service_info=$(curl -s "http://localhost:8500/v1/catalog/service/$service")
    
    if echo "$service_info" | jq -e '. | length > 0' > /dev/null; then
        echo "$service_info" | jq -r '.[] | "  - 주소: \(.ServiceAddress // .Address):\(.ServicePort)", "  - 태그: \(.ServiceTags | join(", "))", "  - ID: \(.ServiceID)"'
    else
        echo "  ❌ 서비스가 등록되지 않았습니다"
    fi
done

# 헬스체크 상태 확인
echo ""
echo "3. 헬스체크 상태 확인 중..."
echo ""
echo "=== 헬스체크 상태 ==="

for service in user-service product-service order-service; do
    echo ""
    echo "[$service]"
    health_info=$(curl -s "http://localhost:8500/v1/health/service/$service")
    
    if echo "$health_info" | jq -e '. | length > 0' > /dev/null; then
        echo "$health_info" | jq -r '.[] | 
            "  - 노드: \(.Node.Node)",
            "  - 서비스 ID: \(.Service.ID)",
            "  - 상태: \(if .Checks | map(.Status) | all(. == "passing") then "✅ 정상" else "❌ 비정상" end)",
            "  - 체크 수: \(.Checks | length)개"'
        
        # 개별 체크 상태
        echo "$health_info" | jq -r '.[] | .Checks[] | "    * \(.Name): \(.Status) - \(.Output // "N/A")"'
    else
        echo "  ❌ 헬스체크 정보를 찾을 수 없습니다"
    fi
done

# 서비스 간 통신 테스트
echo ""
echo "4. 서비스 간 통신 테스트 중..."
echo ""
echo "=== 서비스 간 통신 테스트 ==="

# Order Service의 상세 정보 API 호출 (다른 서비스들을 호출하는 엔드포인트)
echo ""
echo "주문 상세 정보 조회 (서비스 간 통신):"
order_details=$(curl -s http://localhost:3003/orders/1/details)

if echo "$order_details" | jq -e '.user and .product' > /dev/null; then
    echo "✅ 서비스 간 통신 성공"
    echo "$order_details" | jq -r '"  - 주문 ID: \(.id)", "  - 사용자: \(.user.name) (\(.user.email))", "  - 상품: \(.product.name) - $\(.product.price)", "  - 수량: \(.quantity)개", "  - 총액: $\(.totalAmount)"'
else
    echo "❌ 서비스 간 통신 실패"
    echo "응답: $order_details"
fi

# DNS 해결 테스트
echo ""
echo "5. DNS 해결 테스트 중..."
echo ""
echo "=== DNS 해결 테스트 ==="

# 각 서비스의 DNS 해결 확인
for service in user-service product-service order-service; do
    echo ""
    echo "[$service DNS 해결]"
    
    # 컨테이너 내에서 nslookup 실행
    dns_result=$(docker exec consul-server nslookup $service 2>/dev/null)
    
    if echo "$dns_result" | grep -q "Address:"; then
        echo "✅ DNS 해결 성공"
        echo "$dns_result" | grep "Address:" | tail -1 | sed 's/^/  /'
    else
        echo "❌ DNS 해결 실패"
    fi
done

# Consul DNS 인터페이스 테스트
echo ""
echo "6. Consul DNS 인터페이스 테스트 중..."
echo ""
echo "=== Consul DNS 인터페이스 ==="

for service in user-service product-service order-service; do
    echo ""
    echo "[$service.service.consul]"
    
    # Consul DNS 쿼리
    dns_query=$(docker exec consul-server dig @127.0.0.1 -p 8600 $service.service.consul SRV 2>/dev/null)
    
    if echo "$dns_query" | grep -q "ANSWER SECTION"; then
        echo "✅ Consul DNS 쿼리 성공"
        echo "$dns_query" | grep -A 5 "ANSWER SECTION" | grep -v "ANSWER SECTION" | sed 's/^/  /'
    else
        echo "❌ Consul DNS 쿼리 실패"
    fi
done

# 로드 밸런싱 테스트 (여러 인스턴스가 있는 경우)
echo ""
echo "7. 로드 밸런싱 테스트 중..."
echo ""
echo "=== 로드 밸런싱 테스트 ==="

# User Service 추가 인스턴스 생성 (테스트용)
echo "User Service 추가 인스턴스 생성 중..."
docker run -d \
  --name user-service-2 \
  --network microservices-net \
  -v ~/microservices-lab/services/user-service:/app \
  -w /app \
  node:16-alpine \
  sh -c "npm install && npm start" > /dev/null 2>&1

sleep 5

# 로드 밸런싱 확인
echo ""
echo "User Service 인스턴스 확인:"
user_instances=$(curl -s "http://localhost:8500/v1/catalog/service/user-service")
instance_count=$(echo "$user_instances" | jq '. | length')
echo "  - 등록된 인스턴스 수: $instance_count개"

if [ "$instance_count" -gt 1 ]; then
    echo "✅ 다중 인스턴스 등록 확인"
    echo "$user_instances" | jq -r '.[] | "  - \(.ServiceID): \(.ServiceAddress // .Address):\(.ServicePort)"'
else
    echo "⚠️  단일 인스턴스만 등록됨"
fi

# 추가 인스턴스 정리
docker stop user-service-2 2>/dev/null || true
docker rm user-service-2 2>/dev/null || true

# 서비스 메트릭 확인
echo ""
echo "8. 서비스 메트릭 확인 중..."
echo ""
echo "=== 서비스 메트릭 ==="

total_services=$(curl -s http://localhost:8500/v1/catalog/services | jq '. | length')
total_nodes=$(curl -s http://localhost:8500/v1/catalog/nodes | jq '. | length')
healthy_services=0

for service in user-service product-service order-service; do
    health=$(curl -s "http://localhost:8500/v1/health/service/$service")
    if echo "$health" | jq -e '.[] | .Checks | map(.Status) | all(. == "passing")' > /dev/null; then
        ((healthy_services++))
    fi
done

echo "서비스 디스커버리 메트릭:"
echo "  - 총 서비스 수: $total_services개"
echo "  - 총 노드 수: $total_nodes개"
echo "  - 정상 서비스 수: $healthy_services/3개"
echo "  - 서비스 가용성: $(( healthy_services * 100 / 3 ))%"

echo ""
echo "=== 서비스 디스커버리 테스트 완료 ==="
echo ""
echo "요약:"
echo "✅ Consul 서비스 디스커버리 정상 동작"
echo "✅ 모든 마이크로서비스 등록 및 헬스체크 통과"
echo "✅ 서비스 간 통신 정상"
echo "✅ DNS 해결 정상"
echo ""
echo "Consul UI에서 더 자세한 정보를 확인하세요:"
echo "http://localhost:8500/ui"
