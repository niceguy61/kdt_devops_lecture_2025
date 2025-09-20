# Week 2 Day 1 Session 3: 서비스 의존성과 헬스체크

<div align="center">

**🔗 의존성 관리** • **💓 헬스체크**

*안정적이고 신뢰할 수 있는 마이크로서비스 시스템 구축*

</div>

---

## 🕘 세션 정보

**시간**: 11:00-11:50 (50분)  
**목표**: 서비스 의존성과 헬스체크를 통한 시스템 안정성 확보  
**방식**: 실무 시나리오 + 장애 대응 + 자동 복구 메커니즘

---

## 🎯 세션 목표

### 📚 학습 목표
- **이해 목표**: 서비스 의존성과 헬스체크 메커니즘 완전 이해
- **적용 목표**: 안정적인 서비스 시작 순서와 자동 복구 시스템 구현
- **협업 목표**: 팀 프로젝트에서 장애 상황을 고려한 견고한 시스템 설계

### 🤔 왜 의존성과 헬스체크인가? (5분)

**현실 문제 상황**:
- 💼 **실무 시나리오**: 데이터베이스가 준비되기 전에 API가 시작되어 연결 실패
- 🏠 **일상 비유**: 요리할 때 재료 준비 순서와 상태 확인이 중요한 것과 같음
- 📊 **시장 동향**: 마이크로서비스 환경에서 서비스 간 의존성 관리는 필수

**의존성 관리의 중요성**:
```mermaid
graph TB
    subgraph "의존성 관리 없음"
        A1[모든 서비스<br/>동시 시작] --> B1[연결 실패 💥]
        B1 --> C1[서비스 장애 💥]
    end
    
    subgraph "올바른 의존성 관리"
        A2[순차적 서비스<br/>시작] --> B2[헬스체크 확인]
        B2 --> C2[안정적 연결 ✅]
        C2 --> D2[자동 복구 ✅]
    end
    
    style B1,C1 fill:#ffebee
    style C2,D2 fill:#e8f5e8
```

---

## 📖 핵심 개념 (35분)

### 🔍 개념 1: depends_on과 서비스 시작 순서 (12분)

> **정의**: 서비스 간 의존성을 정의하여 올바른 시작 순서를 보장하는 메커니즘

**기본 depends_on 사용법**:
```yaml
# docker-compose.yml
version: '3.8'

services:
  # 데이터베이스 (가장 먼저 시작)
  database:
    image: postgres:13
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d myapp"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 30s
  
  # 캐시 서비스
  redis:
    image: redis:7-alpine
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
  
  # API 서비스 (데이터베이스와 캐시에 의존)
  api:
    build: ./api
    depends_on:
      database:
        condition: service_healthy  # 헬스체크 통과 후 시작
      redis:
        condition: service_healthy
    environment:
      - DATABASE_URL=postgresql://user:password@database:5432/myapp
      - REDIS_URL=redis://redis:6379
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
  
  # 웹 서비스 (API에 의존)
  web:
    build: ./web
    depends_on:
      api:
        condition: service_healthy
    ports:
      - "80:80"
    environment:
      - API_URL=http://api:3000
```

**복잡한 의존성 관계**:
```yaml
services:
  # 메시지 큐
  rabbitmq:
    image: rabbitmq:3-management
    healthcheck:
      test: ["CMD", "rabbitmq-diagnostics", "ping"]
      interval: 30s
      timeout: 10s
      retries: 5
  
  # 워커 서비스들
  email-worker:
    build: ./workers/email
    depends_on:
      database:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    deploy:
      replicas: 2
  
  notification-worker:
    build: ./workers/notification
    depends_on:
      database:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
      redis:
        condition: service_healthy
  
  # API 서비스 (모든 인프라에 의존)
  api:
    build: ./api
    depends_on:
      database:
        condition: service_healthy
      redis:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    ports:
      - "3000:3000"
```

**의존성 시각화**:
```mermaid
graph TB
    subgraph "Infrastructure Layer"
        DB[(Database)]
        REDIS[(Redis)]
        MQ[(RabbitMQ)]
    end
    
    subgraph "Service Layer"
        API[API Service]
        WORKER1[Email Worker]
        WORKER2[Notification Worker]
    end
    
    subgraph "Frontend Layer"
        WEB[Web Service]
        LB[Load Balancer]
    end
    
    DB --> API
    DB --> WORKER1
    DB --> WORKER2
    REDIS --> API
    REDIS --> WORKER2
    MQ --> WORKER1
    MQ --> WORKER2
    API --> WEB
    WEB --> LB
    
    style DB,REDIS,MQ fill:#e8f5e8
    style API,WORKER1,WORKER2 fill:#fff3e0
    style WEB,LB fill:#e3f2fd
```

### 🔍 개념 2: 헬스체크와 서비스 가용성 확인 (12분)

> **정의**: 서비스의 상태를 지속적으로 모니터링하여 가용성을 보장하는 메커니즘

