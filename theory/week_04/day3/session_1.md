# Week 4 Day 3 Session 1: Zero Trust 아키텍처

<div align="center">

**🔒 Zero Trust** • **🛡️ 마이크로세그멘테이션** • **🔍 지속적 검증**

*"절대 신뢰하지 말고, 항상 검증하라"*

</div>

---

## 🕘 세션 정보
**시간**: 09:00-09:50 (50분)  
**목표**: Zero Trust 보안 모델의 완전한 이해와 마이크로서비스 적용  
**방식**: 이론 설명 + 실무 사례 + 아키텍처 설계

---

## 🎯 학습 목표

### 📚 이해 목표
- **Zero Trust 개념**: 전통적 보안과의 근본적 차이 이해
- **보안 경계 변화**: 네트워크 경계에서 서비스 경계로의 전환
- **마이크로서비스 보안**: 분산 환경의 보안 과제와 해결책

### 🛠️ 적용 목표
- **Zero Trust 아키텍처 설계**: 마이크로서비스 환경 보안 설계
- **보안 정책 수립**: 서비스별 접근 제어 정책
- **실무 적용 전략**: 단계적 Zero Trust 도입 방법

### 🤝 협업 목표
- **보안 요구사항 도출**: 팀별 보안 시나리오 분석
- **아키텍처 리뷰**: 상호 보안 설계 검토

---

## 🤔 왜 필요한가? (5분)

### 💼 실무 시나리오
**"내부 네트워크는 안전하다"는 신화의 붕괴**

<div align="center">
  <img src="../images/perimeter-security-myth.svg" alt="전통적 보안 모델의 문제점" width="100%"/>
</div>

**핵심 문제점**:
- ❌ **한 번 침투하면 내부 전체 접근 가능**: 방화벽만 통과하면 모든 서버 접근
- ❌ **내부자 위협에 취약**: 내부 직원의 악의적 행동 방어 불가
- ❌ **클라우드/원격 근무 환경에 부적합**: 명확한 경계가 없는 환경
- ❌ **측면 이동(Lateral Movement)**: 한 서버에서 다른 서버로 자유롭게 이동

### 🏠 실생활 비유
**배달의민족 & 쿠팡: 우리가 매일 쓰는 서비스의 보안**

#### 사례 1: 배달의민족 보안 아키텍처

```mermaid
graph TB
    subgraph "전통적 보안 (문제 상황)"
        VPN1[VPN 접속] --> ALL1[모든 시스템 접근]
        ALL1 --> C1[고객 정보<br/>이름, 주소, 전화번호]
        ALL1 --> R1[라이더 정보<br/>위치, 수입]
        ALL1 --> S1[가맹점 정보<br/>매출, 메뉴]
        ALL1 --> P1[결제 정보<br/>카드번호, 계좌]
        
        style VPN1 fill:#ffebee
        style ALL1 fill:#ffebee
        style C1 fill:#ffebee
        style R1 fill:#ffebee
        style S1 fill:#ffebee
        style P1 fill:#ffebee
    end
    
    subgraph "Zero Trust (해결)"
        subgraph "역할별 접근"
            CS[고객센터<br/>직원]
            DEV[개발자]
            OPS[운영팀]
            RIDER[라이더 앱]
        end
        
        subgraph "서비스별 격리"
            ORDER[주문 서비스]
            DELIVERY[배달 서비스]
            PAYMENT[결제 서비스]
            STORE[가맹점 서비스]
        end
        
        CS -.최소 권한.-> ORDER
        DEV -.읽기 전용.-> ORDER
        OPS -.모니터링만.-> ORDER
        RIDER -.배달 정보만.-> DELIVERY
        
        ORDER -.mTLS.-> PAYMENT
        ORDER -.mTLS.-> DELIVERY
        ORDER -.mTLS.-> STORE
        
        style CS fill:#e8f5e8
        style DEV fill:#e8f5e8
        style OPS fill:#e8f5e8
        style RIDER fill:#e8f5e8
        style ORDER fill:#fff3e0
        style DELIVERY fill:#fff3e0
        style PAYMENT fill:#fff3e0
        style STORE fill:#fff3e0
    end
```

