# Week 2 Day 2 Session 3: 데이터베이스 컨테이너 운영 실무

<div align="center">

**🗄️ DB 컨테이너 운영** • **⚡ 성능 최적화** • **🔄 클러스터링**

*Stateful 애플리케이션의 컨테이너 운영 노하우 습득*

</div>

---

## 🕘 세션 정보

**시간**: 11:00-11:50 (50분)  
**목표**: Stateful 애플리케이션의 컨테이너 운영 노하우 습득  
**방식**: 실무 사례 + 성능 튜닝 + 고가용성 구성

---

## 🎯 세션 목표

### 📚 학습 목표
- **이해 목표**: 데이터베이스 컨테이너의 특수성과 운영 고려사항 이해
- **적용 목표**: 프로덕션급 데이터베이스 컨테이너 구성과 튜닝 능력
- **협업 목표**: DBA와 DevOps 엔지니어 간 협업 방안 이해

### 🤔 왜 필요한가? (5분)

**현실 문제 상황**:
- 💼 **성능 저하**: 잘못된 DB 컨테이너 설정으로 인한 50% 성능 저하
- 🏠 **일상 비유**: 귀중품을 안전하게 보관하면서도 쉽게 접근할 수 있게 하는 것
- 📊 **시장 동향**: 컨테이너 기반 데이터베이스 도입 증가 (2024년 60% 증가)

**Stateful vs Stateless 비교**:
```mermaid
graph TB
    subgraph "Stateless Applications"
        A[웹 서버]
        B[API 서버]
        C[로드 밸런서]
    end
    
    subgraph "Stateful Applications"
        D[데이터베이스]
        E[파일 시스템]
        F[세션 스토어]
    end
    
    subgraph "특징 비교"
        G[쉬운 스케일링<br/>빠른 재시작<br/>단순한 배포]
        H[복잡한 스케일링<br/>신중한 재시작<br/>데이터 일관성]
    end
    
    A --> G
    B --> G
    C --> G
    
    D --> H
    E --> H
    F --> H
    
    style A,B,C fill:#e8f5e8
    style D,E,F fill:#fff3e0
    style G fill:#4caf50
    style H fill:#ff9800
```

---

## 📖 핵심 개념 (35분)

### 🔍 개념 1: 데이터베이스별 컨테이너 최적화 (12분)

> **정의**: MySQL, PostgreSQL, MongoDB 등 각 데이터베이스의 특성에 맞는 컨테이너 설정

**MySQL 컨테이너 최적화**:
```bash
# 프로덕션급 MySQL 설정
docker run -d \
  --name mysql-prod \
  --restart=unless-stopped \
  -p 3306:3306 \
  -v mysql-data:/var/lib/mysql \
  -v mysql-config:/etc/mysql/conf.d \
  -v mysql-logs:/var/log/mysql \
  --tmpfs /tmp:rw,noexec,nosuid,size=2g \
  -e MYSQL_ROOT_PASSWORD_FILE=/run/secrets/mysql_root_password \
  -e MYSQL_DATABASE=production \
  -e MYSQL_USER=appuser \
  -e MYSQL_PASSWORD_FILE=/run/secrets/mysql_user_password \
  --memory=4g \
  --memory-swap=4g \
  --cpus=2.0 \
  --ulimit nofile=65536:65536 \
  --security-opt no-new-privileges:true \
  mysql:8.0 \
  --character-set-server=utf8mb4 \
  --collation-server=utf8mb4_unicode_ci \
  --innodb-buffer-pool-size=2G \
  --innodb-log-file-size=256M \
  --innodb-flush-log-at-trx-commit=2 \
  --max-connections=200 \
  --query-cache-size=0 \
  --query-cache-type=0
```

**MySQL 설정 파일 (my.cnf)**:
```ini
[mysqld]
# 기본 설정
bind-address = 0.0.0.0
port = 3306
datadir = /var/lib/mysql
socket = /var/run/mysqld/mysqld.sock

# 문자셋
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# InnoDB 설정
innodb_buffer_pool_size = 2G
innodb_log_file_size = 256M
innodb_log_buffer_size = 64M
innodb_flush_log_at_trx_commit = 2
innodb_file_per_table = 1
innodb_open_files = 400

# 연결 설정
max_connections = 200
max_connect_errors = 1000
wait_timeout = 600
interactive_timeout = 600

# 쿼리 캐시 (MySQL 8.0에서는 제거됨)
query_cache_type = 0
query_cache_size = 0

# 로깅
general_log = 1
general_log_file = /var/log/mysql/general.log
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 2

# 보안
local_infile = 0
secure_file_priv = /var/lib/mysql-files/

# 복제 설정 (Master)
server-id = 1
log-bin = mysql-bin
binlog_format = ROW
expire_logs_days = 7
```

