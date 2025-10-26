# Week 5 AWS Asset Icons 사용 가이드

## 📁 아이콘 위치

AWS Asset Icons는 다음 경로에 있습니다:
```
Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/
└── Architecture-Service-Icons_01312023/
    ├── Arch_Compute/
    ├── Arch_Database/
    ├── Arch_Storage/
    ├── Arch_Networking-Content-Delivery/
    ├── Arch_Security-Identity-Compliance/
    ├── Arch_Management-Governance/
    └── ...
```

## 🎯 주요 서비스 아이콘 경로

### Compute (컴퓨팅)
```markdown
![EC2](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Compute/64/Arch_Amazon-EC2_64.svg)
![Lambda](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Compute/64/Arch_AWS-Lambda_64.svg)
![Elastic Beanstalk](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Compute/64/Arch_AWS-Elastic-Beanstalk_64.svg)
```

### Database (데이터베이스)
```markdown
![RDS](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Database/64/Arch_Amazon-RDS_64.svg)
![DynamoDB](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Database/64/Arch_Amazon-DynamoDB_64.svg)
![ElastiCache](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Database/64/Arch_Amazon-ElastiCache_64.svg)
```

### Storage (스토리지)
```markdown
![S3](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Storage/64/Arch_Amazon-Simple-Storage-Service_64.svg)
![EBS](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Storage/64/Arch_Amazon-Elastic-Block-Store_64.svg)
![EFS](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Storage/64/Arch_Amazon-Elastic-File-System_64.svg)
```

### Networking & Content Delivery (네트워킹)
```markdown
![VPC](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Networking-Content-Delivery/64/Arch_Amazon-Virtual-Private-Cloud_64.svg)
![CloudFront](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Networking-Content-Delivery/64/Arch_Amazon-CloudFront_64.svg)
![Route 53](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Networking-Content-Delivery/64/Arch_Amazon-Route-53_64.svg)
![ELB](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Networking-Content-Delivery/64/Arch_Elastic-Load-Balancing_64.svg)
```

### Security, Identity & Compliance (보안)
```markdown
![IAM](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Security-Identity-Compliance/64/Arch_AWS-Identity-and-Access-Management_64.svg)
![KMS](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Security-Identity-Compliance/64/Arch_AWS-Key-Management-Service_64.svg)
![WAF](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Security-Identity-Compliance/64/Arch_AWS-WAF_64.svg)
```

### Management & Governance (관리)
```markdown
![CloudWatch](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Management-Governance/64/Arch_Amazon-CloudWatch_64.svg)
![CloudTrail](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Management-Governance/64/Arch_AWS-CloudTrail_64.svg)
![Organizations](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Management-Governance/64/Arch_AWS-Organizations_64.svg)
```

## 📋 사용 방법

### Session 문서에서 사용
```markdown
### 🔧 AWS 서비스 분류

**IaaS 서비스**:
- ![EC2](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Compute/64/Arch_Amazon-EC2_64.svg) **EC2**: 가상 서버
- ![VPC](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Networking-Content-Delivery/64/Arch_Amazon-Virtual-Private-Cloud_64.svg) **VPC**: 네트워크
- ![S3](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Storage/64/Arch_Amazon-Simple-Storage-Service_64.svg) **S3**: 스토리지
```

## 🔍 아이콘 찾기

특정 서비스의 아이콘을 찾으려면:

```bash
# 서비스명으로 검색
find Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023 -name "*서비스명*.svg" | grep "/64/"

# 예시: EC2 아이콘 찾기
find Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023 -name "*EC2*.svg" | grep "/64/"
```

## 📐 아이콘 크기

아이콘은 4가지 크기로 제공됩니다:
- **16px**: `/16/` 폴더
- **32px**: `/32/` 폴더
- **48px**: `/48/` 폴더
- **64px**: `/64/` 폴더 (권장)

Week 5에서는 **64px** 크기를 표준으로 사용합니다.

## ⚠️ 주의사항

1. **경로 확인**: 실제 파일이 존재하는지 확인 후 사용
2. **파일명 정확성**: AWS 서비스 정식 명칭 사용
   - S3 → `Amazon-Simple-Storage-Service`
   - VPC → `Amazon-Virtual-Private-Cloud`
   - IAM → `AWS-Identity-and-Access-Management`
3. **상대 경로**: Session 문서 위치에 따라 `../../../` 조정

## 📚 전체 카테고리 목록

```
Arch_Analytics/
Arch_Application-Integration/
Arch_Business-Applications/
Arch_Compute/
Arch_Containers/
Arch_Database/
Arch_Developer-Tools/
Arch_End-User-Computing/
Arch_Front-End-Web-Mobile/
Arch_Internet-of-Things/
Arch_Machine-Learning/
Arch_Management-Governance/
Arch_Media-Services/
Arch_Migration-Transfer/
Arch_Networking-Content-Delivery/
Arch_Security-Identity-Compliance/
Arch_Storage/
```

## 🎯 Week 5 Day별 주요 아이콘

### Day 1: AWS 기초 & 네트워킹
- EC2, VPC, Security Groups, Internet Gateway

### Day 2: 컴퓨팅 & 스토리지
- EBS, EFS, S3, CloudFront

### Day 3: 데이터베이스 & 캐싱
- RDS, ElastiCache, DynamoDB

### Day 4: 로드밸런싱 & 고가용성
- ELB, Auto Scaling, CloudWatch

### Day 5: CloudMart 프로젝트 배포
- 위 모든 서비스 통합

---

<div align="center">

**🎨 공식 아이콘** • **📐 일관된 디자인** • **🔍 쉬운 검색**

*AWS Asset Icons로 전문적인 강의 자료 제작*

</div>
