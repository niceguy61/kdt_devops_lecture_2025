#!/bin/bash

# Week 2 Day 3 Lab 1 - Phase 1: 보안 강화 이미지 빌드 스크립트
# 사용법: ./build_secure_image.sh

echo "=== 보안 강화 이미지 빌드 시작 ==="
echo ""

# 작업 디렉토리 확인
if [ ! -d "app" ]; then
    echo "❌ app 디렉토리가 없습니다. 먼저 샘플 애플리케이션을 생성해주세요."
    exit 1
fi

cd app

echo "1. 보안 강화 Dockerfile 생성 중..."

# 보안 강화 Dockerfile 생성
cat > Dockerfile.secure << 'EOF'
# 멀티스테이지 빌드 + 보안 강화
FROM node:18-alpine AS builder

# 보안: 최신 패키지 업데이트
RUN apk update && apk upgrade && apk add --no-cache dumb-init

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# 프로덕션 스테이지
FROM node:18-alpine AS production

# 보안: 최신 패키지 업데이트
RUN apk update && apk upgrade && apk add --no-cache dumb-init

# 보안: 비root 사용자 생성
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

WORKDIR /app

# 보안: 파일 소유권 설정
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --chown=appuser:appgroup . .

# 보안: 불필요한 파일 제거
RUN rm -rf tests/ *.md package-lock.json

# 보안: 비root 사용자로 전환
USER appuser

# 보안: 최소 권한 포트
EXPOSE 3000

# 보안: dumb-init 사용
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]
EOF

echo "✅ 보안 강화 Dockerfile 생성 완료"

echo ""
echo "2. 보안 강화 이미지 빌드 중..."
docker build -f Dockerfile.secure -t secure-app:v1 . --quiet

if [ $? -eq 0 ]; then
    echo "✅ 보안 강화 이미지 빌드 성공"
else
    echo "❌ 이미지 빌드 실패"
    exit 1
fi

echo ""
echo "3. 보안 강화 이미지 스캔 중..."
trivy image secure-app:v1 --severity HIGH,CRITICAL --quiet > ../secure-app-scan.txt
SECURE_COUNT=$(cat ../secure-app-scan.txt | grep -c "HIGH\|CRITICAL" || echo "0")

echo "보안 강화 이미지 취약점 수: $SECURE_COUNT"

# 이전 스캔 결과와 비교
if [ -f "../node16-scan.txt" ]; then
    NODE16_COUNT=$(cat ../node16-scan.txt | grep -c "HIGH\|CRITICAL" || echo "0")
    if [ "$SECURE_COUNT" -lt "$NODE16_COUNT" ]; then
        REDUCTION=$((NODE16_COUNT - SECURE_COUNT))
        echo "✅ 보안 강화로 $REDUCTION 개의 취약점 감소!"
    fi
fi

echo ""
echo "4. 이미지 크기 비교..."
echo "=== 이미지 크기 비교 ==="
docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep -E "(node:16|node:18-alpine|secure-app)"

cd ..

echo ""
echo "=== 보안 강화 이미지 빌드 완료 ==="
echo "다음 단계: 런타임 보안 적용"
echo ""