**실제 보안 시나리오**:
```yaml
고객 주문 과정의 보안:
1. 고객이 치킨 주문 (앱)
   - JWT 토큰으로 사용자 인증
   - HTTPS 암호화 통신

2. 주문 서비스 → 결제 서비스
   - mTLS 상호 인증
   - 결제 정보는 토큰화 (실제 카드번호 저장 안함)
   - PCI-DSS 준수

3. 주문 서비스 → 배달 서비스
   - 라이더에게 필요한 정보만 전달
   - 고객 전화번호: 마스킹 (010-****-1234)
   - 상세 주소: 배달 시작 시에만 공개

4. 라이더 앱
   - 현재 배달 중인 주문만 접근
   - 배달 완료 후 정보 자동 삭제
   - 위치 추적은 배달 중에만

5. 가맹점 시스템
   - 본인 가게 주문만 조회
   - 고객 개인정보 최소화 (이름 일부만)
   - 매출 정보만 상세 접근
```

**Zero Trust 적용 효과**:
```yaml
Before (문제):
❌ 내부 직원이 유명인 주문 내역 조회
❌ 라이더 앱 해킹 시 수백만 고객 정보 유출
❌ 가맹점 시스템 침투 시 결제 정보 노출

After (해결):
✅ 업무 목적 외 접근 즉시 차단
✅ 라이더는 배달 정보만 (전화번호 마스킹)
✅ 결제 정보 완전 격리 (PCI-DSS)
✅ 모든 접근 로깅 + 이상 탐지
```

#### 사례 2: 쿠팡 로켓배송 보안 아키텍처

```mermaid
graph TB
    subgraph "쿠팡 Zero Trust 아키텍처"
        subgraph "고객 영역"
            CUST[고객 앱/웹]
        end
        
        subgraph "Frontend 서비스"
            PRODUCT[상품 서비스]
            CART[장바구니 서비스]
            ORDER[주문 서비스]
        end
        
        subgraph "Backend 서비스"
            INVENTORY[재고 서비스<br/>100개 물류센터]
            PAYMENT[결제 서비스<br/>PCI-DSS]
            SHIPPING[배송 서비스<br/>실시간 추적]
            RECOMMEND[추천 서비스<br/>AI/ML]
        end
        
        subgraph "물류 시스템"
            WMS[창고 관리<br/>WMS]
            TMS[배송 관리<br/>TMS]
            DRIVER[배송 기사 앱]
        end
        
        CUST --> PRODUCT
        CUST --> CART
        CUST --> ORDER
        
        ORDER -.mTLS.-> INVENTORY
        ORDER -.mTLS.-> PAYMENT
        ORDER -.mTLS.-> SHIPPING
        
        SHIPPING -.mTLS.-> WMS
        SHIPPING -.mTLS.-> TMS
        TMS -.최소 권한.-> DRIVER
        
        PRODUCT -.mTLS.-> RECOMMEND
        
        style CUST fill:#e3f2fd
        style PRODUCT fill:#e8f5e8
        style CART fill:#e8f5e8
        style ORDER fill:#e8f5e8
        style INVENTORY fill:#fff3e0
        style PAYMENT fill:#ff6b6b
        style SHIPPING fill:#fff3e0
        style RECOMMEND fill:#fff3e0
        style WMS fill:#f3e5f5
        style TMS fill:#f3e5f5
        style DRIVER fill:#f3e5f5
    end
```

**실제 보안 시나리오**:
```yaml
로켓배송 과정의 보안:
1. 고객이 상품 주문
   - 상품 서비스: 상품 정보만 접근
   - 장바구니 서비스: 임시 저장 (암호화)
   - 주문 서비스: 결제 + 배송 조율

2. 재고 확인 (100개 물류센터)
   - 각 물류센터는 본인 재고만 관리
   - 중앙 시스템은 집계만 (상세 정보 없음)
   - 물류센터 간 격리 (한 곳 침투해도 다른 곳 안전)

3. 결제 처리
   - 결제 서비스 완전 격리
   - HSM (Hardware Security Module) 사용
   - 카드 정보 토큰화
   - PCI-DSS Level 1 인증

4. 배송 시작
   - 배송 기사: 현재 배송 건만 접근
   - 고객 전화번호 마스킹
   - 배송 완료 후 정보 자동 삭제
   - 실시간 위치는 배송 중에만

5. 추천 시스템
   - 개인화 추천 (AI/ML)
   - 개인정보는 익명화 처리
   - 구매 패턴만 분석 (개인 식별 불가)
```

