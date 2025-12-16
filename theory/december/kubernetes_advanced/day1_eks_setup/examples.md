# Day 1 실습 예제 모음

## 🎯 목적
Day 1 세션에서 사용하는 모든 명령어와 예제를 한 곳에 모아 챌린저들이 쉽게 참조할 수 있도록 합니다.

---

## 📋 사전 준비 체크리스트

### 필수 도구 설치 확인
```bash
# AWS CLI 버전 확인
aws --version

# eksctl 설치 확인
eksctl version

# kubectl 설치 확인
kubectl version --client

# AWS 계정 정보 확인
aws sts get-caller-identity
```

### AWS CLI 설정 (필요시)
```bash
# AWS 자격 증명 설정
aws configure

# 또는 환경 변수로 설정
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
export AWS_DEFAULT_REGION=ap-northeast-2
```

---

## 🏗️ Session 1 예제

### EKS 클러스터 생성

#### 1. 기본 클러스터 생성 (간단한 방법)
```bash
# 가장 간단한 클러스터 생성
eksctl create cluster \
  --name my-simple-cluster \
  --region ap-northeast-2 \
  --nodegroup-name workers \
  --node-type t3.medium \
  --nodes 2
```

#### 2. 설정 파일을 사용한 클러스터 생성 (권장)
```bash
# 설정 파일로 클러스터 생성
eksctl create cluster -f cluster-config.yaml

# 생성 진행 상황 확인
eksctl get cluster --region ap-northeast-2

# 특정 클러스터 상태 확인
eksctl get cluster --name my-eks-cluster --region ap-northeast-2
```

#### 3. 클러스터 생성 중 다른 터미널에서 확인
```bash
# AWS 콘솔 대신 CLI로 확인
aws eks list-clusters --region ap-northeast-2

# CloudFormation 스택 확인
aws cloudformation list-stacks --region ap-northeast-2 \
  --stack-status-filter CREATE_IN_PROGRESS
```

---

## 🔍 Session 2 예제

### 클러스터 연결 및 확인

#### 1. kubectl 설정 확인
```bash
# 현재 컨텍스트 확인
kubectl config current-context

# 모든 컨텍스트 보기
kubectl config get-contexts

# 클러스터 정보 확인
kubectl cluster-info

# 클러스터 상세 정보
kubectl cluster-info dump
```

#### 2. 노드 상태 확인
```bash
# 기본 노드 정보
kubectl get nodes

# 상세 노드 정보
kubectl get nodes -o wide

# 특정 노드 상세 정보
kubectl describe node [NODE-NAME]

# 노드 라벨 확인
kubectl get nodes --show-labels
```

#### 3. AWS 리소스 확인 명령어

##### EKS 클러스터 정보
```bash
# 클러스터 기본 정보
aws eks describe-cluster --name my-eks-cluster --region ap-northeast-2

# 클러스터 엔드포인트 확인
aws eks describe-cluster --name my-eks-cluster --region ap-northeast-2 \
  --query 'cluster.endpoint' --output text

# 클러스터 버전 확인
aws eks describe-cluster --name my-eks-cluster --region ap-northeast-2 \
  --query 'cluster.version' --output text
```

##### 노드 그룹 정보
```bash
# 노드 그룹 목록
aws eks list-nodegroups --cluster-name my-eks-cluster --region ap-northeast-2

# 노드 그룹 상세 정보
aws eks describe-nodegroup \
  --cluster-name my-eks-cluster \
  --nodegroup-name worker-nodes \
  --region ap-northeast-2

# 노드 그룹 스케일링 설정 확인
aws eks describe-nodegroup \
  --cluster-name my-eks-cluster \
  --nodegroup-name worker-nodes \
  --region ap-northeast-2 \
  --query 'nodegroup.scalingConfig'
```

##### VPC 및 네트워킹
```bash
# 클러스터 VPC ID 확인
aws eks describe-cluster --name my-eks-cluster --region ap-northeast-2 \
  --query 'cluster.resourcesVpcConfig.vpcId' --output text

# VPC 정보 확인
VPC_ID=$(aws eks describe-cluster --name my-eks-cluster --region ap-northeast-2 \
  --query 'cluster.resourcesVpcConfig.vpcId' --output text)
aws ec2 describe-vpcs --vpc-ids $VPC_ID

# 서브넷 정보 확인
aws eks describe-cluster --name my-eks-cluster --region ap-northeast-2 \
  --query 'cluster.resourcesVpcConfig.subnetIds' --output table

# 보안 그룹 확인
aws eks describe-cluster --name my-eks-cluster --region ap-northeast-2 \
  --query 'cluster.resourcesVpcConfig.clusterSecurityGroupId' --output text
```

#### 4. IAM 역할 및 정책 확인

##### 클러스터 서비스 역할
```bash
# 서비스 역할 이름 확인
aws eks describe-cluster --name my-eks-cluster --region ap-northeast-2 \
  --query 'cluster.roleArn' --output text

# 역할 정보 확인
aws iam get-role --role-name eksctl-my-eks-cluster-cluster-ServiceRole

# 연결된 정책 목록
aws iam list-attached-role-policies \
  --role-name eksctl-my-eks-cluster-cluster-ServiceRole
```

