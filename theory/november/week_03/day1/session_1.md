# November Week 3 Day 1 Session 1: Terraform for_each & count

<div align="center">

**🔄 반복문** • **📦 리소스 생성** • **🎯 효율성**

*반복문으로 여러 리소스를 효율적으로 생성하기*

</div>

---

## 🕘 세션 정보
**시간**: 09:00-09:40 (40분)
**목표**: for_each와 count를 활용한 반복 리소스 생성
**방식**: 이론 + 코드 예시

## 🎯 학습 목표
- for_each와 count의 차이점 이해
- Map, List 변수를 활용한 리소스 생성
- 반복 코드 제거 및 유지보수성 향상
- 실무 활용 패턴 습득

---

## 📖 기술 개요

### 1. 생성 배경 (Why?) - 5분

**문제 상황**:
- **반복 코드**: 비슷한 리소스를 여러 개 만들 때 코드 중복
  ```hcl
  # 나쁜 예: 3개 Subnet을 각각 정의
  resource "aws_subnet" "public_a" {
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-northeast-2a"
  }
  resource "aws_subnet" "public_b" {
    cidr_block = "10.0.2.0/24"
    availability_zone = "ap-northeast-2b"
  }
  resource "aws_subnet" "public_c" {
    cidr_block = "10.0.3.0/24"
    availability_zone = "ap-northeast-2c"
  }
  ```
- **유지보수 어려움**: 설정 변경 시 모든 리소스 수정 필요
- **확장성 부족**: 리소스 추가 시 코드 복사-붙여넣기

**Terraform 솔루션**:
- **for_each**: Map이나 Set으로 여러 리소스 생성
- **count**: 숫자로 반복 생성
- **DRY 원칙**: 코드 중복 제거

---

### 2. 핵심 원리 (How?) - 10분

**작동 원리**:

**count 방식**:
```hcl
# count: 숫자로 반복
resource "aws_subnet" "public" {
  count = 3
  
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = "ap-northeast-2${element(["a", "b", "c"], count.index)}"
  
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

# 참조: count.index 사용
output "subnet_ids" {
  value = aws_subnet.public[*].id  # 모든 Subnet ID
}
```

**for_each 방식**:
```hcl
# for_each: Map으로 반복
variable "availability_zones" {
  type = map(string)
  default = {
    "a" = "ap-northeast-2a"
    "b" = "ap-northeast-2b"
    "c" = "ap-northeast-2c"
  }
}

resource "aws_subnet" "public" {
  for_each = var.availability_zones
  
  cidr_block        = "10.0.${index(keys(var.availability_zones), each.key) + 1}.0/24"
  availability_zone = each.value
  
  tags = {
    Name = "public-subnet-${each.key}"
  }
}

# 참조: each.key 사용
output "subnet_ids" {
  value = {
    for k, subnet in aws_subnet.public : k => subnet.id
  }
}
```

**다이어그램**:
```mermaid
graph TB
    subgraph "count 방식"
        C[count = 3]
        C --> C1[리소스[0]]
        C --> C2[리소스[1]]
        C --> C3[리소스[2]]
    end
    
    subgraph "for_each 방식"
        F[for_each = map]
        F --> F1[리소스[a]]
        F --> F2[리소스[b]]
        F --> F3[리소스[c]]
    end
    
    style C fill:#fff3e0
    style F fill:#e8f5e8
    style C1 fill:#fff3e0
    style C2 fill:#fff3e0
    style C3 fill:#fff3e0
    style F1 fill:#e8f5e8
    style F2 fill:#e8f5e8
    style F3 fill:#e8f5e8
```

---

### 3. 주요 사용 사례 (When?) - 5분

**적합한 경우**:

**count 사용**:
- 동일한 리소스를 N개 생성
- 순서가 중요한 경우
- 간단한 반복 (예: 3개 인스턴스)

**for_each 사용**:
- 각 리소스가 고유한 식별자 필요
- Map 데이터 구조 활용
- 리소스 추가/삭제가 빈번한 경우

