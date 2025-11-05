# Week 1 Day 3 Lab 1: RDS PostgreSQL 성능 모니터링 실습

<div align="center">

**🎯 RDS 성능 분석** • **📊 CloudWatch 모니터링** • **🔍 쿼리 최적화**

*Private RDS에서 인덱스 최적화를 통한 200배 성능 향상 체험*

</div>

---

## 🕘 Lab 정보
**시간**: 14:00-14:50 (50분)
**목표**: RDS 성능 모니터링 및 쿼리 최적화 실습
**방식**: AWS Web Console + EC2 SSM 접속
**예상 비용**: $0.073/hour

## 🎯 학습 목표
- [ ] Private RDS 구성 및 보안 설정
- [ ] EC2 SSM Session Manager를 통한 안전한 접속
- [ ] CloudWatch를 통한 RDS 성능 모니터링
- [ ] 인덱스 최적화를 통한 쿼리 성능 개선 (200배 향상)
- [ ] 실시간 성능 메트릭 분석

---

## 🏗️ 구축할 아키텍처

### 📐 아키텍처 다이어그램
```
┌─────────────────────────────────────────────────────────────┐
│                    AWS Cloud (ap-northeast-2)               │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  VPC: 10.0.0.0/16                                     │  │
│  │  ┌─────────────────────┐  ┌─────────────────────┐    │  │
│  │  │ Private Subnet A    │  │ Private Subnet C    │    │  │
│  │  │ 10.0.11.0/24        │  │ 10.0.12.0/24        │    │  │
│  │  │                     │  │                     │    │  │
│  │  │  ┌──────────────┐   │  │  ┌──────────────┐   │    │  │
│  │  │  │ EC2 Bastion  │   │  │  │ RDS Primary  │   │    │  │
│  │  │  │ + SSM Agent  │───┼──┼─▶│ PostgreSQL   │   │    │  │
│  │  │  │ + psql       │   │  │  │ db.t3.micro  │   │    │  │
│  │  │  └──────────────┘   │  │  └──────────────┘   │    │  │
│  │  └─────────────────────┘  └─────────────────────┘    │  │
│  │                                                        │  │
│  │  Security Groups:                                     │  │
│  │  - EC2 SG: Outbound to RDS (5432)                   │  │
│  │  - RDS SG: Inbound from EC2 SG (5432)               │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│  CloudWatch:                                                │
│  - RDS Performance Insights                                 │
│  - CPU, Memory, Connections 모니터링                        │
└─────────────────────────────────────────────────────────────┘

사용자 → AWS Console → SSM Session Manager → EC2 → RDS
```

**이미지 자리**: 아키텍처 다이어그램 이미지

### 🔗 참조 Session
**당일 Session**:
- [Session 1: RDS 기초](./session_1.md) - RDS 개념, Multi-AZ, Read Replica
- [Session 2: RDS 운영](./session_2.md) - 모니터링, Performance Insights

**이전 Day Session**:
- [Week 1 Day 1 Session 2: VPC 아키텍처](../day1/session_2.md) - VPC, Subnet 기초

---

## 📋 사전 준비: VPC 네트워크 구성

⚠️ **필수**: 먼저 VPC 네트워크를 구성해야 합니다!

👉 **[VPC Setup Guide](./vpc_setup_guide.md)** 를 따라 다음을 생성하세요:
- VPC (10.0.0.0/16)
- Public Subnet 2개 (AZ-A, AZ-C)
- Private Subnet 2개 (AZ-A, AZ-C)
- Internet Gateway
- NAT Gateway (AZ-A)
- Route Tables (Public RT, Private RT)

**예상 시간**: 20-25분

---

## 🛠️ Step 1: RDS Subnet Group 생성 (3분)

### 1-1. Subnet Group 생성

**경로**: AWS Console → RDS → Subnet groups → Create DB subnet group

