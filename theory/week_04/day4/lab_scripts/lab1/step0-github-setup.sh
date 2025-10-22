#!/bin/bash

# Week 4 Day 4 Lab 1: GitHub 저장소 설정
# 설명: 학생 개인 GitHub 저장소 생성 및 초기 푸시
# 사용법: ./step0-github-setup.sh

set -e

echo "=== GitHub 저장소 설정 시작 ==="
echo ""
echo "📝 사전 준비사항:"
echo "1. GitHub 계정이 있어야 합니다 (https://github.com)"
echo "2. Git이 설치되어 있어야 합니다"
echo "3. GitHub에 로그인되어 있어야 합니다"
echo ""

# GitHub 사용자 이름 입력
read -p "GitHub 사용자 이름을 입력하세요: " GITHUB_USER

if [ -z "$GITHUB_USER" ]; then
    echo "❌ GitHub 사용자 이름이 필요합니다"
    exit 1
fi

REPO_NAME="cicd-demo-app"

echo ""
echo "=== 저장소 정보 ==="
echo "사용자: $GITHUB_USER"
echo "저장소: $REPO_NAME"
echo "URL: https://github.com/$GITHUB_USER/$REPO_NAME"
echo ""

# 1. 작업 디렉토리 생성
echo "1/7 작업 디렉토리 생성 중..."
rm -rf $REPO_NAME
mkdir $REPO_NAME
cd $REPO_NAME

# 2. 프로젝트 파일 복사
echo "2/7 프로젝트 파일 복사 중..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp -r "$SCRIPT_DIR/cicd-lab"/* .
cp -r "$SCRIPT_DIR/cicd-lab"/.github .
cp "$SCRIPT_DIR/cicd-lab"/.gitignore .

# 3. Git 초기화
echo "3/7 Git 초기화 중..."
git init
git add .
git commit -m "Initial commit: CI/CD Demo Application"

# 4. GitHub 저장소 생성 안내
echo ""
echo "4/7 GitHub 저장소 생성"
echo ""
echo "🌐 웹 브라우저에서 GitHub 저장소를 생성하세요:"
echo ""
echo "1. https://github.com/new 접속"
echo "2. Repository name: $REPO_NAME"
echo "3. Public 선택"
echo "4. ⚠️  'Add a README file' 체크 해제 (중요!)"
echo "5. 'Create repository' 클릭"
echo ""
read -p "저장소 생성 완료 후 Enter를 누르세요..."

# 5. Remote 추가
echo "5/7 Remote 추가 중..."
git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
git branch -M main

# 6. 코드 푸시
echo "6/7 코드 푸시 중..."
echo ""
echo "⚠️  GitHub 인증이 필요합니다:"
echo "- Personal Access Token 사용 권장"
echo "- Token 생성: https://github.com/settings/tokens"
echo "- Scopes: repo (전체 선택)"
echo ""
git push -u origin main

# 7. Actions 확인
echo ""
echo "7/7 GitHub Actions 자동 실행 확인"

echo ""
echo "=== GitHub 저장소 설정 완료 ==="
echo ""
echo "✅ 저장소 URL: https://github.com/$GITHUB_USER/$REPO_NAME"
echo "✅ Actions URL: https://github.com/$GITHUB_USER/$REPO_NAME/actions"
echo ""
echo "📍 현재 위치: $PWD"
echo ""
echo "다음 단계:"
echo "1. 브라우저에서 Actions 탭 확인"
echo "   → CI/CD 파이프라인이 자동으로 실행됩니다!"
echo ""
echo "2. 로컬 테스트 (선택사항):"
echo "   docker-compose up -d"
echo "   curl http://localhost/api/health"
echo ""
echo "3. 코드 변경 후 CI/CD 재실행:"
echo "   echo '# Update' >> README.md"
echo "   git add README.md"
echo "   git commit -m 'Test CI/CD'"
echo "   git push"
