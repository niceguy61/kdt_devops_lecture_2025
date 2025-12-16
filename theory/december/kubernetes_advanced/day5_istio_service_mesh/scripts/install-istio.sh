#!/bin/bash

# Istio 설치 및 설정 스크립트

echo "🚀 Istio 서비스 메시 설치 시작..."
echo "=================================="

# Istio 버전 설정
ISTIO_VERSION="1.20.0"

# 1. Istio CLI 설치
echo "📥 Istio CLI 다운로드 및 설치 중..."

if command -v istioctl &> /dev/null; then
    echo "✅ istioctl이 이미 설치되어 있습니다"
    istioctl version --remote=false
else
    echo "📦 Istio 다운로드 중..."
    curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIO_VERSION sh -
    
    if [ $? -eq 0 ]; then
        echo "✅ Istio 다운로드 완료"
        
        # PATH에 istioctl 추가
        export PATH=$PWD/istio-$ISTIO_VERSION/bin:$PATH
        
        # .bashrc에 PATH 추가
        if ! grep -q "istio.*bin" ~/.bashrc; then
            echo "export PATH=\$PWD/istio-$ISTIO_VERSION/bin:\$PATH" >> ~/.bashrc
        fi
        
        echo "✅ istioctl PATH 설정 완료"
    else
        echo "❌ Istio 다운로드 실패"
        exit 1
    fi
fi

# 2. 사전 검사
echo -e "\n🔍 Istio 설치 사전 검사 중..."
istioctl analyze

if [ $? -eq 0 ]; then
    echo "✅ 사전 검사 통과"
else
    echo "⚠️  사전 검사에서 경고가 발견되었지만 계속 진행합니다"
fi

# 3. Istio Control Plane 설치
echo -e "\n🏗️  Istio Control Plane 설치 중..."

# 기존 Istio 설치 확인
if kubectl get namespace istio-system > /dev/null 2>&1; then
    echo "⚠️  기존 Istio 설치가 발견되었습니다"
    echo "기존 설치를 제거하고 새로 설치하시겠습니까? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "🗑️  기존 Istio 제거 중..."
        istioctl uninstall --purge -y
        kubectl delete namespace istio-system --ignore-not-found=true
    else
        echo "기존 설치를 유지합니다"
    fi
fi

# Demo 프로필로 설치 (개발/테스트용)
echo "📦 Istio 설치 중 (Demo 프로필)..."
istioctl install --set values.defaultRevision=default -y

if [ $? -eq 0 ]; then
    echo "✅ Istio Control Plane 설치 완료"
else
    echo "❌ Istio Control Plane 설치 실패"
    exit 1
fi

# 4. 설치 확인
echo -e "\n🔍 Istio 설치 확인 중..."

# Pod 상태 확인
echo "Istio 시스템 Pod 상태 확인 중..."
kubectl wait --for=condition=Ready pod -l app=istiod -n istio-system --timeout=300s

if [ $? -eq 0 ]; then
    echo "✅ Istiod Pod 준비 완료"
else
    echo "❌ Istiod Pod 준비 실패"
    exit 1
fi

# Ingress Gateway 확인
kubectl wait --for=condition=Ready pod -l app=istio-ingressgateway -n istio-system --timeout=300s

if [ $? -eq 0 ]; then
    echo "✅ Istio Ingress Gateway 준비 완료"
else
    echo "❌ Istio Ingress Gateway 준비 실패"
    exit 1
fi

# 5. 네임스페이스 사이드카 주입 설정
echo -e "\n🏷️  네임스페이스 사이드카 주입 설정 중..."

NAMESPACES=("production" "staging" "development")

for ns in "${NAMESPACES[@]}"; do
    if kubectl get namespace "$ns" > /dev/null 2>&1; then
        echo "네임스페이스 '$ns'에 사이드카 주입 활성화 중..."
        kubectl label namespace "$ns" istio-injection=enabled --overwrite
        echo "✅ 네임스페이스 '$ns' 사이드카 주입 활성화 완료"
    else
        echo "⚠️  네임스페이스 '$ns'가 존재하지 않습니다"
    fi
done

# 6. 기존 워크로드 재시작 (사이드카 주입을 위해)
echo -e "\n🔄 기존 워크로드 재시작 중 (사이드카 주입)..."

