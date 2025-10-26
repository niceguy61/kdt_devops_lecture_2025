# Week 5 Day 3 Session 4: 고객 사례 - FinTech 플랫폼

<div align="center">

**💰 금융 서비스** • **🔐 보안 & 규정 준수** • **⚡ 고성능 트랜잭션**

*실시간 송금 서비스의 AWS 아키텍처*

</div>

---

## 🕘 Session 정보

**시간**: 12:00-12:50 (50분)  
**목표**: 실제 FinTech 아키텍처 분석 및 설계 원칙 학습  
**방식**: 사례 분석 + 아키텍처 설계

---

## 🎯 학습 목표

- **실무 아키텍처**: 실제 금융 서비스의 AWS 구성
- **보안 요구사항**: 금융 데이터 보호 및 규정 준수
- **고가용성**: 99.99% 가용성 달성 전략
- **성능 최적화**: 실시간 트랜잭션 처리

---

## 🏢 고객 사례: "QuickPay" - 간편 송금 서비스

### 📖 서비스 개요

**QuickPay란?**:
- 모바일 기반 P2P 송금 서비스
- 실시간 계좌 이체 및 잔액 조회
- 월 거래액: 1조원 (100만 사용자)
- 일일 트랜잭션: 500만 건

**비즈니스 요구사항**:
- **가용성**: 99.99% SLA (연간 다운타임 52분 이하)
- **성능**: 트랜잭션 응답 시간 < 200ms
- **보안**: 금융 데이터 암호화 및 감사
- **규정 준수**: 전자금융거래법, 개인정보보호법

---

## 🏗️ 아키텍처 설계

### 📐 전체 시스템 아키텍처

```mermaid
architecture-beta
    group aws(cloud)[AWS Cloud]
    
    group waf_layer(cloud)[Security Layer] in aws
    group app_layer(cloud)[Application Layer] in aws
    group data_layer(cloud)[Data Layer] in aws
    group monitoring(cloud)[Monitoring Layer] in aws
    
    service waf(internet)[WAF] in waf_layer
    service alb(internet)[ALB] in waf_layer
    
    service api1(server)[API Server 1] in app_layer
    service api2(server)[API Server 2] in app_layer
    service api3(server)[API Server 3] in app_layer
    
    service rds_primary(database)[RDS Primary] in data_layer
    service rds_standby(database)[RDS Standby] in data_layer
    service redis(disk)[ElastiCache] in data_layer
    
    service cw(disk)[CloudWatch] in monitoring
    service xray(disk)[X-Ray] in monitoring
    
    waf:R -- L:alb
    alb:R -- L:api1
    alb:R -- L:api2
    alb:R -- L:api3
    api1:B -- T:rds_primary
    api2:B -- T:redis
    api3:B -- T:rds_primary
    rds_primary:R -- L:rds_standby
    api1:T -- B:cw
    api2:T -- B:xray
```

### 🔧 계층별 구성 요소

#### 1. 보안 계층

**AWS WAF (Web Application Firewall)**:
- **SQL Injection 차단**: 악의적 쿼리 방어
- **DDoS 방어**: Rate Limiting (초당 1,000 요청)
- **지역 차단**: 특정 국가 IP 차단
- **비용**: $5/월 + $1/100만 요청

**Application Load Balancer**:
- **HTTPS 종료**: SSL/TLS 인증서 관리
- **헬스체크**: 비정상 인스턴스 자동 제외
- **Sticky Session**: 세션 유지
- **비용**: $0.0225/hour + $0.008/LCU

#### 2. 애플리케이션 계층

**EC2 Auto Scaling Group**:
```
구성:
- 인스턴스 타입: t3.medium (2 vCPU, 4GB)
- 최소: 3개 (각 AZ에 1개씩)
- 최대: 10개
- 스케일링 정책: CPU 70% 이상 시 확장

비용 (평균 5개 실행):
$0.0416/hour × 5 × 730 = $151.84/월
```

**애플리케이션 구성**:
- **언어**: Node.js 18 (Express.js)
- **인증**: JWT 토큰 (Redis 저장)
- **로깅**: CloudWatch Logs
- **추적**: AWS X-Ray

#### 3. 데이터 계층

