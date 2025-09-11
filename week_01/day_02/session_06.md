# Session 6: 컨테이너 오케스트레이션 개요

## 📍 교과과정에서의 위치
이 세션은 **Week 1 > Day 2 > Session 6**으로, 단일 컨테이너의 한계를 극복하기 위한 오케스트레이션 기술을 소개합니다. Week 3-4에서 학습할 Kubernetes의 필요성과 기본 개념을 이해하는 중요한 기초 세션입니다.

## 학습 목표 (5분)
- 단일 컨테이너 운영의 한계점 이해
- 컨테이너 오케스트레이션의 필요성과 개념 학습
- Kubernetes의 기본 아키텍처와 주요 기능 파악

## 1. 단일 컨테이너의 한계 (15분)

### 프로덕션 환경의 요구사항
**실제 서비스 운영에서 필요한 기능들**:

```mermaid
graph TB
    subgraph "프로덕션 요구사항"
        A[고가용성<br/>High Availability]
        B[확장성<br/>Scalability]
        C[로드 밸런싱<br/>Load Balancing]
        D[자동 복구<br/>Self-healing]
        E[롤링 업데이트<br/>Rolling Update]
        F[서비스 디스커버리<br/>Service Discovery]
    end
    
    style A fill:#ffebee,stroke:#f44336
    style B fill:#e8f5e8,stroke:#4caf50
    style C fill:#e3f2fd,stroke:#2196f3
    style D fill:#fff3e0,stroke:#ff9800
    style E fill:#f3e5f5,stroke:#7b1fa2
    style F fill:#e0f2f1,stroke:#009688
```

### 단일 컨테이너의 문제점
**하나의 컨테이너로는 해결할 수 없는 문제들**:

#### 1. 단일 장애점 (Single Point of Failure)
```mermaid
graph LR
    A[사용자] --> B[단일 컨테이너]
    B --> C[서비스 중단!]
    
    style C fill:#ffebee,stroke:#f44336
```

#### 2. 수동 확장의 어려움
- 트래픽 증가 시 수동으로 컨테이너 추가
- 로드 밸런싱 설정의 복잡성
- 리소스 사용량 모니터링의 어려움

#### 3. 네트워크 관리 복잡성
**여러 컨테이너 간 통신 문제**:
- 포트 충돌 관리
- 서비스 간 연결 설정
- 동적 IP 주소 문제

## 2. 오케스트레이션의 개념 (18분)

### 오케스트레이션이란?
**여러 컨테이너를 조화롭게 관리하는 기술**로, 마치 오케스트라 지휘자처럼 전체를 조율합니다.

```mermaid
graph TB
    subgraph "오케스트레이션 플랫폼"
        O[Orchestrator<br/>지휘자]
    end
    
    subgraph "컨테이너 클러스터"
        C1[Container 1<br/>Web Server]
        C2[Container 2<br/>API Server]
        C3[Container 3<br/>Database]
        C4[Container 4<br/>Cache]
    end
    
    O --> C1
    O --> C2
    O --> C3
    O --> C4
    
    style O fill:#e1f5fe,stroke:#0277bd
    style C1 fill:#e8f5e8,stroke:#4caf50
    style C2 fill:#e8f5e8,stroke:#4caf50
    style C3 fill:#e8f5e8,stroke:#4caf50
    style C4 fill=#e8f5e8,stroke=#4caf50
```

### 주요 기능들
**오케스트레이션 플랫폼이 제공하는 핵심 기능**:

#### 1. 자동 스케일링
```mermaid
graph LR
    A[CPU 사용률 80%] --> B[오케스트레이터]
    B --> C[새 컨테이너 생성]
    C --> D[로드 밸런서 업데이트]
    
    style B fill:#e1f5fe,stroke:#0277bd
```

#### 2. 자동 복구 (Self-healing)
- 컨테이너 장애 감지
- 자동으로 새 컨테이너 시작
- 불건전한 컨테이너 교체

#### 3. 서비스 디스커버리
**동적으로 변하는 서비스 위치 자동 관리**:
- DNS 기반 서비스 이름 해결
- 로드 밸런싱 자동 구성
- 헬스 체크 통합

#### 4. 롤링 업데이트
**무중단 배포를 위한 점진적 업데이트**:

```mermaid
sequenceDiagram
    participant LB as Load Balancer
    participant V1 as Version 1.0
    participant V2 as Version 2.0
    
    Note over LB,V2: 초기 상태: 모든 트래픽이 V1으로
    LB->>V1: 100% 트래픽
    
    Note over LB,V2: 1단계: V2 컨테이너 시작
    V2->>V2: 새 버전 시작
    
    Note over LB,V2: 2단계: 트래픽 점진적 이동
    LB->>V1: 50% 트래픽
    LB->>V2: 50% 트래픽
    
    Note over LB,V2: 3단계: V1 종료
    LB->>V2: 100% 트래픽
    V1->>V1: 이전 버전 종료
```

## 3. 오케스트레이션 도구들 (10분)

