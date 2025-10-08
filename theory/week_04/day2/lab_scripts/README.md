# Week 4 Day 2 Lab 1 Scripts

API Gateway & 서비스 디스커버리 구축을 위한 자동화 스크립트들

## 🚀 빠른 시작

### 1단계: 환경 준비 (필수)
```bash
cd lab1
./setup-environment.sh
```

### 2단계: 전체 서비스 구축
```bash
./setup-all-services.sh
```

## 📋 전체 스크립트 목록
- **setup-environment.sh**: 🔧 시스템 환경 준비 (Docker, jq, curl 확인/설치)
- **setup-all-services.sh**: 🌟 전체 서비스 자동 구축 (원클릭 설치)
- setup-network.sh: Docker 네트워크 구성
- setup-consul.sh: Consul 서비스 디스커버리 구축
- deploy-user-service.sh: User Service 배포
- deploy-product-service.sh: Product Service 배포  
- deploy-order-service.sh: Order Service 배포
- setup-kong.sh: Kong API Gateway 구축
- configure-kong-routes.sh: Kong 라우트 설정
- test-service-discovery.sh: 서비스 디스커버리 테스트
- cleanup.sh: 환경 정리

## 🎯 사용 방법

### 완전 자동 설치 (권장)
```bash
cd lab1
./setup-environment.sh    # 환경 준비
./setup-all-services.sh   # 서비스 구축
```

### 수동 설치 (학습용)
```bash
cd lab1
./setup-environment.sh    # 환경 준비 (필수)
./setup-network.sh
./setup-consul.sh
./deploy-user-service.sh
./deploy-product-service.sh
./deploy-order-service.sh
./setup-kong.sh
./configure-kong-routes.sh
```

## ⚠️ 주의사항
- 실습 전 반드시 `setup-environment.sh`를 먼저 실행하세요
- Docker, jq, curl이 설치되어 있어야 합니다
- 포트 8000, 8001, 8500, 3001-3003이 사용 가능해야 합니다
