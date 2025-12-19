# EKS 실습 환경 설정 가이드

## 🎯 목적
이 문서는 Amazon EKS 실습을 위한 완전한 환경 설정 가이드입니다. 실습 시작 전에 반드시 모든 요구사항을 확인하고 설정을 완료해주세요.

## ⚠️ 중요 사항
- **실습 전 필수 완료**: 모든 설정은 실습 시작 전에 완료되어야 합니다
- **권한 확인 필수**: IAM 사용자의 경우 EKS 관련 권한이 없을 수 있습니다
- **비용 주의**: EKS 클러스터 생성 시 AWS 비용이 발생합니다 (~$121/월)

---

## 📋 시스템 요구사항

### 운영체제
- **Windows**: Windows 10/11 (PowerShell 5.1 이상)
- **macOS**: macOS 10.15 이상
- **Linux**: Ubuntu 18.04+, CentOS 7+, Amazon Linux 2

### 하드웨어
- **RAM**: 최소 4GB (권장 8GB)
- **디스크**: 최소 10GB 여유 공간
- **네트워크**: 안정적인 인터넷 연결

---

## 🛠️ 필수 도구 설치

### 1. AWS CLI v2 설치

#### Windows
```powershell
# MSI 설치 파일 다운로드 및 설치
# https://awscli.amazonaws.com/AWSCLIV2.msi

# 또는 Chocolatey 사용
choco install awscli

# 설치 확인
aws --version
```

#### macOS
```bash
# Homebrew 사용 (권장)
brew install awscli

# 또는 직접 설치
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /

# 설치 확인
aws --version
```

#### Linux (Ubuntu/Debian)
```bash
# 패키지 업데이트
sudo apt update

# AWS CLI v2 설치
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# 설치 확인
aws --version
```

### 2. eksctl 설치

#### Windows
```powershell
# Chocolatey 사용
choco install eksctl

# 또는 직접 다운로드
# https://github.com/weaveworks/eksctl/releases/latest

# 설치 확인
eksctl version
```

#### macOS
```bash
# Homebrew 사용
brew tap weaveworks/tap
brew install weaveworks/tap/eksctl

# 설치 확인
eksctl version
```

#### Linux
```bash
# 최신 버전 다운로드 및 설치
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# 설치 확인
eksctl version
```

### 3. kubectl 설치

#### Windows
```powershell
# Chocolatey 사용
choco install kubernetes-cli

# 또는 직접 다운로드
curl -LO "https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe"

# 설치 확인
kubectl version --client
```

#### macOS
```bash
# Homebrew 사용
brew install kubectl

# 설치 확인
kubectl version --client
```

#### Linux
```bash
# 최신 버전 다운로드 및 설치
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# 설치 확인
kubectl version --client
```

---

## 🔐 AWS 계정 및 자격 증명 설정

### 1. AWS 계정 확인
```bash
# 현재 AWS 계정 정보 확인
aws sts get-caller-identity
```

**예상 출력**:
```json
{
    "UserId": "AIDACKCEVSQ6C2EXAMPLE",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/your-username"
}
```

### 2. Access Key 설정

#### 2-1. Access Key가 없는 경우
1. **AWS Console 로그인** → IAM → Users → [본인 사용자명]
2. **Security credentials** 탭 클릭
3. **Create access key** 클릭
4. **Use case**: Command Line Interface (CLI) 선택
5. **Access Key ID**와 **Secret Access Key** 복사 및 안전하게 보관

#### 2-2. AWS CLI 설정
```bash
# AWS 자격 증명 설정
aws configure

# 입력 정보:
# AWS Access Key ID: [YOUR_ACCESS_KEY_ID]
# AWS Secret Access Key: [YOUR_SECRET_ACCESS_KEY]  
# Default region name: ap-northeast-2
# Default output format: json
```

#### 2-3. 프로필 사용 (권장)
```bash
# 별도 프로필로 설정
aws configure --profile eks-lab

# 프로필 사용
export AWS_PROFILE=eks-lab

# 또는 명령어마다 지정
aws sts get-caller-identity --profile eks-lab
```

### 3. 자격 증명 확인
```bash
# 설정된 자격 증명 확인
aws configure list

# 계정 정보 재확인
aws sts get-caller-identity

# 기본 리전 확인
aws configure get region
```

---

## 🔑 IAM 권한 확인 및 설정

### 1. 필수 IAM 권한 목록

EKS 클러스터 생성을 위해 다음 권한들이 필요합니다:

