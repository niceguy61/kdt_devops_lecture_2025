# 3단계: 프로젝트 초기화 및 인프라 팀 구성 (Hands-on Start)

[< 이전 단계](./02_iam_design.md) | [다음 단계 >](./04_security_team.md)

> **Terraform 공식 문서**: [terraform init](https://developer.hashicorp.com/terraform/cli/commands/init) | [terraform plan](https://developer.hashicorp.com/terraform/cli/commands/plan) | [terraform apply](https://developer.hashicorp.com/terraform/cli/commands/apply) | [aws_iam_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group)

---

## 1. 실습 환경 준비 (Project Initialization)
이제부터 직접 빈 폴더에서 시작하여 Terraform 코드를 작성해 봅니다.
먼저 작업할 디렉터리와 모듈 구조를 생성합니다.

### 1-1. 폴더 생성 (Make Directories)
**Windows (PowerShell)**:
```powershell
# 프로젝트 루트(d:\special_lecture)에서 시작
mkdir terraform
cd terraform
mkdir modules\iam
```

**Linux / Mac (Bash)**:
```bash
mkdir -p terraform/modules/iam
cd terraform
```

> **Module 구조는 왜 사용하나요?**
> Terraform에서 모듈(Module)은 재사용 가능한 리소스 묶음입니다. `modules/iam/` 폴더에 IAM 관련 리소스를 분리하면, 루트 `main.tf`는 모듈만 호출하고, 실제 리소스 정의는 모듈 내부에서 관리됩니다. 이렇게 하면 코드가 깔끔하게 분리되고, 다른 프로젝트에서도 모듈을 재사용할 수 있습니다.

---

## 2. Terraform 기본 구성 (main.tf)

Terraform이 AWS와 통신할 수 있도록 공급자(Provider)를 설정하고, IAM 모듈을 호출합니다.
`terraform` 폴더 안에 `main.tf` 파일을 생성하고 아래 내용을 작성하세요.

**파일 경로**: `d:/special_lecture/terraform/main.tf`

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-2"  # 서울 리전
  profile = "terraform-user"
}

# IAM 모듈 호출
module "iam" {
  source = "./modules/iam"
}
```

> **`module` 블록이란?**
> `source`에 지정한 경로(`./modules/iam`)의 `.tf` 파일들을 하나의 묶음으로 실행합니다. 이후 단계에서 `modules/iam/` 폴더 안에 그룹과 정책 파일을 추가하면, `main.tf`는 수정 없이 자동으로 반영됩니다.

---

## 3. 인프라 팀(Infra Team) 리소스 추가

가장 강력한 권한을 가진 인프라 팀 그룹을 모듈 안에 생성합니다.

**파일 경로**: `d:/special_lecture/terraform/modules/iam/groups.tf` (새로 생성)

```hcl
# 인프라 팀 그룹 생성
resource "aws_iam_group" "infra_team" {
  name = "infra-team"
}
```

**파일 경로**: `d:/special_lecture/terraform/modules/iam/policies.tf` (새로 생성)

```hcl
# 인프라 팀 - 관리자 권한 연결 (AdministratorAccess)
resource "aws_iam_group_policy_attachment" "infra_admin" {
  group      = aws_iam_group.infra_team.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
```

이 시점에서 프로젝트 구조는 다음과 같습니다:
```
terraform/
├── main.tf                  # Provider 설정 + 모듈 호출
└── modules/
    └── iam/
        ├── groups.tf        # IAM 그룹 정의
        └── policies.tf      # 그룹별 정책 연결
```

### `AdministratorAccess` 정책이란?
이 정책의 실제 JSON은 다음과 같습니다:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
}
```

| 항목 | 값 | 의미 |
| :--- | :--- | :--- |
| **Action** | `*` | 모든 AWS 서비스의 모든 API 호출 허용 |
| **Resource** | `*` | 계정 내 모든 리소스에 대해 적용 |

> **주의**: 이 정책은 AWS에서 가장 강력한 권한입니다. EC2 삭제, S3 버킷 제거, IAM 사용자 생성/삭제 등 모든 작업이 가능합니다. 실제 운영 환경에서는 인프라 팀이라 하더라도 **특정 서비스에만 한정된 커스텀 정책**을 만드는 것이 권장됩니다.

---

## 4. 실행 및 검증 (Execute & Verify)

작성한 코드를 실행하여 실제 AWS 리소스를 생성해 봅니다.

### 4-1. 초기화 (Init)
Terraform이 AWS 플러그인을 다운로드합니다.
```bash
terraform init
```
*결과: `Terraform has been successfully initialized!` 메시지가 나와야 합니다.*

### 4-2. 계획 확인 (Plan)
어떤 리소스가 생성될지 미리 확인합니다.
```bash
terraform plan
```
*결과: `Plan: 2 to add, 0 to change, 0 to destroy.` (그룹 1개 + 정책 연결 1개)*
*리소스 이름이 `module.iam.aws_iam_group.infra_team`처럼 모듈 접두사가 붙어 있는 것을 확인하세요.*

### 4-3. 적용 (Apply)
실제로 배포합니다.
```bash
terraform apply
# Enter a value: 프롬프트가 나오면 'yes' 입력
```

---

## 5. 상태 파일 확인 (State Inspection)

배포가 성공하면 폴더에 `terraform.tfstate` 파일이 생깁니다. 이 파일은 **Terraform의 뇌**와 같습니다.

**Windows (PowerShell)**:
```powershell
type terraform.tfstate
```

**Linux / Mac**:
```bash
cat terraform.tfstate
```

### 무엇을 확인해야 하나요?
파일 내용을 보면 JSON 형태로 방금 생성한 `infra-team`의 정보(ARN, ID 등)가 저장되어 있습니다.
- **중요**: AWS 콘솔에서 리소스를 지우더라도 이 파일에는 "있다"고 기록되어 있다면, Terraform은 다음 실행 때 혼란(Drift)을 겪습니다. **절대 이 파일을 수동으로 수정하지 마세요.**

---

[< 이전 단계](./02_iam_design.md) | [다음 단계 >](./04_security_team.md)
