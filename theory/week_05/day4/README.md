# Week 5 Day 4: 로드밸런싱 & 고가용성

<div align="center">

**⚖️ 로드 밸런싱** • **📈 자동 확장** • **🏗️ Multi-AZ** • **📰 실무 사례**

*완전한 고가용성 아키텍처 구축*

</div>

---

## 🎯 일일 목표

> **ALB + ASG + Multi-AZ를 통한 완전한 고가용성 아키텍처 구축**

- AWS 로드 밸런서 종류와 특징 이해
- Auto Scaling Groups 동작 원리 및 컨테이너 레지스트리 전략
- Multi-AZ 고가용성 아키텍처 설계
- 실제 뉴스 플랫폼 사례를 통한 통합 적용

## ⏰ 일일 스케줄

```
09:00-09:50  Session 1: Elastic Load Balancing (50분) + 10분 휴식
10:00-10:50  Session 2: Auto Scaling Groups & 컨테이너 레지스트리 (50분) + 10분 휴식  
11:00-11:50  Session 3: 고가용성 아키텍처 설계 (50분) + 10분 휴식
12:00-12:50  Session 4: 고객 사례 - News & Media 플랫폼 (50분) + 10분 휴식
13:00-14:00  점심시간 (60분)
14:00-14:50  Lab 1: ALB + ASG 구성 (50분) + 10분 휴식
15:00-15:50  Challenge: 고가용성 아키텍처 구현 (50분)
```

## 📚 이론 세션 (4시간)

### [Session 1: Elastic Load Balancing](./session_1.md) (09:00-09:50)
**핵심 주제**: AWS 로드 밸런서 종류와 특징
- **ALB vs NLB vs CLB** 비교 및 선택 기준
- **Target Groups & Health Check** 설정 방법
- **고급 라우팅 규칙** (경로, 호스트, 헤더 기반)
- **실무 사례**: Netflix 로드 밸런싱 전략

**🎯 학습 성과**: 상황별 적절한 로드 밸런서 선택 및 설정 능력

### [Session 2: Auto Scaling Groups & 컨테이너 레지스트리](./session_2.md) (10:00-10:50)
**핵심 주제**: 자동 확장과 컨테이너 이미지 관리
- **ASG 동작 원리** 및 Launch Template 설정
- **스케일링 정책** (Target Tracking, Step, Simple)
- **GHCR vs ECR** 비교 및 선택 전략
- **실무 사례**: 쿠팡 11번가 세일 대응

**🎯 학습 성과**: 트래픽 패턴에 따른 자동 확장 전략 수립

### [Session 3: 고가용성 아키텍처 설계](./session_3.md) (11:00-11:50)
**핵심 주제**: Multi-AZ 배포와 장애 복구
- **Multi-AZ 배포 전략** 및 가용성 계산
- **장애 복구 메커니즘** (RTO/RPO)
- **Blue-Green vs Canary** 배포 전략
- **실무 사례**: 카카오톡 장애 분석

**🎯 학습 성과**: 99.99% 가용성을 위한 아키텍처 설계 능력

### [Session 4: 고객 사례 - News & Media 플랫폼](./session_4.md) (12:00-12:50)
**핵심 주제**: Ghost CMS 기반 뉴스 플랫폼 아키텍처
- **Ghost CMS 아키텍처** 및 특수 요구사항
- **트래픽 급증 대응** (속보 시 100배 증가)
- **읽기 최적화** 및 글로벌 배포 전략
- **실무 사례**: CNN, WHO 발표 시 트래픽 패턴

**🎯 학습 성과**: Day 1-4 학습 내용의 통합 적용 능력

## 🛠️ 실습 세션 (2시간)

### [Lab 1: ALB + ASG 구성](./lab_1.md) (14:00-14:50)
**목표**: 기본 고가용성 아키텍처 구축
- **Launch Template** 생성 및 설정
- **Application Load Balancer** 구성
- **Auto Scaling Group** 생성 및 정책 설정
- **부하 테스트** 및 스케일링 확인

**구축 아키텍처**:
```
사용자 → ALB → ASG (Min:2, Max:6) → Target Group → EC2 인스턴스들
```

### [Challenge: 고가용성 아키텍처 구현](./challenge_1.md) (15:00-15:50)
**목표**: 완전한 Multi-AZ 고가용성 시스템 구축
- **Multi-AZ 인프라** 설계 및 구현
- **Web Tier**: ALB + ASG
- **App Tier**: Internal ALB + ASG  
- **DB Tier**: Multi-AZ RDS
- **장애 테스트** 시나리오 수행

**구축 아키텍처**:
```
Route 53 → CloudFront → ALB → Multi-AZ ASG → Internal ALB → App ASG → Multi-AZ RDS
```