**PostgreSQL 컨테이너 최적화**:
```bash
# 프로덕션급 PostgreSQL 설정
docker run -d \
  --name postgres-prod \
  --restart=unless-stopped \
  -p 5432:5432 \
  -v postgres-data:/var/lib/postgresql/data \
  -v postgres-config:/etc/postgresql \
  --tmpfs /tmp:rw,noexec,nosuid,size=1g \
  -e POSTGRES_DB=production \
  -e POSTGRES_USER=appuser \
  -e POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password \
  -e PGDATA=/var/lib/postgresql/data/pgdata \
  --memory=4g \
  --memory-swap=4g \
  --cpus=2.0 \
  --shm-size=1g \
  postgres:15 \
  -c shared_buffers=1GB \
  -c effective_cache_size=3GB \
  -c maintenance_work_mem=256MB \
  -c checkpoint_completion_target=0.9 \
  -c wal_buffers=16MB \
  -c default_statistics_target=100 \
  -c random_page_cost=1.1 \
  -c effective_io_concurrency=200 \
  -c work_mem=4MB \
  -c min_wal_size=1GB \
  -c max_wal_size=4GB
```

**MongoDB 컨테이너 최적화**:
```bash
# 프로덕션급 MongoDB 설정
docker run -d \
  --name mongo-prod \
  --restart=unless-stopped \
  -p 27017:27017 \
  -v mongo-data:/data/db \
  -v mongo-config:/data/configdb \
  --tmpfs /tmp:rw,noexec,nosuid,size=1g \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD_FILE=/run/secrets/mongo_root_password \
  -e MONGO_INITDB_DATABASE=production \
  --memory=4g \
  --memory-swap=4g \
  --cpus=2.0 \
  mongo:7.0 \
  --wiredTigerCacheSizeGB 2 \
  --wiredTigerCollectionBlockCompressor snappy \
  --wiredTigerIndexPrefixCompression true
```

### 🔍 개념 2: 성능 모니터링과 튜닝 (12분)

> **정의**: 데이터베이스 컨테이너의 성능을 실시간으로 모니터링하고 최적화하는 방법

**성능 메트릭 모니터링**:
```mermaid
graph TB
    subgraph "시스템 메트릭"
        A[CPU 사용률]
        B[메모리 사용률]
        C[디스크 I/O]
        D[네트워크 I/O]
    end
    
    subgraph "데이터베이스 메트릭"
        E[쿼리 응답시간]
        F[연결 수]
        G[트랜잭션/초]
        H[캐시 히트율]
    end
    
    subgraph "비즈니스 메트릭"
        I[처리량]
        J[가용성]
        K[오류율]
        L[사용자 경험]
    end
    
    A --> E --> I
    B --> F --> J
    C --> G --> K
    D --> H --> L
    
    style A fill:#e3f2fd
    style B fill:#e3f2fd
    style C fill:#e3f2fd
    style D fill:#e3f2fd
    style E fill:#fff3e0
    style F fill:#fff3e0
    style G fill:#fff3e0
    style H fill:#fff3e0
    style I fill:#e8f5e8
    style J fill:#e8f5e8
    style K fill:#e8f5e8
    style L fill:#e8f5e8
```

**모니터링 스택 구성**:
```yaml
# docker-compose.monitoring.yml
version: '3.8'

services:
  # Prometheus - 메트릭 수집
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'

  # Grafana - 시각화
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    volumes:
      - grafana-data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123

  # MySQL Exporter
  mysql-exporter:
    image: prom/mysqld-exporter:latest
    ports:
      - "9104:9104"
    environment:
      - DATA_SOURCE_NAME=exporter:password@(mysql-prod:3306)/
    depends_on:
      - mysql-prod

  # PostgreSQL Exporter
  postgres-exporter:
    image: prometheuscommunity/postgres-exporter:latest
    ports:
      - "9187:9187"
    environment:
      - DATA_SOURCE_NAME=postgresql://exporter:password@postgres-prod:5432/production?sslmode=disable
    depends_on:
      - postgres-prod

volumes:
  prometheus-data:
  grafana-data:
```

