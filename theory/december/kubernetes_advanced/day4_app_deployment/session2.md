# Session 2: 멀티 티어 앱 배포 (50분)

## 🎯 세션 목표
- 멀티 티어 애플리케이션 아키텍처 구성
- 데이터베이스, API, 프론트엔드 연동
- 서비스 간 통신 및 설정 관리

## ⏰ 시간 배분
- **실습** (40분): DB + API + Frontend 배포
- **정리** (10분): 애플리케이션 상태 확인

---

## 🛠️ 실습: 멀티 티어 애플리케이션 배포 (40분)

### 1. 데이터베이스 계층 배포 (10분)

#### MySQL 데이터베이스 배포
```bash
# Production 네임스페이스로 전환
kubectl config use-context production-context 2>/dev/null || \
kubectl config set-context --current --namespace=production

# MySQL Secret 생성
kubectl create secret generic mysql-secret \
    --from-literal=mysql-root-password=rootpassword123 \
    --from-literal=mysql-user=appuser \
    --from-literal=mysql-password=apppassword123 \
    --from-literal=mysql-database=appdb

# MySQL ConfigMap 생성
cat > mysql-config.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
data:
  my.cnf: |
    [mysqld]
    default-authentication-plugin=mysql_native_password
    bind-address=0.0.0.0
    max_connections=200
    innodb_buffer_pool_size=128M
EOF

kubectl apply -f mysql-config.yaml

# MySQL Deployment 생성
cat > mysql-deployment.yaml << 'EOF'
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

kubectl apply -f mysql-deployment.yaml

# MySQL Service 생성
cat > mysql-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
  labels:
    app: mysql
spec:
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306
  type: ClusterIP
EOF

kubectl apply -f mysql-service.yaml
```

### 2. 백엔드 API 계층 배포 (15분)

#### 백엔드 ConfigMap 및 Secret 생성
```bash
# 백엔드 설정 ConfigMap
cat > backend-config.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-config
data:
  NODE_ENV: "production"
  PORT: "3000"
  DB_HOST: "mysql-service"
  DB_PORT: "3306"
  DB_NAME: "appdb"
  API_VERSION: "v1.0.0"
EOF

kubectl apply -f backend-config.yaml

# 데이터베이스 연결 Secret
cat > backend-secret.yaml << 'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: backend-secret
type: Opaque
data:
  DB_USER: YXBwdXNlcg==      # appuser (base64)
  DB_PASSWORD: YXBwcGFzc3dvcmQxMjM=  # apppassword123 (base64)
EOF

kubectl apply -f backend-secret.yaml
```

#### 백엔드 Deployment 생성
```bash
# ECR 이미지 URI 설정
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="ap-northeast-2"
BACKEND_IMAGE="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/backend-api:v1.0.0"

cat > backend-deployment.yaml << EOF
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
        image: $BACKEND_IMAGE
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

kubectl apply -f backend-deployment.yaml

# 백엔드 Service 생성
cat > backend-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  labels:
    app: backend-api
spec:
  selector:
    app: backend-api
  ports:
  - port: 3000
    targetPort: 3000
    name: http
  type: ClusterIP
EOF

kubectl apply -f backend-service.yaml
```

### 3. 프론트엔드 계층 배포 (10분)

#### 프론트엔드 ConfigMap 생성
```bash
# 프론트엔드 설정
cat > frontend-config.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-config
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

kubectl apply -f frontend-config.yaml
```

#### 프론트엔드 Deployment 생성
```bash
# 프론트엔드 이미지 URI 설정
FRONTEND_IMAGE="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/frontend-app:v1.0.0"

cat > frontend-deployment.yaml << EOF
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
        image: $FRONTEND_IMAGE
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

kubectl apply -f frontend-deployment.yaml

# 프론트엔드 LoadBalancer Service 생성
cat > frontend-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  labels:
    app: frontend-app
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

kubectl apply -f frontend-service.yaml
```

### 4. 애플리케이션 연동 테스트 (5분)

#### 서비스 간 통신 테스트
```bash
# 백엔드 API 테스트
kubectl run test-backend --image=busybox --rm -it --restart=Never \
    -- wget -qO- http://backend-service:3000/api/health

# 프론트엔드에서 백엔드 API 테스트
kubectl run test-frontend --image=busybox --rm -it --restart=Never \
    -- wget -qO- http://frontend-service/api/health

# 데이터베이스 연결 테스트
kubectl run mysql-client --image=mysql:8.0 --rm -it --restart=Never \
    -- mysql -h mysql-service -u appuser -papppassword123 -e "SELECT 1"
```

#### 외부 접근 테스트
```bash
# LoadBalancer 외부 IP 확인
kubectl get service frontend-service -o wide

# 외부 IP가 할당되면 테스트
EXTERNAL_IP=$(kubectl get service frontend-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
if [ ! -z "$EXTERNAL_IP" ]; then
    echo "External URL: http://$EXTERNAL_IP"
    curl -s http://$EXTERNAL_IP/health
    curl -s http://$EXTERNAL_IP/api/health
fi
```

---

## ✅ 체크포인트 (10분)

### 완료 확인 사항
- [ ] MySQL 데이터베이스 배포 및 실행 확인
- [ ] 백엔드 API 배포 및 헬스체크 성공
- [ ] 프론트엔드 배포 및 백엔드 연동 확인
- [ ] LoadBalancer를 통한 외부 접근 가능

