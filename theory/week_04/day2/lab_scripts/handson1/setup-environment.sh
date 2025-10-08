#!/bin/bash

# Hands-on 1 환경 준비 스크립트

echo "=== Hands-on 1 환경 준비 시작 ==="
echo ""

# 1. 기존 클러스터 확인 및 삭제
echo "1. 기존 클러스터 확인 중..."
if kind get clusters | grep -q "w4d2-handson"; then
    echo "   ⚠️  기존 w4d2-handson 클러스터 발견"
    echo "   🗑️  기존 클러스터 삭제 중..."
    kind delete cluster --name w4d2-handson
    echo "   ✅ 기존 클러스터 삭제 완료"
fi

# 2. Kind 클러스터 생성 (포트 8080 매핑)
echo ""
echo "2. Kind 클러스터 생성 중 (포트 8080 매핑)..."
cat <<YAML | kind create cluster --name w4d2-handson --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080
    hostPort: 8080
    protocol: TCP
YAML

echo "   ✅ 클러스터 생성 완료"

# 3. kubectl 컨텍스트 설정
echo ""
echo "3. kubectl 컨텍스트 설정 중..."
kubectl config use-context kind-w4d2-handson
echo "   ✅ 컨텍스트 설정 완료"

# 4. 노드 Ready 대기
echo ""
echo "4. 노드 Ready 대기 중..."
kubectl wait --for=condition=ready node --all --timeout=60s

echo ""
echo "=== 환경 준비 완료 ==="
echo ""
echo "작업 디렉토리: $(pwd)"
echo "Kubernetes Context: $(kubectl config current-context)"
echo ""
echo "💡 접속 주소: http://localhost:8080"
echo ""
echo "다음 단계:"
echo "  1. 수동 실행: handson_1.md의 Step 2부터 진행"
echo "  2. 빠른 실행: ./setup-all.sh"
