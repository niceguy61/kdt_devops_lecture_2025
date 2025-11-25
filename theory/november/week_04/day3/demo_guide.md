# November Week 4 Day 3: Helm Demo Guide

<div align="center">

**📦 Helm 전체 스택 배포** • **📊 모니터링 구축** • **🔒 SSL 자동화**

*강사용 완벽 검증 데모 가이드*

</div>

---

## 🎯 Demo 개요

### 목표
- Helm Chart 작성부터 배포까지 전 과정 시연
- Prometheus Stack 실제 설치 및 설정
- 애플리케이션 Chart 작성 및 배포
- 업그레이드 및 롤백 시연

### 시간 배분
```
11:00-11:15  Demo 1: Chart 작성 (15분)
11:15-11:30  Demo 2: Prometheus Stack 설치 (15분)
11:30-11:45  Demo 3: 애플리케이션 배포 (15분)
11:45-11:55  Demo 4: 업그레이드 & 롤백 (10분)
11:55-12:00  Q&A (5분)
```

### 사전 준비
- EKS 클러스터 실행 중 (Day 1에서 생성)
- kubectl 설정 완료
- Helm 3.x 설치 완료

---

## 🚀 Demo 1: Chart 작성 (11:00-11:15)

### 목표
- Helm Chart 구조 이해
- 기본 템플릿 커스터마이징
- Values 파일 작성

### 실행 스크립트

```bash
# 1. Chart 생성
cd ~/demo
helm create myapp

# 2. Chart 구조 확인
echo "=== Chart 구조 ==="
tree myapp/

# 출력 설명:
# myapp/
# ├── Chart.yaml          # Chart 메타데이터
# ├── values.yaml         # 기본 설정 값
# ├── charts/             # 의존성 Chart
# ├── templates/          # Kubernetes 리소스 템플릿
# │   ├── deployment.yaml
# │   ├── service.yaml
# │   ├── ingress.yaml
# │   ├── _helpers.tpl    # 헬퍼 함수
# │   └── NOTES.txt       # 설치 후 안내 메시지
# └── .helmignore         # 패키징 제외 파일

# 3. Chart.yaml 확인
echo "=== Chart 메타데이터 ==="
cat myapp/Chart.yaml

# 4. values.yaml 수정
echo "=== Values 파일 커스터마이징 ==="
cat > myapp/values.yaml <<'EOF'
replicaCount: 2

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "1.21"

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: false

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi

autoscaling:
  enabled: false
EOF

# 5. 템플릿 렌더링 테스트
echo "=== 템플릿 렌더링 ==="
helm template myapp ./myapp | head -50

# 6. Chart 검증
echo "=== Chart 검증 ==="
helm lint ./myapp
```

