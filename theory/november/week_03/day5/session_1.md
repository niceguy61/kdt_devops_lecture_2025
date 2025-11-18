# November Week 3 Day 5 Session 1: Terraform Remote State & Backend

<div align="center">

**☁️ Remote State** • **🔒 State Locking** • **👥 팀 협업** • **🔐 보안**

*S3 Backend로 안전한 팀 협업 체계 구축*

</div>

---

## 🕘 세션 정보
**시간**: 09:00-09:40 (40분)
**목표**: Remote State Backend 설정 및 팀 협업 전략 습득
**방식**: 개념 학습 + 실전 패턴

## 🎯 학습 목표
- Terraform Remote State의 필요성과 장점 이해
- S3 Backend 설정 및 State Locking 구현
- 팀 협업 시 State 관리 전략 수립
- State 보안 및 버전 관리 방법 습득

---

## 📖 서비스 개요

### 1. 생성 배경 (Why?) - 5분

**문제 상황**:
- **로컬 State 파일 문제**: 개발자 A의 노트북에만 State 파일 존재
  ```
  개발자 A: terraform.tfstate (최신)
  개발자 B: terraform.tfstate (없음 또는 구버전)
  → 개발자 B가 apply 하면 리소스 중복 생성!
  ```

- **동시 수정 충돌**: 두 명이 동시에 `terraform apply` 실행
  ```
  개발자 A: EC2 인스턴스 생성 중...
  개발자 B: 같은 시간에 VPC 수정 중...
  → State 파일 충돌! 인프라 손상 위험!
  ```

- **State 파일 유실**: 노트북 고장, 실수로 삭제
  ```
  terraform.tfstate 삭제됨
  → Terraform이 기존 리소스를 모름
  → 모든 리소스를 다시 생성하려고 시도!
  ```

- **버전 관리 어려움**: State 파일을 Git에 커밋?
  ```
  ❌ State에는 민감한 정보 포함 (DB 비밀번호, API 키)
  ❌ Git 충돌 해결 어려움
  ❌ 대용량 파일 (수 MB)
  ```

**Terraform Remote State 솔루션**:
- **중앙 집중식 저장**: S3에 State 파일 저장 → 모든 팀원이 동일한 State 사용
- **State Locking**: DynamoDB로 동시 수정 방지 → 한 번에 한 명만 작업
- **버전 관리**: S3 Versioning으로 State 히스토리 보관 → 언제든 복구 가능
- **보안**: 암호화 및 접근 제어 → 민감한 정보 보호


### 2. 핵심 원리 (How?) - 10분

**작동 원리**:

```mermaid
sequenceDiagram
    participant Dev1 as 개발자 A
    participant S3 as S3 Bucket<br/>(State 저장)
    participant DDB as DynamoDB<br/>(Lock Table)
    participant Dev2 as 개발자 B
    
    Dev1->>DDB: 1. Lock 획득 요청
    DDB->>Dev1: Lock 획득 성공
    Dev1->>S3: 2. State 다운로드
    S3->>Dev1: 현재 State 반환
    
    Note over Dev1: 3. terraform plan/apply 실행
    
    Dev2->>DDB: Lock 획득 요청 (동시)
    DDB->>Dev2: ❌ Lock 대기 (이미 사용 중)
    
    Dev1->>S3: 4. 변경된 State 업로드
    Dev1->>DDB: 5. Lock 해제
    
    DDB->>Dev2: ✅ Lock 획득 가능
    Dev2->>S3: State 다운로드
    
    style Dev1 fill:#e8f5e8
    style Dev2 fill:#fff3e0
    style S3 fill:#ffebee
    style DDB fill:#e3f2fd
```

**Backend 구성 요소**:

1. **S3 Bucket**: State 파일 저장소
   - Versioning 활성화 (히스토리 보관)
   - 암호화 활성화 (AES-256 또는 KMS)
   - 접근 제어 (IAM Policy)

