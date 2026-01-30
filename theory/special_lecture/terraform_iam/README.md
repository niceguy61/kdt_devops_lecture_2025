<div align="center">

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazonwebservices&logoColor=white)
![IAM](https://img.shields.io/badge/IAM-DD344C?style=for-the-badge&logo=amazonsimpleemailservice&logoColor=white)
![HCL](https://img.shields.io/badge/HCL-5C4EE5?style=for-the-badge&logo=hashicorp&logoColor=white)

# Terraform으로 배우는 AWS IAM 권한 관리

**Infrastructure as Code 핵심 실습** · **팀별 권한 설계부터 Drift 감지까지**

![Sessions](https://img.shields.io/badge/Sessions-9개-blue?style=flat-square)
![Difficulty](https://img.shields.io/badge/Difficulty-입문~중급-orange?style=flat-square)
![Provider](https://img.shields.io/badge/AWS_Provider-~>_5.0-FF9900?style=flat-square&logo=amazonaws)

</div>

---

## 📌 Overview

Terraform을 이용해 AWS IAM(Identity and Access Management) 리소스를 **코드로 정의하고 관리**하는 핸즈온 실습입니다.
가상의 기업 환경에서 4개 팀(인프라, 보안, 프론트엔드, 백엔드)의 권한 구조를 설계하고, 실제 AWS에 배포합니다.

### 이 과정에서 배우는 것
- **Terraform 기초**: HCL 문법, Provider 설정, Module 구조
- **IAM 권한 설계**: 그룹, 정책, 사용자 관리
- **실무 패턴**: `terraform import`로 기존 리소스 편입
- **Drift 감지**: 코드 밖 변경이 발생했을 때 감지하고 해소하는 방법

![Terraform Workflow](./assets/terraform_flow.png)

---

## 🗂️ 세션 구성

| # | 세션 | 내용 | 유형 |
| :---: | :--- | :--- | :---: |
| **00** | [Terraform 소개 및 팀별 협업 전략](./00_intro.md) | Terraform 핵심 철학, Drift 시나리오, 팀 R&R | 📖 이론 |
| **01** | [AWS 계정 및 Terraform 사용자 설정](./01_setup.md) | 프리티어 계정, IAM 사용자, AWS CLI 설정 | 🔧 설정 |
| **02** | [IAM 팀 구조 설계 및 권한 분리](./02_iam_design.md) | 4개 팀 그룹 설계, 정책 매핑, 배포 흐름도 | 📖 설계 |
| **03** | [프로젝트 초기화 및 인프라 팀 구성](./03_infra_team.md) | Module 구조, Provider 설정, 인프라 팀 생성 | 🛠️ 실습 |
| **04** | [보안 팀 구성](./04_security_team.md) | SecurityAudit, IAMFullAccess 정책 연결 | 🛠️ 실습 |
| **05** | [프론트엔드 팀 구성](./05_frontend_team.md) | S3FullAccess, CloudFrontFullAccess 정책 연결 | 🛠️ 실습 |
| **06** | [백엔드 팀 구성 및 최종 적용](./06_backend_team.md) | EC2FullAccess, RDSFullAccess, 최종 배포 | 🛠️ 실습 |
| **07** | [AWS 콘솔 수동 추가 및 Terraform Import](./07_import.md) | 콘솔에서 사용자 생성 → terraform import | 🧪 체험 |
| **08** | [웹 콘솔 삭제와 Drift 감지 실습](./08_drift.md) | 콘솔에서 삭제 → Drift 감지 → 코드 정리 | 🧪 체험 |

---

## 🏗️ 프로젝트 구조 (최종)

```
terraform/
├── main.tf                      # Provider 설정 + IAM 모듈 호출
└── modules/
    └── iam/
        ├── groups.tf            # 4개 팀 IAM 그룹 정의
        └── policies.tf          # 그룹별 정책 연결 (7개)
```

---

## 📋 사전 준비

| 항목 | 설명 |
| :--- | :--- |
| **AWS 계정** | [프리티어 계정](https://aws.amazon.com/free) (신용카드 필요) |
| **Terraform** | [다운로드](https://developer.hashicorp.com/terraform/install) v1.0 이상 |
| **AWS CLI** | [다운로드](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) v2 권장 |
| **텍스트 에디터** | VS Code 권장 ([Terraform 확장](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform) 설치) |

---

## 🔗 공식 문서 모음

| 분류 | 링크 |
| :--- | :--- |
| **Terraform** | [소개](https://developer.hashicorp.com/terraform/intro) · [HCL 문법](https://developer.hashicorp.com/terraform/language) · [CLI 명령어](https://developer.hashicorp.com/terraform/cli) |
| **AWS Provider** | [Provider 문서](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) · [aws_iam_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) · [aws_iam_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) |
| **AWS IAM** | [IAM 사용자 가이드](https://docs.aws.amazon.com/ko_kr/IAM/latest/UserGuide/) · [관리형 정책 목록](https://docs.aws.amazon.com/ko_kr/IAM/latest/UserGuide/access_policies_managed-vs-inline.html) |

---

## ▶️ 시작하기

**[0단계: Terraform 소개 및 팀별 협업 전략 →](./00_intro.md)**
