# 4단계: 보안 팀 (Security Team) 구성

[< 이전 단계](./03_infra_team.md) | [다음 단계 >](./05_frontend_team.md)

---

## 1. 개요
**보안 팀**은 리소스 설정을 감사(Audit)하고, IAM 사용자 및 권한을 관리할 수 있어야 합니다. 하지만 실제 서버를 끄거나 켜는 작업은 제한될 수 있습니다(여기서는 IAM User 관리를 위해 `IAMFullAccess`를 부여합니다).

- **대상 그룹**: `security-team`
- **부여 정책**: 
  1. `SecurityAudit`: 계정 설정, 로그, 구성 등을 '읽을' 수 있는 권한.
  2. `IAMFullAccess`: IAM 사용자와 정책을 생성/수정/삭제할 수 있는 권한.

## 2. Terraform 코드 작성

### 그룹 정의 (`groups.tf`)
`groups.tf`에 다음 내용을 추가합니다.

```hcl
resource "aws_iam_group" "security_team" {
  name = "security-team"
}
```

### 권한 연결 (`policies.tf`)
`policies.tf`에 다음 내용을 추가합니다.

```hcl
# 보안 팀 - 감사 및 IAM 전체 관리 권한
resource "aws_iam_group_policy_attachment" "security_audit" {
  group      = aws_iam_group.security_team.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_group_policy_attachment" "security_iam_full" {
  group      = aws_iam_group.security_team.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}
```

## 3. 정책 심화 분석
`SecurityAudit` 정책은 보안 전문가가 AWS 환경의 취약점을 분석할 때 필수적입니다.
이 정책은 **Read-Only** 성격이 강하며, 다음과 같은 작업을 허용합니다:
- `config:Get*` (AWS Config 조회)
- `cloudtrail:DescribeTrails` (로그 설정 확인)
- `ec2:DescribeSecurityGroups` (방화벽 설정 확인)

## 4. 확인 및 적용
```bash
terraform plan
```
*보안 팀 관련 리소스가 추가되었는지 확인합니다.*

---

## 공식 문서
- [IAM: SecurityAudit 관리형 정책](https://docs.aws.amazon.com/aws-managed-policy/latest/reference/SecurityAudit.html)

---

[< 이전 단계](./03_infra_team.md) | [다음 단계 >](./05_frontend_team.md)
