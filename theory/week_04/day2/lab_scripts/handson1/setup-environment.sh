#!/bin/bash

# Hands-on 1: Istio Service Mesh - 환경 준비

echo "=== Istio Hands-on 환경 준비 시작 ==="
echo ""

# 1. Lab 1 cleanup 확인
echo "1. Lab 1 환경 확인 중..."
if kubectl get namespace kong &>/dev/null; then
    echo "   ⚠️  Kong 네임스페이스가 존재합니다."
    echo "   💡 Lab 1 cleanup을 먼저 실행하세요:"
    echo "      cd ../lab1 && ./cleanup.sh"
    exit 1
fi
echo "   ✅ Kong 정리 완료"

# 2. backend 네임스페이스 확인
echo ""
echo "2. backend 네임스페이스 확인 중..."
if ! kubectl get namespace backend &>/dev/null; then
    kubectl create namespace backend
    echo "   ⚠️  backend 네임스페이스가 없어 생성했습니다."
fi
echo "   ✅ backend 네임스페이스 존재"

# 3. 백엔드 서비스 확인
echo ""
echo "3. 백엔드 서비스 확인 중..."
SERVICES=$(kubectl get svc -n backend --no-headers 2>/dev/null | wc -l)
if [ "$SERVICES" -lt 3 ]; then
    echo "   ❌ 백엔드 서비스가 부족합니다 (현재: $SERVICES개, 필요: 3개)."
    echo "   💡 Lab 1의 deploy-services.sh를 실행하세요:"
    echo "      cd ../lab1 && ./deploy-services.sh"
    exit 1
fi
echo "   ✅ 백엔드 서비스 확인 완료 (3개)"

# 4. Pod 상태 확인
echo ""
echo "4. Pod 상태 확인 중..."
kubectl get pods -n backend
echo ""

READY_PODS=$(kubectl get pods -n backend --no-headers 2>/dev/null | grep "1/1" | wc -l)
if [ "$READY_PODS" -lt 6 ]; then
    echo "   ⚠️  일부 Pod가 준비되지 않았습니다 (Ready: $READY_PODS/6)."
    echo "   ⏳ Pod 준비 대기 중..."
    kubectl wait --for=condition=ready pod --all -n backend --timeout=60s
fi
echo "   ✅ 모든 Pod 준비 완료"

# 5. Istio 다운로드 확인
echo ""
echo "5. Istio 설치 파일 확인 중..."
if [ ! -d "/tmp/istio-1.20.0" ]; then
    echo "   ⚠️  Istio가 다운로드되지 않았습니다."
    echo "   💡 다음 명령어로 Istio를 다운로드하세요:"
    echo "      cd /tmp"
    echo "      curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.20.0 sh -"
    echo ""
    echo "   또는 install-istio.sh 스크립트를 실행하세요:"
    echo "      ./install-istio.sh"
    exit 1
fi
echo "   ✅ Istio 설치 파일 확인 완료"

# 6. istioctl 명령어 확인
echo ""
echo "6. istioctl 명령어 확인 중..."
export PATH=/tmp/istio-1.20.0/bin:$PATH
if ! command -v istioctl &>/dev/null; then
    echo "   ⚠️  istioctl 명령어를 찾을 수 없습니다."
    echo "   💡 PATH에 istioctl을 추가하세요:"
    echo "      export PATH=/tmp/istio-1.20.0/bin:\$PATH"
    exit 1
fi
echo "   ✅ istioctl 명령어 확인 완료"
istioctl version --remote=false

echo ""
echo "=== 환경 준비 완료 ==="
echo ""
echo "📍 현재 상태:"
echo "   - backend 네임스페이스: 존재"
echo "   - 백엔드 서비스: 3개 (user, product, order)"
echo "   - Pod 상태: 모두 Ready"
echo "   - Istio 설치 파일: 준비 완료"
echo ""
echo "다음 단계:"
echo "   1. Istio 설치: ./install-istio.sh"
echo "   2. 애플리케이션 배포: ./deploy-with-istio.sh"
echo "   3. Istio 설정: ./configure-istio.sh"
