#!/bin/bash

# Week 2 Day 3 Lab 2: 트레이싱 지원 애플리케이션 배포
# 사용법: ./deploy_traced_apps.sh

echo "=== 트레이싱 지원 마이크로서비스 배포 시작 ==="

cd ~/docker-tracing-lab

# 애플리케이션 디렉토리 생성
echo "1. 애플리케이션 디렉토리 구조 생성 중..."
mkdir -p apps/{api-gateway,user-service,order-service}

# API Gateway (Node.js) 생성
echo "2. API Gateway (Node.js + OpenTelemetry) 생성 중..."
cd apps/api-gateway

cat > package.json << 'EOF'
{
  "name": "api-gateway",
  "version": "1.0.0",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.2",
    "axios": "^1.5.0",
    "@opentelemetry/api": "^1.6.0",
    "@opentelemetry/sdk-node": "^0.43.0",
    "@opentelemetry/auto-instrumentations-node": "^0.39.4",
    "@opentelemetry/exporter-otlp-http": "^0.43.0",
    "prom-client": "^14.2.0"
  }
}
EOF

cat > tracing.js << 'EOF'
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-otlp-http');

const sdk = new NodeSDK({
  traceExporter: new OTLPTraceExporter({
    url: 'http://otel-collector:4318/v1/traces',
  }),
  instrumentations: [getNodeAutoInstrumentations()],
  serviceName: 'api-gateway',
});

sdk.start();
console.log('OpenTelemetry started for api-gateway');
EOF

cat > server.js << 'EOF'
require('./tracing');
const express = require('express');
const axios = require('axios');
const client = require('prom-client');

const app = express();
const port = 3001;

// Prometheus 메트릭 설정
const register = new client.Registry();
const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10]
});

const httpRequestsTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status']
});

register.registerMetric(httpRequestDuration);
register.registerMetric(httpRequestsTotal);

app.use(express.json());

// 메트릭 수집 미들웨어
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const labels = { method: req.method, route: req.path, status: res.statusCode };
    httpRequestDuration.observe(labels, duration);
    httpRequestsTotal.inc(labels);
  });
  next();
});

// 헬스체크
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', service: 'api-gateway', timestamp: new Date().toISOString() });
});

// 메트릭 엔드포인트
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// 사용자 정보 조회 (User Service 호출)
app.get('/api/users/:id', async (req, res) => {
  try {
    console.log(`Fetching user ${req.params.id} from user-service`);
    const response = await axios.get(`http://user-service:3002/users/${req.params.id}`);
    res.json(response.data);
  } catch (error) {
    console.error('User service error:', error.message);
    res.status(500).json({ error: 'User service error', details: error.message });
  }
});

// 주문 생성 (Order Service 호출)
app.post('/api/orders', async (req, res) => {
  try {
    console.log('Creating order:', req.body);
    const response = await axios.post('http://order-service:3003/orders', req.body);
    res.json(response.data);
  } catch (error) {
    console.error('Order service error:', error.message);
    res.status(500).json({ error: 'Order service error', details: error.message });
  }
});

// 복합 요청 (여러 서비스 호출)
app.get('/api/user-orders/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;
    
    // 사용자 정보 조회
    const userResponse = await axios.get(`http://user-service:3002/users/${userId}`);
    
    // 사용자의 주문 조회
    const ordersResponse = await axios.get(`http://order-service:3003/orders/user/${userId}`);
    
    res.json({
      user: userResponse.data,
      orders: ordersResponse.data
    });
  } catch (error) {
    console.error('Complex request error:', error.message);
    res.status(500).json({ error: 'Service error', details: error.message });
  }
});

app.listen(port, () => {
  console.log(`API Gateway running on port ${port}`);
});
EOF

cat > Dockerfile << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
EXPOSE 3001
CMD ["node", "server.js"]
EOF

# User Service (Python) 생성
echo "3. User Service (Python + OpenTelemetry) 생성 중..."
cd ../user-service

