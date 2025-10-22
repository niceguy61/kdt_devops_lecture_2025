#!/bin/bash

# Week 4 Day 4 Lab 1: 로컬 환경 실행
# 설명: Docker Compose로 개발 환경 실행
# 사용법: cd cicd-lab && ../step2-run-local.sh

set -e

echo "=== 로컬 환경 실행 시작 ==="

# 현재 디렉토리 확인
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ docker-compose.yml을 찾을 수 없습니다."
    echo "cicd-lab 디렉토리에서 실행하세요: cd cicd-lab"
    exit 1
fi

# 1. 기존 컨테이너 정리
echo "1/4 기존 컨테이너 정리 중..."
docker-compose down -v 2>/dev/null || true

# 2. 이미지 빌드
echo "2/4 이미지 빌드 중..."
docker-compose build

# 3. 컨테이너 실행
echo "3/4 컨테이너 실행 중..."
docker-compose up -d

# 4. 헬스체크
echo "4/4 헬스체크 중..."
sleep 10
curl -f http://localhost/api/health || echo "Backend 시작 대기 중..."
sleep 5
curl -f http://localhost/api/health

echo ""
echo "=== 로컬 환경 실행 완료 ==="
echo ""
echo "접속 정보:"
echo "- Frontend: http://localhost"
echo "- Backend API: http://localhost/api/health"
echo "- Users API: http://localhost/api/users"
echo ""
echo "로그 확인: docker-compose logs -f"
echo "다음 단계: ../step3-test-api.sh"
