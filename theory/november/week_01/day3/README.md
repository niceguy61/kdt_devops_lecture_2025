# November Week 1 Day 3: 데이터베이스 & 캐싱

<div align="center">

**🗄️ RDS** • **⚡ ElastiCache** • **📊 모니터링** • **🔧 최적화**

*관리형 데이터베이스와 인메모리 캐시로 성능 최적화*

</div>

---

## 📅 일일 개요

### 🎯 학습 목표
- RDS 관리형 데이터베이스 이해 및 Multi-AZ 고가용성 구현
- ElastiCache Redis/Memcached 활용 및 캐싱 전략 수립
- CloudWatch를 통한 데이터베이스 모니터링 및 성능 최적화
- 실제 부하 테스트를 통한 인덱스 최적화 경험

### ⏰ 세션 구성

| 시간 | 구분 | 주제 | 내용 |
|------|------|------|------|
| **09:00-09:40** | 📚 Session 1 | RDS 기초 | 관리형 DB, Multi-AZ, Read Replica, Failover |
| **09:40-10:20** | 📚 Session 2 | ElastiCache | Redis vs Memcached, 캐싱 전략, 성능 향상 |
| **10:20-11:00** | 📚 Session 3 | DB 운영 | CloudWatch 모니터링, Performance Insights, 최적화 |
| **11:00-12:00** | 🛠️ Lab 1 | RDS 성능 모니터링 | 대용량 데이터 + 인덱스 최적화 실습 |
| **12:00-13:00** | 🍽️ 점심 | 점심시간 | |

---

## 📚 세션 상세

### Session 1: RDS (Relational Database Service) (40분)
**핵심 내용**:
- RDS 관리형 서비스의 생성 배경과 이점
- Multi-AZ vs Read Replica 아키텍처 및 Failover 과정
- 지원 엔진별 특징 (MySQL, PostgreSQL, Aurora 등)
- 자동 백업, 스냅샷, 보안 (암호화, IAM 인증)

**학습 목표**:
- [ ] RDS의 관리형 서비스 이점과 EC2 직접 설치 대비 장점 이해
- [ ] Multi-AZ 고가용성 구현 방법과 자동 Failover 과정 파악
- [ ] Read Replica를 통한 읽기 성능 향상 전략 수립
- [ ] 백업 및 복구 전략, 비용 구조 이해

### Session 2: ElastiCache (40분)
**핵심 내용**:
- 인메모리 캐시의 필요성과 ElastiCache 솔루션
- Redis vs Memcached 상세 비교 및 선택 기준
- 캐싱 전략 (Cache-Aside, Write-Through, Write-Behind)
- 클러스터 모드, 복제, 데이터 영속성

**학습 목표**:
- [ ] Redis와 Memcached의 차이점과 적합한 사용 사례 파악
- [ ] Cache-Aside 패턴 등 효과적인 캐싱 전략 수립
- [ ] 캐시 무효화, TTL 관리, 성능 최적화 방법 이해
- [ ] 세션 스토어, 순위표 등 실무 활용 방안 습득

### Session 3: 데이터베이스 운영 및 최적화 (40분)
**핵심 내용**:
- CloudWatch를 통한 RDS/ElastiCache 모니터링
- Performance Insights로 쿼리 성능 분석
- 주요 메트릭 (CPU, 메모리, IOPS, 연결 수) 및 알람 설정
- 백업, 복구, 장애 대응 및 성능 최적화

**학습 목표**:
- [ ] CloudWatch 메트릭을 통한 데이터베이스 성능 모니터링
- [ ] Performance Insights로 느린 쿼리 분석 및 최적화
- [ ] 알람 설정을 통한 사전 장애 예방 체계 구축
- [ ] 백업/복구 전략과 장애 상황 대응 방법 습득

---

## 🛠️ 실습 상세

### Lab 1: RDS 성능 모니터링 및 최적화 (60분)
**목표**: 대용량 데이터로 실제 성능 문제를 경험하고 해결하기