cat > requirements.txt << 'EOF'
flask==2.3.3
psycopg2-binary==2.9.7
opentelemetry-api==1.20.0
opentelemetry-sdk==1.20.0
opentelemetry-instrumentation-flask==0.41b0
opentelemetry-instrumentation-psycopg2==0.41b0
opentelemetry-exporter-otlp==1.20.0
prometheus-client==0.17.1
EOF

cat > app.py << 'EOF'
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.instrumentation.psycopg2 import Psycopg2Instrumentor

from flask import Flask, jsonify
import psycopg2
import time
import random
from prometheus_client import Counter, Histogram, generate_latest

# OpenTelemetry 설정
trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)

otlp_exporter = OTLPSpanExporter(endpoint="http://otel-collector:4318/v1/traces")
span_processor = BatchSpanProcessor(otlp_exporter)
trace.get_tracer_provider().add_span_processor(span_processor)

app = Flask(__name__)

# 자동 계측 활성화
FlaskInstrumentor().instrument_app(app)
Psycopg2Instrumentor().instrument()

# Prometheus 메트릭
REQUEST_COUNT = Counter('user_service_requests_total', 'Total requests', ['method', 'endpoint', 'status'])
REQUEST_LATENCY = Histogram('user_service_request_duration_seconds', 'Request latency', ['endpoint'])
DB_QUERIES = Counter('user_service_db_queries_total', 'Total database queries')

# 데이터베이스 연결
def get_db_connection():
    return psycopg2.connect(
        host="postgres",
        database="userdb",
        user="admin",
        password="password"
    )

@app.route('/health')
def health():
    return jsonify({"status": "healthy", "service": "user-service", "timestamp": time.time()})

@app.route('/metrics')
def metrics():
    return generate_latest()

@app.route('/users/<int:user_id>')
def get_user(user_id):
    with REQUEST_LATENCY.labels(endpoint='/users').time():
        REQUEST_COUNT.labels(method='GET', endpoint='/users', status='processing').inc()
        
        with tracer.start_as_current_span("get_user_from_db") as span:
            span.set_attribute("user.id", user_id)
            span.set_attribute("db.operation", "SELECT")
            
            # 의도적 지연 (트레이싱 시각화용)
            delay = random.uniform(0.1, 0.5)
            span.set_attribute("processing.delay", delay)
            time.sleep(delay)
            
            try:
                with tracer.start_as_current_span("db_connection"):
                    conn = get_db_connection()
                    cur = conn.cursor()
                    
                with tracer.start_as_current_span("db_query"):
                    cur.execute("SELECT id, name, email FROM users WHERE id = %s", (user_id,))
                    user = cur.fetchone()
                    DB_QUERIES.inc()
                    
                cur.close()
                conn.close()
                
                if user:
                    REQUEST_COUNT.labels(method='GET', endpoint='/users', status='200').inc()
                    return jsonify({
                        "id": user[0],
                        "name": user[1],
                        "email": user[2],
                        "service": "user-service"
                    })
                else:
                    REQUEST_COUNT.labels(method='GET', endpoint='/users', status='404').inc()
                    return jsonify({"error": "User not found"}), 404
                    
            except Exception as e:
                span.record_exception(e)
                span.set_status(trace.Status(trace.StatusCode.ERROR, str(e)))
                REQUEST_COUNT.labels(method='GET', endpoint='/users', status='500').inc()
                return jsonify({"error": str(e)}), 500

@app.route('/users')
def list_users():
    with REQUEST_LATENCY.labels(endpoint='/users').time():
        with tracer.start_as_current_span("list_all_users") as span:
            try:
                conn = get_db_connection()
                cur = conn.cursor()
                cur.execute("SELECT id, name, email FROM users ORDER BY id")
                users = cur.fetchall()
                DB_QUERIES.inc()
                cur.close()
                conn.close()
                
                user_list = [{"id": u[0], "name": u[1], "email": u[2]} for u in users]
                span.set_attribute("users.count", len(user_list))
                
                REQUEST_COUNT.labels(method='GET', endpoint='/users', status='200').inc()
                return jsonify({"users": user_list, "count": len(user_list)})
                
            except Exception as e:
                span.record_exception(e)
                REQUEST_COUNT.labels(method='GET', endpoint='/users', status='500').inc()
                return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    print("Starting User Service with OpenTelemetry tracing")
    app.run(host='0.0.0.0', port=3002, debug=True)
