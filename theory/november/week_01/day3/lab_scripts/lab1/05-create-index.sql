-- November Week 1 Day 3 Lab 1: 인덱스 생성
-- 설명: 쿼리 성능 최적화를 위한 인덱스 생성

-- 인덱스 생성
CREATE INDEX idx_product_name ON orders(product_name);
CREATE INDEX idx_price ON orders(price);
CREATE INDEX idx_status ON orders(status);
CREATE INDEX idx_order_date ON orders(order_date);

-- 인덱스 확인
\di

-- 인덱스 크기 확인
SELECT 
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
FROM pg_indexes
WHERE tablename = 'orders';
