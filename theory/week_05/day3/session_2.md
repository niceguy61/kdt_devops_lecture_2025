# Week 5 Day 3 Session 2: RDS 운영

<div align="center">

**📊 모니터링** • **💾 백업 & 복구** • **🔧 성능 최적화**

*RDS 운영 전략과 장애 대응*

</div>

---

## 🕘 Session 정보

**시간**: 10:00-10:50 (50분)  
**목표**: RDS 운영 전략 및 모니터링 방법 학습  
**방식**: 이론 학습 + 실무 사례

---

## 🎯 학습 목표

- **모니터링**: CloudWatch 메트릭 및 Performance Insights
- **백업 전략**: 자동 백업, 스냅샷, Point-in-Time Recovery
- **성능 최적화**: 쿼리 튜닝, 인덱스 관리, 파라미터 그룹
- **장애 대응**: Failover 시나리오 및 복구 절차

---

## 📖 서비스 개요

### 1. 생성 배경 (Why?)

#### 어떤 문제를 해결하기 위해 만들어졌는가?

**온프레미스 DB 운영의 문제점**:
- 수동 백업 스크립트 작성 및 관리
- 백업 실패 시 알림 시스템 별도 구축
- 복구 테스트 복잡 (별도 환경 필요)
- 모니터링 도구 설치 및 유지보수
- 성능 분석 도구 라이선스 비용

**EC2 + DB 운영의 한계**:
- CloudWatch 메트릭 수동 설정
- 백업 스토리지 관리 (S3 연동)
- 복구 절차 문서화 및 테스트
- 성능 분석 도구 별도 설치
- 알람 설정 및 관리 복잡

**AWS RDS 솔루션**:
- 자동 백업 (35일 보관, 무료)
- Point-in-Time Recovery (5분 단위)
- CloudWatch 통합 모니터링
- Performance Insights (쿼리 분석)
- 자동 알람 및 이벤트 알림

### 2. 핵심 원리 (How?)

#### RDS 모니터링 아키텍처

```mermaid
graph TB
    subgraph "RDS 인스턴스"
        DB[Database Engine]
        OS[Operating System]
        HW[Hardware Metrics]
    end
    
    subgraph "모니터링 계층"
        CW[CloudWatch<br/>기본 메트릭]
        EM[Enhanced Monitoring<br/>OS 메트릭]
        PI[Performance Insights<br/>쿼리 분석]
    end
    
    subgraph "알람 및 대응"
        SNS[SNS Topic]
        Lambda[Lambda 자동 대응]
        Email[이메일 알림]
    end
    
    DB --> CW
    OS --> EM
    DB --> PI
    
    CW --> SNS
    SNS --> Lambda
    SNS --> Email
    
    style DB fill:#e8f5e8
    style CW fill:#e3f2fd
    style EM fill:#e3f2fd
    style PI fill:#e3f2fd
    style SNS fill:#fff3e0
    style Lambda fill:#ffebee
```

#### 백업 및 복구 메커니즘

```mermaid
sequenceDiagram
    participant RDS as RDS Instance
    participant S3 as S3 Backup Storage
    participant Snap as Manual Snapshot
    participant PITR as Point-in-Time Recovery
    
    Note over RDS,S3: 자동 백업 (매일)
    RDS->>S3: 전체 백업 (Daily)
    RDS->>S3: 트랜잭션 로그 (5분마다)
    
    Note over RDS,Snap: 수동 스냅샷
    RDS->>Snap: 사용자 요청 시
    Snap->>S3: 스냅샷 저장
    
    Note over PITR: 복구 시나리오
    PITR->>S3: 백업 데이터 조회
    PITR->>S3: 트랜잭션 로그 조회
    S3->>PITR: 특정 시점 데이터 복원
    PITR->>RDS: 새 인스턴스 생성
```

#### Performance Insights 동작 원리

```mermaid
graph TB
    subgraph "데이터 수집"
        Q[실행 중인 쿼리]
        W[Wait Events]
        L[Lock 정보]
    end
    
    subgraph "분석 엔진"
        A[쿼리 집계]
        B[성능 병목 분석]
        C[추천 생성]
    end
    
    subgraph "시각화"
        D[Top SQL]
        E[Wait Event 차트]
        F[DB Load 그래프]
    end
    
    Q --> A
    W --> B
    L --> B
    
    A --> D
    B --> E
    B --> F
    
    style Q fill:#e8f5e8
    style W fill:#e8f5e8
    style L fill:#e8f5e8
    style A fill:#fff3e0
    style B fill:#fff3e0
    style C fill:#fff3e0
    style D fill:#e3f2fd
    style E fill:#e3f2fd
    style F fill:#e3f2fd
```

#### 백업 전략 비교

```mermaid
quadrantChart
    title Backup Strategy Selection Matrix
    x-axis Low Cost --> High Cost
    y-axis Short Term --> Long Term
    quadrant-1 Optimal
    quadrant-2 Cost Concern
    quadrant-3 Basic
    quadrant-4 Over Investment
    Auto Backup 7days: [0.2, 0.3]
    Auto Backup 35days: [0.3, 0.5]
    Manual Snapshot: [0.6, 0.8]
    Cross Region Copy: [0.8, 0.9]
```

