# Week 3.5 Kubernetes 핵심 개념 보충 강좌

## 🎯 목적

Week 3 본 강의에서 **비기너들이 어려워하는 핵심 개념**을 집중적으로 다루는 2일 보충 과정입니다.

### 왜 필요한가?

Week 3 수강생들이 공통적으로 어려워하는 5가지 개념:
1. **Pod vs Container vs Deployment 계층 구조** - "왜 컨테이너가 아닌 Pod인가?"
2. **ETCD와 클러스터 상태 관리** - "ETCD가 뭐고 왜 필요한가?"
3. **Service 타입별 차이** - "ClusterIP, NodePort, LoadBalancer 언제 뭘 쓰나요?"
4. **PV/PVC 바인딩** - "왜 PV와 PVC를 따로 만들어야 하나요?"
5. **Kubernetes 네트워킹** - "Pod CIDR, Service CIDR이 뭔가요?"

---

## 📅 2일 과정 구성

### **Day 1: 핵심 아키텍처 개념 깨우치기**

#### Session 1 (09:00-09:50): [Pod vs Container vs Deployment 완전 정복](day1/session1/session1.md)
**해결하는 질문**:
- "Docker로 컨테이너 실행하면 되는데 왜 Pod가 필요한가요?"
- "Deployment랑 ReplicaSet이 뭐가 다른가요?"
- "Rolling Update가 어떻게 무중단 배포를 보장하나요?"

**실습 내용**:
- 단일/멀티 컨테이너 Pod 생성
- ReplicaSet 자동 복구 체험
- Rolling Update 실시간 관찰

---

#### Session 2 (10:00-10:50): ETCD와 클러스터 상태의 모든 것
**해결하는 질문**:
- "ETCD가 없으면 어떻게 되나요?"
- "Raft 알고리즘이 뭔가요?"
- "왜 3개, 5개처럼 홀수로 구성하나요?"

**실습 내용**:
- ETCD에 직접 데이터 저장/조회
- Watch 메커니즘 실시간 체험
- Leader Election 관찰

---

#### Session 3 (11:00-11:50): Service 타입 마스터하기
**해결하는 질문**:
- "언제 어떤 Service 타입을 써야 하나요?"
- "ClusterIP는 IP가 어디서 오나요?"
- "NodePort는 왜 30000-32767 범위인가요?"

**실습 내용**:
- ClusterIP, NodePort, LoadBalancer 3가지 모두 생성
- 각 타입별 접근 방법 테스트
- Service Endpoint 확인

---

### **Day 2: 네트워킹과 스토리지 실전**

#### Session 4 (09:00-09:50): Kubernetes 네트워킹 완전 정복
**해결하는 질문**:
- "Pod IP랑 Service IP가 왜 다른 대역인가요?"
- "CNI가 뭐고 왜 필요한가요?"
- "10.244.0.0/16은 어디서 온 숫자인가요?"

**실습 내용**:
- Pod IP, Service IP 주소 추적
- CNI 플러그인 확인
- 네트워크 디버깅 (ping, curl, nslookup)

---

#### Session 5 (10:00-10:50): PV/PVC 바인딩의 모든 것
**해결하는 질문**:
- "왜 PV와 PVC를 분리했을까?"
- "StorageClass는 뭔가요?"
- "동적 프로비저닝 vs 정적 프로비저닝?"

**실습 내용**:
- 정적 PV/PVC 생성 및 바인딩
- 동적 프로비저닝 (StorageClass)
- StatefulSet으로 영속적 데이터 관리

---

#### Session 6 (11:00-11:50): 종합 실습 - 3-Tier 애플리케이션 배포
**실습 내용**:
- Frontend (Deployment + LoadBalancer Service)
- Backend (Deployment + ClusterIP Service)
- Database (StatefulSet + PVC + ClusterIP Service)

**최종 완성**:
```
User → LoadBalancer → Frontend Pod
                          ↓
                    ClusterIP Service
                          ↓
                    Backend Pod
                          ↓
                    ClusterIP Service
                          ↓
                    Database StatefulSet (PVC)
```

---

## 🛠️ 실습 환경 준비

### ⚠️ 실습 전 필수 완료!

**모든 세션 시작 전에 실습 환경이 준비되어야 합니다.**

### 📋 [실습 환경 설정 가이드 (requirements.md)](requirements.md)

**체크리스트**:
- [ ] Docker 설치 및 실행 (`docker --version`)
- [ ] kubectl 설치 (`kubectl version --client`)
- [ ] Kind 설치 (`kind version`)
- [ ] Kind 클러스터 생성 (`kind create cluster --name k8s-lab`)
- [ ] 클러스터 동작 확인 (`kubectl get nodes` → Ready)
- [ ] 테스트 Pod 생성 성공 (`kubectl run test --image=nginx:1.25.3`)

**소요 시간**: 약 10-15분 (처음 설정 시)

