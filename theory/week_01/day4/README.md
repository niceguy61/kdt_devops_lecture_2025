# Week 1 Day 4: Docker Compose & 멀티 컨테이너

<div align="center">

**🎼 Docker Compose 마스터** • **🏗️ 멀티 컨테이너 아키텍처**

*YAML로 정의하는 멀티 컨테이너 애플리케이션, Week 1 통합 프로젝트 완성*

</div>

---

## 🕘 일일 스케줄

### 📊 시간 배분
```
📚 이론 강의: 2.5시간 (31.25%) - 50분×3세션
🛠️ 실습 챌린지: 3시간 (37.5%) - 통합 프로젝트
👥 학생 케어: 2.5시간 (31.25%) - Week 1 총정리
```

### 🗓️ 상세 스케줄
| 시간 | 구분 | 내용 | 목적 |
|------|------|------|------|
| **09:00-09:50** | 📚 이론 1 | Docker Compose 개념 (50분) | YAML 기반 관리 |
| **09:50-10:00** | ☕ 휴식 | 10분 휴식 | |
| **10:00-10:50** | 📚 이론 2 | 멀티 컨테이너 아키텍처 (50분) | 서비스 설계 |
| **10:50-11:00** | ☕ 휴식 | 10분 휴식 | |
| **11:00-11:50** | 📚 이론 3 | 환경별 설정 관리 (50분) | 운영 환경 대응 |
| **11:50-13:00** | 🍽️ 점심 | 점심시간 (70분) | |
| **13:00-16:00** | 🛠️ 프로젝트 | Week 1 통합 프로젝트 (3시간) | 실무 시뮬레이션 |
| **16:00-16:15** | ☕ 휴식 | 15분 휴식 | |
| **16:15-18:00** | 👥 케어 | Week 1 총정리 & 회고 (105분) | 성과 점검 |

---

## 📚 이론 강의 (2.5시간 - 50분×3세션)

### Session 1: Docker Compose 개념과 YAML 작성 (50분)

#### 🎯 학습 목표
- **이해 목표**: Docker Compose의 필요성과 YAML 문법 완전 이해
- **적용 목표**: 복잡한 멀티 컨테이너 애플리케이션을 YAML로 정의 가능
- **협업 목표**: 팀원들과 Compose 파일 설계 및 리뷰

#### 🤔 왜 필요한가? (5분)
**현실 문제 상황**:
- 💼 **복잡한 명령어**: 여러 컨테이너 실행 시 긴 docker run 명령어들
- 🏠 **일상 비유**: 오케스트라 지휘자처럼 여러 컨테이너를 조율
- 📊 **시장 동향**: 마이크로서비스 아키텍처에서 필수적인 컨테이너 오케스트레이션

#### 📖 핵심 개념 (35분)

**🔍 개념 1: Docker Compose 소개 (12분)**
> **정의**: 여러 컨테이너로 구성된 애플리케이션을 정의하고 실행하는 도구

**Compose의 장점**:
```mermaid
graph TB
    subgraph "Docker 명령어 방식"
        A1[docker run 명령어 1] --> A4[복잡한 관리]
        A2[docker run 명령어 2] --> A4
        A3[docker run 명령어 3] --> A4
    end
    
    subgraph "Docker Compose 방식"
        B1[docker-compose.yml] --> B2[docker-compose up]
        B2 --> B3[간단한 관리]
    end
    
    style A4 fill:#ffebee
    style B3 fill:#e8f5e8
```

**Compose 사용 시나리오**:
- **개발 환경**: 로컬에서 전체 스택 실행
- **테스트 환경**: CI/CD 파이프라인에서 테스트 환경 구성
- **단일 호스트 배포**: 간단한 프로덕션 환경

**🔍 개념 2: YAML 문법과 구조 (12분)**
> **정의**: Docker Compose에서 사용하는 YAML 파일의 구조와 문법

**기본 YAML 구조**:
```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "8080:80"
    depends_on:
      - db
    environment:
      - NODE_ENV=production
    
  db:
    image: postgres:13
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:

networks:
  default:
    driver: bridge
```

