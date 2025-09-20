# Week 1 Day 2 Session 4: Docker 기초 실습

<div align="center">

**🛠️ Docker 첫 실습** • **컨테이너 생명주기 체험**

*이론에서 실습으로, Docker의 실제 동작 확인*

</div>

---

## 🕘 세션 정보

**시간**: 13:00-15:00 (120분)  
**목표**: Docker 설치부터 기본 사용법까지 완전 습득  
**방식**: 단계별 실습 + 페어 프로그래밍 + 문제 해결

---

## 🎯 실습 목표

### 📚 학습 목표
- **기본 목표**: Docker 설치 및 기본 명령어 완전 습득
- **응용 목표**: 컨테이너 생명주기 직접 체험 및 관리
- **협업 목표**: 페어 프로그래밍을 통한 상호 학습 및 문제 해결

---

## 🚀 Phase 1: Docker 설치 & 환경 확인 (30분)

### 💾 Docker Desktop 설치

#### 📥 운영체제별 다운로드

**🪟 Windows**
- **다운로드**: [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/)
- **요구사항**: Windows 10 64-bit 또는 Windows 11
- **설치**: 다운로드 후 실행하여 기본 설정으로 설치

**🍎 macOS**
- **다운로드**: [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/)
- **Intel/Apple Silicon 자동 감지**
- **설치**: DMG 파일 다운로드 후 Applications 폴더로 드래그

