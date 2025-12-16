# EKS 시스템 컴포넌트 및 관리 애플리케이션

## 🎯 목적
EKS Control Plane에서 자동으로 관리하는 시스템 컴포넌트들과 추가로 설치할 수 있는 관리 애플리케이션들을 이해합니다.

---

## 🏗️ EKS Control Plane 관리 컴포넌트

### AWS 완전 관리형 컴포넌트
EKS Control Plane에서 **자동으로 관리**되어 사용자가 직접 접근할 수 없는 컴포넌트들:

```bash
# 이 컴포넌트들은 AWS가 완전 관리 (사용자 접근 불가)
# - kube-apiserver
# - etcd
# - kube-scheduler  
# - kube-controller-manager
# - cloud-controller-manager

# 확인 방법: EKS 클러스터 정보에서 간접 확인
aws eks describe-cluster --name my-eks-cluster --query 'cluster.{Version:version,Status:status,Endpoint:endpoint}'
```

### 사용자 확인 가능한 시스템 정보
```bash
# API 서버 버전 확인
kubectl version --short

# 클러스터 정보 확인
kubectl cluster-info

# API 리소스 확인
kubectl api-resources

# API 버전 확인
kubectl api-versions
```

---

## 🔧 Worker Node 시스템 컴포넌트

### 기본 설치 컴포넌트
Worker Node에 **자동으로 설치**되는 시스템 컴포넌트들:

```bash
# kube-system 네임스페이스의 기본 컴포넌트들
kubectl get pods -n kube-system

# 주요 컴포넌트들:
# - aws-node (VPC CNI)
# - kube-proxy  
# - coredns
# - aws-load-balancer-controller (선택적)
```

#### 1. VPC CNI (aws-node)
```bash
# VPC CNI Pod 확인
kubectl get pods -n kube-system -l k8s-app=aws-node

# VPC CNI 설정 확인
kubectl describe daemonset aws-node -n kube-system

# ENI 및 IP 할당 확인
kubectl get nodes -o custom-columns=NAME:.metadata.name,PODS:.status.allocatable.pods,IPS:.status.addresses[0].address
```

#### 2. kube-proxy
```bash
# kube-proxy Pod 확인
kubectl get pods -n kube-system -l k8s-app=kube-proxy

# kube-proxy 설정 확인
kubectl get configmap kube-proxy-config -n kube-system -o yaml

# 네트워크 규칙 확인 (노드에서)
# iptables -t nat -L KUBE-SERVICES
```

#### 3. CoreDNS
```bash
# CoreDNS Pod 확인
kubectl get pods -n kube-system -l k8s-app=kube-dns

# CoreDNS 설정 확인
kubectl get configmap coredns -n kube-system -o yaml

# DNS 테스트
kubectl run dns-test --image=busybox --rm -it --restart=Never -- nslookup kubernetes.default.svc.cluster.local
```

---

## 📦 EKS 애드온 (Add-ons)

### 1. 공식 EKS 애드온 확인
```bash
# 사용 가능한 애드온 목록
aws eks describe-addon-versions --region ap-northeast-2

# 클러스터에 설치된 애드온 확인
aws eks list-addons --cluster-name my-eks-cluster --region ap-northeast-2

# 특정 애드온 상세 정보
aws eks describe-addon --cluster-name my-eks-cluster --addon-name vpc-cni --region ap-northeast-2
```

### 2. 주요 EKS 애드온들

#### VPC CNI 애드온
```bash
# VPC CNI 애드온 설치/업데이트
aws eks create-addon \
    --cluster-name my-eks-cluster \
    --addon-name vpc-cni \
    --addon-version v1.15.1-eksbuild.1 \
    --region ap-northeast-2

# VPC CNI 설정 확인
kubectl describe daemonset aws-node -n kube-system
```

#### CoreDNS 애드온
```bash
# CoreDNS 애드온 설치/업데이트
aws eks create-addon \
    --cluster-name my-eks-cluster \
    --addon-name coredns \
    --addon-version v1.10.1-eksbuild.5 \
    --region ap-northeast-2

# CoreDNS 성능 확인
kubectl top pods -n kube-system -l k8s-app=kube-dns
```

#### kube-proxy 애드온
```bash
# kube-proxy 애드온 설치/업데이트
aws eks create-addon \
    --cluster-name my-eks-cluster \
    --addon-name kube-proxy \
    --addon-version v1.28.2-eksbuild.2 \
    --region ap-northeast-2
```

#### EBS CSI Driver 애드온
```bash
# EBS CSI Driver 애드온 설치
aws eks create-addon \
    --cluster-name my-eks-cluster \
    --addon-name aws-ebs-csi-driver \
    --addon-version v1.24.0-eksbuild.1 \
    --region ap-northeast-2

# EBS CSI Driver 확인
kubectl get pods -n kube-system -l app=ebs-csi-controller
kubectl get storageclass
```

---

## 🎛️ 추가 관리 애플리케이션

### 1. AWS Load Balancer Controller
```bash
# IAM 정책 생성
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

# ServiceAccount 생성 (IRSA)
eksctl create iamserviceaccount \
  --cluster=my-eks-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::ACCOUNT-ID:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

# Helm으로 설치
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=my-eks-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

# 설치 확인
kubectl get deployment -n kube-system aws-load-balancer-controller
```

