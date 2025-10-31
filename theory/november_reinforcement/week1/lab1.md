# Week 1 Day 1 Lab 1: Docker Compose로 WordPress 블로그 구축

<div align="center">

**🎯 실습 목표** • **⏱️ 50분** • **🐳 Docker Compose**

*실제 블로그 서비스를 Docker Compose로 배포하고 사용해보기*

</div>

---

## 🕘 Lab 정보
**시간**: 10:00-10:50 (50분)
**목표**: WordPress + MySQL을 Docker Compose로 배포
**방식**: 단계별 실습 가이드
**난이도**: ⭐⭐☆☆☆ (초급)

## 🎯 학습 목표
- [ ] Docker Compose 파일 작성 및 이해
- [ ] 멀티 컨테이너 애플리케이션 배포
- [ ] 서비스 간 통신 및 데이터 영속성 확인
- [ ] 실제 웹 서비스 운영 경험

---

## 🏗️ 구축할 아키텍처

### 📐 아키텍처 다이어그램
```
┌─────────────────────────────────────────┐
│         로컬 개발 환경 (Docker)          │
│  ┌───────────────────────────────────┐  │
│  │  Docker Compose Network           │  │
│  │  ┌─────────────┐  ┌────────────┐ │  │
│  │  │ WordPress   │  │   MySQL    │ │  │
│  │  │ Container   │→ │ Container  │ │  │
│  │  │ Port: 8080  │  │ Port: 3306 │ │  │
│  │  └─────────────┘  └────────────┘ │  │
│  │         ↓                ↓        │  │
│  │  ┌─────────────┐  ┌────────────┐ │  │
│  │  │ wordpress_  │  │  mysql_    │ │  │
│  │  │   data      │  │   data     │ │  │
│  │  │  (Volume)   │  │ (Volume)   │ │  │
│  │  └─────────────┘  └────────────┘ │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
         ↑
    http://localhost:8080
```

### 🔧 구성 요소
- **WordPress Container**: PHP 기반 블로그 플랫폼
- **MySQL Container**: 데이터베이스 (사용자, 게시글 저장)
- **Docker Network**: 컨테이너 간 통신
- **Docker Volumes**: 데이터 영속성 보장

---

## 🛠️ Step 1: 환경 준비 (5분)

### 1-1. Docker 설치 확인
```bash
# Docker 버전 확인
docker --version
# 예상 출력: Docker version 24.0.0 이상

# Docker Compose 버전 확인
docker-compose --version
# 예상 출력: Docker Compose version v2.20.0 이상
```

**✅ 체크포인트**:
- [ ] Docker 설치 확인
- [ ] Docker Compose 설치 확인

### 1-2. 실습 디렉토리 생성
```bash
# 실습 디렉토리 생성
mkdir -p ~/november-reinforcement/week1/day1
cd ~/november-reinforcement/week1/day1

# 현재 위치 확인
pwd
# 예상 출력: /home/username/november-reinforcement/week1/day1
```

**✅ 체크포인트**:
- [ ] 디렉토리 생성 완료
- [ ] 올바른 위치로 이동

---

## 🛠️ Step 2: docker-compose.yml 작성 (10분)

### 2-1. 파일 생성
```bash
# docker-compose.yml 파일 생성
cat > docker-compose.yml <<'EOF'
version: '3.8'

services:
  # WordPress 서비스
  wordpress:
    image: wordpress:latest
    container_name: wordpress-app
    ports:
      - "8080:80"
    environment:
      # MySQL 연결 정보
      WORDPRESS_DB_HOST: mysql
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress123
      WORDPRESS_DB_NAME: wordpress
    volumes:
      # WordPress 파일 영속성
      - wordpress_data:/var/www/html
    depends_on:
      # MySQL이 먼저 시작되어야 함
      - mysql
    restart: unless-stopped
    networks:
      - wordpress-network

  # MySQL 서비스
  mysql:
    image: mysql:5.7
    container_name: wordpress-db
    environment:
      # 데이터베이스 초기 설정
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress123
      MYSQL_ROOT_PASSWORD: rootpassword123
    volumes:
      # MySQL 데이터 영속성
      - mysql_data:/var/lib/mysql
    restart: unless-stopped
    networks:
      - wordpress-network

# Named Volumes 정의
volumes:
  wordpress_data:
    driver: local
  mysql_data:
    driver: local

# 네트워크 정의
networks:
  wordpress-network:
    driver: bridge
EOF
```

