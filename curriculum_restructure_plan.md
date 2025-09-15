# DevOps 과정 커리큘럼 재구성 계획 (KT Cloud 모델 기반)

## 📋 재구성 개요
- **기존**: Week 1 이론 중심 + Week 2-7 실습 중심
- **신규**: KT Cloud 모델 기반 단계적 이론-실습 통합

## 🔄 주차별 재구성 계획

### Week 1: DevOps 기초 + Docker 이론 (80% 이론 + 20% 개념 예시)
**현재 상태**: ✅ 완성 (일부 보강 필요)
**수정 범위**: Docker 이론 추가

#### Day 1: DevOps 개념 및 문화 (기존 유지)
- Session 1: DevOps란 무엇인가? ✅
- Session 2: DevOps 문화와 조직 변화 ✅
- Session 3: 전통적 개발 vs DevOps 개발 ✅
- Session 4: DevOps 도구 생태계 개요 ✅
- Session 5: 애자일과 DevOps의 관계 ✅
- Session 6: CI/CD 파이프라인 개념 ✅
- Session 7: DevOps 성공 사례 분석 ✅
- Session 8: 이론 정리 및 토론 ✅

#### Day 2: 컨테이너 기술 이론 (기존 유지)
- Session 1-8: 컨테이너 기술 아키텍처 중심 ✅

#### Day 3: Docker 개념 및 명령어 체계 (기존 유지)
- Session 1-8: Docker 구조 이해 중심 ✅

#### Day 4: Docker 이미지 관리 이론 (기존 유지)
- Session 1-8: 방법론 중심 ✅

#### Day 5: Docker 네트워킹 및 전체 아키텍처 (기존 유지)
- Session 1-8: 개념 종합 ✅

### Week 2: Kubernetes + 클라우드 보안 이론 (80% 이론 + 20% 개념 예시)
**현재 상태**: 🔄 전면 재구성 필요
**기존**: Docker 실습 → **신규**: Kubernetes + 클라우드 보안 이론

#### Day 1: Kubernetes 기본 개념 및 아키텍처
- Session 1: Kubernetes란 무엇인가?
- Session 2: 컨테이너 오케스트레이션의 필요성
- Session 3: Kubernetes 클러스터 아키텍처
- Session 4: 마스터 노드와 워커 노드
- Session 5: etcd와 API 서버
- Session 6: 스케줄러와 컨트롤러
- Session 7: kubelet과 kube-proxy
- Session 8: 아키텍처 종합 및 토론

#### Day 2: Kubernetes 핵심 오브젝트 이론
- Session 1: Pod 개념과 설계 원리
- Session 2: ReplicaSet과 Deployment
- Session 3: Service와 네트워킹
- Session 4: ConfigMap과 Secret
- Session 5: Volume과 PersistentVolume
- Session 6: Namespace와 리소스 격리
- Session 7: Labels과 Selectors
- Session 8: 오브젝트 관계 및 설계 패턴

#### Day 3: Kubernetes 네트워킹 이론
- Session 1: 클러스터 네트워킹 개념
- Session 2: CNI(Container Network Interface)
- Session 3: Service 타입별 특징
- Session 4: Ingress와 로드 밸런싱
- Session 5: NetworkPolicy와 보안
- Session 6: DNS와 서비스 디스커버리
- Session 7: 멀티 클러스터 네트워킹
- Session 8: 네트워킹 모범 사례

#### Day 4: 클라우드 보안 기초 이론
- Session 1: DevSecOps 개념과 원칙
- Session 2: 컨테이너 보안 위협 모델
- Session 3: 이미지 보안과 취약점 스캔
- Session 4: 런타임 보안과 모니터링
- Session 5: Kubernetes 보안 모델
- Session 6: RBAC과 접근 제어
- Session 7: 네트워크 보안 정책
- Session 8: 보안 모범 사례

#### Day 5: Kubernetes 고급 개념 및 통합
- Session 1: StatefulSet과 상태 관리
- Session 2: DaemonSet과 Job
- Session 3: HPA와 VPA (오토스케일링)
- Session 4: 클러스터 오토스케일링
- Session 5: 헬름(Helm)과 패키지 관리
- Session 6: 커스텀 리소스와 오퍼레이터
- Session 7: Kubernetes 생태계
- Session 8: 이론 종합 및 토론

### Week 3: CI/CD + 모니터링/로깅 이론 (70% 이론 + 30% 개념 실습)
**현재 상태**: 🆕 신규 구성 필요

#### Day 1: CI/CD 파이프라인 이론
- Session 1: CI/CD 개념과 필요성
- Session 2: 지속적 통합(CI) 원리
- Session 3: 지속적 배포(CD) 전략
- Session 4: GitOps와 선언적 배포
- Session 5: 파이프라인 설계 원칙
- Session 6: 테스트 자동화 전략
- Session 7: 배포 패턴과 전략
- Session 8: CI/CD 도구 생태계

#### Day 2: Jenkins와 GitHub Actions 이론
- Session 1: Jenkins 아키텍처
- Session 2: Pipeline as Code
- Session 3: GitHub Actions 워크플로우
- Session 4: 빌드 최적화 전략
- Session 5: 아티팩트 관리
- Session 6: 보안과 시크릿 관리
- Session 7: 멀티 환경 배포
- Session 8: CI/CD 모범 사례