**전략 설명**:
- **Auto Backup 7days**: 기본 전략, 비용 효율적
- **Auto Backup 35days**: 규정 준수, 중간 비용
- **Manual Snapshot**: 장기 보관, 높은 비용
- **Cross Region Copy**: 재해 복구, 최고 비용

#### RDS 운영 프로세스

```mermaid
stateDiagram-v2
    [*] --> 정상운영
    
    정상운영 --> 모니터링: 지속적 감시
    모니터링 --> 정상운영: 정상 범위
    모니터링 --> 경고: 임계값 초과
    
    경고 --> 분석: 원인 파악
    분석 --> 최적화: 성능 문제
    분석 --> 확장: 용량 부족
    
    최적화 --> 정상운영: 문제 해결
    확장 --> 정상운영: 리소스 증설
    
    정상운영 --> 장애: 심각한 문제
    장애 --> 복구: Failover/PITR
    복구 --> 정상운영: 복구 완료
```

#### 모니터링 메트릭 우선순위

```mermaid
graph TB
    A[RDS 모니터링 메트릭] --> B[Critical 메트릭]
    A --> C[Important 메트릭]
    A --> D[Nice-to-have 메트릭]
    
    B --> B1[CPU Utilization<br/>80% 이상 즉시 대응]
    B --> B2[Freeable Memory<br/>10% 미만 위험]
    B --> B3[Database Connections<br/>90% 이상 경고]
    
    C --> C1[Read/Write IOPS<br/>성능 추세 분석]
    C --> C2[Replica Lag<br/>5초 이상 주의]
    C --> C3[Disk Queue Depth<br/>병목 지점 파악]
    
    D --> D1[Network Throughput<br/>트래픽 패턴]
    D --> D2[Swap Usage<br/>메모리 부족 징후]
    
    style B1 fill:#ffebee
    style B2 fill:#ffebee
    style B3 fill:#ffebee
    style C1 fill:#fff3e0
    style C2 fill:#fff3e0
    style C3 fill:#fff3e0
    style D1 fill:#e8f5e8
    style D2 fill:#e8f5e8
```

#### 백업 및 복구 타임라인

```mermaid
timeline
    title RDS 백업 및 복구 전략
    section 일일 운영
        자동 백업 : 매일 새벽 3시
                  : 트랜잭션 로그 5분마다
    section 주간 관리
        수동 스냅샷 : 매주 일요일
                    : 주요 배포 전
    section 월간 관리
        크로스 리전 복제 : 매월 1일
                        : 재해 복구 테스트
    section 분기 관리
        백업 정리 : 오래된 스냅샷 삭제
                  : 비용 최적화
```

### 3. 주요 사용 사례 (When?)

#### 모니터링 시나리오

**실시간 성능 모니터링**:
- **CPU 사용률**: 70% 이상 시 스케일업 고려
- **메모리 사용률**: Swap 발생 시 인스턴스 크기 증가
- **IOPS**: 프로비저닝된 IOPS 대비 사용률 추적
- **네트워크**: Read/Write 처리량 모니터링

**장애 예방 모니터링**:
- **Disk Queue Depth**: 높은 값은 I/O 병목 신호
- **Read/Write Latency**: 응답 시간 증가 감지
- **Connection Count**: 동시 연결 수 제한 확인
- **Replication Lag**: 읽기 복제본 지연 시간 추적

#### 백업 및 복구 시나리오

**정기 백업 전략**:
```
일일 백업 (Daily):
├── 자동 백업: 매일 새벽 2시
├── 보관 기간: 7일
└── 비용: DB 크기만큼 무료

주간 백업 (Weekly):
├── 수동 스냅샷: 매주 일요일
├── 보관 기간: 4주
└── 비용: $0.095/GB-월

월간 백업 (Monthly):
├── 수동 스냅샷: 매월 1일
├── 보관 기간: 12개월
└── 비용: $0.095/GB-월
```

**재해 복구 시나리오**:
- **데이터 손상**: 특정 시점 복원 (PITR)
- **리전 장애**: 다른 리전으로 스냅샷 복사
- **테스트 환경**: 프로덕션 스냅샷으로 테스트 DB 생성
- **마이그레이션**: 스냅샷 기반 DB 이전

#### 성능 최적화 시나리오

**쿼리 성능 분석**:
```sql
-- Performance Insights에서 확인할 주요 쿼리
-- 1. 가장 느린 쿼리 (Top SQL)
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;

-- 2. 가장 많이 실행되는 쿼리
SELECT query, calls, total_time
FROM pg_stat_statements
ORDER BY calls DESC
LIMIT 10;

-- 3. 인덱스 사용률
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0;
```

**인덱스 최적화**:
- **Missing Index**: Performance Insights가 제안하는 인덱스 추가
- **Unused Index**: 사용하지 않는 인덱스 제거
- **Index Bloat**: 인덱스 재구성 (REINDEX)

