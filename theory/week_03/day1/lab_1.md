# Lab 1: 클러스터 구축 & 컴포넌트 탐험 (90분)

<div align="center">

**🏗️ 클러스터 구축** • **🔍 컴포넌트 분석** • **💾 ETCD 탐험** • **🌐 API 호출**

*Kubernetes 클러스터의 내부 구조를 직접 구축하고 탐험하는 핵심 실습*

</div>

---

## 🎯 Lab 목표

### 📚 학습 목표
- **클러스터 구축**: Kind를 이용한 3노드 클러스터 생성 및 설정
- **컴포넌트 분석**: 각 컴포넌트의 상태와 로그 분석
- **ETCD 탐험**: 분산 저장소의 데이터 구조와 동작 원리 체험
- **API 호출**: kubectl 없이 직접 API Server 호출

### 🤔 왜 필요한가?
**실무 상황**: "클러스터에 문제가 생겼는데, 어떤 컴포넌트부터 확인해야 할까?"

**Lab 후 변화**:
- ❌ **Before**: "kubectl이 안 되면 어떻게 해야 할지 모르겠다..."
- ✅ **After**: "API Server → ETCD → Controller 순서로 체계적으로 진단할 수 있다!"

---

## 📋 사전 준비 (5분)

### 🚀 자동화 스크립트 사용
```bash
# 환경 설정 자동화
./lab_scripts/lab1/setup-environment.sh
```

**📋 스크립트 내용**: [setup-environment.sh](./lab_scripts/lab1/setup-environment.sh)

**수동 실행 (학습용)**:
```bash
# 작업 디렉토리 생성
mkdir -p ~/k8s-lab1
cd ~/k8s-lab1

# 필요 도구 확인
kubectl version --client
kind version
docker --version
```

### 필수 도구 설치 (필요시)
```bash
# 도구 설치 자동화
./lab_scripts/lab1/install-tools.sh
```

---

## 🏗️ Step 1: 클러스터 구축 (20분)

### 🚀 자동화 스크립트 사용
```bash
# 3노드 클러스터 자동 생성
./lab_scripts/lab1/create-cluster.sh
```

**📋 스크립트 내용**: [create-cluster.sh](./lab_scripts/lab1/create-cluster.sh)

**수동 실행 (학습용)**:
```bash
# Kind 설정 파일 생성
# kind-config.yaml 파일 생성

# 클러스터 생성
kind create cluster --config kind-config.yaml --wait 300s

# 상태 확인
kubectl cluster-info
kubectl get nodes -o wide
```

**kind-config.yaml**
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: lab-cluster
nodes:
- role: control-plane
- role: worker
- role: worker
```

### 🎯 확인 포인트
- [ ] 3개 노드 모두 Ready 상태
- [ ] Control Plane 1개, Worker 2개 구성
- [ ] kubectl 명령어 정상 동작

---

## 🔍 Step 2: 컴포넌트 상태 확인 (25분)

### 🚀 자동화 스크립트 사용
```bash
# 모든 컴포넌트 상태 자동 점검
./lab_scripts/lab1/check-components.sh
```

**📋 스크립트 내용**: [check-components.sh](./lab_scripts/lab1/check-components.sh)

**수동 실행 (학습용)**:
```bash
# Control Plane 컴포넌트 확인
kubectl get pods -n kube-system -l tier=control-plane

# API Server 상태
kubectl get pods -n kube-system -l component=kube-apiserver

# ETCD 상태  
kubectl get pods -n kube-system -l component=etcd

# Controller Manager 상태
kubectl get pods -n kube-system -l component=kube-controller-manager

# Scheduler 상태
kubectl get pods -n kube-system -l component=kube-scheduler

