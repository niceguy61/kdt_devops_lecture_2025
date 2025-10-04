#!/bin/bash

# Week 3 Day 4 Lab 1: 환경 정리
# 사용법: ./cleanup.sh

set -e

echo "=== Lab 1 환경 정리 시작 ==="

# RBAC 리소스 삭제
echo "1/3 RBAC 리소스 삭제 중..."
kubectl delete role developer-role -n development --ignore-not-found=true
kubectl delete role operator-prod -n production --ignore-not-found=true
kubectl delete clusterrole operator-readonly --ignore-not-found=true
kubectl delete rolebinding developer-binding -n development --ignore-not-found=true
kubectl delete rolebinding operator-prod-binding -n production --ignore-not-found=true
kubectl delete clusterrolebinding operator-readonly-binding --ignore-not-found=true
kubectl delete serviceaccount developer-sa -n development --ignore-not-found=true
kubectl delete serviceaccount operator-sa -n production --ignore-not-found=true

# Network Policy 삭제
echo "2/3 Network Policy 삭제 중..."
kubectl delete networkpolicy --all -n development --ignore-not-found=true
kubectl delete networkpolicy --all -n production --ignore-not-found=true

# 네임스페이스 삭제 (선택사항)
echo "3/3 네임스페이스 삭제 여부 확인..."
read -p "네임스페이스를 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    kubectl delete namespace development staging production --ignore-not-found=true
    echo "네임스페이스 삭제 완료"
else
    echo "네임스페이스 유지"
fi

echo ""
echo "=== Lab 1 환경 정리 완료 ==="
