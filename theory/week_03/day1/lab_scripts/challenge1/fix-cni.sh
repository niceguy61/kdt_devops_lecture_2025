#!/bin/bash

# CNI 수정 스크립트

echo "=== Fixing CNI Configuration ==="

echo "1. Backing up CNI configuration..."
sudo cp -r /etc/cni/net.d /etc/cni/net.d.backup

echo "2. Fixing API Server port in CNI kubeconfig..."
if [ -f "/etc/cni/net.d/calico-kubeconfig" ]; then
    sudo sed -i 's/6444/6443/' /etc/cni/net.d/calico-kubeconfig
    echo "Fixed API Server port in CNI kubeconfig"
else
    echo "CNI kubeconfig not found"
fi

echo "3. Creating valid ServiceAccount token for CNI..."
kubectl create token calico-node -n kube-system --duration=8760h > /tmp/calico-token 2>/dev/null || echo "Cannot create token"

if [ -f "/tmp/calico-token" ]; then
    echo "4. Updating CNI kubeconfig with valid token..."
    CALICO_TOKEN=$(cat /tmp/calico-token)
    sudo sed -i "s/token: invalid-token/token: $CALICO_TOKEN/" /etc/cni/net.d/calico-kubeconfig
    echo "Updated CNI token"
    rm /tmp/calico-token
else
    echo "Could not create valid token"
fi

echo "5. Restarting CNI pods..."
kubectl delete pods -n kube-system -l k8s-app=calico-node 2>/dev/null || echo "No Calico pods to restart"

echo "6. Waiting for CNI pods to restart..."
sleep 30

echo "7. Testing network connectivity..."
kubectl run test-network --image=busybox --rm -it --restart=Never -- /bin/sh -c "nslookup kubernetes.default.svc.cluster.local" || echo "Network test failed"

echo "8. Checking pod status after CNI fix..."
kubectl get pods --all-namespaces | grep -E "(Pending|ContainerCreating)" || echo "No pending pods"

echo "CNI fix completed!"