2. **DynamoDB Table**: State Lock 관리
   - Hash Key: `LockID` (문자열)
   - 누가, 언제, 어떤 작업 중인지 기록
   - Lock 획득/해제 자동 관리

3. **Backend 설정**: Terraform 코드에 Backend 정의
   ```hcl
   terraform {
     backend "s3" {
       bucket         = "my-terraform-state"
       key            = "prod/terraform.tfstate"
       region         = "ap-northeast-2"
       encrypt        = true
       dynamodb_table = "terraform-locks"
     }
   }
   ```


### 3. 주요 사용 사례 (When?) - 5분

**적합한 경우**:
- **팀 협업**: 2명 이상의 개발자가 동일한 인프라 관리
- **프로덕션 환경**: 중요한 인프라로 State 유실 불가
- **CI/CD 파이프라인**: GitHub Actions, GitLab CI에서 Terraform 실행
- **멀티 환경**: dev/staging/prod 각각 별도 State 관리

**실제 사례**:
- **스타트업 A**: 5명 DevOps 팀이 S3 Backend로 협업
  - 동시 수정 충돌 0건 (DynamoDB Locking)
  - State 유실 사고 0건 (S3 Versioning)
  
- **기업 B**: 100개 이상 프로젝트 관리
  - 프로젝트별 S3 Key 분리 (`project-a/terraform.tfstate`)
  - 환경별 Workspace 사용 (`dev`, `staging`, `prod`)

- **CI/CD 환경**: GitHub Actions에서 자동 배포
  - GitHub Secrets에 AWS 자격증명 저장
  - 매 PR마다 `terraform plan` 자동 실행
  - Merge 후 `terraform apply` 자동 실행


### 4. 비슷한 서비스 비교 (Which?) - 5분

**Terraform Backend 옵션**:

**S3 Backend vs Local Backend**:
- 언제 Local Backend 사용: 개인 학습, 프로토타입, 일회성 테스트
- 언제 S3 Backend 사용: 팀 협업, 프로덕션 환경, CI/CD

**S3 Backend vs Terraform Cloud**:
- 언제 S3 Backend 사용: AWS 중심 인프라, 비용 절감, 완전한 제어
- 언제 Terraform Cloud 사용: 멀티 클라우드, GUI 필요, 고급 기능 (Policy as Code)

**S3 Backend vs Consul Backend**:
- 언제 S3 Backend 사용: AWS 환경, 간단한 설정, 낮은 비용
- 언제 Consul Backend 사용: 온프레미스, 서비스 디스커버리 통합

**선택 기준 표**:
| 기준 | Local Backend | S3 Backend | Terraform Cloud | Consul Backend |
|------|---------------|------------|-----------------|----------------|
| **비용** | 무료 | S3 요금 (~$0.01/월) | $20/user/월 | 서버 운영 비용 |
| **팀 협업** | ❌ 불가능 | ✅ 가능 | ✅ 가능 | ✅ 가능 |
| **State Locking** | ❌ 없음 | ✅ DynamoDB | ✅ 내장 | ✅ 내장 |
| **설정 복잡도** | 낮음 | 중간 | 낮음 | 높음 |
| **보안** | 로컬 파일 | ✅ 암호화 | ✅ 암호화 | ✅ 암호화 |
| **버전 관리** | Git (비권장) | ✅ S3 Versioning | ✅ 내장 | ✅ 내장 |
| **적합한 규모** | 개인 | 소~대규모 | 중~대규모 | 대규모 |


### 5. 장단점 분석 - 3분

**장점**:
- ✅ **팀 협업 가능**: 모든 팀원이 동일한 State 사용
- ✅ **동시 수정 방지**: DynamoDB Lock으로 충돌 방지
- ✅ **State 유실 방지**: S3 Versioning으로 히스토리 보관
- ✅ **보안 강화**: 암호화 및 IAM 접근 제어
- ✅ **낮은 비용**: S3 + DynamoDB 월 $0.01~$0.10 수준
- ✅ **CI/CD 통합**: GitHub Actions 등에서 쉽게 사용

