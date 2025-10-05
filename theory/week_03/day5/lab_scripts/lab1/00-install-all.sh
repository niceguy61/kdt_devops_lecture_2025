#!/bin/bash

# Week 3 Day 5 Lab 1: 전체 설치 스크립트
# 사용법: ./00-install-all.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Week 3 Day 5 Lab 1: 운영 환경 구축 - 전체 설치          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "⏱️  예상 소요 시간: 약 10-15분"
echo ""

read -p "계속 진행하시겠습니까? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "설치가 취소되었습니다."
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1/5: Helm 설치"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$SCRIPT_DIR/01-install-helm.sh"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2/5: Prometheus Stack 설치"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$SCRIPT_DIR/02-install-prometheus.sh"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3/5: 테스트 애플리케이션 배포"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$SCRIPT_DIR/03-deploy-app.sh"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4/5: Metrics Server 및 HPA 설정"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$SCRIPT_DIR/04-setup-hpa.sh"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 5/5: ArgoCD 설치"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$SCRIPT_DIR/05-install-argocd.sh"

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  🎉 전체 설치 완료!                                       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📊 설치된 컴포넌트:"
echo "   ✅ Helm"
echo "   ✅ Prometheus + Grafana"
echo "   ✅ 테스트 애플리케이션"
echo "   ✅ Metrics Server + HPA"
echo "   ✅ ArgoCD"
echo ""
echo "🌐 접속 정보:"
echo ""
echo "   📊 Prometheus:"
echo "      kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090"
echo "      http://localhost:9090"
echo ""
echo "   📈 Grafana:"
echo "      kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
echo "      http://localhost:3000 (admin/admin123)"
echo ""
echo "   🚀 ArgoCD:"
echo "      kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "      https://localhost:8080"
echo ""
echo "💡 다음 단계:"
echo "   1. Grafana 대시보드 확인"
echo "   2. HPA 부하 테스트"
echo "   3. ArgoCD Application 생성"
echo ""
echo "📚 자세한 내용은 lab_1.md를 참고하세요."
