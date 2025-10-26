# Week 5 Day 2: 컴퓨팅 & 스토리지

<div align="center">

**🔄 EC2 심화** • **💾 EBS 스토리지** • **📦 S3 + CloudFront** • **🔒 OAC 보안**

*데이터 영속성과 안전한 콘텐츠 배포*

</div>

---

## 🕘 일일 스케줄

| 시간 | 구분 | 내용 | 비고 |
|------|------|------|------|
| **09:00-09:50** | 📚 이론 1 | Session 1: EC2 심화 (50분) | 생명주기, Elastic IP, Session Manager |
| **09:50-10:00** | ☕ 휴식 | 10분 휴식 | |
| **10:00-10:50** | 📚 이론 2 | Session 2: EBS 스토리지 (50분) | 볼륨 타입, 스냅샷, 암호화 |
| **10:50-11:00** | ☕ 휴식 | 10분 휴식 | |
| **11:00-11:50** | 📚 이론 3 | Session 3: S3 & CloudFront (50분) | 객체 스토리지, CDN, OAC |
| **11:50-12:00** | ☕ 휴식 | 10분 휴식 | |
| **12:00-12:50** | 📚 이론 4 | Session 4: E-Commerce 아키텍처 (50분) | 실무 사례 분석 |
| **12:50-13:00** | ☕ 휴식 | 10분 휴식 | |
| **13:00-14:00** | 🍽️ 점심 | 점심시간 (60분) | |
| **14:00-14:50** | 🛠️ 실습 | Lab 1: 정적 웹사이트 + 이미지 스토리지 (50분) | EC2 + EBS + S3 통합 |
| **14:50-15:15** | ☕ 휴식 | 25분 휴식 | |
| **15:15-16:05** | 🎮 Challenge | Challenge 1: CloudFront OAC 보안 아키텍처 (50분) | S3 Private + CloudFront OAC |
| **16:05-18:00** | 👥 멘토링 | 개별 멘토링 시간 (115분) | 질문, 복습, 심화 학습 |

---

## 🎯 Day 2 학습 목표

### 📚 이론 학습
- [ ] EC2 인스턴스 생명주기 및 고급 기능 (Elastic IP, Session Manager)
- [ ] EBS 볼륨 타입별 특징 및 선택 기준
- [ ] S3 스토리지 클래스 및 CloudFront OAC 보안
- [ ] E-Commerce 실무 아키텍처 패턴 이해

### 🛠️ 실습 목표
- [ ] EC2 + EBS + S3 통합 웹 서비스 구축
- [ ] Nginx 웹 서버 + EBS 데이터 볼륨 구성
- [ ] S3 퍼블릭 버킷 + 이미지 저장소 구성
- [ ] 웹 페이지에서 S3 이미지 참조

### 🎮 Challenge 목표
- [ ] S3 Private Bucket + CloudFront OAC 보안 아키텍처
- [ ] CloudFront만 S3 접근 가능하도록 설정
- [ ] 웹 페이지에서 CloudFront URL로 이미지 로드
- [ ] 보안 검증 (S3 직접 접근 차단)

---

## 📚 이론 세션

### Session 1: EC2 심화 (09:00-09:50)
**학습 내용**:
- EC2 인스턴스 생명주기 (Pending → Running → Stopped → Terminated)
- Elastic IP (고정 Public IP)
- EC2 Instance Connect
- Systems Manager Session Manager (SSH 없이 안전한 접속)
- CloudWatch 기본 모니터링

**Day 1 연계**:
- Day 1에서 EC2 기본 배포 학습
- Day 2에서 EC2 고급 관리 및 운영 학습

**문서**: [session_1.md](./session_1.md)

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

**문서**: [session_2.md](./session_2.md)

### Session 3: S3 & CloudFront (11:00-11:50)
**학습 내용**:
- S3 버킷 생성 및 정책
- S3 스토리지 클래스 (Standard, IA, Glacier)
- CloudFront CDN 아키텍처
- **OAC (Origin Access Control)** - S3 보안 강화
- CloudFront 캐싱 및 성능 최적화

**실무 연계**:
- 정적 파일 관리 (이미지, CSS, JS)
- 글로벌 콘텐츠 배포
- S3 보안 강화 (Private Bucket + CloudFront OAC)

**문서**: [session_3.md](./session_3.md)

### Session 4: E-Commerce 아키텍처 (12:00-12:50)
**학습 내용**:
- 쇼핑몰 플랫폼 실무 아키텍처
- CloudFront + S3 (정적 파일)
- ALB + EC2 (웹/앱 서버)
- RDS (상품/주문 DB)
- ElastiCache (세션/캐시)

**실무 사례**:
- 정적/동적 콘텐츠 분리
- CDN을 통한 성능 최적화
- 데이터 영속성 (EBS, S3)

**문서**: [session_4.md](./session_4.md)

---

## 🛠️ 실습 세션

### Lab 1: 정적 웹사이트 + 이미지 스토리지 (14:00-14:50)
**목표**: EC2, EBS, S3를 통합한 웹 서비스 구축

**구축 내용**:
1. **VPC 네트워크 구성** (Step 0):
   - VPC 생성 (10.0.0.0/16)
   - Public Subnet 생성
   - Internet Gateway 연결
   - Route Table 설정

2. **EC2 웹 서버** (Step 1):
   - t3.micro 인스턴스
   - Nginx 웹 서버
   - User Data로 자동 설치

