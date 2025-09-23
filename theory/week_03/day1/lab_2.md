# Week 3 Day 1 Lab 2: EKS 클러스터 구축

<div align="center">
**☁️ AWS EKS** • **🚀 관리형 서비스** • **🔗 클라우드 통합**
*AWS의 관리형 Kubernetes로 프로덕션 수준 클러스터 구축*
</div>

---

## 🕘 실습 정보
**시간**: 14:00-14:50 (50분)
**목표**: AWS EKS 클러스터 생성 및 고급 기능 구현
**방식**: 클라우드 네이티브 실습 + 심화 기능 탐구

## 🎯 심화 목표
### 🚀 고급 기능 구현
- Lab 1의 로컬 클러스터 경험을 바탕으로 관리형 서비스 활용
- AWS 클라우드 네이티브 기능 통합 (VPC, IAM, CloudWatch)
- 프로덕션 수준의 클러스터 구성 및 보안 설정
- kubeadm vs EKS의 실질적 차이점 체험

### 🤝 협업 학습
- 팀별 EKS 클러스터 구성 및 관리
- AWS 서비스 통합 기능 탐구
- 비용 최적화 및 운영 전략 수립

---

## 📋 실습 준비 (5분)

### 환경 설정
- **AWS 계정**: AWS 계정 및 적절한 권한 확인
- **AWS CLI**: 최신 버전 설치 및 자격 증명 설정
- **kubectl**: EKS 클러스터 접근을 위한 설정
- **eksctl**: EKS 클러스터 관리 도구 (선택사항)

### 사전 확인
```bash
# AWS CLI 설치 확인
aws --version

# 자격 증명 확인
aws sts get-caller-identity

# kubectl 설치 확인
kubectl version --client

# eksctl 설치 (선택사항)
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
```

---

## 🔧 심화 구현 (45분)

### 심화 기능 1: EKS 클러스터 생성 및 구성 (20분)

#### 1-1. VPC 및 보안 그룹 설정
```bash
# VPC 정보 확인 (기존 VPC 사용 또는 새로 생성)
aws ec2 describe-vpcs --query 'Vpcs[?IsDefault==`true`]'

# 서브넷 정보 확인
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-xxxxxxxx"

# EKS용 보안 그룹 생성
aws ec2 create-security-group \
    --group-name eks-cluster-sg \
    --description "Security group for EKS cluster" \
    --vpc-id vpc-xxxxxxxx
```

#### 1-2. IAM 역할 생성
```bash
# EKS 서비스 역할 생성
cat > eks-service-role-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

aws iam create-role \
    --role-name EKS-ServiceRole \
    --assume-role-policy-document file://eks-service-role-trust-policy.json

# 필요한 정책 연결
aws iam attach-role-policy \
    --role-name EKS-ServiceRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
```

#### 1-3. EKS 클러스터 생성
```bash
# EKS 클러스터 생성
aws eks create-cluster \
    --name my-eks-cluster \
    --version 1.28 \
    --role-arn arn:aws:iam::ACCOUNT-ID:role/EKS-ServiceRole \
    --resources-vpc-config subnetIds=subnet-12345,subnet-67890,securityGroupIds=sg-12345

# 클러스터 생성 상태 확인
aws eks describe-cluster --name my-eks-cluster --query cluster.status

# 클러스터 생성 완료까지 대기 (약 10-15분)
aws eks wait cluster-active --name my-eks-cluster
```

### 심화 기능 2: 노드 그룹 및 Fargate 구성 (15분)

#### 2-1. 노드 그룹용 IAM 역할 생성
```bash
# 노드 그룹 IAM 역할 생성
cat > node-group-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

aws iam create-role \
    --role-name EKS-NodeInstanceRole \
    --assume-role-policy-document file://node-group-trust-policy.json

# 필요한 정책들 연결
aws iam attach-role-policy \
    --role-name EKS-NodeInstanceRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy

aws iam attach-role-policy \
    --role-name EKS-NodeInstanceRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy

aws iam attach-role-policy \
    --role-name EKS-NodeInstanceRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
```

#### 2-2. 노드 그룹 생성
```bash
# 노드 그룹 생성
aws eks create-nodegroup \
    --cluster-name my-eks-cluster \
    --nodegroup-name my-nodes \
    --scaling-config minSize=1,maxSize=3,desiredSize=2 \
    --disk-size 20 \
    --instance-types t3.medium \
    --ami-type AL2_x86_64 \
    --node-role arn:aws:iam::ACCOUNT-ID:role/EKS-NodeInstanceRole \
    --subnets subnet-12345 subnet-67890

# 노드 그룹 생성 상태 확인
aws eks describe-nodegroup \
    --cluster-name my-eks-cluster \
    --nodegroup-name my-nodes \
    --query nodegroup.status
```

