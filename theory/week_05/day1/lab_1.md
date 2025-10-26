# Week 5 Day 1 Lab 1: VPC 네트워크 인프라 구축 (14:00-14:50)

<div align="center">

**🌐 VPC 생성** • **🏗️ Multi-AZ Subnet** • **🚪 Internet Gateway** • **🗺️ Route Table**

*AWS 네트워크의 기초를 직접 구축하기*

</div>

---

## 🕘 Lab 정보
**시간**: 14:00-14:50 (50분)
**목표**: VPC부터 Route Table까지 완전한 네트워크 인프라 구축
**방식**: AWS Web Console 실습
**예상 비용**: $0.00 (VPC 자체는 무료)

## 🎯 학습 목표
- [ ] VPC CIDR 블록 설계 및 생성
- [ ] Multi-AZ Subnet 구성 (Public/Private)
- [ ] Internet Gateway 생성 및 연결
- [ ] Route Table 설정 및 Subnet 연결

---

## 🏗️ 구축할 아키텍처

### 📐 아키텍처 다이어그램

```mermaid
architecture-beta
    group aws(cloud)[AWS Cloud]
    
    service internet(internet)[Internet] in aws
    service igw(internet)[IGW] in aws
    
    group vpc(cloud)[VPC 10.0.0.0/16] in aws
    
    group aza(cloud)[AZ A] in vpc
    group public_a(cloud)[Public Subnet 10.0.1.0/24] in aza
    group private_a(cloud)[Private Subnet 10.0.11.0/24] in aza
    
    group azb(cloud)[AZ B] in vpc
    group public_b(cloud)[Public Subnet 10.0.2.0/24] in azb
    group private_b(cloud)[Private Subnet 10.0.12.0/24] in azb
    
    service rt_pub(server)[Public Route Table] in vpc
    service rt_priv(server)[Private Route Table] in vpc
    
    internet:R -- L:igw
    igw:R -- L:vpc
    rt_pub:R -- L:public_a
    rt_pub:R -- L:public_b
    rt_priv:R -- L:private_a
    rt_priv:R -- L:private_b
```

### 🔗 참조 Session
**당일 Session**:
- [Session 1: AWS 기초 개념](./session_1.md) - Region, AZ, VPC 개념
- [Session 2: VPC 아키텍처](./session_2.md) - CIDR, Subnet, IGW, Route Table

---

## 🛠️ Step 1: VPC 생성 (예상 시간: 10분)

### 📋 이 단계에서 할 일
- VPC CIDR 블록 설계
- VPC 생성
- DNS 설정 활성화

### 🔗 참조 개념
- [Session 2: VPC 아키텍처](./session_2.md) - VPC CIDR 블록 설계

### 📝 실습 절차

#### 1-1. VPC 생성

**AWS Console 경로**:
```
AWS Console → VPC → Your VPCs → Create VPC
```

**설정 값**:
| 항목 | 값 | 설명 |
|------|-----|------|
| **Resources to create** | VPC only | VPC만 생성 (Subnet은 별도) |
| **Name tag** | week5-day1-vpc | 실습용 VPC |
| **IPv4 CIDR block** | 10.0.0.0/16 | 65,536개 IP 주소 |
| **IPv6 CIDR block** | No IPv6 CIDR block | IPv6 사용 안 함 |
| **Tenancy** | Default | 공유 하드웨어 (비용 절감) |

**이미지 자리**: Step 1-1 VPC 생성 화면

**⚠️ 주의사항**:
- CIDR 블록은 생성 후 변경 불가능
- 10.0.0.0/16은 가장 일반적인 선택
- Tenancy는 Default 선택 (Dedicated는 비용 높음)

#### 1-2. DNS 설정 활성화

**AWS Console 경로**:
```
VPC → Your VPCs → week5-day1-vpc 선택 → Actions → Edit VPC settings
```

**설정 값**:
| 항목 | 값 | 설명 |
|------|-----|------|
| **Enable DNS resolution** | ✅ 체크 | DNS 쿼리 활성화 |
| **Enable DNS hostnames** | ✅ 체크 | 인스턴스 DNS 이름 자동 할당 |

**이미지 자리**: Step 1-2 DNS 설정 화면

**💡 왜 필요한가?**:
- DNS resolution: VPC 내에서 도메인 이름 해석
- DNS hostnames: EC2 인스턴스에 자동으로 DNS 이름 부여

### ✅ Step 1 검증

**AWS Console에서 확인**:
```
VPC → Your VPCs → week5-day1-vpc 선택
```

