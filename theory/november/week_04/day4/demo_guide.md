# November Week 4 Day 4: CI/CD Demo Guide

<div align="center">

**🔄 완전 자동화 파이프라인** • **🐳 Docker 빌드** • **🚀 Kubernetes 배포**

*강사용 완벽 검증 데모 가이드*

</div>

---

## 🎯 Demo 개요

### 목표
- GitHub Actions 워크플로우 작성 및 실행
- Docker 이미지 자동 빌드 및 ECR 푸시
- Kubernetes 자동 배포 시연
- 전체 CI/CD 파이프라인 동작 확인

### 시간 배분
```
11:00-11:10  Demo 1: Repository 준비 (10분)
11:10-11:25  Demo 2: Docker 빌드 파이프라인 (15분)
11:25-11:45  Demo 3: Kubernetes 배포 파이프라인 (20분)
11:45-11:55  Demo 4: 전체 파이프라인 테스트 (10분)
11:55-12:00  Q&A (5분)
```

### 사전 준비
- GitHub 계정 및 Repository
- AWS 계정 (ECR, EKS 접근 권한)
- EKS 클러스터 실행 중
- kubectl 및 Helm 설치 완료

---

## 🚀 Demo 1: Repository 준비 (11:00-11:10)

### 목표
- GitHub Repository 생성
- 샘플 애플리케이션 코드 준비
- Secrets 설정

### 실행 절차

**1. Repository 생성**:
```bash
# GitHub에서 새 Repository 생성
# Repository 이름: cicd-demo
# Public 또는 Private

# 로컬에 클론
git clone https://github.com/YOUR_USERNAME/cicd-demo.git
cd cicd-demo
```

**2. 샘플 애플리케이션 준비**:
```bash
# Node.js 애플리케이션 생성
cat > package.json <<'EOF'
{
  "name": "cicd-demo",
  "version": "1.0.0",
  "description": "CI/CD Demo Application",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "test": "echo \"Test passed\" && exit 0"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

# 서버 코드
cat > server.js <<'EOF'
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from CI/CD Demo!',
    version: process.env.VERSION || '1.0.0',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
EOF

# Dockerfile
cat > Dockerfile <<'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
EOF

# .dockerignore
cat > .dockerignore <<'EOF'
node_modules
npm-debug.log
.git
.github
EOF
```

**3. Helm Chart 준비**:
```bash
# Helm Chart 생성
mkdir -p helm/myapp
cd helm/myapp

# Chart.yaml
cat > Chart.yaml <<'EOF'
apiVersion: v2
name: myapp
description: CI/CD Demo Application
type: application
version: 1.0.0
appVersion: "1.0.0"
EOF

# values.yaml
cat > values.yaml <<'EOF'
replicaCount: 2

image:
  repository: ACCOUNT_ID.dkr.ecr.ap-northeast-2.amazonaws.com/cicd-demo
  pullPolicy: IfNotPresent
  tag: "latest"

service:
  type: LoadBalancer
  port: 80
  targetPort: 3000

resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi
EOF

# templates/deployment.yaml
mkdir -p templates
cat > templates/deployment.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Chart.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Chart.Name }}
  template:
    metadata:
      labels:
        app: {{ .Chart.Name }}
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - containerPort: {{ .Values.service.targetPort }}
        resources:
          {{- toYaml .Values.resources | nindent 10 }}
        livenessProbe:
          httpGet:
            path: /health
            port: {{ .Values.service.targetPort }}
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: {{ .Values.service.targetPort }}
          initialDelaySeconds: 5
          periodSeconds: 5
EOF

# templates/service.yaml
cat > templates/service.yaml <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: {{ .Chart.Name }}
spec:
  type: {{ .Values.service.type }}
  ports:
  - port: {{ .Values.service.port }}
    targetPort: {{ .Values.service.targetPort }}
    protocol: TCP
  selector:
    app: {{ .Chart.Name }}
EOF

cd ../..
```

**4. GitHub Secrets 설정**:
```
GitHub Repository → Settings → Secrets and variables → Actions

추가할 Secrets:
1. AWS_ACCESS_KEY_ID: AWS 액세스 키
2. AWS_SECRET_ACCESS_KEY: AWS 시크릿 키
3. ECR_REPOSITORY: cicd-demo
4. EKS_CLUSTER_NAME: my-eks-cluster
```

**5. 코드 푸시**:
```bash
git add .
git commit -m "Initial commit: CI/CD demo setup"
git push origin main
```

