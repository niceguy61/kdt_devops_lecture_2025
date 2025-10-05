#!/bin/bash

# Week 3 Day 5 Challenge 1: 환경 정리

echo "=== Challenge 1 환경 정리 시작 ==="

# 1. Application 삭제
echo "1. Challenge Application 삭제 중..."
for i in {1..4}; do
    kubectl delete application challenge-app-$i -n argocd --ignore-not-found=true
done
echo "✅ Application 삭제 완료"

# 2. Namespace 정리 (리소스만 삭제, 네임스페이스 유지)
echo "2. day5-challenge 네임스페이스 리소스 정리 중..."
kubectl delete all --all -n day5-challenge
echo "✅ 리소스 정리 완료"

# 3. 임시 파일 정리
echo "3. 임시 파일 정리 중..."
rm -rf /tmp/challenge-app-*
echo "✅ 임시 파일 정리 완료"

echo ""
echo "=== Challenge 1 환경 정리 완료 ==="
echo ""
echo "클러스터 정보:"
echo "- 클러스터명: challenge-cluster"
echo "- 네임스페이스: day5-challenge (유지됨)"
echo ""
echo "남은 리소스 확인:"
echo "  kubectl get application -n argocd | grep challenge"
echo "  kubectl get all -n day5-challenge"