### 2-2. 파일 내용 확인
```bash
# 파일이 제대로 생성되었는지 확인
cat docker-compose.yml

# 또는 에디터로 열기
# code docker-compose.yml  # VS Code
# vim docker-compose.yml   # Vim
```

### 2-3. 코드 이해하기

**주요 설정 설명**:

| 설정 | 의미 | 예시 |
|------|------|------|
| `image` | 사용할 Docker 이미지 | `wordpress:latest` |
| `container_name` | 컨테이너 이름 | `wordpress-app` |
| `ports` | 포트 매핑 (호스트:컨테이너) | `8080:80` |
| `environment` | 환경 변수 | `WORDPRESS_DB_HOST: mysql` |
| `volumes` | 데이터 영속성 | `wordpress_data:/var/www/html` |
| `depends_on` | 시작 순서 | `mysql` 먼저 시작 |
| `restart` | 재시작 정책 | `unless-stopped` |
| `networks` | 네트워크 연결 | `wordpress-network` |

**💡 핵심 포인트**:
- `WORDPRESS_DB_HOST: mysql` → 서비스 이름으로 통신 (자동 DNS)
- `volumes` → 컨테이너 삭제해도 데이터 유지
- `depends_on` → MySQL이 먼저 시작되도록 보장

**✅ 체크포인트**:
- [ ] docker-compose.yml 파일 생성 완료
- [ ] 파일 내용 확인 완료
- [ ] 주요 설정 이해

---

## 🛠️ Step 3: 서비스 시작 (5분)

### 3-1. Docker Compose 실행
```bash
# 백그라운드로 서비스 시작
docker-compose up -d

# 예상 출력:
# Creating network "day1_wordpress-network" with driver "bridge"
# Creating volume "day1_wordpress_data" with default driver
# Creating volume "day1_mysql_data" with default driver
# Pulling mysql (mysql:5.7)...
# Pulling wordpress (wordpress:latest)...
# Creating wordpress-db ... done
# Creating wordpress-app ... done
```

**명령어 옵션 설명**:
- `up`: 서비스 시작
- `-d`: 백그라운드 실행 (detached mode)

### 3-2. 서비스 상태 확인
```bash
# 실행 중인 컨테이너 확인
docker-compose ps

# 예상 출력:
#     Name                   Command               State          Ports
# -------------------------------------------------------------------------------
# wordpress-app   docker-entrypoint.sh apach ...   Up      0.0.0.0:8080->80/tcp
# wordpress-db    docker-entrypoint.sh mysqld      Up      3306/tcp, 33060/tcp
```

**상태 확인 포인트**:
- `State`: `Up` 상태여야 함
- `Ports`: `0.0.0.0:8080->80/tcp` 포트 매핑 확인

### 3-3. 로그 확인
```bash
# 전체 로그 확인
docker-compose logs

# WordPress 로그만 확인
docker-compose logs wordpress

# 실시간 로그 (Ctrl+C로 종료)
docker-compose logs -f
```

**✅ 체크포인트**:
- [ ] 서비스 정상 시작 (Up 상태)
- [ ] 포트 매핑 확인 (8080:80)
- [ ] 에러 로그 없음

---

## 🛠️ Step 4: WordPress 초기 설정 (15분)

### 4-1. 웹 브라우저 접속
```
http://localhost:8080
```

**예상 화면**: WordPress 언어 선택 화면

### 4-2. 언어 선택
- **한국어** 선택
- **계속** 버튼 클릭

### 4-3. 사이트 정보 입력
```
사이트 제목: My Docker Blog
사용자명: admin
비밀번호: (강력한 비밀번호 생성 - 자동 생성 추천)
이메일: your-email@example.com
검색 엔진 노출: ☑ (체크)
```

**💡 팁**:
- 비밀번호는 자동 생성된 강력한 비밀번호 사용 권장
- 이메일은 실제 이메일 주소 사용 (알림 받기 위해)

