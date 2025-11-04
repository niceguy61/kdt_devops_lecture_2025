# Week 5 November Day 5 Lab 1: Terraform으로 ECS 보안 구성 실습 (14:00-14:50)

<div align="center">

**🔐 IAM 역할 생성** • **📦 Parameter Store 설정** • **🔗 Task Definition 통합** • **✅ 보안 검증**

*Session 3에서 배운 이론을 실제 Terraform 코드로 구현*

</div>

---

## 🕘 실습 정보
**시간**: 14:00-14:50 (50분)
**목표**: Terraform으로 ECS 보안 변수 관리 구현
**방식**: 단계별 Terraform 코드 작성 및 적용
**예상 비용**: $0.05 (1시간 기준)

## 🎯 실습 목표

### 📚 학습 목표
- Terraform으로 IAM Role/Policy 생성
- Parameter Store에 민감 정보 안전하게 저장
- ECS Task Definition에서 secrets 블록 사용
- 전체 보안 파이프라인 검증

### 🛠️ 구현 목표
- Task Execution Role 생성 (Parameter Store 읽기 권한)
- Task Role 생성 (애플리케이션 권한)
- SecureString 파라미터 생성 (KMS 암호화)
- Task Definition에서 안전하게 참조

---

## 🏗️ 구축할 아키텍처

### 📐 아키텍처 다이어그램

```mermaid
graph TB
    subgraph "Terraform 관리"
        TF[Terraform]
    end
    
    subgraph "IAM 역할"
        EXEC[Task Execution Role]
        TASK[Task Role]
    end
    
    subgraph "Parameter Store"
        KMS[KMS Key]
        P1[/myapp/prod/db/password]
        P2[/myapp/prod/api/key]
    end
    
    subgraph "ECS"
        TD[Task Definition]
        T[Running Task]
    end
    
    TF --> EXEC
    TF --> TASK
    TF --> KMS
    TF --> P1
    TF --> P2
    TF --> TD
    
    EXEC --> P1
    EXEC --> P2
    EXEC --> KMS
    TD --> EXEC
    TD --> TASK
    TD --> T
    
    style TF fill:#e8f5e8
    style EXEC fill:#fff3e0
    style TASK fill:#fff3e0
    style KMS fill:#ffebee
    style P1 fill:#e3f2fd
    style P2 fill:#e3f2fd
    style TD fill:#f3e5f5
```

### 🔗 참조 Session
**당일 Session**:
- [Session 3: Terraform에서 ECS 보안 변수 관리](./session_3.md) - 이론 및 개념

**이전 Session**:
- [Session 1: ECS 배포 전략](./session_1.md) - Task Definition 기초
- [Session 2: 모니터링 및 로깅](./session_2.md) - CloudWatch 통합

---

## 🛠️ Step 1: 프로젝트 초기화 및 IAM 역할 생성 (15분)

### 📋 이 단계에서 할 일
- Terraform 프로젝트 구조 생성
- Task Execution Role 생성 (Parameter Store 읽기)
- Task Role 생성 (애플리케이션 권한)
- IAM Policy 연결

