# Week 5 AWS 집중 과정 규칙

## 🎯 Week 5 핵심 목표
**"CloudMart 프로젝트를 AWS에 배포하기 위한 단계적 인프라 구축"**

## 🌏 기본 설정 표준

### 리전 설정
- **기본 리전**: **ap-northeast-2 (서울)** ⭐
- **모든 실습**: 서울 리전 사용
- **이유**: 
  - 한국 사용자 기준 최저 지연시간
  - 한국어 지원 및 기술 지원 용이
  - 데이터 주권 법규 준수

### 📋 전체 학습 목표
- AWS 핵심 서비스 실무 활용
- Docker Compose → AWS 마이그레이션
- 고가용성 아키텍처 구축
- 비용 효율적 운영 전략
- CloudMart 프로젝트 완전 배포

### 🖥️ 실습 방식
- **Web Console 중심**: 모든 실습은 AWS Web Console에서 진행
- **아키텍처 우선**: 먼저 아키텍처 다이어그램 제시 → 학생들이 구현
- **사고 중심 학습**: 왜 이렇게 구성하는지 생각하며 직접 클릭
- **강사 모니터링**: ReadOnly Role로 학생 리소스 실시간 확인

## 📚 Session 구조 표준

### 필수 포함 요소
모든 Session은 다음 구조를 **반드시** 따라야 합니다:

```markdown
## Session N: [서비스명] (HH:MM-HH:MM)

### 🎯 학습 목표
- [구체적인 학습 목표 3-5개]

### 📖 서비스 개요

#### 1. 생성 배경 (Why?)
- 어떤 문제를 해결하기 위해 만들어졌는가?
- 기존 방식의 한계점
- AWS가 제시하는 솔루션

#### 2. 핵심 원리 (How?)
- 서비스의 작동 원리
- 주요 아키텍처 구성 요소
- 다른 서비스와의 차이점

#### 3. 주요 사용 사례 (When?)
- 실제 업계 활용 사례
- 적합한 워크로드 유형
- 권장 사용 시나리오

#### 4. 비슷한 서비스 비교 (Which?)
**AWS 내 대안 서비스**:
- [대안 서비스 1] vs [현재 서비스]
  - 언제 [대안 서비스 1]을 사용: [구체적 상황]
  - 언제 [현재 서비스]를 사용: [구체적 상황]
  
- [대안 서비스 2] vs [현재 서비스]
  - 언제 [대안 서비스 2]를 사용: [구체적 상황]
  - 언제 [현재 서비스]를 사용: [구체적 상황]

**선택 기준**:
| 기준 | [현재 서비스] | [대안 서비스 1] | [대안 서비스 2] |
|------|---------------|-----------------|-----------------|
| 비용 | [비교] | [비교] | [비교] |
| 성능 | [비교] | [비교] | [비교] |
| 관리 복잡도 | [비교] | [비교] | [비교] |
| 적합한 규모 | [비교] | [비교] | [비교] |

#### 5. 장단점 분석
**장점**:
- [장점 1]
- [장점 2]
- [장점 3]

**단점/제약사항**:
- [제약사항 1]
- [제약사항 2]
- [대안 방법]

#### 6. 비용 구조 💰
- 과금 방식 (시간당, GB당 등)
- 프리티어 혜택
- 비용 최적화 팁
- 예상 비용 계산 예시

#### 7. 최신 업데이트 🆕
- [최근 변경사항 - AWS 문서 참조]
- [새로운 기능]
- [Deprecated 기능]

### 📊 실습 연계
- 이번 Lab에서 어떻게 활용되는지
- 실제 구성 시 주의사항

### 🔗 공식 문서 (필수)
**⚠️ 학생들이 직접 확인해야 할 공식 문서**:
- 📘 [서비스 개요](AWS 공식 문서 URL)
- 📗 [사용자 가이드](AWS 공식 문서 URL)
- 📙 [API 레퍼런스](AWS 공식 문서 URL)
- 📕 [요금 정보](AWS 요금 페이지 URL)
- 🆕 [최신 업데이트](AWS What's New URL)
```

