# Week 2 용어집 - Docker 실습 및 구현

## 📖 Week 2 핵심 용어 정리

Week 2에서 다루는 Docker 설치, 이미지 빌드, 네트워킹, 볼륨, Compose 관련 실무 용어들을 정리했습니다.

---

## 🐳 Docker 기초

### **Docker**
- **정의**: 컨테이너 기반 가상화 플랫폼
- **구성요소**: Docker Engine, Docker CLI, Docker Desktop
- **장점**: 환경 일관성, 빠른 배포, 리소스 효율성

### **Container (컨테이너)**
- **정의**: 애플리케이션과 실행 환경을 패키징한 경량 가상화 단위
- **특징**: 격리성, 이식성, 확장성
- **vs VM**: 더 가볍고 빠른 시작 시간

### **Image (이미지)**
- **정의**: 컨테이너를 실행하기 위한 읽기 전용 템플릿
- **구조**: 레이어 기반 파일시스템
- **명명**: `[registry]/[namespace]/[repository]:[tag]`

### **Docker Hub**
- **정의**: Docker의 공식 클라우드 기반 레지스트리
- **기능**: 이미지 저장, 공유, 자동 빌드
- **사용**: `docker pull`, `docker push` 명령어

---

## 🏗 Docker 설치 및 환경

### **Docker Desktop**
- **정의**: Windows/macOS용 Docker 개발 환경
- **포함**: Docker Engine, CLI, Compose, Kubernetes
- **백엔드**: WSL 2 (Windows), HyperKit (macOS)

### **WSL 2 (Windows Subsystem for Linux 2)**
- **정의**: Windows에서 Linux 커널을 실행하는 호환성 계층
- **장점**: 네이티브 Linux 성능, Docker와 완벽 통합
- **vs Hyper-V**: 더 빠른 성능과 적은 리소스 사용

### **Container Runtime**
- **containerd**: Docker의 핵심 컨테이너 런타임
- **runc**: OCI 표준 컨테이너 런타임
- **Docker Engine**: 전체 Docker 플랫폼의 핵심

---

## 📝 Dockerfile 및 이미지 빌드

### **Dockerfile**
- **정의**: Docker 이미지를 빌드하기 위한 명령어 스크립트
- **구조**: 텍스트 파일, 한 줄당 하나의 명령어
- **베스트 프랙티스**: 레이어 최소화, 캐시 활용

### **주요 Dockerfile 명령어**

#### **FROM**
- **용도**: 베이스 이미지 지정
- **예시**: `FROM node:18-alpine`
- **특징**: 모든 Dockerfile의 첫 번째 명령어

#### **RUN**
- **용도**: 이미지 빌드 시 명령어 실행
- **예시**: `RUN npm install`
- **주의**: 각 RUN은 새로운 레이어 생성

#### **COPY vs ADD**
- **COPY**: 로컬 파일을 이미지로 복사
- **ADD**: COPY + URL 다운로드 + 압축 해제
- **권장**: 단순 복사는 COPY 사용

#### **CMD vs ENTRYPOINT**
- **CMD**: 컨테이너 실행 시 기본 명령어
- **ENTRYPOINT**: 컨테이너의 고정 진입점
- **조합**: ENTRYPOINT + CMD로 유연한 실행

#### **ENV**
- **용도**: 환경 변수 설정
- **예시**: `ENV NODE_ENV=production`
- **특징**: 빌드와 런타임 모두 적용

#### **EXPOSE**
- **용도**: 컨테이너가 사용할 포트 문서화
- **예시**: `EXPOSE 3000`
- **주의**: 실제 포트 바인딩은 `docker run -p`

### **Multi-stage Build (멀티 스테이지 빌드)**
- **정의**: 하나의 Dockerfile에서 여러 단계로 이미지 빌드
- **장점**: 이미지 크기 최적화, 보안 향상
- **예시**: 빌드 단계 + 런타임 단계 분리

