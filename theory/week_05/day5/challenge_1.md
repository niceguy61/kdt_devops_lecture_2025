# Week 5 Day 5 Challenge: 프로덕션급 CloudMart 배포 (15:00-15:50)

<div align="center">

**🏆 최종 도전** • **🚀 프로덕션급** • **📊 완전한 운영** • **🔐 엔터프라이즈 보안**

*Lab 1을 넘어 실제 운영 가능한 완전한 시스템 구축*

</div>

---

## 🕘 Challenge 정보
**시간**: 15:00-15:50 (50분)
**목표**: 프로덕션급 완성도로 CloudMart 전체 시스템 완성
**방식**: Lab 1 기반 고도화 + 추가 기능 구현
**예상 비용**: $0.80

## 🎯 Challenge 목표

### 📚 학습 목표
- Lab 1의 기본 인프라를 프로덕션급으로 고도화
- 모니터링, 로깅, 알람 시스템 완전 구축
- 백업 및 재해 복구 전략 실제 구현
- 보안 강화 및 비용 최적화

### 🛠️ 구현 목표
- 완전한 고가용성 (Multi-AZ + Auto Scaling)
- 종합 모니터링 대시보드
- 자동화된 백업 시스템
- 엔터프라이즈급 보안 설정

---

## 🚨 Challenge 시나리오: "CloudMart 프로덕션 런칭"

### 📖 배경 상황
**시나리오**: 
CloudMart가 드디어 정식 서비스를 시작합니다. 예상 사용자는 일 1만 명, 피크 시간대에는 동시 접속자 1,000명이 예상됩니다. 투자자들은 99.9% 가용성과 완벽한 보안을 요구하고 있습니다.

**긴급도**: 🔴 **Critical** - 내일 오픈 예정
**영향도**: 💰 **High** - 회사의 미래가 걸림
**제한시간**: ⏰ **50분**

**요구사항**:
1. **고가용성**: 어떤 AZ가 장애 나도 서비스 계속
2. **자동 확장**: 트래픽 증가 시 자동으로 서버 추가
3. **모니터링**: 실시간 대시보드 + 알람
4. **백업**: 데이터 손실 방지 (RPO < 5분)
5. **보안**: 최소 권한 + 암호화 + 감사 로그
6. **비용**: $0.80 이하로 구현

---

## 🏗️ 프로덕션급 아키텍처

