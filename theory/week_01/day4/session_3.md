# Week 1 Day 4 Session 3: 마이크로서비스 아키텍처

<div align="center">

**🏗️ 마이크로서비스 설계와 구현** • **실무 아키텍처 패턴**

*모놀리스에서 마이크로서비스로, 현대적 애플리케이션 아키텍처의 모든 것*

</div>

---

## 🕘 세션 정보

**시간**: 11:00-11:50 (50분)  
**목표**: 마이크로서비스 아키텍처 설계 원칙과 Docker Compose 구현  
**방식**: 아키텍처 설계 + 실무 패턴 + 팀 준비

---

## 🎯 세션 목표

### 📚 학습 목표
- **이해 목표**: 마이크로서비스 아키텍처 원칙과 패턴 완전 이해
- **적용 목표**: Docker Compose로 마이크로서비스 구현 능력
- **협업 목표**: 팀 프로젝트를 위한 아키텍처 설계 준비

### 🤔 왜 필요한가? (3분)
**마이크로서비스의 현실적 필요성**:
- 💼 **실무 표준**: 현대 기업의 90% 이상이 마이크로서비스 도입
- 🏠 **일상 비유**: 대형 백화점을 전문 매장들로 분리하는 것
- 📊 **효과**: 확장성, 유지보수성, 팀 자율성 대폭 향상

---

## 📖 핵심 개념 (35분)

### 🔍 개념 1: 마이크로서비스 아키텍처 원칙 (12분)

#### 모놀리스 vs 마이크로서비스
```mermaid
graph TB
    subgraph "모놀리스 아키텍처"
        A1[사용자 인터페이스]
        A2[비즈니스 로직]
        A3[데이터 접근 계층]
        A4[데이터베이스]
        
        A1 --> A2 --> A3 --> A4
    end
    
    subgraph "마이크로서비스 아키텍처"
        B1[API Gateway]
        
        B2[User Service]
        B3[Product Service]
        B4[Order Service]
        B5[Payment Service]
        
        B6[User DB]
        B7[Product DB]
        B8[Order DB]
        B9[Payment DB]
        
        B1 --> B2
        B1 --> B3
        B1 --> B4
        B1 --> B5
        
        B2 --> B6
        B3 --> B7
        B4 --> B8
        B5 --> B9
    end
    
    style A1,A2,A3,A4 fill:#ffebee
    style B1 fill:#e3f2fd
    style B2,B3,B4,B5 fill:#e8f5e8
    style B6,B7,B8,B9 fill:#fff3e0
```

#### 마이크로서비스 핵심 원칙
```yaml
# 마이크로서비스 설계 원칙
principles:
  single_responsibility:
    description: "하나의 비즈니스 기능에 집중"
    example: "사용자 관리만 담당하는 User Service"
    
  decentralized:
    description: "각 서비스가 독립적으로 배포 가능"
    example: "User Service 업데이트가 Product Service에 영향 없음"
    
  database_per_service:
    description: "서비스별 전용 데이터베이스"
    example: "User DB, Product DB, Order DB 분리"
    
  failure_isolation:
    description: "한 서비스 장애가 전체에 영향 없음"
    example: "Payment Service 장애 시 User Service는 정상 동작"
    
  technology_diversity:
    description: "서비스별 최적 기술 스택 선택"
    example: "User Service는 Node.js, Analytics는 Python"
```

#### 마이크로서비스 장단점
**장점**:
- ✅ **독립적 배포**: 서비스별 개별 배포 가능
- ✅ **기술 다양성**: 서비스별 최적 기술 선택
- ✅ **팀 자율성**: 작은 팀이 서비스 전체 소유
- ✅ **확장성**: 필요한 서비스만 스케일링
- ✅ **장애 격리**: 부분 장애가 전체 영향 최소화

**단점**:
- ❌ **복잡성 증가**: 네트워크 통신, 분산 시스템 복잡도
- ❌ **데이터 일관성**: 분산 트랜잭션 관리 어려움
- ❌ **운영 오버헤드**: 더 많은 서비스 모니터링 필요
- ❌ **네트워크 지연**: 서비스 간 통신 오버헤드
- ❌ **테스트 복잡도**: 통합 테스트 어려움

