# Day 3: 모니터링과 관찰 가능성

## 📍 일차 개요
Week 3의 세 번째 날로, Kubernetes 환경에서의 모니터링과 관찰 가능성(Observability) 구현을 학습합니다. Day 2에서 학습한 보안 모델을 바탕으로 시스템의 상태를 효과적으로 관찰하고 분석하는 방법을 다룹니다.

## 🎯 일차 학습 목표
- **관찰 가능성** 개념과 **메트릭, 로그, 추적** 3요소 이해
- **Prometheus** 아키텍처와 **메트릭 수집** 전략 학습
- **Grafana** 대시보드와 **시각화** 설계 원리 파악
- **로깅 아키텍처**와 **ELK 스택** 구현 방법 이해
- **분산 추적**과 **성능 모니터링** 최적화 전략 습득

## 📅 세션 구성

### [Session 1: 관찰 가능성(Observability) 개념과 원칙](./session_01.md)
- 관찰 가능성의 3요소: 메트릭, 로그, 추적
- 모니터링 vs 관찰 가능성 차이점
- SLI, SLO, SLA 정의와 측정 방법
- 관찰 가능성 성숙도 모델

### [Session 2: Prometheus 아키텍처와 메트릭 수집](./session_02.md)
- Prometheus 아키텍처와 데이터 모델
- 메트릭 타입과 수집 전략
- ServiceMonitor와 PodMonitor 설정
- PromQL 쿼리 언어와 알림 규칙

### [Session 3: Grafana 대시보드와 시각화 전략](./session_03.md)
- Grafana 아키텍처와 데이터 소스 연동
- 대시보드 설계 원칙과 시각화 패턴
- 알림 채널과 알림 관리
- 대시보드 자동화와 프로비저닝

### [Session 4: 로깅 아키텍처와 ELK 스택](./session_04.md)
- 중앙집중식 로깅 아키텍처
- Elasticsearch, Logstash, Kibana 구성
- Fluentd/Fluent Bit 로그 수집 전략
- 로그 파싱, 필터링, 인덱싱 최적화

### [Session 5: 분산 추적과 Jaeger 패턴](./session_05.md)
- 분산 추적 개념과 OpenTelemetry
- Jaeger 아키텍처와 추적 데이터 수집
- 추적 샘플링과 성능 최적화
- 마이크로서비스 성능 분석

### [Session 6: 알림과 인시던트 관리](./session_06.md)
- 알림 설계 원칙과 피로도 방지
- 인시던트 대응 프로세스
- 에스컬레이션 정책과 온콜 관리
- 사후 분석(Post-mortem) 문화

### [Session 7: 성능 모니터링과 최적화](./session_07.md)
- 애플리케이션 성능 모니터링 (APM)
- 리소스 사용률 분석과 최적화
- 용량 계획과 예측 분석
- 성능 병목 지점 식별 방법

### [Session 8: 모니터링 전략 수립과 운영 방안](./session_08.md)
- 종합적 모니터링 전략 설계
- 모니터링 도구 선택과 통합
- 운영 팀 조직과 역할 분담
- 지속적 개선과 최적화 프로세스

## 🛠 학습 방식
- **이론 70%**: 관찰 가능성 개념과 아키텍처 심화 학습
- **모니터링 패턴 30%**: 검증된 모니터링 패턴과 사례 분석

## 📊 세션별 시간 배분
```
각 세션 50분 구성:
├── 학습 목표 (5분)
├── 핵심 개념 (15분)
├── 심화 분석 (12분)
├── 모니터링 패턴 (10분)
└── 그룹 토론 (8분)
```

## 🔗 연계성
- **Day 2**: 보안 모델 → 모니터링 및 관찰 가능성
- **Day 4**: 모니터링 → Service Mesh와 마이크로서비스 통신
- **실무 연계**: 프로덕션 모니터링 요구사항 반영

## 📚 참고 자료
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [OpenTelemetry](https://opentelemetry.io/)
- [Site Reliability Engineering](https://sre.google/books/)
- [Observability Engineering](https://www.oreilly.com/library/view/observability-engineering/9781492076438/)

---
*Day 3을 통해 Kubernetes 환경에서의 관찰 가능성을 완전히 이해하고, 효과적인 모니터링 시스템을 구축할 수 있는 전문성을 기릅니다.*