**단점/제약사항**:
- ⚠️ **초기 설정 필요**: S3 Bucket, DynamoDB Table 먼저 생성
- ⚠️ **AWS 의존성**: AWS 계정 및 자격증명 필요
- ⚠️ **네트워크 필요**: 인터넷 연결 없으면 작업 불가
- ⚠️ **Lock 해제 실패**: 비정상 종료 시 수동 Lock 해제 필요
  ```bash
  # Lock이 걸린 채로 남아있을 때
  terraform force-unlock <LOCK_ID>
  ```

**대안**:
- 간단한 개인 프로젝트: Local Backend 사용
- 멀티 클라우드: Terraform Cloud 고려
- 온프레미스: Consul Backend 고려


### 6. 비용 구조 💰 - 5분

**과금 방식**:

**S3 Bucket**:
- 스토리지: $0.025/GB/월 (첫 50TB)
- PUT 요청: $0.005/1,000 요청
- GET 요청: $0.0004/1,000 요청

**DynamoDB Table**:
- On-Demand 모드: $1.25/백만 쓰기, $0.25/백만 읽기
- 또는 Provisioned 모드: 최소 $0.00065/시간 (1 RCU + 1 WCU)

**프리티어 혜택** (12개월):
- S3: 5GB 스토리지, 20,000 GET, 2,000 PUT
- DynamoDB: 25GB 스토리지, 25 RCU, 25 WCU

**비용 최적화 팁**:
1. **S3 Lifecycle**: 오래된 State 버전 자동 삭제 (90일 이상)
2. **DynamoDB On-Demand**: 사용량 적으면 Provisioned보다 저렴
3. **State 크기 최소화**: 불필요한 리소스 제거
4. **단일 Backend**: 여러 프로젝트가 같은 Bucket 공유 (Key만 다르게)

**예상 비용 (ap-northeast-2)**:
| 항목 | 사용량 | 월 비용 |
|------|--------|---------|
| S3 스토리지 | 10MB State 파일 | $0.0003 |
| S3 요청 | 100 PUT + 1,000 GET | $0.0009 |
| DynamoDB | On-Demand (100 Lock) | $0.0002 |
| **합계** | | **$0.0014 (~₩2)** |

**실제 사례**:
- 10명 팀, 하루 50회 apply: 월 $0.05
- 100개 프로젝트 관리: 월 $0.50


### 7. 최신 업데이트 🆕 - 2분

**2024년 주요 변경사항**:
- **Terraform 1.6+**: S3 Backend에서 `skip_metadata_api_check` 옵션 추가
- **S3 Express One Zone**: 초고속 State 액세스 지원 (10배 빠름)
- **DynamoDB 개선**: Lock 타임아웃 자동 조정 기능

**2025년 예정**:
- **State 암호화 강화**: KMS 키 자동 로테이션
- **Multi-Region Backend**: 여러 리전에 State 복제

**Deprecated 기능**:
- **S3 Legacy 인증**: `access_key`/`secret_key` 직접 지정 방식 (IAM Role 권장)