EOF

cat > Dockerfile << 'EOF'
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 3002
CMD ["python", "app.py"]
EOF

# Order Service (Go) 생성
echo "4. Order Service (Go + OpenTelemetry) 생성 중..."
cd ../order-service

cat > main.go << 'EOF'
package main

import (
    "context"
    "encoding/json"
    "fmt"
    "log"
    "math/rand"
    "net/http"
    "strconv"
    "time"

    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/attribute"
    "go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
    "go.opentelemetry.io/otel/sdk/resource"
    "go.opentelemetry.io/otel/sdk/trace"
    semconv "go.opentelemetry.io/otel/semconv/v1.17.0"
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
    requestsTotal = prometheus.NewCounterVec(
        prometheus.CounterOpts{
            Name: "order_service_requests_total",
            Help: "Total number of requests",
        },
        []string{"method", "endpoint", "status"},
    )
    
    requestDuration = prometheus.NewHistogramVec(
        prometheus.HistogramOpts{
            Name: "order_service_request_duration_seconds",
            Help: "Request duration in seconds",
        },
        []string{"endpoint"},
    )
)

type Order struct {
    ID       int    `json:"id"`
    UserID   int    `json:"user_id"`
    Product  string `json:"product"`
    Quantity int    `json:"quantity"`
    Status   string `json:"status"`
}

var orders []Order
var nextID = 1

func init() {
    prometheus.MustRegister(requestsTotal)
    prometheus.MustRegister(requestDuration)
    
    // 샘플 주문 데이터
    orders = []Order{
        {ID: 1, UserID: 1, Product: "laptop", Quantity: 1, Status: "completed"},
        {ID: 2, UserID: 2, Product: "mouse", Quantity: 2, Status: "pending"},
    }
    nextID = 3
}

func initTracer() {
    ctx := context.Background()
    
    exporter, err := otlptracehttp.New(ctx,
        otlptracehttp.WithEndpoint("http://otel-collector:4318"),
        otlptracehttp.WithInsecure(),
    )
    if err != nil {
        log.Fatal("Failed to create OTLP exporter:", err)
    }

    resource := resource.NewWithAttributes(
        semconv.SchemaURL,
        semconv.ServiceName("order-service"),
        semconv.ServiceVersion("1.0.0"),
    )

    tp := trace.NewTracerProvider(
        trace.WithBatcher(exporter),
        trace.WithResource(resource),
    )

    otel.SetTracerProvider(tp)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
    response := map[string]interface{}{
        "status":    "healthy",
        "service":   "order-service",
        "timestamp": time.Now().Unix(),
    }
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(response)
}

func createOrderHandler(w http.ResponseWriter, r *http.Request) {
    timer := prometheus.NewTimer(requestDuration.WithLabelValues("/orders"))
    defer timer.ObserveDuration()
    
    tracer := otel.Tracer("order-service")
    ctx, span := tracer.Start(r.Context(), "create_order")
    defer span.End()
    
    if r.Method != "POST" {
        requestsTotal.WithLabelValues("POST", "/orders", "405").Inc()
        http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
        return
    }
    
    var order Order
    if err := json.NewDecoder(r.Body).Decode(&order); err != nil {
        requestsTotal.WithLabelValues("POST", "/orders", "400").Inc()
        http.Error(w, "Invalid JSON", http.StatusBadRequest)
        return
    }
    
    // 주문 처리 시뮬레이션
    _, processSpan := tracer.Start(ctx, "process_order")
    processSpan.SetAttributes(
        attribute.Int("order.user_id", order.UserID),
        attribute.String("order.product", order.Product),
        attribute.Int("order.quantity", order.Quantity),
    )
    
    // 의도적 지연
    delay := time.Duration(rand.Intn(300)+100) * time.Millisecond
    time.Sleep(delay)
    processSpan.SetAttributes(attribute.Float64("processing.delay_ms", float64(delay.Milliseconds())))
    
    order.ID = nextID
    nextID++
    order.Status = "pending"
    orders = append(orders, order)
    
    processSpan.End()
    
    requestsTotal.WithLabelValues("POST", "/orders", "201").Inc()
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusCreated)
    json.NewEncoder(w).Encode(order)
}