**주요 섹션들**:
- **version**: Compose 파일 버전
- **services**: 컨테이너 서비스 정의
- **volumes**: 데이터 볼륨 정의
- **networks**: 네트워크 설정

**🔍 개념 3: 서비스 간 의존성과 통신 (11분)**
> **정의**: 컨테이너 간의 실행 순서와 통신 방법 정의

**의존성 관리**:
```mermaid
graph TB
    A[Database] --> B[Backend API]
    B --> C[Frontend Web]
    A --> D[Cache Redis]
    D --> B
    
    E[depends_on] --> A
    E --> B
    E --> C
    E --> D
    
    style A fill:#e3f2fd
    style B fill:#fff3e0
    style C fill:#e8f5e8
    style D fill:#f3e5f5
```

**서비스 간 통신**:
```yaml
services:
  web:
    build: .
    depends_on:
      - api
      - redis
    
  api:
    build: ./api
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/myapp
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis
  
  db:
    image: postgres:13
    
  redis:
    image: redis:alpine
```

#### 💭 함께 생각해보기 (10분)

**🤝 페어 토론** (5분):
**토론 주제**:
1. **구조 이해**: "YAML 파일로 인프라를 정의하는 것의 장점은?"
2. **의존성 관리**: "서비스 간 의존성을 어떻게 효과적으로 관리할까요?"
3. **실무 적용**: "개발팀에서 Compose를 어떻게 활용할 수 있을까요?"

**🎯 전체 공유** (5분):
- **YAML 설계**: 효과적인 Compose 파일 구조 아이디어
- **의존성 전략**: 서비스 간 의존성 관리 방안

### Session 2: 멀티 컨테이너 아키텍처 설계 (50분)

#### 🎯 학습 목표
- **이해 목표**: 실무에서 사용하는 멀티 컨테이너 아키텍처 패턴 이해
- **적용 목표**: 확장 가능하고 유지보수가 용이한 아키텍처 설계 능력
- **협업 목표**: 팀원들과 아키텍처 설계 및 트레이드오프 토론

#### 📖 핵심 개념 (35분)

**🔍 개념 1: 3-Tier 아키텍처 (12분)**
> **정의**: 프레젠테이션, 비즈니스 로직, 데이터 계층으로 분리된 구조

**3-Tier 구조**:
```mermaid
graph TB
    subgraph "Presentation Tier"
        A[Nginx<br/>Load Balancer] --> B[React Frontend]
    end
    
    subgraph "Application Tier"
        C[Node.js API 1] 
        D[Node.js API 2]
        E[Python Worker]
    end
    
    subgraph "Data Tier"
        F[PostgreSQL<br/>Primary DB]
        G[Redis<br/>Cache]
        H[MongoDB<br/>Document Store]
    end
    
    A --> C
    A --> D
    C --> F
    C --> G
    D --> F
    D --> G
    E --> H
    
    style A,B fill:#e3f2fd
    style C,D,E fill:#fff3e0
    style F,G,H fill:#e8f5e8
```

**각 계층의 역할**:
- **Presentation**: 사용자 인터페이스, 로드 밸런싱
- **Application**: 비즈니스 로직, API 서버
- **Data**: 데이터 저장, 캐싱, 검색

**🔍 개념 2: 마이크로서비스 패턴 (12분)**
> **정의**: 각 서비스가 독립적으로 배포되고 확장되는 아키텍처

**마이크로서비스 구조**:
```mermaid
graph TB
    A[API Gateway] --> B[User Service]
    A --> C[Product Service]
    A --> D[Order Service]
    A --> E[Payment Service]
    
    B --> F[User DB]
    C --> G[Product DB]
    D --> H[Order DB]
    E --> I[Payment DB]
    
    J[Message Queue] --> B
    J --> C
    J --> D
    J --> E
    
    style A fill:#e3f2fd
    style B,C,D,E fill:#fff3e0
    style F,G,H,I fill:#e8f5e8
    style J fill:#f3e5f5
```

**마이크로서비스 장점**:
- **독립 배포**: 각 서비스별 독립적 배포
- **기술 다양성**: 서비스별 최적 기술 스택 선택
- **확장성**: 필요한 서비스만 스케일링
- **장애 격리**: 한 서비스 장애가 전체에 영향 최소화

