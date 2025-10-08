# Week 3 Kubernetes 상세 계획서

## 📅 Day 1: Kubernetes 기초 & 클러스터 아키텍처

### Session 1: K8s 아키텍처 & 컴포넌트 (50분)

#### 🎯 필수 요소
- **Cluster Architecture 완전 이해**
- **Master-Worker 노드 역할 분담**
- **Docker vs ContainerD 실무 차이점**
- **Container Runtime 진화 과정**

#### 🔍 핵심 설명
**Kubernetes 클러스터 구조**:
```
Master Node (Control Plane)
├── API Server (모든 요청의 관문)
├── ETCD (클러스터 상태 저장소)
├── Controller Manager (상태 관리자)
└── Scheduler (Pod 배치 결정자)

Worker Node
├── Kubelet (노드 에이전트)
├── Kube Proxy (네트워크 프록시)
└── Container Runtime (실제 컨테이너 실행)
```

**동작 원리**:
1. 사용자가 kubectl로 API Server에 요청
2. API Server가 ETCD에 상태 저장
3. Controller Manager가 현재 상태와 원하는 상태 비교
4. Scheduler가 새로운 Pod의 배치 위치 결정
5. Kubelet이 실제 컨테이너 생성/관리

#### 🎉 Fun Facts
- **K8s 이름의 비밀**: Kubernetes = K + 8글자 + s
- **Google의 15년 노하우**: Borg 시스템의 오픈소스 버전
- **매주 1,000개 컨테이너**: Google이 관리하는 컨테이너 규모
- **Docker의 몰락**: 왜 Kubernetes가 Docker를 버렸을까?

### Session 2: 핵심 컴포넌트 심화 (50분)

#### 🎯 필수 요소
- **ETCD 분산 저장소 원리**
- **API Server RESTful 설계**
- **Controller Manager 루프 메커니즘**
- **각 컴포넌트 간 통신 방식**

#### 🔍 핵심 설명
**ETCD - 클러스터의 뇌**:
- Raft 알고리즘 기반 분산 합의
- Key-Value 저장소로 모든 클러스터 상태 보관
- Watch 기능으로 실시간 변경 감지

**API Server - 모든 것의 중심**:
- RESTful API로 모든 리소스 관리
- 인증, 인가, 검증 단계 수행
- ETCD와의 유일한 통신 창구

**Controller Manager - 자동화의 핵심**:
- Reconciliation Loop (조정 루프) 실행
- 현재 상태 → 원하는 상태로 지속적 조정
- 40개 이상의 내장 컨트롤러 포함

#### 🎉 Fun Facts
- **ETCD 이름**: "distributed reliable key-value store"
- **API Server 성능**: 초당 수천 개 요청 처리 가능
- **Controller 개수**: 실제로는 40개 이상의 컨트롤러가 하나로 패키징
- **Watch의 마법**: 폴링 없이 실시간 이벤트 감지

### Session 3: 스케줄러 & 에이전트 (50분)

#### 🎯 필수 요소
- **Scheduler 알고리즘 동작 원리**
- **Kubelet 역할과 책임**
- **Kube Proxy 네트워크 관리**
- **각 컴포넌트의 장애 대응**

#### 🔍 핵심 설명
**Kube Scheduler - 최적 배치의 마법사**:
```
스케줄링 과정:
1. Filtering (필터링) - 조건에 맞는 노드 선별
2. Scoring (점수 매기기) - 각 노드에 점수 부여
3. Binding (바인딩) - 최고 점수 노드에 Pod 할당
```

**Kubelet - 노드의 충실한 관리자**:
- Pod 생명주기 관리 (생성, 실행, 모니터링, 삭제)
- Container Runtime과 통신 (CRI 인터페이스)
- 노드 상태 API Server에 보고

**Kube Proxy - 네트워크 교통 경찰**:
- Service 추상화 구현
- iptables/IPVS 규칙 관리
- 로드밸런싱 및 트래픽 라우팅

#### 🎉 Fun Facts
- **스케줄링 조건**: 100개 이상의 조건 고려
- **Kubelet 통신**: 10초마다 heartbeat 전송
- **Proxy 모드**: iptables, IPVS, userspace 3가지 모드
- **CRI 표준**: Docker, containerd, CRI-O 모두 지원

