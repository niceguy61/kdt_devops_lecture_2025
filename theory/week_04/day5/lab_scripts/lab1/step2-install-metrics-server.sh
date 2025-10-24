#!/bin/bash

# Week 4 Day 5 Lab 1: Metrics Server 설치
# 설명: Kubernetes 메트릭 수집을 위한 Metrics Server 설치

set -e

echo "=== Metrics Server 설치 시작 ==="

# 1. Metrics Server 설치
echo "1/3 Metrics Server 설치 중..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# 2. Kind 환경을 위한 패치
echo "2/3 Kind 환경 패치 적용 중..."
kubectl patch -n kube-system deployment metrics-server --type=json \
  -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

# 3. 배포 완료 대기
echo "3/3 배포 완료 대기 중..."
kubectl rollout status -n kube-system deployment/metrics-server --timeout=300s

echo ""
echo "=== Metrics Server 설치 완료 ==="
echo ""
echo "배포된 컴포넌트:"
echo "- Metrics Server: 리소스 사용량 수집"
echo ""
echo "테스트 명령어:"
echo "  kubectl top nodes"
echo "  kubectl top pods -A"
echo ""
echo "✅ 모든 작업이 성공적으로 완료되었습니다."
