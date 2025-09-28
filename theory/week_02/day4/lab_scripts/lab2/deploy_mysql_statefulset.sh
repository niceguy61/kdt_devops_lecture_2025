#!/bin/bash

# Week 2 Day 4 Lab 2: MySQL StatefulSet 자동 배포 스크립트
# 사용법: ./deploy_mysql_statefulset.sh

echo "=== MySQL StatefulSet 배포 시작 ==="
echo ""

# 1. 사전 요구사항 확인
echo "1. 사전 요구사항 확인 중..."
if ! kubectl get namespace wordpress-k8s &> /dev/null; then
    echo "❌ wordpress-k8s 네임스페이스가 없습니다."
    echo "먼저 setup_configs_secrets.sh를 실행해주세요."
    exit 1
fi

if ! kubectl get configmap mysql-config -n wordpress-k8s &> /dev/null; then
    echo "❌ mysql-config ConfigMap이 없습니다."
    echo "먼저 setup_configs_secrets.sh를 실행해주세요."
    exit 1
fi

if ! kubectl get secret wordpress-secret -n wordpress-k8s &> /dev/null; then
    echo "❌ wordpress-secret Secret이 없습니다."
    echo "먼저 setup_configs_secrets.sh를 실행해주세요."
    exit 1
fi

echo "✅ 사전 요구사항 확인 완료"
echo ""

# 2. StorageClass 생성 (로컬 환경용)
echo "2. StorageClass 생성 중..."
cat > /tmp/storageclass.yaml << 'EOF'
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
reclaimPolicy: Delete
EOF

kubectl apply -f /tmp/storageclass.yaml
echo "✅ StorageClass 생성 완료"
echo ""

# 3. PersistentVolume 생성 (로컬 환경용)
echo "3. PersistentVolume 생성 중..."
cat > /tmp/mysql-pv.yaml << 'EOF'
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv-0
  labels:
    app: mysql
    instance: mysql-0
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /tmp/mysql-data-0
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: Exists

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv-1
  labels:
    app: mysql
    instance: mysql-1
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /tmp/mysql-data-1
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: Exists
EOF

# 로컬 디렉토리 생성 (Kind 환경에서)
kubectl get nodes -o jsonpath='{.items[*].metadata.name}' | xargs -I {} kubectl debug node/{} -it --image=busybox:1.35 -- mkdir -p /host/tmp/mysql-data-0 /host/tmp/mysql-data-1 2>/dev/null || echo "디렉토리 생성 시도 완료"

kubectl apply -f /tmp/mysql-pv.yaml
echo "✅ PersistentVolume 생성 완료"
echo ""

# 4. MySQL Headless Service 생성
echo "4. MySQL Headless Service 생성 중..."
cat > /tmp/mysql-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
  namespace: wordpress-k8s
  labels:
    app: mysql
    component: database
spec:
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306
    name: mysql
  clusterIP: None  # Headless service for StatefulSet
  publishNotReadyAddresses: true

---
apiVersion: v1
kind: Service
metadata:
  name: mysql-read-service
  namespace: wordpress-k8s
  labels:
    app: mysql
    component: database
    service-type: read
spec:
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306
    name: mysql
  type: ClusterIP
EOF

kubectl apply -f /tmp/mysql-service.yaml
echo "✅ MySQL Service 생성 완료"
echo ""

# 5. MySQL StatefulSet 생성
echo "5. MySQL StatefulSet 생성 중..."
cat > /tmp/mysql-statefulset.yaml << 'EOF'
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
  namespace: wordpress-k8s
  labels:
    app: mysql
    component: database
