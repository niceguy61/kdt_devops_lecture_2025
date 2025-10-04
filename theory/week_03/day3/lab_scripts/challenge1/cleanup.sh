#!/bin/bash

# Challenge 1 환경 정리 스크립트

echo "🧹 Challenge 1 환경 정리 시작..."

echo "🗑️ day3-challenge 네임스페이스 삭제 중..."
kubectl delete namespace day3-challenge --ignore-not-found=true

echo "📝 hosts 파일 정리 안내:"
echo "다음 명령어로 hosts 파일에서 shop.local 제거:"
echo "sudo sed -i '/shop.local/d' /etc/hosts"

echo "✅ Challenge 1 환경 정리 완료!"
echo ""
echo "정리된 리소스:"
echo "- day3-challenge 네임스페이스 및 모든 하위 리소스"
echo "- Pods, Services, Deployments, PVC, Ingress, NetworkPolicy"
echo ""
echo "수동 정리 필요:"
echo "- /etc/hosts 파일의 shop.local 엔트리 (선택사항)"
