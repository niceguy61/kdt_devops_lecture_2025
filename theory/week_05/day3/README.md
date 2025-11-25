# Week 5 Day 3: 데이터베이스 & 캐싱

<div align="center">

**🗄️ RDS 관리형 DB** • **⚡ ElastiCache 캐싱** • **📊 모니터링**

*3-Tier 아키텍처 + 캐싱 계층으로 성능 최적화*

</div>

---

## 🕘 일일 스케줄

| 시간 | 구분 | 내용 | 목적 |
|------|------|------|------|
| **09:00-09:50** | 📚 Session 1 | RDS 기초 (Multi-AZ, Read Replica) | 관리형 DB 이해 |
| **09:50-10:00** | ☕ 휴식 | 10분 휴식 | |
| **10:00-10:50** | 📚 Session 2 | RDS 운영 (모니터링, 백업) | 운영 전략 |
| **10:50-11:00** | ☕ 휴식 | 10분 휴식 | |
| **11:00-11:50** | 📚 Session 3 | ElastiCache Redis | 캐싱 전략 |
| **11:50-12:00** | ☕ 휴식 | 10분 휴식 | |
| **12:00-12:50** | 📚 Session 4 | 고객 사례 - FinTech 플랫폼 | 실무 아키텍처 |
| **12:50-13:00** | ☕ 휴식 | 10분 휴식 | |
| **13:00-14:00** | 🍽️ 점심 | 점심시간 | |
| **14:00-14:50** | 🛠️ Lab 1 | RDS PostgreSQL 구성 | DB 구축 |
| **14:50-15:00** | ☕ 휴식 | 10분 휴식 | |
| **15:00-15:50** | 🎮 Challenge 1 | 데이터베이스 장애 복구 | 실전 대응 |

---

## 🎯 학습 목표

### 📚 이론 목표
- **RDS 아키텍처**: Multi-AZ, Read Replica 이해
- **운영 전략**: 백업, 모니터링, 장애 복구
- **캐싱 전략**: Redis 활용 및 성능 최적화
- **실무 사례**: FinTech 아키텍처 분석

### 🛠️ 실습 목표
- **RDS 구성**: PostgreSQL Multi-AZ 배포
- **애플리케이션 연동**: EC2 → RDS 연결
- **Redis 캐싱**: ElastiCache 구성 및 성능 비교
- **모니터링**: CloudWatch 메트릭 확인

---

## 🏗️ Day 3 아키텍처

### 📐 전체 구성도

```mermaid
architecture-beta
    group aws(cloud)[AWS Cloud]
    
    group vpc(cloud)[VPC] in aws
    group public(cloud)[Public Subnet] in vpc
    group private_a(cloud)[Private Subnet A] in vpc
    group private_b(cloud)[Private Subnet B] in vpc
    
    service internet(internet)[Internet] in aws
    service ec2(server)[EC2 API Server] in public
    service rds_primary(database)[RDS Primary] in private_a
    service rds_standby(database)[RDS Standby] in private_b
    service redis(disk)[ElastiCache Redis] in private_a
    service cw(disk)[CloudWatch] in aws
    
    internet:R --> L:ec2
    ec2:B --> T:rds_primary
    ec2:B --> T:redis
    rds_primary:R --> L:rds_standby
    ec2:T --> B:cw
    rds_primary:T --> B:cw
    redis:T --> B:cw
```

### 🔧 사용된 AWS 서비스

**데이터베이스**:
- ![RDS](../../../Asset-Package/Architecture-Service-Icons_01312023/Arch_Database/48/Arch_Amazon-RDS_48.svg) **Amazon RDS**: PostgreSQL Multi-AZ
- ![ElastiCache](../../../Asset-Package/Architecture-Service-Icons_01312023/Arch_Database/48/Arch_Amazon-ElastiCache_48.svg) **Amazon ElastiCache**: Redis 캐싱

**컴퓨팅 & 네트워킹**:
- ![EC2](../../../Asset-Package/Architecture-Service-Icons_01312023/Arch_Compute/48/Arch_Amazon-EC2_48.svg) **Amazon EC2**: API 서버
- ![VPC](../../../Asset-Package/Architecture-Service-Icons_01312023/Arch_Networking-Content-Delivery/48/Arch_Amazon-Virtual-Private-Cloud_48.svg) **Amazon VPC**: 네트워크 격리

**모니터링**:
- ![CloudWatch](../../../Asset-Package/Architecture-Service-Icons_01312023/Arch_Management-Governance/48/Arch_Amazon-CloudWatch_48.svg) **Amazon CloudWatch**: 메트릭 및 알람

---

## 📚 Session 개요

### 📊 Session 학습 흐름