**성능 튜닝 스크립트**:
```bash
#!/bin/bash
# db-performance-tuning.sh

DB_TYPE=$1
CONTAINER_NAME=$2

case $DB_TYPE in
    "mysql")
        tune_mysql $CONTAINER_NAME
        ;;
    "postgres")
        tune_postgres $CONTAINER_NAME
        ;;
    "mongo")
        tune_mongo $CONTAINER_NAME
        ;;
    *)
        echo "Usage: $0 {mysql|postgres|mongo} container_name"
        exit 1
        ;;
esac

tune_mysql() {
    local container=$1
    
    echo "=== MySQL 성능 튜닝 시작 ==="
    
    # 현재 설정 확인
    docker exec $container mysql -u root -p -e "SHOW VARIABLES LIKE 'innodb_buffer_pool_size';"
    docker exec $container mysql -u root -p -e "SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool_read_requests';"
    
    # 슬로우 쿼리 분석
    docker exec $container mysql -u root -p -e "SELECT * FROM mysql.slow_log ORDER BY start_time DESC LIMIT 10;"
    
    # 인덱스 사용률 확인
    docker exec $container mysql -u root -p -e "
        SELECT 
            table_schema,
            table_name,
            index_name,
            cardinality
        FROM information_schema.statistics 
        WHERE table_schema NOT IN ('mysql', 'information_schema', 'performance_schema')
        ORDER BY cardinality DESC;
    "
    
    echo "=== MySQL 튜닝 권장사항 ==="
    echo "1. innodb_buffer_pool_size: 전체 메모리의 70-80%"
    echo "2. 슬로우 쿼리 최적화 필요"
    echo "3. 인덱스 추가 검토 필요"
}

tune_postgres() {
    local container=$1
    
    echo "=== PostgreSQL 성능 튜닝 시작 ==="
    
    # 현재 설정 확인
    docker exec $container psql -U postgres -c "SHOW shared_buffers;"
    docker exec $container psql -U postgres -c "SHOW effective_cache_size;"
    
    # 슬로우 쿼리 분석
    docker exec $container psql -U postgres -c "
        SELECT query, calls, total_time, mean_time 
        FROM pg_stat_statements 
        ORDER BY total_time DESC 
        LIMIT 10;
    "
    
    # 인덱스 사용률 확인
    docker exec $container psql -U postgres -c "
        SELECT 
            schemaname,
            tablename,
            indexname,
            idx_tup_read,
            idx_tup_fetch
        FROM pg_stat_user_indexes 
        ORDER BY idx_tup_read DESC;
    "
    
    echo "=== PostgreSQL 튜닝 권장사항 ==="
    echo "1. shared_buffers: 전체 메모리의 25%"
    echo "2. effective_cache_size: 전체 메모리의 75%"
    echo "3. work_mem: 동시 연결 수 고려하여 설정"
}

tune_mongo() {
    local container=$1
    
    echo "=== MongoDB 성능 튜닝 시작 ==="
    
    # 현재 설정 확인
    docker exec $container mongo --eval "db.serverStatus().wiredTiger.cache"
    
    # 슬로우 쿼리 분석
    docker exec $container mongo --eval "db.setProfilingLevel(2, {slowms: 100})"
    docker exec $container mongo --eval "db.system.profile.find().sort({ts: -1}).limit(10)"
    
    # 인덱스 사용률 확인
    docker exec $container mongo --eval "
        db.runCommand({listCollections: 1}).cursor.firstBatch.forEach(
            function(collection) {
                print('Collection: ' + collection.name);
                db[collection.name].getIndexes().forEach(printjson);
            }
        )
    "
    
    echo "=== MongoDB 튜닝 권장사항 ==="
    echo "1. wiredTigerCacheSizeGB: 전체 메모리의 50%"
    echo "2. 적절한 인덱스 생성"
    echo "3. 샤딩 고려 (대용량 데이터)"
}
```

### 🔍 개념 3: 고가용성과 클러스터링 (11분)

> **정의**: 데이터베이스의 가용성을 높이기 위한 복제, 클러스터링, 페일오버 구성

