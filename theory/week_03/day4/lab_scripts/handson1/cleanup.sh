#!/bin/bash

# Week 3 Day 4 Hands-on 1: 환경 정리
# 사용법: ./cleanup.sh

set -e

echo "=== Hands-on 1 환경 정리 시작 ==="

# Pod Security Standards 라벨 제거
echo "1/4 Pod Security Standards 라벨 제거 중..."
kubectl label namespace production \
  pod-security.kubernetes.io/enforce- \
  pod-security.kubernetes.io/audit- \
  pod-security.kubernetes.io/warn- \
  2>&1 || true

kubectl label namespace development \
  pod-security.kubernetes.io/enforce- \
  pod-security.kubernetes.io/audit- \
  pod-security.kubernetes.io/warn- \
  2>&1 || true

# 테스트 Pod 삭제
echo "2/4 테스트 리소스 삭제 중..."
kubectl delete pod secure-app -n production 2>&1 || true
kubectl delete pod privileged-app -n production 2>&1 || true
kubectl delete secret test-secret -n production 2>&1 || true

# External Secrets 삭제 (설치된 경우)
echo "3/4 External Secrets 확인 중..."
if kubectl get namespace external-secrets-system &>/dev/null; then
    read -p "External Secrets Operator를 삭제하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        helm uninstall external-secrets -n external-secrets-system 2>/dev/null || true
        kubectl delete namespace external-secrets-system 2>&1 || true
        echo "External Secrets 삭제 완료"
    else
        echo "External Secrets 유지"
    fi
fi

# 백업 파일 정리
echo "4/4 백업 파일 정리 중..."
if [ -d "/tmp/etcd-backup" ]; then
    read -p "ETCD 백업 파일을 삭제하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf /tmp/etcd-backup
        echo "백업 파일 삭제 완료"
    else
        echo "백업 파일 유지"
    fi
fi

echo ""
echo "=== Hands-on 1 환경 정리 완료 ==="
echo ""
echo "참고: Lab 1 네임스페이스는 유지됩니다."
echo "Lab 1 환경도 정리하려면 ../lab1/cleanup.sh를 실행하세요."
