#!/bin/bash

# Week 4 Day 2 Lab 1: Order Service 배포
# 사용법: ./deploy-order-service.sh

echo "=== Order Service 배포 시작 ==="

# 기존 컨테이너 정리
echo "1. 기존 Order Service 컨테이너 정리 중..."
docker stop order-service order-cache 2>/dev/null || true
docker rm order-service order-cache 2>/dev/null || true

# 디렉토리 생성
echo "2. 서비스 디렉토리 생성 중..."
mkdir -p ~/microservices-lab/services/order-service
mkdir -p ~/microservices-lab/data/redis

# Redis 캐시 실행
echo "3. Redis 캐시 실행 중..."
docker run -d \
  --name order-cache \
  --network microservices-net \
  -v ~/microservices-lab/data/redis:/data \
  redis:7-alpine

# Order Service 코드 생성
echo "4. Order Service 코드 생성 중..."
cat > ~/microservices-lab/services/order-service/app.js << 'EOF'
const express = require('express');
const consul = require('consul')();
const axios = require('axios');
const app = express();
const PORT = 3003;

app.use(express.json());

// 주문 목록 (임시 데이터)
let orders = [
  { 
    id: 1, 
    userId: 1, 
    productId: 1, 
    quantity: 2, 
    status: 'completed',
    totalAmount: 4999.98,
    createdAt: '2024-01-15T10:30:00Z'
  },
  { 
    id: 2, 
    userId: 2, 
    productId: 2, 
    quantity: 1, 
    status: 'pending',
    totalAmount: 45.99,
    createdAt: '2024-01-16T14:20:00Z'
  }
];

// 헬스체크 엔드포인트
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    service: 'order-service',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// 주문 목록 조회
app.get('/orders', (req, res) => {
  const { status, userId } = req.query;
  let filteredOrders = orders;
  
  if (status) {
    filteredOrders = filteredOrders.filter(o => o.status === status);
  }
  
  if (userId) {
    filteredOrders = filteredOrders.filter(o => o.userId === parseInt(userId));
  }
  
  console.log(`GET /orders - 주문 목록 조회 (${filteredOrders.length}개)`);
  res.json(filteredOrders);
});

// 주문 상세 조회
app.get('/orders/:id', (req, res) => {
  const orderId = parseInt(req.params.id);
  console.log(`GET /orders/${orderId} - 주문 상세 조회`);
  
  const order = orders.find(o => o.id === orderId);
  if (!order) {
    return res.status(404).json({ error: 'Order not found' });
  }
  res.json(order);
});

// 주문 상세 정보 (다른 서비스 호출)
app.get('/orders/:id/details', async (req, res) => {
  const orderId = parseInt(req.params.id);
  console.log(`GET /orders/${orderId}/details - 주문 상세 정보 조회`);
  
  try {
    const order = orders.find(o => o.id === orderId);
    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    // 서비스 디스커버리를 통한 다른 서비스 호출
    console.log(`Calling user-service for user ${order.userId}`);
    const userResponse = await axios.get(`http://user-service:3001/users/${order.userId}`, {
      timeout: 5000
    });
    
    console.log(`Calling product-service for product ${order.productId}`);
    const productResponse = await axios.get(`http://product-service:3002/products/${order.productId}`, {
      timeout: 5000
    });

    const orderDetails = {
      ...order,
      user: userResponse.data,
      product: productResponse.data,
      totalCalculated: productResponse.data.price * order.quantity
    };

    res.json(orderDetails);
  } catch (error) {
    console.error('Error fetching order details:', error.message);
    if (error.code === 'ECONNREFUSED') {
      res.status(503).json({ error: 'Service unavailable' });
    } else if (error.response && error.response.status === 404) {
      res.status(404).json({ error: 'User or Product not found' });
    } else {
      res.status(500).json({ error: 'Failed to fetch order details' });
    }
  }
});

// 새 주문 생성
app.post('/orders', async (req, res) => {
  const { userId, productId, quantity } = req.body;
  
  try {
    // 사용자 및 상품 정보 확인
    const userResponse = await axios.get(`http://user-service:3001/users/${userId}`);
    const productResponse = await axios.get(`http://product-service:3002/products/${productId}`);
    
    const totalAmount = productResponse.data.price * quantity;
    
    const newOrder = {
      id: orders.length + 1,
      userId: parseInt(userId),
      productId: parseInt(productId),
      quantity: parseInt(quantity),
      status: 'pending',
      totalAmount,
      createdAt: new Date().toISOString()
    };
    
    orders.push(newOrder);
    console.log('POST /orders - 새 주문 생성:', newOrder);
    res.status(201).json(newOrder);
  } catch (error) {
    console.error('Error creating order:', error.message);
    res.status(400).json({ error: 'Failed to create order' });
  }
});

// 주문 상태 업데이트
app.patch('/orders/:id/status', (req, res) => {
  const orderId = parseInt(req.params.id);
  const { status } = req.body;
  
  const order = orders.find(o => o.id === orderId);
  if (!order) {
    return res.status(404).json({ error: 'Order not found' });
  }
  
  order.status = status;
  console.log(`PATCH /orders/${orderId}/status - 주문 상태 업데이트: ${status}`);
  res.json(order);
});

// 서버 시작 및 Consul 등록
app.listen(PORT, () => {
  console.log(`Order Service running on port ${PORT}`);
  
  // Consul에 서비스 등록
  consul.agent.service.register({
    id: 'order-service-1',
    name: 'order-service',
    tags: ['api', 'orders', 'v1'],
    address: 'order-service',
    port: PORT,
    check: {
      http: `http://order-service:${PORT}/health`,
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
  console.log('Shutting down Order Service...');
  consul.agent.service.deregister('order-service-1', () => {
    process.exit(0);
  });
});
EOF

# package.json 생성
cat > ~/microservices-lab/services/order-service/package.json << 'EOF'
{
  "name": "order-service",
  "version": "1.0.0",
  "description": "Order management microservice",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "consul": "^0.40.0",
    "axios": "^1.6.0"
  }
}
EOF

# Redis 시작 대기
echo "5. Redis 시작 대기 중..."
sleep 5

# Order Service 컨테이너 실행
echo "6. Order Service 컨테이너 실행 중..."
docker run -d \
  --name order-service \
  --network microservices-net \
  -p 3003:3003 \
  -v ~/microservices-lab/services/order-service:/app \
  -w /app \
  node:16-alpine \
  sh -c "npm install && npm start"

# 서비스 시작 대기
echo "7. Order Service 시작 대기 중..."
sleep 15

# 서비스 상태 확인
echo "8. Order Service 상태 확인 중..."
if curl -s http://localhost:3003/health | grep -q "healthy"; then
    echo "✅ Order Service 정상 실행"
    echo ""
    echo "서비스 정보:"
    echo "- 포트: 3003"
    echo "- 헬스체크: http://localhost:3003/health"
    echo "- API 엔드포인트: http://localhost:3003/orders"
    echo ""
    echo "테스트:"
    curl -s http://localhost:3003/orders | jq -r '.[] | "- 주문 #\(.id): \(.status) ($\(.totalAmount))"'
else
    echo "❌ Order Service 시작 실패"
    docker logs order-service
    exit 1
fi

echo ""
echo "=== Order Service 배포 완료 ==="