**설정 값**:
| 항목 | 값 | 설명 |
|------|-----|------|
| **Name** | `november-w1-d3-subnet-group` | Subnet Group 이름 |
| **Description** | `Private subnets for RDS` | 설명 |
| **VPC** | `november-w1-d3-vpc` | VPC 선택 |

**📸 스크린샷 자리**: Subnet Group 기본 설정

**Availability Zones 선택**:
- ✅ `ap-northeast-2a`
- ✅ `ap-northeast-2c`

**Subnets 선택**:
- ✅ `november-w1-d3-private-a` (10.0.11.0/24)
- ✅ `november-w1-d3-private-c` (10.0.12.0/24)

**📸 스크린샷 자리**: AZ 및 Subnet 선택

**Create** 버튼 클릭

**📸 스크린샷 자리**: Subnet Group 생성 완료

✅ **체크포인트**: Subnet Group이 생성되었나요?

---

## 🛠️ Step 2: RDS PostgreSQL 생성 (10분)

### 2-1. RDS 인스턴스 생성

**경로**: AWS Console → RDS → Databases → Create database

**Engine options**:
| 항목 | 값 |
|------|-----|
| **Engine type** | PostgreSQL |
| **Engine version** | PostgreSQL 15.x (최신) |

**📸 스크린샷 자리**: Engine 선택

**Templates**:
- ✅ **Free tier** 선택

**Settings**:
| 항목 | 값 |
|------|-----|
| **DB instance identifier** | `november-w1-d3-rds` |
| **Master username** | `postgres` |
| **Master password** | `YourPassword123!` |
| **Confirm password** | `YourPassword123!` |

**📸 스크린샷 자리**: DB 식별자 및 자격증명

**Instance configuration**:
- **DB instance class**: db.t3.micro (프리티어)

**Storage**:
- **Storage type**: gp3
- **Allocated storage**: 20 GB

**📸 스크린샷 자리**: 인스턴스 및 스토리지 설정

**Connectivity**:
| 항목 | 값 | 설명 |
|------|-----|------|
| **VPC** | `november-w1-d3-vpc` | VPC 선택 |
| **DB subnet group** | `november-w1-d3-subnet-group` | 위에서 생성한 Subnet Group |
| **Public access** | **No** | ⚠️ Private 접근만 허용 |
| **VPC security group** | Create new | 새 보안 그룹 생성 |
| **Security group name** | `november-w1-d3-rds-sg` | 보안 그룹 이름 |

**📸 스크린샷 자리**: Connectivity 설정 (Public access = No 확인!)

**Additional configuration**:
| 항목 | 값 |
|------|-----|
| **Initial database name** | `testdb` |
| **Backup retention period** | 1 day |
| **Enable Enhanced monitoring** | No (비용 절감) |

**📸 스크린샷 자리**: Additional configuration

**Create database** 버튼 클릭

⏱️ **대기 시간**: 약 5-10분 (Status: Creating → Available)

**📸 스크린샷 자리**: RDS 생성 중 (Creating 상태)

---

## 🛠️ Step 3: EC2 인스턴스 생성 (SSM Agent) (8분)

### 3-1. IAM Role 생성 (SSM 접근용)

**경로**: AWS Console → IAM → Roles → Create role

**설정**:
| 항목 | 값 |
|------|-----|
| **Trusted entity type** | AWS service |
| **Use case** | EC2 |

**📸 스크린샷 자리**: Trusted entity 선택

**Permissions policies**:
- ✅ `AmazonSSMManagedInstanceCore` 검색 후 선택

**📸 스크린샷 자리**: SSM Policy 선택

**Role name**: `november-w1-d3-ec2-ssm-role`

**Create role** 버튼 클릭

**📸 스크린샷 자리**: Role 생성 완료

---

### 3-2. EC2 인스턴스 생성

**경로**: AWS Console → EC2 → Launch instance

**설정 값**:
| 항목 | 값 | 설명 |
|------|-----|------|
| **Name** | `november-w1-d3-bastion` | EC2 이름 |
| **AMI** | Amazon Linux 2023 | 최신 AMI |
| **Instance type** | t3.micro | 프리티어 |
| **Key pair** | Proceed without a key pair | SSM 사용하므로 불필요 |

