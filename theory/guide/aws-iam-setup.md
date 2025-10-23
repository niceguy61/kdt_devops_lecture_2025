# AWS IAM Access Key 생성 가이드

<div align="center">

**🔑 Access Key 생성** • **⚙️ CLI 설정** • **🔐 안전한 관리**

*팀원이 직접 자신의 IAM Access Key를 생성하는 방법*

</div>

---

## 🎯 상황 설명

- **팀장**: 이미 AWS 계정 생성 및 팀원별 IAM 사용자 할당 완료
- **팀원**: IAM 사용자는 있지만 CLI용 Access Key가 없는 상태
- **목표**: 팀원이 직접 자신의 Access Key를 생성하여 CLI 사용

---

## 🔧 Step 1: 팀장이 권한 추가 (필수 선행)

### 팀원 Access Key 생성 권한 부여
**팀장이 각 팀원 IAM 사용자에게 추가해야 할 정책**:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:RunInstances"
      ],
      "Resource": [
        "arn:aws:ec2:*:*:instance/*",
        "arn:aws:ec2:*:*:volume/*",
        "arn:aws:ec2:*:*:network-interface/*",
        "arn:aws:ec2:*:*:subnet/*",
        "arn:aws:ec2:*:*:security-group/*",
        "arn:aws:ec2:*:*:key-pair/*",
        "arn:aws:ec2:*::image/*"
      ],
      "Condition": {
        "StringEquals": {
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
      "Effect": "Allow",
      "Action": [
        "ec2:CreateKeyPair",
        "ec2:DeleteKeyPair",
        "ec2:DescribeKeyPairs"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    }
  ]
}
```

**설정 방법**:
1. IAM 콘솔 → Users → 팀원 사용자 선택
2. "Add permissions" → "Create inline policy"
3. JSON 탭에서 위 정책 붙여넣기
4. 정책 이름: `SelfManageAccessKeys`
5. "Create policy" 클릭

---

## 🔑 Step 2: 팀원이 Access Key 생성

### 2-1: AWS 콘솔 로그인
```
1. 팀장이 제공한 콘솔 URL 접속
2. IAM 사용자명과 비밀번호로 로그인
3. 첫 로그인 시 비밀번호 변경 (필요시)
```

### 2-2: 본인 Access Key 생성
```
1. 로그인 후 우측 상단 사용자명 클릭
2. "Security credentials" 선택
3. "Access keys" 섹션에서 "Create access key" 클릭
4. Use case: "Command Line Interface (CLI)" 선택
5. 확인 체크박스 체크 후 "Next"
6. Description: "My CLI Access" 입력
7. "Create access key" 클릭
```

### 2-3: Access Key 정보 저장
```
⚠️ 중요: 다음 정보를 안전한 곳에 저장하세요!

Access Key ID: AKIA....... (20자)
Secret Access Key: ......... (40자)

🚨 Secret Access Key는 이 화면에서만 확인 가능!
   "Download .csv file" 클릭하여 저장하세요.
```

---

## ⚙️ Step 3: AWS CLI 설정

### 3-1: AWS CLI 설치 확인
```bash
# AWS CLI 버전 확인
aws --version

# 설치되지 않은 경우
# macOS: brew install awscli
# Ubuntu: sudo apt install awscli
# Windows: https://aws.amazon.com/cli/
```

### 3-2: CLI 인증 설정
```bash
# AWS 인증 정보 설정
aws configure

# 입력 정보:
AWS Access Key ID [None]: AKIA....... (방금 생성한 Access Key)
AWS Secret Access Key [None]: ......... (방금 생성한 Secret Key)
Default region name [None]: ap-northeast-2  # 서울 리전
Default output format [None]: json
```

### 3-3: 설정 확인
```bash
# 인증 정보 확인
aws configure list

# 연결 테스트
aws sts get-caller-identity

# 성공 시 출력 예시:
{
    "UserId": "AIDACKCEVSQ6C2EXAMPLE",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/team-member-1"
}
```

---

## ✅ 완료 체크리스트

### 팀장 확인사항
- [ ] 모든 팀원에게 Access Key 생성 권한 부여
- [ ] 팀원들에게 콘솔 로그인 정보 제공
- [ ] 권한 정책 적용 확인

### 팀원 확인사항  
- [ ] 콘솔 로그인 성공
- [ ] Access Key 생성 완료
- [ ] Access Key 정보 안전 저장
- [ ] AWS CLI 설정 완료
- [ ] `aws sts get-caller-identity` 성공

---

## 🔒 보안 주의사항

```
✅ 해야 할 것:
- Access Key 안전한 곳에 저장
- 정기적인 Access Key 로테이션 (30일마다)
- 사용하지 않는 Access Key 즉시 삭제

❌ 하지 말아야 할 것:
- Access Key를 코드에 하드코딩
- Git 저장소에 Access Key 업로드
- 다른 사람과 Access Key 공유
```

---

<div align="center">

**🔑 간단한 설정** • **🔐 안전한 관리** • **🚀 빠른 시작**

*팀원이 직접 자신의 CLI 접근 권한을 관리*

</div>
