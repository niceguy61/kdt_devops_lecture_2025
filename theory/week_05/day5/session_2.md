# Week 5 Day 5 Session 2: 인프라 구성 (10:00-10:50)

<div align="center">

**🏗️ 네트워크 설계** • **💾 데이터베이스** • **⚡ 캐싱** • **🔐 보안**

*CloudMart를 위한 프로덕션급 AWS 인프라 구축*

</div>

---

## 🕘 세션 정보
**시간**: 10:00-10:50 (50분)
**목표**: CloudMart 배포를 위한 완전한 AWS 인프라 설계 및 구성
**방식**: 이론 설명 + 아키텍처 설계

## 🎯 세션 목표

### 📚 학습 목표
- **이해 목표**: Multi-AZ 고가용성 아키텍처 설계 원칙 이해
- **적용 목표**: VPC, RDS, ElastiCache 최적 구성 방법 습득
- **협업 목표**: 팀과 함께 인프라 설계 결정 사항 도출

### 🤔 왜 필요한가? (5분)

**현실 문제 상황**:
- 💼 **실무 시나리오**: "서버 1대가 죽으면 전체 서비스가 멈춰요. 어떻게 해야 하나요?"
- 🏠 **일상 비유**: 식당에 주방이 1개 → 고장 나면 영업 중단 vs 주방 2개 → 하나 고장 나도 계속 영업
- ☁️ **AWS 아키텍처**: Single-AZ (1개 데이터센터) → Multi-AZ (2개 이상 데이터센터)
- 📊 **시장 동향**: Netflix는 99.99% 가용성 (연간 52분 다운타임)

**Single-AZ vs Multi-AZ 비교**:
```mermaid
graph TB
    subgraph "Single-AZ (위험)"
        A1[사용자] --> B1[AZ-A만 사용]
        B1 --> C1[EC2]
        B1 --> D1[RDS]
        E1[AZ-A 장애 시<br/>전체 서비스 중단]
    end
    
    subgraph "Multi-AZ (안전)"
        A2[사용자] --> B2[ALB<br/>트래픽 분산]
        B2 --> C2[AZ-A<br/>EC2 + RDS Primary]
        B2 --> D2[AZ-B<br/>EC2 + RDS Standby]
        E2[AZ-A 장애 시<br/>AZ-B로 자동 전환]
    end
    
    style B1 fill:#ffebee
    style E1 fill:#ffebee
    style B2 fill:#e8f5e8
    style C2 fill:#e8f5e8
    style D2 fill:#e8f5e8
    style E2 fill:#e8f5e8
```

## 📖 핵심 개념 (35분)

### 🔍 개념 1: Multi-AZ VPC 네트워크 설계 (12분)

> **정의**: 여러 가용 영역에 걸쳐 고가용성을 보장하는 네트워크 아키텍처

**CloudMart VPC 설계**:
```
VPC: 10.0.0.0/16 (65,536개 IP)
├── AZ-A (ap-northeast-2a)
│   ├── Public Subnet: 10.0.1.0/24 (256개 IP)
│   │   └── ALB, NAT Gateway
│   └── Private Subnet: 10.0.11.0/24 (256개 IP)
│       └── EC2 Backend, RDS Primary, ElastiCache
│
└── AZ-B (ap-northeast-2b)
    ├── Public Subnet: 10.0.2.0/24 (256개 IP)
    │   └── ALB, NAT Gateway (선택)
    └── Private Subnet: 10.0.12.0/24 (256개 IP)
        └── EC2 Backend, RDS Standby, ElastiCache
```

**네트워크 구성 다이어그램**:
```mermaid
graph TB
    subgraph "VPC 10.0.0.0/16"
        IGW[Internet Gateway]
        
        subgraph "AZ-A"
            PUB1[Public Subnet<br/>10.0.1.0/24]
            PRIV1[Private Subnet<br/>10.0.11.0/24]
            NAT1[NAT Gateway]
            
            PUB1 --> NAT1
            NAT1 --> PRIV1
        end
        
        subgraph "AZ-B"
            PUB2[Public Subnet<br/>10.0.2.0/24]
            PRIV2[Private Subnet<br/>10.0.12.0/24]
            NAT2[NAT Gateway]
            
            PUB2 --> NAT2
            NAT2 --> PRIV2
        end
        
        IGW --> PUB1
        IGW --> PUB2
    end
    
    style IGW fill:#4caf50
    style PUB1 fill:#fff3e0
    style PUB2 fill:#fff3e0
    style PRIV1 fill:#e8f5e8
    style PRIV2 fill:#e8f5e8
```