```mermaid
graph TB
    S1[Session 1<br/>RDS 기초] --> S2[Session 2<br/>RDS 운영]
    S2 --> S3[Session 3<br/>ElastiCache]
    S3 --> S4[Session 4<br/>FinTech 사례]
    
    S1 --> L1[Lab 1<br/>RDS 구성]
    S2 --> L1
    S2 --> C1[Challenge 1<br/>장애 복구]
    S4 --> C1
    
    style S1 fill:#e8f5e8
    style S2 fill:#fff3e0
    style S3 fill:#e3f2fd
    style S4 fill:#f3e5f5
    style L1 fill:#ffebee
    style C1 fill:#fce4ec
```

### Session 1: RDS 기초 (09:00-09:50)
**학습 내용**:
- RDS 아키텍처 및 엔진 선택
- Multi-AZ vs Read Replica
- 자동 백업 & 스냅샷
- RDS 보안 (암호화, IAM 인증)

**핵심 개념**:
- 관리형 데이터베이스의 장점
- 고가용성 구성 방법
- 백업 및 복구 전략

### 🔄 RDS Multi-AZ 동작 원리

```mermaid
sequenceDiagram
    participant App as Application
    participant Primary as RDS Primary
    participant Standby as RDS Standby
    participant DNS as RDS Endpoint
    
    App->>DNS: 연결 요청
    DNS->>Primary: Primary로 라우팅
    Primary->>App: 연결 성공
    
    Note over Primary,Standby: 동기식 복제
    Primary->>Standby: 데이터 동기화
    
    Note over Primary: 장애 발생!
    Primary--xApp: 연결 끊김
    
    Note over Standby: 자동 Failover
    Standby->>DNS: Primary로 승격
    App->>DNS: 재연결 시도
    DNS->>Standby: 새 Primary로 라우팅
    Standby->>App: 연결 복구
```

### Session 2: RDS 운영 (10:00-10:50)
**학습 내용**:
- RDS 모니터링 (CloudWatch)
- 성능 인사이트 (Performance Insights)
- 스케일링 전략
- 장애 복구 (Failover)

**핵심 개념**:
- 운영 메트릭 이해
- 성능 최적화 방법
- 장애 대응 절차

### 📊 RDS 모니터링 메트릭

```mermaid
graph TB
    subgraph "CloudWatch 메트릭"
        A[CPU 사용률]
        B[메모리 사용률]
        C[디스크 IOPS]
        D[네트워크 처리량]
        E[DB 연결 수]
        F[복제 지연]
    end
    
    subgraph "알람 설정"
        G[CPU > 80%]
        H[연결 수 > 100]
        I[복제 지연 > 5초]
    end
    
    A --> G
    E --> H
    F --> I
    
    style A fill:#e8f5e8
    style B fill:#e8f5e8
    style C fill:#e8f5e8
    style D fill:#fff3e0
    style E fill:#fff3e0
    style F fill:#fff3e0
    style G fill:#ffebee
    style H fill:#ffebee
    style I fill:#ffebee
```

### Session 3: ElastiCache Redis (11:00-11:50)
**학습 내용**:
- Redis vs Memcached
- 캐싱 전략 (Cache-Aside, Write-Through)
- 클러스터 모드
- 데이터 영속성

**핵심 개념**:
- 캐싱의 필요성
- 캐싱 패턴 선택
- Redis 고급 기능

### 🔄 캐싱 패턴 비교

```mermaid
graph TB
    subgraph "Cache-Aside Pattern"
        A1[App] -->|1. Read| A2[Cache]
        A2 -->|2. Miss| A3[DB]
        A3 -->|3. Return| A1
        A1 -->|4. Write| A2
    end
    
    subgraph "Write-Through Pattern"
        B1[App] -->|1. Write| B2[Cache]
        B2 -->|2. Sync Write| B3[DB]
        B3 -->|3. Confirm| B1
    end
    
    subgraph "Write-Behind Pattern"
        C1[App] -->|1. Write| C2[Cache]
        C2 -->|2. Async Write| C3[DB]
        C2 -->|3. Immediate| C1
    end
    
    style A1 fill:#e8f5e8
    style A2 fill:#fff3e0
    style A3 fill:#e3f2fd
    style B1 fill:#e8f5e8
    style B2 fill:#fff3e0
    style B3 fill:#e3f2fd
    style C1 fill:#e8f5e8
    style C2 fill:#fff3e0
    style C3 fill:#e3f2fd
```

### Session 4: 고객 사례 - FinTech 플랫폼 (12:00-12:50)
**실무 아키텍처**:
- 간편 송금 서비스 (Stripe/PayPal 스타일)
- Node.js API + PostgreSQL + Redis
- 트랜잭션 무결성 보장
- 실시간 잔액 캐싱

