# Week 3 Day 4 Hands-on 1: 고급 보안 & 클러스터 관리

<div align="center">

**🔒 Pod Security Standards** • **🔐 Secret 암호화** • **💾 ETCD 백업** • **🔄 클러스터 업그레이드**

*Lab 1을 기반으로 고급 보안 기능 및 클러스터 관리 실습*

</div>

---

## 🕘 실습 정보
**시간**: 선택적 심화 실습 (90분)  
**목표**: Lab 1 기반 고급 보안 및 클러스터 관리 기능 구현  
**방식**: Lab 1 확장 + 고급 기능 추가

## 🎯 실습 목표

### 📚 학습 목표
- **Pod Security Standards**: Restricted 정책으로 컨테이너 보안 강화
- **Secret 암호화**: ETCD 레벨 암호화와 External Secrets
- **ETCD 백업/복원**: 클러스터 재해 복구 능력
- **클러스터 업그레이드**: 무중단 업그레이드 시뮬레이션

### 🛠️ 구현 목표
- **보안 강화**: 컨테이너 런타임 보안 정책 적용
- **데이터 보호**: Secret 암호화 및 안전한 관리
- **재해 복구**: ETCD 백업 자동화 및 복원 테스트
- **안정적 운영**: 클러스터 업그레이드 절차 숙지

---

## 🛠️ 환경 준비

### 환경 설정

**🚀 자동화 스크립트 사용**
```bash
cd theory/week_03/day4/lab_scripts/handson1
./setup-environment.sh
```

**📋 스크립트 내용**: [setup-environment.sh](./lab_scripts/handson1/setup-environment.sh)

**수동 실행 (학습용)**
```bash
# 네임스페이스 생성 (없는 경우)
kubectl create namespace development
kubectl create namespace staging
kubectl create namespace production

# 라벨 추가
kubectl label namespace development env=dev
kubectl label namespace staging env=staging
kubectl label namespace production env=prod
```

---

## 🔒 Step 1: Pod Security Standards 적용 (25분)

### Step 1-1: Restricted 정책 적용 (15분)

**목표**: 프로덕션 네임스페이스에 가장 엄격한 보안 정책 적용

**1-1. Pod Security Standards 라벨 적용**

```bash
# Production: restricted 정책
kubectl label namespace production \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/audit=restricted \
  pod-security.kubernetes.io/warn=restricted

# Development: baseline 정책
kubectl label namespace development \
  pod-security.kubernetes.io/enforce=baseline \
  pod-security.kubernetes.io/audit=baseline \
  pod-security.kubernetes.io/warn=baseline

# Staging: baseline 정책
kubectl label namespace staging \
  pod-security.kubernetes.io/enforce=baseline \
  pod-security.kubernetes.io/audit=baseline \
  pod-security.kubernetes.io/warn=baseline

# 정책 확인
kubectl get namespace production -o yaml | grep pod-security
kubectl get namespace development -o yaml | grep pod-security
kubectl get namespace staging -o yaml | grep pod-security
```

### Step 1-2: 보안 강화된 Pod 배포 (10분)

**1-2. Restricted 정책을 만족하는 Pod 배포**

**파일 생성**: `secure-app-pod.yaml`
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-app
  namespace: production
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: nginx:alpine
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      runAsNonRoot: true
      runAsUser: 1000
      capabilities:
        drop:
        - ALL
    volumeMounts:
    - name: cache
      mountPath: /var/cache/nginx
    - name: run
      mountPath: /var/run
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 200m
        memory: 256Mi
  volumes:
  - name: cache
    emptyDir: {}
  - name: run
    emptyDir: {}
```

**배포 및 확인**:
```bash
kubectl apply -f secure-app-pod.yaml

# Pod 상태 확인
kubectl get pod secure-app -n production
kubectl describe pod secure-app -n production
```

**1-3. 위반 사례 테스트 (정책 차단 확인)**

**파일 생성**: `privileged-pod.yaml`
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: privileged-app
  namespace: production
spec:
  containers:
  - name: app
    image: nginx:alpine
    securityContext:
      privileged: true
```

