# Session 6: CI/CD 파이프라인 개념

## 📍 교과과정에서의 위치
이 세션은 **Week 1 > Day 1 > Session 6**으로, DevOps의 핵심 실천 방법인 CI/CD 파이프라인의 개념을 학습합니다. 이후 Week 2-5에서 학습할 Docker, Kubernetes, 실제 CI/CD 구축의 이론적 기초가 되는 중요한 내용입니다.

## 학습 목표 (5분)
- 지속적 통합(CI)과 지속적 배포(CD)의 개념 이해
- CI/CD 파이프라인의 구성 요소 파악
- CI/CD 도입의 이점과 과제 학습

## 1. 지속적 통합(CI) 개념 (15분)

### CI란?
> "개발자들이 작업한 코드를 정기적으로(최소 하루에 한 번) 메인 브랜치에 통합하는 개발 실천 방법"

**통합 지옥을 방지**하는 가장 효과적인 방법입니다.

### CI 등장 배경
**전통적 방식의 문제**

![Integration Hell](../images/integration-hell.svg)

### CI의 핵심 실천 방법
1. **단일 소스 저장소**: 모든 코드를 하나의 저장소에
2. **빌드 자동화**: 체크인 시 자동 빌드
3. **자동화된 테스트**: 빌드와 함께 테스트 실행
4. **빠른 빌드**: 10분 이내 빌드 완료
5. **매일 커밋**: 최소 하루에 한 번 메인 브랜치에 커밋

### CI 파이프라인 단계
```
코드 커밋 → 빌드 → 단위 테스트 → 통합 테스트 → 정적 분석 → 아티팩트 생성
```

## 2. 지속적 배포(CD) 개념 (15분)

### CD의 두 가지 의미
**자동화 수준에 따른 구분**이 중요:
1. **Continuous Delivery (지속적 전달)**
   - 언제든 배포 가능한 상태 유지
   - 수동 승인 후 배포

2. **Continuous Deployment (지속적 배포)**
   - 모든 변경사항 자동 배포
   - 인간 개입 없이 프로덕션까지

### CD 파이프라인 구조

![CI/CD Pipeline](../images/cicd-pipeline.svg)

### 배포 전략
1. **블루-그린 배포**: 두 개의 동일한 환경 운영
2. **카나리 배포**: 일부 사용자에게만 먼저 배포
3. **롤링 배포**: 점진적으로 인스턴스 교체

## 3. CI/CD의 이점과 과제 (12분)

### 이점
**비즈니스 가치를 직접적으로 제공**하는 5가지 핵심 이점:
1. **빠른 피드백**: 문제를 조기에 발견
2. **위험 감소**: 작은 단위의 변경으로 위험 최소화
3. **배포 속도**: 수동 프로세스 제거로 빠른 배포
4. **품질 향상**: 자동화된 테스트로 일관된 품질
5. **개발자 생산성**: 반복 작업 자동화

### 도입 과제
1. **초기 투자**: 파이프라인 구축 비용
2. **문화 변화**: 기존 프로세스 변경 저항
3. **기술 부채**: 레거시 시스템 통합 어려움
4. **테스트 자동화**: 충분한 테스트 커버리지 필요

### 성공 요인
- **경영진 지원**: Top-down 의지
- **점진적 도입**: 작은 프로젝트부터 시작
- **교육 투자**: 팀 역량 강화
- **도구 표준화**: 일관된 도구 체인

## 실습: CI/CD 파이프라인 설계 (8분)

### 시나리오
"Node.js 웹 애플리케이션을 AWS에 배포하는 CI/CD 파이프라인을 설계해보세요."

### 요구사항
- GitHub 저장소 사용
- 자동화된 테스트 포함
- 3단계 환경 (dev, staging, prod)
- 승인 프로세스 포함

### 그룹 활동 (6분)
1. 파이프라인 단계 정의
2. 사용할 도구 선택
3. 승인 및 롤백 전략 수립

### 발표 (2분)

## 다음 세션 예고
실제 기업들의 DevOps 성공 사례를 분석하고, 실패 사례에서 얻을 수 있는 교훈을 살펴보겠습니다.

## 📚 참고 자료
- [Continuous Integration - Martin Fowler](https://martinfowler.com/articles/continuousIntegration.html)
- [Continuous Delivery vs Deployment](https://www.atlassian.com/continuous-delivery/principles/continuous-integration-vs-delivery-vs-deployment)
- [CI/CD Best Practices - GitLab](https://docs.gitlab.com/ee/ci/pipelines/)
- [Blue-Green Deployment](https://martinfowler.com/bliki/BlueGreenDeployment.html)
- [Canary Releases](https://martinfowler.com/bliki/CanaryRelease.html)