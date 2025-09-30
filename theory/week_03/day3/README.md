# Week 3 Day 3: 스토리지와 상태 관리

<div align="center">

**💾 Volume 타입** • **📦 PV/PVC** • **🔄 StatefulSet**

*CNCF 기초 과정 - Volume부터 StatefulSet까지, Kubernetes 스토리지 마스터*

</div>

---

## 🕘 세션 정보
**시간**: 09:00-11:50 (이론 2.5시간) + 13:00-14:30 (실습 1.5시간)
**목표**: Volume + PV/PVC + StatefulSet + 상태 관리
**방식**: 협업 중심 학습 + 레벨별 차별화

## 🎯 세션 목표
### 📚 학습 목표
- **이해 목표**: Volume 타입, PV/PVC, StatefulSet, Health Probes 완전 이해
- **적용 목표**: 영속성 스토리지를 사용한 상태 관리 애플리케이션 배포
- **협업 목표**: 페어 프로그래밍으로 데이터베이스 클러스터 구성 경험

---

## 📖 Session 1: Volume 타입과 영속성 (emptyDir, hostPath, PV/PVC) (50분)

### 🔍 개념 1: Volume 기본 개념 (15분)
> **정의**: Pod 내 컨테이너들이 데이터를 공유하고 영속적으로 저장할 수 있는 메커니즘

**Volume이 필요한 이유**:
- **데이터 영속성**: 컨테이너 재시작 시에도 데이터 보존
- **컨테이너 간 공유**: 같은 Pod 내 컨테이너들 간 데이터 공유
- **외부 스토리지 연결**: 클라우드 스토리지, NFS 등 외부 저장소 활용

### 🔍 개념 2: Volume 타입별 특징 (15분)
> **정의**: 다양한 스토리지 백엔드와 사용 목적에 따른 Volume 타입 분류

**주요 Volume 타입**:
- **emptyDir**: Pod 생명주기와 동일한 임시 스토리지
- **hostPath**: 호스트 노드의 파일시스템 마운트
- **persistentVolumeClaim**: PVC를 통한 영속 스토리지
- **configMap/secret**: 설정 데이터를 파일로 마운트

### 🔍 개념 3: PV/PVC 아키텍처 (15분)
> **정의**: 스토리지 리소스와 사용자 요청을 분리하는 Kubernetes 스토리지 추상화

**PV/PVC 관계**:
- **PersistentVolume (PV)**: 실제 스토리지 리소스
- **PersistentVolumeClaim (PVC)**: 스토리지 요청
- **StorageClass**: 동적 프로비저닝을 위한 스토리지 클래스

### 💭 함께 생각해보기 (5분)
**🤝 페어 토론**:
1. "데이터베이스 Pod에는 어떤 Volume 타입이 적합할까요?"
2. "PV와 PVC를 분리하는 이유는 무엇일까요?"

---

## 📖 Session 2: StatefulSet vs Deployment + 상태 관리 (50분)

### 🔍 개념 1: StatefulSet 기본 개념 (15분)
> **정의**: 상태를 가진 애플리케이션을 위한 워크로드 컨트롤러

**StatefulSet 특징**:
- **안정적인 네트워크 ID**: 예측 가능한 Pod 이름과 DNS
- **안정적인 스토리지**: 각 Pod마다 고유한 PVC
- **순서 보장**: Pod 생성/삭제 시 순서 보장
- **점진적 배포**: 하나씩 순차적으로 업데이트

### 🔍 개념 2: Deployment vs StatefulSet (15분)
> **정의**: 상태 없는 애플리케이션과 상태 있는 애플리케이션의 차이점

**비교표**:
| 구분 | Deployment | StatefulSet |
|------|------------|-------------|
| **Pod 이름** | 랜덤 해시 | 순차적 인덱스 |
| **네트워크 ID** | 불안정 | 안정적 |
| **스토리지** | 공유 또는 없음 | 개별 PVC |
| **배포 순서** | 병렬 | 순차적 |
| **사용 사례** | 웹서버, API | 데이터베이스, 큐 |

### 🔍 개념 3: Headless Service (15분)
> **정의**: StatefulSet과 함께 사용되는 클러스터 IP가 없는 Service

**Headless Service 특징**:
- **직접 Pod 접근**: 각 Pod에 직접 DNS 레코드 생성
- **서비스 디스커버리**: Pod별 고유한 DNS 이름 제공
- **로드밸런싱 없음**: 클라이언트가 직접 Pod 선택

### 💭 함께 생각해보기 (5분)
**🤝 페어 토론**:
1. "MySQL 클러스터에 StatefulSet이 필요한 이유는?"
2. "Headless Service는 언제 사용해야 할까요?"

---

## 📖 Session 3: Health Check (Liveness, Readiness, Startup Probes) (50분)

### 🔍 개념 1: Health Probes 개념 (15분)
> **정의**: 컨테이너의 상태를 확인하고 적절한 조치를 취하는 메커니즘

**Probe 타입별 역할**:
- **Liveness Probe**: 컨테이너가 살아있는지 확인, 실패 시 재시작
- **Readiness Probe**: 트래픽을 받을 준비가 되었는지 확인
- **Startup Probe**: 초기화가 완료되었는지 확인

### 🔍 개념 2: Probe 구성 방법 (15분)
> **정의**: HTTP GET, TCP Socket, Exec Command를 통한 상태 확인 방법

