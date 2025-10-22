#!/bin/bash

# Week 4 Day 4 Lab 1: 환경 정리
# 설명: 모든 컨테이너, 이미지, 볼륨 삭제
# 사용법: cd cicd-lab && ../cleanup.sh

echo "=== Lab 환경 정리 시작 ==="

# 1. 컨테이너 및 볼륨 삭제
echo "1/3 컨테이너 및 볼륨 삭제 중..."
docker-compose down -v 2>/dev/null || true

# 2. 이미지 삭제
echo "2/3 이미지 삭제 중..."
docker rmi cicd-lab-frontend cicd-lab-backend 2>/dev/null || true

# 3. 프로젝트 디렉토리 삭제
echo "3/3 프로젝트 디렉토리 삭제 중..."
cd ..
read -p "프로젝트 디렉토리를 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf cicd-lab
    echo "✅ 프로젝트 디렉토리 삭제 완료"
else
    echo "ℹ️  프로젝트 디렉토리 유지"
fi

echo ""
echo "=== Lab 환경 정리 완료 ==="