# Worker 컴포넌트 확인
kubectl get pods -n kube-system -l k8s-app=kube-proxy
kubectl get pods -n kube-system -l app=kindnet
```

### 🔍 로그 분석
```bash
# 각 컴포넌트 로그 확인
kubectl logs -n kube-system -l component=kube-apiserver --tail=10
kubectl logs -n kube-system -l component=etcd --tail=10
kubectl logs -n kube-system -l component=kube-controller-manager --tail=10
kubectl logs -n kube-system -l component=kube-scheduler --tail=10
```

### 🎯 확인 포인트
- [ ] 모든 Control Plane Pod가 Running 상태
- [ ] Worker 컴포넌트 정상 동작
- [ ] 로그에서 심각한 오류 없음

---

## 💾 Step 3: ETCD 직접 조회 (25분)

### 🚀 자동화 스크립트 사용
```bash
# ETCD 데이터 구조 완전 탐험
./lab_scripts/lab1/etcd-exploration.sh
```

**📋 스크립트 내용**: [etcd-exploration.sh](./lab_scripts/lab1/etcd-exploration.sh)

**수동 실행 (학습용)**:
```bash
# ETCD Pod 이름 확인
ETCD_POD=$(kubectl get pods -n kube-system -l component=etcd -o jsonpath='{.items[0].metadata.name}')

# ETCD 데이터 구조 확인
kubectl exec -n kube-system $ETCD_POD -- \
  etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  get / --prefix --keys-only | head -10

# 특정 리소스 확인
kubectl exec -n kube-system $ETCD_POD -- \
  etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  get /registry/pods/default/ --prefix --keys-only
```

### 🔍 실시간 Watch 체험
```bash
# 터미널 1: ETCD Watch 시작
kubectl exec -n kube-system $ETCD_POD -- \
  etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  watch /registry/pods/default/ --prefix

# 터미널 2: Pod 생성/삭제
kubectl run test-pod --image=nginx
kubectl delete pod test-pod
```

### 🎯 확인 포인트
- [ ] ETCD 데이터 구조 이해 (/registry/ 하위)
- [ ] Pod 생성 시 실시간 데이터 변경 관찰
- [ ] Raft 합의 알고리즘 동작 확인

---

## 🌐 Step 4: API Server 직접 호출 (15분)

### 🚀 자동화 스크립트 사용
```bash
# API Server 직접 호출 테스트
./lab_scripts/lab1/api-server-test.sh
```

**📋 스크립트 내용**: [api-server-test.sh](./lab_scripts/lab1/api-server-test.sh)

**수동 실행 (학습용)**:
```bash
# kubectl proxy 시작
kubectl proxy --port=8080 &

# 직접 API 호출
curl http://localhost:8080/api/v1/pods
curl http://localhost:8080/api/v1/nodes
curl http://localhost:8080/api/v1/namespaces

# 메트릭 확인
curl http://localhost:8080/metrics | grep apiserver_request

# proxy 종료
pkill -f "kubectl proxy"
```

### 🎯 확인 포인트
- [ ] kubectl 없이 API 호출 성공
- [ ] RESTful API 구조 이해
- [ ] 메트릭 데이터 수집 확인

---

## 🔬 Step 5: 네트워크 & 인증서 분석 (15분)

### 🚀 자동화 스크립트 사용
```bash
# 네트워크 통신 분석
./lab_scripts/lab1/analyze-network.sh

# 인증서 체인 분석  
./lab_scripts/lab1/analyze-certificates.sh
```

**📋 스크립트 내용**: 
- [analyze-network.sh](./lab_scripts/lab1/analyze-network.sh)
- [analyze-certificates.sh](./lab_scripts/lab1/analyze-certificates.sh)

**수동 실행 (학습용)**:
```bash
# Control Plane 노드 내부 접속
docker exec -it lab-cluster-control-plane bash

# 포트 사용 현황 확인
ss -tlnp | grep -E "(6443|2379|2380|10250)"

# 인증서 확인
ls -la /etc/kubernetes/pki/
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout | head -20

