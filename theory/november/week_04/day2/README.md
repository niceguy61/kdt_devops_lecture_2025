# November Week 4 Day 2: EKS 워크로드 관리

<div align="center">

**📦 Deployment** • **🔄 Rolling Update** • **💾 StatefulSet** • **📈 Auto Scaling** • **🎬 라이브 데모**

*EKS에서 애플리케이션 배포 및 스케일링 완전 정복*

</div>

---

## 🕘 일일 스케줄

| 시간 | 구분 | 내용 | 방식 |
|------|------|------|------|
| **09:00-09:50** | 📚 이론 1 | [Session 1: Deployment & Service](./session_1.md) | 강의 |
| **09:50-10:00** | ☕ 휴식 | 10분 휴식 | |
| **10:00-10:50** | 📚 이론 2 | [Session 2: StatefulSet & PersistentVolume](./session_2.md) | 강의 |
| **10:50-11:00** | ☕ 휴식 | 10분 휴식 | |
| **11:00-11:50** | 📚 이론 3 | [Session 3: HPA & Cluster Autoscaler](./session_3.md) | 강의 |
| **11:50-12:00** | ☕ 휴식 | 10분 휴식 | |
| **12:00-13:00** | 🎬 라이브 데모 | [Demo: 워크로드 배포 및 스케일링](./demo_guide.md) | 실시간 시연 |
| **13:00-14:00** | 🍽️ 점심 | 점심시간 | |
| **14:00-15:00** | 💬 Q&A | 질의응답 및 토론 | 상호작용 |

---

## 🎯 일일 학습 목표

### 📚 이론 목표
- **Deployment 관리**: Rolling Update 전략 및 무중단 배포
- **StatefulSet 이해**: 상태 유지 애플리케이션 배포 방법
- **Auto Scaling**: HPA와 Cluster Autoscaler 작동 원리

### 🎬 데모 목표
- **실시간 배포**: Deployment 생성 및 Rolling Update 관찰
- **스토리지 연결**: EBS CSI Driver로 PersistentVolume 사용
- **자동 스케일링**: HPA로 Pod 자동 증가 확인

---

## 📖 세션 개요

### Session 1: Deployment & Service (09:00-09:50)
**핵심 내용**:
- Deployment 생성 및 관리
- Rolling Update 전략
- LoadBalancer Service
- ConfigMap & Secret

**학습 포인트**:
- 무중단 배포 방법
- 서비스 노출 전략
- 설정 관리 베스트 프랙티스

**🔗 참조**: [session_1.md](./session_1.md)

---

### Session 2: StatefulSet & PersistentVolume (10:00-10:50)
**핵심 내용**:
- StatefulSet vs Deployment
- EBS CSI Driver 설치
- PersistentVolume & PersistentVolumeClaim
- 데이터베이스 배포

**학습 포인트**:
- 상태 유지 애플리케이션 관리
- 스토리지 프로비저닝
- 데이터 영속성 보장

**🔗 참조**: [session_2.md](./session_2.md)

---

### Session 3: HPA & Cluster Autoscaler (11:00-11:50)
**핵심 내용**:
- Metrics Server 설치
- Horizontal Pod Autoscaler
- Cluster Autoscaler 설정
- 리소스 관리

**학습 포인트**:
- 자동 스케일링 메커니즘
- 리소스 효율화
- 비용 최적화

**🔗 참조**: [session_3.md](./session_3.md)

---

## 🎬 라이브 데모 (12:00-13:00)

### 데모 개요
**목표**: EKS에서 애플리케이션 배포, 스토리지 연결, 자동 스케일링 실시간 시연

**시연 내용**:
1. **환경 준비** (5분)
   - Day 1 클러스터 재사용 또는 새로 생성
   - 필요한 도구 확인

2. **Deployment 배포** (15분)
   - Nginx Deployment 생성
   - Rolling Update 실행
   - 무중단 배포 확인

3. **PersistentVolume 사용** (15분)
   - EBS CSI Driver 설치
   - PVC 생성 및 Pod 연결
   - 데이터 영속성 확인

4. **Auto Scaling 설정** (15분)
   - Metrics Server 설치
   - HPA 생성
   - 부하 테스트로 자동 증가 확인

5. **리소스 정리** (5분)
   - 모든 리소스 삭제

6. **마무리 및 Q&A** (5분)
   - 실무 팁 공유

**📋 상세 가이드**: [demo_guide.md](./demo_guide.md)

**💰 예상 비용**: 시간당 $0.25 (EBS 볼륨 추가)

---

## 💬 Q&A 세션 (14:00-15:00)

### 예상 질문 주제

#### 1. 배포 전략
- **Q**: Rolling Update vs Blue-Green vs Canary, 언제 어떤 것을 사용하나요?
- **A**: 
  - **Rolling Update**: 기본 전략, 점진적 교체
  - **Blue-Green**: 즉시 전환, 빠른 롤백
  - **Canary**: 일부 트래픽으로 테스트

#### 2. 스토리지 선택
- **Q**: EBS vs EFS, 어떤 것을 선택해야 하나요?
- **A**:
  - **EBS**: 단일 Pod, 높은 성능, 블록 스토리지
  - **EFS**: 여러 Pod 공유, 파일 스토리지

#### 3. Auto Scaling
- **Q**: HPA와 Cluster Autoscaler의 차이는?
- **A**:
  - **HPA**: Pod 수 조절 (수평 확장)
  - **Cluster Autoscaler**: Node 수 조절 (인프라 확장)

#### 4. 비용 최적화
- **Q**: Auto Scaling으로 비용을 줄이는 방법은?
- **A**:
  - 적절한 리소스 요청/제한 설정
  - Scale down 정책 최적화
  - Spot Instance 활용

---

## 📊 학습 성과 체크

### ✅ 이해도 체크리스트
- [ ] **Deployment 관리**: Rolling Update 전략 이해
- [ ] **StatefulSet 차이**: Deployment와의 차이점 파악
- [ ] **PersistentVolume**: 스토리지 프로비저닝 이해
- [ ] **HPA 작동**: 자동 스케일링 메커니즘 이해
- [ ] **실시간 관찰**: 배포 및 스케일링 과정 완전 이해

### 🎯 실무 적용 준비도
- [ ] **무중단 배포**: Rolling Update 전략 적용 가능
- [ ] **상태 관리**: StatefulSet으로 데이터베이스 배포 가능
- [ ] **스토리지 연결**: PVC로 영속 스토리지 사용 가능
- [ ] **Auto Scaling**: HPA 설정 및 관리 가능

---

## 🔗 참고 자료

### 📚 공식 문서
- [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
- [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [EBS CSI Driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver)

### 🎥 추가 학습 자료
- [Kubernetes Deployment Strategies](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy)
- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Cluster Autoscaler on AWS](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/aws)

---

## 💡 다음 학습 준비

### Day 3 예고: 마이크로서비스 보안
**주제**:
- Service Mesh (Istio)
- mTLS 통신
- JWT 인증
- Network Policy

**사전 준비 사항**:
- [ ] Day 2 개념 복습
- [ ] 마이크로서비스 아키텍처 개념 정리
- [ ] 보안 기본 개념 복습

---

<div align="center">

**📦 워크로드 관리** • **💾 데이터 영속성** • **📈 자동 스케일링** • **🎬 실전 감각**

*EKS 운영의 핵심 기술 완전 정복*

</div>
