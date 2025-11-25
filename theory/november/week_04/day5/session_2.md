# November Week 4 Day 5 Session 2: 기본 프로젝트 소개

<div align="center">

**🎯 프로젝트 목표** • **🏗️ 아키텍처** • **📋 요구사항**

*4주간의 실전 프로젝트 완전 가이드*

</div>

---

## 🕘 세션 정보
**시간**: 09:40-10:20 (40분)
**목표**: 기본 프로젝트 이해 및 준비
**방식**: 프로젝트 소개 + 질의응답

## 🎯 학습 목표
- 기본 프로젝트 목표 및 범위 이해
- 기술 스택 및 아키텍처 파악
- 요구사항 및 평가 기준 숙지
- 일정 및 마일스톤 계획

---

## 📖 프로젝트 개요

### 프로젝트 목표

**핵심 목표**:
- November 4주 학습 내용 실전 적용
- 컨테이너 기반 웹 서비스 구축
- 팀 협업 및 Git 워크플로우 경험
- 포트폴리오 제작

**기간 및 일정**:
```
기간: 4주 (12월 1주 - 4주)
Week 1: 기획 & 설계
Week 2: 개발 (Frontend + Backend)
Week 3: 인프라 & 배포
Week 4: 테스트 & 발표 준비
```

### 프로젝트 범위

**필수 구현 사항**:
1. **Frontend**: 사용자 인터페이스
2. **Backend**: API 서버
3. **Database**: 데이터 저장
4. **Docker**: 컨테이너화
5. **Kubernetes**: 오케스트레이션
6. **CI/CD**: 자동 배포

**선택 구현 사항**:
- Helm Chart
- 모니터링 (Prometheus + Grafana)
- 로깅 (ELK Stack)
- Service Mesh (Istio)

---

## 🏗️ 기술 스택

### 권장 기술 스택

**Frontend**:
- React / Vue.js / Angular
- Nginx (정적 파일 서빙)
- Docker 컨테이너

**Backend**:
- Node.js (Express) / Python (FastAPI) / Go
- RESTful API
- Docker 컨테이너

**Database**:
- PostgreSQL / MySQL (관계형)
- MongoDB / Redis (NoSQL)
- Docker 컨테이너 또는 Kubernetes StatefulSet

**Infrastructure**:
- Docker & Docker Compose (로컬 개발)
- Kubernetes (배포)
- Helm (패키지 관리)

**CI/CD**:
- GitHub Actions
- Docker Hub / GitHub Container Registry
- ArgoCD (선택)

**Monitoring** (선택):
- Prometheus (메트릭 수집)
- Grafana (시각화)
- Loki (로깅)

### 기술 선택 가이드

**간단한 프로젝트**:
```
Frontend: React
Backend: Node.js + Express
Database: PostgreSQL
Infrastructure: Docker Compose
```

**표준 프로젝트**:
```
Frontend: React + Nginx
Backend: Node.js + Express
Database: PostgreSQL + Redis
Infrastructure: Kubernetes + Helm
CI/CD: GitHub Actions
```

**고급 프로젝트**:
```
Frontend: React + Nginx
Backend: Node.js + Express (마이크로서비스)
Database: PostgreSQL + Redis + MongoDB
Infrastructure: Kubernetes + Helm
CI/CD: GitHub Actions + ArgoCD
Monitoring: Prometheus + Grafana
```

---

## 🎯 프로젝트 주제 예시

### 1. 블로그 플랫폼
**기능**:
- 사용자 인증 (회원가입, 로그인)
- 게시글 CRUD
- 댓글 기능
- 태그 및 검색

**기술 포인트**:
- JWT 인증
- RESTful API
- 이미지 업로드 (S3 또는 MinIO)
- 전문 검색 (Elasticsearch)

### 2. TODO 관리 앱
**기능**:
- 할 일 CRUD
- 카테고리 분류
- 마감일 알림
- 팀 협업 (공유)

**기술 포인트**:
- WebSocket (실시간 업데이트)
- 알림 시스템
- 권한 관리
- 캘린더 통합

### 3. 간단한 E-Commerce
**기능**:
- 상품 목록 및 상세
- 장바구니
- 주문 및 결제
- 관리자 페이지

**기술 포인트**:
- 결제 API 연동 (Stripe/Toss)
- 재고 관리
- 주문 상태 관리
- 이메일 알림

### 4. 실시간 채팅 앱
**기능**:
- 1:1 채팅
- 그룹 채팅
- 파일 공유
- 읽음 표시

**기술 포인트**:
- WebSocket / Socket.io
- 메시지 큐 (Redis)
- 파일 스토리지
- 실시간 알림

### 5. 프로젝트 관리 도구
**기능**:
- 프로젝트 생성
- 태스크 관리 (Kanban)
- 팀원 초대
- 진행 상황 대시보드

**기술 포인트**:
- 드래그 앤 드롭
- 권한 관리
- 실시간 업데이트
- 통계 및 리포트

---

## 📋 요구사항

### 기능적 요구사항

**필수 기능**:
1. **사용자 인증**: 회원가입, 로그인, 로그아웃
2. **CRUD 기능**: 핵심 데이터 생성/조회/수정/삭제
3. **API 설계**: RESTful API 또는 GraphQL
4. **데이터 저장**: 데이터베이스 연동
5. **에러 처리**: 적절한 에러 메시지 및 처리

**선택 기능**:
- 실시간 기능 (WebSocket)
- 파일 업로드
- 검색 기능
- 알림 시스템
- 관리자 페이지

### 비기능적 요구사항

