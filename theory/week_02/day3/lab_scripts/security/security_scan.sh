#!/bin/bash

# Week 2 Day 3 Lab 1 - Phase 1: 보안 스캔 자동화 스크립트
# 사용법: ./security_scan.sh

echo "=== 컨테이너 보안 스캔 시작 ==="
echo ""

# Trivy 설치 확인 및 설치
echo "1. Trivy 설치 확인 중..."
if ! command -v trivy &> /dev/null; then
    echo "Trivy가 설치되지 않았습니다. 설치를 시작합니다..."
    
    # Ubuntu/Debian 환경에서 Trivy 설치
    sudo apt-get update -qq
    sudo apt-get install -y wget apt-transport-https gnupg lsb-release
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
    echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
    sudo apt-get update -qq
    sudo apt-get install -y trivy
    
    echo "✅ Trivy 설치 완료"
else
    echo "✅ Trivy가 이미 설치되어 있습니다"
fi

echo ""
echo "2. 기본 이미지 취약점 스캔 중..."

# 취약점이 많은 이미지 스캔
echo "=== Node.js 16 이미지 스캔 ==="
trivy image node:16 --severity HIGH,CRITICAL --quiet > node16-scan.txt
NODE16_COUNT=$(cat node16-scan.txt | grep -c "HIGH\|CRITICAL" || echo "0")
echo "Node.js 16 취약점 수: $NODE16_COUNT"

# 보안이 강화된 이미지 스캔
echo ""
echo "=== Node.js 18 Alpine 이미지 스캔 ==="
trivy image node:18-alpine --severity HIGH,CRITICAL --quiet > node18-alpine-scan.txt
NODE18_COUNT=$(cat node18-alpine-scan.txt | grep -c "HIGH\|CRITICAL" || echo "0")
echo "Node.js 18 Alpine 취약점 수: $NODE18_COUNT"

# 결과 비교
echo ""
echo "=== 스캔 결과 비교 ==="
echo "Node.js 16: $NODE16_COUNT 개의 HIGH/CRITICAL 취약점"
echo "Node.js 18 Alpine: $NODE18_COUNT 개의 HIGH/CRITICAL 취약점"

if [ "$NODE18_COUNT" -lt "$NODE16_COUNT" ]; then
    REDUCTION=$((NODE16_COUNT - NODE18_COUNT))
    echo "✅ Alpine 이미지 사용으로 $REDUCTION 개의 취약점 감소!"
else
    echo "⚠️  추가 보안 조치가 필요합니다"
fi

# JSON 형태로 상세 결과 저장
echo ""
echo "3. 상세 스캔 결과 저장 중..."
trivy image node:16 --format json --output node16-detailed.json --quiet
trivy image node:18-alpine --format json --output node18-alpine-detailed.json --quiet
echo "✅ 상세 스캔 결과가 JSON 파일로 저장되었습니다"

echo ""
echo "=== 보안 스캔 완료 ==="
echo "다음 단계: 보안 강화 Dockerfile 작성"
echo ""