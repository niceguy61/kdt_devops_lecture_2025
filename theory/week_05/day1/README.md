# Week 5 Day 1: AWS 기초 & 네트워킹

<div align="center">

**🌐 AWS 시작** • **🏗️ VPC 네트워크** • **💻 EC2 배포**

*AWS 클라우드의 첫 걸음*

</div>

---

## 🕘 일일 스케줄

| 시간 | 구분 | 내용 | 비고 |
|------|------|------|------|
| **09:00-09:50** | 📚 이론 1 | Session 1: AWS 기초 개념 (50분) | Region, AZ, VPC 개념 |
| **09:50-10:00** | ☕ 휴식 | 10분 휴식 | |
| **10:00-10:50** | 📚 이론 2 | Session 2: VPC 아키텍처 (50분) | CIDR, Subnet, IGW, Route Table |
| **10:50-11:00** | ☕ 휴식 | 10분 휴식 | |
| **11:00-11:50** | 📚 이론 3 | Session 3: EC2 & Security Groups (50분) | 인스턴스 타입, SG 설정 |
| **11:50-12:00** | ☕ 휴식 | 10분 휴식 | |
| **12:00-12:50** | 🛠️ 실습 1 | Lab 1: VPC 네트워크 인프라 구축 (50분) | VPC, Subnet, IGW, Route Table |
| **12:50-13:00** | ☕ 휴식 | 10분 휴식 | |
| **13:00-14:00** | 🍽️ 점심 | 점심시간 (60분) | |
| **14:00-14:50** | 🛠️ 실습 2 | Lab 2: EC2 웹 서버 배포 (50분) | EC2 배포, Nginx 설치 |
| **14:50-15:00** | ☕ 휴식 | 10분 휴식 | |
| **15:00-15:50** | 🎮 Challenge | Challenge 1: 커뮤니티 사이트 구축 (50분) | 통합 실습 및 평가 |
| **15:50-16:00** | ☕ 휴식 | 10분 휴식 | |
| **16:00-18:00** | 👥 멘토링 | 개별 멘토링 시간 (120분) | 질문, 복습, 심화 학습 |

---

## 🎯 Day 1 학습 목표

### 📚 이론 학습
- [ ] AWS 글로벌 인프라 이해 (Region, AZ, Edge Location)
- [ ] VPC 네트워크 아키텍처 설계
- [ ] EC2 인스턴스 타입 및 선택 기준
- [ ] Security Group 설정 및 보안 원칙

### 🛠️ 실습 목표
- [ ] VPC 네트워크 인프라 완전 구축
- [ ] Multi-AZ Subnet 구성
- [ ] EC2 웹 서버 배포 및 Nginx 설치
- [ ] 실제 접속 가능한 웹 서비스 구축

### 🎮 Challenge 목표
- [ ] Lab 1 + Lab 2 통합 구축
- [ ] 강사 접속 가능한 웹 서버 배포
- [ ] 상세 아키텍처 다이어그램 작성
- [ ] 디스코드 스레드에 결과 제출

---

## 📚 이론 세션

### Session 1: AWS 기초 개념 (09:00-09:50)
**학습 내용**:
- AWS 글로벌 인프라 (Region, AZ, Edge Location)
- 클라우드 컴퓨팅 모델 (IaaS, PaaS, SaaS)
- AWS 계정 구조 (Root, IAM User, Role)
- 프리티어 활용 전략

**문서**: [session_1.md](./session_1.md)

### Session 2: VPC 아키텍처 (10:00-10:50)
**학습 내용**:
- VPC 개념 및 CIDR 블록 설계
- Subnet (Public/Private) 구성
- Internet Gateway & Route Table
- VPC Resource Map 활용

**문서**: [session_2.md](./session_2.md)

### Session 3: EC2 & Security Groups (11:00-11:50)
**학습 내용**:
- EC2 인스턴스 타입 및 선택
- AMI & Key Pair
- Security Groups vs Network ACL
- User Data 초기화

**문서**: [session_3.md](./session_3.md)

### 📖 참고 자료: Session 4
**내용**: 고객 사례 - 블로그 플랫폼 아키텍처
- WordPress + MySQL 구조
- Docker Compose → AWS 마이그레이션
- 실무 아키텍처 패턴

