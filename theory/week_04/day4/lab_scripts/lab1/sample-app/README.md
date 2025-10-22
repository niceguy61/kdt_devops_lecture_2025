# CI/CD Demo App

## 🚀 자동 배포 워크플로우

```
코드 수정 → Git Push → GitHub Actions 빌드 → GHCR 푸시 → Watchtower 자동 배포
```

## 📦 구성

- **Frontend**: React + Nginx
- **Backend**: Node.js + Express
- **Database**: PostgreSQL
- **CI/CD**: GitHub Actions + GHCR
- **Auto Deploy**: Watchtower

## 🛠️ 사용 방법

### 1. 환경 설정
```bash
cp .env.example .env
# .env 파일에서 본인의 GitHub 정보 입력
```

### 2. 로컬 실행
```bash
# .env 파일 로드 후 실행
export $(cat .env | xargs)
docker-compose up -d
```

### 3. 접속
- Frontend: http://localhost:3000
- Backend API: http://localhost:3001/api/health

### 4. 코드 수정 후 배포
```bash
# 코드 수정
git add .
git commit -m "Update message"
git push

# GitHub Actions 자동 실행
# 5분 후 Watchtower가 자동으로 새 이미지 배포
```

## 🔄 Watchtower 동작

- **체크 간격**: 5분마다
- **동작**: GHCR에서 새 이미지 확인 → Pull → 컨테이너 재시작
- **비용**: 무료 (GHCR 무제한)

## 📝 수정 예시

**Frontend 메시지 변경**:
```javascript
// frontend/src/App.js
<h1>🚀 CI/CD Demo App v2.0</h1>
```

**Backend 응답 변경**:
```javascript
// backend/index.js
message: 'Backend is running! 🎉 Updated!'
```