### 🛠️ Lab 1: 클러스터 구축 & 컴포넌트 탐험 (90분)

#### 기본 Lab 요소
1. **환경 구축** (20분)
   - Kind/Minikube 클러스터 생성
   - kubectl 설정 및 연결 확인

2. **컴포넌트 상태 확인** (25분)
   - 각 컴포넌트 Pod 상태 조회
   - 로그 확인 및 상태 모니터링

3. **ETCD 직접 조회** (25분)
   - etcdctl 도구 사용법
   - 클러스터 데이터 직접 조회

4. **API 직접 호출** (20분)
   - curl로 API Server 직접 호출
   - kubectl 없이 리소스 조회

#### 심화 Lab 요소 (이해도 상승)
1. **컴포넌트 간 통신 분석**
   - Wireshark로 네트워크 패킷 분석
   - TLS 인증서 체인 확인

2. **ETCD 클러스터 구성**
   - 3노드 ETCD 클러스터 구축
   - 리더 선출 과정 관찰

3. **커스텀 스케줄러 작성**
   - 간단한 스케줄러 구현
   - 스케줄링 로직 커스터마이징

### 🎮 Challenge 1: 고장난 클러스터 복구하기 (90분)

#### Challenge 시나리오
**시나리오 1: API Server 설정 오류** (20분)
```yaml
# 의도적 오류: 잘못된 포트 설정
apiVersion: v1
kind: Pod
metadata:
  name: kube-apiserver
spec:
  containers:
  - name: kube-apiserver
    command:
    - kube-apiserver
    - --secure-port=6444  # 잘못된 포트
```

**시나리오 2: ETCD 연결 문제** (25분)
```yaml
# 의도적 오류: 잘못된 ETCD 엔드포인트
- --etcd-servers=https://127.0.0.1:2380  # 잘못된 포트
```

**시나리오 3: Kubelet 인증서 만료** (25분)
```bash
# 의도적 오류: 만료된 인증서 사용
# kubelet.conf에 만료된 인증서 설정
```

**시나리오 4: 네트워크 플러그인 오류** (20분)
```yaml
# 의도적 오류: CNI 설정 파일 손상
# /etc/cni/net.d/ 설정 파일 오류
```

#### 문제해결 가이드
- 로그 분석 방법
- 컴포넌트별 트러블슈팅
- 복구 절차 및 검증

---

## 📅 Day 2: 워크로드 관리 & 스케줄링

### Session 1: 기본 워크로드 객체 (50분)

#### 🎯 필수 요소
- **Pod 개념과 설계 철학**
- **ReplicaSet vs ReplicationController**
- **Deployment 롤링 업데이트 메커니즘**
- **Namespace 리소스 격리**

#### 🔍 핵심 설명
**Pod - 최소 배포 단위의 비밀**:
```
왜 컨테이너가 아닌 Pod인가?
1. 네트워크 공유 - 같은 IP, 포트 공간
2. 스토리지 공유 - 볼륨 마운트 공유
3. 생명주기 공유 - 함께 생성, 삭제
4. 사이드카 패턴 - 보조 컨테이너 배치
```

**ReplicaSet - 복제본 관리의 진화**:
- Label Selector 기반 Pod 관리
- 원하는 개수 유지 (Desired State)
- ReplicationController의 진화형

**Deployment - 무중단 배포의 핵심**:
```
롤링 업데이트 과정:
1. 새 ReplicaSet 생성
2. 점진적으로 새 Pod 생성
3. 기존 Pod 점진적 제거
4. 완료 후 기존 ReplicaSet 유지 (롤백용)
```

#### 🎉 Fun Facts
- **Pod 어원**: 고래 떼(Pod of whales)에서 유래
- **사이드카 패턴**: 오토바이 사이드카에서 착안
- **ReplicaSet 진화**: ReplicationController → ReplicaSet → Deployment
- **무중단 배포**: Netflix가 하루에 수천 번 배포하는 비결

### Session 2: 고급 스케줄링 (50분)