**참조**: [Terraform S3 Backend 문서](https://developer.hashicorp.com/terraform/language/settings/backends/s3) (2024.11 업데이트)


### 8. 잘 사용하는 방법 ✅ - 3분

**베스트 프랙티스**:
1. **Backend 설정 분리**: `backend.tf` 파일로 분리
   ```hcl
   # backend.tf
   terraform {
     backend "s3" {
       bucket = "my-terraform-state"
       key    = "prod/terraform.tfstate"
       region = "ap-northeast-2"
     }
   }
   ```

2. **환경별 Key 분리**: 환경마다 다른 State 파일
   ```
   dev/terraform.tfstate
   staging/terraform.tfstate
   prod/terraform.tfstate
   ```

3. **S3 Versioning 활성화**: State 히스토리 보관
   ```hcl
   resource "aws_s3_bucket_versioning" "terraform_state" {
     bucket = aws_s3_bucket.terraform_state.id
     versioning_configuration {
       status = "Enabled"
     }
   }
   ```

4. **암호화 필수**: 민감한 정보 보호
   ```hcl
   terraform {
     backend "s3" {
       encrypt = true  # 필수!
     }
   }
   ```

5. **IAM Role 사용**: Access Key 대신 IAM Role
   ```hcl
   # CI/CD에서
   terraform {
     backend "s3" {
       role_arn = "arn:aws:iam::123456789012:role/TerraformRole"
     }
   }
   ```

**실무 팁**:
- **State 백업**: 중요한 변경 전 수동 백업
  ```bash
  terraform state pull > backup.tfstate
  ```
- **Lock 확인**: 누가 작업 중인지 확인
  ```bash
  aws dynamodb get-item \
    --table-name terraform-locks \
    --key '{"LockID":{"S":"my-bucket/prod/terraform.tfstate-md5"}}'
  ```


### 9. 잘못 사용하는 방법 ❌ - 3분

**흔한 실수**:
1. **Backend 설정 없이 팀 작업**: 각자 로컬 State 사용 → 리소스 중복 생성
2. **DynamoDB Table 없이 사용**: Lock 없이 동시 수정 → State 충돌
3. **암호화 미설정**: `encrypt = false` → 민감한 정보 노출
4. **Versioning 미활성화**: State 손상 시 복구 불가
5. **Git에 State 커밋**: `.gitignore` 누락 → 민감 정보 유출

**안티 패턴**:
- **Backend 설정 하드코딩**: 환경마다 코드 수정
  ```hcl
  # ❌ 나쁜 예
  terraform {
    backend "s3" {
      bucket = "prod-terraform-state"  # 하드코딩
    }
  }
  
  # ✅ 좋은 예: Backend 설정 파일 분리
  # backend-dev.hcl
  bucket = "dev-terraform-state"
  key    = "dev/terraform.tfstate"
  
  # 사용: terraform init -backend-config=backend-dev.hcl
  ```

- **Lock 강제 해제 남용**: 정상 작업 중인데 해제
  ```bash
  # ❌ 확인 없이 해제
  terraform force-unlock <LOCK_ID>
  
  # ✅ 팀원 확인 후 해제
  # 1. 누가 작업 중인지 확인
  # 2. 팀원에게 연락
  # 3. 확인 후 해제
  ```

**보안 취약점**:
- **Public S3 Bucket**: State 파일 공개 노출
- **IAM 권한 과다**: 모든 사람이 State 수정 가능
- **KMS 키 미사용**: 기본 암호화만 사용


### 10. 구성 요소 상세 - 5분

**주요 구성 요소**:

**1. S3 Bucket (State 저장소)**:
- **역할**: Terraform State 파일 중앙 저장
- **필수 설정**:
  - Versioning: 활성화 (State 히스토리)
  - Encryption: AES-256 또는 KMS
  - Bucket Policy: IAM 기반 접근 제어
  - Lifecycle: 오래된 버전 자동 삭제

**2. DynamoDB Table (Lock 관리)**:
- **역할**: 동시 수정 방지
- **필수 설정**:
  - Hash Key: `LockID` (String 타입)
  - Billing Mode: On-Demand (사용량 적음)
- **Lock 정보**:
  ```json
  {
    "LockID": "my-bucket/prod/terraform.tfstate-md5",
    "Info": "{\"ID\":\"abc123\",\"Operation\":\"OperationTypeApply\",\"Who\":\"user@example.com\",\"Version\":\"1.6.0\",\"Created\":\"2024-11-18T05:00:00Z\",\"Path\":\"prod/terraform.tfstate\"}"
  }
  ```

**3. Backend 설정 (terraform 블록)**:
```hcl
terraform {
  backend "s3" {
    # 필수 설정
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "ap-northeast-2"
    
    # 보안 설정
    encrypt        = true
    kms_key_id     = "arn:aws:kms:..."  # 선택
    
    # Lock 설정
    dynamodb_table = "terraform-locks"
    
    # 고급 설정
    workspace_key_prefix = "workspaces"  # Workspace 사용 시
    role_arn             = "arn:aws:iam::..."  # IAM Role
  }
}
```

**설정 옵션**:
- **bucket**: S3 Bucket 이름
- **key**: State 파일 경로 (프로젝트/환경별 분리)
- **region**: S3 Bucket 리전
- **encrypt**: 암호화 활성화 (true 권장)
- **dynamodb_table**: Lock 테이블 이름
- **workspace_key_prefix**: Workspace 사용 시 Key 접두사

**의존성**:
- **AWS 자격증명**: IAM User 또는 IAM Role
- **네트워크**: S3/DynamoDB API 접근 가능
- **권한**: S3 읽기/쓰기, DynamoDB 읽기/쓰기


### 11. 공식 문서 링크 (필수 5개)

**⚠️ 학생들이 직접 확인해야 할 공식 문서**:
- 📘 [Terraform Backend 개요](https://developer.hashicorp.com/terraform/language/settings/backends/configuration)
- 📗 [S3 Backend 사용자 가이드](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
- 📙 [State Locking 레퍼런스](https://developer.hashicorp.com/terraform/language/state/locking)
- 📕 [AWS S3 요금](https://aws.amazon.com/s3/pricing/)
- 🆕 [Terraform 1.6 최신 업데이트](https://github.com/hashicorp/terraform/releases/tag/v1.6.0)

---

## 💭 함께 생각해보기

### 🤝 페어 토론 (5분)
**토론 주제**:
1. **Local vs Remote**: 여러분의 프로젝트에서 Remote State가 필요한가요?
2. **보안 고려사항**: State 파일에 어떤 민감한 정보가 포함될 수 있을까요?
3. **팀 협업**: 동시에 여러 명이 작업할 때 어떤 문제가 생길 수 있을까요?

### 🎯 전체 공유 (3분)
- **인사이트 공유**: Remote State의 가장 큰 장점은?
- **질문 수집**: 이해가 어려운 부분
- **다음 연결**: Session 2 (Kubernetes 기초)와의 연결

### 💡 이해도 체크 질문
- ✅ "Remote State와 Local State의 차이를 설명할 수 있나요?"
- ✅ "DynamoDB Table이 왜 필요한지 이해했나요?"
- ✅ "팀 협업 시 State 관리 전략을 세울 수 있나요?"

---

## 🔑 핵심 키워드

- **Remote State**: 중앙 집중식 State 저장소
- **S3 Backend**: AWS S3를 State 저장소로 사용
- **State Locking**: DynamoDB로 동시 수정 방지
- **Versioning**: S3 Versioning으로 State 히스토리 보관
- **Encryption**: State 파일 암호화 (AES-256, KMS)
- **IAM Role**: Access Key 대신 IAM Role 사용
- **Backend Configuration**: terraform 블록에 Backend 설정
- **State Migration**: 로컬 State를 Remote State로 이전

---

## 📝 세션 마무리

### ✅ 오늘 세션 성과
- [ ] Remote State의 필요성 이해
- [ ] S3 Backend 설정 방법 습득
- [ ] State Locking 메커니즘 이해
- [ ] 팀 협업 전략 수립 능력

### 🎯 다음 세션 준비
- **Session 2**: Kubernetes 기초 개념
- **연계 내용**: EKS에서 Terraform으로 Kubernetes 리소스 관리

---

<div align="center">

**☁️ Remote State** • **🔒 안전한 협업** • **📦 중앙 집중식 관리**

*팀 협업의 시작, Remote State Backend*

</div>
