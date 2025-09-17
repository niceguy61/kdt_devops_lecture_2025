# Session 8: 이론 종합 및 토론

## 📍 교과과정에서의 위치
이 세션은 **Week 1 > Day 2**의 마지막 세션으로, 컨테이너 기술의 핵심 개념들을 종합적으로 정리하고 산업 동향과 미래 전망을 분석합니다. 그룹 토론을 통해 컨테이너 기술의 영향과 전망을 논의합니다.

## 학습 목표 (5분)
- 컨테이너 기술 **핵심 개념 종합 정리**
- **산업 동향**과 **미래 전망** 분석
- 그룹 토론: 컨테이너 기술의 영향과 전망

## 1. 컨테이너 기술 핵심 개념 정리 (15분)

### 컨테이너 기술의 본질
**컨테이너 기술**은 **애플리케이션 배포와 실행의 패러다임을 근본적으로 변화**시켰습니다.

#### 기술적 혁신의 핵심
컨테이너가 가져온 근본적 변화:

1. **가상화의 진화**
   - 하드웨어 가상화 → OS 가상화 → 애플리케이션 가상화
   - 무거운 하이퍼바이저 → 경량 컨테이너 런타임
   - 분 단위 시작 시간 → 초 단위 시작 시간

2. **개발 워크플로우의 혁신**
   - "Works on my machine" 문제 해결
   - 개발/테스트/운영 환경 일치
   - 인프라스트럭처 자동화

3. **마이크로서비스 아키텍처 지원**
   - 모놀리스 → 마이크로서비스 전환 촉진
   - 서비스별 독립적 배포와 확장
   - 기술 스택 다양성 지원

#### 이론적 기초의 중요성
컨테이너 기술을 제대로 활용하기 위해서는:
- **Linux 커널 기능** 이해 (Namespaces, Cgroups)
- **네트워킹 개념** 이해 (Bridge, Overlay, Host)
- **스토리지 시스템** 이해 (Union FS, Volumes)
- **보안 모델** 이해 (Isolation, Least Privilege)

### 권한 설정 확인
Docker 명령어 실행 권한 점검:

#### Windows/Mac (Docker Desktop)
- Docker Desktop이 실행 중인지 확인
- 시스템 트레이에서 Docker 아이콘 상태 확인
- 필요시 관리자 권한으로 재시작

#### Linux
```bash
# Docker 그룹에 사용자 추가 확인
groups $USER

# Docker 서비스 상태 확인
sudo systemctl status docker

# 필요시 Docker 서비스 시작
sudo systemctl start docker
```

### 네트워크 연결 테스트
Docker Hub 연결 및 이미지 다운로드 테스트:

```bash
# Hello World 컨테이너 실행
docker run hello-world

# 간단한 이미지 다운로드 테스트
docker pull alpine:latest

# 다운로드된 이미지 확인
docker images
```

## 2. 기본 명령어 미리보기 (20분)

### 이미지 관련 명령어
내일 실습에서 사용할 핵심 명령어들:

```bash
# 이미지 검색
docker search nginx

# 이미지 다운로드
docker pull nginx:alpine

# 로컬 이미지 목록
docker images

# 이미지 상세 정보
docker inspect nginx:alpine

# 이미지 히스토리 (레이어 확인)
docker history nginx:alpine
```

### 컨테이너 관련 명령어
컨테이너 라이프사이클 관리 명령어들:

```bash
# 컨테이너 실행 (포그라운드)
docker run nginx:alpine

# 컨테이너 실행 (백그라운드)
docker run -d --name my-nginx nginx:alpine

# 실행 중인 컨테이너 목록
docker ps

# 모든 컨테이너 목록
docker ps -a

# 컨테이너 중지
docker stop my-nginx

# 컨테이너 시작
docker start my-nginx

# 컨테이너 제거
docker rm my-nginx
```

### 실용적인 옵션들
자주 사용되는 유용한 옵션들:

```bash
# 포트 매핑
docker run -d -p 8080:80 --name web nginx:alpine

# 환경 변수 설정
docker run -d -e ENV=production --name app node:alpine

# 볼륨 마운트
docker run -d -v /host/path:/container/path --name data alpine

# 컨테이너 내부 접속
docker exec -it my-nginx /bin/sh

# 컨테이너 로그 확인
docker logs my-nginx

# 실시간 로그 모니터링
docker logs -f my-nginx
```

## 3. 문제 해결 가이드 (10분)

### 일반적인 문제들과 해결책
실습 중 자주 발생하는 문제들:

#### 1. Docker Daemon 연결 오류
```bash
# 오류: Cannot connect to the Docker daemon
# 해결: Docker 서비스 시작
sudo systemctl start docker  # Linux
# 또는 Docker Desktop 재시작 (Windows/Mac)
```

#### 2. 권한 거부 오류
```bash
# 오류: permission denied while trying to connect
# 해결: 사용자를 docker 그룹에 추가 (Linux)
sudo usermod -aG docker $USER
# 로그아웃 후 다시 로그인
```

#### 3. 포트 충돌 오류
```bash
# 오류: port is already allocated
# 해결: 다른 포트 사용 또는 기존 컨테이너 중지
docker ps  # 실행 중인 컨테이너 확인
docker stop <container_name>  # 충돌하는 컨테이너 중지
```

