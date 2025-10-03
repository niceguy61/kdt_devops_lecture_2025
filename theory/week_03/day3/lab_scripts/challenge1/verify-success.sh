#!/bin/bash

# Week 3 Day 3 Challenge 1: 성공 검증 스크립트
# 모든 문제가 해결되었는지 자동으로 확인합니다

echo "=== Challenge 1 성공 검증 시작 ==="
echo ""

NAMESPACE="eshop-broken"
PASS=0
FAIL=0

# 색상 정의
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

# Service Endpoint 확인
check_test "backend-service Endpoint 존재" \
    "kubectl get endpoints backend-service -n $NAMESPACE -o jsonpath='{.subsets[0].addresses[0].ip}' | grep -q '.'"

# DNS 해결 테스트
check_test "backend-service DNS 해결" \
    "kubectl run dns-test-$RANDOM --image=busybox:1.35 --rm -i --restart=Never -n $NAMESPACE -- nslookup backend-service 2>&1 | grep -q 'Address'"

echo ""
echo "🌐 시나리오 2: Ingress 라우팅 테스트"
echo "-----------------------------------"

# Ingress 존재 확인
check_test "Ingress 리소스 존재" \
    "kubectl get ingress eshop-ingress -n $NAMESPACE"

# Ingress Backend 확인
check_test "Ingress Backend 올바른 Service 참조" \
    "kubectl get ingress eshop-ingress -n $NAMESPACE -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' | grep -q 'frontend-service'"

# Ingress ADDRESS 할당 확인
check_test "Ingress ADDRESS 할당됨" \
    "kubectl get ingress eshop-ingress -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0]}' | grep -q '.'"

echo ""
echo "💾 시나리오 3: PVC 바인딩 테스트"
echo "-----------------------------------"

# PVC Bound 상태 확인
check_test "postgres-data PVC Bound 상태" \
    "kubectl get pvc postgres-data -n $NAMESPACE -o jsonpath='{.status.phase}' | grep -q 'Bound'"

# PVC 크기 확인 (1000Ti가 아닌지)
check_test "PVC 크기가 현실적임 (1000Ti 아님)" \
    "! kubectl get pvc postgres-data -n $NAMESPACE -o jsonpath='{.spec.resources.requests.storage}' | grep -q '1000Ti'"

# Pod가 PVC 마운트 확인
check_test "PostgreSQL Pod가 PVC 마운트" \
    "kubectl get pods -n $NAMESPACE -l app=postgres -o jsonpath='{.items[0].spec.volumes[*].persistentVolumeClaim.claimName}' | grep -q 'postgres-data'"

echo ""
echo "🔒 시나리오 4: Network Policy 테스트"
echo "-----------------------------------"

# 과도한 Network Policy 없음 확인
check_test "모든 트래픽 차단 정책 없음" \
    "! kubectl get networkpolicy -n $NAMESPACE -o yaml | grep -A 10 'podSelector: {}' | grep -q 'policyTypes'"

# Frontend -> Backend 통신 가능
check_test "Frontend -> Backend 통신 가능" \
    "kubectl exec -n $NAMESPACE deployment/frontend -- timeout 5 nc -zv backend-service 3000 2>&1 | grep -q 'succeeded\|open'"

# Backend -> PostgreSQL 통신 가능
check_test "Backend -> PostgreSQL 통신 가능" \
    "kubectl exec -n $NAMESPACE deployment/backend -- timeout 5 nc -zv postgres-service 5432 2>&1 | grep -q 'succeeded\|open'"

echo ""
echo "🚀 전체 시스템 상태 테스트"
echo "-----------------------------------"

# 모든 Pod Running 상태
check_test "모든 Pod가 Running 상태" \
    "[ \$(kubectl get pods -n $NAMESPACE --field-selector=status.phase!=Running --no-headers 2>/dev/null | wc -l) -eq 0 ]"

# 모든 Deployment Ready
check_test "모든 Deployment가 Ready" \
    "kubectl get deployments -n $NAMESPACE -o jsonpath='{.items[*].status.conditions[?(@.type==\"Available\")].status}' | grep -v False"

echo ""
echo "=================================================="
echo "📊 검증 결과 요약"
echo "=================================================="
echo -e "${GREEN}통과: $PASS${NC}"
echo -e "${RED}실패: $FAIL${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}🎉 축하합니다! 모든 문제를 해결했습니다!${NC}"
    echo ""
    echo "✨ 다음 단계:"
    echo "1. 팀원들과 해결 과정 공유"
    echo "2. 어려웠던 점과 배운 점 정리"
    echo "3. 실무에서 어떻게 활용할지 토론"
    echo ""
    exit 0
else
    echo -e "${YELLOW}⚠️  아직 해결하지 못한 문제가 있습니다.${NC}"
    echo ""
    echo "💡 다음을 시도해보세요:"
    echo "1. 실패한 테스트의 리소스 상태 확인"
    echo "2. kubectl describe로 상세 정보 확인"
    echo "3. Pod 로그 확인"
    echo "4. 힌트 파일 참고: hints.md"
    echo ""
    exit 1
fi
