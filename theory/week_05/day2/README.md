# Week 5 Day 2: 컴퓨팅 & 스토리지

<div align="center">

**💾 EBS 스토리지** • **📦 S3 객체 스토리지** • **🌐 CloudFront CDN**

*데이터 영속성과 콘텐츠 배포*

</div>

---

## 🕘 일일 스케줄

| 시간 | 구분 | 내용 | 비고 |
|------|------|------|------|
| **09:00-09:50** | 📚 이론 1 | Session 1: EC2 심화 (50분) | 생명주기, Elastic IP, Session Manager |
| **09:50-10:00** | ☕ 휴식 | 10분 휴식 | |
| **10:00-10:50** | 📚 이론 2 | Session 2: EBS 스토리지 (50분) | 볼륨 타입, 스냅샷, 암호화 |
| **10:50-11:00** | ☕ 휴식 | 10분 휴식 | |
| **11:00-11:50** | 📚 이론 3 | Session 3: S3 & CloudFront (50분) | 객체 스토리지, CDN, 정적 호스팅 |
| **11:50-12:00** | ☕ 휴식 | 10분 휴식 | |
| **12:00-12:50** | 🛠️ 실습 1 | Lab 1: EBS 볼륨 관리 (50분) | 볼륨 추가, 스냅샷, 복원 |
| **12:50-13:00** | ☕ 휴식 | 10분 휴식 | |
| **13:00-14:00** | 🍽️ 점심 | 점심시간 (60분) | |
| **14:00-14:50** | 🛠️ 실습 2 | Lab 2: S3 정적 웹 호스팅 (50분) | S3 버킷, CloudFront 배포 |
| **14:50-15:00** | ☕ 휴식 | 10분 휴식 | |
| **15:00-15:50** | 🎮 Challenge | Challenge 1: 블로그 플랫폼 구축 (50분) | EC2 + EBS + S3 + CloudFront |
| **15:50-16:00** | ☕ 휴식 | 10분 휴식 | |
| **16:00-18:00** | 👥 멘토링 | 개별 멘토링 시간 (120분) | 질문, 복습, 심화 학습 |

---

## 🎯 Day 2 학습 목표

### 📚 이론 학습
- [ ] EC2 인스턴스 생명주기 및 고급 기능 이해
- [ ] EBS 볼륨 타입별 특징 및 선택 기준
- [ ] S3 스토리지 클래스 및 사용 사례
- [ ] CloudFront CDN 동작 원리

### 🛠️ 실습 목표
- [ ] EC2에 EBS 볼륨 추가 및 관리
- [ ] EBS 스냅샷 생성 및 복원
- [ ] S3 정적 웹 호스팅 구성
- [ ] CloudFront로 글로벌 콘텐츠 배포

### 🎮 Challenge 목표
- [ ] EC2 + EBS + S3 + CloudFront 통합
- [ ] 블로그 플랫폼 완전 구축
- [ ] 데이터 영속성 및 CDN 적용
- [ ] 강사 접속 가능한 URL 제공

---

## 📚 이론 세션

### Session 1: EC2 심화 (09:00-09:50)
**학습 내용**:
- EC2 인스턴스 생명주기 (Launch, Stop, Terminate)
- Elastic IP & ENI (Elastic Network Interface)
- EC2 Instance Connect
- Systems Manager Session Manager
- CloudWatch 기본 모니터링

**Day 1 연계**:
- Day 1에서 EC2 기본 배포 학습
- Day 2에서 EC2 고급 관리 학습

**문서**: session_1.md (생성 예정)

### Session 2: EBS 스토리지 (10:00-10:50)
**학습 내용**:
- EBS 볼륨 타입 비교 (gp3, gp2, io2, st1, sc1)
- EBS 스냅샷 & 백업 전략
- EBS 암호화 (at-rest, in-transit)
- EBS vs Instance Store 비교
- 볼륨 크기 조정 및 성능 최적화

**실무 연계**:
- 데이터베이스 스토리지 선택
- 백업 및 재해 복구 전략
- 비용 최적화

**문서**: session_2.md (생성 예정)

### Session 3: S3 & CloudFront (11:00-11:50)
**학습 내용**:
- S3 버킷 생성 및 정책
- S3 스토리지 클래스 (Standard, IA, Glacier)
- S3 정적 웹 호스팅
- CloudFront CDN 아키텍처
- 오리진 및 캐싱 동작

**실무 연계**:
- 정적 파일 관리 (이미지, CSS, JS)
- 글로벌 콘텐츠 배포
- 비용 효율적 스토리지

**문서**: session_3.md (생성 예정)

---

## 🛠️ 실습 세션

### Lab 1: EBS 볼륨 관리 & 데이터 영속성 (12:00-12:50)
**목표**: EC2에 EBS 볼륨 추가 및 스냅샷 관리

**구축 내용**:
1. **Day 1 VPC 활용**: 기존 VPC 및 EC2 사용
2. **EBS 볼륨 생성**: gp3 볼륨 생성 (10GB)
3. **볼륨 연결**: EC2에 연결 및 마운트
4. **데이터 저장**: 테스트 데이터 저장
5. **스냅샷 생성**: 백업 생성
6. **볼륨 복원**: 스냅샷에서 새 볼륨 생성
7. **검증**: 데이터 무결성 확인

