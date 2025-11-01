# November Week 1 Day 3 Lab 1: RDS 성능 모니터링 및 최적화

<div align="center">

**📊 실시간 모니터링** • **🔍 성능 분석** • **⚡ 인덱스 최적화**

*대용량 데이터로 실제 성능 문제를 경험하고 해결하기*

</div>

---

## 🕘 Lab 정보
**시간**: 11:00-12:00 (60분)
**목표**: RDS 성능 모니터링 및 쿼리 최적화 실습
**방식**: AWS Console + SQL 스크립트 실행

## 🎯 학습 목표
- RDS 인스턴스 생성 및 연결
- 대용량 데이터 생성 (100MB ~ 1GB)
- CloudWatch Dashboard로 실시간 모니터링
- 인덱스 없는 쿼리의 성능 문제 확인
- 인덱스 생성 후 성능 개선 확인

---

## 🏗️ 구축할 아키텍처

```
EC2 (psql client)
    ↓ SQL 쿼리
RDS PostgreSQL (db.t3.micro)
    ↓ 메트릭 전송
CloudWatch Dashboard
    - CPU Utilization
    - Database Connections
    - Read/Write IOPS
    - Read/Write Latency
```

---

## 🛠️ Step 1: RDS PostgreSQL 생성 (10분)

### AWS Console에서 RDS 생성

**경로**: AWS Console → RDS → Create database

**설정 값**:
| 항목 | 값 | 설명 |
|------|-----|------|
| Engine | PostgreSQL | 버전 15.x |
| Template | Free tier | 프리티어 사용 |
| DB instance identifier | lab-rds-perf | 인스턴스 이름 |
| Master username | postgres | 기본 사용자 |
| Master password | YourPassword123! | 비밀번호 설정 |
| DB instance class | db.t3.micro | 프리티어 |
| Storage | 20 GB gp3 | 기본 스토리지 |
| Public access | Yes | 외부 접근 허용 |
| VPC security group | Create new | 새 보안 그룹 |

**보안 그룹 설정**:
- Inbound: PostgreSQL (5432) - My IP

### ✅ 검증
```bash
# RDS 엔드포인트 확인
aws rds describe-db-instances \
  --db-instance-identifier lab-rds-perf \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text
```

---

## 🛠️ Step 2: 스키마 생성 (5분)

### 데이터베이스 연결
```bash
# RDS 엔드포인트를 환경변수로 설정
export RDS_ENDPOINT="lab-rds-perf.xxxxx.ap-northeast-2.rds.amazonaws.com"

# psql 연결
psql -h $RDS_ENDPOINT -U postgres -d postgres
```

### 스키마 생성
```sql
-- 데이터베이스 생성
CREATE DATABASE testdb;

-- testdb로 연결
\c testdb

-- 주문 테이블 생성
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    order_date TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL,
    description TEXT
);

-- 테이블 확인
\dt
```

### ✅ 검증
```sql
SELECT COUNT(*) FROM orders;
-- 예상: 0 (아직 데이터 없음)
```

---

## 🛠️ Step 3: 대용량 데이터 생성 (15분)

### 스크립트 실행

**옵션 1: 100MB 데이터 (100만 건)**
```bash
cd theory/november/week_01/day3/lab_scripts/lab1
./03-generate-data.sh 1000000
```

**옵션 2: 1GB 데이터 (1000만 건)** - 시간 여유 있을 때
```bash
./03-generate-data.sh 10000000
```

### 스크립트 내용
```bash
#!/bin/bash
# 03-generate-data.sh

ROWS=${1:-1000000}
echo "=== $ROWS 건의 데이터 생성 시작 ==="

psql -h $RDS_ENDPOINT -U postgres -d testdb <<EOF
INSERT INTO orders (user_id, product_name, price, order_date, status, description)
SELECT 
    floor(random() * 10000)::INTEGER,
    'Product-' || floor(random() * 1000)::INTEGER,
    (random() * 1000)::DECIMAL(10,2),
    NOW() - (random() * 365 || ' days')::INTERVAL,
    CASE WHEN random() < 0.5 THEN 'completed' ELSE 'pending' END,
    md5(random()::TEXT) || md5(random()::TEXT) || md5(random()::TEXT)
FROM generate_series(1, $ROWS);
EOF

echo "=== 데이터 생성 완료 ==="
```

### ✅ 검증
```sql
-- 데이터 건수 확인
SELECT COUNT(*) FROM orders;

-- 테이블 크기 확인
SELECT pg_size_pretty(pg_total_relation_size('orders'));
-- 예상: 약 100MB (100만 건) 또는 1GB (1000만 건)

-- 샘플 데이터 확인
SELECT * FROM orders LIMIT 5;
```

---

## 🛠️ Step 4: CloudWatch Dashboard 설정 (5분)

### AWS Console에서 Dashboard 생성

**경로**: AWS Console → CloudWatch → Dashboards → Create dashboard

**위젯 추가**:
1. **CPU Utilization**
   - Metric: RDS → DBInstanceIdentifier → CPUUtilization
   - Statistic: Average
   - Period: 1 minute

2. **Database Connections**
   - Metric: DatabaseConnections
   - Statistic: Sum

3. **Read IOPS**
   - Metric: ReadIOPS
   - Statistic: Average

4. **Write IOPS**
   - Metric: WriteIOPS
   - Statistic: Average

5. **Read Latency**
   - Metric: ReadLatency
   - Statistic: Average

6. **Write Latency**
   - Metric: WriteLatency
   - Statistic: Average

---

## 🛠️ Step 5: 느린 쿼리 실행 (10분)

### 인덱스 없는 쿼리 (전체 테이블 스캔)