**문서**: [session_4.md](./session_4.md)
**비고**: 일정에 포함되지 않음 (자율 학습)

---

## 🛠️ 실습 세션

### Lab 1: VPC 네트워크 인프라 구축 (12:00-12:50)
**목표**: VPC부터 Route Table까지 완전한 네트워크 인프라 구축

**구축 내용**:
- VPC 생성 (10.0.0.0/16)
- Multi-AZ Subnet 4개 (Public 2개, Private 2개)
- Internet Gateway 생성 및 연결
- Route Table 설정
- VPC Resource Map으로 검증

**문서**: [lab_1.md](./lab_1.md)

### Lab 2: EC2 웹 서버 배포 (14:00-14:50)
**목표**: VPC 위에 EC2 배포 및 웹 서버 구축

**구축 내용**:
- Security Group 생성 (Public/Private)
- Public EC2 2대 배포 (Nginx)
- Private EC2 2대 배포
- 통신 테스트 (Public ↔ Private)

**문서**: [lab_2.md](./lab_2.md)

---

## 🎮 Challenge

### Challenge 1: 커뮤니티 사이트 인프라 구축 (15:00-15:50)
**목표**: Lab 1 + Lab 2 통합하여 실제 서비스 인프라 구축

**요구사항**:
- 기존 VPC 삭제 후 새로운 이름으로 구축
- Public EC2에 커스텀 웹 페이지 배포
- 강사가 접속 가능한 URL 제공
- 상세 아키텍처 다이어그램 작성
- 디스코드 스레드에 제출

**평가 기준**:
- 기능 구현: 40점
- 웹 서버 구현: 30점
- 강사 접속 가능: 20점
- 아키텍처 문서화: 10점

**문서**: [challenge_1.md](./challenge_1.md)

---

## 👥 멘토링 시간 (16:00-18:00)

### 멘토링 내용
- **개별 질문 답변**: 이론 및 실습 관련 질문
- **복습 지원**: 어려웠던 부분 재설명
- **심화 학습**: 추가 학습 자료 제공
- **Challenge 피드백**: 제출한 결과물 리뷰

### 활용 방법
- 이해가 안 되는 개념 질문
- 실습 중 발생한 오류 해결
- Session 4 (참고 자료) 학습
- 다음 Day 예습

---

## 📊 학습 성과 측정

### ✅ 이론 이해도
- [ ] AWS 글로벌 인프라 설명 가능
- [ ] VPC CIDR 블록 설계 가능
- [ ] Security Group 규칙 설정 가능

### ✅ 실습 완성도
- [ ] VPC 네트워크 완전 구축
- [ ] EC2 웹 서버 정상 배포
- [ ] 외부에서 접속 가능

### ✅ Challenge 성과
- [ ] 독립적으로 인프라 구축
- [ ] 강사 접속 가능한 URL 제공
- [ ] 아키텍처 문서화 완료

---

## 💰 예상 비용

| 리소스 | 사용 시간 | 단가 | 예상 비용 |
|--------|----------|------|-----------|
| VPC/Subnet/IGW | 무제한 | 무료 | $0.00 |
| EC2 t2.micro (4대) | 6시간 | $0.0116/hour × 4 | $0.28 |
| **합계** | | | **$0.28** |

**💡 비용 절감 팁**:
- 실습 완료 후 즉시 리소스 정리
- 프리티어 t2.micro 사용
- 불필요한 리소스 생성 방지

---

## 🔗 관련 자료

### 📖 AWS 공식 문서
- [AWS 글로벌 인프라](https://aws.amazon.com/about-aws/global-infrastructure/)
- [VPC 사용자 가이드](https://docs.aws.amazon.com/vpc/latest/userguide/)
- [EC2 사용자 가이드](https://docs.aws.amazon.com/ec2/latest/userguide/)

### 🎯 다음 Day 준비
- [Week 5 Day 2: 컴퓨팅 & 스토리지](../day2/README.md)

---

<div align="center">

**🌐 AWS 시작** • **🏗️ 네트워크 구축** • **💻 서버 배포** • **🎮 실전 Challenge**

*Day 1: AWS 클라우드의 기초를 완전히 마스터하기*

</div>
