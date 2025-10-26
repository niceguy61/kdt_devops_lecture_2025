# Lab 작성 규칙 (Lab Creation Rules)

## 📋 Lab 구조 표준

### 🎯 AWS Asset Icons 사용 (Week 5 전용)
**참조**: [AWS Asset Icons 사용 규칙](./aws_asset_icons_usage.md)

Lab 문서에서 AWS 서비스 표시 시 반드시 공식 아이콘 사용:
```markdown
**사용된 AWS 서비스**:
- ![EC2](../../../Asset-Package.../Arch_Compute/64/Arch_Amazon-EC2_64.svg) **EC2**
- ![RDS](../../../Asset-Package.../Arch_Database/64/Arch_Amazon-RDS_64.svg) **RDS**
```

### 필수 구성 요소 (순서대로)

1. **전체 아키텍처 설명**
   - Mermaid 다이어그램으로 시각화
   - 각 컴포넌트 간 관계 명확히 표시
   - 색상 코딩으로 계층 구분

2. **역할별 상세 설명**
   - 각 서비스/컴포넌트의 역할
   - 보안 계층별 책임
   - 통신 방식 (mTLS, JWT 등)

3. **트래픽 흐름 예시**
   - Sequence Diagram으로 실제 요청 흐름
   - 단계별 인증/인가 과정
   - 실제 사용자 시나리오 기반

4. **Step 1: 환경 초기화**
   - 기존 lab-cluster 삭제
   - 새로운 lab-cluster 생성
   - 클러스터 스펙:
     * Control Plane: 1개
     * Worker Node: 2개
     * 오픈 포트: 30080-30082, 443, 80

5. **각 Step별 구현**
   - Step 2, 3, 4... 순차적 진행
   - 각 Step마다 스크립트 제공
   - 스크립트 위치: `lab_scripts/lab1/`

6. **실습 체크포인트**
   - 각 단계별 검증 항목
   - 체크리스트 형태

7. **트러블슈팅 가이드**
   - 예상 문제 상황
   - 진단 방법
   - 해결 방법

8. **실습 정리**
   - cleanup.sh 스크립트 제공
   - 모든 리소스 삭제

9. **실습 회고**
   - 학습 성과 정리
   - 다음 Lab 연계

---

## 🔧 스크립트 작성 규칙

### 스크립트 위치
```
theory/week_XX/dayX/lab_scripts/
├── lab1/
│   ├── step1-setup-cluster.sh
│   ├── step2-install-istio.sh
│   ├── step3-deploy-services.sh
│   ├── step4-configure-security.sh
│   ├── test-system.sh
│   └── cleanup.sh
```

### 스크립트 헤더 표준
```bash
#!/bin/bash

# Week X Day X Lab X: [스크립트 목적]
# 설명: [상세 설명]
# 사용법: ./script-name.sh

set -e  # 에러 발생 시 즉시 종료

echo "=== [작업명] 시작 ==="
```

### 스크립트 본문 구조
```bash
# 1. 환경 확인
echo "1/5 환경 확인 중..."
# ... 코드 ...

# 2. 리소스 생성
echo "2/5 리소스 생성 중..."
# ... 코드 ...

# 3. 설정 적용
echo "3/5 설정 적용 중..."
# ... 코드 ...

# 4. 검증
echo "4/5 검증 중..."
# ... 코드 ...

# 5. 결과 출력
echo "5/5 완료"
echo ""
echo "=== [작업명] 완료 ==="
echo ""
echo "배포된 리소스:"
echo "- 리소스 1: 설명"
echo "- 리소스 2: 설명"
```

### 스크립트 종료 처리
```bash
# 성공 시
echo "✅ 모든 작업이 성공적으로 완료되었습니다."
exit 0

# 실패 시
echo "❌ 작업 실패: [오류 메시지]"
exit 1
```

---

## 📝 Lab 문서 작성 템플릿

### Step 구조
```markdown
## 🛠️ Step X: [단계명] (예상 시간)

### 목표
- [이 단계에서 달성할 목표]

### 🚀 자동화 스크립트 사용
```bash
cd theory/week_XX/dayX/lab_scripts/lab1
./stepX-script-name.sh
```

**📋 스크립트 내용**: [stepX-script-name.sh](./lab_scripts/lab1/stepX-script-name.sh)

**스크립트 핵심 부분**:
```bash
# 핵심 코드만 표시 (5-10줄)
kubectl apply -f resource.yaml
# ... 중략 ...
```

### 📊 예상 결과
```
예상 출력 결과 표시
```

### ✅ 검증
```bash
# 검증 명령어
kubectl get pods -n namespace
```

**예상 출력**:
```
NAME                     READY   STATUS    RESTARTS   AGE
pod-name                 2/2     Running   0          30s
```
```

---

## 🎯 클러스터 설정 표준

### Kind 클러스터 설정 (Step 1)
```yaml
# kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: lab-cluster
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080
    hostPort: 30080
    protocol: TCP
  - containerPort: 30081
    hostPort: 30081
    protocol: TCP
  - containerPort: 30082
    hostPort: 30082
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
  - containerPort: 80
    hostPort: 80
    protocol: TCP
- role: worker
- role: worker
```

### Step 1 스크립트 예시
```bash
#!/bin/bash

# Week X Day X Lab 1: 클러스터 초기화
# 설명: 기존 클러스터 삭제 및 새 클러스터 생성

set -e

echo "=== Lab 클러스터 초기화 시작 ==="

# 1. 기존 클러스터 삭제
echo "1/3 기존 lab-cluster 삭제 중..."
kind delete cluster --name lab-cluster 2>/dev/null || true

# 2. 새 클러스터 생성
echo "2/3 새 lab-cluster 생성 중..."
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

# 3. 클러스터 확인
echo "3/3 클러스터 상태 확인 중..."
kubectl cluster-info
kubectl get nodes

echo ""
echo "=== Lab 클러스터 초기화 완료 ==="
echo ""
echo "클러스터 정보:"
echo "- 이름: lab-cluster"
echo "- Control Plane: 1개"
echo "- Worker Node: 2개"
echo "- 오픈 포트: 30080-30082, 443, 80"
```

