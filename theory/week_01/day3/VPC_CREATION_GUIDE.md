# VPC 완전 생성 가이드

<div align="center">
**🏗️ 3개 AZ** • **🌐 Public/Private 서브넷** • **📡 IGW/NAT Gateway**
*AWS VPC를 처음부터 끝까지 완벽하게 만들기*
</div>

---

## 🎯 만들 것

### 📐 최종 구조
```
VPC (10.0.0.0/16)
├── AZ-A (ap-northeast-2a)
│   ├── Public Subnet (10.0.1.0/24)
│   └── Private Subnet (10.0.11.0/24)
├── AZ-B (ap-northeast-2b)  
│   ├── Public Subnet (10.0.2.0/24)
│   └── Private Subnet (10.0.12.0/24)
└── AZ-C (ap-northeast-2c)
    ├── Public Subnet (10.0.3.0/24)
    └── Private Subnet (10.0.13.0/24)
```

---

## 🛠️ Step 1: VPC 생성 (2분)

### AWS Console 이동
```
AWS Console → VPC → Your VPCs → Create VPC
```

### 설정값
| 항목 | 값 | 설명 |
|------|-----|------|
| **Name** | `nw1d3-vpc` | VPC 이름 |
| **IPv4 CIDR** | `10.0.0.0/16` | IP 주소 범위 |
| **IPv6 CIDR** | 체크 안함 | IPv6 사용 안함 |
| **Tenancy** | Default | 기본값 |

**✅ 생성 버튼 클릭**

---

## 🛠️ Step 2: Internet Gateway 생성 (1분)

### AWS Console 이동
```
VPC → Internet gateways → Create internet gateway
```

### 설정값
| 항목 | 값 |
|------|-----|
| **Name** | `nw1d3-igw` |

**✅ 생성 후 VPC에 연결**
1. 생성된 IGW 선택
2. Actions → Attach to VPC
3. VPC: `nw1d3-vpc` 선택
4. Attach internet gateway 클릭

---

## 🛠️ Step 3: Public 서브넷 3개 생성 (3분)

### AWS Console 이동
```
VPC → Subnets → Create subnet
```

### 첫 번째 Public 서브넷
| 항목 | 값 |
|------|-----|
| **VPC** | `nw1d3-vpc` |
| **Name** | `nw1d3-public-a` |
| **AZ** | `ap-northeast-2a` |
| **IPv4 CIDR** | `10.0.1.0/24` |

### 두 번째 Public 서브넷
| 항목 | 값 |
|------|-----|
| **Name** | `nw1d3-public-b` |
| **AZ** | `ap-northeast-2b` |
| **IPv4 CIDR** | `10.0.2.0/24` |

### 세 번째 Public 서브넷
| 항목 | 값 |
|------|-----|
| **Name** | `nw1d3-public-c` |
| **AZ** | `ap-northeast-2c` |
| **IPv4 CIDR** | `10.0.3.0/24` |

**✅ Create subnet 클릭**

---

## 🛠️ Step 4: Private 서브넷 3개 생성 (3분)

### 동일한 방법으로 Private 서브넷 생성

### 첫 번째 Private 서브넷
| 항목 | 값 |
|------|-----|
| **VPC** | `nw1d3-vpc` |
| **Name** | `nw1d3-private-a` |
| **AZ** | `ap-northeast-2a` |
| **IPv4 CIDR** | `10.0.11.0/24` |

### 두 번째 Private 서브넷
| 항목 | 값 |
|------|-----|
| **Name** | `nw1d3-private-b` |
| **AZ** | `ap-northeast-2b` |
| **IPv4 CIDR** | `10.0.12.0/24` |

### 세 번째 Private 서브넷
| 항목 | 값 |
|------|-----|
| **Name** | `nw1d3-private-c` |
| **AZ** | `ap-northeast-2c` |
| **IPv4 CIDR** | `10.0.13.0/24` |

**✅ Create subnet 클릭**

---