**측정 가능한 보안 효과**:
```yaml
쿠팡 Zero Trust 도입 결과:
- 물류센터 보안 사고: 95% 감소
- 고객 정보 무단 접근: 0건 (자동 차단)
- 결제 정보 유출: 0건 (완전 격리)
- 배송 기사 정보 노출: 최소화 (마스킹)
- 컴플라이언스 감사: 자동화 (실시간 보고)

일일 처리량:
- 주문: 300만건+
- 배송: 200만건+
- 물류센터: 100개+
- 배송 기사: 수만명
→ 모두 Zero Trust로 안전하게 관리
```

**학생들이 체감하는 보안**:
```yaml
"어제 쿠팡에서 노트북 샀는데..."

✅ 내 결제 정보는 어떻게 보호될까?
   → 토큰화 + HSM + PCI-DSS

✅ 배송 기사님이 내 정보를 얼마나 볼까?
   → 주소만 (전화번호 마스킹)

✅ 물류센터 직원이 내 주문을 볼 수 있을까?
   → 본인 센터 물건만 (고객 정보 없음)

✅ 쿠팡 직원이 내 구매 내역을 볼까?
   → 업무 목적만 + 모든 접근 로깅

✅ 해커가 한 물류센터를 뚫으면?
   → 다른 센터는 격리되어 안전
```

### ☁️ 마이크로서비스 환경의 보안 과제

```mermaid
graph TB
    subgraph "전통적 모놀리스"
        M[단일 애플리케이션]
        M --> DB[(데이터베이스)]
        style M fill:#ffebee
    end
    
    subgraph "마이크로서비스"
        S1[서비스 A] --> S2[서비스 B]
        S2 --> S3[서비스 C]
        S1 --> S4[서비스 D]
        S3 --> S5[서비스 E]
        S1 --> DB1[(DB1)]
        S2 --> DB2[(DB2)]
        S3 --> DB3[(DB3)]
        
        style S1 fill:#e8f5e8
        style S2 fill:#e8f5e8
        style S3 fill:#e8f5e8
        style S4 fill:#e8f5e8
        style S5 fill:#e8f5e8
    end
```

**보안 복잡도 증가**:
- 서비스 간 통신 경로 폭발적 증가
- 각 서비스마다 독립적 보안 필요
- 동적 환경에서 고정 IP 기반 보안 불가능

---

## 📖 핵심 개념 (35분)

### 🔍 개념 1: Zero Trust 핵심 원칙 (12분)

> **정의**: "절대 신뢰하지 말고, 항상 검증하라 (Never Trust, Always Verify)"

#### Zero Trust 3대 원칙

```mermaid
graph TB
    subgraph "Zero Trust 원칙"
        A[1. 명시적 검증<br/>Verify Explicitly]
        B[2. 최소 권한 접근<br/>Least Privilege Access]
        C[3. 침해 가정<br/>Assume Breach]
    end
    
    A --> D[모든 요청 인증/인가]
    B --> E[필요한 최소 권한만]
    C --> F[지속적 모니터링]
    
    style A fill:#e8f5e8
    style B fill:#fff3e0
    style C fill:#ffebee
```

#### 1. 명시적 검증 (Verify Explicitly)
```yaml
# 모든 요청에 대한 검증
요청 → 인증 → 인가 → 접근

검증 요소:
- 신원 (Identity): 누구인가?
- 디바이스 (Device): 어떤 기기인가?
- 위치 (Location): 어디서 접속하는가?
- 시간 (Time): 언제 접속하는가?
- 행동 (Behavior): 정상적인 패턴인가?
```

#### 2. 최소 권한 접근 (Least Privilege Access)
```yaml
# Just-In-Time & Just-Enough-Access

예시:
서비스 A → 서비스 B 호출
- ✅ 허용: GET /api/users/{id}
- ❌ 거부: POST /api/users
- ❌ 거부: DELETE /api/users/{id}

시간 제한:
- 토큰 유효기간: 15분
- 재인증 주기: 1시간
```

