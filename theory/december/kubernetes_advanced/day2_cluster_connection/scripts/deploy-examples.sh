#!/bin/bash

# 예제 워크로드 배포 스크립트

echo "🚀 예제 워크로드 배포 시작..."
echo "=================================="

# 네임스페이스 존재 확인
NAMESPACES=("development" "staging")

for ns in "${NAMESPACES[@]}"; do
    if ! kubectl get namespace "$ns" > /dev/null 2>&1; then
        echo "❌ 네임스페이스 '$ns'가 존재하지 않습니다"
        echo "   먼저 setup-namespaces.sh를 실행하세요"
        exit 1
    fi
done

echo "✅ 네임스페이스 확인 완료"

# Development 네임스페이스에 Pod 배포
echo -e "\n📁 Development 네임스페이스에 Pod 배포 중..."
kubectl apply -f ../manifests/pod-example.yaml

# Pod 상태 확인
echo "⏳ Pod 시작 대기 중..."
kubectl wait --for=condition=Ready pod/nginx-pod -n development --timeout=60s

if [ $? -eq 0 ]; then
    echo "✅ nginx-pod 배포 완료"
else
    echo "❌ nginx-pod 배포 실패"
fi

# Service 배포
echo -e "\n🌐 Service 배포 중..."
kubectl apply -f ../manifests/service-example.yaml

# Staging 네임스페이스에 Deployment 배포
echo -e "\n📁 Staging 네임스페이스에 Deployment 배포 중..."
kubectl apply -f ../manifests/deployment-example.yaml

# Deployment 상태 확인
echo "⏳ Deployment 롤아웃 대기 중..."
kubectl rollout status deployment/web-app -n staging --timeout=120s

if [ $? -eq 0 ]; then
    echo "✅ web-app Deployment 배포 완료"
else
    echo "❌ web-app Deployment 배포 실패"
fi

# LoadBalancer Service 생성
echo -e "\n🌐 LoadBalancer Service 생성 중..."
kubectl expose deployment web-app --port=80 --target-port=80 \
    --type=LoadBalancer --name=web-app-lb -n staging

echo -e "\n📋 배포 상태 확인:"
echo "Development 네임스페이스:"
kubectl get all -n development

echo -e "\nStaging 네임스페이스:"
kubectl get all -n staging

echo -e "\n🎯 배포 완료!"
echo "테스트 명령어:"
echo "  # Pod 접근 테스트"
echo "  kubectl run test-client --image=busybox --rm -it --restart=Never -n development -- wget -qO- http://nginx-service"
echo ""
echo "  # LoadBalancer 외부 IP 확인"
echo "  kubectl get service web-app-lb -n staging"
