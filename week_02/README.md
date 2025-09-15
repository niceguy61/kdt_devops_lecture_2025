# Week 2: Kubernetes + 클라우드 보안 이론 (80% 이론 + 20% 개념 예시) 🔄 재구성

## 🎯 학습 목표 (KT Cloud 모델 기반)
- **Kubernetes 아키텍처**와 **오케스트레이션 개념** 완전 이해
- **컨테이너 오케스트레이션**의 **필요성**과 **설계 원칙** 학습
- **Kubernetes 핵심 오브젝트**와 **네트워킹 모델** 심화 분석
- **DevSecOps 개념**과 **클라우드 보안 모델** 이론적 토대 구축
- **RBAC과 접근 제어** 프레임워크 이해

## 🌟 KT Cloud 모델 적용 학습 방식
- **내용 비중**: 이론 80% + 개념 예시 20%
- **학습 방식**: 아키텍처 분석 + 개념 설명 + 사례 연구 + 토론
- **시각화 도구**: Mermaid, SVG 다이어그램 적극 활용
- **개념 실습**: 간단한 구조 확인용 실습만 포함
- **실무 연계**: Kubernetes 설계 원칙을 실무 프로젝트로 연결 준비

## 주간 일정

### [Day 1: Kubernetes 기본 개념 및 아키텍처](./day_01/README.md) 🆕 신규 구성
**세션 1**: Kubernetes란 무엇인가?
**세션 2**: 컨테이너 오케스트레이션의 필요성
**세션 3**: Kubernetes 클러스터 아키텍처
**세션 4**: 마스터 노드와 워커 노드
**세션 5**: etcd와 API 서버
**세션 6**: 스케줄러와 컨트롤러
**세션 7**: kubelet과 kube-proxy
**세션 8**: 아키텍처 종합 및 토론

### [Day 2: Kubernetes 핵심 오브젝트 이론](./day_02/README.md) 🆕 신규 구성
**세션 1**: Pod 개념과 설계 원리
**세션 2**: ReplicaSet과 Deployment
**세션 3**: Service와 네트워킹
**세션 4**: ConfigMap과 Secret
**세션 5**: Volume과 PersistentVolume
**세션 6**: Namespace와 리소스 격리
**세션 7**: Labels과 Selectors
**세션 8**: 오브젝트 관계 및 설계 패턴

### [Day 3: Kubernetes 네트워킹 이론](./day_03/README.md) 🆕 신규 구성
**세션 1**: 클러스터 네트워킹 개념
**세션 2**: CNI(Container Network Interface)
**세션 3**: Service 타입별 특징
**세션 4**: Ingress와 로드 밸런싱
**세션 5**: NetworkPolicy와 보안
**세션 6**: DNS와 서비스 디스커버리
**세션 7**: 멀티 클러스터 네트워킹
**세션 8**: 네트워킹 모범 사례

### [Day 4: 클라우드 보안 기초 이론](./day_04/README.md) 🆕 신규 구성
**세션 1**: DevSecOps 개념과 원칙
**세션 2**: 컨테이너 보안 위협 모델
**세션 3**: 이미지 보안과 취약점 스캔
**세션 4**: 런타임 보안과 모니터링
**세션 5**: Kubernetes 보안 모델
**세션 6**: RBAC과 접근 제어
**세션 7**: 네트워크 보안 정책
**세션 8**: 보안 모범 사례

### [Day 5: Kubernetes 고급 개념 및 통합](./day_05/README.md) 🆕 신규 구성
**세션 1**: StatefulSet과 상태 관리
**세션 2**: DaemonSet과 Job
**세션 3**: HPA와 VPA (오토스케일링)
**세션 4**: 클러스터 오토스케일링
**세션 5**: 헬름(Helm)과 패키지 관리
**세션 6**: 커스텀 리소스와 오퍼레이터
**세션 7**: Kubernetes 생태계
**세션 8**: 이론 종합 및 토론

## 📊 Week 2 학습 성과 목표 (KT Cloud 모델)

### 이론 이해도 목표
```
Kubernetes 아키텍처:
├── 클러스터 구조 이해    ████████████ 100%
├── 핵심 오브젝트 개념    ████████████ 100%
├── 네트워킹 모델        ████████████ 100%
└── 보안 프레임워크      ████████████ 100%

실무 연계 준비도:
├── 아키텍처 설계 능력   ███████████  90%
├── 보안 정책 수립      ██████████   85%
├── 사례 분석 역량      ████████████ 90%
└── 취업 준비 기초      ██████████   80%
```

### 추가 구성 요소 (KT Cloud 모델)
- **업계 전문가 특강**: 매주 금요일 Session 8 (Kubernetes 전문가)
- **아키텍처 설계 과제**: Kubernetes 클러스터 설계
- **사례 연구**: 대기업 Kubernetes 도입 사례
- **취업 준비**: Kubernetes 관련 기술 면접 대비

## 🎯 Week 3 준비 완료 (CI/CD + 모니터링/로깅 이론)

### 이론적 토대 구축 완료
- **Kubernetes 아키텍처** → CI/CD 파이프라인 통합 준비
- **오브젝트 모델** → 배포 자동화 전략 준비
- **네트워킹 이론** → 서비스 메시 연결 준비
- **보안 모델** → DevSecOps 통합 준비
- **고급 개념** → 모니터링 시스템 연결 준비

### Week 3 이론 학습 준비사항
- [ ] Week 2 Kubernetes + 보안 이론 복습
- [ ] CI/CD 파이프라인 기본 개념 예습
- [ ] 모니터링 시스템 기초 개념 예습
- [ ] 아키텍처 설계 과제 준비
- [ ] 사례 연구 자료 준비

## 💡 Week 2 핵심 개념 (KT Cloud 모델)
- **오케스트레이션**: 자동화, 스케일링, 고가용성, 서비스 디스커버리
- **Kubernetes 아키텍처**: 마스터-워커, API 서버, etcd, 스케줄러
- **핵심 오브젝트**: Pod, Service, Deployment, ConfigMap, Secret
- **네트워킹**: CNI, Service 타입, Ingress, NetworkPolicy
- **보안 모델**: RBAC, 네트워크 정책, 이미지 보안, 런타임 보안

## 📚 참고 자료
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [CNCF Landscape](https://landscape.cncf.io/)
- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/)
- [Container Security](https://kubernetes.io/docs/concepts/security/pod-security-standards/)

---
**Week 2 재구성 완료! KT Cloud 모델에 따라 Kubernetes와 클라우드 보안 이론을 체계적으로 학습합니다!** 🚀

**이전**: [Week 1 - DevOps 기초 + Docker 이론](../week_01/README.md)
**다음**: [Week 3 - CI/CD + 모니터링/로깅 이론 (70% 이론 + 30% 개념 실습)](../week_03/README.md)