-- CloudMart Database Schema
-- PostgreSQL 16

-- 상품 테이블
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    category VARCHAR(100),
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 인덱스 생성
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_price ON products(price);

-- 샘플 데이터 삽입
INSERT INTO products (name, description, price, stock, category, image_url) VALUES
    ('MacBook Pro 16"', 'Apple M3 Max, 36GB RAM, 1TB SSD', 3499.99, 15, 'Electronics', 'https://via.placeholder.com/300x300?text=MacBook'),
    ('iPhone 15 Pro', '256GB, Titanium Blue', 1199.99, 50, 'Electronics', 'https://via.placeholder.com/300x300?text=iPhone'),
    ('AirPods Pro', '2nd Generation with USB-C', 249.99, 100, 'Electronics', 'https://via.placeholder.com/300x300?text=AirPods'),
    ('iPad Air', '11-inch, M2 chip, 256GB', 749.99, 30, 'Electronics', 'https://via.placeholder.com/300x300?text=iPad'),
    ('Apple Watch Ultra 2', 'Titanium Case with Alpine Loop', 799.99, 25, 'Electronics', 'https://via.placeholder.com/300x300?text=Watch'),
    
    ('Sony WH-1000XM5', 'Wireless Noise Cancelling Headphones', 399.99, 40, 'Audio', 'https://via.placeholder.com/300x300?text=Headphones'),
    ('Bose QuietComfort', 'Wireless Earbuds', 299.99, 60, 'Audio', 'https://via.placeholder.com/300x300?text=Earbuds'),
    ('JBL Flip 6', 'Portable Bluetooth Speaker', 129.99, 80, 'Audio', 'https://via.placeholder.com/300x300?text=Speaker'),
    
    ('Samsung 55" OLED TV', '4K Smart TV with AI Upscaling', 1499.99, 20, 'Home Entertainment', 'https://via.placeholder.com/300x300?text=TV'),
    ('LG Soundbar', 'Dolby Atmos 5.1.2 Channel', 699.99, 35, 'Home Entertainment', 'https://via.placeholder.com/300x300?text=Soundbar'),
    
    ('Logitech MX Master 3S', 'Wireless Performance Mouse', 99.99, 120, 'Accessories', 'https://via.placeholder.com/300x300?text=Mouse'),
    ('Keychron K8 Pro', 'Wireless Mechanical Keyboard', 109.99, 75, 'Accessories', 'https://via.placeholder.com/300x300?text=Keyboard'),
    ('Dell UltraSharp 27"', '4K USB-C Monitor', 549.99, 45, 'Accessories', 'https://via.placeholder.com/300x300?text=Monitor'),
    ('Anker PowerCore', '20000mAh Power Bank', 49.99, 200, 'Accessories', 'https://via.placeholder.com/300x300?text=PowerBank'),
    
    ('Canon EOS R6', 'Mirrorless Camera Body', 2499.99, 12, 'Cameras', 'https://via.placeholder.com/300x300?text=Camera'),
    ('Sony A7 IV', 'Full Frame Mirrorless Camera', 2499.99, 10, 'Cameras', 'https://via.placeholder.com/300x300?text=Sony'),
    ('DJI Mini 3 Pro', 'Lightweight Foldable Drone', 759.99, 28, 'Cameras', 'https://via.placeholder.com/300x300?text=Drone'),
    
    ('Nintendo Switch OLED', 'Gaming Console with Dock', 349.99, 65, 'Gaming', 'https://via.placeholder.com/300x300?text=Switch'),
    ('PlayStation 5', 'Gaming Console 1TB', 499.99, 18, 'Gaming', 'https://via.placeholder.com/300x300?text=PS5'),
    ('Xbox Series X', 'Gaming Console 1TB', 499.99, 22, 'Gaming', 'https://via.placeholder.com/300x300?text=Xbox');

-- 통계 뷰 생성
CREATE OR REPLACE VIEW product_stats AS
SELECT 
    category,
    COUNT(*) as product_count,
    SUM(stock) as total_stock,
    AVG(price) as avg_price,
    SUM(price * stock) as total_value
FROM products
GROUP BY category;

-- 업데이트 트리거 함수
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 트리거 생성
CREATE TRIGGER products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- 권한 설정 (선택사항)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON products TO cloudmart_user;
-- GRANT USAGE, SELECT ON SEQUENCE products_id_seq TO cloudmart_user;
