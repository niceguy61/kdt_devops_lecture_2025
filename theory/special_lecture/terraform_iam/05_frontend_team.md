# 5단계: 프론트엔드 팀 (Frontend Team) 구성

[< 이전 단계](./04_security_team.md) | [다음 단계 >](./06_backend_team.md)

---

## 1. 개요
**프론트엔드 팀**은 웹사이트 정적 파일(HTML, CSS, JS)을 업로드하고, 전 세계에 배포하는 CDN 설정을 관리해야 합니다.

- **대상 그룹**: `frontend-team`
- **부여 정책**: 
  1. `AmazonS3FullAccess`: 파일 저장소(버킷) 관리.
  2. `CloudFrontFullAccess`: CDN 배포 설정 관리.

## 2. Terraform 코드 작성

### 그룹 정의 (`groups.tf`)
`groups.tf`에 다음 내용을 추가합니다.

```hcl
resource "aws_iam_group" "frontend_team" {
  name = "frontend-team"
}
```

### 권한 연결 (`policies.tf`)
`policies.tf`에 다음 내용을 추가합니다.

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

## 3. 정책 심화 분석 (JSON 예시)
Terraform이 연결해주는 `AmazonS3FullAccess` 정책은 실제로는 아래와 같은 JSON 형태입니다.
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
> **주의**: `Resource: *`는 모든 S3 버킷에 접근 가능하다는 뜻입니다. 실제 운영 환경에서는 특정 버킷(`arn:aws:s3:::my-website-bucket`)에만 접근하도록 제한하는 **인라인 정책(Inline Policy)**을 만드는 것이 더 안전합니다.

## 4. 확인 및 적용
```bash
terraform plan
```

---

## 공식 문서
- [Amazon S3용 자격 증명 기반 정책](https://docs.aws.amazon.com/ko_kr/AmazonS3/latest/userguide/security_iam_id-based-policy-examples.html)

---

[< 이전 단계](./04_security_team.md) | [다음 단계 >](./06_backend_team.md)
