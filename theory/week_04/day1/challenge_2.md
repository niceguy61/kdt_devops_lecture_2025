# Week 4 Day 1 Challenge 2: 마이크로서비스 아키텍처 설계

<div align="center">

**🏗️ 아키텍처 설계** • **🎯 기술 선택** • **💡 트레이드오프 분석**

*실무 시나리오 기반 마이크로서비스 아키텍처 설계 과제*

</div>

---

## 🎯 미션: 차량 공유 서비스 "CloudRide" 아키텍처 재설계

### 📖 시나리오

당신은 차량 공유 스타트업 "CloudRide"의 새로운 시니어 아키텍트로 합류했습니다.

**현재 상황:**
- 기존 아키텍트가 "최신 기술"만 추구하여 과도하게 복잡한 시스템 구축
- 월 클라우드 비용 $50,000 (실제 트래픽 대비 10배 과다)
- 신입 개발자들이 시스템 이해 못함 (러닝커브 6개월+)
- 배포 한 번에 3시간 소요
- 장애 발생 시 원인 파악 불가능

**당신의 임무:**
기존의 과도하게 복잡한 아키텍처를 분석하고, 
**실용적이고 비용 효율적인** 아키텍처로 재설계하세요.

---

## 🚨 기존 아키텍처 (안티패턴 예시)

### ❌ 문제투성이 아키텍처

```mermaid
graph TB
    subgraph "CDN Layer - $5,000/월"
        CDN1[Cloudflare]
        CDN2[AWS CloudFront]
    end
    
    subgraph "API Gateway - $3,100/월"
        GW1[Kong Enterprise<br/>$3,000/월]
        GW2[AWS API Gateway<br/>$100/월]
    end
    
    subgraph "Frontend - 3개 프레임워크"
        F1[Angular 15<br/>관리자용]
        F2[React 18<br/>사용자용]
        F3[Vue 3 + Nuxt<br/>드라이버용]
    end
    
    subgraph "Backend - 10개 언어"
        B1[User: Scala]
        B2[Auth: Haskell]
        B3[Profile: Elixir]
        B4[Ride: Rust]
        B5[Payment: Java]
        B6[Location: C++]
        B7[Notification: Erlang]
        B8[Analytics: Python]
        B9[Rating: Ruby]
    end
    
    subgraph "Database - $20,000/월"
        D1[PostgreSQL<br/>6개 인스턴스]
        D2[MongoDB<br/>샤딩 + 3 Replicas]
        D3[Cassandra<br/>9 nodes<br/>$15,000/월]
    end
    
    subgraph "Cache - 3개 시스템"
        C1[Redis Cluster<br/>6 nodes]
        C2[Memcached]
        C3[Hazelcast]
    end
    
    subgraph "Message Queue - 3개 시스템"
        Q1[RabbitMQ Cluster]
        Q2[Kafka<br/>9 brokers]
        Q3[AWS SQS]
    end
    
    subgraph "Monitoring - $8,000/월"
        M1[Prometheus]
        M2[Grafana]
        M3[ELK Stack]
        M4[Datadog]
        M5[New Relic]
    end
    
    CDN1 --> GW1
    CDN2 --> GW2
    GW1 --> F1
    GW1 --> F2
    GW2 --> F3
    
    F1 --> B1
    F2 --> B2
    F3 --> B3
    
    B1 --> D1
    B2 --> D2
    B3 --> D3
    B4 --> C1
    B5 --> C2
    B6 --> C3
    B7 --> Q1
    B8 --> Q2
    B9 --> Q3
    
    style CDN1 fill:#f44336
    style CDN2 fill:#f44336
    style GW1 fill:#f44336
    style GW2 fill:#f44336
    style D3 fill:#f44336
    style Q2 fill:#f44336
    style M4 fill:#f44336
    style M5 fill:#f44336
```

**총 비용: $50,000/월**

### 🔥 주요 문제점

1. **과도한 기술 스택**: 10개 언어 (Scala, Haskell, Elixir, Rust, C++, Erlang, Ruby...)
2. **중복 인프라**: API Gateway 2개, 캐시 3개, 큐 3개
3. **과도한 DB**: Cassandra 9 노드 ($15,000/월), PostgreSQL 6개
4. **모니터링 중복**: 5개 도구 ($8,000/월)
5. **운영 복잡도**: 배포 3시간, 장애 원인 파악 불가

---

## 🎯 당신의 임무

### 1. 문제점 분석 (필수)
기존 아키텍처의 문제점을 구체적으로 분석하세요.

**분석 항목:**
- 불필요한 기술 스택
- 중복된 인프라
- 비용 낭비 요소
- 운영 복잡도 증가 원인