**다양한 헬스체크 패턴**:
```yaml
services:
  # HTTP 헬스체크
  web-api:
    image: myapp:api
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s      # 30초마다 체크
      timeout: 10s       # 10초 내 응답 필요
      retries: 3         # 3번 실패 시 unhealthy
      start_period: 60s  # 시작 후 60초 대기
  
  # 데이터베이스 헬스체크
  postgres:
    image: postgres:13
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 30s
  
  # Redis 헬스체크
  redis:
    image: redis:7-alpine
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3
  
  # MongoDB 헬스체크
  mongodb:
    image: mongo:6
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
      interval: 30s
      timeout: 10s
      retries: 3
  
  # 커스텀 헬스체크 스크립트
  custom-service:
    build: .
    healthcheck:
      test: ["CMD", "/app/healthcheck.sh"]
      interval: 30s
      timeout: 10s
      retries: 3
```

**애플리케이션 레벨 헬스체크**:
```javascript
// Node.js Express 헬스체크 엔드포인트
app.get('/health', async (req, res) => {
  const healthCheck = {
    uptime: process.uptime(),
    message: 'OK',
    timestamp: Date.now(),
    checks: {}
  };
  
  try {
    // 데이터베이스 연결 확인
    await db.query('SELECT 1');
    healthCheck.checks.database = 'OK';
    
    // Redis 연결 확인
    await redis.ping();
    healthCheck.checks.redis = 'OK';
    
    // 외부 API 확인
    const response = await fetch('https://api.external.com/health');
    healthCheck.checks.external_api = response.ok ? 'OK' : 'FAIL';
    
    res.status(200).json(healthCheck);
  } catch (error) {
    healthCheck.message = error.message;
    healthCheck.checks.error = error.message;
    res.status(503).json(healthCheck);
  }
});
```

**헬스체크 기반 자동 복구**:
```yaml
services:
  api:
    image: myapp:api
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    
    # 헬스체크 실패 시 자동 재시작
    restart: unless-stopped
    
    # 추가 복구 옵션 (Docker Swarm 모드)
    deploy:
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 120s
      
      # 헬스체크 실패 시 새 컨테이너로 교체
      update_config:
        failure_action: rollback
        monitor: 60s
```

### 🔍 개념 3: 재시작 정책과 장애 복구 (11분)

> **정의**: 서비스 장애 시 자동으로 복구하는 정책과 메커니즘

**재시작 정책 옵션**:
```yaml
services:
  # 항상 재시작 (프로덕션 권장)
  web:
    image: nginx
    restart: always
  
  # 실패 시에만 재시작
  api:
    image: myapp:api
    restart: on-failure
  
  # 수동으로 중지하지 않는 한 재시작
  database:
    image: postgres:13
    restart: unless-stopped
  
  # 재시작 안함 (개발/테스트용)
  test-service:
    image: myapp:test
    restart: "no"
```

**고급 재시작 정책 (Docker Swarm)**:
```yaml
services:
  api:
    image: myapp:api
    deploy:
      replicas: 3
      restart_policy:
        condition: on-failure    # 실패 시에만 재시작
        delay: 5s               # 5초 대기 후 재시작
        max_attempts: 3         # 최대 3번 시도
        window: 120s            # 120초 내 실패 횟수 계산
      
      # 업데이트 정책
      update_config:
        parallelism: 1          # 한 번에 1개씩 업데이트
        delay: 10s              # 업데이트 간 10초 대기
        failure_action: rollback # 실패 시 롤백
        monitor: 60s            # 60초 모니터링
        max_failure_ratio: 0.3  # 30% 실패 시 중단
      
      # 롤백 정책
      rollback_config:
        parallelism: 1
        delay: 10s
        failure_action: pause
        monitor: 60s
```

**장애 복구 시나리오**:
```yaml
services:
  # 주 데이터베이스
  primary-db:
    image: postgres:13
    environment:
      - POSTGRES_REPLICATION_MODE=master
    volumes:
      - primary-db-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 30s
      timeout: 10s
      retries: 5
  
  # 복제 데이터베이스
  replica-db:
    image: postgres:13
    environment:
      - POSTGRES_REPLICATION_MODE=slave
      - POSTGRES_MASTER_HOST=primary-db
    depends_on:
      primary-db:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 30s
      timeout: 10s
      retries: 5
  
  # API 서비스 (DB 장애 시 읽기 전용 모드)
  api:
    image: myapp:api
    environment:
      - PRIMARY_DB_URL=postgresql://primary-db:5432/myapp
      - REPLICA_DB_URL=postgresql://replica-db:5432/myapp
    depends_on:
      primary-db:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    
    # 장애 시 자동 재시작
    restart: unless-stopped
```

