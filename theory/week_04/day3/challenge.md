# Week 4 Day 3 Challenge: 보안 취약점 진단 및 해결

<div align="center">

**🚨 보안 사고 대응** • **🔍 취약점 진단** • **🛠️ 신속 복구**

*실전 보안 시나리오 대응 훈련*

</div>

---

## 🕘 Challenge 정보
**시간**: 15:00-15:50 (50분)  
**목표**: 보안 취약점 식별 및 신속한 해결  
**방식**: 문제 배포 → 진단 → 해결 → 검증

---

## 🎯 Challenge 목표

### 📚 학습 목표
- 보안 취약점 식별 능력 향상
- 신속한 보안 패치 적용 훈련
- 보안 정책 강화 경험
- 사고 대응 프로세스 체험

### 🛠️ 실무 역량
- 체계적 보안 진단 방법
- 우선순위 기반 대응
- 근본 원인 분석
- 재발 방지 대책 수립

---

## 🚨 Challenge 시나리오

### 📖 배경 상황
**"E-Commerce 플랫폼 보안 감사 중 다수의 취약점 발견"**

```
긴급도: 🔴 Critical
영향도: 💰 High - 고객 데이터 유출 위험
제한시간: ⏰ 50분

상황:
- 외부 보안 감사에서 4가지 주요 취약점 발견
- 즉시 조치하지 않으면 서비스 중단 가능
- 고객 데이터 보호를 위한 긴급 패치 필요
```

---

## 🔧 Challenge 환경 배포

### 환경 구성

```bash
# Challenge 네임스페이스 생성
kubectl create namespace security-challenge

# 취약한 시스템 배포
kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: security-challenge
  labels:
    istio-injection: enabled

---
# 취약점 1: JWT 검증 누락
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
  namespace: security-challenge
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api-gateway
  template:
    metadata:
      labels:
        app: api-gateway
    spec:
      containers:
      - name: gateway
        image: nginx:1.20
        ports:
        - containerPort: 80

---
# 취약점 2: Root 사용자 실행
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
  namespace: security-challenge
spec:
  replicas: 2
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
      - name: user-service
        image: node:16
        command: ["node", "server.js"]
        # securityContext 없음 - root로 실행!

---
# 취약점 3: 암호화되지 않은 통신
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: security-challenge
spec:
  mtls:
    mode: PERMISSIVE  # Plain text 허용!

---
# 취약점 4: 정책 위반 리소스
apiVersion: v1
kind: Pod
metadata:
  name: admin-pod
  namespace: security-challenge
  # 필수 라벨 없음!
spec:
  containers:
  - name: admin
    image: ubuntu:20.04
    command: ["sleep", "3600"]
    securityContext:
      privileged: true  # 특권 모드!
    resources: {}  # 리소스 제한 없음!
EOF
```

---

## 🚨 문제 상황 1: JWT 검증 누락 (12분)

### 증상
```
- API Gateway가 JWT 토큰 검증 없이 모든 요청 허용
- 인증되지 않은 사용자도 내부 API 접근 가능
- 보안 로그에 비정상 접근 패턴 다수 발견
```

### 🔍 진단 과정

**1단계: 현상 확인**
```bash
# API Gateway 설정 확인
kubectl get deployment api-gateway -n security-challenge -o yaml

# RequestAuthentication 확인
kubectl get requestauthentication -n security-challenge

# 예상: RequestAuthentication 리소스 없음
```

**2단계: 취약점 분석**
```bash
# 인증 없이 API 접근 테스트
kubectl run test-pod --image=curlimages/curl -n security-challenge -- sleep 3600

kubectl exec -it test-pod -n security-challenge -- \
  curl http://api-gateway/api/users

# 예상: 200 OK (인증 없이 접근 가능 - 취약!)
```

### 💡 해결 방법

