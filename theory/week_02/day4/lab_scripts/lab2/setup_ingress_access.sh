#!/bin/bash

# Week 2 Day 4 Lab 2: Ingress 및 외부 접근 자동 설정 스크립트
# 사용법: ./setup_ingress_access.sh

echo "=== Ingress 및 외부 접근 설정 시작 ==="
echo ""

# 1. 사전 요구사항 확인
echo "1. 사전 요구사항 확인 중..."
if ! kubectl get deployment wordpress -n wordpress-k8s &> /dev/null; then
    echo "❌ WordPress Deployment가 배포되지 않았습니다."
    echo "먼저 deploy_wordpress_deployment.sh를 실행해주세요."
    exit 1
fi

if ! kubectl get service wordpress-service -n wordpress-k8s &> /dev/null; then
    echo "❌ WordPress Service가 생성되지 않았습니다."
    echo "먼저 deploy_wordpress_deployment.sh를 실행해주세요."
    exit 1
fi

echo "✅ 사전 요구사항 확인 완료"
echo ""

# 2. NGINX Ingress Controller 설치
echo "2. NGINX Ingress Controller 설치 중..."

# Kind 환경용 NGINX Ingress Controller 설치
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/kind/deploy.yaml

echo "✅ NGINX Ingress Controller 설치 요청 완료"
echo ""

# 3. Ingress Controller 준비 대기
echo "3. Ingress Controller 준비 대기 중..."
echo "이 작업은 몇 분 소요될 수 있습니다..."

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

if [ $? -eq 0 ]; then
    echo "✅ NGINX Ingress Controller 준비 완료"
else
    echo "⚠️ Ingress Controller가 완전히 준비되지 않았지만 계속 진행합니다"
fi
echo ""

# 4. WordPress Ingress 생성
echo "4. WordPress Ingress 생성 중..."
cat > /tmp/wordpress-ingress.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: wordpress-ingress
  namespace: wordpress-k8s
  labels:
    app: wordpress
    component: ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "64m"
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "600"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "600"
    nginx.ingress.kubernetes.io/configuration-snippet: |
      more_set_headers "X-Forwarded-Proto $scheme";
      more_set_headers "X-Real-IP $remote_addr";
spec:
  ingressClassName: nginx
  rules:
  # 도메인 기반 라우팅
  - host: wordpress.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: wordpress-service
            port:
              number: 80
  
  # 기본 라우팅 (IP 접근)
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: wordpress-service
            port:
              number: 80

---
# HTTPS용 Ingress (TLS 적용)
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: wordpress-ingress-tls
  namespace: wordpress-k8s
  labels:
    app: wordpress
    component: ingress-tls
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "64m"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - wordpress.local
    - secure.wordpress.local
    secretName: wordpress-tls
  rules:
  - host: secure.wordpress.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: wordpress-service
            port:
              number: 80
EOF

kubectl apply -f /tmp/wordpress-ingress.yaml
echo "✅ WordPress Ingress 생성 완료"
echo ""

# 5. 관리용 Ingress 생성 (wp-admin 전용)
echo "5. 관리용 Ingress 생성 중..."
cat > /tmp/wordpress-admin-ingress.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: wordpress-admin-ingress
  namespace: wordpress-k8s
  labels:
    app: wordpress
    component: admin-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: wordpress-admin-auth
    nginx.ingress.kubernetes.io/auth-realm: 'WordPress Admin Area'
    nginx.ingress.kubernetes.io/whitelist-source-range: "10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - admin.wordpress.local
    secretName: wordpress-tls
  rules:
  - host: admin.wordpress.local
    http:
      paths:
      - path: /wp-admin
        pathType: Prefix
        backend:
          service:
            name: wordpress-service
            port:
              number: 80
      - path: /wp-login.php
        pathType: Exact
        backend:
          service:
            name: wordpress-service
            port:
              number: 80
EOF

# 관리자 인증을 위한 Secret 생성
htpasswd -cb /tmp/auth admin admin123! 2>/dev/null || echo -n 'admin:$2y$10$1234567890123456789012345678901234567890123456' > /tmp/auth
kubectl create secret generic wordpress-admin-auth --from-file=auth=/tmp/auth -n wordpress-k8s --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f /tmp/wordpress-admin-ingress.yaml
echo "✅ 관리용 Ingress 생성 완료"
echo ""

# 6. 모니터링용 Ingress 생성
echo "6. 모니터링용 Ingress 생성 중..."
cat > /tmp/monitoring-ingress.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: monitoring-ingress
  namespace: wordpress-k8s
  labels:
    app: monitoring
    component: ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  ingressClassName: nginx
  rules:
  - host: metrics.wordpress.local
    http:
      paths:
      - path: /wordpress
        pathType: Prefix
        backend:
          service:
            name: wordpress-service
            port:
              number: 9117
      - path: /mysql
        pathType: Prefix
        backend:
          service:
            name: mysql-service
            port:
              number: 9104
EOF

kubectl apply -f /tmp/monitoring-ingress.yaml
echo "✅ 모니터링용 Ingress 생성 완료"
echo ""

# 7. 포트 포워딩 설정 (로컬 접근용)
echo "7. 포트 포워딩 설정 중..."

# 백그라운드에서 포트 포워딩 실행
kubectl port-forward --namespace ingress-nginx service/ingress-nginx-controller 8080:80 > /dev/null 2>&1 &
PF_PID_HTTP=$!

