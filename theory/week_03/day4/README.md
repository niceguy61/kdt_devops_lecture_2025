# Week 3 Day 4: 보안 & 클러스터 관리

<div align="center">

**🔐 Kubernetes 보안** • **👥 RBAC 권한 관리** • **🔧 클러스터 유지보수**

*프로덕션 환경을 위한 보안 강화와 안정적인 클러스터 운영*

</div>

---

## 🕘 일일 스케줄

### 📊 시간 배분
```
📚 이론 강의: 2.5시간 (50분×3세션) - 보안 개념과 관리 전략
🛠️ 실습 세션: 2.5시간 (Lab 90분 + Challenge 90분) - 보안 설정과 문제 해결
👥 학생 케어: 개별 맞춤 지원 (필요시)
```

### 🗓️ 상세 스케줄
| 시간 | 구분 | 내용 | 목적 |
|------|------|------|------|
| **09:00-09:50** | 📚 이론 1 | 보안 기초 & 인증 (50분) | 보안 모델과 인증 체계 |
| **09:50-10:00** | ☕ 휴식 | 10분 휴식 | |
| **10:00-10:50** | 📚 이론 2 | 권한 관리 & RBAC (50분) | 세밀한 권한 제어 |
| **10:50-11:00** | ☕ 휴식 | 10분 휴식 | |
| **11:00-11:50** | 📚 이론 3 | 클러스터 유지보수 (50분) | 운영과 관리 전략 |
| **11:50-12:00** | ☕ 휴식 | 10분 휴식 | |
| **12:00-13:30** | 🛠️ 실습 1 | Lab 4: 보안 설정 & 권한 관리 (90분) | 프로덕션급 보안 구성 |
| **13:30-14:30** | 🍽️ 점심 | 점심시간 (60분) | |
| **14:30-16:00** | 🎮 Challenge | Challenge 4: 보안 침해 시나리오 (90분) | 보안 문제 해결 |
| **16:00-18:00** | 👥 케어 | 레벨별 개별 멘토링 | 맞춤형 지원 |

---

## 🎯 Day 4 학습 목표

### 📚 핵심 학습 목표
- **보안 모델 이해**: Kubernetes 4C 보안 모델과 다층 방어 전략
- **인증/인가 체계**: Authentication, Authorization, Admission Control
- **RBAC 마스터**: Role, RoleBinding, ClusterRole, ClusterRoleBinding
- **클러스터 관리**: 업그레이드, 백업/복원, 노드 유지보수

### 🎯 실무 역량 목표
- 프로덕션급 보안 설정 구성 능력
- 사용자/팀별 권한 관리 체계 구축
- 클러스터 무중단 업그레이드 수행
- ETCD 백업/복원을 통한 재해 복구

---

## 📚 이론 세션 구성

### Session 1: 보안 기초 & 인증 (50분)
**🎯 학습 목표**: Kubernetes 보안의 기본 원칙과 인증 체계

**핵심 개념**:
- **4C 보안 모델**: Cloud, Cluster, Container, Code
- **인증 메커니즘**: X.509 인증서, Bearer Token, ServiceAccount
- **TLS 통신**: 모든 컴포넌트 간 암호화 통신
- **인증서 관리**: 인증서 생명주기와 갱신 전략

**🎉 Fun Facts**:
- Kubernetes는 기본적으로 모든 통신을 TLS로 암호화
- 클러스터 내에서만 수십 개의 인증서가 사용됨
- kubeconfig 파일에는 클러스터 접근을 위한 모든 정보가 포함

### Session 2: 권한 관리 & RBAC (50분)
**🎯 학습 목표**: 세밀한 권한 제어와 네트워크 보안

**핵심 개념**:
- **RBAC 구조**: Role, RoleBinding, ClusterRole, ClusterRoleBinding
- **ServiceAccount**: Pod의 신원과 권한
- **Network Policy**: 네트워크 수준 보안 제어
- **Security Context**: 컨테이너 보안 설정

**🎉 Fun Facts**:
- RBAC는 기본적으로 모든 것이 거부(deny-by-default)
- ServiceAccount는 Pod가 API Server와 통신할 때 사용
- Network Policy는 CNI 플러그인이 지원해야 동작

### Session 3: 클러스터 유지보수 (50분)
**🎯 학습 목표**: 프로덕션 클러스터의 안정적 운영