### 4-4. WordPress 설치
- **WordPress 설치** 버튼 클릭
- 설치 완료 메시지 확인
- **로그인** 버튼 클릭

### 4-5. 대시보드 확인
- 사용자명과 비밀번호 입력
- 로그인 후 WordPress 관리자 대시보드 확인

**✅ 체크포인트**:
- [ ] WordPress 초기 설정 완료
- [ ] 관리자 계정 생성 완료
- [ ] 대시보드 접속 성공

---

## 🛠️ Step 5: 블로그 글 작성 및 확인 (10분)

### 5-1. 새 글 작성
**경로**: 글 → 새로 추가

**글 내용**:
```
제목: Docker Compose로 만든 첫 블로그

내용:
오늘 Docker Compose를 배웠습니다.

## 배운 내용
- Docker Compose 기본 개념
- 멀티 컨테이너 애플리케이션 배포
- WordPress + MySQL 구성

## 느낀 점
Docker Compose를 사용하니 복잡한 애플리케이션도 
쉽게 배포할 수 있었습니다!
```

### 5-2. 글 게시
- **게시** 버튼 클릭
- **글 보기** 클릭하여 확인

### 5-3. 블로그 방문
```
http://localhost:8080
```
- 메인 페이지에서 작성한 글 확인

**✅ 체크포인트**:
- [ ] 글 작성 완료
- [ ] 글 게시 성공
- [ ] 블로그에서 글 확인

---

## 🛠️ Step 6: 데이터 영속성 테스트 (5분)

### 6-1. 컨테이너 중지
```bash
# 서비스 중지
docker-compose down

# 예상 출력:
# Stopping wordpress-app ... done
# Stopping wordpress-db  ... done
# Removing wordpress-app ... done
# Removing wordpress-db  ... done
# Removing network day1_wordpress-network
```

**💡 주의**: `down`은 컨테이너만 삭제, 볼륨은 유지

### 6-2. 서비스 재시작
```bash
# 다시 시작
docker-compose up -d

# 상태 확인
docker-compose ps
```

### 6-3. 데이터 확인
```
http://localhost:8080
```
- 이전에 작성한 글이 그대로 남아있는지 확인
- 관리자 계정으로 로그인 가능한지 확인

**✅ 체크포인트**:
- [ ] 컨테이너 재시작 성공
- [ ] 작성한 글 유지 확인
- [ ] 계정 정보 유지 확인

**💡 왜 데이터가 유지될까?**
```yaml
volumes:
  - wordpress_data:/var/www/html  # WordPress 파일
  - mysql_data:/var/lib/mysql     # MySQL 데이터
```
→ Named Volume이 데이터를 영속적으로 저장!

---

## 🔍 추가 실습 (선택 사항)

### 실습 1: 환경 변수 변경
```bash
# docker-compose.yml 수정
# 데이터베이스 이름 변경
MYSQL_DATABASE: myblog  # wordpress → myblog

# 재배포
docker-compose down -v  # 볼륨까지 삭제
docker-compose up -d
```

### 실습 2: 포트 변경
```yaml
# docker-compose.yml 수정
ports:
  - "9090:80"  # 8080 → 9090

# 재배포
docker-compose down
docker-compose up -d

# 접속
http://localhost:9090
```

### 실습 3: MySQL 데이터 직접 확인
```bash
# MySQL 컨테이너 접속
docker exec -it wordpress-db mysql -u wordpress -pwordpress123

# MySQL 명령어
mysql> SHOW DATABASES;
mysql> USE wordpress;
mysql> SHOW TABLES;
mysql> SELECT * FROM wp_posts;
mysql> exit;
```

---

## 🧹 실습 정리

### 방법 1: 컨테이너만 삭제 (데이터 유지)
```bash
docker-compose down
```
- 컨테이너 삭제
- 네트워크 삭제
- 볼륨 유지 (데이터 보존)

### 방법 2: 완전 삭제 (데이터 포함)
```bash
docker-compose down -v
```
- 컨테이너 삭제
- 네트워크 삭제
- 볼륨 삭제 (⚠️ 모든 데이터 삭제)

### 방법 3: 이미지까지 삭제
```bash
docker-compose down -v --rmi all
```
- 위 내용 + Docker 이미지까지 삭제

