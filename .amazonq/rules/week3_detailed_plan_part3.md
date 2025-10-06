# Week 3 Kubernetes 상세 계획서 - Part 3

## 📅 Day 5: 운영 & 고급 기능

### Session 1: 모니터링 & 로깅 (50분)

#### 🎯 필수 요소
- **관측성 3요소 (Metrics, Logs, Traces)**
- **Prometheus 아키텍처와 데이터 모델**
- **클러스터 모니터링 vs 애플리케이션 모니터링**
- **중앙화된 로깅 시스템 구조**

#### 🔍 핵심 설명
**관측성(Observability) 3요소**:
```
1. Metrics (지표)
   ├── 시계열 데이터 (CPU, Memory, Request Rate)
   ├── Prometheus + Grafana
   └── 알림 및 대시보드

2. Logs (로그)
   ├── 구조화된 이벤트 데이터
   ├── ELK Stack (Elasticsearch, Logstash, Kibana)
   └── 중앙화된 로그 수집

3. Traces (추적)
   ├── 분산 시스템 요청 추적
   ├── Jaeger, Zipkin
   └── 마이크로서비스 간 호출 관계
```

**Prometheus 아키텍처**:
```
Prometheus Server
├── Time Series Database
├── PromQL (쿼리 언어)
├── Pull 기반 메트릭 수집
└── Alertmanager 연동

메트릭 수집 방식:
1. /metrics 엔드포인트에서 Pull
2. Service Discovery로 타겟 자동 발견
3. 시계열 DB에 저장
4. PromQL로 쿼리 및 알림
```

**Kubernetes 로깅 패턴**:
```
1. Node-level logging
   ├── kubelet이 컨테이너 로그 수집
   ├── /var/log/containers/ 저장
   └── 로그 로테이션 관리

2. Cluster-level logging
   ├── DaemonSet으로 로그 수집기 배포
   ├── Fluent Bit, Fluentd 사용
   └── 중앙 저장소로 전송
```

#### 🎉 Fun Facts
- **Prometheus 이름**: 그리스 신화의 프로메테우스에서 유래
- **Pull vs Push**: Prometheus는 Pull, 대부분은 Push 방식
- **PromQL**: SQL과 유사하지만 시계열 데이터 특화
- **Grafana**: "그래프"와 "아나"(데이터)의 합성어

### Session 2: 오토스케일링 & 자동화 (50분)

#### 🎯 필수 요소
- **HPA vs VPA vs Cluster Autoscaler**
- **메트릭 기반 스케일링 알고리즘**
- **커스텀 메트릭 스케일링**
- **KEDA 이벤트 기반 스케일링**

#### 🔍 핵심 설명
**3가지 오토스케일링**:
```yaml
# HPA (Horizontal Pod Autoscaler) - Pod 개수 조정
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70

# VPA (Vertical Pod Autoscaler) - Pod 리소스 조정
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  updatePolicy:
    updateMode: "Auto"  # Off, Initial, Auto

# Cluster Autoscaler - 노드 개수 조정
# 클라우드 제공자별 구현
# AWS: Auto Scaling Group
# GCP: Managed Instance Group
# Azure: Virtual Machine Scale Set
```

**스케일링 알고리즘**:
```
HPA 계산 공식:
desiredReplicas = ceil[currentReplicas * (currentMetricValue / desiredMetricValue)]

예시:
- 현재 Pod: 3개
- 현재 CPU: 80%
- 목표 CPU: 50%
- 계산: ceil[3 * (80/50)] = ceil[4.8] = 5개
```

#### 🎉 Fun Facts
- **HPA 최소 간격**: 15초마다 메트릭 확인, 3분마다 스케일링
- **VPA vs HPA**: 동시 사용 시 충돌 가능 (CPU/Memory 기준)
- **KEDA**: Azure Functions 팀에서 시작된 오픈소스
- **커스텀 메트릭**: Prometheus, DataDog 등 외부 메트릭 사용 가능

### Session 3: 고급 기능 & 미래 (50분)

#### 🎯 필수 요소
- **Custom Resource Definition (CRD)**
- **Operator 패턴과 Controller**
- **Gateway API vs Ingress**
- **Service Mesh 개념과 필요성**

