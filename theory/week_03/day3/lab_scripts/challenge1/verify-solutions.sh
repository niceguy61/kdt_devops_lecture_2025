#!/bin/bash

# Challenge 1: 해결 검증 스크립트

echo "🚀 Challenge 1: 해결 검증 시작..."

echo ""
echo "=== 📊 전체 리소스 상태 확인 ==="
echo ""
echo "🔸 Pods 상태:"
kubectl get pods -n eshop-broken -o wide

echo ""
echo "🔸 Services 상태:"
kubectl get svc -n eshop-broken

echo ""
echo "🔸 PVC 상태:"
kubectl get pvc -n eshop-broken

echo ""
echo "🔸 Ingress 상태:"
kubectl get ingress -n eshop-broken

echo ""
echo "🔸 Network Policy 상태:"
kubectl get networkpolicy -n eshop-broken

echo ""
echo "=== 🔍 문제별 검증 ==="

# 문제 1: DNS 해결 검증
echo ""
echo "🔸 문제 1 - DNS 해결 검증:"
if kubectl get svc backend-service -n eshop-broken >/dev/null 2>&1; then
    echo "✅ backend-service 존재함"
    kubectl exec -it deployment/frontend -n eshop-broken -- nslookup backend-service 2>/dev/null && echo "✅ DNS 해결 성공" || echo "❌ DNS 해결 실패"
else
    echo "❌ backend-service가 존재하지 않음"
fi

# 문제 2: Ingress 라우팅 검증
echo ""
echo "🔸 문제 2 - Ingress 라우팅 검증:"
INGRESS_SERVICE=$(kubectl get ingress shop-ingress -n eshop-broken -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
if [ "$INGRESS_SERVICE" = "frontend-service" ]; then
    echo "✅ Ingress가 올바른 서비스를 참조함: $INGRESS_SERVICE"
else
    echo "❌ Ingress가 잘못된 서비스를 참조함: $INGRESS_SERVICE"
fi

# 문제 3: PVC 바인딩 검증
echo ""
echo "🔸 문제 3 - PVC 바인딩 검증:"
PVC_STATUS=$(kubectl get pvc database-storage -n eshop-broken -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$PVC_STATUS" = "Bound" ]; then
    echo "✅ PVC 바인딩 성공: $PVC_STATUS"
    DB_POD_STATUS=$(kubectl get pods -l app=database -n eshop-broken -o jsonpath='{.items[0].status.phase}' 2>/dev/null)
    echo "✅ 데이터베이스 Pod 상태: $DB_POD_STATUS"
else
    echo "❌ PVC 바인딩 실패: $PVC_STATUS"
fi

# 문제 4: 네트워크 연결 검증
echo ""
echo "🔸 문제 4 - 네트워크 연결 검증:"
if kubectl exec -it deployment/backend -n eshop-broken -- nc -zv database-service 5432 2>/dev/null; then
    echo "✅ 백엔드 → 데이터베이스 연결 성공"
else
    echo "❌ 백엔드 → 데이터베이스 연결 실패"
fi

echo ""
echo "=== 🌐 외부 접근 테스트 ==="
echo ""
echo "🔸 NodePort 접근 (있는 경우):"
NODEPORT=$(kubectl get svc -n eshop-broken -o jsonpath='{.items[?(@.spec.type=="NodePort")].spec.ports[0].nodePort}' 2>/dev/null)
if [ ! -z "$NODEPORT" ]; then
    echo "NodePort: http://localhost:$NODEPORT"
else
    echo "NodePort 서비스 없음"
fi

echo ""
echo "🔸 Ingress 접근:"
echo "hosts 파일 설정 후 접근: http://shop.local"
echo "또는 Host 헤더로 테스트: curl -H 'Host: shop.local' http://localhost/"

echo ""
echo "=== ✅ 종합 평가 ==="

# 성공 카운터
SUCCESS_COUNT=0
TOTAL_TESTS=4

# 각 문제별 성공 여부 확인
if kubectl get svc backend-service -n eshop-broken >/dev/null 2>&1; then
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
fi

if [ "$INGRESS_SERVICE" = "frontend-service" ]; then
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
fi

if [ "$PVC_STATUS" = "Bound" ]; then
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
fi

if kubectl exec -it deployment/backend -n eshop-broken -- nc -zv database-service 5432 >/dev/null 2>&1; then
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
fi

echo ""
echo "📊 해결 완료: $SUCCESS_COUNT/$TOTAL_TESTS"

if [ $SUCCESS_COUNT -eq $TOTAL_TESTS ]; then
    echo "🎉 모든 문제 해결 완료! E-Shop 시스템이 정상 작동합니다!"
    echo ""
    echo "✅ 성공 지표:"
    echo "- DNS 해결: 서비스 간 이름 해결 성공"
    echo "- Ingress 라우팅: 외부 접근 경로 정상"
    echo "- 스토리지: 데이터베이스 영속적 저장"
    echo "- 네트워크: 모든 계층 간 통신 성공"
else
    echo "⚠️  아직 해결되지 않은 문제가 있습니다."
    echo "남은 문제: $((TOTAL_TESTS - SUCCESS_COUNT))개"
fi

echo ""
echo "🎯 Challenge 1 검증 완료!"
