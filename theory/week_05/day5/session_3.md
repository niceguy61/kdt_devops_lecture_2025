# Week 5 Day 5 Session 3: Docker Compose 완전체 - 관측성까지

<div align="center">

**🔍 완전한 관측성** • **🛠️ 직접 구축** • **💡 Pain Point 경험**

*처음부터 좋은 걸 쓰면 왜 좋은지 모른다. Docker Compose로 직접 구축해봐야 AWS의 진짜 가치를 안다.*

</div>

---

## 🕘 Session 정보
**시간**: 11:00-11:50 (50분)
**목표**: Docker Compose로 완전한 관측성 스택 구축 및 Pain Point 경험
**방식**: 실습 중심 + 문제 경험 + AWS 전환 시점 판단

## 🎯 Session 목표

### 📚 학습 목표
- **이해 목표**: 관측성 3대 요소 (Metrics, Logs, Traces) 완전 이해
- **구축 목표**: Docker Compose로 Prometheus + Grafana + Jaeger + APM 스택 구축
- **경험 목표**: 직접 구축하며 운영의 복잡함과 AWS Managed Service 필요성 체감

### 🤔 왜 필요한가? (5분)

**현실 문제 상황**:
- 💼 **실무 시나리오**: "신입이 처음부터 Kubernetes + CloudWatch 쓰자고 하는데, 왜 필요한지 설명 못함"
- 🏠 **일상 비유**: 요리를 배울 때 처음부터 고급 주방기구를 쓰면 기본기를 모르게 되는 것처럼
- 🎯 **학습 철학**: "Pain First, Solution Second" - 문제를 먼저 경험해야 해결책의 가치를 안다
- 📊 **실무 현실**: 많은 개발자가 Managed Service를 쓰면서도 왜 비싼지, 뭐가 좋은지 모름

**학습 전후 비교**:
```mermaid
graph LR
    A[학습 전<br/>AWS가 좋다고 하니까<br/>무작정 사용] --> B[학습 후<br/>직접 구축해봤으니<br/>AWS 가치 정확히 인식]
    
    style A fill:#ffebee
    style B fill:#e8f5e8
```

---

## 📖 핵심 개념 (35분)

### 🔍 개념 1: "왜 처음부터 좋은 걸 쓰면 안 되는가?" (10분)

> **정의**: 기술 학습에서 "Pain First" 원칙 - 문제를 먼저 경험해야 해결책의 진짜 가치를 이해할 수 있다

**실제 대화 사례**:
```
신입 개발자: "처음부터 Kubernetes + CloudWatch 쓰면 되잖아요?"
시니어: "그럼 왜 그게 필요한지 알아?"
신입: "...더 좋으니까요?"
시니어: "뭐가 어떻게 좋은데?"
신입: "...잘 모르겠어요"
```

**문제점 분석**:
```mermaid
graph TB
    subgraph "잘못된 학습 순서"
        A1[Managed Service 바로 사용]
        B1[편리함만 경험]
        C1[왜 필요한지 모름]
        D1[문제 발생 시 대응 불가]
    end
    
    subgraph "올바른 학습 순서"
        A2[직접 구축]
        B2[Pain Point 경험]
        C2[해결책 탐색]
        D2[Managed Service 가치 체감]
    end
    
    A1 --> B1 --> C1 --> D1
    A2 --> B2 --> C2 --> D2
    
    style A1 fill:#ffebee
    style B1 fill:#ffebee
    style C1 fill:#ffebee
    style D1 fill:#ffebee
    style A2 fill:#e8f5e8
    style B2 fill:#e8f5e8
    style C2 fill:#e8f5e8
    style D2 fill:#e8f5e8
```

**학습 철학**:
- 🎯 **Pain First**: 문제를 먼저 경험해야 해결책의 가치를 안다
- 🔧 **Build First**: 직접 만들어봐야 Managed Service의 편리함을 안다
- 💡 **Understand Why**: 왜 필요한지 알아야 제대로 활용할 수 있다
- 📊 **Cost Awareness**: 직접 구축해봐야 비용의 합리성을 판단할 수 있다

**실무 적용**:
- ✅ **주니어 교육**: 먼저 직접 구축 경험 → 이후 Managed Service 도입
- ✅ **기술 선택**: 문제를 명확히 정의 → 해결책 비교 → 최적 선택
- ✅ **비용 정당화**: 직접 구축 비용 vs Managed Service 비용 비교 가능

### 🔍 개념 2: Docker Compose 관측성 완전체 스택 (15분)

