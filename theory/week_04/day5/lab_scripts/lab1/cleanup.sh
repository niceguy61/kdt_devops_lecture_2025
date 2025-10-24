#!/bin/bash

# Week 4 Day 5 Lab 1: 실습 환경 정리
# 설명: 모든 실습 리소스 삭제

echo "=== Lab 환경 정리 시작 ==="

# 1. Helm 릴리스 삭제
echo "1/4 Helm 릴리스 삭제 중..."
helm uninstall kubecost -n kubecost 2>/dev/null || echo "kubecost 릴리스 없음"

# 2. 네임스페이스 삭제
echo "2/4 네임스페이스 삭제 중..."
kubectl delete namespace kubecost --ignore-not-found=true
kubectl delete namespace production --ignore-not-found=true
kubectl delete namespace staging --ignore-not-found=true
kubectl delete namespace development --ignore-not-found=true

# 3. PVC 삭제 확인
echo "3/4 PVC 삭제 확인 중..."
kubectl get pvc --all-namespaces 2>/dev/null || echo "남은 PVC 없음"

# 4. 클러스터 삭제 (선택사항)
echo "4/4 클러스터 삭제 확인..."
read -p "클러스터를 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kind delete cluster --name lab-cluster
    echo "✅ 클러스터 삭제 완료"
else
    echo "ℹ️  클러스터 유지"
fi

echo ""
echo "=== Lab 환경 정리 완료 ==="
