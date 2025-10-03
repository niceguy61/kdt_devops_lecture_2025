#!/bin/bash

# 복구 검증 스크립트

echo "=== Cluster Recovery Verification ==="

echo "1. Checking cluster info..."
kubectl cluster-info || echo "❌ Cluster info failed"

echo "2. Checking node status..."
kubectl get nodes || echo "❌ Node status check failed"

echo "3. Checking system pods..."
kubectl get pods -n kube-system || echo "❌ System pods check failed"

echo "4. Checking component status..."
kubectl get componentstatuses || echo "❌ Component status check failed"

echo "5. Testing DNS resolution..."
kubectl run test-dns --image=busybox --rm -it --restart=Never -- nslookup kubernetes.default.svc.cluster.local || echo "❌ DNS test failed"

echo "6. Testing pod creation..."
kubectl run test-pod --image=nginx --restart=Never
if kubectl wait --for=condition=Ready pod/test-pod --timeout=60s; then
    echo "✅ Pod creation successful"
    kubectl delete pod test-pod
else
    echo "❌ Pod creation failed"
    kubectl delete pod test-pod --force --grace-period=0 2>/dev/null
fi

echo "7. Testing service connectivity..."
kubectl create deployment test-deploy --image=nginx --replicas=2
kubectl expose deployment test-deploy --port=80 --target-port=80
sleep 10

if kubectl run test-client --image=busybox --rm -it --restart=Never -- wget -qO- http://test-deploy.default.svc.cluster.local; then
    echo "✅ Service connectivity successful"
else
    echo "❌ Service connectivity failed"
fi

kubectl delete deployment test-deploy
kubectl delete service test-deploy

echo "8. Checking ETCD health..."
ETCD_POD=$(kubectl get pods -n kube-system -l component=etcd -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ ! -z "$ETCD_POD" ]; then
    if kubectl exec -n kube-system $ETCD_POD -- \
      etcdctl --endpoints=https://127.0.0.1:2379 \
      --cacert=/etc/kubernetes/pki/etcd/ca.crt \
      --cert=/etc/kubernetes/pki/etcd/server.crt \
      --key=/etc/kubernetes/pki/etcd/server.key \
      endpoint health >/dev/null 2>&1; then
        echo "✅ ETCD health check passed"
    else
        echo "❌ ETCD health check failed"
    fi
else
    echo "❌ ETCD pod not found"
fi

echo "9. Final cluster status summary..."
echo "Nodes:"
kubectl get nodes --no-headers | wc -l | xargs echo "  Total nodes:"
kubectl get nodes --no-headers | grep " Ready " | wc -l | xargs echo "  Ready nodes:"

echo "Pods:"
kubectl get pods --all-namespaces --no-headers | wc -l | xargs echo "  Total pods:"
kubectl get pods --all-namespaces --no-headers | grep " Running " | wc -l | xargs echo "  Running pods:"

echo "=== Recovery Verification Complete ==="