**실제 사례**:
```hcl
# 사례 1: Multi-AZ Subnet (for_each 권장)
variable "subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    "public-a"  = { cidr = "10.0.1.0/24", az = "ap-northeast-2a" }
    "public-b"  = { cidr = "10.0.2.0/24", az = "ap-northeast-2b" }
    "private-a" = { cidr = "10.0.11.0/24", az = "ap-northeast-2a" }
  }
}

resource "aws_subnet" "main" {
  for_each = var.subnets
  
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  
  tags = {
    Name = each.key
  }
}

# 사례 2: 동일한 인스턴스 N개 (count 적합)
resource "aws_instance" "worker" {
  count = 5
  
  ami           = "ami-12345678"
  instance_type = "t3.micro"
  
  tags = {
    Name = "worker-${count.index + 1}"
  }
}
```

---

### 4. 비슷한 기술 비교 (Which?) - 5분

**Terraform 내 대안**:

**count vs for_each**:
- **언제 count 사용**: 동일한 리소스 N개, 순서 중요
- **언제 for_each 사용**: 고유 식별자, Map 데이터, 유연한 관리

**선택 기준 표**:
| 기준 | count | for_each |
|------|-------|----------|
| **데이터 구조** | 숫자 (정수) | Map 또는 Set |
| **참조 방법** | `[index]` | `[key]` |
| **리소스 추가** | 중간 추가 시 재생성 | 안전하게 추가 |
| **리소스 삭제** | 중간 삭제 시 재생성 | 안전하게 삭제 |
| **가독성** | 낮음 (숫자 인덱스) | 높음 (의미있는 키) |
| **유지보수** | 어려움 | 쉬움 |

**예시**:
```hcl
# count: 중간 삭제 시 문제
# 리소스[0], [1], [2] 중 [1] 삭제 → [2]가 [1]로 변경 (재생성!)

# for_each: 안전한 삭제
# 리소스[a], [b], [c] 중 [b] 삭제 → [a], [c]는 영향 없음
```

---

### 5. 장단점 분석 - 3분

**count 장점**:
- ✅ 간단한 문법
- ✅ 숫자 기반 반복
- ✅ 빠른 작성

**count 단점**:
- ⚠️ 중간 삭제 시 재생성
- ⚠️ 가독성 낮음
- ⚠️ 유지보수 어려움

**for_each 장점**:
- ✅ 안전한 추가/삭제
- ✅ 의미있는 키
- ✅ 높은 가독성
- ✅ 유지보수 용이

**for_each 단점**:
- ⚠️ Map/Set 구조 필요
- ⚠️ 약간 복잡한 문법

---

### 6. 비용 구조 💰 - 5분

**과금 방식**:
- Terraform 자체는 무료 (오픈소스)
- 생성된 AWS 리소스에 대한 비용만 발생

**프리티어 혜택**:
- Terraform: 무료
- AWS 리소스: 각 서비스별 프리티어 적용

**비용 최적화 팁**:
1. **count 활용**: 환경별 리소스 수 조절
   ```hcl
   locals {
     instance_count = var.environment == "prod" ? 3 : 1
   }
   
   resource "aws_instance" "app" {
     count = local.instance_count
   }
   ```

2. **for_each 활용**: 필요한 리소스만 생성
   ```hcl
   variable "enable_nat_gateway" {
     type = map(bool)
     default = {
       "dev"  = false  # 비용 절감
       "prod" = true
     }
   }
   ```

**예상 비용**:
- Terraform 사용: $0
- 생성된 리소스: 각 서비스 요금 적용

---

### 7. 최신 업데이트 🆕 - 2분

**2024년 주요 변경사항**:
- Terraform 1.7: for_each 성능 개선
- Terraform 1.8: count 에러 메시지 개선

**2025년 예정**:
- for_each 고급 기능 추가 예정