**📸 스크린샷 자리**: 기본 설정

**Network settings**:
| 항목 | 값 |
|------|-----|
| **VPC** | `november-w1-d3-vpc` |
| **Subnet** | `november-w1-d3-private-a` (Private!) |
| **Auto-assign public IP** | Disable |
| **Security group name** | `november-w1-d3-ec2-sg` |

**Security group rules**:
- Outbound: All traffic (기본값 유지)
- Inbound: 없음 (SSM으로만 접근)

**📸 스크린샷 자리**: Network 설정 (Private Subnet 확인!)

**Advanced details**:
- **IAM instance profile**: `november-w1-d3-ec2-ssm-role` 선택

**📸 스크린샷 자리**: IAM Role 선택

**User data** (⚠️ 중요!):
```bash
#!/bin/bash
# PostgreSQL 클라이언트 설치
dnf install -y postgresql15

# SSM Agent는 Amazon Linux 2023에 기본 설치됨
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
```

**📸 스크린샷 자리**: User data 입력

**Launch instance** 버튼 클릭

⏱️ **대기 시간**: 약 2-3분

**📸 스크린샷 자리**: EC2 인스턴스 Running 상태

---

### 3-3. RDS 보안 그룹 수정 (EC2 접근 허용)

**경로**: AWS Console → EC2 → Security Groups → `november-w1-d3-rds-sg`

**Inbound rules 추가**:
| Type | Protocol | Port | Source | 설명 |
|------|----------|------|--------|------|
| PostgreSQL | TCP | 5432 | `november-w1-d3-ec2-sg` | EC2에서 RDS 접근 |

**📸 스크린샷 자리**: RDS 보안 그룹 Inbound rule 추가

**Save rules** 버튼 클릭

---

## 🛠️ Step 4: SSM으로 EC2 접속 및 RDS 연결 (5분)

### 4-1. SSM Session Manager로 접속

**경로**: AWS Console → EC2 → Instances → `november-w1-d3-bastion` 선택

**Connect** 버튼 클릭 → **Session Manager** 탭 선택 → **Connect** 버튼

**📸 스크린샷 자리**: Session Manager 연결 화면

⏱️ **대기**: 터미널 창이 열릴 때까지 약 10초

**📸 스크린샷 자리**: SSM 터미널 화면

---

### 4-2. RDS 연결 테스트

```bash
# RDS 엔드포인트 확인 (AWS Console에서 복사)
# 예: november-w1-d3-rds.xxxxx.ap-northeast-2.rds.amazonaws.com

# PostgreSQL 연결
psql -h november-w1-d3-rds.xxxxx.ap-northeast-2.rds.amazonaws.com \
     -U postgres \
     -d testdb

# 비밀번호 입력: YourPassword123!
```

**📸 스크린샷 자리**: psql 연결 성공

✅ **체크포인트**: `testdb=#` 프롬프트가 보이나요?

---

## 🛠️ Step 5: 스키마 생성 (3분)

### 5-1. 테이블 생성

```sql
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

**📸 스크린샷 자리**: 테이블 생성 결과

---

## 🛠️ Step 6: 대용량 데이터 생성 (15분)

### 6-1. 데이터 생성 스크립트 다운로드

```bash
# SSM 터미널에서 실행
cd /tmp

# 스크립트 다운로드 (GitHub에서)
curl -O https://raw.githubusercontent.com/.../03-generate-data.sh
chmod +x 03-generate-data.sh
```

또는 **직접 작성**:

```bash
cat > generate-data.sh <<'EOF'
#!/bin/bash
ROWS=${1:-1000000}
echo "=== $ROWS 건의 데이터 생성 시작 ==="

export PGPASSWORD='YourPassword123!'
psql -h november-w1-d3-rds.xxxxx.ap-northeast-2.rds.amazonaws.com \
     -U postgres -d testdb <<SQL
