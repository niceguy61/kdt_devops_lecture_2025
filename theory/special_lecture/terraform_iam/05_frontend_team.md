# 5단계: 프론트엔드 팀 (Frontend Team) 구성

[< 이전 단계](./04_security_team.md) | [다음 단계 >](./06_backend_team.md)

> **Terraform 공식 문서**: [aws_iam_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) | [aws_iam_group_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | [Amazon S3 IAM 정책](https://docs.aws.amazon.com/ko_kr/AmazonS3/latest/userguide/security_iam_id-based-policy-examples.html)

---

## 1. 개요
**프론트엔드 팀**은 웹사이트 정적 파일(HTML, CSS, JS)을 업로드하고, 전 세계에 배포하는 CDN 설정을 관리해야 합니다.

- **대상 그룹**: `frontend-team`
- **부여 정책**: 
  1. `AmazonS3FullAccess`: 파일 저장소(버킷) 관리.
  2. `CloudFrontFullAccess`: CDN 배포 설정 관리.

## 2. Terraform 코드 작성

### 그룹 정의 (`modules/iam/groups.tf`)
`modules/iam/groups.tf`에 다음 내용을 추가합니다.

```hcl
resource "aws_iam_group" "frontend_team" {
  name = "frontend-team"
}
```

### 권한 연결 (`modules/iam/policies.tf`)
`modules/iam/policies.tf`에 다음 내용을 추가합니다.

```hcl
# 프론트엔드 팀 - S3 및 CloudFront 권한
resource "aws_iam_group_policy_attachment" "frontend_s3" {
  group      = aws_iam_group.frontend_team.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_group_policy_attachment" "frontend_cloudfront" {
  group      = aws_iam_group.frontend_team.name
  policy_arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"
}
```

## 3. 정책 심화 분석

### `AmazonS3FullAccess` 정책
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "s3-object-lambda:*"
            ],
            "Resource": "*"
        }
    ]
}
```

| 항목 | 값 | 의미 |
| :--- | :--- | :--- |
| **s3:\*** | 모든 S3 액션 | 버킷 생성/삭제, 객체 업로드/다운로드/삭제 등 |
| **s3-object-lambda:\*** | S3 Object Lambda | 객체 반환 시 Lambda로 데이터를 변환하는 기능 |
| **Resource: \*** | 모든 버킷 | 계정 내 모든 S3 버킷에 접근 가능 |

> **주의**: `Resource: *`는 모든 S3 버킷에 접근 가능하다는 뜻입니다. 실제 운영 환경에서는 특정 버킷(`arn:aws:s3:::my-website-bucket`)에만 접근하도록 제한하는 **인라인 정책(Inline Policy)**을 만드는 것이 더 안전합니다.

### `CloudFrontFullAccess` 정책
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudfront:*",
                "s3:ListAllMyBuckets",
                "acm:ListCertificates",
                "waf:ListWebACLs",
                "waf:GetWebACL",
                "wafv2:ListWebACLs",
                "wafv2:GetWebACL"
            ],
            "Resource": "*"
        }
    ]
}
```

| 항목 | 값 | 의미 |
| :--- | :--- | :--- |
| **cloudfront:\*** | 모든 CloudFront 액션 | CDN 배포(Distribution) 생성/수정/삭제, 캐시 무효화 등 |
| **s3:ListAllMyBuckets** | S3 버킷 목록 조회 | CloudFront의 Origin으로 사용할 버킷을 선택하기 위한 읽기 권한 |
| **acm:ListCertificates** | 인증서 목록 조회 | HTTPS 설정에 필요한 SSL/TLS 인증서 선택용 |
| **waf/wafv2** | WAF 조회 | CloudFront에 연결할 웹 방화벽(WAF) 설정 확인용 |

> **참고**: CloudFront 정책은 CDN 외에도 S3, ACM(인증서), WAF(방화벽)에 대한 **읽기 권한**을 함께 포함하고 있습니다. 이는 CloudFront 콘솔에서 Origin과 보안 설정을 선택할 때 필요하기 때문입니다.

## 4. 확인 및 적용
```bash
terraform plan
```

---

## 공식 문서
- [Amazon S3용 자격 증명 기반 정책](https://docs.aws.amazon.com/ko_kr/AmazonS3/latest/userguide/security_iam_id-based-policy-examples.html)

---

[< 이전 단계](./04_security_team.md) | [다음 단계 >](./06_backend_team.md)
