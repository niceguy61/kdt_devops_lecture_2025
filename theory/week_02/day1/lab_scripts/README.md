# Week 2 Day 1 Lab Scripts

<div align="center">

**🐳 Docker 네트워킹 & 보안** • **🛡️ 실습 스크립트 모음**

*멀티 컨테이너 네트워크 구성부터 보안 강화까지*

</div>

---

## 📁 스크립트 구조

### 🏗️ Lab 1: 멀티 컨테이너 네트워크 구성
```
lab1/
├── setup_networks.sh      # 네트워크 인프라 구축
├── deploy_database.sh     # MySQL 데이터베이스 배포
├── deploy_backend.sh      # Redis + API 서버 배포
├── deploy_frontend.sh     # Nginx + HAProxy 배포
└── test_system.sh         # 전체 시스템 테스트
```

### 🛡️ Lab 2: 보안 강화된 네트워크 환경
```
lab2/
├── generate_ssl.sh        # SSL/TLS 인증서 생성
├── setup_firewall.sh      # 방화벽 규칙 설정
├── deploy_secure_services.sh  # 보안 강화된 서비스 배포
├── setup_monitoring.sh    # 보안 모니터링 시스템
├── security_test.sh       # 보안 테스트 및 검증
├── cleanup.sh            # 실습 환경 정리
├── configs/              # 설정 파일들
│   └── haproxy-ssl.cfg   # SSL 지원 HAProxy 설정
├── scripts/              # 추가 스크립트들
└── ssl/                  # SSL 인증서 저장소
```

---

## 🚀 사용 방법

### Lab 1 실행 순서
```bash
# 1. 작업 디렉토리로 이동
cd ~/docker-network-lab
cp -r /path/to/lab_scripts/lab1/* .

# 2. 단계별 실행
./setup_networks.sh      # 네트워크 생성
./deploy_database.sh     # 데이터베이스 배포
./deploy_backend.sh      # 백엔드 서비스 배포
./deploy_frontend.sh     # 프론트엔드 배포
./test_system.sh         # 전체 테스트

# 3. 웹 브라우저에서 확인
# http://localhost - 웹 애플리케이션
# http://localhost:8404/stats - HAProxy 통계
```

### Lab 2 실행 순서
```bash
# 1. Lab 1 완료 후 보안 강화
cd ~/docker-network-lab
cp -r /path/to/lab_scripts/lab2/* .

# 2. 보안 설정 실행
./generate_ssl.sh           # SSL 인증서 생성
sudo ./setup_firewall.sh    # 방화벽 설정 (sudo 필요)
./deploy_secure_services.sh # 보안 서비스 배포
./setup_monitoring.sh       # 모니터링 시스템
./security_test.sh          # 보안 테스트

# 3. 보안 강화된 시스템 확인
# https://localhost - HTTPS 웹 애플리케이션
# http://localhost:8888 - 보안 모니터링 대시보드
# http://localhost:8404/stats - HAProxy 통계 (인증 필요)
```

### 실습 완료 후 정리
```bash
# 모든 실습 환경 정리
./cleanup.sh
```

---

## 📋 스크립트별 상세 설명

### 🏗️ Lab 1 스크립트들

#### `setup_networks.sh`
- **목적**: Docker 커스텀 네트워크 생성
- **생성 네트워크**:
  - `frontend-net`: 172.20.1.0/24 (외부 접근)
  - `backend-net`: 172.20.2.0/24 (내부 통신)
  - `database-net`: 172.20.3.0/24 (격리된 DB)

#### `deploy_database.sh`
- **목적**: MySQL 데이터베이스 배포 및 초기 데이터 생성
- **기능**: 
  - MySQL 8.0 컨테이너 실행
  - 샘플 데이터베이스 및 테이블 생성
  - 연결 테스트

#### `deploy_backend.sh`
- **목적**: Redis 캐시 및 Node.js API 서버 배포
- **기능**:
  - Redis 캐시 서버 실행
  - API 서버 소스 코드 생성 및 빌드
  - 2개 API 서버 인스턴스 실행
  - 네트워크 간 연결 설정

#### `deploy_frontend.sh`
- **목적**: HAProxy 로드 밸런서 및 Nginx 웹 서버 배포
- **기능**:
  - HAProxy 로드 밸런서 설정 및 실행
  - Nginx 웹 서버 및 인터랙티브 웹 페이지 배포
  - 프록시 설정 및 네트워크 연결

#### `test_system.sh`
- **목적**: 전체 시스템 동작 검증
- **테스트 항목**:
  - 컨테이너 상태 확인
  - 네트워크 연결 테스트
  - 서비스 간 통신 검증
  - 로드 밸런싱 동작 확인
  - 웹 애플리케이션 접근 테스트

