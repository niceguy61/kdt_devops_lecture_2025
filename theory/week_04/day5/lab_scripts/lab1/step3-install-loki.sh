#!/bin/bash

# Week 4 Day 5 Lab 1: Loki Stack 설치
# 설명: Loki + Promtail 로깅 스택 설치

set -e

echo "=== Loki Stack 설치 시작 ==="

# 1. Helm 저장소 추가
echo "1/3 Helm 저장소 추가 중..."
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# 2. Loki Stack 설치
echo "2/3 Loki Stack 설치 중..."
helm install loki grafana/loki-stack \
  --namespace monitoring \
  --set grafana.enabled=false \
  --set prometheus.enabled=false \
  --set loki.persistence.enabled=true \
  --set loki.persistence.size=10Gi \
  --wait \
  --timeout=10m

# 3. 배포 확인
echo "3/3 배포 상태 확인 중..."
kubectl get pods -n monitoring | grep loki

echo ""
echo "=== Loki Stack 설치 완료 ==="
echo ""
echo "배포된 컴포넌트:"
echo "- Loki: 로그 저장소"
echo "- Promtail: 로그 수집 에이전트 (DaemonSet)"
echo ""
echo "💡 Grafana에서 Loki 데이터소스가 자동으로 추가됩니다."
echo ""
echo "✅ 모든 작업이 성공적으로 완료되었습니다."
