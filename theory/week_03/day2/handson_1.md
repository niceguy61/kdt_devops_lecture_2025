# 🚀 Hands-On 1: 대화형 워크로드 관리 (30분)

<div align="center">

**🎮 실시간 상호작용** • **👥 함께 따라하기** • **💡 즉석 문제해결**

*강사와 함께하는 라이브 Kubernetes 워크로드 관리*

</div>

---

## 🎯 Hands-On 목표
**함께 따라하며 Kubernetes 워크로드 관리의 핵심을 실시간으로 체험해보세요!**

### 📚 학습 포커스
- Pod부터 Deployment까지 단계별 생성 과정 실시간 관찰
- 스케줄링과 리소스 관리의 실제 동작 확인
- 문제 상황 발생 시 즉석 해결 과정 체험

---

## 📋 준비 사항

### ✅ 1. 환경 확인
```bash
# 클러스터 상태 확인
kubectl cluster-info
kubectl get nodes

# k9s 실행 (선택사항 - 시각적 모니터링)
k9s
```

### ✅ 2. 작업 공간 준비
```bash
# 실습용 네임스페이스 생성
kubectl create namespace handson-workloads
kubectl config set-context --current --namespace=handson-workloads

echo "✅ 준비 완료: $(kubectl config current-context)"
```

---

## 🎮 Step 1: Pod 생성과 관찰 (8분)

### 👨‍🏫 강사 데모: "Pod의 탄생 과정"

**함께 따라해보세요!**
```bash
# 1. 기본 Pod 생성
kubectl run demo-pod --image=nginx:1.20 --port=80

# 2. 실시간 상태 변화 관찰
kubectl get pods -w
# (Ctrl+C로 중단)
```

**🔍 관찰 포인트**:
- Pod 상태 변화: Pending → ContainerCreating → Running
- 이벤트 발생 과정 실시간 확인

**💬 질문 타임**: 
- "Pod가 Pending 상태에 머무르는 이유는 무엇일까요?"
- "ContainerCreating에서 시간이 오래 걸리는 경우는?"

### 🎯 실시간 문제 해결
```bash
# 의도적으로 문제 상황 만들기
kubectl run broken-pod --image=nginx:nonexistent-tag

# 함께 문제 진단해보기
kubectl describe pod broken-pod
kubectl get events --field-selector involvedObject.name=broken-pod
```

**💡 즉석 해결**:
```bash
# 올바른 이미지로 수정
kubectl delete pod broken-pod
kubectl run fixed-pod --image=nginx:1.20
```

---

## 📦 Step 2: ReplicaSet으로 확장 (8분)

### 👨‍🏫 강사 데모: "복제본 관리의 마법"

**함께 따라해보세요!**
```bash
# 1. ReplicaSet 생성
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: web-rs
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
        ports:
        - containerPort: 80
EOF
```

**🔍 실시간 관찰**:
```bash
# Pod 생성 과정 관찰
kubectl get pods -l app=web -w
# (잠시 후 Ctrl+C)

# ReplicaSet 상태 확인
kubectl get rs web-rs
```

### 🎮 상호작용: "자동 복구 테스트"
```bash
# Pod 하나 삭제해보기
kubectl delete pod $(kubectl get pods -l app=web -o jsonpath='{.items[0].metadata.name}')

# 즉시 새로운 Pod 생성되는 것 확인
kubectl get pods -l app=web
```

**💬 질문 타임**: 
- "Pod를 삭제했는데 왜 다시 생겼을까요?"
- "replicas를 5로 늘리면 어떻게 될까요?"

**🎯 실시간 스케일링**:
```bash
# 실시간으로 스케일링 해보기
kubectl scale rs web-rs --replicas=5
kubectl get pods -l app=web -w
```

---

## 🚀 Step 3: Deployment로 업그레이드 (8분)

### 👨‍🏫 강사 데모: "무중단 배포의 비밀"

**함께 따라해보세요!**
```bash
# 1. Deployment 생성
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deploy
spec:
  replicas: 4
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app: web-deploy
  template:
    metadata:
      labels:
        app: web-deploy
        version: v1
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
        ports:
        - containerPort: 80
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
EOF
```

