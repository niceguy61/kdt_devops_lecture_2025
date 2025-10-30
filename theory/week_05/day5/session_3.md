# Week 5 Day 5 Session 3: 모니터링 & 로깅 (11:00-11:50)

<div align="center">

**📊 CloudWatch** • **📝 로그 분석** • **🔍 분산 추적** • **🚨 알람 설정**

*프로덕션 환경의 완전한 관측성 구축*

</div>

---

## 🕘 세션 정보
**시간**: 11:00-11:50 (50분)
**목표**: CloudMart 운영을 위한 종합 모니터링 및 로깅 시스템 구축
**방식**: 이론 설명 + 실무 사례

## 🎯 세션 목표

### 📚 학습 목표
- **이해 목표**: CloudWatch 메트릭, 로그, 알람의 역할과 중요성 이해
- **적용 목표**: 실무 모니터링 대시보드 구성 및 알람 설정 방법 습득
- **협업 목표**: 팀과 함께 장애 대응 프로세스 수립

### 🤔 왜 필요한가? (5분)

**현실 문제 상황**:
- 💼 **실무 시나리오**: "새벽 3시에 서버가 죽었는데 아무도 몰랐어요. 어떻게 해야 하나요?"
- 🏠 **일상 비유**: 자동차 계기판 (속도, 연료, 엔진 온도) → 문제 발생 전 미리 알림
- ☁️ **AWS 아키텍처**: CloudWatch로 모든 리소스 실시간 모니터링 + 알람
- 📊 **시장 동향**: Netflix는 초당 수백만 개의 메트릭 수집 및 분석

**모니터링 없음 vs 있음 비교**:
```mermaid
graph TB
    subgraph "모니터링 없음 (위험)"
        A1[서버 장애 발생] --> B1[사용자 불만 접수]
        B1 --> C1[개발자 확인]
        C1 --> D1[원인 파악 어려움]
        D1 --> E1[복구 지연<br/>수시간 소요]
    end
    
    subgraph "모니터링 있음 (안전)"
        A2[서버 부하 증가] --> B2[CloudWatch 알람]
        B2 --> C2[즉시 개발자 알림]
        C2 --> D2[로그로 원인 파악]
        D2 --> E2[신속 대응<br/>수분 내 복구]
    end
    
    style A1 fill:#ffebee
    style E1 fill:#ffebee
    style A2 fill:#fff3e0
    style B2 fill:#e8f5e8
    style E2 fill:#e8f5e8
```

## 📖 핵심 개념 (35분)

### 🔄 Docker Compose vs AWS 모니터링 비교

**Docker Compose 멀티 서버 + 모니터링 스택 🔍**:
```mermaid
graph TB
    subgraph "모니터링 서버 (별도)"
        GRAFANA[Grafana<br/>대시보드<br/>3000포트]
        PROMETHEUS[Prometheus<br/>메트릭 수집<br/>9090포트]
        LOKI[Loki<br/>로그 수집<br/>3100포트]
        JAEGER[Jaeger<br/>분산 추적<br/>16686포트]
        ALERTMANAGER[AlertManager<br/>알림<br/>9093포트]
    end
    
    subgraph "서버 1 (AZ-A)"
        NODE_EXP1[Node Exporter<br/>시스템 메트릭]
        CADVISOR1[cAdvisor<br/>컨테이너 메트릭]
        PROMTAIL1[Promtail<br/>로그 수집]
        JAEGER_AGENT1[Jaeger Agent<br/>트레이스 수집]
        APP1[애플리케이션<br/>컨테이너들]
    end
    
    subgraph "서버 2 (AZ-B)"
        NODE_EXP2[Node Exporter<br/>시스템 메트릭]
        CADVISOR2[cAdvisor<br/>컨테이너 메트릭]
        PROMTAIL2[Promtail<br/>로그 수집]
        JAEGER_AGENT2[Jaeger Agent<br/>트레이스 수집]
        APP2[애플리케이션<br/>컨테이너들]
    end
    
    subgraph "AWS S3"
        S3_METRICS[S3 Bucket<br/>메트릭 백업]
        S3_LOGS[S3 Bucket<br/>로그 백업]
        S3_TRACES[S3 Bucket<br/>트레이스 백업]
    end
    
    NODE_EXP1 --> PROMETHEUS
    NODE_EXP2 --> PROMETHEUS
    CADVISOR1 --> PROMETHEUS
    CADVISOR2 --> PROMETHEUS
    
    PROMTAIL1 --> LOKI
    PROMTAIL2 --> LOKI
    
    APP1 --> JAEGER_AGENT1
    APP2 --> JAEGER_AGENT2
    JAEGER_AGENT1 --> JAEGER
    JAEGER_AGENT2 --> JAEGER
    
    PROMETHEUS --> GRAFANA
    LOKI --> GRAFANA
    JAEGER --> GRAFANA
    PROMETHEUS --> ALERTMANAGER
    
    PROMETHEUS -.백업.-> S3_METRICS
    LOKI -.백업.-> S3_LOGS
    JAEGER -.백업.-> S3_TRACES
    
    ALERTMANAGER -.알림.-> SLACK[Slack/Email]
    
    style GRAFANA fill:#ff9800
    style PROMETHEUS fill:#e8f5e8
    style LOKI fill:#e3f2fd
    style JAEGER fill:#9c27b0
    style ALERTMANAGER fill:#ffebee
    style S3_METRICS fill:#fce4ec
    style S3_LOGS fill:#fce4ec
    style S3_TRACES fill:#fce4ec
```

