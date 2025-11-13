# November Week 3 Day 2 Session 1: EC2 & ALB

<div align="center">

**💻 EC2 Instance** • **⚖️ Application Load Balancer** • **🔍 Data Source** • **📝 Terraform**

*Terraform으로 가상 서버 및 로드 밸런서 완전 코드화*

</div>

---

## 🕘 세션 정보
**시간**: 09:00-09:40 (40분)
**목표**: EC2 인스턴스 및 ALB를 Terraform으로 코드화
**방식**: 이론 설명 + 실습 예제

## 🎯 학습 목표
- **Data Source**: 최신 AMI 자동 선택
- **EC2 Instance**: 가상 서버 코드화
- **User Data**: 초기화 스크립트 자동화
- **ALB**: Application Load Balancer 구성
- **Target Group**: Health Check 및 라우팅

---

## 📖 서비스 개요

### 1. 생성 배경 (Why?) - 5분

**문제 상황**:
- **수동 배포**: 콘솔에서 클릭으로 EC2 생성 (반복 작업, 실수 가능)
- **AMI 관리**: 최신 AMI ID를 수동으로 찾아서 입력
- **초기화 작업**: 서버마다 SSH 접속하여 수동 설정
- **로드 밸런서**: 여러 서버에 트래픽 분산 필요
- **고가용성**: 서버 장애 시 자동 복구 필요

**🏠 실생활 비유**:
**EC2**: 아파트 한 채를 빌리는 것
- 원하는 크기(인스턴스 타입) 선택
- 위치(AZ) 선택
- 보안(Security Group) 설정

**ALB**: 아파트 단지 입구의 경비실
- 방문자(트래픽)를 적절한 동(서버)으로 안내
- 각 동의 상태(Health Check) 확인
- 문제 있는 동은 방문 제한

**Terraform 솔루션**:
- **코드로 관리**: 모든 설정을 코드로 버전 관리
- **자동 AMI 선택**: Data Source로 최신 AMI 자동 선택
- **User Data**: 초기화 스크립트 자동 실행
- **ALB 자동 구성**: 로드 밸런서 및 Health Check 자동 설정
- **재현 가능**: 동일한 환경을 언제든 재생성

### 2. 핵심 원리 (How?) - 10분

**작동 원리**:

```mermaid
graph TB
    subgraph "Terraform 실행"
        A[terraform apply] --> B[Data Source<br/>최신 AMI 조회]
        B --> C[EC2 Instance<br/>생성]
        C --> D[User Data<br/>초기화]
        D --> E[ALB<br/>생성]
        E --> F[Target Group<br/>등록]
        F --> G[Health Check<br/>시작]
    end
    
    subgraph "트래픽 흐름"
        H[사용자] --> I[ALB]
        I --> J{Health Check}
        J -->|Healthy| K[EC2-1]
        J -->|Healthy| L[EC2-2]
        J -->|Unhealthy| M[EC2-3<br/>제외]
    end
    
    style A fill:#e8f5e8
    style B fill:#fff3e0
    style C fill:#ffebee
    style D fill:#e3f2fd
    style E fill:#f3e5f5
    style F fill:#e8f5e8
    style G fill:#fff3e0
    style I fill:#ffebee
    style K fill:#e8f5e8
    style L fill:#e8f5e8
    style M fill:#ffebee
```

**1. Data Source로 AMI 자동 선택**:

```hcl
# 최신 Amazon Linux 2 AMI 자동 선택
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 인스턴스에서 사용
resource "aws_instance" "web" {
  ami = data.aws_ami.amazon_linux_2.id  # 자동으로 최신 AMI 사용
  # ...
}
```

**장점**:
- 항상 최신 AMI 사용
- AMI ID 하드코딩 불필요
- 리전별 AMI ID 차이 자동 처리

