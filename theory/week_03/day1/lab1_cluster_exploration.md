# Lab 1: 클러스터 구축 & 컴포넌트 탐험 (90분)

## 🎯 Lab 목표
- **기본 목표**: Kubernetes 클러스터 구축 및 핵심 컴포넌트 동작 확인
- **심화 목표**: 컴포넌트 간 통신 분석 및 ETCD 직접 조작
- **실무 연계**: 프로덕션 환경에서의 클러스터 관리 기초 습득

## 📋 사전 준비

### 환경 설정
**스크립트 파일**: [setup-environment.sh](lab_scripts/lab1/setup-environment.sh)

### 필요 도구 설치
**스크립트 파일**: [install-tools.sh](lab_scripts/lab1/install-tools.sh)

## 🔧 기본 Lab 요소 (60분)

### Step 1: 클러스터 구축 (20분)

#### 1.1 Kind 클러스터 생성
**설정 파일**: [kind-config.yaml](lab_scripts/lab1/kind-config.yaml)
**스크립트 파일**: [create-cluster.sh](lab_scripts/lab1/create-cluster.sh)

#### 1.2 클러스터 기본 정보 수집
**스크립트에 포함됨**: [create-cluster.sh](lab_scripts/lab1/create-cluster.sh)

### Step 2: 컴포넌트 상태 확인 (25분)

#### 2.1-2.3 컴포넌트 상태 확인 및 로그 분석
**스크립트 파일**: [check-components.sh](lab_scripts/lab1/check-components.sh)

### Step 3: ETCD 직접 조회 (25분)

#### 3.1-3.3 ETCD 직접 조회 및 모니터링
**스크립트 파일**: [etcd-exploration.sh](lab_scripts/lab1/etcd-exploration.sh)

## 🚀 심화 Lab 요소 (30분)

### Step 4: API Server 직접 호출 (15분)

#### 4.1-4.2 API Server 직접 호출 및 성능 분석
**스크립트 파일**: [api-server-test.sh](lab_scripts/lab1/api-server-test.sh)

### Step 5: 컴포넌트 간 통신 분석 (15분)

#### 5.1 네트워크 통신 확인
**스크립트 파일**: [analyze-network.sh](lab_scripts/lab1/analyze-network.sh)

#### 5.2 인증서 체인 분석
**스크립트 파일**: [analyze-certificates.sh](lab_scripts/lab1/analyze-certificates.sh)

## 📊 결과 분석 및 정리

### 수집된 정보 정리
**스크립트 파일**: [analyze-cluster.sh](lab_scripts/lab1/analyze-cluster.sh)

### 학습 내용 검증
**설정 파일**: [test-workload.yaml](lab_scripts/lab1/test-workload.yaml)

```bash
kubectl apply -f lab_scripts/lab1/test-workload.yaml

# 배포 상태 확인
kubectl get all -n lab-day1

# 스케줄링 결과 확인
kubectl get pods -n lab-day1 -o wide

# 서비스 엔드포인트 확인
kubectl get endpoints -n lab-day1
```

## 🎯 성공 기준

### 기본 목표 달성 확인
- [ ] Kind 클러스터 성공적으로 생성
- [ ] 모든 시스템 컴포넌트 정상 동작 확인
- [ ] ETCD에서 Kubernetes 리소스 직접 조회 성공
- [ ] API Server 직접 호출 성공

### 심화 목표 달성 확인
- [ ] 컴포넌트 간 통신 구조 이해
- [ ] 인증서 체인 분석 완료
- [ ] 실시간 ETCD 변경사항 모니터링 성공
- [ ] API Server 메트릭 분석 완료

### 실무 연계 확인
- [ ] 클러스터 상태 분석 스크립트 작성
- [ ] 문제 진단을 위한 로그 수집 방법 습득
- [ ] 컴포넌트별 헬스체크 방법 이해

## 💡 트러블슈팅 가이드

### 일반적인 문제와 해결책

#### 1. Kind 클러스터 생성 실패
```bash
# Docker 상태 확인
sudo systemctl status docker

# 기존 클러스터 정리
kind delete cluster --name lab-cluster

# 재생성
kind create cluster --config kind-config.yaml
```

#### 2. ETCD 접속 실패
```bash
# ETCD Pod 상태 확인
kubectl get pods -n kube-system -l component=etcd

# ETCD 로그 확인
kubectl logs -n kube-system -l component=etcd
```

#### 3. API Server 호출 실패
```bash
# 토큰 재획득
kubectl create token default -n kube-system

# 네트워크 연결 확인
kubectl proxy --port=8080 &
curl http://localhost:8080/api/v1/namespaces
```

## 📚 추가 학습 자료

### 참고 명령어 모음
```bash
# 클러스터 정보 수집 원라이너
kubectl get all --all-namespaces -o wide > all-resources.txt

# 시스템 이벤트 확인
kubectl get events --all-namespaces --sort-by='.lastTimestamp'

# 리소스 사용량 모니터링
watch kubectl top nodes

# 컴포넌트 상태 지속 모니터링
watch kubectl get componentstatuses
```

### 정리 작업
**스크립트 파일**: [cleanup.sh](lab_scripts/lab1/cleanup.sh)

이 Lab을 통해 Kubernetes 클러스터의 내부 구조와 각 컴포넌트의 동작 원리를 직접 확인하고, 
실제 운영 환경에서 필요한 클러스터 관리 기초 기술을 습득할 수 있습니다! 🚀