**💡 권장**: 내일 실습을 위해 **방법 1**로 정리
```bash
docker-compose down
```

---

## 🔍 트러블슈팅

### 문제 1: 포트 충돌
**증상**:
```
Error: Bind for 0.0.0.0:8080 failed: port is already allocated
```

**원인**: 8080 포트를 다른 프로그램이 사용 중

**해결 방법 1**: 다른 포트 사용
```yaml
# docker-compose.yml 수정
ports:
  - "9090:80"  # 8080 → 9090
```

**해결 방법 2**: 기존 프로세스 종료
```bash
# 8080 포트 사용 중인 프로세스 확인
lsof -i :8080  # macOS/Linux
netstat -ano | findstr :8080  # Windows

# 프로세스 종료 후 재시도
```

### 문제 2: MySQL 연결 실패
**증상**:
```
Error establishing a database connection
```

**원인**: MySQL이 완전히 시작되기 전에 WordPress가 연결 시도

**해결**:
```bash
# 잠시 기다린 후 WordPress 재시작
sleep 30
docker-compose restart wordpress

# 또는 로그 확인
docker-compose logs mysql
# "ready for connections" 메시지 확인
```

### 문제 3: 브라우저 접속 안 됨
**증상**: `localhost:8080`에 접속되지 않음

**체크리스트**:
```bash
# 1. 컨테이너 상태 확인
docker-compose ps
# State가 Up인지 확인

# 2. 포트 매핑 확인
docker-compose ps
# 0.0.0.0:8080->80/tcp 확인

# 3. 로그 확인
docker-compose logs wordpress
# 에러 메시지 확인

# 4. 방화벽 확인
# 로컬 방화벽이 8080 포트를 차단하는지 확인
```

### 문제 4: 볼륨 권한 문제
**증상**:
```
Permission denied
```

**해결**:
```bash
# 볼륨 삭제 후 재생성
docker-compose down -v
docker-compose up -d

# 또는 권한 변경 (Linux)
sudo chown -R $USER:$USER wordpress_data
```

---

## ✅ 최종 체크리스트

### 필수 완료 항목
- [ ] Docker Compose 파일 작성
- [ ] 서비스 정상 시작 (Up 상태)
- [ ] WordPress 초기 설정 완료
- [ ] 블로그 글 작성 및 확인
- [ ] 데이터 영속성 테스트 완료
- [ ] 서비스 정리 (down)

### 이해도 체크
- [ ] Docker Compose 파일 구조 이해
- [ ] 서비스 간 통신 방식 이해 (DNS)
- [ ] 볼륨의 역할 이해 (데이터 영속성)
- [ ] 환경 변수 사용법 이해

### 심화 학습 (선택)
- [ ] 환경 변수 변경 실습
- [ ] 포트 변경 실습
- [ ] MySQL 직접 접속 실습

---

## 💡 Lab 회고

### 개인 회고 (5분)
1. **가장 쉬웠던 부분**:
2. **가장 어려웠던 부분**:
3. **새로 알게 된 점**:
4. **실무 적용 아이디어**:

### 다음 Lab 준비
**내일 (Day 2)**: 확장성 문제 체험
- 오늘 만든 WordPress 환경 유지
- `docker-compose scale` 명령어 미리 읽어보기
- 로드밸런싱 개념 간단히 검색

---

## 📚 참고 자료

### 공식 문서
- [Docker Compose 공식 문서](https://docs.docker.com/compose/)
- [WordPress Docker Hub](https://hub.docker.com/_/wordpress)
- [MySQL Docker Hub](https://hub.docker.com/_/mysql)

### 추가 학습
- [Docker Compose 네트워킹](https://docs.docker.com/compose/networking/)
- [Docker Volumes 가이드](https://docs.docker.com/storage/volumes/)
- [WordPress 설정 가이드](https://wordpress.org/support/article/how-to-install-wordpress/)

---

<div align="center">

**✅ Lab 완료** • **🎉 첫 블로그 배포 성공** • **🚀 내일은 확장성 도전**

*Docker Compose의 강점을 체험했습니다. 내일은 한계를 경험합니다!*

</div>
