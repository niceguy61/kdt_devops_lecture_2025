# Session 8: 실습 환경 구성 및 Q&A

## 📍 교과과정에서의 위치
이 세션은 **Week 1 > Day 1**의 마지막 세션으로, 이후 7주간의 실습을 위한 필수 환경을 구성합니다. Docker Desktop 설치부터 개발 환경 설정까지, 전체 과정에서 사용할 도구들을 준비하고 1일차 학습 내용을 정리합니다.

## 학습 목표 (5분)
- Docker Desktop 설치 및 설정
- 필수 계정 생성 및 설정
- 개발 환경 구성
- 1일차 학습 내용 정리 및 질의응답

## 1. Docker Desktop 설치 (15분)

### 시스템 요구사항 확인

#### Windows
- **OS**: Windows 10 64-bit Pro, Enterprise, Education (Build 19041 이상)
- **기능**: WSL 2 또는 Hyper-V 활성화
- **메모리**: 최소 4GB RAM (권장 8GB)
- **저장공간**: 최소 4GB

#### macOS
- **OS**: macOS 10.15 이상
- **하드웨어**: 2010년 이후 Mac 모델
- **메모리**: 최소 4GB RAM

#### Linux
- **배포판**: Ubuntu, Debian, CentOS, Fedora 등
- **커널**: 3.10 이상

### 설치 과정 (실습)

#### Windows 설치
```bash
# 1. WSL 2 활성화 (PowerShell 관리자 권한)
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# 2. 재부팅 후 WSL 2를 기본값으로 설정
wsl --set-default-version 2

# 3. Docker Desktop 다운로드 및 설치
# https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe
```

#### macOS 설치
```bash
# 1. Docker Desktop 다운로드
# https://desktop.docker.com/mac/main/amd64/Docker.dmg

# 2. 설치 후 Applications 폴더로 이동
# 3. Docker Desktop 실행
```

#### 설치 확인
```bash
# Docker 버전 확인
docker --version
docker-compose --version

# Hello World 컨테이너 실행
docker run hello-world
```

### Docker Desktop 설정

#### 리소스 할당

![Docker Desktop Settings](../images/docker-desktop-settings.svg)

## 2. 필수 계정 생성 (10분)

### GitHub 계정 생성 및 설정

#### 계정 생성
1. https://github.com 접속
2. 계정 생성 (무료 계정으로 충분)
3. 이메일 인증 완료

#### Git 설정
```bash
# 사용자 정보 설정
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 기본 브랜치명 설정
git config --global init.defaultBranch main

# 설정 확인
git config --list
```

### Docker Hub 계정 생성

#### 계정 생성
1. https://hub.docker.com 접속
2. 계정 생성 (무료 계정)
3. 이메일 인증 완료

#### Docker Hub 로그인
```bash
# Docker Hub 로그인
docker login

# 로그인 확인
docker info
```

## 3. 개발 환경 구성 (10분)

### VS Code 설치 및 확장 프로그램

#### 필수 확장 프로그램
```json
{
  "recommendations": [
    "ms-vscode-remote.remote-containers",
    "ms-azuretools.vscode-docker",
    "ms-vscode.vscode-json",
    "redhat.vscode-yaml",
    "ms-vscode-remote.remote-wsl"
  ]
}
```

### 실습용 디렉토리 구성
```bash
# 실습용 디렉토리 생성
mkdir ~/devops-practice
cd ~/devops-practice

# 주차별 디렉토리 생성
mkdir week1 week2 week3 week4 week5 week6 week7

# Week 1 세부 디렉토리
cd week1
mkdir docker-basics docker-images docker-compose docker-networking
```

### 첫 번째 Docker 컨테이너 실행 (실습)
**실제 Docker를 체험**해보는 첫 번째 실습:
```bash
# Nginx 웹 서버 실행
docker run -d -p 8080:80 --name my-nginx nginx

# 컨테이너 상태 확인
docker ps

# 웹 브라우저에서 http://localhost:8080 접속 확인

# 컨테이너 로그 확인
docker logs my-nginx

# 컨테이너 정리
docker stop my-nginx
docker rm my-nginx
```

## 4. 1일차 학습 내용 정리 (10분)

### 핵심 개념 복습

#### DevOps 정의
**7주 과정의 기초가 되는 핵심 개념**:
- Development + Operations
- 협업 문화와 자동화 방법론
- CALMS 모델 (Culture, Automation, Lean, Measurement, Sharing)

#### 전통적 개발 vs DevOps
| 구분 | 전통적 방식 | DevOps 방식 |
|------|-------------|-------------|
| 배포 주기 | 몇 달-몇 년 | 일-주 단위 |
| 팀 구조 | 사일로 | 크로스 펑셔널 |
| 위험도 | 높음 | 낮음 |
| 피드백 | 늦음 | 빠름 |

#### CI/CD 파이프라인
```
코드 커밋 → 빌드 → 테스트 → 배포 → 모니터링
```

### 주요 도구 체인
- **코드 관리**: Git, GitHub
- **CI/CD**: Jenkins, GitHub Actions
- **컨테이너**: Docker, Kubernetes
- **모니터링**: Prometheus, Grafana

## 5. 질의응답 및 토론 (10분)

### 자주 묻는 질문

#### Q1: DevOps 엔지니어가 되려면 어떤 기술을 먼저 배워야 하나요?
**A**: 다음 순서를 권장합니다:
1. Linux 기초 및 Shell 스크립팅
2. Git 버전 관리
3. Docker 컨테이너 기술
4. CI/CD 도구 (Jenkins 또는 GitHub Actions)
5. 클라우드 플랫폼 (AWS, Azure, GCP 중 하나)
6. Kubernetes 오케스트레이션
7. Infrastructure as Code (Terraform)

#### Q2: 작은 회사에서도 DevOps를 도입할 수 있나요?
**A**: 네, 가능합니다. 오히려 작은 회사가 더 빠르게 도입할 수 있습니다:
- 간단한 CI/CD 파이프라인부터 시작
- 클라우드 서비스 활용으로 초기 비용 절약
- GitHub Actions 같은 무료 도구 활용

#### Q3: DevOps와 SRE의 차이점은?
**A**: 
- **DevOps**: 개발과 운영의 협업 문화
- **SRE**: Google에서 시작된 운영 방법론, 소프트웨어 엔지니어링으로 운영 문제 해결

### 오픈 토론
- 현재 조직의 DevOps 도입 가능성
- 예상되는 장애물과 해결 방안
- 개인 학습 계획 수립

## 내일 준비사항

### 사전 학습
- Docker 공식 문서 Getting Started 섹션 읽기
- 컨테이너와 가상머신의 차이점 복습

### 실습 준비
- Docker Desktop 정상 동작 확인
- VS Code Docker 확장 프로그램 설치 확인

### 과제
현재 소속 조직의 개발/배포 프로세스를 분석하고, DevOps 도입 시 예상되는 변화를 정리해오세요 (A4 1페이지).

---

## 1일차 완료! 🎉
내일부터는 Docker를 중심으로 한 컨테이너 기술을 본격적으로 학습합니다. 오늘 배운 DevOps 개념을 바탕으로 실제 기술을 익혀보겠습니다.

## 📚 참고 자료
- [Docker Desktop 공식 다운로드](https://www.docker.com/products/docker-desktop/)
- [Git 공식 다운로드](https://git-scm.com/downloads)
- [VS Code 공식 다운로드](https://code.visualstudio.com/)
- [GitHub 가입](https://github.com/)
- [Docker Hub 가입](https://hub.docker.com/)