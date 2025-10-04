#!/bin/bash

# Week 3 Day 3 Challenge 3: 성공 검증 스크립트

echo "=== Challenge 3 성공 검증 시작 ==="
echo ""

NAMESPACE="day3-challenge"
PASS=0
FAIL=0

# 이전 테스트 Pod 정리
kubectl delete pod -n $NAMESPACE --field-selector=status.phase=Succeeded 2>/dev/null || true

# 색상 정의
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# 검증 함수
check_test() {
    local test_name=$1
    local command=$2
    
    if eval "$command" &>/dev/null; then
        echo -e "${GREEN}✅ PASS${NC}: $test_name"
        ((PASS++))
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}: $test_name"
        ((FAIL++))
        return 1
    fi
}

echo "🔍 시나리오 1: DNS 해결 테스트"
echo "-----------------------------------"

# backend-service 존재 확인
check_test "backend-service 존재" \
    "kubectl get svc backend-service -n $NAMESPACE"

# backend-service Endpoint 확인
check_test "backend-service Endpoint 존재" \
    "kubectl get endpoints backend-service -n $NAMESPACE -o jsonpath='{.subsets[0].addresses[0].ip}' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'"

echo ""
echo "💾 시나리오 2: PVC 바인딩 테스트"
echo "-----------------------------------"

# PVC Bound 상태 확인
check_test "database-storage PVC Bound 상태" \
    "kubectl get pvc database-storage -n $NAMESPACE -o jsonpath='{.status.phase}' | grep -q '^Bound$'"

# PVC 크기 확인 (100Ti가 아님)
check_test "PVC 크기가 현실적임" \
    "! kubectl get pvc database-storage -n $NAMESPACE -o jsonpath='{.spec.resources.requests.storage}' | grep -q '100Ti'"

# Database Pod Running 확인
check_test "Database Pod Running 상태" \
    "kubectl get pods -n $NAMESPACE -l app=database -o jsonpath='{.items[0].status.phase}' | grep -q '^Running$'"

echo ""
echo "🔒 시나리오 3: Network Policy 테스트"
echo "-----------------------------------"

# Network Policy가 올바른 라벨 사용
check_test "Network Policy가 app=backend 허용" \
    "kubectl get networkpolicy database-policy -n $NAMESPACE -o jsonpath='{.spec.ingress[0].from[0].podSelector.matchLabels.app}' | grep -q '^backend$'"

# Backend -> Database 통신 테스트
check_test "Backend -> Database 통신 가능" \
    "kubectl exec -n $NAMESPACE deployment/backend -- timeout 5 nc -zv database-service 5432 2>&1 | grep -q 'open'"

echo ""
echo "🚀 전체 시스템 상태 테스트"
echo "-----------------------------------"

# 모든 Pod Running 확인
PENDING_PODS=$(kubectl get pods -n $NAMESPACE --no-headers | grep -v "Running" | grep -v "Completed" | wc -l)
if [ "$PENDING_PODS" -eq 0 ]; then
    echo -e "${GREEN}✅ PASS${NC}: 모든 Pod가 Running 상태"
    ((PASS++))
else
    echo -e "${RED}❌ FAIL${NC}: $PENDING_PODS 개 Pod가 Running 상태 아님"
    ((FAIL++))
fi

# 모든 Deployment Ready 확인
NOT_READY=$(kubectl get deployments -n $NAMESPACE --no-headers | awk '{split($2,a,"/"); if (a[1] != a[2]) print $1}' | wc -l)
if [ "$NOT_READY" -eq 0 ]; then
    echo -e "${GREEN}✅ PASS${NC}: 모든 Deployment가 Ready"
    ((PASS++))
else
    echo -e "${RED}❌ FAIL${NC}: $NOT_READY 개 Deployment가 Ready 아님"
    ((FAIL++))
fi

echo ""
echo "=================================================="
echo "📊 검증 결과 요약"
echo "=================================================="
echo "통과: $PASS"
echo "실패: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "🎉 축하합니다! Challenge 3을 완벽하게 해결했습니다!"
    echo ""
    echo "✅ 해결한 문제들:"
    echo "  1. DNS 해결 실패 → backend-service 이름 수정"
    echo "  2. Ingress 라우팅 오류 → 올바른 서비스 참조"
    echo "  3. PVC 바인딩 실패 → StorageClass와 용량 수정"
    echo "  4. Network Policy 차단 → 올바른 라벨 설정"
else
    echo "⚠️  아직 해결하지 못한 문제가 있습니다."
    echo ""
    echo "💡 다음을 시도해보세요:"
    echo "1. kubectl get all,pvc -n day3-challenge"
    echo "2. kubectl describe [resource] -n day3-challenge"
    echo "3. 힌트 파일 참고: cat hints.md"
    echo "4. 해결책 참고: cat solutions.md"
fi
