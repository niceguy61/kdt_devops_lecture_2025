# Week 2 Day 3 Lab Scripts

이 디렉토리는 **보안 & 최적화 통합 실습**을 위한 자동화 스크립트들을 포함합니다.

## 📁 디렉토리 구조

```
lab_scripts/
├── security/           # Phase 1: 보안 강화 스크립트
│   ├── security_scan.sh
│   ├── build_secure_image.sh
│   └── deploy_secure_container.sh
├── optimization/       # Phase 2: 성능 최적화 스크립트
│   ├── optimize_image.sh
│   ├── performance_test.sh
│   └── setup_caching.sh
├── monitoring/         # Phase 3: 모니터링 구축 스크립트
│   ├── setup_monitoring.sh
│   └── test_monitoring.sh
└── README.md          # 이 파일
```

## 🚀 사용 방법

### Phase 1: 보안 강화 (60분)

1. **보안 스캔 실행**
   ```bash
   chmod +x lab_scripts/security/security_scan.sh
   ./lab_scripts/security/security_scan.sh
   ```

2. **보안 강화 이미지 빌드**
   ```bash
   chmod +x lab_scripts/security/build_secure_image.sh
   ./lab_scripts/security/build_secure_image.sh
   ```

3. **보안 강화 컨테이너 배포**
   ```bash
   chmod +x lab_scripts/security/deploy_secure_container.sh
   ./lab_scripts/security/deploy_secure_container.sh
   ```

### Phase 2: 성능 최적화 (60분)

1. **이미지 최적화**
   ```bash
   chmod +x lab_scripts/optimization/optimize_image.sh
   ./lab_scripts/optimization/optimize_image.sh
   ```

2. **성능 테스트**
   ```bash
   chmod +x lab_scripts/optimization/performance_test.sh
   ./lab_scripts/optimization/performance_test.sh
   ```

3. **캐싱 시스템 구축**
   ```bash
   chmod +x lab_scripts/optimization/setup_caching.sh
   ./lab_scripts/optimization/setup_caching.sh
   ```

### Phase 3: 모니터링 구축 (60분)

1. **모니터링 시스템 구축**
   ```bash
   chmod +x lab_scripts/monitoring/setup_monitoring.sh
   ./lab_scripts/monitoring/setup_monitoring.sh
   ```

2. **모니터링 테스트**
   ```bash
   chmod +x lab_scripts/monitoring/test_monitoring.sh
   ./lab_scripts/monitoring/test_monitoring.sh
   ```

## 🔧 전체 실행 (한 번에 모든 Phase 실행)

```bash
# 모든 스크립트에 실행 권한 부여
find lab_scripts -name "*.sh" -exec chmod +x {} \;

# Phase 1: 보안 강화
./lab_scripts/security/security_scan.sh
./lab_scripts/security/build_secure_image.sh
./lab_scripts/security/deploy_secure_container.sh

# Phase 2: 성능 최적화
./lab_scripts/optimization/optimize_image.sh
./lab_scripts/optimization/performance_test.sh
./lab_scripts/optimization/setup_caching.sh

# Phase 3: 모니터링 구축
./lab_scripts/monitoring/setup_monitoring.sh
./lab_scripts/monitoring/test_monitoring.sh
```

## 📋 사전 요구사항

### 필수 도구
- Docker & Docker Compose
- curl
- wget

### 자동 설치되는 도구
- Trivy (보안 스캔)
- Apache Bench (성능 테스트)

## 🔍 스크립트별 상세 설명

### Security Scripts

#### `security_scan.sh`
- Trivy 자동 설치
- 다양한 이미지 취약점 스캔
- 스캔 결과 비교 및 분석

#### `build_secure_image.sh`
- 보안 강화 Dockerfile 생성
- 멀티스테이지 빌드 적용
- 보안 강화 이미지 빌드 및 스캔

#### `deploy_secure_container.sh`
- 런타임 보안 정책 적용
- 보안 설정 검증
- 애플리케이션 동작 확인

### Optimization Scripts

#### `optimize_image.sh`
- 최적화된 Dockerfile 생성
- 이미지 크기 비교 분석
- 레이어 분석 및 최적화 검증

#### `performance_test.sh`
- Apache Bench 자동 설치
- 기본 성능 테스트 및 부하 테스트
- 리소스 사용량 모니터링

#### `setup_caching.sh`
- Redis 캐싱 시스템 구축
- Docker Compose 기반 통합 환경
- 캐시 성능 테스트

### Monitoring Scripts

#### `setup_monitoring.sh`
- Prometheus + Grafana + cAdvisor 스택 구축
- 설정 파일 자동 생성
- 알림 규칙 설정

#### `test_monitoring.sh`
- 모니터링 시스템 헬스 체크
- 메트릭 수집 확인
- Prometheus 쿼리 테스트

## 🎯 학습 목표

각 스크립트를 통해 다음을 학습할 수 있습니다:

### Phase 1: 보안
- 컨테이너 취약점 스캔 방법
- 보안 강화 Dockerfile 작성법
- 런타임 보안 정책 적용

### Phase 2: 최적화
- 멀티스테이지 빌드를 통한 이미지 최적화
- 성능 테스트 및 벤치마킹
- 캐싱 시스템 구축

### Phase 3: 모니터링
- Prometheus 기반 메트릭 수집
- Grafana 대시보드 구성
- 알림 시스템 설정

## 🔧 문제 해결

### 권한 오류
```bash
chmod +x lab_scripts/**/*.sh
```

### Docker 권한 오류
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### 포트 충돌
기본 포트들을 확인하고 필요시 변경:
- 3000: 애플리케이션
- 6379: Redis
- 8080: cAdvisor
- 9090: Prometheus
- 3001: Grafana

## 📞 지원

스크립트 실행 중 문제가 발생하면:
1. 에러 메시지 확인
2. Docker 로그 확인: `docker logs [container_name]`
3. 포트 사용 확인: `netstat -tulpn | grep [port]`
4. 강사에게 문의

---

**Happy Learning! 🚀**