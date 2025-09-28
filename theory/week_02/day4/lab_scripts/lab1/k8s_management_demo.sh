#!/bin/bash

# Week 2 Day 4 Lab 1: K8s 관리 명령어 데모 스크립트
# 사용법: ./k8s_management_demo.sh

echo "=== Kubernetes 관리 명령어 실습 시작 ==="
echo ""

# 1. 클러스터 및 리소스 확인
echo "1. 클러스터 및 리소스 상태 확인"
echo "=================================="
echo ""

echo "📊 클러스터 정보:"
kubectl cluster-info
echo ""

echo "🖥️ 노드 상태:"
kubectl get nodes -o wide
echo ""

echo "📦 전체 네임스페이스:"
kubectl get namespaces
echo ""

echo "🔍 lab-demo 네임스페이스 리소스:"
kubectl get all -n lab-demo
echo ""

# 2. Pod 관리 명령어 실습
echo "2. Pod 관리 명령어 실습"
echo "======================"
echo ""

echo "📋 Pod 목록 (다양한 출력 형식):"
echo "기본 형식:"
kubectl get pods -n lab-demo
echo ""

echo "상세 정보 포함:"
kubectl get pods -n lab-demo -o wide
echo ""

echo "YAML 형식 (첫 번째 Pod만):"
POD_NAME=$(kubectl get pods -n lab-demo -l app=nginx -o jsonpath='{.items[0].metadata.name}')
kubectl get pod $POD_NAME -n lab-demo -o yaml | head -20
echo "... (생략)"
echo ""

echo "🔍 Pod 상세 정보:"
kubectl describe pod $POD_NAME -n lab-demo | head -30
echo "... (생략)"
echo ""

echo "📜 Pod 로그 확인:"
echo "최근 10줄 로그:"
kubectl logs $POD_NAME -n lab-demo --tail=10
echo ""

echo "실시간 로그 (5초간):"
timeout 5s kubectl logs -f $POD_NAME -n lab-demo || echo "로그 스트리밍 완료"
echo ""

# 3. Pod 내부 접근 및 디버깅
echo "3. Pod 내부 접근 및 디버깅"
echo "========================="
echo ""

echo "🔧 Pod 내부 명령어 실행:"
echo "Nginx 버전 확인:"
kubectl exec $POD_NAME -n lab-demo -- nginx -v
echo ""

echo "설정 파일 확인:"
kubectl exec $POD_NAME -n lab-demo -- cat /etc/nginx/conf.d/default.conf | head -10
echo ""

echo "프로세스 확인:"
kubectl exec $POD_NAME -n lab-demo -- ps aux
echo ""

echo "네트워크 정보:"
kubectl exec $POD_NAME -n lab-demo -- ip addr show eth0
echo ""

# 4. Service 관리 및 네트워킹
echo "4. Service 관리 및 네트워킹"
echo "========================="
echo ""

echo "🌐 Service 목록:"
kubectl get svc -n lab-demo
echo ""

echo "🔗 Endpoints 확인:"
kubectl get endpoints -n lab-demo
echo ""

echo "📡 Service 상세 정보:"
kubectl describe svc nginx-service -n lab-demo
echo ""

echo "🧪 서비스 디스커버리 테스트:"
echo "DNS 해석 테스트:"
kubectl run dns-test --image=busybox:1.35 --rm -it --restart=Never -n lab-demo -- nslookup nginx-service 2>/dev/null || echo "DNS 테스트 완료"
echo ""

echo "HTTP 연결 테스트:"
kubectl run http-test --image=busybox:1.35 --rm -it --restart=Never -n lab-demo -- wget -qO- nginx-service/health 2>/dev/null || echo "HTTP 테스트 완료"
echo ""

# 5. Deployment 관리 (스케일링, 업데이트)
echo "5. Deployment 관리 (스케일링, 업데이트)"
echo "===================================="
echo ""

echo "📈 현재 Deployment 상태:"
kubectl get deployment nginx-deployment -n lab-demo
echo ""

echo "🔄 스케일링 테스트 (5개로 증가):"
kubectl scale deployment nginx-deployment --replicas=5 -n lab-demo
echo "스케일링 진행 상황:"
kubectl get pods -n lab-demo -l app=nginx
echo ""

echo "⏳ 스케일링 완료 대기 (30초):"
kubectl wait --for=condition=Available deployment/nginx-deployment -n lab-demo --timeout=30s
echo ""

echo "📊 스케일링 후 상태:"
kubectl get deployment nginx-deployment -n lab-demo
kubectl get pods -n lab-demo -l app=nginx
echo ""

echo "🔄 다시 3개로 축소:"
kubectl scale deployment nginx-deployment --replicas=3 -n lab-demo
kubectl get pods -n lab-demo -l app=nginx
echo ""

# 6. 롤링 업데이트 실습
echo "6. 롤링 업데이트 실습"
echo "===================="
echo ""