### 주요 오케스트레이션 플랫폼
**시장에서 사용되는 대표적인 도구들**:

```mermaid
graph TB
    subgraph "오케스트레이션 도구"
        A[Kubernetes<br/>업계 표준]
        B[Docker Swarm<br/>Docker 내장]
        C[Apache Mesos<br/>대규모 클러스터]
        D[Nomad<br/>HashiCorp]
    end
    
    subgraph "클라우드 관리형"
        E[Amazon EKS]
        F[Google GKE]
        G[Azure AKS]
    end
    
    A --> E
    A --> F
    A --> G
    
    style A fill:#e8f5e8,stroke:#4caf50
    style E fill:#fff3e0,stroke:#ff9800
    style F fill:#fff3e0,stroke:#ff9800
    style G fill=#fff3e0,stroke=#ff9800
```

### 도구별 특징 비교
| 도구 | 장점 | 단점 | 적합한 용도 |
|------|------|------|-------------|
| **Kubernetes** | 풍부한 기능, 큰 생태계 | 복잡한 학습 곡선 | 대규모 프로덕션 |
| **Docker Swarm** | 간단한 설정 | 제한적 기능 | 소규모 클러스터 |
| **Mesos** | 높은 확장성 | 복잡한 운영 | 대규모 데이터센터 |

## 4. Kubernetes 소개 (12분)

### Kubernetes의 등장
**Google의 Borg 시스템에서 영감을 받아 2014년 오픈소스로 공개**:
- CNCF(Cloud Native Computing Foundation) 첫 번째 프로젝트
- 현재 컨테이너 오케스트레이션의 사실상 표준
- 모든 주요 클라우드 제공업체에서 지원

### 기본 아키텍처
**마스터-워커 노드 구조**:

```mermaid
graph TB
    subgraph "Control Plane (Master)"
        A[API Server]
        B[etcd]
        C[Scheduler]
        D[Controller Manager]
    end
    
    subgraph "Worker Node 1"
        E[kubelet]
        F[kube-proxy]
        G[Container Runtime]
        H[Pod 1]
        I[Pod 2]
    end
    
    subgraph "Worker Node 2"
        J[kubelet]
        K[kube-proxy]
        L[Container Runtime]
        M[Pod 3]
        N[Pod 4]
    end
    
    A --> E
    A --> J
    E --> H
    E --> I
    J --> M
    J --> N
    
    style A fill:#e1f5fe,stroke:#0277bd
    style B fill:#e1f5fe,stroke:#0277bd
    style C fill:#e1f5fe,stroke:#0277bd
    style D fill=#e1f5fe,stroke=#0277bd
```

### 핵심 개념들
**Kubernetes의 주요 오브젝트**:

#### 1. Pod
- **최소 배포 단위**로 하나 이상의 컨테이너를 포함
- 동일한 네트워크와 스토리지 공유
- 일반적으로 하나의 애플리케이션 컨테이너

#### 2. Service
- **Pod들에 대한 안정적인 네트워크 엔드포인트** 제공
- 로드 밸런싱 기능 내장
- 서비스 디스커버리 지원

#### 3. Deployment
- **Pod의 선언적 업데이트** 관리
- 롤링 업데이트와 롤백 지원
- 원하는 상태(Desired State) 유지

### Kubernetes의 장점
**왜 Kubernetes가 표준이 되었는가**:
- **선언적 구성**: 원하는 상태를 선언하면 자동으로 달성
- **자동 복구**: 장애 시 자동으로 복구
- **확장성**: 수천 개의 노드까지 확장 가능
- **이식성**: 어떤 환경에서든 동일하게 동작

## 실습 준비: 오케스트레이션 시나리오 (5분)

### 시나리오 설계
"온라인 쇼핑몰을 운영한다고 가정하고, 다음 상황들을 어떻게 해결할지 생각해보세요."

#### 상황들
1. **블랙프라이데이 트래픽 급증**: 평소의 10배 트래픽
2. **서버 장애 발생**: 웹 서버 중 하나가 다운
3. **새 버전 배포**: 서비스 중단 없이 업데이트
4. **데이터베이스 연결**: 여러 애플리케이션이 DB 접근

#### 토론 포인트
- 단일 컨테이너로는 어떤 문제가 있을까?
- 오케스트레이션이 어떻게 도움이 될까?
- 어떤 기능들이 필요할까?

## 다음 세션 예고
컨테이너 환경에서 고려해야 할 보안 요소들과 기본적인 보안 원칙들을 학습하겠습니다.

## 📚 참고 자료
- [Kubernetes Overview](https://kubernetes.io/docs/concepts/overview/)
- [Container Orchestration Explained](https://www.redhat.com/en/topics/containers/what-is-container-orchestration)
- [Docker Swarm vs Kubernetes](https://www.docker.com/blog/kubernetes-vs-docker-swarm/)
- [CNCF Landscape](https://landscape.cncf.io/)
- [Kubernetes Architecture](https://kubernetes.io/docs/concepts/architecture/)