#### EKS 관련 권한
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:CreateCluster",
                "eks:DescribeCluster",
                "eks:ListClusters",
                "eks:UpdateClusterConfig",
                "eks:UpdateClusterVersion",
                "eks:DeleteCluster",
                "eks:CreateNodegroup",
                "eks:DescribeNodegroup",
                "eks:ListNodegroups",
                "eks:UpdateNodegroupConfig",
                "eks:UpdateNodegroupVersion",
                "eks:DeleteNodegroup"
            ],
            "Resource": "*"
        }
    ]
}
```

#### EC2 및 VPC 권한
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateVpc",
                "ec2:CreateSubnet",
                "ec2:CreateInternetGateway",
                "ec2:CreateNatGateway",
                "ec2:CreateRouteTable",
                "ec2:CreateRoute",
                "ec2:CreateSecurityGroup",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:ModifyVpcAttribute",
                "ec2:ModifySubnetAttribute",
                "ec2:AttachInternetGateway",
                "ec2:AssociateRouteTable",
                "ec2:AllocateAddress",
                "ec2:AssociateAddress",
                "ec2:Describe*",
                "ec2:RunInstances",
                "ec2:TerminateInstances",
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Resource": "*"
        }
    ]
}
```

#### IAM 권한
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateRole",
                "iam:AttachRolePolicy",
                "iam:DetachRolePolicy",
                "iam:DeleteRole",
                "iam:GetRole",
                "iam:ListAttachedRolePolicies",
                "iam:PassRole",
                "iam:CreateInstanceProfile",
                "iam:AddRoleToInstanceProfile",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:DeleteInstanceProfile",
                "iam:GetInstanceProfile"
            ],
            "Resource": "*"
        }
    ]
}
```

#### CloudFormation 권한
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudformation:CreateStack",
                "cloudformation:UpdateStack",
                "cloudformation:DeleteStack",
                "cloudformation:DescribeStacks",
                "cloudformation:DescribeStackEvents",
                "cloudformation:DescribeStackResources",
                "cloudformation:ListStacks",
                "cloudformation:GetTemplate"
            ],
            "Resource": "*"
        }
    ]
}
```

### 2. 권한 확인 방법

#### 2-1. 기본 권한 테스트
```bash
# EKS 클러스터 목록 조회 (권한 확인)
aws eks list-clusters --region ap-northeast-2

# EC2 인스턴스 목록 조회 (권한 확인)  
aws ec2 describe-instances --region ap-northeast-2

# IAM 역할 목록 조회 (권한 확인)
aws iam list-roles --max-items 5
```

#### 2-2. 권한 부족 시 오류 메시지
```bash
# 권한이 없는 경우 다음과 같은 오류 발생:
# An error occurred (AccessDenied) when calling the ListClusters operation: 
# User: arn:aws:iam::123456789012:user/username is not authorized to perform: 
# eks:ListClusters on resource: *
```

### 3. 권한 설정 방법

#### 3-1. 관리자에게 권한 요청
권한이 없는 경우 AWS 계정 관리자에게 다음 정책들을 요청하세요:

1. **AmazonEKSClusterPolicy** (AWS 관리형 정책)
2. **AmazonEKSWorkerNodePolicy** (AWS 관리형 정책)  
3. **AmazonEKS_CNI_Policy** (AWS 관리형 정책)
4. **AmazonEC2ContainerRegistryReadOnly** (AWS 관리형 정책)
5. **사용자 정의 정책**: 위에서 제시한 EC2, IAM, CloudFormation 권한

#### 3-2. 최소 권한 정책 (관리자용)
관리자가 사용할 수 있는 최소 권한 정책:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:*",
                "ec2:*",
                "iam:CreateRole",
                "iam:AttachRolePolicy",
                "iam:DetachRolePolicy", 
                "iam:DeleteRole",
                "iam:GetRole",
                "iam:ListAttachedRolePolicies",
                "iam:PassRole",
                "iam:CreateInstanceProfile",
                "iam:AddRoleToInstanceProfile",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:DeleteInstanceProfile",
                "iam:GetInstanceProfile",
                "cloudformation:*"
            ],
            "Resource": "*"
        }
    ]
}
```

---

## ✅ 환경 테스트 및 검증

### 1. 도구 설치 확인

**Linux/macOS**:
```bash
# 모든 도구 버전 확인
echo "=== AWS CLI ==="
aws --version

echo "=== eksctl ==="
eksctl version

echo "=== kubectl ==="
kubectl version --client

echo "=== 자격 증명 ==="
aws sts get-caller-identity
```

**Windows (PowerShell)**:
```powershell
# 모든 도구 버전 확인
Write-Host "=== AWS CLI ==="
aws --version

Write-Host "=== eksctl ==="
eksctl version

Write-Host "=== kubectl ==="
kubectl version --client

