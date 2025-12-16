# Day 2 실습 예제 모음

## 🎯 목적
Day 2 세션에서 사용하는 모든 명령어와 예제를 한 곳에 모아 챌린저들이 쉽게 참조할 수 있도록 합니다.

---

## 📋 Session 1 예제: kubectl 설정 및 관리

### kubeconfig 관리

#### 기본 설정 확인
```bash
# kubeconfig 파일 위치
echo $KUBECONFIG
ls -la ~/.kube/config

# 현재 설정 보기
kubectl config view
kubectl config view --raw  # 민감 정보 포함

# 현재 컨텍스트 정보
kubectl config current-context
kubectl config get-contexts
kubectl config get-clusters
kubectl config get-users
```

#### 컨텍스트 관리
```bash
# 새 컨텍스트 생성
kubectl config set-context CONTEXT_NAME \
  --cluster=CLUSTER_NAME \
  --user=USER_NAME \
  --namespace=NAMESPACE_NAME

# 컨텍스트 전환
kubectl config use-context CONTEXT_NAME

# 현재 컨텍스트의 네임스페이스 변경
kubectl config set-context --current --namespace=NAMESPACE_NAME

# 컨텍스트 삭제
kubectl config delete-context CONTEXT_NAME
```

### 네임스페이스 관리

#### 네임스페이스 CRUD
```bash
# 생성
kubectl create namespace NAMESPACE_NAME

# 목록 조회
kubectl get namespaces
kubectl get ns  # 축약형

# 상세 정보
kubectl describe namespace NAMESPACE_NAME

# 라벨 추가
kubectl label namespace NAMESPACE_NAME key=value

# 삭제
kubectl delete namespace NAMESPACE_NAME
```

#### 네임스페이스별 리소스 조회
```bash
# 특정 네임스페이스 리소스
kubectl get pods -n NAMESPACE_NAME
kubectl get all -n NAMESPACE_NAME

# 모든 네임스페이스 리소스
kubectl get pods --all-namespaces
kubectl get all --all-namespaces

# 네임스페이스 필터링
kubectl get pods --all-namespaces | grep NAMESPACE_NAME
```

### kubectl 설정 최적화

#### 유용한 별칭
```bash
# ~/.bashrc 또는 ~/.zshrc에 추가
alias k=kubectl
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
alias kaf='kubectl apply -f'
alias kdel='kubectl delete'
alias kdesc='kubectl describe'

# 네임스페이스 관련
alias kgns='kubectl get namespaces'
alias kcn='kubectl config set-context --current --namespace'

# 컨텍스트 관련
alias kcc='kubectl config current-context'
alias kgc='kubectl config get-contexts'
alias kuc='kubectl config use-context'
```

#### 자동완성 설정
```bash
# bash
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc

# zsh
echo 'source <(kubectl completion zsh)' >>~/.zshrc
echo 'complete -F __start_kubectl k' >>~/.zshrc

# 적용
source ~/.bashrc  # 또는 ~/.zshrc
```

---

## 📋 Session 2 예제: 기본 워크로드 배포

### Pod 관리

#### Pod 생성 방법들
```bash
# 간단한 Pod 생성
kubectl run POD_NAME --image=IMAGE_NAME --port=PORT

# 환경 변수와 함께 생성
kubectl run POD_NAME --image=IMAGE_NAME --env="KEY=VALUE"

# 리소스 제한과 함께 생성
kubectl run POD_NAME --image=IMAGE_NAME --requests='cpu=100m,memory=128Mi'

# 임시 Pod (종료 시 자동 삭제)
kubectl run temp-pod --image=busybox --rm -it --restart=Never -- sh

# 특정 네임스페이스에 생성
kubectl run POD_NAME --image=IMAGE_NAME -n NAMESPACE_NAME
```

#### Pod 상태 확인
```bash
# 기본 정보
kubectl get pods
kubectl get pods -o wide
kubectl get pods --show-labels

# 상세 정보
kubectl describe pod POD_NAME

# 로그 확인
kubectl logs POD_NAME
kubectl logs POD_NAME -f  # 실시간
kubectl logs POD_NAME --previous  # 이전 컨테이너

# Pod 내부 접속
kubectl exec -it POD_NAME -- /bin/bash
kubectl exec -it POD_NAME -- sh
```

### Service 관리

#### Service 생성 방법들
```bash
# Pod를 Service로 노출
kubectl expose pod POD_NAME --port=80 --target-port=8080

# Deployment를 Service로 노출
kubectl expose deployment DEPLOYMENT_NAME --port=80

# Service 타입 지정
kubectl expose pod POD_NAME --port=80 --type=ClusterIP
kubectl expose pod POD_NAME --port=80 --type=NodePort
kubectl expose pod POD_NAME --port=80 --type=LoadBalancer

# 포트 이름 지정
kubectl expose pod POD_NAME --port=80 --name=http
```

#### Service 확인
```bash
# Service 목록
kubectl get services
kubectl get svc  # 축약형

# 상세 정보
kubectl describe service SERVICE_NAME

# 엔드포인트 확인
kubectl get endpoints SERVICE_NAME

# Service DNS 테스트
kubectl run dns-test --image=busybox --rm -it --restart=Never \
  -- nslookup SERVICE_NAME.NAMESPACE.svc.cluster.local
```

### Deployment 관리

#### Deployment 생성
```bash
# 기본 Deployment 생성
kubectl create deployment DEPLOYMENT_NAME --image=IMAGE_NAME

# 레플리카 수 지정
kubectl create deployment DEPLOYMENT_NAME --image=IMAGE_NAME --replicas=3

# 포트 지정
kubectl create deployment DEPLOYMENT_NAME --image=IMAGE_NAME --port=80
```

