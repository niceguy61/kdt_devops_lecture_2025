# November Week 1 Day 4: 로드밸런싱 & 고가용성

<div align="center">

**⚖️ 로드밸런싱** • **📈 Auto Scaling** • **🔄 고가용성**

*ALB와 Auto Scaling으로 안정적이고 확장 가능한 아키텍처 구축*

</div>

---

## 🎯 Day 4 목표

### 학습 목표
- Elastic Load Balancing (ALB, NLB, CLB) 이해
- Auto Scaling Group 구성 및 정책 설정
- 고가용성 아키텍처 설계 원칙
- ALB + ASG 통합 실습

### 실무 역량
- 트래픽 분산 및 장애 대응
- 자동 확장/축소로 비용 최적화
- Multi-AZ 고가용성 구현

---

## 📅 일일 스케줄

| 시간 | 구분 | 내용 | 방식 |
|------|------|------|------|
| **09:00-09:20** | 📚 Session 1 | Elastic Load Balancing | 이론 강의 |
| **09:30-09:50** | 📚 Session 2 | Auto Scaling | 이론 강의 |
| **10:00-10:20** | 📚 Session 3 | 고가용성 아키텍처 | 이론 강의 |
| **10:30-11:00** | ☕ 휴식 | 30분 휴식 | |
| **11:00-11:50** | 🛠️ Lab 1 | ALB + ASG 구성 | 실습 |

---

## 📚 세션 구성

### [Session 1: Elastic Load Balancing](./session_1.md) (09:00-09:20)
**주제**: ALB, NLB, CLB 비교 및 선택

**핵심 내용**:
- ELB 종류 및 특징
- ALB (Application Load Balancer)
- NLB (Network Load Balancer)
- Target Groups & Health Checks

**학습 포인트**:
- 로드밸런서 타입별 사용 사례
- Health Check 설정
- Sticky Sessions

---

### [Session 2: Auto Scaling](./session_2.md) (09:30-09:50)
**주제**: Auto Scaling Group 구성 및 정책

**핵심 내용**:
- Auto Scaling Groups (ASG)
- Launch Templates
- 스케일링 정책 (Target Tracking, Step)
- ASG + ALB 통합

**학습 포인트**:
- 자동 확장/축소 조건 설정
- 비용 최적화 전략
- 장애 대응 자동화

---

### [Session 3: 고가용성 아키텍처](./session_3.md) (10:00-10:20)
**주제**: Multi-AZ 고가용성 설계

**핵심 내용**:
- Multi-AZ 배포 전략
- 장애 복구 시나리오
- Blue-Green 배포
- Canary 배포

**학습 포인트**:
- 고가용성 설계 원칙
- 장애 대응 전략
- 무중단 배포 방법

---

## 🛠️ 실습 구성

### [Lab 1: ALB + ASG 구성](./lab_1.md) (11:00-11:50)
**목표**: 자동 확장 가능한 웹 서비스 구축

**실습 내용**:
1. Launch Template 생성
2. ALB 생성 및 Target Group 설정
3. Auto Scaling Group 구성
4. 부하 테스트 및 자동 확장 확인

**예상 결과**:
- 트래픽 증가 시 자동으로 인스턴스 추가
- 트래픽 감소 시 자동으로 인스턴스 제거
- ALB를 통한 트래픽 분산 확인

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
- [ ] ELB 종류 및 차이점 이해
- [ ] Auto Scaling 정책 이해
- [ ] 고가용성 설계 원칙 파악

### 실습 완료
- [ ] Launch Template 생성
- [ ] ALB + Target Group 구성
- [ ] ASG 생성 및 정책 설정
- [ ] 부하 테스트 성공
- [ ] 리소스 정리 완료

### 실무 역량
- [ ] 로드밸런서 선택 기준 이해
- [ ] 자동 확장 설정 능력
- [ ] 고가용성 아키텍처 설계 능력

---

<div align="center">

**⚖️ 로드밸런싱** • **📈 Auto Scaling** • **🔄 고가용성**

*안정적이고 확장 가능한 AWS 아키텍처 구축*

</div>
