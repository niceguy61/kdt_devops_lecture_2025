# Kubernetes YAML 작성 완벽 가이드

<div align="center">

**📚 초보자를 위한 Kubernetes YAML 작성 가이드**

*모든 리소스 타입별 필수 요소와 예제를 포함한 완벽 가이드*

</div>

---

## 📋 목차

1. [YAML 기본 문법](#yaml-기본-문법)
2. [Kubernetes YAML 공통 구조](#kubernetes-yaml-공통-구조)
3. [Pod](#pod)
4. [Deployment](#deployment)
5. [Service](#service)
6. [ConfigMap & Secret](#configmap--secret)
7. [PersistentVolume & PersistentVolumeClaim](#persistentvolume--persistentvolumeclaim)
8. [Ingress](#ingress)
9. [StatefulSet](#statefulset)
10. [DaemonSet](#daemonset)
11. [Job & CronJob](#job--cronjob)
12. [Namespace](#namespace)
13. [ResourceQuota & LimitRange](#resourcequota--limitrange)
14. [NetworkPolicy](#networkpolicy)
15. [ServiceAccount & RBAC](#serviceaccount--rbac)

---

## 📖 YAML 기본 문법

### YAML이란?
YAML (YAML Ain't Markup Language)은 사람이 읽기 쉬운 데이터 직렬화 형식입니다.

### 기본 규칙
```yaml
# 주석은 # 으로 시작합니다

# 키-값 쌍 (콜론 뒤에 공백 필수)
key: value

# 들여쓰기는 2칸 또는 4칸 (일관성 유지)
parent:
  child: value
  
# 리스트 (하이픈 사용)
items:
  - item1
  - item2
  - item3

# 또는 인라인 형식
items: [item1, item2, item3]

# 여러 줄 문자열
description: |
  첫 번째 줄
  두 번째 줄
  세 번째 줄

# 문자열 (따옴표 선택적)
name: my-app
name: "my-app"
name: 'my-app'

# 숫자
replicas: 3
port: 8080

# 불린
enabled: true
disabled: false
```

### 주의사항
- **들여쓰기**: 탭(Tab) 사용 금지, 스페이스만 사용
- **콜론 뒤 공백**: `key: value` (O), `key:value` (X)
- **대소문자 구분**: Kubernetes는 대소문자를 구분합니다
- **YAML 검증**: [YAML Lint](http://www.yamllint.com/)에서 문법 검증 가능

---

## 🏗️ Kubernetes YAML 공통 구조

모든 Kubernetes 리소스는 다음 4가지 필수 필드를 가집니다:

```yaml
apiVersion: v1              # API 버전
kind: Pod                   # 리소스 종류
metadata:                   # 메타데이터
  name: my-resource        # 리소스 이름 (필수)
  namespace: default       # 네임스페이스 (선택, 기본값: default)
  labels:                  # 라벨 (선택)
    app: myapp
  annotations:             # 어노테이션 (선택)
    description: "설명"
spec:                      # 리소스 사양
  # 리소스별 상세 설정
```

### 필수 필드 설명

#### 1. apiVersion
리소스가 속한 API 그룹과 버전을 지정합니다.

**주요 API 버전:**
- `v1`: 핵심 API (Pod, Service, ConfigMap, Secret 등)
- `apps/v1`: 애플리케이션 관련 (Deployment, StatefulSet, DaemonSet)
- `batch/v1`: 배치 작업 (Job, CronJob)
- `networking.k8s.io/v1`: 네트워킹 (Ingress, NetworkPolicy)
- `rbac.authorization.k8s.io/v1`: RBAC (Role, RoleBinding)

📚 **공식 문서**: [Kubernetes API Reference](https://kubernetes.io/docs/reference/kubernetes-api/)

#### 2. kind
생성할 리소스의 종류를 지정합니다.

**주요 Kind:**
- `Pod`, `Deployment`, `Service`, `ConfigMap`, `Secret`
- `PersistentVolume`, `PersistentVolumeClaim`
- `Ingress`, `StatefulSet`, `DaemonSet`
- `Job`, `CronJob`, `Namespace`

📚 **공식 문서**: [Kubernetes API Concepts](https://kubernetes.io/docs/reference/using-api/api-concepts/)

#### 3. metadata
리소스를 식별하고 관리하기 위한 정보입니다.

**필수 필드:**
- `name`: 리소스 이름 (네임스페이스 내에서 유일해야 함)

**선택 필드:**
- `namespace`: 리소스가 속할 네임스페이스
- `labels`: 키-값 쌍으로 리소스를 그룹화
- `annotations`: 추가 메타데이터 (도구나 라이브러리가 사용)

📚 **공식 문서**: [Object Names and IDs](https://kubernetes.io/docs/concepts/overview/working-with-objects/names/)

#### 4. spec
리소스의 원하는 상태를 정의합니다. 리소스 종류마다 다릅니다.

📚 **공식 문서**: 각 리소스별 문서 참조

---

## 🎯 Pod

Pod는 Kubernetes에서 배포 가능한 가장 작은 단위입니다.

### 기본 구조
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
  labels:
    app: myapp
spec:
  containers:
  - name: my-container
    image: nginx:1.21
```

### 필수 필드

#### spec.containers (필수)
Pod 내에서 실행될 컨테이너 목록입니다.

**필수 하위 필드:**
- `name`: 컨테이너 이름
- `image`: 컨테이너 이미지

```yaml
spec:
  containers:
  - name: nginx          # 컨테이너 이름 (필수)
    image: nginx:1.21    # 이미지 (필수)
```

### 주요 선택 필드

#### 1. ports
컨테이너가 노출할 포트를 정의합니다.

```yaml
spec:
  containers:
  - name: web
    image: nginx:1.21
    ports:
    - containerPort: 80        # 컨테이너 포트 (필수)
      name: http               # 포트 이름 (선택)
      protocol: TCP            # 프로토콜 (선택, 기본값: TCP)
```

#### 2. env
환경 변수를 설정합니다.

```yaml
spec:
  containers:
  - name: app
    image: myapp:1.0
    env:
    - name: DATABASE_URL              # 환경 변수 이름
      value: "postgres://db:5432"     # 직접 값 지정
    - name: API_KEY
      valueFrom:                      # 다른 소스에서 값 가져오기
        secretKeyRef:
          name: api-secret
          key: key
```

#### 3. resources
CPU와 메모리 리소스를 제한합니다.

```yaml
spec:
  containers:
  - name: app
    image: myapp:1.0
    resources:
      requests:          # 최소 보장 리소스
        cpu: 100m        # 0.1 CPU 코어
        memory: 128Mi    # 128 메가바이트
      limits:            # 최대 사용 리소스
        cpu: 500m        # 0.5 CPU 코어
        memory: 512Mi    # 512 메가바이트
```

**리소스 단위:**
- CPU: `m` (밀리코어), `1000m = 1 CPU 코어`
- Memory: `Ki`, `Mi`, `Gi` (1024 기반)

#### 4. volumeMounts
볼륨을 컨테이너에 마운트합니다.

```yaml
spec:
  containers:
  - name: app
    image: myapp:1.0
    volumeMounts:
    - name: data-volume      # 볼륨 이름 (spec.volumes와 일치)
      mountPath: /data       # 컨테이너 내 마운트 경로
      readOnly: false        # 읽기 전용 여부 (선택)
  volumes:
  - name: data-volume
    emptyDir: {}
```

#### 5. livenessProbe & readinessProbe
컨테이너 상태를 확인합니다.

```yaml
spec:
  containers:
  - name: app
    image: myapp:1.0
    livenessProbe:           # 컨테이너 생존 확인
      httpGet:
        path: /healthz
        port: 8080
      initialDelaySeconds: 30
      periodSeconds: 10
    readinessProbe:          # 트래픽 수신 준비 확인
      httpGet:
        path: /ready
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 5
```

### 완전한 예제

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-app
  namespace: production
  labels:
    app: web
    tier: frontend
    version: v1.0
  annotations:
    description: "웹 애플리케이션 Pod"
spec:
  # 컨테이너 정의
  containers:
  - name: nginx
    image: nginx:1.21
    ports:
    - containerPort: 80
      name: http
    env:
    - name: ENVIRONMENT
      value: "production"
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 500m
        memory: 512Mi
    volumeMounts:
    - name: config
      mountPath: /etc/nginx/conf.d
    - name: data
      mountPath: /usr/share/nginx/html
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 30
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 5
  
  # 볼륨 정의
  volumes:
  - name: config
    configMap:
      name: nginx-config
  - name: data
    emptyDir: {}
  
  # 재시작 정책
  restartPolicy: Always
  
  # 노드 선택
  nodeSelector:
    disktype: ssd
```

📚 **공식 문서**: 
- [Pod 개념](https://kubernetes.io/docs/concepts/workloads/pods/)
- [Pod API Reference](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/)

---

## 🚀 Deployment

Deployment는 Pod의 복제본을 관리하고 롤링 업데이트를 제공합니다.

### 기본 구조
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: my-container
        image: nginx:1.21
```

### 필수 필드

#### 1. spec.replicas (선택, 기본값: 1)
실행할 Pod의 개수를 지정합니다.

```yaml
spec:
  replicas: 3    # 3개의 Pod 복제본 실행
```

#### 2. spec.selector (필수)
Deployment가 관리할 Pod를 선택하는 라벨 셀렉터입니다.

```yaml
spec:
  selector:
    matchLabels:
      app: myapp           # template.metadata.labels와 일치해야 함
```

**중요**: `selector.matchLabels`는 `template.metadata.labels`와 반드시 일치해야 합니다!

#### 3. spec.template (필수)
생성할 Pod의 템플릿입니다. Pod 스펙과 동일한 구조입니다.

```yaml
spec:
  template:
    metadata:
      labels:
        app: myapp         # selector.matchLabels와 일치
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
```

### 주요 선택 필드

#### 1. strategy
업데이트 전략을 정의합니다.

```yaml
spec:
  strategy:
    type: RollingUpdate           # 또는 Recreate
    rollingUpdate:
      maxUnavailable: 1           # 동시에 중단 가능한 최대 Pod 수
      maxSurge: 1                 # 동시에 생성 가능한 추가 Pod 수
```

**전략 타입:**
- `RollingUpdate` (기본값): 점진적으로 Pod를 교체
- `Recreate`: 모든 기존 Pod를 삭제 후 새 Pod 생성

#### 2. revisionHistoryLimit
유지할 이전 ReplicaSet 개수를 지정합니다.

```yaml
spec:
  revisionHistoryLimit: 10    # 기본값: 10
```

### 완전한 예제

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
  namespace: production
  labels:
    app: web
    tier: frontend
  annotations:
    description: "웹 애플리케이션 Deployment"
spec:
  # 복제본 수
  replicas: 3
  
  # Pod 선택자 (필수)
  selector:
    matchLabels:
      app: web
      tier: frontend
  
  # 업데이트 전략
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  
  # 리비전 히스토리
  revisionHistoryLimit: 10
  
  # Pod 템플릿 (필수)
  template:
    metadata:
      labels:
        app: web
        tier: frontend
        version: v1.0
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
          name: http
        env:
        - name: ENVIRONMENT
          value: "production"
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
```

### 주요 kubectl 명령어

```bash
# Deployment 생성
kubectl apply -f deployment.yaml

# Deployment 조회
kubectl get deployment
kubectl get deploy

# 상세 정보 확인
kubectl describe deployment web-deployment

# Pod 상태 확인
kubectl get pods -l app=web

# 이미지 업데이트 (롤링 업데이트)
kubectl set image deployment/web-deployment nginx=nginx:1.22

# 롤아웃 상태 확인
kubectl rollout status deployment/web-deployment

# 롤아웃 히스토리 확인
kubectl rollout history deployment/web-deployment

# 이전 버전으로 롤백
kubectl rollout undo deployment/web-deployment

# 특정 리비전으로 롤백
kubectl rollout undo deployment/web-deployment --to-revision=2

# 스케일링
kubectl scale deployment/web-deployment --replicas=5

# Deployment 삭제
kubectl delete deployment web-deployment
```

📚 **공식 문서**: 
- [Deployment 개념](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Deployment API Reference](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/deployment-v1/)

---

## 🌐 Service

Service는 Pod 집합에 대한 네트워크 접근을 제공합니다.

### 기본 구조
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
```

### 필수 필드

#### 1. spec.selector (선택, 하지만 대부분 필수)
Service가 트래픽을 전달할 Pod를 선택합니다.

```yaml
spec:
  selector:
    app: myapp    # 이 라벨을 가진 Pod로 트래픽 전달
```

#### 2. spec.ports (필수)
Service가 노출할 포트를 정의합니다.

```yaml
spec:
  ports:
  - port: 80              # Service 포트 (필수)
    targetPort: 8080      # Pod 포트 (선택, 기본값: port와 동일)
    protocol: TCP         # 프로토콜 (선택, 기본값: TCP)
    name: http            # 포트 이름 (선택)
```

### Service 타입

#### 1. ClusterIP (기본값)
클러스터 내부에서만 접근 가능한 가상 IP를 할당합니다.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  type: ClusterIP         # 기본값이므로 생략 가능
  selector:
    app: backend
  ports:
  - port: 80
    targetPort: 8080
```

**사용 사례**: 내부 마이크로서비스 간 통신

#### 2. NodePort
각 노드의 특정 포트로 Service를 노출합니다.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  type: NodePort
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30080       # 30000-32767 범위 (선택)
```

**접근 방법**: `<NodeIP>:<NodePort>`

**사용 사례**: 개발/테스트 환경에서 외부 접근

#### 3. LoadBalancer
클라우드 제공자의 로드밸런서를 생성합니다.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080
```

**사용 사례**: 프로덕션 환경에서 외부 트래픽 수신

#### 4. ExternalName
외부 DNS 이름으로 Service를 매핑합니다.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-db
spec:
  type: ExternalName
  externalName: database.example.com
```

**사용 사례**: 외부 서비스를 클러스터 내부 이름으로 참조

### 완전한 예제

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: production
  labels:
    app: web
    tier: frontend
  annotations:
    description: "웹 애플리케이션 Service"
spec:
  # Service 타입
  type: LoadBalancer
  
  # Pod 선택자
  selector:
    app: web
    tier: frontend
  
  # 포트 정의
  ports:
  - name: http
    port: 80              # Service 포트
    targetPort: 80        # Pod 포트
    protocol: TCP
  - name: https
    port: 443
    targetPort: 443
    protocol: TCP
  
  # 세션 어피니티 (선택)
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800
```

### 주요 kubectl 명령어

```bash
# Service 생성
kubectl apply -f service.yaml

# Service 조회
kubectl get service
kubectl get svc

# 상세 정보 확인
kubectl describe service web-service

# Endpoint 확인 (Service가 연결된 Pod IP)
kubectl get endpoints web-service

# Service 삭제
kubectl delete service web-service

# Service를 통한 Pod 접근 테스트
kubectl run test-pod --image=busybox -it --rm -- wget -O- http://web-service
```

📚 **공식 문서**: 
- [Service 개념](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Service API Reference](https://kubernetes.io/docs/reference/kubernetes-api/service-resources/service-v1/)

---

## 🔧 ConfigMap & Secret

ConfigMap과 Secret은 설정 데이터를 Pod와 분리하여 관리합니다.

### ConfigMap

#### 기본 구조
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
data:
  key1: value1
  key2: value2
```

#### 필수 필드

**data (필수)**
키-값 쌍으로 설정 데이터를 저장합니다.

```yaml
data:
  database.url: "postgres://db:5432"
  log.level: "info"
  config.json: |
    {
      "server": {
        "port": 8080
      }
    }
```

#### 완전한 예제

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: production
  labels:
    app: myapp
data:
  # 단순 키-값
  DATABASE_URL: "postgres://db:5432/mydb"
  LOG_LEVEL: "info"
  MAX_CONNECTIONS: "100"
  
  # 파일 형태의 설정
  nginx.conf: |
    server {
      listen 80;
      server_name example.com;
      
      location / {
        proxy_pass http://backend:8080;
      }
    }
  
  app-config.json: |
    {
      "server": {
        "port": 8080,
        "host": "0.0.0.0"
      },
      "database": {
        "host": "db",
        "port": 5432
      }
    }
```

#### Pod에서 사용하기

**환경 변수로 사용:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: myapp:1.0
    env:
    # 개별 키 사용
    - name: DATABASE_URL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: DATABASE_URL
    
    # 모든 키를 환경 변수로
    envFrom:
    - configMapRef:
        name: app-config
```

**볼륨으로 마운트:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: myapp:1.0
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: app-config
```

### Secret

#### 기본 구조
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
type: Opaque
data:
  username: YWRtaW4=        # base64 인코딩된 값
  password: cGFzc3dvcmQ=
```

#### 필수 필드

**type (필수)**
Secret의 타입을 지정합니다.

**주요 타입:**
- `Opaque`: 일반 Secret (기본값)
- `kubernetes.io/service-account-token`: ServiceAccount 토큰
- `kubernetes.io/dockerconfigjson`: Docker 레지스트리 인증
- `kubernetes.io/tls`: TLS 인증서

**data 또는 stringData (필수)**
- `data`: base64 인코딩된 값
- `stringData`: 평문 값 (자동으로 base64 인코딩됨)

```yaml
# data 사용 (base64 인코딩 필요)
data:
  username: YWRtaW4=        # "admin"을 base64 인코딩
  password: cGFzc3dvcmQ=    # "password"를 base64 인코딩

# stringData 사용 (평문, 더 편리함)
stringData:
  username: admin
  password: password
```

#### 완전한 예제

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
  namespace: production
  labels:
    app: myapp
type: Opaque
stringData:
  # 데이터베이스 인증 정보
  db-username: admin
  db-password: super-secret-password
  
  # API 키
  api-key: "1234567890abcdef"
  
  # 인증서 (여러 줄)
  tls.crt: |
    -----BEGIN CERTIFICATE-----
    MIIDXTCCAkWgAwIBAgIJAKL0UG+mRKe...
    -----END CERTIFICATE-----
  
  tls.key: |
    -----BEGIN PRIVATE KEY-----
    MIIEvQIBADANBgkqhkiG9w0BAQEFAAS...
    -----END PRIVATE KEY-----
```

#### Docker 레지스트리 Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: docker-registry-secret
type: kubernetes.io/dockerconfigjson
stringData:
  .dockerconfigjson: |
    {
      "auths": {
        "https://index.docker.io/v1/": {
          "username": "myusername",
          "password": "mypassword",
          "email": "myemail@example.com",
          "auth": "bXl1c2VybmFtZTpteXBhc3N3b3Jk"
        }
      }
    }
```

또는 kubectl 명령어로 생성:
```bash
kubectl create secret docker-registry docker-registry-secret \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=myusername \
  --docker-password=mypassword \
  --docker-email=myemail@example.com
```

#### Pod에서 사용하기

**환경 변수로 사용:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: myapp:1.0
    env:
    - name: DB_USERNAME
      valueFrom:
        secretKeyRef:
          name: app-secret
          key: db-username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: app-secret
          key: db-password
```

**볼륨으로 마운트:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: myapp:1.0
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: app-secret
```

**이미지 Pull Secret:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: private-registry.com/myapp:1.0
  imagePullSecrets:
  - name: docker-registry-secret
```

### 주요 kubectl 명령어

```bash
# ConfigMap 생성
kubectl create configmap app-config --from-literal=key1=value1
kubectl create configmap app-config --from-file=config.json
kubectl apply -f configmap.yaml

# Secret 생성
kubectl create secret generic app-secret --from-literal=password=secret
kubectl create secret generic app-secret --from-file=./secret.txt
kubectl apply -f secret.yaml

# 조회
kubectl get configmap
kubectl get secret

# 상세 정보 (Secret은 값이 숨겨짐)
kubectl describe configmap app-config
kubectl describe secret app-secret

# Secret 값 확인 (base64 디코딩)
kubectl get secret app-secret -o jsonpath='{.data.password}' | base64 -d

# 삭제
kubectl delete configmap app-config
kubectl delete secret app-secret
```

📚 **공식 문서**: 
- [ConfigMap](https://kubernetes.io/docs/concepts/configuration/configmap/)
- [Secret](https://kubernetes.io/docs/concepts/configuration/secret/)

---

## 💾 PersistentVolume & PersistentVolumeClaim

PersistentVolume(PV)은 클러스터의 스토리지 리소스이고, PersistentVolumeClaim(PVC)은 사용자의 스토리지 요청입니다.

### PersistentVolume (PV)

#### 기본 구조
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  hostPath:
    path: /data
```

#### 필수 필드

**1. spec.capacity (필수)**
스토리지 용량을 지정합니다.

```yaml
spec:
  capacity:
    storage: 10Gi    # 10 기가바이트
```

**2. spec.accessModes (필수)**
볼륨 접근 모드를 지정합니다.

```yaml
spec:
  accessModes:
  - ReadWriteOnce    # RWO: 단일 노드에서 읽기/쓰기
  # - ReadOnlyMany   # ROX: 여러 노드에서 읽기 전용
  # - ReadWriteMany  # RWX: 여러 노드에서 읽기/쓰기
```

**접근 모드:**
- `ReadWriteOnce` (RWO): 단일 노드에서 읽기/쓰기
- `ReadOnlyMany` (ROX): 여러 노드에서 읽기 전용
- `ReadWriteMany` (RWX): 여러 노드에서 읽기/쓰기

**3. 스토리지 백엔드 (필수 중 하나)**
실제 스토리지를 지정합니다.

```yaml
# 로컬 호스트 경로 (개발용)
spec:
  hostPath:
    path: /data

# NFS
spec:
  nfs:
    server: nfs-server.example.com
    path: /exported/path

# AWS EBS
spec:
  awsElasticBlockStore:
    volumeID: vol-0123456789abcdef
    fsType: ext4

# GCE Persistent Disk
spec:
  gcePersistentDisk:
    pdName: my-disk
    fsType: ext4
```

#### 주요 선택 필드

**1. persistentVolumeReclaimPolicy**
PVC 삭제 시 PV 처리 방법을 지정합니다.

```yaml
spec:
  persistentVolumeReclaimPolicy: Retain    # 또는 Delete, Recycle
```

**정책:**
- `Retain`: PV 유지 (수동 정리 필요)
- `Delete`: PV 자동 삭제
- `Recycle`: 데이터 삭제 후 재사용 (deprecated)

**2. storageClassName**
StorageClass를 지정합니다.

```yaml
spec:
  storageClassName: fast-ssd
```

#### 완전한 예제

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
  labels:
    type: local
spec:
  # 용량
  capacity:
    storage: 20Gi
  
  # 접근 모드
  accessModes:
  - ReadWriteOnce
  
  # 회수 정책
  persistentVolumeReclaimPolicy: Retain
  
  # StorageClass
  storageClassName: manual
  
  # 스토리지 백엔드 (hostPath - 개발용)
  hostPath:
    path: /mnt/data/mysql
```

### PersistentVolumeClaim (PVC)

#### 기본 구조
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: standard
```

#### 필수 필드

**1. spec.accessModes (필수)**
요청하는 접근 모드입니다.

```yaml
spec:
  accessModes:
  - ReadWriteOnce
```

**2. spec.resources.requests (필수)**
요청하는 스토리지 용량입니다.

```yaml
spec:
  resources:
    requests:
      storage: 10Gi
```

#### 완전한 예제

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
  namespace: production
  labels:
    app: mysql
spec:
  # 접근 모드
  accessModes:
  - ReadWriteOnce
  
  # 요청 리소스
  resources:
    requests:
      storage: 20Gi
  
  # StorageClass
  storageClassName: manual
  
  # 선택자 (특정 PV 선택)
  selector:
    matchLabels:
      type: local
```

#### Pod에서 사용하기

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mysql-pod
spec:
  containers:
  - name: mysql
    image: mysql:8.0
    env:
    - name: MYSQL_ROOT_PASSWORD
      value: password
    volumeMounts:
    - name: mysql-storage
      mountPath: /var/lib/mysql
  volumes:
  - name: mysql-storage
    persistentVolumeClaim:
      claimName: mysql-pvc    # PVC 이름
```

### StorageClass (동적 프로비저닝)

StorageClass를 사용하면 PV를 자동으로 생성할 수 있습니다.

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
  iops: "3000"
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
```

**PVC에서 사용:**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dynamic-pvc
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: fast-ssd    # StorageClass 지정
  resources:
    requests:
      storage: 10Gi
```

### 주요 kubectl 명령어

```bash
# PV 생성
kubectl apply -f pv.yaml

# PVC 생성
kubectl apply -f pvc.yaml

# 조회
kubectl get pv
kubectl get pvc

# 상세 정보
kubectl describe pv mysql-pv
kubectl describe pvc mysql-pvc

# PVC 상태 확인
kubectl get pvc mysql-pvc -o jsonpath='{.status.phase}'

# StorageClass 조회
kubectl get storageclass
kubectl get sc

# 삭제
kubectl delete pvc mysql-pvc
kubectl delete pv mysql-pv
```

📚 **공식 문서**: 
- [PersistentVolume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [StorageClass](https://kubernetes.io/docs/concepts/storage/storage-classes/)

---

## 🌍 Ingress

Ingress는 클러스터 외부에서 내부 Service로의 HTTP/HTTPS 라우팅을 관리합니다.

### 기본 구조
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-service
            port:
              number: 80
```

### 필수 필드

**spec.rules (필수)**
라우팅 규칙을 정의합니다.

```yaml
spec:
  rules:
  - host: example.com              # 호스트 (선택)
    http:
      paths:
      - path: /                    # 경로 (필수)
        pathType: Prefix           # 경로 타입 (필수)
        backend:                   # 백엔드 Service (필수)
          service:
            name: my-service
            port:
              number: 80
```

**pathType 옵션:**
- `Prefix`: 경로 접두사 매칭 (예: `/app`은 `/app`, `/app/page` 모두 매칭)
- `Exact`: 정확한 경로 매칭 (예: `/app`만 매칭)
- `ImplementationSpecific`: Ingress Controller에 따라 다름

### 주요 선택 필드

#### 1. TLS 설정
HTTPS를 위한 TLS 인증서를 설정합니다.

```yaml
spec:
  tls:
  - hosts:
    - example.com
    secretName: tls-secret    # TLS Secret 이름
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-service
            port:
              number: 80
```

**TLS Secret 생성:**
```bash
kubectl create secret tls tls-secret \
  --cert=path/to/cert.crt \
  --key=path/to/cert.key
```

#### 2. 기본 백엔드
매칭되지 않는 요청을 처리할 기본 백엔드를 설정합니다.

```yaml
spec:
  defaultBackend:
    service:
      name: default-service
      port:
        number: 80
```

#### 3. Annotations
Ingress Controller별 추가 설정을 지정합니다.

```yaml
metadata:
  annotations:
    # Nginx Ingress Controller
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    
    # Cert-Manager (자동 TLS 인증서)
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
```

### 완전한 예제

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  namespace: production
  labels:
    app: web
  annotations:
    # Nginx Ingress Controller 설정
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    
    # 속도 제한
    nginx.ingress.kubernetes.io/limit-rps: "100"
    
    # Cert-Manager (Let's Encrypt)
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  # Ingress Class (Kubernetes 1.18+)
  ingressClassName: nginx
  
  # TLS 설정
  tls:
  - hosts:
    - example.com
    - www.example.com
    secretName: example-tls
  
  # 라우팅 규칙
  rules:
  # 메인 도메인
  - host: example.com
    http:
      paths:
      # 프론트엔드
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
      
      # API
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 8080
      
      # 관리자 페이지
      - path: /admin
        pathType: Prefix
        backend:
          service:
            name: admin-service
            port:
              number: 3000
  
  # www 서브도메인
  - host: www.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
```

### 경로 기반 라우팅 예제

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: path-based-ingress
spec:
  rules:
  - host: myapp.com
    http:
      paths:
      - path: /app1
        pathType: Prefix
        backend:
          service:
            name: app1-service
            port:
              number: 80
      - path: /app2
        pathType: Prefix
        backend:
          service:
            name: app2-service
            port:
              number: 80
```

### 호스트 기반 라우팅 예제

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: host-based-ingress
spec:
  rules:
  - host: app1.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app1-service
            port:
              number: 80
  - host: app2.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app2-service
            port:
              number: 80
```

### 주요 kubectl 명령어

```bash
# Ingress 생성
kubectl apply -f ingress.yaml

# Ingress 조회
kubectl get ingress
kubectl get ing

# 상세 정보
kubectl describe ingress web-ingress

# Ingress 주소 확인
kubectl get ingress web-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Ingress Controller 설치 (Nginx)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# Ingress 삭제
kubectl delete ingress web-ingress
```

📚 **공식 문서**: 
- [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [Ingress Controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)

---

## 📊 StatefulSet

StatefulSet은 상태를 가진 애플리케이션을 관리합니다. 각 Pod에 고유한 식별자와 안정적인 네트워크 ID를 제공합니다.

### 기본 구조
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: my-statefulset
spec:
  serviceName: my-service
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: my-container
        image: nginx:1.21
```

### 필수 필드

#### 1. spec.serviceName (필수)
StatefulSet과 연결된 Headless Service 이름입니다.

```yaml
spec:
  serviceName: mysql-headless    # Headless Service 이름
```

**Headless Service 예제:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-headless
spec:
  clusterIP: None              # Headless Service
  selector:
    app: mysql
  ports:
  - port: 3306
```

#### 2. spec.selector (필수)
관리할 Pod를 선택하는 라벨 셀렉터입니다.

```yaml
spec:
  selector:
    matchLabels:
      app: mysql
```

#### 3. spec.template (필수)
Pod 템플릿입니다. Deployment와 동일합니다.

```yaml
spec:
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
```

### 주요 선택 필드

#### 1. volumeClaimTemplates
각 Pod에 대한 PVC를 자동으로 생성합니다.

```yaml
spec:
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
```

#### 2. podManagementPolicy
Pod 생성/삭제 순서를 지정합니다.

```yaml
spec:
  podManagementPolicy: OrderedReady    # 또는 Parallel
```

**정책:**
- `OrderedReady` (기본값): 순차적으로 생성/삭제
- `Parallel`: 병렬로 생성/삭제

#### 3. updateStrategy
업데이트 전략을 지정합니다.

```yaml
spec:
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      partition: 0
```

### 완전한 예제 (MySQL 클러스터)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-headless
  labels:
    app: mysql
spec:
  clusterIP: None
  selector:
    app: mysql
  ports:
  - port: 3306
    name: mysql
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
  namespace: production
spec:
  # Headless Service 이름 (필수)
  serviceName: mysql-headless
  
  # 복제본 수
  replicas: 3
  
  # Pod 선택자 (필수)
  selector:
    matchLabels:
      app: mysql
  
  # Pod 관리 정책
  podManagementPolicy: OrderedReady
  
  # 업데이트 전략
  updateStrategy:
    type: RollingUpdate
  
  # Pod 템플릿 (필수)
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        ports:
        - containerPort: 3306
          name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: root-password
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
        resources:
          requests:
            cpu: 500m
            memory: 1Gi
          limits:
            cpu: 1000m
            memory: 2Gi
  
  # 볼륨 클레임 템플릿
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: fast-ssd
      resources:
        requests:
          storage: 20Gi
```

### StatefulSet Pod 이름 규칙

StatefulSet의 Pod는 순서가 있는 이름을 가집니다:
- `<statefulset-name>-0`
- `<statefulset-name>-1`
- `<statefulset-name>-2`

예: `mysql-0`, `mysql-1`, `mysql-2`

### 안정적인 네트워크 ID

각 Pod는 안정적인 DNS 이름을 가집니다:
```
<pod-name>.<service-name>.<namespace>.svc.cluster.local
```

예: `mysql-0.mysql-headless.production.svc.cluster.local`

### 주요 kubectl 명령어

```bash
# StatefulSet 생성
kubectl apply -f statefulset.yaml

# StatefulSet 조회
kubectl get statefulset
kubectl get sts

# Pod 조회 (순서 확인)
kubectl get pods -l app=mysql

# 상세 정보
kubectl describe statefulset mysql

# 스케일링
kubectl scale statefulset mysql --replicas=5

# 특정 Pod 삭제 (자동 재생성됨)
kubectl delete pod mysql-0

# StatefulSet 삭제 (Pod는 유지)
kubectl delete statefulset mysql --cascade=orphan

# StatefulSet과 Pod 모두 삭제
kubectl delete statefulset mysql

# PVC 확인
kubectl get pvc -l app=mysql
```

📚 **공식 문서**: 
- [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
- [StatefulSet API Reference](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/stateful-set-v1/)

---

## 🔄 DaemonSet

DaemonSet은 모든 (또는 특정) 노드에서 Pod의 복사본을 실행합니다.

### 기본 구조
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: my-daemonset
spec:
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: my-container
        image: nginx:1.21
```

### 필수 필드

#### 1. spec.selector (필수)
관리할 Pod를 선택하는 라벨 셀렉터입니다.

```yaml
spec:
  selector:
    matchLabels:
      app: node-exporter
```

#### 2. spec.template (필수)
Pod 템플릿입니다.

```yaml
spec:
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      containers:
      - name: node-exporter
        image: prom/node-exporter:latest
```

### 주요 선택 필드

#### 1. updateStrategy
업데이트 전략을 지정합니다.

```yaml
spec:
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
```

#### 2. nodeSelector
특정 노드에만 Pod를 배포합니다.

```yaml
spec:
  template:
    spec:
      nodeSelector:
        disktype: ssd
```

### 완전한 예제 (로그 수집기)

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
  namespace: kube-system
  labels:
    app: fluentd
spec:
  # Pod 선택자 (필수)
  selector:
    matchLabels:
      app: fluentd
  
  # 업데이트 전략
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  
  # Pod 템플릿 (필수)
  template:
    metadata:
      labels:
        app: fluentd
    spec:
      # 호스트 네트워크 사용
      hostNetwork: true
      
      # 우선순위 클래스
      priorityClassName: system-node-critical
      
      # Tolerations (마스터 노드에도 배포)
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      
      containers:
      - name: fluentd
        image: fluent/fluentd:v1.14
        resources:
          requests:
            cpu: 100m
            memory: 200Mi
          limits:
            cpu: 200m
            memory: 400Mi
        volumeMounts:
        # 호스트의 로그 디렉토리 마운트
        - name: varlog
          mountPath: /var/log
          readOnly: true
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
        - name: config
          mountPath: /fluentd/etc
      
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
      - name: config
        configMap:
          name: fluentd-config
```

### 사용 사례

DaemonSet은 다음과 같은 경우에 사용됩니다:
- **로그 수집**: Fluentd, Filebeat
- **모니터링**: Node Exporter, cAdvisor
- **네트워킹**: Calico, Weave Net
- **스토리지**: Ceph, GlusterFS

### 주요 kubectl 명령어

```bash
# DaemonSet 생성
kubectl apply -f daemonset.yaml

# DaemonSet 조회
kubectl get daemonset
kubectl get ds

# 상세 정보
kubectl describe daemonset fluentd

# Pod 조회 (모든 노드에 배포됨)
kubectl get pods -l app=fluentd -o wide

# DaemonSet 삭제
kubectl delete daemonset fluentd
```

📚 **공식 문서**: 
- [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)
- [DaemonSet API Reference](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/daemon-set-v1/)

---

## ⚙️ Job & CronJob

Job은 일회성 작업을, CronJob은 주기적인 작업을 실행합니다.

### Job

#### 기본 구조
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: my-job
spec:
  template:
    spec:
      containers:
      - name: my-container
        image: busybox
        command: ["echo", "Hello World"]
      restartPolicy: Never
```

#### 필수 필드

**1. spec.template (필수)**
실행할 Pod 템플릿입니다.

```yaml
spec:
  template:
    spec:
      containers:
      - name: job-container
        image: busybox
        command: ["sh", "-c", "echo Hello && sleep 30"]
      restartPolicy: Never    # 또는 OnFailure (필수)
```

**중요**: Job의 `restartPolicy`는 `Never` 또는 `OnFailure`만 가능합니다.

#### 주요 선택 필드

**1. completions**
성공적으로 완료해야 할 Pod 수입니다.

```yaml
spec:
  completions: 5    # 5개의 Pod가 성공적으로 완료되어야 함
```

**2. parallelism**
동시에 실행할 Pod 수입니다.

```yaml
spec:
  parallelism: 2    # 동시에 2개의 Pod 실행
```

**3. backoffLimit**
실패 시 재시도 횟수입니다.

```yaml
spec:
  backoffLimit: 4    # 기본값: 6
```

**4. activeDeadlineSeconds**
Job의 최대 실행 시간입니다.

```yaml
spec:
  activeDeadlineSeconds: 600    # 10분
```

#### 완전한 예제

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: data-processing-job
  namespace: production
  labels:
    app: data-processor
spec:
  # 완료해야 할 Pod 수
  completions: 10
  
  # 동시 실행 Pod 수
  parallelism: 3
  
  # 재시도 횟수
  backoffLimit: 3
  
  # 최대 실행 시간 (1시간)
  activeDeadlineSeconds: 3600
  
  # Pod 템플릿 (필수)
  template:
    metadata:
      labels:
        app: data-processor
    spec:
      containers:
      - name: processor
        image: myapp/data-processor:1.0
        command: ["python", "process.py"]
        env:
        - name: DATA_SOURCE
          value: "s3://my-bucket/data"
        resources:
          requests:
            cpu: 500m
            memory: 1Gi
          limits:
            cpu: 1000m
            memory: 2Gi
      restartPolicy: OnFailure    # 실패 시 재시작
```

### CronJob

#### 기본 구조
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: my-cronjob
spec:
  schedule: "0 0 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: my-container
            image: busybox
            command: ["echo", "Hello World"]
          restartPolicy: Never
```

#### 필수 필드

**1. spec.schedule (필수)**
Cron 형식의 스케줄입니다.

```yaml
spec:
  schedule: "0 0 * * *"    # 매일 자정
```

**Cron 형식:**
```
# ┌───────────── 분 (0 - 59)
# │ ┌───────────── 시 (0 - 23)
# │ │ ┌───────────── 일 (1 - 31)
# │ │ │ ┌───────────── 월 (1 - 12)
# │ │ │ │ ┌───────────── 요일 (0 - 6) (일요일=0)
# │ │ │ │ │
# * * * * *
```

**예제:**
- `0 0 * * *`: 매일 자정
- `*/5 * * * *`: 5분마다
- `0 */2 * * *`: 2시간마다
- `0 9 * * 1-5`: 평일 오전 9시
- `0 0 1 * *`: 매월 1일 자정

**2. spec.jobTemplate (필수)**
생성할 Job의 템플릿입니다.

```yaml
spec:
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: backup-tool:1.0
          restartPolicy: OnFailure
```

#### 주요 선택 필드

**1. concurrencyPolicy**
동시 실행 정책입니다.

```yaml
spec:
  concurrencyPolicy: Forbid    # Allow, Forbid, Replace
```

**정책:**
- `Allow` (기본값): 동시 실행 허용
- `Forbid`: 이전 Job이 완료될 때까지 새 Job 실행 금지
- `Replace`: 이전 Job을 취소하고 새 Job 실행

**2. successfulJobsHistoryLimit & failedJobsHistoryLimit**
유지할 Job 히스토리 개수입니다.

```yaml
spec:
  successfulJobsHistoryLimit: 3    # 기본값: 3
  failedJobsHistoryLimit: 1        # 기본값: 1
```

**3. startingDeadlineSeconds**
스케줄된 시간 이후 Job 시작 가능한 최대 시간입니다.

```yaml
spec:
  startingDeadlineSeconds: 200
```

#### 완전한 예제 (데이터베이스 백업)

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: database-backup
  namespace: production
  labels:
    app: backup
spec:
  # 스케줄: 매일 새벽 2시 (필수)
  schedule: "0 2 * * *"
  
  # 동시 실행 정책
  concurrencyPolicy: Forbid
  
  # 히스토리 유지 개수
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  
  # 시작 데드라인 (10분)
  startingDeadlineSeconds: 600
  
  # Job 템플릿 (필수)
  jobTemplate:
    metadata:
      labels:
        app: backup
    spec:
      # Job 설정
      backoffLimit: 2
      activeDeadlineSeconds: 3600
      
      # Pod 템플릿
      template:
        metadata:
          labels:
            app: backup
        spec:
          containers:
          - name: backup
            image: postgres:14
            command:
            - /bin/sh
            - -c
            - |
              pg_dump -h $DB_HOST -U $DB_USER $DB_NAME | \
              gzip > /backup/backup-$(date +%Y%m%d-%H%M%S).sql.gz
            env:
            - name: DB_HOST
              value: "postgres-service"
            - name: DB_USER
              valueFrom:
                secretKeyRef:
                  name: db-secret
                  key: username
            - name: DB_NAME
              value: "mydb"
            - name: PGPASSWORD
              valueFrom:
                secretKeyRef:
                  name: db-secret
                  key: password
            volumeMounts:
            - name: backup-storage
              mountPath: /backup
          volumes:
          - name: backup-storage
            persistentVolumeClaim:
              claimName: backup-pvc
          restartPolicy: OnFailure
```

### 주요 kubectl 명령어

```bash
# Job 생성
kubectl apply -f job.yaml

# CronJob 생성
kubectl apply -f cronjob.yaml

# 조회
kubectl get job
kubectl get cronjob

# 상세 정보
kubectl describe job my-job
kubectl describe cronjob database-backup

# Job 로그 확인
kubectl logs job/my-job

# CronJob에서 즉시 Job 생성
kubectl create job --from=cronjob/database-backup manual-backup

# CronJob 일시 중지
kubectl patch cronjob database-backup -p '{"spec":{"suspend":true}}'

# CronJob 재개
kubectl patch cronjob database-backup -p '{"spec":{"suspend":false}}'

# 삭제
kubectl delete job my-job
kubectl delete cronjob database-backup
```

📚 **공식 문서**: 
- [Job](https://kubernetes.io/docs/concepts/workloads/controllers/job/)
- [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)

---

## 📦 Namespace

Namespace는 클러스터 내에서 리소스를 논리적으로 분리합니다.

### 기본 구조
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: my-namespace
```

### 완전한 예제

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    environment: production
    team: backend
  annotations:
    description: "프로덕션 환경"
```

### 기본 Namespace

Kubernetes는 기본적으로 다음 Namespace를 제공합니다:
- `default`: 기본 Namespace
- `kube-system`: Kubernetes 시스템 컴포넌트
- `kube-public`: 모든 사용자가 읽을 수 있는 리소스
- `kube-node-lease`: 노드 하트비트 정보

### 주요 kubectl 명령어

```bash
# Namespace 생성
kubectl create namespace production
kubectl apply -f namespace.yaml

# Namespace 조회
kubectl get namespace
kubectl get ns

# 특정 Namespace의 리소스 조회
kubectl get pods -n production
kubectl get all -n production

# 기본 Namespace 변경
kubectl config set-context --current --namespace=production

# Namespace 삭제 (내부 리소스 모두 삭제됨!)
kubectl delete namespace production
```

### Namespace 범위 리소스

**Namespace 범위:**
- Pod, Service, Deployment, ConfigMap, Secret
- PersistentVolumeClaim, Ingress

**클러스터 범위:**
- Node, PersistentVolume, StorageClass
- Namespace, ClusterRole, ClusterRoleBinding

📚 **공식 문서**: 
- [Namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)

---

## 🔐 ServiceAccount & RBAC

ServiceAccount는 Pod가 Kubernetes API에 접근할 때 사용하는 계정이고, RBAC는 권한을 관리합니다.

### ServiceAccount

#### 기본 구조
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-serviceaccount
  namespace: default
```

#### 완전한 예제

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-serviceaccount
  namespace: production
  labels:
    app: myapp
---
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
  namespace: production
spec:
  serviceAccountName: app-serviceaccount    # ServiceAccount 지정
  containers:
  - name: app
    image: myapp:1.0
```

### Role & RoleBinding

Role은 Namespace 범위의 권한을 정의하고, RoleBinding은 사용자/ServiceAccount에 Role을 부여합니다.

#### Role 예제

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: production
rules:
- apiGroups: [""]              # "" = core API group
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get"]
```

**주요 verbs:**
- `get`: 개별 리소스 조회
- `list`: 리소스 목록 조회
- `watch`: 리소스 변경 감시
- `create`: 리소스 생성
- `update`: 리소스 수정
- `patch`: 리소스 부분 수정
- `delete`: 리소스 삭제

#### RoleBinding 예제

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: production
subjects:
- kind: ServiceAccount
  name: app-serviceaccount
  namespace: production
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

### ClusterRole & ClusterRoleBinding

ClusterRole은 클러스터 범위의 권한을 정의합니다.

#### ClusterRole 예제

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-reader
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list", "watch"]
```

#### ClusterRoleBinding 예제

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-nodes
subjects:
- kind: ServiceAccount
  name: app-serviceaccount
  namespace: production
roleRef:
  kind: ClusterRole
  name: node-reader
  apiGroup: rbac.authorization.k8s.io
```

### 완전한 RBAC 예제

```yaml
# ServiceAccount 생성
apiVersion: v1
kind: ServiceAccount
metadata:
  name: deployment-manager
  namespace: production
---
# Role 정의 (Deployment 관리 권한)
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deployment-manager-role
  namespace: production
rules:
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
---
# RoleBinding (ServiceAccount에 Role 부여)
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: deployment-manager-binding
  namespace: production
subjects:
- kind: ServiceAccount
  name: deployment-manager
  namespace: production
roleRef:
  kind: Role
  name: deployment-manager-role
  apiGroup: rbac.authorization.k8s.io
---
# Pod에서 ServiceAccount 사용
apiVersion: v1
kind: Pod
metadata:
  name: manager-pod
  namespace: production
spec:
  serviceAccountName: deployment-manager
  containers:
  - name: kubectl
    image: bitnami/kubectl:latest
    command: ["sleep", "3600"]
```

### 주요 kubectl 명령어

```bash
# ServiceAccount 생성
kubectl create serviceaccount my-sa
kubectl apply -f serviceaccount.yaml

# ServiceAccount 조회
kubectl get serviceaccount
kubectl get sa

# Role 생성
kubectl apply -f role.yaml

# RoleBinding 생성
kubectl apply -f rolebinding.yaml

# 권한 확인
kubectl auth can-i get pods --as=system:serviceaccount:production:app-serviceaccount

# 현재 사용자 권한 확인
kubectl auth can-i create deployments

# 모든 RBAC 리소스 조회
kubectl get role,rolebinding,clusterrole,clusterrolebinding
```

📚 **공식 문서**: 
- [ServiceAccount](https://kubernetes.io/docs/concepts/security/service-accounts/)
- [RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)

---

## 📚 추가 학습 자료

### 공식 문서
- [Kubernetes 공식 문서](https://kubernetes.io/docs/home/)
- [Kubernetes API Reference](https://kubernetes.io/docs/reference/kubernetes-api/)
- [kubectl 치트시트](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

### YAML 검증 도구
- [YAML Lint](http://www.yamllint.com/) - YAML 문법 검증
- [Kubeval](https://kubeval.com/) - Kubernetes YAML 검증
- [kube-score](https://github.com/zegl/kube-score) - YAML 베스트 프랙티스 검사

### 학습 플랫폼
- [Kubernetes by Example](https://kubernetesbyexample.com/)
- [Play with Kubernetes](https://labs.play-with-k8s.com/)
- [Katacoda Kubernetes](https://www.katacoda.com/courses/kubernetes)

---

## 💡 베스트 프랙티스

### 1. 라벨 사용
모든 리소스에 의미 있는 라벨을 추가하세요.

```yaml
metadata:
  labels:
    app: myapp
    tier: frontend
    environment: production
    version: v1.0
```

### 2. 리소스 제한
모든 컨테이너에 리소스 requests와 limits를 설정하세요.

```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

### 3. 헬스체크
livenessProbe와 readinessProbe를 설정하세요.

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
```

### 4. 네임스페이스 사용
환경별로 네임스페이스를 분리하세요.

```yaml
metadata:
  namespace: production
```

### 5. Secret 사용
민감한 정보는 Secret으로 관리하세요.

```yaml
env:
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: password
```

---

<div align="center">

**📚 완벽한 YAML 작성** • **🔧 실무 적용** • **🚀 Kubernetes 마스터**

*이 가이드로 Kubernetes YAML 작성을 완벽하게 마스터하세요!*

</div>