### 🎮 상호작용: "롤링 업데이트 체험"
```bash
# 현재 상태 확인
kubectl get deployments web-deploy
kubectl get rs -l app=web-deploy

# 이미지 업데이트 시작
kubectl set image deployment/web-deploy nginx=nginx:1.21

# 롤링 업데이트 과정 실시간 관찰
kubectl rollout status deployment/web-deploy
```

**🔍 상세 관찰**:
```bash
# ReplicaSet 변화 확인
kubectl get rs -l app=web-deploy

# Pod 변화 과정 확인
kubectl get pods -l app=web-deploy --show-labels
```

**💬 질문 타임**: 
- "왜 새로운 ReplicaSet이 생겼을까요?"
- "기존 ReplicaSet은 왜 남아있을까요?"

---

## ⚖️ Step 4: 리소스 관리 실습 (6분)

### 👨‍🏫 강사 데모: "리소스 제한의 중요성"

**함께 따라해보세요!**
```bash
# 1. 리소스 제한이 있는 Pod 생성
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: resource-demo
spec:
  containers:
  - name: nginx
    image: nginx:1.20
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 200m
        memory: 256Mi
EOF
```

**🔍 리소스 상태 확인**:
```bash
# Pod 리소스 사용량 확인
kubectl top pod resource-demo

# QoS 클래스 확인
kubectl get pod resource-demo -o jsonpath='{.status.qosClass}'

# 노드 리소스 상황 확인
kubectl describe nodes | grep -A 5 "Allocated resources"
```

### 🎮 상호작용: "리소스 부족 시뮬레이션"
```bash
# 과도한 리소스 요청 Pod 생성
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: resource-hungry
spec:
  containers:
  - name: nginx
    image: nginx:1.20
    resources:
      requests:
        cpu: 10
        memory: 32Gi
EOF
```

**💬 실시간 질문**: 
- "이 Pod가 Pending 상태인 이유는?"
- "실제 운영에서는 어떻게 해결해야 할까요?"

---

## 🎯 마무리 및 정리

### 📊 전체 상태 한눈에 보기
```bash
# 생성된 모든 리소스 확인
kubectl get all

# 라벨별 리소스 확인
kubectl get pods --show-labels

# 이벤트 타임라인 확인
kubectl get events --sort-by=.metadata.creationTimestamp
```

### 💭 함께 생각해보기
**오늘 체험한 내용 정리**:
1. **Pod**: 가장 기본적인 실행 단위
2. **ReplicaSet**: 복제본 수 관리와 자동 복구
3. **Deployment**: 무중단 배포와 버전 관리
4. **리소스 관리**: 안정적인 운영을 위한 필수 요소

**💬 마지막 질문 타임**:
- "가장 인상 깊었던 부분은?"
- "실무에서 어떻게 활용할 수 있을까요?"
- "더 궁금한 점이 있다면?"

### 🧹 정리 작업
```bash
# 실습 리소스 정리
kubectl delete namespace handson-workloads

# 컨텍스트 원복
kubectl config set-context --current --namespace=default

echo "✅ Hands-On 완료!"
```

---

## 💡 오늘의 핵심 인사이트

### 🎯 기술적 인사이트
1. **계층적 구조**: Pod → ReplicaSet → Deployment의 관계
2. **자동 복구**: ReplicaSet의 desired state 유지 메커니즘
3. **무중단 배포**: 롤링 업데이트의 점진적 교체 전략
4. **리소스 관리**: requests/limits의 스케줄링 영향

### 🤝 협업 인사이트
1. **실시간 관찰**: 함께 보면서 배우는 효과
2. **즉석 질문**: 궁금한 점을 바로 해결하는 중요성
3. **문제 해결**: 오류 상황을 함께 진단하고 해결
4. **경험 공유**: 각자의 관점과 경험 교환

### 🚀 실무 연계
1. **점진적 학습**: 기본부터 고급까지 단계적 접근
2. **실시간 모니터링**: 운영 중 상태 변화 관찰의 중요성
3. **문제 대응**: 장애 상황에서의 체계적 접근법
4. **팀워크**: 함께 문제를 해결하는 협업의 힘

---

<div align="center">

**🎮 실시간 체험** • **👥 함께 학습** • **💡 즉석 해결**

*Kubernetes 워크로드 관리를 함께 마스터하다*

</div>
