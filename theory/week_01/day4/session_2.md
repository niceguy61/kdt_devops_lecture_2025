# Week 1 Day 4 Session 2: 고급 Compose 기능

<div align="center">

**🚀 Docker Compose 고급 활용** • **네트워크, 볼륨, 환경 관리**

*기본 구성을 넘어 실무급 멀티 컨테이너 아키텍처 구축*

</div>

---

## 🕘 세션 정보

**시간**: 10:00-10:50 (50분)  
**목표**: Docker Compose 고급 기능과 실무 패턴 완전 습득  
**방식**: 심화 이론 + 실습 + 문제 해결

---

## 🎯 세션 목표

### 📚 학습 목표
- **이해 목표**: 네트워크, 볼륨, 환경 관리 등 고급 기능 완전 이해
- **적용 목표**: 실무급 멀티 컨테이너 아키텍처 구성 능력
- **협업 목표**: 복잡한 설정을 팀원과 함께 구현하고 문제 해결

### 🤔 왜 필요한가? (3분)
**고급 기능의 중요성**:
- 💼 **실무 필수**: 단순한 연결을 넘어 복잡한 아키텍처 구성
- 🏠 **일상 비유**: 기본 요리에서 고급 요리로 발전하는 것
- 📊 **효과**: 확장성, 보안성, 유지보수성 대폭 향상

---

## 📖 핵심 개념 (35분)

### 🔍 개념 1: 네트워크 고급 관리 (12분)

#### 네트워크 유형과 활용
```yaml
version: '3.8'

services:
  frontend:
    image: nginx:alpine
    networks:
      - public
      - internal
    ports:
      - "80:80"

  backend:
    image: myapp-api:latest
    networks:
      - internal
      - database
    # 외부 접근 불가 (포트 매핑 없음)

  database:
    image: postgres:13
    networks:
      - database
    # 완전히 격리된 데이터베이스

networks:
  public:
    driver: bridge
  internal:
    driver: bridge
    internal: true  # 외부 인터넷 접근 차단
  database:
    driver: bridge
    internal: true
```

#### 네트워크 보안 패턴
```mermaid
graph TB
    subgraph "Public Network"
        A[Frontend<br/>Nginx]
        B[Load Balancer]
    end
    
    subgraph "Internal Network"
        C[API Gateway]
        D[Auth Service]
        E[Business Logic]
    end
    
    subgraph "Database Network"
        F[PostgreSQL]
        G[Redis]
        H[MongoDB]
    end
    
    A --> C
    B --> C
    C --> D
    C --> E
    D --> F
    E --> F
    E --> G
    E --> H
    
    style A,B fill:#ffebee
    style C,D,E fill:#fff3e0
    style F,G,H fill:#e8f5e8
```

#### 고급 네트워크 설정
```yaml
networks:
  frontend:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
          ip_range: 172.20.240.0/20
          gateway: 172.20.0.1
    driver_opts:
      com.docker.network.bridge.name: frontend-br
      com.docker.network.bridge.enable_ip_masquerade: "true"

  backend:
    driver: overlay  # Swarm 모드에서 사용
    attachable: true
    labels:
      - "environment=production"
      - "team=backend"
```

### 🔍 개념 2: 볼륨과 데이터 관리 (12분)

#### 볼륨 유형별 활용
```yaml
version: '3.8'

services:
  database:
    image: postgres:13
    volumes:
      # Named Volume (권장)
      - postgres_data:/var/lib/postgresql/data
      
      # Bind Mount (개발용)
      - ./init-scripts:/docker-entrypoint-initdb.d
      
      # tmpfs Mount (임시 데이터)
      - type: tmpfs
        target: /tmp
        tmpfs:
          size: 100M

  web:
    image: nginx:alpine
    volumes:
      # 설정 파일 바인드
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      
      # 정적 파일 공유
      - static_files:/usr/share/nginx/html
      
      # 로그 수집
      - ./logs:/var/log/nginx

  app:
    build: .
    volumes:
      # 개발 시 코드 동기화
      - ./src:/app/src
      
      # node_modules 캐시
      - node_modules:/app/node_modules

volumes:
  postgres_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /data/postgres
      
  static_files:
    driver: local
    
  node_modules:
    driver: local
```

