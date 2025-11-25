# November Week 4 Day 2 라이브 Demo 가이드

<div align="center">

**🎬 워크로드 배포 및 스케일링** • **⏱️ 60분** • **💰 $0.25/hour**

*Deployment, StatefulSet, Auto Scaling 실시간 시연*

</div>

---

## 🕘 Demo 정보
**시간**: 12:00-13:00 (60분)
**목표**: EKS에서 애플리케이션 배포, 스토리지 연결, 자동 스케일링 라이브 시연
**방식**: 강사 화면 공유 + 실시간 실행 + 학생 관찰

---

## 🎯 Demo 목표

### 📚 학생 학습 목표
- **Deployment 배포**: Rolling Update 전략 실시간 관찰
- **PersistentVolume**: EBS 볼륨 연결 및 데이터 영속성 확인
- **Auto Scaling**: HPA로 Pod 자동 증가 과정 확인
- **실무 운영**: 실제 운영 환경 시나리오 학습

### 🎬 강사 시연 목표
- **안정적 시연**: 사전 검증된 명령어로 오류 없는 데모
- **단계별 설명**: 각 단계마다 상세한 설명 제공
- **실무 팁 공유**: 운영 환경 노하우 전달
- **즉각 대응**: 실시간 질문에 답변

---

## 📋 사전 준비 (Demo 30분 전)

### ✅ 1. 클러스터 확인
```bash
# Day 1 클러스터가 있으면 재사용, 없으면 새로 생성
kubectl get nodes

# 없으면 Day 1 스크립트로 생성
cd ../day1/demo_scripts
./setup-eks-cluster.sh
```

### ✅ 2. 필요한 도구 확인
```bash
# kubectl 확인
kubectl version --client

# AWS CLI 확인
aws --version

# 클러스터 연결 확인
kubectl cluster-info
```

### ✅ 3. 화면 공유 설정
- 터미널 폰트 크기: 18pt 이상
- 불필요한 창 모두 닫기
- 알림 끄기

---

## 🎬 Demo 타임라인 (60분)

### 📍 1단계: 소개 및 개요 (5분) - 12:00-12:05


```
"안녕하세요! 오늘은 EKS에서 실제 워크로드를 배포하고 
관리하는 방법을 실시간으로 보여드리겠습니다.

오늘 시연 내용:
1. Deployment 생성 및 Rolling Update
2. PersistentVolume으로 데이터 영속성 확보
3. HPA로 자동 스케일링 설정
4. 부하 테스트로 자동 증가 확인

예상 비용: 시간당 약 $0.25 (EBS 볼륨 추가)"
```

---

### 📍 2단계: Deployment 배포 (15분) - 12:05-12:20


```
"먼저 Nginx Deployment를 배포하고 Rolling Update를 
실시간으로 확인해보겠습니다."
```

**2-1. Deployment 생성 (5분)**:
```bash
# Deployment YAML 생성
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-app
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
EOF


"Deployment를 생성했습니다.
- replicas: 3 → 3개의 Pod 생성
- image: nginx:1.21 → 특정 버전 지정
- resources: CPU/메모리 요청 및 제한 설정"

# Pod 생성 확인
kubectl get pods -l app=nginx -w


"3개의 Pod가 생성되고 있습니다.
각 Pod는 서로 다른 Node에 분산 배치됩니다."
```

**2-2. Service 생성 (3분)**:
```bash
# LoadBalancer Service 생성
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
EOF


"LoadBalancer Service를 생성했습니다.
AWS가 자동으로 ELB를 프로비저닝합니다."

# ELB 주소 확인 (2-3분 대기)
kubectl get service nginx-service -w

# ELB 주소 저장
NGINX_LB=$(kubectl get service nginx-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Nginx URL: http://$NGINX_LB"

# 브라우저에서 접근 확인
curl http://$NGINX_LB


"Nginx 기본 페이지가 표시됩니다!"
```

**2-3. Rolling Update 실행 (7분)**:
```bash

"이제 Rolling Update를 실행하겠습니다.
nginx:1.21 → nginx:1.22로 업그레이드합니다.
무중단으로 진행되는 과정을 확인하세요."

# 새 터미널에서 지속적으로 접근 테스트
while true; do curl -s http://$NGINX_LB | grep -o "nginx/[0-9.]*"; sleep 1; done

# 원래 터미널에서 Rolling Update 실행
kubectl set image deployment/nginx-app nginx=nginx:1.22


"Rolling Update가 시작되었습니다.
기본 전략은 25% maxUnavailable, 25% maxSurge입니다."

# 실시간 업데이트 과정 확인
kubectl rollout status deployment/nginx-app


"Pod가 하나씩 교체되고 있습니다.
- 새 Pod 생성 → Ready 확인 → 기존 Pod 종료
- 서비스 중단 없이 진행됩니다!"

# 업데이트 완료 확인
kubectl get pods -l app=nginx


"모든 Pod가 nginx:1.22로 업데이트되었습니다.
서비스는 계속 정상 동작했습니다!"

# 접근 테스트 중지 (Ctrl+C)
```

