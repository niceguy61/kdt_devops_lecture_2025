# Week 1 Day 2 Session 5: Docker 개발 워크플로우와 디버깅

<div align="center">
**🔧 개발 워크플로우** • **🐛 디버깅 기법**
*실무에서 바로 사용하는 Docker 개발 패턴*
</div>

---

## 🕘 세션 정보
**시간**: 14:00-14:50 (50분)
**목표**: Docker 개발 워크플로우와 문제 해결 기법 습득
**방식**: 실습 중심 + 페어 프로그래밍 + 문제 해결

## 🎯 세션 목표
### 📚 학습 목표
- **이해 목표**: Docker 개발 워크플로우와 일반적인 개발 패턴 이해
- **적용 목표**: 컨테이너 디버깅과 문제 해결 기법 실습
- **협업 목표**: 팀원들과 개발 경험 공유 및 베스트 프랙티스 토론

### 🤔 왜 필요한가? (5분)

**현실 개발 상황**:
- 💼 **실무 시나리오**: 로컬에서는 잘 되던 앱이 컨테이너에서 안 되는 상황
- 🏠 **일상 비유**: 집에서는 잘 되던 요리가 다른 주방에서 실패하는 것
- 📊 **시장 동향**: 컨테이너 기반 개발이 표준이 되면서 디버깅 스킬 필수화

**학습 전후 비교**:
```mermaid
graph LR
    A[학습 전<br/>시행착오 반복] --> B[학습 후<br/>체계적 개발]
    
    style A fill:#ffebee
    style B fill:#e8f5e8
```

## 🛠️ 실습 중심 학습 (35분)

### 🚀 실습 1: 개발 워크플로우 체험 (12분)
> **목표**: 실제 개발 환경처럼 컨테이너를 사용해보기

#### 📋 실습 준비 (1분)
**개인 실습**: 각자 자신의 환경에서 진행
**목표**: 여러 개의 다른 웹서버 컨테이너 동시 실행

#### 🔧 Step 1: 첫 번째 개발 서버 (4분)
```bash
# 1. 첫 번째 프로젝트 디렉토리
mkdir project-1
cd project-1
echo '<h1>Project 1 - Main Site</h1><p>포트 8080</p>' > index.html

# 2. 첫 번째 웹서버 실행
docker run -d -p 8080:80 -v $(pwd):/usr/share/nginx/html --name project-1 nginx

# 3. 브라우저에서 localhost:8080 확인
```

#### ⚡ Step 2: 두 번째 개발 서버 (4분)
```bash
# 1. 두 번째 프로젝트 (다른 디렉토리)
cd ..
mkdir project-2
cd project-2
echo '<h1>Project 2 - Admin Panel</h1><p>포트 8081</p>' > index.html

# 2. 두 번째 웹서버 실행 (다른 포트)
docker run -d -p 8081:80 -v $(pwd):/usr/share/nginx/html --name project-2 nginx

# 3. 브라우저에서 localhost:8081 확인
```

#### 🎯 Step 3: 실시간 변경 테스트 (3분)
```bash
# 1. 두 프로젝트 동시에 수정해보기
echo '<h1>Updated Project 1</h1><p>실시간 반영 테스트</p>' > ../project-1/index.html
echo '<h1>Updated Project 2</h1><p>동시 개발 환경</p>' > index.html

# 2. 두 브라우저 탭에서 각각 새로고침하여 즉시 반영 확인
# 3. 여러 번 수정하며 독립적인 개발 환경 체험
```

**💡 실습 포인트**:
- 여러 프로젝트를 동시에 개발하는 환경 구축
- 각 컨테이너가 독립적으로 동작하는 것 확인
- 볼륨 마운트로 실시간 반영되는 개발 패턴 이해

### 🐛 실습 2: 디버깅 도구 마스터하기 (12분)
> **목표**: 컨테이너 문제 해결을 위한 필수 명령어 체험

#### 🔍 Step 1: 로그 확인 실습 (4분)
```bash
# 1. 두 컨테이너의 로그 비교해보기
docker logs project-1
docker logs project-2

# 2. 실시간 로그 모니터링 (새 터미널에서)
docker logs -f project-1

# 3. 다른 터미널에서 브라우저 접속하며 로그 변화 관찰
# 4. Ctrl+C로 실시간 로그 종료
```

