# Week 3 Day 2: 워크로드 관리 & 스케줄링

<div align="center">

**🚀 Pod부터 Deployment까지** • **📊 스케줄링 마스터리** • **⚖️ 리소스 관리**

*Kubernetes 워크로드의 계층적 구조와 정교한 스케줄링 전략*

</div>

---

## 🕘 일일 스케줄

### 📊 시간 배분
```
📚 이론 강의: 2.5시간 (50분×3세션) - 오전 집중 학습
🛠️ 실습 세션: 2.5시간 (90분×2세션) - 당일 학습 적용
👥 학생 케어: 2시간 - 개별 맞춤 지원
```

### 🗓️ 상세 스케줄
| 시간 | 구분 | 내용 | 목적 |
|------|------|------|------|
| **09:00-09:50** | 📚 이론 1 | 기본 워크로드 객체 (50분) | Pod, ReplicaSet, Deployment |
| **09:50-10:00** | ☕ 휴식 | 10분 휴식 | |
| **10:00-10:50** | 📚 이론 2 | 고급 스케줄링 (50분) | Labels, Taints, Affinity |
| **10:50-11:00** | ☕ 휴식 | 10분 휴식 | |
| **11:00-11:50** | 📚 이론 3 | 리소스 관리 & 특수 워크로드 (50분) | Resources, DaemonSet, Jobs |
| **11:50-12:00** | ☕ 휴식 | 10분 휴식 | |
| **12:00-13:30** | 🛠️ 실습 1 | 워크로드 배포 & 관리 (90분) | 단계별 배포 실습 |
| **13:30-14:30** | 🍽️ 점심 | 점심시간 (60분) | |
| **14:30-16:00** | 🛠️ 실습 2 | Challenge 2: 배포 재해 시나리오 (90분) | 문제 해결 실습 |
| **16:00-18:00** | 👥 케어 | 개별 멘토링 및 심화 학습 (120분) | 맞춤형 지원 |

---

## 🎯 일일 학습 목표

### 📚 핵심 학습 목표
- **워크로드 계층 구조**: Pod → ReplicaSet → Deployment의 관계 완전 이해
- **스케줄링 메커니즘**: 라벨링, Taint/Toleration, Affinity 전략 마스터
- **리소스 관리**: CPU/Memory 제한과 QoS 클래스 이해
- **특수 워크로드**: DaemonSet, Job, CronJob의 실무 활용

### 🤝 협업 학습 목표
- **페어 프로그래밍**: 복잡한 YAML 작성 시 역할 분담
- **팀 토론**: 스케줄링 전략의 장단점 비교 분석
- **상호 멘토링**: 배포 문제 해결 과정 공유
- **집단 지성**: Challenge 해결을 위한 협력적 문제 해결

### 🚀 실무 연계 목표
- **프로덕션 배포**: 무중단 배포 전략 수립
- **리소스 최적화**: 비용 효율적인 리소스 할당
- **장애 대응**: 배포 실패 시나리오 대응 능력
- **모니터링 연계**: 워크로드 상태 추적 방법

---

## 📚 이론 세션 구성

### [Session 1: 기본 워크로드 객체](./session_1.md) (09:00-09:50)
**🎯 핵심 키워드**: Pod 설계 철학, ReplicaSet 진화, Deployment 무중단 배포

**학습 포커스**: Kubernetes 워크로드의 기본 단위들과 계층적 관계

### [Session 2: 고급 스케줄링](./session_2.md) (10:00-10:50)
**🎯 핵심 키워드**: Labels & Selectors, Taints & Tolerations, Node/Pod Affinity

**학습 포커스**: 정교한 Pod 배치 전략과 스케줄링 최적화

### [Session 3: 리소스 관리 & 특수 워크로드](./session_3.md) (11:00-11:50)
**🎯 핵심 키워드**: Resource Limits, QoS Classes, DaemonSet, Jobs

**학습 포커스**: 리소스 관리와 특수 목적 워크로드 활용

---

## 🛠️ 실습 세션 구성

### [Lab 1: 워크로드 배포 & 관리](./lab_1.md) (12:00-13:30)
**🎯 목표**: 다양한 워크로드 타입을 실제로 배포하고 관리

