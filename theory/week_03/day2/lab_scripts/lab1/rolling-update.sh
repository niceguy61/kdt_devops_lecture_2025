#!/bin/bash

# Week 3 Day 2 Lab 1: 롤링 업데이트 실습
# 사용법: ./rolling-update.sh

echo "=== 롤링 업데이트 실습 시작 ==="

# 1. 현재 상태 확인
echo "1. 현재 Deployment 상태 확인:"
echo "================================"

if kubectl get deployment web-deployment >/dev/null 2>&1; then
    kubectl get deployment web-deployment -o wide
    kubectl get pods -l app=web -o wide
    
    echo ""
    echo "현재 이미지 버전:"
    kubectl get deployment web-deployment -o jsonpath='{.spec.template.spec.containers[0].image}'
    echo ""
else
    echo "⚠️  web-deployment가 존재하지 않습니다. 먼저 생성합니다..."
    
    # 기본 Deployment 생성
    kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
  labels:
    app: web
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
        version: v1
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
EOF
    
    echo "기본 Deployment 생성 완료. 잠시 대기..."
    sleep 10
fi

echo ""
echo "================================"

# 2. 롤링 업데이트 시작
echo "2. 롤링 업데이트 시작 (nginx:1.20 → nginx:1.22):"
echo "================================"

echo "업데이트 전 Pod 목록:"
kubectl get pods -l app=web -o custom-columns=NAME:.metadata.name,IMAGE:.spec.containers[0].image,STATUS:.status.phase

echo ""
echo "이미지 업데이트 실행..."
kubectl set image deployment/web-deployment nginx=nginx:1.22

echo ""
echo "롤링 업데이트 진행 상황 모니터링:"
echo "(Ctrl+C로 중단 가능, 백그라운드에서 계속 진행됩니다)"

# 롤링 업데이트 상태를 실시간으로 모니터링
kubectl rollout status deployment/web-deployment --timeout=300s

if [ $? -eq 0 ]; then
    echo "✅ 롤링 업데이트 완료"
else
    echo "⚠️  롤링 업데이트 타임아웃 또는 실패"
fi

echo ""
echo "업데이트 후 Pod 목록:"
kubectl get pods -l app=web -o custom-columns=NAME:.metadata.name,IMAGE:.spec.containers[0].image,STATUS:.status.phase

echo ""
echo "================================"

# 3. 업데이트 히스토리 확인
echo "3. 업데이트 히스토리 확인:"
echo "================================"

kubectl rollout history deployment/web-deployment

echo ""
echo "최신 리비전 상세 정보:"
kubectl rollout history deployment/web-deployment --revision=$(kubectl rollout history deployment/web-deployment | tail -1 | awk '{print $1}')

echo ""
echo "================================"

# 4. 롤백 테스트
echo "4. 롤백 테스트:"
echo "================================"

echo "이전 버전으로 롤백 실행..."
kubectl rollout undo deployment/web-deployment

echo ""
echo "롤백 진행 상황:"
kubectl rollout status deployment/web-deployment --timeout=300s

if [ $? -eq 0 ]; then
    echo "✅ 롤백 완료"
else
    echo "⚠️  롤백 타임아웃 또는 실패"
fi

echo ""
echo "롤백 후 Pod 목록:"
kubectl get pods -l app=web -o custom-columns=NAME:.metadata.name,IMAGE:.spec.containers[0].image,STATUS:.status.phase

echo ""
echo "================================"

# 5. 특정 리비전으로 롤백 테스트
echo "5. 특정 리비전으로 롤백:"
echo "================================"

echo "현재 히스토리:"
kubectl rollout history deployment/web-deployment

# 다시 최신 버전으로 업데이트
echo ""
echo "다시 nginx:1.22로 업데이트..."
kubectl set image deployment/web-deployment nginx=nginx:1.22
kubectl rollout status deployment/web-deployment --timeout=300s

echo ""
echo "특정 리비전(1번)으로 롤백:"
kubectl rollout undo deployment/web-deployment --to-revision=1
kubectl rollout status deployment/web-deployment --timeout=300s

echo ""
echo "최종 상태:"
kubectl get pods -l app=web -o custom-columns=NAME:.metadata.name,IMAGE:.spec.containers[0].image,STATUS:.status.phase

echo ""
echo "================================"

# 6. 롤링 업데이트 전략 테스트
echo "6. 롤링 업데이트 전략 변경 테스트:"
echo "================================"

echo "현재 롤링 업데이트 전략:"
kubectl get deployment web-deployment -o jsonpath='{.spec.strategy}'
echo ""

echo ""
echo "더 보수적인 전략으로 변경 (maxUnavailable: 0, maxSurge: 1):"
kubectl patch deployment web-deployment -p '{"spec":{"strategy":{"rollingUpdate":{"maxUnavailable":0,"maxSurge":1}}}}'

echo ""
echo "변경된 전략으로 업데이트 테스트:"
kubectl set image deployment/web-deployment nginx=nginx:1.21
kubectl rollout status deployment/web-deployment --timeout=300s

echo ""
echo "업데이트 과정에서 Pod 개수 변화 확인:"
kubectl get deployment web-deployment

echo ""
echo "=== 롤링 업데이트 실습 완료 ==="
echo ""
echo "학습 포인트:"
echo "- 롤링 업데이트: 무중단 서비스 업데이트"
echo "- 롤백: 문제 발생 시 이전 버전으로 신속 복구"
echo "- 히스토리: 모든 배포 이력 추적 가능"
echo "- 전략 조정: maxUnavailable, maxSurge로 업데이트 속도 조절"
echo ""
echo "💡 유용한 명령어:"
echo "- 업데이트 일시정지: kubectl rollout pause deployment/web-deployment"
echo "- 업데이트 재개: kubectl rollout resume deployment/web-deployment"
echo "- 실시간 모니터링: watch kubectl get pods -l app=web"
