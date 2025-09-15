# Week 3: Kubernetes 심화 이론 및 실무 패턴

## 📚 주차 소개
Week 2에서 학습한 Kubernetes 기본 개념을 바탕으로, 실무에서 필요한 심화 이론과 설계 패턴을 학습합니다. 고급 워크로드 관리, 보안, 모니터링, 운영 자동화 등 프로덕션 환경에서 필수적인 개념들을 다룹니다.

## 🎯 주차 학습 목표
- **고급 워크로드** 관리 패턴과 **스케줄링** 전략 이해
- **보안 모델**과 **정책 기반** 접근 제어 학습
- **모니터링**과 **로깅** 아키텍처 설계 원리 파악
- **운영 자동화**와 **GitOps** 패턴 이해
- **실무 적용** 시나리오와 **문제 해결** 방법론 습득

## 📅 일차별 구성

### [Day 1: 고급 워크로드 관리](./day_01/README.md)
**학습 방식**: 이론 70% + 실무 패턴 30%
- Session 1: StatefulSet과 상태 관리 패턴
- Session 2: DaemonSet과 시스템 서비스 관리
- Session 3: Job과 CronJob 배치 처리 패턴
- Session 4: HPA와 VPA 자동 스케일링 이론
- Session 5: 커스텀 리소스와 Operator 패턴
- Session 6: Pod 스케줄링과 어피니티 규칙
- Session 7: 리소스 관리와 QoS 클래스
- Session 8: 워크로드 패턴 종합 및 설계 원칙

### [Day 2: 보안 모델과 정책 관리](./day_02/README.md)
**학습 방식**: 이론 70% + 보안 패턴 30%
- Session 1: Kubernetes 보안 모델 개요
- Session 2: RBAC 심화와 권한 설계 패턴
- Session 3: Pod Security Standards와 정책
- Session 4: Network Policy와 트래픽 제어
- Session 5: Secret 관리와 암호화 전략
- Session 6: 이미지 보안과 취약점 관리
- Session 7: 감사 로깅과 컴플라이언스
- Session 8: 보안 아키텍처 설계와 모범 사례

### [Day 3: 모니터링과 관찰 가능성](./day_03/README.md)
**학습 방식**: 이론 70% + 모니터링 패턴 30%
- Session 1: 관찰 가능성(Observability) 개념과 원칙
- Session 2: Prometheus 아키텍처와 메트릭 수집
- Session 3: Grafana 대시보드와 시각화 전략
- Session 4: 로깅 아키텍처와 ELK 스택
- Session 5: 분산 추적과 Jaeger 패턴
- Session 6: 알림과 인시던트 관리
- Session 7: 성능 모니터링과 최적화
- Session 8: 모니터링 전략 수립과 운영 방안

### [Day 4: Service Mesh와 마이크로서비스 통신](./day_04/README.md)
**학습 방식**: 이론 70% + Service Mesh 패턴 30%
- Session 1: Service Mesh 개념과 아키텍처
- Session 2: Istio 구조와 핵심 컴포넌트
- Session 3: 트래픽 관리와 라우팅 전략
- Session 4: 보안 정책과 mTLS 구현
- Session 5: 관찰 가능성과 분산 추적
- Session 6: 카나리 배포와 A/B 테스트
- Session 7: 서비스 메시 운영과 문제 해결
- Session 8: Service Mesh 도입 전략과 모범 사례

### [Day 5: 운영 자동화와 실무 적용](./day_05/README.md)
**학습 방식**: 이론 60% + 실무 사례 40%
- Session 1: GitOps 개념과 ArgoCD 아키텍처
- Session 2: Helm과 Kustomize 패키지 관리
- Session 3: CI/CD 파이프라인 통합 전략
- Session 4: 클러스터 운영과 유지보수
- Session 5: 성능 튜닝과 비용 최적화
- Session 6: 트러블슈팅과 문제 해결
- Session 7: 멀티 클러스터와 하이브리드 클라우드
- Session 8: Kubernetes 실무 종합과 미래 전망

## 🛠 학습 환경
- **이론 중심**: 개념과 원리에 대한 깊이 있는 이해
- **실무 패턴**: 검증된 설계 패턴과 모범 사례
- **사례 연구**: 실제 프로덕션 환경 사례 분석
- **문제 해결**: 일반적인 문제와 해결 방법론

## 📊 이론-실무 비율
```
Day 1: ██████████████ 70% 이론 + ████████ 30% 패턴
Day 2: ██████████████ 70% 이론 + ████████ 30% 패턴  
Day 3: ██████████████ 70% 이론 + ████████ 30% 패턴
Day 4: ██████████████ 70% 이론 + ████████ 30% 패턴
Day 5: ████████████ 60% 이론 + ██████████ 40% 사례
```

## 📋 평가 방법
- **이론 과제**: 개념 이해도 평가 (40%)
- **설계 과제**: 아키텍처 설계 능력 평가 (30%)
- **사례 분석**: 문제 해결 능력 평가 (30%)

## 🎓 수료 조건
- 출석률 80% 이상
- 모든 이론 과제 완료
- 최종 설계 과제 제출 및 발표

## 📚 참고 자료
- [Kubernetes Production Best Practices](https://kubernetes.io/docs/setup/best-practices/)
- [CNCF Landscape](https://landscape.cncf.io/)
- [Kubernetes Patterns Book](https://k8spatterns.io/)
- [Production Kubernetes](https://www.oreilly.com/library/view/production-kubernetes/9781492092292/)

## 🔄 Week 2와의 연계성
- **Week 2**: 기본 개념과 오브젝트 이해
- **Week 3**: 심화 이론과 실무 패턴 적용
- **연결점**: 기본 개념 → 고급 패턴 → 실무 적용

---
*본 주차는 Kubernetes의 심화 개념과 실무 패턴을 통해 프로덕션 환경에서 안정적이고 효율적인 시스템을 구축할 수 있는 전문성을 기르는 것을 목표로 합니다.*