**실습 내용**:
- **단계별 배포**: Pod → ReplicaSet → Deployment 순차 생성
- **스케줄링 실습**: 라벨링과 노드 선택 전략
- **롤링 업데이트**: 무중단 배포 체험
- **리소스 관리**: CPU/Memory 제한 설정

### [Challenge 2: 배포 재해 시나리오](./challenge_2.md) (14:30-16:00)
**🎯 목표**: 배포 과정에서 발생할 수 있는 다양한 문제 해결

**Challenge 시나리오**:
- **시나리오 1**: 잘못된 이미지로 인한 배포 실패
- **시나리오 2**: 리소스 부족으로 인한 스케줄링 실패  
- **시나리오 3**: 롤링 업데이트 중 서비스 중단
- **시나리오 4**: 노드 장애 시 Pod 재배치

---

## 🎓 학습 성과 측정

### ✅ 세션별 체크포인트

**Session 1 완료 후**:
- [ ] Pod, ReplicaSet, Deployment의 관계 설명 가능
- [ ] 각 워크로드 타입의 용도와 특징 이해
- [ ] YAML 매니페스트 작성 및 해석 가능

**Session 2 완료 후**:
- [ ] 라벨링 시스템의 활용 방법 이해
- [ ] Taint/Toleration 메커니즘 설명 가능
- [ ] Affinity 규칙을 이용한 배치 전략 수립

**Session 3 완료 후**:
- [ ] 리소스 제한과 QoS 클래스 이해
- [ ] DaemonSet과 Job의 실무 활용 사례 파악
- [ ] 특수 워크로드의 적절한 사용 시점 판단

### 📊 실습 성과 지표

**Lab 1 성과**:
- [ ] 모든 워크로드 타입 성공적 배포
- [ ] 롤링 업데이트 무중단 수행
- [ ] 리소스 제한 설정 및 모니터링

**Challenge 2 성과**:
- [ ] 4개 시나리오 모두 해결 (목표: 90분 내)
- [ ] 문제 진단부터 해결까지 체계적 접근
- [ ] 팀 협업을 통한 효율적 문제 해결

### 🏆 일일 종합 평가

**기술적 역량 (40%)**:
- Kubernetes 워크로드 관리 능력
- 스케줄링 전략 수립 및 적용
- 리소스 최적화 및 문제 해결

**협업 및 소통 (30%)**:
- 페어 프로그래밍 참여도
- 팀 토론에서의 기여도
- 지식 공유 및 상호 학습

**문제 해결 (20%)**:
- Challenge 해결 속도 및 정확성
- 창의적 접근 방법
- 장애 상황 대응 능력

**학습 태도 (10%)**:
- 적극적 참여 및 질문
- 피드백 수용 및 개선
- 지속적 학습 의지

---

## 🔗 연계 학습

### 📖 사전 학습 (Day 1 복습)
- Kubernetes 클러스터 아키텍처
- 핵심 컴포넌트의 역할과 상호작용
- kubectl 기본 명령어 숙달

### 🚀 다음 학습 (Day 3 예고)
- 네트워킹과 서비스 디스커버리
- 스토리지와 데이터 영속성
- Ingress와 외부 접근 관리

### 🌟 심화 학습 (선택사항)
- Kubernetes Operator 패턴
- Custom Resource Definition (CRD)
- Advanced Scheduling 기법

---

## 📚 참고 자료

### 🔗 공식 문서
- [Kubernetes Workloads](https://kubernetes.io/docs/concepts/workloads/)
- [Managing Resources](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [Assigning Pods to Nodes](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)

### 📖 추천 도서
- "Kubernetes in Action" - Marko Lukša
- "Programming Kubernetes" - Michael Hausenblas
- "Kubernetes Patterns" - Bilgin Ibryam

### 🎥 학습 영상
- [Kubernetes Workloads Explained](https://www.youtube.com/watch?v=example)
- [Advanced Scheduling in Kubernetes](https://www.youtube.com/watch?v=example)

---

<div align="center">

**🚀 워크로드 마스터리** • **📊 스케줄링 전문가** • **⚖️ 리소스 최적화**

*Kubernetes 워크로드 관리의 모든 것을 마스터하는 하루*

</div>
