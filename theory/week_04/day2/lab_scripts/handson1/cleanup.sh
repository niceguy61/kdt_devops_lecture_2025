#!/bin/bash

# Week 4 Day 2 Hands-on 1: 환경 정리
# 모든 컨테이너와 리소스 제거

echo "=== API Gateway 고급 실습 환경 정리 시작 ==="
echo ""

# 컨테이너 중지 및 제거
echo "1. 컨테이너 중지 및 제거 중..."
containers=(
    "kong"
    "kong-database"
    "consul"
    "user-service"
    "product-service"
    "order-service"
    "auth-service"
    "prometheus"
    "grafana"
)

for container in "${containers[@]}"; do
    if docker ps -a | grep -q "$container"; then
        docker rm -f "$container" 2>/dev/null
        echo "   ✅ $container 제거 완료"
    fi
done

# 네트워크 제거
echo ""
echo "2. Docker 네트워크 제거 중..."
if docker network inspect api-gateway-net >/dev/null 2>&1; then
    docker network rm api-gateway-net
    echo "   ✅ 네트워크 제거 완료"
fi

# 작업 디렉토리 제거 (선택사항)
echo ""
echo "3. 작업 디렉토리 정리..."
read -p "작업 디렉토리를 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf ~/api-gateway-advanced
    echo "   ✅ 디렉토리 삭제 완료"
else
    echo "   ℹ️  디렉토리 유지"
fi

echo ""
echo "=== 환경 정리 완료 ==="