**확인 항목**:
| 항목 | 예상 값 |
|------|---------|
| **VPC ID** | vpc-xxxxx |
| **IPv4 CIDR** | 10.0.0.0/16 |
| **DNS resolution** | Enabled |
| **DNS hostnames** | Enabled |

**이미지 자리**: Step 1 검증 결과

**✅ 체크리스트**:
- [ ] VPC ID 확인 (vpc-xxxxx)
- [ ] CIDR 블록 10.0.0.0/16 확인
- [ ] DNS resolution enabled 확인
- [ ] DNS hostnames enabled 확인

---

## 🛠️ Step 2: Subnet 생성 (예상 시간: 15분)

### 📋 이 단계에서 할 일
- AZ-A Public Subnet 생성
- AZ-A Private Subnet 생성
- AZ-B Public Subnet 생성
- AZ-B Private Subnet 생성

### 🔗 참조 개념
- [Session 2: VPC 아키텍처](./session_2.md) - Subnet 설계 및 CIDR 계산

### 📝 실습 절차

#### 2-1. Public Subnet A 생성

**AWS Console 경로**:
```
VPC → Subnets → Create subnet
```

**설정 값**:
| 항목 | 값 | 설명 |
|------|-----|------|
| **VPC ID** | week5-day1-vpc | 위에서 생성한 VPC |
| **Subnet name** | week5-day1-public-a | Public Subnet A |
| **Availability Zone** | ap-northeast-2a | AZ-A |
| **IPv4 CIDR block** | 10.0.1.0/24 | 256개 IP (251개 사용 가능) |

**이미지 자리**: Step 2-1 Public Subnet A 생성

#### 2-2. Private Subnet A 생성

**설정 값**:
| 항목 | 값 | 설명 |
|------|-----|------|
| **VPC ID** | week5-day1-vpc | 동일 VPC |
| **Subnet name** | week5-day1-private-a | Private Subnet A |
| **Availability Zone** | ap-northeast-2a | AZ-A |
| **IPv4 CIDR block** | 10.0.11.0/24 | 256개 IP (251개 사용 가능) |

**이미지 자리**: Step 2-2 Private Subnet A 생성

#### 2-3. Public Subnet B 생성

**설정 값**:
| 항목 | 값 | 설명 |
|------|-----|------|
| **VPC ID** | week5-day1-vpc | 동일 VPC |
| **Subnet name** | week5-day1-public-b | Public Subnet B |
| **Availability Zone** | ap-northeast-2b | AZ-B |
| **IPv4 CIDR block** | 10.0.2.0/24 | 256개 IP (251개 사용 가능) |

**이미지 자리**: Step 2-3 Public Subnet B 생성

#### 2-4. Private Subnet B 생성

**설정 값**:
| 항목 | 값 | 설명 |
|------|-----|------|
| **VPC ID** | week5-day1-vpc | 동일 VPC |
| **Subnet name** | week5-day1-private-b | Private Subnet B |
| **Availability Zone** | ap-northeast-2b | AZ-B |
| **IPv4 CIDR block** | 10.0.12.0/24 | 256개 IP (251개 사용 가능) |

**이미지 자리**: Step 2-4 Private Subnet B 생성

**💡 Subnet CIDR 설계 팁**:
- Public: 10.0.1.0/24, 10.0.2.0/24 (작은 번호)
- Private: 10.0.11.0/24, 10.0.12.0/24 (큰 번호)
- 규칙적인 번호로 관리 용이

### ✅ Step 2 검증

**AWS Console에서 확인**:
```
VPC → Subnets → Filters에서 VPC 선택
```

**확인 항목**:
| Subnet 이름 | CIDR | AZ | 타입 |
|------------|------|-----|------|
| week5-day1-public-a | 10.0.1.0/24 | ap-northeast-2a | Public |
| week5-day1-private-a | 10.0.11.0/24 | ap-northeast-2a | Private |
| week5-day1-public-b | 10.0.2.0/24 | ap-northeast-2b | Public |
| week5-day1-private-b | 10.0.12.0/24 | ap-northeast-2b | Private |

**이미지 자리**: Step 2 검증 결과

**✅ 체크리스트**:
- [ ] 4개 Subnet 모두 생성 확인
- [ ] CIDR 블록 정확히 설정 확인
- [ ] AZ 분산 배치 확인 (2a, 2b)
- [ ] 이름 태그 정확히 설정 확인

---

## 🛠️ Step 3: Internet Gateway 생성 및 연결 (예상 시간: 10분)

