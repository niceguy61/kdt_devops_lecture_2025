# Week 5 Day 5 Lab 1: CloudMart 인프라 구축 (14:00-14:50)

<div align="center">

**🚀 전체 배포** • **🏗️ Multi-AZ** • **📊 모니터링** • **🔐 보안**

*CloudMart 프로젝트를 AWS에 완전 배포*

</div>

---

## 🕘 Lab 정보
**시간**: 14:00-14:50 (50분)
**목표**: CloudMart 전체 인프라를 AWS에 배포하고 검증
**방식**: AWS Web Console 실습
**예상 비용**: $0.50

## 🎯 학습 목표
- [ ] Multi-AZ VPC 네트워크 구축
- [ ] RDS PostgreSQL Multi-AZ 구성
- [ ] ElastiCache Redis 클러스터 생성
- [ ] ALB + ASG로 Backend 배포
- [ ] S3 + CloudFront로 Frontend 배포
- [ ] CloudWatch 모니터링 설정

---

## 🏗️ 구축할 아키텍처

### 📐 최종 아키텍처
```
┌─────────────────────────────────────────────────────────┐
│                    AWS Cloud (ap-northeast-2)           │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │              CloudFront (Global CDN)               │ │
│  └────────────────────────────────────────────────────┘ │
│                          ↓                               │
│  ┌────────────────────────────────────────────────────┐ │
│  │         S3 Bucket (Frontend - React)               │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │    VPC (10.0.0.0/16)                               │ │
│  │                                                     │ │
│  │  ┌──────────────────┐  ┌──────────────────┐       │ │
│  │  │ AZ-A             │  │ AZ-B             │       │ │
│  │  │                  │  │                  │       │ │
│  │  │ Public Subnet    │  │ Public Subnet    │       │ │
│  │  │ ┌──────────────┐ │  │ ┌──────────────┐ │       │ │
│  │  │ │     ALB      │ │  │ │     ALB      │ │       │ │
│  │  │ └──────────────┘ │  │ └──────────────┘ │       │ │
│  │  │                  │  │                  │       │ │
│  │  │ Private Subnet   │  │ Private Subnet   │       │ │
│  │  │ ┌──────────────┐ │  │ ┌──────────────┐ │       │ │
│  │  │ │ EC2 (ASG)    │ │  │ │ EC2 (ASG)    │ │       │ │
│  │  │ │ Backend API  │ │  │ │ Backend API  │ │       │ │
│  │  │ └──────────────┘ │  │ └──────────────┘ │       │ │
│  │  │                  │  │                  │       │ │
│  │  │ ┌──────────────┐ │  │ ┌──────────────┐ │       │ │
│  │  │ │ RDS Primary  │ │  │ │ RDS Standby  │ │       │ │
│  │  │ │ PostgreSQL   │ │  │ │ PostgreSQL   │ │       │ │
│  │  │ └──────────────┘ │  │ └──────────────┘ │       │ │
│  │  │                  │  │                  │       │ │
│  │  │ ┌──────────────┐ │  │ ┌──────────────┐ │       │ │
│  │  │ │ ElastiCache  │ │  │ │ ElastiCache  │ │       │ │
│  │  │ │ Redis        │ │  │ │ Redis        │ │       │ │
│  │  │ └──────────────┘ │  │ └──────────────┘ │       │ │
│  │  └──────────────────┘  └──────────────────┘       │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

**이미지 자리**: 최종 아키텍처 다이어그램

### 🔗 참조 Session
**당일 Session**:
- [Session 1: 배포 전략 수립](./session_1.md) - 마이그레이션 계획
- [Session 2: 인프라 구성](./session_2.md) - VPC, RDS, ElastiCache
- [Session 3: 모니터링 & 로깅](./session_3.md) - CloudWatch
- [Session 4: 보안 & 백업](./session_4.md) - IAM, 보안 그룹

**이전 Day Session**:
- [Day 1 Session 2: VPC 아키텍처](../day1/session_2.md) - VPC 기초
- [Day 3 Session 1: RDS 기초](../day3/session_1.md) - RDS 구성
- [Day 4 Session 1: ELB](../day4/session_1.md) - ALB 설정

---

## 📦 사전 준비: CloudMart 샘플 앱 다운로드

### 📥 샘플 앱 다운로드

**다운로드 링크**:
- 🔗 [cloudmart-sample-app.tar.gz 다운로드](https://github.com/your-repo/releases/download/v1.0.0/cloudmart-sample-app.tar.gz)

**압축 해제**:
```bash
# 다운로드한 파일 압축 해제
tar -xzf cloudmart-sample-app.tar.gz
cd cloudmart-sample-app

