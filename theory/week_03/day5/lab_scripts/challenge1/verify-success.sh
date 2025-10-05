#!/bin/bash

# Week 3 Day 5 Challenge 1: 성공 검증 스크립트

echo "=== Challenge 1 성공 검증 시작 ==="
echo ""

PASS=0
FAIL=0

# 1. Challenge App 1 검증
echo "1. Challenge App 1 (Git 인증) 검증 중..."
APP1_STATUS=$(argocd app get challenge-app-1 --output json 2>/dev/null | jq -r '.status.sync.status')
APP1_HEALTH=$(argocd app get challenge-app-1 --output json 2>/dev/null | jq -r '.status.health.status')

if [[ "$APP1_STATUS" == "Synced" && "$APP1_HEALTH" == "Healthy" ]]; then
    echo "✅ Challenge App 1: PASS (Synced & Healthy)"
    ((PASS++))
else
    echo "❌ Challenge App 1: FAIL (Status: $APP1_STATUS, Health: $APP1_HEALTH)"
    ((FAIL++))
fi

# 2. Challenge App 2 검증
echo "2. Challenge App 2 (YAML 문법) 검증 중..."
APP2_STATUS=$(argocd app get challenge-app-2 --output json 2>/dev/null | jq -r '.status.sync.status')
APP2_HEALTH=$(argocd app get challenge-app-2 --output json 2>/dev/null | jq -r '.status.health.status')

if [[ "$APP2_STATUS" == "Synced" && "$APP2_HEALTH" == "Healthy" ]]; then
    echo "✅ Challenge App 2: PASS (Synced & Healthy)"
    ((PASS++))
else
    echo "❌ Challenge App 2: FAIL (Status: $APP2_STATUS, Health: $APP2_HEALTH)"
    ((FAIL++))
fi

# 3. Challenge App 3 검증
echo "3. Challenge App 3 (Application 설정) 검증 중..."
APP3_STATUS=$(argocd app get challenge-app-3 --output json 2>/dev/null | jq -r '.status.sync.status')
APP3_HEALTH=$(argocd app get challenge-app-3 --output json 2>/dev/null | jq -r '.status.health.status')

if [[ "$APP3_STATUS" == "Synced" && "$APP3_HEALTH" == "Healthy" ]]; then
    echo "✅ Challenge App 3: PASS (Synced & Healthy)"
    ((PASS++))
else
    echo "❌ Challenge App 3: FAIL (Status: $APP3_STATUS, Health: $APP3_HEALTH)"
    ((FAIL++))
fi

# 4. Challenge App 4 검증
echo "4. Challenge App 4 (동기화 정책) 검증 중..."
APP4_STATUS=$(argocd app get challenge-app-4 --output json 2>/dev/null | jq -r '.status.sync.status')
APP4_HEALTH=$(argocd app get challenge-app-4 --output json 2>/dev/null | jq -r '.status.health.status')
APP4_AUTOSYNC=$(kubectl get application challenge-app-4 -n argocd -o jsonpath='{.spec.syncPolicy.automated}')

if [[ "$APP4_STATUS" == "Synced" && "$APP4_HEALTH" == "Healthy" && -n "$APP4_AUTOSYNC" ]]; then
    echo "✅ Challenge App 4: PASS (Synced & Healthy & Auto-sync enabled)"
    ((PASS++))
else
    echo "❌ Challenge App 4: FAIL (Status: $APP4_STATUS, Health: $APP4_HEALTH, Auto-sync: $APP4_AUTOSYNC)"
    ((FAIL++))
fi

# 5. Pod 상태 검증
echo "5. Pod 상태 검증 중..."
RUNNING_PODS=$(kubectl get pods -n day5-challenge --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)

if [[ $RUNNING_PODS -gt 0 ]]; then
    echo "✅ Pod 상태: PASS ($RUNNING_PODS pods running)"
    ((PASS++))
else
    echo "❌ Pod 상태: FAIL (No running pods)"
    ((FAIL++))
fi

echo ""
echo "=== 검증 결과 ==="
echo "✅ 성공: $PASS/5"
echo "❌ 실패: $FAIL/5"
echo ""

if [[ $FAIL -eq 0 ]]; then
    echo "🎉 축하합니다! 모든 Challenge를 성공적으로 완료했습니다!"
    echo ""
    echo "다음 단계:"
    echo "- ArgoCD UI에서 Application 상태 확인"
    echo "- Git 커밋 이력 확인"
    echo "- 팀원들과 해결 과정 공유"
    exit 0
else
    echo "⚠️  일부 Challenge가 아직 해결되지 않았습니다."
    echo ""
    echo "문제 해결 가이드:"
    echo "- argocd app get <app-name> 으로 상세 오류 확인"
    echo "- kubectl logs -n argocd deployment/argocd-application-controller"
    echo "- Challenge 문서의 힌트 섹션 참고"
    exit 1
fi
