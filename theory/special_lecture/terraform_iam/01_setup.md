# 1단계: AWS 계정 및 Terraform 사용자 설정

[< 이전 단계](./00_intro.md) | [다음 단계 >](./02_iam_design.md)

---

## 1. AWS 프리티어 계정 생성
AWS 계정이 없다면 [aws.amazon.com/free](https://aws.amazon.com/free)에서 계정을 생성합니다.
- 신원 확인을 위해 신용카드가 필요합니다.
- 이 계정은 모든 리소스를 관리하는 **루트(Root) 계정**이 됩니다.

## 2. Terraform용 IAM 사용자 생성
**왜 필요한가요?** 보안상 루트 계정을 일상적인 작업이나 코드 배포에 사용하는 것은 권장되지 않습니다.

1.  루트 계정으로 AWS 콘솔에 로그인합니다.
2.  **IAM > 사용자(Users) > 사용자 생성**으로 이동합니다.
3.  **사용자 세부 정보**:
    - 사용자 이름: `terraform-admin`
4.  **권한 설정**:
    - **직접 정책 연결(Attach policies directly)** 선택.
    - `AdministratorAccess`를 검색하여 체크합니다. (참고: 학습 목적이므로 편의상 관리자 권한을 부여하지만, 실제 운영 환경에서는 권한을 최소화해야 합니다).
5.  **검토 및 생성**.
6.  **액세스 키 생성**:
    - 생성된 `terraform-admin` 사용자를 클릭합니다.
    - **보안 자격 증명(Security credentials)** 탭으로 이동합니다.
    - **액세스 키(Access keys)** 섹션에서 **액세스 키 만들기**를 클릭합니다.
    - 사용 사례로 **CLI**를 선택합니다.
    - **중요**: `.csv` 파일을 다운로드하거나 `Access Key ID`와 `Secret Access Key`를 안전한 곳에 복사해 둡니다. Secret Key는 다시 볼 수 없습니다.

## 3. 도구 설치
- **Terraform**: [다운로드 및 설치](https://developer.hashicorp.com/terraform/install)
- **AWS CLI**: [다운로드 및 설치](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

## 4. 로컬 환경 설정
터미널(PowerShell/CMD)을 열고 다음 명령어를 실행합니다:
```bash
aws configure --profile terraform-user
```
- **AWS Access Key ID**: (2단계에서 복사한 값)
- **AWS Secret Access Key**: (2단계에서 복사한 값)
- **Default region name**: `ap-northeast-2` (서울)
- **Default output format**: `json`

## 5. 설정 확인
설정이 올바른지 확인하기 위해 다음 명령어로 자격 증명을 테스트합니다:
```bash
aws sts get-caller-identity --profile terraform-user
```
*계정 ID와 사용자 ARN이 출력되면 성공입니다.*

---

## 공식 문서 (참고 자료)
- [Terraform AWS Provider 문서](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS IAM 사용자 리소스](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user)

---

[< 이전 단계](./00_intro.md) | [다음 단계 >](./02_iam_design.md)
