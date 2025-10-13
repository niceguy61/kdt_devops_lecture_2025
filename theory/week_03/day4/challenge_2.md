# Week 3 Day 4 Challenge 2: 보안 & 클러스터 관리 아키텍처 구현 챌린지 (선택사항, 90분)

<div align="center">

**🔐 보안 설계** • **👥 권한 관리** • **🛡️ 클러스터 보안**

*RBAC, Network Policy, Security Context를 활용한 보안 강화 아키텍처 구현*

</div>

---

## 🎯 Challenge 목표

### 📚 학습 목표
- **보안 설계**: RBAC 권한 체계와 Network Policy 구현
- **클러스터 관리**: 사용자 인증과 리소스 격리 전략
- **실무 문서화**: 보안 정책과 권한 매트릭스 분석

### 🛠️ 구현 목표
- **GitHub Repository**: 보안 설정과 정책의 체계적 관리
- **클러스터 시각화**: 권한 구조와 보안 정책 시각화
- **분석 보고서**: 보안 위험 분석과 대응 방안 수립

---

## 🌐 도메인 준비 (필요시)

### 📋 무료 도메인 발급 가이드
**외부 접근 테스트를 위해 도메인을 준비하세요.**

👉 **[무료 도메인 발급 가이드](../../shared/free-domain-guide.md)** 참조

---

## 🏗️ 구현 시나리오

### 📖 비즈니스 상황
**"금융 서비스의 멀티 테넌트 플랫폼 보안 설계"**

핀테크 회사에서 여러 금융 상품을 제공하는 플랫폼을 운영합니다.
각 상품팀이 독립적으로 개발하면서도 강력한 보안과 격리가 필요합니다.

### 🏦 조직 구조 요구사항
1. **개발팀 (3개팀)**: 각각 독립된 네임스페이스
   - **대출팀**: loan-service 개발
   - **카드팀**: card-service 개발  
   - **투자팀**: investment-service 개발
2. **운영팀**: 모든 네임스페이스 모니터링 권한
3. **보안팀**: 보안 정책 관리 및 감사
4. **데이터팀**: 데이터베이스 관리 전담

### 🔐 보안 요구사항
- **네임스페이스 격리**: 팀 간 완전 격리
- **최소 권한 원칙**: 필요한 최소 권한만 부여
- **네트워크 보안**: 서비스 간 통신 제어
- **데이터 보호**: 민감 정보 암호화 및 접근 제어
- **감사 로깅**: 모든 보안 이벤트 기록

### 👥 권한 매트릭스
| 역할 | loan-ns | card-ns | investment-ns | monitoring-ns | data-ns |
|------|---------|---------|---------------|---------------|---------|
| 대출 개발자 | 전체 | 읽기 전용 | 없음 | 읽기 전용 | 없음 |
| 카드 개발자 | 읽기 전용 | 전체 | 없음 | 읽기 전용 | 없음 |
| 투자 개발자 | 없음 | 읽기 전용 | 전체 | 읽기 전용 | 없음 |
| 운영팀 | 읽기 전용 | 읽기 전용 | 읽기 전용 | 전체 | 읽기 전용 |
| 보안팀 | 감사 | 감사 | 감사 | 전체 | 감사 |
| 데이터팀 | 없음 | 없음 | 없음 | 읽기 전용 | 전체 |

---

## 📁 GitHub Repository 구조