**Subnet 설계 원칙**:
- **Public Subnet**: 인터넷 접근 가능 (ALB, NAT Gateway)
- **Private Subnet**: 인터넷 직접 접근 불가 (Backend, DB, Cache)
- **CIDR 블록**: /24 (256개 IP) - 충분한 여유 확보
- **AZ 분산**: 각 AZ에 동일한 구조 배치

**Route Table 설정**:
```yaml
Public Route Table:
  - 10.0.0.0/16 → local (VPC 내부 통신)
  - 0.0.0.0/0 → Internet Gateway (외부 인터넷)

Private Route Table (AZ-A):
  - 10.0.0.0/16 → local
  - 0.0.0.0/0 → NAT Gateway (AZ-A)

Private Route Table (AZ-B):
  - 10.0.0.0/16 → local
  - 0.0.0.0/0 → NAT Gateway (AZ-B)
```

### 🔍 개념 2: RDS Multi-AZ 데이터베이스 구성 (12분)

> **정의**: 자동 장애 조치를 지원하는 고가용성 관계형 데이터베이스

**RDS Multi-AZ 동작 원리**:
```mermaid
sequenceDiagram
    participant App as Backend API
    participant Primary as RDS Primary<br/>(AZ-A)
    participant Standby as RDS Standby<br/>(AZ-B)
    
    Note over Primary,Standby: 정상 상태
    App->>Primary: 1. 쓰기 요청
    Primary->>Standby: 2. 동기 복제
    Standby-->>Primary: 3. 복제 완료
    Primary-->>App: 4. 응답
    
    Note over Primary: 장애 발생!
    
    Note over Standby: 자동 승격
    App->>Standby: 5. 자동 연결 전환
    Standby-->>App: 6. 정상 응답
```

**CloudMart RDS 설정**:
```yaml
RDS PostgreSQL 설정:
  Engine: PostgreSQL 15
  Instance Class: db.t3.micro (프리티어)
  Storage: 20GB gp3 (범용 SSD)
  Multi-AZ: Enabled (자동 장애 조치)
  
  Backup:
    Automated Backup: 7일 보관
    Backup Window: 03:00-04:00 (새벽)
    Maintenance Window: 일요일 04:00-05:00
  
  Security:
    Encryption: Enabled (저장 데이터 암호화)
    Public Access: Disabled (Private Subnet만)
    Security Group: Backend만 접근 허용
```

**연결 문자열 예시**:
```javascript
// Backend 환경 변수
DATABASE_URL=postgresql://cloudmart_user:password@cloudmart-db.xxxxx.ap-northeast-2.rds.amazonaws.com:5432/cloudmart

// Node.js 연결 코드
const { Pool } = require('pg');
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false // RDS SSL 인증서
  },
  max: 20, // 최대 연결 수
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});
```

**Multi-AZ 장점**:
- **자동 장애 조치**: 1-2분 내 자동 전환
- **동기 복제**: 데이터 손실 없음
- **자동 백업**: 스냅샷 자동 생성
- **유지보수**: 무중단 패치 적용

### 🔍 개념 3: ElastiCache Redis 클러스터 구성 (11분)

> **정의**: 고성능 인메모리 캐싱 및 세션 스토어

**ElastiCache 아키텍처**:
```mermaid
graph TB
    subgraph "Backend API 서버"
        A1[EC2-1] --> C[ElastiCache<br/>Redis Cluster]
        A2[EC2-2] --> C
        A3[EC2-3] --> C
    end
    
    subgraph "Redis Cluster"
        C --> D1[Primary Node<br/>AZ-A]
        C --> D2[Replica Node<br/>AZ-B]
        D1 -.비동기 복제.-> D2
    end
    
    subgraph "사용 사례"
        E1[세션 데이터<br/>공유]
        E2[API 응답<br/>캐싱]
        E3[상품 정보<br/>캐싱]
    end
    
    style C fill:#4caf50
    style D1 fill:#e8f5e8
    style D2 fill:#fff3e0
```

**CloudMart Redis 설정**:
```yaml
ElastiCache Redis 설정:
  Engine: Redis 7.0
  Node Type: cache.t3.micro (프리티어)
  Number of Replicas: 1 (Primary + 1 Replica)
  Multi-AZ: Enabled
  
  Configuration:
    Max Memory Policy: allkeys-lru (메모리 부족 시 LRU 삭제)
    Timeout: 300 (5분 유휴 연결 종료)
    
  Security:
    Encryption in Transit: Enabled (전송 중 암호화)
    Encryption at Rest: Enabled (저장 데이터 암호화)
    Security Group: Backend만 접근 허용
```

**Redis 활용 예시**:
```javascript
// Backend에서 Redis 사용
const redis = require('redis');
const client = redis.createClient({
  url: `redis://${process.env.REDIS_ENDPOINT}:6379`,
  socket: {
    tls: true, // ElastiCache 암호화 연결
    rejectUnauthorized: false
  }
});