INSERT INTO orders (user_id, product_name, price, order_date, status, description)
SELECT 
    floor(random() * 10000)::INTEGER,
    'Product-' || floor(random() * 1000)::INTEGER,
    (random() * 1000)::DECIMAL(10,2),
    NOW() - (random() * 365 || ' days')::INTERVAL,
    CASE WHEN random() < 0.5 THEN 'completed' ELSE 'pending' END,
    md5(random()::TEXT) || md5(random()::TEXT) || md5(random()::TEXT)
FROM generate_series(1, $ROWS);
SQL

echo "=== 데이터 생성 완료 ==="
EOF

chmod +x generate-data.sh
```

**📸 스크린샷 자리**: 스크립트 작성

---

### 6-2. 데이터 생성 실행

```bash
# 100만 건 생성 (약 100MB)
./generate-data.sh 1000000
```

⏱️ **대기 시간**: 약 5-10분

**📸 스크린샷 자리**: 데이터 생성 진행 중

---

### 6-3. 데이터 확인

```sql
-- 데이터 건수 확인
SELECT COUNT(*) FROM orders;
-- 예상: 1000000

-- 테이블 크기 확인
SELECT pg_size_pretty(pg_total_relation_size('orders'));
-- 예상: 약 100MB

-- 샘플 데이터 확인
SELECT * FROM orders LIMIT 5;
```

**📸 스크린샷 자리**: 데이터 확인 결과

---

## 🛠️ Step 7: CloudWatch Dashboard 설정 (5분)

### 7-1. Dashboard 생성

**경로**: AWS Console → CloudWatch → Dashboards → Create dashboard

**Dashboard name**: `RDS-Performance-Lab`

**📸 스크린샷 자리**: Dashboard 생성

---

### 7-2. 위젯 추가

**위젯 1: CPU Utilization**
1. Add widget → Line
2. Metrics → RDS → Per-Database Metrics
3. `november-w1-d3-rds` 선택 → `CPUUtilization`
4. Statistic: Average, Period: 1 minute

**📸 스크린샷 자리**: CPU 위젯 설정

**위젯 2: Database Connections**
- Metric: `DatabaseConnections`

**위젯 3: Read IOPS**
- Metric: `ReadIOPS`

**위젯 4: Write IOPS**
- Metric: `WriteIOPS`

**위젯 5: Read Latency**
- Metric: `ReadLatency`

**위젯 6: Write Latency**
- Metric: `WriteLatency`

**📸 스크린샷 자리**: 6개 위젯 완성된 Dashboard

---

## 🛠️ Step 8: 느린 쿼리 실행 및 모니터링 (10분)

### 8-1. 인덱스 없는 쿼리 실행

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

**📸 스크린샷 자리**: 느린 쿼리 실행 계획

**예상 결과**:
```
Seq Scan on orders  (cost=0.00..50000.00 rows=1000 width=200) 
  (actual time=5000..10000 ms)
Planning Time: 0.5 ms
Execution Time: 10000 ms  ← 10초! 매우 느림
```

---

### 8-2. CloudWatch에서 실시간 모니터링

**확인 사항**:
- CPU Utilization: 80%+ 급증
- Read IOPS: 1000+ 증가
- Read Latency: 증가

**📸 스크린샷 자리**: CloudWatch 메트릭 급증 화면

---

### 8-3. 부하 테스트 (반복 실행)

```bash
# 느린 쿼리 파일 생성
cat > slow-query.sql <<'EOF'
SELECT * FROM orders 
WHERE product_name LIKE '%Product-500%' 
  AND price > 500
  AND status = 'completed'
ORDER BY order_date DESC
LIMIT 100;
EOF

# 10번 반복 실행
export PGPASSWORD='YourPassword123!'
for i in {1..10}; do
  echo "Query $i..."
  psql -h november-w1-d3-rds.xxxxx.ap-northeast-2.rds.amazonaws.com \
       -U postgres -d testdb -f slow-query.sql > /dev/null
