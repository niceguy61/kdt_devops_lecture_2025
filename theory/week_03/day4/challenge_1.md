# Week 3 Day 4 Challenge 1: 보안 침해 대응

<div align="center">

**🚨 보안 장애 대응** • **🔍 권한 문제 진단** • **🛠️ 보안 복구**

*실제 운영 환경에서 발생하는 보안 및 권한 문제 해결 시나리오*

</div>

---

## 🕘 Challenge 정보
**시간**: 14:30-16:00 (90분)  
**목표**: 보안 관련 장애 진단 및 해결 능력 향상  
**방식**: 문제 배포 → 진단 → 해결 → 검증

## 🎯 Challenge 목표

### 📚 학습 목표
- **권한 문제 진단**: RBAC 설정 오류 분석 및 해결
- **인증서 관리**: 만료된 인증서 갱신 및 복구
- **네트워크 보안**: Network Policy 설정 오류 해결
- **Secret 관리**: 노출된 민감 정보 보호

### 🛠️ 실무 역량
- **보안 장애 대응**: 신속한 보안 문제 해결
- **근본 원인 분석**: 보안 취약점의 근본 원인 파악
- **예방 대책**: 재발 방지를 위한 보안 정책 수립
- **팀 협업**: 보안 사고 대응 팀워크

---

## 🚨 Challenge 시나리오: "SecureBank 보안 사고"

### 📖 배경 상황
**시나리오**: 
금융 서비스 "SecureBank"가 새로운 마이크로서비스를 배포한 후 여러 보안 문제가 발견되었습니다.
보안팀으로서 긴급하게 문제를 진단하고 해결해야 합니다.

**긴급도**: 🔴 **Critical** - 보안 감사 실패, 규제 위반 위험
**영향도**: 💰 **Very High** - 금융 데이터 노출 위험, 법적 책임
**제한시간**: ⏰ **90분** - 보안 감사 재검토 전까지 복구 필수

---

## 🔧 Challenge 환경 배포

### 환경 설정

**Step 1: Challenge용 클러스터 생성**
```bash
cd theory/week_03/day4/lab_scripts/challenge1

# Challenge용 Kind 클러스터 생성
./setup-challenge-cluster.sh
```

**Step 2: 문제 시스템 배포**
```bash
# 보안 문제가 있는 SecureBank 시스템 배포
./deploy-broken-system.sh
```

**📋 스크립트 내용**: [deploy-broken-system.sh](./lab_scripts/challenge1/deploy-broken-system.sh)

**🎯 배포 후 상태**: 
- namespace: securebank
- RBAC, 인증서, Network Policy, Secret 관련 문제 포함

---

## 🚨 문제 상황 1: RBAC 권한 오류 (25분)

### 증상
- 개발자가 애플리케이션 배포 시도 시 "forbidden" 오류
- ServiceAccount로 Pod 생성 불가
- 로그 조회 권한 없음

### 🔍 진단 과정

**1단계: 현상 확인**
```bash
# 전체 RBAC 리소스 확인
kubectl get role,rolebinding,clusterrole,clusterrolebinding -n securebank

# ServiceAccount 확인
kubectl get serviceaccount -n securebank

# 권한 테스트
kubectl auth can-i create pods --as=system:serviceaccount:securebank:developer-sa -n securebank
kubectl auth can-i get logs --as=system:serviceaccount:securebank:developer-sa -n securebank
```

**2단계: Role 설정 검사**
```bash
# Role 상세 정보
kubectl describe role developer-role -n securebank

# RoleBinding 확인
kubectl describe rolebinding developer-binding -n securebank

# 권한 목록 확인
kubectl auth can-i --list --as=system:serviceaccount:securebank:developer-sa -n securebank
```

**3단계: 문제 파악**
```bash
# Role의 verbs 확인
kubectl get role developer-role -n securebank -o yaml

# RoleBinding의 subjects 확인
kubectl get rolebinding developer-binding -n securebank -o yaml
```

