# November Week 1 Day 4: 로드밸런싱 & 경로 기반 라우팅

<div align="center">

**⚖️ ALB 라우팅** • **🐳 Docker Compose** • **🔀 멀티 서비스**

*ALB 경로 기반 라우팅으로 단일 EC2의 여러 컨테이너 서비스 운영*

</div>

---

## 🎯 Day 4 목표

### 학습 목표
- Elastic Load Balancing (ALB) 이해
- 경로 기반 라우팅 (Path-based Routing) 구성
- Target Group별 포트 매핑
- 단일 EC2에서 멀티 서비스 운영

### 실무 역량
- ALB를 통한 트래픽 분산
- 마이크로서비스 패턴 구현
- 비용 효율적 아키텍처 설계

---

## 📅 일일 스케줄

| 시간 | 구분 | 내용 | 방식 |
|------|------|------|------|
| **09:00-09:40** | 📚 Session 1 | Elastic Load Balancing | 이론 강의 |
| **09:40-10:20** | 📚 Session 2 | Auto Scaling | 이론 강의 |
| **10:20-11:00** | 📚 Session 3 | 고가용성 아키텍처 | 이론 강의 |
| **11:00-11:10** | ☕ 휴식 | 10분 휴식 | |
| **11:10-12:00** | 🛠️ Lab 1 | ALB 경로 기반 라우팅 | 실습 |

---

## 📚 세션 구성

### [Session 1: Elastic Load Balancing](./session_1.md) (09:00-09:40)
**주제**: ALB, NLB, CLB 비교 및 선택 기준

**핵심 내용**:
- Elastic Load Balancing 개념
- ALB vs NLB vs CLB 비교
- Target Groups & Health Checks
- Listener Rules & 라우팅

**학습 포인트**:
- 로드밸런서 타입별 특징
- 경로 기반 라우팅 (ALB)
- Health Check 설정 방법

---

### [Session 2: Auto Scaling](./session_2.md) (09:40-10:20)
**주제**: Auto Scaling Group 구성 및 정책 설정

**핵심 내용**:
- Auto Scaling 개념 및 필요성
- Launch Template 구성
- Scaling Policy (Target Tracking, Step, Scheduled)
- ALB + ASG 통합

**학습 포인트**:
- 자동 확장/축소 원리
- 스케일링 정책 선택 기준
- 비용 최적화 전략

---

### [Session 3: 고가용성 아키텍처](./session_3.md) (10:20-11:00)
**주제**: Multi-AZ 배포 및 무중단 배포 전략

**핵심 내용**:
- Multi-AZ 고가용성 설계
- 장애 복구 시나리오
- Blue-Green 배포
- Canary 배포

**학습 포인트**:
- 고가용성 설계 원칙
- 무중단 배포 방법
- 장애 대응 전략

---

## 🛠️ 실습 구성

### [Lab 1: ALB 경로 기반 라우팅 + Docker Compose](./lab_1.md) (11:10-12:00)
**목표**: 단일 EC2에서 여러 컨테이너 서비스를 ALB로 라우팅

**실습 내용**:
1. EC2 생성 + Docker/Docker Compose 설치
2. Docker Compose로 3개 컨테이너 실행 (포트 8080, 8081, 8082)
3. ALB 생성 + 3개 Target Group (각각 다른 포트)
4. 경로 기반 라우팅 설정 (/api/*, /backend/*, /admin/*)
5. 테스트: ALB DNS로 각 경로 접근 확인

**예상 결과**:
- `http://ALB-DNS/api` → API 컨테이너 응답
- `http://ALB-DNS/backend` → Backend 컨테이너 응답
- `http://ALB-DNS/admin` → Admin 컨테이너 응답

---

## 🔗 연계 학습

### 이전 Day 복습
- **Day 1**: VPC 네트워크 구조
- **Day 2**: EC2 인스턴스 관리
- **Day 3**: RDS 고가용성 (Multi-AZ)

### 다음 Day 예고
- **Day 5**: CloudMart 프로젝트 AWS 배포
  - 전체 아키텍처 통합
  - 프로덕션 환경 구축

---

## 💰 예상 비용

| 리소스 | 사용 시간 | 단가 | 예상 비용 |
|--------|----------|------|-----------|
| ALB | 1시간 | $0.0225/hour | $0.023 |
| EC2 t3.micro (2-4대) | 1시간 | $0.0104/hour | $0.042 |
| 데이터 전송 | 1GB | $0.09/GB | $0.09 |
| **합계** | | | **$0.16** |

---

## ✅ Day 4 체크리스트

### 이론 학습
- [ ] Elastic Load Balancing 개념 이해
- [ ] ALB vs NLB vs CLB 차이점 파악
- [ ] Auto Scaling 원리 및 정책 이해
- [ ] Multi-AZ 고가용성 설계 이해
- [ ] 무중단 배포 전략 파악

### 실습 완료
- [ ] EC2 + Docker 환경 구축
- [ ] Docker Compose 3개 컨테이너 실행
- [ ] ALB + 3개 Target Group 구성
- [ ] 경로 기반 라우팅 설정
- [ ] 각 경로별 접근 테스트 성공
- [ ] 리소스 정리 완료

### 실무 역량
- [ ] ALB 라우팅 규칙 설정 능력
- [ ] Auto Scaling 정책 구성 능력
- [ ] 단일 호스트 멀티 서비스 운영
- [ ] 고가용성 아키텍처 설계
- [ ] 비용 효율적 운영 전략

---

<div align="center">

**⚖️ 로드밸런싱** • **📈 Auto Scaling** • **🔄 고가용성**

*안정적이고 확장 가능한 AWS 아키텍처 구축*

</div>