### 🔗 참조 개념
- [Session 3: IAM 역할 분리](./session_3.md#개념-3-ecs-task-definition-보안-패턴) - Task Execution Role vs Task Role

### 📝 실습 절차

#### 1-1. 프로젝트 디렉토리 생성

```bash
# 프로젝트 디렉토리 생성
mkdir -p ~/ecs-security-lab
cd ~/ecs-security-lab

# Terraform 파일 구조 생성
touch main.tf variables.tf outputs.tf terraform.tfvars
```

#### 1-2. variables.tf 작성

```hcl
# variables.tf
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "myapp"
}

variable "environment" {
  description = "Environment (dev/staging/prod)"
  type        = string
  default     = "prod"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "api_key" {
  description = "External API key"
  type        = string
  sensitive   = true
}
```

#### 1-3. terraform.tfvars 작성

```hcl
# terraform.tfvars
aws_region  = "ap-northeast-2"
app_name    = "myapp"
environment = "prod"

# 민감 정보 (실제로는 환경변수나 Vault에서 주입)
db_password = "MySecureP@ssw0rd123"
api_key     = "sk-1234567890abcdef"
```

**⚠️ 중요**: `terraform.tfvars`는 `.gitignore`에 추가!

```bash
echo "terraform.tfvars" >> .gitignore
echo "*.tfstate*" >> .gitignore
echo ".terraform/" >> .gitignore
```

#### 1-4. main.tf - Provider 설정

```hcl
# main.tf
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.app_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# 현재 AWS 계정 정보
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
```

#### 1-5. main.tf - Task Execution Role 생성

```hcl
# Task Execution Role (ECS 에이전트가 사용)
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.app_name}-${var.environment}-task-execution-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
  
  tags = {
    Name = "${var.app_name}-task-execution-role"
  }
}

# AWS 관리형 정책 연결 (ECR, CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Parameter Store 읽기 권한 추가
resource "aws_iam_role_policy" "ecs_task_execution_ssm" {
  name = "${var.app_name}-task-execution-ssm"
  role = aws_iam_role.ecs_task_execution_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter"
        ]
        Resource = [
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.app_name}/${var.environment}/*"
        ]
      }
    ]
  })
}
```

#### 1-6. main.tf - Task Role 생성

```hcl
# Task Role (컨테이너 애플리케이션이 사용)
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.app_name}-${var.environment}-task-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
  
  tags = {
    Name = "${var.app_name}-task-role"
  }
}

# 애플리케이션 권한 예시 (S3 읽기)
resource "aws_iam_role_policy" "ecs_task_s3" {
  name = "${var.app_name}-task-s3"
  role = aws_iam_role.ecs_task_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:ListBucket"
      ]
      Resource = [
        "arn:aws:s3:::${var.app_name}-${var.environment}-*",
        "arn:aws:s3:::${var.app_name}-${var.environment}-*/*"
      ]
    }]
  })
}
```

#### 1-7. Terraform 초기화 및 적용

```bash
# Terraform 초기화
terraform init

# 계획 확인
terraform plan

# 적용
terraform apply -auto-approve
```

### 📊 예상 결과

```
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

task_execution_role_arn = "arn:aws:iam::123456789012:role/myapp-prod-task-execution-role"
task_role_arn = "arn:aws:iam::123456789012:role/myapp-prod-task-role"
```

### ✅ Step 1 검증

**검증 명령어**:
```bash
# Task Execution Role 확인
aws iam get-role --role-name myapp-prod-task-execution-role

# Task Role 확인
aws iam get-role --role-name myapp-prod-task-role

# 연결된 정책 확인
aws iam list-attached-role-policies --role-name myapp-prod-task-execution-role
aws iam list-role-policies --role-name myapp-prod-task-execution-role
```

**예상 출력**:
```json
{
  "Role": {
    "RoleName": "myapp-prod-task-execution-role",
    "Arn": "arn:aws:iam::123456789012:role/myapp-prod-task-execution-role",
    "AssumeRolePolicyDocument": {
      "Version": "2012-10-17",
      "Statement": [{
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }]
    }
  }
}
```

**✅ 체크리스트**:
- [ ] Task Execution Role 생성 완료
- [ ] Task Role 생성 완료
- [ ] Parameter Store 읽기 권한 연결
- [ ] S3 읽기 권한 연결

---

## 🛠️ Step 2: KMS 키 및 Parameter Store 설정 (15분)

### 📋 이 단계에서 할 일
- KMS 키 생성 (Parameter Store 암호화용)
- SecureString 파라미터 생성
- Task Execution Role에 KMS 복호화 권한 부여

### 🔗 참조 개념
- [Session 3: Parameter Store 아키텍처](./session_3.md#개념-2-parameter-store-아키텍처) - SecureString과 KMS

### 📝 실습 절차

#### 2-1. main.tf - KMS 키 생성

```hcl
# KMS 키 생성 (Parameter Store 암호화용)
resource "aws_kms_key" "parameter_store" {
  description             = "KMS key for Parameter Store encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  
  tags = {
    Name = "${var.app_name}-parameter-store-key"
  }
}

resource "aws_kms_alias" "parameter_store" {
  name          = "alias/${var.app_name}-parameter-store"
  target_key_id = aws_kms_key.parameter_store.key_id
}

# KMS 키 정책 (Task Execution Role에 복호화 권한)
resource "aws_kms_key_policy" "parameter_store" {
  key_id = aws_kms_key.parameter_store.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow ECS Task Execution Role"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ecs_task_execution_role.arn
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}
```

#### 2-2. main.tf - Parameter Store 파라미터 생성

```hcl
# DB 비밀번호 파라미터
resource "aws_ssm_parameter" "db_password" {
  name   = "/${var.app_name}/${var.environment}/db/password"
  type   = "SecureString"
  value  = var.db_password
  key_id = aws_kms_key.parameter_store.id
  
  description = "Database password for ${var.app_name}"
  
  tags = {
    Name        = "db-password"
    Sensitive   = "true"
    Environment = var.environment
  }
}

# API 키 파라미터
resource "aws_ssm_parameter" "api_key" {
  name   = "/${var.app_name}/${var.environment}/api/key"
  type   = "SecureString"
  value  = var.api_key
  key_id = aws_kms_key.parameter_store.id
  
  description = "External API key for ${var.app_name}"
  
  tags = {
    Name        = "api-key"
    Sensitive   = "true"
    Environment = var.environment
  }
}

# DB 호스트 파라미터 (비민감 정보)
resource "aws_ssm_parameter" "db_host" {
  name  = "/${var.app_name}/${var.environment}/db/host"
  type  = "String"
  value = "myapp-db.cluster-abc123.ap-northeast-2.rds.amazonaws.com"
  
  description = "Database host for ${var.app_name}"
  
  tags = {
    Name        = "db-host"
    Environment = var.environment
  }
}

# DB 포트 파라미터 (비민감 정보)
resource "aws_ssm_parameter" "db_port" {
  name  = "/${var.app_name}/${var.environment}/db/port"
  type  = "String"
  value = "5432"
  
  description = "Database port for ${var.app_name}"
  
  tags = {
    Name        = "db-port"
    Environment = var.environment
  }
}
```

#### 2-3. Task Execution Role에 KMS 권한 추가

```hcl
# Task Execution Role에 KMS 복호화 권한 추가
resource "aws_iam_role_policy" "ecs_task_execution_kms" {
  name = "${var.app_name}-task-execution-kms"
  role = aws_iam_role.ecs_task_execution_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "kms:Decrypt",
        "kms:DescribeKey"
      ]
      Resource = [
        aws_kms_key.parameter_store.arn
      ]
    }]
  })
}
```

#### 2-4. Terraform 적용

```bash
# 계획 확인
terraform plan

# 적용
terraform apply -auto-approve
```

### 📊 예상 결과

```
Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

kms_key_id = "12345678-1234-1234-1234-123456789012"
db_password_arn = "arn:aws:ssm:ap-northeast-2:123456789012:parameter/myapp/prod/db/password"
api_key_arn = "arn:aws:ssm:ap-northeast-2:123456789012:parameter/myapp/prod/api/key"
```

### ✅ Step 2 검증

**검증 명령어**:
```bash
# KMS 키 확인
aws kms describe-key --key-id alias/myapp-parameter-store

# Parameter Store 파라미터 목록
aws ssm get-parameters-by-path \
  --path "/myapp/prod" \
  --recursive

# SecureString 복호화 테스트 (Task Execution Role 권한 확인)
aws ssm get-parameter \
  --name "/myapp/prod/db/password" \
  --with-decryption
```

**예상 출력**:
```json
{
  "Parameter": {
    "Name": "/myapp/prod/db/password",
    "Type": "SecureString",
    "Value": "MySecureP@ssw0rd123",
    "Version": 1,
    "ARN": "arn:aws:ssm:ap-northeast-2:123456789012:parameter/myapp/prod/db/password"
  }
}
```

**✅ 체크리스트**:
- [ ] KMS 키 생성 완료
- [ ] SecureString 파라미터 생성 완료
- [ ] Task Execution Role에 KMS 권한 부여
- [ ] 파라미터 복호화 테스트 성공

---

## 🛠️ Step 3: ECS Task Definition 생성 (15분)

### 📋 이 단계에서 할 일
- CloudWatch Logs 그룹 생성
- ECS Task Definition 생성
- secrets 블록으로 Parameter Store 참조
- environment 블록으로 비민감 정보 전달

### 🔗 참조 개념
- [Session 3: environment vs secrets](./session_3.md#3-1-environment-vs-secrets-차이) - 블록 차이점

### 📝 실습 절차

#### 3-1. main.tf - CloudWatch Logs 그룹 생성

```hcl
# CloudWatch Logs 그룹
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.app_name}/${var.environment}"
  retention_in_days = 7
  
  tags = {
    Name = "${var.app_name}-logs"
  }
}
```

#### 3-2. main.tf - ECS Task Definition 생성

```hcl
# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.app_name}-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  
  # Task Execution Role (Parameter Store 읽기)
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  
  # Task Role (애플리케이션 권한)
  task_role_arn = aws_iam_role.ecs_task_role.arn
  
  container_definitions = jsonencode([{
    name  = "app"
    image = "nginx:alpine"  # 테스트용 이미지
    
    # ✅ 비민감 정보: environment 블록
    environment = [
      {
        name  = "APP_ENV"
        value = var.environment
      },
      {
        name  = "APP_NAME"
        value = var.app_name
      },
      {
        name  = "DB_HOST"
        value = aws_ssm_parameter.db_host.value
      },
      {
        name  = "DB_PORT"
        value = aws_ssm_parameter.db_port.value
      }
    ]
    
    # ✅ 민감 정보: secrets 블록
    secrets = [
      {
        name      = "DB_PASSWORD"
        valueFrom = aws_ssm_parameter.db_password.arn
      },
      {
        name      = "API_KEY"
        valueFrom = aws_ssm_parameter.api_key.arn
      }
    ]
    
    # CloudWatch Logs 설정
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.app.name
        "awslogs-region"        = data.aws_region.current.name
        "awslogs-stream-prefix" = "ecs"
      }
    }
    
    portMappings = [{
      containerPort = 80
      protocol      = "tcp"
    }]
    
    essential = true
  }])
  
  tags = {
    Name = "${var.app_name}-task-definition"
  }
}
```

#### 3-3. outputs.tf 작성

```hcl
# outputs.tf
output "task_execution_role_arn" {
  description = "Task Execution Role ARN"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "task_role_arn" {
  description = "Task Role ARN"
  value       = aws_iam_role.ecs_task_role.arn
}

output "kms_key_id" {
  description = "KMS Key ID"
  value       = aws_kms_key.parameter_store.id
}

output "db_password_arn" {
  description = "DB Password Parameter ARN"
  value       = aws_ssm_parameter.db_password.arn
  sensitive   = true
}

output "api_key_arn" {
  description = "API Key Parameter ARN"
  value       = aws_ssm_parameter.api_key.arn
  sensitive   = true
}

output "task_definition_arn" {
  description = "ECS Task Definition ARN"
  value       = aws_ecs_task_definition.app.arn
}

output "task_definition_family" {
  description = "ECS Task Definition Family"
  value       = aws_ecs_task_definition.app.family
}

output "cloudwatch_log_group" {
  description = "CloudWatch Log Group Name"
  value       = aws_cloudwatch_log_group.app.name
}
```

#### 3-4. Terraform 적용

```bash
# 계획 확인
terraform plan

# 적용
terraform apply -auto-approve
```

### 📊 예상 결과

```
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

task_definition_arn = "arn:aws:ecs:ap-northeast-2:123456789012:task-definition/myapp-prod:1"
task_definition_family = "myapp-prod"
cloudwatch_log_group = "/ecs/myapp/prod"
```

### ✅ Step 3 검증

**검증 명령어**:
```bash
# Task Definition 확인
aws ecs describe-task-definition \
  --task-definition myapp-prod

# Container Definition 확인 (secrets 블록)
aws ecs describe-task-definition \
  --task-definition myapp-prod \
  --query 'taskDefinition.containerDefinitions[0].secrets'

# CloudWatch Logs 그룹 확인
aws logs describe-log-groups \
  --log-group-name-prefix "/ecs/myapp"
```

**예상 출력 (secrets 블록)**:
```json
[
  {
    "name": "DB_PASSWORD",
    "valueFrom": "arn:aws:ssm:ap-northeast-2:123456789012:parameter/myapp/prod/db/password"
  },
  {
    "name": "API_KEY",
    "valueFrom": "arn:aws:ssm:ap-northeast-2:123456789012:parameter/myapp/prod/api/key"
  }
]
```

**✅ 체크리스트**:
- [ ] Task Definition 생성 완료
- [ ] secrets 블록 설정 확인
- [ ] environment 블록 설정 확인
- [ ] CloudWatch Logs 그룹 생성 완료

---

## 🛠️ Step 4: 전체 시스템 테스트 및 검증 (5분)

### 📋 테스트 시나리오
1. Task Definition 유효성 검증
2. IAM 권한 테스트
3. Parameter Store 접근 테스트
4. 보안 설정 확인

### 🧪 테스트 실행

#### 테스트 1: Task Definition 유효성 검증

**방법**:
```bash
# Task Definition JSON 추출
aws ecs describe-task-definition \
  --task-definition myapp-prod \
  --query 'taskDefinition' > task-definition.json

# 유효성 검증
cat task-definition.json | jq '.containerDefinitions[0] | {
  name,
  image,
  environment: .environment | length,
  secrets: .secrets | length,
  logConfiguration: .logConfiguration.logDriver
}'
```

**예상 결과**:
```json
{
  "name": "app",
  "image": "nginx:alpine",
  "environment": 4,
  "secrets": 2,
  "logConfiguration": "awslogs"
}
```

#### 테스트 2: IAM 권한 테스트

**방법**:
```bash
# Task Execution Role 권한 시뮬레이션
aws iam simulate-principal-policy \
  --policy-source-arn $(terraform output -raw task_execution_role_arn) \
  --action-names \
    ssm:GetParameters \
    kms:Decrypt \
    logs:CreateLogStream \
  --resource-arns \
    "arn:aws:ssm:ap-northeast-2:*:parameter/myapp/prod/*" \
    "$(terraform output -raw kms_key_id)" \
    "arn:aws:logs:ap-northeast-2:*:log-group:/ecs/myapp/prod:*"
```

**예상 결과**:
```
EvaluationResults:
- EvalActionName: ssm:GetParameters
  EvalDecision: allowed
- EvalActionName: kms:Decrypt
  EvalDecision: allowed
- EvalActionName: logs:CreateLogStream
  EvalDecision: allowed
```

#### 테스트 3: Parameter Store 접근 테스트

**방법**:
```bash
# Task Execution Role로 파라미터 읽기 테스트
aws ssm get-parameters \
  --names \
    "/myapp/prod/db/password" \
    "/myapp/prod/api/key" \
  --with-decryption \
  --query 'Parameters[*].[Name,Type,Value]' \
  --output table
```

**예상 결과**:
```
---------------------------------------------------------
|                    GetParameters                      |
+-------------------------------+--------------+---------+
|  /myapp/prod/db/password      | SecureString | ******* |
|  /myapp/prod/api/key          | SecureString | ******* |
+-------------------------------+--------------+---------+
```

#### 테스트 4: 보안 설정 확인

**방법**:
```bash
# 1. KMS 키 로테이션 확인
aws kms get-key-rotation-status \
  --key-id $(terraform output -raw kms_key_id)

# 2. Parameter Store 암호화 확인
aws ssm describe-parameters \
  --parameter-filters "Key=Name,Values=/myapp/prod/db/password" \
  --query 'Parameters[0].[Name,Type,KeyId]' \
  --output table

# 3. Task Definition 보안 설정 확인
aws ecs describe-task-definition \
  --task-definition myapp-prod \
  --query 'taskDefinition.{
    ExecutionRole: executionRoleArn,
    TaskRole: taskRoleArn,
    NetworkMode: networkMode,
    RequiresCompatibilities: requiresCompatibilities
  }'
```

**예상 결과**:
```json
{
  "ExecutionRole": "arn:aws:iam::123456789012:role/myapp-prod-task-execution-role",
  "TaskRole": "arn:aws:iam::123456789012:role/myapp-prod-task-role",
  "NetworkMode": "awsvpc",
  "RequiresCompatibilities": ["FARGATE"]
}
```

### ✅ 전체 검증 체크리스트

**기능 검증**:
- [ ] Task Definition 생성 성공
- [ ] secrets 블록 정상 설정
- [ ] environment 블록 정상 설정
- [ ] CloudWatch Logs 연동 확인

**보안 검증**:
- [ ] KMS 키 로테이션 활성화
- [ ] SecureString 암호화 확인
- [ ] IAM 역할 분리 확인
- [ ] 최소 권한 원칙 적용

**권한 검증**:
- [ ] Task Execution Role - Parameter Store 읽기 가능
- [ ] Task Execution Role - KMS 복호화 가능
- [ ] Task Role - S3 읽기 가능
- [ ] 불필요한 권한 없음

---

## 🧹 리소스 정리 (예상 시간: 3분)

### ⚠️ 중요: 반드시 순서대로 삭제

**삭제 명령어**:
```bash
# Terraform으로 모든 리소스 삭제
terraform destroy -auto-approve
```

### ✅ 정리 완료 확인

**확인 명령어**:
```bash
# Task Definition 삭제 확인
aws ecs list-task-definitions --family-prefix myapp-prod

# Parameter Store 삭제 확인
aws ssm get-parameters-by-path --path "/myapp/prod" --recursive

# IAM Role 삭제 확인
aws iam list-roles --query 'Roles[?contains(RoleName, `myapp-prod`)]'

# KMS 키 삭제 예약 확인
aws kms describe-key --key-id alias/myapp-parameter-store
```

**예상 결과**:
```
TaskDefinitionArns: []
Parameters: []
Roles: []
KeyMetadata.KeyState: PendingDeletion
```

**✅ 최종 체크리스트**:
- [ ] Task Definition 삭제 완료
- [ ] Parameter Store 파라미터 삭제 완료
- [ ] IAM Role 삭제 완료
- [ ] KMS 키 삭제 예약 완료
- [ ] CloudWatch Logs 그룹 삭제 완료

---

## 💰 비용 확인

### 예상 비용 계산
| 리소스 | 사용 시간 | 단가 | 예상 비용 |
|--------|----------|------|-----------|
| **Parameter Store (Standard)** | 무료 | $0 | $0 |
| **KMS 키** | 1시간 | $1/월 (시간당 $0.0014) | $0.0014 |
| **CloudWatch Logs** | 1MB | $0.50/GB | $0.0005 |
| **IAM Role** | 무료 | $0 | $0 |
| **합계** | | | **$0.002** |

**💡 비용 절감 팁**:
- Parameter Store Standard는 무료 (10,000개까지)
- KMS 키는 실습 후 즉시 삭제 예약
- CloudWatch Logs는 7일 보관으로 제한

---

## 🔍 트러블슈팅

### 문제 1: Task가 Parameter Store 값을 읽지 못함

**증상**:
```
CannotPullContainerError: Error response from daemon: 
pull access denied for myapp, repository does not exist or may require 'docker login'
```

**원인**:
- Task Execution Role에 Parameter Store 읽기 권한 없음
- KMS 복호화 권한 없음

**해결 방법**:
```bash
# 1. Task Execution Role 권한 확인
aws iam get-role-policy \
  --role-name myapp-prod-task-execution-role \
  --policy-name myapp-task-execution-ssm

# 2. KMS 권한 확인
aws iam get-role-policy \
  --role-name myapp-prod-task-execution-role \
  --policy-name myapp-task-execution-kms

# 3. 권한 추가 (Terraform 재적용)
terraform apply -auto-approve
```

### 문제 2: KMS 복호화 실패

**증상**:
```
AccessDeniedException: User is not authorized to perform: kms:Decrypt
```

**원인**:
- KMS 키 정책에 Task Execution Role 권한 없음

**해결 방법**:
```bash
# KMS 키 정책 확인
aws kms get-key-policy \
  --key-id alias/myapp-parameter-store \
  --policy-name default

# Terraform 재적용
terraform apply -auto-approve
```

### 문제 3: CloudWatch Logs에 로그가 없음

**증상**:
- Task는 실행되지만 로그가 보이지 않음

**원인**:
- Task Execution Role에 CloudWatch Logs 쓰기 권한 없음

**해결 방법**:
```bash
# AmazonECSTaskExecutionRolePolicy 연결 확인
aws iam list-attached-role-policies \
  --role-name myapp-prod-task-execution-role

# 정책 연결 (Terraform 재적용)
terraform apply -auto-approve
```

---

## 💡 Lab 회고

### 🤝 페어 회고 (5분)
1. **가장 어려웠던 부분**: 
   - IAM 역할 분리 개념 이해
   - secrets vs environment 블록 차이
   - KMS 키 정책 설정

2. **새로 배운 점**:
   - Terraform으로 보안 인프라 구축
   - Parameter Store SecureString 사용법
   - Task Definition 보안 패턴

3. **실무 적용 아이디어**:
   - 환경별 Parameter Store 경로 분리
   - KMS 키 로테이션 자동화
   - 민감 정보 Git 커밋 방지

### 📊 학습 성과
- **기술적 성취**: Terraform으로 ECS 보안 인프라 완성
- **이해도 향상**: IAM 역할 분리, Parameter Store, KMS 암호화
- **실무 역량**: 민감 정보 관리 베스트 프랙티스 습득

### 🔗 다음 Lab 준비
- **Lab 2**: ECS Service 배포 및 Auto Scaling 구성
- **연계 내용**: 이번 Lab의 Task Definition 사용

---

## 🔗 관련 자료

### 📚 Session 복습
- [Session 3: Terraform에서 ECS 보안 변수 관리](./session_3.md)

### 📖 AWS 공식 문서
- [ECS Task Definition - Secrets](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html)
- [Parameter Store SecureString](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html)
- [KMS 키 정책](https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html)

### 🎯 다음 Lab
- [Lab 2: ECS Service 배포](./lab_2.md) - Task Definition을 Service로 배포

---

<div align="center">

**✅ Lab 완료** • **🧹 리소스 정리 필수** • **💰 비용 확인**

*다음 Lab으로 이동하기 전 반드시 리소스 정리 확인*

</div>
