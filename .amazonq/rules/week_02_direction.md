# Week 2 진행 방향 규칙

## 🎯 Week 2 메인 테마
**"Docker 심화 + Kubernetes 준비"**

### 📋 핵심 목표
- Docker 네트워킹, 스토리지, 운영 심화 학습
- 실무 Docker 워크플로우 완전 습득
- Kubernetes 학습을 위한 체계적 준비
- 점진적 난이도 증가로 학습 부담 분산

## 📅 4일 구성 전략

### Day 1: Docker 네트워킹 & 보안 기초
**목표**: 컨테이너 네트워킹 완전 이해 + 기본 보안 적용
- Session 1: Docker 네트워킹 심화 (Bridge, Host, Custom)
- Session 2: 컨테이너 간 통신 & 서비스 디스커버리  
- Session 3: 네트워크 보안 & 방화벽 설정
- Lab 1: 멀티 컨테이너 네트워크 구성
- Lab 2: 보안 강화된 네트워크 환경 구축

### Day 2: Docker 스토리지 & 데이터 관리
**목표**: 데이터 영속성과 관리 전략 완전 습득
- Session 1: Volume, Bind Mount, tmpfs 완전 이해
- Session 2: 데이터 영속성 & 백업 전략
- Session 3: 데이터베이스 컨테이너 운영 실무
- Lab 1: Stateful 애플리케이션 구축
- Lab 2: 데이터 백업 및 복구 시스템

### Day 3: Docker 운영 & 모니터링
**목표**: 프로덕션 운영을 위한 모니터링과 오케스트레이션 기초
- Session 1: 컨테이너 모니터링 & 성능 최적화
- Session 2: 로깅 전략 & 중앙화된 로그 관리
- Session 3: Docker Swarm 기초 & 오케스트레이션 체험
- Lab 1: 운영급 모니터링 시스템 구축
- Lab 2: Docker Swarm 클러스터 구성

### Day 4: Kubernetes 준비 & 마이그레이션
**목표**: Week 3 Kubernetes 학습을 위한 완벽한 준비
- Session 1: Docker vs Kubernetes 비교 분석
- Session 2: Kubernetes 아키텍처 & 핵심 개념
- Session 3: Docker 애플리케이션의 K8s 마이그레이션 전략
- Lab 1: K8s 환경 구축 & 기본 배포
- Lab 2: Docker 앱의 K8s 마이그레이션 실습

## 🔄 학습 연결성

### Week 1 → Week 2 연결
- Docker 기초 명령어 → 네트워킹/스토리지 심화
- 단일 컨테이너 → 멀티 컨테이너 시스템
- 개발 환경 → 운영 환경 고려사항

### Week 2 → Week 3 연결  
- Docker 네트워킹 → K8s Service/Ingress
- Docker 스토리지 → K8s PV/PVC
- Docker Swarm → K8s 클러스터
- 컨테이너 운영 → K8s 운영

## 📊 보안 내용 분산 배치

### 점진적 보안 학습
- **Day 1**: 네트워크 보안 (방화벽, 포트 관리)
- **Day 2**: 데이터 보안 (볼륨 암호화, 시크릿 관리)  
- **Day 3**: 런타임 보안 (모니터링, 로깅)
- **Day 4**: K8s 보안 준비 (RBAC 개념)

### 난이도 조절
- 복잡한 보안 개념을 4일에 걸쳐 분산
- 각 Day의 맥락에 맞는 보안 요소 통합
- 실습을 통한 체험적 보안 학습

## 🎯 성공 지표

### 기술적 성취
- Docker 네트워킹 이해도: 90%
- 데이터 관리 역량: 85%  
- 운영 모니터링 구축: 80%
- K8s 준비도: 75%

### 학습 효과
- 점진적 난이도 증가로 학습 부담 감소
- 실무 연계성 강화
- Week 3 학습 동기 및 기반 확보
- 협업 학습 환경 유지

이 방향으로 Week 2를 진행하여 Docker 심화 학습과 Kubernetes 준비를 동시에 달성합니다.