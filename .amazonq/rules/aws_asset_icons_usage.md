# AWS Asset Icons 사용 규칙

## 🎯 적용 범위

**Week 5 전용**: AWS 집중 과정에서 AWS 공식 아이콘 필수 사용

## ⚠️ 필수 검증 절차

### 아이콘 사용 전 반드시 확인
```bash
# 1. 아이콘 파일 존재 확인
ls Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_[Category]/64/Arch_[Service-Name]_64.svg

# 2. 예시: EC2 아이콘 확인
ls Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Compute/64/Arch_Amazon-EC2_64.svg
```

### MCP 공식 이미지 사용 전 반드시 확인
```bash
# 1. MCP로 AWS 문서 읽기
aws___read_documentation(url)

# 2. 이미지 URL 추출 확인
# 3. 브라우저에서 이미지 URL 직접 접근 테스트
# 4. 접근 가능한 경우에만 사용
```

### 검증 실패 시 대응
- **아이콘 없음**: AWS_ASSET_ICONS_GUIDE.md에서 대체 아이콘 찾기
- **이미지 접근 불가**: Mermaid 다이어그램으로 대체
- **불확실한 경우**: 아이콘 사용하지 않고 텍스트만 사용

## 📁 아이콘 위치

**가이드 문서**: `theory/week_05/AWS_ASSET_ICONS_GUIDE.md`

**기본 경로 구조**:
```
Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/
└── Architecture-Service-Icons_01312023/
    └── Arch_[Category]/
        └── 64/
            └── Arch_[Service-Name]_64.svg
```

## 📝 Session에서 사용

### 서비스 설명 시
```markdown
### 🔧 AWS 서비스 분류

**IaaS 서비스**:
- ![EC2](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Compute/64/Arch_Amazon-EC2_64.svg) **EC2**: 가상 서버
- ![VPC](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Networking-Content-Delivery/64/Arch_Amazon-Virtual-Private-Cloud_64.svg) **VPC**: 네트워크
- ![S3](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Storage/64/Arch_Amazon-Simple-Storage-Service_64.svg) **S3**: 스토리지
```

### 개념 설명 시
```markdown
#### 🏗️ AWS 글로벌 인프라

**핵심 구성 요소**:
- ![Region](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Networking-Content-Delivery/64/Arch_AWS-Region_64.svg) **Region**: 지리적으로 분리된 데이터센터 그룹
- ![AZ](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Networking-Content-Delivery/64/Arch_Availability-Zone_64.svg) **Availability Zone**: Region 내 물리적으로 분리된 데이터센터
```

## 🛠️ Lab에서 사용

### 아키텍처 다이어그램
```markdown
## 🏗️ 구축할 아키텍처

### 📐 아키텍처 다이어그램

**사용된 AWS 서비스**:
- ![EC2](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Compute/64/Arch_Amazon-EC2_64.svg) **Amazon EC2**: 가상 서버
- ![VPC](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Networking-Content-Delivery/64/Arch_Amazon-Virtual-Private-Cloud_64.svg) **Amazon VPC**: 네트워크 격리
- ![RDS](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Database/64/Arch_Amazon-RDS_64.svg) **Amazon RDS**: 관리형 데이터베이스
```

### Step별 서비스 표시
```markdown
## 🛠️ Step 2: RDS 데이터베이스 구성 (20분)

### 📋 이 단계에서 사용하는 서비스
- ![RDS](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Database/64/Arch_Amazon-RDS_64.svg) **Amazon RDS**: PostgreSQL 데이터베이스
- ![VPC](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Networking-Content-Delivery/64/Arch_Amazon-Virtual-Private-Cloud_64.svg) **VPC**: Private Subnet 배치
```

## 🎮 Challenge에서 사용

### 시스템 구성 요소
```markdown
## 🏗️ 전체 아키텍처

**배포된 AWS 서비스**:
- ![ALB](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Networking-Content-Delivery/64/Arch_Elastic-Load-Balancing_64.svg) **Application Load Balancer**: 로드 밸런싱
- ![EC2](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Compute/64/Arch_Amazon-EC2_64.svg) **EC2 Auto Scaling**: 자동 확장
- ![RDS](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Database/64/Arch_Amazon-RDS_64.svg) **RDS Multi-AZ**: 고가용성 DB
```

