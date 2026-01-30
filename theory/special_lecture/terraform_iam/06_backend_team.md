# 6단계: 백엔드 팀 (Backend Team) 구성 및 최종 적용

[< 이전 단계](./05_frontend_team.md) | [완료 및 요약 >](./walkthrough.md)

> **Terraform 공식 문서**: [aws_iam_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) | [aws_iam_group_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | [terraform destroy](https://developer.hashicorp.com/terraform/cli/commands/destroy)

---

## 1. 개요
**백엔드 팀**은 애플리케이션 서버(EC2)와 데이터베이스(RDS)를 프로비저닝하고 관리해야 합니다.

- **대상 그룹**: `backend-team`
- **부여 정책**: 
  1. `AmazonEC2FullAccess`: 가상 서버 관리.
  2. `AmazonRDSFullAccess`: 관계형 데이터베이스 관리.

## 2. Terraform 코드 작성

### 그룹 정의 (`modules/iam/groups.tf`)
`modules/iam/groups.tf`에 다음 내용을 추가합니다.

```hcl
resource "aws_iam_group" "backend_team" {
  name = "backend-team"
}
```

### 권한 연결 (`modules/iam/policies.tf`)
`modules/iam/policies.tf`에 다음 내용을 추가합니다.

```hcl
# 백엔드 팀 - EC2 및 RDS 권한
resource "aws_iam_group_policy_attachment" "backend_ec2" {
  group      = aws_iam_group.backend_team.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group_policy_attachment" "backend_rds" {
  group      = aws_iam_group.backend_team.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}
```

## 3. 정책 심화 분석

### `AmazonEC2FullAccess` 정책
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ec2:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "elasticloadbalancing:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "cloudwatch:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "autoscaling:*",
            "Resource": "*"
        }
    ]
}
```

| 항목 | 값 | 의미 |
| :--- | :--- | :--- |
| **ec2:\*** | 모든 EC2 액션 | 인스턴스 생성/종료, 보안 그룹 설정, EBS 볼륨 관리 등 |
| **elasticloadbalancing:\*** | 로드밸런서 전체 | ALB/NLB 생성 및 대상 그룹 관리 |
| **cloudwatch:\*** | 모니터링 전체 | EC2 메트릭 조회, 알람 설정 |
| **autoscaling:\*** | Auto Scaling 전체 | 자동 확장/축소 그룹 설정 |

> **참고**: EC2 정책은 단순히 가상 서버만이 아니라 **로드밸런서, 모니터링, 오토스케일링**까지 포함합니다. EC2 기반 인프라를 운영하는 데 필요한 관련 서비스를 한 묶음으로 제공합니다.

### `AmazonRDSFullAccess` 정책
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "rds:*",
                "application-autoscaling:DeleteScalingPolicy",
                "application-autoscaling:DeregisterScalableTarget",
                "application-autoscaling:DescribeScalableTargets",
                "application-autoscaling:DescribeScalingActivities",
                "application-autoscaling:DescribeScalingPolicies",
                "application-autoscaling:PutScalingPolicy",
                "application-autoscaling:RegisterScalableTarget",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:PutMetricAlarm",
                "cloudwatch:DeleteAlarms",
                "logs:DescribeLogStreams",
                "logs:GetLogEvents",
                "sns:ListSubscriptions",
                "sns:ListTopics",
                "sns:Publish"
            ],
            "Resource": "*"
        }
    ]
}
```

| 항목 | 값 | 의미 |
| :--- | :--- | :--- |
| **rds:\*** | 모든 RDS 액션 | DB 인스턴스 생성/삭제, 스냅샷, 파라미터 그룹 관리 등 |
| **application-autoscaling** | DB 자동 스케일링 | Aurora Serverless 등의 자동 용량 조절 |
| **cloudwatch** | 모니터링 (일부) | DB 성능 메트릭 조회 및 알람 설정 |
| **logs** | 로그 조회 | DB 느린 쿼리, 에러 로그 확인 |
| **sns** | 알림 전송 | DB 이벤트 발생 시 SNS로 알림 전송 |

> **참고**: RDS 정책은 데이터베이스 자체뿐만 아니라 **모니터링(CloudWatch), 로그(CloudWatch Logs), 알림(SNS)** 권한을 함께 포함합니다. DB 장애 감지와 성능 추적을 위해 필요합니다.

---

## 4. 최종 배포 (Apply)
모든 코드가 작성되었습니다. 이제 AWS에 실제로 리소스를 생성합니다.

1.  터미널에서 명령어 실행:
    ```bash
    terraform init
    ```
    *(이미 했다면 생략 가능하지만, 안전하게 다시 실행해도 됩니다)*

2.  계획 확인:
    ```bash
    terraform plan
    ```
    *총 4개의 그룹, 7~8개의 정책 연결이 보여야 합니다.*

3.  적용:
    ```bash
    terraform apply
    ```
    *`Enter a value:` 프롬프트가 나오면 `yes`를 입력합니다.*

## 4. AWS 콘솔에서 검증
1.  AWS 콘솔 로그인 > IAM 서비스 접속.
2.  **사용자 그룹 (User groups)** 메뉴 선택.
3.  `backend-team` 등 4개 그룹이 생성되었는지 확인합니다.
4.  각 그룹을 클릭하고 **권한(Permissions)** 탭에서 우리가 지정한 정책들이 올바르게 붙어있는지 확인합니다.

---

## 수고하셨습니다!
Terraform을 이용해 조직의 권한 구조(IAM)를 코드로 정의하고 배포하는 핸즈온을 완료했습니다.
이 코드는 언제든 `terraform destroy` 명령어로 깔끔하게 삭제할 수 있습니다.

---

[< 이전 단계](./05_frontend_team.md) | [완료 및 요약 >](./walkthrough.md)
