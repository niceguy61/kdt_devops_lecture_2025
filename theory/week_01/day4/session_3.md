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
- 💼 **실무 필요성**: 개발과 운영 환경의 차이점 관리
- 🏠 **일상 비유**: 집과 사무실에서 다른 옷을 입는 것처럼
- 📊 **보안성**: 민감한 정보의 안전한 관리

---

## 📖 핵심 개념 (35분)

### 🔍 개념 1: 환경별 설정 분리 (12분)

> **정의**: 개발, 스테이징, 프로덕션 환경에 맞는 설정 관리 방법

**🖼️ 환경별 배포 파이프라인**
![Environment Pipeline](https://miro.medium.com/max/1400/1*8xZmrWafDdkVlzlWgWbCKg.png)
*개발부터 프로덕션까지 배포 파이프라인*

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

**시크릿 관리 베스트 프랙티스**:
- **환경 변수**: 민감하지 않은 설정
- **Docker Secrets**: 민감한 정보 (패스워드, API 키)
- **외부 시크릿 관리**: HashiCorp Vault, AWS Secrets Manager
- **Git 제외**: .env 파일은 .gitignore에 추가

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

## 📝 세션 마무리

### ✅ 오늘 세션 성과
- [ ] 환경별 설정 분리 방법 완전 이해
- [ ] 환경 변수와 시크릿 관리 방법 습득
- [ ] Compose 파일 오버라이드 기법 파악
- [ ] Week 1 통합 프로젝트 준비 완료

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