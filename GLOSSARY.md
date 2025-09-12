# DevOps Engineer 과정 용어집 (Week 1-2)

## 📖 용어집 사용 가이드
이 용어집은 Week 1-2에서 다루는 DevOps와 Docker 관련 핵심 용어들을 정리한 것입니다. 각 용어는 다음과 같이 구성되어 있습니다:
- **용어**: 영문 원어와 한글 번역
- **정의**: 간단명료한 설명
- **예시**: 실무에서 사용되는 구체적 사례
- **관련 용어**: 함께 알아두면 좋은 연관 용어

---

## 🔤 A-Z 순서

### A

#### **API Gateway**
- **정의**: 마이크로서비스 아키텍처에서 모든 클라이언트 요청의 단일 진입점 역할을 하는 서비스
- **예시**: Netflix의 Zuul, AWS API Gateway, Kong
- **관련 용어**: Microservices, Load Balancer, Reverse Proxy

#### **Automation (자동화)**
- **정의**: 반복적인 작업을 사람의 개입 없이 자동으로 수행하는 것
- **예시**: 코드 빌드, 테스트 실행, 배포 과정 자동화
- **관련 용어**: CI/CD, Pipeline, Jenkins

#### **Alpine Linux**
- **정의**: 보안, 단순성, 리소스 효율성에 중점을 둔 경량 Linux 배포판
- **예시**: `FROM alpine:3.18` (Docker 베이스 이미지로 많이 사용)
- **관련 용어**: Base Image, Container, Lightweight

---

### B

#### **Base Image (베이스 이미지)**
- **정의**: Docker 이미지를 만들 때 기반이 되는 최초 이미지
- **예시**: `ubuntu:20.04`, `node:18-alpine`, `python:3.9`
- **관련 용어**: Dockerfile, FROM, Layer

#### **Bind Mount (바인드 마운트)**
- **정의**: 호스트 파일시스템의 특정 경로를 컨테이너 내부로 직접 마운트하는 방식
- **예시**: `docker run -v /host/path:/container/path`
- **관련 용어**: Volume, tmpfs, Storage

#### **Bridge Network (브리지 네트워크)**
- **정의**: Docker의 기본 네트워크 드라이버로, 컨테이너 간 통신을 위한 가상 네트워크
- **예시**: `docker network create my-bridge`
- **관련 용어**: Network Driver, Container Communication, Docker0

---

### C

#### **CI/CD (Continuous Integration/Continuous Deployment)**
- **정의**: 지속적 통합과 지속적 배포를 의미하는 DevOps 핵심 실천 방법
- **예시**: GitHub Actions, Jenkins Pipeline, GitLab CI/CD
- **관련 용어**: Pipeline, Automation, DevOps

#### **Container (컨테이너)**
- **정의**: 애플리케이션과 그 실행 환경을 패키징한 경량 가상화 기술
- **예시**: Docker 컨테이너, 웹 서버 컨테이너, 데이터베이스 컨테이너
- **관련 용어**: Docker, Image, Virtualization

#### **Container Registry (컨테이너 레지스트리)**
- **정의**: Docker 이미지를 저장하고 배포하는 중앙 저장소
- **예시**: Docker Hub, AWS ECR, Google Container Registry
- **관련 용어**: Docker Hub, Image, Push/Pull

#### **Conway's Law (콘웨이 법칙)**
- **정의**: "조직의 구조는 그 조직이 설계하는 시스템의 구조를 결정한다"
- **예시**: 팀이 분리되어 있으면 시스템도 분리된 구조가 됨
- **관련 용어**: DevOps Culture, Organization, Architecture

---

### D

#### **DevOps**
- **정의**: Development(개발)와 Operations(운영)의 합성어로, 협업 문화와 방법론
- **예시**: Netflix, Amazon의 DevOps 문화
- **관련 용어**: Culture, Automation, CI/CD, Collaboration

#### **Docker**
- **정의**: 컨테이너 기반 가상화 플랫폼으로 애플리케이션을 패키징하고 실행
- **예시**: `docker run nginx`, `docker build -t myapp .`
- **관련 용어**: Container, Image, Dockerfile

#### **Docker Compose**
- **정의**: 멀티 컨테이너 Docker 애플리케이션을 정의하고 실행하는 도구
- **예시**: `docker-compose up -d`로 여러 서비스 동시 실행
- **관련 용어**: YAML, Multi-container, Orchestration

#### **Docker Desktop**
- **정의**: Windows와 macOS에서 Docker를 쉽게 사용할 수 있게 해주는 애플리케이션
- **예시**: GUI를 통한 컨테이너 관리, WSL 2 통합
- **관련 용어**: WSL 2, Hyper-V, Container Runtime