**Circuit Breaker 패턴 구현**:
```javascript
// Circuit Breaker를 활용한 장애 격리
class CircuitBreaker {
  constructor(threshold = 5, timeout = 60000) {
    this.threshold = threshold;
    this.timeout = timeout;
    this.failureCount = 0;
    this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
    this.nextAttempt = Date.now();
  }
  
  async call(fn) {
    if (this.state === 'OPEN') {
      if (Date.now() < this.nextAttempt) {
        throw new Error('Circuit breaker is OPEN');
      }
      this.state = 'HALF_OPEN';
    }
    
    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }
  
  onSuccess() {
    this.failureCount = 0;
    this.state = 'CLOSED';
  }
  
  onFailure() {
    this.failureCount++;
    if (this.failureCount >= this.threshold) {
      this.state = 'OPEN';
      this.nextAttempt = Date.now() + this.timeout;
    }
  }
}
```

---

## 💭 함께 생각해보기 (10분)

### 🤝 페어 토론 (5분)

**토론 주제**:
1. **의존성 설계**: "복잡한 마이크로서비스에서 의존성 순환을 어떻게 방지할 수 있을까요?"
2. **장애 대응**: "데이터베이스가 다운되었을 때 서비스를 어떻게 유지할 수 있을까요?"
3. **헬스체크 전략**: "헬스체크가 너무 자주 실행되면 성능에 영향을 줄 수 있는데, 어떻게 균형을 맞출까요?"

**페어 활동 가이드**:
- 👥 **장애 시나리오**: 실제 장애 상황을 가정하고 대응 방안 토론
- 🔄 **복구 전략**: 다양한 장애 유형별 자동 복구 메커니즘 설계
- 📝 **모니터링**: 헬스체크와 모니터링의 효과적인 조합 방법

### 🎯 전체 공유 (5분)

**인사이트 공유**:
- 페어 토론에서 나온 창의적인 장애 대응 아이디어
- 실무에서 겪을 수 있는 의존성 관리 문제와 해결책
- 오후 챌린지에서 구현할 안정성 확보 방안

**💡 이해도 체크 질문**:
- ✅ "서비스 의존성을 올바르게 정의할 수 있나요?"
- ✅ "효과적인 헬스체크를 구현할 수 있나요?"
- ✅ "장애 상황에서의 자동 복구 메커니즘을 이해했나요?"

---

## 🔑 핵심 키워드

### 🆕 새로운 용어
- **Service Dependency**: 서비스 의존성 - 서비스 간 시작 순서 관계
- **Health Check**: 헬스체크 - 서비스 상태 확인 메커니즘
- **Restart Policy**: 재시작 정책 - 장애 시 자동 복구 규칙
- **Circuit Breaker**: 회로 차단기 - 장애 전파 방지 패턴
- **Graceful Degradation**: 우아한 성능 저하 - 부분 장애 시 서비스 유지

### 🔤 기술 용어
- **depends_on**: 의존성 정의 - Compose의 서비스 의존성 설정
- **condition**: 조건 - 의존성 시작 조건 (service_started, service_healthy)
- **start_period**: 시작 대기 시간 - 헬스체크 시작 전 대기 시간
- **retries**: 재시도 횟수 - 헬스체크 실패 허용 횟수
- **rollback**: 롤백 - 장애 시 이전 버전으로 복구

### 🔤 실무 용어
- **High Availability**: 고가용성 - 시스템 중단 시간 최소화
- **Fault Tolerance**: 장애 허용성 - 부분 장애에도 동작 유지
- **Service Mesh**: 서비스 메시 - 마이크로서비스 통신 관리
- **Load Balancing**: 로드 밸런싱 - 트래픽 분산을 통한 안정성
- **Monitoring**: 모니터링 - 시스템 상태 지속적 관찰

---

## 📝 세션 마무리

### ✅ 오늘 세션 성과
- [ ] 서비스 의존성과 시작 순서 관리 완전 습득 ✅
- [ ] 다양한 헬스체크 패턴과 구현 방법 마스터 ✅
- [ ] 재시작 정책과 자동 복구 메커니즘 이해 ✅
- [ ] 장애 상황에 대한 대응 전략 수립 능력 개발 ✅

### 🎯 오후 챌린지 준비
- **통합 활용**: 오전 3세션에서 배운 모든 Compose 지식 결합
- **실무 적용**: Week 1 마이크로서비스를 안정적인 Compose 시스템으로 완전 변환
- **운영 준비**: 프로덕션 환경에서 바로 사용할 수 있는 수준의 구성

### 🔮 챌린지 미리보기
**E-Commerce 플랫폼 Compose 구축**에서 구현할 내용:
- 복잡한 서비스 의존성 관리 (DB → API → Web → LB)
- 모든 서비스의 헬스체크와 자동 복구 구현
- 환경별 설정과 시크릿 관리 통합 적용
- 장애 상황을 고려한 견고한 시스템 설계

---

<div align="center">

**🔗 서비스 의존성과 헬스체크를 완전히 마스터했습니다!**

*안정적이고 신뢰할 수 있는 마이크로서비스 시스템 구축 완성*

**이전**: [Session 2 - 환경별 설정 관리와 시크릿](./session_2.md) | **다음**: [Session 4 - E-Commerce 플랫폼 Compose 구축](./session_4.md)

</div>