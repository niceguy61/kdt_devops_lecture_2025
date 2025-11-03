# November Week 2 Day 1: 메시징 & 큐 + Terraform 기초

<div align="center">

**📨 SQS** • **📢 SNS** • **📝 Terraform** • **🔄 비동기 처리**

*메시지 큐와 IaC의 시작*

</div>

---

## 🕘 일일 스케줄

| 시간 | 구분 | 내용 | 비고 |
|------|------|------|------|
| **09:00-09:40** | 📚 Session 1 | SQS (Simple Queue Service) | 메시지 큐 기초 |
| **09:40-10:20** | 📚 Session 2 | SNS (Simple Notification Service) | Pub/Sub 패턴 |
| **10:20-11:00** | 📚 Session 3 | Terraform 기초 | IaC 개념 |
| **11:00-12:00** | 🛠️ Lab 1 | SQS + SNS 비동기 처리 시스템 | 실습 |

---

## 🎯 Day 1 목표

### 전체 학습 목표
- 메시지 큐를 통한 비동기 처리 이해
- Pub/Sub 패턴으로 시스템 분리
- IaC 개념 및 Terraform 기초 습득

### 주요 성과물
- SQS + SNS 비동기 메시징 시스템
- Dead Letter Queue 장애 처리
- (선택) Terraform으로 인프라 코드화

---

## 📚 Session 구성

### Session 1: SQS (09:00-09:40)
**[📖 Session 1 자료 보기](./session_1.md)**

**핵심 내용**:
- 메시지 큐 개념 및 비동기 처리 필요성
- Standard vs FIFO Queue 차이
- Dead Letter Queue (DLQ) 개념
- 실무 사용 사례

**학습 포인트**:
- 동기 vs 비동기 처리 비교
- 시스템 분리 및 확장성
- 장애 격리 효과

### Session 2: SNS (09:40-10:20)
**[📖 Session 2 자료 보기](./session_2.md)**

**핵심 내용**:
- Pub/Sub 패턴 이해
- 이메일, SMS, 모바일 푸시 알림
- SQS + SNS Fan-out 패턴
- 구독 프로토콜 6가지

**학습 포인트**:
- 1:N 메시지 전달
- 다중 구독자 처리
- 알림 시스템 구축

**최신 업데이트**:
- Cross-Region 전달 강화 (2025.07)
- IPv6 지원 (2025.04)
- SNS FIFO 고처리량 모드 (2024)

### Session 3: Terraform 기초 (10:20-11:00)
**[📖 Session 3 자료 보기](./session_3.md)**

**핵심 내용**:
- IaC가 필요한 이유
- Terraform vs CloudFormation 비교
- HCL (HashiCorp Configuration Language) 기본 문법
- Provider, Resource, Variable, Output 개념

**학습 포인트**:
- 인프라 버전 관리
- 재현 가능한 환경
- 협업 효율성

**⚠️ 중요 주의사항**:
- 웹 콘솔과 Terraform 혼용 금지
- State 파일 관리의 중요성
- 콘솔 생성 리소스로 인한 충돌 문제

---

## 🛠️ Lab 1: SQS + SNS 비동기 주문 처리 시스템 (11:00-12:00)
**[🔧 Lab 1 실습 가이드](./lab_1.md)**

### 실습 목표
- SQS Queue 생성 및 메시지 전송/수신
- SNS Topic 생성 및 구독 설정
- SNS + SQS Fan-out 패턴 구현
- (선택) Terraform으로 인프라 코드화

### 구현 아키텍처
```
사용자 주문
    ↓
Lambda (Order API)
    ↓
SNS Topic (order-completed)
    ↓
├─→ SQS (email-queue) → Lambda (Email Worker)
├─→ SQS (inventory-queue) → Lambda (Inventory Worker)
└─→ SQS (analytics-queue) → Lambda (Analytics Worker)
```

### 실습 단계
1. **Phase 1**: SQS 기본 구성 (20분)
   - Queue + DLQ 생성
   - Lambda Producer 구현

2. **Phase 2**: SNS Fan-out 패턴 (25분)
   - SNS Topic 생성
   - 3개 Queue 구독 설정
   - Access Policy 설정

