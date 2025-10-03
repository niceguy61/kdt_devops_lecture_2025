#!/bin/bash

# Lab 1 Step 1-4: 워크로드 테스트 및 검증 스크립트

echo "🚀 Lab 1 Step 1-4: 워크로드 테스트 시작..."

echo "📊 전체 워크로드 상태 확인:"
echo ""
echo "=== Pod 상태 ==="
kubectl get pods -n lab2-workloads -o wide

echo ""
echo "=== ReplicaSet 상태 ==="
kubectl get rs -n lab2-workloads

echo ""
echo "=== Deployment 상태 ==="
kubectl get deployment -n lab2-workloads

echo ""
echo "🔍 자동 복구 테스트:"
POD_NAME=$(kubectl get pods -l app=web,version=v1 -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ ! -z "$POD_NAME" ]; then
    echo "ReplicaSet Pod 삭제: $POD_NAME"
    kubectl delete pod $POD_NAME
    echo "⏳ 자동 복구 확인 중..."
    sleep 5
    kubectl get pods -l app=web,version=v1
fi

echo ""
echo "🔄 롤링 업데이트 테스트:"
kubectl set image deployment/web-deployment nginx=nginx:1.21
echo "⏳ 롤아웃 상태 확인 중..."
kubectl rollout status deployment/web-deployment --timeout=60s

echo ""
echo "✅ 모든 테스트 완료!"
echo ""
echo "📋 요약:"
echo "- Pod: 단일 컨테이너 실행 단위"
echo "- ReplicaSet: Pod 복제본 관리"
echo "- Deployment: ReplicaSet + 롤링 업데이트"
