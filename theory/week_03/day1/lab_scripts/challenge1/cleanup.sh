#!/bin/bash

echo "🧹 Challenge 1 리소스 정리 중..."

# namespace 삭제 (클러스터는 유지)
kubectl delete namespace day1-challenge --ignore-not-found=true

echo "✅ Challenge 1 리소스 정리 완료!"
echo "   (클러스터는 유지되어 다른 Challenge에서 재사용 가능)"