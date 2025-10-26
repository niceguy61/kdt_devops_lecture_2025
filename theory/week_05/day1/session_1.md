# Week 5 Day 1 Session 1: AWS 기초 개념 (09:00-09:50)

<div align="center">

**🌍 글로벌 인프라** • **☁️ 클라우드 모델** • **🔐 계정 구조** • **💰 프리티어**

*AWS의 기본 개념과 글로벌 인프라 이해*

</div>

---

## 🕘 세션 정보
- **시간**: 09:00-09:50 (50분)
- **목표**: AWS 클라우드의 기본 개념과 글로벌 인프라 구조 이해
- **방식**: 이론 강의 + 실생활 비유 + 시각적 자료

## 🎯 학습 목표

### 📚 학습 목표
- **이해 목표**: AWS 글로벌 인프라(Region, AZ, Edge Location)의 구조와 역할 이해
- **적용 목표**: 클라우드 컴퓨팅 모델(IaaS, PaaS, SaaS)을 실무 상황에 적용
- **협업 목표**: AWS 계정 구조와 프리티어 활용 전략을 팀원과 공유

### 🛠️ 구현 목표
- AWS 계정 생성 및 기본 설정
- 프리티어 한도 이해 및 비용 관리 계획 수립
- 리전 선택 기준 파악

---

## 🤔 왜 필요한가? (5분)

### 현실 문제 상황

**💼 실무 시나리오**: 
"스타트업에서 서비스를 런칭하려고 합니다. 서버를 직접 구매해야 할까요, 아니면 클라우드를 사용해야 할까요?"

**🏠 일상 비유**: 
"집을 사는 것 vs 렌트하는 것"
- **서버 구매**: 집을 사는 것처럼 초기 비용이 크지만 내 소유
- **클라우드**: 렌트하는 것처럼 필요한 만큼만 사용하고 비용 지불

**☁️ AWS 아키텍처**: 
```
온프레미스 (기존)          →          AWS 클라우드 (현대)
├── 서버 구매 (수천만원)    →    필요한 만큼만 사용 (시간당 과금)
├── 유지보수 인력 필요      →    AWS가 인프라 관리
├── 확장 어려움            →    클릭 몇 번으로 확장
└── 장애 대응 복잡         →    자동 복구 및 백업
```

**📊 시장 동향**: 
- 2024년 기준 AWS 시장 점유율 32% (1위)
- 전 세계 37개 리전, 117개 가용 영역 운영
- 700개 이상의 CloudFront POP 및 엣지 캐시
- Fortune 500 기업의 90% 이상이 AWS 사용

### 학습 전후 비교

```mermaid
graph LR
    A[학습 전<br/>서버 구매만 생각] --> B[학습 후<br/>클라우드 활용 능력]
    
    style A fill:#ffebee
    style B fill:#e8f5e8
```

---

## 📖 핵심 개념 (35분)

### 🔍 개념 1: AWS 글로벌 인프라 (12분)

> **정의**: AWS는 전 세계에 분산된 데이터센터를 통해 서비스를 제공하는 글로벌 클라우드 인프라

**핵심 구성 요소**:
- **AWS Cloud**: 전 세계 분산 인프라
- **Region**: 지리적으로 분리된 데이터센터 그룹 (현재 37개 리전)
- **Availability Zone (AZ)**: Region 내 물리적으로 분리된 데이터센터 (117개 AZ)
- **Edge Location**: ![CloudFront](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Networking-Content-Delivery/64/Arch_Amazon-CloudFront_64.svg) 콘텐츠 전송 네트워크(CDN) 엣지 서버 (700개 이상)

#### 🏗️ AWS 글로벌 인프라 구조