**AWS IaaS 기반 Docker Compose 아키텍처**:
```mermaid
graph TB
    subgraph "AWS Cloud"
        subgraph "VPC (10.0.0.0/16)"
            subgraph "Public Subnet AZ-A (10.0.1.0/24)"
                ALB[Application Load Balancer]
                EC2_1[EC2 Instance 1<br/>Docker Compose Stack]
            end
            subgraph "Public Subnet AZ-B (10.0.2.0/24)"
                EC2_2[EC2 Instance 2<br/>Docker Compose Stack]
            end
            subgraph "Private Subnet AZ-A (10.0.11.0/24)"
                EC2_3[EC2 Instance 3<br/>Monitoring Stack]
            end
            
            IGW[Internet Gateway]
        end
    end
    
    Users[사용자] --> IGW
    IGW --> ALB
    ALB --> EC2_1
    ALB --> EC2_2
    EC2_1 -.-> EC2_3
    EC2_2 -.-> EC2_3
    
    style Users fill:#e3f2fd
    style IGW fill:#ff9800
    style ALB fill:#4caf50
    style EC2_1 fill:#2196f3
    style EC2_2 fill:#2196f3
    style EC2_3 fill:#9c27b0
```

**각 EC2 인스턴스 구성**:

**EC2 Instance 1 & 2 (애플리케이션)**:
```yaml
# cloudmart-app.yml (각 EC2에 배포)
version: '3.8'

services:
  frontend:
    image: cloudmart/frontend:latest
    ports:
      - "80:80"
    labels:
      - "prometheus.io/scrape=true"

  backend:
    image: cloudmart/backend:latest
    ports:
      - "3000:3000"
    environment:
      - PROMETHEUS_ENDPOINT=http://10.0.11.10:9090
      - JAEGER_ENDPOINT=http://10.0.11.10:14268
    labels:
      - "prometheus.io/scrape=true"

  postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=cloudmart
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

**EC2 Instance 3 (모니터링 전용)**:
```yaml
# monitoring-stack.yml (Private Subnet)
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.retention.time=30d'

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin

  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "16686:16686"
      - "14268:14268"

  loki:
    image: grafana/loki:latest
    ports:
      - "3100:3100"

  alertmanager:
    image: prom/alertmanager:latest
    ports:
      - "9093:9093"
```

**네트워크 구성의 장점**:
- ✅ **보안**: 모니터링 스택을 Private Subnet에 격리
- ✅ **성능**: 애플리케이션과 모니터링 분리로 성능 영향 최소화
- ✅ **확장성**: 각 EC2를 독립적으로 스케일링 가능
- ✅ **가용성**: Multi-AZ 배치로 고가용성 확보

**관측성 3대 요소 (Observability)**:
```mermaid
graph TB
    subgraph "관측성 3대 요소"
        A[Metrics<br/>메트릭]
        B[Logs<br/>로그]
        C[Traces<br/>분산 추적]
    end
    
    subgraph "Docker Compose 구현"
        D[Prometheus<br/>+ Grafana]
        E[Loki<br/>+ Promtail]
        F[Jaeger<br/>+ APM]
    end
    
    A --> D
    B --> E
    C --> F
    
    style A fill:#e8f5e8
    style B fill:#fff3e0
    style C fill:#ffebee
    style D fill:#e8f5e8
    style E fill:#fff3e0
    style F fill:#ffebee
```

**완전한 관측성 스택 구성**:

```yaml
# observability-with-dora.yml
version: '3.8'

services:
  # 1. Metrics (메트릭) - Prometheus
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./config/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.retention.time=30d'
      - '--web.enable-lifecycle'
      - '--storage.tsdb.path=/prometheus'

  # 2. Logs (로그) - Loki
  loki:
    image: grafana/loki:latest
    ports:
      - "3100:3100"
    volumes:
      - ./config/loki-config.yml:/etc/loki/local-config.yaml
      - loki_data:/loki
    command: -config.file=/etc/loki/local-config.yaml

  # 3. Traces (분산 추적) - Jaeger
  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "16686:16686"  # UI
      - "14268:14268"  # HTTP collector
      - "6831:6831/udp"  # UDP collector
    environment:
      - COLLECTOR_OTLP_ENABLED=true
      - SPAN_STORAGE_TYPE=memory

  # 4. DORA Metrics - Four Keys (Google 오픈소스)
  fourkeys:
    image: gcr.io/fourkeys-project/fourkeys:latest
    ports:
      - "8080:8080"
    environment:
      - GITHUB_TOKEN=${GITHUB_TOKEN}
      - PROJECT_ID=cloudmart
      - DATABASE_URL=postgresql://fourkeys:fourkeys@fourkeys-db:5432/fourkeys
    depends_on:
      - fourkeys-db

  fourkeys-db:
    image: postgres:13
    environment:
      - POSTGRES_DB=fourkeys
      - POSTGRES_USER=fourkeys
      - POSTGRES_PASSWORD=fourkeys
    volumes:
      - fourkeys_data:/var/lib/postgresql/data

  # 통합 대시보드 - Grafana
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
      - ./config/grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./config/grafana/datasources:/etc/grafana/provisioning/datasources
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false

  # APM (Application Performance Monitoring) - 무료!
  apm-server:
    image: elastic/apm-server:7.17.0
    ports:
      - "8200:8200"
    volumes:
      - ./config/apm-server.yml:/usr/share/apm-server/apm-server.yml
    depends_on:
      - elasticsearch

  elasticsearch:
    image: elasticsearch:7.17.0
    ports:
      - "9200:9200"
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data

  # 메트릭 수집기들
  node-exporter:
    image: prom/node-exporter:latest
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    privileged: true

  # 로그 수집 (Promtail)
  promtail:
    image: grafana/promtail:latest
    volumes:
      - /var/log:/var/log:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - ./config/promtail-config.yml:/etc/promtail/config.yml
    command: -config.file=/etc/promtail/config.yml

  # 알림 (AlertManager)
  alertmanager:
    image: prom/alertmanager:latest
    ports:
      - "9093:9093"
    volumes:
      - ./config/alertmanager.yml:/etc/alertmanager/alertmanager.yml
      - alertmanager_data:/alertmanager