### 💡 힌트
- Role의 verbs에 필요한 동작이 포함되어 있나요?
- RoleBinding이 올바른 ServiceAccount를 참조하나요?
- 네임스페이스가 일치하나요?

**문제 파일**: [broken-rbac.yaml](./lab_scripts/challenge1/broken-rbac.yaml)

---

## 🚨 문제 상황 2: 인증서 만료 (25분)

### 증상
- kubectl 명령어 실행 시 "certificate has expired" 오류
- API Server 접근 불가
- 일부 노드가 NotReady 상태

### 🔍 진단 과정

**1단계: 인증서 상태 확인**
```bash
# kubeconfig 인증서 확인
kubectl config view --raw

# 인증서 만료일 확인
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -dates

# 모든 인증서 만료일 확인
kubeadm certs check-expiration
```

**2단계: 영향 범위 파악**
```bash
# API Server 로그 확인
kubectl logs -n kube-system kube-apiserver-<node-name>

# Kubelet 상태 확인
systemctl status kubelet
journalctl -u kubelet -n 50
```

**3단계: 인증서 갱신**
```bash
# 인증서 갱신 (마스터 노드에서)
kubeadm certs renew all

# 갱신 확인
kubeadm certs check-expiration

# 컴포넌트 재시작
systemctl restart kubelet
```

### 💡 힌트
- kubeadm certs 명령어로 인증서 관리
- API Server, Controller Manager, Scheduler 재시작 필요
- kubeconfig 파일도 업데이트 필요

**문제 파일**: [expired-certs.md](./lab_scripts/challenge1/expired-certs.md)

---

## 🚨 문제 상황 3: Network Policy 차단 (20분)

### 증상
- 프론트엔드에서 백엔드 API 호출 실패
- 백엔드에서 데이터베이스 연결 불가
- "Connection timed out" 오류

### 🔍 진단 과정

**1단계: Network Policy 확인**
```bash
# 적용된 Network Policy 조회
kubectl get networkpolicy -n securebank

# Network Policy 상세 정보
kubectl describe networkpolicy -n securebank

# Pod 라벨 확인
kubectl get pods -n securebank --show-labels
```

**2단계: 연결 테스트**
```bash
# 프론트엔드에서 백엔드 연결 테스트
kubectl exec -it deployment/frontend -n securebank -- nc -zv backend-service 8080

# 백엔드에서 데이터베이스 연결 테스트
kubectl exec -it deployment/backend -n securebank -- nc -zv database-service 5432

# DNS 해결 테스트
kubectl exec -it deployment/frontend -n securebank -- nslookup backend-service
```

**3단계: 정책 분석**
```bash
# Network Policy YAML 확인
kubectl get networkpolicy -n securebank -o yaml

# Pod Selector 매칭 확인
kubectl get pods -n securebank -l app=backend
kubectl get pods -n securebank -l app=database
```

### 💡 힌트
- Network Policy의 podSelector가 올바른 라벨을 사용하나요?
- Ingress/Egress 규칙이 필요한 포트를 허용하나요?
- DNS 접근을 위한 kube-system 허용이 있나요?

**문제 파일**: [broken-network-policy.yaml](./lab_scripts/challenge1/broken-network-policy.yaml)

---

## 🚨 문제 상황 4: Secret 노출 (20분)

### 증상
- 데이터베이스 비밀번호가 환경변수로 평문 노출
- ConfigMap에 API 키 저장
- Git 저장소에 Secret 파일 커밋

### 🔍 진단 과정

**1단계: Secret 사용 현황 확인**
```bash
# 모든 Secret 조회
kubectl get secrets -n securebank

# Pod의 환경변수 확인
kubectl get pod -n securebank -o yaml | grep -A 10 env:

# ConfigMap 확인
kubectl get configmap -n securebank -o yaml
```

