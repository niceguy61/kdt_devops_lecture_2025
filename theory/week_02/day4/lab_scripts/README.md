# Week 2 Day 4 Lab Scripts 사용 가이드

## 📁 스크립트 구조

```
lab_scripts/
├── lab1/                           # Lab 1: K8s 환경 구축 & 기본 배포
│   ├── setup_k8s_cluster.sh       # K8s 클러스터 자동 구축
│   ├── deploy_basic_objects.sh     # 기본 오브젝트 자동 배포
│   ├── k8s_management_demo.sh      # K8s 관리 명령어 데모
│   └── test_k8s_environment.sh     # 종합 환경 테스트
├── lab2/                           # Lab 2: Docker 앱의 K8s 마이그레이션
│   ├── setup_configs_secrets.sh    # 설정 및 시크릿 생성
│   ├── deploy_mysql_statefulset.sh # MySQL StatefulSet 배포
│   ├── deploy_wordpress_deployment.sh # WordPress Deployment 배포
│   ├── setup_ingress_access.sh     # Ingress 및 외부 접근 설정
│   └── cleanup.sh                  # 실습 환경 완전 정리
└── README.md                       # 이 파일
```

## 🚀 Lab 1: K8s 환경 구축 & 기본 배포

### 실행 순서

```bash
# 1. K8s 클러스터 구축
cd lab_scripts/lab1
chmod +x *.sh
./setup_k8s_cluster.sh

# 2. 기본 오브젝트 배포
./deploy_basic_objects.sh

# 3. K8s 관리 명령어 실습
./k8s_management_demo.sh

# 4. 종합 테스트 (선택적)
./test_k8s_environment.sh
```

### 각 스크립트 기능

#### `setup_k8s_cluster.sh`
- **목적**: 로컬 K8s 클러스터 자동 구축
- **기능**:
  - Kind/kubectl 자동 설치 (필요시)
  - 멀티 노드 클러스터 생성 (1 Control Plane + 2 Worker)
  - 포트 매핑 설정 (80→8080, 443→8443)
  - 클러스터 상태 검증
- **소요 시간**: 3-5분
- **결과**: `k8s-lab-cluster` 클러스터 생성

#### `deploy_basic_objects.sh`
- **목적**: K8s 기본 오브젝트 배포
- **기능**:
  - 네임스페이스 생성 (`lab-demo`)
  - ConfigMap 생성 (Nginx 설정)
  - Deployment 배포 (Nginx 3 replicas)
  - Service 생성 (ClusterIP, NodePort)
  - 헬스 체크 및 리소스 제한 적용
- **소요 시간**: 2-3분
- **결과**: 완전한 웹 애플리케이션 스택

#### `k8s_management_demo.sh`
- **목적**: K8s 관리 명령어 실습
- **기능**:
  - Pod 관리 (조회, 로그, 실행)
  - Service 및 네트워킹 테스트
  - 스케일링 및 롤링 업데이트
  - 라벨 및 셀렉터 활용
  - 리소스 모니터링
- **소요 시간**: 5-10분
- **결과**: kubectl 명령어 숙련도 향상

#### `test_k8s_environment.sh`
- **목적**: 종합 환경 테스트
- **기능**:
  - 20+ 개 자동 테스트 실행
  - 클러스터 상태 검증
  - 네트워킹 및 DNS 테스트
  - 애플리케이션 기능 검증
  - 성능 및 안정성 확인
- **소요 시간**: 3-5분
- **결과**: 환경 품질 보증

## 🔄 Lab 2: Docker 앱의 K8s 마이그레이션

### 실행 순서

```bash
# Lab 1 완료 후 진행
cd lab_scripts/lab2
chmod +x *.sh

# 1. 설정 및 시크릿 생성
./setup_configs_secrets.sh

# 2. MySQL StatefulSet 배포
./deploy_mysql_statefulset.sh

# 3. WordPress Deployment 배포
./deploy_wordpress_deployment.sh

# 4. Ingress 및 외부 접근 설정
./setup_ingress_access.sh

# 5. 실습 완료 후 정리 (선택적)
./cleanup.sh
```

### 각 스크립트 기능

#### `setup_configs_secrets.sh`
- **목적**: 설정 및 보안 정보 준비
- **기능**:
  - 네임스페이스 생성 (`wordpress-k8s`, `monitoring-k8s`)
  - MySQL/WordPress ConfigMap 생성
  - Secret 생성 (패스워드, 보안 키)
  - TLS 인증서 생성 (자체 서명)
  - 모니터링 설정 준비
- **소요 시간**: 1-2분
- **결과**: 완전한 설정 외부화

#### `deploy_mysql_statefulset.sh`
- **목적**: MySQL 데이터베이스 배포
- **기능**:
  - StorageClass 및 PV 생성
  - MySQL StatefulSet 배포
  - Headless Service 생성
  - 데이터 영속성 보장
  - MySQL Exporter 포함 (모니터링)
- **소요 시간**: 3-5분
- **결과**: 프로덕션급 MySQL 환경