**Docker Compose 모니터링 스택 구성**:
- ✅ **Prometheus**: 메트릭 수집 (CPU, 메모리, 디스크, 네트워크)
- ✅ **Grafana**: 시각화 대시보드
- ✅ **Loki**: 로그 수집 및 검색
- ✅ **Jaeger**: 분산 추적 (마이크로서비스 간 호출 추적) 🆕
- ✅ **AlertManager**: Slack/Email 알림
- ✅ **Node Exporter**: 시스템 메트릭
- ✅ **cAdvisor**: 컨테이너 메트릭
- ✅ **Promtail**: 로그 수집 에이전트
- ✅ **Jaeger Agent**: 트레이스 수집 에이전트 🆕
- ✅ **S3 백업**: 30일 보관

**Jaeger 분산 추적 예시**:
```mermaid
sequenceDiagram
    participant User as 사용자
    participant Frontend as Frontend
    participant Backend as Backend API
    participant Auth as Auth Service
    participant DB as PostgreSQL
    participant Cache as Redis
    
    User->>Frontend: 1. 상품 조회 요청
    Note over Frontend: Trace ID: abc123<br/>Span ID: span-1
    
    Frontend->>Backend: 2. API 호출
    Note over Backend: Trace ID: abc123<br/>Span ID: span-2<br/>Parent: span-1
    
    Backend->>Auth: 3. 인증 확인
    Note over Auth: Trace ID: abc123<br/>Span ID: span-3<br/>Parent: span-2
    Auth-->>Backend: 4. 인증 성공 (15ms)
    
    Backend->>Cache: 5. 캐시 조회
    Note over Cache: Trace ID: abc123<br/>Span ID: span-4<br/>Parent: span-2
    Cache-->>Backend: 6. 캐시 미스 (5ms)
    
    Backend->>DB: 7. DB 조회
    Note over DB: Trace ID: abc123<br/>Span ID: span-5<br/>Parent: span-2
    DB-->>Backend: 8. 데이터 반환 (120ms)
    
    Backend->>Cache: 9. 캐시 저장
    Cache-->>Backend: 10. 저장 완료 (3ms)
    
    Backend-->>Frontend: 11. 응답 (143ms)
    Frontend-->>User: 12. 화면 표시 (150ms)
    
    Note over User,Cache: 전체 요청: 150ms<br/>가장 느린 구간: DB 조회 (120ms)
```

