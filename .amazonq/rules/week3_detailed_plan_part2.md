# Week 3 Kubernetes 상세 계획서 - Part 2

## 📅 Day 3: 네트워킹 & 스토리지

### Session 1: 네트워킹 기초 & CNI (50분)

#### 🎯 필수 요소
- **Kubernetes 네트워킹 모델 4가지 규칙**
- **CNI 플러그인 아키텍처**
- **Pod-to-Pod 통신 메커니즘**
- **Network Namespace 격리**

#### 🔍 핵심 설명
**Kubernetes 네트워킹 4대 원칙**:
```
1. 모든 Pod은 고유한 IP를 가진다
2. 모든 Pod은 NAT 없이 서로 통신할 수 있다
3. 모든 노드는 NAT 없이 모든 Pod과 통신할 수 있다
4. Pod이 보는 자신의 IP = 다른 Pod이 보는 그 Pod의 IP
```

**CNI (Container Network Interface) 동작**:
```
Pod 생성 과정:
1. Kubelet이 Pause 컨테이너 생성
2. CNI 플러그인 호출 (ADD 명령)
3. 네트워크 네임스페이스 생성
4. IP 할당 및 라우팅 설정
5. 애플리케이션 컨테이너 네트워크 공유
```

**주요 CNI 플러그인 비교**:
- **Flannel**: 간단한 오버레이 네트워크
- **Calico**: L3 라우팅 + 네트워크 정책
- **Weave**: 암호화 지원 메시 네트워크

#### 🎉 Fun Facts
- **Pause 컨테이너**: 모든 Pod의 숨은 영웅 (네트워크 네임스페이스 유지)
- **CNI 표준**: CNCF의 첫 번째 졸업 프로젝트
- **IP 할당**: IPAM(IP Address Management) 플러그인이 담당
- **오버레이 vs 언더레이**: 성능 vs 호환성의 트레이드오프

### Session 2: 서비스 & 인그레스 (50분)

#### 🎯 필수 요소
- **Service 타입별 특징과 용도**
- **Endpoint와 EndpointSlice**
- **Ingress Controller 동작 원리**
- **DNS 기반 서비스 디스커버리**

#### 🔍 핵심 설명
**Service 타입별 특징**:
```yaml
# ClusterIP (기본값) - 클러스터 내부 통신
apiVersion: v1
kind: Service
spec:
  type: ClusterIP
  clusterIP: 10.96.0.1  # 가상 IP

# NodePort - 노드 포트로 외부 노출
spec:
  type: NodePort
  ports:
  - port: 80
    nodePort: 30080  # 30000-32767 범위

# LoadBalancer - 클라우드 로드밸런서
spec:
  type: LoadBalancer
  # 클라우드 제공자가 외부 IP 할당
```

**Ingress - L7 로드밸런서**:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /v1
        pathType: Prefix
        backend:
          service:
            name: api-v1
            port:
              number: 80
```

**DNS 서비스 디스커버리**:
```
서비스 DNS 형식:
<service-name>.<namespace>.svc.cluster.local

예시:
- frontend.default.svc.cluster.local
- database.production.svc.cluster.local
```

#### 🎉 Fun Facts
- **가상 IP**: Service IP는 실제로 존재하지 않는 가상 IP
- **iptables 규칙**: 하나의 Service가 수십 개의 iptables 규칙 생성
- **Ingress Controller**: 실제로는 Nginx, HAProxy 등의 리버스 프록시
- **CoreDNS**: Kubernetes 1.13부터 기본 DNS 서버

### Session 3: 스토리지 & 데이터 관리 (50분)

#### 🎯 필수 요소
- **Volume vs PersistentVolume 차이점**
- **Storage Class 동적 프로비저닝**
- **CSI 드라이버 아키텍처**
- **StatefulSet vs Deployment**

#### 🔍 핵심 설명
**스토리지 추상화 계층**:
```
Volume (Pod 수준)
├── emptyDir - 임시 저장소
├── hostPath - 호스트 경로 마운트
└── configMap/secret - 설정 데이터

PersistentVolume (클러스터 수준)
├── 관리자가 미리 생성
├── 클러스터 전체에서 공유
└── Pod 생명주기와 독립적

PersistentVolumeClaim (네임스페이스 수준)
├── 사용자의 스토리지 요청
├── PV와 1:1 바인딩
└── Pod에서 PVC 참조
```

**Storage Class - 동적 프로비저닝**:
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
```

