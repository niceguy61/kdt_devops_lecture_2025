#!/bin/bash

# Week 2 Day 4 Lab 1: 간단한 외부 접근 설정
# 사용법: ./setup_simple_access.sh

echo "=== 간단한 외부 접근 설정 시작 ==="

# NodePort 서비스 상태 확인
echo "1. NodePort 서비스 상태 확인..."
kubectl get svc nginx-nodeport -n lab-demo

# NodePort 접근 테스트
echo "2. NodePort 접근 테스트..."
if curl -s http://localhost:30080/health > /dev/null; then
    echo "✅ NodePort 접근 성공: http://localhost:30080"
else
    echo "❌ NodePort 접근 실패"
fi

echo ""
echo "=== 간단한 외부 접근 설정 완료 ==="
echo ""
echo "접근 방법:"
echo "🌐 NodePort: http://localhost:30080"
echo ""
echo "✅ 포트 포워딩 없이 안정적인 접근 가능!"