# November Week 1 Day 1 Session 2: EC2 (Elastic Compute Cloud)

<div align="center">

**🖥️ 가상 서버** • **⚡ 탄력적 확장** • **💰 다양한 과금 모델**

*AWS의 핵심 컴퓨팅 서비스 EC2 완벽 이해*

</div>

---

## 🕘 세션 정보
**시간**: 09:20-09:40 (20분)
**목표**: EC2 인스턴스 타입 선택 및 비용 최적화 전략 습득

---

## 📖 서비스 개요

### 1. 생성 배경 (Why?)

**문제 상황**:
- **온프레미스 서버 구매**: 초기 투자 5천만원~1억원, 설치 2-3주 소요
- **확장성 부족**: 트래픽 급증 시 대응 불가 (블랙프라이데이, 이벤트)
- **유지보수 부담**: 24/7 모니터링, 하드웨어 교체, 보안 패치
- **자원 낭비**: 평균 사용률 10-20%, 나머지 80-90% 유휴

**AWS EC2 솔루션**:
- **즉시 생성**: 클릭 몇 번으로 5분 이내 서버 생성
- **탄력적 확장**: Auto Scaling으로 자동 확장/축소
- **사용한 만큼 지불**: 초 단위 과금 (최소 60초)
- **관리 부담 감소**: AWS가 하드웨어 관리, 사용자는 OS부터 관리

---

### 2. 핵심 원리 (How?)

**EC2 아키텍처**:
```
EC2 인스턴스
├── Hypervisor (Xen/Nitro)
│   └── 가상화 계층
├── AMI (Amazon Machine Image)
│   ├── OS (Amazon Linux, Ubuntu, Windows)
│   └── 사전 설치 소프트웨어
├── Instance Type
│   ├── vCPU (가상 CPU 코어)
│   ├── Memory (RAM)
│   ├── Storage (EBS/Instance Store)
│   └── Network (대역폭)
├── EBS Volume
│   └── 영구 스토리지
├── Security Group
│   └── 가상 방화벽
└── Key Pair
    └── SSH 접근 키
```

**작동 원리**:
1. **가상화**: Nitro System으로 물리 서버를 여러 가상 인스턴스로 분할
2. **AMI 선택**: OS 및 소프트웨어 템플릿 선택
3. **Instance Type**: CPU/메모리/네트워크 사양 선택
4. **네트워크**: VPC/Subnet에 배치, Security Group 설정
5. **스토리지**: EBS 볼륨 연결 (영구 저장)
6. **실행**: 부팅 후 SSH/RDP로 접속

**Nitro System**:
- **전용 하드웨어**: CPU 가상화, 스토리지, 네트워킹을 전용 칩으로 처리
- **성능 향상**: 호스트 CPU 부담 감소, 거의 베어메탈 수준 성능
- **보안 강화**: 하드웨어 수준 격리, 암호화

---

### 3. 주요 사용 사례 (When?)

**적합한 경우**:
- **웹 서버**: Apache, Nginx, IIS
- **애플리케이션 서버**: Java, Node.js, Python, .NET
- **데이터베이스**: MySQL, PostgreSQL, MongoDB (자체 관리)
- **배치 처리**: 데이터 분석, ETL, 렌더링
- **개발/테스트**: 개발 환경, CI/CD

**실제 사례**:
- **Netflix**: 10만+ EC2 인스턴스로 스트리밍 서비스
- **Airbnb**: 검색 엔진 및 예약 시스템
- **Slack**: 메시징 백엔드 서버
- **Spotify**: 음악 추천 알고리즘 처리

---

### 4. 비슷한 서비스 비교 (Which?)

**AWS 내 대안 서비스**:
- **EC2** vs **Lambda**
  - 언제 EC2: 지속적 실행, 상태 유지, 복잡한 애플리케이션, 15분 이상 실행
  - 언제 Lambda: 이벤트 기반, 짧은 실행(< 15분), 서버리스, 간헐적 사용

- **EC2** vs **Lightsail**
  - 언제 EC2: 세밀한 제어, 복잡한 아키텍처, Auto Scaling, 엔터프라이즈
  - 언제 Lightsail: 간단한 웹사이트, 고정 가격($3.50/월~), 초보자, WordPress

- **EC2** vs **ECS/EKS**
  - 언제 EC2: 단일 애플리케이션, 컨테이너 불필요, 레거시 앱
  - 언제 ECS/EKS: 마이크로서비스, 컨테이너 오케스트레이션, 복잡한 배포

