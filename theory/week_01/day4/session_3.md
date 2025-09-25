# Week 1 Day 4 Session 3: 환경별 설정 관리 (dev/staging/prod)

<div align="center">

**⚙️ 환경별 설정 분리** • **운영 환경 대응**

*개발부터 프로덕션까지 일관된 배포 전략*

</div>

---

## 🕘 세션 정보

**시간**: 11:00-11:50 (50분)  
**목표**: 개발/스테이징/프로덕션 환경별 설정 관리 방법 이해  
**방식**: 환경 분석 + 설정 실습 + 보안 고려사항

---

## 🎯 세션 목표

### 📚 학습 목표
- **이해 목표**: 개발/스테이징/프로덕션 환경별 설정 관리 방법 이해
- **적용 목표**: 환경별로 다른 설정을 효율적으로 관리하는 능력 습득
- **협업 목표**: 페어 토론을 통한 환경 관리 전략 및 보안 고려사항 분석

### 🤔 왜 필요한가? (5분)

**환경별 설정 관리의 중요성**:
- 💼 **업계 현실**: 대부분의 서비스 장애가 개발/운영 환경 설정 차이로 인해 발생
- 🏠 **일상 비유**: 집에서는 편한 옷, 회사에서는 정장 - 상황에 맞는 설정
- 📊 **보안 위험**: 클라우드 비용 폭탄, 데이터 유출 등 심각한 보안 사고 발생

**환경별 설정 관리 실패 패턴**:
```mermaid
graph TB
    A[개발자가 실수로<br/>프로덕션 DB 접속] --> B[전체 서비스 다운]
    C[테스트 데이터가<br/>프로덕션에 유입] --> D[사용자 데이터 오염]
    E[API 키가 코드에<br/>하드코딩] --> F[보안 사고]
    
    style A,B,C,D,E,F fill:#ffebee
```

**실무에서 자주 발생하는 문제 패턴**:
- **설정 혼동**: 개발자가 실수로 프로덕션 DB에 연결
- **시크릿 노출**: .env 파일을 Git에 커밋하여 API 키 노출
- **데이터 오염**: 테스트 데이터가 실제 서비스에 유입
- **성능 문제**: 개발 설정으로 프로덕션 실행으로 인한 성능 저하

---

## 📖 핵심 개념 (35분)

### 🔍 개념 1: 환경별 설정 분리 (12분)

> **정의**: 개발, 스테이징, 프로덕션 환경에 맞는 설정 관리 방법

