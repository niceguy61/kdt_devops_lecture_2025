#!/bin/bash

# November Week 4 Day 1 Demo: Terraform으로 EKS 클러스터 생성
# 설명: VPC + EKS Cluster + Managed Node Group 완전 자동화
# 사용법: ./setup-eks-cluster.sh

set -e

echo "=========================================="
echo "November Week 4 Day 1 Demo"
echo "Terraform으로 EKS 클러스터 생성"
echo "=========================================="
echo ""

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 필수 도구 확인
echo "1/10 필수 도구 확인 중..."
REQUIRED_TOOLS=("terraform" "aws" "kubectl")
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v $tool &> /dev/null; then
        echo -e "${RED}❌ $tool이 설치되지 않았습니다.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ $tool 설치 확인${NC}"
done

# AWS 자격증명 확인
echo ""
echo "2/10 AWS 자격증명 확인 중..."
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ AWS 자격증명이 설정되지 않았습니다.${NC}"
    echo "aws configure를 실행하여 자격증명을 설정하세요."
    exit 1
fi
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get region || echo "ap-northeast-2")
echo -e "${GREEN}✅ AWS Account: $ACCOUNT_ID${NC}"
echo -e "${GREEN}✅ Region: $REGION${NC}"

# Terraform 디렉토리 생성
echo ""
echo "3/10 Terraform 디렉토리 생성 중..."
DEMO_DIR="eks-demo-$(date +%Y%m%d-%H%M%S)"
mkdir -p $DEMO_DIR
cd $DEMO_DIR
echo -e "${GREEN}✅ 디렉토리 생성: $DEMO_DIR${NC}"

# Terraform 설정 파일 생성
echo ""
echo "4/10 Terraform 설정 파일 생성 중..."

# provider.tf
cat > provider.tf <<'EOF'
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}
EOF

# variables.tf
cat > variables.tf <<EOF
variable "region" {
  description = "AWS Region"
  type        = string
  default     = "$REGION"
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "november-week4-demo"
}

variable "cluster_version" {
  description = "Kubernetes Version"
  type        = string
  default     = "1.28"
}

variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string
  default     = "10.0.0.0/16"
}
EOF

# vpc.tf
cat > vpc.tf <<'EOF'
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = {
    Environment = "demo"
    ManagedBy   = "terraform"
    Demo        = "november-week4-day1"
  }
}
EOF

# eks.tf
cat > eks.tf <<'EOF'
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  # EKS Managed Node Group
  eks_managed_node_groups = {
    demo_nodes = {
      desired_size = 2
      min_size     = 1
      max_size     = 3

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      labels = {
        Environment = "demo"
        NodeGroup   = "demo-nodes"
      }

      tags = {
        Environment = "demo"
        ManagedBy   = "terraform"
      }
    }
  }

  # Cluster access entry
  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = "demo"
    ManagedBy   = "terraform"
    Demo        = "november-week4-day1"
  }
}
EOF

# outputs.tf
cat > outputs.tf <<'EOF'
output "cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS Region"
  value       = var.region
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "configure_kubectl" {
  description = "Configure kubectl command"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}
EOF

echo -e "${GREEN}✅ Terraform 설정 파일 생성 완료${NC}"

# Terraform 초기화
echo ""
echo "5/10 Terraform 초기화 중..."
terraform init
echo -e "${GREEN}✅ Terraform 초기화 완료${NC}"

# Terraform Plan
echo ""
echo "6/10 Terraform Plan 실행 중..."
terraform plan -out=tfplan
echo -e "${GREEN}✅ Terraform Plan 완료${NC}"

# 사용자 확인
echo ""
echo -e "${YELLOW}⚠️  EKS 클러스터를 생성하시겠습니까?${NC}"
echo "예상 시간: 약 15-20분"
echo "예상 비용: 약 $0.10/hour (Control Plane) + $0.04/hour (t3.medium x2)"
read -p "계속하시겠습니까? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy]es$ ]]; then
    echo "취소되었습니다."
    exit 0
fi

# Terraform Apply
echo ""
echo "7/10 Terraform Apply 실행 중..."
echo "⏰ 약 15-20분 소요됩니다. 커피 한 잔 하세요 ☕"
terraform apply tfplan
echo -e "${GREEN}✅ EKS 클러스터 생성 완료${NC}"

# kubectl 설정
echo ""
echo "8/10 kubectl 설정 중..."
CLUSTER_NAME=$(terraform output -raw cluster_name)
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME
echo -e "${GREEN}✅ kubectl 설정 완료${NC}"

# 클러스터 검증
echo ""
echo "9/10 클러스터 검증 중..."
echo ""
echo "=== 클러스터 정보 ==="
kubectl cluster-info
echo ""

echo "=== 노드 확인 ==="
kubectl get nodes -o wide
echo ""

echo "=== 네임스페이스 확인 ==="
kubectl get namespaces
echo ""

echo "=== 시스템 Pod 확인 ==="
kubectl get pods -n kube-system
echo ""

# 테스트 워크로드 배포
echo ""
echo "10/10 테스트 워크로드 배포 중..."

cat > test-deployment.yaml <<'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: demo
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-demo
  namespace: demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: demo
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
EOF

kubectl apply -f test-deployment.yaml
echo ""
echo "⏰ LoadBalancer 생성 대기 중 (약 2-3분)..."
sleep 30

echo ""
echo "=== 테스트 워크로드 확인 ==="
kubectl get all -n demo
echo ""

# LoadBalancer URL 확인
echo "=== LoadBalancer URL 확인 ==="
LB_URL=$(kubectl get svc nginx-service -n demo -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
if [ -n "$LB_URL" ]; then
    echo -e "${GREEN}✅ LoadBalancer URL: http://$LB_URL${NC}"
    echo "브라우저에서 접속하여 Nginx 페이지를 확인하세요."
else
    echo -e "${YELLOW}⚠️  LoadBalancer가 아직 준비되지 않았습니다.${NC}"
    echo "다음 명령어로 확인하세요:"
    echo "kubectl get svc nginx-service -n demo -w"
fi

# 최종 요약
echo ""
echo "=========================================="
echo "✅ Demo 완료!"
echo "=========================================="
echo ""
echo "📋 생성된 리소스:"
echo "  - VPC: $(terraform output -raw vpc_id)"
echo "  - EKS Cluster: $CLUSTER_NAME"
echo "  - Node Group: 2 x t3.medium"
echo "  - Test Deployment: nginx-demo (2 replicas)"
echo "  - LoadBalancer Service: nginx-service"
echo ""
echo "🔧 유용한 명령어:"
echo "  - 노드 확인: kubectl get nodes"
echo "  - Pod 확인: kubectl get pods -n demo"
echo "  - 서비스 확인: kubectl get svc -n demo"
echo "  - 로그 확인: kubectl logs -n demo -l app=nginx"
echo ""
echo "🧹 정리 방법:"
echo "  1. cd $(pwd)"
echo "  2. kubectl delete -f test-deployment.yaml"
echo "  3. terraform destroy -auto-approve"
echo ""
echo "💰 예상 비용:"
echo "  - EKS Control Plane: $0.10/hour"
echo "  - t3.medium x2: $0.0416/hour x 2 = $0.0832/hour"
echo "  - NAT Gateway: $0.045/hour"
echo "  - 합계: 약 $0.23/hour"
echo ""
echo "⚠️  데모 종료 후 반드시 리소스를 정리하세요!"
echo "=========================================="
