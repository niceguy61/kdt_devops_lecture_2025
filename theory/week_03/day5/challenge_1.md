# Week 3 Day 5 Challenge 1: GitOps 장애 복구 미션

<div align="center">

**🚨 긴급 장애 대응** • **🔍 문제 진단** • **🛠️ 신속 복구** • **📊 GitOps 마스터**

*실무 GitOps 장애 상황을 시뮬레이션하여 문제 해결 능력 향상*

</div>

---

## 🕘 Challenge 정보
**시간**: 15:30-17:00 (90분)  
**목표**: GitOps 장애 진단 및 복구 능력 향상  
**방식**: 문제 배포 → 진단 → 해결 → 검증

## 🎯 Challenge 목표

### 📚 학습 목표
- **진단 능력**: ArgoCD 및 Git 연동 문제 체계적 분석
- **해결 능력**: 신속한 장애 복구 및 서비스 정상화
- **예방 대책**: 재발 방지를 위한 모니터링 및 알림 설정

### 🛠️ 실무 역량
- **장애 대응**: 실무 장애 대응 프로세스 체험
- **근본 원인 분석**: 표면이 아닌 근본 원인 파악
- **문서화**: 장애 해결 과정 체계적 기록

---

## 🚨 Challenge 시나리오: "새벽 긴급 배포 후 전체 동기화 실패"

### 📖 배경 상황
**시나리오**: 
금요일 새벽 2시, 긴급 보안 패치를 위한 배포가 진행되었습니다. 
배포 담당자가 서둘러 여러 설정을 변경한 후 퇴근했고, 
월요일 아침 출근하니 ArgoCD의 모든 애플리케이션이 동기화 실패 상태입니다.

**긴급도**: 🔴 **Critical**  
**영향도**: 💰 **High** - 모든 서비스 배포 중단  
**제한시간**: ⏰ **90분**

**당신의 미션**:
1. 각 장애 상황을 신속히 진단
2. 근본 원인을 파악하고 해결
3. 서비스를 정상 상태로 복구
4. 재발 방지 대책 수립

---

## 🔧 Challenge 환경 배포

**💡 힌트 모음**: [hints.md](./lab_scripts/challenge1/hints.md) - 막힐 때 참고하세요!

### Step 1: Challenge용 환경 준비

```bash
# Challenge 디렉토리로 이동
cd /mnt/d/github/kdt_devops_lecture_2025/theory/week_03/day5/lab_scripts/challenge1

# Challenge 환경 자동 배포
./00-setup-challenge.sh
```

**배포되는 환경**:
- ✅ ArgoCD 설치 및 설정
- ✅ 4개의 문제가 있는 Application
- ✅ Git 저장소 시뮬레이션
- ✅ 의도적 오류 주입

---

## 🚨 문제 상황 1: Git 저장소 인증 실패 (20분)

**📋 문제 파일**: [broken-app-1.yaml](./lab_scripts/challenge1/broken-app-1.yaml)

### 증상
```bash
# ArgoCD Application 상태 확인
argocd app get challenge-app-1

# 출력:
# Health Status:     Unknown
# Sync Status:       Unknown
# Message:           rpc error: code = Unknown desc = authentication required
```

### 🔍 진단 과정

**1단계: 현상 확인**
```bash
# Application 상세 정보
kubectl get application challenge-app-1 -n argocd -o yaml

# Repository 연결 상태 확인
argocd repo list

# 오류 로그 확인
kubectl logs -n argocd deployment/argocd-repo-server --tail=50 | grep -i auth
```

**2단계: 상세 분석**
```bash
# Repository credentials 확인
kubectl get secret -n argocd -l argocd.argoproj.io/secret-type=repository

# Secret 내용 확인
kubectl get secret <repo-secret-name> -n argocd -o yaml
```

**3단계: 근본 원인 파악**
- Private 저장소 접근을 위한 인증 정보 만료
- SSH Key 또는 Personal Access Token 갱신 필요