---

## 🐳 Demo 2: Docker 빌드 파이프라인 (11:10-11:25)

### 목표
- GitHub Actions 워크플로우 작성
- Docker 이미지 자동 빌드
- ECR 푸시 자동화

### 워크플로우 작성

```bash
# 워크플로우 디렉토리 생성
mkdir -p .github/workflows

# 빌드 워크플로우
cat > .github/workflows/build.yml <<'EOF'
name: Build and Push Docker Image

on:
  push:
    branches: [ main ]
    paths:
      - 'src/**'
      - 'server.js'
      - 'package.json'
      - 'Dockerfile'

env:
  AWS_REGION: ap-northeast-2
  ECR_REPOSITORY: ${{ secrets.ECR_REPOSITORY }}

jobs:
  build:
    name: Build Docker Image
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}
      
      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1
      
      - name: Build, tag, and push image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: ${{ github.sha }}
        run: |
          echo "Building Docker image..."
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker tag $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPOSITORY:latest
          
          echo "Pushing to ECR..."
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest
          
          echo "Image pushed successfully!"
          echo "Image: $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG"
      
      - name: Output image info
        run: |
          echo "::notice::Docker image built and pushed successfully"
          echo "::notice::Image tag: ${{ github.sha }}"
EOF

# 커밋 및 푸시
git add .github/workflows/build.yml
git commit -m "Add Docker build workflow"
git push origin main
```

### 실행 확인

```bash
# GitHub Actions 탭에서 워크플로우 실행 확인
# - Workflow 이름: Build and Push Docker Image
# - 상태: 진행 중 → 성공

# ECR에서 이미지 확인
aws ecr describe-images \
  --repository-name cicd-demo \
  --region ap-northeast-2
```

---

## 🚀 Demo 3: Kubernetes 배포 파이프라인 (11:25-11:45)

### 목표
- Kubernetes 배포 워크플로우 작성
- Helm을 활용한 자동 배포
- 배포 검증

### 워크플로우 작성

```bash
# 배포 워크플로우
cat > .github/workflows/deploy.yml <<'EOF'
name: Deploy to Kubernetes

on:
  workflow_run:
    workflows: ["Build and Push Docker Image"]
    types: [completed]
    branches: [main]

env:
  AWS_REGION: ap-northeast-2
  EKS_CLUSTER_NAME: ${{ secrets.EKS_CLUSTER_NAME }}
  ECR_REPOSITORY: ${{ secrets.ECR_REPOSITORY }}
  NAMESPACE: production

jobs:
  deploy:
    name: Deploy to EKS
    runs-on: ubuntu-latest
    if: ${{ github.event.workflow_run.conclusion == 'success' }}
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}
      
      - name: Update kubeconfig
        run: |
          aws eks update-kubeconfig \
            --region ${{ env.AWS_REGION }} \
            --name ${{ env.EKS_CLUSTER_NAME }}
      
      - name: Install Helm
        uses: azure/setup-helm@v3
        with:
          version: '3.12.0'
      
      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1
      
      - name: Deploy with Helm
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: ${{ github.sha }}
        run: |
          echo "Deploying to Kubernetes..."
          helm upgrade --install myapp ./helm/myapp \
            --namespace ${{ env.NAMESPACE }} \
            --create-namespace \
            --set image.repository=$ECR_REGISTRY/$ECR_REPOSITORY \
            --set image.tag=$IMAGE_TAG \
            --wait \
            --timeout 5m
      
      - name: Verify deployment
        run: |
          echo "Verifying deployment..."
          kubectl rollout status deployment/myapp -n ${{ env.NAMESPACE }}
          kubectl get pods -n ${{ env.NAMESPACE }}
      
      - name: Health check
        run: |
          echo "Running health check..."
          kubectl wait --for=condition=ready pod \
            -l app=myapp \
            -n ${{ env.NAMESPACE }} \
            --timeout=300s
          
          echo "Deployment successful!"
      
      - name: Get service URL
        run: |
          echo "Getting service URL..."
          kubectl get svc myapp -n ${{ env.NAMESPACE }}
EOF

# 커밋 및 푸시
git add .github/workflows/deploy.yml
git commit -m "Add Kubernetes deployment workflow"
git push origin main
```

---

## 🧪 Demo 4: 전체 파이프라인 테스트 (11:45-11:55)

### 목표
- 코드 변경 및 푸시
- 전체 파이프라인 실행 확인
- 배포 결과 검증

### 테스트 시나리오

