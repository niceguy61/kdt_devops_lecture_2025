# Week 4 Day 1 Session 3: 마이크로서비스 패턴 - 실무 중심 (개선 버전)

<div align="center">

**🔧 핵심 패턴** • **⚖️ 선택 기준** • **🛠️ 실무 적용** • **📊 성능 비교**

*언제, 어떤 패턴을 사용해야 하는가?*

</div>

---

## 🕘 세션 정보
**시간**: 10:50-11:40 (50분)  
**목표**: 실무에서 검증된 마이크로서비스 패턴과 선택 기준 습득  
**방식**: 패턴별 실무 사례 + 선택 기준 + 트레이드오프 분석

## 🎯 세션 목표

### 📚 학습 목표
- **패턴 이해**: 5가지 핵심 패턴의 목적과 동작 원리
- **선택 기준**: 상황별 최적 패턴 선택 능력
- **트레이드오프**: 각 패턴의 장단점과 비용 분석

### 🤔 왜 필요한가? (3분)

**현실 문제 상황**:
- 🔥 **장애 전파**: 하나의 서비스 장애가 전체 시스템 마비
- 🐌 **성능 저하**: 서비스 간 호출이 많아져서 응답 시간 증가
- 💸 **비용 폭증**: 불필요한 동기 호출로 인프라 비용 상승
- 🔄 **데이터 불일치**: 분산 트랜잭션 실패로 데이터 정합성 문제

---

## 📊 패턴 선택 매트릭스 (5분)

### 🎯 상황별 패턴 선택 가이드

| 상황 | 추천 패턴 | 복잡도 | 성능 영향 | 운영 부담 | 비용 |
|------|----------|--------|----------|----------|------|
| **외부 API 호출** | Circuit Breaker | ⭐⭐ | ⭐ | ⭐⭐ | 💰 |
| **여러 서비스 조합** | API Gateway | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | 💰💰 |
| **분산 트랜잭션** | Saga | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | 💰💰💰 |
| **읽기/쓰기 분리** | CQRS | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 💰💰💰💰 |
| **이벤트 기반 통신** | Event Sourcing | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 💰💰💰💰💰 |

---

## 📖 핵심 패턴 (35분)

### 🔍 패턴 1: API Gateway - 단일 진입점 (8분)

> **정의**: 모든 클라이언트 요청을 받아 적절한 마이크로서비스로 라우팅하는 패턴

**🏢 실생활 비유 - 호텔 컨시어지**:
```mermaid
graph TB
    subgraph "🏨 호텔 (시스템)"
        C[🎩 컨시어지<br/>API Gateway]
        
        subgraph "호텔 서비스들"
            R[🛏️ 객실 서비스<br/>Room Service]
            F[🍽️ 레스토랑<br/>Food Service]
            S[🧖‍♀️ 스파<br/>Spa Service]
            T[🚗 교통<br/>Transport Service]
        end
    end
    
    G1[👤 비즈니스 고객] --> C
    G2[👨‍👩‍👧‍👦 가족 고객] --> C
    G3[📱 모바일 앱] --> C
    
    C --> R
    C --> F
    C --> S
    C --> T
    
    style C fill:#ff6b6b
    style G1 fill:#e3f2fd
    style G2 fill:#e3f2fd
    style G3 fill:#e3f2fd
    style R fill:#e8f5e8
    style F fill:#e8f5e8
    style S fill:#e8f5e8
    style T fill:#e8f5e8
```

**핵심 기능**:
1. **라우팅**: 요청을 적절한 서비스로 전달
2. **인증/인가**: 통합 보안 처리
3. **요청/응답 변환**: 클라이언트별 데이터 형식 변환
4. **모니터링**: 통합 로깅 및 메트릭 수집

