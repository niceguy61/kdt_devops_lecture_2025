# November Week 2 Day 3 Session 3: Terraform Variable & Output

<div align="center">

**📝 Variable** • **📤 Output** • **🔧 tfvars** • **🌍 환경 분리**

*Terraform 변수로 유연한 인프라 관리*

</div>

---

## 🕘 Session 정보
**시간**: 10:30-11:10 (40분)
**목표**: Terraform 변수 활용 및 환경별 설정 관리
**방식**: 이론 + 실습 예제

## 🎯 학습 목표

### 📚 이해 목표
- Variable 선언 및 타입 이해
- 변수 값 전달 방법 파악
- Output으로 정보 추출
- 환경별 설정 관리 (dev/staging/prod)

### 🛠️ 적용 목표
- Variable을 활용한 재사용 가능한 코드 작성
- tfvars 파일로 환경 분리
- Output으로 필요한 정보 추출

---

## 🤔 왜 필요한가? (5분)

### 💼 실무 시나리오: 환경별 인프라 관리

**하드코딩의 문제**:
```hcl
# ❌ 나쁜 예: 하드코딩
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  
  tags = {
    Name = "production-web-server"
  }
}

문제점:
- 개발/스테이징/프로덕션 환경마다 코드 복사
- 값 변경 시 여러 곳 수정 필요
- 실수 발생 가능성 높음
- 재사용 불가능
```

**Variable 솔루션**:
```hcl
# ✅ 좋은 예: Variable 사용
variable "environment" {
  type    = string
  default = "dev"
}

variable "instance_type" {
  type = string
  default = "t3.micro"
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  
  tags = {
    Name = "${var.environment}-web-server"
  }
}

장점:
✅ 환경별 다른 값 사용 가능
✅ 한 곳에서 값 관리
✅ 재사용 가능
✅ 실수 방지
```

### 🏠 실생활 비유

**레시피 (요리법)**:
- **하드코딩**: 레시피에 "소금 5g" 고정 (인원수 변경 시 계산 필요)
- **Variable**: 레시피에 "소금 ${인원수 × 1g}" (자동 계산)

---

## 📖 핵심 개념 (30분)

### 🔍 개념 1: Variable 선언 및 타입 (10분)

#### Variable 기본 구조

```hcl
variable "변수명" {
  type        = 타입
  description = "설명"
  default     = 기본값
  validation {
    # 검증 규칙 (선택)
  }
}
```

#### Variable 타입

**1. 기본 타입**:
```hcl
# string (문자열)
variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

# number (숫자)
variable "instance_count" {
  type        = number
  description = "Number of instances"
  default     = 2
}

# bool (불리언)
variable "enable_monitoring" {
  type        = bool
  description = "Enable CloudWatch monitoring"
  default     = true
}
```

**2. 복합 타입**:
```hcl
# list (리스트)
variable "availability_zones" {
  type        = list(string)
  description = "List of AZs"
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}

# map (맵)
variable "instance_types" {
  type = map(string)
  description = "Instance types by environment"
  default = {
    dev  = "t3.micro"
    prod = "t3.medium"
  }
}

# object (객체)
variable "vpc_config" {
  type = object({
    cidr_block = string
    name       = string
    enable_dns = bool
  })
  description = "VPC configuration"
  default = {
    cidr_block = "10.0.0.0/16"
    name       = "main-vpc"
    enable_dns = true
  }
}
```

#### Variable 사용

```hcl
# Variable 참조: var.변수명
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_types[var.environment]
  count         = var.instance_count
  
  monitoring = var.enable_monitoring
  
  tags = {
    Name        = "${var.environment}-web-${count.index + 1}"
    Environment = var.environment
  }
}
```

#### Variable 검증

```hcl
variable "environment" {
  type        = string
  description = "Environment name"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "instance_count" {
  type        = number
  description = "Number of instances"
  
  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}
```

### 🔍 개념 2: 변수 값 전달 방법 (10분)

#### 1. CLI 옵션

```bash
# -var 옵션
terraform apply -var="environment=prod" -var="instance_count=3"

# 여러 변수 전달
terraform apply \
  -var="environment=prod" \
  -var="instance_type=t3.medium" \
  -var="enable_monitoring=true"
```

#### 2. tfvars 파일 (권장)

**dev.tfvars**:
```hcl
environment      = "dev"
instance_type    = "t3.micro"
instance_count   = 1
enable_monitoring = false

vpc_config = {
  cidr_block = "10.0.0.0/16"
  name       = "dev-vpc"
  enable_dns = true
}
```

**prod.tfvars**:
```hcl
environment      = "prod"
instance_type    = "t3.medium"
instance_count   = 3
enable_monitoring = true

vpc_config = {
  cidr_block = "10.1.0.0/16"
  name       = "prod-vpc"
  enable_dns = true
}
```

**사용**:
```bash
# 개발 환경
terraform apply -var-file="dev.tfvars"

# 프로덕션 환경
terraform apply -var-file="prod.tfvars"
```

#### 3. 환경 변수

```bash
# TF_VAR_ 접두사 사용
export TF_VAR_environment="prod"
export TF_VAR_instance_count=3

terraform apply
```

#### 4. terraform.tfvars (자동 로드)

```hcl
# terraform.tfvars (자동으로 로드됨)
environment = "dev"
instance_type = "t3.micro"
```

```bash
# 별도 옵션 없이 실행
terraform apply
```

#### 우선순위