#### 비용 최적화 시나리오

**스토리지 비용 절감**:
```
현재 상황:
- DB 크기: 100GB
- 자동 백업: 100GB (무료)
- 수동 스냅샷: 500GB ($47.50/월)
- 총 비용: $47.50/월

최적화 후:
- 오래된 스냅샷 삭제: 300GB 제거
- 남은 스냅샷: 200GB ($19/월)
- 절감액: $28.50/월 (60% 절감)
```

**인스턴스 비용 절감**:
- **Reserved Instance**: 1년 약정 시 40% 할인
- **적정 크기 조정**: 사용률 낮은 인스턴스 다운사이징
- **읽기 복제본 최적화**: 필요한 만큼만 유지

#### 고가용성 시나리오

**Multi-AZ 장애 대응**:
```
정상 상태:
Primary (AZ-A) ──동기 복제──> Standby (AZ-B)
        │
        └──> 애플리케이션 연결

장애 발생:
Primary (AZ-A) ✗ 장애 발생
        │
        └──> Standby (AZ-B) 자동 승격
                    │
                    └──> 애플리케이션 자동 재연결

복구 시간: 1-2분 (자동)
데이터 손실: 없음 (동기 복제)
```

**읽기 확장 시나리오**:
```
Primary (쓰기 전용)
    │
    ├──> Read Replica 1 (읽기 전용)
    ├──> Read Replica 2 (읽기 전용)
    └──> Read Replica 3 (읽기 전용)

사용 사례:
- 보고서 생성: Read Replica 1
- 분석 쿼리: Read Replica 2
- 검색 기능: Read Replica 3
```

#### 보안 강화 시나리오

**네트워크 격리**:
```
VPC (10.0.0.0/16)
├── Public Subnet (10.0.1.0/24)
│   └── Bastion Host (SSH 접근)
│
└── Private Subnet (10.0.11.0/24)
    └── RDS Instance (외부 접근 불가)
        │
        └── Security Group
            ├── Inbound: 3306 from App Servers only
            └── Outbound: All traffic
```

**암호화 적용**:
- **저장 데이터 암호화**: KMS 키로 EBS 볼륨 암호화
- **전송 데이터 암호화**: SSL/TLS 연결 강제
- **백업 암호화**: 스냅샷 자동 암호화
- **로그 암호화**: CloudWatch Logs 암호화

#### 마이그레이션 시나리오

**온프레미스 → RDS 마이그레이션**:
```
1단계: 평가
├── Database Migration Assessment Report
├── 스키마 호환성 확인
└── 데이터 크기 및 마이그레이션 시간 예측

2단계: 스키마 마이그레이션
├── AWS Schema Conversion Tool (SCT)
├── 스키마 변환 및 최적화
└── 테스트 환경에서 검증

3단계: 데이터 마이그레이션
├── AWS Database Migration Service (DMS)
├── 초기 전체 로드
└── 지속적 복제 (CDC)

4단계: 전환
├── 애플리케이션 연결 문자열 변경
├── DNS 전환
└── 온프레미스 DB 중지
```

**MySQL → PostgreSQL 마이그레이션**:
- **SCT**: 스키마 자동 변환
- **DMS**: 데이터 마이그레이션
- **호환성 검증**: 애플리케이션 쿼리 테스트
- **성능 튜닝**: PostgreSQL 최적화

#### 개발/테스트 환경 시나리오

**환경 분리 전략**:
```
프로덕션 (Production):
├── db.r5.xlarge (Multi-AZ)
├── 자동 백업: 7일
└── Performance Insights: 활성화

스테이징 (Staging):
├── db.t3.medium (Single-AZ)
├── 자동 백업: 3일
└── 프로덕션 스냅샷 복원

개발 (Development):
├── db.t3.small (Single-AZ)
├── 자동 백업: 1일
└── 샘플 데이터 사용
```

**비용 효율적 개발 환경**:
- **자동 시작/중지**: 업무 시간에만 실행
- **작은 인스턴스**: 개발용은 t3.small 사용
- **스냅샷 공유**: 프로덕션 데이터 복사 최소화

---

### 4. 비슷한 서비스 비교 (Which?)

#### AWS 내 대안 서비스

**RDS vs Aurora**

**언제 RDS를 사용**:
- **예산 제약**: Aurora보다 20-30% 저렴
- **단순한 워크로드**: 복잡한 고가용성 불필요
- **특정 엔진 버전**: Aurora가 지원하지 않는 버전 필요
- **소규모 애플리케이션**: 트래픽이 적고 예측 가능

**언제 Aurora를 사용**:
- **고성능 필요**: MySQL/PostgreSQL 대비 5배 빠른 성능
- **대규모 트래픽**: 초당 수만 건의 트랜잭션
- **글로벌 서비스**: Aurora Global Database로 다중 리전
- **자동 확장**: 스토리지 자동 확장 (최대 128TB)

**RDS vs EC2 + 직접 설치 DB**