### 📐 고도화된 아키텍처
```
┌─────────────────────────────────────────────────────────────┐
│                    AWS Cloud (ap-northeast-2)               │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         Route 53 (DNS + Health Check)                │  │
│  └──────────────────────────────────────────────────────┘  │
│                          ↓                                   │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         CloudFront (CDN + WAF)                       │  │
│  └──────────────────────────────────────────────────────┘  │
│                          ↓                                   │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         S3 (Frontend + Versioning + Lifecycle)       │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │    VPC (10.0.0.0/16) + Flow Logs                     │  │
│  │                                                       │  │
│  │  ┌────────────────┐  ┌────────────────┐             │  │
│  │  │ AZ-A           │  │ AZ-B           │             │  │
│  │  │                │  │                │             │  │
│  │  │ Public Subnet  │  │ Public Subnet  │             │  │
│  │  │ ┌────────────┐ │  │ ┌────────────┐ │             │  │
│  │  │ │ ALB        │ │  │ │ ALB        │ │             │  │
│  │  │ │ + SSL Cert │ │  │ │ + SSL Cert │ │             │  │
│  │  │ └────────────┘ │  │ └────────────┘ │             │  │
│  │  │ ┌────────────┐ │  │ ┌────────────┐ │             │  │
│  │  │ │ NAT GW     │ │  │ │ NAT GW     │ │             │  │
│  │  │ └────────────┘ │  │ └────────────┘ │             │  │
│  │  │                │  │                │             │  │
│  │  │ Private Subnet │  │ Private Subnet │             │  │
│  │  │ ┌────────────┐ │  │ ┌────────────┐ │             │  │
│  │  │ │ EC2 (ASG)  │ │  │ │ EC2 (ASG)  │ │             │  │
│  │  │ │ + IAM Role │ │  │ │ + IAM Role │ │             │  │
│  │  │ │ + CW Agent │ │  │ │ + CW Agent │ │             │  │
│  │  │ └────────────┘ │  │ └────────────┘ │             │  │
│  │  │                │  │                │             │  │
│  │  │ ┌────────────┐ │  │ ┌────────────┐ │             │  │
│  │  │ │ RDS Primary│ │  │ │ RDS Standby│ │             │  │
│  │  │ │ + Encrypted│ │  │ │ + Encrypted│ │             │  │
│  │  │ │ + Auto BKP │ │  │ │ + Auto BKP │ │             │  │
│  │  │ └────────────┘ │  │ └────────────┘ │             │  │
│  │  │                │  │                │             │  │
│  │  │ ┌────────────┐ │  │ ┌────────────┐ │             │  │
│  │  │ │ Redis      │ │  │ │ Redis      │ │             │  │
│  │  │ │ + Encrypted│ │  │ │ + Encrypted│ │             │  │
│  │  │ └────────────┘ │  │ └────────────┘ │             │  │
│  │  └────────────────┘  └────────────────┘             │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         CloudWatch (Metrics + Logs + Alarms)         │  │
│  │         + SNS (Email/SMS Notifications)              │  │
│  │         + CloudTrail (Audit Logs)                    │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

**Lab 1 대비 추가 사항**:
- ✅ Route 53 DNS + Health Check
- ✅ CloudFront WAF (보안)
- ✅ S3 Versioning + Lifecycle
- ✅ VPC Flow Logs
- ✅ 2개 AZ에 각각 NAT Gateway (고가용성)
- ✅ SSL/TLS 인증서
- ✅ CloudWatch Agent (상세 메트릭)
- ✅ RDS/Redis 암호화
- ✅ 자동 백업 설정
- ✅ CloudWatch 알람 + SNS
- ✅ CloudTrail 감사 로그

---

## 🛠️ Challenge 구현 단계

### Phase 1: Lab 1 기반 인프라 (10분)

**전제 조건**: Lab 1 완료 상태

**추가 작업**:
1. **NAT Gateway 추가** (AZ-B)
   - 고가용성을 위해 각 AZ에 NAT Gateway 배치
   - Private Route Table 분리 (AZ별)

2. **Security Group 강화**
   - 최소 권한 원칙 적용
   - 불필요한 포트 모두 차단
   - IP 화이트리스트 적용

3. **IAM Role 세밀화**
   - EC2 Instance Role 최소 권한
   - RDS 접근 권한만 부여
   - CloudWatch Logs 쓰기 권한

---

### Phase 2: 모니터링 & 알람 구축 (15분)

#### 2-1. CloudWatch 대시보드 생성

**AWS Console 경로**:
```
CloudWatch → Dashboards → Create dashboard
```

**대시보드 구성**:
```yaml
Dashboard Name: CloudMart-Production

Widgets:
  1. ALB Metrics:
     - RequestCount
     - TargetResponseTime
     - HealthyHostCount
     - UnHealthyHostCount
  
  2. EC2 Metrics:
     - CPUUtilization (모든 인스턴스)
     - NetworkIn/Out
     - StatusCheckFailed
  
  3. RDS Metrics:
     - CPUUtilization
     - DatabaseConnections
     - ReadLatency / WriteLatency
     - FreeStorageSpace
  
  4. ElastiCache Metrics:
     - CPUUtilization
     - CacheHits / CacheMisses
     - NetworkBytesIn/Out
  
  5. Custom Metrics:
     - API Response Time (from logs)
     - Error Rate
     - Active Users
```

**이미지 자리**: CloudWatch 대시보드

#### 2-2. CloudWatch 알람 설정

**필수 알람 5개**:
```yaml
# 1. EC2 CPU 과부하
Alarm: CloudMart-EC2-HighCPU
Metric: CPUUtilization
Threshold: > 80% for 2 periods (10분)
Action: SNS → Email/SMS

# 2. RDS 연결 수 초과
Alarm: CloudMart-RDS-HighConnections
Metric: DatabaseConnections
Threshold: > 80
Action: SNS → Email

# 3. ALB 응답 시간 지연
Alarm: CloudMart-ALB-SlowResponse
Metric: TargetResponseTime
Threshold: > 1 second for 3 periods
Action: SNS → Email + Auto Scaling

# 4. Unhealthy Hosts
Alarm: CloudMart-UnhealthyHosts
Metric: UnHealthyHostCount
Threshold: >= 1
Action: SNS → Email (즉시)