### 2. Cluster Autoscaler
```bash
# Cluster Autoscaler 설치
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml

# 클러스터 이름 설정
kubectl patch deployment cluster-autoscaler \
  -n kube-system \
  -p '{"spec":{"template":{"spec":{"containers":[{"name":"cluster-autoscaler","command":["./cluster-autoscaler","--v=4","--stderrthreshold=info","--cloud-provider=aws","--skip-nodes-with-local-storage=false","--expander=least-waste","--node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/my-eks-cluster"]}]}}}}'

# 안전한 축소 설정
kubectl patch deployment cluster-autoscaler \
  -n kube-system \
  -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict":"false"}}}}}'

# 설치 확인
kubectl get pods -n kube-system -l app=cluster-autoscaler
kubectl logs -n kube-system -l app=cluster-autoscaler
```

### 3. Metrics Server
```bash
# Metrics Server 설치
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# 설치 확인
kubectl get deployment metrics-server -n kube-system
kubectl top nodes
kubectl top pods -n kube-system
```

### 4. Container Insights (CloudWatch)
```bash
# Container Insights 설치
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluentd-quickstart.yaml | sed "s/{{cluster_name}}/my-eks-cluster/;s/{{region_name}}/ap-northeast-2/" | kubectl apply -f -

# 설치 확인
kubectl get pods -n amazon-cloudwatch

# CloudWatch 로그 그룹 확인
aws logs describe-log-groups --log-group-name-prefix /aws/containerinsights/my-eks-cluster --region ap-northeast-2
```

---

## 🔍 시스템 컴포넌트 모니터링

### 1. 전체 시스템 상태 확인
```bash
# 시스템 컴포넌트 상태 스크립트
cat > check-system-components.sh << 'EOF'
#!/bin/bash

echo "🔍 EKS 시스템 컴포넌트 상태 확인"
echo "=================================="

echo "📊 Control Plane 정보:"
kubectl cluster-info

echo -e "\n📊 kube-system 네임스페이스 Pod 상태:"
kubectl get pods -n kube-system -o wide

echo -e "\n📊 시스템 DaemonSet 상태:"
kubectl get daemonsets -n kube-system

echo -e "\n📊 시스템 Deployment 상태:"
kubectl get deployments -n kube-system

echo -e "\n📊 시스템 Service 상태:"
kubectl get services -n kube-system

echo -e "\n📊 StorageClass 확인:"
kubectl get storageclass

echo -e "\n📊 EKS 애드온 상태:"
aws eks list-addons --cluster-name my-eks-cluster --region ap-northeast-2 2>/dev/null || echo "AWS CLI 설정 필요"

echo -e "\n📊 노드 상태:"
kubectl get nodes -o wide

if kubectl top nodes >/dev/null 2>&1; then
    echo -e "\n📊 리소스 사용량:"
    kubectl top nodes
    kubectl top pods -n kube-system
else
    echo -e "\n⚠️  Metrics Server가 설치되지 않았습니다"
fi

echo -e "\n📊 최근 시스템 이벤트:"
kubectl get events -n kube-system --sort-by='.lastTimestamp' | tail -10
EOF

chmod +x check-system-components.sh
./check-system-components.sh
```

### 2. 개별 컴포넌트 상세 확인
```bash
# VPC CNI 상세 정보
kubectl describe daemonset aws-node -n kube-system

# CoreDNS 상세 정보  
kubectl describe deployment coredns -n kube-system

# kube-proxy 상세 정보
kubectl describe daemonset kube-proxy -n kube-system

# 각 컴포넌트 로그 확인
kubectl logs -n kube-system -l k8s-app=aws-node --tail=50
kubectl logs -n kube-system -l k8s-app=kube-dns --tail=50
kubectl logs -n kube-system -l k8s-app=kube-proxy --tail=50
```

---

## 🛠️ 시스템 컴포넌트 관리

### 1. 애드온 업데이트
```bash
# 애드온 버전 확인
aws eks describe-addon-versions --addon-name vpc-cni --region ap-northeast-2

# 애드온 업데이트
aws eks update-addon \
    --cluster-name my-eks-cluster \
    --addon-name vpc-cni \
    --addon-version v1.15.1-eksbuild.1 \
    --region ap-northeast-2

# 업데이트 상태 확인
aws eks describe-addon \
    --cluster-name my-eks-cluster \
    --addon-name vpc-cni \
    --region ap-northeast-2 \
    --query 'addon.status'
```

### 2. 시스템 컴포넌트 문제 해결
```bash
# Pod 재시작
kubectl rollout restart daemonset aws-node -n kube-system
kubectl rollout restart deployment coredns -n kube-system

# 설정 재로드
kubectl delete pod -n kube-system -l k8s-app=kube-dns

# 네트워크 문제 디버깅
kubectl run network-debug --image=nicolaka/netshoot --rm -it --restart=Never -- /bin/bash
```

### 3. 리소스 제한 및 최적화
```bash
# CoreDNS 리소스 제한 설정
kubectl patch deployment coredns -n kube-system -p='
{
  "spec": {
    "template": {
      "spec": {
        "containers": [
          {
            "name": "coredns",
            "resources": {
              "requests": {
                "cpu": "100m",
                "memory": "70Mi"
              },
              "limits": {
                "cpu": "200m", 
                "memory": "170Mi"
              }
            }
          }
        ]
      }
    }
  }
}'

# VPC CNI 설정 최적화
kubectl set env daemonset aws-node -n kube-system ENABLE_PREFIX_DELEGATION=true
kubectl set env daemonset aws-node -n kube-system WARM_PREFIX_TARGET=1
```

이제 챌린저들이 EKS의 시스템 컴포넌트들을 완전히 이해하고 관리할 수 있습니다!
