# Week 3 Day 2 Challenge 2: 워크로드 아키텍처 구현 챌린지 (선택사항, 90분)

<div align="center">

**🏗️ 아키텍처 설계** • **📊 시각화 분석** • **📝 문서화**

*Pod부터 Deployment까지 학습한 워크로드를 활용한 실무 아키텍처 구현*

</div>

---

## 🎯 Challenge 목표

### 📚 학습 목표
- **워크로드 설계**: Pod, ReplicaSet, Deployment 조합 설계
- **스케줄링 전략**: Label, Taint/Toleration, Affinity 활용
- **실무 문서화**: 기술적 의사결정 과정 문서화

### 🛠️ 구현 목표
- **GitHub Repository**: 코드와 문서의 체계적 관리
- **클러스터 시각화**: 배포된 워크로드의 시각적 분석
- **분석 보고서**: 설계 결정사항과 개선 방안 도출

---

## 🌐 도메인 준비 (필요시)

### 📋 무료 도메인 발급 가이드
**외부 접근이 필요한 서비스를 위해 도메인을 준비하세요.**

👉 **[무료 도메인 발급 가이드](../../shared/free-domain-guide.md)** 참조

---

## 🏗️ 구현 시나리오

### 📖 비즈니스 상황
**"게임 회사의 멀티플레이어 서버 아키텍처 설계"**

온라인 게임 회사에서 새로운 멀티플레이어 게임을 출시합니다. 
서버 아키텍처를 Kubernetes 워크로드로 설계해야 합니다.

### 🎮 서비스 구성 요구사항
1. **게임 로비 서버**: 사용자 매칭 및 대기실 관리
2. **게임 룸 서버**: 실제 게임 진행 (CPU 집약적)
3. **채팅 서버**: 실시간 채팅 (메모리 집약적)
4. **랭킹 서버**: 점수 계산 및 순위 관리
5. **모니터링 에이전트**: 모든 노드에서 성능 수집

### 📋 기술 요구사항
- **게임 로비**: 안정성 우선 (3개 복제본, 롤링 업데이트)
- **게임 룸**: 성능 우선 (CPU 최적화 노드 배치)
- **채팅 서버**: 확장성 우선 (HPA 준비, 메모리 최적화)
- **랭킹 서버**: 데이터 일관성 (단일 인스턴스, 재시작 정책)
- **모니터링**: 모든 노드 배치 (DaemonSet)

### 🎯 스케줄링 제약사항
- **고성능 노드**: `node-type=high-performance` 라벨
- **일반 노드**: `node-type=standard` 라벨
- **게임 룸 서버**: 고성능 노드 전용 배치
- **채팅 서버**: 일반 노드 우선, 고성능 노드 허용
- **기타 서비스**: 노드 타입 무관

---

## 📁 GitHub Repository 구조

### 필수 디렉토리 구조
```
game-server-k8s/
├── README.md                           # 프로젝트 개요
├── k8s-manifests/                      # Kubernetes 매니페스트
│   ├── namespaces/
│   │   └── game-namespace.yaml
│   ├── workloads/
│   │   ├── lobby-deployment.yaml       # 게임 로비 서버
│   │   ├── gameroom-deployment.yaml    # 게임 룸 서버
│   │   ├── chat-deployment.yaml       # 채팅 서버
│   │   ├── ranking-deployment.yaml     # 랭킹 서버
│   │   └── monitoring-daemonset.yaml  # 모니터링 에이전트
│   └── scheduling/
│       ├── node-labels.yaml           # 노드 라벨링
│       └── taints-tolerations.yaml    # Taint/Toleration 설정
├── docs/                               # 분석 문서
│   ├── architecture-analysis.md       # 아키텍처 분석 보고서
│   └── screenshots/                   # 시각화 캡처 이미지
│       ├── cluster-overview.png
│       ├── workload-distribution.png
│       └── resource-usage.png
└── scripts/                           # 배포/관리 스크립트
    ├── deploy-all.sh                  # 전체 배포
    ├── setup-nodes.sh                 # 노드 설정
    └── cleanup.sh                     # 환경 정리
```

---

## 📊 시각화 도구 활용

### 🛠️ 권장 시각화 도구
1. **Kubernetes Dashboard**: 전체 클러스터 개요
2. **K9s**: 실시간 워크로드 상태
3. **kubectl tree**: 리소스 계층 구조
4. **Lens**: 네트워크 토폴로지

### 📸 필수 캡처 항목
- **전체 워크로드 분포**: 네임스페이스별 Pod 배치
- **노드별 리소스 사용**: CPU/Memory 사용률
- **스케줄링 결과**: 각 워크로드의 노드 배치 현황
- **롤링 업데이트**: 업데이트 과정 시각화

---

## 📝 분석 보고서 템플릿

