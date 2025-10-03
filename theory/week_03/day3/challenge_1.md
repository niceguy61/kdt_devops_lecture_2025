# Week 3 Day 3 Challenge 1: 네트워크 장애 해결

<div align="center">

**🚨 네트워크 장애 대응** • **🔍 문제 진단** • **🛠️ 해결 능력**

*실제 운영 환경에서 발생하는 네트워킹과 스토리지 문제 해결 시나리오*

</div>

---

## 🕘 Challenge 정보
**시간**: 14:30-16:00 (90분)  
**목표**: 실무에서 발생하는 네트워크 및 스토리지 장애 해결 능력 향상  
**방식**: 문제 상황 배포 → 진단 → 해결 → 검증

## 🎯 Challenge 목표

### 📚 학습 목표
- **문제 진단**: 네트워크와 스토리지 장애의 체계적 진단 방법
- **해결 능력**: kubectl과 디버깅 도구를 활용한 문제 해결
- **예방 대책**: 장애 재발 방지를 위한 모니터링과 정책 수립
- **팀워크**: 복잡한 문제를 팀원과 협력하여 해결

### 🛠️ 실무 역량
- **장애 대응**: 신속하고 정확한 장애 진단 및 복구
- **근본 원인 분석**: 표면적 증상이 아닌 근본 원인 파악
- **문서화**: 장애 해결 과정과 예방책 문서화
- **커뮤니케이션**: 장애 상황을 명확하게 소통하고 협업

---

## 🚨 Challenge 시나리오: "E-Shop 긴급 장애 상황"

### 📖 배경 상황
**시나리오**: 
온라인 쇼핑몰 "E-Shop"이 Black Friday 세일을 준비하던 중 여러 시스템 장애가 동시에 발생했습니다. 
DevOps 엔지니어로서 신속하게 문제를 진단하고 해결해야 합니다.

**긴급도**: 🔴 **Critical** - 서비스 완전 중단 상태
**영향도**: 💰 **High** - 매출 손실 및 고객 불만 급증
**제한시간**: ⏰ **90분** - 세일 시작 전까지 복구 필수

---

## 🔧 Challenge 환경 배포

### 환경 설정

**🚀 Challenge 환경 배포**
```bash
cd theory/week_03/day3/lab_scripts/challenge1
./deploy-broken-system.sh
```

**📋 스크립트 내용**: [deploy-broken-system.sh](./lab_scripts/challenge1/deploy-broken-system.sh)

---

## 🚨 문제 상황 1: DNS 해결 실패 (25분)

### 증상
- 프론트엔드에서 백엔드 API 호출 실패
- "Name resolution failed" 오류 발생
- 사용자가 상품 목록을 볼 수 없음

### 🔍 진단 과정

**1단계: 현상 확인**
```bash
# 전체 Pod 상태 확인
kubectl get pods -n eshop-broken

# 프론트엔드 로그 확인
kubectl logs deployment/frontend -n eshop-broken

# 서비스 상태 확인
kubectl get svc -n eshop-broken
```

**2단계: 네트워크 연결 테스트**
```bash
# 프론트엔드에서 백엔드 연결 테스트
kubectl exec -it deployment/frontend -n eshop-broken -- nslookup backend-service

# DNS 해결 테스트
kubectl exec -it deployment/frontend -n eshop-broken -- nslookup backend-service.eshop-broken.svc.cluster.local
```

**3단계: 서비스 설정 검사**
```bash
# 서비스 상세 정보 확인
kubectl describe svc backend-service -n eshop-broken

# Endpoint 확인
kubectl get endpoints backend-service -n eshop-broken
```

### 💡 힌트
- 서비스 이름이 올바른지 확인하세요
- 네임스페이스가 일치하는지 점검하세요
- 라벨 셀렉터가 Pod 라벨과 매치되는지 확인하세요

**문제 파일**: [broken-backend-service.yaml](./lab_scripts/challenge1/broken-backend-service.yaml)

---

## 🚨 문제 상황 2: Ingress 라우팅 오류 (25분)

### 증상
- 외부에서 웹사이트 접근 시 404 오류
- shop.local 도메인으로 접근 불가
- Ingress Controller는 정상 동작

### 🔍 진단 과정

**1단계: Ingress 상태 확인**
```bash
# Ingress 리소스 확인
kubectl get ingress -n eshop-broken

# Ingress 상세 정보
kubectl describe ingress shop-ingress -n eshop-broken

# Ingress Controller 로그 확인
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

**2단계: 백엔드 서비스 연결 확인**
```bash
# Ingress가 참조하는 서비스 확인
kubectl get svc frontend-service -n eshop-broken

# 서비스 Endpoint 확인
kubectl get endpoints frontend-service -n eshop-broken
```

**3단계: 라우팅 규칙 검증**
```bash
# Ingress 규칙 상세 분석
kubectl get ingress shop-ingress -n eshop-broken -o yaml

