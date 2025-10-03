#!/bin/bash

# 컴포넌트 상태 확인 스크립트

echo "=== Checking Kubernetes Components ==="

# 로그 디렉토리 생성
mkdir -p logs

echo "1. Checking Control Plane Components..."

# API Server 상태 확인
echo "API Server status:"
kubectl get pods -n kube-system -l component=kube-apiserver

# API Server 로그 확인
echo "Collecting API Server logs..."
kubectl logs -n kube-system -l component=kube-apiserver --tail=50 > logs/apiserver.log

# ETCD 상태 확인
echo "ETCD status:"
kubectl get pods -n kube-system -l component=etcd

# Controller Manager 상태 확인
echo "Controller Manager status:"
kubectl get pods -n kube-system -l component=kube-controller-manager

# Controller Manager 로그
kubectl logs -n kube-system -l component=kube-controller-manager --tail=50 > logs/controller-manager.log

# Scheduler 상태 확인
echo "Scheduler status:"
kubectl get pods -n kube-system -l component=kube-scheduler

# Scheduler 로그
kubectl logs -n kube-system -l component=kube-scheduler --tail=50 > logs/scheduler.log

echo "2. Checking Worker Node Components..."

# Kube Proxy 확인
echo "Kube Proxy status:"
kubectl get pods -n kube-system -l k8s-app=kube-proxy

# CNI 플러그인 확인
echo "CNI Plugin status:"
kubectl get pods -n kube-system -l app=kindnet

echo "3. Analyzing Logs..."

# 로그 분석 (에러 및 경고 확인)
echo "Errors found in logs:"
grep -i error logs/*.log || echo "No errors found"

echo "Warnings found in logs:"
grep -i warning logs/*.log || echo "No warnings found"

echo "Component check completed!"
echo "Log files created in logs/ directory"