#!/bin/bash

# API Server 진단 스크립트

echo "=== API Server Diagnosis ==="

echo "1. Checking API Server container status..."
sudo crictl ps -a | grep apiserver || echo "No apiserver container found"
docker ps -a | grep apiserver || echo "No apiserver container found in docker"

echo "2. Checking API Server logs..."
APISERVER_CONTAINER=$(sudo crictl ps -a | grep apiserver | awk '{print $1}' | head -1)
if [ ! -z "$APISERVER_CONTAINER" ]; then
    echo "API Server container logs:"
    sudo crictl logs $APISERVER_CONTAINER | tail -20
else
    echo "No API Server container found"
fi

echo "3. Checking kubelet logs..."
sudo journalctl -u kubelet --no-pager -l | tail -20

echo "4. Checking port usage..."
sudo netstat -tlnp | grep -E "(6443|6444|2379|2380)"

echo "5. Testing API Server connectivity..."
curl -k https://localhost:6443/api/v1 2>&1 || echo "API Server not accessible on port 6443"
curl -k https://localhost:6444/api/v1 2>&1 || echo "API Server not accessible on port 6444"

echo "API Server diagnosis completed!"