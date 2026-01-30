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
mkdir modules
```

**Linux / Mac (Bash)**:
```bash
mkdir -p terraform/modules
cd terraform
```

> **Module 폴더는 왜 만드나요?**
> 지금은 메인 코드(`main.tf`)에 모든 것을 작성하지만, 나중에는 재사용 가능한 코드를 `modules` 폴더에 분리하여 관리하는 것이 표준입니다. (이번 실습에서는 구조만 잡아둡니다.)

---

## 2. Terraform 기본 구성 (main.tf)

Terraform이 AWS와 통신할 수 있도록 공급자(Provider)를 설정합니다.
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
  region = "ap-northeast-2"  # 서울 리전
  profile = "terraform-user"
}
```

---

## 3. 인프라 팀(Infra Team) 리소스 추가

가장 강력한 권한을 가진 인프라 팀 그룹을 생성합니다.

**파일 경로**: `d:/special_lecture/terraform/infra_team.tf` (새로 생성)

```hcl
# 1. 인프라 팀 그룹 생성
resource "aws_iam_group" "infra_team" {
  name = "infra-team"
}

# 2. 관리자 권한 연결 (AdministratorAccess)
resource "aws_iam_group_policy_attachment" "infra_admin" {
  group      = aws_iam_group.infra_team.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
```

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
