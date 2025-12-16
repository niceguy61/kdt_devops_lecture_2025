#!/bin/bash

# 샘플 Helm Chart 생성 스크립트

echo "🚀 샘플 Helm Chart 생성 시작..."
echo "=================================="

CHART_NAME="my-web-app"

# Chart 생성
if [ -d "$CHART_NAME" ]; then
    echo "⚠️  기존 Chart 디렉토리가 존재합니다. 삭제 후 재생성합니다."
    rm -rf "$CHART_NAME"
fi

echo "📁 Chart '$CHART_NAME' 생성 중..."
helm create "$CHART_NAME"

# 환경별 Values 디렉토리 생성
echo "📁 환경별 Values 디렉토리 생성 중..."
mkdir -p values/

# Development Values 파일 생성
echo "📝 Development Values 파일 생성 중..."
cat > values/development.yaml << 'EOF'
replicaCount: 1

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "1.21"

service:
  type: ClusterIP
  port: 80

app:
  name: my-web-app
  environment: development

config:
  message: "Development Environment"
  debug: true

resources:
  requests:
    cpu: 100m
    memory: 128Mi
EOF

# Staging Values 파일 생성
echo "📝 Staging Values 파일 생성 중..."
cat > values/staging.yaml << 'EOF'
replicaCount: 2

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "1.21"

service:
  type: LoadBalancer
  port: 80

app:
  name: my-web-app
  environment: staging

config:
  message: "Staging Environment"
  debug: false

resources:
  requests:
    cpu: 250m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi
EOF

# Production Values 파일 생성
echo "📝 Production Values 파일 생성 중..."
cat > values/production.yaml << 'EOF'
replicaCount: 3

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "1.21"

service:
  type: LoadBalancer
  port: 80

app:
  name: my-web-app
  environment: production

config:
  message: "Production Environment"
  debug: false

resources:
  requests:
    cpu: 500m
    memory: 512Mi
  limits:
    cpu: 1000m
    memory: 1Gi

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
EOF

# 기본 values.yaml 수정
echo "📝 기본 values.yaml 수정 중..."
cat > "$CHART_NAME/values.yaml" << 'EOF'
replicaCount: 1

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "1.21"

nameOverride: ""
fullnameOverride: ""

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: false

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

autoscaling:
  enabled: false

nodeSelector: {}
tolerations: []
affinity: {}

# 커스텀 설정
app:
  name: my-web-app
  environment: development

config:
  message: "Hello from Helm Chart!"
  debug: true
EOF

# ConfigMap 템플릿 추가
echo "📝 ConfigMap 템플릿 추가 중..."
cat > "$CHART_NAME/templates/configmap.yaml" << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "my-web-app.fullname" . }}-config
  labels:
    {{- include "my-web-app.labels" . | nindent 4 }}
data:
  message: {{ .Values.config.message | quote }}
  debug: {{ .Values.config.debug | quote }}
  environment: {{ .Values.app.environment | quote }}
  nginx.conf: |
    server {
        listen 80;
        server_name localhost;
        
        location / {
            root /usr/share/nginx/html;
            index index.html index.htm;
        }
        
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
EOF

# Chart 검증
echo "✅ Chart 검증 중..."
helm lint "$CHART_NAME/"

if [ $? -eq 0 ]; then
    echo "✅ Chart 생성 및 검증 완료!"
else
    echo "❌ Chart 검증 실패"
    exit 1
fi

# 생성된 파일 구조 출력
echo -e "\n📋 생성된 파일 구조:"
tree "$CHART_NAME/" 2>/dev/null || find "$CHART_NAME/" -type f | sort

echo -e "\n📋 환경별 Values 파일:"
ls -la values/

echo -e "\n🎯 생성 완료!"
echo "사용법:"
echo "  # 템플릿 렌더링 테스트"
echo "  helm template $CHART_NAME ./$CHART_NAME/"
echo ""
echo "  # Development 환경 배포"
echo "  helm install $CHART_NAME-dev ./$CHART_NAME/ -f values/development.yaml -n development"
echo ""
echo "  # Staging 환경 배포"
echo "  helm install $CHART_NAME-staging ./$CHART_NAME/ -f values/staging.yaml -n staging"