#### 백업과 복구 전략
```yaml
services:
  database:
    image: postgres:13
    volumes:
      - db_data:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password

  backup:
    image: postgres:13
    depends_on:
      - database
    volumes:
      - db_data:/var/lib/postgresql/data:ro
      - ./backups:/backups
    command: |
      bash -c "
        while true; do
          pg_dump -h database -U user myapp > /backups/backup_$$(date +%Y%m%d_%H%M%S).sql
          sleep 3600  # 1시간마다 백업
        done
      "
    restart: unless-stopped
```

### 🔍 개념 3: 환경별 설정 관리 (11분)

#### 환경별 Compose 파일 구조
```bash
# 파일 구조
├── docker-compose.yml          # 기본 설정
├── docker-compose.override.yml # 개발 환경 (자동 적용)
├── docker-compose.prod.yml     # 프로덕션 환경
├── docker-compose.test.yml     # 테스트 환경
├── .env                        # 기본 환경변수
├── .env.production            # 프로덕션 환경변수
└── .env.test                  # 테스트 환경변수
```

#### 기본 설정 (docker-compose.yml)
```yaml
version: '3.8'

services:
  web:
    image: ${WEB_IMAGE:-myapp:latest}
    environment:
      - NODE_ENV=${NODE_ENV:-development}
      - DATABASE_URL=${DATABASE_URL}
    volumes:
      - static_data:/app/static

  database:
    image: postgres:${POSTGRES_VERSION:-13}
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - db_data:/var/lib/postgresql/data

volumes:
  static_data:
  db_data:
```

#### 개발 환경 오버라이드 (docker-compose.override.yml)
```yaml
version: '3.8'

services:
  web:
    build: .  # 개발 시 로컬 빌드
    ports:
      - "3000:3000"
    volumes:
      - ./src:/app/src  # 코드 동기화
      - ./public:/app/public
    environment:
      - DEBUG=true
      - HOT_RELOAD=true

  database:
    ports:
      - "5432:5432"  # 개발 시 외부 접근 허용
    environment:
      - POSTGRES_DB=myapp_dev
```

#### 프로덕션 환경 (docker-compose.prod.yml)
```yaml
version: '3.8'

services:
  web:
    image: myapp:${VERSION}
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  database:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
    restart: unless-stopped
    
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.prod.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - web
```

#### 환경변수 파일 관리
```bash
# .env (기본)
NODE_ENV=development
POSTGRES_VERSION=13
POSTGRES_DB=myapp
POSTGRES_USER=user
POSTGRES_PASSWORD=password
DATABASE_URL=postgresql://user:password@database:5432/myapp

# .env.production
NODE_ENV=production
WEB_IMAGE=myapp:v1.2.3
POSTGRES_PASSWORD=super_secure_password
DATABASE_URL=postgresql://user:super_secure_password@database:5432/myapp_prod

# .env.test
NODE_ENV=test
POSTGRES_DB=myapp_test
DATABASE_URL=postgresql://user:password@database:5432/myapp_test
```

#### 환경별 실행 명령어
```bash
# 개발 환경 (기본)
docker-compose up -d

# 프로덕션 환경
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# 테스트 환경
docker-compose -f docker-compose.yml -f docker-compose.test.yml up -d

# 환경변수 파일 지정
docker-compose --env-file .env.production up -d
```

---

## 💭 함께 생각해보기 (10분)

### 🤝 실습: 3-Tier 아키텍처 구성 (7분)
**실습 미션**: 프론트엔드, 백엔드, 데이터베이스가 분리된 아키텍처 구성

**요구사항**:
- **프론트엔드**: Nginx (public 네트워크)
- **백엔드**: Node.js API (internal 네트워크)
- **데이터베이스**: PostgreSQL (database 네트워크)
- **캐시**: Redis (database 네트워크)
- **각 계층별 네트워크 격리**
- **개발/프로덕션 환경 분리**