for ns in "${NAMESPACES[@]}"; do
    if kubectl get namespace "$ns" > /dev/null 2>&1; then
        echo "네임스페이스 '$ns'의 Deployment 재시작 중..."
        
        # Deployment 목록 확인
        DEPLOYMENTS=$(kubectl get deployments -n "$ns" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
        
        if [ ! -z "$DEPLOYMENTS" ]; then
            for deployment in $DEPLOYMENTS; do
                echo "  재시작 중: $deployment"
                kubectl rollout restart deployment/"$deployment" -n "$ns"
            done
            
            # 재시작 완료 대기
            echo "  재시작 완료 대기 중..."
            kubectl rollout status deployment --all -n "$ns" --timeout=300s
            
            if [ $? -eq 0 ]; then
                echo "✅ 네임스페이스 '$ns' 워크로드 재시작 완료"
            else
                echo "⚠️  네임스페이스 '$ns' 워크로드 재시작 시간 초과"
            fi
        else
            echo "  네임스페이스 '$ns'에 Deployment가 없습니다"
        fi
    fi
done

# 7. 관측성 도구 설치
echo -e "\n📊 관측성 도구 설치 중..."

# Kiali 설치
echo "Kiali 설치 중..."
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/kiali.yaml

# Prometheus 설치
echo "Prometheus 설치 중..."
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/prometheus.yaml

# Grafana 설치
echo "Grafana 설치 중..."
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/grafana.yaml

# Jaeger 설치
echo "Jaeger 설치 중..."
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/jaeger.yaml

# 관측성 도구 준비 대기
echo "관측성 도구 준비 대기 중..."
sleep 30

# 8. 설치 결과 확인
echo -e "\n📋 Istio 설치 결과 확인:"

echo -e "\n🔍 Istio 시스템 Pod 상태:"
kubectl get pods -n istio-system

echo -e "\n🔍 Istio 서비스 상태:"
kubectl get services -n istio-system

echo -e "\n🔍 사이드카 주입 설정된 네임스페이스:"
kubectl get namespaces --show-labels | grep istio-injection=enabled

echo -e "\n🔍 사이드카가 주입된 Pod 확인:"
for ns in "${NAMESPACES[@]}"; do
    if kubectl get namespace "$ns" > /dev/null 2>&1; then
        echo "네임스페이스: $ns"
        kubectl get pods -n "$ns" 2>/dev/null | grep -E "NAME|2/2" || echo "  사이드카가 주입된 Pod가 없습니다"
    fi
done

# 9. Ingress Gateway 외부 IP 확인
echo -e "\n🌐 Istio Ingress Gateway 외부 접근 정보:"
EXTERNAL_IP=$(kubectl get service istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
EXTERNAL_PORT=$(kubectl get service istio-ingressgateway -n istio-system -o jsonpath='{.spec.ports[?(@.name=="http2")].port}' 2>/dev/null)

if [ ! -z "$EXTERNAL_IP" ]; then
    echo "✅ 외부 접근 URL: http://$EXTERNAL_IP:$EXTERNAL_PORT"
else
    echo "⏳ LoadBalancer IP 할당 대기 중..."
    echo "   다음 명령어로 확인: kubectl get service istio-ingressgateway -n istio-system -w"
fi

# 10. 관측성 도구 접근 정보
echo -e "\n📊 관측성 도구 접근 방법:"
echo "Kiali 대시보드:"
echo "  kubectl port-forward -n istio-system service/kiali 20001:20001"
echo "  브라우저: http://localhost:20001"
echo ""
echo "Grafana 대시보드:"
echo "  kubectl port-forward -n istio-system service/grafana 3000:3000"
echo "  브라우저: http://localhost:3000"
echo ""
echo "Jaeger 추적:"
echo "  kubectl port-forward -n istio-system service/jaeger 16686:16686"
echo "  브라우저: http://localhost:16686"

echo -e "\n🎯 Istio 설치 완료!"
echo "다음 단계:"
echo "  1. Session 2에서 Gateway 및 VirtualService 설정"
echo "  2. 트래픽 관리 및 관측성 실습"
echo "  3. Kiali 대시보드에서 서비스 메시 시각화 확인"

# 최종 상태 검증
echo -e "\n🔍 최종 설치 검증:"
istioctl analyze --all-namespaces

if [ $? -eq 0 ]; then
    echo "✅ Istio 설치 및 설정이 성공적으로 완료되었습니다!"
else
    echo "⚠️  일부 설정에 문제가 있을 수 있습니다. 위의 분석 결과를 확인하세요."
fi
