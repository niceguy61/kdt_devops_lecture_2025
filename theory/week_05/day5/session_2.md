# Week 5 Day 5 Session 2: 인프라 구성 (10:00-10:50)

<div align="center">

**🏗️ 네트워크 설계** • **💾 데이터베이스** • **⚡ 캐싱** • **🔐 보안**

*CloudMart를 위한 프로덕션급 AWS 인프라 구축*

</div>

---

## 🕘 세션 정보
**시간**: 10:00-10:50 (50분)
**목표**: CloudMart 배포를 위한 완전한 AWS 인프라 설계 및 구성
**방식**: 이론 설명 + 아키텍처 설계

## 🎯 세션 목표

### 📚 학습 목표
- **이해 목표**: Multi-AZ 고가용성 아키텍처 설계 원칙 이해
- **적용 목표**: VPC, RDS, ElastiCache 최적 구성 방법 습득
- **협업 목표**: 팀과 함께 인프라 설계 결정 사항 도출

### 🤔 왜 필요한가? (5분)

**현실 문제 상황**:
- 💼 **실무 시나리오**: "서버 1대가 죽으면 전체 서비스가 멈춰요. 어떻게 해야 하나요?"
- 🏠 **일상 비유**: 식당에 주방이 1개 → 고장 나면 영업 중단 vs 주방 2개 → 하나 고장 나도 계속 영업
- ☁️ **AWS 아키텍처**: Single-AZ (1개 데이터센터) → Multi-AZ (2개 이상 데이터센터)
- 📊 **시장 동향**: Netflix는 99.99% 가용성 (연간 52분 다운타임)

**Single-AZ vs Multi-AZ 비교**:
```mermaid
graph TB
    subgraph "Single-AZ (위험)"
        A1[사용자] --> B1[AZ-A만 사용]
        B1 --> C1[EC2]
        B1 --> D1[RDS]
        E1[AZ-A 장애 시<br/>전체 서비스 중단]
    end
    
    subgraph "Multi-AZ (안전)"
        A2[사용자] --> B2[ALB<br/>트래픽 분산]
        B2 --> C2[AZ-A<br/>EC2 + RDS Primary]
        B2 --> D2[AZ-B<br/>EC2 + RDS Standby]
        E2[AZ-A 장애 시<br/>AZ-B로 자동 전환]
    end
    
    style B1 fill:#ffebee
    style E1 fill:#ffebee
    style B2 fill:#e8f5e8
    style C2 fill:#e8f5e8
    style D2 fill:#e8f5e8
    style E2 fill:#e8f5e8
```

## 📖 핵심 개념 (35분)

### 🔍 개념 1: Multi-AZ VPC 네트워크 설계 (12분)

> **정의**: 여러 가용 영역에 걸쳐 고가용성을 보장하는 네트워크 아키텍처

**🔄 Docker Compose vs AWS 아키텍처 비교**:

**Docker Compose (단일 서버 - 로컬 개발)**:
```mermaid
graph TB
    subgraph "단일 서버 (localhost)"
        USER[사용자<br/>localhost:3000]
        
        subgraph "Docker Network (bridge)"
            FRONT[frontend<br/>컨테이너<br/>3000:3000]
            BACK[backend<br/>컨테이너<br/>8080:8080]
            DB[postgres<br/>컨테이너<br/>5432:5432]
            CACHE[redis<br/>컨테이너<br/>6379:6379]
        end
        
        VOL1[postgres_data<br/>볼륨]
        VOL2[redis_data<br/>볼륨]
    end
    
    USER --> FRONT
    FRONT --> BACK
    BACK --> DB
    BACK --> CACHE
    DB --> VOL1
    CACHE --> VOL2
    
    style USER fill:#e3f2fd
    style FRONT fill:#fff3e0
    style BACK fill:#e8f5e8
    style DB fill:#ffebee
    style CACHE fill:#f3e5f5
    style VOL1 fill:#e0f2f1
    style VOL2 fill:#e0f2f1
```

**특징**:
- ✅ **간단**: 모든 것이 한 서버에서 실행
- ✅ **빠른 개발**: docker-compose up 한 번으로 전체 환경 구축
- ❌ **단일 장애점**: 서버 다운 시 전체 서비스 중단
- ❌ **확장 불가**: 트래픽 증가 시 대응 어려움
- ❌ **보안 취약**: 모든 포트가 localhost에 노출

---

**Docker Compose + DB Replication (단일 서버 - 고급 개발)**:
```mermaid
graph TB
    subgraph "단일 서버 (localhost)"
        USER[사용자<br/>localhost:3000]
        
        subgraph "Docker Network (bridge)"
            FRONT[frontend<br/>컨테이너<br/>3000:3000]
            BACK[backend<br/>컨테이너<br/>8080:8080]
            
            subgraph "PostgreSQL Replication"
                DB_PRIMARY[postgres-primary<br/>컨테이너<br/>5432:5432<br/>Read/Write]
                DB_REPLICA[postgres-replica<br/>컨테이너<br/>5433:5432<br/>Read Only]
                
                DB_PRIMARY -.Streaming<br/>Replication.-> DB_REPLICA
            end
            
            CACHE[redis<br/>컨테이너<br/>6379:6379]
        end
        
        VOL1[postgres_primary_data<br/>볼륨]
        VOL2[postgres_replica_data<br/>볼륨]
        VOL3[redis_data<br/>볼륨]
    end
    
    USER --> FRONT
    FRONT --> BACK
    BACK -->|Write| DB_PRIMARY
    BACK -->|Read| DB_REPLICA
    BACK --> CACHE
    DB_PRIMARY --> VOL1
    DB_REPLICA --> VOL2
    CACHE --> VOL3
    
    style USER fill:#e3f2fd
    style FRONT fill:#fff3e0
    style BACK fill:#e8f5e8
    style DB_PRIMARY fill:#ffebee
    style DB_REPLICA fill:#f3e5f5
    style CACHE fill:#e1f5fe
    style VOL1 fill:#e0f2f1
    style VOL2 fill:#e0f2f1
    style VOL3 fill:#e0f2f1
```

