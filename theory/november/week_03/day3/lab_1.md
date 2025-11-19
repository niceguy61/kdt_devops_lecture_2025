# November Week 3 Day 3 Lab 1: 데이터베이스 & 메시징 스택 배포

<div align="center">

**🗄️ RDS** • **⚡ ElastiCache** • **📬 SQS** • **📢 SNS**

*Terraform으로 프로덕션급 데이터베이스 및 메시징 인프라 완전 자동화*

</div>

---

## 🕘 Lab 정보
**시간**: 11:20-12:00 (40분)
**목표**: RDS, ElastiCache, SQS, SNS를 Terraform으로 배포
**방식**: Terraform 코드 작성 및 실행

## 🎯 학습 목표
- RDS PostgreSQL Multi-AZ 구성
- ElastiCache Redis 클러스터 배포
- SQS Queue + DLQ 설정
- SNS Topic + 구독 설정
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
│  │  │  [Bastion Host]  │  │                  │       │ │
│  │  │                  │  │                  │       │ │
│  │  └────────┬─────────┘  └──────────────────┘       │ │
│  │           │                                        │ │
│  │  ┌────────┴─────────┐  ┌──────────────────┐       │ │
│  │  │ Private Subnet A │  │ Private Subnet B │       │ │
│  │  │ 10.0.11.0/24     │  │ 10.0.12.0/24     │       │ │
│  │  │                  │  │                  │       │ │
│  │  │  [RDS Primary]   │  │  [RDS Standby]   │       │ │
│  │  │  [Redis Node]    │  │  [Redis Node]    │       │ │
│  │  │                  │  │                  │       │ │
│  │  └──────────────────┘  └──────────────────┘       │ │
│  │                                                     │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │  메시징 서비스                                      │ │
│  │  - SQS Queue + DLQ                                 │ │
│  │  - SNS Topic (Email, SQS 구독)                    │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
└─────────────────────────────────────────────────────────┘

애플리케이션 → RDS (Multi-AZ) → 자동 Failover
              ↓
         ElastiCache Redis (캐싱)
              ↓
         SQS Queue (비동기 작업)
              ↓
         SNS Topic (알림)
```

### 🔗 참조 Session
**당일 Session**:
- [Session 1: RDS](./session_1.md) - Multi-AZ, Read Replica, Secrets Manager
- [Session 2: ElastiCache & SQS/SNS](./session_2.md) - Redis, 메시지 큐, Pub/Sub
- [Session 3: API Gateway & Cognito](./session_3.md) - API 통합 (선택)

**이전 Day Session**:
- [Week 3 Day 1 Session 1: Terraform 기초](../day1/session_1.md) - 변수, 리소스
- [Week 3 Day 1 Session 2: 프로그래밍 기술](../day1/session_2.md) - for_each, count

---

## 📁 프로젝트 구조

### 디렉토리 구성
```
nw3-day3-lab1/
├── main.tf              # 메인 리소스 정의
├── variables.tf         # 변수 선언
├── outputs.tf           # 출력 값
├── terraform.tfvars     # 변수 값
├── vpc.tf              # VPC 리소스
├── rds.tf              # RDS 리소스
├── elasticache.tf      # ElastiCache 리소스
├── sqs.tf              # SQS 리소스
├── sns.tf              # SNS 리소스
├── security_groups.tf  # 보안 그룹
└── test/
    └── test_connection.sh  # 연결 테스트 스크립트
```

---

## 🛠️ Step 1: 프로젝트 초기화 (5분)

### 📋 이 단계에서 할 일
- 프로젝트 디렉토리 생성
- Terraform 초기화
- Provider 설정

### 📝 실습 절차

#### 1-1. 프로젝트 디렉토리 생성
```bash
mkdir -p ~/terraform/nw3-day3-lab1/test
cd ~/terraform/nw3-day3-lab1
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
      Project     = "NW3-Day3-Lab1"
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

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "dbadmin"
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "notification_email" {
  description = "Email for SNS notifications"
  type        = string
}
```

#### 1-4. 변수 값 설정 (terraform.tfvars)
```hcl
# terraform.tfvars
aws_region         = "ap-northeast-2"
environment        = "dev"
vpc_cidr           = "10.0.0.0/16"
db_username        = "dbadmin"
db_password        = "YourSecurePassword123!"  # 실제로는 Secrets Manager 사용
notification_email = "your-email@example.com"
```

#### 1-5. Terraform 초기화
```bash
terraform init
```

### ✅ Step 1 검증
```bash
# Terraform 버전 확인
terraform version