**문제 발생 시**: [requirements.md의 트러블슈팅 가이드](requirements.md#-문제-해결-가이드) 참조

---

## 🎓 학습 방식

### 코드는 직접 타이핑!

**❌ 복사/붙여넣기 지양**
**✅ 직접 타이핑 권장**

각 세션의 강의 자료(`.md` 파일)를 보면서:
1. YAML 코드를 **한 줄씩 타이핑**
2. 각 필드의 의미를 이해하며 작성
3. 오타가 나면 에러 메시지를 통해 학습

`labs/` 폴더의 파일들은:
- **정답 확인용**
- **시간 부족 시 빠른 진행용**
- **복습용**

### 실습 진행 방식

**멀티 터미널 권장**:
```
터미널 1: kubectl get pods -w          # 실시간 모니터링
터미널 2: kubectl get rs -w            # ReplicaSet 관찰
터미널 3: kubectl logs -f <pod-name>   # 로그 확인
터미널 4: 실제 명령어 실행              # 작업 터미널
```

---

## 📂 디렉토리 구조

```
week_03_supplement/
├── README.md                        # 이 파일
├── requirements.md                  # 실습 환경 설정 가이드 ⭐
│
├── day1/                            # Day 1: 아키텍처 개념
│   ├── session1/                    # Pod vs Container vs Deployment
│   │   ├── session1.md              # 강의 자료
│   │   └── labs/                    # 실습 파일 (정답)
│   │       ├── 01-single-container-pod.yaml
│   │       ├── 02-multi-container-pod.yaml
│   │       ├── 03-replicaset.yaml
│   │       ├── 04-deployment-v1.yaml
│   │       └── README.md
│   │
│   ├── session2/                    # ETCD와 클러스터 상태
│   │   ├── session2.md
│   │   └── labs/
│   │
│   └── session3/                    # Service 타입
│       ├── session3.md
│       └── labs/
│
└── day2/                            # Day 2: 네트워킹과 스토리지
    ├── session4/                    # Kubernetes 네트워킹
    ├── session5/                    # PV/PVC
    └── session6/                    # 종합 실습
```

---

## 🎯 각 세션별 특징

### 실습 중심 (이론 30% + 실습 70%)
- 개념 설명 후 **즉시 실습**으로 확인
- 모든 명령어를 **직접 타이핑**하며 체득
- 에러를 만나고 해결하며 학습

### 비기너 눈높이
- "왜?"에 대한 명확한 답변
- 실생활 비유로 추상적 개념 구체화
- 초보자가 자주 하는 실수 미리 안내

### 코드 기반
- 모든 개념을 **실제 YAML**로 작성
- `kubectl` 명령어로 **직접 확인**
- **트러블슈팅 시나리오** 포함

### 점진적 난이도
- Session 1-2: 기본 개념 확립
- Session 3-4: 중급 개념 적용
- Session 5-6: 실전 통합 프로젝트

---

## 💡 학습 팁

### 1. 실습 환경 미리 준비
**강의 시작 전날** `requirements.md`를 따라 환경 구성 완료

### 2. 실수를 두려워하지 마세요
- 에러 메시지가 최고의 선생님
- `kubectl describe`, `kubectl logs`로 디버깅 습관

### 3. 각 단계마다 확인
```bash
# 매번 현재 상태 확인 습관
kubectl get all
kubectl get pods -o wide
kubectl describe <resource>
```

### 4. 정리하면서 진행
```bash
# 실습 완료 후 리소스 정리
kubectl delete -f <file.yaml>
kubectl delete all --all  # 주의: 모든 리소스 삭제
```

### 5. 메모하며 학습
- 이해한 내용을 자기 말로 정리
- 헷갈리는 부분은 표시해두고 질문

---

## 🚨 자주 묻는 질문 (FAQ)

### Q1: "실습 환경 구성이 안 돼요!"
**A**: [requirements.md의 트러블슈팅 가이드](requirements.md#-문제-해결-가이드) 참조
- Docker 실행 확인
- Kind 클러스터 재생성
- 네트워크/프록시 설정 확인

### Q2: "YAML 파일 작성이 어려워요!"
**A**: 처음엔 천천히 타이핑하세요
- 들여쓰기 주의 (스페이스 2칸)
- `kubectl apply` 후 에러 메시지 읽기
- `labs/` 폴더의 정답과 비교

### Q3: "실습 시간이 부족해요!"
**A**: `labs/` 폴더의 완성된 파일 사용
- 하지만 **복습 시 반드시 직접 타이핑**
- 이해 없는 복붙은 의미 없음

### Q4: "에러가 계속 나요!"
**A**: 에러 메시지를 통한 학습이 핵심
```bash
# 1. Pod 상태 확인
kubectl get pods

# 2. 상세 정보 확인
kubectl describe pod <pod-name>

# 3. 로그 확인
kubectl logs <pod-name>

# 4. 이벤트 확인
kubectl get events --sort-by='.lastTimestamp'
```

---

## 📚 참고 자료

### 공식 문서
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [kubectl 치트시트](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Kind 공식 문서](https://kind.sigs.k8s.io/)

### 추가 학습
- Week 3 본 강의 복습
- Kubernetes The Hard Way (고급)
- CNCF Landscape (생태계 이해)

---

## 🎉 시작 준비 완료!

1. ✅ [requirements.md](requirements.md)로 실습 환경 구성
2. ✅ Day 1 Session 1부터 시작
3. ✅ 코드는 직접 타이핑하며 학습
4. ✅ 에러를 만나고 해결하며 성장

---

<div align="center">

**🚀 Week 3.5 보충 강좌 시작!**

**첫 번째 세션**: [Day 1 Session 1 - Pod vs Container vs Deployment](day1/session1/session1.md)

</div>
