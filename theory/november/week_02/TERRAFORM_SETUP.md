# Terraform 설치 및 AWS 설정 가이드

<div align="center">

**🔧 Terraform 설치** • **🔑 AWS 인증** • **✅ 환경 검증**

*Terraform을 사용하기 위한 완벽한 설정 가이드*

</div>

---

## 📋 목차
1. [Terraform 설치](#1-terraform-설치)
2. [AWS CLI 설치](#2-aws-cli-설치)
3. [AWS Access Key 생성](#3-aws-access-key-생성)
4. [AWS 인증 설정](#4-aws-인증-설정)
5. [환경 검증](#5-환경-검증)
6. [보안 주의사항](#6-보안-주의사항)

---

## 1. Terraform 설치

### Windows

**방법 1: Chocolatey 사용 (권장)**
```powershell
# PowerShell을 관리자 권한으로 실행
choco install terraform

# 설치 확인
terraform version
```

**방법 2: 수동 설치**
1. [Terraform 다운로드 페이지](https://www.terraform.io/downloads) 접속
2. Windows AMD64 버전 다운로드
3. ZIP 파일 압축 해제
4. `terraform.exe`를 `C:\Program Files\Terraform\` 폴더에 복사
5. 환경 변수 PATH에 추가:
   - 시스템 속성 → 환경 변수 → Path 편집
   - `C:\Program Files\Terraform` 추가

### macOS

**방법 1: Homebrew 사용 (권장)**
```bash
# Homebrew로 설치
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# 설치 확인
terraform version
```

**방법 2: 수동 설치**
```bash
# 다운로드
wget https://releases.hashicorp.com/terraform/1.9.0/terraform_1.9.0_darwin_amd64.zip

# 압축 해제
unzip terraform_1.9.0_darwin_amd64.zip

# 실행 파일 이동
sudo mv terraform /usr/local/bin/

# 권한 설정
sudo chmod +x /usr/local/bin/terraform

# 설치 확인
terraform version
```

### Linux (Ubuntu/Debian)

```bash
# HashiCorp GPG 키 추가
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# HashiCorp 리포지토리 추가
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# 패키지 업데이트 및 설치
sudo apt update
sudo apt install terraform

# 설치 확인
terraform version
```

---

## 2. AWS CLI 설치

### Windows

```powershell
# MSI 설치 프로그램 다운로드 및 실행
# https://awscli.amazonaws.com/AWSCLIV2.msi

# 설치 확인
aws --version
```

### macOS

```bash
# Homebrew로 설치
brew install awscli

# 설치 확인
aws --version
```

### Linux

```bash
# AWS CLI v2 설치
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# 설치 확인
aws --version
```

---

## 3. AWS Access Key 생성

### ⚠️ 중요: IAM User 사용 (Root 계정 사용 금지)

**Step 1: IAM User 생성**

1. AWS Console 로그인
2. IAM 서비스로 이동
3. **Users** → **Create user** 클릭
4. User name: `terraform-user` 입력
5. **Next** 클릭

**Step 2: 권한 설정**

1. **Attach policies directly** 선택
2. 다음 정책 선택:
   - `AmazonEC2FullAccess`
   - `AmazonS3FullAccess`
   - `AmazonSQSFullAccess`
   - `AmazonSNSFullAccess`
   - `AmazonRDSFullAccess`
   - `AmazonVPCFullAccess`
   - `IAMFullAccess` (Terraform이 IAM 리소스 관리 시 필요)
3. **Next** → **Create user** 클릭

**Step 3: Access Key 생성**

1. 생성된 User 클릭
2. **Security credentials** 탭 선택
3. **Create access key** 클릭
4. **Use case**: **Command Line Interface (CLI)** 선택
5. 확인 체크박스 선택 → **Next**
6. Description: `Terraform CLI` 입력
7. **Create access key** 클릭

**Step 4: Access Key 저장 (중요!)**

```
⚠️ 이 화면에서만 Secret Access Key를 확인할 수 있습니다!
   반드시 안전한 곳에 저장하세요!

Access Key ID: AKIAIOSFODNN7EXAMPLE
Secret Access Key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

- **Download .csv file** 클릭하여 저장
- 또는 메모장에 복사하여 안전한 곳에 보관

---

## 4. AWS 인증 설정

### 방법 1: AWS CLI Configure (권장)

```bash
# AWS CLI 설정
aws configure

# 입력 프롬프트
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: ap-northeast-2
Default output format [None]: json
```

**설정 파일 위치**:
- Windows: `C:\Users\<사용자명>\.aws\credentials`
- macOS/Linux: `~/.aws/credentials`

**설정 파일 내용**:
```ini
[default]
aws_access_key_id = AKIAIOSFODNN7EXAMPLE
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

### 방법 2: 환경 변수 (임시 사용)

**Windows (PowerShell)**:
```powershell
$env:AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
$env:AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
$env:AWS_DEFAULT_REGION="ap-northeast-2"
```

**macOS/Linux (Bash)**:
```bash
export AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
export AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
export AWS_DEFAULT_REGION="ap-northeast-2"
```

### 방법 3: Terraform Provider에 직접 설정 (비추천)

```hcl
# provider.tf
provider "aws" {
  region     = "ap-northeast-2"
  access_key = "AKIAIOSFODNN7EXAMPLE"  # ❌ 비추천: 코드에 노출
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"  # ❌ 비추천
}
```

**⚠️ 절대 하지 마세요!**
- Git에 커밋되면 보안 사고!
- 방법 1 (AWS CLI Configure) 사용 권장

---

## 5. 환경 검증

### Step 1: AWS CLI 테스트

```bash
# 현재 인증 정보 확인
aws sts get-caller-identity

# 예상 출력
{
    "UserId": "AIDAI...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/terraform-user"
}
```

### Step 2: Terraform 테스트

**테스트 디렉토리 생성**:
```bash
mkdir terraform-test
cd terraform-test
```

**간단한 Terraform 코드 작성**:
```hcl
# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

# 테스트용 S3 버킷
resource "aws_s3_bucket" "test" {
  bucket = "my-terraform-test-bucket-${random_id.bucket_suffix.hex}"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

output "bucket_name" {
  value = aws_s3_bucket.test.id
}
```

**Terraform 실행**:
```bash
# 1. 초기화
terraform init

# 예상 출력
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.x.x...
Terraform has been successfully initialized!

# 2. 실행 계획 확인
terraform plan

# 예상 출력
Terraform will perform the following actions:
  # aws_s3_bucket.test will be created
  + resource "aws_s3_bucket" "test" {
      + bucket = "my-terraform-test-bucket-xxxxx"
      ...
    }
Plan: 1 to add, 0 to change, 0 to destroy.

# 3. 적용 (실제 생성)
terraform apply

# "yes" 입력
# 예상 출력
aws_s3_bucket.test: Creating...
aws_s3_bucket.test: Creation complete after 2s
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

# 4. 정리 (삭제)
terraform destroy

# "yes" 입력
# 예상 출력
aws_s3_bucket.test: Destroying...
aws_s3_bucket.test: Destruction complete after 1s
Destroy complete! Resources: 1 destroyed.
```

### ✅ 성공 기준

- [ ] `terraform version` 명령어 실행 성공
- [ ] `aws --version` 명령어 실행 성공
- [ ] `aws sts get-caller-identity` 실행 성공
- [ ] `terraform init` 실행 성공
- [ ] `terraform plan` 실행 성공
- [ ] `terraform apply` 실행 성공
- [ ] AWS Console에서 S3 버킷 생성 확인
- [ ] `terraform destroy` 실행 성공

---

## 6. 보안 주의사항

### ⚠️ 절대 하지 말아야 할 것

**1. Access Key를 코드에 하드코딩**
```hcl
# ❌ 절대 금지
provider "aws" {
  access_key = "AKIAIOSFODNN7EXAMPLE"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}
```

**2. Access Key를 Git에 커밋**
```bash
# ❌ 절대 금지
git add .aws/credentials
git commit -m "Add AWS credentials"  # 보안 사고!
```

**3. Root 계정 Access Key 사용**
```
❌ Root 계정은 모든 권한을 가지고 있어 매우 위험!
✅ 반드시 IAM User 사용
```

### ✅ 반드시 해야 할 것

**1. .gitignore 설정**
```bash
# .gitignore
.terraform/
*.tfstate
*.tfstate.*
.terraform.lock.hcl
terraform.tfvars
.aws/
*.pem
*.key
```

**2. Access Key 정기 교체**
```bash
# 90일마다 Access Key 교체 권장
# IAM Console → Users → Security credentials → Create access key
```

**3. MFA (Multi-Factor Authentication) 활성화**
```
IAM User에 MFA 설정 권장
→ 보안 강화
```

**4. 최소 권한 원칙**
```
필요한 권한만 부여
예: S3만 사용한다면 AmazonS3FullAccess만 부여
```

### 🔒 Access Key 유출 시 대응

**즉시 조치**:
1. AWS Console → IAM → Users → Security credentials
2. 유출된 Access Key **즉시 비활성화** (Deactivate)
3. 새로운 Access Key 생성
4. 로컬 설정 업데이트 (`aws configure`)
5. Git 히스토리에서 완전 삭제 (git filter-branch 또는 BFG Repo-Cleaner)

**예방**:
- GitHub에 커밋 전 `git-secrets` 도구 사용
- AWS에서 자동 스캔 및 알림 (AWS Secrets Manager)

---

## 🎯 다음 단계

### Lab 1 준비 완료!
이제 다음 Lab에서 Terraform으로 실제 AWS 리소스를 생성할 준비가 되었습니다:
- SQS Queue 생성
- SNS Topic 생성
- Lambda Function 배포

### 추가 학습 자료
- [Terraform AWS Provider 문서](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CLI 사용자 가이드](https://docs.aws.amazon.com/cli/latest/userguide/)
- [IAM 베스트 프랙티스](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

---

## 🆘 트러블슈팅

### 문제 1: terraform: command not found

**원인**: PATH 환경 변수에 Terraform이 없음

**해결**:
```bash
# Windows
echo $env:PATH
# Terraform 경로가 있는지 확인

# macOS/Linux
echo $PATH
which terraform
```

### 문제 2: Error: No valid credential sources found

**원인**: AWS 인증 정보가 설정되지 않음

**해결**:
```bash
# AWS CLI 재설정
aws configure

# 또는 환경 변수 확인
echo $AWS_ACCESS_KEY_ID
echo $AWS_SECRET_ACCESS_KEY
```

### 문제 3: Error: UnauthorizedOperation

**원인**: IAM User에 필요한 권한이 없음

**해결**:
1. AWS Console → IAM → Users
2. 해당 User의 Permissions 확인
3. 필요한 Policy 추가

### 문제 4: Error: BucketAlreadyExists

**원인**: S3 버킷 이름이 전역적으로 중복

**해결**:
```hcl
# 고유한 버킷 이름 사용
resource "aws_s3_bucket" "test" {
  bucket = "my-unique-bucket-name-${random_id.suffix.hex}"
}
```

---

<div align="center">

**🔧 설치 완료** • **🔑 인증 설정** • **✅ 검증 성공** • **🚀 Lab 준비 완료**

*이제 Terraform으로 AWS 인프라를 코드로 관리할 준비가 되었습니다!*

</div>
