# Week 5: AWS 집중 과정

<div align="center">

**☁️ AWS 실무** • **🏗️ 아키텍처 설계** • **💰 비용 효율** • **🚀 프로덕션 배포**

*CloudMart 프로젝트를 AWS에 완전 배포*

</div>

---

## 🎯 주간 목표

> **Docker Compose 애플리케이션을 AWS 프로덕션 환경으로 마이그레이션**

- AWS 핵심 서비스 실무 활용
- 고가용성 아키텍처 구축
- 비용 효율적 운영 전략
- CloudMart 프로젝트 완전 배포

## ⏰ 일일 운영 시간

```
09:00-12:50  이론 4개 세션 (각 50분 + 10분 휴식)
13:00-14:00  점심시간
14:00-15:50  실습 2개 세션 (각 50분 + 10분 휴식)
16:00-18:00  멘토링 시간
```

## 📅 5일 커리큘럼

### Day 1: AWS 기초 & 네트워킹
**아키텍처**: 간단한 2-Tier (Web + DB)

```
Session 1: AWS 기초 개념 (Region, AZ, 프리티어)
Session 2: VPC 아키텍처 (Subnet, IGW, Route Table)
Session 3: 보안 그룹 & EC2 기초
Session 4: 고객 사례 - 블로그 플랫폼 (WordPress)

Lab 1: VPC & EC2 기본 구성
Lab 2: 멀티 AZ 네트워크
```

**배포 예시**: WordPress + MySQL on EC2

---

### Day 2: 컴퓨팅 & 스토리지
**아키텍처**: CDN + 스토리지 통합

```
Session 1: EC2 심화 (Elastic IP, ENI)
Session 2: EBS 스토리지 (볼륨, 스냅샷)
Session 3: EFS & 공유 스토리지
Session 4: 고객 사례 - E-Commerce (PrestaShop)

Lab 1: EBS & 데이터 영속성
Lab 2: S3 정적 웹 호스팅 + CloudFront
```

**배포 예시**: PrestaShop + S3 이미지 스토리지

---

### Day 3: 데이터베이스 & 캐싱
**아키텍처**: 3-Tier + 캐싱 계층

```
Session 1: RDS 기초 (Multi-AZ, Read Replica)
Session 2: RDS 운영 (모니터링, 백업)
Session 3: ElastiCache Redis
Session 4: 고객 사례 - FinTech (Node.js API)

Lab 1: RDS PostgreSQL 구성
Lab 2: Redis 캐싱 구현
```

**배포 예시**: FinTech API + PostgreSQL + Redis

---

### Day 4: 로드밸런싱 & 고가용성
**아키텍처**: 완전한 HA 구성

```
Session 1: Elastic Load Balancing (ALB, NLB)
Session 2: Auto Scaling Groups
Session 3: 고가용성 아키텍처
Session 4: 고객 사례 - News & Media (Ghost CMS)

Lab 1: ALB + ASG 구성
Challenge: 고가용성 아키텍처 구현
```

**배포 예시**: Ghost CMS + Multi-AZ + Auto Scaling

---

### Day 5: CloudMart 프로젝트 배포
**아키텍처**: 프로덕션급 전체 인프라

```
Session 1: 배포 전략 수립
Session 2: 인프라 구성
Session 3: 모니터링 & 로깅
Session 4: 보안 & 백업

Lab 1: CloudMart 인프라 구축
Challenge: 프로덕션급 배포
```

**최종 아키텍처**:
```
CloudFront → S3 (Frontend)
         ↓
       ALB → ASG (Backend)
         ↓
   RDS (Multi-AZ) + ElastiCache
```

---

## 🖥️ 실습 방식

### Web Console 중심
- 모든 실습은 AWS Web Console에서 진행
- 아키텍처 다이어그램 먼저 제시
- 학생들이 직접 클릭하며 구현
- 강사는 ReadOnly Role로 실시간 모니터링

### 비용 관리
- **일일 목표**: $10 이하
- **주간 합계**: ~$17 (12명 기준)
- **학생당**: $1.45/week
- 실습 완료 후 즉시 리소스 정리

---

## 📚 학습 방법

### Session 구조 (각 50분)
1. **생성 배경** - 왜 이 서비스가 필요한가?
2. **핵심 원리** - 어떻게 작동하는가?
3. **사용 사례** - 언제 사용하는가?
4. **서비스 비교** - 어떤 서비스를 선택할까?
5. **장단점** - 무엇을 고려해야 하는가?
6. **비용 구조** - 얼마나 드는가?
7. **최신 업데이트** - 무엇이 바뀌었는가?

### Lab 구조 (각 50분)
1. **아키텍처 다이어그램** 제시
2. **Web Console 단계별 가이드**
3. **직접 구현** (사고하며 클릭)
4. **검증 및 테스트**
5. **리소스 정리**

---

## 🎓 고객 사례 학습

각 Day의 Session 4는 실제 고객 사례 중심:

- **Day 1**: 블로그 플랫폼 (WordPress)
- **Day 2**: E-Commerce (PrestaShop)
- **Day 3**: FinTech (Node.js API)
- **Day 4**: News & Media (Ghost CMS)
- **Day 5**: CloudMart (실제 프로젝트)

모든 사례는 Docker Hub 공식 이미지 사용

---

## 💡 특강: Terraform IaC

Week 5 이후 별도 진행
- Infrastructure as Code 개념
- Terraform 기초 문법
- AWS 리소스 코드화
- 상태 관리 및 협업

---

## 🎯 학습 성과

### 기술적 역량
- [ ] AWS 핵심 서비스 활용
- [ ] 고가용성 아키텍처 설계
- [ ] 비용 효율적 운영
- [ ] 프로덕션 배포 경험

### 실무 역량
- [ ] AWS Console 숙련도
- [ ] 인프라 설계 능력
- [ ] 문제 해결 능력
- [ ] 비용 의식

---

<div align="center">

**☁️ 5일간의 AWS 여정** • **🚀 CloudMart 프로덕션 배포**

*Docker Compose에서 AWS 프로덕션 환경으로*

</div>