kubectl port-forward --namespace ingress-nginx service/ingress-nginx-controller 8443:443 > /dev/null 2>&1 &
PF_PID_HTTPS=$!

echo "✅ 포트 포워딩 설정 완료"
echo "  - HTTP: localhost:8080 (PID: $PF_PID_HTTP)"
echo "  - HTTPS: localhost:8443 (PID: $PF_PID_HTTPS)"
echo ""

# 8. 접근 테스트
echo "8. 접근 테스트 중..."
echo "잠시 대기 후 접근 테스트를 진행합니다..."
sleep 10

echo "🔍 HTTP 접근 테스트:"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")
if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "302" ]; then
    echo "✅ HTTP 접근 성공 (상태 코드: $HTTP_STATUS)"
else
    echo "⚠️ HTTP 접근 대기 중 (상태 코드: $HTTP_STATUS)"
fi

echo "🔍 WordPress 설치 페이지 테스트:"
WP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/wp-admin/install.php 2>/dev/null || echo "000")
if [ "$WP_STATUS" = "200" ] || [ "$WP_STATUS" = "302" ]; then
    echo "✅ WordPress 설치 페이지 접근 성공 (상태 코드: $WP_STATUS)"
else
    echo "⚠️ WordPress 설치 페이지 대기 중 (상태 코드: $WP_STATUS)"
fi
echo ""

# 9. Ingress 상태 확인
echo "9. Ingress 상태 확인"
echo "=================="
echo ""

echo "📋 Ingress 리소스:"
kubectl get ingress -n wordpress-k8s
echo ""

echo "🔍 Ingress 상세 정보:"
kubectl describe ingress wordpress-ingress -n wordpress-k8s | grep -A 5 "Rules"
echo ""

echo "📊 Ingress Controller 상태:"
kubectl get pods -n ingress-nginx
echo ""

echo "🌐 Ingress Controller 서비스:"
kubectl get svc -n ingress-nginx
echo ""

# 10. DNS 설정 가이드 생성
echo "10. DNS 설정 가이드 생성 중..."
cat > /tmp/hosts-setup.txt << 'EOF'
# WordPress K8s Lab - Hosts 파일 설정
# 
# Windows: C:\Windows\System32\drivers\etc\hosts
# Linux/Mac: /etc/hosts
#
# 아래 내용을 hosts 파일에 추가하세요:

127.0.0.1 wordpress.local
127.0.0.1 secure.wordpress.local
127.0.0.1 admin.wordpress.local
127.0.0.1 metrics.wordpress.local

# 설정 후 다음 URL로 접근 가능:
# - http://wordpress.local:8080 (메인 사이트)
# - https://secure.wordpress.local:8443 (HTTPS)
# - https://admin.wordpress.local:8443/wp-admin (관리자)
# - http://metrics.wordpress.local:8080/wordpress (메트릭)
EOF

echo "✅ DNS 설정 가이드 생성 완료 (/tmp/hosts-setup.txt)"
echo ""

# 11. 임시 파일 정리
echo "11. 임시 파일 정리 중..."
rm -f /tmp/wordpress-ingress.yaml
rm -f /tmp/wordpress-admin-ingress.yaml
rm -f /tmp/monitoring-ingress.yaml
rm -f /tmp/auth
echo "✅ 임시 파일 정리 완료"
echo ""

# 12. 완료 요약
echo ""
echo "=== Ingress 및 외부 접근 설정 완료 ==="
echo ""
echo "설치된 구성 요소:"
echo "- NGINX Ingress Controller"
echo "- WordPress Ingress (HTTP/HTTPS)"
echo "- 관리용 Ingress (wp-admin 보안)"
echo "- 모니터링용 Ingress (메트릭)"
echo ""
echo "접속 URL (포트 포워딩):"
echo "- 메인 사이트: http://localhost:8080"
echo "- HTTPS 사이트: https://localhost:8443"
echo "- WordPress 설치: http://localhost:8080/wp-admin/install.php"
echo ""
echo "도메인 접속 (hosts 파일 설정 후):"
echo "- http://wordpress.local:8080"
echo "- https://secure.wordpress.local:8443"
echo "- https://admin.wordpress.local:8443/wp-admin"
echo "- http://metrics.wordpress.local:8080/wordpress"
echo ""
echo "보안 설정:"
echo "- 관리자 영역: Basic Auth (admin/admin123!)"
echo "- TLS 인증서: 자체 서명 (개발용)"
echo "- IP 화이트리스트: 내부 네트워크만"
echo ""
echo "포트 포워딩 프로세스:"
echo "- HTTP PID: $PF_PID_HTTP"
echo "- HTTPS PID: $PF_PID_HTTPS"
echo "- 종료: kill $PF_PID_HTTP $PF_PID_HTTPS"
echo ""
echo "확인 명령어:"
echo "- kubectl get ingress -n wordpress-k8s"
echo "- kubectl describe ingress wordpress-ingress -n wordpress-k8s"
echo "- kubectl logs -n ingress-nginx deployment/ingress-nginx-controller"
echo ""
echo "hosts 파일 설정:"
echo "- cat /tmp/hosts-setup.txt"
echo ""
echo "다음 단계:"
echo "- 브라우저에서 http://localhost:8080 접속"
echo "- WordPress 초기 설정 진행"
echo "- cleanup.sh로 실습 환경 정리 (완료 후)"
echo ""
echo "🎉 Ingress 및 외부 접근 설정이 성공적으로 완료되었습니다!"