### 📋 이 단계에서 할 일
- Internet Gateway 생성
- VPC에 연결

### 🔗 참조 개념
- [Session 2: VPC 아키텍처](./session_2.md) - Internet Gateway 역할

### 📝 실습 절차

#### 3-1. Internet Gateway 생성

**AWS Console 경로**:
```
VPC → Internet Gateways → Create internet gateway
```

**설정 값**:
| 항목 | 값 | 설명 |
|------|-----|------|
| **Name tag** | week5-day1-igw | Internet Gateway |

**이미지 자리**: Step 3-1 IGW 생성

#### 3-2. VPC에 연결

**AWS Console 경로**:
```
Internet Gateways → week5-day1-igw 선택 → Actions → Attach to VPC
```

**설정 값**:
| 항목 | 값 | 설명 |
|------|-----|------|
| **Available VPCs** | week5-day1-vpc | 위에서 생성한 VPC |

**이미지 자리**: Step 3-2 VPC 연결

**⚠️ 주의사항**:
- 하나의 VPC에는 하나의 IGW만 연결 가능
- IGW는 VPC에 연결되어야 작동

### ✅ Step 3 검증

**AWS Console에서 확인**:
```
VPC → Internet Gateways → week5-day1-igw 선택
```

**확인 항목**:
| 항목 | 예상 값 |
|------|---------|
| **Internet gateway ID** | igw-xxxxx |
| **State** | Attached |
| **VPC ID** | vpc-xxxxx (week5-day1-vpc) |

**이미지 자리**: Step 3 검증 결과

**✅ 체크리스트**:
- [ ] IGW ID 확인 (igw-xxxxx)
- [ ] State가 "Attached" 확인
- [ ] VPC ID 연결 확인

---

## 🛠️ Step 4: Route Table 설정 (예상 시간: 15분)

### 📋 이 단계에서 할 일
- Public Route Table 생성
- Public Route Table에 IGW 경로 추가
- Public Subnet들을 Public Route Table에 연결
- Private Route Table 확인 (기본 생성됨)

### 🔗 참조 개념
- [Session 2: VPC 아키텍처](./session_2.md) - Route Table 설정

### 📝 실습 절차

#### 4-1. Public Route Table 생성

**AWS Console 경로**:
```
VPC → Route Tables → Create route table
```

**설정 값**:
| 항목 | 값 | 설명 |
|------|-----|------|
| **Name** | week5-day1-public-rt | Public Route Table |
| **VPC** | week5-day1-vpc | 위에서 생성한 VPC |

**이미지 자리**: Step 4-1 Public RT 생성

#### 4-2. Internet Gateway 경로 추가

**AWS Console 경로**:
```
Route Tables → week5-day1-public-rt 선택 → Routes 탭 → Edit routes
```

**설정 값**:
| Destination | Target | 설명 |
|-------------|--------|------|
| 0.0.0.0/0 | week5-day1-igw | 모든 외부 트래픽을 IGW로 |

**이미지 자리**: Step 4-2 IGW 경로 추가

**💡 0.0.0.0/0의 의미**:
- 모든 IP 주소 (인터넷 전체)
- VPC 내부가 아닌 모든 트래픽을 IGW로 전달

#### 4-3. Public Subnet 연결

**AWS Console 경로**:
```
Route Tables → week5-day1-public-rt 선택 → Subnet associations 탭 → Edit subnet associations
```

**설정 값**:
- ✅ week5-day1-public-a
- ✅ week5-day1-public-b

**이미지 자리**: Step 4-3 Subnet 연결

#### 4-4. Private Route Table 확인

**AWS Console 경로**:
```
VPC → Route Tables → Main route table 확인
```

**확인 사항**:
- VPC 생성 시 자동으로 Main Route Table 생성됨
- Private Subnet들은 자동으로 Main Route Table 사용
- Main Route Table에는 IGW 경로 없음 (외부 접속 불가)

**이미지 자리**: Step 4-4 Private RT 확인

**💡 Main Route Table**:
- VPC 생성 시 자동 생성
- 명시적으로 연결하지 않은 Subnet은 Main RT 사용
- Private Subnet용으로 사용 (IGW 경로 없음)

### ✅ Step 4 검증

**AWS Console에서 확인**:
```
VPC → Route Tables → week5-day1-public-rt 선택 → Routes 탭
```

**확인 항목 (Routes)**:
| Destination | Target | Status |
|-------------|--------|--------|
| 10.0.0.0/16 | local | Active |
| 0.0.0.0/0 | igw-xxxxx | Active |