# 설정 검증
terraform validate
```

---

## 🛠️ Step 2: VPC 네트워크 구성 (5분)

### 📋 이 단계에서 할 일
- VPC 생성
- Public/Private Subnet 생성 (Multi-AZ)
- Internet Gateway 및 NAT Gateway 설정

### 🔗 참조 개념
- [Week 3 Day 1 Session 1](../day1/session_1.md) - VPC 기본 개념

### 📝 실습 절차

#### 2-1. VPC 리소스 (vpc.tf)
```hcl
# vpc.tf
# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-${count.index + 1}"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 11}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.environment}-private-${count.index + 1}"
  }
}

# NAT Gateway (하나만 생성 - 비용 절감)
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.environment}-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.environment}-nat"
  }

  depends_on = [aws_internet_gateway.main]
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.environment}-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.environment}-private-rt"
  }
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Data Source
data "aws_availability_zones" "available" {
  state = "available"
}
```

#### 2-2. VPC 배포
```bash
terraform plan
terraform apply -auto-approve
```

### ✅ Step 2 검증
```bash
# VPC 확인
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=dev-vpc"

# Subnet 확인
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$(terraform output -raw vpc_id)"
```

---

## 🛠️ Step 3: RDS PostgreSQL 배포 (10분)

### 📋 이 단계에서 할 일
- DB Subnet Group 생성
- Security Group 설정
- RDS PostgreSQL Multi-AZ 배포
- Secrets Manager 통합 (선택)

### 🔗 참조 개념
- [Session 1: RDS](./session_1.md) - Multi-AZ, 백업 전략

### 📝 실습 절차

#### 3-1. Security Group (security_groups.tf)
```hcl
# security_groups.tf
# RDS Security Group
resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "PostgreSQL from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-rds-sg"
  }
}

# ElastiCache Security Group
resource "aws_security_group" "redis" {
  name        = "${var.environment}-redis-sg"
  description = "Security group for Redis"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Redis from VPC"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-redis-sg"
  }
}
```

#### 3-2. RDS 리소스 (rds.tf)
```hcl
# rds.tf
# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.environment}-db-subnet"
  }
}

# RDS PostgreSQL
resource "aws_db_instance" "postgres" {
  identifier     = "${var.environment}-postgres"
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = "appdb"
  username = var.db_username
  password = var.db_password

  # Multi-AZ 설정
  multi_az               = var.environment == "prod" ? true : false
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # 백업 설정
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  # 모니터링
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  monitoring_interval             = 60
  monitoring_role_arn             = aws_iam_role.rds_monitoring.arn

  # 삭제 보호
  deletion_protection = var.environment == "prod" ? true : false
  skip_final_snapshot = var.environment != "prod"
  final_snapshot_identifier = var.environment == "prod" ? "${var.environment}-postgres-final-snapshot" : null

  tags = {
    Name = "${var.environment}-postgres"
  }
}

# RDS Monitoring IAM Role
resource "aws_iam_role" "rds_monitoring" {
  name = "${var.environment}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.environment}-rds-monitoring-role"
  }
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
```

#### 3-3. RDS 배포
```bash
terraform plan
terraform apply -auto-approve
```

**⏱️ 예상 시간**: 5-10분 (RDS 인스턴스 생성)

### ✅ Step 3 검증
```bash
# RDS 상태 확인
aws rds describe-db-instances --db-instance-identifier dev-postgres

# 엔드포인트 확인
terraform output rds_endpoint
```

---


## 🛠️ Step 4: ElastiCache Redis 배포 (5분)

### 📋 이 단계에서 할 일
- ElastiCache Subnet Group 생성
- Redis 클러스터 배포

### 🔗 참조 개념
- [Session 2: ElastiCache](./session_2.md) - Redis 캐싱

### 📝 실습 절차

#### 4-1. ElastiCache 리소스 (elasticache.tf)
```hcl
# elasticache.tf
# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.environment}-redis-subnet"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.environment}-redis-subnet"
  }
}

