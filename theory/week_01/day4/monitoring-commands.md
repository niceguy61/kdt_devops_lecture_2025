# Docker Compose 모니터링 명령어 모음

## 🔍 기본 모니터링 명령어

### 컨테이너 상태 확인
```bash
# 모든 서비스 상태
docker-compose ps

# 특정 서비스 상태
docker-compose ps backend

# 실행 중인 프로세스
docker-compose top
```

### 리소스 사용량 모니터링
```bash
# 실시간 리소스 사용량
docker stats $(docker-compose ps -q)

# 한 번만 확인
docker stats --no-stream $(docker-compose ps -q)

# 특정 컨테이너만
docker stats fullstack-backend
```

### 로그 모니터링
```bash
# 모든 서비스 로그
docker-compose logs -f

# 특정 서비스 로그
docker-compose logs -f backend

# 최근 100줄만
docker-compose logs --tail=100 backend

# 타임스탬프 포함
docker-compose logs -f -t backend
```

## 📊 고급 모니터링

### 헬스체크 상태
```bash
# 헬스체크 상태 확인
docker inspect --format='{{.State.Health.Status}}' fullstack-backend

# 헬스체크 로그
docker inspect --format='{{range .State.Health.Log}}{{.Output}}{{end}}' fullstack-backend
```

### 네트워크 모니터링
```bash
# 네트워크 목록
docker network ls

# 네트워크 상세 정보
docker network inspect fullstack_app-network

# 컨테이너 간 연결 확인
docker exec fullstack-backend ping postgres
```

### 볼륨 모니터링
```bash
# 볼륨 사용량
docker system df

# 볼륨 상세 정보
docker volume inspect fullstack_postgres_data

# 볼륨 내용 확인
docker run --rm -v fullstack_postgres_data:/data alpine ls -la /data
```

## 🚨 알림 및 자동화

### 컨테이너 재시작 모니터링
```bash
# 재시작 횟수 확인
docker-compose ps --format "table {{.Name}}\t{{.State}}\t{{.Ports}}"

# 특정 컨테이너 재시작 이벤트
docker events --filter container=fullstack-backend
```

### 자동 복구 스크립트
```bash
#!/bin/bash
# auto-heal.sh - 컨테이너 자동 복구

check_container() {
    if ! docker-compose ps | grep -q "Up"; then
        echo "⚠️ 컨테이너 문제 감지, 재시작 중..."
        docker-compose restart
        sleep 10
    fi
}

while true; do
    check_container
    sleep 30
done
```

## 📈 성능 메트릭 수집

### CPU/메모리 사용률 로깅
```bash
# 성능 데이터를 파일로 저장
docker stats --no-stream --format "{{.Container}},{{.CPUPerc}},{{.MemUsage}}" $(docker-compose ps -q) >> performance.log
```

### 응답 시간 측정
```bash
# API 응답 시간 측정
curl -w "@curl-format.txt" -o /dev/null -s http://localhost/api/health

# curl-format.txt 내용:
#     time_namelookup:  %{time_namelookup}\n
#        time_connect:  %{time_connect}\n
#     time_appconnect:  %{time_appconnect}\n
#    time_pretransfer:  %{time_pretransfer}\n
#       time_redirect:  %{time_redirect}\n
#  time_starttransfer:  %{time_starttransfer}\n
#                     ----------\n
#          time_total:  %{time_total}\n
```

## 🔧 트러블슈팅 명령어

### 컨테이너 디버깅
```bash
# 컨테이너 내부 접속
docker-compose exec backend sh

# 컨테이너 파일 시스템 확인
docker-compose exec backend ls -la /app

# 환경 변수 확인
docker-compose exec backend env
```

### 네트워크 연결 테스트
```bash
# DNS 해상도 테스트
docker-compose exec backend nslookup postgres

# 포트 연결 테스트
docker-compose exec backend nc -zv postgres 5432

# HTTP 엔드포인트 테스트
docker-compose exec backend wget -qO- http://frontend:3000
```