**언제 RDS를 사용**:
- **관리 부담 최소화**: 패치, 백업 자동화
- **고가용성 필요**: Multi-AZ 자동 Failover
- **빠른 구축**: 몇 분 내 DB 생성
- **규정 준수**: AWS 인증 활용

**언제 EC2 + DB를 사용**:
- **완전한 제어 필요**: OS 레벨 접근 필요
- **특수한 설정**: RDS가 지원하지 않는 설정
- **레거시 애플리케이션**: 특정 DB 버전이나 플러그인
- **비용 최적화**: Reserved Instance + Spot Instance 조합

**RDS vs DynamoDB**

**언제 RDS를 사용**:
- **복잡한 쿼리**: JOIN, 집계, 트랜잭션
- **관계형 데이터**: 정규화된 스키마
- **기존 SQL 애플리케이션**: 마이그레이션 용이
- **ACID 보장**: 강력한 일관성 필요

**언제 DynamoDB를 사용**:
- **키-값 저장소**: 단순한 읽기/쓰기
- **무한 확장**: 자동 스케일링
- **서버리스**: 관리 불필요
- **밀리초 응답**: 초저지연 필요

#### 선택 기준 비교표

| 기준 | RDS | Aurora | EC2 + DB | DynamoDB |
|------|-----|--------|----------|----------|
| **비용** | 중간 | 높음 | 낮음 (관리 비용 제외) | 사용량 기반 |
| **성능** | 좋음 | 매우 좋음 | 설정에 따라 다름 | 매우 좋음 |
| **관리 복잡도** | 낮음 | 낮음 | 높음 | 매우 낮음 |
| **확장성** | 수직 확장 | 수평 + 수직 | 수동 확장 | 자동 무한 확장 |
| **고가용성** | Multi-AZ | 기본 제공 | 수동 구성 | 기본 제공 |
| **백업/복구** | 자동 | 자동 | 수동 | 자동 |
| **쿼리 복잡도** | 복잡한 SQL | 복잡한 SQL | 복잡한 SQL | 단순 쿼리 |
| **적합한 규모** | 중소규모 | 대규모 | 모든 규모 | 대규모 |
| **학습 곡선** | 낮음 | 낮음 | 높음 | 중간 |

#### 엔진별 선택 가이드

**MySQL vs PostgreSQL**

**MySQL 선택 시**:
- **읽기 중심**: 읽기 성능 우수
- **단순한 트랜잭션**: OLTP 워크로드
- **레플리케이션**: 비동기 복제 성능 좋음
- **커뮤니티**: 더 큰 커뮤니티와 자료

**PostgreSQL 선택 시**:
- **복잡한 쿼리**: 고급 SQL 기능
- **데이터 무결성**: 엄격한 ACID
- **JSON 지원**: NoSQL 기능 필요
- **확장성**: 다양한 확장 기능

**Oracle vs PostgreSQL**

**Oracle 선택 시**:
- **레거시 시스템**: 기존 Oracle 애플리케이션
- **엔터프라이즈 기능**: 고급 파티셔닝, RAC
- **상용 지원**: Oracle 공식 지원 필요
- **규정 준수**: Oracle 인증 필요

**PostgreSQL 선택 시**:
- **비용 절감**: 라이선스 비용 없음
- **오픈소스**: 커뮤니티 지원
- **클라우드 네이티브**: AWS 최적화
- **마이그레이션**: Oracle 호환 기능 제공

**SQL Server vs PostgreSQL**

**SQL Server 선택 시**:
- **Windows 환경**: .NET 애플리케이션
- **Microsoft 생태계**: Azure 통합
- **T-SQL**: 기존 SQL Server 코드
- **BI 도구**: SSRS, SSAS 사용

**PostgreSQL 선택 시**:
- **Linux 환경**: 오픈소스 스택
- **비용 효율**: 라이선스 비용 없음
- **표준 SQL**: ANSI SQL 준수
- **확장성**: 다양한 확장 기능

#### 실무 의사결정 프로세스

```mermaid
graph TB
    A[데이터베이스 필요] --> B{관계형 데이터?}
    
    B -->|Yes| C{트래픽 규모?}
    B -->|No| D[DynamoDB 고려]
    
    C -->|소규모| E{예산?}
    C -->|대규모| F[Aurora 권장]
    
    E -->|제한적| G[RDS 선택]
    E -->|충분| H{성능 중요?}
    
    H -->|Yes| F
    H -->|No| G
    
    G --> I{엔진 선택}
    F --> I
    
    I --> J[MySQL: 읽기 중심]
    I --> K[PostgreSQL: 복잡한 쿼리]
    I --> L[Oracle: 레거시]
    I --> M[SQL Server: Windows]
    
    style A fill:#e8f5e8
    style B fill:#fff3e0
    style C fill:#fff3e0
    style D fill:#ffebee
    style E fill:#fff3e0
    style F fill:#e3f2fd
    style G fill:#e3f2fd
    style H fill:#fff3e0
    style I fill:#f3e5f5
    style J fill:#e8f5e8
    style K fill:#e8f5e8
    style L fill:#e8f5e8
    style M fill:#e8f5e8
```

#### 마이그레이션 경로

