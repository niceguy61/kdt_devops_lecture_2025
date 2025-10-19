#!/bin/bash

# Week 4 Day 1 Challenge 1: 해결 검증 스크립트
# 사용법: ./verify-solutions.sh

echo "=== Challenge 1 해결 검증 시작 ==="

# 에러가 발생해도 계속 진행
set +e

# 검증 결과 저장
TOTAL_TESTS=0
PASSED_TESTS=0

# 테스트 함수
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo ""
    echo "🧪 테스트: $test_name"
    echo "   명령어: $test_command"
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo "   결과: ✅ 통과"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo "   결과: ❌ 실패"
        echo "   💡 힌트: $expected_result"
    fi
}

# 진행 상황 표시 함수
show_progress() {
    echo ""
    echo "🔍 $1"
    echo "========================================"
}

# 1. Saga 패턴 검증
show_progress "1/4 Saga 패턴 복구 검증"

run_test "Saga Job 성공 실행" \
    "kubectl get jobs saga-orchestrator -n microservices-challenge -o jsonpath='{.status.succeeded}' | grep -q '1'" \
    "Job이 성공적으로 완료되어야 합니다"

run_test "Order Service 정상 응답" \
    "kubectl exec -n testing deployment/load-tester -- curl -s http://order-service.microservices-challenge.svc.cluster.local/api/orders | grep -q 'saga-001'" \
    "Order Service가 정상적인 JSON 응답을 반환해야 합니다"

run_test "Payment Service 정상 응답" \
    "kubectl exec -n testing deployment/load-tester -- curl -s http://payment-service.microservices-challenge.svc.cluster.local/api/payments | grep -q 'completed' && kubectl get jobs saga-orchestrator -n microservices-challenge -o jsonpath='{.status.succeeded}' | grep -q '1'" \
    "Payment Service가 정상적으로 응답하고 Saga가 완료되어야 합니다"

# 2. CQRS 패턴 검증
show_progress "2/4 CQRS 패턴 복구 검증"

run_test "Command Service 정상 응답" \
    "kubectl exec -n testing deployment/load-tester -- curl -s -X POST http://command-service.microservices-challenge.svc.cluster.local/api/commands/create-user | grep -q 'cmd-001'" \
    "Command Service가 유효한 JSON으로 응답해야 합니다"

run_test "Query Service 정상 응답" \
    "kubectl exec -n testing deployment/load-tester -- curl -s http://query-service.microservices-challenge.svc.cluster.local/api/queries/users | grep -q 'John Doe'" \
    "Query Service가 사용자 데이터를 정상 반환해야 합니다"

run_test "Command Service 엔드포인트 연결" \
    "kubectl get endpoints command-service -n microservices-challenge -o jsonpath='{.subsets[0].addresses[0].ip}' | grep -q '[0-9]' && kubectl get svc command-service -n microservices-challenge -o jsonpath='{.spec.ports[0].targetPort}' | grep -q '^80$'" \
    "Command Service의 엔드포인트가 정상 연결되고 포트가 올바르게 설정되어야 합니다"

# 3. Event Sourcing 검증
show_progress "3/4 Event Sourcing 복구 검증"

run_test "Event Store API 정상 응답" \
    "kubectl exec -n testing deployment/load-tester -- curl -s http://event-store-api.microservices-challenge.svc.cluster.local/api/events | grep -q 'evt-001'" \
    "Event Store API가 이벤트 데이터를 정상 반환해야 합니다"

run_test "CronJob 정상 스케줄링" \
    "kubectl get cronjobs event-processor -n microservices-challenge -o jsonpath='{.spec.schedule}' | grep -E '^\*/5 \* \* \* \*$'" \
    "CronJob이 올바른 스케줄 표현식을 가져야 합니다 (매일 5분마다, 요일 필드 없음)"

run_test "Event Processor 실행 가능" \
    "kubectl create job event-processor-test --from=cronjob/event-processor -n microservices-challenge && sleep 10 && kubectl logs job/event-processor-test -n microservices-challenge | grep -q 'Processing'" \
    "Event Processor가 정상적으로 실행되어야 합니다"

# 4. 네트워킹 검증
show_progress "4/4 네트워킹 복구 검증"

run_test "User Service 엔드포인트 연결" \
    "kubectl get endpoints user-service -n microservices-challenge -o jsonpath='{.subsets[0].addresses[0].ip}' | grep -q '[0-9]'" \
    "User Service의 엔드포인트가 정상 연결되어야 합니다"

run_test "Ingress 라우팅 정상" \
    "kubectl get ingress ecommerce-ingress -n microservices-challenge -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' | grep -q 'user-service' && kubectl get ingress ecommerce-ingress -n microservices-challenge -o jsonpath='{.spec.rules[0].http.paths[1].backend.service.port.number}' | grep -q '^80$'" \
    "Ingress가 올바른 서비스와 포트로 라우팅해야 합니다"

run_test "DNS 해결 정상" \
    "kubectl exec -n testing deployment/load-tester -- nslookup user-service.microservices-challenge.svc.cluster.local | grep -q 'Address:'" \
    "DNS가 서비스 이름을 정상적으로 해결해야 합니다"

# 정리 작업
echo ""
echo "🧹 테스트 정리 중..."
kubectl delete job event-processor-test -n microservices-challenge 2>/dev/null || true

# 최종 결과
show_progress "검증 결과 요약"

echo "📊 전체 테스트 결과: $PASSED_TESTS/$TOTAL_TESTS 통과"
echo ""

if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
    echo "🎉 축하합니다! 모든 문제를 성공적으로 해결했습니다!"
    echo ""
    echo "✅ 해결된 문제들:"
    echo "   - Saga 패턴 트랜잭션 정상 실행"
    echo "   - CQRS 패턴 읽기/쓰기 분리 복구"
    echo "   - Event Sourcing 이벤트 처리 재개"
    echo "   - 네트워킹 및 서비스 디스커버리 정상화"
    echo ""
    echo "🏆 Challenge 1 완료!"
    
elif [ $PASSED_TESTS -gt $((TOTAL_TESTS * 7 / 10)) ]; then
    echo "👍 좋습니다! 대부분의 문제를 해결했습니다."
    echo "   남은 문제: $((TOTAL_TESTS - PASSED_TESTS))개"
    echo "   💡 힌트를 참고하여 나머지 문제도 해결해보세요!"
    
elif [ $PASSED_TESTS -gt $((TOTAL_TESTS / 2)) ]; then
    echo "🔧 절반 이상 해결했습니다!"
    echo "   남은 문제: $((TOTAL_TESTS - PASSED_TESTS))개"
    echo "   💪 조금 더 노력하면 완전 해결 가능합니다!"
    
else
    echo "⚠️  아직 해결해야 할 문제가 많습니다."
    echo "   해결된 문제: $PASSED_TESTS개"
    echo "   남은 문제: $((TOTAL_TESTS - PASSED_TESTS))개"
    echo "   💡 힌트를 참고하고 팀원들과 협력해보세요!"
fi

echo ""
echo "=== Challenge 1 검증 완료 ==="
