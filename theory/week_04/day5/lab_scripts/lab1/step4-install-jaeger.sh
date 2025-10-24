#!/bin/bash

# Week 4 Day 5 Lab 1: Jaeger 설치
# 설명: Jaeger 분산 추적 시스템 설치

set -e

echo "=== Jaeger 설치 시작 ==="

# 1. Helm 저장소 추가
echo "1/3 Helm 저장소 추가 중..."
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm repo update

# 2. Jaeger 설치
echo "2/3 Jaeger 설치 중..."
helm install jaeger jaegertracing/jaeger \
  --namespace monitoring \
  --set provisionDataStore.cassandra=false \
  --set allInOne.enabled=true \
  --set storage.type=memory \
  --set query.service.type=NodePort \
  --set query.service.nodePort=30081 \
  --wait \
  --timeout=10m

# 3. 배포 확인
echo "3/3 배포 상태 확인 중..."
kubectl get pods -n monitoring | grep jaeger

echo ""
echo "=== Jaeger 설치 완료 ==="
echo ""
echo "배포된 컴포넌트:"
echo "- Jaeger All-in-One: 분산 추적 시스템"
echo ""
echo "Jaeger UI 접속 정보:"
echo "- URL: http://localhost:30081"
echo ""
echo "✅ 모든 작업이 성공적으로 완료되었습니다."
