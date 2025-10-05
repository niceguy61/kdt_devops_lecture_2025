#!/bin/bash

# Week 3 Day 5 Lab 1: 정리 스크립트
# 사용법: ./99-cleanup.sh

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Week 3 Day 5 Lab 1: 환경 정리                           ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "⚠️  다음 리소스들이 삭제됩니다:"
echo "   - HPA (web-app-hpa)"
echo "   - 테스트 애플리케이션 (web-app)"
echo "   - Prometheus Stack"
echo "   - ArgoCD"
echo "   - Namespace (monitoring, argocd)"
echo ""

read -p "정말 삭제하시겠습니까? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "정리가 취소되었습니다."
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. HPA 삭제"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if kubectl get hpa web-app-hpa &> /dev/null; then
    kubectl delete hpa web-app-hpa
    echo "✅ HPA 삭제 완료"
else
    echo "ℹ️  HPA가 존재하지 않습니다."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2. 테스트 애플리케이션 삭제"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if kubectl get deployment web-app &> /dev/null; then
    kubectl delete deployment web-app
    kubectl delete service web-app
    kubectl delete servicemonitor web-app
    echo "✅ 테스트 애플리케이션 삭제 완료"
else
    echo "ℹ️  테스트 애플리케이션이 존재하지 않습니다."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3. Prometheus Stack 삭제"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if helm list -n monitoring | grep -q prometheus; then
    helm uninstall prometheus -n monitoring
    echo "✅ Prometheus Stack 삭제 완료"
else
    echo "ℹ️  Prometheus Stack이 설치되어 있지 않습니다."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4. ArgoCD 삭제"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if kubectl get namespace argocd &> /dev/null; then
    kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    echo "✅ ArgoCD 삭제 완료"
else
    echo "ℹ️  ArgoCD가 설치되어 있지 않습니다."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5. Namespace 삭제"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if kubectl get namespace monitoring &> /dev/null; then
    kubectl delete namespace monitoring
    echo "✅ monitoring Namespace 삭제 완료"
fi

if kubectl get namespace argocd &> /dev/null; then
    kubectl delete namespace argocd
    echo "✅ argocd Namespace 삭제 완료"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6. Metrics Server 삭제 (선택)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

read -p "Metrics Server도 삭제하시겠습니까? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    echo "✅ Metrics Server 삭제 완료"
else
    echo "ℹ️  Metrics Server는 유지됩니다."
fi

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  🎉 정리 완료!                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "✅ 삭제된 리소스:"
echo "   - HPA"
echo "   - 테스트 애플리케이션"
echo "   - Prometheus Stack"
echo "   - ArgoCD"
echo "   - Namespace (monitoring, argocd)"
echo ""
echo "💡 클러스터가 깨끗하게 정리되었습니다."
