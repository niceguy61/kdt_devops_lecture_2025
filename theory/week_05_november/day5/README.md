# Week 5 November Day 5: Terraform으로 ECS 보안 구성

<div align="center">

**🔐 민감 정보 관리** • **📦 Parameter Store** • **🔑 IAM 역할** • **🛡️ 보안 베스트 프랙티스**

*Terraform으로 ECS Task에 안전하게 민감 정보 전달하기*

</div>

---

## 🕘 일일 스케줄

### 📊 시간 배분
```
📚 이론 강의: 50분 (Session 3)
🛠️ 실습: 50분 (Lab 1)
```

### 🗓️ 상세 스케줄
| 시간 | 구분 | 내용 | 비고 |
|------|------|------|------|
| **11:00-11:50** | 📚 이론 | Session 3: Terraform에서 ECS 보안 변수 관리 | 개념 + 이론 |
| **11:50-12:00** | ☕ 휴식 | 10분 휴식 | |
| **12:00-13:00** | 🍽️ 점심 | 점심시간 (60분) | ⭐ 고정 |
| **13:00-14:00** | 🛠️ 실습 준비 | Lab 1 환경 설정 | Terraform 설치 확인 |
| **14:00-14:50** | 🛠️ 실습 | Lab 1: Terraform으로 ECS 보안 구성 | 3단계 실습 |

---

## 🎯 Day 5 학습 목표

### 📚 이론 목표
- Terraform에서 민감 정보를 안전하게 관리하는 방법 이해
- Parameter Store와 Secrets Manager의 차이점 파악
- ECS Task Definition 보안 패턴 학습
- IAM 역할 분리 원칙 적용

### 🛠️ 실습 목표
- Task Execution Role에 Parameter Store 읽기 권한 부여
- Parameter Store에 민감 정보 안전하게 저장
- ECS Task Definition에서 secrets 블록으로 참조

---

## 📚 Session 3: Terraform에서 ECS 보안 변수 관리 (11:00-11:50)

### 🎯 세션 목표
Terraform에서 ECS Task에 민감 정보를 안전하게 전달하는 방법 학습

### 📖 핵심 내용

#### 1. 민감 정보 관리 전략 (12분)
- **실제 보안 사고 사례**:
  - GitHub에 AWS 키 노출
  - CloudWatch Logs에 비밀번호 평문 노출
  - 환경별 변수 혼용
- **해결 방법**:
  - Parameter Store (무료, 간단)
  - Secrets Manager (자동 로테이션, 유료)
  - Terraform sensitive 변수

#### 2. Parameter Store 아키텍처 (12분)
- **계층적 파라미터 구조**:
  ```
  /myapp/
    /dev/
      /db/password
      /api/key
    /prod/
      /db/password
      /api/key
  ```
- **SecureString 타입**: KMS 암호화
- **버전 관리**: 파라미터 업데이트 추적

#### 3. ECS Task Definition 보안 패턴 (11분)
- **environment vs secrets**:
  - environment: 비민감 정보 (평문)
  - secrets: 민감 정보 (암호화)
- **IAM 역할 분리**:
  - Task Execution Role: Parameter Store 읽기
  - Task Role: 애플리케이션 권한

### 🔗 Session 문서
📄 [Session 3 상세 내용](./session_3.md)

---

## 🛠️ Lab 1: Terraform으로 ECS 보안 구성 실습 (14:00-14:50)

### 🎯 실습 목표
3단계로 ECS 보안 인프라 구축

### 🏗️ 구축 아키텍처

```mermaid
graph TB
    subgraph "Step 1: Task 권한"
        EXEC[Task Execution Role<br/>+ Parameter Store 읽기 권한]
    end
    
    subgraph "Step 2: Parameter Store"
        P1[/myapp/prod/db/password<br/>SecureString]
        P2[/myapp/prod/api/key<br/>SecureString]
    end
    
    subgraph "Step 3: Task Definition"
        TD[Task Definition<br/>secrets 블록]
        T[Container<br/>환경변수로 주입]
    end
    
    EXEC --> P1
    EXEC --> P2
    TD --> EXEC
    TD --> P1
    TD --> P2
    TD --> T
    
    style EXEC fill:#fff3e0
    style P1 fill:#e3f2fd
    style P2 fill:#e3f2fd
    style TD fill:#e8f5e8
    style T fill:#f3e5f5
```

### 📝 실습 단계

#### Step 1: Task 권한 설정 (15분)
- Terraform 프로젝트 구조 생성
- Task Execution Role 생성
- Parameter Store 읽기 권한 부여

**생성 리소스**:
- `aws_iam_role` (Task Execution Role)
- `aws_iam_role_policy_attachment` (AWS 관리형 정책)
- `aws_iam_role_policy` (Parameter Store 읽기)