func getUserOrdersHandler(w http.ResponseWriter, r *http.Request) {
    timer := prometheus.NewTimer(requestDuration.WithLabelValues("/orders/user"))
    defer timer.ObserveDuration()
    
    tracer := otel.Tracer("order-service")
    _, span := tracer.Start(r.Context(), "get_user_orders")
    defer span.End()
    
    userIDStr := r.URL.Path[len("/orders/user/"):]
    userID, err := strconv.Atoi(userIDStr)
    if err != nil {
        requestsTotal.WithLabelValues("GET", "/orders/user", "400").Inc()
        http.Error(w, "Invalid user ID", http.StatusBadRequest)
        return
    }
    
    span.SetAttributes(attribute.Int("user.id", userID))
    
    var userOrders []Order
    for _, order := range orders {
        if order.UserID == userID {
            userOrders = append(userOrders, order)
        }
    }
    
    span.SetAttributes(attribute.Int("orders.count", len(userOrders)))
    
    requestsTotal.WithLabelValues("GET", "/orders/user", "200").Inc()
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(map[string]interface{}{
        "orders": userOrders,
        "count":  len(userOrders),
    })
}

func main() {
    initTracer()
    
    http.HandleFunc("/health", healthHandler)
    http.HandleFunc("/orders", createOrderHandler)
    http.HandleFunc("/orders/user/", getUserOrdersHandler)
    http.Handle("/metrics", promhttp.Handler())
    
    fmt.Println("Order Service starting on port 3003")
    log.Fatal(http.ListenAndServe(":3003", nil))
}
EOF

cat > go.mod << 'EOF'
module order-service

go 1.21

require (
    go.opentelemetry.io/otel v1.19.0
    go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp v1.19.0
    go.opentelemetry.io/otel/sdk v1.19.0
    github.com/prometheus/client_golang v1.17.0
)
EOF

cat > Dockerfile << 'EOF'
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o order-service .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/order-service .
EXPOSE 3003
CMD ["./order-service"]
EOF

# Docker Compose에 애플리케이션 서비스 추가
echo "5. Docker Compose에 애플리케이션 서비스 추가 중..."
cd ~/docker-tracing-lab

cat >> docker-compose.yml << 'EOF'

  # API Gateway
  api-gateway:
    build: ./apps/api-gateway
    container_name: api-gateway
    ports:
      - "3001:3001"
    depends_on:
      - otel-collector
      - user-service
      - order-service
    networks:
      - observability

  # User Service
  user-service:
    build: ./apps/user-service
    container_name: user-service
    ports:
      - "3002:3002"
    depends_on:
      - postgres
      - otel-collector
    networks:
      - observability

  # Order Service
  order-service:
    build: ./apps/order-service
    container_name: order-service
    ports:
      - "3003:3003"
    depends_on:
      - otel-collector
    networks:
      - observability
EOF

echo ""
echo "=== 트레이싱 지원 마이크로서비스 배포 완료 ==="
echo ""
echo "생성된 서비스:"
echo "- API Gateway (Node.js): http://localhost:3001"
echo "- User Service (Python): http://localhost:3002"
echo "- Order Service (Go): http://localhost:3003"
echo ""
echo "다음 단계:"
echo "1. 서비스 시작: docker-compose up -d"
echo "2. Grafana 대시보드 설정: ./setup_grafana_dashboards.sh"
echo "3. 분산 추적 테스트: ./test_distributed_tracing.sh"