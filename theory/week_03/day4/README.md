# Week 3 Day 4: 보안과 RBAC + GitOps

<div align="center">

**🔐 클러스터 보안** • **👤 RBAC** • **🚀 GitOps**

*RBAC부터 GitOps까지, 안전하고 자동화된 Kubernetes 운영*

</div>

---

## 🕘 세션 정보
**시간**: 09:00-11:50 (이론 2.5시간) + 13:00-16:00 (실습 3시간)
**목표**: RBAC 보안 + AWS EKS IRSA + GitOps 배포 자동화
**방식**: 협업 중심 학습 + 레벨별 차별화

## 🎯 세션 목표
### 📚 학습 목표
- **이해 목표**: RBAC, IRSA, GitOps 보안 모델 완전 이해
- **적용 목표**: 실무 수준의 보안 설정과 자동화된 배포 파이프라인 구축
- **협업 목표**: 팀별 권한 관리와 GitOps 워크플로우 구성

---

## 📖 Session 1: RBAC + ServiceAccount (50분)

### 🔍 개념 1: RBAC 기본 개념 (15분)
> **정의**: Role-Based Access Control, 역할 기반 접근 제어로 클러스터 리소스에 대한 세밀한 권한 관리

**RBAC 구성 요소**:
- **Subject**: 사용자, 그룹, ServiceAccount (누가)
- **Verb**: get, list, create, update, delete (무엇을)
- **Resource**: pods, services, deployments (어떤 리소스에)
- **Role/ClusterRole**: 권한 집합 정의
- **RoleBinding/ClusterRoleBinding**: Subject와 Role 연결

### 🔍 개념 2: ServiceAccount 관리 (15분)
> **정의**: Pod가 Kubernetes API에 접근할 때 사용하는 계정으로, 애플리케이션의 신원을 나타냄

**ServiceAccount 특징**:
- **자동 생성**: 각 네임스페이스마다 default ServiceAccount 자동 생성
- **토큰 기반**: JWT 토큰을 통한 인증
- **Pod 연결**: Pod spec에서 serviceAccountName으로 지정
- **권한 제한**: RBAC을 통한 세밀한 권한 제어

### 🔍 개념 3: 최소 권한 원칙 (15분)
> **정의**: 각 주체가 업무 수행에 필요한 최소한의 권한만 부여하는 보안 원칙

### 💭 함께 생각해보기 (5분)

**🤝 페어 토론**:
1. "개발팀과 운영팀의 권한이 달라야 하는 이유는?"
2. "ServiceAccount와 User Account의 차이점과 사용 시기는?"

---

## 📖 Session 2: AWS EKS 보안 + IRSA (50분)

### 🔍 개념 1: EKS 보안 아키텍처 (15분)
> **정의**: AWS EKS의 다층 보안 모델과 AWS 서비스 통합 보안 기능

### 🔍 개념 2: IRSA (IAM Roles for Service Accounts) (15분)
> **정의**: Kubernetes ServiceAccount에 AWS IAM 역할을 직접 연결하여 세밀한 AWS 서비스 접근 제어

### 🔍 개념 3: Pod Security Standards (15분)
> **정의**: Pod의 보안 설정을 표준화하고 강제하는 Kubernetes 보안 정책

### 💭 함께 생각해보기 (5분)

**🤝 페어 토론**:
1. "IRSA를 사용하는 것과 AWS 키를 Secret에 저장하는 것의 차이점은?"
2. "Pod Security Standards의 세 가지 레벨을 언제 각각 사용해야 할까요?"

---

## 📖 Session 3: GitOps (ArgoCD, Helm) + Pod Security Standards (50분)

### 🔍 개념 1: GitOps 기본 개념 (15분)
> **정의**: Git 저장소를 단일 진실 소스로 사용하여 선언적으로 인프라와 애플리케이션을 관리하는 방법론

### 🔍 개념 2: ArgoCD 설치 및 구성 (15분)
> **정의**: Kubernetes를 위한 선언적 GitOps 지속적 배포 도구

### 🔍 개념 3: Helm과 GitOps 통합 (15분)
> **정의**: Helm 차트를 GitOps 워크플로우에 통합하여 템플릿 기반 배포 관리

### 💭 함께 생각해보기 (5분)

**🤝 페어 토론**:
1. "GitOps와 전통적인 CI/CD의 차이점과 장점은?"
2. "Helm을 사용하는 것과 순수 YAML을 사용하는 것의 트레이드오프는?"

---

## 🛠️ 실습 챌린지 (3시간)

### 🚀 Phase 1: RBAC 세밀한 권한 제어 구성 (90분)
### 🌟 Phase 2: EKS IRSA 구성 및 AWS 서비스 연동 (90분)
### 🏆 Phase 3: GitOps 파이프라인 구축 (30분)

---

## 📝 일일 마무리

### ✅ 오늘의 성과
- [ ] RBAC으로 세밀한 권한 제어 시스템 구축
- [ ] EKS IRSA로 AWS 서비스 안전한 연동
- [ ] ArgoCD를 통한 GitOps 파이프라인 구축

### 🎯 내일 준비사항
- **예습**: Prometheus와 Grafana의 기본 개념
- **복습**: RBAC 권한 설정 명령어 연습

---

<div align="center">

**🎉 Day 4 완료!** 

*안전하고 자동화된 Kubernetes 보안 및 배포 시스템을 완전히 마스터했습니다*

</div>