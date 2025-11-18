# November Week 3 Day 2 Lab 1: 전체 컴퓨팅 스택 배포

<div align="center">

**🏗️ VPC** • **🐳 ECR** • **⚖️ ALB** • **🚀 ECS Fargate**

*Terraform으로 프로덕션급 컨테이너 인프라 완전 자동화*

</div>

---

## 🕘 Lab 정보
**시간**: 11:20-12:00 (40분)
**목표**: VPC부터 ECS까지 전체 컴퓨팅 스택을 Terraform으로 배포
**방식**: Terraform 코드 작성 및 실행

## 🎯 학습 목표
- VPC 네트워크 인프라 코드화
- ECR Repository 생성 및 이미지 Push
- ALB + Target Group 설정
- ECS Fargate로 컨테이너 배포
- 전체 스택 통합 및 검증

---

## 🏗️ 구축할 아키텍처

### 📐 전체 아키텍처
```
┌─────────────────────────────────────────────────────────┐
│                    AWS Cloud (ap-northeast-2)           │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │  VPC (10.0.0.0/16)                                 │ │
│  │                                                     │ │
│  │  ┌──────────────────┐  ┌──────────────────┐       │ │
│  │  │ Public Subnet A  │  │ Public Subnet B  │       │ │
│  │  │ 10.0.1.0/24      │  │ 10.0.2.0/24      │       │ │
│  │  │                  │  │                  │       │ │
│  │  │  [ALB]           │  │  [NAT Gateway]   │       │ │
│  │  │                  │  │                  │       │ │
│  │  └────────┬─────────┘  └────────┬─────────┘       │ │
│  │           │                     │                 │ │
│  │  ┌────────┴─────────┐  ┌────────┴─────────┐       │ │
│  │  │ Private Subnet A │  │ Private Subnet B │       │ │
│  │  │ 10.0.11.0/24     │  │ 10.0.12.0/24     │       │ │
│  │  │                  │  │                  │       │ │
│  │  │  [ECS Task 1]    │  │  [ECS Task 2]    │       │ │
│  │  │  (Fargate)       │  │  (Fargate)       │       │ │
│  │  │                  │  │                  │       │ │
│  │  └──────────────────┘  └──────────────────┘       │ │
│  │                                                     │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │  ECR Repository                                    │ │
│  │  - nginx:latest                                    │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
└─────────────────────────────────────────────────────────┘

사용자 → Internet Gateway → ALB → ECS Tasks (Private Subnet)
                                      ↓
                                  NAT Gateway → Internet (ECR Pull)
```

### 🔗 참조 Session
**당일 Session**:
- [Session 1: EC2 & ALB](./session_1.md) - ALB, Target Group 개념
- [Session 2: ECR](./session_2.md) - 컨테이너 이미지 저장소
- [Session 3: ECS](./session_3.md) - Fargate, Task Definition, Service

**이전 Day Session**:
- [Week 3 Day 1 Session 1: Terraform 기초](../day1/session_1.md) - 변수, 리소스
- [Week 3 Day 1 Session 2: 프로그래밍 기술](../day1/session_2.md) - for_each, count

---

## 📁 프로젝트 구조

### 디렉토리 구성
```
nw3-day2-lab1/
├── main.tf              # 메인 리소스 정의
├── variables.tf         # 변수 선언
├── outputs.tf           # 출력 값
├── terraform.tfvars     # 변수 값
├── vpc.tf              # VPC 리소스
├── ecr.tf              # ECR 리소스
├── alb.tf              # ALB 리소스
├── ecs.tf              # ECS 리소스
├── iam.tf              # IAM 역할
└── app/
    ├── Dockerfile       # 컨테이너 이미지
    └── index.html       # 샘플 웹 페이지
```

---

## 🛠️ Step 1: 프로젝트 초기화 (5분)