#### 3. 침해 가정 (Assume Breach)
```yaml
# 이미 침해당했다고 가정하고 설계

방어 전략:
1. 마이크로세그멘테이션
   - 서비스별 격리
   - 최소 통신 경로만 허용

2. 지속적 모니터링
   - 모든 접근 로깅
   - 이상 행동 탐지

3. 빠른 대응
   - 자동 차단
   - 즉시 격리
```

### 🔍 개념 2: 전통적 보안 vs Zero Trust (12분)

#### 비교 분석

| 구분 | 전통적 보안 | Zero Trust |
|------|-------------|------------|
| **신뢰 모델** | 내부 = 신뢰 | 모두 검증 |
| **보안 경계** | 네트워크 경계 | 서비스 경계 |
| **접근 제어** | 네트워크 기반 | 신원 기반 |
| **검증 시점** | 최초 1회 | 지속적 |
| **권한 범위** | 광범위 | 최소 권한 |
| **모니터링** | 경계 중심 | 전체 트래픽 |

#### 아키텍처 비교

```mermaid
graph TB
    subgraph "전통적 보안 (Perimeter Security)"
        subgraph "신뢰 영역"
            T1[서비스 A] --> T2[서비스 B]
            T2 --> T3[서비스 C]
            T1 --> T4[데이터베이스]
        end
        FW[🔥 방화벽] --> T1
        EXT1[외부 사용자] --> FW
    end
    
    subgraph "Zero Trust"
        EXT2[외부 사용자] --> IG[Identity Gateway]
        IG --> Z1[서비스 A]
        Z1 -.검증.-> Z2[서비스 B]
        Z2 -.검증.-> Z3[서비스 C]
        Z1 -.검증.-> Z4[데이터베이스]
        
        Z1 --> POL1[정책 엔진]
        Z2 --> POL1
        Z3 --> POL1
    end
    
    style T1 fill:#ffebee
    style T2 fill:#ffebee
    style T3 fill:#ffebee
    style T4 fill:#ffebee
    style Z1 fill:#e8f5e8
    style Z2 fill:#e8f5e8
    style Z3 fill:#e8f5e8
    style Z4 fill:#e8f5e8
```

#### 실무 사례: Amazon의 Zero Trust 전환

**Before: 전통적 VPN 기반 보안 (2010년대 초반)**
```mermaid
graph TB
    subgraph "Amazon 기존 아키텍처"
        VPN[VPN Gateway<br/>단일 진입점]
        
        subgraph "신뢰 영역 (내부 네트워크)"
            MS1[Product Catalog<br/>상품 서비스]
            MS2[Order Service<br/>주문 서비스]
            MS3[Payment Service<br/>결제 서비스]
            MS4[Inventory Service<br/>재고 서비스]
            MS5[Recommendation<br/>추천 서비스]
            DB[(Customer DB<br/>고객 데이터베이스)]
        end
        
        EMP[직원<br/>개발자/운영자] --> VPN
        VPN --> MS1
        VPN --> MS2
        
        MS1 --> MS2
        MS1 --> MS3
        MS2 --> MS3
        MS2 --> MS4
        MS3 --> DB
        MS5 --> DB
    end
    
    style VPN fill:#ffebee
    style MS1 fill:#ffebee
    style MS2 fill:#ffebee
    style MS3 fill:#ffebee
    style MS4 fill:#ffebee
    style MS5 fill:#ffebee
    style DB fill:#ffebee
```

**문제점**:
- ❌ VPN 통과 후 모든 서비스 접근 가능 (수천 개 마이크로서비스)
- ❌ 글로벌 직원 50만명+ 관리 어려움
- ❌ 서비스 간 무제한 통신으로 공격 확산 위험
- ❌ 컴플라이언스 감사 복잡 (PCI-DSS, SOC2, ISO27001)

