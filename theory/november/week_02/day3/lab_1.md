# November Week 2 Day 3 Lab 1: Terraform Variable로 VPC 확장

<div align="center">

**📝 Variable** • **🔄 for_each** • **🌐 Multi-Subnet** • **🚀 확장성**

*Terraform Variable과 반복문으로 유연한 인프라 구축*

</div>

---

## 🕘 Lab 정보
**시간**: 11:20-12:20 (60분)
**목표**: Day 2 Lab 1을 Variable과 for_each로 확장
**방식**: 기존 코드 리팩토링 + 새로운 기능 추가
**사전 준비**: Day 2 Lab 1 완료 (S3 Backend 설정 완료)

## 🎯 학습 목표

### 📚 이해 목표
- Variable로 하드코딩 제거
- for_each로 반복 리소스 생성
- 환경별 설정 분리 (dev/prod)
- 재사용 가능한 코드 작성

### 🛠️ 구현 목표
- Variable 파일 분리 (variables.tf)
- tfvars로 환경별 설정 (dev.tfvars, prod.tfvars)
- for_each로 Subnet 동적 생성
- Output으로 정보 추출

---

## 🏗️ 확장할 아키텍처

### 📐 기존 vs 확장

**기존 (Day 2 Lab 1)**:
```
VPC (10.0.0.0/16) - 하드코딩
├── AZ-A: Public (10.0.1.0/24) - 하드코딩
├── AZ-A: Private (10.0.11.0/24) - 하드코딩
├── AZ-B: Public (10.0.2.0/24) - 하드코딩
└── AZ-B: Private (10.0.12.0/24) - 하드코딩
```

**확장 (Day 3 Lab 1)**:
```
VPC (Variable) - 환경별 다른 CIDR
├── Subnets (for_each) - 리스트로 동적 생성
│   ├── Public Subnets (Variable)
│   └── Private Subnets (Variable)
├── Route Tables (for_each)
└── Outputs (자동 추출)

환경별 설정:
- dev.tfvars: 10.0.0.0/16, 2 AZ
- prod.tfvars: 10.1.0.0/16, 3 AZ
```

---

## 🛠️ Step 1: 프로젝트 구조 변경 (5분)

### 디렉토리 구조

```bash
# 기존 디렉토리로 이동
cd ~/terraform-lab

# 새로운 구조 생성
mkdir -p day3-lab1
cd day3-lab1

# 파일 구조
# day3-lab1/
# ├── main.tf           # 리소스 정의
# ├── variables.tf      # Variable 선언
# ├── outputs.tf        # Output 정의
# ├── backend.tf        # S3 Backend (Day 2와 동일)
# ├── dev.tfvars        # 개발 환경 설정
# └── prod.tfvars       # 프로덕션 환경 설정
```

---

## 🛠️ Step 2: variables.tf 작성 (10분)

### Variable 선언

```bash
cat > variables.tf << 'EOF'
# 환경 이름
variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# 프로젝트 이름
variable "project_name" {
  type        = string
  description = "Project name for resource naming"
  default     = "terraform-lab"
}

# VPC CIDR 블록
variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

# Public Subnets (리스트)
variable "public_subnets" {
  type = list(object({
    cidr_block        = string
    availability_zone = string
    name              = string
  }))
  description = "List of public subnets"
}

# Private Subnets (리스트)
variable "private_subnets" {
  type = list(object({
    cidr_block        = string
    availability_zone = string
    name              = string
  }))
  description = "List of private subnets"
}

# 공통 태그
variable "common_tags" {
  type        = map(string)
  description = "Common tags for all resources"
  default = {
    ManagedBy = "Terraform"
  }
}
EOF
```

**💡 Variable 설명**:
- `environment`: 환경 이름 (validation으로 검증)
- `vpc_cidr`: VPC CIDR 블록 (validation으로 유효성 검증)
- `public_subnets`: Public Subnet 리스트 (object 타입)
- `private_subnets`: Private Subnet 리스트 (object 타입)
- `common_tags`: 모든 리소스에 적용할 공통 태그

---

## 🛠️ Step 3: dev.tfvars 작성 (5분)

### 개발 환경 설정