```yaml
# jwt-authentication.yaml
apiVersion: security.istio.io/v1beta1
kind: RequestAuthentication
metadata:
  name: jwt-auth
  namespace: security-challenge
spec:
  selector:
    matchLabels:
      app: api-gateway
  jwtRules:
  - issuer: "https://auth.example.com"
    jwksUri: "https://auth.example.com/.well-known/jwks.json"
    audiences:
    - "api.example.com"

---
# JWT 없는 요청 거부
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: require-jwt
  namespace: security-challenge
spec:
  selector:
    matchLabels:
      app: api-gateway
  action: DENY
  rules:
  - from:
    - source:
        notRequestPrincipals: ["*"]
```

```bash
kubectl apply -f jwt-authentication.yaml
```

### ✅ 검증

```bash
# JWT 없이 접근 시도 (거부되어야 함)
kubectl exec -it test-pod -n security-challenge -- \
  curl -v http://api-gateway/api/users

# 예상: 403 Forbidden

# JWT와 함께 접근 (허용되어야 함)
TOKEN="eyJhbGc..."  # 유효한 JWT
kubectl exec -it test-pod -n security-challenge -- \
  curl -v http://api-gateway/api/users \
  -H "Authorization: Bearer $TOKEN"

# 예상: 200 OK
```

---

## 🚨 문제 상황 2: Root 사용자 실행 (12분)

### 증상
```
- 컨테이너가 root 사용자로 실행 중
- 컨테이너 탈출 시 호스트 시스템 위험
- 보안 스캔에서 Critical 등급 경고
```

### 🔍 진단 과정

**1단계: 현상 확인**
```bash
# 컨테이너 사용자 확인
kubectl exec -it deployment/user-service -n security-challenge -- id

# 예상 출력:
# uid=0(root) gid=0(root) groups=0(root)
# ⚠️ root로 실행 중!

# SecurityContext 확인
kubectl get deployment user-service -n security-challenge -o yaml | \
  grep -A 10 securityContext

# 예상: securityContext 설정 없음
```

**2단계: 위험도 평가**
```bash
# 파일 시스템 쓰기 권한 확인
kubectl exec -it deployment/user-service -n security-challenge -- \
  touch /etc/test-file

# 예상: 성공 (root 권한으로 시스템 파일 수정 가능 - 위험!)
```

### 💡 해결 방법

```yaml
# secure-user-service.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
  namespace: security-challenge
spec:
  replicas: 2
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 2000
        seccompProfile:
          type: RuntimeDefault
      containers:
      - name: user-service
        image: node:16
        command: ["node", "server.js"]
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          capabilities:
            drop:
              - ALL
        volumeMounts:
        - name: tmp
          mountPath: /tmp
        - name: cache
          mountPath: /app/.cache
      volumes:
      - name: tmp
        emptyDir: {}
      - name: cache
        emptyDir: {}
```

```bash
kubectl apply -f secure-user-service.yaml
```

### ✅ 검증

```bash
# 사용자 확인
kubectl exec -it deployment/user-service -n security-challenge -- id

# 예상 출력:
# uid=1000 gid=2000 groups=2000
# ✅ Non-root 사용자로 실행

# 시스템 파일 쓰기 시도 (실패해야 함)
kubectl exec -it deployment/user-service -n security-challenge -- \
  touch /etc/test-file

# 예상: Permission denied
```

---

## 🚨 문제 상황 3: 암호화되지 않은 통신 (13분)

### 증상
```
- 서비스 간 통신이 평문(Plain text)으로 전송
- 네트워크 스니핑으로 데이터 유출 가능
- mTLS가 PERMISSIVE 모드로 설정됨
```

### 🔍 진단 과정

**1단계: mTLS 상태 확인**
```bash
# PeerAuthentication 확인
kubectl get peerauthentication -n security-challenge -o yaml

# 예상 출력:
# mtls:
#   mode: PERMISSIVE  # ⚠️ Plain text 허용!

# 실제 통신 확인
istioctl x describe pod <pod-name> -n security-challenge

# 예상: mTLS status: PERMISSIVE
```

**2단계: 평문 통신 테스트**
```bash
# Plain text로 통신 가능한지 확인
kubectl run plain-client --image=curlimages/curl -n security-challenge -- sleep 3600

kubectl exec -it plain-client -n security-challenge -- \
  curl http://user-service:8080/health

# 예상: 200 OK (평문 통신 가능 - 취약!)
```