3. **Phase 3**: Lambda Consumer 구현 (10분)
   - 3개 Worker Lambda 생성
   - 자동 처리 확인

4. **Phase 4**: Terraform 재구성 (선택, 15분)
   - 전체 인프라 코드화
   - 수동 vs IaC 비교

---

## 📦 사전 준비

### Terraform 설치 및 설정 (필수)
**[📖 Terraform 설치 가이드](../TERRAFORM_SETUP.md)**

Lab Phase 4 (Terraform)를 진행하려면 사전 설정이 필요합니다:
- Terraform 설치
- AWS CLI 설치
- AWS Access Key 생성
- AWS 인증 설정
- 환경 검증

**⚠️ Lab 시작 전 반드시 완료하세요!**

---

## 💰 예상 비용

### Day 1 리소스 비용
| 리소스 | 사용량 | 단가 | 예상 비용 |
|--------|--------|------|-----------|
| SQS | 100 요청 | 무료 (프리티어) | $0.00 |
| SNS | 10 발행 | 무료 (프리티어) | $0.00 |
| Lambda | 10 실행 | 무료 (프리티어) | $0.00 |
| **합계** | | | **$0.05** |

### 비용 절감 팁
- 프리티어 충분히 활용
- 실습 완료 후 즉시 리소스 삭제
- SQS/SNS는 요청 기반 과금 (사용한 만큼만)

---

## ✅ Day 1 완료 체크리스트

### Session 이해도
- [ ] SQS 메시지 큐 개념 이해
- [ ] Standard vs FIFO Queue 차이 파악
- [ ] Dead Letter Queue 활용 방법 습득
- [ ] SNS Pub/Sub 패턴 이해
- [ ] Fan-out 패턴 구현 방법 파악
- [ ] IaC 개념 및 필요성 이해
- [ ] Terraform 기본 문법 습득
- [ ] 웹 콘솔 혼용 위험성 인지

### Lab 완료
- [ ] SQS Queue 생성 및 메시지 처리
- [ ] SNS Topic 생성 및 구독 설정
- [ ] Fan-out 패턴 구현 성공
- [ ] Lambda 통합 완료
- [ ] (선택) Terraform 코드 작성 및 실행
- [ ] 모든 리소스 정리 완료

---

## 🔗 참고 자료

### AWS 공식 문서
- [SQS 사용자 가이드](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/)
- [SNS 사용자 가이드](https://docs.aws.amazon.com/sns/latest/dg/)
- [SQS + SNS Fan-out 패턴](https://docs.aws.amazon.com/sns/latest/dg/sns-sqs-as-subscriber.html)

### Terraform 문서
- [Terraform 공식 문서](https://www.terraform.io/docs)
- [AWS Provider 문서](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform 튜토리얼](https://learn.hashicorp.com/terraform)

### 추가 학습
- [AWS 메시징 서비스 비교](https://aws.amazon.com/messaging/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

---

## 🎯 다음 Day 준비

### Day 2 예고: API & 인증 + Terraform 명령어
**주요 내용**:
- API Gateway (REST API vs HTTP API)
- Cognito (사용자 인증/인가)
- Terraform 기본 명령어 (init, plan, apply, destroy)
- Cognito + API Gateway + Lambda 통합

**사전 학습**:
- REST API 기본 개념
- JWT 토큰 이해
- Terraform 명령어 복습

---

## 💡 학습 팁

### 효과적인 학습 방법
1. **Session 집중**: 이론을 확실히 이해하고 Lab 진행
2. **실습 중심**: 직접 해보면서 체득
3. **에러 경험**: 에러를 두려워하지 말고 해결 과정 학습
4. **비교 학습**: 수동 vs Terraform 차이 체감

### 주의사항
- ⚠️ AWS Access Key 보안 관리
- ⚠️ 실습 후 반드시 리소스 정리
- ⚠️ Terraform State 파일 Git 커밋 금지
- ⚠️ 웹 콘솔과 Terraform 혼용 금지

---

<div align="center">

**📨 메시징** • **🔄 비동기** • **📝 IaC** • **🚀 자동화**

*Day 1: 메시지 큐와 인프라 코드화의 시작*

</div>
