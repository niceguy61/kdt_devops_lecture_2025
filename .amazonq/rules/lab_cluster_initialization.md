# Lab 클러스터 초기화 규칙

## 🎯 핵심 원칙

### Lab 1 / Hands-on 1 / Challenge 1 시작 시 필수 작업
- **기존 lab-cluster 삭제**: 포트 충돌 및 설정 충돌 방지
- **새 lab-cluster 생성**: 깨끗한 환경에서 실습 시작
- **표준 클러스터 스펙**: 1 control-plane + 2 worker nodes

## 📋 적용 대상

### 필수 적용
- **모든 Lab 1의 Step 1**: 기본 실습 시작 시
- **모든 Hands-on 1의 Step 1**: 심화 실습 시작 시
- **모든 Challenge 1의 setup**: Challenge 환경 구축 시

### 적용하지 않는 경우
- **Lab 2 이상**: 기존 클러스터 활용
- **Hands-on 2 이상**: Lab 1 환경 기반 확장
- **중간 Step**: 클러스터가 이미 생성된 상태

## 🔧 표준 포트 설정

### 기본 포트 세트 (모든 Lab 공통)
```yaml
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
```

### 추가 포트 (Lab별 필요시)
각 Lab의 특성에 맞게 추가 포트 설정 가능:
- **30090-30099**: 모니터링 도구 (Prometheus, Grafana 등)
- **30100-30109**: 데이터베이스 (PostgreSQL, MongoDB 등)
- **30110-30119**: 메시징 (RabbitMQ, Kafka 등)

**예시: 모니터링 스택 포함**
```yaml
extraPortMappings:
# 기본 포트
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
# 추가 포트 (모니터링)
- containerPort: 30090
  hostPort: 30090  # Prometheus
- containerPort: 30091
  hostPort: 30091  # Grafana
```

## 🔧 표준 스크립트

### Step 1: 클러스터 초기화 스크립트
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

## 📝 Lab 문서 작성 표준

### Lab 1 / Hands-on 1 문서 구조
```markdown
## 🛠️ Step 1: 클러스터 초기화 (5분)

### 목표
- 기존 lab-cluster 삭제
- 새로운 lab-cluster 생성 (1 control-plane + 2 worker)
- 필요한 포트 오픈 (30080-30082, 443, 80)

### 🚀 자동화 스크립트 사용
```bash
cd theory/week_XX/dayX/lab_scripts/lab1
./step1-setup-cluster.sh
```

**📋 스크립트 내용**: [step1-setup-cluster.sh](./lab_scripts/lab1/step1-setup-cluster.sh)

### 📊 예상 결과
```
=== Lab 클러스터 초기화 완료 ===

클러스터 정보:
- 이름: lab-cluster
- Control Plane: 1개
- Worker Node: 2개
- 오픈 포트: 30080-30082, 443, 80
```

### ✅ 검증
```bash
# 클러스터 상태 확인
kubectl get nodes

# 예상 출력
NAME                        STATUS   ROLES           AGE   VERSION
lab-cluster-control-plane   Ready    control-plane   1m    v1.27.0
lab-cluster-worker          Ready    <none>          1m    v1.27.0
lab-cluster-worker2         Ready    <none>          1m    v1.27.0
```
```

## 🎯 포트 설정 이유

### 오픈 포트 목적
- **30080-30082**: NodePort 서비스용 (애플리케이션 접근)
- **443**: HTTPS 트래픽 (Ingress)
- **80**: HTTP 트래픽 (Ingress)

### 포트 충돌 방지
- 기존 클러스터 삭제로 포트 해제
- 새 클러스터 생성 시 포트 재할당
- 다른 실습과의 포트 충돌 방지

## ⚠️ 주의사항

### 데이터 손실 경고
```markdown
⚠️ **주의**: 이 작업은 기존 lab-cluster의 모든 데이터를 삭제합니다.
- 이전 실습의 리소스가 모두 제거됩니다
- 백업이 필요한 경우 사전에 수행하세요
- Lab 2 이상에서는 이 작업을 수행하지 마세요
```

### 실행 전 확인사항
- [ ] 이전 실습 완료 및 정리
- [ ] 백업 필요 데이터 확인
- [ ] Lab 1 또는 Hands-on 1 시작 시점 확인

## 🔄 Challenge 환경 구축

### Challenge 1 setup 스크립트
```bash
#!/bin/bash

# Week X Day X Challenge 1: 클러스터 및 모니터링 설치
# 설명: Kind 클러스터 + Metrics Server + Prometheus + Grafana

set -e

echo "=== Challenge 환경 설치 시작 ==="

# 1. 기존 클러스터 삭제
echo "1/5 기존 lab-cluster 삭제 중..."
kind delete cluster --name lab-cluster 2>/dev/null || true

# 2. 새 클러스터 생성
echo "2/5 새 lab-cluster 생성 중..."
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

# 4-5. 추가 컴포넌트 설치...
# (Prometheus, Grafana 등)

echo ""
echo "=== Challenge 환경 설치 완료 ==="
```

## ✅ 체크리스트

### Lab 1 / Hands-on 1 작성 시
- [ ] Step 1에 클러스터 초기화 포함
- [ ] 기존 클러스터 삭제 명령어 포함
- [ ] 표준 클러스터 스펙 사용 (1+2 노드)
- [ ] 필수 포트 오픈 (30080-30082, 443, 80)
- [ ] 데이터 손실 경고 포함
- [ ] 검증 명령어 제공

### Challenge 1 작성 시
- [ ] setup 스크립트에 클러스터 초기화 포함
- [ ] 모니터링 스택 설치 포함
- [ ] 전체 환경 검증 포함

---

<div align="center">

**🔄 깨끗한 시작** • **⚠️ 포트 충돌 방지** • **✅ 일관된 환경**

*모든 Lab 1과 Hands-on 1은 클러스터 초기화로 시작*

</div>
