# November Week 1 Day 1: AWS 기초 & 컴퓨팅 서비스

<div align="center">

**☁️ AWS 글로벌 인프라** • **🖥️ EC2** • **⚡ Lambda**

*AWS의 기본 개념과 핵심 컴퓨팅 서비스 이해*

</div>

---

## 🕘 일일 스케줄

| 시간 | 구분 | 내용 | 파일 |
|------|------|------|------|
| **09:00-09:20** | 📚 이론 1 | AWS 글로벌 인프라 | [session_1.md](./session_1.md) |
| **09:20-09:40** | 📚 이론 2 | EC2 (Elastic Compute Cloud) | [session_2.md](./session_2.md) |
| **09:40-10:00** | 📚 이론 3 | Lambda (서버리스) | [session_3.md](./session_3.md) |
| **10:00-11:00** | 🛠️ 실습 | EC2 인스턴스 생성 및 웹 서버 배포 | [lab_1.md](./lab_1.md) |

---

## 🎯 학습 목표

### 📚 이론 목표
- AWS 글로벌 인프라 구조 이해 (Region, AZ, Edge Location)
- EC2 인스턴스 타입 및 선택 기준 파악
- Lambda 서버리스 컴퓨팅 개념 이해
- 각 서비스의 비용 구조 및 최적화 방법 습득

### 🛠️ 실습 목표
- EC2 인스턴스 생성 및 접속
- Docker 설치 및 웹 서버 배포
- Security Group 설정
- 프리티어 활용 전략 수립

---

## 📖 세션 개요

### Session 1: AWS 글로벌 인프라 (20분)
**핵심 내용**:
- Region, Availability Zone, Edge Location 개념
- 리전 선택 기준 (지연시간, 규정 준수, 비용)
- 고가용성 아키텍처 설계
- 2024-2025년 신규 리전 정보

**학습 포인트**:
- 왜 여러 AZ에 리소스를 분산 배치해야 하는가?
- 리전별 가격 차이는 얼마나 되는가?
- 최신 리전 추가 현황은?

### Session 2: EC2 (Elastic Compute Cloud) (20분)
**핵심 내용**:
- EC2 아키텍처 및 가상화 원리
- 인스턴스 타입 분류 (T, M, C, R, I 시리즈)
- AMI, Security Group, Key Pair
- 비용 모델 (On-Demand, Reserved, Spot)

**학습 포인트**:
- 워크로드에 맞는 인스턴스 타입 선택 방법
- 비용을 최대 90%까지 절감하는 방법
- Graviton3 프로세서의 장점은?

### Session 3: Lambda (서버리스) (20분)
**핵심 내용**:
- 서버리스 컴퓨팅 개념
- Lambda 함수 구조 (Handler, Runtime, Trigger)
- 이벤트 기반 아키텍처
- 콜드 스타트 최적화

**학습 포인트**:
- EC2와 Lambda 중 언제 무엇을 선택해야 하는가?
- Lambda 비용 계산 방법
- Node.js 22 런타임의 새로운 기능은?

---

## 🛠️ 실습 개요

### Lab 1: EC2 인스턴스 생성 및 웹 서버 배포 (60분)

**실습 목표**:
- t3.micro 인스턴스 생성 (프리티어)
- Docker 설치 및 Nginx 컨테이너 실행
- Security Group으로 HTTP(80), SSH(22) 포트 오픈
- 웹 브라우저로 접속 확인

**예상 비용**: $0 (프리티어 750시간/월)

**주요 단계**:
1. VPC 및 Subnet 확인
2. Security Group 생성
3. EC2 인스턴스 생성 (Amazon Linux 2023)
4. SSH 접속 및 Docker 설치
5. Nginx 컨테이너 실행
6. 웹 브라우저 접속 확인

---

## 💰 예상 비용 (프리티어 활용)

| 리소스 | 사용량 | 프리티어 | 예상 비용 |
|--------|--------|----------|-----------|
| EC2 t3.micro | 1시간 | 750시간/월 | $0 |
| EBS 8GB | 1시간 | 30GB | $0 |
| 데이터 전송 | 1GB | 100GB/월 | $0 |
| **합계** | | | **$0** |

---

## 📚 사전 준비

### 필수 준비사항
- [ ] AWS 계정 생성 (프리티어)
- [ ] MFA 설정 완료
- [ ] IAM User 생성 (관리자 권한)
- [ ] SSH 클라이언트 설치 (Windows: PuTTY, Mac/Linux: 기본 제공)

### 권장 사전 학습
- 클라우드 컴퓨팅 기본 개념
- 리눅스 기본 명령어
- Docker 기초 (Week 1-2에서 학습한 내용)

---

## 🔗 참고 자료

### AWS 공식 문서
- [AWS 글로벌 인프라](https://aws.amazon.com/about-aws/global-infrastructure/)
- [EC2 사용자 가이드](https://docs.aws.amazon.com/ec2/)
- [Lambda 개발자 가이드](https://docs.aws.amazon.com/lambda/)
- [AWS 프리티어](https://aws.amazon.com/free/)

### 추가 학습 자료
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [AWS 아키텍처 센터](https://aws.amazon.com/architecture/)

---

## ✅ 학습 체크리스트

### 이론 이해도
- [ ] Region, AZ, Edge Location의 차이를 설명할 수 있다
- [ ] EC2 인스턴스 타입 분류를 이해하고 선택 기준을 안다
- [ ] Lambda와 EC2의 차이점과 사용 시나리오를 안다
- [ ] 각 서비스의 비용 구조를 이해하고 최적화 방법을 안다

### 실습 완료
- [ ] EC2 인스턴스를 생성하고 접속할 수 있다
- [ ] Security Group을 설정하고 포트를 오픈할 수 있다
- [ ] Docker를 설치하고 컨테이너를 실행할 수 있다
- [ ] 웹 브라우저로 배포한 서비스에 접속할 수 있다

---

## 🎯 다음 학습

### Day 2 (11/4 화): 네트워킹 & 스토리지
- VPC (Virtual Private Cloud)
- S3 (Simple Storage Service)
- EBS vs EFS

---

<div align="center">

**☁️ AWS 기초** • **🖥️ 컴퓨팅 서비스** • **💰 비용 최적화** • **🛠️ 실전 배포**

*AWS의 핵심 컴퓨팅 서비스를 이해하고 실무에 적용*

</div>
