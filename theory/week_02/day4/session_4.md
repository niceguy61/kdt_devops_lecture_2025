# Week 2 Day 4 Session 4: 개인 DevOps 포트폴리오 프로젝트

<div align="center">

**👨‍💻 개인 프로젝트** • **🤖 AI 협업** • **🏗️ DevOps 포트폴리오**

*AI 도구와 협업하여 완성하는 개인 DevOps 전문가 포트폴리오*

</div>

---

## 🕘 세션 정보

**시간**: 13:00-17:30 (4.5시간)  
**목표**: AI 도구를 활용하여 개인 DevOps 포트폴리오 프로젝트 완성  
**방식**: 개인 프로젝트 + AI 도구 협업 + DevOps 중심 구현

---

## 🎯 프로젝트 목표

### 📚 개인 DevOps 목표
- **DevOps 전문성**: Week 1-2 모든 기술을 활용한 개인 프로젝트
- **AI 협업**: 개발/디자인/기획에서 AI 도구 적극 활용
- **포트폴리오**: 취업용 DevOps 전문가 포트폴리오 완성
- **실무 역량**: 혼자서도 완전한 시스템을 구축할 수 있는 능력

### 🤖 AI 도구 활용 전략
- **DevOps 엔지니어**: Docker, 인프라, 모니터링에 집중
- **개발 부분**: GitHub Copilot, ChatGPT로 코드 생성 지원
- **디자인 부분**: Figma AI, Midjourney로 UI/UX 디자인
- **기획 부분**: Claude, GPT로 요구사항 정의 및 문서화

---

## 📋 프로젝트 선택 (개인별 선택)

### 🎯 DevOps 중심 프로젝트 옵션

**Option 1: 개인 블로그 플랫폼**
- **DevOps 역할**: 컨테이너화, CI/CD, 모니터링
- **AI 활용**: 블로그 콘텐츠 생성, UI 디자인, 백엔드 API

**Option 2: 포트폴리오 웹사이트**
- **DevOps 역할**: 인프라 구축, 성능 최적화, 보안 강화
- **AI 활용**: 포트폴리오 콘텐츠, 반응형 디자인, 인터랙션

**Option 3: 개인 프로젝트 관리 도구**
- **DevOps 역할**: 마이크로서비스 아키텍처, 오케스트레이션
- **AI 활용**: 기능 기획, 프론트엔드 개발, 데이터 모델링

**Option 4: 기술 블로그 + 데모 사이트**
- **DevOps 역할**: 멀티 환경 배포, 로그 분석, 성능 튜닝
- **AI 활용**: 기술 문서 작성, 코드 예제, 시각적 설명

---

## 🚀 Phase 1: AI와 함께 프로젝트 설계 (60분)

### 🤖 AI 도구 활용 가이드

**1. 프로젝트 기획 (ChatGPT/Claude)**
```
프롬프트 예시:
"DevOps 엔지니어 포트폴리오용 개인 블로그 플랫폼을 만들고 싶습니다. 
다음 기술 스택을 사용할 예정입니다: Docker, Node.js, PostgreSQL, Redis, Nginx
- 핵심 기능 요구사항을 정의해주세요
- 데이터베이스 스키마를 설계해주세요  
- API 엔드포인트를 설계해주세요
- 보안 고려사항을 제안해주세요"
```

**2. 아키텍처 설계 (AI + 개인 DevOps 전문성)**
```mermaid
graph TB
    subgraph "개인 DevOps 프로젝트 아키텍처"
        A[Nginx<br/>Reverse Proxy] --> B[Frontend<br/>AI 생성 UI]
        A --> C[Backend API<br/>AI 지원 개발]
        C --> D[PostgreSQL<br/>데이터 저장]
        C --> E[Redis<br/>캐싱]
        
        F[Prometheus<br/>메트릭 수집] --> G[Grafana<br/>모니터링]
        H[Docker Compose<br/>로컬 개발]
        I[Docker Swarm<br/>배포 준비]
    end
    
    style A fill:#e3f2fd
    style F fill:#fff3e0
    style G fill:#e8f5e8
    style H fill:#ffebee
    style I fill:#f3e5f5
```

**3. UI/UX 디자인 (Figma AI/Midjourney)**
```
프롬프트 예시:
"Clean and modern blog interface design for DevOps engineer portfolio
- Dark theme with blue accents
- Technical documentation style
- Code syntax highlighting areas
- Responsive design for mobile and desktop
- Professional and minimalist aesthetic"
```