**2. EC2 Instance 생성**:

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public.id
  
  vpc_security_group_ids = [aws_security_group.web.id]
  
  # User Data로 초기화 자동화
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              docker run -d -p 80:80 nginx:alpine
              EOF
  
  tags = {
    Name = "web-server"
  }
}
```

**User Data 실행 과정**:
1. EC2 인스턴스 부팅
2. User Data 스크립트 자동 실행 (root 권한)
3. Docker 설치 및 시작
4. Nginx 컨테이너 실행

**3. Application Load Balancer**:

```hcl
# ALB
resource "aws_lb" "main" {
  name               = "main-alb"
  internal           = false  # 인터넷 연결
  load_balancer_type = "application"  # Layer 7
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id  # 여러 AZ
  
  tags = {
    Name = "main-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "main" {
  name     = "main-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  
  # Health Check 설정
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Listener (트래픽 수신)
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# Target 등록
resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.web.id
  port             = 80
}
```

**ALB 동작 과정**:
1. **사용자 요청**: ALB DNS로 HTTP 요청
2. **Listener 수신**: 포트 80에서 요청 수신
3. **Health Check**: Target의 건강 상태 확인
4. **라우팅**: Healthy Target으로 요청 전달
5. **응답**: Target의 응답을 사용자에게 반환

**Health Check 동작**:
```
매 30초마다 (interval)
  → GET / 요청 (path)
  → 5초 대기 (timeout)
  → 200 응답 확인 (matcher)
  
2번 연속 성공 (healthy_threshold) → Healthy
2번 연속 실패 (unhealthy_threshold) → Unhealthy
```

### 3. 주요 사용 사례 (When?) - 5분

**적합한 경우**:

**1. 웹 애플리케이션 호스팅**:
```hcl
# 웹 서버 + ALB
resource "aws_instance" "web" {
  count = 3  # 3개 서버
  
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
  
  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd
              systemctl start httpd
              echo "Server ${count.index}" > /var/www/html/index.html
              EOF
}

# ALB로 트래픽 분산
resource "aws_lb" "web" {
  # ... ALB 설정 ...
}
```

**2. API 서버 배포**:
```hcl
# API 서버
resource "aws_instance" "api" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.small"
  
  user_data = <<-EOF
              #!/bin/bash
              yum install -y nodejs npm
              npm install -g pm2
              # API 서버 시작
              EOF
}

# ALB로 API 엔드포인트 제공
resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.main.arn
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
  
  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}
```

**3. 마이크로서비스 아키텍처**:
```hcl
# 서비스별 Target Group
resource "aws_lb_target_group" "auth" {
  name = "auth-service-tg"
  # ...
}

resource "aws_lb_target_group" "user" {
  name = "user-service-tg"
  # ...
}

# 경로 기반 라우팅
resource "aws_lb_listener_rule" "auth" {
  # /auth/* → auth-service
}

