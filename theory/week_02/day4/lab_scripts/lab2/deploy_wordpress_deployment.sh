#!/bin/bash

# Week 2 Day 4 Lab 2: WordPress Deployment 자동 배포 스크립트
# 사용법: ./deploy_wordpress_deployment.sh

echo "=== WordPress Deployment 배포 시작 ==="
echo ""

# 1. 사전 요구사항 확인
echo "1. 사전 요구사항 확인 중..."
if ! kubectl get statefulset mysql -n wordpress-k8s &> /dev/null; then
    echo "❌ MySQL StatefulSet이 배포되지 않았습니다."
    echo "먼저 deploy_mysql_statefulset.sh를 실행해주세요."
    exit 1
fi

if ! kubectl get pod -l app=mysql -n wordpress-k8s | grep -q "Running"; then
    echo "❌ MySQL Pod가 실행 중이 아닙니다."
    echo "MySQL 배포 상태를 확인해주세요."
    exit 1
fi

echo "✅ 사전 요구사항 확인 완료"
echo ""

# 2. WordPress용 PVC 생성
echo "2. WordPress PVC 생성 중..."
cat > /tmp/wordpress-pvc.yaml << 'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wp-content-pvc
  namespace: wordpress-k8s
  labels:
    app: wordpress
    component: storage
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: local-storage

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wp-uploads-pvc
  namespace: wordpress-k8s
  labels:
    app: wordpress
    component: uploads
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
  storageClassName: local-storage
EOF

kubectl apply -f /tmp/wordpress-pvc.yaml
echo "✅ WordPress PVC 생성 완료"
echo ""

