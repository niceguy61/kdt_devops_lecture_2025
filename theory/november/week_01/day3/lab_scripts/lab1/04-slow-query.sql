-- November Week 1 Day 3 Lab 1: 느린 쿼리 (인덱스 없음)
-- 설명: 전체 테이블 스캔으로 인한 성능 저하 확인

-- 실행 계획 및 실행 시간 확인
EXPLAIN ANALYZE
SELECT * FROM orders 
WHERE product_name LIKE '%Product-500%' 
  AND price > 500
  AND status = 'completed'
ORDER BY order_date DESC
LIMIT 100;

-- 예상 결과:
-- Seq Scan on orders (전체 테이블 스캔)
-- Execution Time: 5000~10000 ms (매우 느림!)