#### 🔍 핵심 설명
**CRD와 Operator 패턴**:
```yaml
# Custom Resource Definition
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: databases.example.com
spec:
  group: example.com
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              size:
                type: string
              version:
                type: string

# Custom Resource 사용
apiVersion: example.com/v1
kind: Database
metadata:
  name: my-database
spec:
  size: "large"
  version: "13.4"
```

**Operator 패턴**:
```
Operator = CRD + Controller + Domain Knowledge

동작 과정:
1. 사용자가 Custom Resource 생성
2. Controller가 변경 사항 감지 (Watch)
3. 현재 상태와 원하는 상태 비교
4. 필요한 작업 수행 (Reconcile)
5. 상태 업데이트 및 이벤트 기록
```

**Gateway API - Ingress의 진화**:
```yaml
# Gateway API - 더 표현력 있는 라우팅
apiVersion: gateway.networking.k8s.io/v1beta1
kind: Gateway
metadata:
  name: example-gateway
spec:
  gatewayClassName: example-gateway-class
  listeners:
  - name: http
    protocol: HTTP
    port: 80

apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: example-route
spec:
  parentRefs:
  - name: example-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /api/v1
    backendRefs:
    - name: api-v1-service
      port: 80
```

#### 🎉 Fun Facts
- **Operator 유래**: CoreOS에서 처음 제안한 패턴
- **CRD 한계**: 복잡한 검증은 Admission Controller 필요
- **Gateway API**: Ingress의 한계 극복을 위해 SIG-Network에서 개발
- **Service Mesh**: Netflix, Uber 등 대규모 마이크로서비스에서 시작

### 🛠️ Lab 5: 운영 환경 구축 (90분)

#### 기본 Lab 요소
1. **Prometheus + Grafana 스택** (35분)
   - Prometheus Operator 설치
   - ServiceMonitor로 메트릭 수집 설정
   - Grafana 대시보드 구성
   - AlertManager 알림 설정

2. **HPA/VPA 설정** (30분)
   - CPU 기반 HPA 구성
   - 메모리 기반 VPA 설정
   - 부하 테스트로 스케일링 확인

3. **중앙화된 로깅** (25분)
   - Fluent Bit DaemonSet 배포
   - Elasticsearch 클러스터 구성
   - Kibana 대시보드 설정

#### 심화 Lab 요소
1. **커스텀 메트릭 스케일링**
   - Prometheus Adapter 설치
   - 애플리케이션 메트릭 기반 HPA
   - 큐 길이 기반 스케일링

2. **Operator 개발**
   - Kubebuilder로 간단한 Operator 생성
   - CRD 정의 및 Controller 로직 구현
   - 배포 및 테스트

3. **Service Mesh 체험**
   - Istio 설치 및 설정
   - 트래픽 분할 (Canary 배포)
   - 서비스 간 mTLS 설정

### 🎮 Challenge 5: 운영 장애 대응 (90분)

#### Challenge 시나리오
**시나리오 1: 급격한 트래픽 증가** (25분)
```yaml
# 의도적 오류: 부적절한 HPA 설정
spec:
  minReplicas: 1
  maxReplicas: 2  # 너무 낮은 최대값
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 90  # 너무 높은 임계값
```

**시나리오 2: 모니터링 시스템 장애** (25분)
```yaml
# 의도적 오류: Prometheus 설정 오류
spec:
  serviceMonitorSelector:
    matchLabels:
      nonexistent: "label"  # 잘못된 라벨 셀렉터
```

**시나리오 3: 로그 수집 실패** (20분)
```yaml
# 의도적 오류: Fluent Bit 설정 오류
apiVersion: v1
kind: ConfigMap
data:
  fluent-bit.conf: |
    [OUTPUT]
        Name es
        Host elasticsearch.wrong-namespace  # 잘못된 호스트
```

**시나리오 4: 자동 스케일링 오작동** (20분)
```yaml
# 의도적 오류: VPA와 HPA 충돌
# 동일한 Deployment에 VPA와 HPA 동시 적용
```

---

## 🎯 Week 3 통합 최종 프로젝트

