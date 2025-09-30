# Week 2 Day 3 Session 2: 이미지 최적화 & 성능 튜닝

<div align="center">

**⚡ 성능 최적화** • **📦 이미지 최적화** • **🔧 튜닝 기법**

*실무에서 필수인 컨테이너 성능 최적화와 이미지 크기 최소화*

</div>

---

## 🕘 세션 정보
**시간**: 10:00-10:50 (50분)
**목표**: 컨테이너 이미지 최적화와 성능 튜닝 기법 완전 이해
**방식**: 이론 학습 + 실습 예제 + 페어 토론

## 🎯 세션 목표
### 📚 학습 목표
- **이해 목표**: 컨테이너 이미지 최적화와 성능 튜닝 기법 완전 이해
- **적용 목표**: 실무에서 사용할 수 있는 최적화 도구와 기법 습득
- **협업 목표**: 팀원들과 성능 최적화 전략 및 모니터링 방안 토론

### 🤔 왜 필요한가? (5분)

**현실 문제 상황**:
- 💼 **배포 지연**: 큰 이미지로 인한 배포 시간 증가
- 🏠 **일상 비유**: 짐이 많으면 이사가 오래 걸리는 것과 같은 원리
- 📊 **비용 증가**: 스토리지 비용과 네트워크 대역폭 비용 급증

**학습 전후 비교**:
```mermaid
graph LR
    A[학습 전<br/>500MB+ 이미지] --> B[학습 후<br/>50MB- 이미지]
    
    style A fill:#ffebee
    style B fill:#e8f5e8
```

## 📖 핵심 개념 (35분)

### 🔍 개념 1: 이미지 크기 최적화 (12분)
> **정의**: 컨테이너 이미지의 크기를 최소화하여 배포 속도와 저장 비용을 개선하는 기법

**이미지 최적화 전략**:
```mermaid
graph TB
    subgraph "이미지 최적화 기법"
        A[멀티스테이지 빌드<br/>Multi-stage Build] --> E[최적화된 이미지]
        B[Alpine 베이스<br/>Alpine Base] --> E
        C[불필요한 파일 제거<br/>Clean up] --> E
        D[레이어 최적화<br/>Layer Optimization] --> E
    end
    
    subgraph "크기 비교"
        F[일반 이미지<br/>500MB+] --> G[최적화 후<br/>50MB-]
    end
    
    E --> G
    
    style A fill:#e8f5e8
    style B fill:#e8f5e8
    style C fill:#e8f5e8
    style D fill:#e8f5e8
    style E fill:#4caf50
    style F fill:#ffebee
    style G fill:#c8e6c9
```

**멀티스테이지 빌드 예시**:
```dockerfile
# 빌드 스테이지
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# 프로덕션 스테이지
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
RUN npm run build && \
    npm prune --production && \
    rm -rf src/ tests/ *.md

USER node
EXPOSE 3000
CMD ["node", "dist/server.js"]
```

**이미지 크기 분석**:
```bash
# 이미지 크기 확인
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# 이미지 레이어 분석
docker history myapp:latest

# dive 도구로 상세 분석
dive myapp:latest
```

### 🔍 개념 2: 성능 모니터링과 프로파일링 (12분)
> **정의**: 컨테이너 애플리케이션의 성능을 측정하고 병목 지점을 식별하는 방법

**성능 메트릭 계층**:
```mermaid
graph TB
    subgraph "성능 메트릭"
        A[애플리케이션 메트릭<br/>Response Time, Throughput] --> D[종합 성능 분석]
        B[시스템 메트릭<br/>CPU, Memory, I/O] --> D
        C[네트워크 메트릭<br/>Latency, Bandwidth] --> D
    end
    
    subgraph "모니터링 도구"
        E[Prometheus<br/>메트릭 수집] --> F[Grafana<br/>시각화]
        G[cAdvisor<br/>컨테이너 메트릭] --> E
        H[Node Exporter<br/>시스템 메트릭] --> E
    end
    
    D --> E
    
    style A fill:#e8f5e8
    style B fill:#e8f5e8
    style C fill:#e8f5e8
    style D fill:#4caf50
    style E fill:#fff3e0
    style G fill:#fff3e0
    style H fill:#fff3e0
    style F fill:#2196f3
```

**성능 모니터링 설정**:
```yaml
# docker-compose.monitoring.yml
version: '3.8'
services:
  app:
    image: myapp:latest
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
    
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
```

