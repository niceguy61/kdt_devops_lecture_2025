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

## 📖 이론적 기반과 핵심 개념 (25분)

### 📐 분산 시스템 패턴 이론 (8분)

**분산 시스템의 근본적 문제들**:
```
Byzantine Generals Problem (1982):
- 분산 환경에서의 합의 문제
- 일부 노드의 악의적/오류 행동 가능성
- 해결책: 2/3 이상의 정상 노드 필요

Two Generals Problem:
- 네트워크 통신의 불확실성
- 메시지 전달 보장 불가능
- 완벽한 해결책 존재하지 않음

결론: 분산 시스템은 본질적으로 불완전
→ 패턴을 통한 위험 완화 필요
```

**패턴 이론 (Pattern Theory)**:
```
Christopher Alexander의 패턴 언어 (1977):
- 반복되는 문제에 대한 검증된 해결책
- 컨텍스트 + 문제 + 해결책 + 결과

소프트웨어 패턴 적용:
- Gang of Four (GoF) 디자인 패턴 (1994)
- 엔터프라이즈 통합 패턴 (2003)
- 마이크로서비스 패턴 (2018)

패턴의 가치: 집단 지성의 결정체
```

### 🔍 통신 패턴 이론 (8분)

**동기 vs 비동기 통신 이론**:
```
동기 통신 (Synchronous):
- Blocking I/O: 응답 대기 중 스레드 블록
- 장점: 단순한 프로그래밍 모델
- 단점: 연쇄 장애 (Cascading Failure)
- 적용: 실시간 응답 필요, 강한 일관성

비동기 통신 (Asynchronous):
- Non-blocking I/O: 응답 대기 중 다른 작업 수행
- 장점: 높은 처리량, 장애 격리
- 단점: 복잡한 프로그래밍 모델
- 적용: 높은 처리량, 최종 일관성 허용
```

**메시지 패턴 분류**:
```
Request-Response Pattern: 1:1 동기 통신
Publish-Subscribe Pattern: 1:N 비동기 통신
Message Queue Pattern: 1:1 비동기 통신
```

### 🔍 장애 처리 패턴 이론 (9분)

**장애 모델 (Failure Models)**:
```
Crash Failure: 프로세스 중단 (감지 가능)
Omission Failure: 메시지 누락 (타임아웃으로 감지)
Byzantine Failure: 임의적 오동작 (가장 복잡)

장애 처리 전략:
- Fail-Fast: 빠른 실패 감지
- Fail-Safe: 안전한 상태로 전환
- Fail-Over: 대체 시스템으로 전환
```

**회복력 패턴 (Resilience Patterns)**:
```
Circuit Breaker Pattern:
- 전기 회로 차단기에서 영감
- 상태 기계: Closed → Open → Half-Open
- 장애 전파 방지

Bulkhead Pattern:
- 선박의 격벽에서 영감
- 리소스 격리로 장애 영향 범위 제한

Timeout Pattern:
- 무한 대기 방지
- 시스템 응답성 보장
```

**데이터 일관성 패턴 이론**:
```
일관성 모델 스펙트럼:
Strong Consistency → Weak Consistency

Saga 패턴의 이론적 기반:
- Long Running Transaction의 한계
- Compensating Transaction 개념
- 비즈니스적 보상 vs 기술적 롤백

Saga 수학적 모델:
T = T₁ → T₂ → ... → Tₙ (정상)
실패 시: T₁ → ... → Tₖ → Cₖ₋₁ → ... → C₁
```

---

## 📊 패턴 선택 매트릭스 (10분)

### 🎯 상황별 패턴 선택 가이드

| 상황 | 추천 패턴 | 복잡도 | 성능 영향 | 운영 부담 | 비용 |
|------|----------|--------|----------|----------|------|
| **외부 API 호출** | Circuit Breaker | ⭐⭐ | ⭐ | ⭐⭐ | 💰 |
| **여러 서비스 조합** | API Gateway | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | 💰💰 |
| **분산 트랜잭션** | Saga | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | 💰💰💰 |
| **읽기/쓰기 분리** | CQRS | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 💰💰💰💰 |
| **이벤트 기반 통신** | Event Sourcing | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 💰💰💰💰💰 |

