# Challenge 1 힌트 모음

## 🚨 문제 1: Git 저장소 인증 실패

### 힌트 1: 인증 방법 확인
```bash
# ArgoCD가 사용하는 인증 방법 확인
argocd repo list

# 특정 저장소 상세 정보
argocd repo get https://github.com/<username>/k8s-gitops-demo.git
```

### 힌트 2: 인증 정보 추가
```bash
# HTTPS + Personal Access Token
argocd repo add https://github.com/<username>/k8s-gitops-demo.git \
  --username <username> \
  --password <token>

# SSH Key 방식
argocd repo add git@github.com:<username>/k8s-gitops-demo.git \
  --ssh-private-key-path ~/.ssh/id_rsa
```

### 힌트 3: GitHub Token 생성
```
1. GitHub → Settings → Developer settings
2. Personal access tokens → Tokens (classic)
3. Generate new token
4. repo 권한 선택
5. 생성된 토큰 복사
```

---

## 🚨 문제 2: 매니페스트 YAML 문법 오류

### 힌트 1: YAML 검증 도구
```bash
# YAML 문법 체크
yamllint deployment.yaml

# Kubernetes 리소스 검증
kubectl apply --dry-run=client -f deployment.yaml
```

### 힌트 2: 일반적인 YAML 오류
```yaml
# 오류 1: 들여쓰기 부족
spec:
replicas: 3  # 2칸 들여쓰기 필요

# 오류 2: 콜론 뒤 공백 없음
name:nginx  # 콜론 뒤 공백 필요

# 오류 3: 리스트 항목 들여쓰기
containers:
- name: nginx
image: nginx  # 2칸 더 들여쓰기 필요
```

### 힌트 3: resources 위치
```yaml
# 잘못된 위치 (containers와 같은 레벨)
spec:
  containers:
  - name: nginx
  resources:  # 잘못됨

# 올바른 위치 (containers 하위)
spec:
  containers:
  - name: nginx
    resources:  # 올바름
```

---

## 🚨 문제 3: Application 설정 오류

### 힌트 1: 브랜치 확인
```bash
# 원격 브랜치 목록
git ls-remote --heads https://github.com/<username>/k8s-gitops-demo.git

# 로컬에서 확인
git branch -r
```

### 힌트 2: 경로 확인
```bash
# Git 저장소 클론
git clone https://github.com/<username>/k8s-gitops-demo.git
cd k8s-gitops-demo

# 디렉토리 구조 확인
tree apps/
# 또는
find apps -type d
```

### 힌트 3: Application 수정
```bash
# targetRevision 수정
kubectl patch application challenge-app-3 -n argocd --type merge \
  -p '{"spec":{"source":{"targetRevision":"main"}}}'

# path 수정
kubectl patch application challenge-app-3 -n argocd --type merge \
  -p '{"spec":{"source":{"path":"apps/demo-app"}}}'

# 네임스페이스 자동 생성 옵션
kubectl patch application challenge-app-3 -n argocd --type merge \
  -p '{"spec":{"syncPolicy":{"syncOptions":["CreateNamespace=true"]}}}'
```

---

## 🚨 문제 4: 동기화 정책 충돌

### 힌트 1: 현재 정책 확인
```bash
# Application의 syncPolicy 확인
kubectl get application challenge-app-4 -n argocd \
  -o jsonpath='{.spec.syncPolicy}' | jq

# 수동 변경 사항 확인
argocd app diff challenge-app-4
```

### 힌트 2: Auto-sync 활성화
```bash
# automated 섹션 추가
kubectl patch application challenge-app-4 -n argocd --type merge \
  -p '{"spec":{"syncPolicy":{"automated":{"prune":true,"selfHeal":true}}}}'
```

### 힌트 3: 강제 동기화
```bash
# 수동 변경 무시하고 Git 상태로 강제 동기화
argocd app sync challenge-app-4 --force

# Prune 옵션으로 불필요한 리소스 제거
argocd app sync challenge-app-4 --prune
```

---

## 🔍 일반적인 디버깅 명령어

### ArgoCD 관련
```bash
# Application 상세 정보
argocd app get <app-name>

# 동기화 이력
argocd app history <app-name>

# 실시간 로그
argocd app logs <app-name> -f

# Application Controller 로그
kubectl logs -n argocd deployment/argocd-application-controller --tail=100
```

### Kubernetes 관련
```bash
# Pod 상태 확인
kubectl get pods -n day5-challenge

# Pod 로그
kubectl logs -n day5-challenge <pod-name>

# 이벤트 확인
kubectl get events -n day5-challenge --sort-by='.lastTimestamp'

# 리소스 상세 정보
kubectl describe pod -n day5-challenge <pod-name>
```

### Git 관련
```bash
# 최근 커밋 확인
git log --oneline -10

# 변경 사항 확인
git diff

# 특정 파일 이력
git log --follow -- <file-path>
```

---

## 💡 문제 해결 프로세스

1. **증상 파악**: 오류 메시지 정확히 읽기
2. **로그 분석**: ArgoCD, Pod, Event 로그 확인
3. **설정 검증**: YAML 문법, Application 설정 확인
4. **단계별 테스트**: 각 수정 후 즉시 검증
5. **문서화**: 해결 과정 기록

---

## 🚀 빠른 해결 체크리스트

### 문제 1 체크리스트
- [ ] GitHub Personal Access Token 생성
- [ ] ArgoCD에 저장소 인증 정보 추가
- [ ] Repository 연결 상태 확인
- [ ] Application 동기화 재시도

### 문제 2 체크리스트
- [ ] YAML 파일 들여쓰기 확인
- [ ] resources 위치 수정
- [ ] Git에 커밋 및 Push
- [ ] ArgoCD 자동 동기화 대기

### 문제 3 체크리스트
- [ ] Git 브랜치 존재 확인
- [ ] 디렉토리 경로 확인
- [ ] Application 설정 수정
- [ ] 네임스페이스 생성 또는 자동 생성 옵션

### 문제 4 체크리스트
- [ ] 현재 동기화 정책 확인
- [ ] Auto-sync 활성화
- [ ] Prune, SelfHeal 옵션 설정
- [ ] 강제 동기화 실행
