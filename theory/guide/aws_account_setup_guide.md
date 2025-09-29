# 🚀 팀장용 AWS 계정 세팅 가이드

<div align="center">

**🎯 팀 프로젝트를 위한 AWS 계정 구성** • **💰 비용 최적화 중심**

*안전하고 경제적인 AWS 환경 구축 가이드*

</div>

---

## 📋 개요

### 🎯 목표
- 팀 프로젝트용 AWS 계정 생성 및 구성
- 강사 계정(261250906071)과의 ReadOnly 권한 연동
- 팀원 접근 권한 관리 (IAM/SSO)
- 비용 최적화 및 예산 관리 설정

### ⚠️ 중요 사항
- **비용 지원**: 기본 프로젝트(11월) 20만원, 심화 프로젝트 30만원 지원
- **예산 관리**: 지원 금액 초과 방지를 위한 엄격한 비용 통제
- **강사 지원**: 아키텍처 점검 및 비용 누수 방지를 위한 강사 계정 연동
- **협업**: 팀원 모두가 접근 가능한 환경 구성

---

## 🔧 Step 1: AWS 계정 생성

### 1-1. 개인 AWS 계정 생성

**🌐 AWS 계정 가입**
```bash
# AWS 콘솔 접속
https://aws.amazon.com/ko/
```

**📝 가입 절차**:
1. **이메일 주소**: 팀 대표 이메일 또는 개인 이메일
2. **계정 이름**: `[팀명]-devops-2025` (예: team1-devops-2025)
3. **결제 정보**: 신용카드 등록 (필수)
4. **전화번호 인증**: SMS 인증 완료
5. **지원 플랜**: Basic (무료) 선택

**✅ 체크포인트**:
- [ ] AWS 계정 생성 완료
- [ ] 루트 계정 MFA 설정 완료
- [ ] 결제 정보 등록 완료

---

## 🔐 Step 2: 강사 계정 ReadOnly 권한 부여

### 2-1. Cross-Account Role 생성

**🎯 목적**: 강사 계정(261250906071)에서 팀 계정을 ReadOnly로 접근하여 아키텍처 점검 및 비용 누수 방지

**IAM 역할 생성**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::261250906071:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "kdt-devops-2025"
        }
      }
    }
  ]
}
```

### 2-2. ReadOnly 정책 연결

**📋 연결할 정책들**:
- `ReadOnlyAccess` (AWS 관리형 정책)
- `Billing` 조회 권한 (비용 분석용)
- `CloudWatchReadOnlyAccess` (모니터링 분석용)

**🔧 설정 방법**:
1. **IAM 콘솔** → **역할** → **역할 생성**
2. **신뢰할 수 있는 엔터티**: 다른 AWS 계정
3. **계정 ID**: `261250906071` (강사 계정)
4. **외부 ID**: `kdt-devops-2025`
5. **정책 연결**: ReadOnlyAccess + Billing 조회 권한
6. **역할 이름**: `KDT-DevOps-Instructor-ReadOnly-Role`

**✅ 체크포인트**:
- [ ] Cross-Account Role 생성 완료
- [ ] ReadOnly 정책 연결 완료
- [ ] 역할 ARN 확인 및 기록

---

## 👥 Step 3: 팀원 접근 권한 설정

### 3-1. 접근 방식 선택

```mermaid
graph TB
    A[팀원 접근 방식 선택] --> B{비용 고려}
    B -->|무료| C[IAM 사용자]
    B -->|유료 가능| D[AWS SSO]
    
    C --> C1[IAM 사용자 생성]
    C --> C2[개별 액세스 키 발급]
    C --> C3[콘솔 로그인 설정]
    
    D --> D1[SSO 활성화]
    D --> D2[이메일 초대]
    D --> D3[권한 그룹 관리]
    
    style A fill:#e8f5e8
    style C fill:#fff3e0
    style D fill:#ffebee