**2단계: 노출된 정보 파악**
```bash
# 환경변수로 노출된 Secret 확인
kubectl exec -it deployment/backend -n securebank -- env | grep -i password

# ConfigMap에 저장된 민감 정보
kubectl describe configmap app-config -n securebank
```

**3단계: Secret 재생성 및 적용**
```bash
# 기존 Secret 삭제
kubectl delete secret database-credentials -n securebank

# 새로운 Secret 생성
kubectl create secret generic database-credentials \
  --from-literal=username=dbuser \
  --from-literal=password=$(openssl rand -base64 32) \
  -n securebank

# Deployment 업데이트 (Secret 참조)
kubectl set env deployment/backend \
  --from=secret/database-credentials \
  -n securebank
```

### 💡 힌트
- 환경변수 대신 Secret을 사용하세요
- ConfigMap은 민감하지 않은 설정만 저장
- Secret은 ETCD 암호화 활성화 필요
- External Secrets Operator 고려

**문제 파일**: [exposed-secrets.yaml](./lab_scripts/challenge1/exposed-secrets.yaml)

---

## ✅ 해결 검증

### 최종 확인 스크립트

**🚀 전체 시스템 검증**
```bash
cd theory/week_03/day4/lab_scripts/challenge1
./verify-solutions.sh
```

**📋 스크립트 내용**: [verify-solutions.sh](./lab_scripts/challenge1/verify-solutions.sh)

### 수동 검증 체크리스트

**✅ RBAC 권한 확인**
```bash
kubectl auth can-i create pods --as=system:serviceaccount:securebank:developer-sa -n securebank
kubectl auth can-i get logs --as=system:serviceaccount:securebank:developer-sa -n securebank
```

**✅ 인증서 유효성 확인**
```bash
kubeadm certs check-expiration
kubectl get nodes
kubectl get pods -n kube-system
```

**✅ 네트워크 연결 확인**
```bash
kubectl exec -it deployment/frontend -n securebank -- nc -zv backend-service 8080
kubectl exec -it deployment/backend -n securebank -- nc -zv database-service 5432
```

**✅ Secret 보안 확인**
```bash
kubectl get pods -n securebank -o yaml | grep -i "password" | grep -v "secretKeyRef"
# 결과가 없어야 함 (평문 노출 없음)
```

---

## 🎯 성공 기준

### 📊 기능적 요구사항
- [ ] **RBAC**: 개발자가 필요한 권한으로 작업 가능
- [ ] **인증서**: 모든 인증서 유효, 클러스터 정상 동작
- [ ] **네트워크**: 모든 서비스 간 통신 정상
- [ ] **Secret**: 민감 정보 안전하게 관리

### ⏱️ 성능 요구사항
- [ ] **API 응답**: kubectl 명령어 정상 실행
- [ ] **서비스 연결**: 서비스 간 연결 지연 100ms 이내
- [ ] **Pod 상태**: 모든 Pod Ready 상태

### 🔒 보안 요구사항
- [ ] **최소 권한**: 필요한 최소한의 권한만 부여
- [ ] **암호화**: Secret이 평문으로 노출되지 않음
- [ ] **네트워크 격리**: 불필요한 통신 차단
- [ ] **감사 로깅**: 보안 관련 작업 로깅

---

## 🏆 도전 과제 (보너스)

### 고급 보안 강화 (+20점)
1. **Pod Security Standards**: Restricted 정책 적용
2. **ETCD 암호화**: Secret 암호화 활성화
3. **Admission Controller**: OPA Gatekeeper 정책 적용
4. **보안 스캔**: Trivy로 취약점 스캔 및 해결

### 창의적 해결책 (+10점)
1. **자동화**: 인증서 자동 갱신 시스템 구축
2. **모니터링**: Falco로 런타임 보안 모니터링
3. **Secret 관리**: Vault 통합
4. **문서화**: 보안 사고 대응 플레이북 작성