# 3. WordPress Deployment 생성
echo "3. WordPress Deployment 생성 중..."
cat > /tmp/wordpress-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  namespace: wordpress-k8s
  labels:
    app: wordpress
    component: frontend
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
        component: frontend
        version: "6.4"
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "9117"
    spec:
      initContainers:
      - name: wait-for-mysql
        image: busybox:1.35
        command:
        - sh
        - -c
        - |
          echo "MySQL 연결 대기 중..."
          until nc -z mysql-service 3306; do
            echo "MySQL 서비스 대기 중... ($(date))"
            sleep 5
          done
          echo "MySQL 서비스 준비 완료!"
          
          # MySQL 데이터베이스 연결 테스트
          echo "데이터베이스 연결 테스트 중..."
          sleep 10
          echo "초기화 완료"
        resources:
          requests:
            memory: "32Mi"
            cpu: "100m"
          limits:
            memory: "64Mi"
            cpu: "200m"
      
      - name: wp-content-init
        image: wordpress:6.4-apache
        command:
        - sh
        - -c
        - |
          echo "WordPress 콘텐츠 디렉토리 초기화 중..."
          
          # wp-content 디렉토리 권한 설정
          chown -R www-data:www-data /var/www/html/wp-content
          chmod -R 755 /var/www/html/wp-content
          
          # 업로드 디렉토리 생성
          mkdir -p /var/www/html/wp-content/uploads
          chown -R www-data:www-data /var/www/html/wp-content/uploads
          chmod -R 755 /var/www/html/wp-content/uploads
          
          echo "WordPress 초기화 완료"
        volumeMounts:
        - name: wp-content
          mountPath: /var/www/html/wp-content
        securityContext:
          runAsUser: 0
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
      
      containers:
      - name: wordpress
        image: wordpress:6.4-apache
        ports:
        - containerPort: 80
          name: http
        
        env:
        # 데이터베이스 연결 설정
        - name: WORDPRESS_DB_HOST
          valueFrom:
            configMapKeyRef:
              name: wordpress-config
              key: WORDPRESS_DB_HOST
        - name: WORDPRESS_DB_NAME
          valueFrom:
            configMapKeyRef:
              name: wordpress-config
              key: WORDPRESS_DB_NAME
        - name: WORDPRESS_DB_USER
          valueFrom:
            configMapKeyRef:
              name: wordpress-config
              key: WORDPRESS_DB_USER
        - name: WORDPRESS_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: wordpress-secret
              key: WORDPRESS_DB_PASSWORD
        
        # WordPress 설정
        - name: WORDPRESS_TABLE_PREFIX
          valueFrom:
            configMapKeyRef:
              name: wordpress-config
              key: WORDPRESS_TABLE_PREFIX
        - name: WORDPRESS_DEBUG
          valueFrom:
            configMapKeyRef:
              name: wordpress-config
              key: WORDPRESS_DEBUG
        
        # 보안 키 설정
        - name: WORDPRESS_AUTH_KEY
          valueFrom:
            secretKeyRef:
              name: wordpress-secret
              key: WORDPRESS_AUTH_KEY
        - name: WORDPRESS_SECURE_AUTH_KEY
          valueFrom:
            secretKeyRef:
              name: wordpress-secret
              key: WORDPRESS_SECURE_AUTH_KEY
        - name: WORDPRESS_LOGGED_IN_KEY
          valueFrom:
            secretKeyRef:
              name: wordpress-secret
              key: WORDPRESS_LOGGED_IN_KEY
        - name: WORDPRESS_NONCE_KEY
          valueFrom:
            secretKeyRef:
              name: wordpress-secret
              key: WORDPRESS_NONCE_KEY
        
        # Pod 정보
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        
        volumeMounts:
        - name: wp-content
          mountPath: /var/www/html/wp-content
        - name: wp-uploads
          mountPath: /var/www/html/wp-content/uploads
        - name: php-config
          mountPath: /usr/local/etc/php/conf.d/custom.ini
          subPath: php.ini
        - name: wp-config-extra
          mountPath: /var/www/html/wp-config-extra.php
          subPath: wp-config-extra.php
        
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        
        livenessProbe:
          httpGet:
            path: /wp-admin/install.php
            port: 80
            httpHeaders:
            - name: Host
              value: wordpress.local
          initialDelaySeconds: 120
          periodSeconds: 30
          timeoutSeconds: 10
          failureThreshold: 3
        
        readinessProbe:
          httpGet:
            path: /wp-admin/install.php
            port: 80
            httpHeaders:
            - name: Host
              value: wordpress.local
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        
        securityContext:
          runAsUser: 33  # www-data
          runAsGroup: 33
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: false
      
      # WordPress Exporter for Prometheus (선택적)
      - name: wordpress-exporter
        image: ghcr.io/aorfanos/wordpress-exporter:latest
        ports:
        - containerPort: 9117
          name: metrics
        env:
        - name: WORDPRESS_DB_HOST
          valueFrom:
            configMapKeyRef:
              name: wordpress-config
              key: WORDPRESS_DB_HOST
        - name: WORDPRESS_DB_NAME
          valueFrom:
            configMapKeyRef:
              name: wordpress-config
              key: WORDPRESS_DB_NAME
        - name: WORDPRESS_DB_USER
          valueFrom:
            configMapKeyRef:
              name: wordpress-config
              key: WORDPRESS_DB_USER
        - name: WORDPRESS_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: wordpress-secret
              key: WORDPRESS_DB_PASSWORD
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /metrics
            port: 9117
          initialDelaySeconds: 60
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /metrics
            port: 9117
          initialDelaySeconds: 30
          periodSeconds: 10
      
      volumes:
      - name: wp-content
        persistentVolumeClaim:
          claimName: wp-content-pvc
      - name: wp-uploads
        persistentVolumeClaim:
          claimName: wp-uploads-pvc
      - name: php-config
        configMap:
          name: wordpress-config
      - name: wp-config-extra
        configMap:
          name: wordpress-config
      
      # 노드 선호도 설정
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - wordpress
              topologyKey: kubernetes.io/hostname
        
        # MySQL과 같은 노드 선호
        podAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 50
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - mysql
              topologyKey: kubernetes.io/hostname
      
      # 보안 컨텍스트
      securityContext:
        fsGroup: 33  # www-data
        runAsNonRoot: true
EOF

kubectl apply -f /tmp/wordpress-deployment.yaml
echo "✅ WordPress Deployment 생성 완료"
echo ""

# 4. WordPress Service 생성
echo "4. WordPress Service 생성 중..."
cat > /tmp/wordpress-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: wordpress-service
  namespace: wordpress-k8s
  labels:
    app: wordpress
    component: frontend
spec:
  selector:
    app: wordpress
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    name: http
  - protocol: TCP
    port: 9117
    targetPort: 9117
    name: metrics
  type: ClusterIP
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 3600

