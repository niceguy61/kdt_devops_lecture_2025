# AWS 아이콘 가이드

## 개요

이 문서는 AWS 아키텍처 다이어그램 작성 시 공식 AWS 아이콘을 사용하는 방법을 안내합니다. 올바른 아이콘 사용은 전문적이고 이해하기 쉬운 다이어그램을 만드는 핵심입니다.

---

## 공식 AWS 아이콘 위치

### 로컬 Asset Package

이 프로젝트에는 공식 AWS 아이콘이 포함되어 있습니다:

```
Asset-Package/
├── Architecture-Service-Icons_01312023/    # 서비스 아이콘
│   ├── Arch_Compute/                       # EC2, Lambda 등
│   ├── Arch_Storage/                       # S3, EBS 등
│   ├── Arch_Database/                      # RDS, DynamoDB 등
│   ├── Arch_Networking-Content-Delivery/   # VPC, CloudFront 등
│   ├── Arch_Security-Identity-Compliance/  # IAM, KMS 등
│   ├── Arch_Containers/                    # ECS, EKS 등
│   └── ... (기타 카테고리)
│
├── Category-Icons_01312023/                # 카테고리 아이콘
│   ├── Arch-Category_16/
│   ├── Arch-Category_32/
│   ├── Arch-Category_48/
│   └── Arch-Category_64/
│
└── Resource-Icons_01312023/                # 리소스 아이콘
    ├── Res_Compute/
    ├── Res_Storage/
    └── ... (기타 리소스)
```

### 아이콘 크기

각 서비스 아이콘은 4가지 크기로 제공됩니다:
- **16x16**: 작은 다이어그램, 아이콘 목록
- **32x32**: 일반적인 다이어그램 (권장)
- **48x48**: 큰 다이어그램, 프레젠테이션
- **64x64**: 매우 큰 다이어그램, 포스터

### 파일 형식

- **PNG**: 래스터 이미지, 일반적인 용도
- **SVG**: 벡터 이미지, 확대/축소 시 품질 유지 (권장)

---

## Draw.io에서 AWS 라이브러리 추가

### 방법 1: 온라인 라이브러리 사용 (권장)

1. **Draw.io 열기**
   - 웹: https://app.diagrams.net
   - 또는 데스크톱 앱

2. **라이브러리 추가**
   ```
   More Shapes (왼쪽 하단) 클릭
   → "AWS" 검색
   → 필요한 카테고리 체크
     ✓ AWS 19
     ✓ AWS 17
   → Apply 클릭
   ```

3. **사용 가능한 AWS 라이브러리**
   - **AWS 19**: 최신 AWS 아이콘 세트
   - **AWS 17**: 이전 버전 (호환성)
   - **AWS Simple Icons**: 단순화된 아이콘

### 방법 2: 로컬 아이콘 사용

1. **아이콘 파일 준비**
   ```
   Asset-Package/Architecture-Service-Icons_01312023/
   에서 필요한 아이콘 선택
   ```

2. **Draw.io에 추가**
   ```
   File → Import → 아이콘 파일 선택
   또는
   드래그 앤 드롭으로 캔버스에 추가
   ```

3. **커스텀 라이브러리 생성**
   ```
   File → New Library
   → 자주 사용하는 아이콘 추가
   → 저장 및 재사용
   ```

---

## 자주 사용하는 AWS 아이콘

### 컴퓨팅 (Compute)

| 서비스 | 아이콘 위치 | 용도 |
|--------|-------------|------|
| **EC2** | `Arch_Compute/64/Arch_Amazon-EC2_64.png` | 가상 서버 |
| **Lambda** | `Arch_Compute/64/Arch_AWS-Lambda_64.png` | 서버리스 함수 |
| **ECS** | `Arch_Containers/64/Arch_Amazon-ECS_64.png` | 컨테이너 서비스 |
| **EKS** | `Arch_Containers/64/Arch_Amazon-EKS_64.png` | Kubernetes 서비스 |
| **Auto Scaling** | `Arch_Compute/64/Arch_AWS-Auto-Scaling_64.png` | 자동 확장 |

### 스토리지 (Storage)

| 서비스 | 아이콘 위치 | 용도 |
|--------|-------------|------|
| **S3** | `Arch_Storage/64/Arch_Amazon-S3_64.png` | 객체 스토리지 |
| **EBS** | `Arch_Storage/64/Arch_Amazon-EBS_64.png` | 블록 스토리지 |
| **EFS** | `Arch_Storage/64/Arch_Amazon-EFS_64.png` | 파일 스토리지 |
| **Glacier** | `Arch_Storage/64/Arch_Amazon-S3-Glacier_64.png` | 아카이브 스토리지 |

### 데이터베이스 (Database)