**🔍 개념 3: 모니터링과 로깅 통합 (11분)**
> **정의**: 멀티 컨테이너 환경에서의 관측성 확보 방안

**관측성 스택**:
```mermaid
graph TB
    subgraph "애플리케이션 컨테이너들"
        A[Web App 1] --> D[Fluentd<br/>로그 수집]
        B[Web App 2] --> D
        C[API Server] --> D
    end
    
    subgraph "모니터링 스택"
        D --> E[Elasticsearch<br/>로그 저장]
        E --> F[Kibana<br/>로그 시각화]
        
        A --> G[Prometheus<br/>메트릭 수집]
        B --> G
        C --> G
        G --> H[Grafana<br/>메트릭 시각화]
    end
    
    style A,B,C fill:#e8f5e8
    style D,E,F fill:#fff3e0
    style G,H fill:#e3f2fd
```

**모니터링 구성 요소**:
- **로그 수집**: Fluentd, Logstash
- **로그 저장**: Elasticsearch, Loki
- **로그 시각화**: Kibana, Grafana
- **메트릭 수집**: Prometheus, InfluxDB
- **알림**: Alertmanager, PagerDuty

#### 💭 함께 생각해보기 (15분)

**🤝 페어 토론** (10분):
**토론 주제**:
1. **아키텍처 선택**: "3-Tier vs 마이크로서비스, 언제 어떤 것을 선택할까요?"
2. **확장성 고려**: "트래픽이 증가할 때 어떤 부분을 먼저 확장해야 할까요?"
3. **모니터링 전략**: "멀티 컨테이너 환경에서 꼭 필요한 모니터링은?"

**🎯 전체 공유** (5분):
- **아키텍처 패턴**: 상황별 최적 아키텍처 선택 기준
- **확장 전략**: 효과적인 스케일링 방안

### Session 3: 환경별 설정 관리 (dev/staging/prod) (50분)

#### 🎯 학습 목표
- **이해 목표**: 개발/스테이징/프로덕션 환경별 설정 관리 방법 이해
- **적용 목표**: 환경별로 다른 설정을 효율적으로 관리하는 능력 습득
- **협업 목표**: 팀원들과 환경 관리 전략 및 보안 고려사항 토론

#### 📖 핵심 개념 (35분)

**🔍 개념 1: 환경별 설정 분리 (12분)**
> **정의**: 개발, 스테이징, 프로덕션 환경에 맞는 설정 관리 방법

**환경별 차이점**:
```mermaid
graph TB
    subgraph "Development"
        A1[Hot Reload] --> A4[빠른 개발]
        A2[Debug Mode] --> A4
        A3[Local DB] --> A4
    end
    
    subgraph "Staging"
        B1[Production-like] --> B4[테스트 환경]
        B2[Test Data] --> B4
        B3[Monitoring] --> B4
    end
    
    subgraph "Production"
        C1[High Performance] --> C4[실제 서비스]
        C2[Security] --> C4
        C3[Scalability] --> C4
    end
    
    style A4 fill:#e8f5e8
    style B4 fill:#fff3e0
    style C4 fill:#ffebee
```

**환경별 Compose 파일 구조**:
```bash
# 파일 구조
├── docker-compose.yml          # 기본 설정
├── docker-compose.dev.yml      # 개발 환경
├── docker-compose.staging.yml  # 스테이징 환경
├── docker-compose.prod.yml     # 프로덕션 환경
└── .env.example               # 환경 변수 예시
```

**🔍 개념 2: 환경 변수와 시크릿 관리 (12분)**
> **정의**: 민감한 정보와 환경별 설정을 안전하게 관리하는 방법

**환경 변수 관리 방법**:
```yaml
# docker-compose.yml (기본)
version: '3.8'
services:
  web:
    build: .
    environment:
      - NODE_ENV=${NODE_ENV:-development}
      - DATABASE_URL=${DATABASE_URL}
      - API_KEY=${API_KEY}
    env_file:
      - .env

# .env.development
NODE_ENV=development
DATABASE_URL=postgresql://user:pass@localhost:5432/myapp_dev
API_KEY=dev_api_key_here

# .env.production
NODE_ENV=production
DATABASE_URL=postgresql://user:pass@prod-db:5432/myapp
API_KEY=prod_api_key_here
```

