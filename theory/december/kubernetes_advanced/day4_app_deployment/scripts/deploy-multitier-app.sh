#!/bin/bash

# 멀티 티어 애플리케이션 배포 스크립트

echo "🚀 멀티 티어 애플리케이션 배포 시작..."
echo "=================================="

# 환경 변수 설정
export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export REGION="ap-northeast-2"
export ECR_REGISTRY="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"

# 네임스페이스 확인
NAMESPACE="production"
if ! kubectl get namespace "$NAMESPACE" > /dev/null 2>&1; then
    echo "❌ 네임스페이스 '$NAMESPACE'가 존재하지 않습니다"
    echo "   네임스페이스를 생성합니다..."
    kubectl create namespace "$NAMESPACE"
fi

# 네임스페이스로 전환
kubectl config set-context --current --namespace="$NAMESPACE"
echo "✅ 네임스페이스 '$NAMESPACE'로 전환 완료"

# 기존 리소스 정리 (선택사항)
echo -e "\n🧹 기존 리소스 정리 중..."
kubectl delete deployment,service,configmap,secret -l tier=database --ignore-not-found=true
kubectl delete deployment,service,configmap,secret -l tier=backend --ignore-not-found=true
kubectl delete deployment,service,configmap,secret -l tier=frontend --ignore-not-found=true

# 1. 데이터베이스 계층 배포
echo -e "\n📁 데이터베이스 계층 배포 중..."

# MySQL Secret 생성
kubectl create secret generic mysql-secret \
    --from-literal=mysql-root-password=rootpassword123 \
    --from-literal=mysql-user=appuser \
    --from-literal=mysql-password=apppassword123 \
    --from-literal=mysql-database=appdb \
    --dry-run=client -o yaml | kubectl apply -f -

# MySQL ConfigMap 생성
cat > /tmp/mysql-config.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
  labels:
    tier: database
data:
  my.cnf: |
    [mysqld]
    default-authentication-plugin=mysql_native_password
    bind-address=0.0.0.0
    max_connections=200
    innodb_buffer_pool_size=128M
EOF

kubectl apply -f /tmp/mysql-config.yaml

# MySQL Deployment 생성
cat > /tmp/mysql-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
  labels:
    app: mysql
    tier: database
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
        tier: database
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        ports:
        - containerPort: 3306
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: mysql-root-password
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: mysql-user
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: mysql-password
        - name: MYSQL_DATABASE
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: mysql-database
        volumeMounts:
        - name: mysql-config
          mountPath: /etc/mysql/conf.d
        - name: mysql-data
          mountPath: /var/lib/mysql
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
      volumes:
      - name: mysql-config
        configMap:
          name: mysql-config
      - name: mysql-data
        emptyDir: {}
EOF

kubectl apply -f /tmp/mysql-deployment.yaml

# MySQL Service 생성
cat > /tmp/mysql-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
  labels:
    app: mysql
    tier: database
spec:
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306
  type: ClusterIP
EOF

kubectl apply -f /tmp/mysql-service.yaml

# MySQL 시작 대기
echo "⏳ MySQL 시작 대기 중..."
kubectl wait --for=condition=Ready pod -l app=mysql --timeout=120s

if [ $? -eq 0 ]; then
    echo "✅ MySQL 배포 완료"
else
    echo "❌ MySQL 배포 실패"
    exit 1
fi

# 2. 백엔드 API 계층 배포
echo -e "\n📁 백엔드 API 계층 배포 중..."

# 백엔드 ConfigMap 생성
cat > /tmp/backend-config.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-config
  labels:
    tier: backend
data:
  NODE_ENV: "production"
  PORT: "3000"
  DB_HOST: "mysql-service"
  DB_PORT: "3306"
  DB_NAME: "appdb"
  API_VERSION: "v1.0.0"
EOF

kubectl apply -f /tmp/backend-config.yaml

# 백엔드 Secret 생성
cat > /tmp/backend-secret.yaml << 'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: backend-secret
  labels:
    tier: backend
type: Opaque
data:
  DB_USER: YXBwdXNlcg==      # appuser (base64)
  DB_PASSWORD: YXBwcGFzc3dvcmQxMjM=  # apppassword123 (base64)
EOF

kubectl apply -f /tmp/backend-secret.yaml

# 백엔드 Deployment 생성
cat > /tmp/backend-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-api
  labels:
    app: backend-api
    tier: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend-api
  template:
    metadata:
      labels:
        app: backend-api
        tier: backend
    spec:
      containers:
      - name: backend
        image: $ECR_REGISTRY/backend-api:v1.0.0
        ports:
        - containerPort: 3000
        envFrom:
        - configMapRef:
            name: backend-config
        - secretRef:
            name: backend-secret
        livenessProbe:
          httpGet:
            path: /api/health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /api/health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            memory: "128Mi"
            cpu: "250m"
          limits:
            memory: "256Mi"
            cpu: "500m"
EOF

kubectl apply -f /tmp/backend-deployment.yaml

# 백엔드 Service 생성
cat > /tmp/backend-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  labels:
    app: backend-api
    tier: backend
spec:
  selector:
    app: backend-api
  ports:
  - port: 3000
    targetPort: 3000
    name: http
  type: ClusterIP