```mermaid
architecture-beta
    group region(cloud)[AWS Region]
    
    group az1(server)[Availability Zone A] in region
    group az2(server)[Availability Zone B] in region
    group az3(server)[Availability Zone C] in region
    
    service dc1(database)[Data Center 1] in az1
    service dc2(database)[Data Center 2] in az1
    service dc3(database)[Data Center 3] in az2
    service dc4(database)[Data Center 4] in az2
    service dc5(database)[Data Center 5] in az3
    service dc6(database)[Data Center 6] in az3
    
    service edge1(internet)[CloudFront Edge] in region
    service edge2(internet)[CloudFront Edge] in region
    
    dc1:R -- L:dc3
    dc3:R -- L:dc5
    dc1:B -- T:dc5
    edge1:B -- T:dc1
    edge2:B -- T:dc3
```

#### 📊 인프라 계층 구조

| 계층 | 설명 | 개수 (2024년 10월) | 역할 |
|------|------|---------------------|------|
| **Region** | 지리적으로 분리된 지역 | 37개 | 데이터 주권, 지연시간 최소화 |
| **Availability Zone (AZ)** | Region 내 물리적으로 분리된 데이터센터 | 117개 | 고가용성, 장애 격리 |
| **Edge Location** | 콘텐츠 전송 네트워크(CDN) 거점 | 700개+ | 콘텐츠 캐싱, 빠른 전송 |

#### 🌍 실생활 비유

**Region = 도시**
- 서울 리전 (ap-northeast-2)
- 도쿄 리전 (ap-northeast-1)
- 버지니아 리전 (us-east-1)

**Availability Zone = 구/동**
- 서울 리전 내 AZ-A, AZ-B, AZ-C
- 각 AZ는 물리적으로 분리된 데이터센터
- 하나의 AZ가 장애가 나도 다른 AZ는 정상 운영

**Edge Location = 편의점**
- 사용자와 가까운 곳에서 콘텐츠 제공
- CloudFront CDN 서비스 활용
- 빠른 콘텐츠 전송

#### 🔧 리전 선택 기준

```mermaid
quadrantChart
    title AWS Region Selection
    x-axis Low Cost --> High Cost
    y-axis Low Latency --> High Latency
    quadrant-1 Optimal
    quadrant-2 Cost Focus
    quadrant-3 Review
    quadrant-4 Performance Focus
    Seoul: [0.7, 0.2]
    Tokyo: [0.6, 0.3]
    Virginia: [0.3, 0.7]
    Ohio: [0.2, 0.6]
    Singapore: [0.5, 0.5]
```

**리전 선택 4대 고려사항**:

```mermaid
mindmap
  root((리전 선택))
    지연시간
      사용자 위치
      네트워크 거리
      응답 속도
    비용
      리전별 가격 차이
      데이터 전송 비용
      운영 비용
    규정 준수
      데이터 주권
      법적 요구사항
      컴플라이언스
    서비스 가용성
      필요 서비스 제공
      최신 기능 지원
      리전별 제약사항
```

**실무 예시**:
- **한국 서비스**: **ap-northeast-2 (서울)** 선택 ⭐ 기본 권장
- **글로벌 서비스**: 주요 시장별 리전 선택 (서울, 도쿄, 버지니아)
- **규정 준수**: 금융 서비스는 데이터 주권 법규에 따라 리전 선택

**💡 Week 5 실습 기준 리전**: **ap-northeast-2 (서울)**
- 모든 Lab 실습은 서울 리전 사용
- 한국 사용자 기준 최저 지연시간
- 한국어 지원 및 기술 지원 용이

#### 💡 AWS 공식 문서

**AWS 글로벌 인프라 현황 (2024년 10월)**:
- **37개 리전**: 개별 다중 가용 영역을 갖춘 지리적 리전
- **117개 가용 영역**: 물리적으로 분리된 독립적인 데이터센터
- **700개 이상 POP**: CloudFront 엣지 로케이션 및 리전 엣지 캐시
- **43개 로컬/Wavelength 영역**: 초저지연 애플리케이션 지원