#### `deploy_wordpress_deployment.sh`
- **목적**: WordPress 애플리케이션 배포
- **기능**:
  - WordPress Deployment (3 replicas)
  - PVC 생성 (wp-content, uploads)
  - InitContainer로 의존성 관리
  - HPA 설정 (자동 스케일링)
  - WordPress Exporter 포함
- **소요 시간**: 3-5분
- **결과**: 확장 가능한 WordPress 환경

#### `setup_ingress_access.sh`
- **목적**: 외부 접근 및 라우팅 설정
- **기능**:
  - NGINX Ingress Controller 설치
  - 다중 Ingress 생성 (HTTP/HTTPS/Admin)
  - 포트 포워딩 자동 설정
  - DNS 설정 가이드 생성
  - 보안 설정 (Basic Auth, TLS)
- **소요 시간**: 3-5분
- **결과**: 완전한 외부 접근 환경

#### `cleanup.sh`
- **목적**: 실습 환경 완전 정리
- **기능**:
  - 단계별 리소스 정리
  - 사용자 확인 프로세스
  - 선택적 정리 옵션
  - 정리 결과 검증
  - 학습 성과 요약
- **소요 시간**: 2-3분
- **결과**: 깨끗한 환경 복원

## 🛠️ 사용 방법

### 기본 사용법

```bash
# 스크립트 실행 권한 부여
chmod +x lab_scripts/lab1/*.sh
chmod +x lab_scripts/lab2/*.sh

# 순차적 실행
./lab_scripts/lab1/setup_k8s_cluster.sh
./lab_scripts/lab1/deploy_basic_objects.sh
# ... 계속
```

### 고급 사용법

```bash
# 특정 단계만 실행
./lab_scripts/lab2/deploy_mysql_statefulset.sh

# 백그라운드 실행 (로그 저장)
./lab_scripts/lab1/setup_k8s_cluster.sh > setup.log 2>&1 &

# 조건부 실행
if kubectl cluster-info &> /dev/null; then
    ./lab_scripts/lab2/setup_configs_secrets.sh
fi
```

## 🔍 문제 해결

### 일반적인 문제

#### 1. 권한 오류
```bash
# 해결: 실행 권한 부여
chmod +x lab_scripts/lab1/*.sh
chmod +x lab_scripts/lab2/*.sh
```

#### 2. 클러스터 연결 실패
```bash
# 해결: 클러스터 상태 확인
kubectl cluster-info
kind get clusters

# 재구축
kind delete cluster --name k8s-lab-cluster
./lab_scripts/lab1/setup_k8s_cluster.sh
```

#### 3. 이미지 다운로드 실패
```bash
# 해결: 네트워크 확인 후 재시도
docker pull nginx:1.21-alpine
docker pull mysql:8.0
docker pull wordpress:6.4-apache
```

#### 4. 포트 충돌
```bash
# 해결: 사용 중인 포트 확인
netstat -tulpn | grep :8080
lsof -i :8080

# 프로세스 종료
kill $(lsof -t -i:8080)
```

### 로그 확인

```bash
# 스크립트 실행 로그
./script.sh 2>&1 | tee script.log

# K8s 리소스 로그
kubectl logs -f deployment/wordpress -n wordpress-k8s
kubectl describe pod <pod-name> -n wordpress-k8s

# 이벤트 확인
kubectl get events --sort-by='.lastTimestamp' -n wordpress-k8s
```

## 📊 성능 최적화

### 시스템 요구사항

- **CPU**: 최소 4 cores (권장 8 cores)
- **메모리**: 최소 8GB (권장 16GB)
- **디스크**: 최소 20GB 여유 공간
- **네트워크**: 인터넷 연결 (이미지 다운로드)

### 최적화 팁

```bash
# Docker 리소스 증가
# Docker Desktop > Settings > Resources

# Kind 클러스터 리소스 조정
# kind-config.yaml에서 노드 수 조정

# 병렬 실행으로 시간 단축
./script1.sh &
./script2.sh &
wait
```

## 🔐 보안 고려사항

### 개발 환경 전용
- 자체 서명 인증서 사용
- 기본 패스워드 사용
- 로컬 네트워크만 접근

### 프로덕션 적용 시 변경 필요
- 정식 TLS 인증서
- 강력한 패스워드
- 네트워크 보안 정책
- RBAC 설정

## 📚 추가 학습 자료

### 공식 문서
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [Kind 사용 가이드](https://kind.sigs.k8s.io/)
- [kubectl 치트시트](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

### 실습 확장
- Helm 차트 작성
- CI/CD 파이프라인 연동
- 모니터링 스택 구축
- 보안 정책 적용

## 🎯 학습 목표 달성 확인

### Lab 1 완료 기준
- [ ] K8s 클러스터 정상 구축
- [ ] 기본 오브젝트 배포 성공
- [ ] kubectl 명령어 숙련
- [ ] 종합 테스트 80% 이상 통과

### Lab 2 완료 기준
- [ ] Docker → K8s 마이그레이션 성공
- [ ] StatefulSet 데이터 영속성 확인
- [ ] Ingress 외부 접근 가능
- [ ] 전체 시스템 정상 동작

---

<div align="center">

**🎓 체계적 학습** • **🤝 협업 중심** • **🚀 실무 연계**

*Week 2 Day 4 - Kubernetes 여정의 시작*

</div>