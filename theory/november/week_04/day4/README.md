# November Week 4 Day 4: CI/CD 파이프라인

<div align="center">

**🔄 자동화 배포** • **🐳 Docker 빌드** • **🚀 Kubernetes 배포**

*GitHub Actions로 완전 자동화된 배포 파이프라인 구축*

</div>

---

## 🎯 오늘의 목표

### 전체 학습 목표
- CI/CD 개념과 필요성 완전 이해
- GitHub Actions 워크플로우 작성 능력 습득
- Docker 이미지 자동 빌드 및 푸시 구현
- Kubernetes 자동 배포 파이프라인 구축

### 오늘의 성과물
- GitHub Actions 워크플로우 이해
- Docker 이미지 자동화 빌드
- Helm을 활용한 자동 배포
- 완전 자동화된 CI/CD 파이프라인

---

## 📊 학습 구조

### 일일 시간표
```
09:00-09:40  Session 1: CI/CD 기초 (40분)
09:40-10:20  Session 2: GitHub Actions (40분)
10:20-11:00  Session 3: 자동 배포 파이프라인 (40분)
11:00-12:00  강사 Demo: 전체 CI/CD 구축 (60분)
```

### 학습 방식
- **이론 중심**: CI/CD 개념과 GitHub Actions 문법
- **실제 워크플로우 분석**: 실무 파이프라인 구조 분석
- **강사 데모**: 완벽하게 검증된 환경에서 시연
- **비용 절감**: 강사 계정만 사용

---

## 📚 세션별 상세 내용

### Session 1: CI/CD 기초 (09:00-09:40)

**학습 내용**:
- CI/CD가 필요한 이유
- CI/CD 파이프라인 구성 요소
- GitHub Actions 개요
- 워크플로우 기본 구조

**핵심 개념**:
```
CI (Continuous Integration) = 코드 통합 자동화
CD (Continuous Deployment) = 배포 자동화
Pipeline = 빌드 → 테스트 → 배포 자동화
GitHub Actions = GitHub 통합 CI/CD 플랫폼
```

**실습 연계**:
- 워크플로우 파일 구조 이해
- 트리거 이벤트 설정
- Job과 Step 구성

**참조**: [Session 1 상세 내용](./session_1.md)

---

### Session 2: GitHub Actions (09:40-10:20)

**학습 내용**:
- 워크플로우 문법 (YAML)
- Job과 Step 작성
- Secrets 관리
- Marketplace Actions 활용

**핵심 개념**:
```
Workflow = 자동화 프로세스 정의
Job = 독립적으로 실행되는 작업 단위
Step = Job 내부의 개별 명령
Action = 재사용 가능한 작업 단위
```

**실습 연계**:
- Docker 이미지 빌드 워크플로우
- ECR 푸시 자동화
- 환경 변수 및 Secrets 관리

**참조**: [Session 2 상세 내용](./session_2.md)

---

### Session 3: 자동 배포 파이프라인 (10:20-11:00)

**학습 내용**:
- Docker 이미지 빌드 자동화
- ECR 푸시 및 태깅 전략
- Helm을 활용한 Kubernetes 배포
- 배포 검증 및 롤백

**핵심 개념**:
```
Multi-stage Build = 최적화된 이미지 빌드
Image Tagging = 버전 관리 전략
Helm Upgrade = 자동 배포
Health Check = 배포 검증
```

**실습 연계**:
- 전체 파이프라인 구축
- 자동 배포 테스트
- 롤백 시나리오

**참조**: [Session 3 상세 내용](./session_3.md)

---

## 🎬 강사 Demo (11:00-12:00)

### Demo: 완전 자동화 CI/CD 파이프라인

**시연 내용**:

**1. GitHub Repository 준비 (10분)**:
```bash
# Repository 생성
# - 샘플 애플리케이션 코드
# - Dockerfile
# - Helm Chart
# - GitHub Actions 워크플로우

# Secrets 설정
# - AWS_ACCESS_KEY_ID
# - AWS_SECRET_ACCESS_KEY
# - KUBE_CONFIG
```

**2. Docker 이미지 빌드 파이프라인 (15분)**:
```yaml
# .github/workflows/build.yml
name: Build and Push Docker Image

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ap-northeast-2
      
      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1
      
      - name: Build and push
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/myapp:$IMAGE_TAG .
          docker push $ECR_REGISTRY/myapp:$IMAGE_TAG
```

**3. Kubernetes 배포 파이프라인 (20분)**:
```yaml
# .github/workflows/deploy.yml
name: Deploy to Kubernetes

on:
  workflow_run:
    workflows: ["Build and Push Docker Image"]
    types: [completed]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure kubectl
        run: |
          echo "${{ secrets.KUBE_CONFIG }}" | base64 -d > kubeconfig
          export KUBECONFIG=./kubeconfig
      
      - name: Deploy with Helm
        run: |
          helm upgrade --install myapp ./helm/myapp \
            --set image.tag=${{ github.sha }} \
            --namespace production \
            --wait
```

**4. 전체 파이프라인 테스트 (10분)**:
```bash
# 코드 변경 및 푸시
git add .
git commit -m "Update application"
git push origin main

# GitHub Actions 확인
# - Build 워크플로우 실행
# - Deploy 워크플로우 실행
# - Kubernetes 배포 확인

# 배포 검증
kubectl get pods -n production
kubectl rollout status deployment/myapp -n production
```

**5. Q&A (5분)**:
- 질문 답변
- 트러블슈팅 공유
- 베스트 프랙티스 논의

---

## 🔗 학습 자료

### 📚 공식 문서
- [GitHub Actions 문서](https://docs.github.com/en/actions)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)
- [Docker 공식 문서](https://docs.docker.com/)

### 🎯 추천 Actions
- [actions/checkout](https://github.com/actions/checkout)
- [docker/build-push-action](https://github.com/docker/build-push-action)
- [aws-actions/configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials)
- [aws-actions/amazon-ecr-login](https://github.com/aws-actions/amazon-ecr-login)

---

## 💡 Day 4 회고

### 🤝 학습 성과
1. **CI/CD 이해**: 자동화 배포의 필요성과 장점
2. **GitHub Actions**: 워크플로우 작성 능력 습득
3. **Docker 자동화**: 이미지 빌드 및 푸시 자동화
4. **Kubernetes 배포**: Helm을 활용한 자동 배포

### 📊 다음 학습
**Day 5: 모니터링 & 로깅**
- Prometheus 메트릭 수집
- Grafana 대시보드 구성
- ELK Stack 로깅
- 알림 및 장애 대응

---

<div align="center">

**🔄 자동화 배포** • **🐳 Docker 빌드** • **🚀 Kubernetes 배포**

*Day 4 완료! 내일은 모니터링과 로깅을 학습합니다*

</div>