**온프레미스 → RDS**:
```
1단계: 평가
├── 현재 DB 크기 및 성능 측정
├── 호환성 확인 (SCT)
└── 비용 예측

2단계: 테스트
├── 테스트 환경 구축
├── 스키마 마이그레이션
└── 성능 테스트

3단계: 마이그레이션
├── DMS로 데이터 복제
├── 애플리케이션 전환
└── 모니터링 및 최적화
```

**RDS → Aurora**:
```
1단계: 스냅샷 생성
├── RDS 스냅샷 생성
└── 다운타임 최소화 계획

2단계: Aurora 복원
├── 스냅샷에서 Aurora 생성
├── 파라미터 그룹 조정
└── 성능 테스트

3단계: 전환
├── 읽기 복제본 생성 (선택)
├── DNS 전환
└── RDS 종료
```

#### 비용 최적화 전략

**RDS 비용 구성**:
```
총 비용 = 인스턴스 비용 + 스토리지 비용 + 백업 비용 + 데이터 전송 비용

예시 (db.t3.medium, 100GB):
- 인스턴스: $0.068/hour × 730 = $49.64/월
- 스토리지 (gp3): $0.115/GB × 100 = $11.50/월
- 백업 (50GB 초과): $0.095/GB × 50 = $4.75/월
- 데이터 전송: 변동
─────────────────────────────────────────
총 예상 비용: ~$66/월
```

**비용 절감 방법**:
1. **Reserved Instance**: 1년 약정 시 40% 할감
2. **적정 크기 조정**: CloudWatch 메트릭 기반 다운사이징
3. **스토리지 최적화**: gp2 → gp3 전환 (20% 절감)
4. **백업 정리**: 오래된 스냅샷 삭제
5. **읽기 복제본 최적화**: 필요한 만큼만 유지

---

### 5. 장단점 분석

#### 장점

**✅ 관리 부담 최소화**:
- **자동 패치**: OS 및 DB 엔진 자동 업데이트
- **자동 백업**: 일일 자동 백업 및 PITR
- **자동 Failover**: Multi-AZ 자동 장애 조치 (1-2분)
- **모니터링 통합**: CloudWatch 자동 연동

**✅ 고가용성 및 내구성**:
- **Multi-AZ 배포**: 99.95% SLA 보장
- **자동 복제**: 동기식 데이터 복제
- **자동 백업**: 35일까지 보관 가능
- **스냅샷**: 수동 백업 무제한 보관

**✅ 확장성**:
- **수직 확장**: 인스턴스 타입 변경 (다운타임 최소)
- **스토리지 확장**: 온라인 스토리지 증설
- **읽기 확장**: Read Replica 최대 15개
- **성능 향상**: IOPS 및 처리량 조정

**✅ 보안**:
- **네트워크 격리**: VPC 내 Private Subnet 배치
- **암호화**: 저장 데이터 및 전송 데이터 암호화
- **IAM 통합**: 세밀한 권한 관리
- **감사 로그**: 모든 DB 활동 추적

**✅ 비용 효율성**:
- **종량제**: 사용한 만큼만 지불
- **Reserved Instance**: 최대 69% 할인
- **무료 백업**: DB 크기만큼 무료
- **자동 최적화**: AWS가 인프라 최적화

**✅ 다양한 엔진 지원**:
- **MySQL**: 5.7, 8.0
- **PostgreSQL**: 11, 12, 13, 14, 15, 16
- **MariaDB**: 10.3, 10.4, 10.5, 10.6, 10.11
- **Oracle**: 12c, 19c, 21c
- **SQL Server**: 2016, 2017, 2019, 2022

#### 단점/제약사항

**⚠️ OS 레벨 접근 불가**:
- **제약**: SSH 접근 불가, OS 설정 변경 불가
- **영향**: 특수한 OS 설정이나 모니터링 도구 설치 불가
- **대안**: 
  - Enhanced Monitoring으로 OS 메트릭 확인
  - Parameter Group으로 DB 설정 조정
  - CloudWatch Agent로 추가 메트릭 수집

**⚠️ 특정 DB 기능 제한**:
- **제약**: 일부 고급 기능 미지원
  - MySQL: SUPER 권한 제한
  - PostgreSQL: 일부 확장 기능 제한
  - Oracle: RAC, Data Guard 미지원
- **영향**: 특수한 DB 기능 사용 불가
- **대안**:
  - RDS 지원 기능으로 대체
  - Aurora로 마이그레이션 (더 많은 기능)
  - EC2 + 직접 설치 고려

**⚠️ 스토리지 제한**:
- **제약**: 
  - MySQL/PostgreSQL: 최대 64TB
  - Oracle: 최대 64TB
  - SQL Server: 최대 16TB
- **영향**: 초대규모 데이터베이스 제한
- **대안**:
  - Aurora로 마이그레이션 (최대 128TB)
  - 데이터 파티셔닝
  - 아카이빙 전략

**⚠️ 성능 제한**:
- **제약**: 
  - 인스턴스 타입에 따른 성능 상한
  - IOPS 제한 (최대 80,000 IOPS)
  - 네트워크 대역폭 제한
