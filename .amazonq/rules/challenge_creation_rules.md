# Challenge 작성 규칙 (Challenge Creation Rules)

## 📋 Challenge 기본 원칙

### 🎯 AWS Asset Icons 사용 (Week 5 전용)
**참조**: [AWS Asset Icons 사용 규칙](./aws_asset_icons_usage.md)

Challenge 문서에서 AWS 서비스 표시 시 반드시 공식 아이콘 사용:
```markdown
**배포된 AWS 서비스**:
- ![ALB](../../../Asset-Package.../Arch_Networking-Content-Delivery/64/Arch_Elastic-Load-Balancing_64.svg) **ALB**
- ![EC2](../../../Asset-Package.../Arch_Compute/64/Arch_Amazon-EC2_64.svg) **EC2**
```

### 🎯 Challenge 특징
- **실무 시나리오 기반**: Session의 실제 아키텍처 활용
- **Lab + Hands-on 통합**: 두 실습의 개념을 모두 포함
- **의도적 오류**: 4가지 보안/설정 오류 시나리오
- **자동 검증**: verify-solution.sh로 해결 여부 확인

### 📝 핵심 구성 요소
1. **setup-cluster.sh**: 클러스터 생성 + 모니터링 스택 배포
2. **broken-*.yaml**: 의도적 오류가 포함된 리소스
3. **verify-solution.sh**: 4가지 시나리오 해결 검증
4. **cleanup.sh**: 클러스터 삭제

---

## 📁 파일 구조

### Challenge 디렉토리 구조
```
theory/week_XX/dayX/
├── challenge_1.md              # Challenge 문서
└── lab_scripts/
    └── challenge1/             # Challenge 1 스크립트
        ├── setup-cluster.sh    # 클러스터 + 모니터링 설치
        ├── broken-scenario1.yaml
        ├── broken-scenario2.yaml
        ├── broken-scenario3.yaml
        ├── broken-scenario4.yaml
        ├── verify-solution.sh  # 해결 검증
        ├── hints.md            # 힌트 (선택)
        ├── solutions.md            # 강사용 정답
        └── cleanup.sh          # 환경 정리
```

---

## 📝 Challenge 문서 구조