### 배포된 애플리케이션 확인
```bash
# 전체 리소스 상태 확인
kubectl get all -l tier=database
kubectl get all -l tier=backend
kubectl get all -l tier=frontend

# Pod 상태 상세 확인
kubectl get pods -o wide

# 서비스 엔드포인트 확인
kubectl get endpoints

# ConfigMap 및 Secret 확인
kubectl get configmaps
kubectl get secrets
```

### 애플리케이션 아키텍처 확인
```bash
# 서비스 간 네트워크 연결 확인
kubectl describe service mysql-service
kubectl describe service backend-service
kubectl describe service frontend-service

# 환경 변수 확인
POD_NAME=$(kubectl get pods -l app=backend-api -o jsonpath='{.items[0].metadata.name}')
kubectl exec $POD_NAME -- env | grep -E "(DB_|NODE_ENV|PORT)"
```

---

## 🎯 세션 완료 후 상태

### 배포된 멀티 티어 애플리케이션
```
Production 네임스페이스:
├── Database Tier
│   ├── mysql (Deployment)
│   ├── mysql-service (ClusterIP)
│   ├── mysql-config (ConfigMap)
│   └── mysql-secret (Secret)
├── Backend Tier
│   ├── backend-api (Deployment)
│   ├── backend-service (ClusterIP)
│   ├── backend-config (ConfigMap)
│   └── backend-secret (Secret)
└── Frontend Tier
    ├── frontend-app (Deployment)
    ├── frontend-service (LoadBalancer)
    └── frontend-config (ConfigMap)
```

### 서비스 통신 흐름
```
Internet → LoadBalancer → Frontend (Nginx) → Backend API → MySQL Database
```

---

## 🔄 다음 세션 준비

### Day 5 예습 내용
- Istio 서비스 메시 아키텍처
- 사이드카 프록시 패턴
- 트래픽 관리 및 보안 정책

### 숙제
1. 배포한 멀티 티어 애플리케이션이 정상 작동하는지 확인
2. 각 계층 간 통신 흐름 이해
3. LoadBalancer를 통한 외부 접근 테스트

### 애플리케이션 모니터링
```bash
# 실시간 Pod 상태 모니터링
watch kubectl get pods

# 서비스 로그 확인
kubectl logs -l app=backend-api -f
kubectl logs -l app=frontend-app -f

# 리소스 사용량 확인 (metrics-server 필요)
kubectl top pods
```

---

## 🛠️ 추가: 고급 모니터링 및 알림 (보너스)

### 애플리케이션 성능 모니터링 (APM)
```bash
# Jaeger 분산 추적 설치
kubectl create namespace observability
kubectl apply -n observability -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/main/deploy/crds/jaegertracing.io_jaegers_crd.yaml
kubectl apply -n observability -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/main/deploy/service_account.yaml
kubectl apply -n observability -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/main/deploy/role.yaml
kubectl apply -n observability -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/main/deploy/role_binding.yaml
kubectl apply -n observability -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/main/deploy/operator.yaml

# Jaeger 인스턴스 생성
cat > jaeger.yaml << 'EOF'
apiVersion: jaegertracing.io/v1
kind: Jaeger
metadata:
  name: simple-prod
  namespace: observability
EOF

kubectl apply -f jaeger.yaml

# Jaeger UI 접근
kubectl port-forward -n observability svc/simple-prod-query 16686:16686 &
echo "Jaeger UI: http://localhost:16686"
```

### 로그 집계 및 분석
```bash
# ELK Stack 설치 (Elasticsearch + Logstash + Kibana)
helm repo add elastic https://helm.elastic.co
helm repo update

# Elasticsearch 설치
helm install elasticsearch elastic/elasticsearch \
  --namespace logging \
  --create-namespace \
  --set replicas=1 \
  --set minimumMasterNodes=1

# Kibana 설치
helm install kibana elastic/kibana \
  --namespace logging \
  --set elasticsearchHosts="http://elasticsearch-master:9200"

# Filebeat 설치 (로그 수집)
helm install filebeat elastic/filebeat \
  --namespace logging \
  --set daemonset.enabled=true

# Kibana 접근
kubectl port-forward -n logging svc/kibana-kibana 5601:5601 &
echo "Kibana: http://localhost:5601"
```

### 알림 및 경고 설정
```bash
# AlertManager 설정 (Prometheus 스택에 포함)
cat > alertmanager-config.yaml << 'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: alertmanager-monitoring-kube-prometheus-alertmanager
  namespace: monitoring
stringData:
  alertmanager.yml: |
    global:
      slack_api_url: 'YOUR_SLACK_WEBHOOK_URL'
    route:
      group_by: ['alertname']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 1h
      receiver: 'web.hook'
    receivers:
    - name: 'web.hook'
      slack_configs:
      - channel: '#alerts'
        title: 'Kubernetes Alert'
        text: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'
EOF

kubectl apply -f alertmanager-config.yaml

# 커스텀 알림 규칙
cat > custom-alerts.yaml << 'EOF'
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: custom-alerts
  namespace: monitoring
spec:
  groups:
  - name: custom.rules
    rules:
    - alert: HighPodCPU
      expr: rate(container_cpu_usage_seconds_total[5m]) > 0.8
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High CPU usage detected"
        description: "Pod {{ $labels.pod }} CPU usage is above 80%"
    - alert: PodMemoryUsage
      expr: container_memory_usage_bytes / container_spec_memory_limit_bytes > 0.9
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "High memory usage detected"
        description: "Pod {{ $labels.pod }} memory usage is above 90%"
EOF

kubectl apply -f custom-alerts.yaml
```
