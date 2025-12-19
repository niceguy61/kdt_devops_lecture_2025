# 🚀 Kubernetes 고급 과정 (12월)

## 📋 과정 개요
실무 환경에서의 Kubernetes 운영 및 고급 기능을 학습하는 집중 과정입니다. Amazon EKS를 활용하여 실제 클라우드 환경에서 Kubernetes를 운영하는 방법을 익힙니다.

## ⚠️ 실습 전 필수 준비사항

**🚨 중요**: 모든 실습 참가자는 첫 번째 세션 시작 전에 반드시 환경 설정을 완료해야 합니다!

### 📖 필수 문서
- **[EKS 실습 환경 설정 가이드](./day1_eks_setup/requirements.md)**
  - AWS CLI, eksctl, kubectl 설치 방법
  - AWS 자격 증명 및 IAM 권한 설정
  - 환경 체크 스크립트 사용법
  - 문제 해결 가이드

### 🔧 환경 체크
실습 시작 전에 다음 스크립트를 실행하여 환경을 확인하세요:

```bash
# Linux/macOS 사용자
cd day1_eks_setup
chmod +x check-environment.sh
./check-environment.sh

# Windows 사용자 (PowerShell)
cd day1_eks_setup
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\check-environment.ps1
```

## 📅 커리큘럼

### Day 1: EKS 클러스터 생성 및 기본 설정
**디렉토리**: [`day1_eks_setup/`](./day1_eks_setup/)

#### 세션 구성
- **Session 1**: [EKS 기초 + 클러스터 생성](./day1_eks_setup/session1.md) (50분)
  - EKS 아키텍처 이해
  - eksctl을 사용한 클러스터 생성
  - 클러스터 연결 및 확인

#### 주요 학습 내용
- Amazon EKS 아키텍처 및 구성 요소
- eksctl을 활용한 클러스터 생성
- VPC 및 네트워킹 구조 이해
- 클러스터 보안 설정
- kubectl을 통한 클러스터 관리

#### 실습 파일
- [`cluster-config.yaml`](./day1_eks_setup/cluster-config.yaml) - 새 VPC 생성용 설정
- [`cluster-config-existing-vpc.yaml`](./day1_eks_setup/cluster-config-existing-vpc.yaml) - 기존 VPC 사용 설정

### Day 3: Helm 패키지 관리자
**디렉토리**: [`day3_helm_basics/`](./day3_helm_basics/)

#### 세션 구성
- **Session 1**: [Helm 기초 및 설치](./day3_helm_basics/session1.md)
  - Helm 아키텍처 이해
  - Chart 구조 및 템플릿 시스템
  - 기본 명령어 실습

- **Session 2**: [Helm Chart 개발 및 배포](./day3_helm_basics/session2.md)
  - 커스텀 Chart 생성
  - Values 파일 활용
  - 릴리스 관리 및 업그레이드

#### 주요 학습 내용
- Helm의 역할과 장점
- Chart 구조 및 템플릿 문법
- 패키지 관리 및 버전 관리
- 실무 환경에서의 Helm 활용

### Day 5: Istio 서비스 메시
**디렉토리**: [`day5_istio_service_mesh/`](./day5_istio_service_mesh/)

#### 세션 구성
- **Session 1**: [Istio 기초 및 설치](./day5_istio_service_mesh/session1.md)
  - 서비스 메시 개념 이해
  - Istio 아키텍처 및 구성 요소
  - Istio 설치 및 설정

#### 주요 학습 내용
- 서비스 메시의 필요성과 장점
- Istio 아키텍처 (Control Plane, Data Plane)
- 트래픽 관리 및 보안 정책
- 관측성 및 모니터링

## 💰 비용 안내

### EKS 클러스터 예상 비용
- **EKS 클러스터**: $0.10/시간 ($72/월)
- **EC2 인스턴스**: t3.medium 2대 (~$60/월)
- **NAT Gateway**: $32/월 + 데이터 전송비
- **EBS 볼륨**: 20GB x 2 (~$4/월)
- **총 예상 비용**: ~$168/월

### 비용 절약 팁
- 실습 후 즉시 클러스터 삭제
- NAT Gateway Single 사용 (설정 파일에 포함됨)
- 소규모 인스턴스 타입 사용

## 🛠️ 문제 해결

### 일반적인 문제들
1. **AWS 권한 부족**
   - [requirements.md](./day1_eks_setup/requirements.md)의 "IAM 권한 확인 및 설정" 섹션 참조
   - AWS 관리자에게 필요 권한 요청

2. **도구 설치 문제**
   - [requirements.md](./day1_eks_setup/requirements.md)의 "필수 도구 설치" 섹션 참조
   - OS별 설치 방법 확인

3. **네트워크 연결 문제**
   - 방화벽 및 프록시 설정 확인
   - AWS API 엔드포인트 접근 가능 여부 확인

### 지원 요청
문제가 해결되지 않는 경우:
- 실습 진행자에게 문의
- 환경 체크 스크립트 결과 공유
- 오류 메시지 전체 내용 제공

## 📚 참고 자료

### 공식 문서
- [Amazon EKS 사용 설명서](https://docs.aws.amazon.com/eks/)
- [eksctl 공식 문서](https://eksctl.io/)
- [Helm 공식 문서](https://helm.sh/docs/)
- [Istio 공식 문서](https://istio.io/latest/docs/)

### 추가 학습 자료
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [AWS 컨테이너 서비스 블로그](https://aws.amazon.com/blogs/containers/)
- [CNCF 프로젝트](https://www.cncf.io/projects/)

---

## ✅ 실습 준비 체크리스트

실습 시작 전에 다음 항목들을 모두 확인해주세요:

### 환경 설정
- [ ] [requirements.md](./day1_eks_setup/requirements.md) 문서 읽기 완료
- [ ] AWS CLI v2 설치 완료
- [ ] eksctl 설치 완료
- [ ] kubectl 설치 완료
- [ ] AWS 자격 증명 설정 완료
- [ ] 환경 체크 스크립트 실행 완료 (모든 항목 ✅)

### AWS 계정 및 권한
- [ ] AWS 계정 접근 가능
- [ ] EKS 관련 IAM 권한 확인
- [ ] 기본 리전 ap-northeast-2 설정
- [ ] 예상 비용 확인 및 승인

### 실습 환경
- [ ] 안정적인 인터넷 연결
- [ ] 충분한 디스크 공간 (10GB+)
- [ ] 터미널/PowerShell 사용 가능

**⚠️ 모든 항목이 완료된 후에만 실습에 참여하세요!**