resource "aws_lb_listener_rule" "user" {
  # /user/* → user-service
}
```

**실제 사례**:
- **Netflix**: 수천 개의 EC2 인스턴스 + ALB로 글로벌 서비스
- **Airbnb**: 마이크로서비스 아키텍처 + ALB 경로 라우팅
- **Slack**: Auto Scaling + ALB로 트래픽 급증 대응

### 4. 비슷한 서비스 비교 (Which?) - 5분

**AWS 내 대안 서비스**:

**EC2** vs **Lambda**:
- **언제 EC2 사용**: 지속적 실행, 상태 유지, 커스터마이징 필요
- **언제 Lambda 사용**: 이벤트 기반, 짧은 실행, 서버리스

**ALB** vs **NLB** vs **CLB**:
- **언제 ALB 사용**: HTTP/HTTPS, 경로 라우팅, 웹 애플리케이션
- **언제 NLB 사용**: TCP/UDP, 초고성능, 고정 IP 필요
- **언제 CLB 사용**: 레거시 (신규는 ALB/NLB 권장)

**선택 기준**:
| 기준 | EC2 | Lambda | Fargate |
|------|-----|--------|---------|
| **비용** | 시간당 과금 | 실행 시간만 | 실행 시간만 |
| **관리** | 서버 관리 필요 | 서버리스 | 서버리스 |
| **확장성** | Auto Scaling | 자동 확장 | 자동 확장 |
| **적합한 규모** | 중대형 | 소형 | 중형 |
| **실행 시간** | 무제한 | 15분 제한 | 무제한 |

| 기준 | ALB | NLB | CLB |
|------|-----|-----|-----|
| **계층** | Layer 7 (HTTP) | Layer 4 (TCP) | Layer 4/7 |
| **성능** | 중간 | 매우 높음 | 낮음 |
| **기능** | 경로 라우팅, 호스트 기반 | 고정 IP, 초저지연 | 기본 |
| **비용** | 중간 | 중간 | 낮음 |
| **적합한 경우** | 웹 앱, API | 게임, IoT | 레거시 |

### 5. 장단점 분석 - 3분

**EC2 장점**:
- ✅ **완전한 제어**: OS, 소프트웨어 자유롭게 설치
- ✅ **유연성**: 모든 워크로드 실행 가능
- ✅ **성능**: 전용 리소스 사용
- ✅ **비용 효율**: Reserved Instance로 최대 72% 할인

**EC2 단점/제약사항**:
- ⚠️ **관리 부담**: OS 패치, 보안 업데이트 필요
- ⚠️ **확장 복잡도**: Auto Scaling 설정 필요
- ⚠️ **초기 비용**: 항상 실행 중이면 비용 발생
- ⚠️ **장애 대응**: 서버 장애 시 수동 복구

**ALB 장점**:
- ✅ **고가용성**: 여러 AZ에 자동 분산
- ✅ **Health Check**: 자동 장애 감지 및 제외
- ✅ **경로 라우팅**: URL 기반 트래픽 분산
- ✅ **SSL 종료**: HTTPS 처리 오프로드

**ALB 단점/제약사항**:
- ⚠️ **비용**: 시간당 $0.0225 + 데이터 처리 비용
- ⚠️ **Layer 7만**: TCP/UDP는 NLB 필요
- ⚠️ **고정 IP 불가**: DNS 이름만 제공
- ⚠️ **WebSocket 제한**: 일부 프로토콜 제약

**대안**:
- **서버리스**: Lambda + API Gateway (관리 부담 제거)
- **컨테이너**: ECS Fargate (서버 관리 불필요)
- **NLB**: TCP/UDP 트래픽 처리

### 6. 비용 구조 💰 - 5분

**과금 방식**:

**EC2 비용**:
- **On-Demand**: 초 단위 과금 (최소 60초)
- **Reserved Instance**: 1-3년 약정 (최대 72% 할인)
- **Spot Instance**: 경매 방식 (최대 90% 할인)

**ALB 비용**:
- **시간당**: $0.0225/hour
- **LCU (Load Balancer Capacity Unit)**: $0.008/LCU-hour
  - 신규 연결: 25/초
  - 활성 연결: 3,000개
  - 처리량: 1GB/hour
  - 규칙 평가: 1,000/초

**프리티어 혜택** (12개월):
- **EC2**: t2.micro/t3.micro 750시간/월 무료
- **ALB**: 750시간/월 + 15 LCU 무료
- **EBS**: 30GB 무료

**비용 최적화 팁**:
1. **인스턴스 타입 최적화**: 워크로드에 맞는 타입 선택
2. **Reserved Instance**: 장기 워크로드는 RI 구매
3. **Spot Instance**: 중단 가능한 워크로드는 Spot 사용
4. **Auto Scaling**: 필요할 때만 인스턴스 실행
5. **ALB 통합**: 여러 서비스를 하나의 ALB로 통합

**예상 비용 (ap-northeast-2)**:
| 리소스 | 사양 | 시간당 | 월간 (730시간) |
|--------|------|--------|----------------|
| t3.micro | 2 vCPU, 1GB | $0.0104 | $7.59 |
| t3.small | 2 vCPU, 2GB | $0.0208 | $15.18 |
| t3.medium | 2 vCPU, 4GB | $0.0416 | $30.37 |
| ALB | 기본 | $0.0225 | $16.43 |
| ALB LCU | 평균 10 LCU | $0.08 | $58.40 |

**Lab 예상 비용** (1시간):
- EC2 t3.micro × 2: $0.0208
- ALB: $0.0225
- 합계: ~$0.05

### 7. 최신 업데이트 🆕 - 2분

**2024년 주요 변경사항**:
- **EC2**: Graviton3 인스턴스 (40% 성능 향상)
- **ALB**: Automatic Target Weights (ATW) - 자동 트래픽 조정
- **ALB**: Least Outstanding Requests 알고리즘 추가
- **EC2**: Nitro System v5 (보안 강화)

**2025년 예정**:
- **EC2**: Graviton4 프로세서 출시
- **ALB**: 더 많은 라우팅 규칙 지원
- **EC2**: 더 큰 인스턴스 타입

**참조**: 
- [EC2 What's New](https://aws.amazon.com/ec2/whats-new/)
- [ALB What's New](https://aws.amazon.com/elasticloadbalancing/whats-new/)

### 8. 잘 사용하는 방법 ✅ - 3분

**베스트 프랙티스**:

**EC2**:
1. **IAM Role 사용**: Access Key 대신 IAM Role
2. **태그 전략**: 비용 추적을 위한 체계적 태그
3. **AMI 백업**: 정기적인 AMI 생성
4. **모니터링**: CloudWatch 알람 설정
5. **보안 그룹**: 최소 권한 원칙

**ALB**:
1. **Multi-AZ 배포**: 최소 2개 AZ 사용
2. **Health Check 최적화**: 적절한 threshold 설정
3. **Access Logs**: S3에 로그 저장
4. **SSL/TLS**: ACM 인증서 사용
5. **WAF 통합**: 보안 강화

**Terraform 코드 예시**:
```hcl
# ✅ 좋은 예: Data Source로 최신 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# ✅ 좋은 예: IAM Role 사용
resource "aws_iam_role" "ec2" {
  name = "ec2-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_instance_profile" "ec2" {
  name = "ec2-profile"
  role = aws_iam_role.ec2.name
}

resource "aws_instance" "web" {
  ami                  = data.aws_ami.amazon_linux_2.id
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2.name
  
  tags = {
    Name        = "web-server"
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}

# ✅ 좋은 예: Multi-AZ ALB
resource "aws_lb" "main" {
  name               = "main-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id  # 여러 AZ
  
  enable_deletion_protection = true  # 실수 삭제 방지
  
  access_logs {
    bucket  = aws_s3_bucket.alb_logs.id
    enabled = true
  }
}
```

**실무 팁**:
- **User Data 분리**: 복잡한 스크립트는 별도 파일로 관리
- **변수 활용**: 환경별 설정을 변수로 분리
- **모듈화**: 재사용 가능한 모듈 작성

### 9. 잘못 사용하는 방법 ❌ - 3분

**흔한 실수**:

**EC2**:
1. **Root 계정 사용**: IAM User/Role 대신 Root 사용
2. **Security Group 전체 오픈**: 0.0.0.0/0 SSH 허용
3. **Access Key 하드코딩**: 코드에 키 포함
4. **백업 없음**: AMI 스냅샷 미생성
5. **모니터링 미설정**: 장애 감지 불가

**ALB**:
1. **단일 AZ**: 고가용성 부족
2. **Health Check 미설정**: 장애 서버 계속 사용
3. **로그 미활성화**: 문제 추적 불가
4. **SSL 미적용**: HTTP만 사용
5. **과도한 규칙**: 성능 저하

**안티 패턴**:
```hcl
# ❌ 나쁜 예: AMI ID 하드코딩
resource "aws_instance" "web" {
  ami = "ami-0c55b159cbfafe1f0"  # 리전별로 다름, 오래됨
  # ...
}

# ❌ 나쁜 예: Access Key 하드코딩
resource "aws_instance" "web" {
  user_data = <<-EOF
              #!/bin/bash
              export AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
              export AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
              EOF
}

# ❌ 나쁜 예: Security Group 전체 오픈
resource "aws_security_group" "web" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # 전 세계에 SSH 오픈!
  }
}