### 📋 개인 프로젝트 계획서 작성
```markdown
# 개인 DevOps 포트폴리오 프로젝트

## 프로젝트 개요
- **이름**: [프로젝트명]
- **목적**: DevOps 전문성 시연 + 취업 포트폴리오
- **기간**: 4.5시간 (MVP 완성)

## DevOps 기술 스택
- **컨테이너화**: Docker, Docker Compose
- **웹서버**: Nginx (리버스 프록시, 로드 밸런싱)
- **모니터링**: Prometheus + Grafana
- **보안**: SSL/TLS, 컨테이너 보안
- **성능**: 이미지 최적화, 캐싱 전략

## AI 도구 활용 계획
- **기획**: ChatGPT로 요구사항 정의
- **개발**: GitHub Copilot으로 코드 생성
- **디자인**: Figma AI로 UI 컴포넌트
- **콘텐츠**: AI로 샘플 데이터 생성

## 성공 기준
- [ ] 완전한 컨테이너화 (Docker)
- [ ] 보안 스캔 통과 (Trivy)
- [ ] 성능 최적화 (이미지 < 100MB)
- [ ] 모니터링 대시보드 구축
- [ ] 취업용 포트폴리오 완성
```

---

## 🌟 Phase 2: DevOps 중심 개발 및 구현 (180분)

### 🔧 DevOps 엔지니어 핵심 작업

**Step 1: 컨테이너 인프라 구축 (60분)**

**최적화된 Dockerfile 작성**:
```dockerfile
# Frontend Dockerfile (AI 생성 코드 + DevOps 최적화)
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force
COPY . .
RUN npm run build

FROM nginx:alpine
# DevOps: 보안 강화
RUN adduser -D -s /bin/sh nginx && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d
RUN touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

USER nginx
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
```

**Docker Compose 인프라 구성**:
```yaml
# docker-compose.yml - DevOps 전문성 시연
version: '3.8'

services:
  # Frontend (AI 생성 + DevOps 최적화)
  frontend:
    build: 
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "80:8080"
    depends_on:
      - backend
    networks:
      - frontend-net
    deploy:
      resources:
        limits:
          memory: 128M
          cpus: '0.5'
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:8080"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Backend API (AI 지원 개발)
  backend:
    build: 
      context: ./backend
      dockerfile: Dockerfile
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://user:password@postgres:5432/myapp
      - REDIS_URL=redis://redis:6379
    depends_on:
      - postgres
      - redis
    networks:
      - frontend-net
      - backend-net
    deploy:
      resources:
        limits:
          memory: 256M
          cpus: '0.5'
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Database
  postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - backend-net
    deploy:
      resources:
        limits:
          memory: 256M
          cpus: '0.3'
    restart: unless-stopped

  # Cache
  redis:
    image: redis:7-alpine
    networks:
      - backend-net
    deploy:
      resources:
        limits:
          memory: 64M
          cpus: '0.2'
    restart: unless-stopped

  # DevOps: 모니터링 스택
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    networks:
      - monitoring-net
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
      - ./monitoring/grafana:/etc/grafana/provisioning
    networks:
      - monitoring-net
    depends_on:
      - prometheus

networks:
  frontend-net:
    driver: bridge
  backend-net:
    driver: bridge
    internal: true
  monitoring-net:
    driver: bridge

volumes:
  postgres_data:
  prometheus_data:
  grafana_data:
```

**Step 2: 보안 및 성능 최적화 (60분)**

**보안 스캔 및 강화**:
```bash
# DevOps 보안 체크리스트
echo "=== DevOps 보안 검증 ==="

# 1. 이미지 취약점 스캔
trivy image myproject/frontend:latest
trivy image myproject/backend:latest

# 2. 컨테이너 보안 설정 확인
docker inspect myproject_frontend_1 | jq '.[0].HostConfig.SecurityOpt'
docker inspect myproject_backend_1 | jq '.[0].Config.User'

# 3. 네트워크 보안 확인
docker network ls
docker network inspect myproject_backend-net

# 4. 리소스 제한 확인
docker stats --no-stream
```

**성능 최적화 및 모니터링**:
```bash
# DevOps 성능 최적화 체크
echo "=== DevOps 성능 검증 ==="

# 1. 이미지 크기 최적화 확인
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep myproject

# 2. 빌드 시간 측정
time docker-compose build

# 3. 애플리케이션 성능 테스트
ab -n 1000 -c 10 http://localhost/api/health

# 4. 리소스 사용량 모니터링
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

**Step 3: 모니터링 및 관측성 구현 (60분)**

**Prometheus 설정**:
```yaml
# monitoring/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

  - job_name: 'app-metrics'
    static_configs:
      - targets: ['backend:3000']
    metrics_path: '/metrics'
```

**애플리케이션 메트릭 (AI 지원 구현)**:
```javascript
// backend/metrics.js - AI로 생성 후 DevOps 최적화
const prometheus = require('prom-client');

// DevOps: 핵심 비즈니스 메트릭 정의
const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10]
});

const httpRequestTotal = new prometheus.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

const activeConnections = new prometheus.Gauge({
  name: 'active_connections',
  help: 'Number of active connections'
});

// DevOps: 헬스 체크 엔드포인트
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// DevOps: 메트릭 엔드포인트
app.get('/metrics', (req, res) => {
  res.set('Content-Type', prometheus.register.contentType);
  res.end(prometheus.register.metrics());
});
```

---

## 🏆 Phase 3: 배포 준비 및 포트폴리오 완성 (60분)

### 🔧 DevOps 배포 파이프라인 준비

**Docker Swarm 배포 준비**:
```bash
# DevOps: 프로덕션 배포 준비
echo "=== 배포 준비 체크리스트 ==="

