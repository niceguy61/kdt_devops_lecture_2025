# November Week 4 Day 1 강사 Demo 가이드

<div align="center">

**🎬 Terraform으로 EKS 클러스터 생성** • **⏱️ 60분** • **💰 $0.23/hour**

*완전 자동화된 EKS 클러스터 구축 데모*

</div>

---

## 🕘 Demo 정보
**시간**: 11:00-12:00 (60분)
**목표**: Terraform으로 EKS 클러스터 완전 자동 구축 시연
**방식**: 강사 계정에서 실시간 시연 + 학생 관찰

---

## 🎯 Demo 목표

### 학생 학습 목표
- Terraform으로 EKS 클러스터 생성 과정 이해
- VPC, Subnet, NAT Gateway 자동 구성 확인
- Managed Node Group 생성 및 관리 방법 습득
- kubectl 연결 및 기본 명령어 실습
- 실제 워크로드 배포 및 LoadBalancer 동작 확인

### 강사 시연 목표
- 완벽하게 검증된 스크립트로 안정적 시연
- 각 단계별 설명과 함께 진행
- 실시간 Q&A 및 트러블슈팅 공유
- 실무 팁과 베스트 프랙티스 전달

---

## 📋 사전 준비 (Demo 전날)

### ✅ 필수 도구 설치 확인
```bash
# Terraform 설치 확인
terraform version
# 필요 버전: >= 1.0

# AWS CLI 설치 확인
aws --version
# 필요 버전: >= 2.0

# kubectl 설치 확인
kubectl version --client
# 필요 버전: >= 1.28
```

### ✅ AWS 자격증명 설정
```bash
# AWS 자격증명 확인
aws sts get-caller-identity

# 출력 예시:
# {
#     "UserId": "AIDAXXXXXXXXXXXXXXXXX",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/instructor"
# }
```

### ✅ 권한 확인
필요한 IAM 권한:
- `AmazonEKSClusterPolicy`
- `AmazonEKSWorkerNodePolicy`
- `AmazonEC2FullAccess`
- `AmazonVPCFullAccess`

### ✅ 스크립트 다운로드 및 권한 설정
```bash
# 스크립트 디렉토리로 이동
cd theory/november/week_04/day1/demo_scripts

# 실행 권한 부여
chmod +x setup-eks-cluster.sh
chmod +x cleanup-eks-cluster.sh

# 스크립트 확인
ls -la
```

---

## 🎬 Demo 진행 순서 (60분)

### 1단계: 소개 및 개요 (5분)


```
"안녕하세요! 지금부터 Terraform으로 EKS 클러스터를 
완전 자동으로 생성하는 과정을 보여드리겠습니다.

오늘 시연할 내용:
1. Terraform 설정 파일 자동 생성
2. VPC + EKS Cluster + Node Group 생성
3. kubectl 연결 및 기본 명령어
4. 테스트 워크로드 배포
5. LoadBalancer 동작 확인

전체 과정은 약 20분 정도 소요되며,
그 동안 각 단계를 설명드리겠습니다."
```

**화면 공유**:
- 터미널 화면
- AWS Console (EKS, VPC 페이지 미리 열어두기)

---

### 2단계: 스크립트 실행 (20분)

**명령어 실행**:
```bash
# 스크립트 실행
./setup-eks-cluster.sh
```

**각 단계별 설명**:

#### Step 1-2: 도구 및 자격증명 확인
```
"먼저 필요한 도구들이 설치되어 있는지 확인합니다.
Terraform, AWS CLI, kubectl이 모두 필요합니다.

AWS 자격증명도 확인하여 어떤 계정에서 
리소스가 생성될지 확인합니다."
```

#### Step 3-4: Terraform 설정 파일 생성
```
"이제 Terraform 설정 파일을 자동으로 생성합니다.

주요 파일:
- provider.tf: AWS Provider 설정
- variables.tf: 변수 정의
- vpc.tf: VPC 및 네트워크 구성
- eks.tf: EKS 클러스터 및 Node Group
- outputs.tf: 출력 값 정의

실무에서는 이런 파일들을 Git으로 관리합니다."
```

**AWS Console 확인**:
- VPC 페이지 열기
- EKS 페이지 열기
- "아직 리소스가 없는 상태입니다"

#### Step 5: Terraform Init
```
"terraform init으로 필요한 Provider와 Module을 
다운로드합니다.

특히 terraform-aws-modules/vpc와 
terraform-aws-modules/eks를 사용합니다.
이들은 AWS 공식 검증된 모듈입니다."
```