## 🔗 추가 자료

### 📋 ECR 통합 가이드
- **[GitHub Actions + ECR 완전 가이드](./ECR_GITHUB_ACTIONS_GUIDE.md)**: OIDC 설정부터 자동 배포까지

### 🎯 핵심 AWS 서비스

**로드 밸런싱**:
- ![ALB](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Networking-Content-Delivery/48/Arch_Elastic-Load-Balancing_48.svg) **Application Load Balancer**: L7 로드 밸런서
- ![Target Group](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Networking-Content-Delivery/48/Arch_Elastic-Load-Balancing_48.svg) **Target Groups**: 트래픽 대상 그룹 관리

**자동 확장**:
- ![ASG](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Compute/48/Arch_Amazon-EC2-Auto-Scaling_48.svg) **Auto Scaling Groups**: 자동 서버 확장/축소
- ![Launch Template](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Compute/48/Arch_Amazon-EC2_48.svg) **Launch Template**: 서버 생성 템플릿

**컨테이너 레지스트리**:
- ![ECR](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Containers/48/Arch_Amazon-Elastic-Container-Registry_48.svg) **Amazon ECR**: AWS 컨테이너 레지스트리
- **GitHub Container Registry**: GitHub 통합 레지스트리

## 📊 학습 성과 측정

### ✅ 이론 이해도 체크
- [ ] **ALB와 NLB의 차이점**을 설명할 수 있다
- [ ] **ASG 스케일링 정책**을 설계할 수 있다
- [ ] **Multi-AZ 아키텍처**의 장점을 이해한다
- [ ] **Blue-Green vs Canary** 배포 차이를 안다

### 🛠️ 실습 완성도 체크
- [ ] **ALB + Target Group** 정상 구성
- [ ] **ASG 자동 확장** 동작 확인
- [ ] **부하 테스트** 성공적 수행
- [ ] **Multi-AZ 장애 복구** 테스트 완료

### 🎯 실무 적용도 체크
- [ ] **트래픽 급증 시나리오** 대응 방안 수립
- [ ] **컨테이너 레지스트리** 선택 기준 이해
- [ ] **고가용성 아키텍처** 설계 원칙 습득
- [ ] **비용 vs 성능** 균형점 파악

## 🔄 Day 간 연계성

### 📈 이전 Day 연계
- **Day 1**: VPC + EC2 기반 위에 로드 밸런싱 추가
- **Day 2**: S3 + CloudFront와 ALB 통합 구성
- **Day 3**: RDS + ElastiCache와 ASG 연동

### 🚀 다음 Day 예고
- **Day 5**: CloudMart 프로젝트에 Day 4 고가용성 패턴 적용
- **통합 아키텍처**: 전체 AWS 서비스를 하나의 프로덕션 시스템으로 완성

## 💰 예상 비용

### 일일 실습 비용 (12명 기준)
| 리소스 | 수량 | 사용 시간 | 단가 | 예상 비용 |
|--------|------|----------|------|-----------|
| **ALB** | 12개 | 2시간 | $0.0225/hour | $0.54 |
| **EC2 (t3.micro)** | 36개 | 2시간 | $0.0104/hour | $0.75 |
| **Data Transfer** | - | - | 프리티어 | $0.00 |
| **합계** | | | | **$1.29** |

**💡 비용 절약 팁**:
- 프리티어 ALB 시간 활용
- 실습 후 즉시 리소스 정리
- ASG Max Size 제한으로 과도한 확장 방지

## 🔍 트러블슈팅 가이드

### 자주 발생하는 문제
1. **ALB Health Check 실패**
   - Target Group 포트 설정 확인
   - Security Group Inbound 규칙 점검

2. **ASG 확장 안 됨**
   - CloudWatch 메트릭 확인
   - Scaling Policy 임계값 점검

3. **Launch Template 오류**
   - AMI ID 유효성 확인
   - User Data 스크립트 문법 점검

## 🎯 성공 기준

### 기술적 성취
- **ALB + ASG** 정상 동작 확인
- **자동 확장/축소** 테스트 성공
- **Multi-AZ 장애 복구** 시나리오 완료
- **부하 테스트** 목표 성능 달성

### 실무 역량
- **고가용성 아키텍처** 설계 능력
- **트래픽 패턴 분석** 및 대응 전략
- **컨테이너 레지스트리** 선택 및 활용
- **비용 최적화** 고려사항 이해

---

<div align="center">

**⚖️ 로드 밸런싱** • **📈 자동 확장** • **🏗️ 고가용성** • **🚀 실무 적용**

*Day 4를 통해 완전한 고가용성 아키텍처 구축 역량을 갖추게 됩니다*

</div>
