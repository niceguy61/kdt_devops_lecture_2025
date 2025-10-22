#!/bin/bash

# Week 4 Day 4 Lab 1: CI/CD 자동 배포 환경 설정

set -e

echo "=== CI/CD Lab 환경 설정 시작 ==="
echo ""

# 1. GitHub 정보 입력
echo "1/4 GitHub 정보 입력"
read -p "GitHub Username: " GITHUB_USERNAME
read -p "Repository Name (예: cicd-demo-app): " GITHUB_REPO

# 2. .env 파일 생성
echo ""
echo "2/4 환경 변수 파일 생성 중..."
cd sample-app
cat > .env << EOF
GITHUB_USERNAME=$GITHUB_USERNAME
GITHUB_REPO=$GITHUB_REPO
EOF
echo "✅ .env 파일 생성 완료"

# 3. GitHub 저장소 생성 안내
echo ""
echo "3/4 GitHub 저장소 생성 필요"
echo ""
echo "다음 단계를 수행하세요:"
echo "1. https://github.com/new 접속"
echo "2. Repository name: $GITHUB_REPO"
echo "3. Public 선택"
echo "4. Create repository 클릭"
echo ""
read -p "저장소 생성 완료했으면 Enter..."

# 4. Git 초기화 및 푸시
echo ""
echo "4/4 Git 초기화 및 푸시 중..."
git init
git add .
git commit -m "Initial commit: CI/CD demo app"
git branch -M main
git remote add origin https://github.com/$GITHUB_USERNAME/$GITHUB_REPO.git
git push -u origin main

echo ""
echo "=== 설정 완료 ==="
echo ""
echo "다음 단계:"
echo "1. GitHub Actions 실행 확인: https://github.com/$GITHUB_USERNAME/$GITHUB_REPO/actions"
echo "2. 로컬 실행: export \$(cat .env | xargs) && docker-compose up -d"
echo "3. 접속: http://localhost:3000"
echo ""
echo "코드 수정 후 git push하면 자동 배포됩니다! 🚀"
