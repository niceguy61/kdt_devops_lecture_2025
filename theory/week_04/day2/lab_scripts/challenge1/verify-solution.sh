#!/bin/bash

# Challenge 1: 해결 검증 스크립트

echo "=== Challenge 1: 해결 검증 시작 ==="
echo ""

PASS=0
FAIL=0

# 시나리오 1: Gateway 접근
echo "🔍 시나리오 1: Gateway 접근 테스트"
if curl -s -f http://localhost:9090/users > /dev/null 2>&1; then
    echo "   ✅ PASS: /users 접근 성공"
    ((PASS++))
else
    echo "   ❌ FAIL: /users 접근 실패"
    ((FAIL++))
fi

# 시나리오 2: VirtualService 라우팅
echo ""
echo "🔍 시나리오 2: VirtualService 라우팅 테스트"

if curl -s -f http://localhost:9090/products > /dev/null 2>&1; then
    echo "   ✅ PASS: /products 접근 성공"
    ((PASS++))
else
    echo "   ❌ FAIL: /products 접근 실패"
    ((FAIL++))
fi

if curl -s -f http://localhost:9090/orders > /dev/null 2>&1; then
    echo "   ✅ PASS: /orders 접근 성공"
    ((PASS++))
else
    echo "   ❌ FAIL: /orders 접근 실패"
    ((FAIL++))
fi

# 시나리오 3: Traffic Splitting
echo ""
echo "🔍 시나리오 3: Traffic Splitting 테스트"
V2_COUNT=0
for i in {1..100}; do
    if curl -s http://localhost:9090/users | grep -q "v2"; then
        ((V2_COUNT++))
    fi
done

if [ $V2_COUNT -ge 5 ] && [ $V2_COUNT -le 15 ]; then
    echo "   ✅ PASS: v2 비율 정상 ($V2_COUNT/100)"
    ((PASS++))
else
    echo "   ❌ FAIL: v2 비율 비정상 ($V2_COUNT/100, 예상: 5-15)"
    ((FAIL++))
fi

# 시나리오 4: Fault Injection
echo ""
echo "🔍 시나리오 4: Fault Injection 테스트"

# 지연 테스트
DELAY_COUNT=0
for i in {1..10}; do
    START=$(date +%s)
    curl -s http://localhost:9090/products > /dev/null 2>&1
    END=$(date +%s)
    DURATION=$((END - START))
    if [ $DURATION -ge 2 ]; then
        ((DELAY_COUNT++))
    fi
done

if [ $DELAY_COUNT -ge 3 ]; then
    echo "   ✅ PASS: 지연 발생 ($DELAY_COUNT/10)"
    ((PASS++))
else
    echo "   ❌ FAIL: 지연 미발생 ($DELAY_COUNT/10, 예상: 3+)"
    ((FAIL++))
fi

# 오류 테스트
ERROR_COUNT=0
for i in {1..20}; do
    CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9090/products)
    if [ "$CODE" == "503" ]; then
        ((ERROR_COUNT++))
    fi
done

if [ $ERROR_COUNT -ge 2 ]; then
    echo "   ✅ PASS: 503 오류 발생 ($ERROR_COUNT/20)"
    ((PASS++))
else
    echo "   ❌ FAIL: 503 오류 미발생 ($ERROR_COUNT/20, 예상: 2+)"
    ((FAIL++))
fi

# 결과 요약
echo ""
echo "=== 검증 결과 ==="
echo "✅ PASS: $PASS"
echo "❌ FAIL: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "🎉 모든 시나리오 해결 완료!"
    exit 0
else
    echo "⚠️  일부 시나리오 미해결"
    exit 1
fi