#### **Dockerfile**
- **정의**: Docker 이미지를 빌드하기 위한 명령어들을 담은 텍스트 파일
- **예시**: `FROM`, `RUN`, `COPY`, `CMD` 등의 명령어 사용
- **관련 용어**: Image Build, Layer, Multi-stage Build

---

### E

#### **Environment Variable (환경 변수)**
- **정의**: 운영체제에서 프로세스가 참조할 수 있는 동적인 값들
- **예시**: `NODE_ENV=production`, `DB_HOST=localhost`
- **관련 용어**: Configuration, Docker ENV, Runtime

---

### G

#### **Git**
- **정의**: 분산 버전 관리 시스템으로 소스 코드 변경사항을 추적
- **예시**: `git commit`, `git push`, `git merge`
- **관련 용어**: Version Control, GitHub, Branch

#### **GitHub Actions**
- **정의**: GitHub에서 제공하는 CI/CD 플랫폼
- **예시**: `.github/workflows/ci.yml` 파일로 자동화 워크플로우 정의
- **관련 용어**: CI/CD, Workflow, Pipeline

---

### H

#### **Health Check (헬스체크)**
- **정의**: 서비스나 컨테이너의 상태를 주기적으로 확인하는 메커니즘
- **예시**: `HEALTHCHECK --interval=30s CMD curl -f http://localhost/health`
- **관련 용어**: Monitoring, Container Status, Availability

#### **Host Network (호스트 네트워크)**
- **정의**: 컨테이너가 호스트의 네트워크 스택을 직접 사용하는 네트워크 모드
- **예시**: `docker run --network host nginx`
- **관련 용어**: Network Mode, Performance, Port Mapping

---

### I

#### **Image (이미지)**
- **정의**: 컨테이너를 실행하기 위한 읽기 전용 템플릿
- **예시**: `nginx:latest`, `ubuntu:20.04`, `node:18-alpine`
- **관련 용어**: Container, Dockerfile, Layer

#### **Infrastructure as Code (IaC)**
- **정의**: 인프라를 코드로 정의하고 관리하는 방법론
- **예시**: Terraform, AWS CloudFormation, Ansible
- **관련 용어**: Automation, Version Control, Reproducibility

---

### J

#### **Jenkins**
- **정의**: 오픈소스 CI/CD 도구로 빌드, 테스트, 배포 자동화
- **예시**: Jenkinsfile을 통한 파이프라인 정의
- **관련 용어**: CI/CD, Pipeline, Automation

---

### K

#### **Kubernetes (K8s)**
- **정의**: 컨테이너 오케스트레이션 플랫폼으로 컨테이너화된 애플리케이션의 배포, 확장, 관리 자동화
- **예시**: Pod, Service, Deployment 등의 리소스 관리
- **관련 용어**: Container Orchestration, Pod, Service

---

### L

#### **Layer (레이어)**
- **정의**: Docker 이미지를 구성하는 읽기 전용 파일시스템의 각 계층
- **예시**: 각 Dockerfile 명령어가 새로운 레이어 생성
- **관련 용어**: Image, Dockerfile, Union File System

#### **Load Balancer (로드 밸런서)**
- **정의**: 여러 서버에 네트워크 트래픽을 분산시키는 장치나 소프트웨어
- **예시**: Nginx, HAProxy, AWS Application Load Balancer
- **관련 용어**: High Availability, Scaling, Traffic Distribution

---

### M

#### **Microservices (마이크로서비스)**
- **정의**: 애플리케이션을 작고 독립적인 서비스들로 분해하는 아키텍처 패턴
- **예시**: Netflix의 700개 이상의 마이크로서비스
- **관련 용어**: API Gateway, Container, Service Mesh

#### **Multi-stage Build (멀티 스테이지 빌드)**
- **정의**: 하나의 Dockerfile에서 여러 단계를 거쳐 최종 이미지를 만드는 기법
- **예시**: 빌드 단계와 런타임 단계를 분리하여 이미지 크기 최적화
- **관련 용어**: Dockerfile, Image Optimization, Build Stage

---

### N

#### **Named Volume (네임드 볼륨)**
- **정의**: Docker가 관리하는 이름이 있는 볼륨으로 데이터 영속성 보장
- **예시**: `docker volume create mydata`
- **관련 용어**: Data Persistence, Storage, Bind Mount

#### **Network Driver (네트워크 드라이버)**
- **정의**: Docker에서 컨테이너 네트워킹을 구현하는 방식
- **예시**: bridge, host, overlay, macvlan
- **관련 용어**: Container Networking, Bridge, Overlay

---

### O