---

## ✅ 체크포인트 작성 규칙

### 체크포인트 구조
```markdown
## ✅ 실습 체크포인트

### ✅ Step 1: 클러스터 초기화
- [ ] 기존 클러스터 삭제 완료
- [ ] 새 클러스터 생성 완료
- [ ] 노드 3개 정상 실행 (1 control-plane + 2 worker)
- [ ] 포트 매핑 확인

### ✅ Step 2: [단계명]
- [ ] 체크 항목 1
- [ ] 체크 항목 2
- [ ] 체크 항목 3

### ✅ 전체 시스템 검증
- [ ] 모든 Pod Running 상태
- [ ] 서비스 접근 가능
- [ ] 인증/인가 동작 확인
```

---

## 🔍 트러블슈팅 가이드 작성 규칙

### 트러블슈팅 구조
```markdown
## 🔍 트러블슈팅

### 문제 1: [문제 상황]
```bash
# 증상
에러 메시지 또는 증상 설명
```

**원인**:
- 원인 1
- 원인 2

**해결 방법**:
```bash
# 진단
kubectl logs pod-name

# 해결
kubectl apply -f fix.yaml
```

**검증**:
```bash
kubectl get pods
# 예상: Running 상태
```
```

---

## 🧹 정리 스크립트 작성 규칙

### cleanup.sh 표준
```bash
#!/bin/bash

# Week X Day X Lab 1: 실습 환경 정리
# 설명: 모든 실습 리소스 삭제

echo "=== Lab 환경 정리 시작 ==="

# 1. 네임스페이스 삭제
echo "1/3 네임스페이스 삭제 중..."
kubectl delete namespace lab-namespace --ignore-not-found=true

# 2. CRD 삭제 (필요시)
echo "2/3 CRD 삭제 중..."
kubectl delete crd custom-resource --ignore-not-found=true

# 3. 클러스터 삭제 (선택사항)
echo "3/3 클러스터 삭제 중..."
read -p "클러스터를 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kind delete cluster --name lab-cluster
    echo "✅ 클러스터 삭제 완료"
else
    echo "ℹ️  클러스터 유지"
fi

echo ""
echo "=== Lab 환경 정리 완료 ==="
```

---

## 💡 실습 회고 작성 규칙

### 회고 구조
```markdown
## 💡 실습 회고

### 🤝 페어 회고 (5분)
1. **가장 인상 깊었던 부분**: 
2. **어려웠던 점과 해결 방법**:
3. **실무 적용 아이디어**:

### 📊 학습 성과
- **기술적 성취**: [구체적인 기술 습득]
- **문제 해결**: [해결한 문제들]
- **다음 단계**: [다음 Lab 연계]

### 🔗 다음 Lab 준비
- **Lab 2 주제**: [다음 Lab 주제]
- **연계 내용**: [이번 Lab과의 연결점]
```

---

## 📊 결과 예시 작성 규칙

### 명령어 실행 결과
```markdown
### 📊 예상 결과

**명령어**:
```bash
kubectl get pods -n secure-app
```

**예상 출력**:
```
NAME                           READY   STATUS    RESTARTS   AGE
auth-service-7d9f8b5c4-x7k2m   2/2     Running   0          2m
frontend-6b8d9c7f5-9h4j3       2/2     Running   0          2m
backend-5c7d8e9f6-3k5l7        2/2     Running   0          2m
```

**설명**:
- `READY 2/2`: 애플리케이션 컨테이너 + Istio Sidecar
- `STATUS Running`: 정상 실행 중
- `RESTARTS 0`: 재시작 없음 (안정적)
```

---

## 🎯 Lab 작성 체크리스트

### 필수 포함 사항
- [ ] 전체 아키텍처 Mermaid 다이어그램
- [ ] 역할별 상세 설명
- [ ] 트래픽 흐름 Sequence Diagram
- [ ] Step 1: 클러스터 초기화 (control-plane 1 + worker 2)
- [ ] 포트 설정: 30080-30082, 443, 80
- [ ] 각 Step별 스크립트 (lab_scripts/lab1/)
- [ ] 스크립트 파일 링크
- [ ] 스크립트 핵심 부분 설명
- [ ] 예상 결과 출력
- [ ] 실습 체크포인트
- [ ] 트러블슈팅 가이드
- [ ] cleanup.sh 정리 스크립트
- [ ] 실습 회고

### 품질 기준
- [ ] 모든 스크립트 실행 가능 (테스트 완료)
- [ ] 에러 처리 포함
- [ ] 진행 상황 표시
- [ ] 결과 검증 포함
- [ ] 명확한 설명과 주석

---

## 📁 파일 구조 예시

```
theory/week_04/day3/
├── lab_1.md                          # Lab 문서
├── lab_scripts/
│   └── lab1/
│       ├── step1-setup-cluster.sh    # 클러스터 초기화
│       ├── step2-install-istio.sh    # Istio 설치
│       ├── step3-deploy-auth.sh      # 인증 서비스 배포
│       ├── step4-configure-mtls.sh   # mTLS 설정
│       ├── step5-setup-jwt.sh        # JWT 설정
│       ├── step6-test-auth.sh        # 인증 테스트
│       ├── test-system.sh            # 전체 시스템 테스트
│       └── cleanup.sh                # 환경 정리
```

---

이 규칙을 따라 모든 Lab을 일관되게 작성합니다.
