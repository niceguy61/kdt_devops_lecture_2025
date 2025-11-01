# November Week 1 Day 5: DNS, CDN, HTTPS 구성

<div align="center">

**🌐 Route 53** • **⚡ CloudFront** • **🔒 ACM**

*도메인 연결부터 HTTPS까지 - 프로덕션 배포 완성*

</div>

---

## 🎯 Day 5 목표

### 학습 목표
- Route 53으로 DNS 관리 (A 레코드, CNAME)
- CloudFront CDN으로 글로벌 배포
- ACM으로 무료 SSL/TLS 인증서 발급
- HTTPS 프로덕션 환경 구축

### 실무 역량
- 도메인 연결 및 DNS 설정
- CDN 캐싱 전략
- SSL/TLS 인증서 관리
- 대체 도메인 설정

---

## 📅 일일 스케줄

| 시간 | 구분 | 내용 | 방식 |
|------|------|------|------|
| **09:00-09:20** | 📚 Session 1 | Route 53 (DNS) | 이론 강의 |
| **09:30-09:50** | 📚 Session 2 | CloudFront (CDN) | 이론 강의 |
| **10:00-10:20** | 📚 Session 3 | ACM (SSL/TLS) | 이론 강의 |
| **10:30-11:00** | ☕ 휴식 | 30분 휴식 | |
| **11:00-11:50** | 🛠️ Lab 1 | 도메인 + HTTPS 연동 | 실습 |

---

## 📚 세션 구성

### [Session 1: Route 53](./session_1.md) (09:00-09:20)
**주제**: DNS 관리 및 레코드 설정

**핵심 내용**:
- Route 53 개념 및 DNS 작동 원리
- 레코드 타입 (A, CNAME, ALIAS)
- Health Check 및 Failover
- 라우팅 정책 (Simple, Weighted, Latency)

**학습 포인트**:
- A 레코드 vs CNAME vs ALIAS 차이
- CloudFront와 Route 53 연동
- 비용 구조 ($0.50/호스팅 존)

---

### [Session 2: CloudFront](./session_2.md) (09:30-09:50)
**주제**: CDN으로 글로벌 콘텐츠 배포

**핵심 내용**:
- CloudFront 아키텍처 (Edge Location)
- Origin 설정 (S3, ALB, Custom)
- 캐싱 동작 및 TTL
- 대체 도메인 (CNAME)

**학습 포인트**:
- 캐시 히트율 최적화
- 무효화 (Invalidation) 전략
- HTTPS 지원 (ACM 통합)

---

### [Session 3: ACM](./session_3.md) (10:00-10:20)
**주제**: 무료 SSL/TLS 인증서 발급

**핵심 내용**:
- ACM 개념 및 인증서 타입
- 인증서 발급 프로세스 (DNS 검증)
- CloudFront 연동
- 자동 갱신

**학습 포인트**:
- 무료 인증서 vs 유료 인증서
- DNS 검증 vs 이메일 검증
- 와일드카드 인증서 (*.example.com)

---

## 🛠️ 실습 구성

### [Lab 1: 도메인 + HTTPS 연동](./lab_1.md) (11:00-11:50)
**목표**: 준비한 도메인에 Route 53 + CloudFront + ACM 연동

**실습 내용**:
1. **Route 53 호스팅 존 생성** (10분)
   - 도메인 연결
   - NS 레코드 확인

2. **ACM 인증서 발급** (10분)
   - us-east-1 리전에서 발급 (CloudFront용)
   - DNS 검증
   - 인증서 상태 확인

3. **CloudFront Distribution 생성** (15분)
   - Origin: ALB (Day 4 Lab)
   - 대체 도메인: api.example.com
   - SSL 인증서: ACM 연결
   - 캐싱 동작 설정

4. **Route 53 레코드 추가** (10분)
   - A 레코드 (ALIAS) → CloudFront
   - CNAME 레코드 (선택)

5. **HTTPS 접속 테스트** (5분)
   - https://api.example.com
   - SSL 인증서 확인

**예상 결과**:
- 도메인으로 HTTPS 접속 성공
- 글로벌 CDN 캐싱 동작
- SSL/TLS 보안 연결

---

## 🏗️ 최종 아키텍처