volumes:
  prometheus_data:
  loki_data:
  grafana_data:
  elasticsearch_data:
  alertmanager_data:
  fourkeys_data:
```

**각 컴포넌트 역할**:
- **Prometheus**: 메트릭 수집 및 저장 (CPU, 메모리, 응답시간 등)
- **Grafana**: 통합 대시보드 및 시각화
- **Loki**: 로그 수집 및 저장 (구조화되지 않은 로그)
- **Jaeger**: 분산 추적 (마이크로서비스 간 요청 흐름)
- **APM Server**: 애플리케이션 성능 모니터링
- **AlertManager**: 알림 및 경고 관리

**AWS 대응 서비스**:
| Docker Compose | AWS Managed | 월 비용 비교 |
|----------------|-------------|-------------|
| Prometheus + Grafana | CloudWatch | $0 vs $100+ |
| Loki + Promtail | CloudWatch Logs | $0 vs $50+ |
| Jaeger | X-Ray | $0 vs $30+ |
| APM Server | Application Insights | $0 vs $200+ |
| **총합** | **$0** | **$380+** |

### 🔍 개념 3: 실제 애플리케이션 연동 (10분)

**CloudMart 애플리케이션에 관측성 추가**:

```yaml
# cloudmart-with-observability.yml
version: '3.8'

services:
  # 메인 애플리케이션
  backend:
    image: cloudmart/backend:latest
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DB_HOST=postgres
      - REDIS_HOST=redis
      # 관측성 설정
      - PROMETHEUS_ENDPOINT=http://prometheus:9090
      - JAEGER_ENDPOINT=http://jaeger:14268/api/traces
      - APM_SERVER_URL=http://apm-server:8200
      - LOKI_ENDPOINT=http://loki:3100
    volumes:
      - ./logs:/app/logs
    depends_on:
      - postgres
      - redis
      - prometheus
      - jaeger
      - loki
      - apm-server
    labels:
      - "prometheus.io/scrape=true"
      - "prometheus.io/port=3000"
      - "prometheus.io/path=/metrics"

  frontend:
    image: cloudmart/frontend:latest
    ports:
      - "80:80"
    volumes:
      - ./logs/nginx:/var/log/nginx
    depends_on:
      - backend

  postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=cloudmart
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./logs/postgres:/var/log/postgresql
    labels:
      - "prometheus.io/scrape=true"
      - "prometheus.io/port=9187"

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
      - ./logs/redis:/var/log/redis
    labels:
      - "prometheus.io/scrape=true"
      - "prometheus.io/port=9121"

  # PostgreSQL Exporter (메트릭 수집)
  postgres-exporter:
    image: prometheuscommunity/postgres-exporter:latest
    environment:
      - DATA_SOURCE_NAME=postgresql://user:password@postgres:5432/cloudmart?sslmode=disable
    ports:
      - "9187:9187"
    depends_on:
      - postgres

  # Redis Exporter (메트릭 수집)
  redis-exporter:
    image: oliver006/redis_exporter:latest
    environment:
      - REDIS_ADDR=redis://redis:6379
    ports:
      - "9121:9121"
    depends_on:
      - redis

volumes:
  postgres_data:
  redis_data:

networks:
  default:
    name: cloudmart-observability
```

**애플리케이션 코드 수정 예시**:

```javascript
// backend/app.js - 관측성 라이브러리 추가
const express = require('express');
const prometheus = require('prom-client');
const jaeger = require('jaeger-client');
const apm = require('elastic-apm-node');

// APM 초기화
apm.start({
  serviceName: 'cloudmart-backend',
  serverUrl: process.env.APM_SERVER_URL
});

// Prometheus 메트릭 설정
const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code']
});

const httpRequestTotal = new prometheus.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

// Jaeger 트레이싱 설정
const tracer = jaeger.initTracer({
  serviceName: 'cloudmart-backend',
  sampler: { type: 'const', param: 1 }
});

const app = express();

// 메트릭 수집 미들웨어
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const labels = {
      method: req.method,
      route: req.route?.path || req.path,
      status_code: res.statusCode
    };
    
    httpRequestDuration.observe(labels, duration);
    httpRequestTotal.inc(labels);
  });
  
  next();
});

// 메트릭 엔드포인트
app.get('/metrics', (req, res) => {
  res.set('Content-Type', prometheus.register.contentType);
  res.end(prometheus.register.metrics());
});

