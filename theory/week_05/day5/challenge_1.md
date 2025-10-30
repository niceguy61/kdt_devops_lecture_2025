# Week 5 Day 5 Challenge 1: 프로젝트 계획서 작성 (15:00-15:50)

<div align="center">

**📋 프로젝트 정의** • **🏗️ 아키텍처 설계** • **📊 기능 명세** • **🎯 구현 범위**

*다음 주 프로젝트를 위한 완벽한 준비*

</div>

---

## 🕘 Challenge 정보
**시간**: 15:00-15:50 (50분)
**목표**: 팀 프로젝트 계획서 작성 및 구현 범위 정의
**방식**: 팀별 협업 작업
**제출물**: 프로젝트 계획서 문서 + 아키텍처 다이어그램

## 🎯 Challenge 목표

### 📚 학습 목표
- 프로젝트 요구사항을 구체적으로 정의
- Docker Compose 기반 아키텍처 설계
- 기능 목록을 상세하게 분류 및 우선순위 설정
- AWS 마이그레이션 전략 사전 계획

### 🛠️ 실무 역량
- 프로젝트 기획 및 문서화 능력
- 아키텍처 설계 및 시각화
- 팀 협업 및 역할 분담
- 기술 스택 선정 및 정당화

---

## 📋 프로젝트 계획서 양식

### 📄 제출 양식

다음 양식에 맞춰 프로젝트 계획서를 작성하세요.

**파일명**: `[팀명]_프로젝트_계획서.md` (예: `team1_프로젝트_계획서.md`)

**제출 위치**: 각 팀 GitHub Repository의 `docs/` 폴더

---

## 📝 프로젝트 계획서 템플릿

```markdown
# [프로젝트명] 계획서

## 📌 프로젝트 개요

### 프로젝트명
- **한글명**: [프로젝트 한글 이름]
- **영문명**: [프로젝트 영문 이름]
- **버전**: v1.0.0

### 프로젝트 설명
[프로젝트에 대한 간단한 설명 (2-3문장)]

### 프로젝트 목표
- 목표 1: [구체적인 목표]
- 목표 2: [구체적인 목표]
- 목표 3: [구체적인 목표]

### 타겟 사용자
- 주요 사용자: [누가 사용하는가?]
- 사용 시나리오: [어떤 상황에서 사용하는가?]

---

## 🏗️ 아키텍처 설계

### Docker Compose 기반 아키텍처

**아키텍처 다이어그램**:
- 📎 첨부 파일: `architecture_diagram.png` 또는 `architecture_diagram.drawio`
- 🔗 온라인 링크: [Draw.io / Excalidraw / PPT 링크]

**권장 도구**:
- [Draw.io](https://app.diagrams.net/)
- [Excalidraw](https://excalidraw.com/)
- PowerPoint / Google Slides
- Mermaid (Markdown 내 작성 가능)

**아키텍처 다이어그램 포함 요소**:
```
필수 포함 사항:
- [ ] 모든 서비스 컨테이너 (Frontend, Backend, Database 등)
- [ ] 서비스 간 통신 방향 (화살표)
- [ ] 포트 번호 (예: 3000, 8080, 5432)
- [ ] 네트워크 구성 (Docker Network)
- [ ] 볼륨 마운트 (데이터 영속성)
- [ ] 외부 접근 경로 (사용자 → 서비스)

### 서비스 구성 요소

#### Frontend
| 항목 | 내용 |
|------|------|
| **기술 스택** | React / Vue / Angular / Next.js 등 |
| **포트** | 3000 (예시) |
| **주요 기능** | UI/UX, 사용자 인터랙션 |
| **외부 의존성** | Backend API |

#### Backend
| 항목 | 내용 |
|------|------|
| **기술 스택** | Node.js / Spring Boot / Django / FastAPI 등 |
| **포트** | 8080 (예시) |
| **주요 기능** | 비즈니스 로직, API 제공 |
| **외부 의존성** | Database, Cache (선택) |

#### Database
| 항목 | 내용 |
|------|------|
| **기술 스택** | PostgreSQL / MySQL / MongoDB 등 |
| **포트** | 5432 / 3306 / 27017 (예시) |
| **데이터 영속성** | Docker Volume 사용 |
| **초기 데이터** | 있음 / 없음 |

