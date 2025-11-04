# Week 2 Day 3 Lab 1: Terraform Variables와 환경별 인프라 관리

<div align="center">

**🔧 Variable 활용** • **🌍 환경 분리** • **🔄 재사용성**

*하드코딩에서 Variable 기반 인프라로 전환*

</div>

---

## 🕘 Lab 정보
**시간**: 12:00-13:00 (60분)
**목표**: Variable과 for_each를 활용한 프로그래밍적 인프라 관리
**방식**: Terraform 코드 작성 및 환경별 배포

## 🎯 학습 목표

### 📚 학습 목표
- Variable을 활용한 인프라 코드 재사용
- for_each를 이용한 동적 리소스 생성
- 환경별 설정 분리 (dev, prod)
- tfvars 파일을 통한 값 관리

### 🛠️ 구현 목표
- VPC 인프라를 Variable로 정의
- 여러 Subnet을 for_each로 생성
- Dev/Prod 환경 분리 배포

---

## 🏗️ 전체 아키텍처

### 📐 인프라 구조
```
VPC (10.0.0.0/16)
├── Public Subnets
│   ├── 10.0.1.0/24 (ap-northeast-2a)
│   └── 10.0.2.0/24 (ap-northeast-2b)
├── Private Subnets
│   ├── 10.0.11.0/24 (ap-northeast-2a)
│   └── 10.0.12.0/24 (ap-northeast-2b)
├── Internet Gateway
└── Route Tables
    ├── Public RT → IGW
    └── Private RT → Local
```

### 🔗 참조 Session
**이전 Day Session** (기반 지식):
- [November Week 2 Day 2 Session 3: Terraform 기본 명령어](../../../november/week_02/day2/session_3.md) - init, plan, apply, destroy
- [November Week 2 Day 2 Lab 1: VPC 네트워크 구성](../../../november/week_02/day2/lab_1.md) - 하드코딩된 인프라 구축

**당일 Session** (심화 내용):
- [November Week 2 Day 3 Session 3: Terraform Variable & Output](../../../november/week_02/day3/session_3.md) - Variable, Output, tfvars

**이 Lab에서 추가로 배우는 내용**:
- **for_each**: 동적 리소스 생성 (Lab에서 처음 소개)
- **locals**: List를 Map으로 변환
- Day 2 Lab 1의 하드코딩된 코드를 Variable + for_each로 리팩토링
- 환경별 설정 분리 (dev.tfvars, prod.tfvars)

---

## 🛠️ Step 1: 프로젝트 구조 생성 (5분)

### 📋 디렉토리 생성
```bash
mkdir -p ~/terraform-lab/day3-lab1
cd ~/terraform-lab/day3-lab1
```

### 📝 파일 구조
```
day3-lab1/
├── variables.tf      # Variable 정의
├── dev.tfvars       # Dev 환경 값
├── prod.tfvars      # Prod 환경 값
├── main.tf          # 리소스 정의
├── outputs.tf       # Output 정의
└── backend.tf       # S3 Backend
```

---

## 🛠️ Step 2: Variable 정의 (10분)

### 📝 variables.tf 작성
```bash
cat <<'EOF' > variables.tf
# VPC 설정
variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "VPC 이름"
  type        = string
}

# 환경 설정
variable "environment" {
  description = "환경 (dev, staging, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "환경은 dev, staging, prod 중 하나여야 합니다."
  }
}

# AZ 설정
variable "azs" {
  description = "사용할 Availability Zones"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2b"]
}

# Subnet 설정
variable "public_subnet_cidrs" {
  description = "Public Subnet CIDR 블록 목록"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private Subnet CIDR 블록 목록"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

# 태그 설정
variable "common_tags" {
  description = "모든 리소스에 적용할 공통 태그"
  type        = map(string)
  default = {
    Project   = "Terraform-Lab"
    ManagedBy = "Terraform"
  }
}
EOF
```

### 💡 Variable 설명
- **vpc_cidr**: VPC IP 범위 정의
- **environment**: 환경 구분 (validation으로 값 제한)
- **azs**: 고가용성을 위한 다중 AZ
- **subnet_cidrs**: 리스트로 여러 Subnet 정의
- **common_tags**: 모든 리소스에 공통 태그 적용

---

## 🛠️ Step 3: 환경별 설정 파일 (10분)

