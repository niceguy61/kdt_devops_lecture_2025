# Week 2: Docker 심화 + Kubernetes 준비

<div align="center">

**🌐 네트워킹 심화** • **💾 스토리지 관리** • **📊 운영 모니터링** • **☸️ K8s 준비**

*Docker 실무 운영 완성과 Kubernetes 학습을 위한 체계적 준비*

![Week 2](https://img.shields.io/badge/Week-2-blue?style=for-the-badge)
![Docker](https://img.shields.io/badge/Docker-Advanced-green?style=for-the-badge)
![Networking](https://img.shields.io/badge/Networking-Deep-purple?style=for-the-badge)
![Kubernetes](https://img.shields.io/badge/K8s-Ready-orange?style=for-the-badge)

</div>

---

## 🎯 주간 학습 목표

### 📚 전체 공통 목표
> **Docker 네트워킹, 스토리지, 운영 심화 학습을 통해 실무 역량을 완성하고, Kubernetes 학습을 위한 체계적 기반을 구축한다**

### 🎪 레벨별 목표
- **🟢 초급자**: Docker 네트워킹/스토리지 기초 + 기본 모니터링 + K8s 개념 이해
- **🟡 중급자**: 멀티 호스트 네트워킹 + 데이터 관리 전략 + 운영 자동화 + K8s 실습
- **🔴 고급자**: 엔터프라이즈 아키텍처 + 성능 최적화 + 고급 모니터링 + K8s 마이그레이션 전략

---

## 📅 일일 학습 계획 (4일 구성)

### [Day 1: Docker 네트워킹 & 보안 기초](./day1/README.md)
**🎯 목표**: 컨테이너 네트워킹 완전 이해 + 기본 보안 적용

#### 📚 이론 강의 (2.5시간)
- **Session 1**: [Docker 네트워킹 심화 (Bridge, Host, Custom)](./day1/session_1.md)
- **Session 2**: [컨테이너 간 통신 & 서비스 디스커버리](./day1/session_2.md)
- **Session 3**: [네트워크 보안 & 방화벽 설정](./day1/session_3.md)

#### 🛠️ 실습 챌린지 (2.5시간)
- **Lab 1**: [멀티 컨테이너 네트워크 구성](./day1/lab_1.md)
- **Lab 2**: [보안 강화된 네트워크 환경 구축](./day1/lab_2.md)

---

### [Day 2: Docker 스토리지 & 데이터 관리](./day2/README.md)
**🎯 목표**: 데이터 영속성과 관리 전략 완전 습득

#### 📚 이론 강의 (2.5시간)
- **Session 1**: [Volume, Bind Mount, tmpfs 완전 이해](./day2/session_1.md)
- **Session 2**: [데이터 영속성 & 백업 전략](./day2/session_2.md)
- **Session 3**: [데이터베이스 컨테이너 운영 실무](./day2/session_3.md)

#### 🛠️ 실습 챌린지 (2.5시간)
- **Lab 1**: [Stateful 애플리케이션 구축](./day2/lab_1.md)
- **Lab 2**: [데이터 백업 및 복구 시스템](./day2/lab_2.md)

---

### [Day 3: Docker 운영 & 모니터링](./day3/README.md)
**🎯 목표**: 프로덕션 운영을 위한 모니터링과 오케스트레이션 기초

#### 📚 이론 강의 (2.5시간)
- **Session 1**: [컨테이너 모니터링 & 성능 최적화](./day3/session_1.md)
- **Session 2**: [로깅 전략 & 중앙화된 로그 관리](./day3/session_2.md)
- **Session 3**: [Docker Swarm 기초 & 오케스트레이션 체험](./day3/session_3.md)

#### 🛠️ 실습 챌린지 (2.5시간)
- **Lab 1**: [운영급 모니터링 시스템 구축](./day3/lab_1.md)
- **Lab 2**: [Docker Swarm 클러스터 구성](./day3/lab_2.md)

---

### [Day 4: Kubernetes 준비 & 마이그레이션](./day4/README.md)
**🎯 목표**: Week 3 Kubernetes 학습을 위한 완벽한 준비

#### 📚 이론 강의 (2.5시간)
- **Session 1**: [Docker vs Kubernetes 비교 분석](./day4/session_1.md)
- **Session 2**: [Kubernetes 아키텍처 & 핵심 개념](./day4/session_2.md)
- **Session 3**: [Docker 애플리케이션의 K8s 마이그레이션 전략](./day4/session_3.md)

#### 🛠️ 실습 챌린지 (2.5시간)
- **Lab 1**: [K8s 환경 구축 & 기본 배포](./day4/lab_1.md)
- **Lab 2**: [Docker 앱의 K8s 마이그레이션 실습](./day4/lab_2.md)

---

## 🛠️ 주간 통합 프로젝트

### 🎯 프로젝트 목표
**"Docker 심화 → Kubernetes 준비 완성"**
- 네트워킹과 스토리지가 최적화된 멀티 컨테이너 시스템
- 운영급 모니터링과 로깅 환경 구축
- Kubernetes 마이그레이션 준비가 완료된 애플리케이션

### 📋 프로젝트 요구사항
1. **고급 네트워킹**: 커스텀 네트워크와 서비스 디스커버리
2. **데이터 관리**: 영속성 보장과 백업 전략 구현
3. **운영 모니터링**: 실시간 성능 모니터링과 알림 시스템
4. **K8s 준비**: Kubernetes 배포 가능한 매니페스트 작성
5. **마이그레이션**: Docker → K8s 전환 계획 수립

---

## 📊 주간 평가 기준

### ✅ 이해도 평가
- **네트워킹 심화**: 멀티 호스트 네트워크 구성과 보안
- **스토리지 관리**: 데이터 영속성과 백업 전략
- **운영 역량**: 모니터링, 로깅, 성능 최적화
- **K8s 준비도**: 아키텍처 이해와 마이그레이션 계획

### 🎯 성공 지표
- **네트워킹 이해도**: 90% 이상
- **데이터 관리 역량**: 85% 이상
- **운영 시스템 구축**: 80% 이상
- **K8s 준비도**: 75% 이상

---

<div align="center">

**🌐 네트워킹 마스터** • **💾 데이터 관리 전문가** • **📊 운영 전문가** • **☸️ K8s 준비 완료**

*Week 2를 통해 Docker 심화 역량을 완성하고 Kubernetes 학습 준비를 마쳤습니다*

**이전 주**: [Week 1 - DevOps 기초와 문화 이해](../week_01/README.md) | **다음 주**: [Week 3 - Kubernetes 운영과 관리](../week_03/README.md)

</div>