#### 기타 서비스 (선택 사항)
| 서비스 | 기술 스택 | 포트 | 용도 |
|--------|----------|------|------|
| Cache | Redis | 6379 | 세션, 캐싱 |
| Message Queue | RabbitMQ / Kafka | 5672 / 9092 | 비동기 처리 |
| 기타 | - | - | - |

### Docker Compose 구성

```yaml
# docker-compose.yml 예시 (실제 파일은 프로젝트 루트에 위치)

version: '3.8'

services:
  frontend:
    image: [이미지명]
    ports:
      - "3000:3000"
    depends_on:
      - backend
    networks:
      - app-network

  backend:
    image: [이미지명]
    ports:
      - "8080:8080"
    environment:
      - DB_HOST=database
      - DB_PORT=5432
    depends_on:
      - database
    networks:
      - app-network

  database:
    image: postgres:15
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_DB=mydb
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - app-network

volumes:
  db-data:

networks:
  app-network:
    driver: bridge
```

---

## 🎯 기능 명세

### 핵심 기능 목록

**우선순위 분류**:
- **P0 (필수)**: 프로젝트의 핵심 기능, 반드시 구현
- **P1 (중요)**: 사용자 경험 향상, 가능하면 구현
- **P2 (선택)**: 추가 기능, 시간 여유 시 구현

#### 기능 1: [기능명]
| 항목 | 내용 |
|------|------|
| **우선순위** | P0 / P1 / P2 |
| **설명** | [기능에 대한 상세 설명] |
| **사용자 스토리** | "사용자는 [행동]을 통해 [목적]을 달성한다" |
| **API 엔드포인트** | `POST /api/[endpoint]` |
| **요청 예시** | `{ "key": "value" }` |
| **응답 예시** | `{ "status": "success" }` |
| **예상 소요 시간** | X일 |
| **담당자** | [팀원 이름] |

#### 기능 2: [기능명]
[동일한 형식으로 반복]

#### 기능 3: [기능명]
[동일한 형식으로 반복]

### 기능 목록 요약표

| 번호 | 기능명 | 우선순위 | 담당자 | 예상 소요 | 상태 |
|------|--------|----------|--------|-----------|------|
| 1 | [기능 1] | P0 | [이름] | 2일 | 대기 |
| 2 | [기능 2] | P0 | [이름] | 3일 | 대기 |
| 3 | [기능 3] | P1 | [이름] | 1일 | 대기 |
| 4 | [기능 4] | P2 | [이름] | 2일 | 대기 |

---

## 📡 API 명세

### API 엔드포인트 목록

#### 인증 관련
| Method | Endpoint | 설명 | 요청 Body | 응답 |
|--------|----------|------|-----------|------|
| POST | `/api/auth/register` | 회원가입 | `{ "email", "password" }` | `{ "userId", "token" }` |
| POST | `/api/auth/login` | 로그인 | `{ "email", "password" }` | `{ "token" }` |
| POST | `/api/auth/logout` | 로그아웃 | - | `{ "status": "success" }` |

#### 비즈니스 로직 관련
| Method | Endpoint | 설명 | 요청 Body | 응답 |
|--------|----------|------|-----------|------|
| GET | `/api/[resource]` | 목록 조회 | - | `[{ "id", "name" }]` |
| GET | `/api/[resource]/:id` | 상세 조회 | - | `{ "id", "name", "details" }` |
| POST | `/api/[resource]` | 생성 | `{ "name", "data" }` | `{ "id", "status" }` |
| PUT | `/api/[resource]/:id` | 수정 | `{ "name", "data" }` | `{ "status" }` |
| DELETE | `/api/[resource]/:id` | 삭제 | - | `{ "status" }` |

### API 부하 테스트 준비

**강사 부하 테스트를 위한 정보**:
- **테스트 대상 API**: [가장 중요한 API 3-5개 선정]
- **예상 TPS**: [초당 요청 수 예상치]
- **테스트 시나리오**: [사용자 행동 시나리오]