### 📝 dev.tfvars 작성
```bash
cat <<'EOF' > dev.tfvars
vpc_name    = "dev-vpc"
environment = "dev"

# Dev는 2개 AZ만 사용
azs = ["ap-northeast-2a", "ap-northeast-2b"]

public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

common_tags = {
  Project     = "Terraform-Lab"
  Environment = "Development"
  ManagedBy   = "Terraform"
  CostCenter  = "Dev-Team"
}
EOF
```

### 📝 prod.tfvars 작성
```bash
cat <<'EOF' > prod.tfvars
vpc_name    = "prod-vpc"
environment = "prod"

# Prod는 3개 AZ 사용 (고가용성)
azs = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]

public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

common_tags = {
  Project     = "Terraform-Lab"
  Environment = "Production"
  ManagedBy   = "Terraform"
  CostCenter  = "Prod-Team"
  Compliance  = "Required"
}
EOF
```

### 💡 환경별 차이점
- **Dev**: 2 AZ, 간단한 태그
- **Prod**: 3 AZ (고가용성), 상세한 태그 (Compliance 등)

---

## 🛠️ Step 4: 리소스 정의 (for_each 활용) (15분)

### 📝 main.tf 작성
```bash
cat <<'EOF' > main.tf
terraform {
  required_version = ">= 1.0"
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

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.common_tags,
    {
      Name        = var.vpc_name
      Environment = var.environment
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.vpc_name}-igw"
      Environment = var.environment
    }
  )
}

# Public Subnets (for_each 사용)
locals {
  # List를 Map으로 변환 (for_each는 Map 또는 Set 필요)
  public_subnets_map = {
    for idx, cidr in var.public_subnet_cidrs :
    "public-${idx}" => {
      cidr = cidr
      az   = var.azs[idx]
    }
  }
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets_map

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.vpc_name}-${each.key}"
      Environment = var.environment
      Type        = "Public"
    }
  )
}

# Private Subnets (for_each 사용)
locals {
  private_subnets_map = {
    for idx, cidr in var.private_subnet_cidrs :
    "private-${idx}" => {
      cidr = cidr
      az   = var.azs[idx]
    }
  }
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets_map

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.vpc_name}-${each.key}"
      Environment = var.environment
      Type        = "Private"
    }
  )
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.vpc_name}-public-rt"
      Environment = var.environment
    }
  )
}

# Public Route Table Association (for_each 사용)
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.vpc_name}-private-rt"
      Environment = var.environment
    }
  )
}

# Private Route Table Association (for_each 사용)
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
EOF
```

### 💡 for_each 핵심 포인트
1. **locals로 Map 변환**: List → Map 변환 (for_each는 Map/Set 필요)
2. **each.key, each.value**: 각 항목 접근
3. **동적 리소스 생성**: Subnet 개수만큼 자동 생성
4. **태그 자동화**: merge()로 공통 태그 + 개별 태그

---

## 🛠️ Step 5: Output 정의 (5분)

### 📝 outputs.tf 작성
```bash
cat <<'EOF' > outputs.tf
# VPC 정보
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR 블록"
  value       = aws_vpc.main.cidr_block
}

# Public Subnet 정보
output "public_subnet_ids" {
  description = "Public Subnet ID 목록"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "public_subnet_cidrs" {
  description = "Public Subnet CIDR 목록"
  value       = [for subnet in aws_subnet.public : subnet.cidr_block]
}

# Private Subnet 정보
output "private_subnet_ids" {
  description = "Private Subnet ID 목록"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "private_subnet_cidrs" {
  description = "Private Subnet CIDR 목록"
  value       = [for subnet in aws_subnet.private : subnet.cidr_block]
}

# Internet Gateway
output "igw_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

# 환경 정보
output "environment" {
  description = "배포된 환경"
  value       = var.environment
}
EOF
```

### 💡 Output for 표현식
- `[for subnet in aws_subnet.public : subnet.id]`: 모든 Public Subnet ID 추출
- 리스트 형태로 반환하여 다른 모듈에서 활용 가능

---

## 🛠️ Step 6: Backend 설정 (5분)

### 📝 backend.tf 작성
```bash
cat <<'EOF' > backend.tf
terraform {
  backend "s3" {
    bucket         = "terraform-state-sunny-1762228054"
    key            = "week2/day3/lab1/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
EOF
```

---

## 🛠️ Step 7: Dev 환경 배포 (5분)

### 📝 Terraform 초기화
```bash
terraform init
```

### 📝 Dev 환경 Plan
```bash
terraform plan -var-file=dev.tfvars
```

**예상 결과**:
```
Plan: 12 add, 0 change, 0 destroy.

Changes to Outputs:
  + environment         = "dev"
  + public_subnet_ids   = [
      + (known after apply),
      + (known after apply),
    ]
  + vpc_id              = (known after apply)
```