### **Base Image (베이스 이미지)**
- **Official Images**: Docker Hub의 공식 이미지
- **Alpine Linux**: 경량 Linux 배포판 (5MB)
- **Distroless**: Google의 최소한 런타임 이미지
- **Scratch**: 빈 이미지 (정적 바이너리용)

---

## 🌐 Docker 네트워킹

### **Network Drivers (네트워크 드라이버)**

#### **Bridge Network**
- **정의**: Docker의 기본 네트워크 드라이버
- **특징**: 컨테이너 간 격리된 통신
- **사용**: 단일 호스트 환경

#### **Host Network**
- **정의**: 호스트의 네트워크 스택 직접 사용
- **장점**: 최고 성능, 포트 매핑 불필요
- **단점**: 네트워크 격리 없음

#### **None Network**
- **정의**: 네트워크 인터페이스 없음
- **용도**: 완전한 네트워크 격리
- **사용 사례**: 보안이 중요한 배치 작업

#### **Overlay Network**
- **정의**: 멀티 호스트 컨테이너 통신
- **기술**: VXLAN 터널링
- **사용**: Docker Swarm, Kubernetes

### **Port Mapping (포트 매핑)**
- **정의**: 호스트 포트를 컨테이너 포트에 연결
- **문법**: `-p [host_port]:[container_port]`
- **예시**: `-p 8080:80` (호스트 8080 → 컨테이너 80)

### **Service Discovery (서비스 디스커버리)**
- **DNS**: 컨테이너 이름으로 자동 해석
- **예시**: `ping web-server` (같은 네트워크 내)
- **장점**: 하드코딩된 IP 주소 불필요

---

## 💾 Docker 스토리지

### **Volume Types (볼륨 타입)**

#### **Named Volume**
- **정의**: Docker가 관리하는 이름있는 볼륨
- **위치**: `/var/lib/docker/volumes/`
- **장점**: Docker가 관리, 백업 용이
- **사용**: `docker volume create mydata`

#### **Bind Mount**
- **정의**: 호스트 파일시스템을 직접 마운트
- **용도**: 개발 환경, 설정 파일 공유
- **예시**: `-v /host/path:/container/path`
- **주의**: 호스트 의존성, 보안 위험

#### **tmpfs Mount**
- **정의**: 메모리 기반 임시 파일시스템
- **특징**: 빠른 I/O, 컨테이너 종료 시 삭제
- **용도**: 임시 파일, 캐시, 민감한 데이터

### **Data Persistence (데이터 영속성)**
- **문제**: 컨테이너 삭제 시 데이터 손실
- **해결**: Volume을 통한 데이터 분리
- **전략**: 애플리케이션과 데이터 분리 설계

---

## 🎼 Docker Compose

### **Docker Compose**
- **정의**: 멀티 컨테이너 애플리케이션 정의 및 실행 도구
- **파일**: `docker-compose.yml` (YAML 형식)
- **장점**: 선언적 설정, 환경 관리, 서비스 오케스트레이션

### **YAML 구조**
```yaml
version: '3.8'
services:
  web:
    build: .
    ports:
      - "8080:80"
  db:
    image: postgres
    environment:
      POSTGRES_PASSWORD: secret
```

### **주요 Compose 명령어**
- **`docker-compose up`**: 서비스 시작
- **`docker-compose down`**: 서비스 중지 및 제거
- **`docker-compose ps`**: 서비스 상태 확인
- **`docker-compose logs`**: 로그 확인
- **`docker-compose scale`**: 서비스 확장

### **Service Dependencies (서비스 의존성)**
- **depends_on**: 시작 순서 제어
- **condition**: 헬스체크 기반 의존성
- **예시**: 데이터베이스 준비 후 웹 서버 시작

### **Environment Management (환경 관리)**
- **.env 파일**: 환경 변수 정의
- **Override 파일**: 환경별 설정 분리
- **예시**: `docker-compose.override.yml`

---

## 🔧 Docker 명령어

### **기본 명령어**
- **`docker run`**: 컨테이너 실행
- **`docker ps`**: 실행 중인 컨테이너 목록
- **`docker images`**: 이미지 목록
- **`docker pull/push`**: 이미지 다운로드/업로드