#### Step 6: Terraform Plan
```
"terraform plan으로 생성될 리소스를 미리 확인합니다.

주요 리소스:
- VPC: 1개
- Subnet: 6개 (Public 3 + Private 3)
- NAT Gateway: 1개
- Internet Gateway: 1개
- EKS Cluster: 1개
- Managed Node Group: 1개 (2 nodes)
- Security Groups: 여러 개

총 50개 이상의 리소스가 생성됩니다."
```

#### Step 7: Terraform Apply (15분 소요)
```
"이제 실제로 리소스를 생성합니다.
약 15-20분 정도 소요됩니다.

이 시간 동안 각 단계를 설명드리겠습니다."
```

**대기 시간 활용**:

**1. VPC 생성 설명 (5분)**:
```
"먼저 VPC가 생성됩니다.

VPC 구조:
- CIDR: 10.0.0.0/16
- Public Subnet: 10.0.101.0/24 (x3)
  → Internet Gateway 연결
  → LoadBalancer 배치
- Private Subnet: 10.0.1.0/24 (x3)
  → NAT Gateway 연결
  → EKS Node 배치

왜 이렇게 구성할까요?
- Public: 외부 접근 필요한 리소스
- Private: 보안이 중요한 리소스
- Multi-AZ: 고가용성 확보"
```

**AWS Console 확인**:
- VPC 페이지에서 VPC 생성 확인
- Subnet 생성 확인
- Route Table 확인

**2. EKS Control Plane 생성 설명 (5분)**:
```
"다음은 EKS Control Plane이 생성됩니다.

Control Plane:
- Kubernetes API Server
- etcd (데이터 저장소)
- Scheduler
- Controller Manager

AWS가 완전히 관리하므로:
- 고가용성 자동 보장 (Multi-AZ)
- 자동 백업
- 자동 패치
- 우리는 관리 부담 없음"
```

**AWS Console 확인**:
- EKS 페이지에서 클러스터 생성 진행 확인
- Status: Creating → Active

**3. Managed Node Group 생성 설명 (5분)**:
```
"마지막으로 Worker Node가 생성됩니다.

Node Group 설정:
- Instance Type: t3.medium
- Desired: 2 nodes
- Min: 1, Max: 3
- AMI: EKS Optimized AMI (자동)

Managed Node Group 장점:
- 자동 업데이트
- 자동 스케일링
- 자동 복구
- 운영 부담 최소화"
```

**AWS Console 확인**:
- EC2 페이지에서 인스턴스 생성 확인
- EKS 페이지에서 Node Group 확인

---

### 3단계: kubectl 설정 및 검증 (10분)

#### Step 8: kubectl 설정
```bash
# 자동으로 실행됨
aws eks update-kubeconfig --region ap-northeast-2 --name november-week4-demo
```

**설명**:
```
"kubectl 설정이 자동으로 완료되었습니다.

~/.kube/config 파일에 클러스터 정보가 저장되어
이제 kubectl 명령어로 클러스터를 제어할 수 있습니다."
```

#### Step 9: 클러스터 검증
```bash
# 클러스터 정보
kubectl cluster-info

# 노드 확인
kubectl get nodes -o wide

# 네임스페이스 확인
kubectl get namespaces

# 시스템 Pod 확인
kubectl get pods -n kube-system
```

**각 명령어 설명**:

**1. cluster-info**:
```
"클러스터 엔드포인트와 DNS 정보를 확인합니다.
Kubernetes control plane이 정상 동작 중입니다."
```

**2. get nodes**:
```
"2개의 Worker Node가 Ready 상태입니다.

주요 정보:
- NAME: 노드 이름
- STATUS: Ready (정상)
- ROLES: <none> (Worker Node)
- AGE: 생성 시간
- VERSION: Kubernetes 버전 (1.28)
- INTERNAL-IP: Private IP
- OS-IMAGE: Amazon Linux 2
- KERNEL-VERSION: Linux 커널 버전
- CONTAINER-RUNTIME: containerd"
```

**3. get namespaces**:
```
"기본 네임스페이스들이 생성되어 있습니다:
- default: 기본 네임스페이스
- kube-system: 시스템 Pod
- kube-public: 공개 리소스
- kube-node-lease: 노드 상태 관리"
```

**4. get pods -n kube-system**:
```
"시스템 Pod들이 정상 실행 중입니다:
- aws-node: VPC CNI (네트워킹)
- coredns: DNS 서버
- kube-proxy: 네트워크 프록시

모두 Running 상태여야 정상입니다."
```

---

### 4단계: 테스트 워크로드 배포 (15분)

#### Step 10: 워크로드 배포
```bash
# 자동으로 실행됨
kubectl apply -f test-deployment.yaml
```

**배포 내용 설명**:
```
"간단한 Nginx 웹 서버를 배포합니다.

구성:
1. Namespace: demo
2. Deployment: nginx-demo (2 replicas)
3. Service: LoadBalancer 타입

왜 LoadBalancer 타입?
→ AWS ELB가 자동으로 생성되어
  외부에서 접근 가능합니다."
```

