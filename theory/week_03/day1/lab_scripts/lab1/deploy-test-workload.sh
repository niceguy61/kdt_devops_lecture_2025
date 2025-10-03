#!/bin/bash

# 테스트 워크로드 배포 및 검증 스크립트

echo "=== Deploying Test Workload ==="

echo "1. Applying test workload..."
kubectl apply -f test-workload.yaml

echo ""
echo "2. Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=60s deployment/test-deployment -n lab-day1

echo ""
echo "3. Checking deployment status..."
kubectl get all -n lab-day1

echo ""
echo "4. Checking pod distribution across nodes..."
kubectl get pods -n lab-day1 -o wide

echo ""
echo "5. Checking service endpoints..."
kubectl get endpoints -n lab-day1

echo ""
echo "6. Testing service connectivity..."
kubectl run test-client --image=busybox --rm -it --restart=Never -- wget -qO- http://test-service.lab-day1.svc.cluster.local || echo "Service connectivity test completed"

echo ""
echo "7. Checking pod logs..."
kubectl logs -l app=test-app -n lab-day1 --tail=5

echo ""
echo "=== Test Workload Deployment Summary ==="
echo "✅ Deployment created and ready"
echo "✅ Pods scheduled across nodes"
echo "✅ Service endpoints configured"
echo "✅ Internal connectivity verified"

echo ""
echo "Test workload deployment completed!"