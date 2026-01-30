# 4단계: 보안 팀 (Security Team) 구성

[< 이전 단계](./03_infra_team.md) | [다음 단계 >](./05_frontend_team.md)

> **Terraform 공식 문서**: [aws_iam_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) | [aws_iam_group_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | [SecurityAudit 정책](https://docs.aws.amazon.com/aws-managed-policy/latest/reference/SecurityAudit.html)

---

## 1. 개요
**보안 팀**은 리소스 설정을 감사(Audit)하고, IAM 사용자 및 권한을 관리할 수 있어야 합니다. 하지만 실제 서버를 끄거나 켜는 작업은 제한될 수 있습니다(여기서는 IAM User 관리를 위해 `IAMFullAccess`를 부여합니다).

- **대상 그룹**: `security-team`
- **부여 정책**: 
  1. `SecurityAudit`: 계정 설정, 로그, 구성 등을 '읽을' 수 있는 권한.
  2. `IAMFullAccess`: IAM 사용자와 정책을 생성/수정/삭제할 수 있는 권한.

## 2. Terraform 코드 작성

### 그룹 정의 (`modules/iam/groups.tf`)
`modules/iam/groups.tf`에 다음 내용을 추가합니다.

```hcl
resource "aws_iam_group" "security_team" {
  name = "security-team"
}
```

### 권한 연결 (`modules/iam/policies.tf`)
`modules/iam/policies.tf`에 다음 내용을 추가합니다.

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

### `SecurityAudit` 정책
보안 전문가가 AWS 환경의 취약점을 분석할 때 필수적인 **Read-Only** 정책입니다.

주요 허용 액션:
| 액션 패턴 | 설명 |
| :--- | :--- |
| `config:Get*`, `config:Describe*` | AWS Config 규칙 및 리소스 구성 조회 |
| `cloudtrail:Describe*`, `cloudtrail:GetTrailStatus` | CloudTrail 로그 설정 및 상태 확인 |
| `ec2:DescribeSecurityGroups`, `ec2:DescribeNetworkAcls` | VPC 방화벽(보안 그룹, NACL) 설정 확인 |
| `iam:Get*`, `iam:List*` | IAM 사용자, 역할, 정책 목록 조회 (수정 불가) |
| `s3:GetBucketPolicy`, `s3:GetBucketAcl` | S3 버킷 접근 정책 감사 |

> **핵심**: `Describe*`, `Get*`, `List*` 등 **읽기 전용** 액션만 포함되어 있습니다. 리소스를 생성하거나 삭제할 수 없습니다.

### `IAMFullAccess` 정책
IAM 서비스에 대한 **완전한 제어 권한**을 부여합니다.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:*",
                "organizations:DescribeAccount",
                "organizations:DescribeOrganization",
                "organizations:DescribeOrganizationalUnit",
                "organizations:DescribePolicy",
                "organizations:ListChildren",
                "organizations:ListParents",
                "organizations:ListPoliciesForTarget",
                "organizations:ListRoots",
                "organizations:ListPolicies",
                "organizations:ListTargetsForPolicy"
            ],
            "Resource": "*"
        }
    ]
}
```

| 항목 | 값 | 의미 |
| :--- | :--- | :--- |
| **iam:\*** | 모든 IAM 액션 | 사용자, 그룹, 역할, 정책의 생성/수정/삭제 가능 |
| **organizations:Describe\*/List\*** | Organizations 읽기 | 조직 구조를 조회할 수 있지만 변경은 불가 |

> **주의**: `iam:*`는 자기 자신에게 `AdministratorAccess`를 부여할 수도 있으므로 **권한 상승(Privilege Escalation)** 위험이 있습니다. 실무에서는 `iam:CreatePolicy`, `iam:AttachUserPolicy` 등 필요한 액션만 허용하는 것이 좋습니다.

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