```

### 3-2. 권장 방식: IAM 사용자 (비용 무료)

**👤 팀원별 IAM 사용자 생성**:
```bash
# AWS CLI로 사용자 생성 (선택사항)
aws iam create-user --user-name team-member-1
aws iam create-user --user-name team-member-2
aws iam create-user --user-name team-member-3
```

**🔑 콘솔 접근 설정**:
1. **IAM 콘솔** → **사용자** → **사용자 추가**
2. **사용자 이름**: `team-member-[번호]`
3. **액세스 유형**: AWS Management Console 액세스
4. **콘솔 비밀번호**: 자동 생성 또는 사용자 지정
5. **비밀번호 재설정**: 다음 로그인 시 필요

**📋 권한 정책 연결**:
- `ReadOnlyAccess`: 기본 읽기 권한
- `IAMReadOnlyAccess`: IAM 정보 조회
- 사용자 정의 정책 (필요시)

### 3-3. 대안: AWS SSO (Identity Center)

**💰 비용**: 월 $6/사용자 (5명 이상 시 고려)

**🚀 SSO 설정 (선택사항)**:
1. **AWS SSO 활성화**
2. **사용자 그룹 생성**: `DevOps-Team`
3. **이메일 초대**: 팀원 이메일로 초대
4. **권한 세트**: ReadOnly 권한 할당

**✅ 체크포인트**:
- [ ] 팀원 접근 방식 결정
- [ ] 사용자 계정 생성 완료
- [ ] 로그인 정보 팀원 공유

---

## 🧪 Step 4: ReadOnly 접근 테스트

### 4-1. 기본 접근 테스트

**🔍 테스트 항목들**:
```bash
# EC2 인스턴스 조회 (읽기)
aws ec2 describe-instances

# S3 버킷 목록 조회 (읽기)
aws s3 ls

# IAM 사용자 목록 조회 (읽기)
aws iam list-users

# 리소스 생성 시도 (실패해야 함)
aws ec2 run-instances --image-id ami-12345 --instance-type t2.micro
# 예상 결과: AccessDenied 오류
```

### 4-2. 권한 검증 체크리스트

**✅ 읽기 권한 확인**:
- [ ] EC2 인스턴스 목록 조회 가능
- [ ] S3 버킷 및 객체 조회 가능
- [ ] CloudWatch 메트릭 조회 가능
- [ ] 비용 및 청구 정보 조회 가능

**❌ 쓰기 권한 차단 확인**:
- [ ] EC2 인스턴스 생성 차단됨
- [ ] S3 객체 업로드 차단됨
- [ ] IAM 정책 수정 차단됨
- [ ] 리소스 삭제 차단됨

### 4-3. 강사 계정 연동 테스트

**🔗 Cross-Account 접근 테스트**:
```bash
# 강사 계정에서 팀 계정 역할 assume (강사가 수행)
aws sts assume-role \
  --role-arn "arn:aws:iam::[팀계정ID]:role/KDT-DevOps-Instructor-ReadOnly-Role" \
  --role-session-name "instructor-review-session" \
  --external-id "kdt-devops-2025"
```

**👨‍🏫 강사 지원 내용**:
- **아키텍처 검토**: 팀 프로젝트 아키텍처의 적절성 점검
- **비용 모니터링**: 예상치 못한 비용 발생 원인 분석
- **보안 점검**: 기본적인 보안 설정 확인
- **리소스 최적화**: 불필요한 리소스 사용 패턴 식별

---

## 💰 Step 5: 예산 및 비용 관리 설정

### 5-1. 프로젝트별 예산 설정

**💳 비용 지원 계획**:
- **기본 프로젝트 (11월)**: 20만원 (~$150)
- **심화 프로젝트 (12월-1월)**: 30만원 (~$225)

**📊 예산 생성**:
```mermaid
graph TB
    A[프로젝트별 예산] --> B[기본 프로젝트<br/>$150/월]
    A --> C[심화 프로젝트<br/>$225/월]
    
    B --> B1[70% 알림<br/>$105]
    B --> B2[85% 알림<br/>$127]
    B --> B3[95% 알림<br/>$142]
    
    C --> C1[70% 알림<br/>$157]
    C --> C2[85% 알림<br/>$191]
    C --> C3[95% 알림<br/>$213]
    
    style A fill:#e8f5e8
    style B fill:#fff3e0
    style C fill:#f3e5f5
    style B1,C1 fill:#ffebee
    style B2,C2 fill:#ffcdd2
    style B3,C3 fill:#f44336