### 2. 개선된 아키텍처 설계 (필수)
실용적이고 비용 효율적인 아키텍처를 설계하세요.

**설계 원칙:**
- **단순성**: 꼭 필요한 기술만 사용
- **비용 효율**: 월 $10,000 이하 목표
- **유지보수성**: 신입도 2주 내 이해 가능
- **확장성**: 트래픽 10배 증가 대응 가능

### 3. 기술 선택 정당화 (필수)
왜 이 기술을 선택했는지 명확히 설명하세요.

**설명 항목:**
- 선택 이유
- 대안 기술과의 비교
- 트레이드오프
- 비용 분석

---

## 🃏 기술 스택 선택 카드

### 🎨 Frontend

```mermaid
graph TB
    subgraph col1[" "]
        A[React.js]
        B[Vue.js]
        C[Next.js]
        D[Angular]
    end
    
    subgraph col2[" "]
        E[Svelte]
        F[Solid.js]
        G[Qwik]
        H[Astro]
    end
    
    style A fill:#e3f2fd
    style B fill:#e3f2fd
    style C fill:#e3f2fd
    style D fill:#e3f2fd
    style E fill:#e3f2fd
    style F fill:#e3f2fd
    style G fill:#e3f2fd
    style H fill:#e3f2fd
```

### ⚙️ Backend

```mermaid
graph TB
    subgraph col1[" "]
        A[Node.js]
        B[Python]
        C[Go]
        D[Java Spring]
        E[Rust]
    end
    
    subgraph col2[" "]
        F[.NET Core]
        G[PHP Laravel]
        H[Ruby Rails]
        I[Elixir]
        J[Scala]
    end
    
    style A fill:#e8f5e8
    style B fill:#e8f5e8
    style C fill:#e8f5e8
    style D fill:#e8f5e8
    style E fill:#e8f5e8
    style F fill:#e8f5e8
    style G fill:#e8f5e8
    style H fill:#e8f5e8
    style I fill:#e8f5e8
    style J fill:#e8f5e8
```

### 💾 Database

```mermaid
graph TB
    subgraph col1[" "]
        A[PostgreSQL]
        B[MySQL]
        C[MongoDB]
        D[Cassandra]
        E[DynamoDB]
    end
    
    subgraph col2[" "]
        F[CockroachDB]
        G[Redis]
        H[Neo4j]
        I[InfluxDB]
    end
    
    style A fill:#fff3e0
    style B fill:#fff3e0
    style C fill:#fff3e0
    style D fill:#fff3e0
    style E fill:#fff3e0
    style F fill:#fff3e0
    style G fill:#fff3e0
    style H fill:#fff3e0
    style I fill:#fff3e0
```

### ⚡ Cache

```mermaid
graph TB
    subgraph col1[" "]
        A[Redis]
        B[Memcached]
        C[Hazelcast]
    end
    
    subgraph col2[" "]
        D[Varnish]
        E[Apache Ignite]
    end
    
    style A fill:#f3e5f5
    style B fill:#f3e5f5
    style C fill:#f3e5f5
    style D fill:#f3e5f5
    style E fill:#f3e5f5
```

### 📨 Message Queue

```mermaid
graph TB
    subgraph col1[" "]
        A[RabbitMQ]
        B[Kafka]
        C[AWS SQS]
        D[Redis Streams]
    end
    
    subgraph col2[" "]
        E[NATS]
        F[ActiveMQ]
        G[Pulsar]
    end
    
    style A fill:#ffebee
    style B fill:#ffebee
    style C fill:#ffebee
    style D fill:#ffebee
    style E fill:#ffebee
    style F fill:#ffebee
    style G fill:#ffebee
```

### 📊 Monitoring

```mermaid
graph TB
    subgraph col1[" "]
        A[Prometheus<br/>+ Grafana]
        B[Datadog]
        C[ELK Stack]
    end
    
    subgraph col2[" "]
        D[New Relic]
        E[Dynatrace]
        F[AppDynamics]
    end
    
    style A fill:#e0f2f1
    style B fill:#e0f2f1
    style C fill:#e0f2f1
    style D fill:#e0f2f1
    style E fill:#e0f2f1
    style F fill:#e0f2f1
```

### 🔍 Search Engine

```mermaid
graph TB
    subgraph col1[" "]
        A[Elasticsearch]
        B[OpenSearch]
        C[Algolia]
    end
    
    subgraph col2[" "]
        D[Meilisearch]
        E[Typesense]
    end
    
    style A fill:#fce4ec
    style B fill:#fce4ec
    style C fill:#fce4ec
    style D fill:#fce4ec
    style E fill:#fce4ec
```

