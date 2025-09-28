#!/bin/bash

# Week 2 Day 4 Lab 2: 실습 환경 완전 정리 스크립트
# 사용법: ./cleanup.sh

echo "=== WordPress K8s 마이그레이션 실습 환경 정리 시작 ==="
echo ""

# 사용자 확인
read -p "모든 실습 환경을 정리하시겠습니까? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "정리 작업이 취소되었습니다."
    exit 0
fi

echo "실습 환경 정리를 시작합니다..."
echo ""

# 1. 포트 포워딩 프로세스 종료
echo "1. 포트 포워딩 프로세스 종료 중..."
pkill -f "kubectl port-forward.*ingress-nginx" 2>/dev/null || echo "포트 포워딩 프로세스 없음"
pkill -f "kubectl port-forward.*wordpress" 2>/dev/null || echo "WordPress 포트 포워딩 없음"
echo "✅ 포트 포워딩 프로세스 종료 완료"
echo ""

# 2. WordPress 네임스페이스 리소스 정리
echo "2. WordPress 네임스페이스 리소스 정리 중..."

echo "  📋 현재 wordpress-k8s 네임스페이스 리소스:"
kubectl get all -n wordpress-k8s 2>/dev/null || echo "  네임스페이스가 존재하지 않습니다"
echo ""

if kubectl get namespace wordpress-k8s &> /dev/null; then
    echo "  🗑️ Ingress 리소스 삭제 중..."
    kubectl delete ingress --all -n wordpress-k8s --timeout=60s 2>/dev/null || echo "  Ingress 리소스 없음"
    
    echo "  🗑️ HPA 리소스 삭제 중..."
    kubectl delete hpa --all -n wordpress-k8s --timeout=60s 2>/dev/null || echo "  HPA 리소스 없음"
    
    echo "  🗑️ Service 리소스 삭제 중..."
    kubectl delete svc --all -n wordpress-k8s --timeout=60s 2>/dev/null || echo "  Service 리소스 없음"
    
    echo "  🗑️ Deployment 리소스 삭제 중..."
    kubectl delete deployment --all -n wordpress-k8s --timeout=120s 2>/dev/null || echo "  Deployment 리소스 없음"
    
    echo "  🗑️ StatefulSet 리소스 삭제 중..."
    kubectl delete statefulset --all -n wordpress-k8s --timeout=120s 2>/dev/null || echo "  StatefulSet 리소스 없음"
    
    echo "  🗑️ PVC 리소스 삭제 중..."
    kubectl delete pvc --all -n wordpress-k8s --timeout=60s 2>/dev/null || echo "  PVC 리소스 없음"
    
    echo "  🗑️ ConfigMap 리소스 삭제 중..."
    kubectl delete configmap --all -n wordpress-k8s --timeout=30s 2>/dev/null || echo "  ConfigMap 리소스 없음"
    
    echo "  🗑️ Secret 리소스 삭제 중..."
    kubectl delete secret --all -n wordpress-k8s --timeout=30s 2>/dev/null || echo "  Secret 리소스 없음"
    
    echo "  🗑️ wordpress-k8s 네임스페이스 삭제 중..."
    kubectl delete namespace wordpress-k8s --timeout=120s 2>/dev/null || echo "  네임스페이스 삭제 실패"
    
    echo "✅ WordPress 네임스페이스 정리 완료"
else
    echo "✅ wordpress-k8s 네임스페이스가 이미 삭제됨"
fi
echo ""

# 3. 모니터링 네임스페이스 정리
echo "3. 모니터링 네임스페이스 정리 중..."

if kubectl get namespace monitoring-k8s &> /dev/null; then
    echo "  📋 현재 monitoring-k8s 네임스페이스 리소스:"
    kubectl get all -n monitoring-k8s 2>/dev/null || echo "  리소스 없음"
    
    echo "  🗑️ monitoring-k8s 네임스페이스 삭제 중..."
    kubectl delete namespace monitoring-k8s --timeout=60s 2>/dev/null || echo "  네임스페이스 삭제 실패"
    
    echo "✅ 모니터링 네임스페이스 정리 완료"