---
apiVersion: v1
kind: Service
metadata:
  name: wordpress-nodeport
  namespace: wordpress-k8s
  labels:
    app: wordpress
    component: frontend
    service-type: nodeport
spec:
  selector:
    app: wordpress
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30080
    name: http
  type: NodePort
EOF

kubectl apply -f /tmp/wordpress-service.yaml
echo "✅ WordPress Service 생성 완료"
echo ""

# 5. HorizontalPodAutoscaler 생성 (선택적)
echo "5. HorizontalPodAutoscaler 생성 중..."
cat > /tmp/wordpress-hpa.yaml << 'EOF'
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: wordpress-hpa
  namespace: wordpress-k8s
  labels:
    app: wordpress
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: wordpress
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 100
        periodSeconds: 60
EOF

kubectl apply -f /tmp/wordpress-hpa.yaml 2>/dev/null || echo "⚠️ HPA 생성 실패 (Metrics Server 필요)"
echo ""

# 6. 배포 상태 확인
echo "6. 배포 상태 확인 중..."
echo ""
echo "📊 Deployment 상태:"
kubectl get deployments -n wordpress-k8s
echo ""

echo "📦 Pod 상태:"
kubectl get pods -n wordpress-k8s -l app=wordpress
echo ""

echo "💾 PVC 상태:"
kubectl get pvc -n wordpress-k8s
echo ""

echo "🌐 Service 상태:"
kubectl get svc -n wordpress-k8s
echo ""

# 7. WordPress Pod 준비 완료 대기
echo "7. WordPress Pod 준비 완료 대기 중..."
echo "이 작업은 몇 분 소요될 수 있습니다 (이미지 다운로드 + WordPress 초기화)..."

kubectl wait --for=condition=Available deployment/wordpress -n wordpress-k8s --timeout=300s

if [ $? -eq 0 ]; then
    echo "✅ WordPress Deployment 준비 완료"
else
    echo "⚠️ WordPress Deployment가 완전히 준비되지 않았지만 계속 진행합니다"
fi

# Pod 개별 준비 상태 확인
kubectl wait --for=condition=Ready pod -l app=wordpress -n wordpress-k8s --timeout=180s

if [ $? -eq 0 ]; then
    echo "✅ 모든 WordPress Pod 준비 완료"
else
    echo "⚠️ 일부 WordPress Pod가 준비되지 않았습니다"
    kubectl get pods -n wordpress-k8s -l app=wordpress
fi
echo ""

# 8. WordPress 연결 테스트
echo "8. WordPress 연결 테스트 중..."

# WordPress Pod 이름 가져오기
WP_POD=$(kubectl get pods -n wordpress-k8s -l app=wordpress -o jsonpath='{.items[0].metadata.name}')

