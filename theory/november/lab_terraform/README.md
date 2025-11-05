# November Lab Terraform Environment

November 실습용 AWS 인프라 환경

## 🏗️ 구성 요소

- **VPC**: 10.0.0.0/16
- **Public Subnets**: 3개 AZ (10.0.0.0/24, 10.0.1.0/24, 10.0.2.0/24)
- **Private Subnets**: 3개 AZ (10.0.10.0/24, 10.0.11.0/24, 10.0.12.0/24)
- **Internet Gateway**: Public 인터넷 접근
- **Route Tables**: Public/Private 라우팅
- **RDS Subnet Group**: Private 서브넷 그룹
- **ElastiCache Subnet Group**: Private 서브넷 그룹

## 🚀 사용법

### 1. S3 Backend 설정
```bash
# backend.tf 파일에서 bucket과 profile 수정
# - bucket: 본인의 terraform state 저장용 S3 버킷
# - profile: 본인의 AWS SSO 프로필명
```

### 2. 설정 파일 생성
```bash
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars 파일에서 aws_profile 수정
```

### 3. Terraform 초기화 및 배포
```bash
terraform init
terraform plan
terraform apply
```

### 3. 리소스 정리
```bash
terraform destroy
```

## 📋 출력 값

- `vpc_id`: VPC ID
- `public_subnet_ids`: Public 서브넷 ID 목록
- `private_subnet_ids`: Private 서브넷 ID 목록
- `rds_subnet_group_name`: RDS 서브넷 그룹명
- `redis_subnet_group_name`: ElastiCache 서브넷 그룹명

## ⚠️ 주의사항

- AWS SSO 프로필 설정 필요
- S3 버킷 사전 생성 필요 (terraform state 저장용)
- ap-northeast-2 (서울) 리전 기본 사용
- 실습 완료 후 반드시 `terraform destroy` 실행
- DynamoDB 락 없음 (개인 실습용)