else
    echo "✅ monitoring-k8s 네임스페이스가 이미 삭제됨"
fi
echo ""

# 4. Lab 1 리소스 정리 (선택적)
echo "4. Lab 1 리소스 정리 확인..."
read -p "Lab 1 리소스(lab-demo 네임스페이스)도 정리하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if kubectl get namespace lab-demo &> /dev/null; then
        echo "  🗑️ lab-demo 네임스페이스 삭제 중..."
        kubectl delete namespace lab-demo --timeout=120s 2>/dev/null || echo "  네임스페이스 삭제 실패"
        echo "✅ Lab 1 리소스 정리 완료"
    else
        echo "✅ lab-demo 네임스페이스가 이미 삭제됨"
    fi
else
    echo "⏭️ Lab 1 리소스 유지"
fi
echo ""

# 5. PersistentVolume 정리
echo "5. PersistentVolume 정리 중..."

echo "  📋 현재 PV 상태:"
kubectl get pv 2>/dev/null || echo "  PV 없음"

# WordPress 관련 PV 삭제
kubectl get pv -o name | grep -E "(mysql|wordpress|wp-)" | xargs -r kubectl delete --timeout=60s 2>/dev/null || echo "  WordPress 관련 PV 없음"

# Lab 1 관련 PV 삭제 (선택적)
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl get pv -o name | grep -E "(demo|nginx)" | xargs -r kubectl delete --timeout=60s 2>/dev/null || echo "  Lab 1 관련 PV 없음"
fi

echo "✅ PersistentVolume 정리 완료"
echo ""

# 6. StorageClass 정리 (선택적)
echo "6. StorageClass 정리 확인..."
read -p "생성한 StorageClass(local-storage)도 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl delete storageclass local-storage --timeout=30s 2>/dev/null || echo "  StorageClass 삭제 실패 또는 없음"
    echo "✅ StorageClass 정리 완료"
else
    echo "⏭️ StorageClass 유지"
fi
echo ""

# 7. NGINX Ingress Controller 정리 (선택적)
echo "7. NGINX Ingress Controller 정리 확인..."
read -p "NGINX Ingress Controller도 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "  🗑️ NGINX Ingress Controller 삭제 중..."
    kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/kind/deploy.yaml --timeout=120s 2>/dev/null || echo "  Ingress Controller 삭제 실패"
    
    # ingress-nginx 네임스페이스 삭제
    kubectl delete namespace ingress-nginx --timeout=120s 2>/dev/null || echo "  ingress-nginx 네임스페이스 삭제 실패"
    
    echo "✅ NGINX Ingress Controller 정리 완료"
else
    echo "⏭️ NGINX Ingress Controller 유지"
fi
echo ""

# 8. 클러스터 정리 (선택적)
echo "8. 클러스터 정리 확인..."
read -p "전체 K8s 클러스터(k8s-lab-cluster)도 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "  🗑️ Kind 클러스터 삭제 중..."
    if command -v kind &> /dev/null; then
        kind delete cluster --name k8s-lab-cluster 2>/dev/null || echo "  클러스터 삭제 실패 또는 없음"
        echo "✅ K8s 클러스터 정리 완료"
    else
        echo "  ⚠️ kind 명령어를 찾을 수 없습니다"
    fi
else
    echo "⏭️ K8s 클러스터 유지"
fi
echo ""

# 9. 로컬 데이터 정리
echo "9. 로컬 데이터 정리 중..."

