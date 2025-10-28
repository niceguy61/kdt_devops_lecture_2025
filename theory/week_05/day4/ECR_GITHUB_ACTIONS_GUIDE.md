# GitHub Actions + ECR 통합 가이드

## 🎯 개요
GitHub Actions에서 OIDC를 통해 AWS ECR에 안전하게 접근하는 방법

## 🔧 AWS 설정

### 1. IAM Role 생성

**AWS Console 경로**:
```
IAM → Roles → Create role
```

**설정**:
| 항목 | 값 |
|------|-----|
| **Trusted entity type** | Web identity |
| **Identity provider** | token.actions.githubusercontent.com |
| **Audience** | sts.amazonaws.com |

**Trust Policy**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT-ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:USERNAME/REPOSITORY:ref:refs/heads/main"
        }
      }
    }
  ]
}
```

### 2. ECR 권한 정책

**정책 이름**: `ECRPushPolicy`

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage"
      ],
      "Resource": "*"
    }
  ]
}
```

### 3. ECR 리포지토리 생성

```bash
aws ecr create-repository --repository-name cloudmart-frontend --region ap-northeast-2
aws ecr create-repository --repository-name cloudmart-backend --region ap-northeast-2
```

## 🚀 GitHub Actions 워크플로우

### `.github/workflows/deploy-ecr.yml`

```yaml
name: Build and Push to ECR

on:
  push:
    branches: [ main ]

env:
  AWS_REGION: ap-northeast-2
  ECR_REGISTRY: ACCOUNT-ID.dkr.ecr.ap-northeast-2.amazonaws.com

permissions:
  id-token: write
  contents: read

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        role-to-assume: arn:aws:iam::ACCOUNT-ID:role/GitHubActionsECRRole
        aws-region: ${{ env.AWS_REGION }}

    - name: Login to ECR
      uses: aws-actions/amazon-ecr-login@v2

    - name: Build and push frontend
      run: |
        docker build -t $ECR_REGISTRY/cloudmart-frontend:$GITHUB_SHA ./frontend
        docker push $ECR_REGISTRY/cloudmart-frontend:$GITHUB_SHA
        docker tag $ECR_REGISTRY/cloudmart-frontend:$GITHUB_SHA $ECR_REGISTRY/cloudmart-frontend:latest
        docker push $ECR_REGISTRY/cloudmart-frontend:latest

    - name: Build and push backend
      run: |
        docker build -t $ECR_REGISTRY/cloudmart-backend:$GITHUB_SHA ./backend
        docker push $ECR_REGISTRY/cloudmart-backend:$GITHUB_SHA
        docker tag $ECR_REGISTRY/cloudmart-backend:$GITHUB_SHA $ECR_REGISTRY/cloudmart-backend:latest
        docker push $ECR_REGISTRY/cloudmart-backend:latest
```

## 🔑 필수 설정 단계

### 1. OIDC Provider 생성 (한 번만)

```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
  --client-id-list sts.amazonaws.com
```

### 2. 환경 변수 설정

**GitHub Repository Settings → Secrets and variables → Actions**:

| Name | Value | Type |
|------|-------|------|
| `AWS_ACCOUNT_ID` | 123456789012 | Secret |
| `AWS_REGION` | ap-northeast-2 | Variable |

### 3. Trust Policy 업데이트

**실제 값으로 교체**:
- `ACCOUNT-ID`: 실제 AWS 계정 ID
- `USERNAME/REPOSITORY`: 실제 GitHub 저장소

## ✅ 테스트 방법

### 1. 로컬 테스트

```bash
# ECR 로그인 확인
aws ecr get-login-password --region ap-northeast-2 | \
docker login --username AWS --password-stdin \
ACCOUNT-ID.dkr.ecr.ap-northeast-2.amazonaws.com

# 이미지 빌드 및 푸시
docker build -t ACCOUNT-ID.dkr.ecr.ap-northeast-2.amazonaws.com/cloudmart-frontend:test .
docker push ACCOUNT-ID.dkr.ecr.ap-northeast-2.amazonaws.com/cloudmart-frontend:test
```

### 2. GitHub Actions 실행

```bash
git add .
git commit -m "Add ECR workflow"
git push origin main
```

## 🔍 트러블슈팅

### 문제 1: OIDC Provider 없음
```
Error: Could not assume role with OIDC
```

**해결**:
```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
  --client-id-list sts.amazonaws.com
```

### 문제 2: Trust Policy 오류
```
Error: Not authorized to perform sts:AssumeRoleWithWebIdentity
```

**해결**: Trust Policy의 `sub` 조건 확인
```json
"token.actions.githubusercontent.com:sub": "repo:your-username/your-repo:ref:refs/heads/main"
```

### 문제 3: ECR 권한 부족
```
Error: denied: User is not authorized to perform ecr:InitiateLayerUpload
```

**해결**: Role에 `ECRPushPolicy` 연결 확인

## 💰 비용 고려사항

### ECR 요금
- **스토리지**: $0.10/GB/month
- **데이터 전송**: 
  - 같은 리전: 무료
  - 다른 리전: $0.02/GB

### 최적화 팁
- **이미지 라이프사이클 정책** 설정
- **멀티 스테이지 빌드**로 이미지 크기 최소화
- **태그 전략**: latest + SHA 조합

## 🔗 참고 자료

- [AWS ECR 사용자 가이드](https://docs.aws.amazon.com/ecr/)
- [GitHub Actions OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [ECR 요금](https://aws.amazon.com/ecr/pricing/)
