#!/bin/bash

# Lab 1 전체 실행 스크립트
cd "$(dirname "$0")"

echo "🚀 Lab 1: 기본 워크로드 관리 시작"

./create-basic-pod.sh
echo "⏳ 3초 대기..."
sleep 3

./create-replicaset.sh
echo "⏳ 3초 대기..."
sleep 3

./create-deployment.sh
echo "⏳ 3초 대기..."
sleep 3

./test-workloads.sh

echo "✅ Lab 1 완료!"
