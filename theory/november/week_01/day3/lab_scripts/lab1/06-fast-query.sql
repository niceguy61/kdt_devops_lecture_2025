-- November Week 1 Day 3 Lab 1: 빠른 쿼리 (인덱스 있음)
-- 설명: 인덱스를 활용한 성능 개선 확인

-- 실행 계획 및 실행 시간 확인
EXPLAIN ANALYZE
SELECT * FROM orders 
WHERE product_name LIKE '%Product-500%' 
  AND price > 500
  AND status = 'completed'
ORDER BY order_date DESC
LIMIT 100;

-- 예상 결과:
-- Index Scan using idx_order_date (인덱스 스캔)
-- Execution Time: 10~100 ms (100~200배 빨라짐!)