**예시**:
```
1. 로그인 API: POST /api/auth/login
   - 예상 TPS: 100
   - 시나리오: 동시 100명 로그인

2. 상품 조회 API: GET /api/products
   - 예상 TPS: 500
   - 시나리오: 메인 페이지 접속 시 호출
```

---

## 💻 기술 스택

### Frontend
- **프레임워크**: [React / Vue / Angular / Next.js]
- **상태 관리**: [Redux / Vuex / Zustand]
- **스타일링**: [Tailwind CSS / Material-UI / Styled-components]
- **기타**: [TypeScript / ESLint / Prettier]

### Backend
- **프레임워크**: [Node.js + Express / Spring Boot / Django / FastAPI]
- **ORM**: [Prisma / TypeORM / Sequelize / JPA / Django ORM]
- **인증**: [JWT / OAuth2 / Passport.js]
- **기타**: [TypeScript / Swagger / Jest]

### Database
- **RDBMS**: [PostgreSQL / MySQL]
- **NoSQL**: [MongoDB / Redis] (선택)
- **마이그레이션**: [Prisma Migrate / Flyway / Alembic]

### DevOps (Week 1-4 학습 내용)
- **컨테이너**: Docker, Docker Compose
- **오케스트레이션**: Kubernetes (Week 3)
- **CI/CD**: GitHub Actions (예정)
- **모니터링**: Prometheus, Grafana (Week 4)

### 클라우드 (Week 5 학습 예정)
- **AWS 서비스**: [다음 섹션에서 계획]

---

## ☁️ AWS 마이그레이션 계획

### Docker Compose → AWS 서비스 매핑

| Docker Compose | AWS 서비스 | 이유 |
|----------------|-----------|------|
| Frontend Container | **S3 + CloudFront** 또는 **ECS** | 정적 파일 호스팅 또는 컨테이너 실행 |
| Backend Container | **ECS** 또는 **EC2 + ALB** | 컨테이너 오케스트레이션 |
| Database Container | **RDS** (PostgreSQL/MySQL) | 관리형 데이터베이스 |
| Redis Container | **ElastiCache** | 관리형 캐시 |
| Docker Network | **VPC + Subnet** | 네트워크 격리 |
| Docker Volume | **EBS** 또는 **EFS** | 데이터 영속성 |
| Load Balancer | **ALB** (Application Load Balancer) | 로드 밸런싱 |

### 예상 AWS 아키텍처

```
사용자
  ↓
CloudFront (CDN)
  ↓
ALB (Load Balancer)
  ↓
ECS (Backend Containers)
  ↓
RDS (Database) + ElastiCache (Redis)
```

**아키텍처 다이어그램**: [AWS 아키텍처 다이어그램 첨부 또는 링크]

---

## ⚠️ Pain Points 및 최적화 전략

### 예상 Pain Points

#### 1. [Pain Point 1: 예시 - 데이터베이스 성능]
**문제**:
- 대량의 데이터 조회 시 응답 속도 저하
- 복잡한 JOIN 쿼리로 인한 병목

**해결 방안**:
- Redis 캐싱 도입 (자주 조회되는 데이터)
- 인덱스 최적화
- 쿼리 최적화 (N+1 문제 해결)

**AWS 최적화**:
- RDS Read Replica 사용 (읽기 부하 분산)
- ElastiCache Redis 활용

#### 2. [Pain Point 2: 예시 - 트래픽 급증]
**문제**:
- 특정 시간대 트래픽 급증 (예: 이벤트 시작 시)
- 서버 과부하로 인한 서비스 중단

**해결 방안**:
- 수평 확장 (컨테이너 복제)
- 로드 밸런싱

**AWS 최적화**:
- Auto Scaling Group 설정
- ALB를 통한 트래픽 분산

#### 3. [Pain Point 3: 직접 작성]
**문제**:
- [팀 프로젝트의 예상 문제점]

**해결 방안**:
- [Docker Compose 환경에서의 해결책]

**AWS 최적화**:
- [AWS 서비스를 활용한 해결책]

### 최적화 체크리스트

- [ ] 데이터베이스 쿼리 최적화
- [ ] 캐싱 전략 수립
- [ ] API 응답 시간 목표 설정 (예: < 200ms)
- [ ] 에러 핸들링 및 로깅
- [ ] 보안 취약점 점검
- [ ] 부하 테스트 시나리오 작성