**시크릿 관리 베스트 프랙티스**:
- **환경 변수**: 민감하지 않은 설정
- **Docker Secrets**: 민감한 정보 (패스워드, API 키)
- **외부 시크릿 관리**: HashiCorp Vault, AWS Secrets Manager
- **Git 제외**: .env 파일은 .gitignore에 추가

**🔍 개념 3: 오버라이드와 확장 (11분)**
> **정의**: 기본 설정을 유지하면서 환경별로 필요한 부분만 변경하는 방법

**Compose 파일 오버라이드**:
```yaml
# docker-compose.yml (기본)
version: '3.8'
services:
  web:
    build: .
    ports:
      - "8080:3000"

# docker-compose.dev.yml (개발 환경)
version: '3.8'
services:
  web:
    volumes:
      - .:/app  # 코드 변경 시 자동 반영
    environment:
      - DEBUG=true
  
  db:
    image: postgres:13
    environment:
      POSTGRES_DB: myapp_dev

# docker-compose.prod.yml (프로덕션)
version: '3.8'
services:
  web:
    restart: always
    environment:
      - NODE_ENV=production
    deploy:
      replicas: 3
```

**실행 방법**:
```bash
# 개발 환경
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# 프로덕션 환경
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

#### 💭 함께 생각해보기 (15분)

**🤝 페어 토론** (10분):
**토론 주제**:
1. **환경 관리**: "환경별 설정을 관리할 때 가장 중요한 고려사항은?"
2. **보안 전략**: "민감한 정보를 안전하게 관리하는 방법은?"
3. **배포 전략**: "개발에서 프로덕션까지 일관성을 유지하는 방법은?"

**🎯 전체 공유** (5분):
- **환경 관리 전략**: 효과적인 환경별 설정 관리 방안
- **보안 고려사항**: 시크릿 관리 베스트 프랙티스

---

## 🛠️ Week 1 통합 프로젝트 (3시간)

### 🎯 프로젝트 개요
**최종 목표**: 실무와 유사한 풀스택 웹 애플리케이션 구축
- 3-Tier 아키텍처 구현
- 환경별 설정 분리
- 모니터링 및 로깅 통합
- 팀 협업을 통한 완성도 높은 결과물

### 📋 프로젝트 요구사항

#### 🏗️ 아키텍처 요구사항
```mermaid
graph TB
    subgraph "Load Balancer Tier"
        A[Nginx<br/>Reverse Proxy]
    end
    
    subgraph "Application Tier"
        B[Frontend<br/>React/Vue]
        C[Backend API<br/>Node.js/Python]
        D[Worker<br/>Background Jobs]
    end
    
    subgraph "Data Tier"
        E[PostgreSQL<br/>Primary DB]
        F[Redis<br/>Cache & Session]
        G[MongoDB<br/>Logs & Analytics]
    end
    
    subgraph "Monitoring Tier"
        H[Prometheus<br/>Metrics]
        I[Grafana<br/>Dashboard]
        J[Fluentd<br/>Log Collector]
    end
    
    A --> B
    A --> C
    C --> E
    C --> F
    D --> G
    B --> H
    C --> H
    D --> H
    H --> I
    B --> J
    C --> J
    D --> J
    
    style A fill:#e3f2fd
    style B,C,D fill:#fff3e0
    style E,F,G fill:#e8f5e8
    style H,I,J fill:#f3e5f5
```

#### 📝 기능 요구사항
1. **사용자 관리**: 회원가입, 로그인, 프로필 관리
2. **게시판**: CRUD 기능, 댓글, 검색
3. **실시간 기능**: WebSocket을 통한 실시간 알림
4. **파일 업로드**: 이미지 업로드 및 저장
5. **API 문서**: Swagger/OpenAPI 문서화

### 🚀 Phase 1: 팀 구성 및 계획 수립 (30분)

#### 👥 팀 구성 (4팀, 3명씩)
**팀별 역할 분담**:
- **Team 1**: Frontend + UI/UX
- **Team 2**: Backend API + Database
- **Team 3**: DevOps + Infrastructure
- **Team 4**: Monitoring + Security

#### 📋 계획 수립
**각 팀별 계획서 작성**:
```markdown
## 팀명: [팀 이름]
### 담당 영역: [Frontend/Backend/DevOps/Monitoring]
### 팀원 및 역할:
- [이름]: [구체적 역할]
- [이름]: [구체적 역할]
- [이름]: [구체적 역할]

