# Lab 1: 워크로드 배포 & 관리 (90분)

<div align="center">

**🚀 단계별 워크로드 배포** • **📊 스케줄링 전략** • **⚖️ 리소스 최적화**

*Pod부터 Deployment까지 체계적 워크로드 관리*

</div>

---

## 🎯 Lab 목표

### 📚 학습 목표
- Pod → ReplicaSet → Deployment 단계별 배포 경험
- 라벨링과 스케줄링 전략 실제 적용
- 리소스 관리와 롤링 업데이트 실습

### 🛠️ 실습 환경
- **클러스터**: Kind 또는 Minikube
- **도구**: kubectl, k9s (선택사항)
- **시간**: 90분 (Phase별 30분씩)

---

## 📋 사전 준비

### ✅ 환경 확인
```bash
# 클러스터 상태 확인
kubectl cluster-info
kubectl get nodes

# 작업 네임스페이스 생성
kubectl create namespace lab2-workloads
kubectl config set-context --current --namespace=lab2-workloads
```

---

## 🚀 Phase 1: 기본 워크로드 생성 (30분)

### Step 1-1: Pod 직접 생성 (10분)

**🚀 자동화 스크립트 사용**
```bash
cd theory/week_03/day2/lab_scripts/lab1
./create-basic-pod.sh
```

**📋 스크립트 내용**: [create-basic-pod.sh](./lab_scripts/lab1/create-basic-pod.sh)

**수동 실행 (학습용)**:
```bash
# 기본 Pod 생성
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: web-pod
  labels:
    app: web
    tier: frontend
spec:
  containers:
  - name: nginx
    image: nginx:1.20
    ports:
    - containerPort: 80
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 200m
        memory: 256Mi
EOF

# Pod 상태 확인
kubectl get pods -o wide
kubectl describe pod web-pod
```

### Step 1-2: ReplicaSet 생성 (10분)

**🚀 자동화 스크립트 사용**
```bash
cd theory/week_03/day2/lab_scripts/lab1
./create-replicaset.sh
```

**📋 스크립트 내용**: [create-replicaset.sh](./lab_scripts/lab1/create-replicaset.sh)

**수동 실행 (학습용)**:
```bash
# ReplicaSet 생성
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: web-replicaset
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
      version: v1
  template:
    metadata:
      labels:
        app: web
        version: v1
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
EOF

# ReplicaSet 동작 확인
kubectl get rs
kubectl get pods --show-labels
```

### Step 1-3: Deployment 생성 (10분)

**🚀 자동화 스크립트 사용**
```bash
cd theory/week_03/day2/lab_scripts/lab1
./create-deployment.sh
```

**📋 스크립트 내용**: [create-deployment.sh](./lab_scripts/lab1/create-deployment.sh)

**수동 실행 (학습용)**:
```bash
# Deployment 생성
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
        version: v2
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
EOF

# Deployment 상태 확인
kubectl get deployments
kubectl get rs
kubectl get pods
```

### 🎯 Phase 1 확인 포인트
- [ ] Pod, ReplicaSet, Deployment의 계층적 관계 이해
- [ ] 라벨과 셀렉터의 동작 방식 확인
- [ ] 리소스 설정과 헬스체크 적용

---

## 📊 Phase 2: 스케줄링 전략 적용 (30분)

### Step 2-1: 노드 라벨링 (10분)

**🚀 자동화 스크립트 사용**
```bash
./lab_scripts/lab1/setup-node-labels.sh
```

**📋 스크립트 내용**: [setup-node-labels.sh](./lab_scripts/lab1/setup-node-labels.sh)

**수동 실행 (학습용)**:
```bash
# 노드에 라벨 추가
kubectl label nodes $(kubectl get nodes -o jsonpath='{.items[0].metadata.name}') storage-type=ssd
kubectl label nodes $(kubectl get nodes -o jsonpath='{.items[0].metadata.name}') cpu-type=high-performance

# 노드 라벨 확인
kubectl get nodes --show-labels
```

### Step 2-2: Node Affinity 적용 (10분)

**🚀 자동화 스크립트 사용**
```bash
./lab_scripts/lab1/deploy-with-affinity.sh
```

**📋 스크립트 내용**: [deploy-with-affinity.sh](./lab_scripts/lab1/deploy-with-affinity.sh)

**수동 실행 (학습용)**:
```bash
# Node Affinity가 적용된 Deployment
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: database-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: database
  template:
    metadata:
      labels:
        app: database
        tier: backend
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: storage-type
                operator: In
                values: [ssd]
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            preference:
              matchExpressions:
              - key: cpu-type
                operator: In
                values: [high-performance]
      containers:
      - name: postgres
        image: postgres:13
        env:
        - name: POSTGRES_DB
          value: testdb
        - name: POSTGRES_USER
          value: admin
        - name: POSTGRES_PASSWORD
          value: password123
        resources:
          requests:
            cpu: 500m
            memory: 1Gi
          limits:
            cpu: 1
            memory: 2Gi
EOF

# 배치 결과 확인
kubectl get pods -o wide
```

### Step 2-3: Pod Anti-Affinity 적용 (10분)

**🚀 자동화 스크립트 사용**
```bash
./lab_scripts/lab1/deploy-with-anti-affinity.sh
```

**📋 스크립트 내용**: [deploy-with-anti-affinity.sh](./lab_scripts/lab1/deploy-with-anti-affinity.sh)

**수동 실행 (학습용)**:
```bash
# Pod Anti-Affinity로 고가용성 구현
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
        tier: backend
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values: [api]
              topologyKey: kubernetes.io/hostname
      containers:
      - name: api-server
        image: httpd:2.4
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 200m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi
EOF

# Anti-Affinity 효과 확인
kubectl get pods -l app=api -o wide
```

