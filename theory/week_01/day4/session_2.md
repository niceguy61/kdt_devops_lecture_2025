# Week 1 Day 4 Session 2: 멀티 컨테이너 아키텍처 설계

<div align="center">

**🏗️ 아키텍처 설계 패턴** • **확장 가능한 시스템**

*실무에서 사용하는 멀티 컨테이너 아키텍처 패턴*

</div>

---

## 🕘 세션 정보

**시간**: 10:00-10:50 (50분)  
**목표**: 실무에서 사용하는 멀티 컨테이너 아키텍처 패턴 이해  
**방식**: 아키텍처 분석 + 설계 실습 + 팀 토론

---

## 🎯 세션 목표

### 📚 학습 목표
- **이해 목표**: 실무에서 사용하는 멀티 컨테이너 아키텍처 패턴 이해
- **적용 목표**: 확장 가능하고 유지보수가 용이한 아키텍처 설계 능력
- **협업 목표**: 페어 토론을 통한 아키텍처 설계 및 트레이드오프 분석

### 🤔 왜 필요한가? (5분)

**아키텍처 설계의 중요성**:
- 💼 **확장성**: 트래픽 증가에 대응할 수 있는 구조
- 🏠 **일상 비유**: 건물 설계처럼 기초가 탄탄해야 함
- 📊 **유지보수**: 장기적으로 관리하기 쉬운 구조

---

## 📖 핵심 개념 (35분)

### 🔍 개념 1: 3-Tier 아키텍처 (12분)

> **정의**: 프레젠테이션, 비즈니스 로직, 데이터 계층으로 분리된 구조

**3-Tier 구조**:
```mermaid
graph TB
    subgraph "Presentation Tier"
        A[Nginx<br/>Load Balancer] --> B[React Frontend]
    end
    
    subgraph "Application Tier"
        C[Node.js API 1] 
        D[Node.js API 2]
        E[Python Worker]
    end
    
    subgraph "Data Tier"
        F[PostgreSQL<br/>Primary DB]
        G[Redis<br/>Cache]
        H[MongoDB<br/>Document Store]
    end
    
    A --> C
    A --> D
    C --> F
    C --> G
    D --> F
    D --> G
    E --> H
    
    style A,B fill:#e3f2fd
    style C,D,E fill:#fff3e0
    style F,G,H fill:#e8f5e8
```

**각 계층의 역할**:
- **Presentation**: 사용자 인터페이스, 로드 밸런싱
- **Application**: 비즈니스 로직, API 서버
- **Data**: 데이터 저장, 캐싱, 검색

### 🔍 개념 2: 마이크로서비스 패턴 (12분)

> **정의**: 각 서비스가 독립적으로 배포되고 확장되는 아키텍처

**마이크로서비스 구조**:
```mermaid
graph TB
    A[API Gateway] --> B[User Service]
    A --> C[Product Service]
    A --> D[Order Service]
    A --> E[Payment Service]
    
    B --> F[User DB]
    C --> G[Product DB]
    D --> H[Order DB]
    E --> I[Payment DB]
    
    J[Message Queue] --> B
    J --> C
    J --> D
    J --> E
    
    style A fill:#e3f2fd
    style B,C,D,E fill:#fff3e0
    style F,G,H,I fill:#e8f5e8
    style J fill:#f3e5f5
```

**마이크로서비스 장점**:
- **독립 배포**: 각 서비스별 독립적 배포
- **기술 다양성**: 서비스별 최적 기술 스택 선택
- **확장성**: 필요한 서비스만 스케일링
- **장애 격리**: 한 서비스 장애가 전체에 영향 최소화

### 🔍 개념 3: 모니터링과 로깅 통합 (11분)

> **정의**: 멀티 컨테이너 환경에서의 관측성 확보 방안

**관측성 스택**:
```mermaid
graph TB
    subgraph "애플리케이션 컨테이너들"
        A[Web App 1] --> D[Fluentd<br/>로그 수집]
        B[Web App 2] --> D
        C[API Server] --> D
    end
    
    subgraph "모니터링 스택"
        D --> E[Elasticsearch<br/>로그 저장]
        E --> F[Kibana<br/>로그 시각화]
        
        A --> G[Prometheus<br/>메트릭 수집]
        B --> G
        C --> G
        G --> H[Grafana<br/>메트릭 시각화]
    end
    
    style A,B,C fill:#e8f5e8
    style D,E,F fill:#fff3e0
    style G,H fill:#e3f2fd
```

**모니터링 구성 요소**:
- **로그 수집**: Fluentd, Logstash
- **로그 저장**: Elasticsearch, Loki
- **로그 시각화**: Kibana, Grafana
- **메트릭 수집**: Prometheus, InfluxDB
- **알림**: Alertmanager, PagerDuty

---

## 💭 함께 생각해보기 (10분)

### 🤝 페어 토론 (7분)
**토론 주제**:
1. **아키텍처 선택**: "3-Tier vs 마이크로서비스, 언제 어떤 것을 선택할까요?"
2. **확장성 고려**: "트래픽이 증가할 때 어떤 부분을 먼저 확장해야 할까요?"
3. **모니터링 전략**: "멀티 컨테이너 환경에서 꼭 필요한 모니터링은?"

### 🎯 전체 공유 (3분)
- **아키텍처 패턴**: 상황별 최적 아키텍처 선택 기준
- **확장 전략**: 효과적인 스케일링 방안

---

## 🔑 핵심 키워드

### 아키텍처 패턴
- **3-Tier Architecture**: 계층형 아키텍처
- **Microservices**: 마이크로서비스 아키텍처
- **API Gateway**: 서비스 진입점 통합
- **Load Balancer**: 부하 분산 장치

### 확장성 요소
- **Horizontal Scaling**: 수평 확장 (인스턴스 추가)
- **Vertical Scaling**: 수직 확장 (리소스 증가)
- **Service Mesh**: 서비스 간 통신 관리
- **Circuit Breaker**: 장애 전파 방지

---

## 📝 세션 마무리

### ✅ 오늘 세션 성과
- [ ] 3-Tier 아키텍처 패턴 완전 이해
- [ ] 마이크로서비스 아키텍처 개념 습득
- [ ] 모니터링과 로깅 통합 방안 파악
- [ ] 실무 아키텍처 설계 기반 완성

### 🎯 다음 세션 준비
- **주제**: 환경별 설정 관리 (dev/staging/prod)
- **연결고리**: 아키텍처 설계 → 환경별 배포 전략
- **준비사항**: 개발/운영 환경 차이점과 관리 방법 궁금증 가지기

---

<div align="center">

**🏗️ 멀티 컨테이너 아키텍처 설계를 완전히 이해했습니다**

*3-Tier부터 마이크로서비스까지*

**다음**: [Session 3 - 환경별 설정 관리](./session_3.md)

</div>