**모니터링 서버 - docker-compose.yml (Jaeger 추가)**:
```yaml
version: '3.8'
services:
  # 기존 서비스들...
  
  # Jaeger All-in-One (개발/테스트용)
  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "5775:5775/udp"   # Zipkin compact
      - "6831:6831/udp"   # Jaeger compact
      - "6832:6832/udp"   # Jaeger binary
      - "5778:5778"       # Config
      - "16686:16686"     # UI
      - "14268:14268"     # Collector HTTP
      - "14250:14250"     # Collector gRPC
      - "9411:9411"       # Zipkin compatible
    environment:
      - COLLECTOR_ZIPKIN_HOST_PORT=:9411
      - SPAN_STORAGE_TYPE=badger
      - BADGER_EPHEMERAL=false
      - BADGER_DIRECTORY_VALUE=/badger/data
      - BADGER_DIRECTORY_KEY=/badger/key
    volumes:
      - jaeger_data:/badger
    networks:
      - monitoring

  # Grafana에 Jaeger 데이터소스 추가
  grafana:
    image: grafana/grafana:latest
    environment:
      - GF_INSTALL_PLUGINS=grafana-jaeger-datasource
    # ... 기존 설정 ...

volumes:
  jaeger_data:
```

**서버 1/2 - Jaeger Agent 추가**:
```yaml
version: '3.8'
services:
  # 기존 애플리케이션 서비스들...
  
  # Jaeger Agent (각 서버에 배치)
  jaeger-agent:
    image: jaegertracing/jaeger-agent:latest
    ports:
      - "5775:5775/udp"
      - "6831:6831/udp"
      - "6832:6832/udp"
      - "5778:5778"
    environment:
      - REPORTER_GRPC_HOST_PORT=192.168.1.100:14250  # 모니터링 서버 IP
    networks:
      - monitoring
```

**애플리케이션에 Jaeger 연동 (Node.js 예시)**:
```javascript
// backend/src/tracing.js
const { initTracer } = require('jaeger-client');

function initJaeger(serviceName) {
  const config = {
    serviceName: serviceName,
    sampler: {
      type: 'const',
      param: 1, // 모든 요청 추적 (프로덕션에서는 0.1 등으로 조정)
    },
    reporter: {
      logSpans: true,
      agentHost: process.env.JAEGER_AGENT_HOST || 'jaeger-agent',
      agentPort: 6832,
    },
  };
  
  const options = {
    logger: {
      info: msg => console.log('INFO', msg),
      error: msg => console.log('ERROR', msg),
    },
  };
  
  return initTracer(config, options);
}

module.exports = initJaeger;
```

```javascript
// backend/src/app.js
const express = require('express');
const initJaeger = require('./tracing');
const opentracing = require('opentracing');

const tracer = initJaeger('cloudmart-backend');
opentracing.initGlobalTracer(tracer);

const app = express();

// 미들웨어: 모든 요청에 트레이스 추가
app.use((req, res, next) => {
  const span = tracer.startSpan(`${req.method} ${req.path}`);
  req.span = span;
  
  res.on('finish', () => {
    span.setTag('http.status_code', res.statusCode);
    span.finish();
  });
  
  next();
});

// API 엔드포인트
app.get('/api/products', async (req, res) => {
  const parentSpan = req.span;
  
  // DB 조회 트레이스
  const dbSpan = tracer.startSpan('db_query', { childOf: parentSpan });
  const products = await db.query('SELECT * FROM products');
  dbSpan.finish();
  
  // 캐시 저장 트레이스
  const cacheSpan = tracer.startSpan('cache_set', { childOf: parentSpan });
  await redis.set('products', JSON.stringify(products));
  cacheSpan.finish();
  
  res.json(products);
});
```

**💡 Docker vs AWS 모니터링 비교 (Jaeger 포함)**:
| 항목 | Docker 모니터링 스택 | AWS CloudWatch + X-Ray |
|------|---------------------|------------------------|
| **메트릭 수집** | Prometheus (수동 설정) | CloudWatch (자동) |
| **로그 수집** | Loki + Promtail (수동) | CloudWatch Logs (자동) |
| **분산 추적** | Jaeger (수동 설정) 🆕 | X-Ray (자동) |
| **대시보드** | Grafana (직접 구축) | CloudWatch Dashboard |
| **알림** | AlertManager (수동) | CloudWatch Alarms |
| **백업** | S3 Sync 스크립트 | 자동 보관 |
| **설정 복잡도** | 매우 높음 | 낮음 (자동) |
| **비용** | 서버 + 스토리지 | 메트릭/로그/트레이스당 |
| **커스터마이징** | 완전한 제어 | 제한적 |
| **관리 부담** | 매우 높음 | 낮음 (관리형) |