**docker-compose.yml 예시**:
```yaml
version: '3.8'
services:
  postgres-primary:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
      POSTGRES_DB: cloudmart
      # Replication 설정
      POSTGRES_REPLICATION_MODE: master
      POSTGRES_REPLICATION_USER: replicator
      POSTGRES_REPLICATION_PASSWORD: replicator_password
    volumes:
      - postgres_primary_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    command: |
      postgres -c wal_level=replica 
               -c max_wal_senders=3 
               -c max_replication_slots=3

  postgres-replica:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
      # Replica 설정
      POSTGRES_MASTER_SERVICE_HOST: postgres-primary
      POSTGRES_REPLICATION_MODE: slave
      POSTGRES_REPLICATION_USER: replicator
      POSTGRES_REPLICATION_PASSWORD: replicator_password
    volumes:
      - postgres_replica_data:/var/lib/postgresql/data
    ports:
      - "5433:5432"
    depends_on:
      - postgres-primary

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
      - ./redis.conf:/usr/local/etc/redis/redis.conf
    ports:
      - "6379:6379"
    command: redis-server /usr/local/etc/redis/redis.conf
    # Redis 고급 백업 설정

volumes:
  postgres_primary_data:
  postgres_replica_data:
  redis_data:
```

**redis.conf (고급 백업 설정)**:
```conf
# RDB (스냅샷) 백업 설정
save 900 1      # 900초(15분) 동안 1개 이상 키 변경 시 저장
save 300 10     # 300초(5분) 동안 10개 이상 키 변경 시 저장
save 60 10000   # 60초(1분) 동안 10000개 이상 키 변경 시 저장

# RDB 파일 설정
dbfilename dump.rdb
dir /data

# RDB 압축 (CPU vs 디스크 트레이드오프)
rdbcompression yes
rdbchecksum yes

# AOF (Append Only File) 백업 설정
appendonly yes
appendfilename "appendonly.aof"

# AOF 동기화 정책
# always: 모든 쓰기마다 fsync (가장 안전, 가장 느림)
# everysec: 1초마다 fsync (권장, 균형)
# no: OS에 맡김 (가장 빠름, 가장 위험)
appendfsync everysec

# AOF 재작성 (파일 크기 최적화)
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb

# 백업 중 쓰기 허용
no-appendfsync-on-rewrite no

# 메모리 정책
maxmemory 256mb
maxmemory-policy allkeys-lru
```

**백업 전략 비교**:

| 백업 방식 | RDB (스냅샷) | AOF (로그) | RDB + AOF (권장) |
|----------|--------------|------------|------------------|
| **백업 방식** | 특정 시점 전체 스냅샷 | 모든 쓰기 명령 로그 | 두 방식 병행 |
| **복구 속도** | 빠름 (바이너리) | 느림 (명령 재실행) | RDB 먼저, AOF로 보완 |
| **데이터 손실** | 마지막 스냅샷 이후 손실 | 최대 1초 손실 (everysec) | 최소화 (1초 이내) |
| **파일 크기** | 작음 (압축) | 큼 (텍스트 로그) | 중간 (AOF 재작성) |
| **CPU 사용** | 낮음 (주기적) | 높음 (지속적) | 중간 |
| **사용 사례** | 백업/복제 | 데이터 무결성 중요 | 프로덕션 권장 |

**💡 고급 백업 전략의 장점**:
- ✅ **RDB**: 빠른 복구, 작은 파일 크기, 주기적 백업
- ✅ **AOF**: 데이터 무결성, 최소 손실 (1초), 명령 재실행 가능
- ✅ **RDB + AOF**: 두 방식의 장점 결합, 프로덕션 권장
- ✅ **자동 재작성**: AOF 파일 크기 최적화
- ✅ **메모리 정책**: LRU로 메모리 관리

**💡 하지만 여전히 한계**:
- ⚠️ **단일 서버**: 서버 다운 시 백업 파일도 접근 불가
- ⚠️ **수동 복구**: 백업 파일을 수동으로 복원해야 함
- ⚠️ **복구 시간**: RDB 로드 + AOF 재실행 시간 소요
- ❌ **자동 장애 조치 없음**: ElastiCache처럼 자동 failover 불가


**특징**:
- ✅ **읽기 성능 향상**: Read Replica로 읽기 부하 분산
- ✅ **데이터 복제**: Primary 장애 시 Replica로 수동 전환 가능
- ✅ **개발 환경 테스트**: Replication 동작 로컬 테스트 가능
- ⚠️ **여전히 단일 서버**: 서버 다운 시 Primary/Replica 모두 중단
- ⚠️ **수동 장애 조치**: 자동 failover 없음 (수동으로 Replica를 Primary로 승격)
- ⚠️ **복잡도 증가**: 설정 및 관리 복잡
- ❌ **진짜 고가용성 아님**: 물리적으로 같은 서버에 있어 의미 제한적

