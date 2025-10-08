#!/bin/bash

# Challenge 1 정리 스크립트

echo "=== Challenge 1 정리 시작 ==="
echo ""

echo "1. w4d2-challenge 클러스터 삭제 중..."
kind delete cluster --name w4d2-challenge

echo ""
echo "2. Istio 다운로드 파일 정리 (선택사항)..."
read -p "Istio 다운로드 파일도 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf istio-1.20.0
    echo "   ✅ Istio 파일 삭제 완료"
else
    echo "   ℹ️  Istio 파일 유지 (다음 실습에서 재사용)"
fi

echo ""
echo "=== 정리 완료 ==="
echo ""
echo "💡 다시 시작하려면:"
echo "  ./setup-environment.sh"
echo "  ./deploy-broken-system.sh"
