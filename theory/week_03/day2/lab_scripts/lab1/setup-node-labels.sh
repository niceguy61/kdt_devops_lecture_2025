#!/bin/bash

# Week 3 Day 2 Lab 1: 노드 라벨링 설정
# 사용법: ./setup-node-labels.sh

echo "=== 노드 라벨링 설정 시작 ==="

# 현재 노드 목록 확인
echo "현재 클러스터 노드:"
kubectl get nodes

# 첫 번째 노드에 라벨 추가
NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
echo ""
echo "노드 '$NODE_NAME'에 라벨 추가 중..."

# 스토리지 타입 라벨
kubectl label nodes $NODE_NAME storage-type=ssd --overwrite
if [ $? -eq 0 ]; then
    echo "✅ storage-type=ssd 라벨 추가 완료"
else
    echo "❌ storage-type 라벨 추가 실패"
fi

# CPU 타입 라벨
kubectl label nodes $NODE_NAME cpu-type=high-performance --overwrite
if [ $? -eq 0 ]; then
    echo "✅ cpu-type=high-performance 라벨 추가 완료"
else
    echo "❌ cpu-type 라벨 추가 실패"
fi

# 환경 라벨 (선택사항)
kubectl label nodes $NODE_NAME environment=lab --overwrite
if [ $? -eq 0 ]; then
    echo "✅ environment=lab 라벨 추가 완료"
else
    echo "❌ environment 라벨 추가 실패"
fi

echo ""
echo "=== 노드 라벨링 완료 ==="
echo ""
echo "라벨이 적용된 노드 정보:"
kubectl get nodes --show-labels

echo ""
echo "특정 라벨 확인:"
echo "- storage-type 라벨을 가진 노드:"
kubectl get nodes -l storage-type=ssd
echo "- cpu-type 라벨을 가진 노드:"
kubectl get nodes -l cpu-type=high-performance