### 💡 해결 방법

```yaml
# strict-mtls.yaml
# 1. 네임스페이스 전체 STRICT 모드
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: security-challenge
spec:
  mtls:
    mode: STRICT  # mTLS 필수

---
# 2. 전역 STRICT 모드 (선택사항)
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: istio-system
spec:
  mtls:
    mode: STRICT
```

```bash
kubectl apply -f strict-mtls.yaml
```

### ✅ 검증

```bash
# Plain text 통신 시도 (실패해야 함)
kubectl exec -it plain-client -n security-challenge -- \
  curl -v http://user-service:8080/health

# 예상: Connection refused 또는 TLS handshake failed

# mTLS 상태 확인
istioctl x describe pod <pod-name> -n security-challenge

# 예상: mTLS status: STRICT

# 인증서 확인
kubectl exec -it deployment/user-service -n security-challenge -c istio-proxy -- \
  ls /etc/certs/

# 예상: cert-chain.pem, key.pem, root-cert.pem
```

---

## 🚨 문제 상황 4: 정책 위반 리소스 (13분)

### 증상
```
- 필수 라벨이 없는 리소스 존재
- 특권 모드로 실행되는 Pod
- 리소스 제한이 없는 컨테이너
- Gatekeeper 정책 위반 다수
```

### 🔍 진단 과정

**1단계: 정책 위반 확인**
```bash
# Gatekeeper 정책 위반 조회
kubectl get constraints -n security-challenge

# 위반 상세 확인
kubectl get k8srequiredlabels -o json | \
  jq '.items[] | select(.status.totalViolations > 0) | 
      {name: .metadata.name, violations: .status.violations}'

# 예상: admin-pod가 여러 정책 위반
```

**2단계: 위반 리소스 분석**
```bash
# admin-pod 상세 확인
kubectl get pod admin-pod -n security-challenge -o yaml

# 발견된 문제:
# 1. 필수 라벨 없음 (app, version, owner, environment)
# 2. privileged: true (특권 모드)
# 3. resources: {} (리소스 제한 없음)
# 4. securityContext 미설정
```

### 💡 해결 방법

```yaml
# compliant-admin-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: admin-pod
  namespace: security-challenge
  labels:
    app: admin-tools
    version: "1.0"
    owner: "devops-team"
    environment: "production"
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
  containers:
  - name: admin
    image: ubuntu:20.04
    command: ["sleep", "3600"]
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      runAsNonRoot: true
      capabilities:
        drop:
          - ALL
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 500m
        memory: 512Mi
    volumeMounts:
    - name: tmp
      mountPath: /tmp
  volumes:
  - name: tmp
    emptyDir: {}
```

```bash
# 기존 Pod 삭제
kubectl delete pod admin-pod -n security-challenge

# 정책 준수 Pod 생성
kubectl apply -f compliant-admin-pod.yaml
```

### ✅ 검증

```bash
# 정책 위반 재확인
kubectl get constraints -n security-challenge -o json | \
  jq '.items[] | {name: .metadata.name, violations: .status.totalViolations}'

# 예상: totalViolations: 0

# Pod 보안 설정 확인
kubectl get pod admin-pod -n security-challenge -o yaml | \
  grep -A 20 securityContext

# 예상: 모든 보안 설정 적용됨
```

---

## ✅ 최종 검증

### 종합 보안 점검

```bash
# 1. JWT 인증 확인
kubectl get requestauthentication -n security-challenge
kubectl get authorizationpolicy -n security-challenge

# 2. mTLS 상태 확인
kubectl get peerauthentication -n security-challenge
istioctl x describe pod -n security-challenge

# 3. 보안 컨텍스트 확인
kubectl get pods -n security-challenge -o json | \
  jq '.items[] | {name: .metadata.name, 
                  runAsNonRoot: .spec.securityContext.runAsNonRoot,
                  runAsUser: .spec.securityContext.runAsUser}'

# 4. 정책 준수 확인
kubectl get constraints -A -o json | \
  jq '.items[] | {name: .metadata.name, violations: .status.totalViolations}'
```

