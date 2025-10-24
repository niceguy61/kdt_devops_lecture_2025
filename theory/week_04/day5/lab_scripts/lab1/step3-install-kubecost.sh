#!/bin/bash

# Week 4 Day 5 Lab 1: Kubecost 설치
# 설명: Helm을 통한 Kubecost + Prometheus 설치

set -e

echo "=== Kubecost 설치 시작 ==="

# 1. Helm 저장소 추가
echo "1/4 Helm 저장소 추가 중..."
helm repo add kubecost https://kubecost.github.io/cost-analyzer/
helm repo update

# 2. kubecost 네임스페이스 생성
echo "2/4 kubecost 네임스페이스 생성 중..."
kubectl create namespace kubecost --dry-run=client -o yaml | kubectl apply -f -

# 3. Kubecost 설치
echo "3/4 Kubecost 설치 중 (Prometheus 포함)..."
helm install kubecost kubecost/cost-analyzer \
  --namespace kubecost \
  --set kubecostToken="aGVsbUBrdWJlY29zdC5jb20=xm343yadf98" \
  --set prometheus.server.global.external_labels.cluster_id="lab-cluster" \
  --set service.type=NodePort \
  --set service.nodePort=30080 \
  --wait \
  --timeout=10m

# 4. 배포 확인
echo "4/4 배포 상태 확인 중..."
kubectl get pods -n kubecost

echo ""
echo "=== Kubecost 설치 완료 ==="
echo ""
echo "배포된 컴포넌트:"
echo "- Kubecost Cost Analyzer: 비용 계산 엔진"
echo "- Prometheus Server: 메트릭 수집 및 저장"
echo ""
echo "Kubecost 대시보드 접속:"
echo "- URL: http://localhost:30080"
echo ""
echo "💡 대시보드가 완전히 로드되려면 2-3분 소요됩니다."
echo ""
echo "✅ 모든 작업이 성공적으로 완료되었습니다."
