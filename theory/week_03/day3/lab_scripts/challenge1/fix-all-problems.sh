#!/bin/bash

# Challenge 1: 모든 문제 자동 해결 스크립트

echo "🚀 Challenge 1: 자동 문제 해결 시작..."

echo ""
echo "🔧 문제 1: DNS 해결 실패 수정 중..."
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: day3-challenge
spec:
  selector:
    app: backend
  ports:
  - port: 3000
    targetPort: 80
EOF
echo "✅ backend-service 생성 완료"

echo ""
echo "🔧 문제 2: Ingress 라우팅 오류 수정 중..."
kubectl patch ingress shop-ingress -n day3-challenge --type='json' -p='[
  {
    "op": "replace",
    "path": "/spec/rules/0/http/paths/0/backend/service/name",
    "value": "frontend-service"
  }
]'
echo "✅ Ingress 라우팅 수정 완료"

echo ""
echo "🔧 문제 3: PVC 바인딩 실패 수정 중..."
kubectl delete pvc database-storage -n day3-challenge --ignore-not-found=true
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: database-storage
  namespace: day3-challenge
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: standard
EOF
echo "✅ PVC 재생성 완료"

echo ""
echo "🔧 문제 4: 네트워크 정책 차단 수정 중..."
kubectl patch networkpolicy database-policy -n day3-challenge --type='json' -p='[
  {
    "op": "replace",
    "path": "/spec/ingress/0/from/0/podSelector/matchLabels/app",
    "value": "backend"
  }
]'
echo "✅ Network Policy 수정 완료"

echo ""
echo "⏳ 시스템 안정화 대기 중..."
sleep 10

echo ""
echo "🔍 Pod 재시작 대기 중..."
kubectl wait --for=condition=Ready pod -l app=database -n day3-challenge --timeout=120s
kubectl wait --for=condition=Ready pod -l app=backend -n day3-challenge --timeout=60s
kubectl wait --for=condition=Ready pod -l app=frontend -n day3-challenge --timeout=60s

echo ""
echo "✅ 모든 문제 해결 완료!"
echo ""
echo "📊 해결된 문제들:"
echo "1. ✅ DNS 해결 실패 → backend-service 생성"
echo "2. ✅ Ingress 라우팅 오류 → 올바른 서비스 참조"
echo "3. ✅ PVC 바인딩 실패 → 적절한 크기와 StorageClass"
echo "4. ✅ 네트워크 정책 차단 → 올바른 라벨 매칭"
echo ""
echo "🎯 검증 스크립트 실행:"
echo "./verify-solutions.sh"