# ElastiCache Redis
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.environment}-redis"
  engine               = "redis"
  engine_version       = "7.0"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379

  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [aws_security_group.redis.id]

  tags = {
    Name = "${var.environment}-redis"
  }
}
```

#### 4-2. ElastiCache 배포
```bash
terraform apply -auto-approve
```

### ✅ Step 4 검증
```bash
# Redis 상태 확인
aws elasticache describe-cache-clusters --cache-cluster-id dev-redis

# 엔드포인트 확인
terraform output redis_endpoint
```

---

## 🛠️ Step 5: SQS & SNS 배포 (5분)

### 📋 이 단계에서 할 일
- SQS Queue + DLQ 생성
- SNS Topic + 구독 설정

### 🔗 참조 개념
- [Session 2: SQS/SNS](./session_2.md) - 메시지 큐, Pub/Sub

### 📝 실습 절차

#### 5-1. SQS 리소스 (sqs.tf)
```hcl
# sqs.tf
# Dead Letter Queue
resource "aws_sqs_queue" "dlq" {
  name                      = "${var.environment}-dlq"
  message_retention_seconds = 1209600  # 14 days

  tags = {
    Name = "${var.environment}-dlq"
  }
}

# Main Queue
resource "aws_sqs_queue" "main" {
  name                       = "${var.environment}-queue"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 345600
  receive_wait_time_seconds  = 10
  visibility_timeout_seconds = 30

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name = "${var.environment}-queue"
  }
}
```

#### 5-2. SNS 리소스 (sns.tf)
```hcl
# sns.tf
# SNS Topic
resource "aws_sns_topic" "alerts" {
  name = "${var.environment}-alerts"

  tags = {
    Name = "${var.environment}-alerts"
  }
}

# Email Subscription
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# SQS Subscription (Fan-Out)
resource "aws_sns_topic_subscription" "sqs" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.main.arn
}

# SQS Policy for SNS
resource "aws_sqs_queue_policy" "main" {
  queue_url = aws_sqs_queue.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.main.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.alerts.arn
          }
        }
      }
    ]
  })
}
```

#### 5-3. 메시징 서비스 배포
```bash
terraform apply -auto-approve
```

### ✅ Step 5 검증
```bash
# SQS Queue 확인
aws sqs list-queues

# SNS Topic 확인
aws sns list-topics

# 이메일 구독 확인 (이메일 확인 필요)
echo "이메일 받은편지함에서 구독 확인 링크 클릭"
```

---

## 🛠️ Step 6: 출력 값 설정 및 전체 검증 (5분)

### 📋 이 단계에서 할 일
- 출력 값 정의
- 전체 스택 검증
- 연결 테스트

### 📝 실습 절차

#### 6-1. 출력 값 (outputs.tf)
```hcl
# outputs.tf
# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "Private Subnet IDs"
  value       = aws_subnet.private[*].id
}

# RDS Outputs
output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.postgres.endpoint
}

output "rds_port" {
  description = "RDS port"
  value       = aws_db_instance.postgres.port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = aws_db_instance.postgres.db_name
}