### 필수 디렉토리 구조
```
fintech-security-platform/
├── README.md                           # 프로젝트 개요
├── k8s-manifests/                      # Kubernetes 매니페스트
│   ├── namespaces/
│   │   ├── team-namespaces.yaml
│   │   ├── monitoring-namespace.yaml
│   │   └── data-namespace.yaml
│   ├── rbac/
│   │   ├── roles/
│   │   │   ├── developer-roles.yaml
│   │   │   ├── operator-roles.yaml
│   │   │   └── security-roles.yaml
│   │   ├── rolebindings/
│   │   │   ├── team-bindings.yaml
│   │   │   └── admin-bindings.yaml
│   │   └── service-accounts/
│   │       └── team-service-accounts.yaml
│   ├── security/
│   │   ├── network-policies/
│   │   │   ├── team-isolation.yaml
│   │   │   └── database-access.yaml
│   │   ├── pod-security/
│   │   │   └── security-contexts.yaml
│   │   └── secrets/
│   │       └── encrypted-secrets.yaml
│   └── workloads/
│       ├── loan-service.yaml
│       ├── card-service.yaml
│       ├── investment-service.yaml
│       └── monitoring-stack.yaml
├── docs/                               # 분석 문서
│   ├── security-analysis.md           # 보안 분석 보고서
│   ├── rbac-matrix.md                 # 권한 매트릭스
│   └── screenshots/                   # 시각화 캡처
│       ├── rbac-structure.png
│       ├── network-policies.png
│       └── security-dashboard.png
└── scripts/                           # 배포/관리 스크립트
    ├── setup-rbac.sh                 # RBAC 설정
    ├── apply-security-policies.sh     # 보안 정책 적용
    └── test-permissions.sh            # 권한 테스트
```

---

## 📊 시각화 도구 활용

### 🛠️ 권장 시각화 도구
1. **Kubernetes Dashboard**: RBAC 권한 구조
2. **K9s**: 실시간 보안 이벤트 모니터링
3. **kubectl auth**: 권한 테스트 및 확인
4. **Falco**: 보안 위반 탐지 (선택사항)

### 📸 필수 캡처 항목
- **RBAC 구조**: 역할과 바인딩 관계
- **Network Policy**: 네트워크 격리 상태
- **보안 컨텍스트**: Pod 보안 설정
- **권한 테스트**: 각 역할별 접근 권한 확인

---

## 📝 분석 보고서 템플릿

### `docs/security-analysis.md` 구조
```markdown
# 금융 플랫폼 보안 아키텍처 분석 보고서

## 🎯 보안 아키텍처 개요
### 전체 보안 구조
[보안 아키텍처 다이어그램]

### 보안 계층
| 계층 | 보안 요소 | 구현 방식 | 목적 |
|------|-----------|-----------|------|
| 클러스터 | RBAC | Role/RoleBinding | 접근 제어 |
| 네트워크 | Network Policy | Calico/Cilium | 트래픽 제어 |
| Pod | Security Context | runAsNonRoot | 런타임 보안 |
| 데이터 | Secret | 암호화 저장 | 민감정보 보호 |

## 🔐 RBAC 설계 분석

### 1. 역할 정의 전략
**개발자 역할 설계:**
```yaml
# 구현한 Role 예시
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: loan-ns
  name: loan-developer
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps"]
  verbs: ["get", "list", "create", "update", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "create", "update", "delete"]
```

**최소 권한 원칙 적용:**
- 

### 2. 권한 매트릭스 구현
**팀별 권한 분석:**
| 팀 | 자체 네임스페이스 | 타팀 네임스페이스 | 공통 리소스 | 제한사항 |
|----|------------------|-------------------|-------------|----------|
| 대출팀 | 전체 권한 | 읽기 전용 | 모니터링 읽기 | Secret 제한 |
| 카드팀 | 전체 권한 | 읽기 전용 | 모니터링 읽기 | Secret 제한 |
| 투자팀 | 전체 권한 | 없음 | 모니터링 읽기 | Secret 제한 |
| 운영팀 | 읽기 전용 | 읽기 전용 | 전체 권한 | 삭제 제한 |

### 3. ServiceAccount 전략
**팀별 ServiceAccount 분리:**
- 

## 🛡️ 네트워크 보안 분석

### 1. Network Policy 설계
**팀 간 격리 정책:**
```yaml
# 구현한 Network Policy 예시
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: loan-team-isolation
  namespace: loan-ns
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: loan-ns
```

**데이터베이스 접근 제어:**
- 

### 2. 마이크로세그멘테이션
**서비스별 통신 제어:**
- 

## 🔒 Pod 보안 분석

### 1. Security Context 설정
**보안 강화 설정:**
```yaml
# 구현한 Security Context
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 2000
  readOnlyRootFilesystem: true