**선택 기준**:
| 기준 | EC2 | Lambda | Lightsail | ECS/EKS |
|------|-----|--------|-----------|---------|
| 제어 수준 | 완전 제어 | 제한적 | 간단 | 중간 |
| 비용 | 시간당 | 요청당 | 고정 월 | 시간당 |
| 확장성 | Auto Scaling | 자동 무한 | 수동 | 자동 |
| 관리 부담 | 높음 | 없음 | 낮음 | 중간 |
| 학습 곡선 | 높음 | 중간 | 낮음 | 높음 |

---

### 5. 장단점 분석

**장점**:
- ✅ **완전한 제어**: OS, 소프트웨어, 설정 모두 제어 가능
- ✅ **다양한 선택**: 750+ 인스턴스 타입, 모든 워크로드 지원
- ✅ **유연한 확장**: 수직(인스턴스 크기), 수평(인스턴스 수) 확장
- ✅ **온프레미스 마이그레이션**: 기존 애플리케이션 쉽게 이전
- ✅ **다양한 과금 모델**: On-Demand, Reserved, Spot (최대 90% 할인)

**단점/제약사항**:
- ⚠️ **서버 관리 필요**: OS 패치, 보안 업데이트, 모니터링
- ⚠️ **비용 예측 어려움**: 사용량 변동 시 비용 변동
- ⚠️ **초기 학습 곡선**: 인스턴스 타입, 네트워킹, 보안 설정
- ⚠️ **중지 시 EBS 비용**: 인스턴스 중지해도 스토리지 비용 발생

**대안**:
- 관리 부담 감소: Lambda, Fargate (서버리스)
- 비용 예측: Lightsail (고정 가격)
- 간단한 사용: Elastic Beanstalk (PaaS)

---

### 6. 비용 구조 💰

**과금 방식**:

**1. On-Demand (온디맨드)**:
- 초 단위 과금 (최소 60초)
- 약정 없음, 언제든 시작/중지
- 가장 비싸지만 유연함
- 용도: 개발/테스트, 예측 불가능한 워크로드

**2. Reserved Instance (예약 인스턴스)**:
- 1년 또는 3년 약정
- 최대 72% 할인
- 선불 옵션: 전액 선불 > 부분 선불 > 선불 없음
- 용도: 안정적인 프로덕션 워크로드

**3. Spot Instance (스팟 인스턴스)**:
- 경매 방식, 최대 90% 할인
- AWS가 회수 가능 (2분 전 통지)
- 용도: 배치 처리, 데이터 분석, 중단 가능한 작업

**4. Savings Plans (절감 플랜)**:
- 시간당 사용량 약정 ($/hour)
- 최대 72% 할인
- 인스턴스 타입 변경 가능
- 용도: 유연한 장기 워크로드

**프리티어 혜택** (12개월):
- **t3.micro**: 750시간/월 무료 (Linux/Windows)
- **30GB EBS**: gp2 또는 gp3
- **2백만 IO**: EBS 입출력
- **1GB 스냅샷**: EBS 백업

**비용 최적화 팁**:
1. **인스턴스 타입 최적화**: 워크로드에 맞는 타입 선택 (CPU vs 메모리)
2. **Spot Instance 활용**: 배치 작업, 개발 환경에 90% 할인
3. **Auto Scaling**: 필요할 때만 실행, 유휴 시간 제거
4. **Reserved Instance**: 장기 실행 워크로드 72% 할인
5. **중지 vs 종료**: 중지 시 EBS 비용 발생, 불필요하면 종료
6. **Graviton 인스턴스**: 동일 성능에 20-40% 저렴 (ARM 기반)
7. **Compute Optimizer**: AWS 추천 인스턴스 타입 확인

**리전별 가격 (t3.micro, Linux)**:
| Region | 위치 | On-Demand | Reserved (1년) | Spot (평균) |
|--------|------|-----------|----------------|-------------|
| us-east-1 | 버지니아 | $0.0104/h | $0.0062/h (40% 할인) | $0.0031/h (70% 할인) |
| ap-northeast-2 | 서울 | $0.0116/h | $0.0070/h (40% 할인) | $0.0035/h (70% 할인) |
| ap-northeast-1 | 도쿄 | $0.0152/h | $0.0091/h (40% 할인) | $0.0046/h (70% 할인) |

**Lab 예상 비용**:
- t3.micro 1시간: $0 (프리티어 750시간/월)
- EBS 8GB: $0 (프리티어 30GB)
- 데이터 전송: $0 (프리티어 100GB/월)
- **합계**: **$0**

---

### 7. 최신 업데이트 🆕