### 구현 계획:
1. Phase 2 (90분): [구체적 구현 내용]
2. Phase 3 (60분): [통합 및 테스트]

### 사용 기술:
- 언어/프레임워크: [선택한 기술]
- 데이터베이스: [선택한 DB]
- 기타 도구: [추가 도구들]
```

### 🌟 Phase 2: 개발 및 구현 (90분)

#### 🔧 Team 1: Frontend 개발
**구현 내용**:
```dockerfile
# Frontend Dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**주요 기능**:
- React/Vue.js 기반 SPA
- 반응형 디자인
- API 연동
- 실시간 업데이트

#### 🔧 Team 2: Backend API 개발
**구현 내용**:
```dockerfile
# Backend Dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
RUN adduser -D appuser
USER appuser
EXPOSE 3000
CMD ["npm", "start"]
```

**주요 기능**:
- RESTful API 구현
- JWT 인증
- 데이터베이스 연동
- WebSocket 실시간 통신

#### 🔧 Team 3: DevOps & Infrastructure
**구현 내용**:
```yaml
# docker-compose.yml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - frontend
      - backend

  frontend:
    build: ./frontend
    expose:
      - "80"

  backend:
    build: ./backend
    expose:
      - "3000"
    environment:
      - DATABASE_URL=postgresql://user:pass@postgres:5432/myapp
      - REDIS_URL=redis://redis:6379
    depends_on:
      - postgres
      - redis

  postgres:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:alpine
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

#### 🔧 Team 4: Monitoring & Security
**구현 내용**:
```yaml
# monitoring services
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana

  fluentd:
    build: ./fluentd
    volumes:
      - /var/log:/var/log
    depends_on:
      - elasticsearch

  elasticsearch:
    image: elasticsearch:7.14.0
    environment:
      - discovery.type=single-node
    volumes:
      - es_data:/usr/share/elasticsearch/data
```

### 🏆 Phase 3: 통합 및 테스트 (60분)

#### 🔗 서비스 통합
**통합 작업**:
1. **네트워크 연결**: 모든 서비스 간 통신 확인
2. **데이터 플로우**: Frontend → Backend → Database 연결
3. **모니터링 연동**: 메트릭 수집 및 대시보드 구성
4. **로그 수집**: 중앙화된 로그 관리

#### ✅ 테스트 체크리스트
- [ ] 웹 애플리케이션 정상 접속
- [ ] 사용자 회원가입/로그인 기능
- [ ] 게시판 CRUD 기능
- [ ] 실시간 알림 기능
- [ ] 모니터링 대시보드 접속
- [ ] 로그 수집 및 검색 기능

### 🎤 최종 발표 및 데모 (30분)

#### 📊 팀별 발표 (7분×4팀)
**발표 내용**:
1. **아키텍처 설명**: 구현한 시스템 구조
2. **기술 선택**: 사용한 기술과 선택 이유
3. **구현 결과**: 실제 동작하는 기능 데모
4. **도전과 해결**: 어려웠던 점과 해결 방법
5. **팀 협업**: 협업 과정에서 배운 점

#### 🏅 상호 평가
**평가 기준**:
- **기술적 완성도**: 요구사항 구현 정도
- **아키텍처 설계**: 확장성과 유지보수성
- **팀 협업**: 역할 분담과 통합 과정
- **창의성**: 독창적인 아이디어나 해결책

---

## 👥 Week 1 총정리 & 학생 케어 (105분)

### 📊 Week 1 성과 점검 (30분)

#### ✅ 학습 목표 달성도 체크
**개인별 체크리스트**:
- [ ] DevOps 문화와 철학 이해
- [ ] Docker 기본 개념과 명령어 숙달
- [ ] Dockerfile 작성 및 이미지 빌드
- [ ] 컨테이너 네트워킹과 볼륨 관리
- [ ] Docker Compose를 활용한 멀티 컨테이너 구성
- [ ] 팀 프로젝트를 통한 실무 경험

#### 📈 성장 지표 확인
```mermaid
graph TB
    subgraph "Week 1 성장 지표"
        A[기술 역량<br/>85% 달성] --> D[전체 성장]
        B[협업 능력<br/>90% 달성] --> D
        C[문제 해결<br/>80% 달성] --> D
    end
    
    style A,B,C fill:#e8f5e8
    style D fill:#4caf50