**페어 활동**:
- 👥 **아키텍처 설계**: 네트워크 구조와 서비스 배치 계획
- 🔧 **구현**: docker-compose.yml 작성
- 🧪 **테스트**: 서비스 간 통신 확인

**기본 구조**:
```yaml
version: '3.8'

services:
  frontend:
    # TODO: Nginx 설정
    networks:
      - public
      - internal

  backend:
    # TODO: API 서버 설정
    networks:
      - internal
      - database

  database:
    # TODO: PostgreSQL 설정
    networks:
      - database

  cache:
    # TODO: Redis 설정
    networks:
      - database

networks:
  public:
    # TODO: 외부 접근 가능
  internal:
    # TODO: 내부 통신용
  database:
    # TODO: 데이터베이스 전용

volumes:
  # TODO: 필요한 볼륨들
```

### 🎯 전체 공유 (3분)
- **아키텍처 발표**: 각 페어의 네트워크 설계 공유
- **보안 고려사항**: 네트워크 격리와 보안 설정
- **환경 관리**: 개발/프로덕션 환경 분리 전략

### 💡 이해도 체크 질문
- ✅ "네트워크 격리를 통해 어떤 보안 효과를 얻을 수 있나요?"
- ✅ "Named Volume과 Bind Mount의 차이점과 사용 시나리오는?"
- ✅ "환경별 설정 파일을 어떻게 관리하는 것이 좋을까요?"

---

## 🔑 핵심 키워드

### 네트워크 관리
- **networks**: 커스텀 네트워크 정의
- **internal**: 외부 인터넷 접근 차단
- **ipam**: IP 주소 관리 설정
- **driver**: 네트워크 드라이버 (bridge, overlay)

### 볼륨 관리
- **Named Volume**: Docker 관리 볼륨
- **Bind Mount**: 호스트 디렉토리 마운트
- **tmpfs**: 메모리 기반 임시 파일시스템
- **driver_opts**: 볼륨 드라이버 옵션

### 환경 관리
- **override**: 환경별 설정 오버라이드
- **env_file**: 환경변수 파일 지정
- **profiles**: 서비스 그룹 관리
- **extends**: 설정 상속 (deprecated)

### 고급 설정
- **deploy**: 배포 관련 설정 (Swarm 모드)
- **healthcheck**: 서비스 상태 확인
- **logging**: 로그 드라이버 설정
- **restart**: 재시작 정책

---

## 📝 세션 마무리

### ✅ 오늘 세션 성과
- [ ] 네트워크 격리와 보안 설정 완전 이해
- [ ] 볼륨 유형별 활용법과 데이터 관리 전략 습득
- [ ] 환경별 설정 관리 패턴 구현 완료
- [ ] 3-Tier 아키텍처 실습을 통한 실무 경험

### 🎯 다음 세션 준비
- **주제**: 마이크로서비스 아키텍처 패턴
- **연결고리**: 고급 Compose 기능 → 마이크로서비스 설계 → 실무 패턴
- **준비사항**: 오늘 구성한 아키텍처를 마이크로서비스로 확장

### 📊 복잡도 발전 과정
```mermaid
graph LR
    A[단일 컨테이너<br/>Day 1-2] --> B[멀티 컨테이너<br/>Day 3]
    B --> C[Compose 기초<br/>Session 1]
    C --> D[고급 Compose<br/>Session 2 ✅]
    D --> E[마이크로서비스<br/>Session 3]
    
    style A,B,C fill:#4caf50
    style D fill:#ff9800
    style E fill:#e0e0e0
```

---

<div align="center">

**🚀 Docker Compose 고급 기능을 완전히 마스터했습니다**

*네트워크 격리부터 환경별 설정까지, 실무급 컨테이너 오케스트레이션 능력 완성*

**이전**: [Session 1 - Compose 기초](./session_1.md) | **다음**: [Session 3 - 마이크로서비스 아키텍처](./session_3.md)

</div>