**2024년 주요 변경사항**:
- **Graviton4 프로세서** (2024.11): 
  - 40% 성능 향상 (vs Graviton3)
  - 60% 에너지 효율 개선
  - I8g 인스턴스 출시 (스토리지 최적화)
- **Nitro System v5**: 하드웨어 암호화 강화
- **EBS gp3 기본값**: 더 나은 성능/가격 (gp2 대비 20% 저렴)
- **IMDSv2 기본 활성화**: 보안 강화 (SSRF 공격 방어)
- **M8g/R8g 인스턴스**: Graviton4 기반, 최대 192 vCPU

**2025년 예정**:
- **Graviton5 프로세서**: 더 높은 성능
- **더 큰 인스턴스**: 메모리 최적화 (1TB+ RAM)
- **AI 가속기 통합**: 추론 최적화 인스턴스

**Deprecated 기능**:
- **EC2-Classic**: 2022년 종료 (VPC 필수)
- **IMDSv1**: 2025년 단계적 종료 예정
- **일부 구형 인스턴스**: M4, C4, R4 (신규 생성 불가)

**참조**: 
- [EC2 What's New](https://aws.amazon.com/ec2/whats-new/)
- [Graviton4 발표](https://aws.amazon.com/blogs/aws/introducing-storage-optimized-amazon-ec2-i8g-instances-powered-by-aws-graviton4-processors-and-3rd-gen-aws-nitro-ssds/)

---

### 8. 잘 사용하는 방법 ✅

**베스트 프랙티스**:
1. **IAM Role 사용**: Access Key 대신 Role 부여 (보안)
2. **태그 전략**: 비용 추적 (Environment, Project, Owner)
3. **AMI 백업**: 정기적인 스냅샷 (주간/월간)
4. **모니터링**: CloudWatch 알람 (CPU > 80%, 디스크 > 90%)
5. **보안 그룹**: 최소 권한 원칙 (필요한 포트만 오픈)
6. **Multi-AZ 배포**: 고가용성 (최소 2개 AZ)
7. **Auto Scaling**: 자동 확장/축소

**실무 팁**:
- **인스턴스 메타데이터**: 동적 설정 활용 (http://169.254.169.254/latest/meta-data/)
- **User Data**: 초기화 스크립트 자동화 (Docker 설치, 앱 배포)
- **Placement Groups**: 
  - Cluster: 낮은 지연시간 (HPC)
  - Spread: 고가용성 (다른 하드웨어)
  - Partition: 대규모 분산 (Hadoop, Kafka)
- **Elastic IP**: 고정 IP 필요 시만 사용 (미사용 시 과금)
- **Hibernate**: 중지 대신 최대 절전 (메모리 상태 보존)

**성능 최적화**:
- **EBS 최적화**: gp3 사용, IOPS/처리량 조정
- **Enhanced Networking**: SR-IOV 활성화 (높은 PPS)
- **T 시리즈 CPU 크레딧**: 모니터링 및 Unlimited 모드
- **Nitro 인스턴스**: 최신 세대 선택 (더 나은 성능)

---

### 9. 잘못 사용하는 방법 ❌

**흔한 실수**:
1. **Root 계정 사용**: IAM User/Role 사용 필수
2. **Security Group 전체 오픈**: 0.0.0.0/0 SSH(22) 허용 금지
3. **Access Key 하드코딩**: 코드에 키 포함 금지 (IAM Role 사용)
4. **백업 없음**: 정기 스냅샷 필수 (주간/월간)
5. **모니터링 미설정**: 장애 감지 불가, 비용 폭탄
6. **과도한 인스턴스 크기**: 필요 이상 큰 타입 선택 (비용 낭비)
7. **중지된 인스턴스 방치**: EBS 비용 계속 발생

**안티 패턴**:
- **단일 AZ 배포**: 고가용성 부족 (AZ 장애 시 전체 중단)
- **수동 확장**: Auto Scaling 미사용 (트래픽 급증 대응 불가)
- **태그 미사용**: 비용 추적 불가, 리소스 관리 어려움
- **프리티어 초과**: 750시간/월 초과 시 과금 (여러 인스턴스 주의)
- **Spot 인스턴스 오용**: 중요한 프로덕션에 사용 (회수 위험)

**보안 취약점**:
- **Public Subnet에 DB**: Private Subnet 사용 필수
- **SSH 키 공유**: 개인별 키 사용, 정기 교체
- **패치 미적용**: 정기 업데이트 필수 (보안 취약점)
- **로그 미수집**: CloudWatch Logs, 감사 추적 불가
- **암호화 미사용**: EBS 암호화, 전송 중 암호화 (TLS)

---

### 10. 구성 요소 상세

**주요 구성 요소**:

**1. AMI (Amazon Machine Image)**:
- **역할**: OS 및 소프트웨어 템플릿
- **종류**:
  - Amazon Linux 2023 (AWS 최적화, 무료)
  - Ubuntu (20.04, 22.04, 24.04)
  - Windows Server (2019, 2022)
  - Red Hat Enterprise Linux (RHEL)
  - Custom AMI (직접 생성)
- **선택 기준**: 워크로드, 라이선스, 보안 요구사항

**2. Instance Type (인스턴스 타입)**:
- **범용 (T, M)**: 
  - T3/T4g: 버스트 가능, 웹 서버, 개발
  - M5/M6g: 균형잡힌 성능, 애플리케이션 서버
- **컴퓨팅 최적화 (C)**:
  - C5/C6g: CPU 집약적, 배치 처리, HPC
- **메모리 최적화 (R, X)**:
  - R5/R6g: 메모리 집약적, 데이터베이스, 캐시
  - X2: 대용량 메모리 (최대 4TB)
- **스토리지 최적화 (I, D)**:
  - I3/I4g: 고성능 SSD, NoSQL, 데이터 웨어하우스
  - D3: HDD, 빅데이터, 로그 처리
- **가속 컴퓨팅 (P, G, Inf)**:
  - P4/P5: GPU, ML 훈련
  - G5: GPU, 그래픽 렌더링
  - Inf2: AWS Inferentia, ML 추론

**3. EBS (Elastic Block Store)**:
- **gp3**: 범용 SSD (기본 권장, 3000 IOPS)
- **gp2**: 이전 세대 범용 SSD
- **io2**: 고성능 SSD (최대 64,000 IOPS)
- **st1**: 처리량 최적화 HDD (빅데이터)
- **sc1**: 콜드 HDD (아카이브)

**4. Security Group**:
- **Inbound Rules**: 들어오는 트래픽 제어
- **Outbound Rules**: 나가는 트래픽 제어
- **Stateful**: 응답 트래픽 자동 허용
- **예시**:
  - SSH: 22 (본인 IP만)
  - HTTP: 80 (0.0.0.0/0)
  - HTTPS: 443 (0.0.0.0/0)
  - MySQL: 3306 (애플리케이션 서버만)

**5. Key Pair**:
- **SSH 접근**: Linux 인스턴스 (.pem 파일)
- **RDP 접근**: Windows 인스턴스 (비밀번호 복호화)
- **보안**: 개인 키 안전 보관 필수 (chmod 400)

**설정 옵션**:
- **Tenancy**: 
  - Shared (기본): 다른 고객과 하드웨어 공유
  - Dedicated Instance: 전용 하드웨어
  - Dedicated Host: 물리 서버 전체 임대
- **Monitoring**: 
  - Basic (무료): 5분 간격
  - Detailed ($): 1분 간격
- **Termination Protection**: 실수 삭제 방지
- **Stop Protection**: 실수 중지 방지

**의존성**:
- **VPC**: 네트워크 환경 필수
- **Subnet**: 인스턴스 배치 위치 (AZ 결정)
- **IAM Role**: AWS 서비스 접근 권한
- **EBS**: 영구 스토리지 (루트 볼륨 + 추가 볼륨)
- **Security Group**: 방화벽 규칙

---

### 11. 공식 문서 링크 (필수 5개)

**⚠️ 학생들이 직접 확인해야 할 공식 문서**:
- 📘 [EC2란 무엇인가?](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html)
- 📗 [EC2 사용자 가이드](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/)
- 📙 [EC2 인스턴스 타입](https://aws.amazon.com/ec2/instance-types/)
- 📕 [EC2 요금](https://aws.amazon.com/ec2/pricing/)
- 🆕 [EC2 최신 업데이트](https://aws.amazon.com/ec2/whats-new/)

---

## 📊 실습 연계

**Lab 1에서 구현**:
- t3.micro 인스턴스 생성 (프리티어)
- Amazon Linux 2023 AMI
- Security Group 설정 (SSH 22, HTTP 80)
- Docker 설치 및 웹 서버 배포

**주의사항**:
- 프리티어 한도 확인 (750시간/월)
- 실습 후 즉시 종료 (중지 시 EBS 비용)
- Key Pair 안전 보관 (분실 시 접속 불가)

---

<div align="center">

**🖥️ 가상 서버** • **⚡ 탄력적 확장** • **💰 비용 최적화** • **🔒 보안 강화**

*EC2를 이해하고 최적의 인스턴스 타입 선택*

</div>