**배포 확인**:
```bash
# 모든 리소스 확인
kubectl get all -n demo

# Pod 상세 확인
kubectl describe pod -n demo -l app=nginx

# Service 확인
kubectl get svc nginx-service -n demo -w
```

**각 명령어 설명**:

**1. get all**:
```
"demo 네임스페이스의 모든 리소스를 확인합니다:
- Pod: 2개 (nginx-demo-xxx)
- ReplicaSet: 1개 (Deployment가 생성)
- Deployment: 1개 (nginx-demo)
- Service: 1개 (nginx-service)

Pod가 Running 상태가 되어야 합니다."
```

**2. describe pod**:
```
"Pod의 상세 정보를 확인합니다:
- Image: nginx:alpine
- Resources: CPU 100m, Memory 128Mi
- Events: 생성 과정 확인

Events 섹션에서 문제가 있으면
에러 메시지를 확인할 수 있습니다."
```

**3. get svc -w**:
```
"Service의 LoadBalancer 생성을 실시간으로 확인합니다.

EXTERNAL-IP가:
- <pending>: 생성 중
- xxx.elb.amazonaws.com: 생성 완료

약 2-3분 소요됩니다."
```

**AWS Console 확인**:
- EC2 → Load Balancers
- 새로운 Classic Load Balancer 생성 확인
- Target Group 및 Health Check 확인

#### LoadBalancer 접속 테스트
```bash
# LoadBalancer URL 확인
LB_URL=$(kubectl get svc nginx-service -n demo -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "http://$LB_URL"

# 브라우저에서 접속
# 또는 curl로 테스트
curl http://$LB_URL
```

**브라우저 시연**:
```
"브라우저에서 LoadBalancer URL로 접속하면
Nginx 기본 페이지가 표시됩니다.

이것은:
- 외부 인터넷 → AWS ELB
- ELB → Kubernetes Service
- Service → Pod (nginx)
- 전체 경로가 정상 동작함을 의미합니다."
```

---

### 5단계: Q&A 및 정리 (10분)

**주요 질문 예상 및 답변**:

**Q1: "비용이 얼마나 나오나요?"**
```
A: 시간당 약 $0.23입니다.
- EKS Control Plane: $0.10/hour
- t3.medium x2: $0.0832/hour
- NAT Gateway: $0.045/hour

데모 1시간 = 약 $0.23
하루 종일 = 약 $5.52
한 달 = 약 $165

따라서 데모 후 즉시 삭제해야 합니다!
```

**Q2: "프로덕션에서는 어떻게 다르게 구성하나요?"**
```
A: 프로덕션 환경에서는:
1. Multi-AZ NAT Gateway (고가용성)
2. 더 큰 인스턴스 타입 (m5.large 이상)
3. Auto Scaling 설정 (min 3, max 10)
4. Monitoring & Logging (CloudWatch, Prometheus)
5. Backup & Disaster Recovery
6. Security 강화 (Network Policy, Pod Security)
```

**Q3: "Terraform 대신 AWS Console로 만들 수 있나요?"**
```
A: 가능하지만 권장하지 않습니다.
- Console: 클릭 50번 이상, 20분 소요
- Terraform: 코드 작성 1번, 자동 실행
- 재현성: Terraform은 동일 환경 보장
- 버전 관리: Git으로 변경 이력 추적
- 협업: 팀원과 코드 공유 가능
```

**Q4: "Node가 2개인데 Pod도 2개면 각각 다른 Node에 배포되나요?"**
```
A: 기본적으로 Kubernetes Scheduler가 자동 분산합니다.
확인 방법:
kubectl get pods -n demo -o wide

NODE 컬럼을 보면 어느 Node에 배포되었는지 확인 가능합니다.
```

**정리 안내**:
```
"데모가 끝났습니다!

리소스 정리 방법:
1. kubectl delete -f test-deployment.yaml
2. terraform destroy -auto-approve

또는 cleanup-eks-cluster.sh 스크립트 실행

⚠️ 반드시 정리해야 합니다!
그렇지 않으면 계속 비용이 발생합니다."
```

---

## 🧹 Demo 후 정리 (필수!)

### 즉시 정리 (Demo 직후)
```bash
# 정리 스크립트 실행
./cleanup-eks-cluster.sh

# 또는 수동 정리
kubectl delete -f test-deployment.yaml
terraform destroy -auto-approve
```

### 정리 확인
```bash
# EKS 클러스터 확인
aws eks list-clusters

# VPC 확인
aws ec2 describe-vpcs --filters "Name=tag:Demo,Values=november-week4-day1"

# LoadBalancer 확인
aws elb describe-load-balancers
```