# 구조 확인
ls -la
# backend/     - Node.js API 서버
# frontend/    - React 웹 애플리케이션
# database/    - PostgreSQL 초기화 스크립트
# README.md    - 사용 가이드
```

**포함된 내용**:
- **Backend**: Node.js 22 + Express + PostgreSQL + Redis
- **Frontend**: React 18 + 반응형 UI
- **Database**: PostgreSQL 16 스키마 + 샘플 데이터 (20개 상품)

**💡 Windows 사용자 또는 상세 가이드 필요 시**:
- 📖 [CloudMart 샘플 앱 사용 가이드](./SAMPLE_APP_GUIDE.md) - WSL 설정, 로컬 테스트, 커스터마이징 방법

**이미지 자리**: 샘플 앱 구조

---

## 🛠️ Step 1: VPC 네트워크 구성 (10분)

### 📋 이 단계에서 할 일
- VPC 생성 (10.0.0.0/16)
- 4개 Subnet 생성 (Public × 2, Private × 2)
- Internet Gateway 및 NAT Gateway 설정
- Route Table 구성

### 🔗 참조 개념
- [Session 2: 인프라 구성](./session_2.md) - Multi-AZ VPC 설계

### 📝 실습 절차

#### 1-1. VPC 생성

**AWS Console 경로**:
- 🔗 [VPC Console 바로가기](https://ap-northeast-2.console.aws.amazon.com/vpc/home?region=ap-northeast-2#vpcs:)
```
AWS Console → VPC → Your VPCs → Create VPC
```

**설정 값**:
| 항목 | 값 | 설명 |
|------|-----|------|
| Name | cloudmart-vpc | VPC 이름 |
| IPv4 CIDR | 10.0.0.0/16 | 65,536개 IP |
| IPv6 CIDR | No IPv6 | IPv6 미사용 |
| Tenancy | Default | 공유 하드웨어 |

**이미지 자리**: VPC 생성 화면

#### 1-2. Subnet 생성 (4개)

**AWS Console 경로**:
- 🔗 [Subnets Console 바로가기](https://ap-northeast-2.console.aws.amazon.com/vpc/home?region=ap-northeast-2#subnets:)
```
VPC → Subnets → Create subnet
```

**설정 값**:
| Subnet 이름 | AZ | CIDR | 타입 |
|-------------|-----|------|------|
| cloudmart-public-a | ap-northeast-2a | 10.0.1.0/24 | Public |
| cloudmart-public-b | ap-northeast-2b | 10.0.2.0/24 | Public |
| cloudmart-private-a | ap-northeast-2a | 10.0.11.0/24 | Private |
| cloudmart-private-b | ap-northeast-2b | 10.0.12.0/24 | Private |

**이미지 자리**: Subnet 생성 화면

#### 1-3. Internet Gateway 생성

**AWS Console 경로**:
- 🔗 [Internet Gateways Console 바로가기](https://ap-northeast-2.console.aws.amazon.com/vpc/home?region=ap-northeast-2#igws:)
```
VPC → Internet Gateways → Create internet gateway
```

**설정**:
- Name: cloudmart-igw
- Attach to VPC: cloudmart-vpc

**이미지 자리**: IGW 연결 화면

#### 1-4. NAT Gateway 생성

**AWS Console 경로**:
- 🔗 [NAT Gateways Console 바로가기](https://ap-northeast-2.console.aws.amazon.com/vpc/home?region=ap-northeast-2#NatGateways:)
```
VPC → NAT Gateways → Create NAT gateway
```

**설정**:
- Name: cloudmart-nat-a
- Subnet: cloudmart-public-a
- Elastic IP: Allocate Elastic IP

**이미지 자리**: NAT Gateway 생성 화면

#### 1-5. Route Table 설정

**Public Route Table**:
```
Name: cloudmart-public-rt
Routes:
  - 10.0.0.0/16 → local
  - 0.0.0.0/0 → cloudmart-igw