### 기본 템플릿
```markdown
# Week X Day X Challenge 1: [Challenge 제목]

<div align="center">
**🚨 문제 해결** • **🔍 진단 능력** • **🛠️ 실무 대응**
*실제 운영 환경의 장애 상황 시나리오*
</div>

---

## 🕘 Challenge 정보
**시간**: HH:MM-HH:MM (90분)
**목표**: 장애 진단 및 해결 능력 향상
**방식**: 문제 배포 → 진단 → 해결 → 검증

## 🎯 Challenge 목표
### 📚 학습 목표
- 체계적 문제 분석
- 신속한 장애 복구
- 근본 원인 파악

### 🛠️ 실무 역량
- 장애 대응 프로세스
- 로그 분석 및 디버깅
- 보안 정책 검증

---

## 🚨 Challenge 시나리오: "[시나리오 제목]"

### 📖 배경 상황
**시나리오**: 
[구체적인 상황 설명 - Session 1의 실무 사례 활용]

**긴급도**: 🔴 **Critical**
**영향도**: 💰 **High**
**제한시간**: ⏰ **90분**

---

## 🏗️ 전체 아키텍처
[Session 1의 아키텍처 다이어그램]

---

## 🔧 Challenge 환경 배포

### Step 1: 클러스터 및 모니터링 설치
```bash
cd theory/week_XX/dayX/lab_scripts/challenge1
./setup-cluster.sh
```

**설치 내용**:
- Kind 클러스터 (1 control-plane + 2 worker)
- Metrics Server
- Prometheus
- Grafana
- 기본 애플리케이션 스택

### Step 2: 문제 시스템 배포
```bash
# 4가지 오류가 포함된 시스템 배포
kubectl apply -f broken-scenario1.yaml
kubectl apply -f broken-scenario2.yaml
kubectl apply -f broken-scenario3.yaml
kubectl apply -f broken-scenario4.yaml
```

---

## 🚨 문제 상황 1: [문제 제목] (25분)

### 증상
- 증상 1
- 증상 2
- 증상 3

### 🔍 진단 과정

**1단계: 현상 확인**
```bash
kubectl get pods -n [namespace]
kubectl logs [pod-name]
```

**2단계: 상세 분석**
```bash
kubectl describe [resource]
```

**3단계: 근본 원인 파악**
[진단 가이드]

### 💡 힌트
- 힌트 1
- 힌트 2

**문제 파일**: [broken-scenario1.yaml](./lab_scripts/challenge1/broken-scenario1.yaml)

---

## 🚨 문제 상황 2-4: [동일 구조 반복]

---

## ✅ 해결 검증

### 자동 검증 스크립트
```bash
./verify-solution.sh
```

### 수동 검증 체크리스트
**✅ 시나리오 1**
```bash
[검증 명령어]
```

---

## 🎯 성공 기준

### 📊 기능적 요구사항
- [ ] 모든 서비스 정상 통신
- [ ] 인증/인가 동작 확인
- [ ] 정책 적용 검증

### ⏱️ 성능 요구사항
- [ ] 응답 시간 < 200ms
- [ ] 리소스 사용률 정상

### 🔒 보안 요구사항
- [ ] mTLS 통신 확인
- [ ] JWT 검증 성공
- [ ] 정책 위반 차단

---

## 🏆 도전 과제 (보너스)

### 고급 문제 해결 (+20점)
1. 추가 과제 1
2. 추가 과제 2

---

## 💡 문제 해결 가이드

### 🔍 체계적 진단 방법
1. 증상 파악
2. 로그 분석
3. 설정 검증
4. 연결 테스트
5. 근본 원인 파악

### 🛠️ 유용한 디버깅 명령어
```bash
kubectl get all -n [namespace]
kubectl describe [resource]
kubectl logs [pod]
kubectl exec -it [pod] -- [command]
```

---

## 🧹 Challenge 정리
```bash
./cleanup.sh
```

---

## 💡 Challenge 회고

### 🤝 팀 회고 (15분)
1. 가장 어려웠던 문제
2. 효과적인 디버깅 방법
3. 팀워크 경험
4. 실무 적용 방안

### 📊 학습 성과
- 문제 해결 능력
- 디버깅 기술
- 협업 경험
```

---

## 🔧 스크립트 작성 규칙

### setup-cluster.sh 구조
```bash
#!/bin/bash

# Week X Day X Challenge 1: 클러스터 및 모니터링 설치
# 설명: Kind 클러스터 + Metrics Server + Prometheus + Grafana

set -e

echo "=== Challenge 환경 설치 시작 ==="

# 1. 기존 클러스터 삭제
echo "1/5 기존 클러스터 삭제 중..."
kind delete cluster --name lab-cluster 2>/dev/null || true

# 2. 새 클러스터 생성
echo "2/5 클러스터 생성 중..."
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: lab-cluster
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080
    hostPort: 30080
  - containerPort: 30081
    hostPort: 30081
  - containerPort: 30082
    hostPort: 30082
  - containerPort: 443
    hostPort: 443
  - containerPort: 80
    hostPort: 80
- role: worker
- role: worker
EOF

# 3. Metrics Server 설치
echo "3/5 Metrics Server 설치 중..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch -n kube-system deployment metrics-server --type=json \
  -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

# 4. Prometheus 설치
echo "4/5 Prometheus 설치 중..."
kubectl create namespace monitoring
# Prometheus 설치 로직

# 5. Grafana 설치
echo "5/5 Grafana 설치 중..."
# Grafana 설치 로직

echo ""
echo "=== Challenge 환경 설치 완료 ==="
echo ""
echo "설치된 컴포넌트:"
echo "- Kind 클러스터 (1 control-plane + 2 worker)"
echo "- Metrics Server"
echo "- Prometheus"
echo "- Grafana"
```

### broken-scenario.yaml 구조
```yaml
# Week X Day X Challenge 1: 시나리오 N - [문제 설명]
# 의도적 오류: [오류 내용]

apiVersion: v1
kind: Pod
metadata:
  name: broken-pod
  namespace: challenge
spec:
  containers:
  - name: app
    image: nginx:alpine
    # 의도적 오류: 잘못된 설정
    securityContext:
      allowPrivilegeEscalation: true  # 보안 정책 위반
```