// 헬스체크 엔드포인트
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});
```

---

## 🚨 구축하면서 경험하는 Pain Points

### Pain Point 1: 설정 복잡도 폭발

**상황**: Prometheus 설정 파일 작성
```yaml
# config/prometheus.yml - 실제로 작성해야 하는 설정
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert-rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
  
  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']
  
  - job_name: 'backend'
    static_configs:
      - targets: ['backend:3000']
    metrics_path: '/metrics'
    scrape_interval: 5s
  
  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-exporter:9187']
  
  - job_name: 'redis'
    static_configs:
      - targets: ['redis-exporter:9121']

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093
```

**문제점**:
- ❌ **복잡한 설정**: 각 서비스마다 수동 설정 필요
- ❌ **서비스 디스커버리**: 새 서비스 추가 시 설정 파일 수정
- ❌ **메트릭 선택**: 어떤 메트릭을 수집할지 판단 어려움
- ❌ **성능 튜닝**: scrape_interval, retention 등 최적화 필요

**AWS CloudWatch 해결**:
- ✅ **자동 설정**: 서비스 배포 시 자동 메트릭 수집
- ✅ **서비스 디스커버리**: 새 서비스 자동 감지
- ✅ **추천 메트릭**: AWS가 권장하는 핵심 메트릭 자동 수집
- ✅ **자동 최적화**: 성능과 비용 자동 최적화

### Pain Point 2: 대시보드 구성의 어려움

**상황**: Grafana 대시보드 생성
```json
{
  "dashboard": {
    "title": "CloudMart Monitoring",
    "panels": [
      {
        "title": "CPU Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(cpu_usage_total[5m]) * 100",
            "legendFormat": "{{instance}}"
          }
        ]
      },
      {
        "title": "Memory Usage",
        "type": "graph", 
        "targets": [
          {
            "expr": "(memory_usage_bytes / memory_limit_bytes) * 100",
            "legendFormat": "{{instance}}"
          }
        ]
      },
      {
        "title": "HTTP Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{method}} {{route}}"
          }
        ]
      }
    ]
  }
}
```

**문제점**:
- ❌ **PromQL 학습**: 복잡한 쿼리 언어 습득 필요
- ❌ **차트 선택**: 어떤 시각화가 적합한지 판단 어려움
- ❌ **임계값 설정**: 알람 기준 설정의 어려움
- ❌ **대시보드 관리**: 버전 관리 및 공유 복잡

**AWS CloudWatch 해결**:
- ✅ **미리 만들어진 대시보드**: 서비스별 권장 대시보드 제공
- ✅ **간단한 쿼리**: GUI 기반 메트릭 선택
- ✅ **추천 임계값**: 서비스별 권장 알람 임계값
- ✅ **자동 관리**: 대시보드 버전 관리 자동화

### Pain Point 3: 알림 설정의 복잡함

**상황**: AlertManager 알림 규칙 작성
```yaml
# config/alert-rules.yml
groups:
  - name: cloudmart-alerts
    rules:
    - alert: HighCPUUsage
      expr: rate(cpu_usage_total[5m]) * 100 > 80
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High CPU usage on {{ $labels.instance }}"
        description: "CPU usage is above 80% for more than 5 minutes"

    - alert: HighMemoryUsage
      expr: (memory_usage_bytes / memory_limit_bytes) * 100 > 85
      for: 3m
      labels:
        severity: critical
      annotations:
        summary: "High memory usage on {{ $labels.instance }}"

    - alert: HTTPErrorRate
      expr: rate(http_requests_total{status_code=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.1
      for: 2m
      labels:
        severity: critical
      annotations:
        summary: "High HTTP error rate"

    - alert: DatabaseConnectionFailed
      expr: up{job="postgres"} == 0
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "Database connection failed"
```

**문제점**:
- ❌ **임계값 설정**: 언제 알림을 보낼지 기준 모호
- ❌ **알림 피로도**: 너무 많은 알림으로 인한 피로
- ❌ **채널 연동**: Slack, 이메일 등 다양한 채널 설정 복잡
- ❌ **알림 그룹화**: 관련 알림들의 그룹화 어려움

**AWS CloudWatch 해결**:
- ✅ **지능형 알림**: 머신러닝 기반 이상 탐지
- ✅ **SNS 통합**: 이메일, SMS, Slack 원클릭 연동
- ✅ **알림 그룹화**: 관련 알림 자동 그룹화
- ✅ **알림 억제**: 중복 알림 자동 억제

### Pain Point 4: 로그 분석의 어려움

**상황**: 로그 검색 및 분석
```yaml
# config/loki-config.yml
auth_enabled: false

server:
  http_listen_port: 3100

ingester:
  lifecycler:
    address: 127.0.0.1
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1

schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

storage_config:
  boltdb_shipper:
    active_index_directory: /loki/boltdb-shipper-active
    cache_location: /loki/boltdb-shipper-cache
    shared_store: filesystem
  filesystem:
    directory: /loki/chunks

limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h
```

**문제점**:
- ❌ **로그 포맷 표준화**: 각 서비스마다 다른 로그 형식
- ❌ **대용량 처리**: 로그 양이 많아질 때 성능 저하
- ❌ **검색 성능**: 복잡한 쿼리 시 응답 시간 증가
- ❌ **보관 정책**: 디스크 용량 관리 및 로그 순환 정책

**AWS CloudWatch Logs 해결**:
- ✅ **자동 파싱**: 로그 포맷 자동 인식 및 파싱
- ✅ **무제한 확장**: 로그 양에 관계없이 일정한 성능
- ✅ **빠른 검색**: 인덱싱 기반 고속 검색
- ✅ **자동 보관**: 설정 기반 자동 보관 정책

### Pain Point 5: 분산 추적의 복잡함

**상황**: 마이크로서비스 간 요청 추적
```javascript
// 각 서비스마다 추가해야 하는 추적 코드
const opentracing = require('opentracing');
const jaeger = require('jaeger-client');

// Jaeger 초기화
const config = {
  serviceName: 'cloudmart-backend',
  sampler: { type: 'const', param: 1 },
  reporter: { logSpans: true }
};
const tracer = jaeger.initTracer(config);

// 각 API 호출마다 추가
app.get('/api/products', async (req, res) => {
  const span = tracer.startSpan('get_products');
  
  try {
    // 데이터베이스 호출
    const dbSpan = tracer.startSpan('db_query', { childOf: span });
    const products = await db.query('SELECT * FROM products');
    dbSpan.finish();
    
    // Redis 호출
    const cacheSpan = tracer.startSpan('cache_set', { childOf: span });
    await redis.set('products', JSON.stringify(products));
    cacheSpan.finish();
    
    res.json(products);
  } catch (error) {
    span.setTag('error', true);
    span.log({ event: 'error', message: error.message });
    res.status(500).json({ error: error.message });
  } finally {
    span.finish();
  }
});

// 다른 서비스 호출 시 트레이스 ID 전파
const axios = require('axios');
app.get('/api/orders', async (req, res) => {
  const span = tracer.startSpan('get_orders');
  
  // 트레이스 컨텍스트 수동 전파
  const headers = {};
  tracer.inject(span, opentracing.FORMAT_HTTP_HEADERS, headers);
  
  const response = await axios.get('http://payment-service/payments', { headers });
  
  span.finish();
  res.json(response.data);
});
```

**문제점**:
- ❌ **코드 침투성**: 모든 서비스에 추적 코드 추가 필요
- ❌ **수동 전파**: 트레이스 ID 수동 전파 구현
- ❌ **성능 오버헤드**: 추적으로 인한 성능 영향
- ❌ **복잡한 설정**: 샘플링, 리포터 등 세부 설정

**AWS X-Ray 해결**:
- ✅ **SDK 자동 계측**: 최소한의 코드 변경으로 추적
- ✅ **자동 전파**: 트레이스 ID 자동 전파
- ✅ **최적화된 성능**: AWS 최적화된 추적 성능
- ✅ **간단한 설정**: 환경변수만으로 설정 완료

### Pain Point 6: DORA Metrics 측정의 어려움

**상황**: DevOps 팀 성과 측정 및 개선
```bash
# 현재: 수동으로 DORA 메트릭 계산

# 1. Deployment Frequency (배포 빈도)
git log --oneline --since="1 month ago" --grep="deploy" | wc -l
# 결과: 12회 (수동 계산, 부정확할 수 있음)

# 2. Lead Time for Changes (변경 리드타임)
# 커밋 시간 → 배포 시간 수동 계산
git log --format="%H %ct %s" --since="1 month ago" | grep deploy
docker logs deployment_container | grep "deployment completed"
# 결과: 평균 4시간 (수동 추적, 시간 소모)

# 3. Change Failure Rate (변경 실패율)
# 롤백 횟수 / 전체 배포 횟수 수동 집계
grep "rollback" deployment.log | wc -l
echo "scale=2; $(grep "rollback" deployment.log | wc -l) / 12 * 100" | bc
# 결과: 16.67% (수동 집계, 누락 가능성)

# 4. Time to Restore Service (서비스 복구 시간)
# 장애 발생 → 복구 완료 시간 수동 기록
grep -A1 "service down" incident.log | grep "service restored"
# 결과: 평균 45분 (사람이 기록, 부정확)

# 월간 DORA 리포트 작성
echo "이번 달 DORA 메트릭 정리하는데 4시간 걸렸다..."
```

**문제점**:
- ❌ **수동 측정**: 모든 지표를 사람이 직접 계산 (월 4시간 소요)
- ❌ **부정확성**: 사람의 실수, 데이터 누락 가능성
- ❌ **일관성 부족**: 팀원마다 측정 기준이 다름
- ❌ **실시간성 부족**: 월말에야 지표 확인 가능
- ❌ **개선 지연**: 문제를 늦게 발견하여 개선 지연

**Four Keys (Google 오픈소스) 해결**:
```bash
# 자동 DORA 메트릭 수집 및 대시보드
docker-compose -f observability-with-dora.yml up -d

# GitHub 연동 설정
export GITHUB_TOKEN=your_github_token
export PROJECT_ID=cloudmart

# Four Keys 대시보드 접속
open http://localhost:8080

# 실시간 DORA 메트릭 확인
curl http://localhost:8080/api/dora-metrics
```

**Four Keys 자동 수집 결과**:
```json
{
  "deploymentFrequency": {
    "value": 15,
    "period": "monthly",
    "trend": "+25% vs last month"
  },
  "leadTimeForChanges": {
    "value": "2.3 hours",
    "p50": "1.5 hours",
    "p95": "6.2 hours"
  },
  "changeFailureRate": {
    "value": "8.3%",
    "trend": "-50% vs last month"
  },
  "timeToRestoreService": {
    "value": "23 minutes",
    "p50": "15 minutes",
    "p95": "45 minutes"
  }
}
```

**효과**:
- ✅ **자동 데이터 수집**: GitHub API 연동으로 자동 수집
- ✅ **실시간 대시보드**: 언제든 현재 상태 확인 가능
- ✅ **표준화된 측정**: Google 표준 DORA 측정 방식
- ✅ **시간 절약**: 월 4시간 → 0시간 (완전 자동화)
- ✅ **정확한 데이터**: API 기반 정확한 데이터 수집

**AWS CodePipeline + CloudWatch 해결**:
```yaml
# AWS에서 DORA 메트릭 자동 수집
DORA_Metrics:
  DeploymentFrequency:
    Source: CodePipeline 실행 횟수
    Automation: CloudWatch Events 자동 집계
    
  LeadTimeForChanges:
    Source: CodeCommit 푸시 → CodePipeline 완료 시간
    Automation: X-Ray 분산 추적 자동 계산
    
  ChangeFailureRate:
    Source: CodePipeline 실패율
    Automation: CloudWatch 메트릭 자동 계산
    
  TimeToRestoreService:
    Source: CloudWatch 알람 → 복구 시간
    Automation: 실시간 자동 측정 및 알림
```

**측정 비교**:
| 항목 | Docker Compose + 수동 | Four Keys | AWS Native |
|------|---------------------|-----------|------------|
| **설정 시간** | 0분 (측정 안 함) | 30분 | 2시간 |
| **월 운영 시간** | 4시간 (수동 계산) | 0분 | 0분 |
| **데이터 정확도** | 70% (사람 실수) | 95% | 99% |
| **실시간성** | 없음 (월말 확인) | 실시간 | 실시간 |
| **비용** | $0 | $0 | $50/월 |
| **개선 속도** | 느림 (월 1회) | 빠름 (실시간) | 매우 빠름 |

---

## 🔄 "그래서 언제 AWS로 갈아타야 하나?"

### 전환 시점 판단 기준

```mermaid
graph TB
    A[현재 상황 평가] --> B{팀 규모}
    B -->|1-3명| C[Docker Compose 유지]
    B -->|4-10명| D{트래픽 규모}
    B -->|10명+| E[AWS 전환 고려]
    
    D -->|DAU < 1만| F[Docker Compose 유지]
    D -->|DAU 1-10만| G{운영 부담}
    D -->|DAU 10만+| H[AWS 전환 필요]
    
    G -->|감당 가능| I[Docker Compose 유지]
    G -->|부담됨| J[점진적 AWS 전환]
    
    C --> K[비용 최우선]
    F --> L[학습 중심]
    I --> M[현상 유지]
    E --> N[효율성 추구]
    H --> O[확장성 필수]
    J --> P[단계적 전환]
    
    style C fill:#e8f5e8
    style F fill:#e8f5e8
    style I fill:#e8f5e8
    style M fill:#e8f5e8
    style E fill:#ffebee
    style H fill:#ffebee
    style O fill:#ffebee
    style J fill:#fff3e0
    style P fill:#fff3e0
```

### DORA Metrics 기준 전환 시점

**배포 빈도 기준**:
- **주 1회 미만**: Docker Compose 유지 (수동 측정으로 충분)
- **주 1-3회**: Four Keys 도입 고려 (자동화 효과 시작)
- **일 1회 이상**: AWS 전환 권장 (완전 자동화 필요)

**팀 성숙도 기준**:
- **DORA 측정 안 함**: Docker Compose 유지
- **DORA 측정 시작**: Four Keys 도입
- **DORA 개선 집중**: AWS 전환 고려
- **DevOps 성숙**: AWS Native 권장

**실무 의사결정 매트릭스**:
| DORA 지표 | Docker Compose | Four Keys | AWS Native |
|-----------|---------------|-----------|------------|
| **Deployment Frequency** | < 주 1회 | 주 1-5회 | 일 1회+ |
| **Lead Time** | > 1주 | 1일-1주 | < 1일 |
| **Change Failure Rate** | 측정 안 함 | > 15% | < 15% |
| **Time to Restore** | > 1일 | 1시간-1일 | < 1시간 |
| **팀 우선순위** | 기능 개발 | DevOps 개선 | 운영 자동화 |

### 점진적 전환 전략

**Phase 1: 모니터링만 AWS (1-2주)**
```yaml
현재 유지:
- Docker Compose 애플리케이션
- 로컬 데이터베이스
- 기존 배포 프로세스

AWS 도입:
- CloudWatch Agent 설치
- 기본 메트릭 수집
- 간단한 알람 설정

효과:
- 운영 부담 20% 감소
- 비용 증가 $50/월
- 학습 곡선 낮음
```

**Phase 2: 로그 중앙화 (2-3주)**
```yaml
추가 도입:
- CloudWatch Logs
- 로그 그룹 설정
- 로그 인사이트 활용

효과:
- 로그 분석 시간 50% 단축
- 비용 증가 $30/월
- 문제 해결 속도 향상
```

**Phase 3: 데이터베이스 전환 (4-6주)**
```yaml
전환 대상:
- PostgreSQL → RDS
- Redis → ElastiCache

효과:
- 백업/복구 자동화
- 비용 증가 $200/월
- 운영 부담 40% 감소
```

**Phase 4: 컴퓨팅 전환 (6-8주)**
```yaml
전환 대상:
- Docker Compose → ECS/EKS
- 수동 스케일링 → Auto Scaling

효과:
- 확장성 확보
- 비용 증가 $300/월
- 가용성 99.9% → 99.95%
```

**Phase 5: 완전 전환 (8-12주)**
```yaml
최종 상태:
- 모든 인프라 AWS Native
- 완전 자동화
- 통합 모니터링

효과:
- 운영 부담 80% 감소
- 총 비용 증가 $600/월
- 개발 생산성 2배 향상
```

### 전환 ROI 계산

**비용 분석**:
| 항목 | Docker Compose | AWS Native | 차이 |
|------|---------------|------------|------|
| **인프라 비용** | $500/월 | $1,100/월 | +$600 |
| **운영 인력** | 1명 × $5,000 | 0.2명 × $5,000 | -$4,000 |
| **다운타임 비용** | 43분/월 × $1,000 | 22분/월 × $1,000 | -$350 |
| **개발 생산성** | 기준 | +50% 효율 | +$2,000 |
| **월 순이익** | - | **+$1,050** | - |

**전환 시점 결정 요소**:
- ✅ **월 순이익 > $1,000**: 즉시 전환 권장
- ⚠️ **월 순이익 $0-1,000**: 점진적 전환
- ❌ **월 순이익 < $0**: 현상 유지

---

## 🎯 결론: "경험이 최고의 스승"

### 핵심 메시지

> **"Docker Compose로 직접 구축해본 사람만이 AWS Managed Service의 진짜 가치를 안다. 처음부터 좋은 걸 쓰면 왜 좋은지 모른다."**

### 학습 순서의 중요성

```mermaid
sequenceDiagram
    participant 개발자 as 개발자
    participant Docker as Docker Compose
    participant Pain as Pain Points
    participant AWS as AWS Services
    participant 가치 as 가치 인식
    
    개발자->>Docker: 1. 직접 구축
    Docker->>Pain: 2. 문제 경험
    Pain->>AWS: 3. 해결책 탐색
    AWS->>가치: 4. 진짜 가치 체감
    
    Note over 개발자,가치: "아, 이래서 비싼 거구나!"
```

### 실무 적용 가이드

**주니어 개발자 교육**:
1. **1-2개월**: Docker Compose로 완전한 스택 구축
2. **3-4개월**: 실제 운영하며 Pain Point 경험
3. **5-6개월**: AWS Managed Service 도입 및 비교
4. **결과**: AWS 서비스의 가치를 정확히 이해하는 개발자

**기술 선택 프로세스**:
1. **문제 정의**: 현재 겪고 있는 구체적 문제
2. **직접 구축**: 오픈소스로 해결책 구현
3. **Pain Point 수집**: 운영하며 어려운 점 정리
4. **Managed Service 검토**: 비용 대비 효과 분석
5. **점진적 전환**: 단계별 마이그레이션

**비용 정당화**:
- ✅ **Before**: Docker Compose 운영 비용 정확히 측정
- ✅ **After**: AWS 전환 후 비용 및 효과 측정
- ✅ **ROI**: 투자 대비 효과를 수치로 증명
- ✅ **의사결정**: 데이터 기반 합리적 선택

---

## 🔑 핵심 키워드

### 새로운 용어
- **Observability**: 관측성 - 시스템 내부 상태를 외부에서 관찰할 수 있는 능력
- **Pain First**: 페인 퍼스트 - 문제를 먼저 경험하는 학습 방법론
- **ROI (Return on Investment)**: 투자 대비 수익률

### 중요 개념
- **3대 관측성**: Metrics, Logs, Traces
- **점진적 전환**: 단계별 마이그레이션 전략
- **비용 정당화**: 기술 선택의 경제적 근거

### 실무 용어
- **Code Instrumentation**: 코드 계측 - 모니터링을 위한 코드 추가
- **Service Discovery**: 서비스 디스커버리 - 서비스 자동 발견
- **Alert Fatigue**: 알림 피로도 - 과도한 알림으로 인한 피로

---

## 📝 Session 마무리

### ✅ 오늘 Session 성과

**구축 성과**:
- [ ] Docker Compose로 완전한 관측성 스택 구축 (Prometheus + Grafana + Jaeger + APM)
- [ ] 실제 애플리케이션에 모니터링 연동
- [ ] 5가지 주요 Pain Point 직접 경험
- [ ] AWS 전환 시점 판단 기준 습득

**인식 변화**:
- [ ] "처음부터 좋은 걸 쓰면 안 되는 이유" 체감
- [ ] Docker Compose의 한계와 AWS의 가치 정확히 인식
- [ ] 기술 선택 시 비용 대비 효과 고려 습관
- [ ] 점진적 전환의 중요성 이해

### 🎯 다음 Session 준비

**Session 4 예고**: "CloudMart AWS 마이그레이션 실전"
- 실제 CloudMart를 AWS로 단계별 마이그레이션
- 각 단계별 비용 및 효과 측정
- 최종 아키텍처 완성

**준비사항**:
- 오늘 구축한 관측성 스택 유지
- Pain Point 목록 정리 및 우선순위 설정
- AWS 계정 및 권한 확인

---

## 🔗 참고 자료

### 📚 복습 자료
- [Prometheus 공식 문서](https://prometheus.io/docs/)
- [Grafana 대시보드 갤러리](https://grafana.com/grafana/dashboards/)
- [Jaeger 분산 추적 가이드](https://www.jaegertracing.io/docs/)

### 📖 심화 학습
- [관측성 베스트 프랙티스](https://sre.google/sre-book/monitoring-distributed-systems/)
- [Docker Compose 프로덕션 가이드](https://docs.docker.com/compose/production/)

### 💡 실무 참고
- [AWS 마이그레이션 전략](https://aws.amazon.com/cloud-migration/)
- [기술 부채 관리 방법론](https://martinfowler.com/bliki/TechnicalDebt.html)

---

## 💭 함께 생각해보기 (10분)

### 🤝 페어 실습 (5분)

**실습 주제**: "관측성 스택 구축 및 Pain Point 경험"

**페어 활동 가이드**:
1. **기본 스택 실행** (2분):
   ```bash
   # 관측성 + DORA 스택 실행
   cd observability-stack
   docker-compose -f observability-with-dora.yml up -d
   
   # 접속 확인
   curl http://localhost:9090  # Prometheus
   curl http://localhost:3000  # Grafana (admin/admin)
   curl http://localhost:8080  # Four Keys DORA Dashboard
   ```

2. **설정 파일 작성** (2분):
   ```bash
   # Prometheus 설정 확인
   cat config/prometheus.yml
   
   # DORA Metrics 확인
   export GITHUB_TOKEN=demo_token
   curl http://localhost:8080/api/dora-metrics
   # → GitHub 연동 없이는 데모 데이터만 표시
   
   # 새 서비스 추가 시도
   # → 설정 파일 수정 필요성 체감
   ```

3. **대시보드 생성 시도** (1분):
   ```bash
   # Grafana에서 대시보드 생성
   # → PromQL 쿼리 작성의 어려움 체감
   
   # Four Keys에서 DORA 메트릭 확인
   # → 자동 수집의 편리함 체감
   ```

### 🎯 전체 공유 (5분)

**공유 질문**:
1. **설정 복잡도**: "Prometheus 설정이 얼마나 복잡했나요?"
2. **학습 곡선**: "PromQL 쿼리 작성이 어려웠나요?"
3. **DORA 자동화**: "Four Keys로 DORA 메트릭을 자동으로 볼 수 있어서 어땠나요?"
4. **AWS 가치**: "이제 CloudWatch가 왜 비싼지 이해되나요?"

**예상 답변**:
- "설정 파일 하나 만드는데 30분 걸렸어요"
- "PromQL 문법이 SQL보다 어려워요"
- "DORA 메트릭을 수동으로 계산하는 게 얼마나 번거로운지 알겠어요"
- "Four Keys 같은 도구가 있어도 GitHub 연동 설정이 복잡하네요"
- "이제 CloudWatch 비용이 합리적으로 느껴져요"

### 💡 이해도 체크 질문

- ✅ "관측성 3대 요소를 설명할 수 있나요?"
- ✅ "DORA 4대 지표가 무엇인지 말할 수 있나요?"
- ✅ "Docker Compose 관측성 스택의 한계를 3가지 이상 말할 수 있나요?"
- ✅ "Four Keys와 AWS CodePipeline의 차이점을 설명할 수 있나요?"
- ✅ "언제 AWS로 전환해야 하는지 판단 기준을 설명할 수 있나요?"

---

<div align="center">

**🔍 완전한 관측성** • **🛠️ 직접 구축 경험** • **💡 AWS 가치 체감**

*경험이 최고의 스승 - 직접 해봐야 진짜 가치를 안다*

</div>
