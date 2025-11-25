#!/bin/bash

# November Week 4 Day 2: EKS 워크로드 배포 및 스케일링 데모
# 설명: Deployment, PersistentVolume, Auto Scaling 실시간 시연

set -e

echo "=== EKS 워크로드 데모 시작 ==="
echo ""

# 색상 정의
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1. 클러스터 확인 및 생성
echo -e "${BLUE}1/5 클러스터 확인 중...${NC}"
if ! kubectl get nodes &> /dev/null; then
    echo -e "${YELLOW}⚠️  클러스터가 없습니다. 새로 생성합니다...${NC}"
    echo ""
    
    # Day 1 스크립트 실행
    if [ -f "../../day1/demo_scripts/setup-eks-cluster.sh" ]; then
        cd ../../day1/demo_scripts
        ./setup-eks-cluster.sh
        cd ../../day2/demo_scripts
    else
        echo "❌ Day 1 스크립트를 찾을 수 없습니다."
        exit 1
    fi
    echo ""
fi

NODES=$(kubectl get nodes --no-headers | wc -l)
echo -e "${GREEN}✅ 클러스터 연결 완료 (노드 수: $NODES)${NC}"
echo ""

# 2. Deployment 배포
echo -e "${BLUE}2/5 Deployment 배포 중...${NC}"

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
---
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

echo -e "${GREEN}✅ Deployment 및 Service 생성 완료${NC}"
echo ""

# Pod 생성 대기
echo "Pod 생성 대기 중..."
kubectl wait --for=condition=ready pod -l app=nginx --timeout=120s
echo -e "${GREEN}✅ 모든 Pod가 Ready 상태입니다${NC}"
echo ""

# LoadBalancer 주소 대기
echo "LoadBalancer 주소 할당 대기 중 (약 2분 소요)..."
for i in {1..60}; do
    LB_HOSTNAME=$(kubectl get service nginx-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
    if [ -n "$LB_HOSTNAME" ]; then
        break
    fi
    sleep 2
done

if [ -n "$LB_HOSTNAME" ]; then
    echo -e "${GREEN}✅ LoadBalancer 주소: http://$LB_HOSTNAME${NC}"
else
    echo -e "${YELLOW}⚠️  LoadBalancer 주소 할당 대기 중...${NC}"
fi
echo ""

# 3. Metrics Server 설치
echo -e "${BLUE}3/5 Metrics Server 설치 중...${NC}"

if kubectl get deployment metrics-server -n kube-system &> /dev/null; then
    echo "Metrics Server가 이미 설치되어 있습니다."
else
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    
    # TLS 인증서 문제 해결
    kubectl patch deployment metrics-server -n kube-system \
      --type='json' \
      -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
    
    echo "Metrics Server 시작 대기 중..."
    kubectl wait --for=condition=available deployment/metrics-server -n kube-system --timeout=120s
fi

echo -e "${GREEN}✅ Metrics Server 설치 완료${NC}"
echo ""

# 4. HPA 생성
echo -e "${BLUE}4/5 HPA 생성 중...${NC}"

kubectl autoscale deployment nginx-app \
  --cpu-percent=50 \
  --min=3 \
  --max=10

echo -e "${GREEN}✅ HPA 생성 완료${NC}"
echo ""

# 최종 상태 출력
echo "=== 데모 환경 구성 완료 ==="
echo ""
echo "배포된 리소스:"
echo "- Deployment: nginx-app (replicas: 3)"
echo "- Service: nginx-service (LoadBalancer)"
echo "- HPA: nginx-app (min: 3, max: 10, target: 50% CPU)"
echo ""

if [ -n "$LB_HOSTNAME" ]; then
    echo "접속 URL: http://$LB_HOSTNAME"
    echo ""
fi

echo "다음 명령어로 상태 확인:"
echo "  kubectl get pods -l app=nginx"
echo "  kubectl get hpa nginx-app"
echo "  kubectl top pods"
echo ""

echo "Rolling Update 테스트:"
echo "  kubectl set image deployment/nginx-app nginx=nginx:1.22"
echo "  kubectl rollout status deployment/nginx-app"
echo ""

echo "부하 테스트 (HPA 동작 확인):"
echo "  kubectl run load-generator --image=busybox --restart=Never -- /bin/sh -c \"while true; do wget -q -O- http://nginx-service; done\""
echo "  kubectl get hpa nginx-app -w"
echo ""