```

**컨테이너 보안 정책:**
- 

### 2. Pod Security Standards
**Restricted 정책 적용:**
- 

## 📊 보안 위험 분석
### 식별된 위험
1. **높은 위험**: 
2. **중간 위험**: 
3. **낮은 위험**: 

### 위험 완화 방안
#### 즉시 조치 (1주)
- [ ] 
- [ ] 

#### 단기 개선 (1개월)
- [ ] 
- [ ] 

#### 장기 개선 (3개월)
- [ ] 
- [ ] 

## 🔍 보안 모니터링
### 감사 로깅
**중요 이벤트 추적:**
- 

### 보안 메트릭
**모니터링 지표:**
- 

## 📊 시각화 결과 분석
### RBAC 구조
![권한 구조](screenshots/rbac-structure.png)
**분석**: 

### 네트워크 정책
![네트워크 보안](screenshots/network-policies.png)
**분석**: 

### 보안 대시보드
![보안 현황](screenshots/security-dashboard.png)
**분석**: 

## 🎓 학습 인사이트
### RBAC 설계 학습 포인트
- 

### 네트워크 보안 학습 포인트
- 

### 실무 보안 고려사항
- 

## 🚀 보안 로드맵
### 단계별 보안 강화 계획
1. **Phase 1**: 기본 RBAC 및 Network Policy
2. **Phase 2**: 고급 보안 정책 및 모니터링
3. **Phase 3**: 자동화된 보안 검증 및 대응
```

---

## 📋 제출 방법

### 1. GitHub Repository 생성
- **Repository 이름**: `w3d4-fintech-security-platform`
- **Public Repository**로 설정
- **README.md**에 보안 아키텍처 개요 작성

### 2. Discord 제출
```
📝 제출 형식:
**팀명**: [팀 이름]
**GitHub**: [Repository URL]
**완료 시간**: [HH:MM]
**RBAC 특징**: [권한 설계의 핵심 포인트]
**보안 정책**: [적용한 주요 보안 정책]
**도전 과제**: [가장 복잡했던 보안 설정]
```

---

## ⏰ 진행 일정

### 📅 시간 배분
```
1. 보안 설계 (20분)
   - RBAC 권한 매트릭스 설계
   - Network Policy 전략 수립

2. RBAC 구현 (30분)
   - Role/RoleBinding 생성
   - ServiceAccount 설정
   - 권한 테스트

3. 보안 정책 적용 (25분)
   - Network Policy 구현
   - Security Context 설정
   - Secret 관리

4. 시각화 및 분석 (10분)
   - 보안 구조 캡처
   - 분석 보고서 작성

5. 문서화 및 제출 (5분)
   - GitHub 정리 및 제출
```

---

## 🏆 성공 기준

### ✅ 필수 달성 목표
- [ ] 모든 팀별 RBAC 권한 정상 동작
- [ ] Network Policy로 네임스페이스 격리 확인
- [ ] Security Context 적용된 Pod 실행
- [ ] 권한 테스트 스크립트 동작 확인
- [ ] 보안 분석 보고서 완성

### 🌟 우수 달성 목표
- [ ] 고급 보안 정책 적용 (Pod Security Standards 등)
- [ ] 자동화된 보안 테스트 구현
- [ ] 보안 모니터링 대시보드 구성
- [ ] 상세한 위험 분석 및 대응 방안

---

## 💡 힌트 및 팁

### 🔐 RBAC 팁
- **권한 확인**: `kubectl auth can-i <verb> <resource> --as=<user>`
- **Role 확인**: `kubectl describe role <role-name>`
- **바인딩 확인**: `kubectl get rolebindings -o wide`

### 🛡️ 보안 정책 팁
- **Network Policy 테스트**: `kubectl exec -it pod -- nc -zv service-name port`
- **Security Context 확인**: `kubectl describe pod`에서 Security Context 섹션
- **Secret 확인**: `kubectl get secrets -o yaml`

---

<div align="center">

**🔐 보안 전문성** • **👥 권한 관리** • **🛡️ 위험 분석** • **📊 보안 시각화**

*금융급 보안 요구사항을 만족하는 Kubernetes 보안 아키텍처 구현*

</div>