**인프라**:
1. **Docker**: 모든 서비스 컨테이너화
2. **Docker Compose**: 로컬 개발 환경
3. **Kubernetes**: 배포 환경 (Minikube/Kind)
4. **CI/CD**: GitHub Actions 자동 배포

**코드 품질**:
1. **Git**: 브랜치 전략, 커밋 메시지 규칙
2. **코드 리뷰**: 모든 PR은 리뷰 후 머지
3. **테스트**: 단위 테스트 (선택)
4. **문서화**: README, API 문서

**보안**:
1. **환경 변수**: 민감 정보 분리
2. **HTTPS**: SSL/TLS 적용 (선택)
3. **인증/인가**: JWT 또는 Session
4. **입력 검증**: SQL Injection, XSS 방지

---

## 📊 평가 기준

### 평가 항목 및 배점

**1. 기술적 완성도 (40점)**:
- 기능 구현 완성도 (15점)
- 코드 품질 (10점)
- 아키텍처 설계 (10점)
- 테스트 (5점)

**2. 인프라 & DevOps (30점)**:
- Docker 컨테이너화 (10점)
- Kubernetes 배포 (10점)
- CI/CD 파이프라인 (10점)

**3. 협업 & 프로세스 (20점)**:
- Git 사용 (커밋, PR, 리뷰) (10점)
- 문서화 (README, API 문서) (5점)
- 팀 협업 과정 (5점)

**4. 발표 & 시연 (10점)**:
- 프로젝트 소개 (3점)
- 기술 설명 (3점)
- 데모 시연 (3점)
- 질의응답 (1점)

### 우수 프로젝트 기준

**기술적 우수성**:
- November 학습 내용 적극 활용
- 안정적인 아키텍처 설계
- 깔끔한 코드 구조

**협업 우수성**:
- 활발한 코드 리뷰
- 명확한 문서화
- 효과적인 역할 분담

**창의성**:
- 독창적인 아이디어
- 사용자 경험 고려
- 추가 기능 구현

---

## 📅 일정 및 마일스톤

### 주차별 목표

**Week 1 (12/1 - 12/7): 기획 & 설계**
- 팀 구성 및 주제 선정
- 요구사항 정의
- 아키텍처 설계
- 기술 스택 확정
- Git Repository 생성

**산출물**:
- 프로젝트 계획서
- 아키텍처 다이어그램
- API 설계서
- DB 스키마

**Week 2 (12/8 - 12/14): 개발**
- Frontend 개발
- Backend API 개발
- Database 연동
- Docker 컨테이너화

**산출물**:
- Frontend 코드
- Backend 코드
- Dockerfile
- docker-compose.yml

**Week 3 (12/15 - 12/21): 인프라 & 배포**
- Kubernetes 매니페스트 작성
- Helm Chart 작성 (선택)
- GitHub Actions 워크플로우
- 배포 및 테스트

**산출물**:
- Kubernetes YAML
- Helm Chart (선택)
- CI/CD 파이프라인
- 배포 문서

**Week 4 (12/22 - 12/28): 테스트 & 발표**
- 통합 테스트
- 버그 수정
- 문서 정리
- 발표 준비

**산출물**:
- 최종 코드
- 완성된 문서
- 발표 자료
- 데모 영상

---

## 💡 성공 전략

### 프로젝트 성공 팁

**1. 작게 시작하기**:
- MVP (Minimum Viable Product) 먼저
- 핵심 기능 우선 구현
- 점진적 기능 추가

**2. 명확한 역할 분담**:
- Frontend, Backend, DevOps 역할
- 각자의 강점 활용
- 정기적인 통합

**3. 지속적인 통합**:
- 매일 코드 통합
- 작은 단위로 PR
- 빠른 피드백

**4. 문서화 습관**:
- README 먼저 작성
- API 문서 자동화
- 주석 및 설명

### 피해야 할 실수

**❌ 피해야 할 것**:
- 너무 복잡한 주제 선택
- 역할 분담 없이 시작
- 문서화 미루기
- 마지막에 통합하기
- 테스트 없이 배포

**✅ 해야 할 것**:
- 간단하고 명확한 주제
- 명확한 역할 분담
- 지속적인 문서화
- 매일 통합 및 테스트
- 안전한 배포 프로세스

---

## 🔗 참고 자료

### 프로젝트 템플릿
- [Node.js + React 템플릿](https://github.com/...)
- [Python + Vue 템플릿](https://github.com/...)
- [Kubernetes 매니페스트 예시](https://github.com/...)

### 학습 자료
- [REST API 설계 가이드](https://...)
- [Docker 베스트 프랙티스](https://...)
- [Kubernetes 패턴](https://...)
- [Git 협업 가이드](https://...)

---

## 💭 함께 생각해보기

### 🤝 전체 토론 (5분)
1. **주제 아이디어**: 어떤 프로젝트를 만들고 싶나요?
2. **기술 선택**: 어떤 기술 스택이 적합할까요?
3. **우려사항**: 걱정되는 부분은 무엇인가요?

---

## 📝 세션 마무리

### ✅ 이해 완료
- [ ] 프로젝트 목표 및 범위
- [ ] 기술 스택 선택 기준
- [ ] 요구사항 및 평가 기준
- [ ] 일정 및 마일스톤

### 🎯 다음 세션
**Session 3: 팀 구성 & 주제 선정**
- 팀 구성 원칙
- 주제 선정 가이드
- 프로젝트 계획 수립

---

<div align="center">

**🎯 프로젝트 이해 완료** • **🏗️ 기술 스택 선택** • **📋 요구사항 숙지**

*이제 팀을 구성하고 프로젝트를 시작할 준비가 되었습니다*

</div>