### 📋 이 단계에서 할 일
- 프로젝트 디렉토리 생성
- Terraform 초기화
- Provider 설정

### 🔗 참조 개념
- [Session 1: Terraform 기초](../day1/session_1.md) - Provider 설정

### 📝 실습 절차

#### 1-1. 프로젝트 디렉토리 생성
```bash
mkdir -p ~/terraform/nw3-day2-lab1/app
cd ~/terraform/nw3-day2-lab1
```

#### 1-2. Provider 설정 (main.tf)
```hcl
# main.tf
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
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "NW3-Day2-Lab1"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
```

#### 1-3. 변수 선언 (variables.tf)
```hcl
# variables.tf
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "nw3-day2-lab1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2b"]
}
```

#### 1-4. 변수 값 설정 (terraform.tfvars)
```hcl
# terraform.tfvars
aws_region         = "ap-northeast-2"
environment        = "dev"
project_name       = "nw3-day2-lab1"
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["ap-northeast-2a", "ap-northeast-2b"]
```

#### 1-5. Terraform 초기화
```bash
terraform init
```

**예상 결과**:
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.x.x...

Terraform has been successfully initialized!
```

### ✅ Step 1 검증
- [ ] 프로젝트 디렉토리 생성 완료
- [ ] main.tf, variables.tf, terraform.tfvars 작성 완료
- [ ] `terraform init` 성공

---

## 🛠️ Step 2: VPC 네트워크 구성 (10분)

### 📋 이 단계에서 할 일
- VPC 생성
- Public/Private Subnet 생성 (Multi-AZ)
- Internet Gateway 생성
- **NAT Gateway 생성** (Private Subnet → Internet)
- Route Table 설정

### 🔗 참조 개념
- [Session 1: EC2 & ALB](./session_1.md) - VPC, Subnet 개념

### 📝 실습 절차

#### 2-1. VPC 리소스 작성 (vpc.tf)
```hcl
# vpc.tf

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 1)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.project_name}-public-${var.availability_zones[count.index]}"
    Type = "Public"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 11)
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name = "${var.project_name}-private-${var.availability_zones[count.index]}"
    Type = "Private"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  
  tags = {
    Name = "${var.project_name}-nat-eip"
  }
  
  depends_on = [aws_internet_gateway.main]
}

# NAT Gateway (⚠️ 중요: Private Subnet에서 인터넷 접근 필수)
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  
  tags = {
    Name = "${var.project_name}-nat-gw"
  }
  
  depends_on = [aws_internet_gateway.main]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Private Route Table (⚠️ NAT Gateway 경유)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  
  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

# Public Subnet Route Table Association
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Subnet Route Table Association
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
```

**⚠️ 주의사항**:
- **NAT Gateway 필수**: Private Subnet의 ECS Task가 ECR에서 이미지를 Pull하려면 인터넷 접근 필요
- **Elastic IP**: NAT Gateway에 고정 IP 할당
- **Route Table**: Private Subnet의 0.0.0.0/0 트래픽을 NAT Gateway로 라우팅

#### 2-2. VPC 배포
```bash
terraform plan
terraform apply -auto-approve
```

**예상 결과**:
```
Apply complete! Resources: 13 added, 0 changed, 0 destroyed.

Outputs:
vpc_id = "vpc-xxxxx"
public_subnet_ids = ["subnet-xxxxx", "subnet-yyyyy"]
private_subnet_ids = ["subnet-zzzzz", "subnet-wwwww"]
nat_gateway_id = "nat-xxxxx"
```

### ✅ Step 2 검증
```bash
# VPC 확인
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=nw3-day2-lab1-vpc"