### 🔍 개념 2: 마이크로서비스 핵심 패턴 (12분)

#### 1. API Gateway 패턴
```yaml
# API Gateway 구성 예시
version: '3.8'

services:
  api-gateway:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - user-service
      - product-service
      - order-service
    networks:
      - frontend
      - backend

  user-service:
    build: ./user-service
    networks:
      - backend
      - user-db-net
    environment:
      - DATABASE_URL=postgresql://user-db:5432/users

  product-service:
    build: ./product-service
    networks:
      - backend
      - product-db-net
    environment:
      - DATABASE_URL=mongodb://product-db:27017/products

  order-service:
    build: ./order-service
    networks:
      - backend
      - order-db-net
    environment:
      - DATABASE_URL=mysql://order-db:3306/orders
      - USER_SERVICE_URL=http://user-service:3000
      - PRODUCT_SERVICE_URL=http://product-service:3000

networks:
  frontend:
  backend:
  user-db-net:
  product-db-net:
  order-db-net:
```

#### 2. 서비스 디스커버리 패턴
```yaml
services:
  consul:
    image: consul:latest
    ports:
      - "8500:8500"
    command: consul agent -server -ui -node=server-1 -bootstrap-expect=1 -client=0.0.0.0

  user-service:
    build: ./user-service
    environment:
      - CONSUL_URL=http://consul:8500
      - SERVICE_NAME=user-service
      - SERVICE_PORT=3000
    depends_on:
      - consul

  product-service:
    build: ./product-service
    environment:
      - CONSUL_URL=http://consul:8500
      - SERVICE_NAME=product-service
      - SERVICE_PORT=3000
    depends_on:
      - consul
```

#### 3. 회로 차단기 (Circuit Breaker) 패턴
```javascript
// 서비스 간 통신 예시 (Node.js)
const CircuitBreaker = require('opossum');

const options = {
  timeout: 3000,
  errorThresholdPercentage: 50,
  resetTimeout: 30000
};

const breaker = new CircuitBreaker(callExternalService, options);

breaker.fallback(() => {
  return { error: 'Service temporarily unavailable' };
});

async function callExternalService(serviceUrl) {
  const response = await fetch(serviceUrl);
  return response.json();
}
```

#### 4. 이벤트 기반 통신 패턴
```yaml
services:
  rabbitmq:
    image: rabbitmq:3-management
    ports:
      - "5672:5672"
      - "15672:15672"
    environment:
      - RABBITMQ_DEFAULT_USER=admin
      - RABBITMQ_DEFAULT_PASS=password

  order-service:
    build: ./order-service
    environment:
      - RABBITMQ_URL=amqp://admin:password@rabbitmq:5672
    depends_on:
      - rabbitmq

  inventory-service:
    build: ./inventory-service
    environment:
      - RABBITMQ_URL=amqp://admin:password@rabbitmq:5672
    depends_on:
      - rabbitmq

  notification-service:
    build: ./notification-service
    environment:
      - RABBITMQ_URL=amqp://admin:password@rabbitmq:5672
    depends_on:
      - rabbitmq
```

### 🔍 개념 3: 실무 마이크로서비스 구현 (11분)