#### 🔧 Step 2: 컨테이너 내부 탐험 (4분)
```bash
# 1. 첫 번째 컨테이너 내부 접속
docker exec -it project-1 bash
ls -la /usr/share/nginx/html/  # 마운트된 파일 확인
ps aux                         # 실행 중인 프로세스
exit

# 2. 두 번째 컨테이너도 확인
docker exec -it project-2 bash
cat /etc/nginx/nginx.conf      # nginx 설정 파일
whoami                         # 현재 사용자 확인
exit
```

#### 📊 Step 3: 상태 모니터링 (4분)
```bash
# 1. 두 컨테이너 상세 정보 비교
docker inspect project-1 | grep -i "ipaddress\|port"
docker inspect project-2 | grep -i "ipaddress\|port"

# 2. 리소스 사용량 실시간 모니터링
docker stats project-1 project-2
# (몇 초 관찰 후 Ctrl+C로 종료)

# 3. 모든 컨테이너 상태 한눈에 보기
docker ps -a
```

**💡 개인 미션**: 각자 다른 명령어 조합을 시도해보고 차이점 발견하기

### 🚨 실습 3: 문제 해결 챌린지 (11분)
> **목표**: 의도적으로 문제를 만들고 해결해보는 실전 연습

#### 🎯 챌린지 1: 포트 충돌 해결 (3분)
```bash
# 1. 같은 포트로 세 번째 컨테이너 실행 (의도적 에러)
docker run -d -p 8080:80 --name project-3 nginx
# → 에러 발생!

# 2. 문제 진단하기
docker ps -a  # 컨테이너 상태 확인
docker logs project-3  # 에러 로그 확인

# 3. 해결하기
docker rm project-3  # 실패한 컨테이너 삭제
docker run -d -p 8082:80 --name project-3 nginx  # 다른 포트로 실행
```

#### 🎯 챌린지 2: 컨테이너 내부 파일 수정 (3분)
```bash
# 1. 볼륨 마운트 없는 컨테이너에서 파일 수정
docker exec -it project-3 bash
echo '<h1>Modified inside container</h1>' > /usr/share/nginx/html/index.html
exit

# 2. 브라우저에서 localhost:8082 확인
# 3. 컨테이너 재시작 후 변경사항 확인
docker restart project-3
# → 변경사항이 사라짐을 확인 (볼륨 마운트 없음)
```

#### 🎯 챌린지 3: 개인 트러블슈팅 미션 (5분)
**각자 다른 미션을 순서대로 해결해보기**:

```bash
# 미션 1: 메모리 사용량이 가장 높은 컨테이너 찾기
docker stats --no-stream

# 미션 2: 모든 컨테이너의 IP 주소 찾기
docker inspect project-1 project-2 project-3 | grep IPAddress

# 미션 3: 각 컨테이너 내부 프로세스 개수 세기
docker exec project-1 ps aux | wc -l
docker exec project-2 ps aux | wc -l
docker exec project-3 ps aux | wc -l

# 미션 4: 컨테이너 생성 시간 순서로 정렬
docker ps --format "table {{.Names}}\t{{.CreatedAt}}" | sort

# 미션 5: 모든 컨테이너의 포트 매핑 확인
docker port project-1
docker port project-2
docker port project-3
```

**🏆 개인 성과**: 5개 미션 중 몇 개를 성공했는지 스스로 체크

## 🤝 실습 결과 공유 및 정리 (10분)

### 🎤 개인 성과 발표 (7분)
**자유 발표** (원하는 사람만 1-2분씩):
1. **가장 인상적이었던 발견**: "실습하면서 가장 놀랐던 점은?"
2. **유용한 명령어**: "가장 유용하다고 생각하는 명령어는?"
3. **해결한 문제**: "챌린지에서 어떤 문제를 어떻게 해결했나요?"
4. **실무 적용 아이디어**: "실제 개발에 어떻게 활용할 수 있을까요?"

**발표 가이드**:
- 👥 **경험 중심**: 실제 해본 것 위주로 공유
- 🔄 **명령어 시연**: 유용했던 명령어 직접 보여주기
- 📝 **개인 노하우**: 혼자 발견한 팁이나 트릭 공유

### 🧹 정리 및 다음 준비 (3분)
```bash
# 실습 환경 정리
docker stop project-1 project-2 project-3
docker rm project-1 project-2 project-3
cd .. && rm -rf project-1 project-2

# 다음 실습을 위한 확인
docker ps  # 깨끗한 상태 확인
docker images  # 사용 가능한 이미지 확인
```

**🎯 다음 실습 예고**: 오후에는 더 복잡한 애플리케이션으로 실습 예정