#### 4. 디스크 공간 부족
```bash
# 디스크 사용량 확인
docker system df

# 사용하지 않는 리소스 정리
docker system prune

# 모든 미사용 리소스 정리 (주의!)
docker system prune -a
```

### 유용한 디버깅 명령어
문제 진단을 위한 명령어들:

```bash
# Docker 시스템 이벤트 모니터링
docker events

# 컨테이너 리소스 사용량 확인
docker stats

# 컨테이너 프로세스 확인
docker top <container_name>

# 컨테이너 파일 시스템 변경사항 확인
docker diff <container_name>
```

## 4. 2일차 학습 내용 정리 (10분)

### 핵심 개념 복습
오늘 학습한 주요 내용들:

#### 컨테이너 기술의 이해
- 컨테이너의 정의: 애플리케이션과 실행 환경을 패키지화
- 핵심 특징: 격리성, 이식성, 경량성, 확장성
- 해결하는 문제: 환경 불일치, 의존성 충돌, 배포 복잡성

#### 가상머신 vs 컨테이너
- 아키텍처 차이: 하이퍼바이저 vs 컨테이너 런타임
- 성능 비교: 시작 시간, 리소스 사용량, 오버헤드
- 사용 사례: 각각의 적합한 상황과 하이브리드 접근

#### Docker 아키텍처
- 클라이언트-서버 모델: Docker CLI, Docker Daemon, REST API
- 핵심 구성 요소: Images, Containers, Networks, Volumes
- 런타임 계층: containerd, runc, OCI 표준

#### 이미지와 컨테이너
- 관계: 이미지(템플릿) → 컨테이너(인스턴스)
- 레이어 구조: Union File System, 레이어 공유
- 레지스트리: Docker Hub, 프라이빗 레지스트리

#### 컨테이너 라이프사이클
- 상태 전환: Created → Running → Stopped → Removed
- 관리 명령어: create, start, stop, pause, kill, rm
- 네임스페이스: PID, NET, MNT, UTS, IPC, USER

#### 오케스트레이션
- 필요성: 단일 컨테이너의 한계 극복
- 주요 기능: 자동 스케일링, 자동 복구, 서비스 디스커버리
- Kubernetes: 업계 표준 오케스트레이션 플랫폼

#### 컨테이너 보안
- 보안 위협: 취약한 이미지, 권한 상승, 컨테이너 탈출
- 보안 원칙: 최소 권한, 최소 이미지, 취약점 스캔
- 모범 사례: 비루트 실행, 읽기 전용 파일 시스템

## 5. 질의응답 및 토론 (10분)

### 자주 묻는 질문들

#### Q1: 컨테이너와 가상머신 중 어떤 것을 선택해야 하나요?
A: 상황에 따라 다릅니다:
- 컨테이너: 마이크로서비스, 빠른 배포, 클라우드 네이티브
- 가상머신: 강한 격리, 다른 OS, 레거시 애플리케이션
- 하이브리드: 실제로는 두 기술을 함께 사용하는 경우가 많음

#### Q2: Docker 이미지가 너무 큰데 어떻게 줄일 수 있나요?
A: 다음 방법들을 시도해보세요:
- Alpine Linux 기반 이미지 사용
- 멀티 스테이지 빌드 활용
- 불필요한 패키지 설치 금지
- .dockerignore 파일 활용

#### Q3: 프로덕션에서 컨테이너 보안을 어떻게 관리하나요?
A: 다층 보안 전략이 필요합니다:
- 정기적인 취약점 스캔
- 최소 권한 원칙 적용
- 네트워크 정책 구현
- 런타임 보안 모니터링

### 오픈 토론
- 컨테이너 기술에 대한 추가 궁금한 점
- 실제 업무에서의 적용 가능성
- 내일 실습에 대한 기대와 우려

## 내일 준비사항

### 사전 학습
- Docker 공식 문서의 "Get Started" 섹션 읽기
- 기본 Linux 명령어 복습 (ls, cd, cat, grep 등)

### 실습 준비
- Docker Desktop 정상 동작 확인
- 터미널/명령 프롬프트 사용법 숙지
- 텍스트 에디터 준비 (VS Code, nano, vim 등)

### 환경 점검
- 인터넷 연결 상태 확인
- 디스크 여유 공간 확인 (최소 5GB)
- 방화벽 설정 확인

## 2일차 완료! 🎉
내일부터는 Docker 명령어를 직접 사용하여 컨테이너를 생성, 실행, 관리하는 실습을 시작합니다. 오늘 배운 이론적 기초를 바탕으로 실제 기술을 체험해보겠습니다.

## 📚 참고 자료
- [Docker Get Started Guide](https://docs.docker.com/get-started/)
- [Docker Command Line Reference](https://docs.docker.com/engine/reference/commandline/docker/)
- [Docker Best Practices](https://docs.docker.com/develop/best-practices/)
- [Container Security Checklist](https://kubernetes.io/docs/concepts/security/)
- [Docker Troubleshooting Guide](https://docs.docker.com/desktop/troubleshoot/overview/)