**🖼️ 환경별 배포 파이프라인**
![Environment Pipeline](https://miro.medium.com/max/1400/1*8xZmrWafDdkVlzlWgWbCKg.png)
*개발부터 프로덕션까지 배포 파이프라인*

**환경별 상세 차이점**:

**💻 Development (개발 환경)**:
- **목적**: 빠른 개발과 디버깅
- **특징**: Hot Reload, Debug Mode, Verbose Logging
- **데이터**: 로컬 DB, 샘플 데이터
- **보안**: 느슨한 보안 (개발 편의성 우선)
- **리소스**: 최소한의 CPU/메모리

**🧪 Staging (스테이징 환경)**:
- **목적**: 프로덕션 유사 환경에서 테스트
- **특징**: Production-like 설정, 자동 테스트
- **데이터**: 익명화된 프로덕션 데이터 복사본
- **보안**: 프로덕션 수준 보안
- **리소스**: 프로덕션의 70% 수준

**🚀 Production (프로덕션 환경)**:
- **목적**: 실제 사용자 서비스
- **특징**: High Performance, High Availability
- **데이터**: 실제 사용자 데이터
- **보안**: 최고 수준 보안
- **리소스**: 최대 성능 설정

```mermaid
graph TB
    subgraph "Development"
        A1[핫 리로드<br/>빠른 개발] --> A4[개발 효율성]
        A2[디버그 모드<br/>상세 로그] --> A4
        A3[로컬 DB<br/>샘플 데이터] --> A4
    end
    
    subgraph "Staging"
        B1[프로덕션 유사<br/>실제 환경 시뮬레이션] --> B4[테스트 신뢰성]
        B2[익명화 데이터<br/>안전한 테스트] --> B4
        B3[모니터링<br/>성능 검증] --> B4
    end
    
    subgraph "Production"
        C1[고성능<br/>최적화된 설정] --> C4[서비스 안정성]
        C2[고도 보안<br/>암호화 & 접근제어] --> C4
        C3[스케일링<br/>로드 밸런싱] --> C4
    end
    
    style A4 fill:#e8f5e8
    style B4 fill:#fff3e0
    style C4 fill:#ffebee
```

**⚠️ 환경별 주의사항**:
1. **데이터 동기화**: 개발 환경의 오래된 데이터
2. **설정 드리프트**: 환경별 설정 차이로 인한 버그
3. **리소스 차이**: 개발에서는 정상, 프로덕션에서 성능 문제
4. **의존성 차이**: 개발에서는 없던 외부 서비스 의존성

**실무 환경별 Compose 파일 구조**:
```bash
# 실무 프로젝트 파일 구조
├── docker-compose.yml              # 기본 설정 (공통 설정)
├── docker-compose.dev.yml          # 개발 환경 오버라이드
├── docker-compose.staging.yml      # 스테이징 환경 오버라이드
├── docker-compose.prod.yml         # 프로덕션 환경 오버라이드
├── docker-compose.monitoring.yml   # 모니터링 스택 (선택적)
├── .env.example                   # 환경 변수 템플릿
├── .env.dev                       # 개발 환경 변수
├── .env.staging                   # 스테이징 환경 변수
└── .env.prod                      # 프로덕션 환경 변수 (깃에 제외)

# .gitignore 설정 예시
.env.prod      # 프로덕션 시크릿 보호
.env.staging   # 스테이징 시크릿 보호
.env           # 로컬 개발 설정
*.log          # 로그 파일
volumes/       # 로컬 볼륨 데이터
```

**환경별 실행 명령어**:
```bash
# 개발 환경
cp .env.dev .env
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# 스테이징 환경
cp .env.staging .env
docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d

# 프로덕션 환경 (보안 강화)
export $(cat .env.prod | xargs)  # 환경변수로 로드
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# 모니터링 포함 전체 스택
docker-compose -f docker-compose.yml -f docker-compose.prod.yml -f docker-compose.monitoring.yml up -d
```

### 🔍 개념 2: 환경 변수와 시크릿 관리 (12분)

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

**🖼️ 시크릿 관리 전략**
![Secrets Management](https://miro.medium.com/max/1400/1*V5N9gJdnToIrgAgVJTR_Yw.png)
*보안 시크릿 관리 전략*

**실무 시크릿 관리 전략**:

**🔒 보안 수준별 관리 방법**:

**Level 1: 기본 보안 (소규모 프로젝트)**
```bash
# .env 파일 관리
.env.example     # Git에 포함 (템플릿)
.env.dev        # Git에 포함 (개발용)
.env.prod       # Git 제외 (수동 관리)

# .gitignore 설정
.env.prod
.env.staging
.env
*.key
*.pem
```

**Level 2: 중급 보안 (Docker Secrets)**
```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  api:
    image: myapp:latest
    secrets:
      - db_password
      - api_key
    environment:
      - DB_PASSWORD_FILE=/run/secrets/db_password
      - API_KEY_FILE=/run/secrets/api_key

secrets:
  db_password:
    file: ./secrets/db_password.txt
  api_key:
    file: ./secrets/api_key.txt
```

**Level 3: 고급 보안 (외부 시크릿 관리)**
```yaml
# HashiCorp Vault 연동 예시
services:
  vault-agent:
    image: vault:latest
    command: |
      vault agent -config=/vault/config/agent.hcl
    volumes:
      - vault_secrets:/vault/secrets
      - ./vault-config:/vault/config
  
  api:
    image: myapp:latest
    volumes:
      - vault_secrets:/app/secrets:ro
    depends_on:
      - vault-agent
```

**⚠️ 시크릿 관리 주의사항**:
1. **로그 노출**: 로그에 패스워드나 API 키 기록 금지
2. **이미지 내 하드코딩**: Dockerfile에 시크릿 직접 기록 금지
3. **환경변수 노출**: `docker inspect`로 환경변수 확인 가능
4. **백업 보안**: 시크릿 백업 시 암호화 필수
5. **접근 권한**: 시크릿에 대한 최소 권한 원칙

**🔍 시크릿 누출 감지 도구**:
```bash
# Git 이력에서 시크릿 검색
git log --all --full-history -- .env.prod

# 커밋된 시크릿 검색
truffleHog --regex --entropy=False .

# GitHub 시크릿 스캔
git-secrets --scan
```

**🚑 시크릿 누출 시 대응 절차**:
1. **즉시 시크릿 무효화** (API 키, 데이터베이스 패스워드)
2. **Git 이력 정리** (`git filter-branch` 또는 BFG Repo-Cleaner)
3. **새로운 시크릿 생성** 및 배포
4. **보안 감사** 및 재발 방지 대책 수립

### 🔍 개념 3: 오버라이드와 확장 (11분)

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

---

## 💭 함께 생각해보기 (10분)

### 🤝 페어 토론 (7분)
**토론 주제**:
1. **환경 관리**: "환경별 설정을 관리할 때 가장 중요한 고려사항은?"
2. **보안 전략**: "민감한 정보를 안전하게 관리하는 방법은?"
3. **배포 전략**: "개발에서 프로덕션까지 일관성을 유지하는 방법은?"

### 🎯 전체 공유 (3분)
- **환경 관리 전략**: 효과적인 환경별 설정 관리 방안
- **보안 고려사항**: 시크릿 관리 베스트 프랙티스

---

## 🔑 핵심 키워드

### 환경 관리
- **Environment Variables**: 환경 변수를 통한 설정 관리
- **Docker Compose Override**: 환경별 설정 오버라이드
- **Multi-stage Deployment**: 단계별 배포 전략
- **.env Files**: 환경별 설정 파일

### 보안 관리
- **Secrets Management**: 민감한 정보 관리
- **Environment Separation**: 환경별 격리
- **Configuration as Code**: 설정의 코드화
- **GitOps**: Git 기반 설정 관리

---

## 🛠️ 환경별 설정 실습 (10분)

### ⚙️ 개발/프로덕션 환경 분리

**실습 목표**: 환경별 Docker Compose 오버라이드 실습

```bash
# 환경 설정 실습 디렉토리
mkdir ~/environment-practice && cd ~/environment-practice

# 기본 docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "${WEB_PORT:-8080}:80"
    environment:
      - ENV_NAME=${ENV_NAME:-development}
    volumes:
      - ./html:/usr/share/nginx/html
    depends_on:
      - app

  app:
    image: node:alpine
    working_dir: /app
    environment:
      - NODE_ENV=${NODE_ENV:-development}
      - DATABASE_URL=${DATABASE_URL}
      - API_KEY=${API_KEY}
    command: sh -c "echo 'Environment: ${NODE_ENV}' && sleep infinity"
    depends_on:
      - db

  db:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
EOF

# 개발 환경 오버라이드
cat > docker-compose.dev.yml << 'EOF'
version: '3.8'

services:
  web:
    volumes:
      - ./html:/usr/share/nginx/html:ro  # 읽기 전용
    
  app:
    volumes:
      - ./app:/app  # 코드 변경 시 자동 반영
    environment:
      - DEBUG=true
      - LOG_LEVEL=debug
    
  db:
    ports:
      - "5432:5432"  # 개발 시 직접 접근 가능
EOF

# 프로덕션 환경 오버라이드
cat > docker-compose.prod.yml << 'EOF'
version: '3.8'

services:
  web:
    restart: always
    deploy:
      replicas: 2
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
    
  app:
    restart: always
    environment:
      - LOG_LEVEL=info
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
    
  db:
    restart: always
    deploy:
      resources:
        limits:
          memory: 1G
EOF

# 개발 환경 변수
cat > .env.dev << 'EOF'
ENV_NAME=development
NODE_ENV=development
WEB_PORT=8080
DB_NAME=myapp_dev
DB_USER=dev_user
DB_PASSWORD=dev_password
DATABASE_URL=postgresql://dev_user:dev_password@db:5432/myapp_dev
API_KEY=dev_api_key_12345
EOF

# 프로덕션 환경 변수
cat > .env.prod << 'EOF'
ENV_NAME=production
NODE_ENV=production
WEB_PORT=80
DB_NAME=myapp_prod
DB_USER=prod_user
DB_PASSWORD=super_secure_prod_password_2024
DATABASE_URL=postgresql://prod_user:super_secure_prod_password_2024@db:5432/myapp_prod
API_KEY=prod_api_key_abcdef123456
EOF

# HTML 파일
mkdir html
cat > html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Environment Demo</title></head>
<body>
    <h1>🌍 Environment Configuration Demo</h1>
    <p>Check the container logs to see environment-specific settings!</p>
</body>
</html>
EOF

# 개발 환경 테스트
echo "💻 개발 환경 실행..."
cp .env.dev .env
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
docker-compose logs app | head -5
docker-compose down

# 프로덕션 환경 테스트
echo "🚀 프로덕션 환경 실행..."
cp .env.prod .env
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
docker-compose logs app | head -5
docker-compose down

# 정리
rm .env
```

### ✅ 실습 체크포인트
- [ ] 기본 docker-compose.yml 파일 작성
- [ ] 개발/프로덕션 환경 오버라이드 파일 작성
- [ ] 환경별 .env 파일 설정
- [ ] 각 환경에서 다른 설정 적용 확인

---

## 📝 세션 마무리

### ✅ 오늘 세션 성과
- [ ] 환경별 설정 분리 방법 완전 이해
- [ ] 환경 변수와 시크릿 관리 방법 습득
- [ ] Compose 파일 오버라이드 기법 파악
- [ ] 환경별 설정 실습 완료
- [ ] Session 4 실전 프로젝트 준비 완료

### 🎯 통합 프로젝트 준비
- **연결고리**: 모든 이론 학습 → 실무 프로젝트 구현
- **프로젝트 내용**: 풀스택 웹 애플리케이션 구축
- **준비사항**: 팀 구성 및 역할 분담, 기술 스택 선택

---

<div align="center">

**⚙️ 환경별 설정 관리를 완전히 마스터했습니다**

*개발부터 프로덕션까지 일관된 배포 전략*

**다음**: [Week 1 통합 프로젝트](../README.md#week-1-통합-프로젝트)

</div>