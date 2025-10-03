#!/bin/bash

# Lab 1 정리 스크립트

echo "🧹 Lab 1 환경 정리 시작..."

echo "🗑️ 워크로드 삭제 중..."
kubectl delete deployment web-deployment -n lab2-workloads --ignore-not-found=true
kubectl delete replicaset web-replicaset -n lab2-workloads --ignore-not-found=true
kubectl delete pod web-pod -n lab2-workloads --ignore-not-found=true

echo "📦 네임스페이스 삭제 중..."
kubectl delete namespace lab2-workloads --ignore-not-found=true

echo "✅ Lab 1 환경 정리 완료!"