# 1. Swarm 모드 초기화
docker swarm init

# 2. 스택 배포
docker stack deploy -c docker-compose.prod.yml myproject

# 3. 서비스 상태 확인
docker service ls
docker service ps myproject_frontend

# 4. 스케일링 테스트
docker service scale myproject_frontend=3
docker service scale myproject_backend=2

# 5. 롤링 업데이트 테스트
docker service update --image myproject/frontend:v2 myproject_frontend
```

**포트폴리오 문서화**:
```markdown
# DevOps 포트폴리오 프로젝트

## 🎯 프로젝트 개요
개인 DevOps 전문성을 시연하기 위한 완전한 컨테이너화된 웹 애플리케이션

## 🛠️ DevOps 기술 스택
- **컨테이너화**: Docker, Docker Compose, Docker Swarm
- **웹 서버**: Nginx (리버스 프록시, 로드 밸런싱)
- **모니터링**: Prometheus + Grafana
- **보안**: 컨테이너 보안, 네트워크 격리
- **성능**: 이미지 최적화, 리소스 제한

## 🤖 AI 협업 활용
- **개발**: GitHub Copilot으로 백엔드 API 개발
- **디자인**: Figma AI로 UI/UX 디자인
- **콘텐츠**: ChatGPT로 샘플 데이터 및 문서 생성

## 📊 성과 지표
- ✅ 이미지 크기: 평균 85MB (목표: <100MB)
- ✅ 보안 스캔: Critical 0개, High 0개
- ✅ 응답 시간: 평균 150ms (목표: <200ms)
- ✅ 가용성: 99.9% (헬스 체크 기반)

## 🚀 배포 및 운영
- Docker Swarm으로 멀티 노드 배포 준비 완료
- Prometheus + Grafana 모니터링 대시보드 구축
- 자동 스케일링 및 롤링 업데이트 지원

## 💼 실무 적용 가능성
이 프로젝트는 실제 프로덕션 환경에서 사용 가능한 수준으로 구현되었으며,
DevOps 엔지니어로서의 전문성을 충분히 시연합니다.
```

### ✅ 최종 체크리스트
- [ ] 완전한 컨테이너화 구현
- [ ] 보안 스캔 통과 (Critical: 0개)
- [ ] 성능 목표 달성 (이미지 < 100MB, 응답 < 200ms)
- [ ] 모니터링 대시보드 구축
- [ ] Docker Swarm 배포 준비 완료
- [ ] 포트폴리오 문서 완성
- [ ] AI 도구 활용 경험 축적

---

## 🎤 개인 발표 및 포트폴리오 공유 (50분)

### 📊 개인별 발표 (4분×12명)
**발표 내용**:
1. **프로젝트 소개**: 구현한 개인 프로젝트 개요
2. **DevOps 전문성**: 적용한 DevOps 기술과 최적화
3. **AI 협업 경험**: AI 도구 활용 방법과 효과
4. **기술적 도전**: 해결한 기술적 문제와 학습
5. **포트폴리오 가치**: 취업용 포트폴리오로서의 강점
6. **향후 계획**: Week 3 Kubernetes 학습 연계 방안

### 🏅 상호 피드백 및 네트워킹
- 동료들의 프로젝트에서 배울 점 공유
- DevOps 기술 적용 방법 상호 학습
- AI 도구 활용 팁 교환
- 포트폴리오 개선 아이디어 제안

---

## 📝 프로젝트 마무리

### ✅ 개인 성과
- [ ] Week 1-2 모든 DevOps 기술 통합 활용
- [ ] AI 도구와의 효과적 협업 경험
- [ ] 완성도 높은 개인 포트폴리오 프로젝트
- [ ] 실무급 DevOps 시스템 구축 능력 입증
- [ ] 독립적인 문제 해결 능력 개발
- [ ] 취업용 포트폴리오 완성

### 🎯 Week 3 준비사항
- **기술적 자신감**: 개인 프로젝트 완성을 통한 자신감 확보
- **DevOps 전문성**: Docker 전문가 수준 달성
- **AI 협업 역량**: 개발 외 영역에서 AI 도구 활용 능력
- **포트폴리오**: 취업 준비를 위한 실무급 프로젝트 보유

### 🚀 실무 연계 포인트
- **개인 역량**: 혼자서도 완전한 시스템 구축 가능
- **AI 활용**: 개발 생산성 향상을 위한 AI 도구 활용
- **DevOps 전문성**: 컨테이너, 모니터링, 보안 통합 관리
- **포트폴리오**: 실제 취업 면접에서 활용 가능한 프로젝트

---

<div align="center">

**👨‍💻 개인 DevOps 전문가로서의 역량을 완벽하게 입증했습니다!**

*AI와 협업하여 혼자서도 완전한 시스템을 구축할 수 있는 DevOps 엔지니어*

**다음**: [Session 5 - Kubernetes 학습 준비 멘토링](./session_5.md)

</div>