**☁️ AWS 구현**:
```mermaid
graph TB
    subgraph "AWS API Gateway 구현"
        subgraph "클라이언트"
            WEB[🌐 웹 앱]
            MOBILE[📱 모바일 앱]
            API_CLIENT[🔧 API 클라이언트]
        end
        
        subgraph "API Gateway"
            APIGW[API Gateway<br/>라우팅 + 인증]
            LAMBDA_AUTH[Lambda<br/>인증 함수]
        end
        
        subgraph "마이크로서비스"
            EKS[EKS<br/>비즈니스 서비스]
            LAMBDA[Lambda<br/>서버리스 함수]
            FARGATE[Fargate<br/>컨테이너 서비스]
        end
    end
    
    WEB --> APIGW
    MOBILE --> APIGW
    API_CLIENT --> APIGW
    
    APIGW --> LAMBDA_AUTH
    APIGW --> EKS
    APIGW --> LAMBDA
    APIGW --> FARGATE
    
    style APIGW fill:#ff9800
    style EKS fill:#4caf50
    style LAMBDA fill:#2196f3
```

**실무 적용 기준**:
- ✅ **사용해야 할 때**: 클라이언트 종류가 다양할 때
- ⚠️ **주의할 점**: 단일 장애점이 될 수 있음
- 💰 **비용**: 요청당 과금, 월 $3-10/1M requests

### 🔍 패턴 2: Circuit Breaker - 장애 전파 방지 (8분)

> **정의**: 외부 서비스 호출 실패 시 자동으로 차단하여 시스템 안정성을 보장하는 패턴

**⚡ 실생활 비유 - 전기 차단기**:
```mermaid
stateDiagram-v2
    [*] --> Closed: 정상 상태
    
    state Closed {
        [*] --> Normal: 요청 정상 처리
        Normal --> FailureCount: 실패 발생
        FailureCount --> Normal: 성공 시 카운트 리셋
    }
    
    Closed --> Open: 실패 임계값 초과
    
    state Open {
        [*] --> Blocked: 모든 요청 차단
        Blocked --> Timeout: 타임아웃 대기
    }
    
    Open --> HalfOpen: 타임아웃 후
    
    state HalfOpen {
        [*] --> Testing: 제한적 요청 허용
        Testing --> Success: 성공 시
        Testing --> Failure: 실패 시
    }
    
    HalfOpen --> Closed: 성공
    HalfOpen --> Open: 실패
```

**Netflix Hystrix 사례**:
- **문제**: 외부 API 지연으로 전체 시스템 응답 시간 증가
- **해결**: Circuit Breaker로 장애 서비스 차단
- **결과**: 99.99% 가용성 달성, 평균 응답시간 50% 개선

**☁️ AWS 구현 방법**:
```yaml
# AWS App Mesh Circuit Breaker 설정
apiVersion: appmesh.k8s.aws/v1beta2
kind: VirtualNode
spec:
  listeners:
  - outlierDetection:
      maxServerErrors: 5      # 최대 실패 횟수
      interval: 30s           # 측정 간격
      baseEjectionDuration: 15s # 차단 시간
      maxEjectionPercent: 50  # 최대 차단 비율
```

**실무 적용 기준**:
- ✅ **필수 적용**: 외부 API, 데이터베이스 호출
- 📊 **임계값 설정**: 실패율 50%, 응답시간 5초
- 🔄 **복구 전략**: 점진적 트래픽 증가

### 🔍 패턴 3: Saga - 분산 트랜잭션 관리 (8분)

> **정의**: 여러 서비스에 걸친 트랜잭션을 보상 트랜잭션으로 관리하는 패턴

**🛒 실생활 비유 - 온라인 주문 처리**:
```mermaid
sequenceDiagram
    participant O as 📱 주문 서비스
    participant P as 💳 결제 서비스
    participant I as 📦 재고 서비스
    participant S as 🚚 배송 서비스
    
    Note over O,S: 정상 시나리오
    O->>P: 1. 결제 처리
    P->>I: 2. 재고 차감
    I->>S: 3. 배송 요청
    S->>O: 4. 주문 완료
    
    Note over O,S: 실패 시나리오 (재고 부족)
    O->>P: 1. 결제 처리 ✅
    P->>I: 2. 재고 차감 ❌
    I->>P: 3. 결제 취소 (보상)
    P->>O: 4. 주문 실패
```

**Saga 패턴 유형**:

**1. Orchestration (중앙 집중)**:
```mermaid
graph TB
    subgraph "Orchestration Saga"
        SO[📋 Saga Orchestrator<br/>AWS Step Functions]
        
        SO --> S1[💳 결제 서비스]
        SO --> S2[📦 재고 서비스]
        SO --> S3[🚚 배송 서비스]
        
        S1 --> SO
        S2 --> SO
        S3 --> SO
    end
    
    style SO fill:#ff6b6b
    style S1 fill:#e8f5e8
    style S2 fill:#e8f5e8
    style S3 fill:#e8f5e8
```

**2. Choreography (분산 조정)**:
```mermaid
graph LR
    S1[💳 결제 서비스] --> E1[결제완료 이벤트]
    E1 --> S2[📦 재고 서비스]
    S2 --> E2[재고차감 이벤트]
    E2 --> S3[🚚 배송 서비스]
    
    style E1 fill:#fff3e0
    style E2 fill:#fff3e0
    style S1 fill:#e8f5e8
    style S2 fill:#e8f5e8
    style S3 fill:#e8f5e8
```

**☁️ AWS Step Functions 구현**:
```json
{
  "Comment": "주문 처리 Saga",
  "StartAt": "ProcessPayment",
  "States": {
    "ProcessPayment": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:ProcessPayment",
      "Catch": [{
        "ErrorEquals": ["States.ALL"],
        "Next": "PaymentFailed"
      }],
      "Next": "UpdateInventory"
    },
    "UpdateInventory": {
      "Type": "Task", 
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:UpdateInventory",
      "Catch": [{
        "ErrorEquals": ["States.ALL"],
        "Next": "CompensatePayment"
      }],
      "Next": "CreateShipment"
    }
  }
}
```

**실무 적용 기준**:
- ✅ **사용 시기**: 2개 이상 서비스의 데이터 변경
- ⚖️ **패턴 선택**: 단순한 경우 Choreography, 복잡한 경우 Orchestration
- 💰 **비용**: Step Functions $25/1M transitions

### 🔍 패턴 4: CQRS - 읽기/쓰기 분리 (6분)

> **정의**: Command(쓰기)와 Query(읽기)를 별도 모델로 분리하는 패턴

**📚 실생활 비유 - 도서관 시스템**:
```mermaid
graph TB
    subgraph "📚 도서관 CQRS"
        subgraph "✍️ Command Side (쓰기)"
            C1[📝 도서 등록]
            C2[📤 도서 대출]
            C3[📥 도서 반납]
            CDB[(📊 정규화된 DB<br/>PostgreSQL)]
        end
        
        subgraph "👀 Query Side (읽기)"
            Q1[🔍 도서 검색]
            Q2[📊 통계 조회]
            Q3[📈 추천 목록]
            QDB[(🚀 최적화된 DB<br/>Elasticsearch)]
        end
        
        C1 --> CDB
        C2 --> CDB
        C3 --> CDB
        
        CDB -.-> QDB
        
        QDB --> Q1
        QDB --> Q2
        QDB --> Q3
    end
    
    style C1 fill:#ffebee
    style C2 fill:#ffebee
    style C3 fill:#ffebee
    style Q1 fill:#e8f5e8
    style Q2 fill:#e8f5e8
    style Q3 fill:#e8f5e8
    style CDB fill:#ff6b6b
    style QDB fill:#4ecdc4
```

**적용 기준**:
- ✅ **사용해야 할 때**: 읽기와 쓰기 패턴이 크게 다를 때
- 📊 **성능 개선**: 읽기 성능 10-100배 향상 가능
- ⚠️ **복잡도 증가**: 데이터 동기화 복잡성

### 🔍 패턴 5: Event Sourcing - 이벤트 기반 상태 관리 (5분)

> **정의**: 상태 변경을 이벤트 스트림으로 저장하고 재생하여 현재 상태를 구성하는 패턴

**🏦 실생활 비유 - 은행 거래 내역**:
```mermaid
graph TB
    subgraph "🏦 은행 계좌 Event Sourcing"
        subgraph "📝 이벤트 스트림"
            E1[계좌개설: +0원]
            E2[입금: +100만원]
            E3[출금: -30만원]
            E4[입금: +50만원]
        end
        
        subgraph "📊 현재 상태"
            S[잔액: 120만원<br/>= 0 + 100 - 30 + 50]
        end
        
        E1 --> S
        E2 --> S
        E3 --> S
        E4 --> S
    end
    
    style E1 fill:#fff3e0
    style E2 fill:#fff3e0
    style E3 fill:#fff3e0
    style E4 fill:#fff3e0
    style S fill:#e8f5e8
```