3. **EBS 데이터 볼륨** (Step 2):
   - gp3 8GB 볼륨 생성
   - EC2에 연결 및 마운트
   - 웹 콘텐츠 저장

4. **S3 이미지 저장소** (Step 3):
   - S3 버킷 생성 (퍼블릭 액세스)
   - 이미지 업로드
   - 퍼블릭 URL 확인

5. **웹 페이지 통합** (Step 4):
   - HTML 페이지 생성
   - S3 이미지 참조
   - 전체 시스템 테스트

**아키텍처**:
```
사용자 → EC2 (Nginx)
          ↓
        EBS (웹 콘텐츠)
          ↓
        S3 (이미지)
```

**문서**: [lab_1.md](./lab_1.md)

---

## 🎮 Challenge

### Challenge 1: CloudFront OAC 보안 아키텍처 (15:15-16:05)
**시나리오**: S3 퍼블릭 액세스를 완전히 차단하면서 CloudFront를 통한 안전한 콘텐츠 배포

**핵심 목표**:
- **S3 직접 접근**: ❌ 403 Forbidden
- **CloudFront 접근**: ✅ 정상 작동

**구축 내용**:

**Phase 1: EC2 웹 서버 구축** (10분)
- Lab 1 기반 빠른 EC2 구성
- Nginx 웹 서버
- 기본 HTML 페이지

**Phase 2: S3 Private Bucket** (10분)
- S3 버킷 생성 (퍼블릭 액세스 완전 차단)
- 이미지 업로드
- 직접 접근 차단 확인 (403)

**Phase 3: CloudFront + OAC** (20분) ⭐ 핵심
- CloudFront Distribution 생성
- **OAC (Origin Access Control)** 설정
- S3 Bucket Policy 자동 업데이트
- CloudFront URL로 이미지 접근 성공

**Phase 4: 웹 페이지 통합** (10분)
- HTML에서 CloudFront URL 사용
- 개발자 도구로 CloudFront 확인
- 보안 검증 (S3 직접 403, CloudFront 정상)

**아키텍처**:
```
사용자 → CloudFront (OAC 인증)
           ↓
         S3 Private Bucket
         (퍼블릭 액세스 차단)

사용자 → EC2 (웹 서버)
           ↓
         HTML (CloudFront URL 사용)
```

**제출 내용**:
- CloudFront Distribution URL
- 웹 페이지 URL (EC2)
- 스크린샷 3개:
  1. 웹 페이지 (CloudFront 이미지 표시)
  2. Network 탭 (CloudFront 도메인 확인)
  3. S3 직접 접근 403 에러

**평가 기준**:
- 기능 구현 (60점): S3 Private + CloudFront + OAC
- 보안 검증 (30점): S3 차단 + CloudFront 정상
- 문서화 (10점): 제출 내용 완전성

**문서**: [challenge_1.md](./challenge_1.md)

---

## 🔗 Day 1과의 연결

### Day 1 복습
- **VPC 네트워크**: CIDR, Subnet, IGW, Route Table
- **EC2 기본**: 인스턴스 생성, Security Group, SSH 접속
- **기본 웹 서버**: Apache/Nginx 설치 및 구성

### Day 2 확장
- **EC2 심화**: 생명주기, Elastic IP, Session Manager
- **EBS 추가**: 데이터 볼륨, 마운트, 영속성
- **S3 통합**: 이미지 저장소, 웹 페이지 참조
- **CloudFront OAC**: 보안 강화 아키텍처

### 재사용 개념
- VPC 네트워크 구성 (Lab 1 Step 0)
- EC2 인스턴스 생성 및 User Data
- Security Group 설정
- 웹 서버 구성 (Nginx)

### 새로운 개념
- EBS 볼륨 추가 및 마운트
- S3 버킷 생성 및 정책
- CloudFront Distribution + OAC
- 보안 강화 (Private Bucket)

---

## 💰 예상 비용

| 리소스 | 사용 시간 | 단가 | 예상 비용 |
|--------|----------|------|-----------|
| EC2 t3.micro | 4시간 | $0.0116/hour | $0.05 |
| EBS gp3 (8GB) | 4시간 | $0.08/GB/month | $0.01 |
| S3 스토리지 (1GB) | - | $0.023/GB/month | $0.00 |
| CloudFront (100 요청) | - | $0.0075/10K | $0.00 |
| **합계** | | | **$0.06** |

**💡 비용 절감 팁**:
- 실습 완료 후 즉시 리소스 정리
- CloudFront는 Disable 후 15분 대기 → Delete
- S3 버킷은 Empty 후 Delete

---

## 📊 학습 성과 측정

### ✅ 이론 이해도
- [ ] EC2 생명주기 및 Elastic IP 개념 이해
- [ ] EBS 볼륨 타입별 특징 설명 가능
- [ ] S3 + CloudFront OAC 보안 원리 이해
- [ ] E-Commerce 아키텍처 패턴 이해

### ✅ 실습 완성도
- [ ] VPC 네트워크 구성 성공
- [ ] EC2 + EBS + S3 통합 웹 서비스 구축
- [ ] Nginx 웹 서버 + 이미지 표시 성공
- [ ] 웹 페이지 정상 작동

### ✅ Challenge 성과
- [ ] S3 Private Bucket + CloudFront OAC 구성
- [ ] S3 직접 접근 차단 확인 (403)
- [ ] CloudFront 접근 성공 확인
- [ ] 웹 페이지에서 CloudFront 이미지 로드
- [ ] Network 탭에서 CloudFront 도메인 확인

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
