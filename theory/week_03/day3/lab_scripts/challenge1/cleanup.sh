#!/bin/bash

# Challenge 3 환경 정리 스크립트

echo "🧹 Challenge 3 환경 정리 시작..."

echo "🗑️ day3-challenge 네임스페이스 삭제 중..."
kubectl delete namespace day3-challenge --ignore-not-found=true

echo "🔧 Ingress admission webhook 정리 중..."
kubectl delete validatingwebhookconfiguration ingress-nginx-admission --ignore-not-found=true

echo "✅ Challenge 3 환경 정리 완료!"
echo ""
echo "정리된 리소스:"
echo "- day3-challenge 네임스페이스 및 모든 하위 리소스"
echo "- Pods, Services, Deployments, PVC, Ingress, NetworkPolicy"
echo "- Ingress admission webhook configuration"
echo ""
echo "💡 클러스터는 유지되어 다른 Challenge에서 재사용 가능"