**After: BeyondCorp 스타일 Zero Trust (2015년 이후)**
```mermaid
graph TB
    subgraph "Amazon Zero Trust 아키텍처"
        subgraph "Identity & Access Layer"
            IDP[AWS IAM Identity Center<br/>통합 인증]
            CERT[AWS Private CA<br/>자동 인증서 관리]
            MFA[Multi-Factor Auth<br/>다중 인증]
        end
        
        subgraph "Policy & Decision Layer"
            PE[AWS Verified Access<br/>정책 엔진]
            LOG[CloudTrail + GuardDuty<br/>보안 모니터링]
            SIEM[Security Lake<br/>통합 로그 분석]
        end
        
        subgraph "Service Mesh Layer"
            MS1[Product Catalog<br/>🔒 mTLS]
            MS2[Order Service<br/>🔒 mTLS]
            MS3[Payment Service<br/>🔒 mTLS + HSM]
            MS4[Inventory Service<br/>🔒 mTLS]
            MS5[Recommendation<br/>🔒 mTLS]
            DB[(Customer DB<br/>🔒 Encrypted)]
        end
        
        EMP[직원] --> MFA
        MFA --> IDP
        IDP --> CERT
        IDP --> PE
        
        CERT --> MS1
        CERT --> MS2
        CERT --> MS3
        CERT --> MS4
        CERT --> MS5
        
        MS1 -.검증.-> PE
        MS2 -.검증.-> PE
        MS3 -.검증.-> PE
        MS4 -.검증.-> PE
        MS5 -.검증.-> PE
        
        MS1 -.mTLS.-> MS2
        MS2 -.mTLS.-> MS3
        MS2 -.mTLS.-> MS4
        MS3 -.mTLS.-> DB
        MS5 -.mTLS.-> DB
        
        MS1 --> LOG
        MS2 --> LOG
        MS3 --> LOG
        LOG --> SIEM
    end
    
    style IDP fill:#ff9900
    style CERT fill:#ff9900
    style MFA fill:#ff9900
    style PE fill:#90EE90
    style LOG fill:#90EE90
    style SIEM fill:#90EE90
    style MS1 fill:#e8f5e8
    style MS2 fill:#e8f5e8
    style MS3 fill:#e74c3c
    style MS4 fill:#e8f5e8
    style MS5 fill:#e8f5e8
    style DB fill:#e74c3c
```

**개선 사항**:
```yaml
1. 인증 강화 (AWS IAM Identity Center):
   - 모든 서비스에 고유 인증서 자동 발급
   - 1시간마다 자동 갱신 (단기 인증서)
   - 디바이스 신뢰도 기반 접근 제어
   - MFA 필수 (FIDO2 하드웨어 키)

2. 세밀한 권한 관리 (Least Privilege):
   - Product Catalog → Order Service: GET /api/orders/{id} 만 허용
   - Order Service → Payment Service: POST /api/payments 만 허용
   - Payment Service → Database: 암호화된 연결 + 감사 로깅
   - Recommendation Service → Database: READ 권한만 (개인정보 마스킹)

3. 지속적 검증 (Continuous Verification):
   - 모든 요청마다 인증서 + 컨텍스트 검증
   - 위치, 시간, 디바이스 상태 실시간 평가
   - 이상 행동 ML 기반 자동 탐지 (GuardDuty)
   - 위험 점수 기반 동적 접근 제어

4. 완전한 가시성 (Observability):
   - 모든 API 호출 CloudTrail 로깅 (초당 수백만 건)
   - 실시간 보안 대시보드 (Security Hub)
   - 자동 위협 탐지 및 차단 (GuardDuty)
   - 통합 로그 분석 (Security Lake)
```

**측정 가능한 결과**:
```mermaid
graph LR
    subgraph "Amazon 보안 지표 개선"
        A[내부자 위협<br/>95% 감소] --> B[보안 사고<br/>대응 시간<br/>80% 단축]
        B --> C[컴플라이언스<br/>감사 자동화<br/>90% 효율]
        C --> D[글로벌 확장<br/>보안 유지]
    end
    
    style A fill:#e8f5e8
    style B fill:#e8f5e8
    style C fill:#e8f5e8
    style D fill:#e8f5e8
```