**Amazon RDS PostgreSQL (Multi-AZ)**:
```
구성:
- 인스턴스: db.r5.large (2 vCPU, 16GB)
- 스토리지: 500GB gp3
- Multi-AZ: 활성화 (자동 Failover)
- 백업: 7일 자동 백업 + 월간 스냅샷

비용:
- 인스턴스: $0.240 × 730 × 2 = $350.40/월
- 스토리지: $0.092 × 500 × 2 = $92.00/월
- 백업: $0.095 × 200 = $19.00/월
총 비용: $461.40/월
```

**Amazon ElastiCache Redis**:
```
구성:
- 노드: cache.r5.large (2 vCPU, 13.07GB)
- 복제본: 2개 (읽기 확장)
- 클러스터 모드: 비활성화
- 백업: 일일 자동 백업

비용:
- Primary: $0.188 × 730 = $137.24/월
- Replica: $0.188 × 730 × 2 = $274.48/월
총 비용: $411.72/월
```

#### 4. 모니터링 계층

**Amazon CloudWatch**:
- **메트릭**: CPU, Memory, IOPS, Latency
- **알람**: 임계값 초과 시 SNS 알림
- **대시보드**: 실시간 시스템 상태
- **비용**: $3/대시보드 + 메트릭 비용

**AWS X-Ray**:
- **분산 추적**: API 호출 경로 추적
- **성능 분석**: 병목 구간 식별
- **오류 추적**: 예외 발생 지점 파악
- **비용**: $5/100만 추적 + $0.50/100만 검색

---

## 💡 핵심 설계 원칙

### 1. 고가용성 (High Availability)

**Multi-AZ 배포**:
```
ap-northeast-2a (AZ-A):
├── EC2 API Server × 2
├── RDS Primary
└── ElastiCache Primary

ap-northeast-2b (AZ-B):
├── EC2 API Server × 2
├── RDS Standby
└── ElastiCache Replica 1

ap-northeast-2c (AZ-C):
├── EC2 API Server × 1
└── ElastiCache Replica 2
```

**장애 시나리오 및 대응**:

| 장애 유형 | 복구 시간 | 데이터 손실 | 자동 복구 |
|----------|----------|------------|----------|
| **EC2 장애** | 30초 | 없음 | ALB가 자동 제외 |
| **RDS 장애** | 1-2분 | 없음 | Multi-AZ Failover |
| **Redis 장애** | 30초 | 캐시만 손실 | Replica 승격 |
| **AZ 장애** | 1분 | 없음 | 다른 AZ로 전환 |

### 2. 보안 (Security)

**데이터 암호화**:
```
전송 중 암호화:
├── HTTPS (TLS 1.3)
├── RDS SSL 연결
└── Redis TLS 연결

저장 데이터 암호화:
├── RDS: KMS 암호화
├── EBS: KMS 암호화
├── S3: SSE-KMS
└── 백업: 자동 암호화
```

**네트워크 보안**:
```
VPC (10.0.0.0/16)
├── Public Subnet (10.0.1.0/24)
│   ├── ALB (인터넷 접근)
│   └── NAT Gateway
│
└── Private Subnet (10.0.11.0/24)
    ├── EC2 (ALB에서만 접근)
    ├── RDS (EC2에서만 접근)
    └── Redis (EC2에서만 접근)

Security Group 규칙:
- ALB: 0.0.0.0/0 → 443
- EC2: ALB → 8080
- RDS: EC2 → 5432
- Redis: EC2 → 6379
```

**IAM 권한 관리**:
```
최소 권한 원칙:
├── EC2 Role: RDS 연결, CloudWatch 쓰기
├── Lambda Role: RDS 읽기 전용
└── 개발자: 읽기 전용 + 로그 조회
```

### 3. 성능 최적화 (Performance)

**캐싱 전략**:
```
Redis 캐싱 계층:
├── 사용자 세션 (TTL: 30분)
├── 계좌 잔액 (TTL: 5분)
├── 거래 내역 (TTL: 1시간)
└── 환율 정보 (TTL: 10분)

캐시 적용 효과:
- DB 부하: 90% 감소
- 응답 시간: 200ms → 20ms (10배 향상)
- 처리량: 10배 증가
```