Associated Subnets:
  - cloudmart-public-a
  - cloudmart-public-b
```

**Private Route Table**:
```
Name: cloudmart-private-rt
Routes:
  - 10.0.0.0/16 → local
  - 0.0.0.0/0 → cloudmart-nat-a
Associated Subnets:
  - cloudmart-private-a
  - cloudmart-private-b
```

**이미지 자리**: Route Table 설정 화면

### ✅ Step 1 검증

**AWS Console에서 확인**:
```
VPC → Your VPCs → cloudmart-vpc 선택
→ Details 탭에서 CIDR 확인: 10.0.0.0/16

VPC → Subnets → Filter by VPC: cloudmart-vpc
→ 4개 Subnet 확인 (Public × 2, Private × 2)

VPC → Internet Gateways → cloudmart-igw
→ State: Attached

VPC → NAT Gateways → cloudmart-nat-a
→ State: Available

VPC → Route Tables
→ cloudmart-public-rt: 0.0.0.0/0 → IGW 확인
→ cloudmart-private-rt: 0.0.0.0/0 → NAT GW 확인
```

**이미지 자리**: 검증 결과

**✅ 체크리스트**:
- [ ] VPC 생성 완료 (10.0.0.0/16)
- [ ] 4개 Subnet 생성 완료
- [ ] Internet Gateway 연결 완료
- [ ] NAT Gateway 생성 완료
- [ ] Route Table 설정 완료

---

## 🛠️ Step 2: RDS PostgreSQL 구성 (10분)

### 📋 이 단계에서 할 일
- DB Subnet Group 생성
- RDS PostgreSQL Multi-AZ 생성
- Security Group 설정

### 🔗 참조 개념
- [Session 2: 인프라 구성](./session_2.md) - RDS Multi-AZ

### 📝 실습 절차

#### 2-1. DB Subnet Group 생성

**AWS Console 경로**:
- 🔗 [RDS Subnet Groups Console 바로가기](https://ap-northeast-2.console.aws.amazon.com/rds/home?region=ap-northeast-2#db-subnet-groups-list:)
```
RDS → Subnet groups → Create DB subnet group
```

**설정**:
- Name: cloudmart-db-subnet-group
- VPC: cloudmart-vpc
- Subnets: cloudmart-private-a, cloudmart-private-b

**이미지 자리**: DB Subnet Group 생성

#### 2-2. Security Group 생성

**AWS Console 경로**:
- 🔗 [Security Groups Console 바로가기](https://ap-northeast-2.console.aws.amazon.com/ec2/home?region=ap-northeast-2#SecurityGroups:)
```
EC2 → Security Groups → Create security group
```

**설정**:
```yaml
Name: cloudmart-rds-sg
VPC: cloudmart-vpc
Inbound Rules:
  - Type: PostgreSQL (5432)
    Source: cloudmart-backend-sg (나중에 생성)
    Description: Backend access only
Outbound Rules:
  - Type: All traffic
    Destination: 0.0.0.0/0