**💡 핵심 한계**:
> Docker Compose로 DB Replication을 구현해도 **물리적으로 같은 서버**에 있기 때문에, 서버 자체가 다운되면 Primary와 Replica가 모두 중단됩니다. 진정한 고가용성을 위해서는 **물리적으로 분리된 서버**(AWS Multi-AZ)가 필요합니다!

---

**Docker Compose 멀티 서버 (직접 구현하는 Multi-AZ) 🚀**:
```mermaid
graph TB
    subgraph "인터넷"
        USER[사용자]
        LB[HAProxy/Nginx<br/>로드 밸런서<br/>별도 서버]
    end
    
    subgraph "서버 1 (AZ-A 역할)"
        subgraph "Docker Network 1"
            FRONT1[frontend<br/>컨테이너]
            BACK1[backend<br/>컨테이너]
            DB_PRIMARY[postgres-primary<br/>Read/Write]
            REDIS1[redis-master<br/>Read/Write]
        end
        VOL1A[postgres_data]
        VOL1B[redis_data]
        S3_SYNC1[S3 Sync<br/>Cron Job]
    end
    
    subgraph "서버 2 (AZ-B 역할)"
        subgraph "Docker Network 2"
            FRONT2[frontend<br/>컨테이너]
            BACK2[backend<br/>컨테이너]
            DB_REPLICA[postgres-replica<br/>Read Only]
            REDIS2[redis-replica<br/>Read Only]
        end
        VOL2A[postgres_data]
        VOL2B[redis_data]
        S3_SYNC2[S3 Sync<br/>Cron Job]
    end
    
    subgraph "AWS S3 (백업)"
        S3[S3 Bucket<br/>cloudmart-backup]
    end
    
    USER --> LB
    LB -->|Round Robin| FRONT1
    LB -->|Round Robin| FRONT2
    
    FRONT1 --> BACK1
    FRONT2 --> BACK2
    
    BACK1 -->|Write| DB_PRIMARY
    BACK1 -->|Read| DB_REPLICA
    BACK2 -->|Write| DB_PRIMARY
    BACK2 -->|Read| DB_REPLICA
    
    DB_PRIMARY -.Streaming<br/>Replication.-> DB_REPLICA
    REDIS1 -.Replication.-> REDIS2
    
    DB_PRIMARY --> VOL1A
    REDIS1 --> VOL1B
    DB_REPLICA --> VOL2A
    REDIS2 --> VOL2B
    
    VOL1A --> S3_SYNC1
    VOL1B --> S3_SYNC1
    VOL2A --> S3_SYNC2
    VOL2B --> S3_SYNC2
    
    S3_SYNC1 --> S3
    S3_SYNC2 --> S3
    
    style USER fill:#e3f2fd
    style LB fill:#4caf50
    style FRONT1 fill:#fff3e0
    style FRONT2 fill:#fff3e0
    style BACK1 fill:#e8f5e8
    style BACK2 fill:#e8f5e8
    style DB_PRIMARY fill:#ffebee
    style DB_REPLICA fill:#f3e5f5
    style REDIS1 fill:#e1f5fe
    style REDIS2 fill:#e1f5fe
    style S3 fill:#fce4ec
```

**서버 1 (Primary) - docker-compose.yml**:
```yaml
version: '3.8'
services:
  backend:
    image: cloudmart-backend:latest
    environment:
      # Primary DB (Write)
      DATABASE_WRITE_URL: postgresql://postgres-primary:5432/cloudmart
      # Replica DB (Read) - 서버 2의 IP
      DATABASE_READ_URL: postgresql://192.168.1.102:5432/cloudmart
      # Redis Master
      REDIS_MASTER_URL: redis://redis-master:6379
      # Redis Replica - 서버 2의 IP
      REDIS_REPLICA_URL: redis://192.168.1.102:6379

  postgres-primary:
    image: postgres:15-alpine
    environment:
      POSTGRES_REPLICATION_MODE: master
    command: |
      postgres -c wal_level=replica 
               -c max_wal_senders=3 
               -c listen_addresses='*'

  redis-master:
    image: redis:7-alpine
    command: redis-server --appendonly yes --save 900 1

  # S3 백업 (매 시간)
  s3-backup:
    image: amazon/aws-cli
    volumes:
      - postgres_data:/backup/postgres:ro
      - redis_data:/backup/redis:ro
    command: |
      sh -c "while true; do
        tar -czf /tmp/backup_$(date +%Y%m%d_%H%M%S).tar.gz /backup
        aws s3 cp /tmp/backup_*.tar.gz s3://cloudmart-backup/server1/
        rm /tmp/backup_*.tar.gz
        sleep 3600
      done"
```

**서버 2 (Replica) - docker-compose.yml**:
```yaml
version: '3.8'
services:
  backend:
    image: cloudmart-backend:latest
    environment:
      # Primary DB (Write) - 서버 1의 IP
      DATABASE_WRITE_URL: postgresql://192.168.1.101:5432/cloudmart
      # Replica DB (Read)
      DATABASE_READ_URL: postgresql://postgres-replica:5432/cloudmart
      # Redis Master - 서버 1의 IP
      REDIS_MASTER_URL: redis://192.168.1.101:6379
      # Redis Replica
      REDIS_REPLICA_URL: redis://redis-replica:6379

  postgres-replica:
    image: postgres:15-alpine
    environment:
      POSTGRES_REPLICATION_MODE: slave
      POSTGRES_MASTER_SERVICE_HOST: 192.168.1.101  # 서버 1 IP

  redis-replica:
    image: redis:7-alpine
    command: redis-server --replicaof 192.168.1.101 6379

  # S3 백업 (매 시간)
  s3-backup:
    image: amazon/aws-cli
    volumes:
      - postgres_data:/backup/postgres:ro
      - redis_data:/backup/redis:ro
    command: |
      sh -c "while true; do
        tar -czf /tmp/backup_$(date +%Y%m%d_%H%M%S).tar.gz /backup
        aws s3 cp /tmp/backup_*.tar.gz s3://cloudmart-backup/server2/
        rm /tmp/backup_*.tar.gz
        sleep 3600
      done"
```