### 🚀 "Production-Ready Kubernetes Platform" 구축

#### 프로젝트 개요
**목표**: 5일간 학습한 모든 Kubernetes 기술을 통합하여 실제 운영 가능한 플랫폼 구축

**시나리오**: 
- 스타트업이 성장하면서 기존 단일 서버에서 Kubernetes 기반 마이크로서비스로 전환
- 개발팀 3명, 운영팀 2명이 사용할 수 있는 플랫폼 구축
- 보안, 모니터링, 자동화가 모두 적용된 프로덕션급 환경

#### 구현 요구사항

**1. 클러스터 아키텍처** (Day 1 연계)
```yaml
클러스터 구성:
- Master Node: 3개 (HA 구성)
- Worker Node: 3개 (다양한 워크로드 분산)
- ETCD: 외부 클러스터 (백업/복원 가능)
- Container Runtime: containerd
```

**2. 애플리케이션 워크로드** (Day 2 연계)
```yaml
배포할 애플리케이션:
- Frontend: React SPA (Deployment + HPA)
- Backend API: Node.js (Deployment + HPA)
- Database: PostgreSQL (StatefulSet + PVC)
- Cache: Redis (Deployment)
- Message Queue: RabbitMQ (StatefulSet)

스케줄링 요구사항:
- Frontend: 모든 노드에 분산 배치
- Backend: CPU 최적화 노드 우선
- Database: SSD 스토리지 노드 전용
- 개발/스테이징/프로덕션 네임스페이스 분리
```

**3. 네트워킹 & 스토리지** (Day 3 연계)
```yaml
네트워킹:
- CNI: Calico (Network Policy 지원)
- Ingress: Nginx Ingress Controller
- 도메인: dev.company.com, staging.company.com, prod.company.com
- TLS: Let's Encrypt 자동 인증서

스토리지:
- StorageClass: SSD (fast), HDD (standard)
- 백업: Velero를 이용한 자동 백업
- 데이터베이스: 일일 백업 + 7일 보관
```

**4. 보안 & 권한 관리** (Day 4 연계)
```yaml
RBAC 설정:
- 개발자: 개발 네임스페이스 전체 권한
- 운영자: 모든 네임스페이스 읽기 + 프로덕션 쓰기
- 서비스 계정: 최소 권한 원칙

보안 정책:
- Network Policy: 네임스페이스 간 격리
- Pod Security Standards: Restricted 적용
- Image Security: 이미지 스캔 필수
- Secret 관리: External Secrets Operator
```

**5. 모니터링 & 운영** (Day 5 연계)
```yaml
모니터링 스택:
- Prometheus: 메트릭 수집 및 저장
- Grafana: 대시보드 및 시각화
- AlertManager: 알림 및 에스컬레이션
- Jaeger: 분산 추적

로깅 스택:
- Fluent Bit: 로그 수집
- Elasticsearch: 로그 저장 및 검색
- Kibana: 로그 분석 및 시각화

자동화:
- HPA: CPU/Memory 기반 자동 스케일링
- VPA: 리소스 최적화
- GitOps: ArgoCD를 이용한 배포 자동화
```

#### 평가 기준

**기능성 (40점)**
- [ ] 클러스터 정상 구축 및 HA 구성 (10점)
- [ ] 모든 애플리케이션 정상 배포 (10점)
- [ ] 네트워킹 및 외부 접근 가능 (10점)
- [ ] 스토리지 및 데이터 영속성 (10점)

**보안성 (25점)**
- [ ] RBAC 정책 적용 및 테스트 (10점)
- [ ] Network Policy 구현 (8점)
- [ ] Secret 관리 및 보안 강화 (7점)

**운영성 (25점)**
- [ ] 모니터링 대시보드 구성 (10점)
- [ ] 로깅 시스템 구축 (8점)
- [ ] 자동 스케일링 동작 확인 (7점)

**안정성 (10점)**
- [ ] 장애 상황 대응 능력 (5점)
- [ ] 백업/복원 절차 수행 (5점)

#### 도전 과제 (보너스)