### **이미지 관리**
- **`docker build`**: 이미지 빌드
- **`docker tag`**: 이미지 태그 지정
- **`docker rmi`**: 이미지 삭제
- **`docker history`**: 이미지 레이어 히스토리

### **컨테이너 관리**
- **`docker start/stop`**: 컨테이너 시작/중지
- **`docker exec`**: 실행 중인 컨테이너에서 명령 실행
- **`docker logs`**: 컨테이너 로그 확인
- **`docker inspect`**: 상세 정보 확인

### **시스템 관리**
- **`docker system df`**: 디스크 사용량 확인
- **`docker system prune`**: 사용하지 않는 리소스 정리
- **`docker stats`**: 리소스 사용량 모니터링

---

## 🏗 아키텍처 패턴

### **3-Tier Architecture**
- **Presentation**: 웹 서버 (Nginx)
- **Application**: API 서버 (Node.js, Python)
- **Data**: 데이터베이스 (MySQL, PostgreSQL)

### **Microservices**
- **정의**: 작고 독립적인 서비스들의 집합
- **통신**: HTTP API, 메시지 큐
- **장점**: 독립적 배포, 기술 다양성, 확장성

### **API Gateway**
- **역할**: 모든 클라이언트 요청의 단일 진입점
- **기능**: 라우팅, 인증, 로드 밸런싱
- **도구**: Nginx, Kong, AWS API Gateway

---

## 🔍 모니터링 및 로깅

### **Container Monitoring**
- **docker stats**: 실시간 리소스 사용량
- **cAdvisor**: Google의 컨테이너 모니터링
- **Prometheus**: 메트릭 수집 및 저장

### **Logging**
- **Log Drivers**: json-file, syslog, fluentd
- **Centralized Logging**: ELK Stack (Elasticsearch, Logstash, Kibana)
- **Log Rotation**: 로그 파일 크기 및 개수 제한

### **Health Checks**
- **HEALTHCHECK**: Dockerfile에서 헬스체크 정의
- **목적**: 컨테이너 상태 모니터링
- **활용**: 로드 밸런서, 오케스트레이션 도구

---

## 🚀 배포 및 스케일링

### **Scaling Strategies**
- **Horizontal Scaling**: 인스턴스 수 증가
- **Vertical Scaling**: 리소스 증가
- **Auto Scaling**: 부하에 따른 자동 확장

### **Load Balancing**
- **Round Robin**: 순차적 요청 분산
- **Least Connections**: 연결 수 기반 분산
- **Health Check**: 건강한 인스턴스만 트래픽 전달

### **Deployment Patterns**
- **Rolling Update**: 점진적 업데이트
- **Blue-Green**: 두 환경 간 전환
- **Canary**: 일부 트래픽으로 테스트

---

## 🔒 보안

### **Container Security**
- **Non-root User**: 루트 권한 사용 금지
- **Read-only Filesystem**: 파일시스템 쓰기 방지
- **Resource Limits**: CPU, 메모리 제한
- **Network Segmentation**: 네트워크 격리

### **Image Security**
- **Vulnerability Scanning**: 취약점 스캔
- **Minimal Base Images**: 최소한의 베이스 이미지
- **Multi-stage Builds**: 불필요한 도구 제거
- **Image Signing**: 이미지 무결성 검증

---

## 📊 성능 최적화

### **Image Optimization**
- **Layer Caching**: 빌드 캐시 활용
- **Multi-stage Build**: 최종 이미지 크기 최소화
- **.dockerignore**: 불필요한 파일 제외
- **Alpine Images**: 경량 베이스 이미지 사용

### **Runtime Optimization**
- **Resource Limits**: 적절한 리소스 할당
- **Volume Performance**: 적절한 볼륨 타입 선택
- **Network Optimization**: 효율적인 네트워크 구성

---

*이 용어집은 Week 2의 실습 내용을 이해하는 데 필수적인 용어들을 정리했습니다. 실제 실습과 함께 참고하시면 더욱 효과적입니다.*