### `docs/architecture-analysis.md` 구조
```markdown
# 게임 서버 아키텍처 분석 보고서

## 🎯 설계 개요
### 전체 아키텍처
[Mermaid 다이어그램 또는 캡처 이미지]

### 워크로드 분류
| 서비스 | 워크로드 타입 | 복제본 수 | 스케줄링 전략 | 이유 |
|--------|---------------|-----------|---------------|------|
| 게임 로비 | Deployment | 3 | 노드 분산 | 고가용성 |
| 게임 룸 | Deployment | 5 | 고성능 노드 | CPU 집약적 |
| 채팅 서버 | Deployment | 2 | 메모리 최적화 | 실시간 통신 |
| 랭킹 서버 | Deployment | 1 | 일반 노드 | 데이터 일관성 |
| 모니터링 | DaemonSet | N | 모든 노드 | 전체 수집 |

## 🏗️ 주요 설계 결정사항

### 1. 워크로드 타입 선택
**게임 룸 서버를 Deployment로 선택한 이유:**
- 

**모니터링을 DaemonSet으로 선택한 이유:**
- 

### 2. 스케줄링 전략
**고성능 노드 전용 배치 구현:**
```yaml
# 구현한 스케줄링 설정 예시
nodeSelector:
  node-type: high-performance
```

**Anti-Affinity 적용 이유:**
- 

### 3. 리소스 할당 전략
**각 워크로드별 리소스 설정 근거:**
- 

## 📈 장점 분석
1. **성능 최적화**: 
2. **확장성**: 
3. **안정성**: 
4. **운영 효율성**: 

## ⚠️ 단점 및 제약사항
1. **리소스 오버헤드**: 
2. **복잡성**: 
3. **단일 장애점**: 

## 🔧 개선 방안
### 즉시 적용 가능 (1주 이내)
- [ ] 
- [ ] 

### 단기 개선 (1개월 이내)
- [ ] 
- [ ] 

### 장기 개선 (3개월 이내)
- [ ] 
- [ ] 

## 📊 시각화 결과 분석
### 클러스터 전체 현황
![클러스터 개요](screenshots/cluster-overview.png)
**분석**: 

### 워크로드 분산 현황
![워크로드 분포](screenshots/workload-distribution.png)
**분석**: 

### 리소스 사용률
![리소스 사용](screenshots/resource-usage.png)
**분석**: 

## 🎓 학습 인사이트
### 가장 어려웠던 점
- 

### 새롭게 알게 된 점
- 

### 실무 적용 시 고려사항
- 

## 🚀 다음 단계 계획
- 
```

---

## 📋 제출 방법

### 1. GitHub Repository 생성
- **Repository 이름**: `w3d2-game-server-architecture`
- **Public Repository**로 설정
- **README.md**에 프로젝트 개요 작성

### 2. Discord 제출
```
📝 제출 형식:
**팀명**: [팀 이름]
**GitHub**: [Repository URL]
**완료 시간**: [HH:MM]
**핵심 특징**: [설계의 핵심 포인트 한 줄]
**어려웠던 점**: [가장 고민했던 부분]
```

### 3. 상호 리뷰 (선택)
- 다른 팀의 Repository 방문
- Issues나 Discussions로 피드백 제공

---

## ⏰ 진행 일정

### 📅 시간 배분
```
1. 아키텍처 설계 (20분)
   - 요구사항 분석
   - 워크로드 타입 결정
   - 스케줄링 전략 수립

2. 구현 및 배포 (40분)
   - YAML 파일 작성
   - 클러스터 배포
   - 동작 확인

3. 시각화 및 분석 (20분)
   - 시각화 도구로 캡처
   - 분석 보고서 작성

4. 문서화 및 제출 (10분)
   - GitHub 정리
   - Discord 제출
```

---

## 🏆 성공 기준

### ✅ 필수 달성 목표
- [ ] 5개 워크로드 모두 정상 배포
- [ ] 스케줄링 제약사항 적용 확인
- [ ] 시각화 캡처 3개 이상
- [ ] 분석 보고서 완성
- [ ] GitHub Repository 정리

### 🌟 우수 달성 목표
- [ ] 창의적인 스케줄링 전략 적용
- [ ] 상세한 성능 분석
- [ ] 실무 적용 가능한 개선 방안
- [ ] 다른 팀과의 적극적 피드백

---

## 💡 힌트 및 팁

### 🔧 구현 팁
- **노드 라벨링**: `kubectl label nodes <node-name> node-type=high-performance`
- **DaemonSet 확인**: `kubectl get ds -o wide`
- **스케줄링 확인**: `kubectl get pods -o wide`

### 📊 시각화 팁
- **K9s 단축키**: `:pods` → Enter로 Pod 목록
- **Dashboard 접근**: `kubectl proxy` 후 브라우저 접속
- **Tree 플러그인**: `kubectl tree deployment <name>`

### 📝 문서 작성 팁
- **구체적 수치**: "빠르다" → "응답시간 100ms 이내"
- **근거 제시**: 모든 설계 결정에 이유 명시
- **시각 자료**: 텍스트보다 이미지와 표 활용

---

<div align="center">

**🏗️ 실무 아키텍처** • **📊 데이터 기반 분석** • **🤝 협업 경험** • **📚 포트폴리오**

*워크로드 관리 학습을 실무 프로젝트로 승화시키는 종합 챌린지*

</div>