**학습 포인트**:
- 금융 데이터 보안
- 트랜잭션 처리
- 고가용성 & 장애 복구
- 규정 준수 (PCI-DSS)

### 🏦 FinTech 아키텍처

```mermaid
architecture-beta
    group aws(cloud)[AWS Cloud]
    
    service waf(internet)[WAF] in aws
    service alb(server)[ALB] in aws
    service api(server)[API Server] in aws
    service rds(database)[RDS PostgreSQL] in aws
    service redis(disk)[Redis Session] in aws
    service s3(disk)[S3 Archive] in aws
    
    waf:R -- L:alb
    alb:R -- L:api
    api:R -- L:rds
    api:B -- T:redis
    api:B -- T:s3
```

---

## 🛠️ Lab 개요

### 🔄 Lab 실습 흐름

```mermaid
graph LR
    L1[Lab 1<br/>RDS 구성] --> T1[테스트<br/>DB 연결]
    T1 --> C1[Challenge 1<br/>장애 복구]
    C1 --> T2[복구<br/>검증]
    T2 --> CL[정리]
    
    style L1 fill:#e8f5e8
    style T1 fill:#fff3e0
    style C1 fill:#ffebee
    style T2 fill:#f3e5f5
    style CL fill:#e3f2fd
```

### Lab 1: RDS PostgreSQL 구성 (14:00-14:50)
**목표**: Multi-AZ RDS 구성 및 애플리케이션 연동

**구현 내용**:
1. RDS 인스턴스 생성 (db.t3.micro, Multi-AZ)
2. Security Group 구성
3. EC2에서 psql 연결
4. 테이블 생성 및 데이터 삽입
5. 애플리케이션 연동 테스트
6. 수동 스냅샷 생성

**예상 비용**: $0.20 (1시간 기준)

### 🔧 Lab 1 구성 단계

```mermaid
graph TB
    A[RDS 인스턴스<br/>생성] --> B[Security Group<br/>설정]
    B --> C[EC2에서<br/>연결 테스트]
    C --> D[테이블 생성<br/>데이터 삽입]
    D --> E[애플리케이션<br/>연동]
    E --> F[스냅샷<br/>생성]
    
    style A fill:#e8f5e8
    style B fill:#fff3e0
    style C fill:#e3f2fd
    style D fill:#f3e5f5
    style E fill:#ffebee
    style F fill:#c8e6c9
```

### Challenge 1: 데이터베이스 장애 복구 (15:00-15:50)
**목표**: RDS 장애 상황 대응 및 복구

**시나리오**:
1. **시나리오 1**: RDS Primary 장애 (Multi-AZ Failover)
2. **시나리오 2**: 잘못된 데이터 삭제 (스냅샷 복구)
3. **시나리오 3**: 성능 저하 (Read Replica 추가)
4. **시나리오 4**: 연결 실패 (Security Group 문제)

**학습 포인트**:
- 장애 상황 진단
- 신속한 복구 절차
- 데이터 무결성 보장
- 모니터링 및 알람

**예상 비용**: $0.30 (1시간 기준)

### 🚨 Challenge 1 장애 시나리오

```mermaid
graph TB
    subgraph "시나리오 1: Failover"
        A1[Primary 장애] --> A2[Standby 승격]
        A2 --> A3[DNS 업데이트]
        A3 --> A4[서비스 복구]
    end
    
    subgraph "시나리오 2: 데이터 복구"
        B1[데이터 삭제] --> B2[스냅샷 확인]
        B2 --> B3[새 인스턴스]
        B3 --> B4[데이터 복원]
    end
    
    subgraph "시나리오 3: 성능 개선"
        C1[느린 조회] --> C2[Read Replica]
        C2 --> C3[읽기 분산]
        C3 --> C4[성능 향상]
    end
    
    style A1 fill:#ffebee
    style A4 fill:#c8e6c9
    style B1 fill:#ffebee
    style B4 fill:#c8e6c9
    style C1 fill:#ffebee
    style C4 fill:#c8e6c9
```

---

## 💰 예상 비용

### 일일 비용 계산 (14명 기준)
| 리소스 | 사양 | 시간 | 단가 | 비용 |
|--------|------|------|------|------|
| RDS PostgreSQL | db.t3.micro Multi-AZ | 2시간 | $0.034/hour | $0.068 |
| RDS Read Replica | db.t3.micro | 1시간 | $0.017/hour | $0.017 |
| EC2 | t3.micro | 3시간 | $0.0104/hour | $0.031 |
| 데이터 전송 | 1GB | - | $0.09/GB | $0.09 |
| 스냅샷 스토리지 | 5GB | - | $0.095/GB-month | $0.016 |
| **합계** | | | | **$0.222** |