**데이터베이스 최적화**:
```sql
-- 인덱스 전략
CREATE INDEX idx_user_id ON transactions(user_id);
CREATE INDEX idx_created_at ON transactions(created_at DESC);
CREATE INDEX idx_status ON transactions(status) WHERE status = 'pending';

-- 파티셔닝 (월별)
CREATE TABLE transactions_2025_01 PARTITION OF transactions
FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

-- 읽기 복제본 활용
- 쓰기: Primary
- 읽기 (거래 내역): Read Replica 1
- 읽기 (통계): Read Replica 2
```

**Connection Pooling**:
```javascript
// Node.js 연결 풀 설정
const pool = new Pool({
  host: process.env.RDS_ENDPOINT,
  port: 5432,
  database: 'quickpay',
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  max: 20,              // 최대 연결 수
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
  ssl: {
    rejectUnauthorized: true,
    ca: fs.readFileSync('/path/to/rds-ca-cert.pem')
  }
});
```

### 4. 규정 준수 (Compliance)

**감사 로그**:
```
CloudTrail:
├── 모든 API 호출 기록
├── S3에 저장 (7년 보관)
└── 무결성 검증 (SHA-256)

RDS 감사 로그:
├── 모든 SQL 쿼리 기록
├── CloudWatch Logs 전송
└── 민감 데이터 마스킹
```

**백업 및 복구**:
```
백업 전략:
├── RDS 자동 백업: 7일
├── 수동 스냅샷: 월 1회 (12개월 보관)
├── 거래 데이터: S3 Glacier (7년 보관)
└── 복구 테스트: 분기 1회

RPO (Recovery Point Objective): 5분
RTO (Recovery Time Objective): 15분
```

---

## 📊 성능 및 비용 분석

### 성능 지표

**응답 시간 분포**:
```
P50 (중앙값): 18ms
P95: 45ms
P99: 120ms
P99.9: 200ms

목표: P99 < 200ms ✅ 달성
```

**처리량**:
```
평균 TPS: 500 TPS
피크 TPS: 2,000 TPS (점심시간)
일일 트랜잭션: 500만 건
```

**가용성**:
```
월간 가용성: 99.99%
연간 다운타임: 52분 (목표 달성)
MTTR (평균 복구 시간): 2분
```

### 월간 비용 분석

```
인프라 비용:
├── EC2 (5개 평균): $151.84
├── ALB: $16.43 + $24.00 (LCU) = $40.43
├── RDS: $461.40
├── ElastiCache: $411.72
├── WAF: $5.00 + $10.00 (요청) = $15.00
├── CloudWatch: $20.00
├── X-Ray: $15.00
├── 데이터 전송: $50.00
└── S3 (백업): $30.00
─────────────────────────────────
총 비용: $1,195.39/월

사용자당 비용: $1.20/월 (100만 사용자 기준)
거래당 비용: $0.0008 (500만 건 기준)
```

**비용 최적화 방안**:
```
Reserved Instance 적용 시:
├── EC2: $151.84 → $91.10 (40% 절감)
├── RDS: $461.40 → $276.84 (40% 절감)
└── ElastiCache: $411.72 → $247.03 (40% 절감)

최적화 후 총 비용: $880.39/월
절감액: $315.00/월 (26% 절감)
```

---

## 🚀 확장 전략

### 수평 확장 (Horizontal Scaling)

**Auto Scaling 정책**:
```yaml
스케일 아웃 (확장):
- 조건: CPU > 70% (5분 지속)
- 동작: 인스턴스 2개 추가
- 쿨다운: 5분

스케일 인 (축소):
- 조건: CPU < 30% (10분 지속)
- 동작: 인스턴스 1개 제거
- 쿨다운: 10분
```

**Read Replica 확장**:
```
현재: Primary 1 + Standby 1
확장: Primary 1 + Standby 1 + Read Replica 3

읽기 부하 분산:
- 거래 내역 조회: Read Replica 1
- 통계 및 분석: Read Replica 2
- 보고서 생성: Read Replica 3
```

### 글로벌 확장

**Multi-Region 아키텍처**:
```
Primary Region (ap-northeast-2):
├── 전체 서비스 운영
└── 글로벌 데이터베이스 Primary

Secondary Region (ap-southeast-1):
├── 재해 복구용 Standby
├── 글로벌 데이터베이스 Replica
└── 읽기 전용 서비스 (동남아 사용자)

장애 시나리오:
- Primary Region 장애 → Secondary로 자동 전환
- 복구 시간: 5분
- 데이터 손실: 최대 1초 (비동기 복제)
```

