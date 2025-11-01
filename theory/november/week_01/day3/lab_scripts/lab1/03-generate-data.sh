#!/bin/bash

# November Week 1 Day 3 Lab 1: 대용량 데이터 생성
# 설명: 100MB ~ 1GB 랜덤 데이터 생성
# 사용법: ./03-generate-data.sh [행 수]
#   - 1000000 (100만 건) = 약 100MB
#   - 10000000 (1000만 건) = 약 1GB

set -e

ROWS=${1:-1000000}
echo "=== $ROWS 건의 데이터 생성 시작 ==="
echo "예상 크기: $(($ROWS / 10000))MB"
echo ""

# RDS 엔드포인트 확인
if [ -z "$RDS_ENDPOINT" ]; then
    echo "❌ RDS_ENDPOINT 환경변수가 설정되지 않았습니다."
    echo "다음 명령어로 설정하세요:"
    echo "export RDS_ENDPOINT='your-rds-endpoint.rds.amazonaws.com'"
    exit 1
fi

echo "RDS 엔드포인트: $RDS_ENDPOINT"
echo ""

# 데이터 생성
echo "데이터 삽입 중... (시간이 걸릴 수 있습니다)"
psql -h $RDS_ENDPOINT -U postgres -d testdb <<EOF
INSERT INTO orders (user_id, product_name, price, order_date, status, description)
SELECT 
    floor(random() * 10000)::INTEGER,
    'Product-' || floor(random() * 1000)::INTEGER,
    (random() * 1000)::DECIMAL(10,2),
    NOW() - (random() * 365 || ' days')::INTERVAL,
    CASE WHEN random() < 0.5 THEN 'completed' ELSE 'pending' END,
    md5(random()::TEXT) || md5(random()::TEXT) || md5(random()::TEXT)
FROM generate_series(1, $ROWS);
EOF

echo ""
echo "=== 데이터 생성 완료 ==="
echo ""

# 결과 확인
echo "데이터 확인 중..."
psql -h $RDS_ENDPOINT -U postgres -d testdb <<EOF
SELECT COUNT(*) as total_rows FROM orders;
SELECT pg_size_pretty(pg_total_relation_size('orders')) as table_size;
EOF

echo ""
echo "✅ 완료!"