```

### 🤝 협업 경험 회고 (45분)

#### 🌟 팀별 협업 성과 공유 (20분)
**각 팀 발표** (5분×4팀):
- **협업의 하이라이트**: 가장 인상 깊었던 협업 순간
- **역할 분담**: 자연스럽게 형성된 역할과 리더십
- **상호 학습**: 서로에게서 배운 점들
- **시너지 효과**: 다양한 배경이 만든 창의적 결과

#### 💭 개인 성장 회고 (25분)
**회고 질문들**:
1. **기술적 성장**: "Week 1에서 가장 많이 성장한 기술 영역은?"
2. **협업 경험**: "팀 프로젝트에서 가장 의미 있었던 경험은?"
3. **자신감 변화**: "Docker와 DevOps에 대한 자신감이 어떻게 변했나요?"
4. **다음 목표**: "Week 2에서 도전하고 싶은 것은?"

### 🎯 Week 2 준비 및 동기부여 (30분)

#### 🚀 Week 2 미리보기
**학습 내용 소개**:
- **Docker 심화**: 보안, 최적화, 모니터링
- **컨테이너 오케스트레이션**: Kubernetes 기초
- **클라우드 네이티브**: 현대적 애플리케이션 아키텍처
- **실무 프로젝트**: 더 복잡한 시스템 구축

#### 📚 사전 학습 자료
**추천 학습 자료**:
- [Docker 보안 가이드](https://docs.docker.com/engine/security/)
- [Kubernetes 기초 개념](https://kubernetes.io/docs/concepts/)
- [12-Factor App](https://12factor.net/)
- [클라우드 네이티브 패턴](https://www.cncf.io/)

#### 🎉 Week 1 성취 축하
**성취 사항 정리**:
- ✅ DevOps 문화 완전 이해
- ✅ Docker 기술 스택 습득
- ✅ 팀 협업 역량 개발
- ✅ 실무 프로젝트 완성
- ✅ 자신감과 동기 향상

---

## 📝 Week 1 최종 마무리

### 🏆 주간 성과 요약
- **기술적 성취**: Docker 생태계 완전 습득
- **협업적 성취**: 다양한 배경의 팀원들과 성공적 협업
- **개인적 성취**: 각자의 강점 발견 및 자신감 향상
- **프로젝트 성취**: 실무 수준의 멀티 컨테이너 애플리케이션 구축

### 🎯 Week 2 기대효과
- **심화 학습**: Docker 고급 기능과 보안
- **새로운 도전**: Kubernetes와 컨테이너 오케스트레이션
- **확장된 협업**: 더 복잡한 시스템에서의 팀워크
- **실무 연계**: 클라우드 네이티브 아키텍처 경험

### 📊 최종 학습 진도
```mermaid
graph LR
    A[Week 1 ✅] --> B[Week 2]
    B --> C[Week 3]
    C --> D[Week 4]
    D --> E[Week 5]
    E --> F[Week 6]
    
    style A fill:#4caf50
    style B,C,D,E,F fill:#e0e0e0
```

---

<div align="center">

**🎼 Docker Compose 완성** • **🏗️ 멀티 컨테이너 마스터** • **🤝 팀 프로젝트 성공**

*Week 1을 통해 DevOps와 컨테이너 기술의 탄탄한 기초를 완성했습니다*

**다음 주**: [Week 2 - 컨테이너 오케스트레이션 기초](../week_02/README.md)

</div>