#### 🎯 필수 요소
- **Label과 Selector 시스템**
- **Taint와 Toleration 메커니즘**
- **Node Affinity 규칙**
- **Pod Affinity/Anti-Affinity**

#### 🔍 핵심 설명
**Label & Selector - 쿠버네티스의 DNA**:
```yaml
# Label 예시
metadata:
  labels:
    app: frontend
    version: v1.2.0
    environment: production
    
# Selector 예시
selector:
  matchLabels:
    app: frontend
  matchExpressions:
  - key: version
    operator: In
    values: [v1.2.0, v1.2.1]
```

**Taint & Toleration - 노드의 호불호**:
```bash
# Taint 설정 (노드에 "오염" 표시)
kubectl taint nodes node1 key=value:NoSchedule

# Toleration 설정 (Pod가 "참을성" 표시)
tolerations:
- key: "key"
  operator: "Equal"
  value: "value"
  effect: "NoSchedule"
```

#### 🎉 Fun Facts
- **Label 한계**: 최대 63자, 유니코드 지원
- **Taint 의미**: "오염"이라는 뜻으로 특별한 용도 표시
- **Affinity 종류**: Node, Pod, Anti 3가지 조합
- **스케줄링 복잡도**: 수백 개 조건을 동시 고려

### Session 3: 리소스 관리 & 특수 워크로드 (50분)

#### 🎯 필수 요소
- **Resource Request vs Limit**
- **QoS Class 분류**
- **DaemonSet 사용 사례**
- **Job과 CronJob 차이점**

#### 🔍 핵심 설명
**리소스 관리의 균형**:
```yaml
resources:
  requests:    # 최소 보장 리소스
    cpu: 100m
    memory: 128Mi
  limits:      # 최대 사용 리소스
    cpu: 500m
    memory: 512Mi
```

**QoS Class 자동 분류**:
- **Guaranteed**: requests = limits
- **Burstable**: requests < limits
- **BestEffort**: 설정 없음

**DaemonSet - 모든 노드의 수호천사**:
- 각 노드에 정확히 하나의 Pod
- 노드 추가 시 자동으로 Pod 생성
- 로깅, 모니터링 에이전트에 주로 사용

#### 🎉 Fun Facts
- **CPU 단위**: 1000m = 1 CPU 코어
- **메모리 단위**: Ki, Mi, Gi (1024 기반)
- **DaemonSet 예외**: 마스터 노드는 기본 제외
- **Job vs CronJob**: 일회성 vs 주기적 실행

### 🛠️ Lab 2: 워크로드 배포 & 관리 (90분)

#### 기본 Lab 요소
1. **단계별 워크로드 생성** (30분)
   - Pod → ReplicaSet → Deployment 순서
   - 각 단계별 특징 확인

2. **스케줄링 실습** (30분)
   - Label 기반 노드 선택
   - Taint/Toleration 설정

3. **롤링 업데이트** (30분)
   - 이미지 버전 업데이트
   - 롤백 실습

#### 심화 Lab 요소
1. **커스텀 스케줄링 정책**
   - 복잡한 Affinity 규칙 작성
   - 다중 조건 스케줄링

2. **리소스 최적화**
   - HPA와 연동한 리소스 설정
   - QoS Class별 성능 비교

### 🎮 Challenge 2: 배포 재해 시나리오 (90분)

#### Challenge 시나리오
**시나리오 1: 잘못된 이미지 배포** (20분)
```yaml
# 의도적 오류: 존재하지 않는 이미지
spec:
  containers:
  - name: app
    image: nginx:nonexistent-tag
```

**시나리오 2: 리소스 부족** (25분)
```yaml
# 의도적 오류: 과도한 리소스 요청
resources:
  requests:
    cpu: 10000m  # 클러스터 용량 초과
```

**시나리오 3: 스케줄링 실패** (25분)
```yaml
# 의도적 오류: 불가능한 노드 선택
nodeSelector:
  nonexistent-label: "true"
```

**시나리오 4: 롤링 업데이트 실패** (20분)
```yaml
# 의도적 오류: 잘못된 업데이트 전략
strategy:
  rollingUpdate:
    maxUnavailable: 100%  # 모든 Pod 동시 제거
```