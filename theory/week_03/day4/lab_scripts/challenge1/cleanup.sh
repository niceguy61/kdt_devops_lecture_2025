#!/bin/bash

# Week 3 Day 4 Challenge 1: 환경 정리
# 사용법: ./cleanup.sh

set -e

CLUSTER_NAME="day4-challenge"

echo "=== Challenge 환경 정리 시작 ==="

# 네임스페이스 삭제
echo "1/2 네임스페이스 삭제 중..."
kubectl delete namespace securebank --ignore-not-found=true

# 클러스터 삭제 여부 확인
echo "2/2 클러스터 삭제 여부 확인..."
read -p "Kind 클러스터(${CLUSTER_NAME})를 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    kind delete cluster --name ${CLUSTER_NAME}
    echo "클러스터 삭제 완료"
else
    echo "클러스터 유지"
fi

echo ""
echo "=== Challenge 환경 정리 완료 ==="