```

**⚙️ 기본 프로젝트 예산 설정 (11월)**:
1. **Billing 콘솔** → **Budgets** → **Create budget**
2. **Budget type**: Cost budget
3. **Budget amount**: $150 (Monthly)
4. **Alert thresholds**: 
   - 70% ($105) - 이메일 알림
   - 85% ($127) - 이메일 + SMS + 강사 알림
   - 95% ($142) - 긴급 알림 + 리소스 검토

**⚙️ 심화 프로젝트 예산 설정 (12월-1월)**:
1. **Budget amount**: $225 (Monthly)
2. **Alert thresholds**: 
   - 70% ($157) - 이메일 알림
   - 85% ($191) - 이메일 + SMS + 강사 알림
   - 95% ($213) - 긴급 알림 + 리소스 검토

### 5-2. 비용 통제 정책 (필수 적용)

**🛡️ 엄격한 비용 차단 정책**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": [
        "ec2:RunInstances"
      ],
      "Resource": "*",
      "Condition": {
        "ForAllValues:StringNotEquals": {
          "ec2:InstanceType": [
            "t2.micro",
            "t2.small",
            "t3.micro",
            "t3.small",
            "t3.medium"
          ]
        }
      }
    },
    {
      "Effect": "Deny",
      "Action": [
        "rds:CreateDBInstance"
      ],
      "Resource": "*",
      "Condition": {
        "ForAllValues:StringNotEquals": {
          "rds:db-instance-class": [
            "db.t3.micro",
            "db.t3.small"
          ]
        }
      }
    }
  ]
}
```

**🚫 절대 금지 서비스 (비용 폭탄 방지)**:
- **GPU 인스턴스**: p3, p4, g4, g5 시리즈 완전 차단
- **대용량 인스턴스**: m5.large 이상, c5.large 이상 차단
- **고성능 데이터베이스**: RDS r5, x1 시리즈 차단
- **대용량 스토리지**: EBS 100GB 이상 차단
- **NAT Gateway**: 고비용 네트워킹 서비스 제한
- **Elasticsearch**: 관리형 서비스 제한

**⚠️ 주의 서비스 (사전 승인 필요)**:
- **Load Balancer**: ALB/NLB 사용 시 강사 승인
- **CloudFront**: CDN 사용 시 트래픽 제한
- **Lambda**: 대량 실행 방지
- **API Gateway**: 호출량 제한

### 5-3. 자동 리소스 정리

**🔄 자동화 스크립트**:
```bash
#!/bin/bash
# 매일 밤 12시 실행되는 정리 스크립트

# 중지된 EC2 인스턴스 7일 후 종료
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=stopped" \
  --query 'Reservations[].Instances[?LaunchTime<=`2024-01-01`].[InstanceId]' \
  --output text | xargs -I {} aws ec2 terminate-instances --instance-ids {}

# 사용하지 않는 EBS 볼륨 삭제 (7일 이상 미연결)
aws ec2 describe-volumes \
  --filters "Name=status,Values=available" \
  --query 'Volumes[?CreateTime<=`2024-01-01`].[VolumeId]' \
  --output text | xargs -I {} aws ec2 delete-volume --volume-id {}

# 오래된 스냅샷 삭제 (30일 이상)
aws ec2 describe-snapshots --owner-ids self \
  --query 'Snapshots[?StartTime<=`2024-01-01`].[SnapshotId]' \
  --output text | xargs -I {} aws ec2 delete-snapshot --snapshot-id {}
```

---

## 🚨 초보자 비용 절약 가이드

### 💡 주요 비용 발생 원인과 예방

**1. 🖥️ EC2 인스턴스 관련**
```mermaid
graph TB
    A[EC2 비용 절약] --> B[인스턴스 타입]
    A --> C[사용 시간]
    A --> D[스토리지]
    
    B --> B1[t2.micro 사용<br/>프리티어]
    B --> B2[t3.small 최대<br/>학습용]
    
    C --> C1[사용 후 즉시 중지]
    C --> C2[자동 스케줄링]
    
    D --> D1[gp3 8GB 이하]
    D --> D2[불필요한 스냅샷 삭제]
    
    style A fill:#e8f5e8
    style B1,C1,D1 fill:#c8e6c9
    style B2,C2,D2 fill:#fff3e0
```