---

## 💡 핵심 교훈

### 설계 원칙

1. **보안 우선**: 금융 데이터는 항상 암호화
2. **고가용성**: Multi-AZ로 단일 장애점 제거
3. **성능 최적화**: 캐싱으로 DB 부하 90% 감소
4. **비용 효율**: Reserved Instance로 26% 절감
5. **규정 준수**: 감사 로그 및 백업 필수

### 실무 팁

**모니터링 알람 설정**:
```
Critical (즉시 대응):
- RDS CPU > 80%
- API 응답 시간 > 500ms
- 에러율 > 1%

Warning (주의 관찰):
- RDS CPU > 70%
- API 응답 시간 > 300ms
- 에러율 > 0.5%
```

**장애 대응 절차**:
```
1단계: 감지 (1분)
├── CloudWatch 알람
└── PagerDuty 호출

2단계: 진단 (2분)
├── CloudWatch 메트릭 확인
├── X-Ray 추적 분석
└── 로그 검색

3단계: 복구 (5분)
├── 자동 복구 (Auto Scaling, Failover)
├── 수동 개입 (필요 시)
└── 서비스 정상화 확인

4단계: 사후 분석
├── 근본 원인 분석
├── 재발 방지 대책
└── 문서화
```

---

## 📊 실습 연계

### Lab 1, 2와의 연결

**Lab 1 (RDS 구성)**:
- Multi-AZ 배포 실습
- 백업 및 복구 테스트
- CloudWatch 모니터링 설정

**Lab 2 (Redis 캐싱)**:
- ElastiCache 클러스터 생성
- 캐싱 로직 구현
- 성능 비교 (캐시 유무)

**통합 아키텍처**:
- EC2 + RDS + ElastiCache 3-Tier
- 보안 그룹 설정
- 전체 시스템 테스트

---

## 🔗 참고 자료

**AWS 아키텍처 센터**:
- 📘 [금융 서비스 아키텍처](https://aws.amazon.com/architecture/financial-services/)
- 📗 [고가용성 아키텍처](https://aws.amazon.com/architecture/high-availability/)
- 📙 [보안 베스트 프랙티스](https://aws.amazon.com/architecture/security-identity-compliance/)

**규정 준수**:
- 📕 [AWS 금융 규정 준수](https://aws.amazon.com/compliance/financial-services/)
- 🔐 [데이터 보호](https://aws.amazon.com/compliance/data-protection/)

---

## 🔑 핵심 키워드

- **Multi-AZ**: 고가용성을 위한 다중 가용 영역 배포
- **Auto Scaling**: 트래픽에 따른 자동 확장/축소
- **WAF**: 웹 애플리케이션 방화벽
- **KMS**: 암호화 키 관리 서비스
- **CloudTrail**: API 호출 감사 로그
- **X-Ray**: 분산 추적 및 성능 분석
- **Connection Pool**: 데이터베이스 연결 재사용
- **RPO/RTO**: 복구 시점/시간 목표

---

## 💡 Session 마무리

### ✅ 오늘 Session 성과
- **실무 아키텍처**: FinTech 서비스의 실제 AWS 구성 이해
- **보안 설계**: 금융 데이터 보호 및 규정 준수 방법
- **고가용성**: 99.99% SLA 달성 전략
- **성능 최적화**: 캐싱 및 DB 최적화로 10배 성능 향상
- **비용 최적화**: Reserved Instance로 26% 비용 절감

### 🎯 다음 Lab 준비
- **Lab 1**: RDS PostgreSQL Multi-AZ 구성
- **Lab 2**: ElastiCache Redis 캐싱 구현
- **통합 테스트**: 3-Tier 아키텍처 전체 동작 확인
- **성능 측정**: 캐시 적용 전후 응답 시간 비교

### 📚 복습 포인트
- **Multi-AZ vs Read Replica**: 고가용성 vs 읽기 확장
- **캐싱 전략**: 어떤 데이터를 캐싱할 것인가
- **보안 계층**: WAF, Security Group, 암호화
- **모니터링**: CloudWatch, X-Ray 활용

---

<div align="center">

**💰 금융급 보안** • **⚡ 실시간 처리** • **📊 99.99% 가용성** • **💡 실무 노하우**

*실제 FinTech 아키텍처로 배우는 AWS 설계 원칙*

</div>
