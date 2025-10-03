# Week 3 Day 1 Lab 1: Kubernetes 클러스터 탐험 스크립트

## 📋 개요

이 디렉토리에는 Kubernetes 클러스터의 아키텍처와 핵심 컴포넌트를 체계적으로 탐험하기 위한 스크립트들이 포함되어 있습니다.

## 🚀 스크립트 실행 순서

### 1단계: 환경 준비
```bash
# 환경 설정 및 확인
./setup-environment.sh
```
**목적**: 필수 도구 확인, 작업 디렉토리 생성, 네임스페이스 설정

### 2단계: 클러스터 생성
```bash
# Kind 클러스터 생성
./create-cluster.sh
```
**목적**: 실습용 Kubernetes 클러스터 생성

### 3단계: 컴포넌트 분석
```bash
# 핵심 컴포넌트 상태 확인
./check-components.sh
```
**목적**: Control Plane과 Worker Node 컴포넌트 상태 분석

### 4단계: ETCD 탐험
```bash
# ETCD 데이터 구조 탐험
./etcd-exploration.sh
```
**목적**: Kubernetes의 데이터 저장소인 ETCD 내부 구조 이해

### 5단계: 종합 분석
```bash
# 클러스터 전체 상태 종합 분석
./comprehensive-analysis.sh
```
**목적**: 클러스터의 모든 측면을 종합적으로 분석하고 보고서 생성

## 📊 추가 분석 도구

### 네트워크 분석
```bash
./analyze-network.sh
```
**목적**: 클러스터 네트워킹 구성 및 연결성 분석

### 인증서 분석
```bash
./analyze-certificates.sh
```
**목적**: PKI 인증서 체인 및 보안 설정 분석

### API 서버 테스트
```bash
./api-server-test.sh
```
**목적**: API Server 기능 및 성능 테스트

## 📁 생성되는 파일들

### 로그 파일
- `logs/apiserver.log` - API Server 로그
- `logs/controller-manager.log` - Controller Manager 로그
- `logs/scheduler.log` - Scheduler 로그
- `logs/etcd.log` - ETCD 로그

### 분석 보고서
- `analysis-YYYYMMDD-HHMMSS/` - 종합 분석 결과 디렉토리
  - `health-summary.txt` - 전체 상태 요약
  - `cluster-info.txt` - 클러스터 기본 정보
  - `node-analysis.txt` - 노드 상태 분석
  - `security-analysis.txt` - 보안 설정 분석
  - 기타 상세 분석 파일들

## 🛠️ 문제 해결

### 일반적인 문제들

1. **Docker가 실행되지 않음**
   ```bash
   # Docker Desktop 시작 또는
   sudo systemctl start docker
   ```

2. **kubectl 명령어 실패**
   ```bash
   # 클러스터 상태 확인
   kubectl cluster-info
   # 컨텍스트 확인
   kubectl config current-context
   ```

3. **권한 오류**
   ```bash
   # 스크립트 실행 권한 부여
   chmod +x *.sh
   ```

4. **네임스페이스 문제**
   ```bash
   # 네임스페이스 재설정
   kubectl config set-context --current --namespace=lab-day1
   ```

### 환경 정리
```bash
# 실습 환경 정리
./cleanup.sh
```

## 🎓 학습 목표

이 실습을 통해 다음을 학습할 수 있습니다:

- **Kubernetes 아키텍처**: Control Plane과 Worker Node의 구조
- **핵심 컴포넌트**: API Server, ETCD, Controller Manager, Scheduler의 역할
- **데이터 저장**: ETCD에서 Kubernetes 리소스가 저장되는 방식
- **네트워킹**: 클러스터 내부 네트워크 구성
- **보안**: PKI 인증서와 RBAC 설정
- **모니터링**: 로그 분석과 상태 확인 방법

## 📚 참고 자료

- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [ETCD 공식 문서](https://etcd.io/docs/)
- [Kind 사용법](https://kind.sigs.k8s.io/docs/user/quick-start/)

## ⚠️ 주의사항

- 이 스크립트들은 교육 목적으로 설계되었습니다
- 프로덕션 환경에서는 사용하지 마세요
- ETCD 탐험은 읽기 전용으로만 수행됩니다
- 실습 후 반드시 환경을 정리하세요

## 🤝 도움이 필요한 경우

1. 스크립트 실행 중 오류 발생 시 로그 파일 확인
2. 각 스크립트의 상단 주석에서 사용법 확인
3. Kubernetes 공식 문서 참조
4. 강사 또는 동료에게 도움 요청

---

**Happy Learning! 🚀**