EOF

kubectl apply -f /tmp/backend-service.yaml

# 백엔드 시작 대기
echo "⏳ 백엔드 API 시작 대기 중..."
kubectl wait --for=condition=Ready pod -l app=backend-api --timeout=120s

if [ $? -eq 0 ]; then
    echo "✅ 백엔드 API 배포 완료"
else
    echo "❌ 백엔드 API 배포 실패"
    exit 1
fi

# 3. 프론트엔드 계층 배포
echo -e "\n📁 프론트엔드 계층 배포 중..."

# 프론트엔드 ConfigMap 생성
cat > /tmp/frontend-config.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-config
  labels:
    tier: frontend
data:
  nginx.conf: |
    events {
        worker_connections 1024;
    }
    http {
        upstream backend {
            server backend-service:3000;
        }
        
        server {
            listen 80;
            
            location / {
                root /usr/share/nginx/html;
                index index.html;
                try_files $uri $uri/ /index.html;
            }
            
            location /api/ {
                proxy_pass http://backend/;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            }
            
            location /health {
                access_log off;
                return 200 "healthy\n";
                add_header Content-Type text/plain;
            }
        }
    }
EOF

kubectl apply -f /tmp/frontend-config.yaml

# 프론트엔드 Deployment 생성
cat > /tmp/frontend-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-app
  labels:
    app: frontend-app
    tier: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend-app
  template:
    metadata:
      labels:
        app: frontend-app
        tier: frontend
    spec:
      containers:
      - name: frontend
        image: $ECR_REGISTRY/frontend-app:v1.0.0
        ports:
        - containerPort: 80
        volumeMounts:
        - name: nginx-config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "250m"
      volumes:
      - name: nginx-config
        configMap:
          name: frontend-config
EOF

kubectl apply -f /tmp/frontend-deployment.yaml

# 프론트엔드 Service 생성
cat > /tmp/frontend-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  labels:
    app: frontend-app
    tier: frontend
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
spec:
  selector:
    app: frontend-app
  ports:
  - port: 80
    targetPort: 80
    name: http
  type: LoadBalancer
EOF

kubectl apply -f /tmp/frontend-service.yaml

# 프론트엔드 시작 대기
echo "⏳ 프론트엔드 시작 대기 중..."
kubectl wait --for=condition=Ready pod -l app=frontend-app --timeout=120s

if [ $? -eq 0 ]; then
    echo "✅ 프론트엔드 배포 완료"
else
    echo "❌ 프론트엔드 배포 실패"
    exit 1
fi

# 4. 애플리케이션 테스트
echo -e "\n🧪 애플리케이션 연동 테스트 중..."

# 백엔드 헬스체크
echo "백엔드 API 헬스체크..."
kubectl run test-backend --image=busybox --rm -it --restart=Never \
    -- wget -qO- http://backend-service:3000/api/health 2>/dev/null && echo "✅ 백엔드 헬스체크 성공" || echo "❌ 백엔드 헬스체크 실패"

# 프론트엔드 헬스체크
echo "프론트엔드 헬스체크..."
kubectl run test-frontend --image=busybox --rm -it --restart=Never \
    -- wget -qO- http://frontend-service/health 2>/dev/null && echo "✅ 프론트엔드 헬스체크 성공" || echo "❌ 프론트엔드 헬스체크 실패"

# 프론트엔드에서 백엔드 API 테스트
echo "프론트엔드 → 백엔드 API 테스트..."
kubectl run test-api --image=busybox --rm -it --restart=Never \
    -- wget -qO- http://frontend-service/api/health 2>/dev/null && echo "✅ API 프록시 성공" || echo "❌ API 프록시 실패"

# 임시 파일 정리
rm -f /tmp/mysql-*.yaml /tmp/backend-*.yaml /tmp/frontend-*.yaml

# 배포 결과 확인
echo -e "\n📋 배포 결과 확인:"
echo "전체 리소스 상태:"
kubectl get all

echo -e "\n🌐 서비스 정보:"
kubectl get services -o wide

echo -e "\n📊 Pod 상태:"
kubectl get pods -o wide

# LoadBalancer 외부 IP 확인
echo -e "\n🔗 외부 접근 정보:"
EXTERNAL_IP=$(kubectl get service frontend-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
if [ ! -z "$EXTERNAL_IP" ]; then
    echo "✅ 외부 URL: http://$EXTERNAL_IP"
    echo "   헬스체크: http://$EXTERNAL_IP/health"
    echo "   API 테스트: http://$EXTERNAL_IP/api/health"
else
    echo "⏳ LoadBalancer IP 할당 대기 중..."
    echo "   다음 명령어로 확인: kubectl get service frontend-service -w"
fi

echo -e "\n🎯 멀티 티어 애플리케이션 배포 완료!"
echo "관리 명령어:"
echo "  # 전체 상태 확인"
echo "  kubectl get all"
echo ""
echo "  # 로그 확인"
echo "  kubectl logs -l tier=backend -f"
echo "  kubectl logs -l tier=frontend -f"
echo ""
echo "  # 스케일링"
echo "  kubectl scale deployment backend-api --replicas=3"
echo "  kubectl scale deployment frontend-app --replicas=3"
