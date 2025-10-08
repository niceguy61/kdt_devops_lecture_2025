#!/bin/bash

# Week 4 Day 1 Lab 1: 아키텍처 분석
# 사용법: ./analyze-architecture.sh

echo "=== 아키텍처 분석 시작 ==="
echo ""

set -e

echo "1/5 배포된 리소스 분석 중..."
echo ""
echo "📊 모놀리스 아키텍처 리소스:"
echo "네임스페이스: ecommerce-monolith"
kubectl get all -n ecommerce-monolith
echo ""
echo "설정 파일 수:"
kubectl get configmaps -n ecommerce-monolith --no-headers | wc -l

echo ""
echo "📊 마이크로서비스 아키텍처 리소스:"
echo "네임스페이스: ecommerce-microservices"
kubectl get all -n ecommerce-microservices
echo ""
echo "설정 파일 수:"
kubectl get configmaps -n ecommerce-microservices --no-headers | wc -l

echo ""
echo "2/5 네트워크 복잡도 분석 중..."
echo ""
echo "🌐 모놀리스 네트워크 구조:"
echo "서비스 수: $(kubectl get svc -n ecommerce-monolith --no-headers | wc -l)"
echo "내부 통신: 함수 호출 (0 네트워크 홉)"

echo ""
echo "🌐 마이크로서비스 네트워크 구조:"
echo "서비스 수: $(kubectl get svc -n ecommerce-microservices --no-headers | wc -l)"
echo "내부 통신: HTTP 호출 (1+ 네트워크 홉)"

echo ""
echo "3/5 데이터베이스 아키텍처 분석 중..."
echo ""
echo "💾 모놀리스 데이터 구조:"
echo "데이터베이스 수: 1 (통합 DB)"
echo "트랜잭션: ACID 보장"
echo "일관성: 강한 일관성"

echo ""
echo "💾 마이크로서비스 데이터 구조:"
echo "데이터베이스 수: $(kubectl get pods -n ecommerce-microservices -l app=user-service-db --no-headers | wc -l)"
echo "트랜잭션: 분산 트랜잭션 필요"
echo "일관성: 최종 일관성"

echo ""
echo "4/5 운영 복잡도 분석 중..."
echo ""
echo "🔧 배포 복잡도 비교:"
echo ""
echo "모놀리스:"
echo "- 배포 단위: 1개"
echo "- 배포 파일: $(find . -name "*.yaml" -path "*/monolith/*" 2>/dev/null | wc -l || echo 'N/A')"
echo "- 롤백: 단순 (전체 롤백)"

echo ""
echo "마이크로서비스:"
echo "- 배포 단위: 여러 개 (서비스별)"
echo "- 배포 파일: $(find . -name "*.yaml" -path "*/microservices/*" 2>/dev/null | wc -l || echo 'N/A')"
echo "- 롤백: 복잡 (서비스별 개별 롤백)"

echo ""
echo "5/5 모니터링 복잡도 분석 중..."
echo ""
echo "📈 모니터링 포인트:"
echo ""
echo "모놀리스:"
echo "- 모니터링 대상: 1개 애플리케이션"
echo "- 로그 수집: 중앙화됨"
echo "- 디버깅: 단일 프로세스"

echo ""
echo "마이크로서비스:"
echo "- 모니터링 대상: $(kubectl get deployments -n ecommerce-microservices --no-headers | wc -l)개 서비스"
echo "- 로그 수집: 분산됨 (집계 필요)"
echo "- 디버깅: 분산 추적 필요"

echo ""
echo "=== 아키텍처 분석 완료 ==="
echo ""
echo "📋 분석 요약:"
echo ""
echo "복잡도 비교:"
echo "┌─────────────────┬─────────────┬─────────────────┐"
echo "│ 항목            │ 모놀리스    │ 마이크로서비스  │"
echo "├─────────────────┼─────────────┼─────────────────┤"
echo "│ 개발 복잡도     │ 낮음        │ 높음            │"
echo "│ 배포 복잡도     │ 낮음        │ 높음            │"
echo "│ 운영 복잡도     │ 낮음        │ 높음            │"
echo "│ 확장성          │ 제한적      │ 유연함          │"
echo "│ 기술 다양성     │ 제한적      │ 자유로움        │"
echo "│ 팀 독립성      │ 낮음        │ 높음            │"
echo "└─────────────────┴─────────────┴─────────────────┘"
echo ""
echo "🎯 권장사항:"
echo "- 소규모 팀 (< 10명): 모놀리스 우선 고려"
echo "- 대규모 팀 (> 20명): 마이크로서비스 고려"
echo "- 빠른 개발: 모놀리스로 시작 후 점진적 분해"
echo "- 확장성 중요: 마이크로서비스 아키텍처"
echo ""
echo "다음 단계: ./cleanup-all.sh 실행 (정리 시)"
