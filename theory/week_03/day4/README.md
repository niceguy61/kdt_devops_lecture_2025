# Week 3 Day 4: GitOps와 ArgoCD

<div align="center">

**🚀 GitOps 개념** • **🔄 ArgoCD** • **📦 자동 배포**

*CNCF 기초 과정 - GitOps부터 ArgoCD까지, 선언적 배포 마스터*

</div>

---

## 🕘 세션 정보
**시간**: 09:00-11:50 (이론 2.5시간) + 13:00-14:30 (실습 1.5시간)
**목표**: GitOps 개념 + ArgoCD 설치/구성 + 자동 배포 파이프라인
**방식**: 협업 중심 학습 + 레벨별 차별화

## 🎯 세션 목표
### 📚 학습 목표
- **이해 목표**: GitOps 개념, ArgoCD 아키텍처, 선언적 배포 완전 이해
- **적용 목표**: ArgoCD를 통한 자동 배포 파이프라인 구축
- **협업 목표**: 팀별 GitOps 워크플로우 구성 및 관리

---

## 📖 Session 1: GitOps 개념과 장점 + 선언적 배포 (50분)

### 🔍 개념 1: GitOps 기본 개념 (15분)
> **정의**: Git 저장소를 단일 진실 소스(Single Source of Truth)로 사용하여 선언적으로 인프라와 애플리케이션을 관리하는 방법론

**GitOps 핵심 원칙**:
- **선언적 구성**: 원하는 상태를 YAML로 선언
- **Git 중심**: 모든 변경사항이 Git을 통해 관리
- **자동 동기화**: Git 변경 시 자동으로 클러스터에 반영
- **지속적 모니터링**: 실제 상태와 원하는 상태 비교

### 🔍 개념 2: 전통적 CI/CD vs GitOps (15분)
> **정의**: Push 방식과 Pull 방식의 배포 패러다임 차이점

**비교표**:
| 구분 | 전통적 CI/CD | GitOps |
|------|-------------|--------|
| **배포 방식** | Push (CI가 클러스터에 배포) | Pull (클러스터가 Git에서 가져옴) |
| **권한 관리** | CI 시스템이 클러스터 권한 필요 | 클러스터 내부에서만 권한 필요 |
| **보안** | 외부 시스템의 클러스터 접근 | 클러스터 외부 접근 불필요 |
| **가시성** | 배포 상태 추적 어려움 | Git 히스토리로 모든 변경 추적 |
| **롤백** | 복잡한 롤백 프로세스 | Git revert로 간단한 롤백 |

### 🔍 개념 3: GitOps 장점과 도구 생태계 (15분)
> **정의**: GitOps 도입으로 얻을 수 있는 이점과 주요 도구들

**GitOps 장점**:
- **개발자 친화적**: Git 워크플로우 활용
- **감사 가능성**: 모든 변경사항 Git 히스토리에 기록
- **재해 복구**: Git에서 전체 시스템 상태 복원 가능
- **보안 강화**: 클러스터 외부 접근 최소화

**주요 GitOps 도구**:
- **ArgoCD**: 가장 인기 있는 GitOps 도구
- **Flux**: CNCF 졸업 프로젝트
- **Jenkins X**: CI/CD와 GitOps 통합
- **Tekton**: 클라우드 네이티브 CI/CD

### 💭 함께 생각해보기 (5분)
**🤝 페어 토론**:
1. "GitOps가 DevOps 문화에 미치는 영향은?"
2. "어떤 상황에서 GitOps를 도입하면 좋을까요?"

---

## 📖 Session 2: ArgoCD 아키텍처 + 설치 및 구성 (50분)

### 🔍 개념 1: ArgoCD 아키텍처 (15분)
> **정의**: ArgoCD의 구성 요소와 동작 원리