**Probe 설정 옵션**:
- **initialDelaySeconds**: 첫 번째 체크까지 대기 시간
- **periodSeconds**: 체크 간격
- **timeoutSeconds**: 체크 타임아웃
- **failureThreshold**: 실패 임계값

### 🔍 개념 3: 상태 관리 베스트 프랙티스 (15분)
> **정의**: 안정적인 상태 관리를 위한 설계 원칙과 패턴

**베스트 프랙티스**:
- **적절한 Probe 설정**: 애플리케이션 특성에 맞는 체크 방법
- **Graceful Shutdown**: 정상적인 종료 처리
- **데이터 백업**: 정기적인 데이터 백업 전략
- **모니터링**: 상태 변화 추적 및 알림

### 💭 함께 생각해보기 (5분)
**🤝 페어 토론**:
1. "데이터베이스에서 가장 중요한 Probe는 무엇일까요?"
2. "Startup Probe는 언제 사용해야 할까요?"

---

## 🛠️ 실습 (1.5시간)

### 🎯 실습 개요
**목표**: PV/PVC를 사용한 상태 관리 애플리케이션 배포

### 🚀 Lab 1: PV/PVC를 사용한 데이터베이스 배포 (50분)

#### Step 1: PVC 생성 (15분)
```yaml
# mysql-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: hostpath  # Docker Desktop 기본 StorageClass
```

#### Step 2: MySQL Deployment 배포 (20분)
```yaml
# mysql-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "password123"
        - name: MYSQL_DATABASE
          value: "testdb"
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
        livenessProbe:
          exec:
            command:
            - mysqladmin
            - ping
            - -h
            - localhost
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command:
            - mysql
            - -h
            - localhost
            - -u
            - root
            - -ppassword123
            - -e
            - "SELECT 1"
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: mysql-storage
        persistentVolumeClaim:
          claimName: mysql-pvc
```

#### Step 3: 데이터 영속성 테스트 (15분)
```bash
# 1. MySQL 배포 및 확인
kubectl apply -f mysql-pvc.yaml
kubectl apply -f mysql-deployment.yaml
kubectl get pods -l app=mysql

# 2. 데이터 삽입
kubectl exec -it deployment/mysql -- mysql -u root -ppassword123 -e "
CREATE TABLE testdb.users (id INT PRIMARY KEY, name VARCHAR(50));
INSERT INTO testdb.users VALUES (1, 'Alice'), (2, 'Bob');
SELECT * FROM testdb.users;"

# 3. Pod 재시작 후 데이터 확인
kubectl delete pod -l app=mysql
kubectl wait --for=condition=ready pod -l app=mysql
kubectl exec -it deployment/mysql -- mysql -u root -ppassword123 -e "SELECT * FROM testdb.users;"
```

### 🌟 Lab 2: StatefulSet으로 상태 유지 애플리케이션 구성 (50분)

#### Step 1: Headless Service 생성 (10분)
```yaml
# redis-headless-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: redis-headless
spec:
  clusterIP: None
  selector:
    app: redis
  ports:
  - port: 6379
    targetPort: 6379
```

#### Step 2: Redis StatefulSet 배포 (25분)
```yaml
# redis-statefulset.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: redis
spec:
  serviceName: redis-headless
  replicas: 3
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:7-alpine
        ports:
        - containerPort: 6379
        volumeMounts:
        - name: redis-data
          mountPath: /data
        livenessProbe:
          exec:
            command:
            - redis-cli
            - ping
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command:
            - redis-cli
            - ping
          initialDelaySeconds: 5
          periodSeconds: 5
  volumeClaimTemplates:
  - metadata:
      name: redis-data
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 500Mi
      storageClassName: hostpath
```

#### Step 3: StatefulSet 특성 확인 (15분)
```bash
# 1. StatefulSet 배포 및 확인
kubectl apply -f redis-headless-service.yaml
kubectl apply -f redis-statefulset.yaml

# 2. Pod 이름과 순서 확인
kubectl get pods -l app=redis -w

# 3. 각 Pod의 고유한 PVC 확인
kubectl get pvc

# 4. DNS 레코드 확인
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup redis-0.redis-headless.default.svc.cluster.local

# 5. 데이터 영속성 테스트
kubectl exec redis-0 -- redis-cli set key1 "value1"
kubectl exec redis-1 -- redis-cli set key2 "value2"
kubectl delete pod redis-0
kubectl wait --for=condition=ready pod redis-0
kubectl exec redis-0 -- redis-cli get key1
```

---

## 📝 일일 마무리

### ✅ 오늘의 성과
- [ ] Volume 타입별 특징과 사용법 완전 이해
- [ ] PV/PVC를 사용한 영속 스토리지 구현
- [ ] StatefulSet으로 상태 관리 애플리케이션 배포
- [ ] Health Probes로 애플리케이션 안정성 확보
- [ ] 데이터 영속성 테스트 완료

### 🎯 내일 준비사항
- **예습**: GitOps 개념과 ArgoCD의 장점 생각해보기
- **복습**: kubectl을 이용한 PVC, StatefulSet 관리 명령어
- **환경**: 오늘 생성한 스토리지 리소스 정리

---

<div align="center">

**🎉 Day 3 완료!** 

*Kubernetes 스토리지와 상태 관리를 완전히 마스터했습니다*

</div>