**HAProxy 로드 밸런서 (별도 서버)**:
```conf
# haproxy.cfg
frontend http_front
    bind *:80
    default_backend http_back

backend http_back
    balance roundrobin
    option httpchk GET /health
    server server1 192.168.1.101:3000 check
    server server2 192.168.1.102:3000 check
```

**특징**:
- ✅ **진짜 Multi-AZ**: 물리적으로 분리된 2대 서버
- ✅ **자동 로드 밸런싱**: HAProxy로 트래픽 분산
- ✅ **DB Replication**: Primary(서버1) → Replica(서버2)
- ✅ **Redis Replication**: Master(서버1) → Replica(서버2)
- ✅ **S3 백업**: 매 시간 자동 백업, 양쪽 서버 모두
- ✅ **읽기 부하 분산**: Write는 Primary, Read는 Replica
- ✅ **서버 1 다운 시**: 서버 2로 트래픽 자동 전환 (HAProxy)
- ⚠️ **수동 Failover**: Primary DB 다운 시 Replica를 수동으로 Primary로 승격
- ⚠️ **네트워크 설정**: 서버 간 방화벽 설정 필요
- ⚠️ **복잡도 매우 높음**: 설정, 관리, 모니터링 복잡

**💡 이제 AWS Multi-AZ와 거의 비슷해졌습니다!**

**하지만 여전한 차이점**:
| 항목 | Docker 멀티 서버 | AWS Multi-AZ |
|------|------------------|--------------|
| **장애 조치** | 수동 (Replica 승격) | 자동 (1-2분) |
| **로드 밸런서** | HAProxy 직접 관리 | ALB 관리형 |
| **백업** | S3 Sync 스크립트 | RDS 자동 백업 |
| **모니터링** | 직접 구축 필요 | CloudWatch 통합 |
| **보안** | 방화벽 직접 설정 | Security Group |
| **확장** | 수동 서버 추가 | Auto Scaling |
| **관리 부담** | 매우 높음 | 낮음 (관리형) |
| **비용** | 서버 + 관리 인력 | 서비스 비용만 |

**🎯 핵심 인사이트**:
> "Docker Compose로 멀티 서버 구성이 가능하지만, 설정/관리/모니터링의 복잡도가 매우 높습니다. AWS Multi-AZ는 이 모든 것을 관리형 서비스로 제공하여 개발자가 비즈니스 로직에 집중할 수 있게 합니다. **이것이 바로 클라우드의 가치입니다!**"

---

**Docker Compose 멀티 서버 + 모니터링 스택 🔍**:
```mermaid
graph TB
    subgraph "모니터링 서버 (별도)"
        GRAFANA[Grafana<br/>대시보드<br/>3000포트]
        PROMETHEUS[Prometheus<br/>메트릭 수집<br/>9090포트]
        LOKI[Loki<br/>로그 수집<br/>3100포트]
        ALERTMANAGER[AlertManager<br/>알림<br/>9093포트]
    end
    
    subgraph "서버 1 (AZ-A)"
        NODE_EXP1[Node Exporter<br/>시스템 메트릭]
        CADVISOR1[cAdvisor<br/>컨테이너 메트릭]
        PROMTAIL1[Promtail<br/>로그 수집]
        APP1[애플리케이션<br/>컨테이너들]
    end
    
    subgraph "서버 2 (AZ-B)"
        NODE_EXP2[Node Exporter<br/>시스템 메트릭]
        CADVISOR2[cAdvisor<br/>컨테이너 메트릭]
        PROMTAIL2[Promtail<br/>로그 수집]
        APP2[애플리케이션<br/>컨테이너들]
    end
    
    subgraph "AWS S3"
        S3_METRICS[S3 Bucket<br/>메트릭 백업]
        S3_LOGS[S3 Bucket<br/>로그 백업]
    end
    
    NODE_EXP1 --> PROMETHEUS
    NODE_EXP2 --> PROMETHEUS
    CADVISOR1 --> PROMETHEUS
    CADVISOR2 --> PROMETHEUS
    
    PROMTAIL1 --> LOKI
    PROMTAIL2 --> LOKI
    
    PROMETHEUS --> GRAFANA
    LOKI --> GRAFANA
    PROMETHEUS --> ALERTMANAGER
    
    PROMETHEUS -.백업.-> S3_METRICS
    LOKI -.백업.-> S3_LOGS
    
    ALERTMANAGER -.알림.-> SLACK[Slack/Email]
    
    style GRAFANA fill:#ff9800
    style PROMETHEUS fill:#e8f5e8
    style LOKI fill:#e3f2fd
    style ALERTMANAGER fill:#ffebee
    style S3_METRICS fill:#fce4ec
    style S3_LOGS fill:#fce4ec
```