#### 2-3. kubectl 설정 및 클러스터 접근
```bash
# kubeconfig 업데이트
aws eks update-kubeconfig --region us-west-2 --name my-eks-cluster

# 클러스터 접근 확인
kubectl get nodes

# EKS 특화 정보 확인
kubectl get nodes -o wide
kubectl get pods -A
kubectl cluster-info
```

### 심화 기능 3: AWS 서비스 통합 및 모니터링 (10분)

#### 3-1. CloudWatch 로깅 활성화
```bash
# 클러스터 로깅 활성화
aws eks update-cluster-config \
    --name my-eks-cluster \
    --logging '{"enable":["api","audit","authenticator","controllerManager","scheduler"]}'

# 로깅 상태 확인
aws eks describe-cluster \
    --name my-eks-cluster \
    --query cluster.logging
```

#### 3-2. AWS Load Balancer Controller 설치
```bash
# AWS Load Balancer Controller용 ServiceAccount 생성
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.6.0/docs/install/iam_policy.json

# Helm을 이용한 설치 (선택사항)
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=my-eks-cluster \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller
```

#### 3-3. 테스트 애플리케이션 배포
```bash
# 테스트 애플리케이션 배포
cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
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
        image: nginx:1.20
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
EOF

# 서비스 상태 확인
kubectl get services nginx-service
```

---

## ✅ 심화 체크포인트

### 고급 기능 구현 확인
- [ ] **EKS 클러스터 생성**: AWS 콘솔에서 클러스터 상태 Active 확인
- [ ] **노드 그룹 구성**: `kubectl get nodes`에서 Worker Node 2개 확인
- [ ] **VPC 통합**: Pod가 VPC IP 주소를 직접 할당받는 것 확인
- [ ] **AWS 서비스 연동**: CloudWatch 로그 및 LoadBalancer 서비스 동작 확인

### kubeadm vs EKS 비교 분석
```bash
# EKS 클러스터 정보 확인
echo "=== EKS 클러스터 정보 ==="
kubectl cluster-info

echo "=== 노드 정보 (VPC IP 확인) ==="
kubectl get nodes -o wide

echo "=== 시스템 Pod (AWS 관리 vs 사용자 관리) ==="
kubectl get pods -A

echo "=== AWS 통합 서비스 확인 ==="
kubectl get services -A
```

### 성능 및 비용 분석
- **관리 편의성**: Control Plane 관리 부담 제거
- **고가용성**: 다중 AZ 자동 배포 확인
- **보안**: IAM 통합 및 VPC 네이티브 보안
- **비용**: 시간당 $0.10 + EC2 인스턴스 비용

---

## 🎤 결과 발표 및 회고 (5분)

### 시연 및 비교
**팀별 발표** (각 2분):
- **kubeadm vs EKS 비교**: 설치 복잡성, 관리 편의성, 기능 차이
- **AWS 통합 기능**: VPC CNI, IAM 역할, CloudWatch 로깅 등
- **프로덕션 준비도**: 고가용성, 보안, 모니터링 관점에서 비교
- **비용 효율성**: 관리 비용 vs 인프라 비용 분석

### 기술적 인사이트
**핵심 발견사항**:
- **관리형 서비스의 가치**: Control Plane 관리 부담 제거의 실질적 효과
- **클라우드 네이티브 통합**: AWS 서비스와의 seamless한 연동
- **운영 복잡성**: kubeadm의 수동 설정 vs EKS의 자동화
- **확장성**: 노드 그룹 자동 스케일링 및 Fargate 옵션

### 베스트 프랙티스
**실무 적용 방안**:
- **환경별 선택**: 개발/스테이징은 EKS, 학습은 kubeadm
- **비용 최적화**: Spot 인스턴스, Fargate 활용 전략
- **보안 강화**: IAM 역할 최소 권한 원칙 적용
- **모니터링**: CloudWatch와 Prometheus 통합 운영

### 문제 해결 경험
**트러블슈팅 사례**:
- IAM 권한 설정 관련 이슈
- VPC 서브넷 구성 문제
- 노드 그룹 생성 시간 지연
- kubectl 접근 권한 설정

### 향후 발전 방향
**다음 단계 계획**:
- **Day 2 연결**: ConfigMap, Secret 등을 EKS에서 실습
- **고급 기능**: IRSA, Fargate, EKS Anywhere 탐구
- **운영 자동화**: Terraform, GitOps 파이프라인 구축
- **비용 관리**: AWS Cost Explorer를 통한 비용 분석

---

<div align="center">

**🎉 Lab 2 완료!**

*AWS EKS로 프로덕션 수준의 Kubernetes 클러스터를 완전히 마스터했습니다*

</div>