### 💡 힌트
<details>
<summary>힌트 1: 인증 방법 확인</summary>

```bash
# ArgoCD가 사용하는 인증 방법 확인
argocd repo get https://github.com/<username>/k8s-gitops-demo.git
```
</details>

<details>
<summary>힌트 2: 새 인증 정보 추가</summary>

```bash
# HTTPS + Token 방식
argocd repo add https://github.com/<username>/k8s-gitops-demo.git \
  --username <username> \
  --password <personal-access-token>

# 또는 SSH 방식
argocd repo add git@github.com:<username>/k8s-gitops-demo.git \
  --ssh-private-key-path ~/.ssh/id_rsa
```
</details>

### ✅ 해결 방법

**방법 1: Personal Access Token 갱신**
```bash
# 1. GitHub에서 새 Token 생성
# Settings → Developer settings → Personal access tokens → Generate new token
# repo 권한 선택

# 2. ArgoCD에 새 인증 정보 추가
argocd repo add https://github.com/<username>/k8s-gitops-demo.git \
  --username <username> \
  --password <new-token> \
  --upsert

# 3. 연결 테스트
argocd repo get https://github.com/<username>/k8s-gitops-demo.git

# 4. Application 동기화 재시도
argocd app sync challenge-app-1
```

**방법 2: SSH Key 사용**
```bash
# 1. SSH Key 생성 (없는 경우)
ssh-keygen -t ed25519 -C "argocd@example.com" -f ~/.ssh/argocd_key

# 2. GitHub에 Public Key 등록
# Settings → SSH and GPG keys → New SSH key
cat ~/.ssh/argocd_key.pub

# 3. ArgoCD에 Private Key 등록
argocd repo add git@github.com:<username>/k8s-gitops-demo.git \
  --ssh-private-key-path ~/.ssh/argocd_key \
  --insecure-ignore-host-key

# 4. Application의 repoURL을 SSH로 변경
kubectl patch application challenge-app-1 -n argocd --type merge \
  -p '{"spec":{"source":{"repoURL":"git@github.com:<username>/k8s-gitops-demo.git"}}}'

# 5. 동기화
argocd app sync challenge-app-1
```

### 🎯 검증

```bash
# Repository 연결 상태 확인
argocd repo get https://github.com/<username>/k8s-gitops-demo.git
# 출력: CONNECTION STATUS: Successful

# Application 상태 확인
argocd app get challenge-app-1
# 출력: Sync Status: Synced

# Pod 상태 확인
kubectl get pods -n day5-challenge
```

---

## 🚨 문제 상황 2: 매니페스트 문법 오류 (25분)

**📋 문제 파일**: [broken-app-2-deployment.yaml](./lab_scripts/challenge1/broken-app-2-deployment.yaml)

### 증상
```bash
# Application 상태 확인
argocd app get challenge-app-2

# 출력:
# Health Status:     Missing
# Sync Status:       OutOfSync
# Message:           ComparisonError: error unmarshaling JSON: yaml: line 12: mapping values are not allowed in this context
```

### 🔍 진단 과정

**1단계: 현상 확인**
```bash
# Application 상세 정보
argocd app get challenge-app-2 --show-operation

# Git 저장소에서 매니페스트 확인
git clone https://github.com/<username>/k8s-gitops-demo.git
cd k8s-gitops-demo/apps/challenge-app-2

# YAML 파일 확인
cat deployment.yaml
```

**2단계: YAML 문법 검증**
```bash
# YAML 문법 체크
yamllint deployment.yaml

# Kubernetes 리소스 검증
kubectl apply --dry-run=client -f deployment.yaml
```

**3단계: 근본 원인 파악**
- YAML 들여쓰기 오류
- 잘못된 API 버전
- 필수 필드 누락

### 💡 힌트
<details>
<summary>힌트 1: 일반적인 YAML 오류</summary>