**장점과 단점**:
- ✅ **완전한 감사 추적**: 모든 변경 이력 보존
- ✅ **시점별 상태 복원**: 과거 임의 시점 상태 재구성
- ⚠️ **복잡한 쿼리**: 현재 상태 조회 시 이벤트 재생 필요
- ⚠️ **스토리지 증가**: 모든 이벤트 영구 저장

---

## 🎯 패턴 조합 전략 (7분)

### 📊 실무 패턴 조합 사례

**Netflix 아키텍처**:
```mermaid
graph TB
    subgraph "Netflix 마이크로서비스"
        AG[API Gateway<br/>Zuul] --> CB[Circuit Breaker<br/>Hystrix]
        CB --> MS1[User Service]
        CB --> MS2[Content Service]
        CB --> MS3[Recommendation Service]
        
        MS1 --> ES[Event Store<br/>Kafka]
        MS2 --> ES
        MS3 --> ES
        
        ES --> CQRS[CQRS Views<br/>Cassandra]
    end
    
    style AG fill:#ff9800
    style CB fill:#f44336
    style MS1 fill:#4caf50
    style MS2 fill:#4caf50
    style MS3 fill:#4caf50
    style ES fill:#9c27b0
    style CQRS fill:#2196f3
```

**패턴 조합 가이드**:
1. **기본 조합**: API Gateway + Circuit Breaker
2. **트랜잭션 필요**: + Saga Pattern
3. **고성능 읽기**: + CQRS
4. **완전한 감사**: + Event Sourcing

### 💰 비용 대비 효과 분석

| 패턴 조합 | 개발 비용 | 운영 비용 | 성능 향상 | 안정성 향상 |
|----------|----------|----------|----------|------------|
| **Gateway + Circuit Breaker** | 💰💰 | 💰💰 | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **+ Saga** | 💰💰💰 | 💰💰💰 | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| **+ CQRS** | 💰💰💰💰 | 💰💰💰💰 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **+ Event Sourcing** | 💰💰💰💰💰 | 💰💰💰💰💰 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

---

## 🔑 핵심 키워드

- **API Gateway**: 단일 진입점, 라우팅, 인증/인가
- **Circuit Breaker**: 장애 전파 방지, 자동 복구
- **Saga Pattern**: 분산 트랜잭션, 보상 트랜잭션
- **CQRS**: Command Query Responsibility Segregation
- **Event Sourcing**: 이벤트 기반 상태 관리

---

## 📝 세션 마무리

### ✅ 오늘 세션 성과
- [ ] **5가지 핵심 패턴** 이해 및 적용 기준 습득
- [ ] **패턴 선택 매트릭스**로 상황별 최적 패턴 선택 능력
- [ ] **실무 사례**를 통한 패턴 조합 전략 이해
- [ ] **비용 대비 효과** 분석으로 현실적 적용 방안 도출

### 🎯 다음 실습 준비
- **모놀리스 분해**: 오늘 배운 패턴들을 실제 적용
- **통신 구현**: API Gateway, Circuit Breaker 직접 구현
- **Saga 패턴**: Step Functions를 이용한 분산 트랜잭션

### 💡 실무 적용 팁
1. **단계적 도입**: API Gateway → Circuit Breaker → Saga 순서
2. **측정 기반**: 성능과 안정성 지표로 패턴 효과 검증
3. **비용 고려**: 복잡한 패턴일수록 운영 비용 증가 고려
4. **팀 역량**: 팀의 기술 수준에 맞는 패턴 선택

---

<div align="center">

**🔧 실무 검증 패턴** • **⚖️ 명확한 선택 기준** • **📊 비용 효율성** • **🚀 점진적 적용**

*상황에 맞는 최적 패턴으로 안정적인 마이크로서비스 구축*

</div>