#### E-commerce 마이크로서비스 아키텍처
```yaml
version: '3.8'

services:
  # API Gateway
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/ssl:/etc/nginx/ssl
    networks:
      - frontend
    depends_on:
      - user-service
      - product-service
      - order-service

  # User Management Service
  user-service:
    build: ./services/user-service
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://user-db:5432/users
      - JWT_SECRET=${JWT_SECRET}
      - REDIS_URL=redis://redis:6379
    networks:
      - frontend
      - user-backend
    depends_on:
      - user-db
      - redis
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  user-db:
    image: postgres:13
    environment:
      - POSTGRES_DB=users
      - POSTGRES_USER=userservice
      - POSTGRES_PASSWORD=${USER_DB_PASSWORD}
    volumes:
      - user_db_data:/var/lib/postgresql/data
    networks:
      - user-backend

  # Product Catalog Service
  product-service:
    build: ./services/product-service
    environment:
      - NODE_ENV=production
      - MONGODB_URL=mongodb://product-db:27017/products
      - ELASTICSEARCH_URL=http://elasticsearch:9200
    networks:
      - frontend
      - product-backend
    depends_on:
      - product-db
      - elasticsearch

  product-db:
    image: mongo:4.4
    volumes:
      - product_db_data:/data/db
    networks:
      - product-backend

  elasticsearch:
    image: elasticsearch:7.14.0
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    volumes:
      - es_data:/usr/share/elasticsearch/data
    networks:
      - product-backend

  # Order Management Service
  order-service:
    build: ./services/order-service
    environment:
      - NODE_ENV=production
      - DATABASE_URL=mysql://order-db:3306/orders
      - USER_SERVICE_URL=http://user-service:3000
      - PRODUCT_SERVICE_URL=http://product-service:3000
      - PAYMENT_SERVICE_URL=http://payment-service:3000
      - RABBITMQ_URL=amqp://rabbitmq:5672
    networks:
      - frontend
      - order-backend
      - messaging
    depends_on:
      - order-db
      - rabbitmq

  order-db:
    image: mysql:8.0
    environment:
      - MYSQL_DATABASE=orders
      - MYSQL_USER=orderservice
      - MYSQL_PASSWORD=${ORDER_DB_PASSWORD}
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
    volumes:
      - order_db_data:/var/lib/mysql
    networks:
      - order-backend

  # Payment Service
  payment-service:
    build: ./services/payment-service
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://payment-db:5432/payments
      - STRIPE_SECRET_KEY=${STRIPE_SECRET_KEY}
      - RABBITMQ_URL=amqp://rabbitmq:5672
    networks:
      - frontend
      - payment-backend
      - messaging
    depends_on:
      - payment-db
      - rabbitmq

  payment-db:
    image: postgres:13
    environment:
      - POSTGRES_DB=payments
      - POSTGRES_USER=paymentservice
      - POSTGRES_PASSWORD=${PAYMENT_DB_PASSWORD}
    volumes:
      - payment_db_data:/var/lib/postgresql/data
    networks:
      - payment-backend

  # Message Queue
  rabbitmq:
    image: rabbitmq:3-management
    environment:
      - RABBITMQ_DEFAULT_USER=admin
      - RABBITMQ_DEFAULT_PASS=${RABBITMQ_PASSWORD}
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq
    networks:
      - messaging
    ports:
      - "15672:15672"  # Management UI

  # Shared Cache
  redis:
    image: redis:6-alpine
    volumes:
      - redis_data:/data
    networks:
      - user-backend
      - product-backend

  # Monitoring
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    networks:
      - monitoring

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
    volumes:
      - grafana_data:/var/lib/grafana
    networks:
      - monitoring

networks:
  frontend:
  user-backend:
  product-backend:
  order-backend:
  payment-backend:
  messaging:
  monitoring:

volumes:
  user_db_data:
  product_db_data:
  order_db_data:
  payment_db_data:
  es_data:
  rabbitmq_data:
  redis_data:
  prometheus_data:
  grafana_data:
```

#### 서비스별 디렉토리 구조
```
microservices-ecommerce/
├── docker-compose.yml
├── .env
├── nginx/
│   ├── nginx.conf
│   └── ssl/
├── services/
│   ├── user-service/
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   └── src/
│   ├── product-service/
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   └── src/
│   ├── order-service/
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   └── src/
│   └── payment-service/
│       ├── Dockerfile
│       ├── package.json
│       └── src/
└── monitoring/
    ├── prometheus.yml
    └── grafana/
```

---

## 💭 함께 생각해보기 (10분)

### 🤝 팀 프로젝트 아키텍처 설계 (7분)
**설계 미션**: 오후 팀 프로젝트를 위한 마이크로서비스 아키텍처 설계

**팀별 프로젝트 옵션**:
1. **E-commerce 플랫폼**: 사용자, 상품, 주문, 결제 서비스
2. **블로그 플랫폼**: 인증, 콘텐츠, 댓글, 검색 서비스  
3. **채팅 애플리케이션**: 사용자, 채팅, 알림, 파일 서비스