- **영향**: 초고성능 워크로드 제한
- **대안**:
  - Aurora로 마이그레이션 (5배 빠른 성능)
  - 읽기 복제본으로 부하 분산
  - 캐싱 계층 추가 (ElastiCache)

**⚠️ 비용**:
- **제약**: 
  - 24/7 실행 시 비용 발생
  - Multi-AZ는 2배 비용
  - 백업 스토리지 초과 시 추가 비용
- **영향**: 소규모 프로젝트에는 부담
- **대안**:
  - 개발/테스트 환경은 자동 시작/중지
  - Reserved Instance로 40% 절감
  - Aurora Serverless 고려 (사용량 기반)

**⚠️ 마이그레이션 복잡성**:
- **제약**: 
  - 온프레미스 → RDS 마이그레이션 시간 소요
  - 다운타임 발생 가능
  - 애플리케이션 호환성 검증 필요
- **영향**: 마이그레이션 프로젝트 복잡도 증가
- **대안**:
  - DMS로 최소 다운타임 마이그레이션
  - 단계적 마이그레이션 (읽기 복제본 활용)
  - 충분한 테스트 기간 확보

**⚠️ 리전 제약**:
- **제약**: 
  - 특정 리전에서만 사용 가능
  - 리전 간 복제 시 추가 비용
  - 글로벌 배포 시 복잡도 증가
- **영향**: 글로벌 서비스 구축 시 고려 필요
- **대안**:
  - Aurora Global Database (다중 리전)
  - 리전별 독립 DB 구축
  - 읽기 복제본 다중 리전 배치

#### 실무 고려사항

**언제 RDS를 선택하지 말아야 하는가**:

1. **완전한 제어 필요**:
   - OS 레벨 접근 필수
   - 특수한 커널 파라미터 조정
   - 커스텀 모니터링 에이전트 설치
   → **대안**: EC2 + 직접 설치

2. **초고성능 필요**:
   - 초당 수만 건 이상의 트랜잭션
   - 밀리초 단위 응답 시간 필수
   - 복잡한 분석 쿼리
   → **대안**: Aurora 또는 Redshift

3. **NoSQL 워크로드**:
   - 키-값 저장소
   - 문서 기반 데이터
   - 무한 확장 필요
   → **대안**: DynamoDB, DocumentDB

4. **비용 최우선**:
   - 매우 제한된 예산
   - 간헐적 사용 (개발/테스트)
   - 소규모 프로젝트
   → **대안**: Aurora Serverless, EC2 Spot

5. **레거시 시스템**:
   - 매우 오래된 DB 버전
   - RDS가 지원하지 않는 기능
   - 특수한 플러그인 필요
   → **대안**: EC2 + 직접 설치

#### 장단점 요약 비교

| 측면 | 장점 | 단점 | 완화 방법 |
|------|------|------|-----------|
| **관리** | 자동화된 운영 | OS 접근 불가 | Enhanced Monitoring |
| **가용성** | Multi-AZ 자동 Failover | 2배 비용 | 중요 DB만 Multi-AZ |
| **성능** | 쉬운 확장 | 성능 상한 존재 | Aurora 마이그레이션 |
| **보안** | 통합 보안 기능 | 일부 고급 기능 제한 | IAM + KMS 조합 |
| **비용** | 종량제 유연성 | 24/7 실행 시 비용 | Reserved Instance |
| **확장성** | 수직/수평 확장 | 스토리지 제한 (64TB) | 파티셔닝, Aurora |
| **호환성** | 다양한 엔진 지원 | 일부 기능 제한 | 호환성 사전 검증 |

#### 실무 의사결정 체크리스트

**RDS 도입 전 확인사항**:
- [ ] **워크로드 분석**: OLTP vs OLAP vs 혼합
- [ ] **성능 요구사항**: TPS, 응답 시간, 동시 연결 수
- [ ] **가용성 요구사항**: SLA, RTO, RPO
- [ ] **보안 요구사항**: 암호화, 감사, 규정 준수
- [ ] **예산**: 초기 비용, 운영 비용, 확장 비용
- [ ] **기술 스택**: 애플리케이션 호환성
- [ ] **운영 역량**: 관리형 vs 자체 운영
- [ ] **마이그레이션 계획**: 다운타임, 데이터 전환
- [ ] **확장 계획**: 향후 3-5년 성장 예측
- [ ] **재해 복구**: 백업, 복구 전략

**성공적인 RDS 도입을 위한 팁**:
1. **작게 시작**: 개발/테스트 환경부터 시작
2. **충분한 테스트**: 프로덕션 전 성능 및 호환성 검증
3. **모니터링 설정**: CloudWatch 알람 사전 구성
4. **백업 전략**: 자동 백업 + 정기 스냅샷
5. **비용 추적**: Cost Explorer로 비용 모니터링
6. **문서화**: 설정, 절차, 트러블슈팅 가이드
7. **교육**: 팀원 대상 RDS 운영 교육
8. **지속적 최적화**: 정기적인 성능 및 비용 리뷰
- 임계값 초과 시 자동 알람
- 예: CPU 80% 초과 시 SNS 알림