---

## 📖 핵심 패턴과 산업별 적용 사례 (25분)

### 🔍 패턴 1: API Gateway - 단일 진입점 (8분)

> **정의**: 모든 클라이언트 요청을 받아 적절한 마이크로서비스로 라우팅하는 패턴

#### 🏦 금융업 사례: "FinanceBank" 디지털 뱅킹

**비즈니스 요구사항**:
- 웹/모바일/ATM 다양한 채널 지원
- 강력한 보안 및 인증 필요
- 거래별 로깅 및 감사 추적

```mermaid
graph TB
    subgraph "클라이언트"
        WEB[🌐 인터넷 뱅킹]
        MOBILE[📱 모바일 앱]
        ATM[🏧 ATM]
        PARTNER[🤝 제휴사 API]
    end
    
    subgraph "API Gateway Layer"
        APIGW[API Gateway<br/>- 인증/인가<br/>- 요청 라우팅<br/>- 거래 로깅<br/>- Rate Limiting]
        WAF[Web Application Firewall]
        OAUTH[OAuth 2.0 Server]
    end
    
    subgraph "Banking Microservices"
        ACCOUNT[💰 Account Service<br/>계좌 관리]
        TRANSFER[💸 Transfer Service<br/>이체 서비스]
        LOAN[🏠 Loan Service<br/>대출 서비스]
        CARD[💳 Card Service<br/>카드 서비스]
        FRAUD[🛡️ Fraud Detection<br/>이상거래 탐지]
    end
    
    WEB --> WAF
    MOBILE --> WAF
    ATM --> WAF
    PARTNER --> WAF
    
    WAF --> APIGW
    APIGW --> OAUTH
    
    APIGW --> ACCOUNT
    APIGW --> TRANSFER
    APIGW --> LOAN
    APIGW --> CARD
    
    TRANSFER --> FRAUD
    
    style APIGW fill:#ff6b6b
    style ACCOUNT fill:#4ecdc4
    style TRANSFER fill:#45b7d1
    style LOAN fill:#96ceb4
    style CARD fill:#feca57
    style FRAUD fill:#ff9ff3
```

**핵심 구현 요소**:
```yaml
API Gateway 기능:
  인증/인가:
    - JWT 토큰 검증
    - OAuth 2.0 통합
    - 2FA (Two-Factor Authentication)
  
  라우팅 규칙:
    - /api/v1/accounts/* → Account Service
    - /api/v1/transfers/* → Transfer Service
    - /api/v1/loans/* → Loan Service
  
  보안 정책:
    - Rate Limiting: 사용자당 분당 100회
    - IP 화이트리스트
    - 거래 금액별 추가 인증
  
  감사 로깅:
    - 모든 거래 요청/응답 로깅
    - 개인정보 마스킹
    - 실시간 이상 거래 알림
```

#### 🛒 이커머스 사례: "GlobalMart" 글로벌 쇼핑몰

