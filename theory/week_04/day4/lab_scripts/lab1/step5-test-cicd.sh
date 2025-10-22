#!/bin/bash

# Week 4 Day 4 Lab 1: CI/CD 파이프라인 테스트
# 설명: 코드 변경 후 GitHub에 푸시하여 CI/CD 자동 실행 테스트
# 사용법: cd cicd-lab && ../step5-test-cicd.sh

set -e

echo "=== CI/CD 파이프라인 테스트 시작 ==="

# 현재 디렉토리 확인
if [ ! -d ".git" ]; then
    echo "❌ Git 저장소가 아닙니다."
    echo "cicd-lab 디렉토리에서 실행하세요: cd cicd-lab"
    exit 1
fi

# 1. 버전 업데이트
echo "1/5 버전 업데이트 중..."
sed -i 's/Version 1.0.0/Version 1.1.0/g' frontend/src/App.js
sed -i 's/Current: 1.0.0/Current: 1.1.0/g' README.md

echo "✅ 버전 1.0.0 → 1.1.0 업데이트"

# 2. Git 커밋
echo "2/5 Git 커밋 중..."
git add .
git commit -m "chore: Update version to 1.1.0"

echo "✅ 커밋 완료"

# 3. GitHub 푸시
echo "3/5 GitHub에 푸시 중..."
git push

echo "✅ 푸시 완료"

# 4. Actions URL 확인
echo "4/5 GitHub Actions URL 확인 중..."
REMOTE_URL=$(git remote get-url origin)
REPO_URL=$(echo $REMOTE_URL | sed 's/\.git$//')
ACTIONS_URL="$REPO_URL/actions"

echo "✅ Actions URL: $ACTIONS_URL"

# 5. 안내
echo "5/5 CI/CD 파이프라인 실행 확인"

echo ""
echo "=== CI/CD 파이프라인 테스트 완료 ==="
echo ""
echo "다음 단계:"
echo "1. 브라우저에서 GitHub Actions 확인:"
echo "   $ACTIONS_URL"
echo ""
echo "2. 파이프라인 실행 확인:"
echo "   - ✅ Test 단계: Backend/Frontend 테스트"
echo "   - ✅ Build 단계: Docker 이미지 빌드"
echo "   - ✅ Deploy 단계: 배포 알림"
echo ""
echo "3. 실시간 로그 확인:"
echo "   gh run watch (GitHub CLI 필요)"