**설계 활동**:
- 👥 **서비스 분해**: 비즈니스 기능별 서비스 식별
- 🔗 **통신 설계**: 서비스 간 통신 방법 결정
- 🗄️ **데이터 설계**: 서비스별 데이터베이스 선택
- 🌐 **네트워크 설계**: 보안과 성능을 고려한 네트워크 구성

**설계 템플릿**:
```mermaid
graph TB
    subgraph "Frontend Layer"
        A[Web UI]
        B[Mobile App]
    end
    
    subgraph "API Gateway"
        C[Nginx/Kong]
    end
    
    subgraph "Business Services"
        D[Service 1]
        E[Service 2]
        F[Service 3]
    end
    
    subgraph "Data Layer"
        G[Database 1]
        H[Database 2]
        I[Cache]
    end
    
    A --> C
    B --> C
    C --> D
    C --> E
    C --> F
    D --> G
    E --> H
    F --> I
```

### 🎯 전체 공유 (3분)
- **아키텍처 발표**: 각 팀의 서비스 분해 전략
- **기술 선택**: 서비스별 기술 스택 결정 근거
- **도전 과제**: 예상되는 구현 어려움과 해결 방안

### 💡 이해도 체크 질문
- ✅ "마이크로서비스를 어떤 기준으로 분해해야 하나요?"
- ✅ "서비스 간 통신에서 고려해야 할 요소들은?"
- ✅ "데이터 일관성 문제를 어떻게 해결할 수 있나요?"

---

## 🔑 핵심 키워드

### 마이크로서비스 원칙
- **Single Responsibility**: 단일 책임 원칙
- **Decentralized**: 분산화된 거버넌스
- **Database per Service**: 서비스별 데이터베이스
- **Failure Isolation**: 장애 격리

### 아키텍처 패턴
- **API Gateway**: 단일 진입점 패턴
- **Service Discovery**: 서비스 발견 패턴
- **Circuit Breaker**: 회로 차단기 패턴
- **Event Sourcing**: 이벤트 기반 아키텍처

### 통신 방식
- **Synchronous**: HTTP/REST API 동기 통신
- **Asynchronous**: 메시지 큐 비동기 통신
- **Event-Driven**: 이벤트 기반 통신
- **GraphQL**: 유연한 API 쿼리

### 데이터 관리
- **Database per Service**: 서비스별 전용 DB
- **Saga Pattern**: 분산 트랜잭션 관리
- **CQRS**: 명령과 조회 분리
- **Event Store**: 이벤트 저장소

---

## 📝 세션 마무리

### ✅ 오늘 세션 성과
- [ ] 마이크로서비스 아키텍처 원칙과 패턴 완전 이해
- [ ] 실무급 마이크로서비스 구성 방법 습득
- [ ] 팀 프로젝트를 위한 아키텍처 설계 완료
- [ ] Docker Compose로 복잡한 시스템 구현 준비

### 🎯 다음 세션 준비
- **주제**: 마이크로서비스 구축 팀 프로젝트 (3시간)
- **연결고리**: 아키텍처 설계 → 실제 구현 → 팀 협업
- **준비사항**: 팀 구성 및 역할 분담, 구현 계획 수립

### 📊 아키텍처 복잡도 진화
```mermaid
graph LR
    A[단일 컨테이너<br/>Day 1-2] --> B[멀티 컨테이너<br/>Day 3]
    B --> C[Compose 기초<br/>Session 1]
    C --> D[고급 Compose<br/>Session 2]
    D --> E[마이크로서비스<br/>Session 3 ✅]
    E --> F[팀 프로젝트<br/>Session 4]
    
    style A,B,C,D fill:#4caf50
    style E fill:#ff9800
    style F fill:#e0e0e0
```

### 🏆 팀 프로젝트 준비 완료
**오후 목표**:
- 설계한 아키텍처를 실제 구현
- 모든 마이크로서비스 정상 통신
- 팀워크를 통한 복잡한 시스템 완성
- 모니터링과 로깅 구현

---

<div align="center">

**🏗️ 마이크로서비스 아키텍처 전문가가 되었습니다**

*설계 원칙부터 실무 패턴까지, 현대적 애플리케이션 아키텍처의 모든 것*

**이전**: [Session 2 - 고급 Compose 기능](./session_2.md) | **다음**: [Session 4 - 팀 프로젝트](./session_4.md)

</div>