**AWS Console 확인**:
- EKS → Clusters (없어야 함)
- VPC → Your VPCs (Demo VPC 없어야 함)
- EC2 → Load Balancers (Demo LB 없어야 함)

---

## 🔍 트러블슈팅

### 문제 1: Terraform Apply 실패
**증상**:
```
Error: error creating EKS Cluster: InvalidParameterException
```

**원인**: IAM 권한 부족

**해결**:
```bash
# IAM 권한 확인
aws iam get-user

# 필요한 정책 연결
aws iam attach-user-policy --user-name instructor \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
```

### 문제 2: Node가 Ready 상태가 안 됨
**증상**:
```
NAME                          STATUS     ROLES    AGE
ip-10-0-1-123.ec2.internal    NotReady   <none>   5m
```

**원인**: VPC CNI Pod 문제

**해결**:
```bash
# VPC CNI Pod 확인
kubectl get pods -n kube-system -l k8s-app=aws-node

# VPC CNI 재시작
kubectl rollout restart daemonset aws-node -n kube-system
```

### 문제 3: LoadBalancer EXTERNAL-IP가 계속 <pending>
**증상**:
```
NAME            TYPE           EXTERNAL-IP   PORT(S)
nginx-service   LoadBalancer   <pending>     80:31234/TCP
```

**원인**: Subnet 태그 누락

**해결**:
```bash
# Public Subnet 태그 확인
aws ec2 describe-subnets --filters "Name=tag:Name,Values=*public*"

# 태그가 없으면 추가
aws ec2 create-tags --resources subnet-xxx \
  --tags Key=kubernetes.io/role/elb,Value=1
```

### 문제 4: kubectl 연결 안 됨
**증상**:
```
error: You must be logged in to the server (Unauthorized)
```

**원인**: kubeconfig 설정 문제

**해결**:
```bash
# kubeconfig 재설정
aws eks update-kubeconfig --region ap-northeast-2 \
  --name november-week4-demo

# 컨텍스트 확인
kubectl config current-context

# 클러스터 정보 확인
kubectl cluster-info
```

---

## 📊 Demo 체크리스트

### 사전 준비
- [ ] Terraform 설치 확인 (>= 1.0)
- [ ] AWS CLI 설치 확인 (>= 2.0)
- [ ] kubectl 설치 확인 (>= 1.28)
- [ ] AWS 자격증명 설정
- [ ] IAM 권한 확인
- [ ] 스크립트 다운로드 및 권한 설정
- [ ] AWS Console 페이지 미리 열기 (EKS, VPC, EC2)

### Demo 진행
- [ ] 소개 및 개요 설명 (5분)
- [ ] 스크립트 실행 (20분)
  - [ ] 도구 확인
  - [ ] Terraform 파일 생성
  - [ ] Terraform init
  - [ ] Terraform plan
  - [ ] Terraform apply
- [ ] kubectl 설정 및 검증 (10분)
  - [ ] cluster-info
  - [ ] get nodes
  - [ ] get namespaces
  - [ ] get pods -n kube-system
- [ ] 테스트 워크로드 배포 (15분)
  - [ ] Deployment 배포
  - [ ] Service 생성
  - [ ] LoadBalancer 확인
  - [ ] 브라우저 접속 테스트
- [ ] Q&A 및 정리 (10분)

### Demo 후 정리
- [ ] kubectl delete -f test-deployment.yaml
- [ ] terraform destroy
- [ ] AWS Console에서 리소스 삭제 확인
- [ ] 비용 확인 (Cost Explorer)

---

## 💡 강사 팁

### 시간 관리
- Terraform Apply 대기 시간(15분)을 활용하여 이론 설명
- 질문은 각 단계 종료 후 받기
- 시간이 부족하면 LoadBalancer 테스트 생략 가능

### 학생 참여 유도
- "이 명령어는 무엇을 하는 것 같나요?" 질문
- AWS Console 화면을 함께 보며 리소스 생성 확인
- 실시간 채팅으로 질문 받기

### 실수 대응
- 에러 발생 시 당황하지 말고 트러블슈팅 과정 공유
- "실무에서도 이런 에러가 자주 발생합니다" 강조
- 해결 과정을 교육 기회로 활용

### 비용 강조
- Demo 시작 시 예상 비용 안내
- Demo 종료 시 정리 방법 재차 강조
- "정리하지 않으면 한 달에 $165 청구됩니다!" 경고

---

<div align="center">

**🎬 완벽한 Demo** • **⏱️ 시간 엄수** • **💰 비용 관리** • **🔍 트러블슈팅**

*학생들에게 실무 경험을 전달하는 Demo*

</div>