**쿼리 성능 분석**:
- 느린 쿼리 식별 (Performance Insights)
- 인덱스 누락 쿼리 발견
- 예: 1초 이상 쿼리 분석

**용량 계획**:
- 스토리지 사용량 추세 분석
- 연결 수 패턴 파악
- 예: 월별 증가율 예측

#### 백업 및 복구 시나리오

**정기 백업**:
- 매일 자동 백업 (새벽 시간)
- 35일 보관 (규정 준수)
- 예: 금융 서비스 데이터 보관

**장애 복구**:
- 데이터 손상 시 특정 시점 복구
- 잘못된 쿼리 실행 전으로 롤백
- 예: 실수로 DELETE 실행 후 복구

**마이그레이션**:
- 스냅샷으로 다른 리전 복사
- 개발/테스트 환경 생성
- 예: 프로덕션 → 스테이징 복제

### 4. 비슷한 서비스 비교 (Which?)

#### 모니터링 도구 비교

**CloudWatch vs Enhanced Monitoring**:

| 기준 | CloudWatch | Enhanced Monitoring |
|------|------------|---------------------|
| **수집 간격** | 1분 (기본) | 1초 ~ 60초 |
| **메트릭 종류** | DB 엔진 메트릭 | OS 레벨 메트릭 |
| **CPU 상세도** | 전체 CPU | 프로세스별 CPU |
| **메모리 상세도** | 전체 메모리 | 프로세스별 메모리 |
| **비용** | 무료 | 시간당 $0.01 |
| **권장 용도** | 기본 모니터링 | 상세 분석 |

**언제 CloudWatch 사용**:
- 기본 메트릭만 필요
- 비용 최소화
- 간단한 알람 설정

**언제 Enhanced Monitoring 사용**:
- OS 레벨 분석 필요
- 프로세스별 리소스 추적
- 상세한 트러블슈팅

**CloudWatch vs Performance Insights**:

| 기준 | CloudWatch | Performance Insights |
|------|------------|----------------------|
| **초점** | 인프라 메트릭 | 쿼리 성능 |
| **분석 대상** | CPU, Memory, IOPS | SQL 쿼리, Wait Events |
| **시각화** | 기본 차트 | 대화형 대시보드 |
| **쿼리 분석** | 불가 | 가능 (Top SQL) |
| **비용** | 무료 | 7일 무료, 이후 유료 |
| **권장 용도** | 인프라 모니터링 | 쿼리 튜닝 |

**언제 CloudWatch 사용**:
- 인프라 메트릭 중심
- 기본 알람 설정
- 비용 최소화

**언제 Performance Insights 사용**:
- 쿼리 성능 문제 분석
- 데이터베이스 튜닝
- 병목 지점 식별

#### 백업 방식 비교

**자동 백업 vs 수동 스냅샷**:

| 기준 | 자동 백업 | 수동 스냅샷 |
|------|-----------|-------------|
| **생성 방식** | 자동 (매일) | 수동 (사용자 요청) |
| **보관 기간** | 0-35일 | 무제한 |
| **PITR** | 지원 | 미지원 |
| **삭제 시점** | DB 삭제 시 함께 삭제 | 수동 삭제 필요 |
| **비용** | DB 크기만큼 무료 | 스토리지 비용 발생 |
| **권장 용도** | 일상 백업 | 장기 보관 |

**언제 자동 백업 사용**:
- 일상적인 백업
- Point-in-Time Recovery 필요
- 단기 보관 (35일 이내)

**언제 수동 스냅샷 사용**:
- 장기 보관 필요
- 특정 시점 영구 보존
- 다른 리전 복사

### 5. 장단점 분석

#### 장점

**✅ 자동화된 운영**:
- 백업 자동 실행 (실패 시 재시도)
- 패치 자동 적용 (유지보수 창)
- 모니터링 자동 설정

**✅ 통합 모니터링**:
- CloudWatch 통합 (단일 대시보드)
- Performance Insights (쿼리 분석)
- Enhanced Monitoring (OS 메트릭)

**✅ 간편한 복구**:
- Point-in-Time Recovery (5분 단위)
- 스냅샷 복원 (클릭 몇 번)
- 크로스 리전 복사 (재해 복구)

**✅ 비용 효율**:
- 백업 스토리지 무료 (DB 크기만큼)
- CloudWatch 기본 메트릭 무료
- 자동 스토리지 확장 (과다 프로비저닝 방지)

#### 단점/제약사항

**⚠️ 백업 보관 기간 제한**:
- 자동 백업: 최대 35일
- 장기 보관 시 수동 스냅샷 필요

**대안**: 수동 스냅샷으로 장기 보관

**⚠️ 복구 시 다운타임**:
- 새 인스턴스 생성 필요 (10-30분)
- 엔드포인트 변경 필요
- 애플리케이션 재연결 필요

**대안**: Multi-AZ로 Failover 자동화