**ArgoCD 구성 요소**:
- **API Server**: 웹 UI, CLI, gRPC API 제공
- **Repository Server**: Git 저장소 연결 및 매니페스트 생성
- **Application Controller**: 애플리케이션 상태 모니터링 및 동기화
- **Redis**: 캐시 및 세션 저장소
- **Dex**: OIDC 인증 서버 (선택사항)

### 🔍 개념 2: ArgoCD 설치 방법 (15분)
> **정의**: 다양한 환경에서 ArgoCD를 설치하는 방법

**설치 옵션**:
- **Manifest 설치**: kubectl apply로 직접 설치
- **Helm Chart**: Helm을 통한 커스터마이징 설치
- **Operator**: ArgoCD Operator를 통한 관리
- **Docker Desktop**: 로컬 개발 환경 설치

### 🔍 개념 3: ArgoCD 기본 구성 (15분)
> **정의**: ArgoCD 초기 설정과 기본 구성 요소

**기본 구성 요소**:
- **Project**: 애플리케이션 그룹화 및 권한 관리
- **Application**: Git 저장소와 클러스터 연결
- **Repository**: Git 저장소 연결 설정
- **Cluster**: 배포 대상 클러스터 설정

### 💭 함께 생각해보기 (5분)
**🤝 페어 토론**:
1. "ArgoCD의 어떤 구성 요소가 가장 중요할까요?"
2. "멀티 클러스터 환경에서 ArgoCD 구성 방법은?"

---

## 📖 Session 3: Application 배포 + Sync 정책 + 롤백 전략 (50분)

### 🔍 개념 1: ArgoCD Application 구성 (15분)
> **정의**: ArgoCD에서 애플리케이션을 정의하고 관리하는 방법

**Application 주요 설정**:
- **Source**: Git 저장소 URL, 브랜치, 경로
- **Destination**: 배포 대상 클러스터와 네임스페이스
- **Sync Policy**: 자동/수동 동기화 정책
- **Health Check**: 애플리케이션 상태 확인 방법

### 🔍 개념 2: Sync 정책과 전략 (15분)
> **정의**: ArgoCD의 동기화 정책과 다양한 배포 전략

**Sync 정책**:
- **Manual Sync**: 수동으로 동기화 트리거
- **Auto Sync**: Git 변경 시 자동 동기화
- **Self Heal**: 클러스터 변경 시 자동 복원
- **Prune**: 불필요한 리소스 자동 삭제

**배포 전략**:
- **Replace**: 기존 리소스 삭제 후 새로 생성
- **Apply**: kubectl apply와 동일한 방식
- **Sync Waves**: 단계별 순차 배포
- **Hooks**: 배포 전후 작업 실행

### 🔍 개념 3: 롤백과 히스토리 관리 (15분)
> **정의**: ArgoCD를 통한 안전한 롤백과 배포 히스토리 관리

**롤백 방법**:
- **Git Revert**: Git 커밋 되돌리기
- **ArgoCD History**: ArgoCD UI에서 이전 버전으로 롤백
- **Sync to Revision**: 특정 Git 커밋으로 동기화
- **Rollback Hook**: 롤백 시 실행할 작업 정의

### 💭 함께 생각해보기 (5분)
**🤝 페어 토론**:
1. "어떤 상황에서 Auto Sync를 사용해야 할까요?"
2. "안전한 롤백을 위한 베스트 프랙티스는?"

---

## 🛠️ 실습 (1.5시간)

### 🎯 실습 개요
**목표**: ArgoCD를 통한 GitOps 파이프라인 구축

### 🚀 Lab 1: ArgoCD 설치 + 첫 번째 애플리케이션 배포 (50분)

#### Step 1: ArgoCD 설치 (15분)
```bash
# 1. ArgoCD 네임스페이스 생성
kubectl create namespace argocd

# 2. ArgoCD 설치
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 3. ArgoCD 서비스 확인
kubectl get pods -n argocd
kubectl get svc -n argocd

# 4. ArgoCD UI 접근을 위한 포트 포워딩
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# 5. 초기 admin 패스워드 확인
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

#### Step 2: 첫 번째 애플리케이션 배포 (20분)
```yaml
# guestbook-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: guestbook
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