# NAT Gateway 확인
aws ec2 describe-nat-gateways --filter "Name=tag:Name,Values=nw3-day2-lab1-nat-gw"
```

**체크리스트**:
- [ ] VPC 생성 완료
- [ ] Public Subnet 2개 생성 (Multi-AZ)
- [ ] Private Subnet 2개 생성 (Multi-AZ)
- [ ] Internet Gateway 생성
- [ ] **NAT Gateway 생성** (중요!)
- [ ] Route Table 설정 완료

---

## 🛠️ Step 3: ECR Repository 및 이미지 Push (5분)

### 📋 이 단계에서 할 일
- ECR Repository 생성
- 샘플 Docker 이미지 빌드
- ECR에 이미지 Push

### 🔗 참조 개념
- [Session 2: ECR](./session_2.md) - ECR Repository, Image Push

### 📝 실습 절차

#### 3-1. ECR 리소스 작성 (ecr.tf)
```hcl
# ecr.tf
resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}-app"
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }
  
  tags = {
    Name = "${var.project_name}-app"
  }
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name
  
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}
```

#### 3-2. 샘플 애플리케이션 작성
```bash
# app/Dockerfile
cat > app/Dockerfile <<'EOF'
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

# app/index.html
cat > app/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>NW3 Day2 Lab1</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            text-align: center;
        }
        h1 { font-size: 3em; margin-bottom: 0.5em; }
        p { font-size: 1.5em; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 ECS Fargate</h1>
        <p>November Week 3 Day 2 Lab 1</p>
        <p>Terraform + ECR + ALB + ECS</p>
    </div>
</body>
</html>
EOF
```

#### 3-3. outputs.tf에 ECR URL 추가 (먼저!)
```hcl
# outputs.tf
output "ecr_repository_url" {
  description = "ECR Repository URL"
  value       = aws_ecr_repository.app.repository_url
}
```

#### 3-4. ECR 배포 및 이미지 Push
```bash
# ECR Repository 생성
terraform apply -target=aws_ecr_repository.app -auto-approve

# ECR URL 확인 (output 사용 가능)
ECR_URL=$(terraform output -raw ecr_repository_url)
echo "ECR Repository URL: $ECR_URL"

# ECR 로그인
aws ecr get-login-password --region ap-northeast-2 | \
  docker login --username AWS --password-stdin $ECR_URL

# Docker 이미지 빌드
cd app
docker build -t nw3-day2-lab1-app .

# 이미지 태그
docker tag nw3-day2-lab1-app:latest ${ECR_URL}:latest

# 이미지 Push
docker push ${ECR_URL}:latest

cd ..
```

### ✅ Step 3 검증
```bash
# ECR 이미지 확인
aws ecr describe-images \
  --repository-name nw3-day2-lab1-app \
  --region ap-northeast-2
```

**체크리스트**:
- [ ] ECR Repository 생성 완료
- [ ] Docker 이미지 빌드 완료
- [ ] ECR에 이미지 Push 완료
- [ ] 이미지 스캔 결과 확인

---

## 🛠️ Step 4: ALB 및 Security Groups (5분)

### 📋 이 단계에서 할 일
- Security Groups 생성 (ALB, ECS Tasks)
- Application Load Balancer 생성
- Target Group 생성

### 🔗 참조 개념
- [Session 1: EC2 & ALB](./session_1.md) - ALB, Target Group, Health Check

### 📝 실습 절차

#### 4-1. Security Groups 작성 (alb.tf 상단)
```hcl
# alb.tf

# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from anywhere"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }
  
  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# ECS Tasks Security Group
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project_name}-ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "Allow HTTP from ALB"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound (ECR Pull via NAT Gateway)"
  }
  
  tags = {
    Name = "${var.project_name}-ecs-tasks-sg"
  }
}
```

#### 4-2. ALB 리소스 작성 (alb.tf 하단)
```hcl
# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id
  
  enable_deletion_protection = false
  
  tags = {
    Name = "${var.project_name}-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "app" {
  name        = "${var.project_name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"  # Fargate는 ip 타입 필수
  
  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }
  
  deregistration_delay = 30
  
  tags = {
    Name = "${var.project_name}-tg"
  }
}