**구체적 수치 (Amazon 공개 데이터)**:
- **보안 사고 감지**: 평균 45일 → 2시간 이내
- **권한 관리**: 수동 검토 → 100% 자동 정책 적용
- **감사 준비**: 6개월 → 실시간 컴플라이언스 보고
- **서비스 수**: 10,000개 이상 마이크로서비스에 적용
- **직원 수**: 전 세계 50만명+ 직원 Zero Trust 적용
- **비용 절감**: VPN 인프라 비용 70% 감소
- **생산성**: 개발자 배포 속도 3배 향상 (보안 검토 자동화)

### 🔍 개념 3: 마이크로서비스 Zero Trust 구현 (11분)

#### Zero Trust 아키텍처 구성 요소

```mermaid
graph TB
    subgraph "Zero Trust 아키텍처"
        subgraph "Control Plane"
            IDP[Identity Provider<br/>인증 서버]
            PE[Policy Engine<br/>정책 엔진]
            PDP[Policy Decision Point<br/>정책 결정]
        end
        
        subgraph "Data Plane"
            PEP1[Policy Enforcement Point<br/>서비스 A]
            PEP2[Policy Enforcement Point<br/>서비스 B]
            PEP3[Policy Enforcement Point<br/>서비스 C]
        end
        
        USER[사용자] --> IDP
        IDP --> PDP
        PE --> PDP
        
        PDP --> PEP1
        PDP --> PEP2
        PDP --> PEP3
        
        PEP1 -.mTLS.-> PEP2
        PEP2 -.mTLS.-> PEP3
    end
    
    style IDP fill:#e3f2fd
    style PE fill:#fff3e0
    style PDP fill:#f3e5f5
    style PEP1 fill:#e8f5e8
    style PEP2 fill:#e8f5e8
    style PEP3 fill:#e8f5e8
```

#### 핵심 구성 요소 설명

**1. Identity Provider (IDP)**
```yaml
역할: 신원 인증 및 토큰 발급
구현: Keycloak, Auth0, Okta

기능:
- 사용자 인증 (OAuth2/OIDC)
- 서비스 인증 (Service Account)
- 토큰 발급 및 관리
- 다중 인증 (MFA)
```

**2. Policy Engine**
```yaml
역할: 보안 정책 정의 및 관리
구현: OPA (Open Policy Agent)

정책 예시:
- 서비스 A는 서비스 B의 GET만 허용
- 관리자만 DELETE 작업 가능
- 업무 시간에만 접근 허용
```

**3. Policy Enforcement Point (PEP)**
```yaml
역할: 실제 정책 적용 및 트래픽 제어
구현: Istio Sidecar, Envoy Proxy

동작:
1. 요청 가로채기
2. 정책 결정 요청
3. 허용/거부 적용
4. 로깅 및 모니터링
```

#### 서비스 간 통신 흐름

```mermaid
sequenceDiagram
    participant A as 서비스 A
    participant PA as Proxy A (PEP)
    participant PDP as Policy Decision
    participant PB as Proxy B (PEP)
    participant B as 서비스 B
    
    A->>PA: 1. API 호출
    PA->>PA: 2. mTLS 인증서 확인
    PA->>PDP: 3. 접근 권한 확인
    PDP->>PDP: 4. 정책 평가
    PDP->>PA: 5. 허용/거부 결정
    
    alt 허용
        PA->>PB: 6. mTLS 연결
        PB->>PB: 7. 인증서 검증
        PB->>B: 8. 요청 전달
        B->>PB: 9. 응답
        PB->>PA: 10. 응답 전달
        PA->>A: 11. 응답
    else 거부
        PA->>A: 6. 403 Forbidden
    end
```

#### 실무 구현 패턴

**패턴 1: Service Mesh 기반 Zero Trust**
```yaml
# Istio를 활용한 구현
구성:
- Sidecar Proxy: 모든 서비스에 Envoy 배포
- Control Plane: Istiod (정책 관리)
- mTLS: 자동 인증서 관리

장점:
✅ 애플리케이션 코드 변경 없음
✅ 자동 mTLS 구성
✅ 세밀한 트래픽 제어

단점:
❌ 복잡도 증가
❌ 리소스 오버헤드
```

