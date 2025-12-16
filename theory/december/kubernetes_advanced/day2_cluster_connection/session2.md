# Session 2: 기본 워크로드 배포 (50분)

## 🎯 세션 목표
- Kubernetes 기본 오브젝트 실습
- Pod, Service, Deployment 배포
- 네임스페이스별 워크로드 관리

## ⏰ 시간 배분
- **실습** (40분): Pod, Service, Deployment 배포
- **정리** (10분): 체크포인트 확인

---

## 🛠️ 실습: 기본 워크로드 배포 (40분)

### 1. Pod 배포 및 관리 (10분)

#### 간단한 Pod 생성
```bash
# development 네임스페이스로 전환
kubectl config use-context dev-context

# nginx Pod 생성
kubectl run nginx-pod --image=nginx:1.21 --port=80

# Pod 상태 확인
kubectl get pods -o wide

# Pod 상세 정보
kubectl describe pod nginx-pod

# Pod 로그 확인
kubectl logs nginx-pod
```

#### Pod 네트워킹 테스트
```bash
# Pod IP 확인
POD_IP=$(kubectl get pod nginx-pod -o jsonpath='{.status.podIP}')
echo "Pod IP: $POD_IP"

# 다른 Pod에서 접근 테스트
kubectl run test-client --image=busybox --rm -it --restart=Never \
  -- wget -qO- http://$POD_IP

# DNS 테스트
kubectl run dns-test --image=busybox --rm -it --restart=Never \
  -- nslookup kubernetes.default.svc.cluster.local
```

### 2. Service 생성 및 연결 (10분)

#### ClusterIP Service 생성
```bash
# nginx Pod를 위한 Service 생성
kubectl expose pod nginx-pod --port=80 --target-port=80 --name=nginx-service

# Service 확인
kubectl get services
kubectl describe service nginx-service

# Service 엔드포인트 확인
kubectl get endpoints nginx-service
```

#### Service 접근 테스트
```bash
# Service DNS로 접근 테스트
kubectl run service-test --image=busybox --rm -it --restart=Never \
  -- wget -qO- http://nginx-service.development.svc.cluster.local

# 짧은 DNS 이름으로 접근 (같은 네임스페이스)
kubectl run service-test2 --image=busybox --rm -it --restart=Never \
  -- wget -qO- http://nginx-service
```

### 3. Deployment 배포 및 스케일링 (15분)

#### Deployment 생성
```bash
# staging 네임스페이스로 전환
kubectl config use-context staging-context

# Deployment 생성
kubectl create deployment web-app --image=nginx:1.21 --replicas=3

# Deployment 상태 확인
kubectl get deployments
kubectl get pods -l app=web-app

# ReplicaSet 확인
kubectl get replicasets
```

#### Deployment 관리
```bash
# 스케일링
kubectl scale deployment web-app --replicas=5

# 스케일링 확인
kubectl get pods -l app=web-app -w

# 롤링 업데이트
kubectl set image deployment/web-app nginx=nginx:1.22

# 롤아웃 상태 확인
kubectl rollout status deployment/web-app

# 롤아웃 히스토리
kubectl rollout history deployment/web-app
```

#### LoadBalancer Service 생성
```bash
# Deployment를 위한 LoadBalancer Service
kubectl expose deployment web-app --port=80 --target-port=80 \
  --type=LoadBalancer --name=web-app-lb

# Service 확인 (External IP 할당 대기)
kubectl get services -w

# 외부 접근 테스트 (External IP 할당 후)
EXTERNAL_IP=$(kubectl get service web-app-lb -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl http://$EXTERNAL_IP
```

### 4. 다중 네임스페이스 워크로드 관리 (5분)

#### 각 네임스페이스별 리소스 확인
```bash
# 모든 네임스페이스의 Pod 확인
kubectl get pods --all-namespaces

# 특정 네임스페이스 리소스 확인
kubectl get all -n development
kubectl get all -n staging

# 네임스페이스별 리소스 사용량 비교
kubectl top pods -n development
kubectl top pods -n staging
```

#### 네임스페이스 간 통신 테스트
```bash
# development에서 staging 서비스 접근
kubectl config use-context dev-context
kubectl run cross-ns-test --image=busybox --rm -it --restart=Never \
  -- wget -qO- http://web-app-lb.staging.svc.cluster.local
```

---

## ✅ 체크포인트 (10분)

### 완료 확인 사항
- [ ] development 네임스페이스에 nginx Pod 및 Service 배포
- [ ] staging 네임스페이스에 web-app Deployment 배포
- [ ] LoadBalancer Service로 외부 접근 확인
- [ ] 네임스페이스 간 통신 테스트 성공

### 배포된 리소스 확인
```bash
# 전체 리소스 현황
kubectl get all --all-namespaces | grep -E "(development|staging)"

# 네임스페이스별 상세 확인
kubectl get all -n development
kubectl get all -n staging

# 서비스 엔드포인트 확인
kubectl get endpoints --all-namespaces
```

### 네트워킹 상태 확인
```bash
# 모든 Service 확인
kubectl get services --all-namespaces

# LoadBalancer 외부 IP 확인
kubectl get services -o wide | grep LoadBalancer

# DNS 해석 테스트
kubectl run dns-debug --image=busybox --rm -it --restart=Never \
  -- nslookup web-app-lb.staging.svc.cluster.local
```

---

## 🎯 세션 완료 후 상태

### 배포된 워크로드
```
development 네임스페이스:
├── nginx-pod (Pod)
└── nginx-service (ClusterIP Service)

staging 네임스페이스:
├── web-app (Deployment - 5 replicas)
├── web-app-xxxxx (ReplicaSet)
├── web-app-xxxxx-xxxxx (Pods x5)
└── web-app-lb (LoadBalancer Service)
```

### 네트워킹 구성
- **ClusterIP**: 클러스터 내부 통신
- **LoadBalancer**: 외부 인터넷 접근 (AWS ALB)
- **DNS**: 네임스페이스 간 서비스 디스커버리

---

## 🔄 다음 세션 준비

### Day 3 예습 내용
- Helm 패키지 관리자 개념
- Chart 구조 및 템플릿 시스템
- Values 파일을 통한 설정 관리

### 숙제
1. 배포한 애플리케이션들이 정상 작동하는지 확인
2. kubectl 명령어 치트시트 숙지
3. Kubernetes 오브젝트 간 관계 정리

### 정리 작업 (선택사항)
```bash
# 리소스 정리 (다음 세션에서 사용하지 않을 경우)
kubectl delete all --all -n development
kubectl delete all --all -n staging

# 네임스페이스는 유지 (Day 3에서 사용)
```

---

## 🛠️ 추가: 모니터링 스택 설치 (보너스)

### Prometheus + Grafana 설치
```bash
# Helm 저장소 추가
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Prometheus + Grafana 스택 설치
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.adminPassword=admin123

# 설치 확인
kubectl get pods -n monitoring

# Grafana 접근
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80 &
echo "Grafana: http://localhost:3000 (admin/admin123)"

# Prometheus 접근  
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090 &
echo "Prometheus: http://localhost:9090"
```

### 클러스터 대시보드 확인
```bash
# k9s로 전체 클러스터 상태 확인
k9s

# 리소스 사용량 확인 (Metrics Server 설치 후)
kubectl top nodes
kubectl top pods --all-namespaces

# 모니터링 네임스페이스 확인
kubectl get all -n monitoring
```