```

**이미지 자리**: RDS Security Group

#### 2-3. RDS 인스턴스 생성

**AWS Console 경로**:
- 🔗 [RDS Databases Console 바로가기](https://ap-northeast-2.console.aws.amazon.com/rds/home?region=ap-northeast-2#databases:)
```
RDS → Databases → Create database
```

**설정 값**:
| 항목 | 값 |
|------|-----|
| Engine | PostgreSQL 15 |
| Template | Free tier |
| DB instance identifier | cloudmart-db |
| Master username | cloudmart_admin |
| Master password | [강력한 비밀번호] |
| DB instance class | db.t3.micro |
| Storage | 20 GB gp3 |
| Multi-AZ | Enabled |
| VPC | cloudmart-vpc |
| Subnet group | cloudmart-db-subnet-group |
| Public access | No |
| Security group | cloudmart-rds-sg |
| Initial database | cloudmart |

**이미지 자리**: RDS 생성 화면

### ✅ Step 2 검증

**AWS Console에서 확인**:
```
RDS → Databases → cloudmart-db 선택
→ Status: Available
→ Multi-AZ: Yes
→ Endpoint 복사 (나중에 사용)

RDS → Subnet groups → cloudmart-db-subnet-group
→ Subnets: 2개 확인

EC2 → Security Groups → cloudmart-rds-sg
→ Inbound rules: PostgreSQL (5432) 확인
```

**이미지 자리**: RDS 생성 완료

**✅ 체크리스트**:
- [ ] DB Subnet Group 생성 완료
- [ ] RDS Security Group 생성 완료
- [ ] RDS 인스턴스 생성 완료 (Multi-AZ)
- [ ] 상태: Available

---

## 🛠️ Step 3: ElastiCache Redis 구성 (10분)

### 📋 이 단계에서 할 일
- Cache Subnet Group 생성
- ElastiCache Redis 클러스터 생성
- Security Group 설정

### 🔗 참조 개념
- [Session 2: 인프라 구성](./session_2.md) - ElastiCache Redis

### 📝 실습 절차

#### 3-1. Cache Subnet Group 생성

**AWS Console 경로**:
- 🔗 [ElastiCache Subnet Groups Console 바로가기](https://ap-northeast-2.console.aws.amazon.com/elasticache/home?region=ap-northeast-2#/subnet-groups)
```
ElastiCache → Subnet groups → Create subnet group
```

**설정**:
- Name: cloudmart-cache-subnet-group
- VPC: cloudmart-vpc
- Subnets: cloudmart-private-a, cloudmart-private-b

**이미지 자리**: Cache Subnet Group

#### 3-2. Security Group 생성

**설정**:
```yaml
Name: cloudmart-redis-sg
Inbound Rules:
  - Type: Custom TCP (6379)
    Source: cloudmart-backend-sg
    Description: Backend access only
```

**이미지 자리**: Redis Security Group

#### 3-3. Redis 클러스터 생성

**AWS Console 경로**:
- 🔗 [ElastiCache Redis Console 바로가기](https://ap-northeast-2.console.aws.amazon.com/elasticache/home?region=ap-northeast-2#/redis)
```
ElastiCache → Redis clusters → Create
```

**설정**:
| 항목 | 값 |
|------|-----|
| Cluster mode | Disabled |
| Name | cloudmart-redis |
| Engine version | 7.0 |
| Node type | cache.t3.micro |
| Number of replicas | 1 |
| Multi-AZ | Enabled |
| Subnet group | cloudmart-cache-subnet-group |
| Security group | cloudmart-redis-sg |

**이미지 자리**: Redis 생성 화면

### ✅ Step 3 검증

**AWS Console에서 확인**:
```
ElastiCache → Redis clusters → cloudmart-redis 선택
→ Status: Available
→ Cluster mode: Disabled
→ Number of nodes: 2 (Primary + Replica)
→ Primary endpoint 복사 (나중에 사용)

ElastiCache → Subnet groups → cloudmart-cache-subnet-group
→ Subnets: 2개 확인