### 📝 Dev 환경 Apply
```bash
terraform apply -var-file=dev.tfvars
```

### ✅ 검증
```bash
# VPC 확인
aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=dev-vpc" \
  --query 'Vpcs[0].[VpcId,CidrBlock,Tags[?Key==`Environment`].Value|[0]]' \
  --output table

# Subnet 확인
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$(terraform output -raw vpc_id)" \
  --query 'Subnets[*].[SubnetId,CidrBlock,AvailabilityZone,Tags[?Key==`Name`].Value|[0]]' \
  --output table
```

---

## 🛠️ Step 8: Prod 환경 배포 (5분)

### 📝 Workspace 생성 (선택)
```bash
# Workspace로 환경 분리
terraform workspace new prod
terraform workspace select prod
```

### 📝 Prod 환경 Plan
```bash
terraform plan -var-file=prod.tfvars
```

**예상 결과**:
```
Plan: 15 add, 0 change, 0 destroy.

Changes to Outputs:
  + environment         = "prod"
  + public_subnet_ids   = [
      + (known after apply),
      + (known after apply),
      + (known after apply),  # 3개 AZ
    ]
```

### 📝 Prod 환경 Apply
```bash
terraform apply -var-file=prod.tfvars
```

---

## ✅ 실습 체크포인트

### ✅ Variable 활용
- [ ] variables.tf에 모든 Variable 정의
- [ ] validation으로 입력 값 검증
- [ ] dev.tfvars, prod.tfvars 환경별 분리

### ✅ for_each 활용
- [ ] locals로 List → Map 변환
- [ ] Subnet을 for_each로 동적 생성
- [ ] Route Table Association도 for_each 적용

### ✅ 환경별 배포
- [ ] Dev 환경 배포 (2 AZ)
- [ ] Prod 환경 배포 (3 AZ)
- [ ] Output으로 리소스 정보 확인

### ✅ 코드 품질
- [ ] 하드코딩 제거 (모든 값 Variable화)
- [ ] 태그 자동화 (merge 함수 활용)
- [ ] 재사용 가능한 구조

---

## 🔍 트러블슈팅

### 문제 1: for_each는 Map 또는 Set만 가능
**증상**:
```
Error: Invalid for_each argument
for_each argument must be a map, or set of strings
```

**해결**:
```hcl
# ❌ 잘못된 방법
resource "aws_subnet" "public" {
  for_each = var.public_subnet_cidrs  # List는 불가
  ...
}

# ✅ 올바른 방법
locals {
  public_subnets_map = {
    for idx, cidr in var.public_subnet_cidrs :
    "public-${idx}" => {
      cidr = cidr
      az   = var.azs[idx]
    }
  }
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets_map  # Map 사용
  ...
}
```

### 문제 2: Workspace 간 State 충돌
**증상**:
```
Error: VPC already exists
```

**해결**:
```bash
# Workspace 확인
terraform workspace list

# 올바른 Workspace 선택
terraform workspace select dev
```

---

## 🧹 리소스 정리

### Dev 환경 정리
```bash
terraform workspace select dev
terraform destroy -var-file=dev.tfvars
```

### Prod 환경 정리
```bash
terraform workspace select prod
terraform destroy -var-file=prod.tfvars
```

### Workspace 삭제
```bash
terraform workspace select default
terraform workspace delete dev
terraform workspace delete prod
```

---

## 💡 Lab 회고

### 🤝 페어 회고 (5분)
1. **Variable의 장점**: 하드코딩 대비 어떤 점이 좋았나요?
2. **for_each 활용**: 반복 코드를 줄이는 효과를 느꼈나요?
3. **환경 분리**: dev/prod 분리가 실무에서 어떻게 활용될까요?

### 📊 학습 성과
- **Variable 활용**: 재사용 가능한 인프라 코드 작성
- **for_each 마스터**: 동적 리소스 생성 능력 습득
- **환경 관리**: tfvars로 환경별 설정 분리
- **프로그래밍적 사고**: 인프라를 코드로 관리하는 사고방식

### 🔗 다음 Lab 준비
- **Lab 2**: Module 작성 및 재사용
- **연계 내용**: 오늘 작성한 VPC 코드를 Module로 변환

---

<div align="center">

**🔧 Variable 활용** • **🔄 for_each 마스터** • **🌍 환경 분리** • **📦 재사용성**

*하드코딩에서 프로그래밍적 인프라 관리로*

</div>
