#!/bin/bash

# Lab 1: Kong API Gateway - 환경 정리

echo "=== Kong API Gateway Lab 환경 정리 시작 ==="
echo ""

# 1. 클러스터 삭제
echo "1. Kind 클러스터 삭제 중..."
kind delete cluster --name lab-cluster

echo "   ✅ 클러스터 삭제 완료"

echo ""
echo "=== 환경 정리 완료 ==="
echo ""
echo "💡 다음 실습을 위해 새로운 클러스터를 생성하세요:"
echo "   ./setup-cluster.sh"