# 호스트 및 경로 설정 확인
curl -H "Host: shop.local" http://localhost/
```

### 💡 힌트
- Ingress 규칙의 서비스 이름이 정확한지 확인하세요
- 포트 번호가 서비스 포트와 일치하는지 점검하세요
- 호스트 헤더 설정이 올바른지 확인하세요

**문제 파일**: [broken-ingress.yaml](./lab_scripts/challenge1/broken-ingress.yaml)

---

## 🚨 문제 상황 3: PVC 바인딩 실패 (20분)

### 증상
- 데이터베이스 Pod가 Pending 상태
- "pod has unbound immediate PersistentVolumeClaims" 오류
- 데이터 저장 및 조회 불가

### 🔍 진단 과정

**1단계: PVC 상태 확인**
```bash
# PVC 상태 조회
kubectl get pvc -n eshop-broken

# PVC 상세 정보
kubectl describe pvc database-storage -n eshop-broken

# PV 가용성 확인
kubectl get pv
```

**2단계: StorageClass 검증**
```bash
# StorageClass 확인
kubectl get storageclass

# 기본 StorageClass 확인
kubectl get storageclass -o jsonpath='{.items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")].metadata.name}'
```

**3단계: 볼륨 프로비저닝 로그**
```bash
# 시스템 이벤트 확인
kubectl get events -n eshop-broken --sort-by='.lastTimestamp'

# Pod 이벤트 확인
kubectl describe pod -l app=database -n eshop-broken
```

### 💡 힌트
- 요청한 스토리지 크기가 적절한지 확인하세요
- StorageClass가 존재하고 사용 가능한지 점검하세요
- 액세스 모드가 올바른지 확인하세요

**문제 파일**: [broken-database-pvc.yaml](./lab_scripts/challenge1/broken-database-pvc.yaml)

---

## 🚨 문제 상황 4: 네트워크 정책 차단 (20분)

### 증상
- 백엔드에서 데이터베이스 연결 실패
- "Connection timed out" 오류
- 네트워크 정책 적용 후 발생

### 🔍 진단 과정

**1단계: 네트워크 정책 확인**
```bash
# 적용된 네트워크 정책 조회
kubectl get networkpolicy -n eshop-broken

# 네트워크 정책 상세 정보
kubectl describe networkpolicy database-policy -n eshop-broken
```

**2단계: Pod 라벨 검증**
```bash
# 데이터베이스 Pod 라벨 확인
kubectl get pods -l app=database -n eshop-broken --show-labels

# 백엔드 Pod 라벨 확인
kubectl get pods -l app=backend -n eshop-broken --show-labels
```

**3단계: 연결 테스트**
```bash
# 백엔드에서 데이터베이스 연결 테스트
kubectl exec -it deployment/backend -n eshop-broken -- nc -zv database-service 5432

# 네트워크 정책 없이 테스트 (임시)
kubectl delete networkpolicy database-policy -n eshop-broken
kubectl exec -it deployment/backend -n eshop-broken -- nc -zv database-service 5432
```

### 💡 힌트
- 네트워크 정책의 라벨 셀렉터가 정확한지 확인하세요
- Ingress 규칙이 필요한 트래픽을 허용하는지 점검하세요
- Pod 라벨이 정책과 일치하는지 확인하세요

**문제 파일**: [broken-network-policy.yaml](./lab_scripts/challenge1/broken-network-policy.yaml)

---

## ✅ 해결 검증

### 최종 확인 스크립트

**🚀 전체 시스템 검증**
```bash
cd theory/week_03/day3/lab_scripts/challenge1
./verify-solutions.sh
```

**📋 스크립트 내용**: [verify-solutions.sh](./lab_scripts/challenge1/verify-solutions.sh)

### 수동 검증 체크리스트

**✅ DNS 해결 확인**
```bash
kubectl exec -it deployment/frontend -n eshop-broken -- nslookup backend-service
```

**✅ Ingress 라우팅 확인**
```bash
curl -H "Host: shop.local" http://localhost/
```

**✅ PVC 바인딩 확인**
```bash
kubectl get pvc -n eshop-broken
kubectl get pods -l app=database -n eshop-broken
```

**✅ 네트워크 연결 확인**
```bash
kubectl exec -it deployment/backend -n eshop-broken -- nc -zv database-service 5432
```

---

## 🎯 성공 기준

### 📊 기능적 요구사항
- [ ] **DNS 해결**: 모든 서비스 간 이름 해결 성공
- [ ] **외부 접근**: shop.local 도메인으로 웹사이트 접근 가능
- [ ] **데이터 저장**: 데이터베이스 Pod 정상 실행 및 PVC 바인딩
- [ ] **네트워크 통신**: 모든 계층 간 필요한 통신 허용

### ⏱️ 성능 요구사항
- [ ] **응답 시간**: 웹페이지 로딩 시간 3초 이내
- [ ] **가용성**: 모든 Pod가 Ready 상태
- [ ] **연결성**: 서비스 간 연결 지연 시간 100ms 이내

### 🔒 보안 요구사항
- [ ] **네트워크 격리**: 불필요한 트래픽 차단
- [ ] **최소 권한**: 필요한 통신만 허용
- [ ] **데이터 보호**: 데이터베이스 접근 제어

---

## 🏆 도전 과제 (보너스)

### 고급 문제 해결 (+20점)
1. **성능 최적화**: 응답 시간을 1초 이내로 단축
2. **모니터링 구축**: Prometheus + Grafana로 실시간 모니터링
3. **자동 복구**: 장애 자동 감지 및 복구 시스템 구축
4. **백업 전략**: 데이터베이스 자동 백업 및 복원 테스트

### 창의적 해결책 (+10점)
1. **예방 시스템**: 유사 장애 예방을 위한 정책 수립
2. **알림 시스템**: Slack/Teams 연동 장애 알림
3. **문서화**: 장애 대응 플레이북 작성
4. **교육 자료**: 팀원 교육용 장애 시나리오 제작

---

## 💡 문제 해결 가이드

### 🔍 체계적 진단 방법
1. **증상 파악**: 사용자 관점에서 문제 현상 확인
2. **로그 분석**: Pod, 서비스, Ingress 로그 순차 확인
3. **설정 검증**: YAML 파일의 오타나 설정 오류 점검
4. **연결 테스트**: 네트워크 연결성 단계별 확인
5. **근본 원인**: 표면적 증상이 아닌 실제 원인 파악

### 🛠️ 유용한 디버깅 명령어
```bash
# 전체 상태 한눈에 보기
kubectl get all -n eshop-broken