```yaml
# 잘못된 예시 1: 들여쓰기 오류
apiVersion: apps/v1
kind: Deployment
spec:
replicas: 3  # 들여쓰기 부족

# 잘못된 예시 2: 콜론 뒤 공백 없음
metadata:
  name:web-app  # 콜론 뒤 공백 필요

# 잘못된 예시 3: 리스트 형식 오류
containers:
- name: nginx
image: nginx  # 들여쓰기 오류
```
</details>

### ✅ 해결 방법

**의도적 오류 예시**:
```yaml
# apps/challenge-app-2/deployment.yaml (오류 있음)
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
      resources:  # 잘못된 들여쓰기
        requests:
          cpu: 100m
```

**Git에 수정사항 반영**:
```bash
# 파일 수정 후
git add apps/challenge-app-2/deployment.yaml
git commit -m "Fix YAML indentation error"
git push origin main

# ArgoCD 동기화
argocd app sync challenge-app-2
```

### 🎯 검증
```bash
argocd app get challenge-app-2
kubectl get all -n day5-challenge
```

---

## 🚨 문제 상황 3: Application 설정 오류 (25분)

**📋 문제 파일**: [broken-app-3.yaml](./lab_scripts/challenge1/broken-app-3.yaml)

### 증상
```bash
argocd app get challenge-app-3
# 출력: repository not found
```

### 🔍 진단 과정
```bash
# Application 설정 확인
kubectl get application challenge-app-3 -n argocd -o yaml

# 브랜치 확인
git ls-remote --heads https://github.com/<username>/k8s-gitops-demo.git
```

### ✅ 해결 방법
```bash
# 브랜치 수정
kubectl patch application challenge-app-3 -n argocd --type merge \
  -p '{"spec":{"source":{"targetRevision":"main"}}}'

# 경로 수정
kubectl patch application challenge-app-3 -n argocd --type merge \
  -p '{"spec":{"source":{"path":"apps/app-3"}}}'

# 네임스페이스 생성
kubectl create namespace day5-challenge
```

### 🎯 검증
```bash
argocd app get challenge-app-3
kubectl get all -n day5-challenge
```


---

## 🚨 문제 상황 4: 동기화 정책 충돌 (20분)

**📋 문제 파일**: [broken-app-4.yaml](./lab_scripts/challenge1/broken-app-4.yaml)

### 증상
```bash
argocd app get challenge-app-4
# 출력: Sync Status: OutOfSync (수동 변경 감지)
```

### 🔍 진단 과정
```bash
# Application 동기화 정책 확인
kubectl get application challenge-app-4 -n argocd -o jsonpath='{.spec.syncPolicy}'

# 실제 클러스터 상태 vs Git 상태 비교
argocd app diff challenge-app-4
```

### ✅ 해결 방법

**1. Auto-sync 활성화**
```bash
kubectl patch application challenge-app-4 -n argocd --type merge \
  -p '{"spec":{"syncPolicy":{"automated":{"prune":true,"selfHeal":true}}}}'
```

**2. 수동 변경 제거 (강제 동기화)**
```bash
argocd app sync challenge-app-4 --force
```

**3. Prune 옵션으로 불필요한 리소스 제거**
```bash
argocd app sync challenge-app-4 --prune
```

### 🎯 검증
```bash
argocd app get challenge-app-4
# 출력: Sync Status: Synced, Auto-sync: Enabled
```

---

## ✅ 최종 검증

### 자동 검증 스크립트
```bash
# 모든 문제 해결 후 실행
cd /mnt/d/github/kdt_devops_lecture_2025/theory/week_03/day5/lab_scripts/challenge1
./verify-success.sh
```