### 💡 실습 체크 질문
- ✅ "여러 개의 독립적인 개발 환경을 동시에 구축해보셨나요?"
- ✅ "컨테이너에 문제가 생겼을 때 어떤 명령어부터 사용하시겠어요?"
- ✅ "5개 챌린지 미션 중 몇 개를 성공적으로 완료하셨나요?"

## 🔑 핵심 키워드

### 🆕 새로운 용어
- **핫 리로드(Hot Reload)**: 코드 변경 시 자동으로 애플리케이션 재시작
- **볼륨 마운트(Volume Mount)**: 호스트와 컨테이너 간 파일 시스템 공유
- **컨테이너 디버깅(Container Debugging)**: 컨테이너 환경에서의 문제 해결 과정
- **개발 컨테이너(Dev Container)**: 개발 환경에 최적화된 컨테이너 설정

### 🔤 기술 용어
- **docker logs**: 컨테이너의 표준 출력과 에러 로그 확인
- **docker exec**: 실행 중인 컨테이너에 명령어 실행
- **docker inspect**: 컨테이너나 이미지의 상세 정보 조회
- **docker stats**: 컨테이너의 리소스 사용량 실시간 모니터링

### 🔤 실무 용어
- **워크플로우(Workflow)**: 개발부터 배포까지의 작업 흐름
- **트러블슈팅(Troubleshooting)**: 문제 발생 시 원인 파악과 해결 과정
- **환경 일관성(Environment Consistency)**: 개발/테스트/운영 환경의 동일성
- **의존성 관리(Dependency Management)**: 라이브러리와 패키지 버전 관리

## 📝 세션 마무리
### ✅ 오늘 세션 성과
- Docker 개발 워크플로우와 일반적인 개발 패턴 이해
- 컨테이너 디버깅 도구와 문제 해결 기법 학습
- 팀별 개발 팁과 트러블슈팅 노하우 공유
- 효율적인 Docker 개발 환경 구성 방법 토론

### 🎯 다음 세션 준비
- **내일 연결**: Docker 이미지 빌드와 Dockerfile 작성
- **실습 적용**: 오후 실습에서 디버깅 기법 활용
- **심화 학습**: 고급 Docker 개발 도구 탐색

---

## 🛠️ 실습 연계 가이드

### 📋 개발 워크플로우 체크리스트 (실습용)
```bash
# 1. 여러 프로젝트 동시 개발 환경
docker run -d -p 3000:3000 -v $(pwd)/project-a:/app --name dev-a node:18-alpine
docker run -d -p 3001:3000 -v $(pwd)/project-b:/app --name dev-b node:18-alpine
docker run -d -p 3002:3000 -v $(pwd)/project-c:/app --name dev-c node:18-alpine

# 2. 모든 프로젝트 로그 모니터링
docker logs -f dev-a &
docker logs -f dev-b &
docker logs -f dev-c &

# 3. 각 컨테이너 개별 접속
docker exec -it dev-a sh
docker exec -it dev-b sh
docker exec -it dev-c sh

# 4. 전체 리소스 사용량 모니터링
docker stats dev-a dev-b dev-c

# 5. 모든 컨테이너 상태 한번에 확인
docker ps -a
```

### 🔍 디버깅 명령어 모음
```bash
# 컨테이너 상태 확인
docker ps -a  # 모든 컨테이너 상태

# 로그 확인 (다양한 옵션)
docker logs <container>           # 전체 로그
docker logs --tail 50 <container> # 마지막 50줄
docker logs -f <container>        # 실시간 로그

# 컨테이너 내부 프로세스 확인
docker exec <container> ps aux
docker exec <container> top

# 네트워크 연결 상태 확인
docker exec <container> netstat -tulpn
docker port <container>

# 파일시스템 확인
docker exec <container> df -h     # 디스크 사용량
docker exec <container> ls -la /  # 루트 디렉토리
```

### ⚠️ 실습 주의사항
- **백업**: 중요한 데이터는 볼륨 마운트로 호스트에 보관
- **포트 충돌**: 실행 전 포트 사용 여부 확인 (`netstat -tulpn | grep :3000`)
- **리소스 관리**: 불필요한 컨테이너는 정리 (`docker container prune`)
- **로그 관리**: 로그가 너무 커지지 않도록 주기적 확인

---

<div align="center">

**🔧 효율적 개발** • **🐛 체계적 디버깅** • **⚡ 생산성 향상**

*Docker를 활용한 현대적 개발 워크플로우로 개발 생산성 극대화*

</div>