##### 노드 그룹 인스턴스 역할
```bash
# 노드 그룹 역할 ARN 확인
aws eks describe-nodegroup \
  --cluster-name my-eks-cluster \
  --nodegroup-name worker-nodes \
  --region ap-northeast-2 \
  --query 'nodegroup.nodeRole' --output text

# 역할 정보 확인
aws iam get-role --role-name eksctl-my-eks-cluster-nodegroup-worker-nodes-NodeInstanceRole

# 연결된 정책 목록
aws iam list-attached-role-policies \
  --role-name eksctl-my-eks-cluster-nodegroup-worker-nodes-NodeInstanceRole
```

#### 5. 테스트 Pod 배포 예제

##### 기본 Pod 생성
```bash
# nginx Pod 생성
kubectl run test-nginx --image=nginx --port=80

# Pod 상태 확인
kubectl get pods

# Pod 상세 정보
kubectl describe pod test-nginx

# Pod 로그 확인
kubectl logs test-nginx

# Pod 내부 접속
kubectl exec -it test-nginx -- /bin/bash
```

##### 다양한 테스트 Pod
```bash
# busybox Pod (디버깅용)
kubectl run test-busybox --image=busybox --rm -it --restart=Never -- sh

# alpine Pod (경량 리눅스)
kubectl run test-alpine --image=alpine --rm -it --restart=Never -- sh

# curl 테스트용 Pod
kubectl run test-curl --image=curlimages/curl --rm -it --restart=Never -- sh
```

##### Pod 네트워킹 테스트
```bash
# Pod IP 확인
kubectl get pod test-nginx -o jsonpath='{.status.podIP}'

# 다른 Pod에서 접근 테스트
kubectl run test-client --image=busybox --rm -it --restart=Never \
  -- wget -qO- http://$(kubectl get pod test-nginx -o jsonpath='{.status.podIP}')

# DNS 테스트
kubectl run test-dns --image=busybox --rm -it --restart=Never \
  -- nslookup kubernetes.default.svc.cluster.local
```

---

## 🧹 정리 및 삭제 명령어

### Pod 정리
```bash
# 특정 Pod 삭제
kubectl delete pod test-nginx

# 모든 Pod 삭제 (주의!)
kubectl delete pods --all

# 강제 삭제
kubectl delete pod test-nginx --force --grace-period=0
```

### 클러스터 삭제
```bash
# 클러스터 완전 삭제 (주의!)
eksctl delete cluster --name my-eks-cluster --region ap-northeast-2

# 삭제 진행 상황 확인
eksctl get cluster --region ap-northeast-2
```

---

## 🔧 유용한 kubectl 명령어 모음

### 정보 확인
```bash
# 모든 리소스 확인
kubectl get all

# 모든 네임스페이스의 리소스
kubectl get all --all-namespaces

# 특정 리소스 타입 확인
kubectl get pods,services,deployments

# 리소스 상세 정보
kubectl describe [RESOURCE_TYPE] [RESOURCE_NAME]

# 리소스 YAML 출력
kubectl get [RESOURCE_TYPE] [RESOURCE_NAME] -o yaml
```

### 디버깅
```bash
# 이벤트 확인
kubectl get events --sort-by=.metadata.creationTimestamp

# 로그 확인
kubectl logs [POD_NAME]

# 실시간 로그
kubectl logs -f [POD_NAME]

# 이전 컨테이너 로그
kubectl logs [POD_NAME] --previous
```

### 컨텍스트 관리
```bash
# 컨텍스트 목록
kubectl config get-contexts

# 컨텍스트 변경
kubectl config use-context [CONTEXT_NAME]

# 현재 컨텍스트 확인
kubectl config current-context

# 네임스페이스 변경
kubectl config set-context --current --namespace=[NAMESPACE]
```

---

## 📊 모니터링 명령어

### 리소스 사용량 (metrics-server 필요)
```bash
# 노드 리소스 사용량
kubectl top nodes

# Pod 리소스 사용량
kubectl top pods

# 특정 네임스페이스 Pod 사용량
kubectl top pods -n [NAMESPACE]
```

### 클러스터 상태 확인
```bash
# 컴포넌트 상태
kubectl get componentstatuses

# API 서버 상태
kubectl cluster-info

# 노드 상태 상세
kubectl describe nodes
```

---

## 🚨 트러블슈팅 가이드

### 자주 사용하는 디버깅 명령어
```bash
# Pod가 Pending 상태일 때
kubectl describe pod [POD_NAME]
kubectl get events --field-selector involvedObject.name=[POD_NAME]

# 노드 문제 확인
kubectl describe node [NODE_NAME]
kubectl get nodes -o wide

# 네트워킹 문제 확인
kubectl run test-dns --image=busybox --rm -it --restart=Never \
  -- nslookup kubernetes.default.svc.cluster.local

# 권한 문제 확인
kubectl auth can-i [VERB] [RESOURCE]
kubectl auth can-i create pods
```

이 예제 모음을 통해 챌린저들이 실습 중 막히는 부분 없이 원활하게 학습할 수 있을 것입니다!