### 보안 점수 계산

```bash
cat > security-score.sh << 'EOF'
#!/bin/bash

score=0
total=4

echo "=== Security Challenge Score ==="

# 1. JWT 인증 (25점)
if kubectl get requestauthentication jwt-auth -n security-challenge &>/dev/null; then
  echo "✅ JWT Authentication: 25/25"
  ((score+=25))
else
  echo "❌ JWT Authentication: 0/25"
fi

# 2. 보안 컨텍스트 (25점)
non_root=$(kubectl get pods -n security-challenge -o json | \
  jq '[.items[] | select(.spec.securityContext.runAsNonRoot == true)] | length')
if [ "$non_root" -gt 0 ]; then
  echo "✅ Security Context: 25/25"
  ((score+=25))
else
  echo "❌ Security Context: 0/25"
fi

# 3. mTLS STRICT (25점)
mtls_mode=$(kubectl get peerauthentication default -n security-challenge -o json | \
  jq -r '.spec.mtls.mode')
if [ "$mtls_mode" == "STRICT" ]; then
  echo "✅ mTLS STRICT: 25/25"
  ((score+=25))
else
  echo "❌ mTLS STRICT: 0/25"
fi

# 4. 정책 준수 (25점)
violations=$(kubectl get constraints -n security-challenge -o json | \
  jq '[.items[] | .status.totalViolations // 0] | add')
if [ "$violations" -eq 0 ]; then
  echo "✅ Policy Compliance: 25/25"
  ((score+=25))
else
  echo "❌ Policy Compliance: 0/25 ($violations violations)"
fi

echo ""
echo "Total Score: $score/100"

if [ "$score" -eq 100 ]; then
  echo "🎉 Perfect! All security issues resolved!"
elif [ "$score" -ge 75 ]; then
  echo "👍 Good! Most issues resolved."
elif [ "$score" -ge 50 ]; then
  echo "⚠️  Fair. More work needed."
else
  echo "❌ Critical issues remain!"
fi
EOF

chmod +x security-score.sh
./security-score.sh
```

---

## 🎯 성공 기준

### 📊 기능적 요구사항
- [ ] JWT 인증 시스템 구축 완료
- [ ] 모든 컨테이너 Non-root 실행
- [ ] mTLS STRICT 모드 적용
- [ ] 정책 위반 0건 달성

### ⏱️ 성능 요구사항
- [ ] 보안 패치 적용 시간 < 50분
- [ ] 서비스 다운타임 최소화
- [ ] 정책 검증 자동화

### 🔒 보안 요구사항
- [ ] 인증되지 않은 접근 차단
- [ ] 암호화된 서비스 간 통신
- [ ] 최소 권한 원칙 적용
- [ ] 지속적 컴플라이언스 보장

---

## 🧹 Challenge 정리

```bash
# 리소스 삭제
kubectl delete namespace security-challenge

# 검증 스크립트 삭제
rm -f security-score.sh
```

---

## 💡 Challenge 회고

### 🤝 팀 회고 (5분)
1. **가장 어려웠던 문제**: 어떤 취약점이 가장 해결하기 어려웠나요?
2. **효과적인 진단 방법**: 어떤 진단 방법이 가장 유용했나요?
3. **팀워크 경험**: 팀원과 어떻게 협력했나요?
4. **실무 적용**: 실제 업무에서 어떻게 활용할 수 있을까요?

### 📊 학습 성과
- **보안 진단**: 체계적인 취약점 식별 능력
- **신속 대응**: 우선순위 기반 빠른 패치 적용
- **근본 원인 분석**: 표면적 문제가 아닌 근본 원인 해결
- **재발 방지**: 정책 자동화를 통한 지속적 보안

---

<div align="center">

**🚨 보안 사고 대응** • **🔍 취약점 진단** • **🛠️ 신속 복구** • **📋 정책 강화**

*실전 보안 시나리오를 통한 대응 능력 향상*

</div>