**🐧 Linux**
- **다운로드**: [Docker Desktop for Linux](https://www.docker.com/products/docker-desktop/)
- **또는 패키지 매니저로 Docker Engine 설치**

#### 🔧 설치 후 확인
**Step 1: Docker 설치 확인**
```bash
# Docker 버전 확인
docker --version

# Docker 정보 확인
docker info
```

**Step 2: Hello World 실행**
```bash
# 첫 번째 컨테이너 실행
docker run hello-world

# 실행 결과 분석
docker ps -a
docker images
```

**Step 3: 기본 이미지 다운로드**
```bash
# 실습용 이미지들 다운로드
docker pull nginx:alpine
docker pull ubuntu:20.04
docker pull python:3.9-slim

# 이미지 목록 확인
docker images
```

**🔍 Docker 이미지 검색**
- **Docker Hub**: [https://hub.docker.com](https://hub.docker.com) - 공식 이미지 저장소
- **이미지 검색**: `docker search 이미지명` 또는 웹에서 직접 검색
- **인기 이미지**: nginx, ubuntu, python, node, mysql, postgres, redis 등

### ✅ Phase 1 체크포인트
- [ ] 운영체제에 맞는 Docker 설치 완료
- [ ] Docker 정상 설치 및 실행 확인
- [ ] hello-world 컨테이너 성공적 실행
- [ ] 기본 이미지들 다운로드 완료
- [ ] docker images, docker ps 명령어 이해

---

## 🌟 Phase 2: 컨테이너 생명주기 실습 (45분)

### 🔄 생명주기 단계별 체험
**Step 1: 컨테이너 생성 및 시작**
```bash
# 컨테이너 생성 (실행하지 않음)
docker create --name lifecycle-demo ubuntu:20.04 sleep 300

# 컨테이너 상태 확인
docker ps -a

# 컨테이너 시작
docker start lifecycle-demo

# 실행 중인 컨테이너 확인
docker ps
```

**Step 2: 컨테이너 제어**
```bash
# 컨테이너 일시정지
docker pause lifecycle-demo
docker ps

# 컨테이너 재개
docker unpause lifecycle-demo
docker ps

# 컨테이너 정지
docker stop lifecycle-demo
docker ps -a
```

**Step 3: 인터랙티브 컨테이너**
```bash
# Ubuntu 컨테이너에 접속
docker run -it --name interactive-demo ubuntu:20.04 bash

# 컨테이너 내부에서 작업
apt update
apt install -y curl vim
echo "Hello Docker!" > /tmp/test.txt
cat /tmp/test.txt
exit

# 변경사항을 새 이미지로 저장
docker commit interactive-demo my-ubuntu:v1
docker images | grep my-ubuntu
```

### ✅ Phase 2 체크포인트
- [ ] 컨테이너 생명주기 모든 단계 체험
- [ ] create, start, pause, unpause, stop 명령어 이해
- [ ] 인터랙티브 모드로 컨테이너 접속 성공
- [ ] 컨테이너 변경사항을 이미지로 저장

---

## 🏆 Phase 3: 웹 서버 실습 (30분)

### 🌐 Nginx 웹 서버 실행
**Step 1: 기본 웹 서버**
```bash
# Nginx 웹 서버 실행
docker run -d -p 8080:80 --name web-server nginx:alpine

# 컨테이너 상태 확인
docker ps
docker logs web-server

# 브라우저에서 localhost:8080 접속 확인
```

**Step 2: 커스텀 HTML 페이지**
```bash
# 로컬에 HTML 파일 생성
mkdir -p ~/docker-practice
cd ~/docker-practice
echo "<h1>My First Docker Web Server</h1><p>Hello from container!</p>" > index.html

# 볼륨 마운트로 커스텀 페이지 서빙
docker run -d -p 8081:80 -v $(pwd):/usr/share/nginx/html --name custom-web nginx:alpine

# 브라우저에서 localhost:8081 접속 확인
```

**Step 3: 컨테이너 관리**
```bash
# 실행 중인 컨테이너 확인
docker ps

# 컨테이너 로그 확인
docker logs web-server
docker logs custom-web

# 컨테이너 정리
docker stop web-server custom-web
docker rm web-server custom-web
```

### ✅ Phase 3 체크포인트
- [ ] Nginx 웹 서버 컨테이너 실행 성공
- [ ] 포트 매핑 (-p) 옵션 이해
- [ ] 볼륨 마운트 (-v) 옵션 이해
- [ ] 브라우저에서 웹 페이지 접속 확인

---

## 🎯 Phase 4: 초보자 종합 실습 (15분)

### 📝 기본 미션
**미션**: 간단한 Python 웹 애플리케이션 실행

```bash
# Python 웹 서버 실행
docker run -d -p 8000:8000 --name python-web python:3.9-slim python -m http.server 8000

# 컨테이너 접속해서 파일 생성
docker exec -it python-web bash
echo "<h1>Python Web Server</h1>" > index.html
exit

# 브라우저에서 localhost:8000 접속 확인
```

### ✅ 기본 미션 체크포인트
- [ ] Python 컨테이너로 웹 서버 실행
- [ ] docker exec 명령어로 컨테이너 접속
- [ ] 컨테이너 내부에서 파일 생성
- [ ] 웹 브라우저에서 결과 확인

---

## 🚀 숙련자 추가 미션 (20분)

### 🔥 고급 미션
**미션 1: 멀티 컨테이너 네트워킹**
```bash
# 커스텀 네트워크 생성
docker network create my-network

# 데이터베이스 컨테이너 실행
docker run -d --name db --network my-network -e POSTGRES_PASSWORD=password postgres:13-alpine

# 웹 애플리케이션 컨테이너 실행 (DB 연결)
docker run -d --name app --network my-network -p 8080:80 nginx:alpine

# 네트워크 연결 테스트
docker exec app ping db
```

**미션 2: 데이터 영속성**
```bash
# 볼륨 생성
docker volume create my-data

# 볼륨을 사용하는 컨테이너 실행
docker run -it --name data-test -v my-data:/data ubuntu:20.04 bash
echo "Persistent data" > /data/test.txt
exit

# 새 컨테이너에서 동일 볼륨 사용
docker run -it --name data-test2 -v my-data:/data ubuntu:20.04 bash
cat /data/test.txt  # 데이터 확인
exit
```

**미션 3: 리소스 제한**
```bash
# CPU와 메모리 제한
docker run -d --name limited-container --cpus="0.5" --memory="128m" nginx:alpine

# 리소스 사용량 모니터링
docker stats limited-container
```

### ✅ 고급 미션 체크포인트
- [ ] 커스텀 네트워크 생성 및 컨테이너 연결
- [ ] 컨테이너 간 네트워크 통신 확인
- [ ] Docker 볼륨을 통한 데이터 영속성 구현
- [ ] 컨테이너 리소스 제한 설정

---

## 🔧 기본 트러블슈팅

### 자주 발생하는 문제들

1. **Docker Desktop 시작 안됨**
   - Windows: 재시작 후 Docker Desktop 실행
   - macOS: Applications에서 Docker 실행
   - 시스템 트레이에서 Docker 아이콘 확인

2. **포트 충돌 오류**
   ```bash
   # 사용 중인 포트 확인
   docker ps
   # 다른 포트 사용 (8080 대신 8081)
   docker run -p 8081:80 nginx:alpine
   ```

3. **컨테이너 실행 안됨**
   ```bash
   # 컨테이너 로그 확인
   docker logs 컨테이너명
   # 컨테이너 삭제 후 재시도
   docker rm -f 컨테이너명
   ```

### 유용한 정리 명령어
```bash
# 모든 컨테이너 정지 및 삭제
docker stop $(docker ps -q)
docker rm $(docker ps -aq)

# 사용하지 않는 이미지 정리
docker system prune
```

---

## 📝 실습 마무리

### ✅ 오늘 실습 성과
- [ ] Docker 기본 명령어 완전 습득
- [ ] 컨테이너 생명주기 직접 체험
- [ ] 웹 서버 컨테이너 실행 및 관리
- [ ] 페어 프로그래밍을 통한 문제 해결 경험

### 🎯 내일 실습 준비
- **주제**: Dockerfile 작성 및 이미지 빌드
- **준비사항**: 
  - 오늘 배운 기본 명령어 복습
  - 텍스트 에디터 (VS Code, Vim 등) 사용법 확인
  - Git 기본 명령어 숙지 (선택사항)
- **연결고리**: 기존 이미지 사용 → 커스텀 이미지 제작
- **추가 도구**: 내일 실습을 위한 에디터 및 Git 설치 권장

---

<div align="center">

**🛠️ Docker 기초 실습을 완벽하게 완주했습니다**

*이론에서 실습으로, Docker 실전 경험 완료*

**설치 가이드**: [Docker 공식 문서](https://docs.docker.com/get-docker/) | **다음**: [Day 3 - Docker 이미지 & 네트워킹 & 스토리지](../day3/README.md)

</div>