### 🔐 API Gateway

```mermaid
graph TB
    subgraph col1[" "]
        A[AWS API Gateway]
        B[Kong]
        C[Nginx]
    end
    
    subgraph col2[" "]
        D[Traefik]
        E[Envoy]
        F[Tyk]
    end
    
    style A fill:#f1f8e9
    style B fill:#f1f8e9
    style C fill:#f1f8e9
    style D fill:#f1f8e9
    style E fill:#f1f8e9
    style F fill:#f1f8e9
```

---


## 📝 제출 양식

### 1. 문제점 분석 (필수)

```markdown
## 🚨 기존 아키텍처 문제점 분석

### 1. [문제 카테고리]
**문제:**
- [구체적인 문제점]

**영향:**
- [비즈니스/기술적 영향]

**개선 방안:**
- [해결 방법]
```

### 2. 개선 아키텍처 (필수)

```mermaid
graph TB
    subgraph "Layer 1"
        A[Service A]
    end
    
    A --> B[Service B]
```

**총 비용: $X,XXX/월**

### 3. 기술 선택 이유 (필수)

```markdown
### [기술명]: [선택한 것]
**선택 이유:**
- [이유]

**비교:**
| 항목 | 선택 | 대안 |
|------|------|------|
| 항목 | 값 | 값 |

**트레이드오프:**
- [장단점]
```

### 4. 마이크로서비스 설계 (필수)

```markdown
### [Service Name]
**책임:** [역할]
**기술:** [스택]
**API:** [엔드포인트]
```

### 5. 비용 분석 (필수)

```markdown
| 항목 | 기존 | 개선 | 절감 |
|------|------|------|------|
| 총계 | $50,000 | $X,XXX | $XX,XXX |
```

---

## 🎯 평가 기준

### 문제점 분석 (25점)
- [ ] 기존 아키텍처의 문제점 정확히 파악
- [ ] 비용 낭비 요소 구체적 분석
- [ ] 운영 복잡도 증가 원인 이해
- [ ] 개선 방향 명확히 제시

### 아키텍처 설계 (30점)
- [ ] 실용적이고 단순한 설계
- [ ] 비용 효율적인 기술 선택
- [ ] 확장 가능한 구조
- [ ] 마이크로서비스 적절한 분할

### 기술 선택 정당화 (25점)
- [ ] 선택 이유 명확한 설명
- [ ] 대안 기술과의 비교
- [ ] 트레이드오프 이해
- [ ] 비용 분석 포함

### 실무 적용 가능성 (20점)
- [ ] 현실적인 해결책
- [ ] 팀 역량 고려
- [ ] 유지보수 용이성
- [ ] 점진적 마이그레이션 계획

---

## 💡 힌트 및 가이드

### 설계 원칙
1. **KISS (Keep It Simple, Stupid)**
   - 복잡한 것보다 단순한 것이 낫다
   - 꼭 필요한 기술만 사용

2. **YAGNI (You Aren't Gonna Need It)**
   - 미래를 위한 과도한 준비 금지
   - 현재 필요한 것만 구현

3. **Cost-Conscious Design**
   - 모든 기술 선택에 비용 고려
   - 무료 오픈소스 우선 검토

4. **Team Capability**
   - 팀이 사용할 수 있는 기술 선택
   - 러닝커브 최소화

### 흔한 실수
❌ **하지 말아야 할 것:**
- 최신 기술이라고 무조건 사용
- 트래픽 대비 과도한 인프라
- 중복된 기능의 도구 여러 개
- 팀이 모르는 언어/프레임워크

✅ **해야 할 것:**
- 검증된 기술 스택 사용
- 현재 트래픽에 맞는 크기
- 하나의 도구로 통합
- 팀 전체가 사용 가능한 기술

---

## 🤝 팀 발표 (선택)

### 발표 형식 (팀당 15분)
1. **문제점 분석** (5분)
   - 기존 아키텍처의 주요 문제
   - 비용 낭비 요소

2. **개선 아키텍처** (7분)
   - 새로운 설계 소개
   - 기술 선택 이유
   - 비용 절감 효과

3. **Q&A** (3분)
   - 질문 및 답변
   - 피드백 수렴

### 상호 피드백
- 다른 팀의 좋은 아이디어
- 개선 제안
- 배운 점

---

<div align="center">

**🏗️ 실용적 설계** • **💰 비용 효율** • **🎯 단순성** • **🚀 확장성**

*과도한 복잡성을 제거하고 실용적인 아키텍처를 설계하세요*

</div>