echo "🚀 이미지 업데이트 (nginx:1.21-alpine → nginx:1.22-alpine):"
kubectl set image deployment/nginx-deployment nginx=nginx:1.22-alpine -n lab-demo
echo ""

echo "📊 롤아웃 상태 확인:"
kubectl rollout status deployment/nginx-deployment -n lab-demo --timeout=60s
echo ""

echo "📜 롤아웃 히스토리:"
kubectl rollout history deployment/nginx-deployment -n lab-demo
echo ""

echo "🔙 롤백 테스트:"
kubectl rollout undo deployment/nginx-deployment -n lab-demo
kubectl rollout status deployment/nginx-deployment -n lab-demo --timeout=60s
echo ""

echo "✅ 롤백 후 상태:"
kubectl get deployment nginx-deployment -n lab-demo
echo ""

# 7. 리소스 모니터링
echo "7. 리소스 모니터링"
echo "=================="
echo ""

echo "💾 노드 리소스 사용량:"
kubectl top nodes 2>/dev/null || echo "Metrics Server가 설치되지 않아 리소스 사용량을 확인할 수 없습니다."
echo ""

echo "📊 Pod 리소스 사용량:"
kubectl top pods -n lab-demo 2>/dev/null || echo "Metrics Server가 설치되지 않아 Pod 리소스 사용량을 확인할 수 없습니다."
echo ""

echo "🔍 Pod 이벤트 확인:"
kubectl get events -n lab-demo --sort-by='.lastTimestamp' | tail -10
echo ""

# 8. 라벨과 셀렉터 활용
echo "8. 라벨과 셀렉터 활용"
echo "==================="
echo ""

echo "🏷️ 라벨 확인:"
kubectl get pods -n lab-demo --show-labels
echo ""

echo "🔍 라벨 셀렉터로 필터링:"
kubectl get pods -n lab-demo -l app=nginx
kubectl get pods -n lab-demo -l version=v1
echo ""

echo "🏷️ 라벨 추가:"
kubectl label pod $POD_NAME -n lab-demo environment=demo
kubectl get pod $POD_NAME -n lab-demo --show-labels
echo ""

# 9. 네임스페이스 관리
echo "9. 네임스페이스 관리"
echo "=================="
echo ""

echo "📁 현재 컨텍스트:"
kubectl config current-context
echo ""

echo "🔧 기본 네임스페이스 변경 (임시):"
kubectl config set-context --current --namespace=lab-demo
echo "변경 후 기본 네임스페이스: $(kubectl config view --minify -o jsonpath='{..namespace}')"
echo ""

echo "📋 기본 네임스페이스에서 리소스 확인:"
kubectl get pods
echo ""

echo "🔄 기본 네임스페이스 복원:"
kubectl config set-context --current --namespace=default
echo ""

# 10. 유용한 kubectl 팁
echo "10. 유용한 kubectl 팁"
echo "====================="
echo ""

echo "⚡ kubectl 별칭 설정 예시:"
echo "alias k='kubectl'"
echo "alias kgp='kubectl get pods'"
echo "alias kgs='kubectl get svc'"
echo "alias kgd='kubectl get deployment'"
echo ""

echo "🔍 리소스 감시 (5초간):"
echo "Pod 상태 실시간 감시:"
timeout 5s kubectl get pods -n lab-demo -w || echo "감시 완료"
echo ""

echo "📊 JSON 경로를 이용한 정보 추출:"
echo "모든 Pod IP 주소:"
kubectl get pods -n lab-demo -o jsonpath='{.items[*].status.podIP}'
echo ""
echo ""

echo "Pod 이름과 상태:"
kubectl get pods -n lab-demo -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}'
echo ""

# 11. 완료 요약
echo ""
echo "=== Kubernetes 관리 명령어 실습 완료 ==="
echo ""
echo "🎯 실습한 주요 명령어:"
echo "- kubectl get: 리소스 조회"
echo "- kubectl describe: 상세 정보 확인"
echo "- kubectl logs: 로그 확인"
echo "- kubectl exec: Pod 내부 명령 실행"
echo "- kubectl scale: 스케일링"
echo "- kubectl rollout: 롤링 업데이트/롤백"
echo "- kubectl label: 라벨 관리"
echo "- kubectl config: 컨텍스트 관리"
echo ""
echo "💡 추가 학습 권장사항:"
echo "- kubectl explain 명령어로 리소스 스키마 확인"
echo "- kubectl patch 명령어로 부분 업데이트"
echo "- kubectl apply vs kubectl create 차이점 이해"
echo "- YAML 매니페스트 파일 작성 연습"
echo ""
echo "다음 단계:"
echo "- test_k8s_environment.sh로 종합 테스트 실행"
echo "- Lab 2에서 실제 애플리케이션 마이그레이션 실습"
echo ""
echo "🎉 K8s 관리 명령어 실습이 완료되었습니다!"