```bash
cat > dev.tfvars << 'EOF'
environment  = "dev"
project_name = "terraform-lab"
vpc_cidr     = "10.0.0.0/16"

# Public Subnets (2 AZ)
public_subnets = [
  {
    cidr_block        = "10.0.1.0/24"
    availability_zone = "ap-northeast-2a"
    name              = "public-a"
  },
  {
    cidr_block        = "10.0.2.0/24"
    availability_zone = "ap-northeast-2c"
    name              = "public-c"
  }
]

# Private Subnets (2 AZ)
private_subnets = [
  {
    cidr_block        = "10.0.11.0/24"
    availability_zone = "ap-northeast-2a"
    name              = "private-a"
  },
  {
    cidr_block        = "10.0.12.0/24"
    availability_zone = "ap-northeast-2c"
    name              = "private-c"
  }
]

# 공통 태그
common_tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
  Project     = "Lab"
}
EOF
```

---

## 🛠️ Step 4: prod.tfvars 작성 (5분)

### 프로덕션 환경 설정

```bash
cat > prod.tfvars << 'EOF'
environment  = "prod"
project_name = "terraform-lab"
vpc_cidr     = "10.1.0.0/16"

# Public Subnets (3 AZ - 고가용성)
public_subnets = [
  {
    cidr_block        = "10.1.1.0/24"
    availability_zone = "ap-northeast-2a"
    name              = "public-a"
  },
  {
    cidr_block        = "10.1.2.0/24"
    availability_zone = "ap-northeast-2b"
    name              = "public-b"
  },
  {
    cidr_block        = "10.1.3.0/24"
    availability_zone = "ap-northeast-2c"
    name              = "public-c"
  }
]

# Private Subnets (3 AZ - 고가용성)
private_subnets = [
  {
    cidr_block        = "10.1.11.0/24"
    availability_zone = "ap-northeast-2a"
    name              = "private-a"
  },
  {
    cidr_block        = "10.1.12.0/24"
    availability_zone = "ap-northeast-2b"
    name              = "private-b"
  },
  {
    cidr_block        = "10.1.13.0/24"
    availability_zone = "ap-northeast-2c"
    name              = "private-c"
  }
]

# 공통 태그
common_tags = {
  Environment = "prod"
  ManagedBy   = "Terraform"
  Project     = "Lab"
  CostCenter  = "Engineering"
}
EOF
```

**💡 dev vs prod 차이**:
- **VPC CIDR**: 10.0.0.0/16 vs 10.1.0.0/16 (충돌 방지)
- **AZ 개수**: 2개 vs 3개 (고가용성)
- **태그**: 프로덕션에 CostCenter 추가

---

## 🛠️ Step 5: main.tf 작성 (for_each 활용) (20분)

### Local Values 정의

```bash
cat > main.tf << 'EOF'
# Local Values
locals {
  # 이름 접두사
  name_prefix = "${var.environment}-${var.project_name}"
  
  # 모든 리소스에 적용할 태그
  common_tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      Project     = var.project_name
    }
  )
  
  # Public Subnets를 Map으로 변환 (for_each용)
  public_subnets_map = {
    for idx, subnet in var.public_subnets :
    subnet.name => subnet
  }
  
  # Private Subnets를 Map으로 변환 (for_each용)
  private_subnets_map = {
    for idx, subnet in var.private_subnets :
    subnet.name => subnet
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-vpc"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-igw"
    }
  )
}

# Public Subnets (for_each)
resource "aws_subnet" "public" {
  for_each = local.public_subnets_map
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-${each.value.name}"
      Type = "public"
    }
  )
}

# Private Subnets (for_each)
resource "aws_subnet" "private" {
  for_each = local.private_subnets_map
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-${each.value.name}"
      Type = "private"
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
    local.common_tags,
    {
      Name = "${local.name_prefix}-public-rt"
    }
  )
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-private-rt"
    }
  )
}

# Public Route Table Association (for_each)
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public
  
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Private Route Table Association (for_each)
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private
  
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
EOF
```

**💡 for_each 핵심 포인트**:
1. **Map 변환**: List를 Map으로 변환 (`local.public_subnets_map`)
2. **for_each 사용**: `for_each = local.public_subnets_map`
3. **값 참조**: `each.value.cidr_block`, `each.value.availability_zone`
4. **리소스 참조**: `aws_subnet.public` (Map 형태로 생성됨)

---

## 🛠️ Step 6: outputs.tf 작성 (5분)

### Output 정의