**테스트**:
```bash
# 배포 시도 (차단되어야 함)
kubectl apply -f privileged-pod.yaml

# 예상 결과: Error from server (Forbidden): error when creating...
# Pod Security Standards에 의해 차단됨
```

**실패 이유 분석**:

이 Pod가 차단된 이유는 `production` 네임스페이스에 적용된 **Restricted** Pod Security Standard를 위반했기 때문입니다.

**위반 항목**:
1. **privileged: true** 설정
   - Restricted 정책은 특권 컨테이너를 절대 허용하지 않음
   - 특권 컨테이너는 호스트의 모든 리소스에 접근 가능하여 보안 위험

**Restricted 정책 요구사항**:
- `runAsNonRoot: true` 필수
- `allowPrivilegeEscalation: false` 필수
- `privileged: false` 필수 (기본값)
- `capabilities: drop: [ALL]` 필수
- `seccompProfile: RuntimeDefault` 필수

**보안 관점**:
- 특권 컨테이너는 컨테이너 격리를 무력화
- 호스트 커널에 직접 접근 가능
- 프로덕션 환경에서는 절대 사용 금지

---

## 🔐 Step 2: Secret 암호화 및 관리 (30분)

### Step 2-1: ETCD 암호화 설정 (15분)

**암호화 설정 파일 생성**:

```bash
# 암호화 키 생성
head -c 32 /dev/urandom | base64

# EncryptionConfiguration 생성
# WSL 환경에서는 sudo tee 사용
sudo mkdir -p /etc/kubernetes

cat <<EOF | sudo tee /etc/kubernetes/encryption-config.yaml
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
    - secrets
    providers:
    - aescbc:
        keys:
        - name: key1
          secret: $(head -c 32 /dev/urandom | base64)
    - identity: {}
EOF

# 파일 권한 설정
sudo chmod 600 /etc/kubernetes/encryption-config.yaml
sudo chown root:root /etc/kubernetes/encryption-config.yaml

# 생성 확인
sudo cat /etc/kubernetes/encryption-config.yaml
```

**API Server 설정 업데이트**:

**⚠️ 환경 확인 먼저!**

```bash
# 현재 Kubernetes 환경 확인
kubectl cluster-info

# Kind 사용 중인지 확인
docker ps | grep kind

# Minikube 사용 중인지 확인
minikube status
```

**방법 1: Kind 클러스터 (WSL/Docker Desktop)**

```bash
# Kind 컨트롤 플레인 컨테이너 접속
docker exec -it challenge-cluster-control-plane bash

# 컨테이너 내부에서 실행
cat <<EOF | tee /etc/kubernetes/encryption-config.yaml
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
    - secrets
    providers:
    - aescbc:
        keys:
        - name: key1
          secret: $(head -c 32 /dev/urandom | base64)
    - identity: {}
EOF

# kube-apiserver.yaml 백업 및 수정
cp /etc/kubernetes/manifests/kube-apiserver.yaml \
   /etc/kubernetes/manifests/kube-apiserver.yaml.backup

nano /etc/kubernetes/manifests/kube-apiserver.yaml
# 편집 후 저장: Ctrl+O, Enter, Ctrl+X (추가할 내용은 아래 "추가할 내용" 섹션 참조)

# 컨테이너에서 나가기
exit

# API Server 재시작 확인
kubectl get pods -n kube-system | grep kube-apiserver
```

**방법 2: Minikube**

```bash
# Minikube SSH 접속
minikube ssh

# 위와 동일한 방법으로 설정
sudo nano /etc/kubernetes/manifests/kube-apiserver.yaml

# SSH 종료
exit

# API Server 재시작 확인
kubectl get pods -n kube-system | grep kube-apiserver
```

**방법 3: 실제 클러스터 (마스터 노드 직접 접근 가능)**

```bash
# kube-apiserver.yaml 백업
sudo cp /etc/kubernetes/manifests/kube-apiserver.yaml \
       /etc/kubernetes/manifests/kube-apiserver.yaml.backup

# 설정 파일 수정
sudo nano /etc/kubernetes/manifests/kube-apiserver.yaml
```

**추가할 내용 (모든 환경 공통)**:

1. `spec.containers[0].command` 섹션에 추가:
```yaml
- --encryption-provider-config=/etc/kubernetes/encryption-config.yaml
```