**모니터링 서버 - docker-compose.yml**:
```yaml
version: '3.8'
services:
  # Grafana 대시보드
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./grafana/datasources:/etc/grafana/provisioning/datasources
    networks:
      - monitoring

  # Prometheus 메트릭 수집
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=30d'
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    networks:
      - monitoring

  # Loki 로그 수집
  loki:
    image: grafana/loki:latest
    ports:
      - "3100:3100"
    command: -config.file=/etc/loki/local-config.yaml
    volumes:
      - ./loki/loki-config.yaml:/etc/loki/local-config.yaml
      - loki_data:/loki
    networks:
      - monitoring

  # AlertManager 알림
  alertmanager:
    image: prom/alertmanager:latest
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager/config.yml:/etc/alertmanager/config.yml
      - alertmanager_data:/alertmanager
    command:
      - '--config.file=/etc/alertmanager/config.yml'
      - '--storage.path=/alertmanager'
    networks:
      - monitoring

  # S3 백업 (메트릭 + 로그)
  s3-backup:
    image: amazon/aws-cli
    volumes:
      - prometheus_data:/backup/prometheus:ro
      - loki_data:/backup/loki:ro
    environment:
      AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
      AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
      AWS_DEFAULT_REGION: ap-northeast-2
    entrypoint: /bin/sh
    command: |
      -c "while true; do
        # Prometheus 메트릭 백업
        tar -czf /tmp/prometheus_$(date +%Y%m%d_%H%M%S).tar.gz /backup/prometheus
        aws s3 cp /tmp/prometheus_*.tar.gz s3://cloudmart-monitoring/prometheus/
        rm /tmp/prometheus_*.tar.gz
        
        # Loki 로그 백업
        tar -czf /tmp/loki_$(date +%Y%m%d_%H%M%S).tar.gz /backup/loki
        aws s3 cp /tmp/loki_*.tar.gz s3://cloudmart-monitoring/loki/
        rm /tmp/loki_*.tar.gz
        
        # 30일 이상 된 백업 삭제
        aws s3 ls s3://cloudmart-monitoring/prometheus/ | awk '{print \$4}' | head -n -30 | xargs -I {} aws s3 rm s3://cloudmart-monitoring/prometheus/{}
        aws s3 ls s3://cloudmart-monitoring/loki/ | awk '{print \$4}' | head -n -30 | xargs -I {} aws s3 rm s3://cloudmart-monitoring/loki/{}
        
        sleep 3600
      done"

networks:
  monitoring:
    driver: bridge

volumes:
  grafana_data:
  prometheus_data:
  loki_data:
  alertmanager_data:
```

**서버 1/2 - 모니터링 에이전트 추가**:
```yaml
version: '3.8'
services:
  # 기존 애플리케이션 서비스들...
  
  # Node Exporter (시스템 메트릭)
  node-exporter:
    image: prom/node-exporter:latest
    ports:
      - "9100:9100"
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    networks:
      - monitoring

  # cAdvisor (컨테이너 메트릭)
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
    networks:
      - monitoring

  # Promtail (로그 수집)
  promtail:
    image: grafana/promtail:latest
    volumes:
      - /var/log:/var/log:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - ./promtail/promtail-config.yaml:/etc/promtail/config.yml
    command: -config.file=/etc/promtail/config.yml
    networks:
      - monitoring

networks:
  monitoring:
    external: true
```

**prometheus.yml (Prometheus 설정)**:
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

# AlertManager 설정
alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']

# 알림 규칙
rule_files:
  - '/etc/prometheus/alerts/*.yml'

# 메트릭 수집 대상
scrape_configs:
  # Prometheus 자체 모니터링
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # 서버 1 (AZ-A)
  - job_name: 'server1-node'
    static_configs:
      - targets: ['192.168.1.101:9100']
        labels:
          server: 'server1'
          az: 'az-a'

  - job_name: 'server1-cadvisor'
    static_configs:
      - targets: ['192.168.1.101:8080']
        labels:
          server: 'server1'
          az: 'az-a'

  # 서버 2 (AZ-B)
  - job_name: 'server2-node'
    static_configs:
      - targets: ['192.168.1.102:9100']
        labels:
          server: 'server2'
          az: 'az-b'

  - job_name: 'server2-cadvisor'
    static_configs:
      - targets: ['192.168.1.102:8080']
        labels:
          server: 'server2'
          az: 'az-b'

  # PostgreSQL Exporter (선택)
  - job_name: 'postgres'
    static_configs:
      - targets: ['192.168.1.101:9187', '192.168.1.102:9187']

  # Redis Exporter (선택)
  - job_name: 'redis'
    static_configs:
      - targets: ['192.168.1.101:9121', '192.168.1.102:9121']
```

**alerts.yml (알림 규칙)**:
```yaml
groups:
  - name: instance_alerts
    interval: 30s
    rules:
      # 서버 다운 알림
      - alert: InstanceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Instance {{ $labels.instance }} down"
          description: "{{ $labels.instance }} has been down for more than 1 minute."

      # CPU 사용률 높음
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage on {{ $labels.instance }}"
          description: "CPU usage is above 80% for 5 minutes."

      # 메모리 사용률 높음
      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage on {{ $labels.instance }}"
          description: "Memory usage is above 80% for 5 minutes."

      # 디스크 사용률 높음
      - alert: HighDiskUsage
        expr: (node_filesystem_size_bytes - node_filesystem_free_bytes) / node_filesystem_size_bytes * 100 > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High disk usage on {{ $labels.instance }}"
          description: "Disk usage is above 80% for 5 minutes."

      # PostgreSQL 다운
      - alert: PostgreSQLDown
        expr: pg_up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "PostgreSQL down on {{ $labels.instance }}"
          description: "PostgreSQL has been down for more than 1 minute."

      # Redis 다운
      - alert: RedisDown
        expr: redis_up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Redis down on {{ $labels.instance }}"
          description: "Redis has been down for more than 1 minute."