**⚠️ 피해야 할 것들**:
- ❌ **대용량 인스턴스**: m5.large 이상 ($0.096/시간)
- ❌ **GPU 인스턴스**: p3.2xlarge ($3.06/시간)
- ❌ **24시간 실행**: 인스턴스 중지 잊지 말기
- ❌ **다중 AZ**: 학습용으로는 단일 AZ 사용

**✅ 권장 사항 (예산 내 사용)**:
- ✅ **t2.micro**: 프리티어 ($0/월, 750시간) - 기본 프로젝트 추천
- ✅ **t3.small**: 학습용 적정 ($0.0208/시간) - 심화 프로젝트 추천
- ✅ **t3.medium**: 최대 허용 ($0.0416/시간) - 강사 승인 필요
- ✅ **즉시 중지**: 사용 후 바로 중지 (필수)
- ✅ **스케줄링**: CloudWatch Events로 자동 중지 설정

**💰 예산별 사용 가이드**:
- **기본 프로젝트 (20만원)**: t2.micro 주로 사용, 간단한 웹 서비스
- **심화 프로젝트 (30만원)**: t3.small 허용, 복잡한 마이크로서비스

**2. 💾 스토리지 관련**

**EBS 볼륨 최적화 (예산 내 사용)**:
```bash
# 기본 프로젝트 권장 설정
Volume Type: gp3 (최신, 비용 효율적)
Size: 8GB (프리티어) ~ 20GB (최대)
IOPS: 3000 (기본값)
Throughput: 125 MB/s (기본값)

# 심화 프로젝트 허용 설정
Size: 30GB 최대 (강사 승인 시)
IOPS: 3000 유지
Throughput: 125 MB/s 유지
```

**🚨 절대 금지 스토리지**:
- **대용량 EBS**: 100GB 이상 완전 차단
- **고성능 스토리지**: io1, io2 타입 차단
- **스냅샷 남용**: 자동 삭제 설정 필수

**S3 스토리지 관리**:
- **Standard**: 자주 접근하는 파일만
- **IA (Infrequent Access)**: 백업용
- **Lifecycle Policy**: 30일 후 자동 삭제

**3. 🌐 네트워킹 관련**

**데이터 전송 비용 절약**:
- **같은 AZ 내**: 무료
- **다른 AZ 간**: $0.01/GB
- **인터넷 아웃바운드**: $0.09/GB (첫 1GB 무료)

**권장 아키텍처**:
```mermaid
graph TB
    subgraph "Single AZ (비용 절약)"
        A[Public Subnet<br/>Web Server]
        B[Private Subnet<br/>App Server]
        C[Private Subnet<br/>Database]
    end
    
    A --> B
    B --> C
    
    style A fill:#e8f5e8
    style B fill:#fff3e0
    style C fill:#ffebee
```

### 🔧 비용 모니터링 도구

**📊 일일 비용 체크 (필수)**:
```bash
# 어제 비용 확인
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-02 \
  --granularity DAILY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE

# 이번 달 누적 비용
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost

# 예산 대비 사용률 계산
echo "현재 비용: $비용"
echo "예산 대비: $((비용/예산*100))%"
```

**🚨 비용 경고 신호**:
- **일일 $5 이상**: 즉시 리소스 점검
- **주간 $30 이상**: 강사 상담 필수
- **월간 70% 이상**: 새로운 리소스 생성 금지

**📱 모바일 알림 설정**:
- **AWS 모바일 앱**: 실시간 비용 알림
- **Slack 연동**: 일일 비용 리포트
- **이메일 알림**: 예산 초과 시 즉시 알림

---

## 📋 최종 체크리스트

### ✅ 계정 설정 완료 확인
- [ ] **AWS 계정 생성**: 팀 대표 계정 생성 완료
- [ ] **MFA 설정**: 루트 계정 보안 강화
- [ ] **결제 정보**: 신용카드 등록 및 확인