# 5. RDS 저장 공간 부족
Alarm: CloudMart-RDS-LowStorage
Metric: FreeStorageSpace
Threshold: < 2 GB
Action: SNS → Email
```

**이미지 자리**: CloudWatch 알람 설정

#### 2-3. CloudWatch Logs 설정

**Log Groups 생성**:
```yaml
/aws/ec2/cloudmart-backend:
  Retention: 7 days
  Metric Filters:
    - ErrorCount: [ERROR]
    - SlowQuery: { $.query_time > 1 }

/aws/alb/cloudmart-alb:
  Retention: 30 days
  S3 Export: Enabled (장기 보관)

/aws/rds/cloudmart-db:
  Retention: 7 days
  Slow Query Log: Enabled
```

**이미지 자리**: CloudWatch Logs

---

### Phase 3: 백업 & 재해 복구 (10분)

#### 3-1. RDS 자동 백업 설정

**AWS Console 경로**:
```
RDS → Databases → cloudmart-db → Modify
```

**백업 설정**:
```yaml
Automated Backup:
  Backup Retention: 7 days
  Backup Window: 03:00-04:00 (새벽)
  Copy to Another Region: ap-northeast-1 (도쿄)

Point-in-Time Recovery:
  Enabled: Yes
  Granularity: 5 minutes

Manual Snapshot:
  Create Now: cloudmart-db-snapshot-day5
  Retention: 30 days
```

**이미지 자리**: RDS 백업 설정

#### 3-2. S3 Versioning & Lifecycle

**S3 버킷 설정**:
```yaml
Versioning: Enabled

Lifecycle Rules:
  Rule 1: Archive Old Versions
    - Current Version: Keep
    - Previous Versions: Move to Glacier after 30 days
    - Delete after 90 days
  
  Rule 2: Incomplete Multipart Uploads
    - Delete after 7 days
```

**이미지 자리**: S3 Versioning

#### 3-3. EBS 스냅샷 자동화

**AWS Backup 설정**:
```yaml
Backup Plan: CloudMart-Daily-Backup
Resources: All EC2 volumes with tag "Backup=true"
Schedule: Daily at 02:00
Retention: 7 days
```

**이미지 자리**: AWS Backup

---

### Phase 4: 보안 강화 (10분)

#### 4-1. 암호화 설정

**RDS 암호화**:
```yaml
Storage Encryption: Enabled (KMS)
Encryption at Rest: AES-256
Encryption in Transit: SSL/TLS Required
```

**ElastiCache 암호화**:
```yaml
Encryption at Rest: Enabled
Encryption in Transit: Enabled
Auth Token: Enabled
```

**S3 암호화**:
```yaml
Default Encryption: Enabled (SSE-S3)
Bucket Policy: Enforce HTTPS only
```

**이미지 자리**: 암호화 설정

#### 4-2. CloudTrail 감사 로그

**AWS Console 경로**:
```
CloudTrail → Trails → Create trail
```

**설정**:
```yaml
Trail Name: CloudMart-Audit-Trail
Apply to All Regions: Yes
Management Events: Read/Write
Data Events: S3 bucket (cloudmart-frontend)
Log File Validation: Enabled
S3 Bucket: cloudmart-audit-logs
```

**이미지 자리**: CloudTrail 설정

#### 4-3. VPC Flow Logs

**VPC Flow Logs 설정**:
```yaml
VPC: cloudmart-vpc
Filter: All (Accept + Reject)
Destination: CloudWatch Logs
Log Group: /aws/vpc/cloudmart-flow-logs
Retention: 7 days
```

**이미지 자리**: VPC Flow Logs

---

### Phase 5: 최종 검증 & 최적화 (5분)

#### 5-1. 부하 테스트

**간단한 부하 테스트**:
```bash
# Apache Bench로 부하 테스트
ab -n 1000 -c 100 http://<ALB-DNS>/api/products

# 결과 확인
# - Requests per second
# - Time per request
# - Failed requests
```

**CloudWatch에서 확인**:
- CPU 사용률 증가
- Auto Scaling 동작 (필요시)
- 응답 시간 유지

**이미지 자리**: 부하 테스트 결과

#### 5-2. 장애 시뮬레이션

**시나리오 1: EC2 인스턴스 종료**:
```bash
# 1개 인스턴스 수동 종료
aws ec2 terminate-instances --instance-ids <instance-id>

# 확인 사항:
# - ALB가 Unhealthy로 표시
# - ASG가 새 인스턴스 자동 생성
# - 서비스 중단 없음
```

**시나리오 2: RDS Failover 테스트**:
```bash
# RDS Failover 수동 실행
aws rds reboot-db-instance \
  --db-instance-identifier cloudmart-db \
  --force-failover