---

### 📍 3단계: PersistentVolume 사용 (15분) - 12:20-12:35


```
"이제 EBS 볼륨을 사용하여 데이터를 영속적으로 
저장하는 방법을 보여드리겠습니다."
```

**3-1. EBS CSI Driver 설치 (5분)**:
```bash

"먼저 EBS CSI Driver를 설치해야 합니다.
이것이 있어야 EBS 볼륨을 동적으로 프로비저닝할 수 있습니다."

# IAM Policy 생성 (이미 있으면 스킵)
aws iam create-policy \
  --policy-name AmazonEKS_EBS_CSI_Driver_Policy \
  --policy-document file://ebs-csi-policy.json

# IAM Role 생성 및 연결
eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster demo-eks-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve

# EBS CSI Driver 설치
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.25"


"EBS CSI Driver가 설치되었습니다.
이제 PersistentVolumeClaim을 생성할 수 있습니다."

# 설치 확인
kubectl get pods -n kube-system -l app=ebs-csi-controller
```

**3-2. PVC 생성 및 Pod 연결 (5분)**:
```bash
# StorageClass 확인
kubectl get storageclass


"gp2 StorageClass가 기본으로 제공됩니다.
이것을 사용하여 EBS 볼륨을 생성합니다."

# PVC 생성
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ebs-claim
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: gp2
  resources:
    requests:
      storage: 4Gi
EOF


"PVC를 생성했습니다.
- accessModes: ReadWriteOnce → 단일 Node에서만 마운트
- storage: 4Gi → 4GB EBS 볼륨"

# PVC 상태 확인
kubectl get pvc ebs-claim


"STATUS가 Bound가 되면 EBS 볼륨이 생성된 것입니다!"

# Pod에 PVC 연결
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: app-with-storage
spec:
  containers:
  - name: app
    image: nginx:alpine
    volumeMounts:
    - name: persistent-storage
      mountPath: /data
  volumes:
  - name: persistent-storage
    persistentVolumeClaim:
      claimName: ebs-claim
EOF


"Pod에 PVC를 연결했습니다.
/data 디렉토리가 EBS 볼륨에 마운트됩니다."

# Pod 상태 확인
kubectl get pod app-with-storage
```

**3-3. 데이터 영속성 확인 (5분)**:
```bash

"이제 데이터를 저장하고 Pod를 삭제한 후 
데이터가 유지되는지 확인하겠습니다."

# Pod에 데이터 저장
kubectl exec app-with-storage -- sh -c "echo 'Hello EBS!' > /data/test.txt"
kubectl exec app-with-storage -- cat /data/test.txt


"데이터를 저장했습니다: Hello EBS!"

# Pod 삭제
kubectl delete pod app-with-storage


"Pod를 삭제했습니다. 하지만 PVC는 유지됩니다."

# 같은 PVC로 새 Pod 생성
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: app-with-storage-2
spec:
  containers:
  - name: app
    image: nginx:alpine
    volumeMounts:
    - name: persistent-storage
      mountPath: /data
  volumes:
  - name: persistent-storage
    persistentVolumeClaim:
      claimName: ebs-claim
EOF

# 데이터 확인
kubectl exec app-with-storage-2 -- cat /data/test.txt


"데이터가 그대로 유지되었습니다!
EBS 볼륨에 저장되어 Pod가 삭제되어도 데이터는 보존됩니다."
```

---

### 📍 4단계: Auto Scaling 설정 (15분) - 12:35-12:50


```
"이제 HPA를 설정하여 부하에 따라 Pod가 
자동으로 증가하는 것을 확인하겠습니다."
```

**4-1. Metrics Server 설치 (3분)**:
```bash

"HPA가 작동하려면 Metrics Server가 필요합니다.
이것이 CPU/메모리 사용률을 수집합니다."

# Metrics Server 설치
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# 설치 확인
kubectl get deployment metrics-server -n kube-system


"Metrics Server가 설치되었습니다.
잠시 후 메트릭을 수집하기 시작합니다."

# 메트릭 확인 (1-2분 대기)
kubectl top nodes
kubectl top pods
```

**4-2. HPA 생성 (2분)**:
```bash

"이제 HPA를 생성하겠습니다.
CPU 사용률이 50%를 넘으면 Pod를 자동으로 증가시킵니다."

# HPA 생성
kubectl autoscale deployment nginx-app \
  --cpu-percent=50 \
  --min=3 \
  --max=10


"HPA를 생성했습니다.
- cpu-percent: 50% → CPU 사용률 목표
- min: 3 → 최소 Pod 수
- max: 10 → 최대 Pod 수"

# HPA 확인
kubectl get hpa nginx-app
```