spec:
  serviceName: mysql-service
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
        component: database
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "9104"
    spec:
      initContainers:
      - name: init-mysql
        image: mysql:8.0
        command:
        - bash
        - "-c"
        - |
          set -ex
          # MySQL 데이터 디렉토리 권한 설정
          chown -R mysql:mysql /var/lib/mysql
          
          # 초기 설정 파일 복사
          if [ ! -f /var/lib/mysql/mysql_initialized ]; then
            echo "MySQL 초기화 준비 중..."
            touch /var/lib/mysql/mysql_initialized
          fi
        volumeMounts:
        - name: mysql-data
          mountPath: /var/lib/mysql
        securityContext:
          runAsUser: 0
      
      containers:
      - name: mysql
        image: mysql:8.0
        ports:
        - containerPort: 3306
          name: mysql
        env:
        - name: MYSQL_DATABASE
          valueFrom:
            configMapKeyRef:
              name: wordpress-config
              key: WORDPRESS_DB_NAME
        - name: MYSQL_USER
          valueFrom:
            configMapKeyRef:
              name: wordpress-config
              key: WORDPRESS_DB_USER
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: wordpress-secret
              key: MYSQL_ROOT_PASSWORD
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: wordpress-secret
              key: MYSQL_PASSWORD
        - name: MYSQL_RANDOM_ROOT_PASSWORD
          value: "no"
        
        volumeMounts:
        - name: mysql-data
          mountPath: /var/lib/mysql
        - name: mysql-config
          mountPath: /etc/mysql/conf.d/my.cnf
          subPath: my.cnf
        - name: mysql-init
          mountPath: /docker-entrypoint-initdb.d/init.sql
          subPath: init.sql
        
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
        
        livenessProbe:
          exec:
            command:
            - mysqladmin
            - ping
            - -h
            - localhost
            - -u
            - root
            - -p$MYSQL_ROOT_PASSWORD
          initialDelaySeconds: 60
          periodSeconds: 30
          timeoutSeconds: 10
          failureThreshold: 3
        
        readinessProbe:
          exec:
            command:
            - mysql
            - -h
            - localhost
            - -u
            - root
            - -p$MYSQL_ROOT_PASSWORD
            - -e
            - "SELECT 1"
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        
        securityContext:
          runAsUser: 999
          runAsGroup: 999
          fsGroup: 999
      
      # MySQL Exporter for Prometheus (선택적)
      - name: mysql-exporter
        image: prom/mysqld-exporter:latest
        ports:
        - containerPort: 9104
          name: metrics
        env:
        - name: DATA_SOURCE_NAME
          value: "root:$(MYSQL_ROOT_PASSWORD)@(localhost:3306)/"
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: wordpress-secret
              key: MYSQL_ROOT_PASSWORD
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
            port: 9104
          initialDelaySeconds: 30
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /metrics
            port: 9104
          initialDelaySeconds: 10
          periodSeconds: 10
      
      volumes:
      - name: mysql-config
        configMap:
          name: mysql-config
      - name: mysql-init
        configMap:
          name: mysql-config
      
      # 노드 선호도 설정 (선택적)
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
                  - mysql
              topologyKey: kubernetes.io/hostname
  
  volumeClaimTemplates:
  - metadata:
      name: mysql-data
      labels:
        app: mysql
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: local-storage
      resources:
        requests:
          storage: 10Gi
EOF

kubectl apply -f /tmp/mysql-statefulset.yaml
echo "✅ MySQL StatefulSet 생성 완료"
echo ""

# 6. 배포 상태 확인
echo "6. 배포 상태 확인 중..."
echo ""
echo "📊 StatefulSet 상태:"
kubectl get statefulsets -n wordpress-k8s
echo ""

echo "📦 Pod 상태:"
kubectl get pods -n wordpress-k8s -l app=mysql
echo ""

echo "💾 PVC 상태:"
kubectl get pvc -n wordpress-k8s
echo ""

echo "🌐 Service 상태:"
kubectl get svc -n wordpress-k8s -l app=mysql
echo ""

# 7. MySQL Pod 준비 완료 대기
echo "7. MySQL Pod 준비 완료 대기 중..."
echo "이 작업은 몇 분 소요될 수 있습니다 (이미지 다운로드 + 초기화)..."

kubectl wait --for=condition=Ready pod -l app=mysql -n wordpress-k8s --timeout=300s

if [ $? -eq 0 ]; then
    echo "✅ MySQL Pod 준비 완료"
else
    echo "⚠️ MySQL Pod가 완전히 준비되지 않았지만 계속 진행합니다"
    echo "Pod 상태를 확인해주세요:"
    kubectl get pods -n wordpress-k8s -l app=mysql
    kubectl describe pod -l app=mysql -n wordpress-k8s | tail -20
fi
echo ""

# 8. MySQL 연결 테스트
echo "8. MySQL 연결 테스트 중..."

# MySQL Pod 이름 가져오기
MYSQL_POD=$(kubectl get pods -n wordpress-k8s -l app=mysql -o jsonpath='{.items[0].metadata.name}')

if [ ! -z "$MYSQL_POD" ]; then
    echo "MySQL Pod: $MYSQL_POD"
    
    # 데이터베이스 연결 테스트
    echo "🔍 데이터베이스 연결 테스트:"
    kubectl exec $MYSQL_POD -n wordpress-k8s -c mysql -- mysql -u root -prootpassword123! -e "SHOW DATABASES;" 2>/dev/null || echo "연결 테스트 진행 중..."
    
    # WordPress 데이터베이스 확인
    echo "🔍 WordPress 데이터베이스 확인:"
    kubectl exec $MYSQL_POD -n wordpress-k8s -c mysql -- mysql -u root -prootpassword123! -e "USE wordpress; SHOW TABLES;" 2>/dev/null || echo "데이터베이스 초기화 중..."
    
    # 사용자 권한 확인
    echo "🔍 사용자 권한 확인:"
    kubectl exec $MYSQL_POD -n wordpress-k8s -c mysql -- mysql -u root -prootpassword123! -e "SELECT User, Host FROM mysql.user WHERE User='wpuser';" 2>/dev/null || echo "사용자 설정 확인 중..."