**⚠️ Performance Insights 비용**:
- 7일 이후 유료 ($0.018/vCPU/hour)
- 장기 데이터 보관 시 비용 증가

**대안**: 필요 시에만 활성화

### 6. 비용 구조 💰

#### 모니터링 비용

**CloudWatch 메트릭**:
```
기본 메트릭: 무료
- CPU, Memory, IOPS, Connections 등
- 1분 간격 수집

커스텀 메트릭: $0.30/메트릭/월
- 사용자 정의 메트릭
- 애플리케이션 메트릭
```

**Enhanced Monitoring**:
```
$0.01/인스턴스/시간
- 1초 ~ 60초 간격 선택
- OS 레벨 메트릭

월 비용 예시:
- 1초 간격: $7.30/월
- 60초 간격: $7.30/월 (동일)
```

**Performance Insights**:
```
7일 보관: 무료
장기 보관: $0.018/vCPU/시간

월 비용 예시:
- db.t3.micro (1 vCPU): $13.14/월
- db.m5.large (2 vCPU): $26.28/월
```

#### 백업 비용

**자동 백업**:
```
DB 크기만큼 무료
- 예: 100GB DB → 100GB 백업 무료

초과분: $0.095/GB-월
- 예: 100GB DB + 50GB 추가 백업 = $4.75/월
```

**수동 스냅샷**:
```
$0.095/GB-월
- 모든 스냅샷 유료
- 예: 100GB 스냅샷 = $9.50/월
```

**크로스 리전 복사**:
```
데이터 전송: $0.02/GB
스토리지: $0.095/GB-월

예시 (100GB 스냅샷):
- 전송 비용: $2.00 (1회)
- 스토리지: $9.50/월
```

#### 비용 최적화 팁

**모니터링 최적화**:
- CloudWatch 기본 메트릭 활용 (무료)
- Enhanced Monitoring 필요 시에만 활성화
- Performance Insights 7일 보관 (무료)

**백업 최적화**:
- 자동 백업 보관 기간 최소화 (7-14일)
- 불필요한 수동 스냅샷 삭제
- 오래된 스냅샷 Glacier로 이동 (수동)

**알람 최적화**:
- 필수 메트릭만 알람 설정
- SNS 대신 CloudWatch Logs 활용
- Lambda로 자동 대응 (알람 감소)

### 7. 최신 업데이트 🆕

#### 2024년 주요 변경사항

**RDS Extended Support** (2024.02):
- 표준 지원 종료 후 3년 추가 지원
- PostgreSQL 11, MySQL 5.7 등
- 추가 비용 발생 (시간당 요금)

**Automated Backups Replication** (2024.05):
- 자동 백업을 다른 리전으로 복제
- 재해 복구 시간 단축
- 크로스 리전 PITR 지원

**CloudWatch Anomaly Detection** (2024.08):
- ML 기반 이상 탐지
- 자동 임계값 조정
- 거짓 알람 감소

#### 2025년 예정

**Intelligent Backup Scheduling**:
- 워크로드 패턴 분석
- 최적 백업 시간 자동 선택

**Predictive Scaling**:
- ML 기반 용량 예측
- 자동 스케일링 권장

**참조**: [AWS RDS What's New](https://aws.amazon.com/rds/whats-new/)

---

## 📊 실습 연계

### Lab 1에서 활용

**모니터링 설정**:
- CloudWatch 대시보드 생성
- CPU, Memory 알람 설정
- Performance Insights 활성화

**백업 설정**:
- 자동 백업 활성화 (7일 보관)
- 수동 스냅샷 생성
- Point-in-Time Recovery 테스트

**주의사항**:
- Enhanced Monitoring 비용 발생
- Performance Insights 7일 이후 유료
- 스냅샷 삭제 확인 (비용 절감)

---

## 🔗 공식 문서 (필수)

**⚠️ 학생들이 직접 확인해야 할 공식 문서**:
- 📘 [RDS 모니터링](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Monitoring.html)
- 📗 [백업 및 복원](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_CommonTasks.BackupRestore.html)
- 📙 [Performance Insights](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PerfInsights.html)
- 📕 [CloudWatch 통합](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/monitoring-cloudwatch.html)
- 🆕 [RDS 최신 기능](https://aws.amazon.com/rds/features/)

---

## 🔑 핵심 키워드

- **CloudWatch**: AWS 통합 모니터링 서비스
- **Enhanced Monitoring**: OS 레벨 상세 모니터링
- **Performance Insights**: 쿼리 성능 분석 도구
- **Automated Backup**: 자동 백업 (35일 보관)
- **Manual Snapshot**: 수동 스냅샷 (무제한 보관)
- **Point-in-Time Recovery (PITR)**: 특정 시점 복구
- **DB Parameter Group**: 데이터베이스 설정 그룹
- **Maintenance Window**: 유지보수 시간대
- **Event Notification**: 이벤트 알림 (SNS)

---

<div align="center">

**📊 실시간 모니터링** • **💾 자동 백업** • **🔧 성능 최적화** • **🚨 장애 대응**

*RDS 운영 자동화로 관리 부담 90% 감소*

</div>