**Subnet associations 탭 확인**:
| Subnet ID | Subnet 이름 |
|-----------|-------------|
| subnet-xxxxx | week5-day1-public-a |
| subnet-yyyyy | week5-day1-public-b |

**이미지 자리**: Step 4 검증 결과

**✅ 체크리스트**:
- [ ] Public Route Table 생성 확인
- [ ] 0.0.0.0/0 → IGW 경로 확인
- [ ] Public Subnet 2개 연결 확인
- [ ] Private Subnet은 Main RT 사용 확인

---

## ✅ 전체 검증 체크리스트

### ✅ VPC 구성 완료
- [ ] VPC 생성 (10.0.0.0/16)
- [ ] DNS resolution 활성화
- [ ] DNS hostnames 활성화

### ✅ Subnet 구성 완료
- [ ] Public Subnet A (10.0.1.0/24, AZ-A)
- [ ] Private Subnet A (10.0.11.0/24, AZ-A)
- [ ] Public Subnet B (10.0.2.0/24, AZ-B)
- [ ] Private Subnet B (10.0.12.0/24, AZ-B)

### ✅ Internet Gateway 구성 완료
- [ ] IGW 생성
- [ ] VPC에 연결
- [ ] State "available" 확인

### ✅ Route Table 구성 완료
- [ ] Public Route Table 생성
- [ ] 0.0.0.0/0 → IGW 경로 추가
- [ ] Public Subnet 2개 연결
- [ ] Private Subnet Main RT 사용 확인

---

## 🔍 트러블슈팅

### 문제 1: Subnet CIDR 블록 중복 오류
**증상**:
```
The CIDR '10.0.1.0/24' conflicts with another subnet
```

**원인**:
- 동일한 CIDR 블록을 중복 사용

**해결 방법**:
- 각 Subnet마다 고유한 CIDR 블록 사용
- 10.0.1.0/24, 10.0.2.0/24, 10.0.11.0/24, 10.0.12.0/24

### 문제 2: IGW를 VPC에 연결할 수 없음
**증상**:
```
Resource has a dependent object
```

**원인**:
- 이미 다른 IGW가 연결되어 있음

**해결 방법**:
- 하나의 VPC에는 하나의 IGW만 연결 가능
- 기존 IGW 확인 및 제거

### 문제 3: Route Table 경로 추가 실패
**증상**:
```
The internet gateway ID 'igw-xxxxx' does not exist
```

**원인**:
- IGW가 VPC에 연결되지 않음

**해결 방법**:
- IGW를 먼저 VPC에 연결
- State가 "available" 확인 후 경로 추가

---

## 💰 비용 확인

### 예상 비용 계산
| 리소스 | 사용 시간 | 단가 | 예상 비용 |
|--------|----------|------|-----------|
| VPC | 무제한 | 무료 | $0.00 |
| Subnet | 무제한 | 무료 | $0.00 |
| Internet Gateway | 무제한 | 무료 | $0.00 |
| Route Table | 무제한 | 무료 | $0.00 |
| **합계** | | | **$0.00** |

**💡 비용 팁**:
- VPC 인프라 자체는 완전 무료
- 비용은 EC2, NAT Gateway 등 리소스 사용 시 발생

---

## 💡 Lab 회고

### 🤝 페어 회고 (5분)
1. **가장 어려웠던 부분**: 
2. **CIDR 블록 설계 경험**:
3. **Route Table 이해도**:

### 📊 학습 성과
- **기술적 성취**: VPC 네트워크 인프라 완전 구축
- **이해도 향상**: CIDR, Subnet, IGW, Route Table 개념
- **다음 Lab 준비**: EC2 배포를 위한 네트워크 준비 완료

---

## 🔗 관련 자료

### 📚 Session 복습
- [Session 1: AWS 기초 개념](./session_1.md)
- [Session 2: VPC 아키텍처](./session_2.md)

### 📖 AWS 공식 문서
- [VPC 사용자 가이드](https://docs.aws.amazon.com/vpc/latest/userguide/)
- [Subnet 설계](https://docs.aws.amazon.com/vpc/latest/userguide/configure-subnets.html)
- [Route Table](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html)

### 🎯 다음 Lab
- [Lab 2: EC2 웹 서버 배포](./lab_2.md) - VPC 위에 EC2 배포 및 Nginx 설치

---

<div align="center">

**✅ Lab 1 완료** • **🌐 네트워크 준비 완료** • **💻 다음은 EC2 배포**

*VPC 인프라 구축 성공! 이제 EC2를 배포할 준비가 되었습니다.*

</div>