**참조**: [Terraform Changelog](https://github.com/hashicorp/terraform/blob/main/CHANGELOG.md)

---

### 8. 잘 사용하는 방법 ✅ - 3분

**베스트 프랙티스**:
1. **for_each 우선 사용**: 대부분의 경우 for_each 권장
2. **의미있는 키**: Map 키는 리소스 의미 반영
3. **toset() 활용**: List를 Set으로 변환
   ```hcl
   resource "aws_subnet" "public" {
     for_each = toset(["a", "b", "c"])
     
     availability_zone = "ap-northeast-2${each.key}"
   }
   ```

**실무 팁**:
- **변수 분리**: 반복 데이터는 variables.tf에 정의
- **Output 활용**: 생성된 리소스 정보 출력
- **조건 결합**: count + for_each 조합 (Terraform 1.4+)

---

### 9. 잘못 사용하는 방법 ❌ - 3분

**흔한 실수**:
1. **count 중간 삭제**: 리소스 재생성 발생
   ```hcl
   # ❌ 나쁜 예
   count = 3  # [0], [1], [2]
   # [1] 삭제 시 [2]가 [1]로 변경됨!
   ```

2. **for_each에 List 직접 사용**:
   ```hcl
   # ❌ 에러 발생
   for_each = ["a", "b", "c"]  # List는 불가
   
   # ✅ toset() 사용
   for_each = toset(["a", "b", "c"])
   ```

3. **count와 for_each 혼용**:
   ```hcl
   # ❌ 동시 사용 불가
   resource "aws_instance" "app" {
     count    = 3
     for_each = var.instances  # 에러!
   }
   ```

**안티 패턴**:
- count로 복잡한 리소스 관리
- for_each 없이 수동 반복 코드
- 하드코딩된 인덱스 사용

---

### 10. 구성 요소 상세 - 5분

**주요 구성 요소**:

**1. count**:
- **역할**: 숫자 기반 반복
- **참조**: `count.index` (0부터 시작)
- **설정**: `count = 숫자`

**2. for_each**:
- **역할**: Map/Set 기반 반복
- **참조**: `each.key`, `each.value`
- **설정**: `for_each = map 또는 set`

**3. 참조 방법**:
```hcl
# count 참조
aws_subnet.public[0].id
aws_subnet.public[1].id

# for_each 참조
aws_subnet.public["a"].id
aws_subnet.public["b"].id

# 전체 참조
aws_subnet.public[*].id  # count
values(aws_subnet.public)[*].id  # for_each
```

---

### 11. 공식 문서 링크 (필수 5개)

**⚠️ 학생들이 직접 확인해야 할 공식 문서**:
- 📘 [for_each Meta-Argument](https://www.terraform.io/language/meta-arguments/for_each)
- 📗 [count Meta-Argument](https://www.terraform.io/language/meta-arguments/count)
- 📙 [Expressions - For](https://www.terraform.io/language/expressions/for)
- 📕 [Functions - toset](https://www.terraform.io/language/functions/toset)
- 🆕 [Terraform 1.8 Release](https://github.com/hashicorp/terraform/releases)

---

## 💭 함께 생각해보기

**🤝 페어 토론** (5분):
1. **실무 적용**: "여러분의 프로젝트에서 반복되는 리소스는 무엇인가요?"
2. **선택 기준**: "count와 for_each 중 어떤 것을 선택하시겠어요?"
3. **경험 공유**: "코드 중복으로 어려움을 겪은 경험이 있나요?"

---

## 🔑 핵심 키워드

- **count**: 숫자 기반 반복, `count.index` 참조
- **for_each**: Map/Set 기반 반복, `each.key`, `each.value` 참조
- **DRY 원칙**: Don't Repeat Yourself, 코드 중복 제거
- **toset()**: List를 Set으로 변환하는 함수
- **Meta-Argument**: 모든 리소스에 사용 가능한 특수 인자

---

## 📝 세션 마무리

### ✅ 오늘 세션 성과
- [ ] count와 for_each의 차이점 이해
- [ ] Map, List 변수 활용 방법 파악
- [ ] 반복 코드 제거 방법 습득
- [ ] 실무 활용 패턴 학습

### 🎯 다음 세션 준비
- **Session 2**: 조건문 & Locals
- **연계**: for_each + 조건문 조합

---

<div align="center">

**🔄 반복문** • **📦 효율성** • **🎯 유지보수** • **✨ DRY 원칙**

*Session 1: Terraform 반복문 완전 정복*

</div>