---


## 📚 참고 자료

### 학습 자료
- Week 1-2: Docker 기초 및 심화
- Week 3: Kubernetes
- Week 4: Cloud Native (Service Mesh, GitOps, FinOps)
- Week 5: AWS 인프라 구축

### 외부 참고 자료
- [프로젝트 관련 공식 문서 링크]
- [참고한 오픈소스 프로젝트]
- [기술 블로그 글]

---

## ✅ 제출 체크리스트

### 필수 항목
- [ ] 프로젝트 개요 작성 완료
- [ ] 아키텍처 다이어그램 첨부 (Docker Compose 기반)
- [ ] 기능 명세 상세 작성 (최소 5개 이상)
- [ ] API 엔드포인트 목록 작성
- [ ] 기술 스택 선정 및 이유 명시
- [ ] AWS 마이그레이션 계획 수립
- [ ] Pain Points 및 최적화 전략 (최소 3개)
- [ ] 팀 역할 분담 명확히 정의
- [ ] 주차별 계획 수립

### 권장 항목
- [ ] Docker Compose 파일 작성
- [ ] API 부하 테스트 시나리오
- [ ] 데이터베이스 ERD 다이어그램
- [ ] 화면 설계 (Wireframe)

---

## 📤 제출 방법

### 제출 위치
```
GitHub Repository: [팀 Repository URL]
└── docs/
    ├── [팀명]_프로젝트_계획서.md          # 이 문서
    ├── architecture_diagram.png           # 아키텍처 다이어그램
    ├── aws_architecture_diagram.png       # AWS 아키텍처 (선택)
    └── erd_diagram.png                    # ERD (선택)
```

### 제출 기한
- **마감**: Week 5 Day 5 (오늘) 18:00까지
- **제출 방법**: GitHub Repository에 Push 후 강사에게 링크 공유

---

## 🎤 발표 준비 (선택 사항)

### 발표 자료 (5분)
다음 주 월요일 간단한 프로젝트 소개 발표를 진행할 수 있습니다.

**발표 내용**:
1. 프로젝트 소개 (1분)
2. 아키텍처 설명 (2분)
3. 핵심 기능 소개 (1분)
4. 기술 스택 및 이유 (1분)

**발표 자료 형식**: PPT, PDF, 또는 Markdown

---

## 💡 작성 팁

### 좋은 계획서의 특징
- ✅ **구체적**: 모호한 표현 대신 명확한 수치와 기준
- ✅ **실현 가능**: 4주 내 완성 가능한 범위
- ✅ **우선순위 명확**: P0/P1/P2 분류로 집중할 기능 선정
- ✅ **역할 분담 명확**: 각 팀원의 책임 영역 정의
- ✅ **확장 가능**: AWS 마이그레이션을 고려한 설계

### 피해야 할 것
- ❌ 너무 많은 기능 (4주 내 완성 불가능)
- ❌ 모호한 표현 ("대충", "적당히", "나중에")
- ❌ 역할 분담 없음 (모두가 모든 것을 함)
- ❌ 기술 스택 선정 이유 없음

---

## 🔗 참고 예시

### 예시 프로젝트: "CloudMart"

**프로젝트 개요**:
- 온라인 쇼핑몰 플랫폼
- 사용자: 일반 소비자 및 판매자
- 목표: 간편한 상품 구매 및 판매 경험 제공

**핵심 기능**:
1. 회원가입/로그인 (P0)
2. 상품 목록 조회 (P0)
3. 상품 상세 조회 (P0)
4. 장바구니 (P1)
5. 주문/결제 (P1)
6. 리뷰 작성 (P2)

**기술 스택**:
- Frontend: React + TypeScript
- Backend: Node.js + Express
- Database: PostgreSQL
- Cache: Redis

**Docker Compose 구성**:
- frontend (React)
- backend (Node.js)
- database (PostgreSQL)
- cache (Redis)

---

<div align="center">

**📋 완벽한 계획** • **🏗️ 명확한 설계** • **🎯 실현 가능한 범위** • **👥 효율적인 협업**

*다음 주 프로젝트 성공을 위한 첫 걸음!*

</div>
```