**1. 코드 변경**:
```bash
# server.js 수정
cat > server.js <<'EOF'
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from CI/CD Demo - Updated!',
    version: '2.0.0',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'production'
  });
});

app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy',
    uptime: process.uptime()
  });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
EOF

# 커밋 및 푸시
git add server.js
git commit -m "Update application to v2.0.0"
git push origin main
```

**2. 파이프라인 실행 확인**:
```bash
# GitHub Actions 탭에서 확인
# 1. Build and Push Docker Image 워크플로우 실행
# 2. Deploy to Kubernetes 워크플로우 자동 트리거
# 3. 모든 단계 성공 확인
```

**3. 배포 검증**:
```bash
# Pod 상태 확인
kubectl get pods -n production

# Service 확인
kubectl get svc myapp -n production

# 애플리케이션 테스트
SERVICE_URL=$(kubectl get svc myapp -n production -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl http://$SERVICE_URL/
curl http://$SERVICE_URL/health

# Helm Release 확인
helm list -n production
helm history myapp -n production
```

---

## 💡 Q&A 준비 사항 (11:55-12:00)

### 예상 질문 및 답변

**Q1: 워크플로우가 실패하면 어떻게 하나요?**
- A: GitHub Actions 탭에서 로그 확인, 실패한 Step 분석, Secrets 설정 확인

**Q2: 배포 중 문제가 생기면 자동으로 롤백되나요?**
- A: Helm의 --wait 옵션으로 실패 시 자동 롤백, 추가로 Health Check 실패 시 롤백 로직 구현 가능

**Q3: 여러 환경(dev, staging, prod)에 배포하려면?**
- A: 
  - 브랜치별 워크플로우 분리
  - Environment Secrets 활용
  - 승인 프로세스 추가

**Q4: Docker 이미지 빌드 시간을 줄이려면?**
- A:
  - Multi-stage build 활용
  - Layer 캐싱 (cache-from, cache-to)
  - 불필요한 파일 제외 (.dockerignore)

**Q5: 프로덕션 배포 전 승인 프로세스를 추가하려면?**
- A:
```yaml
jobs:
  deploy:
    environment:
      name: production
      url: https://myapp.example.com
    # GitHub Environment에서 승인자 설정
```

---

## 🧹 Demo 정리 (선택사항)

### 리소스 정리

```bash
# 1. Kubernetes 리소스 삭제
helm uninstall myapp -n production
kubectl delete namespace production

# 2. ECR 이미지 삭제
aws ecr batch-delete-image \
  --repository-name cicd-demo \
  --image-ids imageTag=latest \
  --region ap-northeast-2

# 3. GitHub Repository 삭제 (선택)
# GitHub 웹에서 수동 삭제
```

---

## 📊 Demo 체크리스트

### 사전 준비
- [ ] GitHub 계정 및 Repository
- [ ] AWS 계정 (ECR, EKS 권한)
- [ ] EKS 클러스터 실행 중
- [ ] kubectl 및 Helm 설치

### Demo 1: Repository 준비
- [ ] Repository 생성
- [ ] 샘플 애플리케이션 코드
- [ ] Helm Chart 준비
- [ ] GitHub Secrets 설정

### Demo 2: Docker 빌드
- [ ] 빌드 워크플로우 작성
- [ ] 워크플로우 실행 확인
- [ ] ECR 이미지 확인

### Demo 3: Kubernetes 배포
- [ ] 배포 워크플로우 작성
- [ ] 자동 배포 확인
- [ ] 배포 검증

### Demo 4: 전체 테스트
- [ ] 코드 변경 및 푸시
- [ ] 파이프라인 실행 확인
- [ ] 배포 결과 검증

### 정리
- [ ] 리소스 정리 (선택)
- [ ] Q&A 진행

---

## 🎯 Demo 성공 기준

### 기술적 성공
- [ ] 모든 워크플로우 정상 실행
- [ ] Docker 이미지 ECR 푸시 성공
- [ ] Kubernetes 배포 성공
- [ ] 애플리케이션 정상 동작

### 교육적 성공
- [ ] 학생들이 CI/CD 흐름 이해
- [ ] GitHub Actions 작성 방법 습득
- [ ] 자동 배포의 장점 체감
- [ ] 질문에 대한 명확한 답변

---

<div align="center">

**🔄 완전 자동화** • **🐳 Docker 빌드** • **🚀 Kubernetes 배포**

*학생들이 CI/CD의 강력함을 체감하는 Demo*

</div>
