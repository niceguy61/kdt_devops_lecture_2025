# Week 3 Day 5 Lab 1 스크립트

## 📋 스크립트 목록

### 🚀 전체 설치
```bash
./00-install-all.sh
```
모든 컴포넌트를 순차적으로 설치합니다. (약 10-15분 소요)

### 📦 개별 설치 스크립트

#### 0. 클러스터 환경 설정 (필수)
```bash
./00-setup-cluster.sh
```
- Kubernetes 클러스터 확인 (없으면 kind 클러스터 생성)
- day5-lab Namespace 생성
- 기본 Namespace 설정

#### 1. Helm 설치
```bash
./01-install-helm.sh
```
- Helm 3 설치
- Repository 추가 (prometheus-community, grafana, argo)

#### 2. Prometheus Stack 설치
```bash
./02-install-prometheus.sh
```
- monitoring Namespace 생성
- kube-prometheus-stack 설치
- Prometheus, Grafana, AlertManager 포함

#### 3. 테스트 애플리케이션 배포
```bash
./03-deploy-app.sh
```
- Nginx 기반 웹 애플리케이션
- Service 및 ServiceMonitor 생성

#### 4. Metrics Server 및 HPA 설정
```bash
./04-setup-hpa.sh
```
- Metrics Server 설치
- HPA 생성 (CPU/Memory 기반)

#### 5. ArgoCD 설치
```bash
./05-install-argocd.sh
```
- argocd Namespace 생성
- ArgoCD 설치
- 초기 admin 비밀번호 출력

### 🧹 정리
```bash
./99-cleanup.sh
```
모든 리소스를 삭제하고 클러스터를 정리합니다.

## 🎯 사용 방법

### 전체 설치 (권장)
```bash
# 모든 컴포넌트 한 번에 설치 (환경 설정 포함)
./00-install-all.sh
```

### 단계별 설치
```bash
# 0단계: 환경 설정 (필수)
./00-setup-cluster.sh

# 1단계씩 실행
./01-install-helm.sh
./02-install-prometheus.sh
./03-deploy-app.sh
./04-setup-hpa.sh
./05-install-argocd.sh
```

### 정리
```bash
# 모든 리소스 삭제
./99-cleanup.sh
```

## 📊 설치 후 접속 정보

### Prometheus
```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
```
- URL: http://localhost:9090

### Grafana
```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```
- URL: http://localhost:3000
- Username: admin
- Password: admin123

### ArgoCD
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
- URL: https://localhost:8080
- Username: admin
- Password: (스크립트 실행 시 출력됨)

## 🔍 상태 확인

### 전체 리소스 확인
```bash
# day5-lab Namespace
kubectl get all -n day5-lab
kubectl get hpa -n day5-lab

# Monitoring Namespace
kubectl get all -n monitoring

# ArgoCD Namespace
kubectl get all -n argocd
```

### HPA 모니터링
```bash
# HPA 상태 실시간 확인
watch kubectl get hpa -n day5-lab web-app-hpa

# Pod 개수 변화 확인
watch kubectl get pods -n day5-lab -l app=web-app
```

## 🧪 부하 테스트

### 부하 생성
```bash
kubectl run -n day5-lab load-generator --image=busybox --restart=Never -- /bin/sh -c \
  "while true; do wget -q -O- http://web-app; done"
```

### 부하 중지
```bash
kubectl delete pod -n day5-lab load-generator
```

## ⚠️ 주의사항

1. **Kubernetes 클러스터 필요**: 로컬 클러스터 (kind, minikube) 또는 클라우드 클러스터
2. **kubectl 설정**: 클러스터에 접근 가능한 kubeconfig 필요
3. **리소스 요구사항**: 최소 4GB RAM, 2 CPU 권장
4. **네트워크**: 인터넷 연결 필요 (이미지 다운로드)

## 🐛 문제 해결

### Metrics Server 메트릭 수집 실패
```bash
# Metrics Server 로그 확인
kubectl logs -n kube-system deployment/metrics-server

# 재시작
kubectl rollout restart deployment metrics-server -n kube-system
```

### Prometheus Pod 시작 실패
```bash
# Pod 상태 확인
kubectl get pods -n monitoring

# 로그 확인
kubectl logs -n monitoring prometheus-prometheus-kube-prometheus-prometheus-0
```

### ArgoCD 접속 불가
```bash
# Pod 상태 확인
kubectl get pods -n argocd

# 서비스 확인
kubectl get svc -n argocd

# 포트포워딩 재시작
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

## 📚 참고 자료

- [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator)
- [Grafana](https://grafana.com/docs/)
- [ArgoCD](https://argo-cd.readthedocs.io/)
- [Kubernetes HPA](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