### verify-solution.sh 구조
```bash
#!/bin/bash

# Week X Day X Challenge 1: 해결 검증
# 설명: 4가지 시나리오 해결 여부 자동 검증

set -e

echo "=== Challenge 해결 검증 시작 ==="
echo ""

PASS=0
FAIL=0

# 시나리오 1 검증
echo "1/4 시나리오 1 검증 중..."
if [검증 조건]; then
  echo "✅ 시나리오 1: 통과"
  ((PASS++))
else
  echo "❌ 시나리오 1: 실패"
  ((FAIL++))
fi

# 시나리오 2-4 검증 (동일 구조)

echo ""
echo "=== 검증 결과 ==="
echo "통과: $PASS/4"
echo "실패: $FAIL/4"

if [ $PASS -eq 4 ]; then
  echo ""
  echo "🎉 축하합니다! 모든 시나리오를 해결했습니다!"
  exit 0
else
  echo ""
  echo "💡 아직 해결하지 못한 시나리오가 있습니다."
  exit 1
fi
```

### cleanup.sh 구조
```bash
#!/bin/bash

# Week X Day X Challenge 1: 환경 정리
# 설명: 클러스터 삭제

echo "=== Challenge 환경 정리 시작 ==="

# 클러스터 삭제
kind delete cluster --name lab-cluster

echo ""
echo "=== Challenge 환경 정리 완료 ==="
```

---

## 🎯 시나리오 설계 원칙

### 4가지 시나리오 구성
1. **시나리오 1 (25분)**: 보안 정책 위반
   - mTLS 설정 오류
   - 권한 상승 허용
   
2. **시나리오 2 (25분)**: 인증/인가 문제
   - JWT 토큰 검증 실패
   - Authorization Policy 오류

3. **시나리오 3 (20분)**: 리소스 제한 문제
   - CPU/메모리 제한 누락
   - OPA 정책 위반

4. **시나리오 4 (20분)**: 네트워크/통신 문제
   - Service 연결 실패
   - DNS 해결 오류

### 난이도 조절
- **시나리오 1-2**: 중간 난이도 (25분)
- **시나리오 3-4**: 상대적으로 쉬움 (20분)
- **힌트 제공**: 막힐 때 참고할 힌트

---

## 📊 검증 기준

### 자동 검증 항목
- Pod 상태 (Running)
- Service 연결 (curl 테스트)
- 정책 적용 (Constraint 확인)
- 인증 성공 (JWT 검증)

### 수동 검증 항목
- 로그 확인
- 메트릭 확인
- 보안 정책 검증

---

## ✅ Challenge 작성 체크리스트

### 필수 파일
- [ ] challenge_1.md (문서)
- [ ] setup-cluster.sh (환경 설치)
- [ ] broken-scenario1.yaml (오류 1)
- [ ] broken-scenario2.yaml (오류 2)
- [ ] broken-scenario3.yaml (오류 3)
- [ ] broken-scenario4.yaml (오류 4)
- [ ] verify-solution.sh (검증)
- [ ] cleanup.sh (정리)

### 품질 기준
- [ ] 모든 스크립트 실행 가능
- [ ] 의도적 오류 명확
- [ ] 검증 스크립트 정확
- [ ] 힌트 적절
- [ ] 시간 배분 합리적

---

## 🎨 Session 1 아키텍처 활용

### Week 4 Day 3 Session 1 예시
- **배달의민족 (Baemin)**: 마이크로서비스 보안
- **쿠팡 (Coupang)**: 물류 시스템 보안
- **Amazon**: Zero Trust 아키텍처

### 아키텍처 → Challenge 변환
1. Session 1의 실무 아키텍처 선택
2. 핵심 컴포넌트 추출
3. 4가지 오류 시나리오 설계
4. Lab 1 + Hands-on 1 개념 통합

---

<div align="center">

**🚨 실무 시나리오** • **🔍 문제 해결** • **🛠️ 자동 검증** • **🎯 통합 학습**

*Challenge를 통한 실전 역량 강화*

</div>
