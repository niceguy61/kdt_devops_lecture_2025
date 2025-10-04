# Week 3 Day 3 Hands-on 1: 고급 네트워킹 & 스토리지 기능

<div align="center">

**🔧 Network Policy** • **📊 StatefulSet** • **🔄 Dynamic Storage** • **⚖️ Load Balancing**

*Lab 1을 기반으로 고급 기능 추가 및 실무 최적화*

</div>

---

## 🕘 실습 정보
**시간**: 14:30-16:00 (90분)  
**목표**: Lab 1 기반 고급 네트워킹 및 스토리지 기능 구현  
**방식**: Lab 1 확장 + 고급 기능 추가

## 🎯 실습 목표

### 📚 학습 목표
- **Network Policy**: 마이크로세그멘테이션으로 보안 강화
- **StatefulSet**: 상태를 가진 애플리케이션 관리
- **Storage Class**: 동적 프로비저닝과 성능 최적화
- **HPA**: 자동 스케일링으로 성능 향상

### 🛠️ 구현 목표
- **보안 강화**: 네트워크 정책으로 트래픽 제어
- **고가용성**: StatefulSet 기반 데이터베이스 클러스터
- **성능 최적화**: 다양한 스토리지 클래스 활용
- **자동화**: HPA와 VPA로 리소스 자동 관리

---

## 🔐 Step 1: Network Policy 보안 강화 (25분)

### Step 1-1: 기본 네트워크 정책 적용 (15분)

**목표**: 데이터베이스 접근을 백엔드에서만 허용

**데이터베이스 보안 정책 생성**:

#### 데이터베이스 보안 정책 파일 생성 : postgres-security-policy.yaml
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: postgres-security-policy
  namespace: day3-lab
spec:
  podSelector:
    matchLabels:
      app: postgres
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 5432
  egress:
  - {}  # 모든 아웃바운드 허용 (DNS 등)
```

```bash
# 정책 적용
kubectl apply -f postgres-security-policy.yaml
```

**검증**:
```bash
# 정책 확인
kubectl get networkpolicy postgres-security-policy

# 백엔드에서 데이터베이스 접근 테스트 (성공해야 함)
kubectl exec -it deployment/backend -- nc -zv postgres-service 5432

# 프론트엔드에서 데이터베이스 접근 테스트 (실패해야 함)
kubectl exec -it deployment/frontend -- nc -zv postgres-service 5432 || echo "✅ 정책 적용 성공 - 접근 차단됨"
```

### Step 1-2: 계층별 네트워크 분리 (10분)

**프론트엔드 정책: frontend-policy.yaml**:

```yaml
# 프론트엔드 보안 정책 파일 생성
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-policy
  namespace: day3-lab
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from: []  # Ingress Controller에서만 접근
    ports:
    - protocol: TCP
      port: 80
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 3000
  - to: # DNS 접근 허용
    - namespaceSelector: {}
    ports:
    - protocol: UDP
      port: 53
```
```bash
# 정책 적용
kubectl apply -f frontend-policy.yaml
```

---

## 📊 Step 2: StatefulSet으로 데이터베이스 클러스터 구성 (30분)

### Step 2-1: 기존 Deployment를 StatefulSet으로 전환 (20분)

**기존 PostgreSQL 삭제**:
```bash
kubectl delete deployment postgres
kubectl delete svc postgres-service
```

**PostgreSQL StatefulSet 생성: postgres-statefulset.yaml**:

```yaml
# PostgreSQL StatefulSet 파일 생성
apiVersion: v1
kind: Service
metadata:
  name: postgres-headless
  namespace: day3-lab
spec:
  clusterIP: None
  selector:
    app: postgres-cluster
  ports:
  - port: 5432
    targetPort: 5432
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
  namespace: day3-lab
spec:
  selector:
    app: postgres-cluster
  ports:
  - port: 5432
    targetPort: 5432
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres-cluster
  namespace: day3-lab
spec:
  serviceName: postgres-headless
  replicas: 3
  selector:
    matchLabels:
      app: postgres-cluster
  template:
    metadata:
      labels:
        app: postgres-cluster
    spec:
      containers:
      - name: postgres
        image: postgres:13
        env:
        - name: POSTGRES_DB
          value: shopdb
        - name: POSTGRES_USER
          value: shopuser
        - name: POSTGRES_PASSWORD
          value: shoppass
        - name: POSTGRES_REPLICATION_MODE
          value: master
        - name: POSTGRES_REPLICATION_USER
          value: replicator
        - name: POSTGRES_REPLICATION_PASSWORD
          value: replicatorpass
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
        resources:
          requests:
            cpu: 200m
            memory: 512Mi
          limits:
            cpu: 500m
            memory: 1Gi
  volumeClaimTemplates:
  - metadata:
      name: postgres-data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: standard
      resources:
        requests:
          storage: 2Gi
