#!/bin/bash

# Week 3 Day 2 Lab 1: 리소스 모니터링
# 사용법: ./monitor-resources.sh

echo "=== 리소스 모니터링 시작 ==="

# 1. 노드 리소스 사용량 확인
echo "1. 노드 리소스 사용량:"
echo "================================"

# Metrics Server가 설치되어 있는지 확인
if kubectl top nodes >/dev/null 2>&1; then
    kubectl top nodes
    echo ""
    echo "노드별 상세 리소스 정보:"
    kubectl describe nodes | grep -A 5 "Allocated resources"
else
    echo "⚠️  Metrics Server가 설치되지 않았습니다."
    echo "노드 기본 정보만 표시합니다:"
    kubectl get nodes -o wide
fi

echo ""
echo "================================"

# 2. Pod 리소스 사용량 확인
echo "2. Pod 리소스 사용량:"
echo "================================"

if kubectl top pods >/dev/null 2>&1; then
    echo "전체 Pod 리소스 사용량:"
    kubectl top pods --all-namespaces
    
    echo ""
    echo "현재 네임스페이스 Pod 리소스 사용량:"
    kubectl top pods
else
    echo "⚠️  Metrics Server를 통한 실시간 사용량을 확인할 수 없습니다."
    echo "Pod 기본 정보를 표시합니다:"
    kubectl get pods -o wide
fi

echo ""
echo "================================"

# 3. QoS 클래스 확인
echo "3. Pod QoS 클래스 분석:"
echo "================================"

echo "Pod별 QoS 클래스:"
kubectl get pods -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass,REQUESTS-CPU:.spec.containers[*].resources.requests.cpu,LIMITS-CPU:.spec.containers[*].resources.limits.cpu,REQUESTS-MEM:.spec.containers[*].resources.requests.memory,LIMITS-MEM:.spec.containers[*].resources.limits.memory

echo ""
echo "QoS 클래스별 Pod 개수:"
echo "- Guaranteed: $(kubectl get pods -o jsonpath='{.items[?(@.status.qosClass=="Guaranteed")].metadata.name}' | wc -w)"
echo "- Burstable: $(kubectl get pods -o jsonpath='{.items[?(@.status.qosClass=="Burstable")].metadata.name}' | wc -w)"
echo "- BestEffort: $(kubectl get pods -o jsonpath='{.items[?(@.status.qosClass=="BestEffort")].metadata.name}' | wc -w)"

echo ""
echo "================================"

# 4. 리소스 할당 현황
echo "4. 리소스 할당 현황:"
echo "================================"

echo "네임스페이스별 Pod 개수:"
kubectl get pods --all-namespaces | awk 'NR>1 {print $1}' | sort | uniq -c | sort -nr

echo ""
echo "워크로드 타입별 현황:"
echo "- Deployments: $(kubectl get deployments --no-headers | wc -l)"
echo "- ReplicaSets: $(kubectl get replicasets --no-headers | wc -l)"
echo "- DaemonSets: $(kubectl get daemonsets --no-headers | wc -l)"
echo "- Jobs: $(kubectl get jobs --no-headers | wc -l)"
echo "- CronJobs: $(kubectl get cronjobs --no-headers | wc -l)"

echo ""
echo "================================"

# 5. 이벤트 확인
echo "5. 최근 클러스터 이벤트:"
echo "================================"

echo "최근 10개 이벤트:"
kubectl get events --sort-by='.lastTimestamp' | tail -10

echo ""
echo "경고 및 오류 이벤트:"
kubectl get events --field-selector type!=Normal

echo ""
echo "================================"

# 6. 상세 리소스 분석
echo "6. 상세 리소스 분석:"
echo "================================"

echo "CPU 요청량이 높은 Pod Top 5:"
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].resources.requests.cpu}{"\n"}{end}' | grep -v "<no value>" | sort -k2 -nr | head -5

echo ""
echo "메모리 요청량이 높은 Pod Top 5:"
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].resources.requests.memory}{"\n"}{end}' | grep -v "<no value>" | sort -k2 -nr | head -5

echo ""
echo "================================"

# 7. 모니터링 요약
echo "7. 모니터링 요약:"
echo "================================"

TOTAL_PODS=$(kubectl get pods --no-headers | wc -l)
RUNNING_PODS=$(kubectl get pods --no-headers | grep Running | wc -l)
PENDING_PODS=$(kubectl get pods --no-headers | grep Pending | wc -l)
FAILED_PODS=$(kubectl get pods --no-headers | grep -E "Failed|Error" | wc -l)

echo "Pod 상태 요약:"
echo "- 전체 Pod: $TOTAL_PODS"
echo "- 실행 중: $RUNNING_PODS"
echo "- 대기 중: $PENDING_PODS"
echo "- 실패: $FAILED_PODS"

if [ $PENDING_PODS -gt 0 ]; then
    echo ""
    echo "⚠️  대기 중인 Pod가 있습니다. 리소스 부족이나 스케줄링 문제를 확인하세요."
fi

if [ $FAILED_PODS -gt 0 ]; then
    echo ""
    echo "❌ 실패한 Pod가 있습니다. 로그를 확인하세요."
fi

echo ""
echo "=== 리소스 모니터링 완료 ==="
echo ""
echo "💡 추가 모니터링 명령어:"
echo "- 실시간 Pod 상태: watch kubectl get pods"
echo "- 특정 Pod 로그: kubectl logs <pod-name>"
echo "- Pod 상세 정보: kubectl describe pod <pod-name>"
echo "- 리소스 사용량 실시간: watch kubectl top pods"
