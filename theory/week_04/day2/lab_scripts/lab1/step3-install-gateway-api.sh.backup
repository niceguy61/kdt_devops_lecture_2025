#!/bin/bash

# Step 3: Gateway API 설치

echo "=== Step 3: Gateway API 설치 시작 ==="
echo ""

# Gateway API CRDs 설치
echo "1. Gateway API CRDs 설치 중..."
kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v1.0.0" | kubectl apply -f -; }

# 설치 확인
echo ""
echo "2. Gateway API CRDs 확인 중..."
kubectl get crd | grep gateway

echo ""
echo "=== Step 3: Gateway API 설치 완료 ==="