2. `spec.containers[0].volumeMounts` 섹션에 추가:
```yaml
- name: encryption-config
  mountPath: /etc/kubernetes/encryption-config.yaml
  readOnly: true
```

3. `spec.volumes` 섹션에 추가:
```yaml
- name: encryption-config
  hostPath:
    path: /etc/kubernetes/encryption-config.yaml
    type: File
```

**설정 적용 확인**:
```bash
# API Server Pod 재시작 확인 (약 30초 소요)
watch kubectl get pods -n kube-system | grep kube-apiserver

# 정상 동작 확인
kubectl get pods -n kube-system
```

**암호화 검증**:

```bash
# Secret 생성
kubectl create secret generic test-secret \
  --from-literal=password=supersecret \
  -n production

# ETCD에서 암호화 확인
# WSL 환경에서는 etcdctl이 설치되어 있어야 함
ETCDCTL_API=3 etcdctl get /registry/secrets/production/test-secret \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# 암호화되어 있으면 평문이 보이지 않음
```

**WSL 환경 참고사항**:
- Kind/Minikube 사용 시: 컨테이너 내부에서 설정 필요
- 실제 클러스터: 마스터 노드에서 직접 설정
- 권한 문제: sudo 사용 필수
- etcdctl 설치: `sudo apt-get install etcd-client` (Ubuntu/Debian)

### Step 2-2: External Secrets Operator (15분)

**External Secrets Operator 설치**:

```bash
# Helm으로 설치
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets \
  external-secrets/external-secrets \
  -n external-secrets-system \
  --create-namespace

# 설치 확인
kubectl get pods -n external-secrets-system
```

**2-2. SecretStore 설정**

**파일 생성**: `secret-store.yaml`
```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: kubernetes-backend
  namespace: production
spec:
  provider:
    kubernetes:
      remoteNamespace: vault
      auth:
        serviceAccount:
          name: external-secrets-sa
      server:
        caProvider:
          type: ConfigMap
          name: kube-root-ca.crt
          key: ca.crt
```

**배포**:
```bash
kubectl apply -f secret-store.yaml
```

**2-3. ExternalSecret 생성**

**파일 생성**: `external-secret.yaml`
```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-config
  namespace: production
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: kubernetes-backend
    kind: SecretStore
  target:
    name: app-config-secret
    creationPolicy: Owner
  data:
  - secretKey: database-password
    remoteRef:
      key: db-credentials
      property: password
```

**배포 및 확인**:
```bash
kubectl apply -f external-secret.yaml

# 확인
kubectl get secretstore -n production
kubectl get externalsecret -n production
kubectl get secret app-config-secret -n production
```

---

## 💾 Step 3: ETCD 백업 및 복원 (20분)

### Step 3-1: ETCD 백업 자동화 (10분)

**3-1. 백업 스크립트 생성**

```bash
cat > /usr/local/bin/etcd-backup.sh <<'EOF'
#!/bin/bash
set -e

BACKUP_DIR="/backup/etcd"
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="$BACKUP_DIR/etcd-snapshot-$DATE.db"

mkdir -p $BACKUP_DIR

echo "Starting ETCD backup..."
ETCDCTL_API=3 etcdctl snapshot save $BACKUP_FILE \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# 백업 검증
ETCDCTL_API=3 etcdctl snapshot status $BACKUP_FILE --write-out=table

# 7일 이상 된 백업 삭제
find $BACKUP_DIR -name "etcd-snapshot-*.db" -mtime +7 -delete

echo "Backup completed: $BACKUP_FILE"
EOF

chmod +x /usr/local/bin/etcd-backup.sh

# 백업 실행 테스트
/usr/local/bin/etcd-backup.sh
```

**CronJob으로 자동 백업**:

```bash
# Cron 작업 등록 (매일 새벽 2시)
(crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/etcd-backup.sh >> /var/log/etcd-backup.log 2>&1") | crontab -

# Cron 작업 확인
crontab -l
```

### Step 3-2: ETCD 복원 테스트 (10분)

**복원 절차**:

```bash
# 1. 현재 상태 백업
ETCDCTL_API=3 etcdctl snapshot save /backup/etcd/before-restore.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# 2. 테스트용 리소스 생성
kubectl create namespace test-restore
kubectl create deployment nginx --image=nginx -n test-restore

# 3. 복원 시뮬레이션 (실제로는 클러스터 중지 필요)
echo "복원 절차:"
echo "1. systemctl stop kubelet"
echo "2. systemctl stop etcd"
echo "3. mv /var/lib/etcd /var/lib/etcd.backup"
echo "4. ETCDCTL_API=3 etcdctl snapshot restore /backup/etcd/before-restore.db --data-dir=/var/lib/etcd"
echo "5. chown -R etcd:etcd /var/lib/etcd"
echo "6. systemctl start etcd"
echo "7. systemctl start kubelet"

# 4. 정리
kubectl delete namespace test-restore
```

---

## 🔄 Step 4: 클러스터 업그레이드 시뮬레이션 (15분)

### Step 4-1: 업그레이드 계획 확인

```bash
# 현재 버전 확인
kubectl version --short
kubeadm version

# 업그레이드 가능 버전 확인
kubeadm upgrade plan

# 출력 예시 분석:
# - 현재 버전
# - 업그레이드 가능한 버전
# - 각 컴포넌트별 버전 변경사항
# - 업그레이드 명령어
```

### Step 4-2: 업그레이드 체크리스트 작성

**업그레이드 전 체크리스트**:

```bash
cat > /tmp/upgrade-checklist.md <<'EOF'
# Kubernetes 클러스터 업그레이드 체크리스트

## 사전 준비
- [ ] ETCD 백업 완료
- [ ] 현재 클러스터 상태 정상 확인
- [ ] 업그레이드 문서 검토
- [ ] 롤백 계획 수립
- [ ] 유지보수 공지

## 마스터 노드 업그레이드
- [ ] kubeadm 업그레이드
- [ ] kubeadm upgrade apply 실행
- [ ] kubelet 및 kubectl 업그레이드
- [ ] 마스터 노드 상태 확인

## 워커 노드 업그레이드 (순차적)
- [ ] kubectl drain 실행
- [ ] kubeadm upgrade node
- [ ] kubelet 및 kubectl 업그레이드
- [ ] kubectl uncordon 실행
- [ ] Pod 재배치 확인

## 업그레이드 후 검증
- [ ] 모든 노드 Ready 상태
- [ ] 모든 시스템 Pod 정상
- [ ] 애플리케이션 동작 확인
- [ ] 모니터링 지표 정상
- [ ] 로그 확인

## 롤백 절차 (필요시)
- [ ] ETCD 백업에서 복원
- [ ] 이전 버전 패키지 재설치
- [ ] 클러스터 상태 검증
EOF

cat /tmp/upgrade-checklist.md
```

---

## 🔍 고급 모니터링 및 감사

### 보안 감사 로깅

```bash
# Audit Policy 확인
cat /etc/kubernetes/audit-policy.yaml

# 감사 로그 확인
tail -f /var/log/kubernetes/audit.log | jq '.'

# RBAC 변경 사항 필터링
tail -f /var/log/kubernetes/audit.log | jq 'select(.objectRef.resource | contains("role"))'
```

### 보안 스캔

```bash
# Trivy로 클러스터 스캔
trivy k8s --report summary cluster

# 네임스페이스별 스캔
trivy k8s --report summary namespace production

# RBAC 분석
kubectl auth can-i --list --as=system:serviceaccount:production:operator-sa
```

---

## ✅ 실습 체크포인트

### 🔒 보안 강화 확인
- [ ] **Pod Security Standards**: Restricted 정책 적용
- [ ] **Secret 암호화**: ETCD 레벨 암호화 활성화
- [ ] **External Secrets**: 외부 Secret 관리 시스템 연동
- [ ] **보안 스캔**: 취약점 스캔 및 분석

### 💾 백업 및 복구 확인
- [ ] **자동 백업**: Cron으로 일일 백업 설정
- [ ] **백업 검증**: 백업 파일 무결성 확인
- [ ] **복원 절차**: 복원 프로세스 문서화
- [ ] **재해 복구**: 복원 테스트 성공