**참조**: [AWS 글로벌 인프라 공식 페이지](https://aws.amazon.com/ko/about-aws/global-infrastructure/)

---

### 🔍 개념 2: 클라우드 컴퓨팅 모델 (12분)

> **정의**: 클라우드 서비스는 제공하는 관리 수준에 따라 IaaS, PaaS, SaaS로 구분

**AWS 서비스 모델 예시**:
- ![EC2](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Compute/64/Arch_Amazon-EC2_64.svg) **IaaS**: Amazon EC2 (완전한 제어)
- ![Elastic Beanstalk](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Compute/64/Arch_AWS-Elastic-Beanstalk_64.svg) **PaaS**: Elastic Beanstalk (플랫폼 관리)
- ![WorkMail](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Business-Applications/64/Arch_Amazon-WorkMail_64.svg) **SaaS**: WorkMail (즉시 사용)

#### ☁️ 클라우드 서비스 모델 비교

```mermaid
%%{init: {'theme':'base'}}%%
timeline
    title 클라우드 서비스 모델 진화
    section 온프레미스
        모든 것을 직접 관리 : 애플리케이션
                              : 데이터
                              : 런타임
                              : 미들웨어
                              : OS
                              : 가상화
                              : 서버
                              : 스토리지
                              : 네트워크
    section IaaS
        인프라만 AWS 관리 : 애플리케이션 (고객)
                          : 데이터 (고객)
                          : 런타임 (고객)
                          : 미들웨어 (고객)
                          : OS (고객)
                          : 가상화 (AWS)
                          : 서버 (AWS)
                          : 스토리지 (AWS)
                          : 네트워크 (AWS)
    section PaaS
        플랫폼까지 AWS 관리 : 애플리케이션 (고객)
                            : 데이터 (고객)
                            : 런타임 (AWS)
                            : 미들웨어 (AWS)
                            : OS (AWS)
                            : 가상화 (AWS)
                            : 서버 (AWS)
                            : 스토리지 (AWS)
                            : 네트워크 (AWS)
    section SaaS
        모든 것을 AWS 관리 : 애플리케이션 (AWS)
                           : 데이터 (AWS)
                           : 런타임 (AWS)
                           : 미들웨어 (AWS)
                           : OS (AWS)
                           : 가상화 (AWS)
                           : 서버 (AWS)
                           : 스토리지 (AWS)
                           : 네트워크 (AWS)
```

#### 📊 서비스 모델 비교표

| 구분 | IaaS | PaaS | SaaS |
|------|------|------|------|
| **정의** | 인프라만 제공 | 플랫폼까지 제공 | 소프트웨어까지 제공 |
| **관리 범위** | OS부터 직접 관리 | 애플리케이션만 관리 | 사용만 하면 됨 |
| **AWS 예시** | EC2, VPC, S3 | Elastic Beanstalk, RDS | WorkMail, Chime |
| **유연성** | 높음 | 중간 | 낮음 |
| **관리 부담** | 높음 | 중간 | 낮음 |
| **적합한 경우** | 완전한 제어 필요 | 빠른 개발 필요 | 즉시 사용 필요 |

#### 🏠 실생활 비유

**IaaS = 빈 집 렌트**
- 집(서버)만 제공
- 가구(OS, 미들웨어)는 직접 설치
- 완전한 자유도, 높은 관리 부담

**PaaS = 가구 포함 렌트**
- 집 + 기본 가구(플랫폼) 제공
- 개인 물건(애플리케이션)만 가져오면 됨
- 적절한 자유도, 중간 관리 부담

**SaaS = 호텔**
- 모든 것이 준비됨
- 사용만 하면 됨
- 낮은 자유도, 관리 부담 없음

#### 🔧 AWS 서비스 분류

```mermaid
sankey-beta

AWS Services,IaaS,25
AWS Services,PaaS,15
AWS Services,SaaS,5

IaaS,Compute (EC2),8
IaaS,Storage (S3/EBS),7
IaaS,Network (VPC),10

PaaS,Database (RDS),5
PaaS,Container (ECS/EKS),5
PaaS,Serverless (Lambda),5

SaaS,Collaboration (WorkMail),2
SaaS,Analytics (QuickSight),2
SaaS,Communication (Chime),1
```

**주요 서비스 카테고리**:

```mermaid
mindmap
  root((AWS 서비스))
    IaaS
      EC2
        가상 서버
        완전한 제어
      VPC
        네트워크 격리
        보안 그룹
      S3
        객체 스토리지
        무제한 확장
      EBS
        블록 스토리지
        고성능 디스크
    PaaS
      RDS
        관리형 DB
        자동 백업
      Lambda
        서버리스
        이벤트 기반
      Elastic Beanstalk
        앱 배포
        자동 스케일링
      ECS/EKS
        컨테이너
        오케스트레이션
    SaaS
      WorkMail
        이메일
        즉시 사용
      Chime
        화상회의
        협업 도구
      QuickSight
        BI 분석
        시각화
```

---

### 🔍 개념 3: AWS 계정 구조 & 프리티어 (11분)

> **정의**: AWS 계정은 Root, IAM User, Role로 구성되며, 프리티어를 통해 무료로 학습 가능

**핵심 보안 서비스**:
- ![IAM](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Security-Identity-Compliance/64/Arch_AWS-Identity-and-Access-Management_64.svg) **IAM**: 권한 관리
- ![Organizations](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Management-Governance/64/Arch_AWS-Organizations_64.svg) **Organizations**: 계정 관리
- ![CloudTrail](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Management-Governance/64/Arch_AWS-CloudTrail_64.svg) **CloudTrail**: 감사 로그

#### 🔐 AWS 계정 구조

```mermaid
graph TB
    subgraph "AWS 계정 구조"
        A[Root Account<br/>최고 권한]
        
        subgraph "IAM (Identity and Access Management)"
            B[IAM User<br/>개별 사용자]
            C[IAM Group<br/>사용자 그룹]
            D[IAM Role<br/>임시 권한]
            E[IAM Policy<br/>권한 정책]
        end
    end
    
    A -.생성.-> B
    A -.생성.-> C
    A -.생성.-> D
    
    B -.소속.-> C
    C -.적용.-> E
    B -.적용.-> E
    D -.적용.-> E
    
    style A fill:#ffebee
    style B fill:#e8f5e8
    style C fill:#fff3e0
    style D fill:#e3f2fd
    style E fill:#f3e5f5
```

#### 📊 계정 유형 비교

| 구분 | Root Account | IAM User | IAM Role |
|------|--------------|----------|----------|
| **권한** | 모든 권한 | 제한된 권한 | 임시 권한 |
| **사용 시기** | 계정 생성 시만 | 일상적 작업 | 서비스 간 연동 |
| **MFA 필수** | ✅ 필수 | ✅ 권장 | ❌ 불필요 |
| **비밀번호** | ✅ 있음 | ✅ 있음 | ❌ 없음 |
| **액세스 키** | ⚠️ 생성 금지 | ✅ 가능 | ❌ 불필요 |

#### 🔒 보안 베스트 프랙티스

```mermaid
stateDiagram-v2
    [*] --> RootAccount: AWS 계정 생성
    
    state RootAccount {
        [*] --> EnableMFA: 1. MFA 활성화
        EnableMFA --> NoAccessKey: 2. 액세스 키 생성 금지
        NoAccessKey --> CreateIAMUser: 3. IAM User 생성
    }
    
    RootAccount --> IAMUser: Root 계정 잠금
    
    state IAMUser {
        [*] --> SetPermissions: 권한 설정
        SetPermissions --> EnableUserMFA: MFA 활성화
        EnableUserMFA --> DailyWork: 일상 작업 수행
    }
    
    IAMUser --> [*]: 안전한 운영
    
    note right of RootAccount
        ⚠️ Root 계정은
        절대 일상 작업에
        사용 금지
    end note
    
    note right of IAMUser
        ✅ 모든 작업은
        IAM User로
        수행
    end note
```

**⚠️ 중요 보안 규칙**:
1. **Root 계정은 절대 일상 작업에 사용 금지**
2. **Root 계정에 MFA(다중 인증) 필수 설정**
3. **Root 계정의 액세스 키 생성 금지**
4. **모든 작업은 IAM User로 수행**

#### 💰 AWS 프리티어 활용 전략

**12개월 무료 서비스**:
- ![EC2](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Compute/64/Arch_Amazon-EC2_64.svg) **EC2**: t2.micro/t3.micro 750시간/월
- ![RDS](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Database/64/Arch_Amazon-RDS_64.svg) **RDS**: db.t2.micro 750시간/월
- ![S3](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Storage/64/Arch_Amazon-Simple-Storage-Service_64.svg) **S3**: 5GB 스토리지
- ![CloudFront](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Networking-Content-Delivery/64/Arch_Amazon-CloudFront_64.svg) **CloudFront**: 50GB 전송

**항상 무료 서비스**:
- ![Lambda](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Compute/64/Arch_AWS-Lambda_64.svg) **Lambda**: 100만 요청/월
- ![DynamoDB](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Database/64/Arch_Amazon-DynamoDB_64.svg) **DynamoDB**: 25GB 스토리지
- ![SNS](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Application-Integration/64/Arch_Amazon-Simple-Notification-Service_64.svg) **SNS**: 100만 요청/월

```mermaid
graph TB
    subgraph "AWS 프리티어 유형"
        A[12개월 무료<br/>Free Tier]
        B[항상 무료<br/>Always Free]
        C[평가판<br/>Trials]
    end
    
    subgraph "12개월 무료 서비스"
        D[EC2<br/>t2.micro/t3.micro<br/>750시간/월]
        E[RDS<br/>db.t2.micro<br/>750시간/월]
        F[S3<br/>5GB 스토리지]
        G[CloudFront<br/>50GB 전송]
    end
    
    subgraph "항상 무료 서비스"
        H[Lambda<br/>100만 요청/월]
        I[DynamoDB<br/>25GB 스토리지]
        J[SNS<br/>100만 요청/월]
    end
    
    A --> D
    A --> E
    A --> F
    A --> G
    
    B --> H
    B --> I
    B --> J
    
    style A fill:#e8f5e8
    style B fill:#fff3e0
    style C fill:#ffebee
    style D fill:#e3f2fd
    style E fill:#e3f2fd
    style F fill:#e3f2fd
    style G fill:#e3f2fd
    style H fill:#f3e5f5
    style I fill:#f3e5f5
    style J fill:#f3e5f5
```

#### 📊 프리티어 한도 (Week 5 실습 기준)

| 서비스 | 프리티어 한도 | Week 5 사용 예상 | 초과 여부 |
|--------|---------------|------------------|-----------|
| **EC2** | 750시간/월 | 120시간 (5일 × 24시간) | ✅ 안전 |
| **RDS** | 750시간/월 | 120시간 | ✅ 안전 |
| **S3** | 5GB 스토리지 | 1GB | ✅ 안전 |
| **데이터 전송** | 100GB/월 | 10GB | ✅ 안전 |
| **NAT Gateway** | ❌ 유료 | $0.045/시간 | ⚠️ 비용 발생 |

**💡 비용 절감 팁**:
- **실습 시간 엄수**: 50분 실습 후 즉시 리소스 정리
- **프리티어 서비스 우선**: t2.micro, t3.micro 인스턴스 사용
- **NAT Gateway 최소화**: 필요시에만 생성, 즉시 삭제
- **비용 알림 설정**: $5 초과 시 알림 설정

#### 🔧 프리티어 모니터링

```bash
# AWS CLI로 프리티어 사용량 확인
aws ce get-cost-and-usage \
  --time-period Start=2025-01-01,End=2025-01-31 \
  --granularity MONTHLY \
  --metrics "BlendedCost" "UnblendedCost" \
  --group-by Type=DIMENSION,Key=SERVICE
```

**AWS Console 경로**:
```
AWS Console → Billing Dashboard → Free Tier
```

---

## 💭 함께 생각해보기 (10분)

### 🤝 페어 토론 (5분)

**토론 주제**:
1. **리전 선택**: "한국 서비스를 만든다면 어떤 리전을 선택하고, 그 이유는?"
2. **서비스 모델**: "우리 프로젝트에 IaaS, PaaS, SaaS 중 어떤 것이 적합할까?"
3. **비용 관리**: "프리티어를 최대한 활용하려면 어떻게 해야 할까?"

**페어 활동 가이드**:
- 👥 **자유 페어링**: 관심사가 비슷한 사람끼리
- 🔄 **역할 교대**: 5분씩 설명자/질문자 역할 바꾸기
- 📝 **핵심 정리**: 대화 내용 중 중요한 점 메모하기

### 🎯 전체 공유 (5분)

**공유 내용**:
- 각 페어의 리전 선택 이유
- 서비스 모델 선택 기준
- 비용 절감 아이디어

### 💡 이해도 체크 질문

- ✅ "Region, AZ, Edge Location의 차이를 설명할 수 있나요?"
- ✅ "IaaS, PaaS, SaaS를 실생활 예시로 설명할 수 있나요?"
- ✅ "Root 계정과 IAM User의 차이를 아나요?"
- ✅ "프리티어 한도를 초과하지 않으려면 어떻게 해야 하나요?"

---

## 🔑 핵심 키워드

### 📚 오늘의 핵심 용어

#### 🔤 기본 용어
- **Region (리전)**: 지리적으로 분리된 AWS 데이터센터 그룹
- **Availability Zone (AZ)**: Region 내 물리적으로 분리된 데이터센터
- **Edge Location**: CloudFront CDN 서비스를 위한 콘텐츠 캐싱 거점

#### 🔤 기술 용어
- **IaaS**: Infrastructure as a Service (인프라만 제공)
- **PaaS**: Platform as a Service (플랫폼까지 제공)
- **SaaS**: Software as a Service (소프트웨어까지 제공)
- **IAM**: Identity and Access Management (권한 관리)
- **MFA**: Multi-Factor Authentication (다중 인증)

#### 🔤 실무 용어
- **Free Tier**: 12개월 무료 또는 항상 무료 서비스
- **Root Account**: 최고 권한을 가진 계정 (일상 작업 금지)
- **IAM User**: 일상 작업용 사용자 계정
- **IAM Role**: 서비스 간 연동을 위한 임시 권한

---

## 📝 세션 마무리

### ✅ 오늘 세션 성과

**학습한 내용**:
- ✅ AWS 글로벌 인프라 구조 (Region, AZ, Edge Location)
- ✅ 클라우드 컴퓨팅 모델 (IaaS, PaaS, SaaS)
- ✅ AWS 계정 구조 및 보안 베스트 프랙티스
- ✅ 프리티어 활용 전략 및 비용 관리

**실무 적용**:
- 리전 선택 기준 파악
- 서비스 모델 선택 능력
- 보안 설정 중요성 인식
- 비용 관리 전략 수립

### 🎯 다음 세션 준비

**Session 2: VPC 아키텍처 (10:00-10:50)**
- VPC 개념 및 CIDR 블록
- Subnet (Public/Private) 설계
- Internet Gateway & NAT Gateway
- Route Table 설정

**사전 준비**:
- AWS 계정 생성 (아직 안 했다면)
- MFA 설정 완료
- IAM User 생성 및 로그인

---

## 🔗 공식 문서 (필수)

**⚠️ 학생들이 직접 확인해야 할 공식 문서**:
- 📘 [AWS 글로벌 인프라](https://aws.amazon.com/about-aws/global-infrastructure/)
- 📗 [AWS 계정 및 IAM 사용자 가이드](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html)
- 📙 [AWS 프리티어](https://aws.amazon.com/free/)
- 📕 [AWS 요금 계산기](https://calculator.aws/)
- 🆕 [AWS 최신 업데이트](https://aws.amazon.com/new/)

---

<div align="center">

**🌍 글로벌 인프라** • **☁️ 클라우드 모델** • **🔐 보안 우선** • **💰 비용 관리**

*AWS의 기본을 탄탄히 다지는 첫 걸음*

</div>