done
```

**📸 스크린샷 자리**: 반복 쿼리 실행 중

---

## 🛠️ Step 9: 인덱스 생성 및 성능 개선 (5분)

### 9-1. 인덱스 생성

```sql
-- 인덱스 생성
CREATE INDEX idx_product_name ON orders(product_name);
CREATE INDEX idx_price ON orders(price);
CREATE INDEX idx_status ON orders(status);
CREATE INDEX idx_order_date ON orders(order_date);

-- 인덱스 확인
\di
```

**📸 스크린샷 자리**: 인덱스 생성 완료

---

### 9-2. 같은 쿼리 재실행

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

**📸 스크린샷 자리**: 빠른 쿼리 실행 계획

**예상 결과**:
```
Index Scan using idx_order_date on orders  
  (cost=0.00..100.00 rows=100 width=200) (actual time=10..50 ms)
Planning Time: 0.5 ms
Execution Time: 50 ms  ← 200배 빨라짐!
```

---

### 9-3. CloudWatch에서 성능 개선 확인

**확인 사항**:
- CPU Utilization: 10% 이하로 감소
- Read IOPS: 10 이하로 감소
- Read Latency: 정상화

**📸 스크린샷 자리**: CloudWatch 메트릭 정상화

---

## 📊 성능 비교

| 항목 | 인덱스 없음 | 인덱스 있음 | 개선율 |
|------|-------------|-------------|--------|
| **실행 시간** | 10,000 ms | 50 ms | **200배** |
| **CPU 사용률** | 80%+ | 10% 이하 | **8배** |
| **Read IOPS** | 1000+ | 10 이하 | **100배** |
| **스캔 방식** | Seq Scan (전체) | Index Scan (선택적) | - |

**📸 스크린샷 자리**: 성능 비교 표 또는 그래프

---

## ✅ 실습 체크포인트

### ✅ 사전 준비: VPC 네트워크
- [ ] VPC 생성 완료
- [ ] Subnet 4개 생성 (Public 2, Private 2)
- [ ] Internet Gateway 연결
- [ ] NAT Gateway 생성 (AZ-A)
- [ ] Route Tables 설정 (Public RT, Private RT)

### ✅ Step 1: RDS Subnet Group
- [ ] Subnet Group 생성
- [ ] Private Subnet 2개 포함

### ✅ Step 2: RDS 생성
- [ ] PostgreSQL 15.x 생성
- [ ] Private Subnet에 배치
- [ ] Public access = No
- [ ] Status: Available

### ✅ Step 3: EC2 + SSM
- [ ] IAM Role 생성 (SSM 권한)
- [ ] EC2 Private Subnet에 생성
- [ ] User data로 psql 설치
- [ ] RDS 보안 그룹 수정

### ✅ Step 4: SSM 접속
- [ ] Session Manager로 EC2 접속 성공
- [ ] psql로 RDS 연결 성공

### ✅ Step 5-6: 데이터 생성
- [ ] testdb 및 orders 테이블 생성
- [ ] 100만 건 데이터 삽입
- [ ] 테이블 크기 약 100MB 확인

### ✅ Step 7: CloudWatch
- [ ] Dashboard 생성
- [ ] 6개 위젯 추가

### ✅ Step 8: 느린 쿼리
- [ ] 인덱스 없는 쿼리 실행 (10초+)
- [ ] CloudWatch에서 CPU/IOPS 급증 확인

### ✅ Step 9: 인덱스 최적화
- [ ] 4개 인덱스 생성
- [ ] 같은 쿼리 50ms 이하로 개선
- [ ] CloudWatch 메트릭 정상화

---

## 🧹 리소스 정리 (5분)

⚠️ **비용 발생 방지를 위해 반드시 순서대로 삭제!**

### 삭제 순서

**1. RDS 인스턴스 삭제**
```bash
aws rds delete-db-instance \
  --db-instance-identifier november-w1-d3-rds \
  --skip-final-snapshot \
  --region ap-northeast-2