#### Step 2: Parameter Store 구현 (15분)
- SecureString 파라미터 생성 (민감 정보)
- String 파라미터 생성 (비민감 정보)
- 계층적 경로 구조 구성

**생성 리소스**:
- `aws_ssm_parameter` (db_password - SecureString)
- `aws_ssm_parameter` (api_key - SecureString)
- `aws_ssm_parameter` (db_host - String)
- `aws_ssm_parameter` (db_port - String)

#### Step 3: Task Definition - secrets 블록 (15분)
- CloudWatch Logs 그룹 생성
- Task Definition 생성
- secrets 블록으로 Parameter Store 참조
- environment 블록으로 비민감 정보 전달

**생성 리소스**:
- `aws_cloudwatch_log_group`
- `aws_ecs_task_definition`

### 💰 예상 비용
- **총 비용**: $0.0005 (1시간 기준)
- Parameter Store Standard: 무료
- CloudWatch Logs: $0.0005

### 🔗 Lab 문서
📄 [Lab 1 상세 가이드](./lab_1.md)

---

## 🔑 핵심 키워드

### 🆕 새로운 용어
- **Parameter Store**: AWS Systems Manager의 계층적 파라미터 저장소
- **SecureString**: KMS로 암호화된 Parameter Store 타입
- **Task Execution Role**: ECS 에이전트가 사용하는 IAM 역할
- **secrets 블록**: Task Definition에서 민감 정보를 참조하는 방법

### 🔤 기술 용어
- **KMS (Key Management Service)**: AWS 암호화 키 관리 서비스
- **ARN (Amazon Resource Name)**: AWS 리소스 고유 식별자
- **IAM Policy**: AWS 리소스 접근 권한 정의

### 🔤 실무 용어
- **Secrets Rotation**: 비밀번호 자동 변경
- **Least Privilege**: 최소 권한 원칙
- **Sensitive Variables**: Terraform 민감 변수

---

## ✅ Day 5 체크리스트

### 📚 이론 학습
- [ ] 민감 정보 관리 방법 이해
- [ ] Parameter Store vs Secrets Manager 비교
- [ ] IAM 역할 분리 원칙 파악
- [ ] Task Definition 보안 패턴 학습

### 🛠️ 실습 완료
- [ ] Task Execution Role 생성
- [ ] Parameter Store 파라미터 생성
- [ ] Task Definition secrets 블록 설정
- [ ] 전체 시스템 검증

### 🔐 보안 검증
- [ ] SecureString 암호화 확인
- [ ] IAM 권한 최소화 적용
- [ ] Parameter Store 접근 테스트
- [ ] CloudWatch Logs 연동 확인

---

## 🔗 관련 자료

### 📖 AWS 공식 문서
- [ECS Task Definition - Secrets](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html)
- [Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html)
- [IAM Roles for Tasks](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html)

### 🎓 이전 Day 복습
- [Day 1: ECS 기초](../day1/README.md)
- [Day 2: ECS 배포 전략](../day2/README.md)
- [Day 3: 모니터링 및 로깅](../day3/README.md)
- [Day 4: Auto Scaling](../day4/README.md)

### 🚀 다음 학습
- **Week 3**: Kubernetes 기초
- **연계 내용**: ECS 보안 개념을 Kubernetes Secrets로 확장

---

## 💡 학습 팁

### 🎯 효과적인 학습 방법
1. **Session 3 먼저**: 이론을 충분히 이해한 후 실습
2. **단계별 진행**: Lab 1의 3단계를 순서대로 완료
3. **검증 필수**: 각 Step마다 검증 명령어 실행
4. **리소스 정리**: 실습 완료 후 반드시 `terraform destroy`

### ⚠️ 주의사항
- **terraform.tfvars**: Git에 커밋하지 않기 (.gitignore 추가)
- **민감 정보**: 절대 코드에 하드코딩하지 않기
- **비용 관리**: 실습 후 즉시 리소스 삭제
- **권한 최소화**: 필요한 권한만 부여

### 🤝 협업 학습
- **페어 프로그래밍**: 2명씩 함께 실습
- **코드 리뷰**: 서로의 Terraform 코드 검토
- **문제 해결**: 막힐 때 함께 트러블슈팅

---

## 🎓 Day 5 학습 성과

### 기술적 성취
- ✅ Terraform으로 ECS 보안 인프라 구축
- ✅ Parameter Store SecureString 활용
- ✅ IAM 역할 분리 원칙 적용
- ✅ Task Definition 보안 패턴 구현

### 실무 역량
- ✅ 민감 정보 관리 베스트 프랙티스
- ✅ Terraform 보안 코드 작성
- ✅ AWS 보안 서비스 통합
- ✅ 트러블슈팅 능력 향상

---

<div align="center">

**🔐 보안 우선** • **📦 중앙 관리** • **🔑 최소 권한** • **🛡️ 암호화 필수**

*Day 5: Terraform으로 ECS 보안 완성*

</div>
