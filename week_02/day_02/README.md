# Week 2 Day 2: Kubernetes 핵심 오브젝트 이론 (이론 중심)

## 📅 일정 개요
- **날짜**: Week 2, Day 2
- **주제**: Kubernetes 핵심 오브젝트와 설계 패턴
- **총 세션**: 8개 (각 50분)
- **학습 방식**: 이론 80% + 개념 예시 20%

## 🎯 학습 목표
- **Pod 개념**과 **설계 원리** 완전 이해
- **ReplicaSet과 Deployment**의 **관계**와 **배포 전략** 학습
- **Service와 네트워킹** 모델 심화 분석
- **ConfigMap과 Secret**의 **구성 관리** 패턴 파악
- **Volume과 PersistentVolume**의 **스토리지 추상화** 이해

## Day 2 특징 (KT Cloud 모델)
- **내용 비중**: 이론 80% + 개념 예시 20%
- **학습 방식**: 오브젝트 분석 + 설계 패턴 + 관계 이해 + 토론
- **시각 자료**: 오브젝트 관계도와 YAML 구조 분석
- **실습 제한**: 복잡한 배포 과정 지양, 구조와 관계 설명 중심
- **토론 시간**: 각 세션 마지막 10분은 설계 패턴 토론

## 📚 세션 구성

### [Session 1: Pod 개념과 설계 원리](./session_01.md)
- **Pod**의 **정의**와 **최소 배포 단위** 개념
- **컨테이너 그룹화** 원칙과 **사이드카 패턴**
- **Pod 라이프사이클**과 **상태 전이** 메커니즘
- **리소스 공유**와 **네트워크 모델**

### [Session 2: ReplicaSet과 Deployment](./session_02.md)
- **ReplicaSet**의 **복제본 관리** 역할
- **Deployment**의 **선언적 배포** 모델
- **롤링 업데이트**와 **배포 전략** 이론
- **버전 관리**와 **롤백** 메커니즘

### [Session 3: Service와 네트워킹](./session_03.md)
- **Service 추상화** 모델과 **타입별 특징**
- **ClusterIP, NodePort, LoadBalancer** 비교 분석
- **Endpoint**와 **서비스 디스커버리** 메커니즘
- **DNS 기반 서비스** 해결 원리

### [Session 4: ConfigMap과 Secret](./session_04.md)
- **구성 관리** 패턴과 **외부화** 원칙
- **ConfigMap**의 **설정 데이터** 관리 방식
- **Secret**의 **민감 정보** 보안 모델
- **환경별 구성** 관리 전략

### [Session 5: Volume과 PersistentVolume](./session_05.md)
- **스토리지 추상화** 모델과 **데이터 영속성**
- **Volume 타입**과 **라이프사이클** 관리
- **PersistentVolume**과 **PersistentVolumeClaim** 관계
- **StorageClass**와 **동적 프로비저닝**

### [Session 6: Namespace와 리소스 격리](./session_06.md)
- **Namespace**의 **논리적 격리** 개념
- **멀티 테넌시**와 **리소스 분할** 전략
- **RBAC**과 **네임스페이스** 기반 권한 관리
- **리소스 쿼터**와 **제한** 정책

### [Session 7: Labels과 Selectors](./session_07.md)
- **Label** 시스템과 **메타데이터** 관리
- **Selector** 패턴과 **오브젝트 연결** 메커니즘
- **Annotation**과 **추가 메타데이터** 활용
- **라벨링 전략**과 **모범 사례**

### [Session 8: 오브젝트 관계 및 설계 패턴](./session_08.md)
- **Kubernetes 오브젝트** 간 **관계** 종합 분석
- **소유권**과 **참조** 관계 이해
- **설계 패턴**과 **모범 사례** 정리
- **그룹 토론**: 오브젝트 설계 원칙

## 개념 토론 주제

### Session별 토론 주제
1. **Session 1**: "Pod가 최소 배포 단위인 이유와 설계 철학"
2. **Session 2**: "선언적 배포 모델의 장점과 실무 적용"
3. **Session 3**: "Service 추상화가 마이크로서비스에 미치는 영향"
4. **Session 4**: "구성 관리 외부화의 중요성과 보안 고려사항"
5. **Session 5**: "클라우드 환경에서 스토리지 추상화의 가치"
6. **Session 6**: "멀티 테넌시 구현을 위한 격리 전략"
7. **Session 7**: "효과적인 라벨링 전략과 운영 효율성"
8. **Session 8**: "Kubernetes 오브젝트 설계의 핵심 원칙"

## 📚 학습 자료
- **오브젝트 관계도**: Kubernetes 리소스 간 연결 구조
- **YAML 스펙 분석**: 각 오브젝트의 구조와 필드
- **설계 패턴**: 실무에서 사용되는 구성 패턴
- **비교 분석표**: 오브젝트별 특징과 사용 사례

## 🎯 학습 성과
이 날의 학습을 완료하면 다음을 할 수 있게 됩니다:
- **Kubernetes 핵심 오브젝트**의 **개념**과 **역할** 완전 이해
- **오브젝트 간 관계**와 **의존성** 파악
- **설계 패턴**과 **모범 사례** 적용 능력
- **YAML 매니페스트** 구조 이해
- Day 3 **네트워킹 이론** 학습을 위한 **오브젝트 기초** 완성

## 💡 핵심 키워드
- **Pod**: 최소 배포 단위, 컨테이너 그룹, 리소스 공유
- **Deployment**: 선언적 배포, 롤링 업데이트, 버전 관리
- **Service**: 네트워크 추상화, 로드 밸런싱, 서비스 디스커버리
- **ConfigMap/Secret**: 구성 외부화, 보안 관리, 환경 분리
- **Volume**: 데이터 영속성, 스토리지 추상화, 동적 프로비저닝

## 📝 이론 과제
다음 중 하나를 선택하여 A4 1페이지로 작성하세요:
1. Pod 설계 원리와 컨테이너 그룹화 전략 분석
2. Kubernetes 오브젝트 간 관계와 의존성 구조 분석
3. 구성 관리 외부화 패턴과 보안 모델 설계

## 다음 날 준비
내일은 **Kubernetes 네트워킹 이론**에 대해 학습합니다. 클러스터 네트워킹과 CNI, Service 타입별 특징을 이론적으로 심화 학습할 예정입니다.

## 🔗 참고 자료
- [Kubernetes Objects](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/)
- [Pod Concepts](https://kubernetes.io/docs/concepts/workloads/pods/)
- [Service Networking](https://kubernetes.io/docs/concepts/services-networking/)

---
**다음**: [Day 3 - Kubernetes 네트워킹 이론](../day_03/README.md)