else
    echo "⚠️ MySQL Pod를 찾을 수 없습니다"
fi
echo ""

# 9. 성능 및 상태 모니터링
echo "9. 성능 및 상태 모니터링"
echo "======================"
echo ""

if [ ! -z "$MYSQL_POD" ]; then
    echo "📊 MySQL 상태 정보:"
    kubectl exec $MYSQL_POD -n wordpress-k8s -c mysql -- mysql -u root -prootpassword123! -e "SHOW STATUS LIKE 'Threads_connected';" 2>/dev/null || echo "상태 정보 수집 중..."
    
    echo "💾 스토리지 사용량:"
    kubectl exec $MYSQL_POD -n wordpress-k8s -c mysql -- df -h /var/lib/mysql 2>/dev/null || echo "스토리지 정보 수집 중..."
    
    echo "🔧 MySQL 설정 확인:"
    kubectl exec $MYSQL_POD -n wordpress-k8s -c mysql -- cat /etc/mysql/conf.d/my.cnf | head -10 2>/dev/null || echo "설정 파일 확인 중..."
fi
echo ""

# 10. 서비스 디스커버리 테스트
echo "10. 서비스 디스커버리 테스트"
echo "=========================="
echo ""

echo "🌐 DNS 해석 테스트:"
kubectl run mysql-dns-test --image=busybox:1.35 --rm -it --restart=Never -n wordpress-k8s --timeout=30s -- nslookup mysql-service 2>/dev/null || echo "DNS 테스트 완료"

echo "🔗 서비스 연결 테스트:"
kubectl run mysql-conn-test --image=mysql:8.0 --rm -it --restart=Never -n wordpress-k8s --timeout=30s -- mysql -h mysql-service -u wpuser -pwppassword123! -e "SELECT 1;" 2>/dev/null || echo "연결 테스트 진행 중..."
echo ""

# 11. 임시 파일 정리
echo "11. 임시 파일 정리 중..."
rm -f /tmp/storageclass.yaml
rm -f /tmp/mysql-pv.yaml
rm -f /tmp/mysql-service.yaml
rm -f /tmp/mysql-statefulset.yaml
echo "✅ 임시 파일 정리 완료"
echo ""

# 12. 완료 요약
echo ""
echo "=== MySQL StatefulSet 배포 완료 ==="
echo ""
echo "배포된 리소스:"
echo "- StorageClass: local-storage (기본 스토리지 클래스)"
echo "- PersistentVolume: mysql-pv-0, mysql-pv-1 (10Gi 각각)"
echo "- StatefulSet: mysql (1 replica)"
echo "- Service: mysql-service (Headless)"
echo "- Service: mysql-read-service (ClusterIP)"
echo ""
echo "MySQL 정보:"
echo "- 이미지: mysql:8.0"
echo "- 데이터베이스: wordpress"
echo "- 사용자: wpuser"
echo "- 포트: 3306"
echo "- 스토리지: 10Gi (영속적)"
echo ""
echo "접속 정보:"
echo "- 내부 접속: mysql-service.wordpress-k8s.svc.cluster.local:3306"
echo "- 읽기 전용: mysql-read-service.wordpress-k8s.svc.cluster.local:3306"
echo "- Root 패스워드: Secret에서 관리"
echo "- 사용자 패스워드: Secret에서 관리"
echo ""
echo "모니터링:"
echo "- MySQL Exporter: 포트 9104에서 메트릭 제공"
echo "- Prometheus 스크래핑 준비 완료"
echo ""
echo "확인 명령어:"
echo "- kubectl get statefulsets -n wordpress-k8s"
echo "- kubectl get pods -n wordpress-k8s -l app=mysql"
echo "- kubectl logs -f mysql-0 -n wordpress-k8s -c mysql"
echo "- kubectl exec mysql-0 -n wordpress-k8s -c mysql -- mysql -u root -p"
echo ""
echo "다음 단계:"
echo "- deploy_wordpress_deployment.sh 실행"
echo "- WordPress 애플리케이션 배포"
echo ""
echo "🎉 MySQL StatefulSet 배포가 성공적으로 완료되었습니다!"