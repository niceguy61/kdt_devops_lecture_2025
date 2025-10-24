#!/bin/bash

# Week 4 Day 5 Lab 1: Prometheus Stack 설치
# 설명: kube-prometheus-stack Helm Chart 설치

set -e

echo "=== Prometheus Stack 설치 시작 ==="

# 1. Helm 저장소 추가
echo "1/4 Helm 저장소 추가 중..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# 2. monitoring 네임스페이스 생성
echo "2/4 monitoring 네임스페이스 생성 중..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# 3. kube-prometheus-stack 설치
echo "3/4 kube-prometheus-stack 설치 중..."
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.retention=7d \
  --set grafana.adminPassword=admin123 \
  --set grafana.service.type=NodePort \
  --set grafana.service.nodePort=30080 \
  --wait \
  --timeout=10m

# 4. 배포 확인
echo "4/4 배포 상태 확인 중..."
kubectl get pods -n monitoring

echo ""
echo "=== Prometheus Stack 설치 완료 ==="
echo ""
echo "배포된 컴포넌트:"
echo "- Prometheus: 메트릭 수집 및 저장"
echo "- Grafana: 대시보드 (http://localhost:30080)"
echo "- AlertManager: 알림 관리"
echo ""
echo "Grafana 접속 정보:"
echo "- URL: http://localhost:30080"
echo "- Username: admin"
echo "- Password: admin123"
echo ""
echo "✅ 모든 작업이 성공적으로 완료되었습니다."