### 설명 포인트
1. **Chart.yaml**: Chart 메타데이터 (이름, 버전, 설명)
2. **values.yaml**: 기본 설정 값 (환경별로 오버라이드 가능)
3. **templates/**: Go Template 기반 Kubernetes 리소스
4. **_helpers.tpl**: 재사용 가능한 템플릿 함수
5. **helm template**: 실제 배포 전 렌더링 결과 확인
6. **helm lint**: Chart 문법 및 구조 검증

---

## 📊 Demo 2: Prometheus Stack 설치 (11:15-11:30)

### 목표
- Helm Repository 추가 및 관리
- 커뮤니티 Chart 활용
- Values 파일로 설정 커스터마이징
- 모니터링 스택 배포

### 실행 스크립트

```bash
# 1. Helm Repository 추가
echo "=== Repository 추가 ==="
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add stable https://charts.helm.sh/stable
helm repo update

# 2. Repository 목록 확인
echo "=== Repository 목록 ==="
helm repo list

# 3. Chart 검색
echo "=== Prometheus Chart 검색 ==="
helm search repo prometheus

# 4. Chart 정보 확인
echo "=== Chart 상세 정보 ==="
helm show chart prometheus-community/kube-prometheus-stack
helm show values prometheus-community/kube-prometheus-stack | head -100

# 5. Values 파일 준비
echo "=== Values 파일 작성 ==="
cat > values-prometheus.yaml <<'EOF'
# Prometheus 설정
prometheus:
  prometheusSpec:
    retention: 30d
    resources:
      requests:
        cpu: 200m
        memory: 512Mi
      limits:
        cpu: 500m
        memory: 1Gi
    storageSpec:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 50Gi

# Grafana 설정
grafana:
  enabled: true
  adminPassword: "demo-password"
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 200m
      memory: 512Mi
  persistence:
    enabled: true
    size: 10Gi

# Alertmanager 설정
alertmanager:
  enabled: true
  alertmanagerSpec:
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 200m
        memory: 256Mi
EOF

# 6. Namespace 생성
echo "=== Namespace 생성 ==="
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# 7. Chart 설치
echo "=== Prometheus Stack 설치 ==="
helm install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f values-prometheus.yaml \
  --wait \
  --timeout 10m

# 8. 설치 확인
echo "=== 설치 상태 확인 ==="
helm list -n monitoring
kubectl get pods -n monitoring
kubectl get svc -n monitoring

# 9. Grafana 접속 정보
echo "=== Grafana 접속 ==="
echo "Username: admin"
echo "Password: demo-password"
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80 &
echo "Grafana URL: http://localhost:3000"
```

### 설명 포인트
1. **Repository 관리**: 커뮤니티 Chart 활용
2. **Chart 검색**: 필요한 Chart 찾기
3. **Values 커스터마이징**: 환경에 맞게 설정 변경
4. **--wait 옵션**: 모든 리소스가 Ready 상태까지 대기
5. **Grafana 대시보드**: 사전 구성된 Kubernetes 모니터링 대시보드

---

## 🚀 Demo 3: 애플리케이션 배포 (11:30-11:45)

### 목표
- Chart 의존성 관리
- 환경별 Values 파일 작성
- 애플리케이션 배포 및 확인

### 실행 스크립트

```bash
# 1. Chart 의존성 추가
echo "=== Chart 의존성 추가 ==="
cat >> myapp/Chart.yaml <<'EOF'

dependencies:
  - name: postgresql
    version: "17.x.x"
    repository: https://charts.bitnami.com/bitnami
    condition: postgresql.enabled
EOF

# 2. Repository 추가
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# 3. 의존성 다운로드
echo "=== 의존성 다운로드 ==="
helm dependency update ./myapp

# 4. 의존성 확인
echo "=== 의존성 확인 ==="
ls -la myapp/charts/

# 5. 프로덕션 Values 파일 작성
echo "=== 프로덕션 Values 작성 ==="
cat > values-prod.yaml <<'EOF'
replicaCount: 3

image:
  repository: nginx
  tag: "1.21"

service:
  type: LoadBalancer
  port: 80

resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi

# PostgreSQL 설정
postgresql:
  enabled: true
  auth:
    username: myapp
    password: myapp-password
    database: myapp
  primary:
    persistence:
      enabled: true
      size: 20Gi
EOF

# 6. Namespace 생성
echo "=== Namespace 생성 ==="
kubectl create namespace production --dry-run=client -o yaml | kubectl apply -f -

# 7. 애플리케이션 배포
echo "=== 애플리케이션 배포 ==="
helm install myapp ./myapp \
  -n production \
  -f values-prod.yaml \
  --wait \
  --timeout 5m

# 8. 배포 확인
echo "=== 배포 상태 확인 ==="
helm list -n production
kubectl get all -n production
kubectl get pvc -n production

# 9. 애플리케이션 접속 테스트
echo "=== 접속 테스트 ==="
kubectl port-forward -n production svc/myapp 8080:80 &
sleep 3
curl http://localhost:8080
```

### 설명 포인트
1. **의존성 관리**: Chart.yaml에 의존성 선언
2. **condition**: 조건부 의존성 활성화
3. **환경별 Values**: 프로덕션 환경 설정
4. **PVC**: PostgreSQL 데이터 영속성
5. **LoadBalancer**: 외부 접근 가능한 서비스

---

## 🔄 Demo 4: 업그레이드 & 롤백 (11:45-11:55)

### 목표
- Chart 업그레이드 시연
- 롤백 기능 시연
- Release 이력 관리

### 실행 스크립트

```bash
# 1. 현재 Release 상태 확인
echo "=== 현재 Release 상태 ==="
helm list -n production
helm status myapp -n production

# 2. 이미지 태그 업그레이드
echo "=== 이미지 업그레이드 (v1.21 -> v1.22) ==="
helm upgrade myapp ./myapp \
  -n production \
  -f values-prod.yaml \
  --set image.tag=1.22 \
  --wait

# 3. 업그레이드 확인
echo "=== 업그레이드 확인 ==="
kubectl get pods -n production -o wide
kubectl describe deployment myapp -n production | grep Image

# 4. Release 이력 확인
echo "=== Release 이력 ==="
helm history myapp -n production

# 5. 레플리카 수 변경
echo "=== 레플리카 수 변경 (3 -> 5) ==="
helm upgrade myapp ./myapp \
  -n production \
  -f values-prod.yaml \
  --set replicaCount=5 \
  --wait

# 6. 변경 확인
echo "=== 레플리카 확인 ==="
kubectl get pods -n production

# 7. 롤백 (이전 버전으로)
echo "=== 롤백 (Revision 2로) ==="
helm rollback myapp 2 -n production --wait

# 8. 롤백 확인
echo "=== 롤백 확인 ==="
kubectl get pods -n production
helm history myapp -n production

# 9. Values 비교
echo "=== Revision 간 Values 비교 ==="
helm get values myapp -n production --revision 2
helm get values myapp -n production --revision 3

# 10. Release 정보 확인
echo "=== Release 상세 정보 ==="
helm get all myapp -n production
```

### 설명 포인트
1. **helm upgrade**: 기존 Release 업데이트
2. **--set**: 명령줄에서 값 오버라이드
3. **helm history**: Release 변경 이력
4. **helm rollback**: 이전 버전으로 복구
5. **Revision**: 각 변경사항이 새로운 Revision 생성

---

## 🧹 Demo 정리 (선택사항)

### 리소스 정리 스크립트

```bash
# 1. 애플리케이션 삭제
echo "=== 애플리케이션 삭제 ==="
helm uninstall myapp -n production

# 2. Prometheus Stack 삭제
echo "=== Prometheus Stack 삭제 ==="
helm uninstall prometheus -n monitoring

# 3. Namespace 삭제
echo "=== Namespace 삭제 ==="
kubectl delete namespace production
kubectl delete namespace monitoring

# 4. PVC 확인 및 삭제
echo "=== PVC 정리 ==="
kubectl get pvc --all-namespaces
# 필요시 수동 삭제

# 5. 포트 포워딩 종료
echo "=== 포트 포워딩 종료 ==="
pkill -f "port-forward"
```

---

## 💡 Q&A 준비 사항

### 예상 질문 및 답변

**Q1: Helm 2와 Helm 3의 차이는?**
- A: Helm 3는 Tiller 제거, 3-way merge, 네임스페이스 지원 강화

**Q2: Chart 버전과 앱 버전의 차이는?**
- A: Chart 버전은 Chart 자체의 버전, 앱 버전은 배포되는 애플리케이션 버전

**Q3: Values 파일 우선순위는?**
- A: 명령줄 --set > -f values.yaml > Chart 기본 values.yaml

**Q4: 프로덕션에서 Helm 사용 시 주의사항은?**
- A: 
  - Values 파일 버전 관리
  - Secret 관리 (Sealed Secrets, External Secrets)
  - Dry-run으로 사전 검증
  - 롤백 계획 수립

**Q5: Chart Repository는 어떻게 구축하나?**
- A: 
  - GitHub Pages
  - ChartMuseum
  - Harbor
  - Artifact Hub

---

## 📊 Demo 체크리스트

### 사전 준비
- [ ] EKS 클러스터 실행 중
- [ ] kubectl 설정 완료
- [ ] Helm 3.x 설치 완료
- [ ] 충분한 클러스터 리소스 (CPU, Memory)

### Demo 1: Chart 작성
- [ ] Chart 생성 및 구조 설명
- [ ] Values 파일 커스터마이징
- [ ] 템플릿 렌더링 테스트
- [ ] Chart 검증

### Demo 2: Prometheus Stack
- [ ] Repository 추가 및 관리
- [ ] Values 파일 작성
- [ ] Chart 설치
- [ ] Grafana 접속 확인

### Demo 3: 애플리케이션 배포
- [ ] 의존성 추가 및 다운로드
- [ ] 프로덕션 Values 작성
- [ ] 애플리케이션 배포
- [ ] 배포 상태 확인

### Demo 4: 업그레이드 & 롤백
- [ ] 이미지 업그레이드
- [ ] 레플리카 수 변경
- [ ] 롤백 시연
- [ ] Release 이력 확인

### 정리
- [ ] 리소스 정리 (선택)
- [ ] Q&A 진행
- [ ] 다음 Day 예고

---

## 🎯 Demo 성공 기준

### 기술적 성공
- [ ] 모든 Chart가 정상 설치됨
- [ ] Prometheus + Grafana 접속 가능
- [ ] 애플리케이션 정상 동작
- [ ] 업그레이드/롤백 성공

### 교육적 성공
- [ ] 학생들이 Helm 필요성 이해
- [ ] Chart 구조 명확히 파악
- [ ] 실무 활용 방법 습득
- [ ] 질문에 대한 명확한 답변

---

<div align="center">

**📦 완벽한 Demo** • **📊 실전 경험** • **🎯 학습 효과**

*학생들이 Helm의 강력함을 체감하는 Demo*

</div>
