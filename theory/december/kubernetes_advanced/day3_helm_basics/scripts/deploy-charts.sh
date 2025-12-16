#!/bin/bash

# Helm Chart 배포 스크립트

echo "🚀 Helm Chart 배포 시작..."
echo "=================================="

CHART_NAME="my-web-app"
CHART_PATH="./$CHART_NAME"

# Chart 존재 확인
if [ ! -d "$CHART_PATH" ]; then
    echo "❌ Chart 디렉토리 '$CHART_PATH'가 존재하지 않습니다"
    echo "   먼저 create-sample-chart.sh를 실행하세요"
    exit 1
fi

# 네임스페이스 존재 확인
NAMESPACES=("development" "staging")

for ns in "${NAMESPACES[@]}"; do
    if ! kubectl get namespace "$ns" > /dev/null 2>&1; then
        echo "❌ 네임스페이스 '$ns'가 존재하지 않습니다"
        echo "   먼저 Day 2의 setup-namespaces.sh를 실행하세요"
        exit 1
    fi
done

echo "✅ 사전 조건 확인 완료"

# Chart 검증
echo -e "\n🔍 Chart 검증 중..."
helm lint "$CHART_PATH/"

if [ $? -ne 0 ]; then
    echo "❌ Chart 검증 실패"
    exit 1
fi

# Development 환경 배포
echo -e "\n📁 Development 환경 배포 중..."

# 기존 Release 확인 및 삭제
if helm list -n development | grep -q "$CHART_NAME-dev"; then
    echo "⚠️  기존 Release '$CHART_NAME-dev' 삭제 중..."
    helm uninstall "$CHART_NAME-dev" -n development
fi

# 템플릿 렌더링 테스트
echo "🔍 템플릿 렌더링 테스트 중..."
helm template "$CHART_NAME-dev" "$CHART_PATH/" -f values/development.yaml > /dev/null

if [ $? -ne 0 ]; then
    echo "❌ 템플릿 렌더링 실패"
    exit 1
fi

# Development 배포
helm install "$CHART_NAME-dev" "$CHART_PATH/" \
    -f values/development.yaml \
    -n development

if [ $? -eq 0 ]; then
    echo "✅ Development 환경 배포 완료"
else
    echo "❌ Development 환경 배포 실패"
    exit 1
fi

# Staging 환경 배포
echo -e "\n📁 Staging 환경 배포 중..."

# 기존 Release 확인 및 삭제
if helm list -n staging | grep -q "$CHART_NAME-staging"; then
    echo "⚠️  기존 Release '$CHART_NAME-staging' 삭제 중..."
    helm uninstall "$CHART_NAME-staging" -n staging
fi

# Staging 배포
helm install "$CHART_NAME-staging" "$CHART_PATH/" \
    -f values/staging.yaml \
    -n staging

if [ $? -eq 0 ]; then
    echo "✅ Staging 환경 배포 완료"
else
    echo "❌ Staging 환경 배포 실패"
    exit 1
fi

# 배포 상태 확인
echo -e "\n📋 배포 상태 확인:"

echo -e "\n🔍 Helm Release 목록:"
helm list --all-namespaces | grep "$CHART_NAME"

echo -e "\n🔍 Development 환경 리소스:"
kubectl get all -n development -l app.kubernetes.io/instance="$CHART_NAME-dev"

echo -e "\n🔍 Staging 환경 리소스:"
kubectl get all -n staging -l app.kubernetes.io/instance="$CHART_NAME-staging"

# ConfigMap 확인
echo -e "\n🔍 ConfigMap 확인:"
echo "Development ConfigMap:"
kubectl get configmap -n development -l app.kubernetes.io/instance="$CHART_NAME-dev"

echo "Staging ConfigMap:"
kubectl get configmap -n staging -l app.kubernetes.io/instance="$CHART_NAME-staging"

# 서비스 접근 테스트
echo -e "\n🌐 서비스 접근 테스트:"

# Development 서비스 테스트
echo "Development 서비스 테스트 중..."
kubectl run test-dev --image=busybox --rm -it --restart=Never -n development \
    -- wget -qO- http://"$CHART_NAME-dev":80 2>/dev/null && echo "✅ Development 서비스 접근 성공" || echo "❌ Development 서비스 접근 실패"

# Staging 서비스 테스트
echo "Staging 서비스 테스트 중..."
kubectl run test-staging --image=busybox --rm -it --restart=Never -n staging \
    -- wget -qO- http://"$CHART_NAME-staging":80 2>/dev/null && echo "✅ Staging 서비스 접근 성공" || echo "❌ Staging 서비스 접근 실패"

echo -e "\n🎯 배포 완료!"
echo "관리 명령어:"
echo "  # Release 상태 확인"
echo "  helm status $CHART_NAME-dev -n development"
echo "  helm status $CHART_NAME-staging -n staging"
echo ""
echo "  # Release 업그레이드"
echo "  helm upgrade $CHART_NAME-dev $CHART_PATH/ -f values/development.yaml -n development"
echo ""
echo "  # Release 삭제"
echo "  helm uninstall $CHART_NAME-dev -n development"
echo "  helm uninstall $CHART_NAME-staging -n staging"
