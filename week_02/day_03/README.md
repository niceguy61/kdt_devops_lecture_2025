# Week 2 Day 3: Kubernetes 네트워킹 이론 (이론 중심)

## 📅 일정 개요
- **날짜**: Week 2, Day 3
- **주제**: Kubernetes 네트워킹 모델과 통신 메커니즘
- **총 세션**: 8개 (각 50분)
- **학습 방식**: 이론 80% + 개념 예시 20%

## 🎯 학습 목표
- **클러스터 네트워킹** 모델과 **CNI** 개념 완전 이해
- **Service 타입별** 네트워킹 메커니즘 심화 분석
- **Ingress**와 **로드 밸런싱** 아키텍처 학습
- **DNS**와 **서비스 디스커버리** 원리 파악
- **네트워크 정책**과 **보안** 모델 이해

## Day 3 특징 (KT Cloud 모델)
- **내용 비중**: 이론 80% + 개념 예시 20%
- **학습 방식**: 네트워킹 모델 분석 + 아키텍처 이해 + 통신 메커니즘 + 토론
- **시각 자료**: 네트워크 다이어그램과 패킷 플로우 분석
- **실습 제한**: 복잡한 네트워크 설정 지양, 개념과 구조 설명 중심
- **토론 시간**: 각 세션 마지막 10분은 네트워킹 설계 토론

## 📚 세션 구성

### [Session 1: 클러스터 네트워킹 모델](./session_01.md)
- **Kubernetes 네트워킹** 기본 원칙과 **요구사항**
- **Flat 네트워크** 모델과 **Pod-to-Pod** 통신
- **Node 네트워킹**과 **클러스터 네트워크** 구조
- **IP 주소 할당**과 **라우팅** 메커니즘

### [Session 2: CNI (Container Network Interface)](./session_02.md)
- **CNI 표준**과 **플러그인** 아키텍처
- **주요 CNI 구현체** 비교 분석 (Flannel, Calico, Weave)
- **네트워크 정책** 지원과 **성능** 특성
- **CNI 선택** 기준과 **운영** 고려사항

### [Session 3: Service 네트워킹 심화](./session_03.md)
- **ClusterIP** 내부 로드 밸런싱 메커니즘
- **NodePort**와 **외부 접근** 패턴
- **LoadBalancer**와 **클라우드 통합**
- **ExternalName**과 **외부 서비스** 연결

### [Session 4: kube-proxy와 로드 밸런싱](./session_04.md)
- **kube-proxy** 역할과 **구현 모드**
- **iptables vs IPVS** 모드 비교
- **세션 어피니티**와 **로드 밸런싱** 알고리즘
- **Endpoint**와 **EndpointSlice** 관리

### [Session 5: Ingress 아키텍처](./session_05.md)
- **Ingress 컨트롤러** 개념과 **구현체** 비교
- **HTTP/HTTPS** 라우팅과 **TLS 종료**
- **Path 기반**과 **Host 기반** 라우팅
- **Ingress 클래스**와 **다중 컨트롤러** 관리

### [Session 6: DNS와 서비스 디스커버리](./session_06.md)
- **CoreDNS** 아키텍처와 **DNS 해결** 과정
- **Service DNS** 레코드와 **네이밍** 규칙
- **Pod DNS** 정책과 **사용자 정의** 설정
- **외부 DNS** 통합과 **서비스 메시** 연동

### [Session 7: 네트워크 정책과 보안](./session_07.md)
- **NetworkPolicy** 개념과 **트래픽 제어**
- **Ingress/Egress** 규칙과 **선택자** 패턴
- **네임스페이스** 기반 격리와 **마이크로세그멘테이션**
- **보안 모델**과 **제로 트러스트** 네트워킹

### [Session 8: 네트워킹 설계 패턴](./session_08.md)
- **멀티 클러스터** 네트워킹과 **서비스 메시**
- **하이브리드 클라우드** 네트워킹 패턴
- **성능 최적화**와 **트러블슈팅** 방법론
- **그룹 토론**: 네트워킹 아키텍처 설계 원칙

## 개념 토론 주제

### Session별 토론 주제
1. **Session 1**: "Flat 네트워크 모델의 장단점과 실무 적용"
2. **Session 2**: "CNI 선택 기준과 운영 환경별 고려사항"
3. **Session 3**: "Service 타입별 사용 시나리오와 설계 전략"
4. **Session 4**: "kube-proxy 모드 선택과 성능 최적화"
5. **Session 5**: "Ingress 컨트롤러 선택과 고가용성 설계"
6. **Session 6**: "DNS 기반 서비스 디스커버리의 한계와 대안"
7. **Session 7**: "네트워크 보안 정책 설계와 제로 트러스트"
8. **Session 8**: "대규모 환경에서의 네트워킹 아키텍처 설계"

## 📚 학습 자료
- **네트워크 다이어그램**: 클러스터 네트워킹 구조도
- **패킷 플로우**: 통신 경로와 처리 과정
- **CNI 비교표**: 구현체별 특징과 성능
- **설계 패턴**: 실무 네트워킹 아키텍처 사례

## 🎯 학습 성과
이 날의 학습을 완료하면 다음을 할 수 있게 됩니다:
- **Kubernetes 네트워킹** 모델과 **통신 메커니즘** 완전 이해
- **CNI 구현체** 특징과 **선택 기준** 파악
- **Service와 Ingress** 아키텍처 설계 능력
- **네트워크 보안** 정책 설계 역량
- Day 4 **스토리지 이론** 학습을 위한 **네트워킹 기초** 완성

## 💡 핵심 키워드
- **Flat Network**: Pod 간 직접 통신, IP 할당
- **CNI**: 네트워크 인터페이스 표준, 플러그인 아키텍처
- **Service**: 네트워크 추상화, 로드 밸런싱
- **Ingress**: HTTP 라우팅, TLS 종료
- **NetworkPolicy**: 트래픽 제어, 마이크로세그멘테이션

## 📝 이론 과제
다음 중 하나를 선택하여 A4 1페이지로 작성하세요:
1. Kubernetes 네트워킹 모델과 CNI 아키텍처 분석
2. Service 타입별 네트워킹 메커니즘과 사용 사례 비교
3. 네트워크 보안 정책 설계와 제로 트러스트 구현 방안

## 다음 날 준비
내일은 **Kubernetes 스토리지 이론**에 대해 학습합니다. 영구 볼륨과 스토리지 클래스, 데이터 관리 패턴을 이론적으로 심화 학습할 예정입니다.

## 🔗 참고 자료
- [Cluster Networking](https://kubernetes.io/docs/concepts/cluster-administration/networking/)
- [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [CNI Specification](https://github.com/containernetworking/cni)

---
**다음**: [Day 4 - Kubernetes 스토리지 이론](../day_04/README.md)