**고급 기능 구현** (+10점)
- [ ] Service Mesh (Istio) 적용
- [ ] Custom Operator 개발
- [ ] Multi-cluster 구성
- [ ] Chaos Engineering 적용

**창의적 해결책** (+5점)
- [ ] 독창적인 모니터링 대시보드
- [ ] 효율적인 CI/CD 파이프라인
- [ ] 비용 최적화 전략

#### 프로젝트 진행 방식

**팀 구성**: 2-3명씩 팀 구성 (역할 분담)
- **Platform Engineer**: 클러스터 구축 및 인프라
- **DevOps Engineer**: CI/CD 및 자동화
- **SRE**: 모니터링 및 운영

**진행 일정**:
- **Day 1-2**: 요구사항 분석 및 설계
- **Day 3-4**: 구현 및 테스트
- **Day 5**: 최종 점검 및 발표

**발표 형식** (팀당 15분):
- **아키텍처 설명** (5분): 전체 구조 및 설계 결정
- **데모** (7분): 실제 동작 시연
- **Q&A** (3분): 질문 및 답변

#### 성공 지표

**기술적 성취**:
- 모든 컴포넌트 정상 동작
- 부하 테스트 통과 (동시 사용자 100명)
- 장애 복구 시간 5분 이내

**학습 효과**:
- Kubernetes 핵심 개념 완전 이해
- 실무 적용 가능한 운영 노하우 습득
- 팀워크 및 문제해결 능력 향상

**실무 연계**:
- 포트폴리오 작성 가능한 수준
- 실제 프로덕션 환경 적용 가능
- Kubernetes 관련 인증 시험 준비

---

## 📊 Week 3 전체 학습 성과 측정

### 일일 체크포인트

**Day 1: 아키텍처 이해도**
- [ ] 클러스터 컴포넌트 역할 설명 가능
- [ ] ETCD 데이터 직접 조회 가능
- [ ] 장애 상황 진단 및 복구 가능

**Day 2: 워크로드 관리**
- [ ] Pod부터 Deployment까지 계층 구조 이해
- [ ] 스케줄링 정책 설정 및 테스트 가능
- [ ] 롤링 업데이트 및 롤백 수행 가능

**Day 3: 네트워킹 & 스토리지**
- [ ] 서비스 타입별 특징 및 용도 이해
- [ ] Ingress 설정 및 도메인 라우팅 구성
- [ ] PV/PVC를 이용한 데이터 영속화

**Day 4: 보안 & 관리**
- [ ] RBAC 정책 설계 및 구현
- [ ] 클러스터 업그레이드 절차 수행
- [ ] 보안 정책 적용 및 검증

**Day 5: 운영 & 고급 기능**
- [ ] 모니터링 스택 구축 및 운영
- [ ] 오토스케일링 설정 및 튜닝
- [ ] CRD/Operator 개념 이해 및 활용

### 주간 종합 평가

**기술적 역량** (40%)
- Kubernetes 아키텍처 완전 이해
- 실무 환경 구축 및 운영 능력
- 문제 상황 진단 및 해결 능력

**협업 및 소통** (30%)
- 팀 프로젝트 기여도
- 지식 공유 및 상호 학습
- 발표 및 설명 능력

**창의성 및 응용** (20%)
- 독창적인 해결책 제시
- 최신 기술 트렌드 적용
- 실무 개선 아이디어 제안

**학습 태도** (10%)
- 적극적인 참여 및 질문
- 지속적인 학습 의지
- 피드백 수용 및 개선

### 성취 수준별 가이드

**초급 달성** (60점 이상)
- 기본 Kubernetes 개념 이해
- 간단한 애플리케이션 배포 가능
- 기본적인 문제 해결 능력

**중급 달성** (75점 이상)
- 복잡한 워크로드 설계 및 배포
- 보안 및 네트워킹 정책 구현
- 모니터링 및 운영 환경 구축

**고급 달성** (90점 이상)
- 프로덕션급 클러스터 설계
- 고급 기능 및 최신 트렌드 적용
- 멘토링 및 지식 전파 능력

이 상세 계획서를 바탕으로 각 세션과 Lab, Challenge를 구체적으로 구현하시면 됩니다! 🚀