**아키텍처**:
```
EC2 Instance
├── Root Volume (gp3, 8GB) - OS
└── Data Volume (gp3, 10GB) - 애플리케이션 데이터
    └── Snapshot → 백업 저장소 (S3)
```

**문서**: lab_1.md (생성 예정)

### Lab 2: S3 정적 웹 호스팅 & CloudFront (14:00-14:50)
**목표**: S3로 정적 사이트 배포 및 CloudFront CDN 연결

**구축 내용**:
1. **S3 버킷 생성**: 정적 웹 호스팅 활성화
2. **웹 파일 업로드**: HTML, CSS, JS, 이미지
3. **버킷 정책 설정**: Public 읽기 권한
4. **CloudFront 생성**: S3를 오리진으로 설정
5. **캐싱 설정**: TTL 및 캐시 동작 구성
6. **접속 테스트**: CloudFront URL로 접속

**아키텍처**:
```
사용자 → CloudFront (Edge Location)
           ↓ (캐시 미스)
         S3 Bucket (오리진)
```

**문서**: lab_2.md (생성 예정)

---

## 🎮 Challenge

### Challenge 1: 블로그 플랫폼 인프라 구축 (15:00-15:50)
**시나리오**: 개인 블로그 플랫폼을 AWS에 완전 구축

**요구사항**:
1. **EC2 웹 서버**: 블로그 애플리케이션 (Nginx)
2. **EBS 데이터 볼륨**: 블로그 포스트 데이터 (10GB)
3. **S3 미디어 버킷**: 이미지 및 파일 저장
4. **CloudFront**: S3 콘텐츠 CDN 배포
5. **커스텀 페이지**: 챌린저 정보 + 샘플 블로그 포스트

**아키텍처**:
```
사용자
  ↓
CloudFront (이미지/CSS/JS)
  ↓
S3 Bucket (미디어 파일)

사용자
  ↓
EC2 (Nginx - 블로그 HTML)
  ↓
EBS Volume (블로그 데이터)
```

**제출 내용**:
- 블로그 URL (EC2)
- CloudFront URL (미디어)
- 아키텍처 다이어그램
- 구성 정보
- 디스코드 스레드 업로드

**평가 기준**:
- EC2 + EBS 구성: 30점
- S3 + CloudFront 구성: 30점
- 통합 동작: 20점
- 아키텍처 문서화: 20점

---

## 🔗 Day 1과의 연결

### 재사용 리소스
- VPC 네트워크 (10.0.0.0/16)
- Public/Private Subnet
- Security Group (확장)
- EC2 인스턴스 (추가 볼륨)

### 새로운 리소스
- EBS 볼륨 (추가)
- S3 버킷
- CloudFront Distribution

---

## 💰 예상 비용

| 리소스 | 사용 시간 | 단가 | 예상 비용 |
|--------|----------|------|-----------|
| EC2 t2.micro | 6시간 | $0.0116/hour | $0.07 |
| EBS gp3 (10GB) | 6시간 | $0.08/GB/month | $0.02 |
| S3 스토리지 (1GB) | - | $0.023/GB/month | $0.00 |
| CloudFront (1GB) | - | $0.085/GB | $0.09 |
| **합계** | | | **$0.18** |

---

## 📊 학습 성과 측정

### ✅ 이론 이해도
- [ ] EBS 볼륨 타입별 특징 설명 가능
- [ ] S3 스토리지 클래스 선택 기준 이해
- [ ] CloudFront 캐싱 동작 원리 이해

### ✅ 실습 완성도
- [ ] EBS 볼륨 추가 및 마운트 성공
- [ ] 스냅샷 생성 및 복원 성공
- [ ] S3 정적 웹 호스팅 구성
- [ ] CloudFront 배포 완료

### ✅ Challenge 성과
- [ ] EC2 + EBS + S3 + CloudFront 통합
- [ ] 블로그 플랫폼 완전 구축
- [ ] 강사 접속 가능한 URL 제공

---

## 🔗 관련 자료

### 📖 AWS 공식 문서
- [EC2 사용자 가이드](https://docs.aws.amazon.com/ec2/latest/userguide/)
- [EBS 볼륨](https://docs.aws.amazon.com/ebs/latest/userguide/)
- [S3 사용자 가이드](https://docs.aws.amazon.com/s3/latest/userguide/)
- [CloudFront 개발자 가이드](https://docs.aws.amazon.com/cloudfront/latest/developerguide/)

### 🎯 이전/다음 Day
- [Week 5 Day 1: AWS 기초 & 네트워킹](../day1/README.md)
- Week 5 Day 3: 데이터베이스 & 캐싱 (예정)

---

<div align="center">

**💾 데이터 영속성** • **📦 객체 스토리지** • **🌐 글로벌 배포** • **🎮 통합 Challenge**

*Day 2: 컴퓨팅과 스토리지로 완전한 애플리케이션 구축*

</div>
