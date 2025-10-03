# Day 1: Kubernetes 기초 & 클러스터 아키텍처

<div align="center">

**🏗️ Kubernetes 아키텍처 완전 정복** • **🔧 핵심 컴포넌트 심화** • **🚀 실습 중심 학습**

*Kubernetes의 내부 구조와 핵심 컴포넌트를 완전히 이해하는 첫 번째 날*

</div>

---

## 🎯 Day 1 학습 목표

### 📚 핵심 학습 목표
- **Kubernetes 아키텍처**: 클러스터 구조와 핵심 컴포넌트 완전 이해
- **컴포넌트 동작 원리**: API Server, ETCD, Scheduler, Kubelet의 상세 동작
- **실무 진단 기술**: 클러스터 상태 분석 및 문제 해결 능력
- **네트워크 & 보안**: 컴포넌트 간 통신과 인증서 체계 이해

### 🔄 학습 방법론
- **이론 3시간**: 50분 세션 × 3 (아키텍처 → 컴포넌트 → 스케줄러)
- **실습 3시간**: Lab 90분 + Challenge 90분
- **핸즈온 세션**: 강사와 함께하는 30분 실시간 실습

---

## 📚 이론 세션 (3시간)

### Session 1: Kubernetes 아키텍처 & 컴포넌트 (50분)
**파일**: [session1_k8s_architecture.md](session1_k8s_architecture.md)

#### 🎯 핵심 내용
- **Cluster Architecture**: Master-Worker 노드 구조의 비밀
- **Docker vs ContainerD**: 컨테이너 런타임 전쟁의 승자
- **Container Runtime 진화**: Docker 지원 중단의 배경과 대안

#### 🎉 Fun Facts
- K8s 이름의 비밀: Kubernetes = K + 8글자 + s
- Google의 15년 노하우: Borg 시스템의 오픈소스 버전
- 매주 1,000개 컨테이너: Google이 관리하는 컨테이너 규모

#### 📊 시각화 요소
- 클러스터 아키텍처 다이어그램
- 컨테이너 런타임 진화 타임라인
- 컴포넌트 간 통신 흐름도

---

### Session 2: 핵심 컴포넌트 심화 (50분)
**파일**: [session2_core_components.md](session2_core_components.md)

#### 🎯 핵심 내용
- **ETCD**: 분산 시스템의 뇌, Raft 알고리즘 기반 합의
- **API Server**: RESTful API의 마법, 모든 요청의 관문
- **Controller Manager**: 자동화의 핵심, Reconciliation Loop

#### 🎉 Fun Facts
- ETCD 이름: "distributed reliable key-value store"
- API Server 성능: 초당 수천 개 요청 처리 가능
- Controller 개수: 실제로는 40개 이상의 컨트롤러

#### 📊 시각화 요소
- ETCD Raft 합의 알고리즘 시퀀스
- API Server 요청 처리 파이프라인
- Controller Manager Reconciliation Loop

---

### Session 3: 스케줄러 & 에이전트 (50분)
**파일**: [session3_scheduler_agents.md](session3_scheduler_agents.md)

#### 🎯 핵심 내용
- **Kube Scheduler**: 최적 배치 알고리즘 (Filtering → Scoring → Binding)
- **Kubelet**: 노드의 충실한 관리자, Pod 생명주기 관리
- **Kube Proxy**: 네트워크 교통 경찰, iptables/IPVS 규칙 관리

#### 🎉 Fun Facts
- 스케줄링 조건: 100개 이상의 조건을 동시 고려
- Kubelet 통신: 10초마다 heartbeat 전송
- Proxy 모드: iptables, IPVS, userspace 3가지 모드

#### 📊 시각화 요소
- 스케줄링 알고리즘 플로우차트
- Kubelet 아키텍처 다이어그램
- Kube Proxy 모드별 비교

---

## 🛠️ 실습 세션 (3시간)

### Lab 1: 클러스터 구축 & 컴포넌트 탐험 (90분)
**파일**: [lab1_cluster_exploration.md](lab1_cluster_exploration.md)

#### 🎯 실습 목표
- Kind 클러스터 구축 및 컴포넌트 상태 확인
- ETCD 직접 조회 및 API Server 호출
- 네트워크 통신 분석 및 인증서 체인 확인

#### 🔧 주요 실습 내용
1. **클러스터 구축**: Kind로 3노드 클러스터 생성
2. **컴포넌트 분석**: 각 컴포넌트 상태 및 로그 확인
3. **ETCD 탐험**: 클러스터 데이터 직접 조회
4. **API 호출**: kubectl proxy를 통한 직접 API 호출
5. **네트워크 분석**: 포트 사용 현황 및 프로세스 확인

#### 📁 스크립트 파일들
- [setup-environment.sh](lab_scripts/lab1/setup-environment.sh)
- [create-cluster.sh](lab_scripts/lab1/create-cluster.sh)
- [check-components.sh](lab_scripts/lab1/check-components.sh)
- [etcd-exploration.sh](lab_scripts/lab1/etcd-exploration.sh)
- [api-server-test.sh](lab_scripts/lab1/api-server-test.sh)
- [analyze-network.sh](lab_scripts/lab1/analyze-network.sh)
- [analyze-certificates.sh](lab_scripts/lab1/analyze-certificates.sh)

