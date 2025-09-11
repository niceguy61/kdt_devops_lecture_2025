# Session 5: 애자일과 DevOps의 관계

## 📍 교과과정에서의 위치
이 세션은 **Week 1 > Day 1 > Session 5**로, DevOps와 밀접한 관련이 있는 애자일 방법론과의 관계를 학습합니다. 두 방법론이 어떻게 상호 보완하며 함께 적용될 수 있는지 이해하여, 실제 조직에서 DevOps 도입 시 애자일과의 통합 전략을 수립할 수 있습니다.

## 학습 목표 (5분)
- 애자일 방법론의 핵심 원칙 이해
- DevOps와 애자일의 공통점과 차이점 파악
- 두 방법론을 함께 적용하는 방법 학습

## 1. 애자일 방법론 개요 (15분)

### 애자일 선언문 (Agile Manifesto)

![Agile Manifesto](../images/agile-manifesto.svg)

### 애자일 12원칙 (핵심 4가지)
1. **고객 만족**: 가치 있는 소프트웨어의 지속적 배포
2. **변화 수용**: 요구사항 변화를 경쟁 우위로 활용
3. **짧은 주기**: 2주-2개월의 짧은 배포 주기
4. **협업**: 개발자와 비즈니스 담당자의 일상적 협력

### 주요 애자일 프레임워크
- **Scrum**: 스프린트 기반 반복 개발
- **Kanban**: 흐름 기반 작업 관리
- **XP (Extreme Programming)**: 기술적 실천 중심

## 2. DevOps와 애자일의 관계 (20분)

### 공통점

![Agile DevOps Venn Diagram](../images/agile-devops-venn.svg)

### 차이점
| 구분 | 애자일 | DevOps |
|------|--------|--------|
| **범위** | 개발 프로세스 | 개발 + 운영 전체 |
| **팀** | 개발팀 중심 | 크로스 펑셔널 팀 |
| **목표** | 빠른 개발 | 빠른 배포 + 안정적 운영 |
| **측정** | 속도, 품질 | MTTR, MTBF, 배포 빈도 |

### 상호 보완 관계
**두 방법론은 서로 다른 문제를 해결**:
- **애자일**: "무엇을" 빠르게 만들 것인가
- **DevOps**: "어떻게" 빠르게 배포하고 운영할 것인가

## 3. 통합 적용 방법 (8분)

### DevOps + Scrum 통합 모델
```
Sprint Planning → Development → CI/CD → Production → Monitoring
     ↑                                                    ↓
     ←←←←←←←←← Sprint Review ←←←←←←←←←←←←←←←←←←←←←←←←←←
```

### 실천 방법
**애자일과 DevOps를 효과적으로 결합**하는 방법:
1. **스프린트 내 배포**: 매 스프린트마다 프로덕션 배포
2. **자동화된 파이프라인**: 개발 완료 즉시 배포 가능
3. **통합 회고**: 개발 + 운영 이슈 함께 검토
4. **공유 메트릭**: 비즈니스 + 기술 지표 통합 관리

### 조직 구조 변화
**Before**: 개발팀 → QA팀 → 운영팀
**After**: Feature Team (개발자 + QA + DevOps 엔지니어)

## 실습: 통합 프로세스 설계 (7분)

### 시나리오
"전자상거래 웹사이트를 운영하는 팀에서 애자일과 DevOps를 함께 도입하려고 합니다."

### 그룹 활동 (5분)
1. 2주 스프린트 계획 수립
2. CI/CD 파이프라인 통합 지점 설계
3. 회고 프로세스에 운영 메트릭 포함 방안

### 발표 및 토론 (2분)

## 다음 세션 예고
CI/CD 파이프라인의 구체적인 개념과 구성 요소를 자세히 알아보겠습니다.

## 📚 참고 자료
- [Agile Manifesto](https://agilemanifesto.org/)
- [Scrum Guide](https://scrumguides.org/)
- [DevOps and Agile - Atlassian](https://www.atlassian.com/agile/devops)
- [Kanban vs Scrum](https://www.atlassian.com/agile/kanban/kanban-vs-scrum)
- [Extreme Programming (XP)](http://www.extremeprogramming.org/)