```mermaid
graph TB
    subgraph "Multi-Channel Clients"
        WEB[🌐 웹사이트]
        MOBILE[📱 모바일 앱]
        VOICE[🎤 음성 주문<br/>Alexa/Google]
        B2B[🏢 B2B 파트너]
    end
    
    subgraph "API Gateway Cluster"
        APIGW_US[API Gateway US<br/>- 지역별 라우팅<br/>- 다국어 지원<br/>- 통화 변환]
        APIGW_EU[API Gateway EU]
        APIGW_ASIA[API Gateway ASIA]
    end
    
    subgraph "E-commerce Services"
        CATALOG[📦 Catalog Service<br/>상품 카탈로그]
        CART[🛒 Cart Service<br/>장바구니]
        ORDER[📋 Order Service<br/>주문 처리]
        PAYMENT[💳 Payment Service<br/>결제 처리]
        SHIPPING[🚚 Shipping Service<br/>배송 관리]
        RECOMMEND[🎯 Recommendation<br/>개인화 추천]
    end
    
    WEB --> APIGW_US
    MOBILE --> APIGW_EU
    VOICE --> APIGW_ASIA
    B2B --> APIGW_US
    
    APIGW_US --> CATALOG
    APIGW_US --> CART
    APIGW_US --> ORDER
    APIGW_EU --> PAYMENT
    APIGW_ASIA --> SHIPPING
    APIGW_US --> RECOMMEND
    
    style APIGW_US fill:#ff6b6b
    style APIGW_EU fill:#ff6b6b
    style APIGW_ASIA fill:#ff6b6b
    style CATALOG fill:#4ecdc4
    style CART fill:#45b7d1
    style ORDER fill:#96ceb4
```

### 🔍 패턴 2: Circuit Breaker - 장애 전파 방지 (8분)

#### 🎬 스트리밍 서비스 사례: "StreamFlix" 동영상 플랫폼

**비즈니스 요구사항**:
- 99.99% 가용성 필요
- 외부 CDN 및 결제 서비스 의존
- 피크 시간 트래픽 급증 대응

```mermaid
graph TB
    subgraph "StreamFlix Architecture"
        subgraph "Core Services"
            USER[👤 User Service<br/>사용자 관리]
            CONTENT[🎬 Content Service<br/>콘텐츠 관리]
            STREAM[📺 Streaming Service<br/>스트리밍 엔진]
            BILLING[💰 Billing Service<br/>구독 관리]
        end
        
        subgraph "Circuit Breaker Layer"
            CB_CDN[🔌 CDN Circuit Breaker<br/>- 임계값: 5회 실패<br/>- 타임아웃: 30초<br/>- 복구: 점진적]
            CB_PAY[🔌 Payment Circuit Breaker<br/>- 임계값: 3회 실패<br/>- 타임아웃: 60초<br/>- 폴백: 나중에 결제]
            CB_REC[🔌 Recommendation CB<br/>- 임계값: 10회 실패<br/>- 폴백: 인기 콘텐츠]
        end
        
        subgraph "External Services"
            CDN[☁️ CDN Provider<br/>콘텐츠 전송]
            PAYMENT[💳 Payment Gateway<br/>결제 처리]
            ML[🤖 ML Recommendation<br/>추천 엔진]
        end
        
        subgraph "Fallback Services"
            CACHE[💾 Content Cache<br/>로컬 캐시]
            POPULAR[📈 Popular Content<br/>인기 콘텐츠]
            RETRY[🔄 Retry Queue<br/>재시도 큐]
        end
    end
    
    STREAM --> CB_CDN --> CDN
    BILLING --> CB_PAY --> PAYMENT
    CONTENT --> CB_REC --> ML
    
    CB_CDN -.-> CACHE
    CB_PAY -.-> RETRY
    CB_REC -.-> POPULAR
    
    style CB_CDN fill:#f44336
    style CB_PAY fill:#f44336
    style CB_REC fill:#f44336
    style CACHE fill:#4caf50
    style POPULAR fill:#4caf50
    style RETRY fill:#4caf50
```

**Circuit Breaker 설정**:
```yaml
CDN Circuit Breaker:
  실패 임계값: 5회 연속 실패
  타임아웃: 30초
  복구 전략: 점진적 트래픽 증가 (10% → 50% → 100%)
  폴백 동작: 로컬 캐시에서 콘텐츠 제공
  
Payment Circuit Breaker:
  실패 임계값: 3회 연속 실패
  타임아웃: 60초
  폴백 동작: "나중에 결제" 큐에 저장
  알림: 즉시 운영팀에 알림 발송
  
Recommendation Circuit Breaker:
  실패 임계값: 10회 연속 실패
  타임아웃: 15초
  폴백 동작: 인기 콘텐츠 목록 반환
  성능 영향: 사용자 경험 저하 최소화
```

