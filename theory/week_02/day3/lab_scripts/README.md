# Week 2 Day 3 Lab Scripts

## 📁 스크립트 구조

```
lab_scripts/
├── security/                    # 보안 관련 스크립트
│   ├── security_scan.sh        # 취약점 스캔 자동화
│   ├── build_secure_image.sh   # 보안 강화 이미지 빌드
│   └── deploy_secure_container.sh # 보안 강화 컨테이너 배포
├── optimization/               # 성능 최적화 스크립트
│   ├── optimize_image.sh       # 이미지 최적화
│   ├── performance_test.sh     # 성능 벤치마크 테스트
│   └── setup_caching.sh        # 캐싱 시스템 구축
├── monitoring/                 # 모니터링 관련 스크립트
│   ├── setup_monitoring.sh     # 모니터링 스택 구축
│   └── test_monitoring.sh      # 모니터링 시스템 테스트
└── README.md                   # 이 파일
```

## 🚀 스크립트 사용 방법

### 1. 보안 강화 워크플로우

```bash
# 1단계: 취약점 스캔
./security/security_scan.sh

# 2단계: 보안 강화 이미지 빌드
./security/build_secure_image.sh

# 3단계: 보안 강화 컨테이너 배포
./security/deploy_secure_container.sh
```

### 2. 성능 최적화 워크플로우

```bash
# 1단계: 이미지 최적화
./optimization/optimize_image.sh

# 2단계: 성능 벤치마크 테스트
./optimization/performance_test.sh

# 3단계: 캐싱 시스템 구축
./optimization/setup_caching.sh
```

### 3. 모니터링 구축 워크플로우

```bash
# 1단계: 모니터링 스택 구축
./monitoring/setup_monitoring.sh

# 2단계: 모니터링 시스템 테스트
./monitoring/test_monitoring.sh
```

## 📋 전체 통합 실습 순서

### Phase 1: 보안 강화 (60분)
1. `./security/security_scan.sh` - 기본 이미지 취약점 분석
2. `./security/build_secure_image.sh` - 보안 강화 이미지 빌드
3. `./security/deploy_secure_container.sh` - 보안 정책 적용 배포

### Phase 2: 성능 최적화 (60분)
1. `./optimization/optimize_image.sh` - 멀티스테이지 빌드 최적화
2. `./optimization/performance_test.sh` - 성능 벤치마크 측정
3. `./optimization/setup_caching.sh` - Redis 캐싱 시스템 구축

### Phase 3: 모니터링 구축 (60분)
1. `./monitoring/setup_monitoring.sh` - Prometheus + Grafana 스택
2. `./monitoring/test_monitoring.sh` - 모니터링 시스템 검증

## 🔧 스크립트 실행 권한 설정

```bash
# 모든 스크립트에 실행 권한 부여
find lab_scripts/ -name "*.sh" -exec chmod +x {} \;

# 또는 개별 설정
chmod +x security/*.sh
chmod +x optimization/*.sh
chmod +x monitoring/*.sh
```

## 📊 생성되는 결과 파일

### 보안 관련
- `scan-results/` - 취약점 스캔 결과 (JSON)
- `security-report.txt` - 보안 강화 종합 리포트
- `secure-deployment-report.txt` - 보안 배포 분석

### 성능 관련
- `performance-results/` - 성능 테스트 결과
- `cache-performance-report.txt` - 캐시 성능 분석
- `docker-compose.optimized.yml` - 최적화된 구성

### 모니터링 관련
- `monitoring/` - Prometheus, Grafana 설정 파일
- `monitoring-test-report.txt` - 모니터링 시스템 검증 결과

## ⚠️ 사전 요구사항

### 필수 도구
- Docker & Docker Compose
- curl, jq
- Apache Bench (ab) - 성능 테스트용

### 설치 명령어 (Ubuntu/Debian)
```bash
# 기본 도구 설치
sudo apt-get update
sudo apt-get install -y curl jq apache2-utils bc

# Docker 설치 (필요시)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

## 🔍 트러블슈팅

### 일반적인 문제

1. **권한 오류**
   ```bash
   chmod +x lab_scripts/**/*.sh
   ```

2. **포트 충돌**
   ```bash
   # 사용 중인 포트 확인
   netstat -tlnp | grep -E "(3000|3001|6379|8080|9090)"
   
   # 기존 컨테이너 정리
   docker stop $(docker ps -aq)
   docker rm $(docker ps -aq)
   ```

3. **디스크 공간 부족**
   ```bash
   # 사용하지 않는 이미지 정리
   docker system prune -a
   ```

4. **네트워크 충돌**
   ```bash
   # 기존 네트워크 정리
   docker network prune
   ```

## 📈 성능 최적화 팁

### 스크립트 실행 속도 향상
- 병렬 실행 가능한 작업은 백그라운드 실행
- 불필요한 이미지 다운로드 최소화
- 로컬 캐시 활용

### 리소스 사용량 최적화
- 동시 실행 컨테이너 수 제한
- 메모리 사용량 모니터링
- CPU 사용률 분산

## 🎯 학습 목표 달성 체크

### 보안 강화
- [ ] 취약점 50% 이상 감소
- [ ] 비root 사용자 실행
- [ ] 읽기 전용 파일시스템 적용
- [ ] 최소 권한 원칙 적용

### 성능 최적화
- [ ] 이미지 크기 50% 이상 감소
- [ ] 성능 벤치마크 측정 완료
- [ ] 캐싱 시스템 구축
- [ ] 리소스 제한 적용

### 모니터링 구축
- [ ] Prometheus + Grafana 스택 구축
- [ ] 메트릭 수집 확인
- [ ] 알림 시스템 테스트
- [ ] 대시보드 구성

## 🔗 관련 문서

- [Lab 1 실습 가이드](../lab_1.md)
- [Week 2 Day 3 README](../README.md)
- [Week 2 전체 개요](../../README.md)

---

<div align="center">

**🔒 보안** • **⚡ 최적화** • **📊 모니터링**

*자동화 스크립트로 효율적인 실습 진행*

</div>