**핵심 개념**:
- **클러스터 업그레이드**: 무중단 업그레이드 전략
- **ETCD 백업/복원**: 클러스터 상태 보호
- **노드 유지보수**: Drain, Cordon, Uncordon
- **트러블슈팅**: 클러스터 문제 진단과 해결

**🎉 Fun Facts**:
- Kubernetes는 3개 버전까지 지원 (N, N-1, N-2)
- ETCD 백업 하나로 전체 클러스터 상태 복구 가능
- 노드 드레인으로 안전한 유지보수 가능

---

## 🛠️ 실습 세션 구성

### Lab 4: 보안 설정 & 권한 관리 (90분)

#### 🎯 실습 목표
**프로덕션급 보안 환경 구축**:
- RBAC 기반 사용자/팀별 권한 관리
- Network Policy로 마이크로세그멘테이션 구현
- Security Context로 컨테이너 보안 강화
- Secret과 ConfigMap을 이용한 민감 정보 관리

#### 📋 실습 구성
1. **RBAC 구성** (30분)
   - 개발자용 Role 생성
   - 운영자용 ClusterRole 생성
   - 사용자별 권한 테스트

2. **Network Policy 구현** (30분)
   - 네임스페이스 간 격리
   - 애플리케이션 간 통신 제어
   - Ingress/Egress 규칙 설정

3. **보안 강화** (30분)
   - Security Context 설정
   - Secret 관리
   - Pod Security Standards 적용

---

### Challenge 4: 보안 침해 시나리오 (90분)

#### 🎮 Challenge 목표
**보안 관련 문제 상황 대응 능력 향상**

#### 🔧 Challenge 시나리오

**시나리오 1: 권한 오류** (25분)
```yaml
# 의도적 오류: 부족한 권한
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get"]  # create 권한 없음
```

**증상**:
- Pod 생성 시 "forbidden" 오류
- 애플리케이션 배포 실패

**시나리오 2: 인증서 만료** (25분)
```bash
# 의도적 오류: 만료된 인증서 사용
# kubelet.conf에 만료된 클라이언트 인증서
```

**증상**:
- kubectl 명령어 실행 불가
- 노드가 NotReady 상태

**시나리오 3: Network Policy 차단** (20분)
```yaml
# 의도적 오류: 과도한 네트워크 제한
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  # 모든 트래픽 차단
```

**증상**:
- 서비스 간 통신 불가
- 외부 접근 차단

**시나리오 4: Secret 노출** (20분)
```yaml
# 의도적 오류: 환경변수로 Secret 노출
env:
- name: DB_PASSWORD
  value: "plaintext-password"  # Secret 사용하지 않음
```

**증상**:
- 민감 정보 노출 위험
- 보안 감사 실패

---

## 📊 학습 성과 측정

### ✅ 이론 이해도 체크
- [ ] 4C 보안 모델 설명 가능
- [ ] RBAC 4가지 리소스 이해
- [ ] 인증서 관리 프로세스 이해
- [ ] 클러스터 업그레이드 절차 숙지

### 🛠️ 실습 완성도 체크
- [ ] RBAC 정책 설계 및 구현
- [ ] Network Policy 작성 및 테스트
- [ ] Security Context 적용
- [ ] ETCD 백업/복원 수행

### 🎮 Challenge 해결 능력
- [ ] 권한 오류 진단 및 해결
- [ ] 인증서 문제 해결
- [ ] 네트워크 정책 디버깅
- [ ] 보안 취약점 발견 및 개선

---

## 🔗 연결성

### 이전 학습과의 연결
- **Day 1**: 클러스터 아키텍처 → 보안 컴포넌트
- **Day 2**: 워크로드 관리 → 보안 설정
- **Day 3**: 네트워킹 → Network Policy

### 다음 학습 준비
- **Day 5**: 모니터링 & 운영 → 보안 모니터링
- **Week 4**: 클라우드 네이티브 → 보안 아키텍처

---

## 📝 일일 마무리

### ✅ 오늘의 성과
- [ ] Kubernetes 보안 모델 완전 이해
- [ ] RBAC 기반 권한 관리 체계 구축
- [ ] 클러스터 유지보수 절차 습득
- [ ] 보안 문제 해결 능력 향상

### 🎯 내일 준비사항
- **예습**: 모니터링과 로깅 개념
- **복습**: RBAC 정책 설계 연습
- **환경**: Prometheus, Grafana 사전 학습

---

<div align="center">

**🔐 보안 강화** • **👥 권한 관리** • **🔧 안정적 운영**

*프로덕션 환경을 위한 완벽한 보안과 관리 체계*

</div>