#### Day 3: 모니터링 시스템 이론
- Session 1: 관찰성(Observability) 개념
- Session 2: 메트릭, 로그, 트레이스
- Session 3: Prometheus 아키텍처
- Session 4: 메트릭 수집과 저장
- Session 5: 알림과 임계값 설정
- Session 6: SLI/SLO/SLA 개념
- Session 7: 모니터링 전략
- Session 8: 성능 최적화 방법론

#### Day 4: 로깅 시스템 이론
- Session 1: 중앙집중식 로깅 개념
- Session 2: ELK Stack 아키텍처
- Session 3: 로그 수집과 파싱
- Session 4: 로그 저장과 인덱싱
- Session 5: 로그 분석과 시각화
- Session 6: 로그 보안과 규정 준수
- Session 7: 로그 라이프사이클 관리
- Session 8: 로깅 모범 사례

#### Day 5: Grafana와 시각화 (개념 실습 포함)
- Session 1: Grafana 아키텍처
- Session 2: 대시보드 설계 원리
- Session 3: 데이터 소스 연동
- Session 4: 시각화 유형과 선택
- Session 5: 알림과 노티피케이션
- Session 6: 대시보드 모범 사례
- Session 7: 실습: 기본 대시보드 구성
- Session 8: 모니터링 통합 전략

### Week 4: API Gateway + Service Mesh 이론 (70% 이론 + 30% 개념 실습)
**현재 상태**: 🆕 신규 구성 필요

#### Day 1: 마이크로서비스 아키텍처 이론
- Session 1: 마이크로서비스 개념과 원칙
- Session 2: 모놀리스 vs 마이크로서비스
- Session 3: 서비스 분해 전략
- Session 4: 데이터 관리 패턴
- Session 5: 통신 패턴과 프로토콜
- Session 6: 분산 시스템의 도전과제
- Session 7: 마이크로서비스 설계 원칙
- Session 8: 아키텍처 패턴 종합

#### Day 2: API Gateway 이론
- Session 1: API Gateway 개념과 역할
- Session 2: 라우팅과 로드 밸런싱
- Session 3: 인증과 권한 부여
- Session 4: 속도 제한과 쿼터
- Session 5: API 버전 관리
- Session 6: 캐싱과 성능 최적화
- Session 7: 모니터링과 분석
- Session 8: API Gateway 선택 기준

#### Day 3: Service Mesh 개념
- Session 1: Service Mesh란 무엇인가?
- Session 2: 사이드카 패턴
- Session 3: 데이터 플레인과 컨트롤 플레인
- Session 4: 트래픽 관리
- Session 5: 보안과 mTLS
- Session 6: 관찰성과 텔레메트리
- Session 7: 정책과 거버넌스
- Session 8: Service Mesh 필요성 분석

#### Day 4: Istio 아키텍처 이론
- Session 1: Istio 개요와 구성 요소
- Session 2: Envoy 프록시
- Session 3: Pilot과 트래픽 관리
- Session 4: Citadel과 보안
- Session 5: Galley와 구성 관리
- Session 6: Mixer와 정책/텔레메트리
- Session 7: Istio 설치와 구성
- Session 8: Istio 운영 고려사항

#### Day 5: 통합 아키텍처 설계 (개념 실습 포함)
- Session 1: 전체 아키텍처 설계 원칙
- Session 2: API Gateway + Service Mesh 통합
- Session 3: 보안 아키텍처 설계
- Session 4: 성능과 확장성 고려사항
- Session 5: 장애 복구와 회복력
- Session 6: 실습: 아키텍처 다이어그램 작성
- Session 7: 실습: 설계 문서 작성
- Session 8: 설계 리뷰와 피드백

### Week 5: 클라우드 네트워킹 + IaC 이론 (60% 이론 + 40% 실습)
**현재 상태**: 🆕 신규 구성 필요

### Week 6: 분산 시스템 아키텍처 + 통합 이론 (60% 이론 + 40% 실습)
**현재 상태**: 🆕 신규 구성 필요

### Week 7: 종합 정리 + 실무 연계 준비 (50% 이론 + 50% 실습)
**현재 상태**: 🆕 신규 구성 필요

## 📊 작업 우선순위

### 즉시 작업 (Week 2)
1. **Week 2 전체 재구성**: Kubernetes + 클라우드 보안 이론
2. **40개 세션 신규 작성**: Day 1-5, Session 1-8 각각

### 단계별 작업 (Week 3-7)
1. **Week 3**: CI/CD + 모니터링/로깅 이론 (40개 세션)
2. **Week 4**: API Gateway + Service Mesh 이론 (40개 세션)
3. **Week 5**: 클라우드 네트워킹 + IaC (40개 세션)
4. **Week 6**: 분산 시스템 아키텍처 (40개 세션)
5. **Week 7**: 종합 정리 + 실무 연계 (40개 세션)

## 🎯 추가 구성 요소

### 매주 추가 요소
- **업계 전문가 특강**: 매주 금요일 Session 8 대체
- **아키텍처 설계 과제**: 주간 과제
- **사례 연구 세션**: 매주 수요일 추가
- **취업 준비 역량 테스트**: 격주 실시

### 평가 체계
- **주간 개념 테스트**: 매주 금요일
- **아키텍처 설계 과제**: 격주 제출
- **사례 분석 리포트**: 월 1회
- **최종 통합 프로젝트**: Week 7

## 📅 작업 일정
- **Week 2 재구성**: 즉시 시작
- **Week 3-4 구성**: Week 2 완료 후
- **Week 5-7 구성**: 순차적 진행
- **전체 검토**: 각 주차 완료 후

이 계획으로 진행하시겠습니까?