```
사용자 (전 세계)
    ↓
Route 53 (api.example.com)
    ↓
CloudFront (Edge Location)
    ├─ SSL/TLS (ACM 인증서)
    └─ 캐싱 (TTL 설정)
    ↓
ALB (Origin)
    ↓
EC2 (Docker Compose)
    ├─ /api/*      → API:8080
    ├─ /backend/*  → Backend:8081
    └─ /admin/*    → Admin:8082
```

---

## 🔗 연계 학습

### Week 1 복습
- **Day 1**: EC2 기본
- **Day 2**: S3 (CloudFront Origin 가능)
- **Day 3**: RDS (백엔드 DB)
- **Day 4**: ALB (CloudFront Origin)

### Week 2 예고
- **IAM**: 권한 관리
- **Systems Manager**: Parameter Store
- **SNS**: 알람
- **CloudWatch Logs**: 로그 중앙화

---

## 💰 예상 비용

| 리소스 | 사용 시간 | 단가 | 예상 비용 |
|--------|----------|------|-----------|
| Route 53 호스팅 존 | 1개월 | $0.50/월 | $0.50 |
| Route 53 쿼리 | 100만 건 | $0.40/백만 | $0.40 |
| CloudFront | 1GB 전송 | $0.085/GB | $0.09 |
| CloudFront 요청 | 10,000건 | $0.0075/만 건 | $0.01 |
| ACM 인증서 | 무료 | $0 | $0 |
| **합계** | | | **$1.00** |

**💡 비용 절감 팁**:
- CloudFront 프리티어: 1TB 데이터 전송/월 (12개월)
- ACM 인증서: 완전 무료
- Route 53: 첫 호스팅 존만 $0.50

---

## ✅ Day 5 체크리스트

### 이론 학습
- [ ] Route 53 DNS 개념 이해
- [ ] CloudFront CDN 작동 원리 파악
- [ ] ACM 인증서 발급 프로세스 이해

### 실습 완료
- [ ] Route 53 호스팅 존 생성
- [ ] 도메인 NS 레코드 연결
- [ ] ACM 인증서 발급 (DNS 검증)
- [ ] CloudFront Distribution 생성
- [ ] 대체 도메인 설정
- [ ] Route 53 A 레코드 (ALIAS) 추가
- [ ] HTTPS 접속 테스트 성공
- [ ] SSL 인증서 확인

### 실무 역량
- [ ] DNS 레코드 설정 능력
- [ ] CDN 캐싱 전략 수립
- [ ] SSL/TLS 인증서 관리
- [ ] 프로덕션 HTTPS 환경 구축

---

## 🎓 Week 1 총정리

### 학습한 AWS 서비스 (8개)
1. **컴퓨팅**: EC2, Lambda
2. **네트워킹**: VPC, ALB, Route 53, CloudFront
3. **스토리지**: S3, EBS, EFS
4. **데이터베이스**: RDS, ElastiCache
5. **보안**: Security Groups, ACM
6. **모니터링**: CloudWatch

### 실무 패턴
- Multi-AZ 고가용성
- ALB 경로 기반 라우팅
- CloudFront + ACM HTTPS
- Route 53 DNS 관리
- Docker Compose 활용

### Week 2 예고
- **IAM**: 권한 관리 및 Role
- **Systems Manager**: 환경 변수 관리
- **SNS**: 알람 및 알림
- **CloudWatch Logs**: 로그 중앙화
- **Terraform**: 인프라 코드화

---

## 📝 도메인 준비 사항

### 옵션 1: 도메인 보유
- 기존 도메인 사용
- Route 53으로 NS 레코드 변경

### 옵션 2: 도메인 미보유
- 저렴한 도메인 구매 ($1-5/년)
  - Namecheap, GoDaddy, Gabia
  - .xyz, .site, .online 등
- 또는 Route 53에서 직접 구매

### 옵션 3: 테스트 환경
- CloudFront 기본 도메인 사용
  - `d1234abcd.cloudfront.net`
- ACM 인증서 없이 HTTP만 테스트

---

<div align="center">

**🌐 Route 53** • **⚡ CloudFront** • **🔒 ACM**

*Week 1 완성 - 프로덕션급 HTTPS 배포*

</div>