```bash
# 애플리케이션 배포
kubectl apply -f guestbook-app.yaml

# ArgoCD UI에서 확인 (https://localhost:8080)
# Username: admin
# Password: (위에서 확인한 패스워드)
```

#### Step 3: 동기화 및 상태 확인 (15분)
```bash
# 1. ArgoCD CLI 설치 (선택사항)
# Windows: choco install argocd-cli
# macOS: brew install argocd
# Linux: curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64

# 2. CLI 로그인
argocd login localhost:8080 --username admin --password <password> --insecure

# 3. 애플리케이션 상태 확인
argocd app list
argocd app get guestbook

# 4. 수동 동기화
argocd app sync guestbook

# 5. 배포된 리소스 확인
kubectl get all -l app.kubernetes.io/instance=guestbook
```

### 🌟 Lab 2: Git 기반 자동 배포 + 멀티 환경 관리 (50분)

#### Step 1: Git 저장소 준비 (15분)
```bash
# 1. 로컬 Git 저장소 생성
mkdir my-k8s-apps
cd my-k8s-apps
git init

# 2. 환경별 디렉토리 구조 생성
mkdir -p environments/{dev,staging,prod}
mkdir -p apps/nginx

# 3. 기본 애플리케이션 매니페스트 생성
cat > apps/nginx/deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
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
EOF

cat > apps/nginx/service.yaml << EOF
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
  type: ClusterIP
EOF
```

#### Step 2: 환경별 Kustomization 설정 (20분)
```yaml
# environments/dev/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: dev

resources:
- ../../apps/nginx

patchesStrategicMerge:
- replica-patch.yaml

---
# environments/dev/replica-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 1
```

```yaml
# environments/staging/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: staging

resources:
- ../../apps/nginx

patchesStrategicMerge:
- replica-patch.yaml

---
# environments/staging/replica-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 2
```

#### Step 3: ArgoCD 애플리케이션 생성 (15분)
```yaml
# dev-nginx-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: nginx-dev
  namespace: argocd
spec:
  project: default
  source:
    repoURL: <YOUR_GIT_REPO_URL>
    targetRevision: HEAD
    path: environments/dev
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true

---
# staging-nginx-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: nginx-staging
  namespace: argocd
spec:
  project: default
  source:
    repoURL: <YOUR_GIT_REPO_URL>
    targetRevision: HEAD
    path: environments/staging
  destination:
    server: https://kubernetes.default.svc
    namespace: staging
  syncPolicy:
    syncOptions:
    - CreateNamespace=true
```

```bash
# Git에 커밋 및 푸시
git add .
git commit -m "Initial nginx application setup"
git remote add origin <YOUR_GIT_REPO_URL>
git push -u origin main

# ArgoCD 애플리케이션 배포
kubectl apply -f dev-nginx-app.yaml
kubectl apply -f staging-nginx-app.yaml

# 상태 확인
argocd app list
kubectl get pods -n dev
kubectl get pods -n staging
```

---

## 📝 일일 마무리

### ✅ 오늘의 성과
- [ ] GitOps 개념과 장점 완전 이해
- [ ] ArgoCD 설치 및 기본 구성 완료
- [ ] 첫 번째 애플리케이션 GitOps 배포 성공
- [ ] 멀티 환경 관리 파이프라인 구축
- [ ] 자동 동기화 및 롤백 테스트 완료

### 🎯 내일 준비사항
- **예습**: Service Mesh와 Istio의 개념 생각해보기
- **복습**: ArgoCD CLI 명령어와 UI 사용법 연습
- **환경**: Git 저장소와 ArgoCD 애플리케이션 정리

---

<div align="center">

**🎉 Day 4 완료!** 

*GitOps와 ArgoCD를 통한 자동 배포 파이프라인을 완전히 마스터했습니다*

</div>