---

## 💡 문제 해결 가이드

### 🔍 체계적 진단 방법
1. **증상 파악**: 오류 메시지와 로그 분석
2. **권한 확인**: RBAC 설정 검증
3. **인증서 점검**: 만료일과 유효성 확인
4. **네트워크 테스트**: 연결성 단계별 확인
5. **Secret 감사**: 민감 정보 노출 여부 점검

### 🛠️ 유용한 디버깅 명령어
```bash
# RBAC 디버깅
kubectl auth can-i --list --as=<user>
kubectl describe role,rolebinding -n <namespace>

# 인증서 디버깅
kubeadm certs check-expiration
openssl x509 -in <cert-file> -noout -dates

# 네트워크 디버깅
kubectl exec -it <pod> -- nc -zv <service> <port>
kubectl describe networkpolicy -n <namespace>

# Secret 디버깅
kubectl get pods -o yaml | grep -A 10 env:
kubectl get secret <secret-name> -o yaml
```

---

## 🤝 팀워크 가이드

### 👥 역할 분담 제안
- **RBAC 전문가**: 권한 문제 진단 및 해결
- **인증서 관리자**: 인증서 갱신 및 관리
- **네트워크 엔지니어**: Network Policy 설정
- **보안 담당자**: Secret 관리 및 보안 강화

### 🗣️ 소통 방법
- **상황 공유**: 발견한 보안 문제 즉시 공유
- **우선순위**: 가장 심각한 문제부터 해결
- **검증 협력**: 해결 후 팀원과 함께 검증
- **문서화**: 해결 과정과 예방책 기록

---

## 🧹 Challenge 정리

### 환경 정리 스크립트

**🚀 자동화 정리**
```bash
cd theory/week_03/day4/lab_scripts/challenge1
./cleanup.sh
```

**수동 정리**
```bash
# 네임스페이스 삭제 (모든 리소스 함께 삭제)
kubectl delete namespace securebank

# 인증서 백업 정리 (선택사항)
rm -rf /backup/certs-backup-*
```

---

## 📝 Challenge 회고

### 🤝 팀 회고 (15분)
1. **가장 어려웠던 문제**: 어떤 보안 문제가 가장 진단하기 어려웠나요?
2. **효과적인 방법**: 어떤 디버깅 방법이 가장 도움이 되었나요?
3. **팀워크**: 협업을 통해 어떤 시너지가 있었나요?
4. **실무 적용**: 실제 보안 사고 시 어떻게 대응하시겠어요?

### 📊 학습 성과
- **보안 진단**: 체계적인 보안 문제 분석 능력
- **권한 관리**: RBAC 설정 오류 해결 능력
- **인증서 관리**: 인증서 갱신 및 관리 능력
- **보안 강화**: 프로덕션급 보안 정책 수립

### 🎯 실무 연계
- **보안 사고 대응**: 신속한 보안 장애 복구
- **예방 체계**: 보안 문제 예방 시스템 구축
- **팀 역량**: 보안 대응 팀 훈련 및 역할 정의
- **지속적 개선**: 보안 감사를 통한 시스템 강화

---

### 🆘 힌트가 필요하신가요?

충분히 시도해보셨나요? 로그도 확인해보고, RBAC 설정도 체크해보고, 인증서도 검증해보셨나요?

그래도 정말 막혔다면... 👇

**힌트 파일**: [hints.md](./lab_scripts/challenge1/hints.md)

⚠️ **주의**: 힌트를 보기 전에 최소 20분은 스스로 시도해보세요. 실무에서는 힌트가 없습니다!

---

<div align="center">

**🚨 보안 사고 해결** • **🔍 권한 문제 진단** • **🛠️ 보안 복구** • **🤝 팀 협업**

*실무에서 마주할 보안 문제, 이제 자신 있게 해결할 수 있습니다!*

</div>
