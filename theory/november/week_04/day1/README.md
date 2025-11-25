# November Week 4 Day 1: Amazon EKS 기초

<div align="center">

**☸️ Amazon EKS** • **🏗️ Terraform IaC** • **🔐 보안 설정** • **🎬 라이브 데모**

*AWS 관리형 Kubernetes 서비스 완전 정복*

</div>

---

## 🕘 일일 스케줄

| 시간 | 구분 | 내용 | 방식 |
|------|------|------|------|
| **09:00-09:40** | 📚 이론 1 | [Session 1: EKS 아키텍처](./session_1.md) | 강의 |
| **09:40-10:20** | 📚 이론 2 | [Session 2: Terraform으로 EKS 구축](./session_2.md) | 강의 |
| **10:20-11:10** | 📚 이론 3 | [Session 3: EKS 보안](./session_3.md) | 강의 |
| **11:10-12:00** | 🎬 라이브 데모 | [Demo: EKS 클러스터 실시간 구축](./demo_guide.md) | 실시간 시연 |
| **12:00-13:00** | 🍽️ 점심 | 점심시간 | |
| **13:00-14:00** | 💬 Q&A | 질의응답 및 토론 | 상호작용 |

---

## 🎯 일일 학습 목표

### 📚 이론 목표
- **EKS 아키텍처**: Control Plane과 Worker Node 구조 완전 이해
- **Terraform IaC**: 코드로 EKS 클러스터 자동 구축 방법 습득
- **보안 메커니즘**: RBAC, Pod Security, Network Policy 이해

### 🎬 데모 목표
- **실시간 관찰**: Terraform으로 EKS 클러스터 생성 과정 직접 확인
- **아키텍처 확인**: VPC, Subnet, NAT Gateway 자동 구성 관찰
- **워크로드 배포**: 실제 애플리케이션 배포 및 LoadBalancer 동작 확인
- **실무 감각**: 실제 운영 환경에서의 노하우 습득

---

## 📖 세션 개요

### Session 1: EKS 아키텍처 (09:00-09:40)
**핵심 내용**:
- EKS가 필요한 이유 (Self-managed K8s의 한계)
- Control Plane vs Worker Node 구조
- VPC CNI 네트워킹 원리
- Managed Node Group vs Fargate 비교

**학습 포인트**:
- AWS 관리형 서비스의 장점
- Multi-AZ 고가용성 구조
- EKS 네트워킹 아키텍처

**🔗 참조**: [session_1.md](./session_1.md)

---

### Session 2: Terraform으로 EKS 구축 (09:40-10:20)
**핵심 내용**:
- Terraform EKS Module 활용 방법
- IAM Role 및 Policy 설정
- Node Group 구성 및 관리
- kubectl 연결 및 기본 명령어

**학습 포인트**:
- Infrastructure as Code 개념
- 재현 가능한 인프라 구축
- 버전 관리 및 자동화

**🔗 참조**: [session_2.md](./session_2.md)

---

### Session 3: EKS 보안 (10:20-11:10)
**핵심 내용**:
- RBAC (Role-Based Access Control)
- Pod Security Standards
- Network Policy로 트래픽 제어
- Secrets 안전한 관리

**학습 포인트**:
- 최소 권한 원칙 적용
- Pod 보안 강화 방법
- 네트워크 격리 전략

**🔗 참조**: [session_3.md](./session_3.md)

---

## 🎬 라이브 데모 (11:10-12:00)

### 데모 개요
**목표**: Terraform으로 EKS 클러스터를 실시간으로 생성하고 애플리케이션 배포

**시연 내용**:
1. **환경 준비** (5분)
   - AWS 자격증명 확인
   - 필요한 도구 검증

2. **클러스터 생성** (20분)
   - Terraform 스크립트 실행
   - VPC + EKS + Node Group 자동 생성
   - 생성 과정 실시간 관찰 및 설명

3. **클러스터 확인** (5분)
   - kubectl로 노드 확인
   - 시스템 Pod 확인
   - 클러스터 정보 확인

4. **애플리케이션 배포** (10분)
   - Nginx Deployment 생성
   - LoadBalancer Service 생성
   - 외부 접근 확인

5. **리소스 정리** (5분)
   - Terraform destroy 실행
   - 비용 절감 확인

6. **마무리 및 Q&A** (5분)
   - 실무 팁 공유
   - 질문 답변

**📋 상세 가이드**: [demo_guide.md](./demo_guide.md)

**💰 예상 비용**: 시간당 $0.23 (1시간 데모 = $0.23)

---

## 💬 Q&A 세션 (13:00-14:00)

### 예상 질문 주제

#### 1. 서비스 선택
- **Q**: EKS vs Self-managed Kubernetes, 언제 어떤 것을 선택해야 하나요?
- **A**: 
  - **EKS 선택**: 운영 부담 최소화, AWS 통합 필요, 빠른 시작
  - **Self-managed**: 완전한 제어 필요, 비용 최적화 극대화, 특수 요구사항