### 🔍 패턴 3: Saga - 분산 트랜잭션 관리 (9분)

#### 🚗 모빌리티 서비스 사례: "RideShare" 차량 공유

**비즈니스 요구사항**:
- 실시간 차량 매칭
- 복잡한 요금 계산
- 다중 결제 수단 지원

```mermaid
sequenceDiagram
    participant U as 👤 User App
    participant RS as 🚗 Ride Service
    participant DS as 🚙 Driver Service
    participant PS as 💳 Payment Service
    participant NS as 📱 Notification Service
    participant WS as 💰 Wallet Service
    
    Note over U,WS: 승차 요청 Saga (Orchestration)
    
    U->>RS: 1. 승차 요청
    RS->>DS: 2. 드라이버 매칭 요청
    DS->>RS: 3. 매칭 성공 (Driver ID)
    RS->>PS: 4. 예상 요금 사전 승인
    PS->>WS: 5. 지갑 잔액 확인
    WS->>PS: 6. 잔액 충분 (Hold)
    PS->>RS: 7. 사전 승인 완료
    RS->>NS: 8. 드라이버/승객 알림
    NS->>U: 9. 매칭 완료 알림
    
    Note over U,WS: 승차 완료 후 결제 Saga
    
    U->>RS: 10. 승차 완료 신호
    RS->>PS: 11. 최종 요금 결제 요청
    PS->>WS: 12. Hold 금액 실제 차감
    WS->>PS: 13. 결제 완료
    PS->>DS: 14. 드라이버 정산 처리
    DS->>NS: 15. 정산 완료 알림
    
    Note over U,WS: 실패 시나리오 (드라이버 취소)
    
    DS-->>RS: ❌ 드라이버 취소
    RS-->>PS: 🔄 사전 승인 취소
    PS-->>WS: 🔄 Hold 금액 해제
    WS-->>PS: ✅ 해제 완료
    PS-->>RS: ✅ 취소 완료
    RS-->>NS: 📢 취소 알림 발송
```

**Saga 패턴 구현**:
```yaml
Ride Booking Saga:
  단계:
    1. 승차 요청 생성
    2. 드라이버 매칭
    3. 요금 사전 승인
    4. 알림 발송
  
  보상 트랜잭션:
    1. 승차 요청 취소
    2. 드라이버 매칭 해제
    3. 사전 승인 취소
    4. 취소 알림 발송
  
  타임아웃 정책:
    - 드라이버 매칭: 5분
    - 결제 승인: 30초
    - 전체 Saga: 10분
```

#### 🏥 헬스케어 사례: "MediCare" 의료 예약 시스템

```mermaid
sequenceDiagram
    participant P as 👨‍⚕️ Patient App
    participant AS as 📅 Appointment Service
    participant DS as 👩‍⚕️ Doctor Service
    participant HS as 🏥 Hospital Service
    participant IS as 🛡️ Insurance Service
    participant BS as 💊 Billing Service
    
    Note over P,BS: 의료 예약 Saga (Choreography)
    
    P->>AS: 1. 예약 요청
    AS->>DS: 2. 의사 스케줄 확인
    DS->>AS: 3. 예약 가능 시간 반환
    AS->>HS: 4. 병원 시설 예약
    HS->>AS: 5. 시설 예약 완료
    AS->>IS: 6. 보험 적용 확인
    IS->>AS: 7. 보험 승인 (사전 승인번호)
    AS->>BS: 8. 예상 비용 계산
    BS->>AS: 9. 비용 정보 반환
    AS->>P: 10. 예약 확정 및 비용 안내
    
    Note over P,BS: 예약 취소 시나리오
    
    P-->>AS: ❌ 예약 취소 요청
    AS-->>DS: 🔄 의사 스케줄 복원
    AS-->>HS: 🔄 시설 예약 취소
    AS-->>IS: 🔄 보험 사전승인 취소
    AS-->>BS: 🔄 비용 계산 무효화
    AS-->>P: ✅ 취소 완료 확인
```