**🎯 Jaeger의 장점**:
- ✅ **마이크로서비스 추적**: Frontend → Backend → Auth → DB 전체 흐름 시각화
- ✅ **성능 병목 발견**: 어느 구간이 느린지 정확히 파악 (DB 조회 120ms)
- ✅ **에러 추적**: 어느 서비스에서 에러가 발생했는지 즉시 확인
- ✅ **의존성 분석**: 서비스 간 호출 관계 시각화
- ✅ **Grafana 통합**: Grafana에서 메트릭 + 로그 + 트레이스 통합 조회

**🎯 핵심 인사이트**:
> "Docker Compose로 Prometheus + Grafana + Loki + **Jaeger** 모니터링 스택을 구축할 수 있지만, 설정/관리/유지보수의 복잡도가 매우 높습니다. AWS CloudWatch + **X-Ray**는 이 모든 것을 자동으로 제공하며, 추가 설정 없이 즉시 사용 가능합니다. **관리형 서비스의 진정한 가치는 복잡도 제거입니다!**"

---

### 🔍 개념 1: CloudWatch 메트릭 & 알람 (12분)

> **정의**: AWS 리소스의 성능 지표를 수집하고 임계값 초과 시 알림을 보내는 서비스

**CloudWatch 메트릭 계층 구조**:
```mermaid
graph TB
    subgraph "CloudWatch 메트릭"
        A[Namespace<br/>AWS/EC2, AWS/RDS]
        A --> B1[Metric Name<br/>CPUUtilization]
        A --> B2[Metric Name<br/>NetworkIn]
        A --> B3[Metric Name<br/>DiskReadOps]
        
        B1 --> C1[Dimensions<br/>InstanceId=i-xxx]
        B2 --> C2[Dimensions<br/>InstanceId=i-yyy]
        
        C1 --> D1[Datapoints<br/>시간별 값]
        C2 --> D2[Datapoints<br/>시간별 값]
    end
    
    style A fill:#4caf50
    style B1 fill:#e8f5e8
    style B2 fill:#e8f5e8
    style B3 fill:#e8f5e8
```

**CloudMart 핵심 메트릭**:
```yaml
EC2 메트릭:
  - CPUUtilization: CPU 사용률 (%)
  - NetworkIn/Out: 네트워크 트래픽 (Bytes)
  - StatusCheckFailed: 상태 체크 실패 횟수
  
RDS 메트릭:
  - CPUUtilization: CPU 사용률
  - DatabaseConnections: 활성 연결 수
  - FreeStorageSpace: 남은 저장 공간
  - ReadLatency/WriteLatency: 읽기/쓰기 지연 시간
  
ALB 메트릭:
  - RequestCount: 요청 수
  - TargetResponseTime: 응답 시간
  - HealthyHostCount: 정상 호스트 수
  - UnHealthyHostCount: 비정상 호스트 수
  
ElastiCache 메트릭:
  - CPUUtilization: CPU 사용률
  - CacheHits/CacheMisses: 캐시 히트/미스
  - NetworkBytesIn/Out: 네트워크 트래픽
```

**알람 설정 예시**:
```yaml
# 1. EC2 CPU 과부하 알람
Alarm Name: CloudMart-EC2-HighCPU
Metric: CPUUtilization
Threshold: > 80% for 2 consecutive periods (10분)
Action: SNS 알림 → 개발자 이메일/SMS

# 2. RDS 연결 수 초과 알람
Alarm Name: CloudMart-RDS-HighConnections
Metric: DatabaseConnections
Threshold: > 80 connections
Action: SNS 알림 + Auto Scaling 트리거

# 3. ALB 응답 시간 지연 알람
Alarm Name: CloudMart-ALB-SlowResponse
Metric: TargetResponseTime
Threshold: > 1 second for 3 consecutive periods
Action: SNS 알림 + Lambda 자동 복구

# 4. ElastiCache 메모리 부족 알람
Alarm Name: CloudMart-Redis-LowMemory
Metric: DatabaseMemoryUsagePercentage
Threshold: > 90%
Action: SNS 알림 + 캐시 플러시
```

### 🔍 개념 2: CloudWatch Logs 중앙화 (12분)

> **정의**: 모든 애플리케이션 및 시스템 로그를 중앙에서 수집, 저장, 분석하는 서비스

