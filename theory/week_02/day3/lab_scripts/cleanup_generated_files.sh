#!/bin/bash

# Week 2 Day 3 Lab Scripts - 생성된 파일 정리 스크립트
# Git 정리를 위해 스크립트로 생성된 모든 파일과 디렉토리를 삭제

echo "=== Week 2 Day 3 Lab Scripts 생성 파일 정리 ==="

# 현재 디렉토리 확인
if [[ ! -d "monitoring" && ! -d "optimization" && ! -d "security" ]]; then
    echo "❌ lab_scripts 디렉토리에서 실행해주세요"
    exit 1
fi

echo "다음 항목들이 삭제됩니다:"
echo ""

# 삭제할 항목들 나열
echo "📁 디렉토리:"
find . -type d -name "monitoring" -o -name "scan-results" -o -name "performance-results" -o -name "configs" -o -name "app" | sed 's/^/  /'

echo ""
echo "📄 생성된 파일:"
find . -name "*.txt" -o -name "*.json" -o -name "*.yml" -o -name "*.dat" -o -name "cookies.txt" | grep -v "package.json" | sed 's/^/  /'

echo ""
echo "🐳 Docker 관련:"
echo "  - Docker 컨테이너 (모니터링 스택)"
echo "  - Docker 볼륨 (prometheus-data, grafana-data)"
echo "  - Docker 네트워크 (monitoring-network)"

echo ""
read -p "정말로 모든 생성된 파일을 삭제하시겠습니까? (y/N): " confirm

if [[ $confirm != [yY] ]]; then
    echo "취소되었습니다."
    exit 0
fi

echo ""
echo "🧹 정리 시작..."

# 1. Docker 컨테이너 및 볼륨 정리
echo "1. Docker 리소스 정리..."
if [ -f "monitoring/monitoring/docker-compose.monitoring.yml" ]; then
    cd monitoring/monitoring
    docker-compose -f docker-compose.monitoring.yml down -v --remove-orphans 2>/dev/null
    cd ../..
fi

if [ -f "security-optimization-lab/docker-compose.optimized.yml" ]; then
    cd security-optimization-lab
    docker-compose -f docker-compose.optimized.yml down -v --remove-orphans 2>/dev/null
    cd ..
fi

# Docker 이미지 정리 (생성된 것들만)
docker rmi $(docker images | grep -E "(error-test-app|optimized-app|secure-app)" | awk '{print $3}') 2>/dev/null

echo "   ✅ Docker 리소스 정리 완료"

# 2. 생성된 디렉토리 삭제
echo "2. 생성된 디렉토리 삭제..."
rm -rf monitoring/monitoring 2>/dev/null
rm -rf security/scan-results 2>/dev/null
rm -rf security-optimization-lab/performance-results 2>/dev/null
rm -rf security-optimization-lab/scan-results 2>/dev/null
rm -rf security-optimization-lab/monitoring 2>/dev/null
rm -rf security-optimization-lab/configs 2>/dev/null
rm -rf security-optimization-lab/app 2>/dev/null
rm -rf security-optimization-lab/scripts 2>/dev/null

echo "   ✅ 디렉토리 삭제 완료"

# 3. 생성된 파일 삭제
echo "3. 생성된 파일 삭제..."

# 모니터링 관련 파일
rm -f monitoring/monitoring-test-report.txt 2>/dev/null
rm -f monitoring/cookies.txt 2>/dev/null

# 성능 테스트 결과 파일
find . -name "*-test.txt" -delete 2>/dev/null
find . -name "*-test.dat" -delete 2>/dev/null
find . -name "*-report.txt" -delete 2>/dev/null
find . -name "performance-*.txt" -delete 2>/dev/null

# 보안 스캔 결과 파일
find . -name "*-scan.json" -delete 2>/dev/null
find . -name "security-*.txt" -delete 2>/dev/null

# Docker Compose 파일 (생성된 것들)
rm -f security-optimization-lab/docker-compose.optimized.yml 2>/dev/null

# 기타 생성된 파일
rm -f cookies.txt 2>/dev/null

echo "   ✅ 파일 삭제 완료"

# 4. 빈 디렉토리 정리
echo "4. 빈 디렉토리 정리..."
find . -type d -empty -delete 2>/dev/null
echo "   ✅ 빈 디렉토리 정리 완료"

# 5. 최종 확인
echo ""
echo "🔍 정리 결과 확인:"

# 남은 파일 확인
REMAINING_FILES=$(find . -name "*.txt" -o -name "*.json" -o -name "*.dat" | grep -v -E "(package\.json|README\.md)" | wc -l)
REMAINING_DIRS=$(find . -type d | grep -v -E "^\./?$|^\./\.(git|vscode)" | wc -l)

echo "   - 남은 생성 파일: ${REMAINING_FILES}개"
echo "   - 남은 디렉토리: $((REMAINING_DIRS - 1))개 (현재 디렉토리 제외)"

if [ "$REMAINING_FILES" -eq 0 ]; then
    echo "   ✅ 모든 생성 파일이 정리되었습니다"
else
    echo "   ⚠️  일부 파일이 남아있을 수 있습니다"
    find . -name "*.txt" -o -name "*.json" -o -name "*.dat" | grep -v -E "(package\.json|README\.md)" | sed 's/^/     /'
fi

echo ""
echo "=== 정리 완료 ==="
echo ""
echo "Git 상태 확인:"
echo "git status"
echo ""
echo "변경사항 커밋:"
echo "git add ."
echo "git commit -m 'Clean up generated files from Week 2 Day 3 labs'"