```

**alertmanager/config.yml (알림 채널 설정)**:
```yaml
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname', 'cluster', 'service']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
  receiver: 'slack-notifications'

receivers:
  # Slack 알림
  - name: 'slack-notifications'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'
        channel: '#cloudmart-alerts'
        title: '{{ .GroupLabels.alertname }}'
        text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'

  # Email 알림
  - name: 'email-notifications'
    email_configs:
      - to: 'devops@cloudmart.com'
        from: 'alertmanager@cloudmart.com'
        smarthost: 'smtp.gmail.com:587'
        auth_username: 'alertmanager@cloudmart.com'
        auth_password: 'your-password'
```

**모니터링 스택 특징**:
- ✅ **Prometheus**: 메트릭 수집 및 저장 (CPU, 메모리, 디스크, 네트워크)
- ✅ **Grafana**: 시각화 대시보드 (실시간 차트, 그래프)
- ✅ **Loki**: 로그 수집 및 검색 (모든 컨테이너 로그)
- ✅ **AlertManager**: 알림 (Slack, Email)
- ✅ **Node Exporter**: 시스템 메트릭 (서버 1, 2)
- ✅ **cAdvisor**: 컨테이너 메트릭 (Docker 컨테이너)
- ✅ **Promtail**: 로그 수집 에이전트
- ✅ **S3 백업**: 메트릭 + 로그 30일 보관

**💡 모니터링 vs AWS CloudWatch 비교**:
| 항목 | Docker 모니터링 스택 | AWS CloudWatch |
|------|---------------------|----------------|
| **메트릭 수집** | Prometheus (직접 설정) | 자동 수집 |
| **로그 수집** | Loki + Promtail (직접 설정) | 자동 수집 |
| **대시보드** | Grafana (직접 구축) | 기본 제공 |
| **알림** | AlertManager (직접 설정) | CloudWatch Alarms |
| **백업** | S3 Sync 스크립트 | 자동 보관 |
| **설정 복잡도** | 매우 높음 | 낮음 (자동) |
| **비용** | 서버 비용 + 스토리지 | 메트릭/로그당 과금 |
| **커스터마이징** | 완전한 제어 | 제한적 |

**🎯 핵심 인사이트**:
> "Docker Compose로 Prometheus + Grafana + Loki 모니터링 스택을 구축할 수 있지만, 설정/관리/유지보수의 복잡도가 매우 높습니다. AWS CloudWatch는 이 모든 것을 자동으로 제공하며, 추가 설정 없이 즉시 사용 가능합니다. **관리형 서비스의 진정한 가치는 복잡도 제거입니다!**"

---

**AWS Multi-AZ (프로덕션 - 고가용성)**:

**CloudMart VPC 설계**:
```mermaid
graph TB
    VPC[VPC: 10.0.0.0/16<br/>65,536개 IP]
    
    VPC --> AZA[AZ-A<br/>ap-northeast-2a]
    VPC --> AZB[AZ-B<br/>ap-northeast-2b]
    
    AZA --> PUB1[Public Subnet<br/>10.0.1.0/24<br/>256개 IP]
    AZA --> PRIV1[Private Subnet<br/>10.0.11.0/24<br/>256개 IP]
    
    AZB --> PUB2[Public Subnet<br/>10.0.2.0/24<br/>256개 IP]
    AZB --> PRIV2[Private Subnet<br/>10.0.12.0/24<br/>256개 IP]
    
    PUB1 --> RES1[ALB<br/>NAT Gateway]
    PRIV1 --> RES2[EC2 Backend<br/>RDS Primary<br/>ElastiCache]
    
    PUB2 --> RES3[ALB<br/>NAT Gateway]
    PRIV2 --> RES4[EC2 Backend<br/>RDS Standby<br/>ElastiCache]
    
    style VPC fill:#4caf50
    style AZA fill:#e3f2fd
    style AZB fill:#e3f2fd
    style PUB1 fill:#fff3e0
    style PUB2 fill:#fff3e0
    style PRIV1 fill:#e8f5e8
    style PRIV2 fill:#e8f5e8
    style RES1 fill:#ffebee
    style RES2 fill:#f3e5f5
    style RES3 fill:#ffebee
    style RES4 fill:#f3e5f5