## 📋 주요 서비스 경로 (빠른 참조)

### Compute
```
EC2: Arch_Compute/64/Arch_Amazon-EC2_64.svg
Lambda: Arch_Compute/64/Arch_AWS-Lambda_64.svg
Elastic Beanstalk: Arch_Compute/64/Arch_AWS-Elastic-Beanstalk_64.svg
```

### Database
```
RDS: Arch_Database/64/Arch_Amazon-RDS_64.svg
DynamoDB: Arch_Database/64/Arch_Amazon-DynamoDB_64.svg
ElastiCache: Arch_Database/64/Arch_Amazon-ElastiCache_64.svg
```

### Storage
```
S3: Arch_Storage/64/Arch_Amazon-Simple-Storage-Service_64.svg
EBS: Arch_Storage/64/Arch_Amazon-Elastic-Block-Store_64.svg
EFS: Arch_Storage/64/Arch_Amazon-Elastic-File-System_64.svg
```

### Networking
```
VPC: Arch_Networking-Content-Delivery/64/Arch_Amazon-Virtual-Private-Cloud_64.svg
CloudFront: Arch_Networking-Content-Delivery/64/Arch_Amazon-CloudFront_64.svg
Route 53: Arch_Networking-Content-Delivery/64/Arch_Amazon-Route-53_64.svg
ELB: Arch_Networking-Content-Delivery/64/Arch_Elastic-Load-Balancing_64.svg
```

### Security
```
IAM: Arch_Security-Identity-Compliance/64/Arch_AWS-Identity-and-Access-Management_64.svg
KMS: Arch_Security-Identity-Compliance/64/Arch_AWS-Key-Management-Service_64.svg
WAF: Arch_Security-Identity-Compliance/64/Arch_AWS-WAF_64.svg
```

### Management
```
CloudWatch: Arch_Management-Governance/64/Arch_Amazon-CloudWatch_64.svg
CloudTrail: Arch_Management-Governance/64/Arch_AWS-CloudTrail_64.svg
Organizations: Arch_Management-Governance/64/Arch_AWS-Organizations_64.svg
```

## ⚠️ 주의사항

### 1. 크기 선택
- **48px 사용**: `/48/` 폴더의 아이콘 사용
- 다른 크기 (16, 32, 64)는 사용하지 않음

### 2. 서비스명 정확성
- **S3**: `Amazon-Simple-Storage-Service` (O)
- **S3**: `Amazon-S3` (X)
- **VPC**: `Amazon-Virtual-Private-Cloud` (O)
- **VPC**: `Amazon-VPC` (X)
- **IAM**: `AWS-Identity-and-Access-Management` (O)
- **IAM**: `AWS-IAM` (X)

### 3. 상대 경로 조정
- Session: `../../../Asset-Package...`
- Lab: `../../../Asset-Package...`
- Challenge: `../../../Asset-Package...`

### 4. 아이콘 찾기
```bash
# 서비스명으로 검색
find Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023 -name "*서비스명*.svg" | grep "/64/"

# 예시: EC2 아이콘 찾기
find Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023 -name "*EC2*.svg" | grep "/64/"
```

## ✅ 체크리스트

### Session 작성 시
- [ ] 서비스 설명마다 아이콘 포함
- [ ] 64px 크기 사용
- [ ] 정확한 서비스명 사용
- [ ] 상대 경로 확인

### Lab 작성 시
- [ ] 아키텍처 다이어그램에 아이콘 표시
- [ ] Step별 사용 서비스 아이콘 표시
- [ ] 검증 섹션에 서비스 아이콘 포함

### Challenge 작성 시
- [ ] 전체 시스템 구성 요소 아이콘 표시
- [ ] 문제 상황별 관련 서비스 아이콘
- [ ] 해결 방법에 서비스 아이콘 포함

---

<div align="center">

**🎨 공식 아이콘** • **📐 일관된 디자인** • **🔍 정확한 경로**

*AWS Asset Icons로 전문적인 Week 5 강의 자료 제작*

</div>
