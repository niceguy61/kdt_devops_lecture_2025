#!/bin/bash

# Week 3 Day 4 Challenge 1: 해결 검증
# 사용법: ./verify-solutions.sh

set -e

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
echo ""

# 문제 3: Network Policy 확인
echo "📋 문제 3: Network Policy 검증"
echo "----------------------------------------"
test_check "Backend Network Policy 존재" \
    "kubectl get networkpolicy backend-policy -n securebank"
test_check "Backend Pod 라벨 일치" \
    "kubectl get networkpolicy backend-policy -n securebank -o yaml | grep -A2 podSelector | grep -q 'tier: api'"
test_check "올바른 포트 설정" \
    "kubectl get networkpolicy backend-policy -n securebank -o yaml | grep -q 'port: 8080'"
echo ""

# 문제 4: Secret 보안 확인
echo "📋 문제 4: Secret 보안 검증"
echo "----------------------------------------"
test_check "Secret 리소스 존재" \
    "kubectl get secret -n securebank | grep -q database-credentials"
test_check "환경변수에 평문 비밀번호 없음" \
    "! kubectl get deployment backend -n securebank -o yaml | grep -q 'value:.*password'"
test_check "Secret 참조 사용" \
    "kubectl get deployment backend -n securebank -o yaml | grep -q secretKeyRef"
echo ""

# 최종 결과
echo "=== 검증 결과 ==="
echo "✅ PASS: $PASS"
echo "❌ FAIL: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "🎉 축하합니다! 모든 문제를 해결했습니다!"
    exit 0
else
    echo "⚠️  아직 해결하지 못한 문제가 있습니다."
    echo "힌트가 필요하면 hints.md 파일을 확인하세요."
    exit 1
fi