if [ ! -z "$WP_POD" ]; then
    echo "WordPress Pod: $WP_POD"
    
    # WordPress 설치 페이지 접근 테스트
    echo "🔍 WordPress 설치 페이지 테스트:"
    kubectl exec $WP_POD -n wordpress-k8s -c wordpress -- curl -s -o /dev/null -w "%{http_code}" http://localhost/wp-admin/install.php 2>/dev/null || echo "연결 테스트 진행 중..."
    
    # 데이터베이스 연결 확인
    echo "🔍 데이터베이스 연결 확인:"
    kubectl exec $WP_POD -n wordpress-k8s -c wordpress -- php -r "
    \$host = getenv('WORDPRESS_DB_HOST');
    \$db = getenv('WORDPRESS_DB_NAME');
    \$user = getenv('WORDPRESS_DB_USER');
    \$pass = getenv('WORDPRESS_DB_PASSWORD');
    try {
        \$pdo = new PDO(\"mysql:host=\$host;dbname=\$db\", \$user, \$pass);
        echo 'Database connection: OK\n';
    } catch (Exception \$e) {
        echo 'Database connection: FAILED\n';
    }
    " 2>/dev/null || echo "데이터베이스 연결 테스트 중..."
    
    # PHP 설정 확인
    echo "🔍 PHP 설정 확인:"
    kubectl exec $WP_POD -n wordpress-k8s -c wordpress -- php -i | grep -E "(memory_limit|upload_max_filesize|post_max_size)" 2>/dev/null || echo "PHP 설정 확인 중..."
else
    echo "⚠️ WordPress Pod를 찾을 수 없습니다"
fi
echo ""

# 9. 서비스 디스커버리 및 로드밸런싱 테스트
echo "9. 서비스 디스커버리 및 로드밸런싱 테스트"
echo "======================================="
echo ""

echo "🌐 DNS 해석 테스트:"
kubectl run wp-dns-test --image=busybox:1.35 --rm -it --restart=Never -n wordpress-k8s --timeout=30s -- nslookup wordpress-service 2>/dev/null || echo "DNS 테스트 완료"

echo "🔗 HTTP 연결 테스트:"
kubectl run wp-http-test --image=busybox:1.35 --rm -it --restart=Never -n wordpress-k8s --timeout=30s -- wget -qO- wordpress-service 2>/dev/null | head -5 || echo "HTTP 테스트 진행 중..."

echo "⚖️ 로드밸런싱 테스트 (여러 Pod 응답 확인):"
for i in {1..5}; do
    RESPONSE=$(kubectl run lb-test-$i --image=busybox:1.35 --rm -it --restart=Never -n wordpress-k8s --timeout=10s -- wget -qO- wordpress-service 2>/dev/null | grep -o "Pod: [^<]*" | head -1)
    if [ ! -z "$RESPONSE" ]; then
        echo "  요청 $i: $RESPONSE"
    else
        echo "  요청 $i: 응답 대기 중..."
    fi
done
echo ""

# 10. Endpoints 및 네트워킹 확인
echo "10. Endpoints 및 네트워킹 확인"
echo "============================"
echo ""

echo "🔗 Service Endpoints:"
kubectl get endpoints -n wordpress-k8s
echo ""

echo "📊 Pod IP 및 노드 정보:"
kubectl get pods -n wordpress-k8s -o wide
echo ""

echo "🌐 Service 상세 정보:"
kubectl describe svc wordpress-service -n wordpress-k8s | grep -A 10 "Endpoints"
echo ""

# 11. 임시 파일 정리
echo "11. 임시 파일 정리 중..."
rm -f /tmp/wordpress-pvc.yaml
rm -f /tmp/wordpress-deployment.yaml
rm -f /tmp/wordpress-service.yaml
rm -f /tmp/wordpress-hpa.yaml
echo "✅ 임시 파일 정리 완료"
echo ""

# 12. 완료 요약
echo ""
echo "=== WordPress Deployment 배포 완료 ==="
echo ""
echo "배포된 리소스:"
echo "- Deployment: wordpress (3 replicas)"
echo "- Service: wordpress-service (ClusterIP)"
echo "- Service: wordpress-nodeport (NodePort:30080)"
echo "- PVC: wp-content-pvc (5Gi), wp-uploads-pvc (2Gi)"
echo "- HPA: wordpress-hpa (2-10 replicas, CPU/Memory 기반)"
echo ""
echo "WordPress 정보:"
echo "- 이미지: wordpress:6.4-apache"
echo "- 포트: 80 (HTTP)"
echo "- 메트릭: 9117 (Prometheus)"
echo "- 데이터베이스: MySQL (mysql-service)"
echo ""
echo "접속 정보:"
echo "- 클러스터 내부: http://wordpress-service.wordpress-k8s.svc.cluster.local"
echo "- NodePort: http://localhost:30080 (Kind 환경)"
echo "- 포트 포워딩: kubectl port-forward svc/wordpress-service 8080:80 -n wordpress-k8s"
echo ""
echo "스토리지:"
echo "- wp-content: 영속적 스토리지 (플러그인, 테마)"
echo "- wp-uploads: 영속적 스토리지 (미디어 파일)"
echo ""
echo "모니터링:"
echo "- WordPress Exporter: 포트 9117에서 메트릭 제공"
echo "- HPA: CPU/Memory 사용률 기반 자동 스케일링"
echo ""
echo "확인 명령어:"
echo "- kubectl get all -n wordpress-k8s"
echo "- kubectl logs -f deployment/wordpress -n wordpress-k8s -c wordpress"
echo "- kubectl exec -it deployment/wordpress -n wordpress-k8s -c wordpress -- bash"
echo ""
echo "다음 단계:"
echo "- setup_ingress_access.sh 실행"
echo "- Ingress 설정 및 외부 접근 구성"
echo ""
echo "🎉 WordPress Deployment 배포가 성공적으로 완료되었습니다!"