### 🔍 패턴 4: CQRS - 읽기/쓰기 분리 (실시간 분석이 중요한 산업) (5분)

#### 📊 핀테크 사례: "TradingPro" 주식 거래 플랫폼

```mermaid
graph TB
    subgraph "Trading Platform CQRS"
        subgraph "Command Side (거래 실행)"
            TC[📈 Trading Command<br/>주문 접수]
            OE[⚡ Order Engine<br/>주문 매칭]
            PS[💰 Position Service<br/>포지션 관리]
            WRITE_DB[(📊 Write DB<br/>PostgreSQL<br/>ACID 보장)]
        end
        
        subgraph "Query Side (실시간 조회)"
            MD[📊 Market Data<br/>시장 데이터]
            PF[💼 Portfolio View<br/>포트폴리오 조회]
            AN[📈 Analytics<br/>실시간 분석]
            READ_DB[(🚀 Read DB<br/>ClickHouse<br/>실시간 분석 최적화)]
        end
        
        subgraph "Event Streaming"
            KAFKA[📨 Kafka<br/>이벤트 스트림]
        end
        
        subgraph "Real-time Processing"
            SPARK[⚡ Spark Streaming<br/>실시간 처리]
            REDIS[💾 Redis<br/>실시간 캐시]
        end
    end
    
    TC --> OE
    OE --> PS
    PS --> WRITE_DB
    
    WRITE_DB --> KAFKA
    KAFKA --> SPARK
    SPARK --> READ_DB
    SPARK --> REDIS
    
    READ_DB --> MD
    READ_DB --> PF
    READ_DB --> AN
    
    REDIS --> MD
    
    style TC fill:#ffebee
    style OE fill:#ffebee
    style PS fill:#ffebee
    style MD fill:#e8f5e8
    style PF fill:#e8f5e8
    style AN fill:#e8f5e8
    style KAFKA fill:#fff3e0
    style SPARK fill:#e3f2fd
```

**CQRS 구현 세부사항**:
```yaml
Command Side (쓰기):
  - 주문 접수 및 검증
  - 실시간 매칭 엔진
  - 포지션 업데이트
  - 강한 일관성 (ACID)
  
Query Side (읽기):
  - 실시간 차트 데이터
  - 포트폴리오 현황
  - 수익률 분석
  - 최종 일관성 (수초 지연 허용)
  
성능 최적화:
  - 쓰기: 초당 10만 건 주문 처리
  - 읽기: 밀리초 단위 응답시간
  - 캐싱: Redis로 핫 데이터 캐싱
```

---

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

## 🎯 산업별 패턴 조합 전략 (10분)

### 📊 산업별 패턴 적용 매트릭스

| 산업군 | 주요 패턴 | 핵심 요구사항 | 아키텍처 특징 |
|--------|----------|---------------|---------------|
| **🏦 금융** | API Gateway + Circuit Breaker + Saga | 보안, 규제준수, 정확성 | 강한 일관성, 감사 추적 |
| **🛒 이커머스** | API Gateway + CQRS + Event Sourcing | 확장성, 개인화, 글로벌 | 최종 일관성, 높은 처리량 |
| **🎬 미디어** | Circuit Breaker + CDN + Cache | 가용성, 성능, 글로벌 배포 | 지역별 분산, 캐싱 중심 |
| **🚗 모빌리티** | Saga + Event-Driven + Real-time | 실시간성, 위치기반, 매칭 | 이벤트 기반, 지리적 분산 |
| **🏥 헬스케어** | Saga + RBAC + Audit | 규제준수, 개인정보보호 | 강한 보안, 완전한 감사 |
| **🎮 게임** | Event Sourcing + CQRS + Cache | 실시간성, 상태 관리 | 이벤트 기반, 빠른 응답 |

