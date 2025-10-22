#!/bin/bash

# Week 4 Day 4 Lab 1: API 테스트
# 설명: 배포된 애플리케이션의 API 엔드포인트 테스트
# 사용법: cd cicd-lab && ../step3-test-api.sh

set -e

echo "=== API 테스트 시작 ==="

# 1. Health Check
echo "1/3 Health Check 테스트 중..."
HEALTH=$(curl -s http://localhost/api/health)
echo "Response: $HEALTH"

if echo "$HEALTH" | grep -q "healthy"; then
    echo "✅ Health Check 성공"
else
    echo "❌ Health Check 실패"
    exit 1
fi

# 2. Users API
echo "2/3 Users API 테스트 중..."
USERS=$(curl -s http://localhost/api/users)
echo "Response: $USERS"

if echo "$USERS" | grep -q "Alice"; then
    echo "✅ Users API 성공"
else
    echo "❌ Users API 실패"
    exit 1
fi

# 3. Frontend
echo "3/3 Frontend 테스트 중..."
FRONTEND=$(curl -s http://localhost)

if echo "$FRONTEND" | grep -q "CI/CD Demo"; then
    echo "✅ Frontend 성공"
else
    echo "❌ Frontend 실패"
    exit 1
fi

echo ""
echo "=== API 테스트 완료 ==="
echo ""
echo "✅ 모든 테스트 통과!"
echo ""
echo "다음 단계: GitHub에 푸시하여 CI/CD 파이프라인 실행"