# ❌ 나쁜 예: 단일 AZ ALB
resource "aws_lb" "main" {
  subnets = [aws_subnet.public_a.id]  # 1개 AZ만
}

# ❌ 나쁜 예: Health Check 없음
resource "aws_lb_target_group" "main" {
  # health_check 블록 없음
}
```

**보안 취약점**:
- **Public Subnet에 DB**: Private Subnet 필수
- **SSH 키 공유**: 개인별 키 사용
- **패치 미적용**: 정기 업데이트 필수
- **로그 미저장**: 감사 추적 불가

### 10. 구성 요소 상세 - 5분

**주요 구성 요소**:

**1. EC2 Instance**:
- **역할**: 가상 서버
- **구성 요소**:
  - AMI: OS 이미지
  - Instance Type: CPU, 메모리 사양
  - EBS Volume: 스토리지
  - Network Interface: 네트워크 카드
  - Security Group: 방화벽
  - IAM Role: 권한

**2. Data Source**:
- **역할**: 외부 데이터 조회
- **사용 예**:
  ```hcl
  data "aws_ami" "latest" {
    most_recent = true
    owners      = ["amazon"]
    
    filter {
      name   = "name"
      values = ["amzn2-ami-hvm-*"]
    }
  }
  ```

**3. Application Load Balancer**:
- **역할**: Layer 7 로드 밸런싱
- **구성 요소**:
  - Listener: 트래픽 수신 (포트, 프로토콜)
  - Target Group: 대상 서버 그룹
  - Health Check: 건강 상태 확인
  - Rules: 라우팅 규칙

**4. Target Group**:
- **역할**: 트래픽 대상 관리
- **설정 옵션**:
  ```hcl
  resource "aws_lb_target_group" "main" {
    name     = "main-tg"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.main.id
    
    health_check {
      path                = "/"
      protocol            = "HTTP"
      matcher             = "200"
      interval            = 30
      timeout             = 5
      healthy_threshold   = 2
      unhealthy_threshold = 2
    }
    
    stickiness {
      type            = "lb_cookie"
      cookie_duration = 86400
      enabled         = true
    }
  }
  ```

**5. User Data**:
- **역할**: 인스턴스 초기화 스크립트
- **실행 시점**: 첫 부팅 시 1회
- **권한**: root
- **예시**:
  ```bash
  #!/bin/bash
  # 패키지 업데이트
  yum update -y
  
  # Docker 설치
  yum install -y docker
  systemctl start docker
  systemctl enable docker
  
  # 애플리케이션 시작
  docker run -d -p 80:80 nginx:alpine
  ```

**의존성**:
- **VPC**: EC2와 ALB의 네트워크 환경
- **Subnet**: 리소스 배치 위치
- **Security Group**: 트래픽 제어
- **IAM Role**: AWS 서비스 접근 권한

### 11. 공식 문서 링크 (필수 5개)

**⚠️ 학생들이 직접 확인해야 할 공식 문서**:
- 📘 [EC2 Instance Types](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html)
- 📗 [EC2 User Guide](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/)
- 📙 [ALB User Guide](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)
- 📕 [ALB Target Groups](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html)
- 🆕 [EC2 What's New](https://aws.amazon.com/ec2/whats-new/)

**Terraform 문서**:
- [AWS EC2 Instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)
- [AWS AMI Data Source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami)
- [AWS ALB](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb)
- [AWS Target Group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group)

---

## 💭 함께 생각해보기

### 🤝 페어 토론 (5분)

**토론 주제**:
1. **AMI 관리**: "Data Source로 AMI를 자동 선택하는 것의 장단점은?"
2. **User Data**: "복잡한 초기화 작업은 User Data로 하는 게 좋을까요, 아니면 AMI에 미리 구워두는 게 좋을까요?"
3. **ALB vs NLB**: "어떤 상황에서 ALB 대신 NLB를 사용해야 할까요?"

**페어 활동 가이드**:
- 👥 **자유 페어링**: 관심사나 경험이 비슷한 사람끼리
- 🔄 **역할 교대**: 5분씩 설명자/질문자 역할 바꾸기
- 📝 **핵심 정리**: 대화 내용 중 중요한 점 메모하기

### 🎯 전체 공유 (3분)
- **인사이트 공유**: 페어 토론에서 나온 좋은 아이디어
- **질문 수집**: 아직 이해가 어려운 부분
- **다음 연결**: Lab 실습과의 연결고리 확인

### 💡 이해도 체크 질문
- ✅ "Data Source와 Resource의 차이를 설명할 수 있나요?"
- ✅ "ALB의 Health Check가 어떻게 동작하는지 아시나요?"
- ✅ "User Data 스크립트는 언제 실행되나요?"

---

## 🔑 핵심 키워드

- **Data Source**: Terraform에서 외부 데이터 조회
- **AMI (Amazon Machine Image)**: EC2 인스턴스의 OS 이미지
- **User Data**: 인스턴스 초기화 스크립트
- **ALB (Application Load Balancer)**: Layer 7 로드 밸런서
- **Target Group**: ALB의 트래픽 대상 그룹
- **Health Check**: 대상 서버의 건강 상태 확인
- **Listener**: ALB의 트래픽 수신 포트
- **IAM Instance Profile**: EC2에 부여하는 IAM Role

---

## 📝 세션 마무리

### ✅ 오늘 세션 성과
- [ ] Data Source로 최신 AMI 자동 선택 방법 이해
- [ ] EC2 인스턴스 Terraform 코드 작성법 습득
- [ ] User Data로 초기화 자동화 방법 파악
- [ ] ALB 구성 요소 및 동작 원리 이해
- [ ] Health Check 설정 방법 학습

### 🎯 다음 세션 준비
- **Session 2**: ECR (Elastic Container Registry)
- **적용 내용**: 컨테이너 이미지 저장소 관리
- **준비 사항**: Docker 기본 개념 복습

---

<div align="center">

**💻 EC2** • **⚖️ ALB** • **🔍 Data Source** • **📝 Terraform**

*Session 1: EC2 & ALB 코드화 완료*

</div>

