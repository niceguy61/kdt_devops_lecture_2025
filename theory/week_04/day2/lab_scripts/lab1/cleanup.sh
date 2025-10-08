#!/bin/bash

# Week 4 Day 2 Lab 1: 환경 정리
# 사용법: ./cleanup.sh

echo "=== 마이크로서비스 환경 정리 시작 ==="

# 사용자 확인
read -p "모든 컨테이너와 데이터를 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "정리 작업을 취소했습니다."
    exit 0
fi

# 1. 모든 관련 컨테이너 중지
echo "1. 컨테이너 중지 중..."
containers=(
    "kong-gateway"
    "kong-database" 
    "order-service"
    "product-service"
    "user-service"
    "order-cache"
    "product-db"
    "user-db"
    "consul-server"
    "user-service-2"
)

for container in "${containers[@]}"; do
    if docker ps -q -f name="$container" | grep -q .; then
        echo "  - $container 중지 중..."
        docker stop "$container" > /dev/null 2>&1
    fi
done

echo "✅ 모든 컨테이너 중지 완료"

# 2. 컨테이너 제거
echo "2. 컨테이너 제거 중..."
for container in "${containers[@]}"; do
    if docker ps -aq -f name="$container" | grep -q .; then
        echo "  - $container 제거 중..."
        docker rm "$container" > /dev/null 2>&1
    fi
done

echo "✅ 모든 컨테이너 제거 완료"

# 3. 네트워크 제거
echo "3. 네트워크 제거 중..."
if docker network ls | grep -q "microservices-net"; then
    docker network rm microservices-net > /dev/null 2>&1
    echo "✅ microservices-net 네트워크 제거 완료"
else
    echo "  - microservices-net 네트워크가 존재하지 않습니다"
fi

# 4. 볼륨 정리 (선택사항)
echo "4. 볼륨 정리 중..."
read -p "데이터 볼륨도 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # 사용하지 않는 볼륨 제거
    docker volume prune -f > /dev/null 2>&1
    echo "✅ 사용하지 않는 볼륨 제거 완료"
    
    # 로컬 데이터 디렉토리 제거
    if [ -d ~/microservices-lab ]; then
        rm -rf ~/microservices-lab
        echo "✅ 로컬 데이터 디렉토리 제거 완료"
    fi
else
    echo "  - 볼륨은 유지됩니다"
fi

# 5. 이미지 정리 (선택사항)
echo "5. 이미지 정리 중..."
read -p "사용하지 않는 이미지도 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker image prune -f > /dev/null 2>&1
    echo "✅ 사용하지 않는 이미지 제거 완료"
else
    echo "  - 이미지는 유지됩니다"
fi

# 6. 정리 상태 확인
echo "6. 정리 상태 확인 중..."
echo ""
echo "=== 정리 결과 ==="

# 남은 컨테이너 확인
remaining_containers=$(docker ps -a --format "table {{.Names}}\t{{.Status}}" | grep -E "(kong|consul|user-service|product-service|order-service)" || true)
if [ -n "$remaining_containers" ]; then
    echo "⚠️  남은 관련 컨테이너:"
    echo "$remaining_containers"
else
    echo "✅ 모든 관련 컨테이너 제거됨"
fi

# 남은 네트워크 확인
remaining_networks=$(docker network ls --format "table {{.Name}}" | grep "microservices" || true)
if [ -n "$remaining_networks" ]; then
    echo "⚠️  남은 관련 네트워크:"
    echo "$remaining_networks"
else
    echo "✅ 모든 관련 네트워크 제거됨"
fi

# 포트 사용 확인
echo ""
echo "포트 사용 상태 확인:"
ports=(8000 8001 8002 8500 3001 3002 3003)
for port in "${ports[@]}"; do
    if lsof -i :$port > /dev/null 2>&1; then
        echo "⚠️  포트 $port: 사용 중"
    else
        echo "✅ 포트 $port: 사용 가능"
    fi
done

echo ""
echo "=== 환경 정리 완료 ==="
echo ""
echo "정리된 항목:"
echo "- Kong API Gateway 및 관련 컨테이너"
echo "- Consul 서비스 디스커버리"
echo "- 마이크로서비스 (User, Product, Order)"
echo "- 데이터베이스 (PostgreSQL, MongoDB, Redis)"
echo "- Docker 네트워크 (microservices-net)"

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "- 데이터 볼륨 및 로컬 파일"
fi

echo ""
echo "실습을 다시 시작하려면 다음 스크립트들을 순서대로 실행하세요:"
echo "1. ./setup-network.sh"
echo "2. ./setup-consul.sh"
echo "3. ./deploy-user-service.sh"
echo "4. ./deploy-product-service.sh"
echo "5. ./deploy-order-service.sh"
echo "6. ./setup-kong.sh"
echo "7. ./configure-kong-routes.sh"