# Listener
resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
```

#### 4-3. ALB 배포
```bash
terraform apply -auto-approve
```

### ✅ Step 4 검증
```bash
# ALB DNS 확인
terraform output alb_dns_name

# ALB 상태 확인
aws elbv2 describe-load-balancers \
  --names nw3-day2-lab1-alb
```

**체크리스트**:
- [ ] Security Groups 생성 (ALB, ECS Tasks)
- [ ] ALB 생성 완료
- [ ] Target Group 생성 완료
- [ ] Listener 설정 완료

---

## 🛠️ Step 5: IAM Roles 및 ECS 배포 (10분)

### 📋 이 단계에서 할 일
- IAM Roles 생성 (Execution Role, Task Role)
- ECS Cluster 생성
- Task Definition 작성
- ECS Service 배포

### 🔗 참조 개념
- [Session 3: ECS](./session_3.md) - Cluster, Task Definition, Service

### 📝 실습 절차

#### 5-1. IAM Roles 작성 (iam.tf)
```hcl
# iam.tf

# ECS Task Execution Role (ECR Pull, CloudWatch Logs)
resource "aws_iam_role" "ecs_execution" {
  name = "${var.project_name}-ecs-execution-role"
  
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
    Name = "${var.project_name}-ecs-execution-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Role (애플리케이션 권한)
resource "aws_iam_role" "ecs_task" {
  name = "${var.project_name}-ecs-task-role"
  
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
    Name = "${var.project_name}-ecs-task-role"
  }
}
```

#### 5-2. ECS 리소스 작성 (ecs.tf)
```hcl
# ecs.tf

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  
  tags = {
    Name = "${var.project_name}-cluster"
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.project_name}-app"
  retention_in_days = 7
  
  tags = {
    Name = "${var.project_name}-app-logs"
  }
}

# Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  
  container_definitions = jsonencode([{
    name  = "app"
    image = "${aws_ecr_repository.app.repository_url}:latest"
    
    portMappings = [{
      containerPort = 80
      protocol      = "tcp"
    }]
    
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.app.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
    
    environment = [
      { name = "ENVIRONMENT", value = var.environment }
    ]
  }])
  
  tags = {
    Name = "${var.project_name}-app-task"
  }
}

# ECS Service
resource "aws_ecs_service" "app" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets          = aws_subnet.private[*].id  # Private Subnet 배포
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false  # Private Subnet이므로 false
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = 80
  }
  
  depends_on = [
    aws_lb_listener.app,
    aws_iam_role_policy_attachment.ecs_execution
  ]
  
  tags = {
    Name = "${var.project_name}-service"
  }
}
```

**⚠️ 중요 포인트**:
- **Private Subnet 배포**: `subnets = aws_subnet.private[*].id`
- **Public IP 비활성화**: `assign_public_ip = false`
- **NAT Gateway 필수**: Private Subnet에서 ECR 이미지 Pull을 위해 NAT Gateway 필요

#### 5-3. 전체 스택 배포
```bash
terraform apply -auto-approve
```

**예상 결과**:
```
Apply complete! Resources: 25 added, 0 changed, 0 destroyed.

Outputs:
alb_dns_name = "nw3-day2-lab1-alb-xxxxx.ap-northeast-2.elb.amazonaws.com"
ecs_cluster_name = "nw3-day2-lab1-cluster"
ecs_service_name = "nw3-day2-lab1-service"
```

#### 5-4. outputs.tf 완성
```hcl
# outputs.tf
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.main.id
}

output "ecr_repository_url" {
  description = "ECR Repository URL"
  value       = aws_ecr_repository.app.repository_url
}

output "alb_dns_name" {
  description = "ALB DNS Name"
  value       = aws_lb.main.dns_name
}