#### **Orchestration (오케스트레이션)**
- **정의**: 여러 컨테이너의 배포, 관리, 확장, 네트워킹을 자동화하는 것
- **예시**: Kubernetes, Docker Swarm, Docker Compose
- **관련 용어**: Container Management, Scaling, Service Discovery

---

### P

#### **Pipeline (파이프라인)**
- **정의**: 소스 코드부터 배포까지의 자동화된 프로세스 체인
- **예시**: Code → Build → Test → Deploy 단계
- **관련 용어**: CI/CD, Automation, Jenkins

#### **Pod**
- **정의**: Kubernetes에서 배포 가능한 가장 작은 단위로, 하나 이상의 컨테이너를 포함
- **예시**: 웹 서버 컨테이너와 사이드카 컨테이너를 함께 실행
- **관련 용어**: Kubernetes, Container, Service

---

### R

#### **Registry (레지스트리)**
- **정의**: Docker 이미지를 저장하고 배포하는 서비스
- **예시**: Docker Hub, AWS ECR, Harbor
- **관련 용어**: Image Repository, Push/Pull, Distribution

#### **Replica (레플리카)**
- **정의**: 동일한 애플리케이션의 여러 인스턴스를 실행하여 가용성과 성능 향상
- **예시**: `docker-compose up --scale web=3`
- **관련 용어**: Scaling, High Availability, Load Balancing

---

### S

#### **Scaling (스케일링)**
- **정의**: 애플리케이션의 처리 능력을 증가시키는 것
- **예시**: 수평 스케일링(인스턴스 증가), 수직 스케일링(리소스 증가)
- **관련 용어**: Horizontal Scaling, Vertical Scaling, Auto Scaling

#### **Service Discovery (서비스 디스커버리)**
- **정의**: 마이크로서비스 환경에서 서비스들이 서로를 찾고 통신할 수 있게 하는 메커니즘
- **예시**: DNS 기반 서비스 발견, Consul, etcd
- **관련 용어**: Microservices, DNS, Load Balancing

#### **Silo Effect (사일로 현상)**
- **정의**: 조직 내 부서나 팀이 서로 단절되어 정보 공유가 되지 않는 현상
- **예시**: 개발팀과 운영팀이 서로 다른 목표로 일하는 상황
- **관련 용어**: DevOps Culture, Collaboration, Conway's Law

---

### T

#### **tmpfs Mount**
- **정의**: 메모리에 임시 파일시스템을 마운트하는 방식
- **예시**: `docker run --tmpfs /tmp:rw,size=100m`
- **관련 용어**: Memory Storage, Temporary Files, Performance

---

### V

#### **Volume (볼륨)**
- **정의**: 컨테이너의 데이터를 영속적으로 저장하기 위한 메커니즘
- **예시**: Named Volume, Bind Mount, tmpfs Mount
- **관련 용어**: Data Persistence, Storage, Mount

#### **Virtualization (가상화)**
- **정의**: 물리적 하드웨어 리소스를 논리적으로 분할하여 여러 환경을 만드는 기술
- **예시**: VM(가상머신), Container(컨테이너)
- **관련 용어**: Hypervisor, Container, Resource Isolation

---

### W

#### **Waterfall Model (워터폴 모델)**
- **정의**: 소프트웨어 개발 과정을 순차적 단계로 나누어 진행하는 전통적 방법론
- **예시**: 요구사항 → 설계 → 구현 → 테스트 → 배포 순서
- **관련 용어**: SDLC, Agile, DevOps

#### **WSL 2 (Windows Subsystem for Linux 2)**
- **정의**: Windows에서 Linux 바이너리를 네이티브로 실행할 수 있게 해주는 호환성 계층
- **예시**: Windows에서 Docker Desktop의 백엔드로 사용
- **관련 용어**: Docker Desktop, Linux, Windows

---

## 📚 추가 학습 자료

### 공식 문서
- [Docker 공식 문서](https://docs.docker.com/)
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [DevOps Institute](https://devopsinstitute.com/)

### 추천 도서
- "The DevOps Handbook" - Gene Kim
- "Docker Deep Dive" - Nigel Poulton
- "Kubernetes in Action" - Marko Lukša

### 온라인 리소스
- [Docker Hub](https://hub.docker.com/)
- [GitHub Actions Marketplace](https://github.com/marketplace)
- [CNCF Landscape](https://landscape.cncf.io/)

---

## 🔄 용어집 업데이트
이 용어집은 과정 진행에 따라 지속적으로 업데이트됩니다.
- **Week 3-4**: Kubernetes 심화 용어 추가 예정
- **Week 5-6**: CI/CD 및 IaC 용어 추가 예정
- **Week 7**: 최신 DevOps 트렌드 용어 추가 예정

---

*마지막 업데이트: 2024년 12월*