**검증 항목**:
- ✅ Challenge App 1: Synced & Healthy (Git 인증 해결)
- ✅ Challenge App 2: Synced & Healthy (YAML 오류 수정)
- ✅ Challenge App 3: Synced & Healthy (설정 오류 수정)
- ✅ Challenge App 4: Synced & Healthy & Auto-sync (동기화 정책 수정)
- ✅ Pod 상태: Running

### 수동 검증
```bash
# 모든 Application 상태
argocd app list

# 각 Application 상세 확인
for app in challenge-app-{1..4}; do
  echo "=== $app ==="
  argocd app get $app | grep -E "Health Status|Sync Status"
  echo ""
done

# Pod 상태 확인
kubectl get pods -n day5-challenge
```

**성공 기준**:
- [ ] challenge-app-1: Synced, Healthy (인증 문제 해결)
- [ ] challenge-app-2: Synced, Healthy (YAML 오류 수정)
- [ ] challenge-app-3: Synced, Healthy (설정 오류 수정)
- [ ] challenge-app-4: Synced, Healthy (동기화 정책 수정)

---

## 💡 Challenge 회고

### 🤝 팀 회고 (15분)
1. **가장 어려웠던 문제**: 어떤 문제가 가장 도전적이었나요?
2. **효과적인 디버깅 방법**: 어떤 방법이 문제 해결에 도움이 되었나요?
3. **팀워크 경험**: 팀원들과 어떻게 협력했나요?
4. **실무 적용 방안**: 실제 업무에서 어떻게 활용할 수 있을까요?

### 📊 학습 성과
- ✅ GitOps 장애 진단 및 복구 프로세스 체험
- ✅ ArgoCD 설정 및 문제 해결 능력 향상
- ✅ Git, YAML, Kubernetes 통합 이해
- ✅ 실무 장애 대응 경험 축적

### 🎯 재발 방지 대책

**1. 모니터링 강화**
```yaml
# ArgoCD Notification 설정
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-notifications-cm
  namespace: argocd
data:
  trigger.on-sync-failed: |
    - when: app.status.operationState.phase in ['Error', 'Failed']
      send: [app-sync-failed]
  template.app-sync-failed: |
    message: |
      Application {{.app.metadata.name}} sync failed!
      Error: {{.app.status.operationState.message}}
```

**2. Pre-commit Hook**
```bash
# .git/hooks/pre-commit
#!/bin/bash
# YAML 문법 검증
for file in $(git diff --cached --name-only | grep -E '\.ya?ml$'); do
  yamllint "$file" || exit 1
  kubectl apply --dry-run=client -f "$file" || exit 1
done
```

**3. 정기 점검 체크리스트**
- [ ] Repository 인증 정보 유효기간 확인
- [ ] Application 설정 정기 검토
- [ ] YAML 문법 자동 검증 도구 적용
- [ ] 동기화 정책 일관성 유지

---

## 🧹 Challenge 정리

```bash
# Challenge 환경 정리
cd /mnt/d/github/kdt_devops_lecture_2025/theory/week_03/day5/lab_scripts/challenge1
./99-cleanup.sh

# 또는 수동 정리
kubectl delete application challenge-app-{1..4} -n argocd
kubectl delete namespace challenge-{1..4}
```



---

## 📋 Challenge 기본 설정

### 클러스터 및 네임스페이스 정보
- **클러스터명**: challenge-cluster
- **기본 네임스페이스**: day5-challenge
- **ArgoCD 네임스페이스**: argocd

### 네임스페이스 설정 확인
```bash
# 현재 컨텍스트 확인
kubectl config current-context

# 기본 네임스페이스 설정
kubectl config set-context --current --namespace=day5-challenge

# 설정 확인
kubectl config view --minify | grep namespace:
```

---

<div align="center">

**🚨 긴급 대응** • **🔍 체계적 진단** • **🛠️ 신속 복구** • **📊 재발 방지**

*실무 GitOps 장애 대응 능력 완성!*

**Cluster**: challenge-cluster | **Namespace**: day5-challenge

</div>
