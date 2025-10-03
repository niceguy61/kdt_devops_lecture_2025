#!/bin/bash

# CNI 진단 스크립트

echo "=== CNI Diagnosis ==="

echo "1. Checking CNI configuration files..."
sudo ls -la /etc/cni/net.d/ || echo "CNI configuration directory not found"

echo "2. Checking CNI plugin pods..."
kubectl get pods -n kube-system -l k8s-app=calico-node || echo "Calico pods not found"
kubectl get pods -n kube-system | grep -E "(calico|flannel|weave)" || echo "No CNI pods found"

echo "3. Checking kubelet CNI logs..."
sudo journalctl -u kubelet | grep -i cni | tail -10 || echo "No CNI messages in kubelet logs"

echo "4. Checking pod creation issues..."
kubectl get pods --all-namespaces | grep -E "(Pending|ContainerCreating)" || echo "No pending pods found"

echo "5. Describing problematic pods..."
PENDING_PODS=$(kubectl get pods --all-namespaces --field-selector=status.phase=Pending -o jsonpath='{.items[*].metadata.name}')
if [ ! -z "$PENDING_PODS" ]; then
    for pod in $PENDING_PODS; do
        echo "Describing pod: $pod"
        kubectl describe pod $pod -n kube-system | grep -A5 -B5 -i "network\|cni\|sandbox"
    done
else
    echo "No pending pods to describe"
fi

echo "6. Checking network interfaces..."
ip addr show | grep -E "(cali|flannel|weave|cni)" || echo "No CNI network interfaces found"

echo "7. Checking CNI kubeconfig..."
if [ -f "/etc/cni/net.d/calico-kubeconfig" ]; then
    echo "CNI kubeconfig exists"
    grep "server:" /etc/cni/net.d/calico-kubeconfig
    grep "token:" /etc/cni/net.d/calico-kubeconfig | head -c 50
else
    echo "CNI kubeconfig not found"
fi

echo "CNI diagnosis completed!"