# Week 1 Day 4: 팀 프로젝트 선택 가이드

<div align="center">

**🎯 Docker Compose 실전 프로젝트** • **팀별 선택**

*7가지 프로젝트 중 팀별로 선택하여 구현*

**👥 추천 인원: 4명**

</div>

---

## 📋 프로젝트 목록

### 1. 소셜 미디어 플랫폼

**🎯 프로젝트 개요**  
트위터/인스타그램 같은 소셜 미디어의 핵심 기능 구현

**📋 필수 API 엔드포인트**
- `POST /api/auth/login`
- `POST /api/auth/register`
- `GET /api/users/{id}/profile`
- `POST /api/posts`
- `GET /api/posts/feed`
- `POST /api/posts/{id}/like`
- `POST /api/posts/{id}/comments`
- `GET /api/users/{id}/followers`

**🔧 핵심 기능**
- 사용자 인증 및 프로필 관리
- 게시물 CRUD (이미지 업로드 포함)
- 팔로우/언팔로우 시스템
- 좋아요 및 댓글
- 피드 알고리즘 (시간순/인기순)
- 실시간 알림

---

### 2. 온라인 쇼핑몰 API

**🎯 프로젝트 개요**  
아마존/쿠팡 같은 전자상거래 플랫폼의 백엔드 시스템

**📋 필수 API 엔드포인트**
- `GET /api/products`
- `GET /api/products/{id}`
- `POST /api/cart/items`
- `GET /api/cart`
- `POST /api/orders`
- `GET /api/orders/{id}`
- `POST /api/reviews`
- `GET /api/products/{id}/reviews`

**🔧 핵심 기능**
- 상품 카탈로그 관리
- 장바구니 시스템
- 주문 처리 워크플로우
- 재고 관리
- 리뷰 및 평점 시스템
- 검색 및 필터링
- 주문 상태 추적

---

### 3. 프로젝트 관리 도구

**🎯 프로젝트 개요**  
지라/트렐로 같은 업무 관리 플랫폼

**📋 필수 API 엔드포인트**
- `POST /api/projects`
- `GET /api/projects/{id}/tasks`
- `POST /api/tasks`
- `PUT /api/tasks/{id}/status`
- `POST /api/tasks/{id}/comments`
- `GET /api/users/{id}/assigned-tasks`
- `GET /api/projects/{id}/analytics`

**🔧 핵심 기능**
- 프로젝트 생성 및 관리
- 태스크 CRUD 및 상태 관리
- 사용자 역할 및 권한 관리
- 댓글 및 첨부파일
- 마일스톤 및 데드라인
- 작업 시간 추적
- 프로젝트 진행률 대시보드

---

### 4. 블로그 CMS + 커뮤니티

**🎯 프로젝트 개요**  
미디엄/네이버 블로그 같은 콘텐츠 플랫폼

**📋 필수 API 엔드포인트**
- `POST /api/posts`
- `GET /api/posts`
- `GET /api/posts/{slug}`
- `POST /api/posts/{id}/comments`
- `GET /api/categories`
- `GET /api/tags`
- `GET /api/users/{id}/posts`
- `GET /api/search`

**🔧 핵심 기능**
- 마크다운 기반 포스트 작성
- 카테고리 및 태그 시스템
- 댓글 및 답글
- 포스트 좋아요/북마크
- 검색 기능 (제목/내용/태그)
- 조회수 및 인기글
- 구독/팔로우 시스템

---

### 5. 실시간 채팅 + 파일 공유 서비스

**🎯 프로젝트 개요**  
슬랙/디스코드 같은 팀 커뮤니케이션 도구

**📋 필수 API 엔드포인트**
- `POST /api/channels`
- `GET /api/channels/{id}/messages`
- `POST /api/channels/{id}/messages`
- `POST /api/files/upload`
- `GET /api/files/{id}`
- `GET /api/users/online`
- `POST /api/channels/{id}/invite`

**🔧 핵심 기능**
- 채널 생성 및 관리
- 실시간 메시지 전송
- 파일 업로드 및 다운로드
- 온라인 사용자 표시
- 메시지 검색
- 멘션 및 알림
- 채널 초대 시스템

---

### 6. 예약 관리 시스템

**🎯 프로젝트 개요**  
병원/미용실/레스토랑 같은 예약 기반 서비스 플랫폼

**📋 필수 API 엔드포인트**
- `GET /api/services`
- `GET /api/providers/{id}/availability`
- `POST /api/reservations`
- `GET /api/reservations/{id}`
- `PUT /api/reservations/{id}/status`
- `GET /api/users/{id}/reservations`
- `POST /api/providers/{id}/schedule`
- `GET /api/providers/{id}/analytics`

**🔧 핵심 기능**
- 서비스 제공자 및 서비스 관리
- 실시간 예약 가능 시간 조회
- 예약 생성/수정/취소
- 예약 상태 관리 (대기/확정/완료/취소)
- 예약 충돌 방지 로직
- 리마인더 알림 시스템
- 대기열 관리
- 예약 통계 및 분석

---

### 7. URL 단축 + 분석 서비스

**🎯 프로젝트 개요**  
비트리/TinyURL 같은 URL 단축 + 클릭 분석 플랫폼

**📋 필수 API 엔드포인트**
- `POST /api/urls/shorten`
- `GET /api/urls/{shortCode}`
- `GET /api/urls/{id}/analytics`
- `GET /api/users/{id}/urls`
- `PUT /api/urls/{id}`
- `DELETE /api/urls/{id}`
- `GET /api/analytics/dashboard`

**🔧 핵심 기능**
- URL 단축 및 커스텀 단축 코드
- 클릭 추적 및 리다이렉트
- 지역별/시간별 클릭 통계
- 브라우저/OS/디바이스 분석
- QR 코드 자동 생성
- 만료 기간 설정
- 비밀번호 보호 URL
- 대시보드 및 실시간 통계

---

## 🎯 팀 구성 및 선택 가이드

### 👥 추천 팀 구성 (4명)
- **프론트엔드 개발자** (1명): React/Vue.js UI 구현
- **백엔드 개발자** (1명): API 서버 및 비즈니스 로직
- **데이터베이스 설계자** (1명): DB 스키마 및 데이터 관리
- **DevOps 엔지니어** (1명): Docker Compose 구성 및 배포

### 📊 프로젝트 선택 기준
| 프로젝트 | 난이도 | 기술 스택 다양성 | 실무 연관성 |
|---------|--------|----------------|------------|
| 소셜 미디어 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| 온라인 쇼핑몰 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| 프로젝트 관리 | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| 블로그 CMS | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| 실시간 채팅 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| 예약 관리 | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| URL 단축 | ⭐⭐ | ⭐⭐ | ⭐⭐⭐ |

### 🚀 선택 가이드
- **초보자 팀**: URL 단축 서비스 또는 블로그 CMS
- **중급자 팀**: 프로젝트 관리 도구 또는 예약 관리 시스템
- **고급자 팀**: 소셜 미디어, 온라인 쇼핑몰, 실시간 채팅

---

<div align="center">

**🎯 팀별로 프로젝트를 선택하고 Docker Compose로 구현해보세요!**

*각 프로젝트는 실무에서 사용하는 기술 스택과 아키텍처 패턴을 경험할 수 있습니다*

</div>