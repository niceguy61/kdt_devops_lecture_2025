#!/bin/bash

# ETCD 탐험 스크립트

echo "=== ETCD Exploration ==="

# ETCD Pod 이름 확인
ETCD_POD=$(kubectl get pods -n kube-system -l component=etcd -o jsonpath='{.items[0].metadata.name}')
echo "ETCD Pod: $ETCD_POD"

echo "1. Checking ETCD Health..."

# ETCD 클러스터 상태 확인
kubectl exec -it -n kube-system $ETCD_POD -- sh -c "
export ETCDCTL_API=3
export ETCDCTL_ENDPOINTS=https://127.0.0.1:2379
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key

echo 'ETCD endpoint health:'
etcdctl endpoint health

echo 'ETCD endpoint status:'
etcdctl endpoint status --write-out=table
"

echo "2. Exploring Kubernetes Data Structure..."

# 모든 키 조회 (처음 20개만)
kubectl exec -it -n kube-system $ETCD_POD -- sh -c "
export ETCDCTL_API=3
export ETCDCTL_ENDPOINTS=https://127.0.0.1:2379
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key

echo 'Top 20 keys in ETCD:'
etcdctl get / --prefix --keys-only | head -20
"

echo "3. Examining Specific Resources..."

# 네임스페이스 정보 조회
kubectl exec -it -n kube-system $ETCD_POD -- sh -c "
export ETCDCTL_API=3
export ETCDCTL_ENDPOINTS=https://127.0.0.1:2379
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key

echo 'Default namespace data:'
etcdctl get /registry/namespaces/default

echo 'System pods keys:'
etcdctl get /registry/pods/kube-system/ --prefix --keys-only | head -10

echo 'Services keys:'
etcdctl get /registry/services/specs/default/kubernetes
"

echo "ETCD exploration completed!"