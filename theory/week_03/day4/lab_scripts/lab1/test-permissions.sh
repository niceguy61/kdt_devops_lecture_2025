#!/bin/bash

# Week 3 Day 4 Lab 1: 권한 테스트
# 사용법: ./test-permissions.sh

set -e

echo "=== 권한 테스트 시작 ==="
echo ""

# 개발자 권한 테스트
echo "📋 개발자 권한 테스트 (development 네임스페이스)"
echo "----------------------------------------"
echo -n "Pod 생성 권한: "
kubectl auth can-i create pods --as=system:serviceaccount:development:developer-sa -n development
echo -n "Deployment 삭제 권한: "
kubectl auth can-i delete deployments --as=system:serviceaccount:development:developer-sa -n development
echo -n "Secret 생성 권한: "
kubectl auth can-i create secrets --as=system:serviceaccount:development:developer-sa -n development
echo -n "Production 접근: "
kubectl auth can-i get pods --as=system:serviceaccount:development:developer-sa -n production
echo ""

# 운영자 권한 테스트
echo "📋 운영자 권한 테스트"
echo "----------------------------------------"
echo -n "모든 네임스페이스 Pod 조회: "
kubectl auth can-i get pods --as=system:serviceaccount:production:operator-sa --all-namespaces
echo -n "Production Pod 삭제: "
kubectl auth can-i delete pods --as=system:serviceaccount:production:operator-sa -n production
echo -n "노드 조회: "
kubectl auth can-i get nodes --as=system:serviceaccount:production:operator-sa
echo -n "ClusterRole 생성: "
kubectl auth can-i create clusterroles --as=system:serviceaccount:production:operator-sa
echo ""

# 상세 권한 목록
echo "📋 개발자 상세 권한 목록"
echo "----------------------------------------"
kubectl auth can-i --list --as=system:serviceaccount:development:developer-sa -n development | head -20
echo ""

echo "=== 권한 테스트 완료 ==="