#### 2. 비용 최적화
- **Q**: EKS 비용을 줄이는 방법은?
- **A**:
  - Spot Instance 활용 (70% 절감)
  - Fargate로 간헐적 워크로드 실행
  - Auto Scaling으로 유휴 시간 Node 축소
  - Reserved Instance로 장기 워크로드 할인

#### 3. 프로덕션 배포
- **Q**: 실제 운영 환경에서 주의할 점은?
- **A**:
  - Multi-AZ Node Group 구성 (고가용성)
  - RBAC 세밀하게 설정 (최소 권한)
  - Network Policy로 트래픽 제어
  - CloudWatch Container Insights 모니터링
  - 정기적인 Kubernetes 버전 업그레이드

#### 4. 트러블슈팅
- **Q**: 흔한 문제와 해결 방법은?
- **A**:
  - **Pod Pending**: Node 리소스 부족 → Node 추가
  - **LoadBalancer Pending**: Subnet 태그 확인
  - **ImagePullBackOff**: ECR 권한 확인
  - **CrashLoopBackOff**: 애플리케이션 로그 확인

### 토론 주제

#### 1. 실무 경험 공유
- EKS 사용 경험이 있다면 공유
- 어떤 문제를 해결했는가?
- 어떤 아키텍처를 구성했는가?

#### 2. 아키텍처 설계
- 우리 프로젝트에 EKS를 어떻게 적용할까?
- 어떤 Node Group 구성이 적합한가?
- 모니터링 전략은?

#### 3. 보안 전략
- 추가로 고려해야 할 보안 사항은?
- 컴플라이언스 요구사항은?
- 감사 로그는 어떻게 관리할까?

---

## 📊 학습 성과 체크

### ✅ 이해도 체크리스트
- [ ] **EKS 아키텍처**: Control Plane과 Worker Node 구조 설명 가능
- [ ] **Terraform 활용**: EKS 클러스터 생성 과정 이해
- [ ] **RBAC 이해**: 역할 기반 접근 제어 원리 파악
- [ ] **Network Policy**: 트래픽 제어 방법 이해
- [ ] **실시간 관찰**: 클러스터 생성 과정 완전 이해

### 🎯 실무 적용 준비도
- [ ] **프로젝트 검토**: EKS 도입 가능성 평가 가능
- [ ] **Terraform 작성**: 기본 EKS 코드 작성 및 수정 가능
- [ ] **보안 설정**: 기본적인 RBAC 및 Network Policy 적용 가능
- [ ] **kubectl 관리**: 기본 명령어로 클러스터 관리 가능
- [ ] **트러블슈팅**: 기본적인 문제 진단 및 해결 가능

---

## 🔗 참고 자료

### 📚 공식 문서
- [Amazon EKS 사용자 가이드](https://docs.aws.amazon.com/eks/latest/userguide/)
- [Terraform AWS EKS Module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)
- [Kubernetes RBAC 문서](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [kubectl 치트시트](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

### 🎥 추가 학습 자료
- [AWS EKS Workshop](https://www.eksworkshop.com/)
- [Terraform EKS 예제](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples)
- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/)

### 💡 실무 가이드
- [EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)
- [Cost Optimization for EKS](https://aws.amazon.com/blogs/containers/cost-optimization-for-kubernetes-on-aws/)
- [EKS Security Best Practices](https://aws.amazon.com/blogs/containers/amazon-eks-security-best-practices/)

---

## 💡 다음 학습 준비

### Day 2 예고: EKS 워크로드 관리
**주제**:
- Deployment & Service (Rolling Update, LoadBalancer)
- StatefulSet & PersistentVolume (EBS CSI Driver)
- HPA & Cluster Autoscaler (자동 스케일링)

**사전 준비 사항**:
- [ ] kubectl 명령어 복습
- [ ] Kubernetes 기본 개념 정리 (Pod, Deployment, Service)
- [ ] Day 1 데모 코드 리뷰
- [ ] EKS 아키텍처 복습

**예습 키워드**:
- Rolling Update 전략
- PersistentVolume & PersistentVolumeClaim
- Horizontal Pod Autoscaler
- Cluster Autoscaler

---

## 📝 일일 회고

### 🤝 페어 회고 (5분)
1. **가장 인상 깊었던 부분**: 
   - 라이브 데모에서 어떤 부분이 가장 흥미로웠나요?
   - 이론 세션에서 새롭게 알게 된 점은?

2. **어려웠던 점**:
   - 이해하기 어려웠던 개념은?
   - 더 자세히 알고 싶은 부분은?

3. **실무 적용 아이디어**:
   - 우리 프로젝트에 어떻게 적용할 수 있을까?
   - 어떤 부분을 더 학습해야 할까?

### 📊 학습 성과
- **기술적 성취**: EKS 아키텍처 및 Terraform 활용 방법 습득
- **실무 연계**: 라이브 데모를 통한 실전 감각 획득
- **다음 단계**: Day 2 워크로드 관리 학습 준비

---

<div align="center">

**☸️ EKS 기초 완성** • **🏗️ Terraform 자동화** • **🔐 보안 강화** • **🎬 실전 감각**

*라이브 데모로 실무 역량 강화*

</div>