| 서비스 | 아이콘 위치 | 용도 |
|--------|-------------|------|
| **RDS** | `Arch_Database/64/Arch_Amazon-RDS_64.png` | 관계형 DB |
| **DynamoDB** | `Arch_Database/64/Arch_Amazon-DynamoDB_64.png` | NoSQL DB |
| **ElastiCache** | `Arch_Database/64/Arch_Amazon-ElastiCache_64.png` | 인메모리 캐시 |
| **Aurora** | `Arch_Database/64/Arch_Amazon-Aurora_64.png` | 고성능 RDS |

### 네트워킹 (Networking)

| 서비스 | 아이콘 위치 | 용도 |
|--------|-------------|------|
| **VPC** | `Arch_Networking-Content-Delivery/64/Arch_Amazon-VPC_64.png` | 가상 네트워크 |
| **CloudFront** | `Arch_Networking-Content-Delivery/64/Arch_Amazon-CloudFront_64.png` | CDN |
| **Route 53** | `Arch_Networking-Content-Delivery/64/Arch_Amazon-Route-53_64.png` | DNS |
| **ELB** | `Arch_Networking-Content-Delivery/64/Arch_Elastic-Load-Balancing_64.png` | 로드 밸런서 |
| **API Gateway** | `Arch_App-Integration/64/Arch_Amazon-API-Gateway_64.png` | API 관리 |

### 보안 (Security)

| 서비스 | 아이콘 위치 | 용도 |
|--------|-------------|------|
| **IAM** | `Arch_Security-Identity-Compliance/64/Arch_AWS-IAM_64.png` | 접근 관리 |
| **KMS** | `Arch_Security-Identity-Compliance/64/Arch_AWS-KMS_64.png` | 키 관리 |
| **WAF** | `Arch_Security-Identity-Compliance/64/Arch_AWS-WAF_64.png` | 웹 방화벽 |
| **Shield** | `Arch_Security-Identity-Compliance/64/Arch_AWS-Shield_64.png` | DDoS 방어 |

### 개발자 도구 (Developer Tools)

| 서비스 | 아이콘 위치 | 용도 |
|--------|-------------|------|
| **CodePipeline** | `Arch_Developer-Tools/64/Arch_AWS-CodePipeline_64.png` | CI/CD 파이프라인 |
| **CodeBuild** | `Arch_Developer-Tools/64/Arch_AWS-CodeBuild_64.png` | 빌드 서비스 |
| **CodeDeploy** | `Arch_Developer-Tools/64/Arch_AWS-CodeDeploy_64.png` | 배포 서비스 |
| **CloudFormation** | `Arch_Management-Governance/64/Arch_AWS-CloudFormation_64.png` | IaC |

---

## 색상 및 스타일 가이드

### AWS 공식 색상

AWS 아이콘은 서비스 카테고리별로 색상이 지정되어 있습니다:

| 카테고리 | 색상 | 예시 |
|----------|------|------|
| **Compute** | 주황색 | EC2, Lambda |
| **Storage** | 녹색 | S3, EBS |
| **Database** | 파란색 | RDS, DynamoDB |
| **Networking** | 보라색 | VPC, CloudFront |
| **Security** | 빨간색 | IAM, KMS |
| **Analytics** | 분홍색 | Athena, EMR |

### 다이어그램 스타일 권장사항

#### 1. 컨테이너 색상

```
VPC: 연한 녹색 배경 (#E8F5E9)
Public Subnet: 연한 파란색 배경 (#E3F2FD)
Private Subnet: 연한 회색 배경 (#F5F5F5)
```

#### 2. 연결선 스타일

```
데이터 흐름: 실선 화살표
네트워크 연결: 실선
보안 그룹: 점선
선택적 연결: 점선 화살표
```

#### 3. 레이블 규칙

```
서비스 이름: 굵게 (Bold)
인스턴스 ID: 일반
설명: 기울임 (Italic)
```

---

## 다이어그램 작성 모범 사례

### 1. 계층 구조 표현

```
상위 레벨 (Region)
  ↓
중간 레벨 (VPC, Availability Zone)
  ↓
하위 레벨 (Subnet, Security Group)
  ↓
서비스 레벨 (EC2, RDS, S3)
```

### 2. 그룹화 원칙

- **Region**: 가장 큰 컨테이너
- **VPC**: Region 내부
- **Availability Zone**: VPC 내부 (수직 분할)
- **Subnet**: AZ 내부 (Public/Private 구분)
- **Security Group**: 점선 테두리

### 3. 아이콘 배치 규칙

```
왼쪽 → 오른쪽: 데이터 흐름 방향
위 → 아래: 계층 구조
중앙: 핵심 서비스
외곽: 보조 서비스
```

### 4. 일관성 유지

- 동일한 서비스는 동일한 아이콘 사용
- 동일한 크기 유지 (보통 48x48 또는 64x64)
- 정렬 및 간격 일정하게 유지

---

## 실전 예제

### 3계층 웹 애플리케이션