### 🛡️ Lab 2 스크립트들

#### `generate_ssl.sh`
- **목적**: SSL/TLS 인증서 생성
- **생성 파일**:
  - CA 인증서 및 개인키
  - 서버 인증서 (localhost, 172.20.1.10)
  - 클라이언트 인증서
  - HAProxy용 결합 인증서

#### `setup_firewall.sh`
- **목적**: iptables 방화벽 규칙 설정
- **보안 정책**:
  - 네트워크 계층별 접근 제어
  - 공격 패턴 차단 (포트 스캔, SYN Flood)
  - 연결 제한 및 로깅
  - 기본 거부 정책

#### `deploy_secure_services.sh`
- **목적**: 보안 강화된 서비스 재배포
- **보안 강화 사항**:
  - MySQL: SSL 강제, 읽기 전용 파일시스템
  - Redis: 비밀번호 인증, 위험 명령어 비활성화
  - HAProxy: HTTPS 강제, 보안 헤더, Rate Limiting
  - 컨테이너: 최소 권한, 보안 옵션 적용

#### `setup_monitoring.sh`
- **목적**: 보안 모니터링 시스템 구축
- **모니터링 구성요소**:
  - Fail2ban 침입 탐지 시스템
  - Fluent Bit 로그 수집
  - Python 기반 보안 분석기
  - 웹 기반 모니터링 대시보드

#### `security_test.sh`
- **목적**: 종합적인 보안 테스트 실행
- **테스트 항목**:
  - 포트 스캔 테스트
  - 웹 애플리케이션 보안 (SQL 인젝션, XSS)
  - Rate Limiting 동작 확인
  - SSL/TLS 설정 검증
  - 방화벽 및 접근 제어 테스트

#### `cleanup.sh`
- **목적**: 실습 환경 완전 정리
- **정리 항목**:
  - 모든 실습 컨테이너 삭제
  - 네트워크 및 볼륨 정리
  - 방화벽 규칙 초기화
  - 생성된 파일 정리

---

## ⚠️ 주의사항

### 권한 요구사항
- `setup_firewall.sh`: sudo 권한 필요 (iptables 설정)
- `cleanup.sh`: 방화벽 정리 시 sudo 권한 필요

### 포트 사용
- **80**: HTTP (Nginx)
- **443**: HTTPS (HAProxy)
- **3306**: MySQL (내부 네트워크만)
- **6379**: Redis (내부 네트워크만)
- **8080**: HAProxy API
- **8404**: HAProxy 통계
- **8888**: 보안 모니터링 대시보드

### 시스템 요구사항
- Docker 20.10 이상
- 최소 4GB RAM
- 10GB 이상 디스크 공간
- Linux 환경 (iptables 지원)

---

## 🔧 문제 해결

### 일반적인 문제들

#### 포트 충돌
```bash
# 사용 중인 포트 확인
netstat -tlnp | grep -E '(80|443|3306|6379|8080|8404|8888)'

# 기존 서비스 중지
sudo systemctl stop apache2 nginx mysql
```

#### 네트워크 충돌
```bash
# 기존 네트워크 확인 및 삭제
docker network ls
docker network rm frontend-net backend-net database-net monitoring-net
```

#### 권한 문제
```bash
# Docker 그룹에 사용자 추가
sudo usermod -aG docker $USER
newgrp docker

# 방화벽 설정 권한
sudo chmod +x setup_firewall.sh
```

#### SSL 인증서 문제
```bash
# 인증서 재생성
rm -f *.pem *.csr *.cnf *.srl
./generate_ssl.sh
```

### 로그 확인 방법
```bash
# 컨테이너 로그
docker logs [컨테이너명]

# 방화벽 로그
sudo dmesg | grep DOCKER-FIREWALL

# 보안 모니터링 로그
tail -f logs/security-events.log
cat logs/security-report.json
```

---

## 📚 추가 학습 자료

### 관련 문서
- [Docker 네트워킹 공식 문서](https://docs.docker.com/network/)
- [HAProxy 설정 가이드](https://www.haproxy.org/download/2.8/doc/configuration.txt)
- [iptables 방화벽 가이드](https://netfilter.org/documentation/HOWTO/packet-filtering-HOWTO.html)

### 확장 실습 아이디어
- Kubernetes 네트워킹으로 마이그레이션
- Prometheus + Grafana 모니터링 추가
- ELK 스택을 활용한 로그 분석
- Vault를 활용한 시크릿 관리

---

<div align="center">

**🐳 Docker 네트워킹 마스터** • **🛡️ 보안 전문가** • **🚀 실무 준비 완료**

*Week 2 Day 1 실습을 통해 프로덕션급 컨테이너 네트워킹 역량 획득!*

</div>