---

### Challenge 1: 고장난 클러스터 복구하기 (90분)
**파일**: [challenge1_cluster_recovery.md](challenge1_cluster_recovery.md)

#### 🎯 Challenge 목표
**시나리오**: TechStart 스타트업의 클러스터에 여러 장애가 발생!
DevOps 엔지니어로서 시스템을 진단하고 복구해야 합니다.

#### ⚠️ 의도적 오류 시나리오
1. **API Server 설정 오류**: 잘못된 포트 설정 (6444 → 6443)
2. **ETCD 연결 문제**: 잘못된 데이터 디렉토리 및 클러스터 상태
3. **Kubelet 인증서 만료**: Worker 노드 통신 불가
4. **CNI 플러그인 오류**: Pod 간 네트워크 통신 실패

#### 🔧 문제 해결 도구
- [diagnose-apiserver.sh](lab_scripts/challenge1/diagnose-apiserver.sh)
- [fix-apiserver.sh](lab_scripts/challenge1/fix-apiserver.sh)
- [diagnose-etcd.sh](lab_scripts/challenge1/diagnose-etcd.sh)
- [fix-etcd.sh](lab_scripts/challenge1/fix-etcd.sh)
- [verify-recovery.sh](lab_scripts/challenge1/verify-recovery.sh)

---

## 🚀 Hands-On Session: 클러스터 탐험 (30분)
**파일**: [hands_on_session.md](hands_on_session.md)

### 🎯 세션 특징
- **강사와 함께**: 실시간으로 따라하며 학습
- **단계별 진행**: 5분씩 나누어 집중도 유지
- **즉시 피드백**: 각 명령어 실행 후 바로 결과 확인
- **질문 유도**: 관찰 포인트와 질문으로 사고 유발

### 📋 진행 순서
1. **클러스터 생성** (5분): Kind로 3노드 클러스터 구축
2. **내부 탐험** (10분): ETCD, API Server, 네트워크 확인
3. **워크로드 배포** (10분): 실제 애플리케이션 배포 및 서비스 생성
4. **실시간 모니터링** (5분): ETCD Watch로 변경사항 관찰

---

## 🎯 성공 기준

### 📊 일일 체크포인트
- [ ] **아키텍처 이해**: 클러스터 컴포넌트 역할 설명 가능
- [ ] **ETCD 조작**: 클러스터 데이터 직접 조회 성공
- [ ] **API 호출**: kubectl 없이 직접 API 호출 성공
- [ ] **장애 복구**: Challenge의 모든 시나리오 해결
- [ ] **네트워크 분석**: 컴포넌트 간 통신 구조 이해

### 🏆 학습 성과
- **기술적 역량**: Kubernetes 아키텍처 완전 이해
- **문제해결 능력**: 클러스터 장애 진단 및 복구
- **실무 적용성**: 프로덕션 환경 관리 기초 습득
- **협업 능력**: 핸즈온 세션을 통한 상호 학습

---

## 📚 추가 학습 자료

### 🔗 참고 링크
- [Kubernetes 공식 문서 - 아키텍처](https://kubernetes.io/docs/concepts/architecture/)
- [ETCD 공식 문서](https://etcd.io/docs/)
- [Container Runtime Interface (CRI)](https://kubernetes.io/docs/concepts/architecture/cri/)

### 📖 권장 도서
- "Kubernetes in Action" - Marko Lukša
- "Programming Kubernetes" - Michael Hausenblas
- "Kubernetes Patterns" - Bilgin Ibryam

### 🎥 추천 영상
- [Kubernetes Deconstructed](https://www.youtube.com/watch?v=90kZRyPcRZw)
- [Life of a Packet](https://www.youtube.com/watch?v=0Omvgd7Hg1I)

---

## 💡 실무 팁

### 🔧 클러스터 관리 베스트 프랙티스
1. **모니터링**: 모든 컴포넌트 상태 지속 모니터링
2. **백업**: ETCD 정기 백업 자동화
3. **보안**: 인증서 만료 추적 및 자동 갱신
4. **업그레이드**: 단계적 클러스터 업그레이드 전략

### 🚨 일반적인 문제와 해결책
- **API Server 응답 없음**: 포트 및 인증서 확인
- **Pod 스케줄링 실패**: 노드 리소스 및 Taint 확인
- **네트워크 통신 오류**: CNI 플러그인 및 DNS 설정 확인
- **ETCD 접근 불가**: 인증서 및 엔드포인트 확인

---

<div align="center">

**🏗️ 아키텍처 마스터** • **🔧 컴포넌트 전문가** • **🚀 실무 준비 완료**

*Day 1을 통해 Kubernetes의 핵심을 완전히 이해했습니다!*

**다음**: [Day 2 - 워크로드 관리 & 스케줄링](../day2/README.md)

</div>