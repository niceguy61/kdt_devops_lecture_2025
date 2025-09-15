# Day 2: 보안 모델과 정책 관리

## 📍 일차 개요
Week 3의 두 번째 날로, Kubernetes의 보안 모델과 정책 기반 관리 시스템을 학습합니다. Day 1에서 학습한 워크로드 관리를 바탕으로 프로덕션 환경에서 필수적인 보안 개념과 정책 관리 전략을 다룹니다.

## 🎯 일차 학습 목표
- **Kubernetes 보안 모델**의 **다층 방어** 아키텍처 이해
- **RBAC** 심화와 **세밀한 권한 설계** 패턴 학습
- **Pod Security Standards**와 **네트워크 정책** 구현 방법 파악
- **Secret 관리**와 **암호화 전략** 설계 원리 이해
- **컴플라이언스**와 **감사 체계** 구축 방법 습득

## 📅 세션 구성

### [Session 1: Kubernetes 보안 모델 개요](./session_01.md)
- 다층 보안 아키텍처와 보안 경계
- 인증, 인가, 감사 (AAA) 프레임워크
- 보안 컨텍스트와 권한 관리
- 위협 모델링과 공격 벡터 분석

### [Session 2: RBAC 심화와 권한 설계 패턴](./session_02.md)
- Role과 ClusterRole 설계 원칙
- RoleBinding과 ClusterRoleBinding 전략
- ServiceAccount 관리와 토큰 보안
- 최소 권한 원칙 구현 방법

### [Session 3: Pod Security Standards와 정책](./session_03.md)
- Pod Security Standards (Restricted, Baseline, Privileged)
- SecurityContext 설정과 보안 제약
- 컨테이너 런타임 보안
- 권한 상승 방지 메커니즘

### [Session 4: Network Policy와 트래픽 제어](./session_04.md)
- 네트워크 분할과 마이크로세그멘테이션
- Ingress/Egress 규칙 설계
- CNI 플러그인별 네트워크 정책 구현
- 서비스 메시와 네트워크 보안 통합

### [Session 5: Secret 관리와 암호화 전략](./session_05.md)
- Secret 생명주기 관리
- 외부 시크릿 관리 시스템 통합
- 암호화 키 관리 (KMS 연동)
- 시크릿 로테이션과 자동화

### [Session 6: 이미지 보안과 취약점 관리](./session_06.md)
- 컨테이너 이미지 보안 스캔
- 이미지 서명과 검증
- 취약점 데이터베이스 활용
- 보안 정책 기반 이미지 관리

### [Session 7: 감사 로깅과 컴플라이언스](./session_07.md)
- Kubernetes 감사 로깅 구성
- 보안 이벤트 모니터링
- 컴플라이언스 프레임워크 (CIS, NIST)
- 규제 요구사항 대응 전략

### [Session 8: 보안 아키텍처 설계와 모범 사례](./session_08.md)
- 종합적 보안 아키텍처 설계
- 보안 운영 센터 (SOC) 구축
- 인시던트 대응 및 복구 절차
- 보안 자동화와 DevSecOps 통합

## 🛠 학습 방식
- **이론 70%**: 보안 개념과 원리에 대한 심화 학습
- **보안 패턴 30%**: 검증된 보안 설계 패턴과 사례 분석

## 📊 세션별 시간 배분
```
각 세션 50분 구성:
├── 학습 목표 (5분)
├── 핵심 개념 (15분)
├── 심화 분석 (12분)
├── 보안 패턴 (10분)
└── 그룹 토론 (8분)
```

## 🔗 연계성
- **Day 1**: 워크로드 관리 → 보안 모델
- **Day 3**: 보안 모델 → 모니터링 및 관찰 가능성
- **실무 연계**: 프로덕션 보안 요구사항 반영

## 📚 참고 자료
- [Kubernetes Security](https://kubernetes.io/docs/concepts/security/)
- [RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
- [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes)

---
*Day 2를 통해 Kubernetes의 보안 모델을 완전히 이해하고, 프로덕션 환경에서 안전하고 컴플라이언트한 시스템을 구축할 수 있는 전문성을 기릅니다.*