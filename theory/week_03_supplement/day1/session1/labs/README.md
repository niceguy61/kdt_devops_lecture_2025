# Session 1 실습 파일 가이드

## 📁 파일 목록

### 1. 단일 컨테이너 Pod
**파일**: `01-single-container-pod.yaml`
- 가장 기본적인 Pod 형태
- nginx 컨테이너 1개만 포함
- Docker와 비교하며 학습

### 2. 멀티 컨테이너 Pod
**파일**: `02-multi-container-pod.yaml`
- Sidecar 패턴 예제
- nginx (메인) + busybox (로그 뷰어)
- 볼륨 공유 학습

### 3. ReplicaSet
**파일**: `03-replicaset.yaml`
- Pod 복제본 관리
- replicas: 3개
- 자동 복구 메커니즘 학습

### 4. Deployment
**파일**: `04-deployment-v1.yaml`
- 프로덕션 권장 설정
- Rolling Update 전략
- Health Probe 설정 포함

## 🚀 실습 순서

### Step 1: 단일 컨테이너 Pod
```bash
kubectl apply -f 01-single-container-pod.yaml
kubectl get pods
kubectl describe pod single-pod
kubectl delete pod single-pod
```

### Step 2: 멀티 컨테이너 Pod
```bash
kubectl apply -f 02-multi-container-pod.yaml
kubectl get pods
kubectl logs multi-pod -c main-app
kubectl logs multi-pod -c log-viewer
kubectl delete pod multi-pod
```

### Step 3: ReplicaSet
```bash
kubectl apply -f 03-replicaset.yaml
kubectl get rs
kubectl get pods
kubectl delete pod <pod-name>  # 자동 복구 확인
kubectl scale rs web-rs --replicas=5
kubectl delete rs web-rs
```

### Step 4: Deployment
```bash
kubectl apply -f 04-deployment-v1.yaml
kubectl get deployments
kubectl get rs
kubectl get pods
kubectl set image deployment/web-deployment nginx=nginx:1.25
kubectl rollout status deployment/web-deployment
kubectl rollout history deployment/web-deployment
kubectl rollout undo deployment/web-deployment
kubectl delete deployment web-deployment
```

## 💡 팁

- 각 단계마다 `kubectl get all`로 전체 리소스 확인
- `-w` 옵션으로 실시간 변화 관찰 (`kubectl get pods -w`)
- `kubectl describe`로 상세 정보 및 이벤트 확인
