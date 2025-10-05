#!/bin/bash

# Week 3 Day 5 Lab 1: Prometheus Stack 설치
# 사용법: ./02-install-prometheus.sh

set -e

echo "=== Prometheus Stack 설치 시작 ==="
echo ""

# Namespace 생성
echo "1. monitoring Namespace 생성 중..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
echo "✅ Namespace 생성 완료"

echo ""
echo "2. kube-prometheus-stack 설치 중..."
echo "   (약 2-3분 소요됩니다)"

helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set grafana.enabled=true \
  --set grafana.adminPassword=admin123 \
  --wait

echo ""
echo "✅ Prometheus Stack 설치 완료"

echo ""
echo "3. 설치된 컴포넌트 확인 중..."
echo ""

# Helm Release 확인
echo "📦 Helm Release:"
helm list -n monitoring

echo ""
echo "🔍 Pod 상태:"
kubectl get pods -n monitoring

echo ""
echo "🌐 Service 목록:"
kubectl get svc -n monitoring

echo ""
echo "=== 설치 완료 ==="
echo ""
echo "📊 Prometheus 접속:"
echo "   kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090"
echo "   http://localhost:9090"
echo ""
echo "📈 Grafana 접속:"
echo "   kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
echo "   http://localhost:3000"
echo "   Username: admin"
echo "   Password: admin123"