### 🎯 Phase 2 확인 포인트
- [ ] Node Affinity로 특정 노드 타입에 배치
- [ ] Pod Anti-Affinity로 고가용성 구현
- [ ] 스케줄링 결과와 의도한 배치 전략 일치 확인

---

## ⚖️ Phase 3: 리소스 관리 & 롤링 업데이트 (30분)

### Step 3-1: 특수 워크로드 배포 (10분)

**🚀 자동화 스크립트 사용**
```bash
./lab_scripts/lab1/deploy-special-workloads.sh
```

**📋 스크립트 내용**: [deploy-special-workloads.sh](./lab_scripts/lab1/deploy-special-workloads.sh)

**수동 실행 (학습용)**:
```bash
# DaemonSet 배포 (로그 수집기)
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: log-collector
spec:
  selector:
    matchLabels:
      name: log-collector
  template:
    metadata:
      labels:
        name: log-collector
    spec:
      containers:
      - name: fluent-bit
        image: fluent/fluent-bit:1.8
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
          limits:
            cpu: 100m
            memory: 128Mi
        volumeMounts:
        - name: varlog
          mountPath: /var/log
          readOnly: true
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
EOF

# Job 배포 (일회성 작업)
kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: data-processor
spec:
  completions: 3
  parallelism: 2
  template:
    spec:
      containers:
      - name: processor
        image: busybox:1.35
        command: ["sh", "-c", "echo 'Processing data...' && sleep 30 && echo 'Done!'"]
        resources:
          requests:
            cpu: 100m
            memory: 64Mi
      restartPolicy: Never
EOF

# 특수 워크로드 상태 확인
kubectl get daemonsets
kubectl get jobs
kubectl get pods
```

### Step 3-2: 리소스 모니터링 (10분)

**🚀 자동화 스크립트 사용**
```bash
./lab_scripts/lab1/monitor-resources.sh
```

**📋 스크립트 내용**: [monitor-resources.sh](./lab_scripts/lab1/monitor-resources.sh)

**수동 실행 (학습용)**:
```bash
# 리소스 사용량 확인
kubectl top nodes
kubectl top pods

# QoS 클래스 확인
kubectl get pods -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass

# 리소스 상세 정보
kubectl describe nodes
```

### Step 3-3: 롤링 업데이트 실습 (10분)

**🚀 자동화 스크립트 사용**
```bash
./lab_scripts/lab1/rolling-update.sh
```

**📋 스크립트 내용**: [rolling-update.sh](./lab_scripts/lab1/rolling-update.sh)

**수동 실행 (학습용)**:
```bash
# 현재 상태 확인
kubectl get deployments web-deployment -o wide

# 이미지 업데이트 (롤링 업데이트 시작)
kubectl set image deployment/web-deployment nginx=nginx:1.22

# 롤링 업데이트 과정 실시간 관찰
kubectl rollout status deployment/web-deployment

# 업데이트 히스토리 확인
kubectl rollout history deployment/web-deployment

# 롤백 테스트
kubectl rollout undo deployment/web-deployment

# 롤백 상태 확인
kubectl rollout status deployment/web-deployment
```

### 🎯 Phase 3 확인 포인트
- [ ] DaemonSet과 Job의 동작 방식 이해
- [ ] 리소스 사용량과 QoS 클래스 확인
- [ ] 롤링 업데이트와 롤백 과정 체험

---

## ✅ Lab 완료 검증

### 🔍 전체 상태 확인
```bash
# 모든 워크로드 상태 확인
kubectl get all

# 라벨별 리소스 확인
kubectl get pods --show-labels
kubectl get pods -l tier=frontend
kubectl get pods -l tier=backend

# 노드별 Pod 분산 확인
kubectl get pods -o wide
```

### 📊 학습 성과 체크리스트
- [ ] **워크로드 계층**: Pod → ReplicaSet → Deployment 관계 이해
- [ ] **라벨링 시스템**: 라벨과 셀렉터 활용 능력
- [ ] **스케줄링 전략**: Affinity/Anti-Affinity 적용 경험
- [ ] **리소스 관리**: Requests/Limits 설정과 QoS 이해
- [ ] **특수 워크로드**: DaemonSet, Job 활용 방법
- [ ] **롤링 업데이트**: 무중단 배포와 롤백 경험

---

## 🧹 정리 작업

### 리소스 정리
```bash
# 네임스페이스 전체 삭제
kubectl delete namespace lab2-workloads

# 노드 라벨 제거
kubectl label nodes --all storage-type-
kubectl label nodes --all cpu-type-

# 컨텍스트 원복
kubectl config set-context --current --namespace=default
```

---

## 💡 실무 인사이트

### 🎯 베스트 프랙티스
1. **라벨 설계**: 체계적인 라벨링 규칙 수립
2. **리소스 설정**: 모니터링 데이터 기반 최적화
3. **스케줄링**: 고가용성과 성능의 균형점 찾기
4. **롤링 업데이트**: 적절한 maxUnavailable/maxSurge 설정

### ⚠️ 주의사항
1. **리소스 과할당**: Requests 합계가 노드 용량 초과 주의
2. **Anti-Affinity 과용**: 너무 엄격한 규칙은 스케줄링 실패 유발
3. **롤링 업데이트**: 헬스체크 없으면 문제 있는 버전 배포 위험
4. **DaemonSet 리소스**: 모든 노드에 배치되므로 리소스 사용량 주의

---

<div align="center">

**🚀 워크로드 배포 마스터** • **📊 스케줄링 전문가** • **⚖️ 리소스 최적화**

*Kubernetes 워크로드 관리의 실전 경험 완성*

</div>