```
```bash
# StatefulSet 배포
kubectl apply -f postgres-statefulset.yaml
```

### Step 2-2: StatefulSet 동작 확인 (10분)

```bash
# StatefulSet 상태 확인
kubectl get statefulset postgres-cluster
kubectl get pods -l app=postgres-cluster

# 각 Pod의 개별 PVC 확인
kubectl get pvc

# Headless Service DNS 테스트
kubectl run dns-test --image=busybox:1.35 --rm -it --restart=Never -- nslookup postgres-headless.day3-lab.svc.cluster.local

# 개별 Pod DNS 확인
kubectl run dns-test --image=busybox:1.35 --rm -it --restart=Never -- nslookup postgres-cluster-0.postgres-headless.day3-lab.svc.cluster.local
```

---

## 🔄 Step 3: 동적 스토리지 클래스 활용 (20분)

### Step 3-1: 다양한 StorageClass 생성 (10분)

**고성능 SSD StorageClass: storage-classes.yaml**:

```yaml
# StorageClass 파일 생성
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: kubernetes.io/no-provisioner  # 실제 환경에서는 클라우드 프로바이더 사용
parameters:
  type: "ssd"
  iops: "3000"
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: slow-hdd
provisioner: kubernetes.io/no-provisioner
parameters:
  type: "hdd"
reclaimPolicy: Retain
allowVolumeExpansion: true
volumeBindingMode: Immediate
```
```bash
# StorageClass 적용
kubectl apply -f storage-classes.yaml
```

### Step 3-2: 캐시용 고성능 스토리지 추가 (10분)

**Redis 캐시 서버 배포: redis-cache.yaml**:

```yaml
# Redis 캐시 서버 파일 생성
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-cache
  namespace: day3-lab
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis-cache
  template:
    metadata:
      labels:
        app: redis-cache
    spec:
      containers:
      - name: redis
        image: redis:7-alpine
        ports:
        - containerPort: 6379
        volumeMounts:
        - name: redis-data
          mountPath: /data
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
      volumes:
      - name: redis-data
        persistentVolumeClaim:
          claimName: redis-cache-pvc
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: redis-cache-pvc
  namespace: day3-lab
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: standard
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Service
metadata:
  name: redis-service
  namespace: day3-lab
spec:
  selector:
    app: redis-cache
  ports:
  - port: 6379
    targetPort: 6379
```
```bash
# Redis 배포
kubectl apply -f redis-cache.yaml
```

---

## ⚖️ Step 4: 자동 스케일링 구성 (15분)

### Step 4-1: HPA (Horizontal Pod Autoscaler) 설정 (10분)

```bash
# 프론트엔드 HPA 생성
kubectl autoscale deployment frontend --cpu-percent=70 --min=2 --max=10 --namespace=day3-lab

# 백엔드 HPA 생성
kubectl autoscale deployment backend --cpu-percent=60 --min=2 --max=8 --namespace=day3-lab

# HPA 상태 확인
kubectl get hpa -n day3-lab
```

**부하 테스트**:
```bash
# 부하 생성 Pod 실행
kubectl run load-generator --image=busybox:1.35 --rm -it --restart=Never --namespace=day3-lab -- /bin/sh

# Pod 내부에서 실행
while true; do wget -q -O- http://frontend-service/; done
```

### Step 4-2: VPA (Vertical Pod Autoscaler) 설정 (5분)

** redis-vpa.yaml **
```yaml
# VPA 설정 파일 생성 (VPA가 설치된 경우)
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: redis-vpa
  namespace: day3-lab
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: redis-cache
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: redis
      maxAllowed:
        cpu: 500m
        memory: 512Mi
      minAllowed:
        cpu: 50m
        memory: 64Mi
```
```bash
# VPA 적용
kubectl apply -f redis-vpa.yaml
```

---

## 🔍 고급 모니터링 및 디버깅

### 네트워크 정책 디버깅:
```bash
# 네트워크 정책 확인
kubectl describe networkpolicy -n day3-lab

# Pod 간 연결 테스트
kubectl exec -it deployment/backend -- nc -zv postgres-service 5432
kubectl exec -it deployment/frontend -- nc -zv backend-service 3000
```

### StatefulSet 상태 확인:
```bash
# StatefulSet 상세 정보
kubectl describe statefulset postgres-cluster -n day3-lab

# 각 Pod의 PVC 매핑 확인
kubectl get pods -l app=postgres-cluster -o custom-columns=NAME:.metadata.name,PVC:.spec.volumes[0].persistentVolumeClaim.claimName
```

### 스토리지 성능 테스트:

** storage-test.yaml **
```yaml
# 스토리지 성능 테스트 Pod 파일 생성
apiVersion: v1
kind: Pod
metadata:
  name: storage-test
  namespace: day3-lab