exit
```

### 🎯 확인 포인트
- [ ] 주요 포트 바인딩 상태 확인
- [ ] 인증서 체인 구조 이해
- [ ] 컴포넌트 간 통신 방식 파악

---

## 🧹 정리 및 마무리 (10분)

### 🚀 자동화 스크립트 사용
```bash
# 환경 정리
./lab_scripts/lab1/cleanup.sh
```

**수동 실행 (학습용)**:
```bash
# 클러스터 삭제
kind delete cluster --name lab-cluster

# 작업 파일 정리
cd ~
rm -rf ~/k8s-lab1

# 컨텍스트 초기화
kubectl config use-context docker-desktop 2>/dev/null || echo "기본 컨텍스트 없음"
```

---

## 📊 Lab 완료 체크리스트

### ✅ 기본 달성 목표
- [ ] **클러스터 구축**: 3노드 클러스터 성공적 생성
- [ ] **컴포넌트 확인**: 모든 핵심 컴포넌트 상태 점검
- [ ] **ETCD 탐험**: 데이터 구조와 Watch 기능 체험
- [ ] **API 호출**: kubectl 없이 직접 API 사용

### 🚀 심화 달성 목표
- [ ] **로그 분석**: 각 컴포넌트 로그에서 의미있는 정보 추출
- [ ] **네트워크 이해**: 포트와 통신 구조 완전 파악
- [ ] **인증서 분석**: TLS 인증서 체인 구조 이해
- [ ] **메트릭 수집**: API Server 성능 지표 분석

### 💡 실무 연계 성과
- [ ] **장애 진단**: 컴포넌트별 문제 진단 순서 습득
- [ ] **성능 분석**: 메트릭을 통한 성능 모니터링 방법
- [ ] **보안 이해**: 인증서 기반 보안 체계 파악
- [ ] **자동화 활용**: 스크립트를 통한 반복 작업 효율화

---

## 🎉 Fun Facts & 실무 팁

### 🎉 재미있는 발견
- **ETCD 키 개수**: 기본 클러스터에도 수백 개의 키가 저장됨
- **API Server 메트릭**: 초당 수십 개의 요청이 처리됨
- **인증서 개수**: 클러스터 내부에 10개 이상의 인증서 사용
- **포트 바인딩**: Control Plane에서 6개 이상의 주요 포트 사용

### 💡 실무 활용 팁
- **ETCD 백업**: `etcdctl snapshot save`로 전체 클러스터 백업 가능
- **API 디버깅**: `kubectl proxy`로 브라우저에서 API 탐험 가능
- **로그 모니터링**: `kubectl logs -f`로 실시간 로그 추적
- **성능 튜닝**: 메트릭 데이터로 병목 지점 식별

### 🚨 주의사항
- **ETCD 직접 수정**: 절대 프로덕션에서 직접 수정 금지
- **인증서 관리**: 만료 전 자동 갱신 시스템 필수
- **포트 보안**: 불필요한 포트 노출 방지
- **로그 용량**: 로그 로테이션 설정으로 디스크 관리

---

## 🔗 다음 단계

### 🎯 연계 학습
- **Session 2**: 오늘 탐험한 컴포넌트들의 상세 동작 원리
- **Session 3**: Scheduler와 Kubelet의 협력 메커니즘
- **Challenge 1**: 실제 장애 상황에서의 진단 및 복구

### 📚 추가 학습 자료
- [Kubernetes 공식 문서 - 클러스터 아키텍처](https://kubernetes.io/docs/concepts/architecture/)
- [ETCD 공식 문서](https://etcd.io/docs/)
- [Kind 사용자 가이드](https://kind.sigs.k8s.io/docs/user/quick-start/)

---

<div align="center">

**🏗️ 클러스터 구축 완료** • **🔍 컴포넌트 탐험 성공** • **💾 ETCD 마스터** • **🌐 API 전문가**

*이제 Kubernetes 클러스터의 내부 구조를 완전히 파악했습니다!*

**다음**: [Challenge 1 - 고장난 클러스터 복구하기](challenge1_cluster_recovery.md)

</div>
