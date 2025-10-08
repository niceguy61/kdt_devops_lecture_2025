#!/bin/bash

# Week 4 Day 2 Lab 1: Docker 네트워크 구성
# 사용법: ./setup-network.sh

echo "=== 마이크로서비스 네트워크 구성 시작 ==="

# 기존 네트워크 정리
echo "1. 기존 네트워크 정리 중..."
docker network rm microservices-net 2>/dev/null || true

# 마이크로서비스 전용 네트워크 생성
echo "2. 마이크로서비스 네트워크 생성 중..."
docker network create --driver bridge microservices-net

# 네트워크 정보 확인
echo "3. 네트워크 정보 확인 중..."
docker network ls | grep microservices-net

if docker network inspect microservices-net >/dev/null 2>&1; then
    echo "✅ 네트워크 생성 완료"
    echo ""
    echo "네트워크 정보:"
    docker network inspect microservices-net | jq -r '.[0] | "- 이름: \(.Name)", "- 드라이버: \(.Driver)", "- 서브넷: \(.IPAM.Config[0].Subnet)"'
else
    echo "❌ 네트워크 생성 실패"
    exit 1
fi

echo ""
echo "=== 네트워크 구성 완료 ==="