```
1. CLI -var 옵션 (최우선)
2. CLI -var-file 옵션
3. terraform.tfvars (자동 로드)
4. *.auto.tfvars (자동 로드)
5. 환경 변수 (TF_VAR_)
6. Variable 기본값 (default)
```

### 🔍 개념 3: Output & Local Values (10분)

#### Output 값

> **목적**: Terraform 실행 후 필요한 정보를 추출하여 표시하거나 다른 모듈에 전달

**기본 구조**:
```hcl
output "출력명" {
  value       = 값
  description = "설명"
  sensitive   = true/false  # 민감 정보 숨김
}
```

**예시**:
```hcl
# 인스턴스 Public IP 출력
output "instance_public_ips" {
  value       = aws_instance.web[*].public_ip
  description = "Public IP addresses of web servers"
}

# VPC ID 출력
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

# 데이터베이스 엔드포인트 (민감 정보)
output "db_endpoint" {
  value       = aws_db_instance.main.endpoint
  description = "Database endpoint"
  sensitive   = true
}
```

**Output 확인**:
```bash
# terraform apply 후 자동 표시
terraform apply

# 명시적 확인
terraform output

# 특정 output만 확인
terraform output instance_public_ips

# JSON 형식으로 출력
terraform output -json
```

#### Local Values

> **목적**: 반복되는 표현식을 변수처럼 사용 (내부 전용)

**기본 구조**:
```hcl
locals {
  로컬변수명 = 값
}
```

**예시**:
```hcl
locals {
  # 공통 태그
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "MyApp"
  }
  
  # 환경별 인스턴스 타입
  instance_type = var.environment == "prod" ? "t3.medium" : "t3.micro"
  
  # 이름 접두사
  name_prefix = "${var.environment}-${var.project_name}"
}

# Local 값 사용
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = local.instance_type
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-web"
    }
  )
}
```

#### Variable vs Local

| 특징 | Variable | Local |
|------|----------|-------|
| **입력** | 외부에서 전달 가능 | 내부에서만 정의 |
| **용도** | 사용자 입력 | 계산된 값 |
| **참조** | `var.변수명` | `local.변수명` |
| **변경** | 실행 시마다 가능 | 코드 수정 필요 |

---

## 💡 실무 활용 예시 (5분)

### 환경별 인프라 구성

**디렉토리 구조**:
```
terraform/
├── main.tf           # 리소스 정의
├── variables.tf      # Variable 선언
├── outputs.tf        # Output 정의
├── dev.tfvars        # 개발 환경 값
├── staging.tfvars    # 스테이징 환경 값
└── prod.tfvars       # 프로덕션 환경 값
```

**variables.tf**:
```hcl
variable "environment" {
  type        = string
  description = "Environment name"
}

variable "instance_config" {
  type = object({
    type  = string
    count = number
  })
  description = "Instance configuration"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}
```

**dev.tfvars**:
```hcl
environment = "dev"

instance_config = {
  type  = "t3.micro"
  count = 1
}

vpc_cidr = "10.0.0.0/16"
```

**prod.tfvars**:
```hcl
environment = "prod"

instance_config = {
  type  = "t3.medium"
  count = 3
}

vpc_cidr = "10.1.0.0/16"
```

**main.tf**:
```hcl
locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-vpc"
    }
  )
}

resource "aws_instance" "web" {
  count         = var.instance_config.count
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_config.type
  
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-web-${count.index + 1}"
    }
  )
}
```

**outputs.tf**:
```hcl
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "instance_ips" {
  value       = aws_instance.web[*].public_ip
  description = "Instance public IPs"
}
```

**배포**:
```bash
# 개발 환경
terraform apply -var-file="dev.tfvars"

# 프로덕션 환경
terraform apply -var-file="prod.tfvars"
```

---

## 🔑 핵심 키워드

- **Variable**: 외부에서 전달 가능한 입력 변수
- **tfvars**: 변수 값을 정의하는 파일
- **Output**: Terraform 실행 결과 정보 추출
- **Local**: 내부에서만 사용하는 계산된 값
- **환경 분리**: dev/staging/prod 환경별 설정 관리
- **Validation**: 변수 값 검증 규칙

---

## 📝 Session 마무리

### ✅ 오늘 Session 성과
- [ ] Variable 선언 및 타입 이해
- [ ] 변수 값 전달 방법 (CLI, tfvars, 환경변수) 파악
- [ ] Output으로 정보 추출 방법 습득
- [ ] Local Values 활용 방법 이해
- [ ] 환경별 설정 관리 전략 수립

### 🎯 다음 Lab 준비
- **Lab 1**: ECS Fargate 배포 (Terraform Variable 활용)
- **연계**: Variable로 환경별 Fargate 설정 관리

### 🔗 공식 문서 (필수)

**⚠️ 학생들이 직접 확인해야 할 공식 문서**:
- 📘 [Input Variables](https://developer.hashicorp.com/terraform/language/values/variables)
- 📗 [Output Values](https://developer.hashicorp.com/terraform/language/values/outputs)
- 📙 [Local Values](https://developer.hashicorp.com/terraform/language/values/locals)
- 📕 [Variable Definition Files](https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files)
- 🆕 [Terraform 최신 업데이트](https://github.com/hashicorp/terraform/releases)

---

<div align="center">

**📝 Variable** • **📤 Output** • **🔧 tfvars** • **🌍 환경 분리**

*다음: Lab 1 - ECS Fargate 배포*

</div>
