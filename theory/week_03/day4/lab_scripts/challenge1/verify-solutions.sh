#!/bin/bash

# Week 3 Day 4 Challenge 1: 해결 검증
# 사용법: ./verify-solutions.sh

echo "=== Challenge 해결 검증 시작 ==="
echo ""

PASS=0
FAIL=0

# 테스트 함수
test_check() {
    local test_name=$1
    local command=$2
    
    echo -n "Testing: $test_name ... "
    if eval "$command" &>/dev/null; then
        echo "✅ PASS"
        ((PASS++))
    else
        echo "❌ FAIL"
        ((FAIL++))
    fi
}

# 문제 1: RBAC 권한 확인
echo "📋 문제 1: RBAC 권한 검증"
echo "----------------------------------------"
test_check "ServiceAccount 존재" \
    "kubectl get sa developer-sa -n securebank"
test_check "Role 존재" \
    "kubectl get role developer-role -n securebank"
test_check "RoleBinding 존재" \
    "kubectl get rolebinding developer-binding -n securebank"
test_check "개발자 Pod 생성 권한" \
    "kubectl auth can-i create pods --as=system:serviceaccount:securebank:developer-sa -n securebank | grep -q yes"
test_check "개발자 로그 조회 권한" \
    "kubectl auth can-i get pods/log --as=system:serviceaccount:securebank:developer-sa -n securebank | grep -q yes"
test_check "RoleBinding 올바른 SA 참조" \
    "kubectl get rolebinding developer-binding -n securebank -o yaml | grep -q 'name: developer-sa'"
echo ""

# 문제 2: 인증서 확인 (시뮬레이션)
echo "📋 문제 2: 인증서 유효성 검증"
echo "----------------------------------------"
test_check "클러스터 노드 Ready 상태" \
    "kubectl get nodes | grep -q Ready"
test_check "API Server 정상 동작" \
    "kubectl get --raw /healthz | grep -q ok"
test_check "cert-checker Pod 존재" \
    "kubectl get pod cert-checker -n securebank 2>/dev/null"
echo ""

# 문제 3: Network Policy 확인
echo "📋 문제 3: Network Policy 검증"
echo "----------------------------------------"
test_check "Backend Network Policy 존재" \
    "kubectl get networkpolicy backend-policy -n securebank"
test_check "Database Network Policy 존재" \
    "kubectl get networkpolicy database-policy -n securebank"
test_check "Backend Pod 라벨 일치 (tier: api)" \
    "kubectl get networkpolicy backend-policy -n securebank -o yaml | grep -A5 podSelector | grep -q 'tier: api'"
test_check "올바른 포트 설정 (8080)" \
    "kubectl get networkpolicy backend-policy -n securebank -o yaml | grep -q 'port: 8080'"
test_check "Database ingress 규칙 존재" \
    "kubectl get networkpolicy database-policy -n securebank -o yaml | grep -q 'ingress:'"
echo ""

# 문제 4: Secret 보안 확인
echo "📋 문제 4: Secret 보안 검증"
echo "----------------------------------------"
test_check "db-secret 존재" \
    "kubectl get secret db-secret -n securebank"
test_check "api-secret 존재" \
    "kubectl get secret api-secret -n securebank"
test_check "db-url-secret 존재" \
    "kubectl get secret db-url-secret -n securebank"
test_check "Backend Deployment에서 Secret 참조" \
    "kubectl get deployment backend -n securebank -o yaml | grep -q secretKeyRef"
test_check "환경변수에 평문 비밀번호 없음" \
    "! kubectl get deployment backend -n securebank -o yaml | grep -E 'value:.*supersecret|value:.*password123'"
echo ""

# 최종 결과
echo "========================================"
echo "=== 검증 결과 ==="
echo "✅ PASS: $PASS"
echo "❌ FAIL: $FAIL"
echo "========================================"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "🎉 축하합니다! 모든 문제를 해결했습니다!"
    echo ""
    echo "학습 포인트:"
    echo "- RBAC: 최소 권한 원칙 적용"
    echo "- 인증서: 정기적인 갱신 및 모니터링"
    echo "- Network Policy: 명시적 허용 정책"
    echo "- Secret: 민감 정보의 안전한 관리"
    exit 0
else
    echo "⚠️  아직 해결하지 못한 문제가 있습니다."
    echo ""
    echo "다음 단계:"
    echo "1. hints.md 파일에서 힌트 확인"
    echo "2. solutions.md 파일에서 상세 솔루션 확인"
    echo "3. 수정 후 다시 검증: ./verify-solutions.sh"
    exit 1
fi