**로그 수집 아키텍처**:
```mermaid
graph TB
    subgraph "로그 소스"
        A1[EC2 Backend<br/>애플리케이션 로그]
        A2[ALB<br/>액세스 로그]
        A3[RDS<br/>슬로우 쿼리 로그]
        A4[Lambda<br/>함수 로그]
    end
    
    subgraph "CloudWatch Logs"
        B[Log Groups]
        B --> C1[`/aws/ec2/cloudmart-backend`]
        B --> C2[`/aws/alb/cloudmart-alb`]
        B --> C3[`/aws/rds/cloudmart-db`]
        B --> C4[`/aws/lambda/cloudmart-functions`]
    end
    
    subgraph "로그 분석"
        D[CloudWatch Insights<br/>쿼리 및 분석]
        E[CloudWatch Alarms<br/>로그 기반 알람]
        F[S3 Export<br/>장기 보관]
    end
    
    A1 --> C1
    A2 --> C2
    A3 --> C3
    A4 --> C4
    
    C1 --> D
    C2 --> D
    C3 --> D
    C4 --> D
    
    D --> E
    D --> F
    
    style B fill:#4caf50
    style D fill:#e8f5e8
```

**CloudMart 로그 구성**:
```yaml
Log Groups:
  /aws/ec2/cloudmart-backend:
    Retention: 7 days
    Logs:
      - Application logs (console.log)
      - Error logs (console.error)
      - Access logs (HTTP requests)
    
  /aws/alb/cloudmart-alb:
    Retention: 30 days
    Logs:
      - Request/Response logs
      - Client IP, User-Agent
      - Response time, Status code
    
  /aws/rds/cloudmart-db:
    Retention: 7 days
    Logs:
      - Slow query logs (> 1 second)
      - Error logs
      - General logs (선택적)
```

**CloudWatch Logs Insights 쿼리 예시**:
```sql
-- 1. 최근 1시간 에러 로그 검색
fields @timestamp, @message
| filter @message like /ERROR/
| sort @timestamp desc
| limit 100

-- 2. API 응답 시간 분석
fields @timestamp, request_time
| filter request_time > 1000
| stats avg(request_time), max(request_time), count() by bin(5m)

-- 3. 특정 사용자 활동 추적
fields @timestamp, user_id, action
| filter user_id = "user123"
| sort @timestamp desc

-- 4. 에러율 계산
fields @timestamp
| stats count(*) as total,
        sum(status_code >= 500) as errors
        by bin(5m)
| fields errors / total * 100 as error_rate
```

**로그 기반 알람**:
```yaml
# 에러 로그 급증 알람
Metric Filter:
  Pattern: [ERROR]
  Metric Name: ErrorCount
  Alarm:
    Threshold: > 10 errors in 5 minutes
    Action: SNS 알림

# 슬로우 쿼리 알람
Metric Filter:
  Pattern: { $.query_time > 1 }
  Metric Name: SlowQueryCount
  Alarm:
    Threshold: > 5 slow queries in 10 minutes
    Action: SNS 알림 + DBA 호출
```

### 🔍 개념 3: AWS X-Ray 분산 추적 (11분)

> **정의**: 마이크로서비스 간 요청 흐름을 추적하고 병목 지점을 찾는 서비스

**X-Ray 추적 흐름**:
```mermaid
sequenceDiagram
    participant User as 사용자
    participant CF as CloudFront
    participant ALB as ALB
    participant Backend as Backend API
    participant RDS as RDS
    participant Redis as ElastiCache
    
    User->>CF: 1. 상품 조회 요청
    Note over CF: Trace ID 생성
    CF->>ALB: 2. 요청 전달 (Trace ID)
    ALB->>Backend: 3. 라우팅 (Trace ID)
    
    Backend->>Redis: 4. 캐시 확인 (50ms)
    Redis-->>Backend: 5. 캐시 미스
    
    Backend->>RDS: 6. DB 쿼리 (200ms)
    RDS-->>Backend: 7. 데이터 반환
    
    Backend->>Redis: 8. 캐시 저장 (10ms)
    Backend-->>ALB: 9. 응답 (260ms)
    ALB-->>CF: 10. 응답 전달
    CF-->>User: 11. 최종 응답 (280ms)
    
    Note over User,Redis: X-Ray가 전체 흐름 추적<br/>병목: RDS 쿼리 (200ms)
```

