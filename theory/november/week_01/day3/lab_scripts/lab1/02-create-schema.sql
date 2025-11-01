-- November Week 1 Day 3 Lab 1: 스키마 생성
-- 설명: orders 테이블 생성

-- 데이터베이스 생성
CREATE DATABASE testdb;

-- testdb로 연결
\c testdb

-- 주문 테이블 생성
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    order_date TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL,
    description TEXT
);

-- 테이블 확인
\dt

-- 초기 데이터 확인
SELECT COUNT(*) FROM orders;