```

**특징**:
- ✅ **고가용성**: AZ 하나가 다운되어도 서비스 지속
- ✅ **자동 확장**: Auto Scaling으로 트래픽 대응
- ✅ **보안 강화**: Private Subnet으로 DB/Cache 격리
- ✅ **관리형 서비스**: RDS, ElastiCache 자동 백업/패치
- ❌ **복잡도 증가**: 설정 및 관리 복잡
- ❌ **비용 발생**: 시간당 $0.124 (월 $89.28)

---

**📊 상세 비교표**:

| 항목 | Docker Compose | AWS Multi-AZ | 차이점 |
|------|----------------|--------------|--------|
| **네트워크** | 단일 bridge 네트워크 | VPC + Multi-AZ Subnet | 격리 및 분산 |
| **Frontend** | 1개 컨테이너 (3000포트) | S3 + CloudFront (글로벌 CDN) | 정적 파일 최적화 |
| **Backend** | 1개 컨테이너 (8080포트) | ALB + EC2 ASG (2-10개) | 로드밸런싱 + 자동 확장 |
| **Database** | 1개 컨테이너 (5432포트) | RDS Multi-AZ (Primary + Standby) | 자동 장애 조치 |
| **Cache** | 1개 컨테이너 (6379포트) | ElastiCache 클러스터 | 고가용성 캐시 |
| **스토리지** | 로컬 볼륨 (postgres_data) | EBS + 자동 백업 | 데이터 영속성 보장 |
| **가용성** | 단일 서버 (99% 미만) | Multi-AZ (99.99%) | 4배 향상 |
| **확장성** | 수동 (서버 업그레이드) | 자동 (ASG) | 트래픽 대응 |
| **비용** | $0 (로컬) | $89.28/월 | 프로덕션 비용 |
| **배포 시간** | 1분 (docker-compose up) | 5-10분 (롤링 배포) | 안정성 우선 |

---

**네트워크 구성 다이어그램**:
```mermaid
graph TB
    subgraph "VPC 10.0.0.0/16"
        IGW[Internet Gateway]
        
        subgraph "AZ-A"
            PUB1[Public Subnet<br/>10.0.1.0/24]
            PRIV1[Private Subnet<br/>10.0.11.0/24]
            NAT1[NAT Gateway]
            
            PUB1 --> NAT1
            NAT1 --> PRIV1
        end
        
        subgraph "AZ-B"
            PUB2[Public Subnet<br/>10.0.2.0/24]
            PRIV2[Private Subnet<br/>10.0.12.0/24]
            NAT2[NAT Gateway]
            
            PUB2 --> NAT2
            NAT2 --> PRIV2
        end
        
        IGW --> PUB1
        IGW --> PUB2
    end
    
    style IGW fill:#4caf50
    style PUB1 fill:#fff3e0
    style PUB2 fill:#fff3e0
    style PRIV1 fill:#e8f5e8
    style PRIV2 fill:#e8f5e8
```

**Subnet 설계 원칙**:
- **Public Subnet**: 인터넷 접근 가능 (ALB, NAT Gateway)
- **Private Subnet**: 인터넷 직접 접근 불가 (Backend, DB, Cache)
- **CIDR 블록**: /24 (256개 IP) - 충분한 여유 확보
- **AZ 분산**: 각 AZ에 동일한 구조 배치

**Route Table 설정**:
```yaml
Public Route Table:
  - 10.0.0.0/16 → local (VPC 내부 통신)
  - 0.0.0.0/0 → Internet Gateway (외부 인터넷)

Private Route Table (AZ-A):
  - 10.0.0.0/16 → local
  - 0.0.0.0/0 → NAT Gateway (AZ-A)

Private Route Table (AZ-B):
  - 10.0.0.0/16 → local
  - 0.0.0.0/0 → NAT Gateway (AZ-B)
```

### 🔍 개념 2: RDS Multi-AZ 데이터베이스 구성 (12분)

> **정의**: 자동 장애 조치를 지원하는 고가용성 관계형 데이터베이스

**RDS Multi-AZ 동작 원리**:
```mermaid
sequenceDiagram
    participant App as Backend API
    participant Primary as RDS Primary<br/>(AZ-A)
    participant Standby as RDS Standby<br/>(AZ-B)
    
    Note over Primary,Standby: 정상 상태
    App->>Primary: 1. 쓰기 요청
    Primary->>Standby: 2. 동기 복제
    Standby-->>Primary: 3. 복제 완료
    Primary-->>App: 4. 응답
    
    Note over Primary: 장애 발생!
    
    Note over Standby: 자동 승격
    App->>Standby: 5. 자동 연결 전환
    Standby-->>App: 6. 정상 응답
```

**CloudMart RDS 설정**:
```yaml
RDS PostgreSQL 설정:
  Engine: PostgreSQL 15
  Instance Class: db.t3.micro (프리티어)
  Storage: 20GB gp3 (범용 SSD)
  Multi-AZ: Enabled (자동 장애 조치)
  
  Backup:
    Automated Backup: 7일 보관
    Backup Window: 03:00-04:00 (새벽)
    Maintenance Window: 일요일 04:00-05:00
  
  Security:
    Encryption: Enabled (저장 데이터 암호화)
    Public Access: Disabled (Private Subnet만)
    Security Group: Backend만 접근 허용
```

**연결 문자열 예시**:
```javascript
// Backend 환경 변수
DATABASE_URL=postgresql://cloudmart_user:password@cloudmart-db.xxxxx.ap-northeast-2.rds.amazonaws.com:5432/cloudmart

// Node.js 연결 코드
const { Pool } = require('pg');
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false // RDS SSL 인증서
  },
  max: 20, // 최대 연결 수
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});
```

**Multi-AZ 장점**:
- **자동 장애 조치**: 1-2분 내 자동 전환
- **동기 복제**: 데이터 손실 없음
- **자동 백업**: 스냅샷 자동 생성
- **유지보수**: 무중단 패치 적용

### 🔍 개념 3: ElastiCache Redis 클러스터 구성 (11분)

> **정의**: 고성능 인메모리 캐싱 및 세션 스토어

**ElastiCache 아키텍처**:
```mermaid
graph TB
    subgraph "Backend API 서버"
        A1[EC2-1] --> C[ElastiCache<br/>Redis Cluster]
        A2[EC2-2] --> C
        A3[EC2-3] --> C
    end
    
    subgraph "Redis Cluster"
        C --> D1[Primary Node<br/>AZ-A]
        C --> D2[Replica Node<br/>AZ-B]
        D1 -.비동기 복제.-> D2
    end
    
    subgraph "사용 사례"
        E1[세션 데이터<br/>공유]
        E2[API 응답<br/>캐싱]
        E3[상품 정보<br/>캐싱]
    end
    
    style C fill:#4caf50
    style D1 fill:#e8f5e8
    style D2 fill:#fff3e0
