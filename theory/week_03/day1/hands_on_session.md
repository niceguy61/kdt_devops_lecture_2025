# 🚀 Hands-On Session: Kubernetes 클러스터 탐험 (30분)

## 🎯 세션 목표
**함께 따라하며 Kubernetes 클러스터의 내부 구조를 직접 확인해보세요!**

---

## 📋 준비 사항

### 1. 환경 확인
```bash
# Docker 실행 상태 확인
docker --version
docker ps

# kubectl 설치 확인
kubectl version --client
```

### 2. 작업 디렉토리 생성
```bash
mkdir -p ~/k8s-hands-on
cd ~/k8s-hands-on
```

---

## 🔧 Step 1: 클러스터 생성하기 (5분)

### Kind 클러스터 설정 파일 생성
```bash
cat > kind-config.yaml << 'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: hands-on-cluster
nodes:
- role: control-plane
- role: worker
- role: worker
EOF
```

### 클러스터 생성
```bash
# 클러스터 생성 (2-3분 소요)
kind create cluster --config kind-config.yaml

# 클러스터 상태 확인
kubectl cluster-info
kubectl get nodes
```

**🎉 성공하면 다음과 같이 보입니다:**
```
NAME                         STATUS   ROLES           AGE   VERSION
hands-on-cluster-control-plane   Ready    control-plane   2m    v1.27.3
hands-on-cluster-worker          Ready    <none>          2m    v1.27.3
hands-on-cluster-worker2         Ready    <none>          2m    v1.27.3
```

---

## 🔍 Step 2: 클러스터 내부 들여다보기 (10분)

### 2.1 시스템 Pod 확인
```bash
# 시스템 Pod들 확인
kubectl get pods -n kube-system

# API Server Pod 찾기
kubectl get pods -n kube-system -l component=kube-apiserver
```

**💡 질문**: API Server Pod의 이름은 무엇인가요?

### 2.2 ETCD 데이터 직접 조회
```bash
# ETCD Pod 이름 확인
ETCD_POD=$(kubectl get pods -n kube-system -l component=etcd -o jsonpath='{.items[0].metadata.name}')
echo "ETCD Pod: $ETCD_POD"

# ETCD 내부 데이터 구조 확인
kubectl exec -n kube-system $ETCD_POD -- \
  etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  get / --prefix --keys-only | head -10
```

**🤔 관찰해보세요**: `/registry/` 경로 아래에 어떤 데이터들이 저장되어 있나요?

### 2.3 네트워크 구조 확인
```bash
# Control Plane 노드 내부 접속
docker exec -it hands-on-cluster-control-plane bash

# 내부에서 실행 (컨테이너 안에서)
ss -tlnp | grep -E "(6443|2379|2380)"
exit
```

**📊 결과 해석**: 
- `6443`: API Server 포트
- `2379`: ETCD 클라이언트 포트  
- `2380`: ETCD 피어 포트

---

## 🚀 Step 3: 실제 워크로드 배포해보기 (10분)

### 3.1 네임스페이스 생성
```bash
kubectl create namespace hands-on-demo
```

### 3.2 간단한 웹 애플리케이션 배포
```bash
# Deployment 생성
kubectl create deployment nginx-demo --image=nginx:1.20 --replicas=3 -n hands-on-demo

# Service 생성
kubectl expose deployment nginx-demo --port=80 --target-port=80 --type=ClusterIP -n hands-on-demo
```

### 3.3 배포 결과 확인
```bash
# Pod 상태 확인
kubectl get pods -n hands-on-demo -o wide

# Service 확인
kubectl get svc -n hands-on-demo

# Endpoints 확인
kubectl get endpoints -n hands-on-demo
```

**🎯 관찰 포인트**:
- Pod들이 어떤 노드에 배치되었나요?
- 각 Pod의 IP 주소는 무엇인가요?
- Service의 ClusterIP는 무엇인가요?

### 3.4 서비스 연결 테스트
```bash
# 테스트 Pod 생성하여 서비스 접근
kubectl run test-pod --image=busybox --rm -it --restart=Never -n hands-on-demo -- /bin/sh

# 컨테이너 내부에서 실행
wget -qO- http://nginx-demo.hands-on-demo.svc.cluster.local
exit
```

---

## 🔬 Step 4: ETCD에서 실시간 변경사항 관찰 (5분)

### 4.1 ETCD Watch 설정
```bash
# 새 터미널에서 ETCD 변경사항 모니터링
kubectl exec -n kube-system $ETCD_POD -- \
  etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  watch /registry/pods/hands-on-demo/ --prefix &
```

### 4.2 Pod 생성/삭제하며 변경사항 관찰
```bash
# 다른 터미널에서 Pod 생성
kubectl run watch-test --image=nginx -n hands-on-demo

# Pod 삭제
kubectl delete pod watch-test -n hands-on-demo
```

**👀 실시간 관찰**: ETCD에서 Pod 생성/삭제 이벤트가 실시간으로 보이나요?

---

## 🎯 마무리 및 정리

### 학습 내용 요약
```bash
# 전체 클러스터 상태 한눈에 보기
echo "=== 클러스터 노드 ==="
kubectl get nodes

echo "=== 시스템 컴포넌트 ==="
kubectl get pods -n kube-system -l tier=control-plane

echo "=== 우리가 만든 애플리케이션 ==="
kubectl get all -n hands-on-demo

echo "=== 클러스터 정보 ==="
kubectl cluster-info
```

### 정리 작업
```bash
# 실습 환경 정리
kubectl delete namespace hands-on-demo
kind delete cluster --name hands-on-cluster

# 작업 디렉토리 정리
cd ~
rm -rf ~/k8s-hands-on
```

---

## 🎉 축하합니다!

**여러분이 방금 경험한 것들:**
- ✅ Kubernetes 클러스터 직접 구축
- ✅ 핵심 컴포넌트들의 실제 동작 확인
- ✅ ETCD 데이터 저장소 직접 조회
- ✅ 실제 애플리케이션 배포 및 서비스 생성
- ✅ 실시간 클러스터 상태 변경 모니터링

**🚀 다음 단계**: 이제 더 복잡한 워크로드와 고급 기능들을 탐험할 준비가 되었습니다!

---

## 💡 추가 탐험 과제 (선택사항)

### 도전 과제 1: 로드밸런싱 확인
```bash
# 여러 번 요청하여 로드밸런싱 확인
for i in {1..5}; do
  kubectl run test-$i --image=busybox --rm -it --restart=Never -n hands-on-demo -- wget -qO- http://nginx-demo
done
```

### 도전 과제 2: 스케일링 테스트
```bash
# 레플리카 수 변경
kubectl scale deployment nginx-demo --replicas=5 -n hands-on-demo

# 변경사항 실시간 관찰
kubectl get pods -n hands-on-demo -w
```

### 도전 과제 3: 노드 정보 상세 분석
```bash
# 노드 상세 정보 확인
kubectl describe node hands-on-cluster-worker

# 노드별 Pod 분포 확인
kubectl get pods -o wide --all-namespaces | grep hands-on-cluster-worker
```