Write-Host "=== 자격 증명 ==="
aws sts get-caller-identity
```

### 2. 권한 테스트
```bash
# EKS 권한 테스트
echo "=== EKS 권한 테스트 ==="
aws eks list-clusters --region ap-northeast-2

# EC2 권한 테스트  
echo "=== EC2 권한 테스트 ==="
aws ec2 describe-vpcs --region ap-northeast-2 --max-items 1

# IAM 권한 테스트
echo "=== IAM 권한 테스트 ==="
aws iam list-roles --max-items 1

# CloudFormation 권한 테스트
echo "=== CloudFormation 권한 테스트 ==="
aws cloudformation list-stacks --region ap-northeast-2 --max-items 1
```

### 3. 네트워크 연결 테스트

**Linux/macOS**:
```bash
# AWS API 엔드포인트 연결 테스트
curl -I https://eks.ap-northeast-2.amazonaws.com

# 예상 응답: HTTP/2 403 (정상 - 인증 오류이지만 연결은 성공)
```

**Windows (PowerShell)**:
```powershell
# AWS API 엔드포인트 연결 테스트
try {
    Invoke-WebRequest -Uri "https://eks.ap-northeast-2.amazonaws.com" -Method Head -TimeoutSec 10
    Write-Host "연결 성공"
} catch {
    if ($_.Exception.Response.StatusCode -eq 403) {
        Write-Host "연결 성공 (403 응답은 정상 - 인증 오류이지만 연결됨)"
    } else {
        Write-Host "연결 실패: $($_.Exception.Message)"
    }
}
```

---

## 🚨 문제 해결 가이드

### 1. AWS CLI 관련 문제

#### 문제: "aws: command not found"
**해결방법**:

**Linux/macOS**:
```bash
# PATH 환경변수 확인
echo $PATH

# AWS CLI 설치 위치 확인
which aws

# 재설치 또는 PATH 추가
export PATH=$PATH:/usr/local/bin
```

**Windows (PowerShell)**:
```powershell
# PATH 환경변수 확인
echo $env:PATH

# AWS CLI 설치 위치 확인
Get-Command aws -ErrorAction SilentlyContinue

# PATH에 추가 (필요시)
$env:PATH += ";C:\Program Files\Amazon\AWSCLIV2"
```

**Windows (CMD)**:
```cmd
# PATH 환경변수 확인
echo %PATH%

# AWS CLI 설치 위치 확인
where aws

# PATH에 추가 (필요시)
set PATH=%PATH%;C:\Program Files\Amazon\AWSCLIV2
```

#### 문제: "Unable to locate credentials"
**해결방법**:

**Linux/macOS**:
```bash
# 자격 증명 파일 확인
cat ~/.aws/credentials
cat ~/.aws/config

# 다시 설정
aws configure
```

**Windows (PowerShell)**:
```powershell
# 자격 증명 파일 확인
type $env:USERPROFILE\.aws\credentials
type $env:USERPROFILE\.aws\config

# 다시 설정
aws configure
```

**Windows (CMD)**:
```cmd
# 자격 증명 파일 확인
type %USERPROFILE%\.aws\credentials
type %USERPROFILE%\.aws\config

# 다시 설정
aws configure
```

### 2. 권한 관련 문제

#### 문제: "AccessDenied" 오류
**해결방법**:
1. AWS 계정 관리자에게 권한 요청
2. 필요한 정책 목록 제공 (위 섹션 참조)
3. 임시로 PowerUser 또는 AdministratorAccess 권한 요청

#### 문제: "AssumeRole" 오류
**해결방법**:
```bash
# 현재 사용자 확인
aws sts get-caller-identity

# 역할 전환이 필요한 경우
aws sts assume-role --role-arn arn:aws:iam::ACCOUNT:role/ROLE-NAME --role-session-name test
```

### 3. AWS API 연결 문제

#### 문제: AWS API 엔드포인트 연결 시간 초과
**증상**: `aws` 명령어 실행 시 "Connection timeout" 또는 "Unable to connect" 오류

**해결방법**:
1. **회사/기관 방화벽 확인**
   - AWS API 엔드포인트 (*.amazonaws.com) 접근 허용 필요
   - IT 관리자에게 AWS 도메인 화이트리스트 요청

2. **프록시 설정 확인**
   - 회사에서 프록시를 사용하는 경우 AWS CLI에 프록시 설정 필요

**Linux/macOS**:
```bash
# 프록시 설정 (회사 프록시 사용 시)
export HTTP_PROXY=http://proxy.company.com:8080
export HTTPS_PROXY=http://proxy.company.com:8080

