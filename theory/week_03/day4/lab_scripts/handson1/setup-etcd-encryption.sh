#!/bin/bash

# Week 3 Day 4 Hands-on 1: ETCD 암호화 설정
# 주의: 이 스크립트는 Kind 컨테이너 내부에서 실행해야 합니다
# 사용법: docker exec -it challenge-cluster-control-plane bash
#         ./setup-etcd-encryption.sh

set -e

echo "=== ETCD 암호화 설정 시작 ==="

# 1. 암호화 설정 파일 생성
echo "1/4 암호화 설정 파일 생성 중..."
cat <<EOF > /etc/kubernetes/encryption-config.yaml
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
EOF

echo "✅ 암호화 설정 파일 생성 완료: /etc/kubernetes/encryption-config.yaml"

# 2. API Server 설정 백업
echo "2/4 API Server 설정 백업 중..."
cp /etc/kubernetes/manifests/kube-apiserver.yaml \
   /etc/kubernetes/manifests/kube-apiserver.yaml.backup

echo "✅ 백업 완료: kube-apiserver.yaml.backup"

# 3. API Server 설정 수정
echo "3/4 API Server 설정 수정 중..."

# command에 옵션 추가
sed -i '/- --tls-cert-file/a\    - --encryption-provider-config=/etc/kubernetes/encryption-config.yaml' \
  /etc/kubernetes/manifests/kube-apiserver.yaml

# volumeMounts 추가
sed -i '/volumeMounts:/a\    - name: encryption-config\n      mountPath: /etc/kubernetes/encryption-config.yaml\n      readOnly: true' \
  /etc/kubernetes/manifests/kube-apiserver.yaml

# volumes 추가
sed -i '/volumes:/a\  - name: encryption-config\n    hostPath:\n      path: /etc/kubernetes/encryption-config.yaml\n      type: File' \
  /etc/kubernetes/manifests/kube-apiserver.yaml

echo "✅ API Server 설정 수정 완료"

# 4. 설정 확인
echo "4/4 설정 확인 중..."
if grep -q "encryption-provider-config" /etc/kubernetes/manifests/kube-apiserver.yaml; then
    echo "✅ encryption-provider-config 옵션 추가 확인"
else
    echo "❌ encryption-provider-config 옵션 추가 실패"
    exit 1
fi

echo ""
echo "=== ETCD 암호화 설정 완료 ==="
echo ""
echo "다음 단계:"
echo "1. 컨테이너 종료: exit"
echo "2. API Server 재시작 확인 (약 30초 소요):"
echo "   kubectl get pods -n kube-system | grep kube-apiserver"
echo ""
echo "⚠️  주의: API Server가 재시작되지 않으면 백업에서 복구하세요:"
echo "   docker exec -it challenge-cluster-control-plane bash"
echo "   cp /etc/kubernetes/manifests/kube-apiserver.yaml.backup \\"
echo "      /etc/kubernetes/manifests/kube-apiserver.yaml"
