#!/bin/bash

# 네임스페이스 설정 스크립트

echo "🚀 네임스페이스 설정 시작..."
echo "=================================="

# 네임스페이스 생성
NAMESPACES=("development" "staging" "production")

for ns in "${NAMESPACES[@]}"; do
    echo "📁 네임스페이스 '$ns' 생성 중..."
    
    if kubectl get namespace "$ns" > /dev/null 2>&1; then
        echo "✅ 네임스페이스 '$ns'가 이미 존재합니다"
    else
        kubectl create namespace "$ns"
        echo "✅ 네임스페이스 '$ns' 생성 완료"
    fi
    
    # 라벨 추가
    kubectl label namespace "$ns" env="$ns" --overwrite
    echo "🏷️  라벨 추가: env=$ns"
done

echo -e "\n🎯 컨텍스트 생성 중..."

# 현재 클러스터와 사용자 정보 가져오기
CURRENT_CONTEXT=$(kubectl config current-context)
CLUSTER=$(kubectl config view -o jsonpath="{.contexts[?(@.name=='$CURRENT_CONTEXT')].context.cluster}")
USER=$(kubectl config view -o jsonpath="{.contexts[?(@.name=='$CURRENT_CONTEXT')].context.user}")

# 각 네임스페이스별 컨텍스트 생성
for ns in "${NAMESPACES[@]}"; do
    CONTEXT_NAME="${ns}-context"
    
    kubectl config set-context "$CONTEXT_NAME" \
        --cluster="$CLUSTER" \
        --user="$USER" \
        --namespace="$ns"
    
    echo "✅ 컨텍스트 '$CONTEXT_NAME' 생성 완료"
done

echo -e "\n📋 생성된 네임스페이스 확인:"
kubectl get namespaces --show-labels | grep -E "(development|staging|production)"

echo -e "\n📋 생성된 컨텍스트 확인:"
kubectl config get-contexts | grep -E "(development|staging|production)"

echo -e "\n🎯 설정 완료!"
echo "사용법:"
echo "  kubectl config use-context development-context"
echo "  kubectl config use-context staging-context"
echo "  kubectl config use-context production-context"
