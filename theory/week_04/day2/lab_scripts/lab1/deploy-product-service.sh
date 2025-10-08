#!/bin/bash

# Week 4 Day 2 Lab 1: Product Service 배포
# 사용법: ./deploy-product-service.sh

echo "=== Product Service 배포 시작 ==="

# 기존 컨테이너 정리
echo "1. 기존 Product Service 컨테이너 정리 중..."
docker stop product-service product-db 2>/dev/null || true
docker rm product-service product-db 2>/dev/null || true

# 디렉토리 생성
echo "2. 서비스 디렉토리 생성 중..."
mkdir -p ~/microservices-lab/services/product-service
mkdir -p ~/microservices-lab/data/mongo

# MongoDB 데이터베이스 실행
echo "3. MongoDB 데이터베이스 실행 중..."
docker run -d \
  --name product-db \
  --network microservices-net \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=password \
  -v ~/microservices-lab/data/mongo:/data/db \
  mongo:5

# Product Service 코드 생성
echo "4. Product Service 코드 생성 중..."
cat > ~/microservices-lab/services/product-service/app.js << 'EOF'
const express = require('express');
const consul = require('consul')();
const app = express();
const PORT = 3002;

app.use(express.json());

// 상품 목록 (임시 데이터)
let products = [
  { 
    id: 1, 
    name: 'MacBook Pro', 
    price: 2499.99, 
    category: 'Electronics',
    stock: 10,
    description: 'Apple MacBook Pro 16-inch'
  },
  { 
    id: 2, 
    name: 'JavaScript 완벽 가이드', 
    price: 45.99, 
    category: 'Books',
    stock: 25,
    description: 'JavaScript programming guide'
  },
  { 
    id: 3, 
    name: 'Docker 컨테이너', 
    price: 39.99, 
    category: 'Books',
    stock: 15,
    description: 'Docker containerization guide'
  }
];

// 헬스체크 엔드포인트
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    service: 'product-service',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// 상품 목록 조회
app.get('/products', (req, res) => {
  const { category, minPrice, maxPrice } = req.query;
  let filteredProducts = products;
  
  if (category) {
    filteredProducts = filteredProducts.filter(p => 
      p.category.toLowerCase() === category.toLowerCase()
    );
  }
  
  if (minPrice) {
    filteredProducts = filteredProducts.filter(p => p.price >= parseFloat(minPrice));
  }
  
  if (maxPrice) {
    filteredProducts = filteredProducts.filter(p => p.price <= parseFloat(maxPrice));
  }
  
  console.log(`GET /products - 상품 목록 조회 (${filteredProducts.length}개)`);
  res.json(filteredProducts);
});

// 상품 상세 조회
app.get('/products/:id', (req, res) => {
  const productId = parseInt(req.params.id);
  console.log(`GET /products/${productId} - 상품 상세 조회`);
  
  const product = products.find(p => p.id === productId);
  if (!product) {
    return res.status(404).json({ error: 'Product not found' });
  }
  res.json(product);
});

// 새 상품 생성
app.post('/products', (req, res) => {
  const { name, price, category, stock = 0, description = '' } = req.body;
  const newProduct = {
    id: products.length + 1,
    name,
    price: parseFloat(price),
    category,
    stock: parseInt(stock),
    description
  };
  products.push(newProduct);
  console.log('POST /products - 새 상품 생성:', newProduct);
  res.status(201).json(newProduct);
});

// 상품 재고 업데이트
app.patch('/products/:id/stock', (req, res) => {
  const productId = parseInt(req.params.id);
  const { quantity } = req.body;
  
  const product = products.find(p => p.id === productId);
  if (!product) {
    return res.status(404).json({ error: 'Product not found' });
  }
  
  product.stock += parseInt(quantity);
  console.log(`PATCH /products/${productId}/stock - 재고 업데이트: ${product.stock}`);
  res.json(product);
});

// 서버 시작 및 Consul 등록
app.listen(PORT, () => {
  console.log(`Product Service running on port ${PORT}`);
  
  // Consul에 서비스 등록
  consul.agent.service.register({
    id: 'product-service-1',
    name: 'product-service',
    tags: ['api', 'products', 'v1'],
    address: 'product-service',
    port: PORT,
    check: {
      http: `http://product-service:${PORT}/health`,
      interval: '10s',
      timeout: '3s'
    }
  }, (err) => {
    if (err) {
      console.error('Consul registration failed:', err);
    } else {
      console.log('✅ Service registered with Consul');
    }
  });
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('Shutting down Product Service...');
  consul.agent.service.deregister('product-service-1', () => {
    process.exit(0);
  });
});
EOF

# package.json 생성
cat > ~/microservices-lab/services/product-service/package.json << 'EOF'
{
  "name": "product-service",
  "version": "1.0.0",
  "description": "Product management microservice",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "consul": "^0.40.0"
  }
}
EOF

# MongoDB 시작 대기
echo "5. MongoDB 시작 대기 중..."
sleep 5

# Product Service 컨테이너 실행
echo "6. Product Service 컨테이너 실행 중..."
docker run -d \
  --name product-service \
  --network microservices-net \
  -p 3002:3002 \
  -v ~/microservices-lab/services/product-service:/app \
  -w /app \
  node:16-alpine \
  sh -c "npm install && npm start"

# 서비스 시작 대기
echo "7. Product Service 시작 대기 중..."
sleep 10

# 서비스 상태 확인
echo "8. Product Service 상태 확인 중..."
if curl -s http://localhost:3002/health | grep -q "healthy"; then
    echo "✅ Product Service 정상 실행"
    echo ""
    echo "서비스 정보:"
    echo "- 포트: 3002"
    echo "- 헬스체크: http://localhost:3002/health"
    echo "- API 엔드포인트: http://localhost:3002/products"
    echo ""
    echo "테스트:"
    curl -s http://localhost:3002/products | jq -r '.[] | "- \(.name): $\(.price) (\(.stock)개)"'
else
    echo "❌ Product Service 시작 실패"
    docker logs product-service
    exit 1
fi

echo ""
echo "=== Product Service 배포 완료 ==="