### 🏗️ 통합 아키텍처 예시: "SuperApp" 슈퍼앱

**비즈니스 요구사항**: 금융 + 이커머스 + 모빌리티 통합 서비스

```mermaid
graph TB
    subgraph "SuperApp Unified Architecture"
        subgraph "API Gateway Cluster"
            APIGW_MAIN[🌐 Main API Gateway<br/>- 통합 인증<br/>- 서비스 라우팅<br/>- 크로스 서비스 보안]
        end
        
        subgraph "Financial Services"
            BANK[🏦 Banking Service]
            PAY[💳 Payment Service]
            INVEST[📈 Investment Service]
            CB_FIN[🔌 Financial CB]
        end
        
        subgraph "Commerce Services"
            SHOP[🛒 Shopping Service]
            DELIVERY[🚚 Delivery Service]
            CQRS_SHOP[📊 Shopping Analytics]
        end
        
        subgraph "Mobility Services"
            RIDE[🚗 Ride Service]
            MAP[🗺️ Map Service]
            SAGA_RIDE[🔄 Ride Saga]
        end
        
        subgraph "Shared Services"
            USER[👤 User Service]
            NOTIF[📱 Notification]
            ANALYTICS[📊 Analytics]
        end
        
        subgraph "Data & Events"
            KAFKA[📨 Event Stream]
            REDIS[💾 Real-time Cache]
            DW[🏢 Data Warehouse]
        end
    end
    
    APIGW_MAIN --> BANK
    APIGW_MAIN --> SHOP
    APIGW_MAIN --> RIDE
    
    BANK --> CB_FIN
    SHOP --> CQRS_SHOP
    RIDE --> SAGA_RIDE
    
    BANK --> KAFKA
    SHOP --> KAFKA
    RIDE --> KAFKA
    
    KAFKA --> ANALYTICS
    KAFKA --> DW
    
    USER --> REDIS
    NOTIF --> REDIS
    
    style APIGW_MAIN fill:#ff6b6b
    style CB_FIN fill:#f44336
    style CQRS_SHOP fill:#2196f3
    style SAGA_RIDE fill:#4caf50
    style KAFKA fill:#ff9800
```

**패턴 조합 전략**:
```yaml
Cross-Service Patterns:
  API Gateway:
    - 통합 인증 (SSO)
    - 서비스 간 라우팅
    - 크로스 도메인 보안
  
  Event-Driven Integration:
    - 서비스 간 느슨한 결합
    - 실시간 데이터 동기화
    - 크로스 서비스 분석
  
  Shared Data Strategy:
    - User Profile 공유
    - 통합 알림 시스템
    - 크로스 서비스 추천

Service-Specific Patterns:
  Financial: Circuit Breaker + Saga
  Commerce: CQRS + Event Sourcing  
  Mobility: Saga + Real-time Processing
```

### 💡 패턴 선택 가이드라인

**1. 비즈니스 특성 기반 선택**:
```
높은 정확성 요구 → Saga Pattern
실시간 분석 필요 → CQRS Pattern
외부 의존성 많음 → Circuit Breaker
다양한 클라이언트 → API Gateway
완전한 감사 필요 → Event Sourcing
```

**2. 기술적 제약 고려**:
```
팀 규모 < 10명 → 단순한 패턴 (API Gateway + Circuit Breaker)
팀 규모 > 20명 → 복합 패턴 (CQRS + Event Sourcing + Saga)
레거시 시스템 → 점진적 패턴 도입
클라우드 네이티브 → 모든 패턴 활용 가능
```

**3. 운영 복잡도 관리**:
```
패턴 복잡도 순서:
API Gateway < Circuit Breaker < Saga < CQRS < Event Sourcing

권장 도입 순서:
1단계: API Gateway + Circuit Breaker
2단계: + Saga Pattern  
3단계: + CQRS (필요시)
4단계: + Event Sourcing (고급 요구사항)
```

---

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