**CSI (Container Storage Interface)**:
- 스토리지 벤더 독립적 인터페이스
- 플러그인 형태로 다양한 스토리지 지원
- 동적 프로비저닝, 스냅샷, 복제 등 고급 기능

#### 🎉 Fun Facts
- **PV vs PVC**: 공급자 vs 소비자 관계
- **Reclaim Policy**: Delete, Retain, Recycle 3가지 정책
- **CSI 혁신**: 스토리지 벤더들이 직접 드라이버 개발
- **StatefulSet**: Pod 이름과 PVC가 1:1 매핑

### 🛠️ Lab 3: 네트워킹 & 서비스 구성 (90분)

#### 기본 Lab 요소
1. **3-Tier 애플리케이션 구축** (40분)
   - Frontend (React) - ClusterIP Service
   - Backend (Node.js) - ClusterIP Service  
   - Database (PostgreSQL) - StatefulSet + PVC

2. **서비스 타입별 테스트** (25분)
   - ClusterIP로 내부 통신 확인
   - NodePort로 외부 접근 테스트
   - LoadBalancer 시뮬레이션

3. **Ingress 설정** (25분)
   - Nginx Ingress Controller 설치
   - 도메인 기반 라우팅 설정
   - TLS 인증서 적용

#### 심화 Lab 요소
1. **네트워크 정책 구현**
   - 마이크로세그멘테이션
   - 네임스페이스 간 통신 제어

2. **고급 스토리지 기능**
   - 볼륨 스냅샷 생성/복원
   - 동적 볼륨 확장

3. **서비스 메시 체험**
   - Istio 기본 설치
   - 트래픽 분할 및 카나리 배포

### 🎮 Challenge 3: 네트워크 장애 해결 (90분)

#### Challenge 시나리오
**시나리오 1: DNS 해결 실패** (25분)
```yaml
# 의도적 오류: 잘못된 서비스 이름
spec:
  containers:
  - name: app
    env:
    - name: DB_HOST
      value: "wrong-database-service"  # 존재하지 않는 서비스
```

**시나리오 2: Ingress 라우팅 오류** (25분)
```yaml
# 의도적 오류: 잘못된 백엔드 서비스
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /api
        backend:
          service:
            name: nonexistent-service  # 존재하지 않는 서비스
```

**시나리오 3: PVC 바인딩 실패** (20분)
```yaml
# 의도적 오류: 불가능한 스토리지 요청
spec:
  resources:
    requests:
      storage: 1000Ti  # 사용 불가능한 용량
```

**시나리오 4: 네트워크 정책 차단** (20분)
```yaml
# 의도적 오류: 모든 트래픽 차단하는 정책
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  # ingress/egress 규칙 없음 = 모든 트래픽 차단
```

---

## 📅 Day 4: 보안 & 클러스터 관리

### Session 1: 보안 기초 & 인증 (50분)

#### 🎯 필수 요소
- **Kubernetes 보안 4C 모델**
- **인증 vs 인가 vs 어드미션**
- **TLS 인증서 체인 구조**
- **ServiceAccount vs User Account**

#### 🔍 핵심 설명
**4C 보안 모델**:
```
Cloud (클라우드) - 인프라 보안
├── 물리적 보안, 네트워크 보안
└── 클라우드 제공자 책임

Cluster (클러스터) - K8s 클러스터 보안
├── API Server 보안, RBAC
└── 네트워크 정책, Pod 보안

Container (컨테이너) - 컨테이너 보안
├── 이미지 스캔, 런타임 보안
└── Security Context

Code (코드) - 애플리케이션 보안
├── 보안 코딩, 의존성 관리
└── 시크릿 관리
```

**인증/인가/어드미션 3단계**:
```
1. Authentication (인증) - "누구인가?"
   ├── X.509 인증서
   ├── Bearer Token
   └── ServiceAccount Token

2. Authorization (인가) - "무엇을 할 수 있는가?"
   ├── RBAC (Role-Based Access Control)
   ├── ABAC (Attribute-Based Access Control)
   └── Webhook

3. Admission Control (어드미션) - "요청이 유효한가?"
   ├── Validating Admission
   ├── Mutating Admission
   └── Custom Admission Controllers
```

#### 🎉 Fun Facts
- **인증서 개수**: 클러스터 내 수십 개의 인증서 사용
- **kubeconfig**: 클러스터 접근의 모든 정보 포함
- **ServiceAccount**: Pod가 API Server와 통신할 때 사용
- **RBAC 기본값**: 모든 것이 거부(deny-by-default)