EC2 → Security Groups → cloudmart-redis-sg
→ Inbound rules: Custom TCP (6379) 확인
```

**이미지 자리**: Redis 생성 완료

**✅ 체크리스트**:
- [ ] Cache Subnet Group 생성 완료
- [ ] Redis Security Group 생성 완료
- [ ] Redis 클러스터 생성 완료
- [ ] 상태: Available

---

## 🛠️ Step 4: ALB + ASG Backend 배포 (15분)

### 📋 이 단계에서 할 일
- Backend Security Group 생성
- Launch Template 생성
- ALB 생성
- Auto Scaling Group 생성

### 🔗 참조 개념
- [Day 4 Session 1: ELB](../day4/session_1.md) - ALB 설정
- [Day 4 Session 2: Auto Scaling](../day4/session_2.md) - ASG 구성

### 📝 실습 절차

#### 4-1. Backend Security Group

**설정**:
```yaml
Name: cloudmart-backend-sg
Inbound Rules:
  - Type: HTTP (8080)
    Source: cloudmart-alb-sg
  - Type: SSH (22)
    Source: [Your IP]/32
Outbound Rules:
  - Type: All traffic
    Destination: 0.0.0.0/0
```

**이미지 자리**: Backend Security Group

#### 4-2. Launch Template 생성

**AWS Console 경로**:
- 🔗 [Launch Templates Console 바로가기](https://ap-northeast-2.console.aws.amazon.com/ec2/home?region=ap-northeast-2#LaunchTemplates:)
```
EC2 → Launch Templates → Create launch template
```

**설정**:
```yaml
Name: cloudmart-backend-template
AMI: Amazon Linux 2023
Instance type: t3.micro
Key pair: [Your key pair]
Network: cloudmart-vpc
Security group: cloudmart-backend-sg
IAM instance profile: [CloudMart-Backend-Role]

User data:
#!/bin/bash
yum update -y
yum install -y docker nodejs npm
systemctl start docker
systemctl enable docker

# CloudMart 샘플 앱 다운로드
cd /home/ec2-user
wget https://github.com/your-repo/releases/download/v1.0.0/cloudmart-sample-app.tar.gz
tar -xzf cloudmart-sample-app.tar.gz
cd cloudmart-sample-app/backend

# 환경 변수 설정
export DATABASE_URL="postgresql://cloudmart_admin:password@<RDS-ENDPOINT>:5432/cloudmart"
export REDIS_URL="redis://<REDIS-ENDPOINT>:6379"
export PORT=8080

# 의존성 설치 및 실행
npm install --omit=dev
nohup node server.js > /var/log/cloudmart-backend.log 2>&1 &
```

**이미지 자리**: Launch Template

#### 4-3. ALB 생성

**AWS Console 경로**:
- 🔗 [Load Balancers Console 바로가기](https://ap-northeast-2.console.aws.amazon.com/ec2/home?region=ap-northeast-2#LoadBalancers:)
```
EC2 → Load Balancers → Create load balancer → Application Load Balancer
```

**설정**:
```yaml
Name: cloudmart-alb
Scheme: Internet-facing
IP address type: IPv4
VPC: cloudmart-vpc
Subnets: cloudmart-public-a, cloudmart-public-b
Security group: cloudmart-alb-sg

Target group:
  Name: cloudmart-backend-tg
  Protocol: HTTP
  Port: 8080
  Health check path: /health
```

**이미지 자리**: ALB 생성

#### 4-4. Auto Scaling Group 생성

**AWS Console 경로**:
- 🔗 [Auto Scaling Groups Console 바로가기](https://ap-northeast-2.console.aws.amazon.com/ec2/home?region=ap-northeast-2#AutoScalingGroups:)
```
EC2 → Auto Scaling Groups → Create Auto Scaling group
```

**설정**:
```yaml
Name: cloudmart-backend-asg
Launch template: cloudmart-backend-template
VPC: cloudmart-vpc
Subnets: cloudmart-private-a, cloudmart-private-b
Load balancer: cloudmart-alb
Target group: cloudmart-backend-tg