output "ecs_cluster_name" {
  description = "ECS Cluster Name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS Service Name"
  value       = aws_ecs_service.app.name
}
```

### ✅ Step 5 검증
```bash
# ECS Service 상태 확인
aws ecs describe-services \
  --cluster nw3-day2-lab1-cluster \
  --services nw3-day2-lab1-service

# Task 실행 확인
aws ecs list-tasks \
  --cluster nw3-day2-lab1-cluster \
  --service-name nw3-day2-lab1-service
```

**체크리스트**:
- [ ] IAM Roles 생성 완료
- [ ] ECS Cluster 생성 완료
- [ ] Task Definition 작성 완료
- [ ] ECS Service 배포 완료 (Private Subnet)
- [ ] Task 2개 Running 상태

---

## 🛠️ Step 6: 전체 시스템 테스트 (5분)

### 📋 테스트 시나리오
1. ALB를 통한 웹 접근 테스트
2. Task 로그 확인
3. Health Check 상태 확인
4. NAT Gateway 트래픽 확인

### 🧪 테스트 실행

#### 테스트 1: 웹 접근 테스트
```bash
# ALB DNS 확인
ALB_DNS=$(terraform output -raw alb_dns_name)
echo "ALB URL: http://$ALB_DNS"

# 웹 브라우저에서 접근 또는 curl
curl http://$ALB_DNS

# 여러 번 요청하여 로드 밸런싱 확인
for i in {1..10}; do
  curl -s http://$ALB_DNS | grep "ECS Fargate"
  sleep 1
done
```

**예상 결과**:
```html
<!DOCTYPE html>
<html>
<head>
    <title>NW3 Day2 Lab1</title>
...
        <h1>🚀 ECS Fargate</h1>
        <p>November Week 3 Day 2 Lab 1</p>
