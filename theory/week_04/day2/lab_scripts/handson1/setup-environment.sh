#!/bin/bash

# Week 4 Day 2 Hands-on 1: 환경 준비
# 기본 네트워크와 디렉토리 구조 생성

echo "=== API Gateway 고급 실습 환경 준비 시작 ==="
echo ""

# Docker 네트워크 생성
echo "1. Docker 네트워크 생성 중..."
if docker network inspect api-gateway-net >/dev/null 2>&1; then
    echo "   ℹ️  네트워크가 이미 존재합니다"
else
    docker network create api-gateway-net
    echo "   ✅ 네트워크 생성 완료"
fi

# 작업 디렉토리 생성
echo ""
echo "2. 작업 디렉토리 생성 중..."
mkdir -p api-gateway-advanced/{kong,consul,services,monitoring}
cd api-gateway-advanced
echo "   ✅ 디렉토리 생성 완료"

echo ""
echo "=== 환경 준비 완료 ==="
echo ""
echo "작업 디렉토리: api-gateway-advanced"
echo "Docker 네트워크: api-gateway-net"