# AWS CLI 프록시 설정 (영구 적용)
aws configure set proxy.http http://proxy.company.com:8080
aws configure set proxy.https http://proxy.company.com:8080
```

**Windows (PowerShell)**:
```powershell
# 프록시 설정 (회사 프록시 사용 시)
$env:HTTP_PROXY = "http://proxy.company.com:8080"
$env:HTTPS_PROXY = "http://proxy.company.com:8080"

# AWS CLI 프록시 설정 (영구 적용)
aws configure set proxy.http http://proxy.company.com:8080
aws configure set proxy.https http://proxy.company.com:8080
```

**Windows (CMD)**:
```cmd
# 프록시 설정 (회사 프록시 사용 시)
set HTTP_PROXY=http://proxy.company.com:8080
set HTTPS_PROXY=http://proxy.company.com:8080

# AWS CLI 프록시 설정 (영구 적용)
aws configure set proxy.http http://proxy.company.com:8080
aws configure set proxy.https http://proxy.company.com:8080
```

3. **DNS 설정 확인**
   - AWS 도메인 해석이 가능한지 확인
   ```bash
   # Linux/macOS
   nslookup eks.ap-northeast-2.amazonaws.com
   
   # Windows
   nslookup eks.ap-northeast-2.amazonaws.com
   ```

4. **VPN 연결 확인**
   - 회사 VPN 사용 시 AWS 접근 정책 확인
   - 개인 VPN 사용 시 일시적으로 해제 후 테스트

### 4. eksctl 관련 문제

#### 문제: "no such host" 오류
**증상**: eksctl 실행 시 "no such host" 또는 DNS 해석 실패

**해결방법**:
```bash
# 1. 리전 설정 확인
aws configure get region

# 2. 올바른 리전으로 설정
aws configure set region ap-northeast-2

# 3. DNS 해석 테스트
nslookup eks.ap-northeast-2.amazonaws.com

# 4. 인터넷 연결 확인
ping 8.8.8.8
```

#### 문제: 회사/기관 네트워크 제한
**증상**: 
- AWS CLI 명령어가 매우 느리거나 시간 초과
- "SSL certificate verify failed" 오류
- 특정 AWS 서비스만 접근 불가

**해결방법**:
1. **IT 관리자에게 요청할 사항**:
   - `*.amazonaws.com` 도메인 화이트리스트 추가
   - HTTPS(443) 포트 아웃바운드 허용
   - AWS IP 대역 허용 (선택사항)

2. **임시 해결책**:
   - 개인 핫스팟 사용하여 연결 테스트
   - 회사 게스트 네트워크 사용 (가능한 경우)

3. **SSL 인증서 문제**:
   ```bash
   # SSL 검증 비활성화 (임시, 보안상 권장하지 않음)
   aws configure set ca_bundle ""
   aws configure set cli_verify_ssl false
   ```

---

## 📝 최종 체크리스트

실습 시작 전에 다음 항목들을 모두 확인해주세요:

### 도구 설치 확인
- [ ] AWS CLI v2 설치 완료 (`aws --version`)
- [ ] eksctl 설치 완료 (`eksctl version`)  
- [ ] kubectl 설치 완료 (`kubectl version --client`)

### AWS 자격 증명 확인
- [ ] AWS Access Key 생성 완료
- [ ] AWS CLI 설정 완료 (`aws configure`)
- [ ] 계정 정보 확인 완료 (`aws sts get-caller-identity`)
- [ ] 기본 리전 설정 완료 (ap-northeast-2)

### 권한 확인
- [ ] EKS 권한 확인 (`aws eks list-clusters`)
- [ ] EC2 권한 확인 (`aws ec2 describe-vpcs`)
- [ ] IAM 권한 확인 (`aws iam list-roles`)
- [ ] CloudFormation 권한 확인 (`aws cloudformation list-stacks`)

### 비용 및 주의사항 확인
- [ ] EKS 클러스터 비용 이해 (~$121/월)
- [ ] 실습 후 리소스 정리 계획 수립
- [ ] 백업 및 복구 계획 수립 (필요시)

### 네트워크 및 환경
- [ ] 안정적인 인터넷 연결 확인
- [ ] 방화벽/프록시 설정 확인 (필요시)
- [ ] 충분한 디스크 공간 확인 (10GB+)

---

## 🆘 추가 지원

### 유용한 참고 자료
- [AWS EKS 사용 설명서](https://docs.aws.amazon.com/eks/)
- [eksctl 공식 문서](https://eksctl.io/)
- [kubectl 공식 문서](https://kubernetes.io/docs/reference/kubectl/)

---

**⚠️ 중요**: 이 체크리스트의 모든 항목이 완료된 후에만 EKS 실습을 시작하세요. 미완료 항목이 있으면 실습 중 문제가 발생할 수 있습니다.