# ElastiCache Outputs
output "redis_endpoint" {
  description = "Redis endpoint"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "redis_port" {
  description = "Redis port"
  value       = aws_elasticache_cluster.redis.port
}

# SQS Outputs
output "sqs_queue_url" {
  description = "SQS Queue URL"
  value       = aws_sqs_queue.main.url
}

output "sqs_dlq_url" {
  description = "SQS DLQ URL"
  value       = aws_sqs_queue.dlq.url
}

# SNS Outputs
output "sns_topic_arn" {
  description = "SNS Topic ARN"
  value       = aws_sns_topic.alerts.arn
}

# Connection Info
output "connection_info" {
  description = "Connection information"
  value = {
    rds_endpoint   = aws_db_instance.postgres.endpoint
    redis_endpoint = "${aws_elasticache_cluster.redis.cache_nodes[0].address}:${aws_elasticache_cluster.redis.port}"
    sqs_queue_url  = aws_sqs_queue.main.url
    sns_topic_arn  = aws_sns_topic.alerts.arn
  }
}
```

#### 6-2. 전체 출력 확인
```bash
terraform output
```

#### 6-3. 연결 테스트 스크립트 (test/test_connection.sh)
```bash
#!/bin/bash
# test/test_connection.sh

echo "=== 데이터베이스 & 메시징 스택 연결 테스트 ==="
echo ""

# RDS 연결 테스트
echo "1. RDS PostgreSQL 연결 테스트"
RDS_ENDPOINT=$(terraform output -raw rds_endpoint | cut -d: -f1)
echo "RDS Endpoint: $RDS_ENDPOINT"
nc -zv $RDS_ENDPOINT 5432 2>&1 | grep -q succeeded && echo "✅ RDS 연결 성공" || echo "❌ RDS 연결 실패"
echo ""

# Redis 연결 테스트
echo "2. ElastiCache Redis 연결 테스트"
REDIS_ENDPOINT=$(terraform output -raw redis_endpoint)
echo "Redis Endpoint: $REDIS_ENDPOINT"
nc -zv $REDIS_ENDPOINT 6379 2>&1 | grep -q succeeded && echo "✅ Redis 연결 성공" || echo "❌ Redis 연결 실패"
echo ""

# SQS 테스트
echo "3. SQS Queue 테스트"
QUEUE_URL=$(terraform output -raw sqs_queue_url)
echo "Queue URL: $QUEUE_URL"
aws sqs send-message --queue-url "$QUEUE_URL" --message-body "Test message" > /dev/null 2>&1 && echo "✅ SQS 메시지 전송 성공" || echo "❌ SQS 메시지 전송 실패"
echo ""

# SNS 테스트
echo "4. SNS Topic 테스트"
TOPIC_ARN=$(terraform output -raw sns_topic_arn)
echo "Topic ARN: $TOPIC_ARN"
aws sns publish --topic-arn "$TOPIC_ARN" --message "Test notification" > /dev/null 2>&1 && echo "✅ SNS 알림 발행 성공" || echo "❌ SNS 알림 발행 실패"
echo ""

echo "=== 테스트 완료 ==="
```

#### 6-4. 테스트 실행
```bash
chmod +x test/test_connection.sh
./test/test_connection.sh
```

### ✅ Step 6 검증
- [ ] 모든 출력 값 확인
- [ ] RDS 연결 가능
- [ ] Redis 연결 가능
- [ ] SQS 메시지 전송 성공
- [ ] SNS 알림 발행 성공

---

## ✅ 실습 체크포인트

### ✅ Step 1: 프로젝트 초기화
- [ ] Terraform 초기화 완료
- [ ] Provider 설정 완료
- [ ] 변수 선언 완료

### ✅ Step 2: VPC 네트워크
- [ ] VPC 생성 완료
- [ ] Public/Private Subnet 생성 (Multi-AZ)
- [ ] NAT Gateway 설정 완료

### ✅ Step 3: RDS PostgreSQL
- [ ] DB Subnet Group 생성
- [ ] Security Group 설정
- [ ] RDS 인스턴스 생성 (Multi-AZ)
- [ ] 모니터링 설정 완료

### ✅ Step 4: ElastiCache Redis
- [ ] Redis Subnet Group 생성
- [ ] Redis 클러스터 생성
- [ ] 엔드포인트 확인

### ✅ Step 5: SQS & SNS
- [ ] SQS Queue + DLQ 생성
- [ ] SNS Topic 생성
- [ ] 이메일 구독 확인
- [ ] Fan-Out 패턴 설정

### ✅ Step 6: 전체 검증
- [ ] 모든 출력 값 확인
- [ ] 연결 테스트 성공
- [ ] 메시징 테스트 성공

---

## 🔍 트러블슈팅

### 문제 1: RDS 생성 시간 초과
**증상**:
```
Error: timeout while waiting for state to become 'available'
```

**원인**:
- RDS 인스턴스 생성은 5-10분 소요

**해결 방법**:
```bash
# 상태 확인
aws rds describe-db-instances --db-instance-identifier dev-postgres --query 'DBInstances[0].DBInstanceStatus'

# 기다리기
terraform apply -auto-approve
```

### 문제 2: SNS 이메일 구독 미확인
**증상**:
- 이메일 알림이 오지 않음

**원인**:
- 이메일 구독 확인 링크 클릭 필요

**해결 방법**:
1. 이메일 받은편지함 확인
2. "AWS Notification - Subscription Confirmation" 이메일 찾기
3. "Confirm subscription" 링크 클릭

### 문제 3: Security Group 규칙 오류
**증상**:
```
Error: creating Security Group Rule: InvalidPermission.Duplicate
```

**원인**:
- 중복된 Security Group 규칙

**해결 방법**:
```bash
# 기존 Security Group 삭제
terraform destroy -target=aws_security_group.rds
terraform apply -auto-approve
```

---

## 🧹 리소스 정리

### ⚠️ 중요: 반드시 순서대로 삭제

**삭제 순서**:
```
SNS → SQS → ElastiCache → RDS → NAT Gateway → VPC
```

### 🗑️ 삭제 절차

#### 전체 삭제
```bash
terraform destroy -auto-approve
```

**⏱️ 예상 시간**: 10-15분

#### 개별 삭제 (필요시)
```bash
# 1. SNS & SQS 삭제
terraform destroy -target=aws_sns_topic.alerts -target=aws_sqs_queue.main -auto-approve

# 2. ElastiCache 삭제
terraform destroy -target=aws_elasticache_cluster.redis -auto-approve

# 3. RDS 삭제
terraform destroy -target=aws_db_instance.postgres -auto-approve

# 4. VPC 삭제
terraform destroy -auto-approve
```

### ✅ 정리 완료 확인
```bash
# 모든 리소스 확인
terraform show

# 예상 결과: 빈 상태
```

---

## 💰 비용 확인

### 예상 비용 계산
| 리소스 | 사용 시간 | 단가 | 예상 비용 |
|--------|----------|------|-----------|
| RDS db.t3.micro | 40분 | $0.017/hour | $0.011 |
| ElastiCache cache.t3.micro | 40분 | $0.017/hour | $0.011 |
| NAT Gateway | 40분 | $0.045/hour | $0.030 |
| SQS | 100 요청 | $0.40/1M | $0.00004 |
| SNS | 10 발행 | $0.50/1M | $0.000005 |
| **합계** | | | **$0.052** |

### 실제 비용 확인
```bash
# AWS Cost Explorer에서 확인
# AWS Console → Cost Management → Cost Explorer
```

---

## 💡 Lab 회고

### 🤝 페어 회고 (5분)
1. **가장 어려웠던 부분**: RDS 생성 대기 시간? Security Group 설정?
2. **새로 배운 점**: Multi-AZ 구성? DLQ 패턴? Fan-Out 패턴?
3. **실무 적용 아이디어**: 어떤 프로젝트에 적용할 수 있을까?

### 📊 학습 성과
- **기술적 성취**: RDS, ElastiCache, SQS, SNS를 Terraform으로 완전 자동화
- **이해도 향상**: Multi-AZ, 백업 전략, 메시징 패턴 이해
- **다음 Lab 준비**: API Gateway + Lambda 통합 준비

---

## 🔗 관련 자료

### 📚 Session 복습
- [Session 1: RDS](./session_1.md)
- [Session 2: ElastiCache & SQS/SNS](./session_2.md)
- [Session 3: API Gateway & Cognito](./session_3.md)

### 📖 AWS 공식 문서
- [RDS 사용자 가이드](https://docs.aws.amazon.com/rds/)
- [ElastiCache 사용자 가이드](https://docs.aws.amazon.com/elasticache/)
- [SQS 사용자 가이드](https://docs.aws.amazon.com/sqs/)
- [SNS 사용자 가이드](https://docs.aws.amazon.com/sns/)

### 🎯 다음 Lab
- [Week 3 Day 4 Lab 1](../day4/lab_1.md) - API Gateway + Lambda 통합

---

<div align="center">

**✅ Lab 완료** • **🧹 리소스 정리 필수** • **💰 비용 확인**

*다음 Lab으로 이동하기 전 반드시 리소스 정리 확인*

</div>