### 🔄 클러스터 관리 확인
- [ ] **업그레이드 계획**: 업그레이드 가능 버전 확인
- [ ] **체크리스트**: 업그레이드 절차 문서화
- [ ] **롤백 계획**: 실패 시 복구 방안 수립

---

## 🚀 추가 도전 과제

### 1. Falco 런타임 보안

```bash
# Falco 설치
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm install falco falcosecurity/falco \
  --namespace falco-system \
  --create-namespace

# 보안 이벤트 모니터링
kubectl logs -f -n falco-system -l app.kubernetes.io/name=falco
```

### 2. Vault 통합

```bash
# Vault 설치
helm repo add hashicorp https://helm.releases.hashicorp.com
helm install vault hashicorp/vault \
  --namespace vault-system \
  --create-namespace

# Vault와 Kubernetes 인증 연동
kubectl exec -it vault-0 -n vault-system -- vault auth enable kubernetes
```

### 3. 정책 자동화 (OPA Gatekeeper)

```bash
# Gatekeeper 설치
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml

# 설치 확인
kubectl get pods -n gatekeeper-system
```

**정책 템플릿 생성**

**파일 생성**: `required-labels-template.yaml`
```yaml
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: k8srequiredlabels
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredLabels
      validation:
        openAPIV3Schema:
          type: object
          properties:
            labels:
              type: array
              items:
                type: string
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredlabels
        violation[{"msg": msg, "details": {"missing_labels": missing}}] {
          provided := {label | input.review.object.metadata.labels[label]}
          required := {label | label := input.parameters.labels[_]}
          missing := required - provided
          count(missing) > 0
          msg := sprintf("You must provide labels: %v", [missing])
        }
```

**배포**:
```bash
kubectl apply -f required-labels-template.yaml
```

**Constraint 생성 및 테스트**

**파일 생성**: `require-labels-constraint.yaml`
```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLabels
metadata:
  name: require-app-env-labels
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
    namespaces: ["production"]
  parameters:
    labels: ["app", "env"]
```

**배포 및 테스트**:
```bash
kubectl apply -f require-labels-constraint.yaml

# 테스트: 라벨 없는 Pod 배포 시도 (차단되어야 함)
kubectl run test-pod --image=nginx -n production

# 예상 결과: Error from server (Forbidden): admission webhook denied...
```

---

## 🧹 실습 정리

### 환경 정리 스크립트

**🚀 자동화 정리**
```bash
cd theory/week_03/day4/lab_scripts/handson1
./cleanup.sh
```

**📋 스크립트 내용**: [cleanup.sh](./lab_scripts/handson1/cleanup.sh)

**수동 정리**
```bash
# Pod Security Standards 라벨 제거
kubectl label namespace production pod-security.kubernetes.io/enforce-
kubectl label namespace production pod-security.kubernetes.io/audit-
kubectl label namespace production pod-security.kubernetes.io/warn-

# 테스트 리소스 삭제
kubectl delete pod secure-app -n production
kubectl delete secret test-secret -n production

# External Secrets 삭제 (선택사항)
helm uninstall external-secrets -n external-secrets-system
kubectl delete namespace external-secrets-system

# Cron 작업 제거
crontab -l | grep -v etcd-backup | crontab -
```

---

## 💡 실습 회고

### 🤝 팀 회고 (10분)
1. **보안 정책**: Pod Security Standards가 개발 생산성에 미치는 영향은?
2. **백업 전략**: ETCD 백업 주기와 보관 기간을 어떻게 설정해야 할까요?
3. **업그레이드**: 무중단 업그레이드를 위한 핵심 고려사항은?
4. **실무 적용**: 가장 먼저 적용하고 싶은 보안 기능은?

### 📊 학습 성과
- **심층 방어**: 다층 보안 체계 구축 능력
- **데이터 보호**: Secret 암호화와 안전한 관리
- **재해 복구**: ETCD 백업/복원 프로세스 숙지
- **안정적 운영**: 클러스터 업그레이드 절차 이해

---

<div align="center">

**🔒 보안 강화** • **💾 재해 복구** • **🔄 안정적 운영** • **⚡ 프로덕션 준비**

*Lab 1 + Hands-on 1 = 완전한 프로덕션급 Kubernetes 보안 및 관리*

</div>