```sql
-- 실행 계획 확인
EXPLAIN ANALYZE
SELECT * FROM orders 
WHERE product_name LIKE '%Product-500%' 
  AND price > 500
  AND status = 'completed'
ORDER BY order_date DESC
LIMIT 100;
```

**예상 결과**:
```
Seq Scan on orders  (cost=0.00..50000.00 rows=1000 width=200) (actual time=5000..10000 ms)
  Filter: ((product_name ~~ '%Product-500%') AND (price > 500) AND (status = 'completed'))
Planning Time: 0.5 ms
Execution Time: 10000 ms  ← 매우 느림!
```

### CloudWatch에서 확인
- CPU Utilization 급증 (80%+)
- Read IOPS 증가
- Read Latency 증가

### 여러 번 실행하여 부하 생성
```bash
# 10번 반복 실행
for i in {1..10}; do
  psql -h $RDS_ENDPOINT -U postgres -d testdb -f 04-slow-query.sql
  echo "Query $i completed"
done
```

---

## 🛠️ Step 6: 인덱스 생성 및 성능 개선 (5분)

### 인덱스 생성
```sql
-- 인덱스 생성
CREATE INDEX idx_product_name ON orders(product_name);
CREATE INDEX idx_price ON orders(price);
CREATE INDEX idx_status ON orders(status);
CREATE INDEX idx_order_date ON orders(order_date);

-- 인덱스 확인
\di
```

### 같은 쿼리 재실행
```sql
-- 실행 계획 확인
EXPLAIN ANALYZE
SELECT * FROM orders 
WHERE product_name LIKE '%Product-500%' 
  AND price > 500
  AND status = 'completed'
ORDER BY order_date DESC
LIMIT 100;
```

**예상 결과**:
```
Index Scan using idx_order_date on orders  (cost=0.00..100.00 rows=100 width=200) (actual time=10..50 ms)
  Filter: ((product_name ~~ '%Product-500%') AND (price > 500) AND (status = 'completed'))
Planning Time: 0.5 ms
Execution Time: 50 ms  ← 200배 빨라짐!
```

### CloudWatch에서 확인
- CPU Utilization 정상 (10% 이하)
- Read IOPS 감소
- Read Latency 감소

---

## 📊 성능 비교

| 항목 | 인덱스 없음 | 인덱스 있음 | 개선율 |
|------|-------------|-------------|--------|
| **실행 시간** | 10,000 ms | 50 ms | **200배** |
| **CPU 사용률** | 80%+ | 10% 이하 | **8배** |
| **Read IOPS** | 1000+ | 10 이하 | **100배** |
| **스캔 방식** | Seq Scan | Index Scan | - |

---

## ✅ 실습 체크포인트

### ✅ Step 1: RDS 생성
- [ ] RDS PostgreSQL 인스턴스 생성 완료
- [ ] 보안 그룹 설정 완료
- [ ] psql 연결 성공

### ✅ Step 2: 스키마 생성
- [ ] testdb 데이터베이스 생성
- [ ] orders 테이블 생성

### ✅ Step 3: 데이터 생성
- [ ] 100만 건 (또는 1000만 건) 데이터 삽입
- [ ] 테이블 크기 확인 (약 100MB 또는 1GB)

### ✅ Step 4: CloudWatch Dashboard
- [ ] Dashboard 생성
- [ ] 6개 위젯 추가 (CPU, Connections, IOPS, Latency)

### ✅ Step 5: 느린 쿼리
- [ ] 인덱스 없는 쿼리 실행
- [ ] CloudWatch에서 CPU/IOPS 급증 확인
- [ ] 실행 시간 10초 이상 확인

### ✅ Step 6: 인덱스 최적화
- [ ] 4개 인덱스 생성
- [ ] 같은 쿼리 재실행
- [ ] 실행 시간 100ms 이하 확인
- [ ] CloudWatch에서 메트릭 정상화 확인

---

## 🧹 리소스 정리

```bash
cd theory/november/week_01/day3/lab_scripts/lab1
./cleanup.sh
```

**cleanup.sh**:
```bash
#!/bin/bash
echo "=== RDS 인스턴스 삭제 ==="

aws rds delete-db-instance \
  --db-instance-identifier lab-rds-perf \
  --skip-final-snapshot

echo "=== CloudWatch Dashboard 삭제 ==="
aws cloudwatch delete-dashboards \
  --dashboard-names RDS-Performance-Lab

echo "=== 정리 완료 ==="
```

---

## 💡 Lab 회고

### 🤝 페어 회고 (5분)
1. **가장 인상 깊었던 부분**: 인덱스 전후 성능 차이
2. **어려웠던 점**: 대용량 데이터 생성 시간
3. **실무 적용**: 실제 프로젝트에서 쿼리 최적화 방법

### 📊 학습 성과
- **기술적 성취**: RDS 모니터링 및 쿼리 최적화
- **이해도 향상**: 인덱스의 중요성 체감
- **실무 역량**: CloudWatch를 활용한 성능 분석

---

## 💰 예상 비용

| 리소스 | 사용 시간 | 단가 | 예상 비용 |
|--------|----------|------|-----------|
| RDS db.t3.micro | 1시간 | $0.017/hour | $0.017 |
| 스토리지 20GB | 1시간 | $0.115/GB/month | $0.001 |
| 데이터 전송 | 1GB | 무료 (프리티어) | $0 |
| **합계** | | | **$0.02** |

---

<div align="center">

**📊 실시간 모니터링** • **🔍 성능 분석** • **⚡ 인덱스 최적화**

*실제 부하로 경험하는 데이터베이스 성능 최적화*

</div>
