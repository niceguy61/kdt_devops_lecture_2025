# November Week 1 Day 5 - Diagrams Summary

## 📊 생성된 다이어그램 목록

### Session 1: Route 53 (DNS)

#### 1. Route 53 DNS Query Flow
**파일**: `route53_dns_flow.png`
**위치**: Session 1 - 핵심 원리 (How?)
**설명**: 사용자 DNS 쿼리부터 IP 반환까지의 전체 흐름
- User → Route 53 → ALB
- DNS 조회 프로세스 시각화

#### 2. Route 53 Health Check
**파일**: `route53_health_check.png`
**위치**: Session 1 - 핵심 원리 (How?)
**설명**: Health Check 동작 원리
- Primary/Secondary 서버 상태 확인
- 30초 간격 체크
- Healthy/Standby 상태 표시

#### 3. Route 53 Record Types
**파일**: `route53_record_types.png`
**위치**: Session 1 - 비슷한 서비스 비교 (Which?)
**설명**: A, ALIAS, CNAME 레코드 타입 비교
- A Record: $0.40/M
- ALIAS Record: FREE (AWS 리소스)
- CNAME Record: $0.40/M

#### 4. Route 53 Routing Policies
**파일**: `route53_routing_policies.png`
**위치**: Session 1 - 핵심 원리 (How?)
**설명**: 6가지 라우팅 정책 개요
- Simple Routing
- Weighted Routing (70%/30%)
- Latency Routing (Seoul/Virginia/Ireland)
- Failover Routing (Primary/Secondary)

#### 5. Route 53 Latency Based Routing
**파일**: `route53_latency_routing.png`
**위치**: Session 1 - 주요 사용 사례 (When?) - 글로벌 서비스
**설명**: 지역별 최적 서버 자동 연결
- Korea User → Seoul
- US User → Virginia
- EU User → Ireland
- Lowest Latency 기반 라우팅

#### 6. Route 53 Failover Routing
**파일**: `route53_failover_routing.png`
**위치**: Session 1 - 주요 사용 사례 (When?) - 고가용성
**설명**: Primary/Secondary 자동 전환
- Primary ALB (Seoul) - Active
- Secondary ALB (Tokyo) - Standby
- Health Check 통합

#### 7. Route 53 Weighted Routing (A/B Test)
**파일**: `route53_weighted_routing.png`
**위치**: Session 1 - 주요 사용 사례 (When?) - A/B 테스트
**설명**: 트래픽 비율 조정
- Version A: 70% (3 ALBs)
- Version B: 30% (2 ALBs)
- 카나리 배포 시나리오

---

## 📁 기존 다이어그램 (Day 5 전체)

### Session 2: CloudFront (CDN)
- `cloudfront_cdn.png`: CloudFront Edge Locations 및 캐싱

### Session 3: ACM (SSL/TLS)
- `acm_certificate.png`: ACM 인증서 발급 및 검증

### Day 5 통합
- `https_stack.png`: Route 53 + CloudFront + ACM 통합 스택
- `route53_dns.png`: Route 53 DNS 기본 구조
- `route53_flow.png`: Route 53 전체 흐름

### CloudMart 프로젝트
- `cloudmart_architecture.png`: CloudMart AWS 아키텍처
- `docker_to_aws.png`: Docker Compose → AWS 마이그레이션

---

## 🎯 다이어그램 활용 가이드

### Session 1 강의 흐름
1. **DNS 기본 개념** → `route53_dns_flow.png`
2. **Health Check** → `route53_health_check.png`
3. **레코드 타입 비교** → `route53_record_types.png`
4. **라우팅 정책 개요** → `route53_routing_policies.png`
5. **글로벌 서비스** → `route53_latency_routing.png`
6. **고가용성** → `route53_failover_routing.png`
7. **A/B 테스트** → `route53_weighted_routing.png`

### 실습 연계
- Lab 1에서 실제 Route 53 설정 시 다이어그램 참조
- 각 라우팅 정책 실습 시 해당 다이어그램 확인

---

## ✅ 다이어그램 품질 체크

### 생성 완료 항목
- [x] Route 53 DNS Flow
- [x] Health Check
- [x] Record Types
- [x] Routing Policies Overview
- [x] Latency Routing
- [x] Failover Routing
- [x] Weighted Routing

### 다이어그램 특징
- ✅ AWS 공식 아이콘 사용
- ✅ 영어 라벨 (한글 폰트 미지원)
- ✅ 여백 최소화 (pad: 0.1)
- ✅ 명확한 흐름 표시
- ✅ 색상 코딩 (green: active, red: failover, orange: standby)

---

<div align="center">

**📊 7개 신규 다이어그램** • **🎨 AWS 공식 아이콘** • **🔄 실습 연계**

*Session 1 Route 53 완전 시각화 완료*

</div>