# 이벤트 시간순 정렬
kubectl get events -n eshop-broken --sort-by='.lastTimestamp'

# 리소스 상세 정보
kubectl describe <resource-type> <resource-name> -n eshop-broken

# 실시간 로그 모니터링
kubectl logs -f deployment/<deployment-name> -n eshop-broken

# 네트워크 연결 테스트
kubectl exec -it <pod-name> -n eshop-broken -- <command>
```

---

## 🤝 팀워크 가이드

### 👥 역할 분담 제안
- **진단 전문가**: 로그 분석과 문제 원인 파악
- **네트워크 엔지니어**: 서비스, Ingress, DNS 문제 해결
- **스토리지 관리자**: PVC, PV, StorageClass 문제 해결
- **보안 담당자**: Network Policy와 접근 제어 문제 해결

### 🗣️ 소통 방법
- **상황 공유**: 발견한 문제와 해결 진행 상황 실시간 공유
- **지식 교환**: 각자의 전문 영역에서 다른 팀원 지원
- **검증 협력**: 해결책 적용 후 함께 검증 및 테스트
- **문서화**: 해결 과정과 교훈을 팀 차원에서 정리

---

## 🧹 Challenge 정리

### 환경 정리 스크립트

**🚀 자동화 정리**
```bash
cd theory/week_03/day3/lab_scripts/challenge1
./cleanup.sh
```

**수동 정리**
```bash
# 네임스페이스 삭제 (모든 리소스 함께 삭제)
kubectl delete namespace eshop-broken

# hosts 파일 정리 (필요시)
sudo sed -i '/shop.local/d' /etc/hosts
```

---

## 📝 Challenge 회고

### 🤝 팀 회고 (15분)
1. **가장 어려웠던 문제**: 어떤 장애가 가장 진단하기 어려웠나요?
2. **효과적인 디버깅 방법**: 어떤 접근법이 가장 도움이 되었나요?
3. **팀워크 경험**: 협업을 통해 어떤 시너지가 있었나요?
4. **실무 적용**: 실제 운영 환경에서 어떻게 활용하시겠어요?

### 📊 학습 성과
- **문제 진단 능력**: 체계적인 장애 분석 방법론 습득
- **도구 활용**: kubectl과 디버깅 도구 숙련도 향상
- **네트워크 이해**: Kubernetes 네트워킹 심화 이해
- **팀 협업**: 복잡한 문제의 협업 해결 경험

### 🎯 실무 연계
- **장애 대응 매뉴얼**: 체계적인 장애 대응 프로세스 수립
- **모니터링 강화**: 예방적 모니터링 시스템 구축
- **팀 역량 강화**: 장애 대응 팀 훈련 및 역할 정의
- **지속적 개선**: 장애 사례 분석을 통한 시스템 개선

---

<div align="center">

**🚨 장애 대응 완료** • **🔍 진단 능력 향상** • **🛠️ 해결 역량 강화** • **🤝 팀워크 경험**

*실무에서 마주할 네트워크 장애, 이제 자신 있게 해결할 수 있습니다!*

</div>