### ✅ 권한 설정 완료 확인
- [ ] **Cross-Account Role**: 강사 계정 ReadOnly 접근 설정
- [ ] **팀원 계정**: IAM 사용자 또는 SSO 설정
- [ ] **권한 테스트**: 읽기 권한 확인, 쓰기 권한 차단 확인
- [ ] **강사 연동**: 강사가 계정 접근 가능한지 확인

### ✅ 비용 관리 완료 확인
- [ ] **프로젝트별 예산**: 기본($150)/심화($225) 예산 설정
- [ ] **비용 차단 정책**: 고비용 서비스 완전 차단 정책 적용
- [ ] **알림 시스템**: 70%, 85%, 95% 단계별 알림 설정
- [ ] **강사 모니터링**: 85% 초과 시 강사 자동 알림
- [ ] **일일 체크**: 매일 비용 확인 시스템 구축

### ✅ 팀 공유 완료 확인
- [ ] **로그인 정보**: 팀원들에게 접근 정보 공유
- [ ] **비용 교육**: 지원 금액 및 절약 가이드 팀 교육
- [ ] **일일 체크**: 매일 비용 확인 담당자 지정
- [ ] **비상 연락**: 예산 초과 시 대응 방안 공유
- [ ] **승인 프로세스**: 새 서비스 사용 시 강사 승인 절차 숙지

---

## 🆘 문제 해결 가이드

### 🔧 자주 발생하는 문제들

**1. Cross-Account Role 접근 실패**
```bash
# 문제: AssumeRole 실패
# 해결: 신뢰 정책 확인
aws iam get-role --role-name KDT-DevOps-Instructor-ReadOnly-Role
```

**강사 계정 연동 문제 해결**:
- **역할 ARN 확인**: 정확한 역할 ARN을 강사에게 전달
- **외부 ID 확인**: `kdt-devops-2025` 정확히 설정
- **권한 범위**: ReadOnly + Billing 조회 권한 포함

**2. 팀원 로그인 실패**
```bash
# 문제: 콘솔 로그인 불가
# 해결: 비밀번호 재설정
aws iam create-login-profile --user-name team-member-1 --password NewPassword123!
```

**3. 예산 알림 미수신**
```bash
# 문제: 예산 알림이 오지 않음
# 해결: SNS 주제 및 구독 확인
aws sns list-subscriptions
```

### 📞 지원 연락처

**🎓 교육 관련 문의**:
- **강사**: 김선우 (niceguy6113@gmail.com, 010-8507-7220)
- **지원 내용**: 아키텍처 검토, 비용 최적화 조언, 계정 관리
- **비용 모니터링**: 예상치 못한 비용 발생 시 즉시 강사 연락

**💰 비용 관련 긴급 상황**:
- **1차 연락**: 강사진 (즉시 대응 가능)
- **2차 지원**: AWS Support (Basic Plan)
- **예방 도구**: AWS Trusted Advisor 활용

**🚨 예산 초과 위험 시 대응 절차**:
1. **85% 도달**: 김선우 강사 자동 알림 + 리소스 사용 검토
2. **95% 도달**: 모든 리소스 즉시 중지 + 강사와 긴급 회의
3. **100% 초과**: 계정 일시 정지 + 강사와 원인 분석
4. **재발 방지**: 강사 지도하에 정책 강화 + 추가 모니터링

**📞 긴급 연락처**: 김선우 강사 (010-8507-7220, niceguy6113@gmail.com)

**💡 비용 절약 필수 수칙**:
- **매일 체크**: 일일 비용 확인 습관화
- **즉시 정리**: 사용하지 않는 리소스 즉시 삭제
- **사전 승인**: 새로운 서비스 사용 전 강사 승인
- **팀 공유**: 비용 현황 팀 내 투명 공유

---

<div align="center">

**🎯 안전한 학습 환경** • **💰 비용 최적화** • **🤝 팀 협업 지원**

*AWS 클라우드에서 함께 성장하는 DevOps 여정*

</div>