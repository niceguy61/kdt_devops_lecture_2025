#!/bin/bash

# Week 2 Day 3 Lab 1: 보안 스캔 자동화 스크립트
# 사용법: ./security_scan.sh

echo "=== 컨테이너 보안 스캔 시작 ==="

# Trivy 설치 확인 및 설치
if ! command -v trivy &> /dev/null; then
    echo "1. Trivy 설치 중..."
    
    # Ubuntu/Debian 환경에서 Trivy 설치
    sudo apt-get update -qq
    sudo apt-get install -y wget apt-transport-https gnupg lsb-release
    
    # Trivy GPG 키 및 저장소 추가
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
    echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
    
    sudo apt-get update -qq
    sudo apt-get install -y trivy
    
    echo "✅ Trivy 설치 완료"
else
    echo "✅ Trivy 이미 설치됨"
fi

# 스캔 결과 디렉토리 생성
mkdir -p scan-results

echo ""
echo "2. 기본 이미지 취약점 스캔 중..."

# Node.js 16 이미지 스캔 (취약점이 많은 예시)
echo "   - Node 16 이미지 스캔..."
trivy image node:16 --severity HIGH,CRITICAL --format json --output scan-results/node16-scan.json
NODE16_VULNS=$(jq '.Results[]?.Vulnerabilities // [] | length' scan-results/node16-scan.json 2>/dev/null | awk '{sum+=$1} END {print sum+0}')

# Node.js 18 Alpine 이미지 스캔 (보안이 강화된 예시)
echo "   - Node 18 Alpine 이미지 스캔..."
trivy image node:18-alpine --severity HIGH,CRITICAL --format json --output scan-results/node18-alpine-scan.json
NODE18_VULNS=$(jq '.Results[]?.Vulnerabilities // [] | length' scan-results/node18-alpine-scan.json 2>/dev/null | awk '{sum+=$1} END {print sum+0}')

echo ""
echo "3. 스캔 결과 분석..."

# 결과 비교 및 출력
echo "=== 취약점 스캔 결과 비교 ==="
echo "Node 16 이미지 취약점: ${NODE16_VULNS}개"
echo "Node 18 Alpine 이미지 취약점: ${NODE18_VULNS}개"

if [ "$NODE18_VULNS" -lt "$NODE16_VULNS" ]; then
    REDUCTION=$((NODE16_VULNS - NODE18_VULNS))
    PERCENTAGE=$(( (REDUCTION * 100) / NODE16_VULNS ))
    echo "✅ Alpine 이미지 사용으로 ${REDUCTION}개 취약점 감소 (${PERCENTAGE}% 개선)"
else
    echo "⚠️  추가 보안 조치가 필요합니다"
fi

echo ""
echo "4. 상세 스캔 결과 확인..."

# 심각도별 취약점 요약
echo "=== Node 16 심각도별 취약점 ==="
trivy image node:16 --severity HIGH,CRITICAL --format table | head -20

echo ""
echo "=== Node 18 Alpine 심각도별 취약점 ==="
trivy image node:18-alpine --severity HIGH,CRITICAL --format table | head -20

echo ""
echo "=== 보안 스캔 완료 ==="
echo ""
echo "생성된 파일:"
echo "- scan-results/node16-scan.json: Node 16 상세 스캔 결과"
echo "- scan-results/node18-alpine-scan.json: Node 18 Alpine 상세 스캔 결과"
echo ""
echo "다음 단계: 보안 강화 Dockerfile 작성"