**필요한 아이콘**:
1. VPC (컨테이너)
2. Internet Gateway
3. Application Load Balancer
4. EC2 (Web Server)
5. EC2 (App Server)
6. RDS (Database)
7. S3 (Static Assets)
8. CloudFront (CDN)

**배치 순서**:
```
1. VPC 컨테이너 생성
2. Public Subnet (상단)
   - Internet Gateway
   - ALB
3. Private Subnet (중간)
   - EC2 (Web/App)
4. Private Subnet (하단)
   - RDS
5. 외부
   - S3
   - CloudFront
```

### Kubernetes on EKS

**필요한 아이콘**:
1. EKS (클러스터)
2. VPC
3. EC2 (Worker Nodes)
4. ALB (Ingress)
5. ECR (Container Registry)
6. CloudWatch (Monitoring)

---

## 아이콘 검색 팁

### Draw.io 내 검색

```
1. 왼쪽 패널에서 검색창 사용
2. 서비스 이름 입력 (예: "EC2", "S3")
3. 필터링된 아이콘 목록 확인
```

### 로컬 파일 검색

```
1. Asset-Package 디렉토리에서 검색
2. 파일명 패턴: Arch_[서비스명]_[크기].png
3. 예: Arch_Amazon-EC2_64.png
```

### 온라인 리소스

- **AWS 공식 아이콘**: https://aws.amazon.com/architecture/icons/
- **다운로드**: 최신 아이콘 세트 다운로드 가능
- **업데이트**: 분기별 업데이트 확인

---

## 일반적인 실수 및 해결

### 실수 1: 잘못된 아이콘 사용

❌ **잘못된 예**: EC2 대신 일반 서버 아이콘 사용
✅ **올바른 예**: 공식 EC2 아이콘 사용

### 실수 2: 크기 불일치

❌ **잘못된 예**: 다양한 크기의 아이콘 혼용
✅ **올바른 예**: 모든 아이콘을 동일한 크기로 통일

### 실수 3: 색상 변경

❌ **잘못된 예**: AWS 아이콘 색상 임의 변경
✅ **올바른 예**: 공식 색상 유지

### 실수 4: 레이블 누락

❌ **잘못된 예**: 아이콘만 배치
✅ **올바른 예**: 모든 아이콘에 명확한 레이블 추가

---

## 고급 기법

### 1. 커스텀 아이콘 세트 생성

```
1. 자주 사용하는 아이콘 선택
2. Draw.io에서 커스텀 라이브러리 생성
3. 팀과 공유
```

### 2. 템플릿 활용

```
1. 표준 아키텍처 패턴을 템플릿으로 저장
2. 새 프로젝트 시작 시 템플릿 사용
3. 일관성 유지 및 시간 절약
```

### 3. 레이어 활용

```
Layer 1: 네트워크 인프라 (VPC, Subnet)
Layer 2: 컴퓨팅 리소스 (EC2, Lambda)
Layer 3: 데이터 서비스 (RDS, S3)
Layer 4: 보안 및 모니터링
```

---

## 체크리스트

다이어그램 완성 전 확인사항:

- [ ] 모든 AWS 서비스에 공식 아이콘 사용
- [ ] 아이콘 크기 일관성 유지
- [ ] 모든 구성 요소에 레이블 추가
- [ ] VPC, Subnet 등 컨테이너 명확히 표시
- [ ] 데이터 흐름 방향 표시
- [ ] 보안 그룹 및 네트워크 ACL 표시
- [ ] Availability Zone 구분
- [ ] 색상 코딩 일관성
- [ ] 범례 추가 (필요시)
- [ ] 다이어그램 제목 및 버전 표시

---

## 추가 리소스

### 공식 문서
- **AWS 아키텍처 센터**: https://aws.amazon.com/architecture/
- **AWS 아이콘 다운로드**: https://aws.amazon.com/architecture/icons/
- **모범 사례**: https://aws.amazon.com/architecture/well-architected/

### 커뮤니티 리소스
- **AWS 샘플 다이어그램**: GitHub에서 검색
- **Draw.io AWS 템플릿**: 커뮤니티 공유 템플릿

### 학습 자료
- **AWS 아키텍처 다이어그램 작성 가이드**
- **클라우드 아키텍처 패턴**

---

## 빠른 시작 가이드

### 첫 AWS 다이어그램 만들기 (5분)

```
1. Draw.io 열기
2. More Shapes → AWS 19 추가
3. VPC 컨테이너 생성 (사각형)
4. Public Subnet 추가 (연한 파란색)
5. ALB 아이콘 드래그
6. Private Subnet 추가 (연한 회색)
7. EC2 아이콘 드래그
8. RDS 아이콘 드래그
9. 연결선 추가
10. 레이블 작성 및 저장
```

이 가이드를 참고하여 전문적인 AWS 아키텍처 다이어그램을 작성하세요!