**X-Ray 세그먼트 구조**:
```json
{
  "trace_id": "1-5f8a1234-abcd1234efgh5678ijkl",
  "id": "abcd1234",
  "name": "CloudMart-Backend",
  "start_time": 1602789600.0,
  "end_time": 1602789600.28,
  "subsegments": [
    {
      "name": "Redis-Cache-Check",
      "start_time": 1602789600.05,
      "end_time": 1602789600.10,
      "namespace": "remote"
    },
    {
      "name": "RDS-Query",
      "start_time": 1602789600.10,
      "end_time": 1602789600.30,
      "namespace": "remote",
      "sql": {
        "query": "SELECT * FROM products WHERE id = $1"
      }
    }
  ]
}
```

**X-Ray 활용 사례**:
- **성능 병목 발견**: 어느 구간이 느린지 시각적으로 확인
- **에러 추적**: 에러가 발생한 정확한 위치 파악
- **의존성 맵**: 서비스 간 호출 관계 시각화
- **SLA 모니터링**: 응답 시간 목표 달성 여부 확인

## 💭 함께 생각해보기 (10분)

### 🤝 페어 토론 (5분)

**토론 주제**:
1. **알람 임계값**: "CPU 80%에서 알람을 보내는 게 적절할까요? 더 낮춰야 할까요?"
2. **로그 보관 기간**: "로그를 얼마나 오래 보관해야 할까요? 비용은?"
3. **분산 추적**: "X-Ray 없이도 문제를 찾을 수 있을까요?"

**페어 활동 가이드**:
- 👥 **자유 페어링**: 운영 경험이 있는 사람끼리
- 🔄 **역할 교대**: 3분씩 설명자/질문자 역할 바꾸기
- 📝 **핵심 정리**: 모니터링 체크리스트 작성

### 🎯 전체 공유 (5분)

**인사이트 공유**:
- 페어 토론에서 나온 모니터링 전략
- 실무에서 겪은 장애 대응 경험
- 효과적인 알람 설정 방법

**💡 이해도 체크 질문**:
- ✅ "CloudWatch 메트릭과 로그의 차이는 무엇인가요?"
- ✅ "로그 기반 알람은 언제 유용한가요?"
- ✅ "X-Ray로 어떤 문제를 해결할 수 있나요?"

## 🔑 핵심 키워드

### 🆕 새로운 용어
- **Observability (관측성)**: 시스템 내부 상태를 외부에서 파악할 수 있는 능력
- **Metric (메트릭)**: 시스템 성능을 나타내는 수치 데이터
- **Trace (추적)**: 요청이 시스템을 통과하는 전체 경로

### 🔧 중요 개념
- **Log Aggregation**: 여러 소스의 로그를 중앙에서 수집
- **Metric Filter**: 로그에서 특정 패턴을 찾아 메트릭으로 변환
- **Service Map**: 서비스 간 의존성을 시각화한 맵

### 💼 실무 용어
- **SLI (Service Level Indicator)**: 서비스 수준 지표 (응답 시간, 가용성 등)
- **SLO (Service Level Objective)**: 서비스 수준 목표 (99.9% 가용성)
- **SLA (Service Level Agreement)**: 서비스 수준 계약 (고객과의 약속)

## 📝 세션 마무리

### ✅ 오늘 세션 성과
- **메트릭 이해**: CloudWatch 메트릭 및 알람 설정 방법 습득
- **로그 분석**: 중앙화된 로그 시스템 구축 및 쿼리 방법 학습
- **분산 추적**: X-Ray를 통한 성능 병목 발견 방법 이해

### 🎯 다음 세션 준비
- **Session 4 주제**: 보안 & 백업 (IAM, 백업 전략)
- **연결 내용**: 모니터링으로 발견한 문제를 보안과 백업으로 예방
- **사전 생각**: "데이터가 손실되면 어떻게 복구할까요?"

### 🔗 실습 연계
- **Lab 1**: CloudWatch 대시보드 구성 및 알람 설정
- **Challenge**: 완전한 모니터링 시스템 구축

---

<div align="center">

**📊 모니터링 완료** • **📝 로그 분석 준비** • **🔍 관측성 확보**

*다음 세션에서는 보안과 백업 전략을 수립해보겠습니다!*

</div>
