# CI/CD Demo Application

Docker Compose 기반 3-Tier 애플리케이션 + GitHub Actions CI/CD

## 🚀 빠른 시작

### 로컬 실행
```bash
docker-compose up -d
```

### 접속
- Frontend: http://localhost
- Backend API: http://localhost/api/health
- Users API: http://localhost/api/users

## 📦 구조

```
.
├── frontend/          # React 프론트엔드
├── backend/           # Node.js 백엔드
├── docker-compose.yml # Docker Compose 설정
├── init.sql          # 데이터베이스 초기화
└── .github/
    └── workflows/
        └── ci-cd.yml  # GitHub Actions 워크플로우
```

## 🔄 CI/CD 파이프라인

### 자동 실행 조건
- `main` 또는 `develop` 브랜치에 푸시
- `main` 브랜치로 Pull Request

### 파이프라인 단계
1. **Test**: Backend/Frontend 테스트 실행
2. **Build**: Docker 이미지 빌드
3. **Deploy**: 배포 알림 (실제 배포는 수동)

## 🛠️ 개발

### Backend 개발
```bash
cd backend
npm install
npm run dev
```

### Frontend 개발
```bash
cd frontend
npm install
npm start
```

## 📝 버전
- Current: 1.0.0