### Session 2: 권한 관리 & RBAC (50분)

#### 🎯 필수 요소
- **Role vs ClusterRole 차이점**
- **RoleBinding vs ClusterRoleBinding**
- **ServiceAccount 토큰 관리**
- **Network Policy 구현**

#### 🔍 핵심 설명
**RBAC 4가지 리소스**:
```yaml
# Role - 네임스페이스 수준 권한
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "create"]

# ClusterRole - 클러스터 수준 권한
kind: ClusterRole
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list"]

# RoleBinding - Role과 사용자 연결
kind: RoleBinding
subjects:
- kind: User
  name: jane
roleRef:
  kind: Role
  name: pod-reader

# ClusterRoleBinding - ClusterRole과 사용자 연결
kind: ClusterRoleBinding
subjects:
- kind: ServiceAccount
  name: cluster-admin
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: cluster-admin
```

**Network Policy - 네트워크 수준 보안**:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 5432
```

#### 🎉 Fun Facts
- **최소 권한 원칙**: 필요한 최소한의 권한만 부여
- **기본 ClusterRole**: system:admin, system:node 등 내장
- **ServiceAccount 자동 생성**: 각 네임스페이스마다 default SA
- **Network Policy CNI**: Calico, Cilium 등에서만 지원

### Session 3: 클러스터 유지보수 (50분)

#### 🎯 필수 요소
- **클러스터 업그레이드 전략**
- **ETCD 백업/복원 절차**
- **노드 유지보수 방법**
- **클러스터 트러블슈팅**

#### 🔍 핵심 설명
**클러스터 업그레이드 순서**:
```
1. 마스터 노드 업그레이드
   ├── API Server 버전 확인
   ├── kubeadm upgrade plan
   └── kubeadm upgrade apply

2. 워커 노드 업그레이드 (하나씩)
   ├── kubectl drain node1 (Pod 대피)
   ├── kubeadm upgrade node
   ├── kubelet, kubectl 업그레이드
   └── kubectl uncordon node1 (복귀)
```

**ETCD 백업/복원**:
```bash
# 백업
ETCDCTL_API=3 etcdctl snapshot save backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# 복원
ETCDCTL_API=3 etcdctl snapshot restore backup.db \
  --data-dir=/var/lib/etcd-restore
```

#### 🎉 Fun Facts
- **버전 지원**: N, N-1, N-2 총 3개 버전 지원
- **업그레이드 주기**: 약 3개월마다 새 버전 릴리스
- **ETCD 중요성**: 백업 하나로 전체 클러스터 복구 가능
- **드레인 과정**: Graceful shutdown으로 안전한 Pod 이동

### 🛠️ Lab 4: 보안 설정 & 권한 관리 (90분)

#### 기본 Lab 요소
1. **RBAC 구성** (35분)
   - 개발자용 Role 생성
   - 운영자용 ClusterRole 생성
   - 사용자별 권한 테스트

2. **Network Policy 구현** (30분)
   - 네임스페이스 간 격리
   - 애플리케이션 간 통신 제어

3. **Security Context 설정** (25분)
   - 비특권 사용자로 실행
   - 읽기 전용 루트 파일시스템

#### 심화 Lab 요소
1. **Pod Security Standards**
   - Restricted 정책 적용
   - 보안 위반 시나리오 테스트

2. **Admission Controller**
   - OPA Gatekeeper 설치
   - 커스텀 정책 작성

3. **인증서 관리**
   - 사용자 인증서 생성
   - 인증서 갱신 자동화

### 🎮 Challenge 4: 보안 침해 시나리오 (90분)

#### Challenge 시나리오
**시나리오 1: 권한 오류** (25분)
```yaml
# 의도적 오류: 부족한 권한
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get"]  # create 권한 없음
```

**시나리오 2: 인증서 만료** (25분)
```bash
# 의도적 오류: 만료된 인증서 사용
# kubelet.conf에 만료된 클라이언트 인증서
```

**시나리오 3: Network Policy 차단** (20분)
```yaml
# 의도적 오류: 과도한 네트워크 제한
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  # 모든 트래픽 차단
```

**시나리오 4: Secret 노출** (20분)
```yaml
# 의도적 오류: 환경변수로 Secret 노출
env:
- name: DB_PASSWORD
  value: "plaintext-password"  # Secret 사용하지 않음
```