Group size:
  Desired: 2
  Minimum: 2
  Maximum: 4

Scaling policy:
  Target tracking: Average CPU 70%
```

**이미지 자리**: ASG 생성

### ✅ Step 4 검증

**AWS Console에서 확인**:
```
EC2 → Load Balancers → cloudmart-alb 선택
→ State: Active
→ DNS name 복사
→ Listeners 탭: HTTP:80 확인

EC2 → Target Groups → cloudmart-backend-tg
→ Targets 탭: 2개 인스턴스 Healthy 확인

EC2 → Auto Scaling Groups → cloudmart-backend-asg
→ Desired: 2, Min: 2, Max: 4
→ Instances 탭: 2개 인스턴스 InService 확인
```

**브라우저에서 테스트**:
```
http://<ALB-DNS>/health
→ 예상 결과: {"status":"healthy"}
```

**이미지 자리**: Backend 배포 완료

**✅ 체크리스트**:
- [ ] Launch Template 생성 완료
- [ ] ALB 생성 완료
- [ ] ASG 생성 완료 (2개 인스턴스)
- [ ] Target Health: Healthy

---

## 🛠️ Step 5: S3 + CloudFront Frontend 배포 (5분)

### 📋 이 단계에서 할 일
- S3 버킷 생성 및 정적 웹 호스팅 설정
- Frontend 빌드 파일 업로드
- CloudFront 배포 생성

### 🔗 참조 개념
- [Day 2 Lab 2: S3 정적 웹 호스팅](../day2/lab_2.md)

### 📝 실습 절차

#### 5-1. S3 버킷 생성

**AWS Console 경로**:
- 🔗 [S3 Buckets Console 바로가기](https://s3.console.aws.amazon.com/s3/buckets?region=ap-northeast-2)
```
S3 → Buckets → Create bucket
```

**설정**:
```yaml
Bucket name: cloudmart-frontend-[unique-id]
Region: ap-northeast-2
Block all public access: Unchecked
Static website hosting: Enabled
Index document: index.html
```

**이미지 자리**: S3 버킷 생성

#### 5-2. Frontend 업로드

**AWS Console에서 업로드**:
```
S3 → Buckets → cloudmart-frontend-[unique-id] 선택
→ Upload 버튼 클릭
→ Add files 또는 Add folder
→ cloudmart-sample-app/frontend 폴더의 모든 파일 선택
→ Upload 버튼 클릭
```

**업로드 확인**:
- index.html
- styles.css
- app.js
- 기타 파일들이 모두 업로드되었는지 확인

**이미지 자리**: S3 파일 업로드

#### 5-3. CloudFront 배포

**AWS Console 경로**:
- 🔗 [CloudFront Distributions Console 바로가기](https://console.aws.amazon.com/cloudfront/v3/home#/distributions)
```
CloudFront → Distributions → Create distribution
```

**설정**:
```yaml
Origin domain: cloudmart-frontend-[unique-id].s3.ap-northeast-2.amazonaws.com
Origin path: /
Viewer protocol policy: Redirect HTTP to HTTPS
Default root object: index.html
```

**이미지 자리**: CloudFront 배포

### ✅ Step 5 검증

**AWS Console에서 확인**:
```
S3 → Buckets → cloudmart-frontend-[unique-id]
→ Objects 탭: 파일 업로드 확인