**4-3. 부하 테스트 (10분)**:
```bash

"이제 부하를 발생시켜 HPA가 작동하는 것을 확인하겠습니다."

# 부하 생성 Pod 실행
kubectl run load-generator \
  --image=busybox \
  --restart=Never \
  -- /bin/sh -c "while true; do wget -q -O- http://nginx-service; done"


"부하 생성 Pod가 nginx-service에 지속적으로 요청을 보냅니다."

# 실시간 HPA 상태 확인
kubectl get hpa nginx-app -w


"CPU 사용률이 증가하고 있습니다!
- TARGETS: 현재 CPU 사용률 / 목표 CPU 사용률
- REPLICAS: 현재 Pod 수"

# 실시간 Pod 상태 확인 (새 터미널)
watch kubectl get pods -l app=nginx


"Pod가 자동으로 증가하고 있습니다!
HPA가 부하를 감지하고 Pod를 추가했습니다."

# 약 5분 대기 후 부하 중지
kubectl delete pod load-generator


"부하를 중지했습니다.
잠시 후 Pod 수가 다시 줄어듭니다."

# Scale down 확인
kubectl get hpa nginx-app -w


"CPU 사용률이 감소하면서 Pod 수도 줄어듭니다.
기본적으로 5분 후 scale down이 시작됩니다."
```

---

### 📍 5단계: 리소스 정리 (5분) - 12:50-12:55


```
"데모가 완료되었습니다!
이제 생성한 리소스를 정리하겠습니다."
```

```bash
# HPA 삭제
kubectl delete hpa nginx-app

# Deployment 삭제
kubectl delete deployment nginx-app

# Service 삭제
kubectl delete service nginx-service

# PVC 및 Pod 삭제
kubectl delete pod app-with-storage-2
kubectl delete pvc ebs-claim


"모든 리소스를 삭제했습니다.
EBS 볼륨도 자동으로 삭제됩니다."

# 정리 확인
kubectl get all
kubectl get pvc
```

---

### 📍 6단계: 마무리 및 Q&A (5분) - 12:55-13:00


```
"오늘 데모를 정리하겠습니다.

우리가 본 것:
1. Deployment 생성 및 Rolling Update (무중단 배포)
2. PersistentVolume으로 데이터 영속성 확보
3. HPA로 자동 스케일링 (부하에 따라 Pod 증가)

실무 팁:
- Rolling Update 전략은 maxUnavailable, maxSurge로 조절
- PVC는 삭제해도 데이터 보존 (reclaimPolicy 확인)
- HPA는 적절한 리소스 요청/제한 설정 필수
- Cluster Autoscaler와 함께 사용하면 Node도 자동 증가

질문 있으신가요?"
```

---

## 💡 트러블슈팅 가이드

### 문제 1: Metrics Server 설치 실패
**증상**: `kubectl top nodes` 실패

**해결**:
```bash
# Metrics Server 로그 확인
kubectl logs -n kube-system deployment/metrics-server

# TLS 인증서 문제면 --kubelet-insecure-tls 추가
kubectl patch deployment metrics-server -n kube-system \
  --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
```

### 문제 2: PVC Pending 상태
**증상**: PVC가 계속 Pending

**해결**:
```bash
# PVC 이벤트 확인
kubectl describe pvc ebs-claim

# EBS CSI Driver 확인
kubectl get pods -n kube-system -l app=ebs-csi-controller

# StorageClass 확인
kubectl get storageclass
```

### 문제 3: HPA 작동 안 함
**증상**: HPA TARGETS가 `<unknown>`

**해결**:
```bash
# Metrics Server 확인
kubectl top pods

# Pod에 리소스 요청 설정 확인
kubectl describe deployment nginx-app | grep -A 5 "Limits\|Requests"
```

---

## 📊 비용 정보

### 예상 비용 (ap-northeast-2)
| 리소스 | 수량 | 시간당 비용 | 1시간 비용 |
|--------|------|-------------|-----------|
| EKS Control Plane | 1 | $0.10 | $0.10 |
| EC2 t3.medium | 2 | $0.0416 | $0.08 |
| NAT Gateway | 1 | $0.045 | $0.045 |
| EBS gp2 (4GB) | 1 | $0.0001/GB | $0.0004 |
| ELB | 1 | $0.025 | $0.025 |
| **합계** | | | **$0.25** |

---

<div align="center">

**🎬 라이브 데모 완료** • **📦 워크로드 관리** • **📈 자동 스케일링**

*실전 운영 감각 완전 습득*

</div>