```bash
cat > outputs.tf << 'EOF'
# VPC 정보
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "vpc_cidr" {
  value       = aws_vpc.main.cidr_block
  description = "VPC CIDR block"
}

# Internet Gateway
output "igw_id" {
  value       = aws_internet_gateway.main.id
  description = "Internet Gateway ID"
}

# Public Subnets
output "public_subnet_ids" {
  value = {
    for name, subnet in aws_subnet.public :
    name => subnet.id
  }
  description = "Public Subnet IDs (Map)"
}

output "public_subnet_cidrs" {
  value = {
    for name, subnet in aws_subnet.public :
    name => subnet.cidr_block
  }
  description = "Public Subnet CIDR blocks (Map)"
}

# Private Subnets
output "private_subnet_ids" {
  value = {
    for name, subnet in aws_subnet.private :
    name => subnet.id
  }
  description = "Private Subnet IDs (Map)"
}

output "private_subnet_cidrs" {
  value = {
    for name, subnet in aws_subnet.private :
    name => subnet.cidr_block
  }
  description = "Private Subnet CIDR blocks (Map)"
}

# Route Tables
output "public_route_table_id" {
  value       = aws_route_table.public.id
  description = "Public Route Table ID"
}

output "private_route_table_id" {
  value       = aws_route_table.private.id
  description = "Private Route Table ID"
}

# 환경 정보
output "environment" {
  value       = var.environment
  description = "Environment name"
}

# 전체 요약
output "network_summary" {
  value = {
    environment         = var.environment
    vpc_id              = aws_vpc.main.id
    vpc_cidr            = aws_vpc.main.cidr_block
    public_subnet_count = length(aws_subnet.public)
    private_subnet_count = length(aws_subnet.private)
  }
  description = "Network infrastructure summary"
}
EOF
```

---

## 🛠️ Step 7: backend.tf 작성 (Day 2와 동일) (3분)

```bash
# Day 2에서 사용한 버킷 이름 확인
aws s3 ls | grep terraform-state

# backend.tf 생성 (버킷 이름 수정 필요)
cat > backend.tf << 'EOF'
terraform {
  backend "s3" {
    bucket = "terraform-state-YOUR-BUCKET-NAME"  # 본인 버킷 이름으로 변경
    key    = "day3-lab1/terraform.tfstate"
    region = "ap-northeast-2"
  }
}
EOF

# 버킷 이름 자동 설정 (선택)
BUCKET_NAME=$(aws s3 ls | grep terraform-state | awk '{print $3}' | head -1)
sed -i "s/YOUR-BUCKET-NAME/${BUCKET_NAME}/" backend.tf
```

---

## 🛠️ Step 8: 개발 환경 배포 (10분)

### Terraform 초기화

```bash
# 1. Terraform 초기화
terraform init

# 예상 출력:
# Initializing the backend...
# Successfully configured the backend "s3"!
# Terraform has been successfully initialized!
```

### Plan 확인 (dev 환경)

```bash
# 2. Plan 확인 (dev.tfvars 사용)
terraform plan -var-file="dev.tfvars"

# 예상 출력:
# Plan: 11 to add, 0 to change, 0 to destroy.
# 
# Changes to Outputs:
#   + environment         = "dev"
#   + vpc_id              = (known after apply)
#   + public_subnet_ids   = {
#       + public-a = (known after apply)
#       + public-c = (known after apply)
#     }
#   + private_subnet_ids  = {
#       + private-a = (known after apply)
#       + private-c = (known after apply)
#     }
```

### Apply 실행

```bash
# 3. Apply 실행
terraform apply -var-file="dev.tfvars"

# 확인 프롬프트에서 "yes" 입력

# 예상 출력:
# Apply complete! Resources: 11 added, 0 changed, 0 destroyed.
# 
# Outputs:
# 
# environment = "dev"
# network_summary = {
#   "environment" = "dev"
#   "private_subnet_count" = 2
#   "public_subnet_count" = 2
#   "vpc_cidr" = "10.0.0.0/16"
#   "vpc_id" = "vpc-xxxxx"
# }
# public_subnet_ids = {
#   "public-a" = "subnet-xxxxx"
#   "public-c" = "subnet-yyyyy"
# }
# ...
```

### Output 확인

```bash
# 4. Output 확인
terraform output

# 특정 output만 확인
terraform output vpc_id
terraform output network_summary

# JSON 형식으로 확인
terraform output -json
```

---

## 🛠️ Step 9: 프로덕션 환경 배포 (선택) (7분)

### Workspace 생성 (환경 분리)

```bash
# 1. 현재 workspace 확인
terraform workspace list

# 2. prod workspace 생성
terraform workspace new prod

# 3. prod 환경 배포
terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"

# 예상 출력:
# Apply complete! Resources: 15 added, 0 changed, 0 destroyed.
# (3 AZ이므로 리소스 더 많음)
```