**MySQL 마스터-슬레이브 복제**:
```yaml
# docker-compose.mysql-cluster.yml
version: '3.8'

services:
  mysql-master:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: production
      MYSQL_USER: appuser
      MYSQL_PASSWORD: apppassword
    volumes:
      - mysql-master-data:/var/lib/mysql
      - ./mysql-master.cnf:/etc/mysql/conf.d/mysql.cnf
    ports:
      - "3306:3306"
    command: --server-id=1 --log-bin=mysql-bin --binlog-format=ROW

  mysql-slave1:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: production
      MYSQL_USER: appuser
      MYSQL_PASSWORD: apppassword
    volumes:
      - mysql-slave1-data:/var/lib/mysql
      - ./mysql-slave.cnf:/etc/mysql/conf.d/mysql.cnf
    ports:
      - "3307:3306"
    command: --server-id=2 --relay-log=mysql-relay-bin --log-slave-updates=1
    depends_on:
      - mysql-master

  mysql-slave2:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: production
      MYSQL_USER: appuser
      MYSQL_PASSWORD: apppassword
    volumes:
      - mysql-slave2-data:/var/lib/mysql
      - ./mysql-slave.cnf:/etc/mysql/conf.d/mysql.cnf
    ports:
      - "3308:3306"
    command: --server-id=3 --relay-log=mysql-relay-bin --log-slave-updates=1
    depends_on:
      - mysql-master

  # ProxySQL for Load Balancing
  proxysql:
    image: proxysql/proxysql:latest
    ports:
      - "6032:6032"  # Admin interface
      - "6033:6033"  # MySQL interface
    volumes:
      - ./proxysql.cnf:/etc/proxysql.cnf
    depends_on:
      - mysql-master
      - mysql-slave1
      - mysql-slave2

volumes:
  mysql-master-data:
  mysql-slave1-data:
  mysql-slave2-data:
```

**PostgreSQL 스트리밍 복제**:
```yaml
# docker-compose.postgres-cluster.yml
version: '3.8'

services:
  postgres-primary:
    image: postgres:15
    environment:
      POSTGRES_DB: production
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
      POSTGRES_REPLICATION_USER: replicator
      POSTGRES_REPLICATION_PASSWORD: replicator_password
    volumes:
      - postgres-primary-data:/var/lib/postgresql/data
      - ./postgresql-primary.conf:/etc/postgresql/postgresql.conf
      - ./pg_hba.conf:/etc/postgresql/pg_hba.conf
    ports:
      - "5432:5432"
    command: postgres -c config_file=/etc/postgresql/postgresql.conf

  postgres-standby1:
    image: postgres:15
    environment:
      POSTGRES_DB: production
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
      PGUSER: postgres
    volumes:
      - postgres-standby1-data:/var/lib/postgresql/data
      - ./postgresql-standby.conf:/etc/postgresql/postgresql.conf
    ports:
      - "5433:5432"
    depends_on:
      - postgres-primary
    command: |
      bash -c "
      if [ ! -f /var/lib/postgresql/data/PG_VERSION ]; then
        pg_basebackup -h postgres-primary -D /var/lib/postgresql/data -U replicator -W
        echo 'standby_mode = on' >> /var/lib/postgresql/data/recovery.conf
        echo 'primary_conninfo = ''host=postgres-primary port=5432 user=replicator''' >> /var/lib/postgresql/data/recovery.conf
      fi
      postgres -c config_file=/etc/postgresql/postgresql.conf
      "

  # PgBouncer for Connection Pooling
  pgbouncer:
    image: pgbouncer/pgbouncer:latest
    ports:
      - "6432:6432"
    volumes:
      - ./pgbouncer.ini:/etc/pgbouncer/pgbouncer.ini
      - ./userlist.txt:/etc/pgbouncer/userlist.txt
    depends_on:
      - postgres-primary
      - postgres-standby1

volumes:
  postgres-primary-data:
  postgres-standby1-data:
```

**자동 페일오버 스크립트**:
```bash
#!/bin/bash
# auto-failover.sh

MASTER_HOST="mysql-master"
SLAVE_HOST="mysql-slave1"
VIP="192.168.1.100"  # Virtual IP

check_master_health() {
    docker exec mysql-master mysqladmin ping -u root -p${MYSQL_ROOT_PASSWORD} >/dev/null 2>&1
    return $?
}

promote_slave_to_master() {
    echo "Promoting slave to master..."
    
    # 슬레이브에서 복제 중지
    docker exec mysql-slave1 mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "STOP SLAVE;"
    
    # 슬레이브를 마스터로 승격
    docker exec mysql-slave1 mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "RESET MASTER;"
    
    # VIP 이동
    ip addr del ${VIP}/24 dev eth0 2>/dev/null
    docker exec mysql-slave1 ip addr add ${VIP}/24 dev eth0
    
    # 애플리케이션에 알림
    curl -X POST -H 'Content-type: application/json' \
        --data '{"text":"🚨 Database Failover: Slave promoted to Master"}' \
        $SLACK_WEBHOOK_URL
    
    echo "Failover completed"
}

# 메인 모니터링 루프
while true; do
    if ! check_master_health; then
        echo "Master is down! Starting failover..."
        promote_slave_to_master
        break
    fi
    
    sleep 30
done
```

