# November Week 4 Day 3: Helm & 패키지 관리

<div align="center">

**📦 Helm 마스터** • **📊 모니터링 스택** • **🔒 SSL 자동화**

*Kubernetes 애플리케이션을 패키지로 관리하기*

</div>

---

## 🎯 오늘의 목표

### 전체 학습 목표
- Helm의 필요성과 핵심 개념 완전 이해
- Chart 템플릿 작성 및 고급 기능 활용
- 실무에서 자주 사용하는 Chart 배포 경험
- 프로덕션급 모니터링 및 보안 설정

### 오늘의 성과물
- Helm Chart 구조 이해
- Go Template 문법 습득
- Prometheus + Grafana 배포 지식
- SSL 인증서 자동화 이해

---

## 📊 학습 구조

### 일일 시간표
```
09:00-09:40  Session 1: Helm 기초 (40분)
09:40-10:20  Session 2: Helm Chart 작성 (40분)
10:20-11:00  Session 3: 실무 Helm 활용 (40분)
11:00-12:00  강사 Demo: Helm 전체 스택 배포 (60분)
```

### 학습 방식
- **이론 중심**: Helm 개념과 템플릿 문법 체계적 학습
- **실제 Chart 분석**: 커뮤니티 Chart 구조 분석
- **강사 데모**: 완벽하게 검증된 환경에서 시연
- **비용 절감**: 강사 계정만 사용

---

## 📚 세션별 상세 내용

### Session 1: Helm 기초 (09:00-09:40)

**학습 내용**:
- Helm이 필요한 이유
- Chart 구조와 구성 요소
- Values 파일을 통한 설정 관리
- Release 관리 및 버전 제어

**핵심 개념**:
```
Chart = Kubernetes 리소스 패키지
Release = 배포된 Chart 인스턴스
Values = Chart 설정 값
Template = Go Template 기반 리소스 정의
```

**실습 연계**:
- Chart 구조 이해
- Values 파일 작성
- Release 관리 명령어

**참조**: [Session 1 상세 내용](./session_1.md)

---

### Session 2: Helm Chart 작성 (09:40-10:20)

**학습 내용**:
- Go Template 문법 (조건문, 반복문)
- 헬퍼 함수 작성 (_helpers.tpl)
- Chart 의존성 관리
- Chart Repository 구축

**핵심 개념**:
```
Go Template = 동적 YAML 생성
조건문 = 선택적 리소스 생성
반복문 = 반복 리소스 생성
의존성 = 서브 Chart 관리
```

**실습 연계**:
- 템플릿 작성 및 렌더링
- 조건문/반복문 활용
- 의존성 Chart 추가

**참조**: [Session 2 상세 내용](./session_2.md)

---

### Session 3: 실무 Helm 활용 (10:20-11:00)

**학습 내용**:
- Prometheus Stack 배포
- Ingress Controller 설치
- Cert-Manager SSL 자동화
- 애플리케이션 Chart 작성

**핵심 개념**:
```
Prometheus Stack = 모니터링 통합 솔루션
Ingress Controller = HTTP 라우팅
Cert-Manager = SSL 인증서 자동화
커뮤니티 Chart = 검증된 배포 패턴
```

**실습 연계**:
- 커뮤니티 Chart 활용
- 모니터링 스택 구축
- SSL 인증서 자동 발급

**참조**: [Session 3 상세 내용](./session_3.md)

---

## 🎬 강사 Demo (11:00-12:00)

### Demo: Helm으로 전체 스택 배포

**시연 내용**:

**1. Chart 작성 (15분)**:
```bash
# Chart 생성
helm create myapp

# Chart 구조 설명
tree myapp/

# 템플릿 커스터마이징
# - deployment.yaml
# - service.yaml
# - ingress.yaml
```

**2. Prometheus Stack 설치 (15분)**:
```bash
# Repository 추가
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Values 파일 준비
cat > values-prometheus.yaml <<EOF
prometheus:
  prometheusSpec:
    retention: 30d
    storageSpec:
      volumeClaimTemplate:
        spec:
          resources:
            requests:
              storage: 50Gi

grafana:
  adminPassword: "demo-password"
  ingress:
    enabled: true
    hosts:
      - grafana.demo.com
EOF

# 설치
helm install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring \
  --create-namespace \
  -f values-prometheus.yaml

# 상태 확인
kubectl get pods -n monitoring
helm list -n monitoring
```

**3. 애플리케이션 배포 (15분)**:
```bash
# 의존성 추가
cat >> myapp/Chart.yaml <<EOF
dependencies:
  - name: postgresql
    version: "12.x.x"
    repository: https://charts.bitnami.com/bitnami
EOF

# 의존성 다운로드
helm dependency update ./myapp

# 배포
helm install myapp ./myapp \
  -n production \
  --create-namespace \
  -f values-prod.yaml

# 확인
kubectl get all -n production
```

**4. 업그레이드 & 롤백 (10분)**:
```bash
# 이미지 태그 변경
helm upgrade myapp ./myapp \
  --set image.tag=v2.0.0 \
  -n production

# 롤백
helm rollback myapp 1 -n production

# 이력 확인
helm history myapp -n production
```

**5. Q&A (5분)**:
- 질문 답변
- 트러블슈팅 공유
- 베스트 프랙티스 논의

---

## 🔗 학습 자료

### 📚 공식 문서
- [Helm 공식 문서](https://helm.sh/docs/)
- [Chart 템플릿 가이드](https://helm.sh/docs/chart_template_guide/)
- [Artifact Hub](https://artifacthub.io/)

### 🎯 추천 Chart
- [Prometheus Stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- [Ingress NGINX](https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx)
- [Cert-Manager](https://github.com/cert-manager/cert-manager/tree/master/deploy/charts/cert-manager)

---

## 💡 Day 3 회고

### 🤝 학습 성과
1. **Helm 이해**: 패키지 관리의 필요성과 장점
2. **템플릿 작성**: Go Template 문법 습득
3. **실무 활용**: 커뮤니티 Chart 활용법
4. **통합 배포**: 모니터링 + 애플리케이션 통합

### 📊 다음 학습
**Day 4: CI/CD 파이프라인**
- GitHub Actions 기초
- Docker 이미지 빌드 & 푸시
- Kubernetes 배포 자동화
- Helm을 활용한 자동 배포

---

<div align="center">

**📦 Helm 마스터** • **📊 모니터링 스택** • **🔒 SSL 자동화**

*Day 3 완료! 내일은 CI/CD 파이프라인을 구축합니다*

</div>