### AWS 문서 참조 규칙 (필수)
1. **aws___search_documentation** 로 서비스 검색
2. **aws___read_documentation** 로 문서 내용 확인
3. **공식 문서 URL 5개 필수 포함**:
   - 서비스 개요 (What is...)
   - 사용자 가이드 (User Guide)
   - API 레퍼런스 (API Reference)
   - 요금 정보 (Pricing)
   - 최신 업데이트 (What's New)
4. 최신 업데이트 날짜 명시

### 🛠️ MCP 도구 활용 (강의 제작 시 필수)

#### AWS 문서 관련 MCP
- **aws___search_documentation**: AWS 서비스 검색
  ```
  사용 예: "VPC networking" 검색
  → 관련 문서 목록 반환
  ```

- **aws___read_documentation**: 문서 내용 읽기
  ```
  사용 예: VPC 사용자 가이드 URL 입력
  → 최신 문서 내용 확인
  ```

- **aws___recommend**: 관련 문서 추천
  ```
  사용 예: VPC 문서 URL 입력
  → 관련 문서 추천 (Highly Rated, New, Similar)
  ```

- **aws___list_regions**: AWS 리전 목록
  ```
  사용 예: 리전 정보 필요 시
  → 모든 리전 ID와 이름 반환
  ```

- **aws___get_regional_availability**: 리전별 서비스 가용성
  ```
  사용 예: 특정 리전에서 서비스 사용 가능 여부 확인
  → API/CloudFormation 리소스 가용성 확인
  ```

#### AWS 비용 관련 MCP
- **get_pricing**: 서비스 가격 정보
  ```
  사용 예: EC2 t3.micro 가격 조회
  → 시간당 비용, 프리티어 정보
  ```

- **get_pricing_service_codes**: 서비스 코드 목록
  ```
  사용 예: "EC2" 검색
  → AmazonEC2 서비스 코드 반환
  ```

- **get_pricing_service_attributes**: 가격 필터 속성
  ```
  사용 예: EC2 가격 필터 가능한 속성 확인
  → instanceType, region, operatingSystem 등
  ```

- **get_pricing_attribute_values**: 속성 값 목록
  ```
  사용 예: EC2 instanceType 값 조회
  → t3.micro, t3.small, m5.large 등
  ```

- **generate_cost_report**: 비용 분석 보고서
  ```
  사용 예: Lab 예상 비용 계산
  → 상세 비용 분석 리포트 생성
  ```

#### 강의 제작 워크플로우
```
1. 서비스 검색
   aws___search_documentation("VPC")
   ↓
2. 문서 읽기
   aws___read_documentation(VPC 가이드 URL)
   ↓
3. 최신 정보 확인
   aws___recommend(VPC 문서 URL) → "New" 섹션 확인
   ↓
4. 비용 정보 수집
   get_pricing("AmazonVPC", "ap-northeast-2")
   ↓
5. Session 작성
   - 생성 배경, 원리, 사용 사례
   - 비용 구조 (MCP 데이터 활용)
   - 최신 업데이트 (MCP 문서 기반)
   - 공식 문서 링크 5개
```

#### Lab 제작 시 MCP 활용
```
1. 리전 가용성 확인
   aws___get_regional_availability("ap-northeast-2", "api", ["EC2"])
   ↓
2. 비용 계산
   get_pricing("AmazonEC2", "ap-northeast-2", filters)
   generate_cost_report(pricing_data)
   ↓
3. Lab 문서 작성
   - 예상 비용 표 (MCP 데이터)
   - 리전별 주의사항
```

### Session 작성 예시 (VPC)

```markdown
## Session 2: VPC 아키텍처 (10:00-10:50)

### 🎯 학습 목표
- VPC의 생성 배경과 필요성 이해
- VPC 네트워크 구조 및 CIDR 블록 설계
- Subnet, IGW, NAT Gateway 역할 파악
- 실제 VPC 구성 시 고려사항 습득

### 📖 서비스 개요

#### 1. 생성 배경 (Why?)
**문제 상황**:
- 온프레미스: 물리적 네트워크 구성의 복잡성과 비용
- 초기 클라우드: 공유 네트워크 환경의 보안 우려
- 멀티 테넌시: 고객 간 네트워크 격리 필요

**AWS VPC 솔루션**:
- 논리적으로 격리된 가상 네트워크
- 완전한 네트워크 제어권
- 온프레미스와 동일한 네트워크 개념 적용

#### 2. 핵심 원리 (How?)
**VPC 아키텍처**:
```
VPC (10.0.0.0/16)
├── Subnet (10.0.1.0/24) - Public
│   └── Internet Gateway 연결
├── Subnet (10.0.2.0/24) - Private
│   └── NAT Gateway 통한 외부 접근
└── Route Tables
    ├── Public RT: 0.0.0.0/0 → IGW
    └── Private RT: 0.0.0.0/0 → NAT GW
```

**작동 원리**:
- CIDR 블록으로 IP 주소 범위 정의
- Subnet으로 AZ별 네트워크 분할
- Route Table로 트래픽 경로 제어
- Security Group/NACL로 방화벽 구성

#### 3. 주요 사용 사례 (When?)
**적합한 경우**:
- 웹 애플리케이션 호스팅 (Public + Private Subnet)
- 데이터베이스 격리 (Private Subnet only)
- 하이브리드 클라우드 (VPN/Direct Connect)
- 멀티 티어 아키텍처 (Web/App/DB 분리)

**실제 사례**:
- Netflix: 수천 개의 VPC로 서비스 격리
- Airbnb: 리전별 VPC로 글로벌 서비스
- Slack: Private Subnet에 민감 데이터 격리

#### 4. 비슷한 서비스 비교 (Which?)
**AWS 내 대안 서비스**:
- **Default VPC** vs **Custom VPC**
  - 언제 Default VPC 사용: 간단한 테스트, 프로토타입, 학습 목적
  - 언제 Custom VPC 사용: 프로덕션 환경, 보안 요구사항, 복잡한 네트워크

- **VPC Peering** vs **Transit Gateway**
  - 언제 VPC Peering 사용: 소수의 VPC 연결 (2-5개), 간단한 구조
  - 언제 Transit Gateway 사용: 다수의 VPC 연결 (10개+), 중앙 집중식 관리

- **NAT Gateway** vs **NAT Instance**
  - 언제 NAT Gateway 사용: 관리형 서비스 선호, 고가용성 필요, 운영 부담 최소화
  - 언제 NAT Instance 사용: 비용 절감 우선, 커스터마이징 필요, 작은 규모

**선택 기준**:
| 기준 | Custom VPC | Default VPC | Transit Gateway |
|------|------------|-------------|-----------------|
| 비용 | 무료 (NAT GW 제외) | 무료 | $0.05/hour + 데이터 |
| 설정 복잡도 | 높음 | 낮음 (자동) | 중간 |
| 보안 제어 | 완전한 제어 | 제한적 | 완전한 제어 |
| 적합한 규모 | 모든 규모 | 소규모/테스트 | 대규모 (10+ VPC) |
| 유연성 | 매우 높음 | 낮음 | 높음 |

#### 5. 장단점 분석
**장점**:
- ✅ 완전한 네트워크 제어 (IP 범위, 라우팅)
- ✅ 보안 강화 (격리된 환경)
- ✅ 온프레미스 연결 가능 (VPN, Direct Connect)
- ✅ 무료 (VPC 자체는 비용 없음)

**단점/제약사항**:
- ⚠️ CIDR 블록 변경 불가 (신중한 설계 필요)
- ⚠️ NAT Gateway 비용 발생 ($0.045/hour)
- ⚠️ VPC Peering 제한 (최대 125개)
- ⚠️ 학습 곡선 (네트워킹 지식 필요)

**대안**:
- 간단한 앱: Default VPC 사용
- 서버리스: Lambda (VPC 불필요)

#### 6. 비용 구조 💰
**무료 항목**:
- VPC 생성 및 사용: $0
- Subnet, Route Table: $0
- Internet Gateway: $0
- Security Groups, NACL: $0

**유료 항목**:
- NAT Gateway: $0.045/hour + 데이터 처리 $0.045/GB
- VPN Connection: $0.05/hour
- VPC Peering 데이터 전송: $0.01/GB (동일 AZ)

**비용 최적화**:
- NAT Gateway 대신 NAT Instance (저비용)
- VPC Endpoint로 S3/DynamoDB 무료 접근
- 불필요한 데이터 전송 최소화

**예상 비용 (Day 1 Lab)**:
- VPC: $0
- NAT Gateway (1시간): $0.045
- 데이터 전송 (1GB): $0.045
- 합계: ~$0.10

#### 7. 최신 업데이트 🆕
**2024년 주요 변경사항**:
- IPv6 지원 강화 (Dual-stack VPC)
- VPC Flow Logs 개선 (Parquet 형식 지원)
- Network Access Analyzer (보안 분석 도구)

**2025년 예정**:
- VPC Lattice 통합 (서비스 메시)
- 더 큰 CIDR 블록 지원 검토

**참조**: AWS VPC 문서 (2024.10 업데이트)

### 📊 실습 연계
**Lab 1에서 구현**:
- 기본 VPC 생성 (10.0.0.0/16)
- Public Subnet 구성
- Internet Gateway 연결
- WordPress 배포 환경 구축

**주의사항**:
- CIDR 블록 중복 방지
- Subnet 크기 적절히 설계 (/24 권장)
- Route Table 연결 확인 필수

### 🔗 공식 문서 (필수)
**⚠️ 학생들이 직접 확인해야 할 공식 문서**:
- 📘 [VPC란 무엇인가?](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)
- 📗 [VPC 사용자 가이드](https://docs.aws.amazon.com/vpc/latest/userguide/)
- 📙 [VPC API 레퍼런스](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/OperationList-query-vpc.html)
- 📕 [VPC 요금](https://aws.amazon.com/vpc/pricing/)
- 🆕 [VPC 최신 업데이트](https://aws.amazon.com/about-aws/whats-new/networking/)

### 🔗 참고 자료
- [AWS VPC 공식 문서](https://docs.aws.amazon.com/vpc/)
- [VPC 설계 베스트 프랙티스](https://aws.amazon.com/vpc/best-practices/)
- [VPC 비용 계산기](https://calculator.aws/#/addService/VPC)
```

## ⏰ 일일 스케줄 표준
```
09:00-09:50  Session 1 (50분) + 10분 휴식
10:00-10:50  Session 2 (50분) + 10분 휴식
11:00-11:50  Session 3 (50분) + 10분 휴식
12:00-12:50  Session 4 (50분) + 10분 휴식
13:00-14:00  점심시간 (60분) ⭐ 고정
14:00-14:50  Lab 1 (50분) + 10분 휴식
15:00-15:50  Lab 2 또는 Challenge (50분) + 10분 휴식
16:00-18:00  멘토링 시간 (120분)
```

### 📊 시간 배분
- **이론 세션**: 4시간 (Session 1-4, 각 50분)
- **실습**: 2시간 (Lab 1-2 또는 Challenge, 각 50분)
- **점심**: 1시간 (13:00-14:00 고정)
- **멘토링**: 2시간 (16:00-18:00)
- **휴식**: 총 60분 (10분씩 6회)

## 💰 비용 관리 원칙 (Week 5 전체)

### 주간 비용 제한
- **최대 예산**: 주당 $50 이하
- **일일 목표**: $10 이하
- **학생당**: 약 $0.80/day (12명 기준)

### 비용 절감 전략
```yaml
프리티어 최대 활용:
  EC2: t3.micro (750시간/월 무료)
  RDS: db.t3.micro (750시간/월 무료)
  S3: 5GB 무료
  데이터 전송: 100GB/월 무료

실습 시간 제한:
  Lab 1: 50분
  Lab 2/Challenge: 50분
  즉시 정리: 실습 완료 후 30분 이내

리소스 태깅:
  Week: "Week5"
  Day: "Day1-5"
  Student: "student-name"
  Lab: "Lab1-2"
```

## 📅 5일 커리큘럼 구조

### Day 1: AWS 기초 & 네트워킹
**목표**: VPC 네트워크 구성 및 EC2 Docker 환경 구축

#### Session 1: AWS 기초 개념 (09:00-09:50)
- AWS 글로벌 인프라 (Region, AZ, Edge Location)
- 클라우드 컴퓨팅 모델 (IaaS, PaaS, SaaS)
- AWS 계정 구조 (Root, IAM User, Role)
- 프리티어 활용 전략 및 비용 관리

#### Session 2: VPC 아키텍처 (10:00-10:50)
- VPC 개념 및 CIDR 블록
- Subnet (Public/Private) 설계
- Internet Gateway & NAT Gateway
- Route Table 설정

#### Session 3: 보안 그룹 & EC2 기초 (11:00-11:50)
- Security Groups vs Network ACL
- EC2 인스턴스 타입 및 선택
- AMI & Key Pair
- User Data 초기화

#### Session 4: 고객 사례 - 블로그 플랫폼 아키텍처 (12:00-12:50)
**사례**: Medium 스타일 블로그 플랫폼 (WordPress)

**아키텍처 구성**:
```
사용자 → Internet Gateway → Public Subnet (EC2 + Docker)
                                    ↓
                            Private Subnet (RDS MySQL)
```

**Docker Compose 구성**:
```yaml
# WordPress + MySQL
services:
  wordpress:
    image: wordpress:latest
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: mysql
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: password
  
  mysql:
    image: mysql:5.7
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: password
      MYSQL_ROOT_PASSWORD: rootpassword
```

**AWS 서비스 매핑**:
- VPC: 격리된 네트워크 환경
- Public Subnet: WordPress 컨테이너 (EC2)
- Private Subnet: MySQL (RDS 대신 컨테이너로 시작)
- Security Groups: 웹(80), SSH(22), MySQL(3306)

**학습 포인트**:
- 간단한 2-tier 아키텍처
- Docker Compose → AWS 마이그레이션 기초
- 네트워크 격리 개념

#### Lab 1: VPC & EC2 기본 구성 (14:00-14:50)
```markdown
목표: Docker 실행 가능한 EC2 환경 구축

📐 아키텍처 다이어그램 (먼저 제시):
┌─────────────────────────────────────────┐
│           AWS Cloud (Region)            │
│  ┌───────────────────────────────────┐  │
│  │  VPC (10.0.0.0/16)                │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │ Public Subnet (10.0.1.0/24) │  │  │
│  │  │  ┌──────────────────────┐   │  │  │
│  │  │  │ EC2 (t3.micro)       │   │  │  │
│  │  │  │ - Docker installed   │   │  │  │
│  │  │  │ - WordPress running  │   │  │  │
│  │  │  └──────────────────────┘   │  │  │
│  │  └─────────────────────────────┘  │  │
│  │  Internet Gateway                  │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘

🎯 Web Console 실습 단계:

Step 1: VPC 생성 (15분)
[AWS Console → VPC Dashboard]
1. "Create VPC" 클릭
2. VPC 설정:
   - Name: week5-day1-vpc
   - IPv4 CIDR: 10.0.0.0/16
3. Subnet 생성:
   - Name: week5-day1-public-subnet
   - CIDR: 10.0.1.0/24
   - AZ: ap-northeast-2a
4. Internet Gateway 생성 및 연결
5. Route Table 설정:
   - 0.0.0.0/0 → Internet Gateway

Step 2: Security Group 생성 (10분)
[AWS Console → EC2 → Security Groups]
1. "Create security group" 클릭
2. 규칙 설정:
   - Inbound: HTTP (80), SSH (22)
   - Outbound: All traffic

Step 3: EC2 인스턴스 생성 (20분)
[AWS Console → EC2 → Launch Instance]
1. AMI 선택: Amazon Linux 2023
2. Instance type: t3.micro
3. Network: week5-day1-vpc
4. Subnet: week5-day1-public-subnet
5. Auto-assign Public IP: Enable
6. Security Group: 위에서 생성한 SG
7. User Data 입력:
   #!/bin/bash
   yum update -y
   yum install -y docker
   systemctl start docker
   systemctl enable docker
   usermod -aG docker ec2-user
8. Launch!

Step 4: 접속 및 확인 (5분)
1. EC2 Public IP 확인
2. SSH 접속: ssh -i key.pem ec2-user@<public-ip>
3. Docker 확인: docker --version

💡 학습 포인트:
- VPC 네트워크 구조 이해
- Public Subnet과 Internet Gateway 역할
- Security Group 설정의 중요성
- User Data를 통한 자동화

🧹 리소스 정리:
[AWS Console에서 순서대로]
1. EC2 인스턴스 종료
2. Security Group 삭제
3. Subnet 삭제
4. Internet Gateway 분리 및 삭제
5. VPC 삭제

비용: $0.10 (1시간 기준)
```

#### Lab 2: 멀티 AZ 네트워크 (15:00-15:50)
```markdown
목표: 고가용성을 위한 Multi-AZ 네트워크

📐 아키텍처 다이어그램:
┌──────────────────────────────────────────────┐
│              AWS Cloud (Region)              │
│  ┌────────────────────────────────────────┐  │
│  │  VPC (10.0.0.0/16)                     │  │
│  │  ┌──────────────┐  ┌──────────────┐   │  │
│  │  │ AZ-A         │  │ AZ-B         │   │  │
│  │  │ Public       │  │ Public       │   │  │
│  │  │ 10.0.1.0/24  │  │ 10.0.2.0/24  │   │  │
│  │  │  [EC2-Web1]  │  │  [EC2-Web2]  │   │  │
│  │  └──────────────┘  └──────────────┘   │  │
│  │  ┌──────────────┐  ┌──────────────┐   │  │
│  │  │ Private      │  │ Private      │   │  │
│  │  │ 10.0.11.0/24 │  │ 10.0.12.0/24 │   │  │
│  │  │  [NAT GW]    │  │              │   │  │
│  │  └──────────────┘  └──────────────┘   │  │
│  │  Internet Gateway                      │  │
│  └────────────────────────────────────────┘  │
└──────────────────────────────────────────────┘

🎯 Web Console 실습 단계:

Step 1: Multi-AZ VPC (20분)
[AWS Console → VPC Dashboard]
1. VPC 생성: 10.0.0.0/16
2. Subnet 4개 생성:
   - Public-A: 10.0.1.0/24 (ap-northeast-2a)
   - Public-B: 10.0.2.0/24 (ap-northeast-2b)
   - Private-A: 10.0.11.0/24 (ap-northeast-2a)
   - Private-B: 10.0.12.0/24 (ap-northeast-2b)
3. Internet Gateway 생성 및 연결
4. NAT Gateway 생성 (Public-A에 배치)
5. Route Tables 설정:
   - Public RT: 0.0.0.0/0 → IGW
   - Private RT: 0.0.0.0/0 → NAT GW

Step 2: Bastion Host (15분)
[AWS Console → EC2]
1. Bastion 인스턴스 생성 (Public-A)
2. Security Group: SSH (22) only
3. Private 인스턴스 생성 (Private-A)
4. Bastion 통해 Private 접근 테스트

Step 3: 웹 서버 배포 (10분)
1. 각 AZ Public Subnet에 웹 서버 배포
2. 연결 테스트

Step 4: 리소스 정리 (5분)

비용: $0.15 (NAT Gateway 포함)
```

---

### Day 2: 컴퓨팅 & 스토리지
**목표**: EC2 심화 및 스토리지 서비스 활용

#### Session 1: EC2 심화 (09:00-09:50)
- EC2 인스턴스 생명주기
- Elastic IP & ENI
- EC2 Instance Connect
- Systems Manager Session Manager

#### Session 2: EBS 스토리지 (10:00-10:50)
- EBS (Elastic Block Store) 타입 및 성능
- EBS 스냅샷 & 백업 전략
- EBS 암호화
- Instance Store vs EBS

#### Session 3: EFS & 공유 스토리지 (11:00-11:50)
- EFS (Elastic File System) 아키텍처
- EFS 마운트 및 성능 모드
- EFS vs EBS 비교
- 공유 스토리지 활용 사례

#### Session 4: 고객 사례 - E-Commerce 플랫폼 (12:00-12:50)
**사례**: 쇼핑몰 플랫폼 (Magento/PrestaShop)

**아키텍처 구성**:
```
사용자 → CloudFront (CDN) → S3 (정적 파일)
                          ↓
                    ALB → EC2 (웹/앱)
                          ↓
                    RDS (상품/주문 DB)
                          ↓
                    ElastiCache (세션/캐시)
```

**Docker Compose 구성**:
```yaml
# PrestaShop E-Commerce
services:
  prestashop:
    image: prestashop/prestashop:latest
    ports:
      - "80:80"
    environment:
      DB_SERVER: mysql
      DB_NAME: prestashop
      DB_USER: prestashop
      DB_PASSWD: password
    volumes:
      - prestashop_data:/var/www/html
  
  mysql:
    image: mysql:5.7
    environment:
      MYSQL_DATABASE: prestashop
      MYSQL_USER: prestashop
      MYSQL_PASSWORD: password
      MYSQL_ROOT_PASSWORD: rootpassword
    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  prestashop_data:
  mysql_data:
```

**AWS 서비스 매핑**:
- CloudFront: 정적 파일 CDN (이미지, CSS, JS)
- S3: 상품 이미지 스토리지
- ALB: 로드 밸런싱
- EC2: PrestaShop 컨테이너
- RDS: MySQL 데이터베이스
- ElastiCache: 세션 스토어 & 상품 캐시

**학습 포인트**:
- 정적/동적 콘텐츠 분리
- CDN을 통한 성능 최적화
- 데이터 영속성 (EBS, S3)

#### Lab 1: EBS & 데이터 영속성 (14:00-14:50)
```markdown
목표: EBS 볼륨 관리 및 스냅샷 활용

Step 1: EBS 볼륨 생성 (15분)
- gp3 볼륨 생성 및 연결
- 파일시스템 생성 및 마운트

Step 2: 스냅샷 & 복구 (20분)
- EBS 스냅샷 생성
- 새 볼륨으로 복원
- 데이터 무결성 확인

Step 3: EFS 공유 스토리지 (10분)
- EFS 파일시스템 생성
- 여러 EC2에서 마운트

Step 4: 리소스 정리 (5분)

비용: $0.15
```

#### Lab 2: S3 정적 웹 호스팅 (15:00-15:50)
```markdown
목표: S3로 정적 사이트 배포

Step 1: S3 버킷 생성 (15분)
- 정적 웹 호스팅 설정
- 버킷 정책 구성
- HTML/CSS/JS 업로드

Step 2: CloudFront 배포 (25분)
- CloudFront Distribution 생성
- 캐싱 동작 확인

Step 3: 성능 테스트 (5분)
- 글로벌 접근 테스트

Step 4: 리소스 정리 (5분)

비용: $0.10
```

---

### Day 3: 데이터베이스 & 캐싱
**목표**: RDS 및 ElastiCache 구성 및 연동

#### Session 1: RDS 기초 (09:00-09:50)
- RDS 아키텍처 및 엔진 선택
- Multi-AZ vs Read Replica
- 자동 백업 & 스냅샷
- RDS 보안 (암호화, IAM 인증)

#### Session 2: RDS 운영 (10:00-10:50)
- RDS 모니터링 (CloudWatch)
- 성능 인사이트 (Performance Insights)
- 스케일링 전략
- 장애 복구 (Failover)

#### Session 3: ElastiCache Redis (11:00-11:50)
- Redis vs Memcached
- 캐싱 전략 (Cache-Aside, Write-Through)
- 클러스터 모드
- 데이터 영속성

#### Session 4: 고객 사례 - FinTech 플랫폼 (12:00-12:50)
**사례**: 간편 송금 서비스 (Stripe/PayPal 스타일)

**아키텍처 구성**:
```
사용자 → WAF → ALB → API Gateway
                        ↓
                  Lambda/ECS (트랜잭션 처리)
                        ↓
              RDS (트랜잭션 DB - Multi-AZ)
                        ↓
              ElastiCache (세션 & 실시간 잔액)
                        ↓
              S3 (거래 내역 아카이브)
```

**Docker Compose 구성**:
```yaml
# FinTech API Backend
services:
  api:
    image: node:18-alpine
    command: sh -c "npm install && npm start"
    ports:
      - "3000:3000"
    environment:
      DB_HOST: postgres
      REDIS_HOST: redis
      NODE_ENV: production
    volumes:
      - ./app:/app
    working_dir: /app
  
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: fintech
      POSTGRES_USER: fintech
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
  
  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

**AWS 서비스 매핑**:
- WAF: DDoS 방어 및 SQL Injection 차단
- ALB: HTTPS 종료 및 로드 밸런싱
- EC2/ECS: Node.js API 서버
- RDS PostgreSQL: 트랜잭션 데이터 (ACID 보장)
- ElastiCache Redis: 세션 & 실시간 잔액 캐시
- S3: 거래 내역 장기 보관 (Glacier)

**학습 포인트**:
- 금융 데이터 보안 (암호화, 감사)
- 트랜잭션 무결성 (ACID)
- 고가용성 & 장애 복구
- 규정 준수 (PCI-DSS)

#### Lab 1: RDS PostgreSQL 구성 (14:00-14:50)
```markdown
목표: Multi-AZ RDS 구성 및 애플리케이션 연동

Step 1: RDS 인스턴스 생성 (20분)
- db.t3.micro PostgreSQL
- Multi-AZ 배포
- Security Group 구성

Step 2: 데이터베이스 연결 (20분)
- EC2에서 psql 연결
- 테이블 생성 및 데이터 삽입
- 애플리케이션 연동 테스트

Step 3: 백업 & 복원 (5분)
- 수동 스냅샷 생성

Step 4: 리소스 정리 (5분)

비용: $0.20
```

#### Lab 2: Redis 캐싱 구현 (15:00-15:50)
```markdown
목표: ElastiCache Redis로 성능 최적화

Step 1: ElastiCache 클러스터 (15분)
- Redis 클러스터 생성
- Security Group 설정

Step 2: 캐싱 로직 구현 (25분)
- 애플리케이션에 Redis 연동
- Cache-Aside 패턴 구현
- 성능 비교

Step 3: 세션 스토어 (5분)
- 세션 데이터 Redis 저장

Step 4: 리소스 정리 (5분)

비용: $0.20
```

---

### Day 4: 로드밸런싱 & 고가용성
**목표**: ALB 및 Auto Scaling으로 고가용성 구현

#### Session 1: Elastic Load Balancing (09:00-09:50)
- ALB vs NLB vs CLB 비교
- Target Groups & Health Checks
- 리스너 규칙 & 라우팅
- Sticky Sessions

#### Session 2: Auto Scaling (10:00-10:50)
- Auto Scaling Groups (ASG)
- Launch Templates
- 스케일링 정책 (Target Tracking, Step)
- ASG + ALB 통합

#### Session 3: 고가용성 아키텍처 (11:00-11:50)
- Multi-AZ 배포 전략
- 장애 복구 시나리오
- Blue-Green 배포
- Canary 배포

#### Session 4: 고객 사례 - News & Media 플랫폼 (12:00-12:50)
**사례**: 뉴스 포털 (CNN/BBC 스타일)

**아키텍처 구성**:
```
사용자 → CloudFront (글로벌 CDN)
            ↓
       S3 (정적 콘텐츠) + ALB (동적 API)
            ↓
       ASG (뉴스 서버 - 트래픽 급증 대응)
            ↓
       ElastiCache (인기 기사 캐싱)
            ↓
       RDS Read Replica (읽기 부하 분산)
            ↓
       S3 (미디어 파일 - 이미지/비디오)
```

**Docker Compose 구성**:
```yaml
# Ghost CMS (뉴스 플랫폼)
services:
  ghost:
    image: ghost:5-alpine
    ports:
      - "2368:2368"
    environment:
      database__client: mysql
      database__connection__host: mysql
      database__connection__user: ghost
      database__connection__password: password
      database__connection__database: ghost
      url: http://localhost:2368
    volumes:
      - ghost_content:/var/lib/ghost/content
  
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: ghost
      MYSQL_USER: ghost
      MYSQL_PASSWORD: password
    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  ghost_content:
  mysql_data:
```

**AWS 서비스 매핑**:
- CloudFront: 글로벌 콘텐츠 배포 (엣지 캐싱)
- S3: 정적 파일 & 미디어 스토리지
- ALB: 동적 콘텐츠 로드 밸런싱
- ASG: 트래픽 급증 시 자동 확장 (속보 발생 시)
- ElastiCache: 인기 기사 캐싱 (읽기 성능 향상)
- RDS Read Replica: 읽기 부하 분산 (쓰기 1대, 읽기 N대)

**학습 포인트**:
- 읽기 중심 워크로드 최적화
- 트래픽 급증 대응 (Auto Scaling)
- 글로벌 콘텐츠 배포 (CDN)
- 비용 효율적 미디어 스토리지

#### Lab 1: ALB + ASG 구성 (14:00-14:50)
```markdown
목표: 자동 확장 가능한 웹 서비스 구축

Step 1: Launch Template (10분)
- User Data로 웹 서버 설치
- 보안 설정

Step 2: ALB 생성 (15분)
- Application Load Balancer
- Target Group 설정
- Health Check 구성

Step 3: Auto Scaling Group (20분)
- ASG 생성 (Min: 2, Max: 4)
- Target Tracking 정책
- 부하 테스트

Step 4: 리소스 정리 (5분)

비용: $0.30
```

#### Challenge: 고가용성 아키텍처 (15:00-15:50)
```markdown
목표: 완전한 HA 아키텍처 구현

요구사항:
- Multi-AZ 인프라
- Web Tier: ALB + ASG
- App Tier: Internal ALB + ASG
- DB Tier: Multi-AZ RDS

Step 1: 아키텍처 설계 (10분)
Step 2: 인프라 구축 (30분)
Step 3: 장애 테스트 (5분)
Step 4: 리소스 정리 (5분)

비용: $0.40
```

---

### Day 5: CloudMart 프로젝트 AWS 배포
**목표**: Week 3-4 CloudMart를 AWS에 완전 배포

#### Session 1: 배포 전략 수립 (09:00-09:50)
- CloudMart 아키텍처 분석
- AWS 서비스 매핑
- 마이그레이션 계획
- 비용 추정

#### Session 2: 인프라 구성 (10:00-10:50)
- VPC & 네트워크 설계
- 컴퓨팅 리소스 계획
- 데이터베이스 전략
- 스토리지 구성

#### Session 3: 모니터링 & 로깅 (11:00-11:50)
- CloudWatch 메트릭 & 알람
- CloudWatch Logs
- AWS X-Ray (분산 추적)
- 로그 중앙화

#### Session 4: 보안 & 백업 (12:00-12:50)
- IAM 정책 & 역할
- 보안 그룹 최적화
- 백업 전략
- 재해 복구 계획

#### Lab 1: CloudMart 인프라 구축 (14:00-14:50)
```markdown
목표: CloudMart 전체 인프라 AWS 배포

Step 1: 네트워크 구성 (10분)
- Multi-AZ VPC
- Public/Private Subnets

Step 2: 데이터베이스 배포 (15분)
- RDS PostgreSQL (Multi-AZ)
- ElastiCache Redis

Step 3: 애플리케이션 배포 (20분)
- Frontend: S3 + CloudFront
- Backend: EC2 + ALB + ASG

Step 4: 검증 (5분)

비용: $0.50
```

#### Challenge: 프로덕션급 배포 (15:00-15:50)
```markdown
목표: 완전한 프로덕션 환경 구축

요구사항:
1. 고가용성 (Multi-AZ)
2. 자동 확장 (ASG)
3. 모니터링 (CloudWatch)
4. 백업 & 복구 전략
5. 비용 최적화

제약사항:
- 비용: $0.80 이하
- 시간: 50분

평가 기준:
- 아키텍처 설계 (30%)
- 고가용성 구현 (30%)
- 보안 설정 (20%)
- 모니터링 (20%)

Step 1: 아키텍처 설계 (10분)
Step 2: 인프라 구축 (30분)
Step 3: 검증 & 최적화 (5분)
Step 4: 리소스 정리 (5분)

비용: $0.80
```

## 🧹 리소스 정리 자동화

### 일일 정리 스크립트
```bash
#!/bin/bash
# cleanup-day.sh

DAY=$1  # Day1, Day2, Day3, Day4, Day5

echo "=== Week 5 $DAY 리소스 정리 시작 ==="

# 태그 기반 리소스 검색
TAG_WEEK="Week5"
TAG_DAY="$DAY"

# 1. EC2 인스턴스 종료
echo "1/8 EC2 인스턴스 종료 중..."
INSTANCES=$(aws ec2 describe-instances \
  --filters "Name=tag:Week,Values=$TAG_WEEK" "Name=tag:Day,Values=$TAG_DAY" \
  --query 'Reservations[].Instances[].InstanceId' \
  --output text)

if [ -n "$INSTANCES" ]; then
  aws ec2 terminate-instances --instance-ids $INSTANCES
  echo "✅ EC2 종료 완료"
else
  echo "ℹ️  종료할 EC2 없음"
fi

# 2. RDS 삭제
echo "2/8 RDS 삭제 중..."
DBS=$(aws rds describe-db-instances \
  --query "DBInstances[?contains(TagList[?Key=='Week'].Value, '$TAG_WEEK')].DBInstanceIdentifier" \
  --output text)

if [ -n "$DBS" ]; then
  for db in $DBS; do
    aws rds delete-db-instance \
      --db-instance-identifier $db \
      --skip-final-snapshot
  done
  echo "✅ RDS 삭제 완료"
else
  echo "ℹ️  삭제할 RDS 없음"
fi

# 3. ElastiCache 삭제
echo "3/8 ElastiCache 삭제 중..."
# ... (생략)

# 4. ALB 삭제
echo "4/8 ALB 삭제 중..."
# ... (생략)

# 5. Auto Scaling Groups 삭제
echo "5/8 ASG 삭제 중..."
# ... (생략)

# 6. S3 버킷 비우기 및 삭제
echo "6/8 S3 버킷 정리 중..."
# ... (생략)

# 7. Security Groups 삭제
echo "7/8 Security Groups 삭제 중..."
# ... (생략)

# 8. VPC 삭제
echo "8/8 VPC 삭제 중..."
# ... (생략)

echo ""
echo "=== $DAY 리소스 정리 완료 ==="
```

## 📊 비용 추정 (Week 5 전체)

### 일별 예상 비용 (12명 기준)
```
Day 1: $1.50 (VPC, EC2, NAT Gateway)
Day 2: $1.50 (EC2, EBS, S3, CloudFront)
Day 3: $2.40 (RDS, ElastiCache, EC2)
Day 4: $4.20 (ALB, ASG, Multi-AZ)
Day 5: $7.80 (전체 인프라)
---
주간 합계: $17.40 (12명 기준)
학생당: $1.45/week
```

### 비용 절감 팁
- 프리티어 최대 활용
- 실습 시간 엄수 (50분)
- 즉시 리소스 정리
- 태그 기반 자동 정리

## ⚠️ 주의사항

### 강사 모니터링 시스템
```markdown
🔍 ReadOnly Role 활용:
- 강사는 모든 학생 계정에 ReadOnly Role Assume 가능
- 실시간으로 학생들의 리소스 구성 확인
- 잘못된 설정 즉시 피드백
- 비용 발생 리소스 모니터링

모니터링 체크리스트:
- [ ] VPC 구성 확인 (CIDR, Subnet)
- [ ] Security Group 규칙 검증
- [ ] EC2 인스턴스 타입 확인
- [ ] 불필요한 리소스 생성 여부
- [ ] 태그 설정 확인
```

### 학생 안내
```markdown
⚠️ **중요**: Week 5 비용 관리 필수!

1. **태그 필수**: 모든 리소스에 Week5, Day, Student 태그
2. **즉시 정리**: 실습 완료 후 30분 이내 삭제
3. **비용 확인**: 매일 비용 확인 습관화
4. **알림 설정**: $5 초과 시 알림 설정

💡 **팁**: 
- cleanup 스크립트 활용
- AWS Budgets 설정
- Cost Explorer 정기 확인
```

### 강사 체크리스트
- [ ] 일일 비용 한도 설정 ($10)
- [ ] 주간 비용 한도 설정 ($50)
- [ ] 실습 전 리소스 확인
- [ ] 실습 후 전체 학생 리소스 정리 확인
- [ ] 일일 비용 리포트 생성

## ❓ FAQ (자주 묻는 질문)

### 🐳 Docker와 AWS 관련

**Q1. Docker Compose로 실행하던 앱을 AWS에 어떻게 배포하나요?**
- **A**: Week 1-2에서 배운 Docker Compose 구조를 AWS 서비스로 매핑합니다:
  - `services` → EC2 인스턴스 또는 ECS
  - `networks` → VPC와 Subnet
  - `volumes` → EBS 또는 EFS
  - `ports` → Security Groups와 ALB

**Q2. Docker 이미지를 AWS에서 어떻게 관리하나요?**
- **A**: 
  - Docker Hub 그대로 사용 가능
  - 또는 ECR (Elastic Container Registry) 사용
  - Week 5에서는 Docker Hub 이미지 직접 사용

**Q3. docker-compose.yml의 환경변수는 AWS에서 어떻게 관리하나요?**
- **A**:
  - EC2 User Data로 환경변수 설정
  - Systems Manager Parameter Store
  - Secrets Manager (민감 정보)

### ☁️ AWS 서비스 선택

**Q4. EC2와 Lambda 중 어떤 것을 선택해야 하나요?**
- **A**:
  - **EC2**: 지속적으로 실행되는 서비스 (웹 서버, API)
  - **Lambda**: 이벤트 기반, 간헐적 실행 (Week 5에서는 EC2 중심)

**Q5. RDS와 EC2에 직접 DB 설치, 어떤 게 나은가요?**
- **A**:
  - **RDS**: 관리형 서비스, 자동 백업, Multi-AZ (권장)
  - **EC2 DB**: 완전한 제어, 특수한 설정 필요 시
  - Week 5에서는 RDS 사용

**Q6. S3와 EBS의 차이는 무엇인가요?**
- **A**:
  - **EBS**: EC2에 연결된 블록 스토리지 (하드디스크처럼)
  - **S3**: 객체 스토리지, 정적 파일, 백업용

### 🔐 보안 관련

**Q7. Security Group과 Network ACL의 차이는?**
- **A**:
  - **Security Group**: 인스턴스 레벨, Stateful (응답 자동 허용)
  - **Network ACL**: Subnet 레벨, Stateless (명시적 규칙)
  - 대부분 Security Group만 사용

**Q8. SSH 키를 잃어버리면 어떻게 하나요?**
- **A**:
  - EC2 Instance Connect 사용
  - Systems Manager Session Manager 사용
  - 또는 새 인스턴스 생성 (실습 환경)

**Q9. 모든 포트를 0.0.0.0/0으로 열어도 되나요?**
- **A**: ❌ **절대 안 됩니다**
  - SSH (22): 본인 IP만 허용
  - HTTP/HTTPS (80/443): 필요시에만 0.0.0.0/0
  - DB (3306, 5432): 애플리케이션 서버만 허용

### 💰 비용 관련

**Q10. 프리티어인데 비용이 청구되는 이유는?**
- **A**: 프리티어 제한 초과 항목:
  - NAT Gateway (시간당 과금)
  - 데이터 전송 (100GB 초과)
  - EBS 스냅샷 스토리지
  - Elastic IP (미사용 시)

**Q11. 실습 후 리소스를 삭제했는데 비용이 나오나요?**
- **A**: 확인 필요 항목:
  - EBS 볼륨 (인스턴스 삭제 시 자동 삭제 설정 확인)
  - Elastic IP (할당만 하고 미사용)
  - S3 버킷 (객체 삭제 확인)
  - RDS 스냅샷

**Q12. 비용을 최소화하는 방법은?**
- **A**:
  - 프리티어 서비스 최대 활용 (t3.micro, db.t3.micro)
  - 실습 시간 엄수 (50분)
  - 즉시 리소스 정리
  - Cost Explorer로 일일 확인

### 🌐 네트워킹 관련

**Q13. Public Subnet과 Private Subnet의 차이는?**
- **A**:
  - **Public**: Internet Gateway 연결, 외부 접근 가능
  - **Private**: NAT Gateway 통해서만 외부 접근, 보안 강화

**Q14. VPC CIDR 블록은 어떻게 설정하나요?**
- **A**:
  - 권장: 10.0.0.0/16 (65,536개 IP)
  - Subnet: /24 단위 (256개 IP)
  - 다른 VPC와 중복 방지

**Q15. 인터넷이 안 되는 이유는?**
- **A**: 체크리스트:
  - [ ] Internet Gateway 생성 및 VPC 연결
  - [ ] Route Table에 0.0.0.0/0 → IGW 규칙
  - [ ] Subnet이 해당 Route Table 연결
  - [ ] Security Group Outbound 허용
  - [ ] Public IP 할당 (EC2)

### 🔄 Kubernetes와 비교

**Q16. Week 3 Kubernetes와 AWS의 관계는?**
- **A**:
  - Kubernetes: 컨테이너 오케스트레이션 (어디서든 실행)
  - AWS: 클라우드 인프라 (Kubernetes 실행 환경 제공)
  - EKS: AWS의 관리형 Kubernetes (Week 5 범위 외)

**Q17. Kubernetes Service와 AWS ALB의 차이는?**
- **A**:
  - **K8s Service**: 클러스터 내부 로드밸런싱
  - **AWS ALB**: AWS 관리형 로드밸런서
  - 비슷한 역할, 다른 계층

**Q18. Week 3에서 배운 개념이 AWS에서는?**
- **A**:
  - Pod → EC2 인스턴스
  - Service → ALB/NLB
  - PersistentVolume → EBS/EFS
  - Ingress → ALB + Route 53
  - ConfigMap/Secret → Parameter Store/Secrets Manager

### 🛠️ 실습 관련

**Q19. Web Console 대신 CLI를 사용해도 되나요?**
- **A**: Week 5는 Web Console 중심 학습
  - 아키텍처 이해가 목적
  - CLI는 Terraform 특강에서 다룸

**Q20. 실습 중 막히면 어떻게 하나요?**
- **A**:
  1. Session 문서 다시 확인
  2. AWS 공식 문서 참조 (각 Session에 링크)
  3. 트러블슈팅 섹션 확인
  4. 강사에게 질문 (ReadOnly로 확인 가능)

**Q21. Lab을 건너뛰고 다음 Lab을 해도 되나요?**
- **A**: ❌ **권장하지 않습니다**
  - 각 Lab은 순차적으로 연결
  - 이전 Lab의 개념이 다음 Lab에 필요
  - 특히 Day 5는 전체 통합

### 🎯 학습 전략

**Q22. AWS 서비스가 너무 많은데 다 외워야 하나요?**
- **A**: ❌ **외울 필요 없습니다**
  - Week 5는 핵심 서비스만 (VPC, EC2, RDS, S3, ALB)
  - 개념과 사용 시나리오 이해가 중요
  - 필요할 때 공식 문서 참조

**Q23. 고객 사례(Session 4)는 왜 배우나요?**
- **A**:
  - 실제 아키텍처 패턴 학습
  - 서비스 조합 방법 이해
  - 실무 적용 능력 향상

**Q24. CloudMart 배포(Day 5)가 어려울까요?**
- **A**: Day 1-4를 잘 따라왔다면 가능
  - Day 1-4: 개별 서비스 학습
  - Day 5: 배운 것을 통합
  - 강사 지원 + 팀 협업

### 🔮 이후 학습

**Q25. Week 5 이후에는 무엇을 배우나요?**
- **A**:
  - Terraform 특강 (IaC)
  - 기본 프로젝트 (4주)
  - 심화 프로젝트 (5주)

**Q26. AWS 자격증을 따야 하나요?**
- **A**: Week 5는 실무 중심
  - 자격증은 선택사항
  - 실무 경험이 더 중요
  - 관심 있다면: AWS Certified Solutions Architect - Associate

**Q27. 더 공부하려면 어떤 자료를 봐야 하나요?**
- **A**:
  - AWS 공식 문서 (각 Session에 링크)
  - AWS Well-Architected Framework
  - AWS 아키텍처 센터 (실제 사례)
  - AWS 블로그

---

## 🎯 학습 성과 측정

### 기술적 성취
- [ ] AWS 핵심 서비스 활용 능력
- [ ] 고가용성 아키텍처 설계
- [ ] 비용 효율적 운영 전략
- [ ] 모니터링 & 운영 역량
- [ ] CloudMart 프로덕션 배포

### 실무 역량
- [ ] AWS 콘솔 & CLI 숙련도
- [ ] 인프라 설계 능력
- [ ] 문제 해결 능력
- [ ] 비용 의식 (Cost Awareness)

---

<div align="center">

**☁️ AWS 실무** • **💰 비용 효율** • **🏗️ 아키텍처 설계** • **🚀 프로덕션 배포**

*Week 5: CloudMart를 AWS에 완전 배포*

</div>