**데이터베이스 클러스터 모니터링**:
```bash
#!/bin/bash
# cluster-monitoring.sh

monitor_mysql_cluster() {
    echo "=== MySQL 클러스터 상태 ==="
    
    # 마스터 상태
    echo "Master Status:"
    docker exec mysql-master mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "SHOW MASTER STATUS;"
    
    # 슬레이브 상태
    echo "Slave Status:"
    docker exec mysql-slave1 mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "SHOW SLAVE STATUS\G" | grep -E "(Slave_IO_Running|Slave_SQL_Running|Seconds_Behind_Master)"
    
    # 복제 지연 확인
    DELAY=$(docker exec mysql-slave1 mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "SHOW SLAVE STATUS\G" | grep "Seconds_Behind_Master" | awk '{print $2}')
    
    if [ "$DELAY" -gt 60 ]; then
        echo "WARNING: Replication delay is ${DELAY} seconds"
    fi
}

monitor_postgres_cluster() {
    echo "=== PostgreSQL 클러스터 상태 ==="
    
    # Primary 상태
    echo "Primary Status:"
    docker exec postgres-primary psql -U postgres -c "SELECT * FROM pg_stat_replication;"
    
    # Standby 상태
    echo "Standby Status:"
    docker exec postgres-standby1 psql -U postgres -c "SELECT * FROM pg_stat_wal_receiver;"
    
    # 복제 지연 확인
    docker exec postgres-primary psql -U postgres -c "
        SELECT 
            client_addr,
            state,
            pg_wal_lsn_diff(pg_current_wal_lsn(), flush_lsn) AS flush_lag
        FROM pg_stat_replication;
    "
}

# 실행
case "$1" in
    "mysql")
        monitor_mysql_cluster
        ;;
    "postgres")
        monitor_postgres_cluster
        ;;
    *)
        echo "Usage: $0 {mysql|postgres}"
        exit 1
        ;;
esac
```

---

## 💭 함께 생각해보기 (10분)

### 🤝 페어 토론 (5분)

**토론 주제**:
1. **DB 선택**: "프로젝트에 적합한 데이터베이스는 무엇이고 왜 그런가요?"
2. **성능 vs 안정성**: "성능과 안정성 중 어느 것을 우선시해야 할까요?"
3. **클러스터링**: "언제부터 데이터베이스 클러스터링을 고려해야 할까요?"

**페어 활동 가이드**:
- 👥 **경험 기반 페어링**: DB 경험이 있는 사람과 없는 사람 매칭
- 🔄 **시나리오 토론**: 구체적인 서비스 규모별 DB 전략 토론
- 📝 **설계 계획**: 팀 프로젝트 DB 아키텍처 초안 작성

### 🎯 전체 공유 (5분)

- **DB 전략**: 각 팀의 데이터베이스 선택과 이유
- **운영 경험**: DB 관련 문제 경험과 해결 방법
- **다음 연결**: 실습에서 실제 DB 컨테이너 구축

### 💡 이해도 체크 질문

- ✅ "각 데이터베이스의 컨테이너 최적화 방법을 설명할 수 있나요?"
- ✅ "성능 모니터링 지표를 이해하고 있나요?"
- ✅ "고가용성 구성의 필요성과 방법을 알고 있나요?"

---

## 🔑 핵심 키워드

- **Stateful Application**: 상태 유지 애플리케이션
- **Database Tuning**: 데이터베이스 성능 튜닝
- **Replication**: 데이터베이스 복제
- **High Availability**: 고가용성
- **Failover**: 장애 조치

---

## 📝 세션 마무리

### ✅ 오늘 세션 성과
- [ ] 데이터베이스별 컨테이너 최적화 방법 이해
- [ ] 성능 모니터링과 튜닝 기법 습득
- [ ] 고가용성 클러스터 구성 방법 학습
- [ ] 실무 운영 노하우와 베스트 프랙티스 습득

### 🎯 다음 세션 준비
- **주제**: Lab 1 - Stateful 애플리케이션 구축
- **연결**: 이론 → 실제 구현으로 연결
- **준비사항**: Docker Compose 문법 복습

---

<div align="center">

**🗄️ 데이터베이스 컨테이너 운영 마스터!**

**다음**: [Lab 1 - Stateful 애플리케이션 구축](./lab_1.md)

</div>