**구성 요소**:
- RDS PostgreSQL (db.t3.micro)
- CloudWatch Dashboard (CPU, IOPS, Latency 모니터링)
- 대용량 데이터 (100만 건 ~ 1GB)
- 인덱스 최적화 실습

**실습 단계**:
1. **RDS PostgreSQL 생성** (10분) - Private Subnet 배치, Security Group 설정
2. **스키마 및 대용량 데이터 생성** (20분) - 100만 건 주문 데이터 생성
3. **CloudWatch Dashboard 설정** (5분) - CPU, IOPS, Latency 위젯 추가
4. **느린 쿼리 실행 및 모니터링** (15분) - 인덱스 없는 전체 테이블 스캔
5. **인덱스 생성 및 성능 개선 확인** (5분) - 200배 성능 향상 체험
6. **리소스 정리** (5분)

**💡 핵심 학습 포인트**:
- 실제 부하 상황에서 CloudWatch 메트릭 변화 관찰
- 인덱스 유무에 따른 극적인 성능 차이 체험 (10초 → 50ms)
- EXPLAIN ANALYZE를 통한 쿼리 실행 계획 분석

**💰 예상 비용**: 약 $0.02 (RDS db.t3.micro 1시간)

**🔧 접근 방법**: 
- **Option 1**: RDS Public access + CloudShell 직접 연결
- **Option 2**: Private EC2 + SSM Session Manager (보안 권장)

---

## 🎯 일일 학습 성과

### 기술적 성취
- [ ] RDS 관리형 데이터베이스 구성 및 Multi-AZ 고가용성 이해
- [ ] ElastiCache 캐시 서버 개념 및 Redis vs Memcached 선택 기준
- [ ] CloudWatch를 통한 실시간 데이터베이스 모니터링 체계 구축
- [ ] 실제 부하 테스트를 통한 인덱스 최적화 효과 체험 (200배 성능 향상)

### 실무 역량
- [ ] 고가용성 데이터베이스 설계 및 Failover 과정 이해
- [ ] 캐싱 전략을 통한 애플리케이션 성능 향상 방법
- [ ] Performance Insights를 활용한 쿼리 성능 분석 능력
- [ ] 비용 최적화를 고려한 데이터베이스 운영 전략

### 협업 및 문제 해결
- [ ] 페어 프로그래밍을 통한 SQL 쿼리 최적화 경험
- [ ] 성능 문제 진단 및 해결 과정 공유
- [ ] 실무 시나리오 기반 장애 대응 방법 토론

---

## 🔗 관련 자료

### 📚 AWS 공식 문서
- [RDS 사용자 가이드](https://docs.aws.amazon.com/rds/) - Multi-AZ, Read Replica 상세 설명
- [ElastiCache 사용자 가이드](https://docs.aws.amazon.com/elasticache/) - Redis vs Memcached 비교
- [CloudWatch 모니터링](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/) - 메트릭 및 알람 설정
- [Performance Insights](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PerfInsights.html) - 쿼리 성능 분석

### 💰 비용 정보
- [RDS 요금](https://aws.amazon.com/rds/pricing/) - 인스턴스 타입별 시간당 비용
- [ElastiCache 요금](https://aws.amazon.com/elasticache/pricing/) - 노드 타입별 비용

### 🎯 다음 Day 준비
- **Day 4**: 로드밸런싱 & Auto Scaling
- **연계 내용**: RDS + ElastiCache를 ALB + ASG와 통합하여 완전한 3-tier 아키텍처 구축
- **사전 준비**: 오늘 학습한 데이터베이스 개념을 바탕으로 확장성 있는 아키텍처 설계 고민

---

<div align="center">

**🗄️ 관리형 DB** • **⚡ 인메모리 캐시** • **📊 실시간 모니터링** • **🔧 성능 최적화**

*실제 부하 테스트로 경험하는 데이터베이스 성능 최적화*

</div>