spec:
  containers:
  - name: test
    image: busybox:1.35
    command: ["/bin/sh"]
    args: ["-c", "while true; do sleep 3600; done"]
    volumeMounts:
    - name: test-volume
      mountPath: /test
  volumes:
  - name: test-volume
    persistentVolumeClaim:
      claimName: storage-test-pvc
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: storage-test-pvc
  namespace: day3-lab
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: fast-ssd
  resources:
    requests:
      storage: 1Gi
```
```bash
# 테스트 Pod 배포
kubectl apply -f storage-test.yaml

# 성능 테스트 실행
kubectl exec -it storage-test -n day3-lab -- dd if=/dev/zero of=/test/testfile bs=1M count=100
```

---

## ✅ 실습 체크포인트

### 🔐 보안 강화 확인
- [ ] **Network Policy**: 데이터베이스 접근이 백엔드에서만 가능
- [ ] **계층 분리**: 각 계층 간 필요한 통신만 허용
- [ ] **접근 제어**: 불필요한 네트워크 트래픽 차단

### 📊 고가용성 확인
- [ ] **StatefulSet**: 3개 PostgreSQL Pod 순차적 생성
- [ ] **개별 스토리지**: 각 Pod마다 독립적인 PVC
- [ ] **Headless Service**: DNS 기반 개별 Pod 접근

### 🔄 동적 관리 확인
- [ ] **StorageClass**: 다양한 성능의 스토리지 클래스
- [ ] **HPA**: CPU 사용률 기반 자동 스케일링
- [ ] **VPA**: 리소스 사용량 기반 자동 조정

---

## 🚀 추가 도전 과제

### 1. 멀티 마스터 데이터베이스
```bash
# PostgreSQL 스트리밍 복제 설정
# Primary-Replica 구조로 읽기 성능 향상
```

### 2. 서비스 메시 통합
```bash
# Istio 사이드카 주입으로 고급 트래픽 관리
kubectl label namespace day3-lab istio-injection=enabled
```

### 3. 백업 자동화

** postgres-backup-cronjob.yaml **
```yaml
# CronJob으로 정기 데이터베이스 백업 파일 생성
apiVersion: batch/v1
kind: CronJob
metadata:
  name: postgres-backup
  namespace: day3-lab
spec:
  schedule: "0 2 * * *"  # 매일 새벽 2시
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: postgres:13
            command: ["/bin/bash"]
            args: ["-c", "pg_dump -h postgres-service -U shopuser shopdb > /backup/backup-$(date +%Y%m%d).sql"]
            env:
            - name: PGPASSWORD
              value: shoppass
            volumeMounts:
            - name: backup-storage
              mountPath: /backup
          volumes:
          - name: backup-storage
            persistentVolumeClaim:
              claimName: backup-pvc
          restartPolicy: OnFailure
```
```bash
# 백업 CronJob 배포
kubectl apply -f postgres-backup-cronjob.yaml
```

---

## 🧹 실습 정리

```bash
# 추가된 리소스 정리
kubectl delete networkpolicy --all -n day3-lab
kubectl delete statefulset postgres-cluster -n day3-lab
kubectl delete svc postgres-headless -n day3-lab
kubectl delete deployment redis-cache -n day3-lab
kubectl delete pvc redis-cache-pvc storage-test-pvc -n day3-lab
kubectl delete hpa --all -n day3-lab
kubectl delete vpa --all -n day3-lab 2>/dev/null || true
kubectl delete storageclass fast-ssd slow-hdd 2>/dev/null || true

# 전체 환경 정리 (Lab 1과 동일)
kubectl delete namespace day3-lab
```

---

## 💡 실습 회고

### 🤝 팀 회고 (10분)
1. **고급 기능 체험**: Network Policy와 StatefulSet의 실무 활용도는?
2. **성능 차이**: 다양한 스토리지 클래스의 성능 차이를 체감했나요?
3. **자동화 효과**: HPA/VPA의 자동 스케일링 효과는 어떠했나요?
4. **실무 적용**: 실제 프로덕션 환경에서 어떤 부분을 우선 적용하시겠어요?

### 📊 학습 성과
- **보안 강화**: 네트워크 레벨에서의 마이크로세그멘테이션
- **상태 관리**: StatefulSet을 통한 안정적인 데이터베이스 운영
- **성능 최적화**: 워크로드별 최적화된 스토리지 선택
- **운영 자동화**: 자동 스케일링으로 효율적인 리소스 관리

---

<div align="center">

**🔐 보안 강화** • **📊 고가용성** • **🔄 자동화** • **⚡ 성능 최적화**

*Lab 1 + Hands-on 1 = 완전한 프로덕션급 Kubernetes 애플리케이션*

</div>