echo "  🗑️ 임시 파일 정리..."
rm -f /tmp/mysql-*.yaml 2>/dev/null || true
rm -f /tmp/wordpress-*.yaml 2>/dev/null || true
rm -f /tmp/monitoring-*.yaml 2>/dev/null || true
rm -f /tmp/storageclass.yaml 2>/dev/null || true
rm -f /tmp/configmap.yaml 2>/dev/null || true
rm -f /tmp/deployment.yaml 2>/dev/null || true
rm -f /tmp/service*.yaml 2>/dev/null || true
rm -f /tmp/ingress*.yaml 2>/dev/null || true
rm -f /tmp/auth 2>/dev/null || true
rm -f /tmp/tls.* 2>/dev/null || true
rm -f /tmp/hosts-setup.txt 2>/dev/null || true

echo "  🗑️ Kind 볼륨 데이터 정리 시도..."
# Kind 컨테이너가 실행 중인 경우 데이터 정리
if docker ps --format "table {{.Names}}" | grep -q "k8s-lab-cluster"; then
    docker exec k8s-lab-cluster-control-plane rm -rf /tmp/mysql-data* 2>/dev/null || true
    docker exec k8s-lab-cluster-worker rm -rf /tmp/mysql-data* 2>/dev/null || true
    docker exec k8s-lab-cluster-worker2 rm -rf /tmp/mysql-data* 2>/dev/null || true
fi

echo "✅ 로컬 데이터 정리 완료"
echo ""

# 10. 정리 결과 확인
echo "10. 정리 결과 확인"
echo "================"
echo ""

echo "📊 남은 네임스페이스:"
kubectl get namespaces 2>/dev/null | grep -E "(wordpress|monitoring|lab-demo)" || echo "  관련 네임스페이스 없음"
echo ""

echo "💾 남은 PV:"
kubectl get pv 2>/dev/null | grep -E "(mysql|wordpress|demo)" || echo "  관련 PV 없음"
echo ""

echo "🌐 Ingress Controller 상태:"
kubectl get pods -n ingress-nginx 2>/dev/null || echo "  Ingress Controller 없음"
echo ""

echo "🐳 Kind 클러스터 상태:"
if command -v kind &> /dev/null; then
    kind get clusters 2>/dev/null | grep k8s-lab-cluster || echo "  k8s-lab-cluster 없음"
else
    echo "  kind 명령어 없음"
fi
echo ""

# 11. 완료 요약
echo ""
echo "=== 실습 환경 정리 완료 ==="
echo ""
echo "정리된 리소스:"
echo "- ✅ WordPress 애플리케이션 (Deployment, Service, Ingress)"
echo "- ✅ MySQL 데이터베이스 (StatefulSet, PVC)"
echo "- ✅ 설정 및 시크릿 (ConfigMap, Secret)"
echo "- ✅ 네트워킹 (Ingress, Service)"
echo "- ✅ 스토리지 (PVC, PV)"
echo "- ✅ 임시 파일 및 로컬 데이터"
echo ""

if kubectl cluster-info &> /dev/null; then
    echo "🔄 클러스터 상태: 실행 중"
    echo "  - 클러스터는 유지되어 다른 실습에 사용 가능"
    echo "  - 완전 정리를 원하면 다시 실행하여 클러스터도 삭제"
else
    echo "🛑 클러스터 상태: 정리됨"
    echo "  - 모든 K8s 리소스가 완전히 정리됨"
    echo "  - 새로운 실습을 위해서는 클러스터 재구축 필요"
fi
echo ""

echo "📚 다음 단계:"
echo "- Week 3에서 Kubernetes 고급 기능 학습"
echo "- 실제 프로젝트에서 K8s 마이그레이션 적용"
echo "- CI/CD 파이프라인과 K8s 통합"
echo ""

echo "🎓 학습 성과:"
echo "- ✅ Docker → K8s 마이그레이션 경험"
echo "- ✅ K8s 핵심 오브젝트 실무 활용"
echo "- ✅ 설정 관리 및 보안 적용"
echo "- ✅ 네트워킹 및 Ingress 구성"
echo "- ✅ 스토리지 및 데이터 영속성"
echo ""

echo "🎉 Week 2 Day 4 Lab 2 실습이 성공적으로 완료되었습니다!"
echo "수고하셨습니다! 🚀"