## 🛠️ Step 5: NAT Gateway 생성 (2분)

### AWS Console 이동
```
VPC → NAT gateways → Create NAT gateway
```

### 설정값
| 항목 | 값 | 설명 |
|------|-----|------|
| **Name** | `nw1d3-natgw` | NAT Gateway 이름 |
| **Subnet** | `nw1d3-public-a` | Public 서브넷에 배치 |
| **Connectivity** | Public | 인터넷 연결 |
| **Elastic IP** | Allocate Elastic IP | 새 IP 할당 |

**✅ Create NAT gateway 클릭**

---

## 🛠️ Step 6: Route Table 생성 및 설정 (5분)

### 6-1. Public Route Table 생성
```
VPC → Route tables → Create route table
```

| 항목 | 값 |
|------|-----|
| **Name** | `nw1d3-public-rt` |
| **VPC** | `nw1d3-vpc` |

**✅ Create route table 클릭**

### 6-2. Public Route Table 설정
1. 생성된 Route Table 선택
2. **Routes 탭** → Edit routes
3. Add route 클릭
4. Destination: `0.0.0.0/0`
5. Target: Internet Gateway → `nw1d3-igw` 선택
6. Save changes

### 6-3. Public 서브넷 연결
1. **Subnet associations 탭** → Edit subnet associations
2. 3개 Public 서브넷 모두 선택:
   - `nw1d3-public-a`
   - `nw1d3-public-b` 
   - `nw1d3-public-c`
3. Save associations

### 6-4. Private Route Table 생성
```
VPC → Route tables → Create route table
```

| 항목 | 값 |
|------|-----|
| **Name** | `nw1d3-private-rt` |
| **VPC** | `nw1d3-vpc` |

### 6-5. Private Route Table 설정
1. 생성된 Route Table 선택
2. **Routes 탭** → Edit routes
3. Add route 클릭
4. Destination: `0.0.0.0/0`
5. Target: NAT Gateway → `nw1d3-natgw` 선택
6. Save changes

### 6-6. Private 서브넷 연결
1. **Subnet associations 탭** → Edit subnet associations
2. 3개 Private 서브넷 모두 선택:
   - `nw1d3-private-a`
   - `nw1d3-private-b`
   - `nw1d3-private-c`
3. Save associations

---

## ✅ 완성 확인

### 체크리스트
- [ ] VPC 1개 생성됨
- [ ] Internet Gateway 1개 생성 및 연결됨
- [ ] Public 서브넷 3개 생성됨 (각 AZ별)
- [ ] Private 서브넷 3개 생성됨 (각 AZ별)
- [ ] NAT Gateway 1개 생성됨
- [ ] Public Route Table 생성 및 IGW 연결됨
- [ ] Private Route Table 생성 및 NAT GW 연결됨
- [ ] 모든 서브넷이 올바른 Route Table에 연결됨

### 최종 확인 방법
```
VPC → Your VPCs → nw1d3-vpc 선택 → Resource map
```
**모든 리소스가 연결된 다이어그램이 보이면 성공!**

---

## 💰 예상 비용
- **NAT Gateway**: $0.045/시간 (약 $32/월)
- **Elastic IP**: $0.005/시간 (미사용 시)
- **기타**: 무료

**⚠️ 실습 후 반드시 삭제하세요!**

---

## 🔍 문제 해결

### 문제 1: 서브넷이 안 보여요
**해결**: VPC를 올바르게 선택했는지 확인

### 문제 2: Route Table 연결이 안 돼요
**해결**: 같은 VPC 내의 리소스인지 확인

### 문제 3: NAT Gateway가 pending 상태예요
**해결**: 2-3분 기다리면 available 상태로 변경됨

---

<div align="center">

**🎉 VPC 생성 완료!** • **🔧 실습 준비 완료** • **💡 네트워킹 기초 완성**

*이제 EC2, RDS 등 다른 서비스를 이 VPC에 배치할 수 있습니다*

</div>