**학생당**: $0.222 × 14명 = **$3.11**

### 비용 절감 팁
- 프리티어 활용 (RDS 750시간/월)
- 실습 완료 후 즉시 삭제
- 스냅샷은 최소한으로 유지
- 데이터 전송 최소화

---

## 🔗 Day 1-2 연결

### 📊 학습 누적 효과

```mermaid
graph TB
    subgraph "Day 1 학습"
        D1A[VPC 네트워크]
        D1B[Security Group]
        D1C[EC2 인스턴스]
    end
    
    subgraph "Day 2 학습"
        D2A[EBS 볼륨]
        D2B[데이터 영속성]
        D2C[S3 스토리지]
    end
    
    subgraph "Day 3 적용"
        D3A[Private Subnet에<br/>RDS 배치]
        D3B[EC2-RDS<br/>Security Group]
        D3C[RDS 데이터<br/>영속성]
    end
    
    D1A --> D3A
    D1B --> D3B
    D2B --> D3C
    
    style D1A fill:#e8f5e8
    style D1B fill:#e8f5e8
    style D1C fill:#e8f5e8
    style D2A fill:#fff3e0
    style D2B fill:#fff3e0
    style D2C fill:#fff3e0
    style D3A fill:#e3f2fd
    style D3B fill:#e3f2fd
    style D3C fill:#e3f2fd
```

### Day 1에서 배운 내용
- VPC 네트워크 구성
- Public/Private Subnet 분리
- Security Group 설정
- EC2 인스턴스 생성

### Day 2에서 배운 내용
- EBS 볼륨 관리
- 데이터 영속성 전략
- S3 스토리지 활용
- CloudFront CDN

### Day 3에서 재사용
- **VPC**: Day 1에서 생성한 VPC 활용
- **Private Subnet**: DB를 Private Subnet에 배치
- **Security Group**: EC2 → RDS 통신 허용
- **데이터 영속성**: Day 2의 개념을 RDS에 적용

---

## 🎯 Day 3 학습 성과

### ✅ 기술적 성취
- [ ] RDS Multi-AZ 구성 완료
- [ ] ElastiCache Redis 구성 완료
- [ ] 애플리케이션 DB 연동 성공
- [ ] 캐싱 성능 개선 확인
- [ ] CloudWatch 모니터링 설정

### ✅ 실무 역량
- [ ] 관리형 DB 운영 능력
- [ ] 캐싱 전략 수립 능력
- [ ] 성능 최적화 경험
- [ ] 모니터링 및 알람 설정

---

## 🔗 Day 4 준비

### 🚀 다음 단계 로드맵

```mermaid
graph LR
    D3[Day 3<br/>RDS + Cache] --> D4A[ALB<br/>로드밸런싱]
    D3 --> D4B[ASG<br/>자동 확장]
    D3 --> D4C[Multi-AZ<br/>통합 HA]
    
    D4A --> D5[Day 5<br/>CloudMart]
    D4B --> D5
    D4C --> D5
    
    style D3 fill:#e3f2fd
    style D4A fill:#f3e5f5
    style D4B fill:#f3e5f5
    style D4C fill:#f3e5f5
    style D5 fill:#ffebee
```

### 다음 학습 내용
- **ALB**: 로드 밸런서로 트래픽 분산
- **Auto Scaling**: 자동 확장으로 고가용성
- **Multi-AZ 통합**: 전체 시스템 고가용성

### 연결 포인트
- Day 3의 RDS Multi-AZ → Day 4의 전체 HA 아키텍처
- ElastiCache 세션 스토어 → ALB Sticky Session 대체
- CloudWatch 모니터링 → Auto Scaling 트리거

---

## 📚 참고 자료

### AWS 공식 문서
- [Amazon RDS 사용자 가이드](https://docs.aws.amazon.com/rds/)
- [Amazon ElastiCache 사용자 가이드](https://docs.aws.amazon.com/elasticache/)
- [RDS 요금](https://aws.amazon.com/rds/pricing/)
- [ElastiCache 요금](https://aws.amazon.com/elasticache/pricing/)

### 추가 학습 자료
- [RDS 베스트 프랙티스](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html)
- [Redis 캐싱 패턴](https://redis.io/docs/manual/patterns/)
- [AWS Well-Architected Framework - 데이터베이스](https://docs.aws.amazon.com/wellarchitected/latest/framework/a-database.html)

---

<div align="center">

**🗄️ 관리형 DB** • **⚡ 캐싱 최적화** • **📊 운영 모니터링**

*3-Tier 아키텍처로 프로덕션급 시스템 구축*

</div>
