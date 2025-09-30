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

### [Day 3: 컨테이너 보안 & 성능 최적화](./day3/README.md)
**🎯 목표**: 실무에서 필수인 컨테이너 보안과 성능 최적화 기법 완전 습득

#### 📚 이론 강의 (2.5시간)
- **Session 1**: [컨테이너 보안 기초](./day3/session_1.md)
- **Session 2**: [이미지 최적화 & 성능 튜닝](./day3/session_2.md)
- **Session 3**: [모니터링 & 관측성](./day3/session_3.md)

#### 🛠️ 실습 챌린지 (4.5시간)
- **통합 실습**: [보안 & 최적화 통합 실습](./day3/lab_1.md)

---

### [Day 4: Week 1-2 종합 실습 & Docker 마스터리](./day4/README.md)
**🎯 목표**: Week 1-2 전체 기술 스택을 통합하여 실무급 Docker 전문가로 성장

#### 📚 이론 강의 (2.5시간)
- **Session 1**: [Week 1-2 핵심 개념 통합 정리](./day4/session_1.md)
- **Session 2**: [실무 Docker 워크플로우와 베스트 프랙티스](./day4/session_2.md)
- **Session 3**: [오케스트레이션 준비와 학습 로드맵](./day4/session_3.md)

#### 🛠️ 통합 프로젝트 (4.5시간)
- **마스터 프로젝트**: [Week 1-2 통합 마스터 프로젝트](./day4/lab_1.md)

---

## 🛠️ 주간 통합 프로젝트

### 🎯 프로젝트 목표
**"Docker 전문가 → 오케스트레이션 준비 완성"**
- 보안이 강화된 컨테이너 이미지와 런타임 환경
- 성능 최적화된 멀티 컨테이너 애플리케이션
- 포괄적인 모니터링과 관측성 시스템
- Week 3 오케스트레이션 학습을 위한 완벽한 준비

### 📋 프로젝트 요구사항
1. **보안 강화**: 취약점 스캔 통과 및 런타임 보안 적용
2. **성능 최적화**: 이미지 크기 최소화 및 리소스 효율성
3. **모니터링**: Prometheus + Grafana 통합 모니터링 스택
4. **통합 실습**: Week 1-2 모든 기술의 실무급 통합 활용
5. **오케스트레이션 준비**: Docker Swarm 체험 및 Week 3 준비

---

## 📊 주간 평가 기준

### ✅ 이해도 평가
- **네트워킹 심화**: 멀티 호스트 네트워크 구성과 보안
- **스토리지 관리**: 데이터 영속성과 백업 전략
- **보안 & 최적화**: 컨테이너 보안 강화와 성능 최적화
- **통합 역량**: Week 1-2 전체 기술 스택 통합 활용
- **오케스트레이션 준비**: Week 3 학습을 위한 기반 완성

### 🎯 성공 지표
- **네트워킹 이해도**: 90% 이상
- **데이터 관리 역량**: 85% 이상
- **보안 & 최적화**: 90% 이상
- **통합 프로젝트**: 95% 이상
- **오케스트레이션 준비도**: 80% 이상

---

<div align="center">

**🌐 네트워킹 마스터** • **💾 데이터 관리 전문가** • **🔒 보안 전문가** • **⚡ 성능 최적화 마스터** • **🎓 Docker 마스터리 완성**

*Week 2를 통해 Docker 전문가로 성장하고 오케스트레이션 학습 준비를 완벽히 마쳤습니다*

**이전 주**: [Week 1 - DevOps 기초와 문화 이해](../week_01/README.md) | **다음 주**: [Week 3 - Kubernetes 운영과 관리](../week_03/README.md)

</div>