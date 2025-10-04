#!/bin/bash

# Week 3 Day 4 Hands-on 1: ETCD 암호화 설정
# 사용법: ./setup-etcd-encryption.sh

set -e

echo "=== ETCD 암호화 설정 시작 ==="

# Kind 클러스터 이름 확인
CLUSTER_NAME=$(kind get clusters 2>/dev/null | head -1)
if [ -z "$CLUSTER_NAME" ]; then
    echo "❌ Kind 클러스터를 찾을 수 없습니다"
    exit 1
fi

CONTAINER_NAME="${CLUSTER_NAME}-control-plane"
echo "✅ 클러스터 발견: $CLUSTER_NAME"
echo "✅ 컨테이너: $CONTAINER_NAME"
echo ""

# 컨테이너 내부에서 실행할 스크립트
docker exec -i $CONTAINER_NAME bash <<'EOF'
set -e

echo "1/4 암호화 설정 파일 생성 중..."
cat <<YAML > /etc/kubernetes/encryption-config.yaml
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
    - secrets
    providers:
    - aescbc:
        keys:
        - name: key1
          secret: $(head -c 32 /dev/urandom | base64)
    - identity: {}
YAML

echo "✅ 암호화 설정 파일 생성 완료"

echo "2/4 API Server 설정 백업 중..."
cp /etc/kubernetes/manifests/kube-apiserver.yaml \
   /etc/kubernetes/manifests/kube-apiserver.yaml.backup
echo "✅ 백업 완료"

echo "3/4 API Server 설정 수정 중..."
sed -i '/- --tls-cert-file/a\    - --encryption-provider-config=/etc/kubernetes/encryption-config.yaml' \
  /etc/kubernetes/manifests/kube-apiserver.yaml

sed -i '/volumeMounts:/a\    - name: encryption-config\n      mountPath: /etc/kubernetes/encryption-config.yaml\n      readOnly: true' \
  /etc/kubernetes/manifests/kube-apiserver.yaml

sed -i '/volumes:/a\  - name: encryption-config\n    hostPath:\n      path: /etc/kubernetes/encryption-config.yaml\n      type: File' \
  /etc/kubernetes/manifests/kube-apiserver.yaml

echo "✅ API Server 설정 수정 완료"

echo "4/4 설정 확인 중..."
if grep -q "encryption-provider-config" /etc/kubernetes/manifests/kube-apiserver.yaml; then
    echo "✅ encryption-provider-config 옵션 추가 확인"
else
    echo "❌ 설정 추가 실패"
    exit 1
fi
EOF

echo ""
echo "=== ETCD 암호화 설정 완료 ==="
echo ""
echo "API Server 재시작 대기 중 (30초)..."
sleep 30

echo "API Server 상태 확인:"
kubectl get pods -n kube-system | grep kube-apiserver

echo ""
echo "✅ 설정 완료!"