# 확인 사항:
# - 1-2분 내 Standby로 전환
# - 애플리케이션 자동 재연결
# - 데이터 손실 없음
```

**이미지 자리**: 장애 시뮬레이션

---

## 🎯 성공 기준

### 📊 기능적 요구사항
- [ ] **고가용성**: 1개 AZ 장애 시에도 서비스 정상
- [ ] **자동 확장**: CPU 70% 초과 시 자동 스케일링
- [ ] **모니터링**: 실시간 대시보드 + 5개 알람 동작
- [ ] **백업**: RDS 자동 백업 + S3 버전 관리
- [ ] **보안**: 암호화 + CloudTrail + VPC Flow Logs

### ⏱️ 성능 요구사항
- [ ] **응답 시간**: 평균 < 500ms, P95 < 1s
- [ ] **가용성**: 99.9% (연간 8.76시간 다운타임)
- [ ] **확장성**: 동시 접속자 1,000명 처리
- [ ] **복구 시간**: RTO < 5분, RPO < 5분

### 🔒 보안 요구사항
- [ ] **암호화**: 저장 데이터 + 전송 데이터 모두 암호화
- [ ] **접근 제어**: 최소 권한 원칙 적용
- [ ] **감사 로그**: 모든 API 호출 기록
- [ ] **네트워크**: Private Subnet에 민감 리소스 배치

### 💰 비용 요구사항
- [ ] **예산 준수**: $0.80 이하
- [ ] **비용 최적화**: 프리티어 최대 활용
- [ ] **리소스 정리**: 실습 후 즉시 삭제

---

## 🏆 평가 기준

### 점수 배분 (100점 만점)
```yaml
아키텍처 설계 (30점):
  - Multi-AZ 구성: 10점
  - 보안 설계: 10점
  - 확장성 고려: 10점

고가용성 구현 (30점):
  - Auto Scaling 동작: 10점
  - RDS Multi-AZ: 10점
  - 장애 복구 테스트: 10점

모니터링 (20점):
  - 대시보드 구성: 10점
  - 알람 설정: 10점

보안 설정 (20점):
  - 암호화: 7점
  - IAM 정책: 7점
  - 감사 로그: 6점
```

### 등급 기준
- **S등급 (90-100점)**: 프로덕션 즉시 배포 가능
- **A등급 (80-89점)**: 일부 개선 후 배포 가능
- **B등급 (70-79점)**: 추가 작업 필요
- **C등급 (60-69점)**: 재검토 필요

---

## 🧹 Challenge 정리

**정리 순서**:
```
1. CloudTrail Trail 삭제
2. CloudWatch 알람 삭제
3. CloudWatch 대시보드 삭제
4. AWS Backup Plan 삭제
5. RDS 스냅샷 삭제
6. (Lab 1 정리 절차 동일)
```

**이미지 자리**: 정리 완료

---

## 💡 Challenge 회고

### 🤝 팀 회고 (15분)
1. **가장 어려웠던 부분**: 
2. **프로덕션급 구현의 차이점**:
3. **실무 적용 시 추가 고려사항**:
4. **Week 5 전체 학습 소감**:

### 📊 학습 성과
- **기술적 성취**: 프로덕션급 CloudMart 완성
- **실무 역량**: 고가용성 + 모니터링 + 보안 통합 구현
- **Week 5 완료**: AWS 핵심 서비스 실무 활용 능력 습득

---

## 🎉 Week 5 완료!

### 🏆 달성한 것들
- [ ] AWS 핵심 서비스 (VPC, EC2, RDS, S3, ALB) 마스터
- [ ] Docker Compose → AWS 마이그레이션 완료
- [ ] 고가용성 아키텍처 설계 및 구현
- [ ] 프로덕션급 모니터링 및 보안 구축
- [ ] CloudMart 프로젝트 AWS 배포 완성

### 🚀 다음 단계
- **Terraform 특강**: Infrastructure as Code
- **기본 프로젝트**: 4주간 팀 프로젝트
- **심화 프로젝트**: 5주간 전문화 트랙

---

<div align="center">

**🎉 Week 5 완료!** • **🏆 CloudMart 프로덕션 배포 성공** • **🚀 다음 여정 준비**

*5일간의 AWS 집중 과정을 완주하신 것을 축하합니다!*

</div>