#### Deployment 스케일링
```bash
# 레플리카 수 변경
kubectl scale deployment DEPLOYMENT_NAME --replicas=5

# 자동 스케일링 (HPA)
kubectl autoscale deployment DEPLOYMENT_NAME --cpu-percent=50 --min=1 --max=10
```

#### Deployment 업데이트
```bash
# 이미지 업데이트
kubectl set image deployment/DEPLOYMENT_NAME CONTAINER_NAME=NEW_IMAGE

# 환경 변수 업데이트
kubectl set env deployment/DEPLOYMENT_NAME KEY=VALUE

# 롤아웃 관리
kubectl rollout status deployment/DEPLOYMENT_NAME
kubectl rollout history deployment/DEPLOYMENT_NAME
kubectl rollout undo deployment/DEPLOYMENT_NAME
kubectl rollout restart deployment/DEPLOYMENT_NAME
```

### 매니페스트 파일 예제

#### Pod 매니페스트
```yaml
# pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  namespace: development
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
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

#### Service 매니페스트
```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: development
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: ClusterIP
```

#### Deployment 매니페스트
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: staging
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
```

### 네트워킹 테스트

#### Pod 간 통신 테스트
```bash
# Pod IP 확인
kubectl get pod POD_NAME -o jsonpath='{.status.podIP}'

# 다른 Pod에서 접근
kubectl run test-client --image=busybox --rm -it --restart=Never \
  -- wget -qO- http://POD_IP

# Service를 통한 접근
kubectl run test-client --image=busybox --rm -it --restart=Never \
  -- wget -qO- http://SERVICE_NAME
```

#### DNS 해석 테스트
```bash
# 기본 DNS 테스트
kubectl run dns-test --image=busybox --rm -it --restart=Never \
  -- nslookup kubernetes.default.svc.cluster.local

# Service DNS 테스트
kubectl run dns-test --image=busybox --rm -it --restart=Never \
  -- nslookup SERVICE_NAME.NAMESPACE.svc.cluster.local

# 짧은 이름 테스트 (같은 네임스페이스)
kubectl run dns-test --image=busybox --rm -it --restart=Never \
  -- nslookup SERVICE_NAME
```

#### 네임스페이스 간 통신
```bash
# 다른 네임스페이스 Service 접근
kubectl run cross-ns-test --image=busybox --rm -it --restart=Never \
  -- wget -qO- http://SERVICE_NAME.TARGET_NAMESPACE.svc.cluster.local
```

---

## 🔧 유용한 kubectl 명령어 모음

### 리소스 조회
```bash
# 모든 리소스 타입
kubectl api-resources

# 특정 리소스의 필드 설명
kubectl explain pod
kubectl explain pod.spec
kubectl explain service.spec.type

# 리소스 상태 감시
kubectl get pods -w
kubectl get events -w

# JSON/YAML 출력
kubectl get pod POD_NAME -o json
kubectl get pod POD_NAME -o yaml
kubectl get pods -o jsonpath='{.items[*].metadata.name}'
```

### 디버깅 명령어
```bash
# 이벤트 확인
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl get events --field-selector involvedObject.name=POD_NAME

# 리소스 사용량 (metrics-server 필요)
kubectl top nodes
kubectl top pods
kubectl top pods -n NAMESPACE_NAME

# 포트 포워딩
kubectl port-forward pod/POD_NAME 8080:80
kubectl port-forward service/SERVICE_NAME 8080:80

# 프록시 서버 시작
kubectl proxy --port=8080
```

### 매니페스트 관리
```bash
# 파일에서 리소스 생성
kubectl apply -f FILE.yaml
kubectl apply -f DIRECTORY/
kubectl apply -f URL

# 리소스 삭제
kubectl delete -f FILE.yaml
kubectl delete pod POD_NAME
kubectl delete all --all  # 모든 리소스 삭제 (주의!)

# 리소스 편집
kubectl edit pod POD_NAME
kubectl edit deployment DEPLOYMENT_NAME

# 매니페스트 생성 (dry-run)
kubectl create deployment test --image=nginx --dry-run=client -o yaml
kubectl expose pod test --port=80 --dry-run=client -o yaml
```

---

## 🚨 트러블슈팅 가이드

### 일반적인 문제들

#### Pod가 Pending 상태
```bash
# 원인 확인
kubectl describe pod POD_NAME
kubectl get events --field-selector involvedObject.name=POD_NAME

# 노드 리소스 확인
kubectl describe nodes
kubectl top nodes
```

#### Pod가 CrashLoopBackOff 상태
```bash
# 로그 확인
kubectl logs POD_NAME
kubectl logs POD_NAME --previous

# 컨테이너 상태 확인
kubectl describe pod POD_NAME
```

#### Service 접근 불가
```bash
# 엔드포인트 확인
kubectl get endpoints SERVICE_NAME

# 라벨 셀렉터 확인
kubectl get pods --show-labels
kubectl describe service SERVICE_NAME

# DNS 테스트
kubectl run dns-test --image=busybox --rm -it --restart=Never \
  -- nslookup SERVICE_NAME
```

#### 권한 문제
```bash
# 현재 사용자 권한 확인
kubectl auth can-i VERB RESOURCE
kubectl auth can-i get pods
kubectl auth can-i create deployments

# 서비스 어카운트 확인
kubectl get serviceaccounts
kubectl describe serviceaccount default
```

### 성능 모니터링
```bash
# 리소스 사용량 모니터링
watch kubectl top pods
watch kubectl top nodes

# 이벤트 실시간 모니터링
kubectl get events -w

# 특정 리소스 상태 모니터링
watch kubectl get pods -l app=nginx
```

이 예제 모음을 통해 챌린저들이 Day 2 실습을 원활하게 진행할 수 있을 것입니다!