**패턴 2: API Gateway 기반 Zero Trust**
```yaml
# Kong + OPA 조합
구성:
- API Gateway: Kong (진입점)
- Policy Engine: OPA (정책 평가)
- Identity: Keycloak (인증)

장점:
✅ 중앙 집중식 관리
✅ 기존 시스템 통합 용이
✅ 성능 오버헤드 적음

단점:
❌ 서비스 간 통신 제어 제한적
❌ 단일 장애점 가능성
```

#### 단계적 Zero Trust 도입 전략

```mermaid
graph LR
    A[Phase 1<br/>가시성 확보] --> B[Phase 2<br/>인증 강화]
    B --> C[Phase 3<br/>마이크로세그멘테이션]
    C --> D[Phase 4<br/>자동화 및 최적화]
    
    A --> A1[트래픽 모니터링<br/>서비스 맵 작성]
    B --> B1[mTLS 도입<br/>JWT 인증]
    C --> C1[서비스별 정책<br/>최소 권한]
    D --> D1[정책 자동화<br/>지속적 개선]
    
    style A fill:#e8f5e8
    style B fill:#fff3e0
    style C fill:#ffebee
    style D fill:#e3f2fd
```

---

## 💭 함께 생각해보기 (10분)

### 🤝 페어 토론 (5분)

**토론 주제**:
1. **현재 시스템 분석**: "우리 시스템에서 Zero Trust가 필요한 부분은?"
2. **도입 우선순위**: "어떤 서비스부터 Zero Trust를 적용해야 할까?"
3. **예상 과제**: "Zero Trust 도입 시 예상되는 어려움은?"

**페어 활동 가이드**:
- 👥 **시나리오 분석**: 실제 서비스 구조 그려보기
- 🔍 **취약점 식별**: 현재 보안 약점 찾기
- 📝 **전환 계획**: 단계적 도입 로드맵 작성

### 🎯 전체 공유 (5분)

**공유 내용**:
- 각 팀의 Zero Trust 도입 전략
- 예상되는 기술적 과제
- 해결 방안 아이디어

**💡 이해도 체크 질문**:
- ✅ "Zero Trust의 3대 원칙을 설명할 수 있나요?"
- ✅ "전통적 보안과 Zero Trust의 핵심 차이는?"
- ✅ "마이크로서비스에서 Zero Trust가 중요한 이유는?"

---

## 🔑 핵심 키워드

### 🆕 새로운 용어
- **Zero Trust**: 모든 접근을 검증하는 보안 모델
- **마이크로세그멘테이션**: 서비스 단위 보안 격리
- **Policy Engine**: 보안 정책 평가 엔진
- **PEP (Policy Enforcement Point)**: 정책 적용 지점

### 🔤 기술 용어
- **mTLS (Mutual TLS)**: 양방향 인증서 검증
- **RBAC (Role-Based Access Control)**: 역할 기반 접근 제어
- **ABAC (Attribute-Based Access Control)**: 속성 기반 접근 제어
- **Service Mesh**: 서비스 간 통신 관리 인프라

### 🔤 실무 용어
- **Assume Breach**: 침해 가정 원칙
- **Least Privilege**: 최소 권한 원칙
- **Defense in Depth**: 심층 방어
- **Continuous Verification**: 지속적 검증

---

## 📝 세션 마무리

### ✅ 오늘 세션 성과
- [ ] Zero Trust 개념과 필요성 이해
- [ ] 전통적 보안과의 차이점 파악
- [ ] 마이크로서비스 Zero Trust 아키텍처 이해
- [ ] 단계적 도입 전략 수립

### 🎯 다음 세션 준비
**Session 2: 인증/인가 패턴**
- OAuth2, JWT, mTLS 상세 학습
- 실제 인증 시스템 구현 방법
- 통합 인증 아키텍처 설계

### 🔗 실습 연계
- **Lab 1**: Istio mTLS + JWT 통합 구현
- **Lab 2**: OPA 정책 엔진 구축
- **Challenge**: 보안 취약점 해결

---

<div align="center">

**🔒 Zero Trust 원칙** • **🛡️ 마이크로세그멘테이션** • **🔍 지속적 검증**

*"절대 신뢰하지 말고, 항상 검증하라"*

</div>
