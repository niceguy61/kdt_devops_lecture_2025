# Week 2 Day 3 Session 3: 모니터링 & 관측성

<div align="center">
**📊 모니터링** • **🔍 관측성**
*컨테이너 환경에서의 포괄적인 관측성 구축 방법 이해*
</div>

---

## 🕘 세션 정보
**시간**: 11:00-11:50 (50분)
**목표**: 컨테이너 환경에서의 포괄적인 관측성 구축 방법 이해
**방식**: 이론 강의 + 페어 토론

## 🎯 세션 목표
### 📚 학습 목표
- **이해 목표**: 컨테이너 환경에서의 포괄적인 관측성 구축 방법 이해
- **적용 목표**: 실무에서 사용할 수 있는 모니터링 시스템 구축 능력 습득
- **협업 목표**: 팀원들과 관측성 전략 및 알림 체계 설계 토론

## 📖 핵심 개념 (35분)

### 🔍 개념 1: 관측성의 3요소 (12분)
> **정의**: 시스템의 내부 상태를 외부에서 관찰할 수 있게 하는 메트릭, 로그, 추적의 통합

**관측성 아키텍처**:
```mermaid
graph TB
    subgraph "관측성 3요소"
        A[메트릭<br/>Metrics<br/>시계열 데이터] --> D[완전한 관측성]
        B[로그<br/>Logs<br/>이벤트 기록] --> D
        C[추적<br/>Traces<br/>요청 흐름] --> D
    end
    
    subgraph "수집 도구"
        E[Prometheus<br/>메트릭 수집] --> A
        F[Fluentd<br/>로그 수집] --> B
        G[Jaeger<br/>분산 추적] --> C
    end
    
    subgraph "분석 도구"
        H[Grafana<br/>시각화] --> D
        I[Elasticsearch<br/>로그 분석] --> D
        J[Kibana<br/>로그 시각화] --> D
    end
    
    style A fill:#e8f5e8
    style B fill:#e8f5e8
    style C fill:#e8f5e8
    style D fill:#4caf50
    style E fill:#fff3e0
    style F fill:#fff3e0
    style G fill:#fff3e0
    style H fill:#2196f3
    style I fill:#2196f3
    style J fill:#2196f3
```

**각 요소의 역할**:
- **메트릭**: 시스템 성능 지표 (CPU, 메모리, 응답시간)
- **로그**: 애플리케이션 이벤트와 오류 정보
- **추적**: 분산 시스템에서의 요청 흐름 추적

### 🔍 개념 2: 컨테이너 모니터링 스택 (12분)
> **정의**: 컨테이너 환경에 특화된 모니터링 도구들의 통합 스택

**CNCF 모니터링 스택**:
```mermaid
graph TB
    subgraph "데이터 수집 계층"
        A[cAdvisor<br/>컨테이너 메트릭] --> D[Prometheus<br/>메트릭 저장소]
        B[Node Exporter<br/>호스트 메트릭] --> D
        C[Application<br/>애플리케이션 메트릭] --> D
    end
    
    subgraph "저장 및 처리"
        D --> E[AlertManager<br/>알림 관리]
        D --> F[Grafana<br/>시각화]
    end
    
    subgraph "로그 스택"
        G[Fluent Bit<br/>로그 수집] --> H[Elasticsearch<br/>로그 저장]
        H --> I[Kibana<br/>로그 분석]
    end
    
    style A fill:#e8f5e8
    style B fill:#e8f5e8
    style C fill:#e8f5e8
    style D fill:#fff3e0
    style E fill:#4caf50
    style F fill:#4caf50
    style G fill:#f3e5f5
    style H fill:#f3e5f5
    style I fill:#f3e5f5
```

**모니터링 설정 예시**:
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']
  
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
  
  - job_name: 'app'
    static_configs:
      - targets: ['app:3000']
    metrics_path: '/metrics'
```

### 🔍 개념 3: 알림과 SLI/SLO (11분)
> **정의**: 서비스 수준 지표와 목표를 기반으로 한 효과적인 알림 체계

**SLI/SLO 프레임워크**:
```mermaid
graph TB
    subgraph "서비스 수준 관리"
        A[SLI<br/>Service Level Indicator<br/>측정 가능한 지표] --> D[서비스 품질 관리]
        B[SLO<br/>Service Level Objective<br/>목표 수준] --> D
        C[SLA<br/>Service Level Agreement<br/>계약 수준] --> D
    end
    
    subgraph "알림 전략"
        E[Error Budget<br/>오류 예산] --> F[알림 발생]
        G[Burn Rate<br/>소진 속도] --> F
    end
    
    D --> E
    F --> H[대응 조치]
    
    style A fill:#e8f5e8
    style B fill:#e8f5e8
    style C fill:#e8f5e8
    style D fill:#4caf50
    style E fill:#fff3e0
    style F fill:#ff9800
    style G fill:#fff3e0
    style H fill:#ff9800
```

**SLI/SLO 예시**:
```yaml
# SLI 정의
availability_sli: |
  sum(rate(http_requests_total{status!~"5.."}[5m])) /
  sum(rate(http_requests_total[5m]))

latency_sli: |
  histogram_quantile(0.95, 
    sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
  )

# SLO 목표
slo_targets:
  availability: 99.9%  # 99.9% 가용성
  latency_p95: 200ms   # 95% 요청이 200ms 이내
```

**알림 규칙 예시**:
```yaml
# alerting.yml
groups:
- name: slo_alerts
  rules:
  - alert: HighErrorRate
    expr: |
      (
        sum(rate(http_requests_total{status=~"5.."}[5m])) /
        sum(rate(http_requests_total[5m]))
      ) > 0.01
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "High error rate detected"
      description: "Error rate is {{ $value | humanizePercentage }}"
```

## 💭 함께 생각해보기 (15분)

### 🤝 페어 토론 (10분)
**토론 주제**:
1. **관측성 우선순위**: "메트릭, 로그, 추적 중 어떤 것부터 구축해야 할까요?"
2. **알림 피로도**: "너무 많은 알림으로 인한 피로도를 어떻게 줄일까요?"
3. **SLO 설정**: "우리 서비스에 적합한 SLO는 어떻게 설정해야 할까요?"

### 🎯 전체 공유 (5분)
- **모니터링 경험**: 효과적인 모니터링 구축 경험
- **도구 선택**: 조직 규모에 맞는 모니터링 도구 선택 기준

## 🔑 핵심 키워드
- **Observability**: 관측성
- **SLI (Service Level Indicator)**: 서비스 수준 지표
- **SLO (Service Level Objective)**: 서비스 수준 목표
- **Error Budget**: 오류 예산
- **Alerting**: 알림 시스템

## 📝 세션 마무리
### ✅ 오늘 세션 성과
- 관측성 3요소 완전 이해
- 컨테이너 모니터링 스택 구성 방법 학습
- SLI/SLO 기반 알림 체계 설계 능력 습득

### 🎯 다음 세션 준비
- **실습 챌린지**: 보안 & 최적화 통합 실습
- **연결**: 이론에서 실습으로의 자연스러운 전환

---

**다음**: [보안 & 최적화 통합 실습](../README.md#실습-챌린지)