```

또는 **AWS Console**:
- RDS → Databases → `november-w1-d3-rds` 선택
- Actions → Delete
- ✅ Skip final snapshot 체크
- "delete me" 입력 후 Delete

**📸 스크린샷 자리**: RDS 삭제 확인

**2. EC2 인스턴스 종료**
- EC2 → Instances → `november-w1-d3-bastion` 선택
- Instance state → Terminate instance

**3. RDS Subnet Group 삭제**
- RDS → Subnet groups → `november-w1-d3-subnet-group` 삭제

**4. Security Groups 삭제**
- EC2 → Security Groups
- `november-w1-d3-rds-sg` 삭제
- `november-w1-d3-ec2-sg` 삭제

**5. IAM Role 삭제**
- IAM → Roles → `november-w1-d3-ec2-ssm-role` 삭제

**6. CloudWatch Dashboard 삭제**
- CloudWatch → Dashboards → `RDS-Performance-Lab` 삭제

**7. VPC 리소스 정리**
- 👉 **[VPC Setup Guide](./vpc_setup_guide.md)** 의 정리 섹션 참조

**📸 스크린샷 자리**: 모든 리소스 삭제 완료

---

## 🔍 트러블슈팅

### 문제 1: SSM Session Manager에 인스턴스가 안 보임
**원인**: SSM Agent 미설치 또는 IAM Role 미설정
**해결**:
1. IAM Role이 EC2에 연결되었는지 확인
2. User data에 SSM Agent 설치 스크립트 포함 확인
3. 5분 정도 대기 후 재시도

### 문제 2: RDS 연결 실패 (timeout)
**원인**: 보안 그룹 설정 오류
**해결**:
1. RDS 보안 그룹 Inbound에 EC2 보안 그룹 추가 확인
2. RDS가 Private Subnet에 있는지 확인
3. NAT Gateway가 정상 작동하는지 확인

### 문제 3: psql 명령어를 찾을 수 없음
**원인**: PostgreSQL 클라이언트 미설치
**해결**:
```bash
sudo dnf install -y postgresql15
```

### 문제 4: 데이터 생성이 너무 느림
**원인**: 네트워크 또는 RDS 성능
**해결**:
- 데이터 건수를 줄여서 시도 (10만 건)
- RDS Status가 Available인지 확인
- CloudWatch에서 IOPS 확인

### 문제 5: RDS Subnet Group 생성 시 "Invalid subnet" 오류
**원인**: Public Subnet을 선택함
**해결**: 반드시 Private Subnet 2개만 선택

---

## 💡 Lab 회고

### 🤝 페어 회고 (5분)
1. **Private RDS 접근**: SSM을 통한 안전한 접근 방법 이해
2. **성능 차이 체감**: 인덱스 전후 200배 성능 향상
3. **실무 적용**: 프로덕션 환경에서의 보안 및 성능 최적화

### 📊 학습 성과
- **보안**: Private Subnet + SSM으로 안전한 DB 접근
- **성능**: 인덱스 최적화의 극적인 효과 체험
- **모니터링**: CloudWatch를 통한 실시간 성능 분석

---

## 💰 예상 비용

| 리소스 | 사용 시간 | 단가 | 예상 비용 |
|--------|----------|------|-----------|
| RDS db.t3.micro | 1시간 | $0.017/hour | $0.017 |
| EC2 t3.micro | 1시간 | $0.0104/hour | $0.010 |
| NAT Gateway | 1시간 | $0.045/hour | $0.045 |
| 스토리지 20GB | 1시간 | $0.115/GB/month | $0.001 |
| **합계** | | | **$0.073** |

---

<div align="center">

**🔒 Private 보안** • **📊 실시간 모니터링** • **⚡ 200배 성능 향상**

*SSM을 통한 안전한 접근과 인덱스 최적화 체험*

</div>