CloudFront → Distributions → 생성한 Distribution 선택
→ Status: Deployed
→ Distribution domain name 복사
```

**브라우저에서 테스트**:
```
https://<cloudfront-domain>/
→ CloudMart 웹사이트 로딩 확인
```

**이미지 자리**: Frontend 배포 완료

**✅ 체크리스트**:
- [ ] S3 버킷 생성 완료
- [ ] Frontend 파일 업로드 완료
- [ ] CloudFront 배포 완료
- [ ] 웹사이트 접속 가능

---

## ✅ 전체 시스템 검증

### 📋 통합 테스트

#### 테스트 1: Frontend → Backend 연결
```
브라우저에서 CloudFront URL 접속
→ 개발자 도구 (F12) → Network 탭
→ 페이지 새로고침
→ API 호출 확인 (ALB DNS로 요청)
```

**예상 결과**: Frontend가 ALB를 통해 Backend API 호출 성공

**이미지 자리**: 통합 테스트 결과

#### 테스트 2: Backend → RDS 연결
```
EC2 → Instances → Backend 인스턴스 선택
→ Connect → Session Manager
→ 로그 확인:
  sudo tail -f /var/log/cloudmart-backend.log
```

**예상 결과**: Backend가 RDS에 정상 연결

#### 테스트 3: Backend → Redis 연결
```
브라우저에서 테스트:
http://<ALB-DNS>/api/products
→ 첫 번째 호출: Database에서 조회
→ 두 번째 호출: Cache에서 조회 (빠른 응답)
```

**예상 결과**: Redis 캐싱 동작 확인

### ✅ 최종 체크리스트
- [ ] VPC 네트워크 구성 완료
- [ ] RDS PostgreSQL Multi-AZ 실행 중
- [ ] ElastiCache Redis 실행 중
- [ ] ALB + ASG Backend 배포 완료
- [ ] S3 + CloudFront Frontend 배포 완료
- [ ] 전체 시스템 통합 테스트 성공

---

## 🧹 리소스 정리 (5분)

### ⚠️ 중요: 반드시 순서대로 삭제

**삭제 순서**:
```
1. CloudFront Distribution 삭제
2. S3 버킷 비우기 및 삭제
3. Auto Scaling Group 삭제
4. ALB 삭제
5. Launch Template 삭제
6. ElastiCache 클러스터 삭제
7. RDS 인스턴스 삭제 (스냅샷 생략)
8. NAT Gateway 삭제
9. Elastic IP 해제
10. Internet Gateway 분리 및 삭제
11. Subnet 삭제
12. VPC 삭제
```

**이미지 자리**: 리소스 정리 완료

---

## 💰 비용 확인

### 예상 비용 계산
| 리소스 | 사용 시간 | 단가 | 예상 비용 |
|--------|----------|------|-----------|
| VPC, Subnet | 50분 | $0 | $0 |
| NAT Gateway | 50분 | $0.045/hour | $0.04 |
| RDS (db.t3.micro) | 50분 | $0.017/hour | $0.01 |
| ElastiCache | 50분 | $0.017/hour | $0.01 |
| ALB | 50분 | $0.025/hour | $0.02 |
| EC2 (t3.micro × 2) | 50분 | $0.010/hour | $0.02 |
| S3 + CloudFront | 50분 | $0.01 | $0.01 |
| **합계** | | | **$0.11** |

**이미지 자리**: Cost Explorer 확인

---

## 💡 Lab 회고

### 🤝 페어 회고 (5분)
1. **가장 어려웠던 부분**: 
2. **새로 배운 점**:
3. **실무 적용 아이디어**:

### 📊 학습 성과
- **기술적 성취**: CloudMart 전체 AWS 배포 완료
- **이해도 향상**: Multi-AZ 고가용성 아키텍처 구현
- **다음 Challenge 준비**: 프로덕션급 완성도 향상

---

## 🔗 관련 자료

### 📚 Session 복습
- [Session 1: 배포 전략](./session_1.md)
- [Session 2: 인프라 구성](./session_2.md)
- [Session 3: 모니터링](./session_3.md)
- [Session 4: 보안 & 백업](./session_4.md)

### 🎯 다음 Challenge
- [Challenge: 프로덕션급 배포](./challenge_1.md) - 완전한 운영 환경 구축

---

<div align="center">

**✅ CloudMart 배포 완료** • **🏗️ Multi-AZ 구성** • **📊 모니터링 준비**

*Challenge에서 프로덕션급 완성도로 마무리하겠습니다!*

</div>