...
```

#### 테스트 2: Task 로그 확인
```bash
# CloudWatch Logs 확인
aws logs tail /ecs/nw3-day2-lab1-app --follow
```

#### 테스트 3: Health Check 상태
```bash
# Target Group Health 확인
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw target_group_arn)
```

**예상 결과**:
```json
{
  "TargetHealthDescriptions": [
    {
      "Target": {
        "Id": "10.0.11.x",
        "Port": 80
      },
      "HealthCheckPort": "80",
      "TargetHealth": {
        "State": "healthy"
      }
    },
    {
      "Target": {
        "Id": "10.0.12.x",
        "Port": 80
      },
      "HealthCheckPort": "80",
      "TargetHealth": {
        "State": "healthy"
      }
    }
  ]
}
```

#### 테스트 4: NAT Gateway 트래픽 확인
```bash
# NAT Gateway 메트릭 확인 (CloudWatch)
aws cloudwatch get-metric-statistics \
  --namespace AWS/NATGateway \
  --metric-name BytesOutToSource \
  --dimensions Name=NatGatewayId,Value=$(terraform output -raw nat_gateway_id) \
  --start-time $(date -u -d '10 minutes ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum
```

### ✅ 전체 검증 체크리스트
- [ ] ALB를 통한 웹 접근 성공
- [ ] 웹 페이지 정상 표시
- [ ] Task 로그 정상 출력
- [ ] Target Health: healthy (2개)
- [ ] NAT Gateway 트래픽 확인

---

## 🧹 리소스 정리 (필수)

### ⚠️ 중요: 반드시 순서대로 삭제

**삭제 순서**:
```
ECS Service → Task Definition → ECS Cluster → ALB → Target Group → 
NAT Gateway → EIP → Subnets → Route Tables → Internet Gateway → VPC → 
ECR Repository → IAM Roles → CloudWatch Logs
```

### 🗑️ 삭제 절차

#### 1. Terraform으로 전체 삭제
```bash
terraform destroy -auto-approve
```

**예상 결과**:
```
Destroy complete! Resources: 25 destroyed.
```

#### 2. 수동 확인 (필요시)
```bash
# VPC 삭제 확인
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=NW3-Day2-Lab1"

# ECR 이미지 삭제 확인
aws ecr describe-repositories --repository-names nw3-day2-lab1-app
```

### ✅ 정리 완료 확인
- [ ] ECS Service 삭제
- [ ] ECS Cluster 삭제
- [ ] ALB 삭제
- [ ] NAT Gateway 삭제
- [ ] VPC 삭제
- [ ] ECR Repository 삭제
- [ ] IAM Roles 삭제

---

## 💰 비용 확인

### 예상 비용 계산
| 리소스 | 사용 시간 | 단가 | 예상 비용 |
|--------|----------|------|-----------|
| **NAT Gateway** | 40분 | $0.045/hour | $0.03 |
| **ECS Fargate** (0.25 vCPU, 0.5GB, 2 Tasks) | 40분 | $0.02468/hour | $0.02 |
| **ALB** | 40분 | $0.0225/hour | $0.015 |
| **ECR Storage** | 500MB | $0.10/GB/month | $0.001 |
| **합계** | | | **$0.066** |

**실제 비용**: 약 80원 (환율 1,200원 기준)

---

## 🔍 트러블슈팅

### 문제 1: ECS Task가 시작되지 않음
**증상**:
```
Task failed to start: CannotPullContainerError
```

**원인**:
- NAT Gateway 미설정
- Private Subnet에서 인터넷 접근 불가

**해결 방법**:
```bash
# NAT Gateway 확인
terraform state show aws_nat_gateway.main

# Private Route Table 확인
terraform state show aws_route_table.private

# 0.0.0.0/0 → NAT Gateway 라우팅 확인
```

### 문제 2: ALB Health Check 실패
**증상**:
```
Target health: unhealthy
```

**원인**:
- Security Group 설정 오류
- Task가 80 포트로 응답하지 않음

**해결 방법**:
```bash
# Security Group 확인
aws ec2 describe-security-groups \
  --group-ids $(terraform output -raw ecs_tasks_sg_id)

# Task 로그 확인
aws logs tail /ecs/nw3-day2-lab1-app
```

### 문제 3: NAT Gateway 비용 우려
**증상**:
- NAT Gateway 시간당 $0.045 비용 발생

**해결 방법**:
- 실습 완료 후 즉시 `terraform destroy`
- 또는 Public Subnet에 Task 배포 (보안 취약, 비권장)

---

## 💡 Lab 회고

### 🤝 페어 회고 (5분)
1. **가장 어려웠던 부분**: NAT Gateway 설정? Private Subnet 배포?
2. **새로 배운 점**: Terraform으로 전체 스택 자동화
3. **실무 적용 아이디어**: 어떤 프로젝트에 적용할 수 있을까?

### 📊 학습 성과
- **기술적 성취**: VPC부터 ECS까지 전체 인프라 코드화
- **이해도 향상**: Private Subnet + NAT Gateway의 필요성
- **실무 연계**: 프로덕션급 컨테이너 배포 경험

---

## 🔗 관련 자료

### 📚 Session 복습
- [Session 1: EC2 & ALB](./session_1.md)
- [Session 2: ECR](./session_2.md)
- [Session 3: ECS](./session_3.md)

### 📖 AWS 공식 문서
- [VPC 사용자 가이드](https://docs.aws.amazon.com/vpc/latest/userguide/)
- [ECR 사용자 가이드](https://docs.aws.amazon.com/AmazonECR/latest/userguide/)
- [ECS 사용자 가이드](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/)

### 🎯 다음 학습
- **Week 3 Day 3**: Terraform State 관리 및 Module 작성
- **Week 3 Day 4**: 고급 Terraform 기술 및 실전 프로젝트

---

<div align="center">

**✅ Lab 완료** • **🧹 리소스 정리 필수** • **💰 비용 확인** • **🚀 프로덕션급 배포**

*NAT Gateway를 통한 Private Subnet 배포 완성!*

</div>