```

**CloudMart Redis 설정**:
```yaml
ElastiCache Redis 설정:
  Engine: Redis 7.0
  Node Type: cache.t3.micro (프리티어)
  Number of Replicas: 1 (Primary + 1 Replica)
  Multi-AZ: Enabled
  
  Configuration:
    Max Memory Policy: allkeys-lru (메모리 부족 시 LRU 삭제)
    Timeout: 300 (5분 유휴 연결 종료)
    
  Security:
    Encryption in Transit: Enabled (전송 중 암호화)
    Encryption at Rest: Enabled (저장 데이터 암호화)
    Security Group: Backend만 접근 허용
```

**Redis 활용 예시**:
```javascript
// Backend에서 Redis 사용
const redis = require('redis');
const client = redis.createClient({
  url: `redis://${process.env.REDIS_ENDPOINT}:6379`,
  socket: {
    tls: true, // ElastiCache 암호화 연결
    rejectUnauthorized: false
  }
});

// 1. 세션 저장
await client.set(`session:${userId}`, JSON.stringify(sessionData), {
  EX: 3600 // 1시간 후 만료
});

// 2. 상품 정보 캐싱
const cacheKey = `product:${productId}`;
let product = await client.get(cacheKey);

if (!product) {
  // 캐시 미스 - DB에서 조회
  product = await db.query('SELECT * FROM products WHERE id = $1', [productId]);
  await client.set(cacheKey, JSON.stringify(product), {
    EX: 600 // 10분 캐싱
  });
}

// 3. API Rate Limiting
const rateLimitKey = `ratelimit:${userId}`;
const count = await client.incr(rateLimitKey);
if (count === 1) {
  await client.expire(rateLimitKey, 60); // 1분 윈도우
}
if (count > 100) {
  throw new Error('Rate limit exceeded');
}
```

**캐싱 전략**:
- **Cache-Aside**: 애플리케이션이 캐시 관리
- **TTL 설정**: 데이터 특성에 따라 만료 시간 조정
- **Invalidation**: 데이터 변경 시 캐시 무효화

## 💭 함께 생각해보기 (10분)

### 🤝 페어 토론 (5분)

**토론 주제**:
1. **AZ 선택**: "2개 AZ로 충분할까요? 3개 AZ가 필요한 경우는?"
2. **비용 vs 안정성**: "NAT Gateway를 1개만 쓰면 비용이 절반인데, 괜찮을까요?"
3. **캐싱 전략**: "어떤 데이터를 Redis에 캐싱하면 효과적일까요?"

**페어 활동 가이드**:
- 👥 **자유 페어링**: 인프라 경험이 비슷한 사람끼리
- 🔄 **역할 교대**: 3분씩 설명자/질문자 역할 바꾸기
- 📝 **핵심 정리**: 인프라 설계 체크리스트 작성

### 🎯 전체 공유 (5분)

**인사이트 공유**:
- 페어 토론에서 나온 인프라 설계 아이디어
- 비용과 안정성의 균형점
- 실무에서 적용 가능한 최적화 방법

**💡 이해도 체크 질문**:
- ✅ "Multi-AZ 구성이 Single-AZ보다 안전한 이유는 무엇인가요?"
- ✅ "RDS Multi-AZ에서 장애 조치는 어떻게 이루어지나요?"
- ✅ "Redis를 사용하면 어떤 성능 향상을 기대할 수 있나요?"

## 🔑 핵심 키워드

### 🆕 새로운 용어
- **Multi-AZ**: 여러 가용 영역에 리소스를 분산 배치하여 고가용성 확보
- **Failover**: 장애 발생 시 대기 시스템으로 자동 전환하는 메커니즘
- **Synchronous Replication**: 동기 복제 - 데이터 손실 없이 실시간 복제

### 🔧 중요 개념
- **Private Subnet**: 인터넷 직접 접근 불가, NAT Gateway 통해서만 외부 통신
- **NAT Gateway**: Private Subnet의 리소스가 외부 인터넷에 접근하기 위한 게이트웨이
- **Cache-Aside Pattern**: 애플리케이션이 캐시를 직접 관리하는 패턴

### 💼 실무 용어
- **RPO (Recovery Point Objective)**: 데이터 손실 허용 시간 (Multi-AZ는 RPO=0)
- **RTO (Recovery Time Objective)**: 복구 목표 시간 (Multi-AZ는 RTO=1-2분)
- **Connection Pooling**: 데이터베이스 연결을 재사용하여 성능 향상

## 📝 세션 마무리

### ✅ 오늘 세션 성과
- **네트워크 설계**: Multi-AZ VPC 아키텍처 완전 이해
- **데이터베이스**: RDS Multi-AZ 고가용성 구성 방법 습득
- **캐싱 전략**: ElastiCache Redis 활용 방안 파악

### 🎯 다음 세션 준비
- **Session 3 주제**: 모니터링 & 로깅 (CloudWatch, X-Ray)
- **연결 내용**: 구축한 인프라의 상태를 실시간으로 모니터링
- **사전 생각**: "서버가 정상인지 어떻게 알 수 있을까요?"

### 🔗 실습 연계
- **Lab 1**: 오늘 배운 인프라를 실제로 AWS에 구축
- **Challenge**: 프로덕션급 완성도로 전체 시스템 완성

---

<div align="center">

**🏗️ 인프라 설계 완료** • **💾 고가용성 확보** • **⚡ 성능 최적화**

*다음 세션에서는 모니터링과 로깅을 구축해보겠습니다!*

</div>
