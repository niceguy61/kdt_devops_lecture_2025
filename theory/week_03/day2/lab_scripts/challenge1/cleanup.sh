#!/bin/bash

# Challenge 1 정리 스크립트
cd "$(dirname "$0")"

echo "🧹 Challenge 1 환경 정리 시작..."

echo "🗑️ Deployment 삭제 중..."
kubectl delete deployment broken-app -n challenge1 --ignore-not-found=true
kubectl delete deployment resource-hungry -n challenge1 --ignore-not-found=true

echo "📦 네임스페이스 삭제 중..."
kubectl delete namespace challenge1 --ignore-not-found=true

echo "✅ Challenge 1 환경 정리 완료!"
