#!/bin/bash

# November Week 1 Day 3 Lab 1: 리소스 정리
# 설명: RDS 인스턴스 및 CloudWatch Dashboard 삭제

set -e

echo "=== Lab 1 리소스 정리 시작 ==="
echo ""

# RDS 인스턴스 삭제
echo "1/2 RDS 인스턴스 삭제 중..."
aws rds delete-db-instance \
  --db-instance-identifier lab-rds-perf \
  --skip-final-snapshot \
  --region ap-northeast-2 2>/dev/null || echo "RDS 인스턴스가 이미 삭제되었거나 존재하지 않습니다."

echo "✅ RDS 삭제 요청 완료 (실제 삭제까지 5-10분 소요)"
echo ""

# CloudWatch Dashboard 삭제
echo "2/2 CloudWatch Dashboard 삭제 중..."
aws cloudwatch delete-dashboards \
  --dashboard-names RDS-Performance-Lab \
  --region ap-northeast-2 2>/dev/null || echo "Dashboard가 이미 삭제되었거나 존재하지 않습니다."

echo "✅ Dashboard 삭제 완료"
echo ""

echo "=== Lab 1 리소스 정리 완료 ==="
echo ""
echo "💡 참고:"
echo "- RDS 인스턴스는 완전히 삭제되기까지 5-10분 소요됩니다."
echo "- AWS Console에서 삭제 상태를 확인하세요."