### Workspace 전환

```bash
# dev로 전환
terraform workspace select dev
terraform output

# prod로 전환
terraform workspace select prod
terraform output

# 차이점 확인:
# - dev: 2 AZ (public-a, public-c)
# - prod: 3 AZ (public-a, public-b, public-c)
```

---

## ✅ 실습 체크포인트

### ✅ Variable 활용
- [ ] variables.tf 작성 완료
- [ ] dev.tfvars 작성 완료
- [ ] prod.tfvars 작성 완료
- [ ] Variable validation 동작 확인

### ✅ for_each 활용
- [ ] Public Subnets for_each로 생성
- [ ] Private Subnets for_each로 생성
- [ ] Route Table Association for_each로 생성
- [ ] Map 변환 이해

### ✅ Output 활용
- [ ] VPC 정보 출력 확인
- [ ] Subnet IDs Map 형태로 출력
- [ ] network_summary 확인
- [ ] terraform output 명령어 사용

### ✅ 환경 분리
- [ ] dev 환경 배포 성공
- [ ] prod 환경 배포 성공 (선택)
- [ ] Workspace 전환 확인
- [ ] 환경별 차이 확인

---

## 🔍 트러블슈팅

### 문제 1: for_each 오류

**증상**:
```
Error: Invalid for_each argument
The given "for_each" argument value is unsuitable
```

**원인**: for_each는 Map 또는 Set만 허용 (List 불가)

**해결**:
```hcl
# ❌ 잘못된 방법
for_each = var.public_subnets  # List

# ✅ 올바른 방법
for_each = local.public_subnets_map  # Map
```

### 문제 2: Variable validation 실패

**증상**:
```
Error: Invalid value for variable
Environment must be dev, staging, or prod.
```

**해결**:
```bash
# tfvars 파일에서 environment 값 확인
# "dev", "staging", "prod" 중 하나여야 함
```

### 문제 3: Output에서 리소스 참조 오류

**증상**:
```
Error: Unsupported attribute
This object does not have an attribute named "id"
```

**해결**:
```hcl
# for_each로 생성된 리소스는 Map 형태
# ❌ aws_subnet.public.id
# ✅ aws_subnet.public["public-a"].id
# ✅ for name, subnet in aws_subnet.public : name => subnet.id
```

---

## 🧹 리소스 정리

### dev 환경 정리

```bash
# 1. dev workspace로 전환
terraform workspace select dev

# 2. 리소스 삭제
terraform destroy -var-file="dev.tfvars"

# 확인 프롬프트에서 "yes" 입력
```

### prod 환경 정리 (생성한 경우)

```bash
# 1. prod workspace로 전환
terraform workspace select prod

# 2. 리소스 삭제
terraform destroy -var-file="prod.tfvars"
```

### Workspace 삭제

```bash
# default로 전환
terraform workspace select default

# workspace 삭제
terraform workspace delete dev
terraform workspace delete prod
```

---

## 💡 Lab 회고

### 🤝 페어 회고 (5분)
1. **Variable 활용**: 하드코딩 제거의 장점은?
2. **for_each 이해**: List를 Map으로 변환하는 이유는?
3. **환경 분리**: dev/prod 분리의 실무 효과는?

### 📊 학습 성과
- **Variable**: 재사용 가능한 코드 작성
- **for_each**: 동적 리소스 생성
- **Output**: 배포 결과 정보 추출
- **환경 분리**: tfvars로 환경별 관리

### 🔗 다음 Lab 준비
- **Day 4**: ECS Fargate 배포 (이 VPC 활용)
- **연계**: 이번 Lab의 VPC에 ECS 배포

---

## 📚 참고 자료

### Terraform 공식 문서
- [for_each Meta-Argument](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each)
- [Input Variables](https://developer.hashicorp.com/terraform/language/values/variables)
- [Output Values](https://developer.hashicorp.com/terraform/language/values/outputs)
- [Local Values](https://developer.hashicorp.com/terraform/language/values/locals)

### 실무 팁
- for_each는 Map/Set만 허용 (List는 변환 필요)
- Variable validation으로 입력 검증
- Output은 다른 모듈에서 재사용 가능
- Workspace로 환경 분리 (State 파일 독립)

---

<div align="center">

**📝 Variable** • **🔄 for_each** • **🌐 Multi-Subnet** • **🚀 확장성**

*Day 3 Lab 1 완료 - 다음: Day 4 ECS Fargate 배포*

</div>
