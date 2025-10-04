#!/bin/bash

# Challenge 1: 성공 검증 스크립트
cd "$(dirname "$0")"

echo "🔍 day2-challenge 성공 검증 시작..."

echo ""
echo "=== 네임스페이스 상태 ==="
kubectl get namespace day2-challenge

echo ""
echo "=== Deployment 상태 ==="
kubectl get deployments -n day2-challenge

echo ""
echo "=== Pod 상태 ==="
kubectl get pods -n day2-challenge -o wide

echo ""
echo "=== 상세 검증 ==="

# broken-app 검증
BROKEN_READY=$(kubectl get deployment broken-app -n day2-challenge -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
if [ "$BROKEN_READY" = "3" ]; then
    echo "✅ broken-app: 3개 Pod 모두 Ready"
else
    echo "❌ broken-app: Ready Pod 수 = $BROKEN_READY/3"
fi

# resource-hungry 검증
RESOURCE_READY=$(kubectl get deployment resource-hungry -n day2-challenge -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
if [ "$RESOURCE_READY" = "2" ]; then
    echo "✅ resource-hungry: 2개 Pod 모두 Ready"
else
    echo "❌ resource-hungry: Ready Pod 수 = $RESOURCE_READY/2"
fi

echo ""
if [ "$BROKEN_READY" = "3" ] && [ "$RESOURCE_READY" = "2" ]; then
    echo "🎉 Challenge 1 완료! 모든 문제가 해결되었습니다!"
else
    echo "⚠️  아직 해결되지 않은 문제가 있습니다."
fi
