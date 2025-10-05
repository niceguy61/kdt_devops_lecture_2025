#!/bin/bash

# Week 3 Day 5 Challenge 1: GitOps 장애 환경 설정

echo "=== Challenge 1: GitOps 장애 환경 설정 시작 ==="

# 1. ArgoCD 설치 확인
echo "1. ArgoCD 설치 확인 중..."
if ! kubectl get namespace argocd &> /dev/null; then
    echo "ArgoCD 설치 중..."
    kubectl create namespace argocd
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    
    echo "ArgoCD 준비 대기 중..."
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
else
    echo "✅ ArgoCD 이미 설치됨"
fi

# 2. Challenge 네임스페이스 생성
echo "2. Challenge 네임스페이스 생성 중..."
kubectl create namespace day5-challenge --dry-run=client -o yaml | kubectl apply -f -
echo "✅ 네임스페이스 생성 완료"

# 3. 기본 네임스페이스 설정
echo "3. 기본 네임스페이스 설정 중..."
kubectl config set-context --current --namespace=day5-challenge
echo "✅ 기본 네임스페이스: day5-challenge"

# 4. 문제 Application 배포
echo "4. 문제가 있는 Application 배포 중..."

# Challenge App 1: 인증 실패 (잘못된 토큰)
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: challenge-app-1
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/invalid-user/k8s-gitops-demo.git
    targetRevision: main
    path: apps/demo-app
  destination:
    server: https://kubernetes.default.svc
    namespace: day5-challenge
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF

# Challenge App 2: YAML 문법 오류
mkdir -p /tmp/challenge-app-2
cat <<EOF > /tmp/challenge-app-2/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: challenge-app-2
  namespace: day5-challenge
spec:
  replicas: 3
  selector:
    matchLabels:
      app: challenge-app-2
  template:
    metadata:
      labels:
        app: challenge-app-2
    spec:
      containers:
      - name: nginx
        image: nginxinc/nginx-unprivileged:1.21
        ports:
        - containerPort: 8080
      resources:
        requests:
          cpu: 100m
EOF

echo "⚠️  Challenge App 2: YAML 파일을 Git 저장소에 추가해야 합니다"
echo "   파일 위치: /tmp/challenge-app-2/deployment.yaml"

# Challenge App 3: 잘못된 설정
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: challenge-app-3
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/<username>/k8s-gitops-demo.git
    targetRevision: develop
    path: apps/wrong-path
  destination:
    server: https://kubernetes.default.svc
    namespace: day5-challenge
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

# Challenge App 4: 동기화 정책 문제
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: challenge-app-4
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/<username>/k8s-gitops-demo.git
    targetRevision: main
    path: apps/demo-app
  destination:
    server: https://kubernetes.default.svc
    namespace: day5-challenge
  syncPolicy:
    syncOptions:
    - CreateNamespace=true
EOF

echo "✅ 문제 Application 배포 완료"

echo ""
echo "=== Challenge 환경 설정 완료 ==="
echo ""
echo "클러스터 정보:"
echo "- 클러스터명: challenge-cluster"
echo "- 기본 네임스페이스: day5-challenge"
echo ""
echo "배포된 Application:"
echo "- challenge-app-1: Git 인증 실패"
echo "- challenge-app-2: YAML 문법 오류"
echo "- challenge-app-3: Application 설정 오류"
echo "- challenge-app-4: 동기화 정책 문제"
echo ""
echo "다음 명령어로 상태 확인:"
echo "  argocd app list"
echo "  kubectl get application -n argocd"
echo "  kubectl get all"
echo ""
echo "⚠️  주의: <username>을 본인의 GitHub username으로 변경하세요"