// 1. 세션 저장
await client.set(`session:${userId}`, JSON.stringify(sessionData), {
  EX: 3600 // 1시간 후 만료
});

// 2. 상품 정보 캐싱
const cacheKey = `product:${productId}`;
let product = await client.get(cacheKey);

if (!product) {
  // 캐시 미스 - DB에서 조회
  product = await db.query('SELECT * FROM products WHERE id = $1', [productId]);
  await client.set(cacheKey, JSON.stringify(product), {
    EX: 600 // 10분 캐싱
  });
}

// 3. API Rate Limiting
const rateLimitKey = `ratelimit:${userId}`;
const count = await client.incr(rateLimitKey);
if (count === 1) {
  await client.expire(rateLimitKey, 60); // 1분 윈도우
}
if (count > 100) {
  throw new Error('Rate limit exceeded');
}
```

**캐싱 전략**:
- **Cache-Aside**: 애플리케이션이 캐시 관리
- **TTL 설정**: 데이터 특성에 따라 만료 시간 조정
- **Invalidation**: 데이터 변경 시 캐시 무효화

## 💭 함께 생각해보기 (10분)

### 🤝 페어 토론 (5분)

**토론 주제**:
1. **AZ 선택**: "2개 AZ로 충분할까요? 3개 AZ가 필요한 경우는?"
2. **비용 vs 안정성**: "NAT Gateway를 1개만 쓰면 비용이 절반인데, 괜찮을까요?"
3. **캐싱 전략**: "어떤 데이터를 Redis에 캐싱하면 효과적일까요?"

**페어 활동 가이드**:
- 👥 **자유 페어링**: 인프라 경험이 비슷한 사람끼리
- 🔄 **역할 교대**: 3분씩 설명자/질문자 역할 바꾸기
- 📝 **핵심 정리**: 인프라 설계 체크리스트 작성

### 🎯 전체 공유 (5분)

**인사이트 공유**:
- 페어 토론에서 나온 인프라 설계 아이디어
- 비용과 안정성의 균형점
- 실무에서 적용 가능한 최적화 방법

**💡 이해도 체크 질문**:
- ✅ "Multi-AZ 구성이 Single-AZ보다 안전한 이유는 무엇인가요?"
- ✅ "RDS Multi-AZ에서 장애 조치는 어떻게 이루어지나요?"
- ✅ "Redis를 사용하면 어떤 성능 향상을 기대할 수 있나요?"

## 🔑 핵심 키워드

### 🆕 새로운 용어
- **Multi-AZ**: 여러 가용 영역에 리소스를 분산 배치하여 고가용성 확보
- **Failover**: 장애 발생 시 대기 시스템으로 자동 전환하는 메커니즘
- **Synchronous Replication**: 동기 복제 - 데이터 손실 없이 실시간 복제

### 🔧 중요 개념
- **Private Subnet**: 인터넷 직접 접근 불가, NAT Gateway 통해서만 외부 통신
- **NAT Gateway**: Private Subnet의 리소스가 외부 인터넷에 접근하기 위한 게이트웨이
- **Cache-Aside Pattern**: 애플리케이션이 캐시를 직접 관리하는 패턴

### 💼 실무 용어
- **RPO (Recovery Point Objective)**: 데이터 손실 허용 시간 (Multi-AZ는 RPO=0)
- **RTO (Recovery Time Objective)**: 복구 목표 시간 (Multi-AZ는 RTO=1-2분)
- **Connection Pooling**: 데이터베이스 연결을 재사용하여 성능 향상

## 📝 세션 마무리

### ✅ 오늘 세션 성과
- **네트워크 설계**: Multi-AZ VPC 아키텍처 완전 이해
- **데이터베이스**: RDS Multi-AZ 고가용성 구성 방법 습득
- **캐싱 전략**: ElastiCache Redis 활용 방안 파악

### 🎯 다음 세션 준비
- **Session 3 주제**: 모니터링 & 로깅 (CloudWatch, X-Ray)
- **연결 내용**: 구축한 인프라의 상태를 실시간으로 모니터링
- **사전 생각**: "서버가 정상인지 어떻게 알 수 있을까요?"

### 🔗 실습 연계
- **Lab 1**: 오늘 배운 인프라를 실제로 AWS에 구축
- **Challenge**: 프로덕션급 완성도로 전체 시스템 완성

---

<div align="center">

**🏗️ 인프라 설계 완료** • **💾 고가용성 확보** • **⚡ 성능 최적화**

*다음 세션에서는 모니터링과 로깅을 구축해보겠습니다!*

</div>
