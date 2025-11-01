# November Week 1 Day 3: 데이터베이스 & 캐싱

<div align="center">

**🗄️ RDS** • **⚡ ElastiCache** • **🔄 캐싱 전략**

*관리형 데이터베이스와 인메모리 캐시로 성능 최적화*

</div>

---

## 📅 일일 개요

### 🎯 학습 목표
- RDS 관리형 데이터베이스 이해 및 구성
- ElastiCache Redis/Memcached 활용
- 캐싱 전략 및 성능 최적화
- 데이터베이스 고가용성 구현

### ⏰ 세션 구성

| 시간 | 구분 | 주제 | 내용 |
|------|------|------|------|
| **09:00-09:20** | 📚 Session 1 | RDS 기초 | 관리형 DB, Multi-AZ, Read Replica |
| **09:20-09:30** | ☕ 휴식 | 10분 휴식 | |
| **09:30-09:50** | 📚 Session 2 | ElastiCache | Redis vs Memcached, 캐싱 전략 |
| **09:50-10:00** | ☕ 휴식 | 10분 휴식 | |
| **10:00-10:20** | 📚 Session 3 | DB 운영 | 백업, 모니터링, 성능 최적화 |
| **10:20-10:30** | ☕ 휴식 | 10분 휴식 | |
| **10:30-11:20** | 🛠️ Lab 1 | RDS + ElastiCache | PostgreSQL + Redis 구성 |
| **11:20-11:30** | ☕ 휴식 | 10분 휴식 | |
| **11:30-12:20** | 🛠️ Lab 2 | 캐싱 성능 테스트 | Cache-Aside 패턴 구현 |
| **12:20-13:00** | 🍽️ 점심 | 점심시간 | |

---

## 📚 세션 상세

### Session 1: RDS (Relational Database Service) (20분)
**핵심 내용**:
- RDS 아키텍처 및 지원 엔진
- Multi-AZ vs Read Replica
- 자동 백업 및 스냅샷
- RDS 보안 (암호화, IAM 인증)

**학습 목표**:
- [ ] RDS의 관리형 서비스 이점 이해
- [ ] Multi-AZ 고가용성 구현 방법
- [ ] Read Replica 읽기 성능 향상
- [ ] 백업 및 복구 전략 수립

### Session 2: ElastiCache (20분)
**핵심 내용**:
- Redis vs Memcached 비교
- 캐싱 전략 (Cache-Aside, Write-Through)
- 클러스터 모드 및 복제
- 데이터 영속성 및 백업

**학습 목표**:
- [ ] Redis와 Memcached 선택 기준
- [ ] 효과적인 캐싱 전략 수립
- [ ] 캐시 무효화 및 TTL 관리
- [ ] 세션 스토어 구현

### Session 3: 데이터베이스 운영 (20분)
**핵심 내용**:
- CloudWatch 모니터링
- Performance Insights
- 파라미터 그룹 최적화
- 장애 복구 및 Failover

**학습 목표**:
- [ ] 데이터베이스 성능 모니터링
- [ ] 쿼리 성능 분석 및 최적화
- [ ] 자동 백업 및 복구 설정
- [ ] 장애 상황 대응 방법

---

## 🛠️ 실습 상세

### Lab 1: RDS PostgreSQL + ElastiCache Redis 구성 (50분)
**목표**: 관리형 데이터베이스와 캐시 서버 구축

**구성 요소**:
- RDS PostgreSQL (Multi-AZ)
- ElastiCache Redis (Cluster Mode)
- VPC Private Subnet 배치
- Security Group 설정

**실습 단계**:
1. RDS PostgreSQL 인스턴스 생성 (20분)
2. ElastiCache Redis 클러스터 생성 (15분)
3. EC2에서 연결 테스트 (10분)
4. 리소스 정리 (5분)

### Lab 2: 캐싱 성능 테스트 및 최적화 (50분)
**목표**: Cache-Aside 패턴 구현 및 성능 비교

**구성 요소**:
- Python/Node.js 애플리케이션
- Cache-Aside 패턴 구현
- 성능 측정 (DB vs Cache)
- 캐시 무효화 전략

**실습 단계**:
1. 캐싱 로직 구현 (20분)
2. 성능 비교 테스트 (15분)
3. 캐시 무효화 테스트 (10분)
4. 결과 분석 및 최적화 (5분)

---

## 🎯 일일 학습 성과

### 기술적 성취
- [ ] RDS 관리형 데이터베이스 구성
- [ ] ElastiCache 캐시 서버 구축
- [ ] 캐싱 전략 실무 적용
- [ ] 데이터베이스 성능 최적화

### 실무 역량
- [ ] 고가용성 데이터베이스 설계
- [ ] 캐시를 통한 성능 향상
- [ ] 모니터링 및 운영 능력
- [ ] 비용 최적화 전략

---

## 🔗 관련 자료

### 📚 AWS 공식 문서
- [RDS 사용자 가이드](https://docs.aws.amazon.com/rds/)
- [ElastiCache 사용자 가이드](https://docs.aws.amazon.com/elasticache/)
- [RDS 요금](https://aws.amazon.com/rds/pricing/)
- [ElastiCache 요금](https://aws.amazon.com/elasticache/pricing/)

### 🎯 다음 Day 준비
- **Day 4**: 로드밸런싱 & Auto Scaling
- **연계 내용**: RDS + ElastiCache를 ALB + ASG와 통합

---

<div align="center">

**🗄️ 관리형 DB** • **⚡ 인메모리 캐시** • **🔄 성능 최적화** • **💰 비용 효율**

*데이터베이스와 캐싱으로 확장 가능한 백엔드 구축*

</div>