### 🔍 개념 3: 리소스 최적화 (11분)
> **정의**: CPU, 메모리, 네트워크 등 시스템 리소스를 효율적으로 사용하는 최적화 기법

**리소스 최적화 전략**:
```mermaid
graph TB
    subgraph "CPU 최적화"
        A[멀티스레딩<br/>Multi-threading] --> D[성능 향상]
        B[비동기 처리<br/>Async Processing] --> D
    end
    
    subgraph "메모리 최적화"
        C[메모리 풀링<br/>Memory Pooling] --> E[메모리 효율성]
        F[가비지 컬렉션 튜닝<br/>GC Tuning] --> E
    end
    
    subgraph "I/O 최적화"
        G[캐싱<br/>Caching] --> H[응답 속도 개선]
        I[연결 풀링<br/>Connection Pooling] --> H
    end
    
    D --> J[전체 성능 최적화]
    E --> J
    H --> J
    
    style A fill:#e8f5e8
    style B fill:#e8f5e8
    style C fill:#e8f5e8
    style F fill:#e8f5e8
    style G fill:#e8f5e8
    style I fill:#e8f5e8
    style D fill:#fff3e0
    style E fill:#fff3e0
    style H fill:#fff3e0
    style J fill:#4caf50
```

**리소스 제한 설정**:
```bash
# CPU 제한 (0.5 코어)
docker run --cpus="0.5" myapp:latest

# 메모리 제한 (512MB)
docker run --memory="512m" myapp:latest

# 복합 리소스 제한
docker run \
  --cpus="0.5" \
  --memory="512m" \
  --memory-swap="1g" \
  myapp:latest
```

**성능 벤치마크 테스트**:
```bash
# Apache Bench로 성능 테스트
ab -n 10000 -c 100 http://localhost:3000/

# 리소스 사용량 모니터링
docker stats myapp

# 성능 프로파일링
docker exec myapp top
docker exec myapp free -h
```

## 💭 함께 생각해보기 (10분)

**🤝 페어 토론** (5분):
**토론 주제**:
1. **최적화 우선순위**: "이미지 크기, CPU, 메모리 중 어떤 것을 먼저 최적화해야 할까요?"
2. **성능 vs 안정성**: "성능 최적화와 시스템 안정성 사이의 균형점은?"
3. **모니터링 전략**: "어떤 메트릭을 가장 중요하게 모니터링해야 할까요?"

**페어 활동 가이드**:
- 👥 **경험 공유**: 성능 최적화 경험이 있다면 공유
- 🔄 **문제 해결**: 성능 문제 상황과 해결 방법 토론
- 📝 **베스트 프랙티스**: 효과적인 최적화 방법 정리

**🎯 전체 공유** (5분):
- **최적화 경험**: 성능 최적화 경험과 효과적인 방법
- **도구 활용**: 성능 모니터링 도구의 실무 활용 방안
- **다음 연결**: Session 3 모니터링과의 연결고리

**💡 이해도 체크 질문**:
- ✅ "멀티스테이지 빌드의 장점을 설명할 수 있나요?"
- ✅ "성능 메트릭의 주요 계층을 이해했나요?"
- ✅ "리소스 제한 설정을 실무에 적용할 수 있나요?"

## 🔑 핵심 키워드

### 🔤 기본 용어
- **Multi-stage Build**: 멀티스테이지 빌드
- **Alpine Linux**: 경량 리눅스 배포판
- **Layer Optimization**: 레이어 최적화

### 🔤 성능 용어
- **Throughput**: 처리량
- **Latency**: 지연 시간
- **Resource Utilization**: 리소스 사용률

### 🔤 도구 및 기법
- **cAdvisor**: 컨테이너 메트릭 수집 도구
- **Dive**: 이미지 레이어 분석 도구
- **Apache Bench (ab)**: HTTP 성능 테스트 도구

## 📝 세션 마무리
### ✅ 오늘 세션 성과
- 이미지 최적화 기법 완전 습득
- 성능 모니터링과 프로파일링 방법 학습
- 리소스 최적화 전략 이해

### 🎯 다음 세션 준비
- **Session 3**: 모니터링 & 관측성
- **연결고리**: 최적화된 시스템의 포괄적 모니터링 방법
- **실습 준비**: 모니터링 도구 설치 및 대시보드 구성

---

<div align="center">

**⚡ 성능 최적화 마스터** • **📦 이미지 크기 최소화** • **🔧 리소스 효율성**

*컨테이너 성능 최적화의 모든 기법을 완전히 마스터했습니다*

</div>