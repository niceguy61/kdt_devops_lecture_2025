#!/bin/bash

# Lab 1 환경 설정 스크립트

echo "=== Lab 1 Environment Setup ==="

# 작업 디렉토리 생성
mkdir -p ~/k8s-lab1
cd ~/k8s-lab1

# 네임스페이스 생성
kubectl create namespace lab-day1
kubectl config set-context --current --namespace=lab-day1

echo "Environment setup completed!"
echo "Working directory: ~/k8s-lab1"
echo "Namespace: lab-day1"