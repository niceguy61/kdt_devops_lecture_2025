# Week 5 Day 2 Lab 1: 정적 웹사이트 + 이미지 스토리지

<div align="center">

**🎯 EC2 + EBS + S3** • **⏱️ 50분** • **💰 $0.15**

*Nginx 웹 서버 + EBS 데이터 볼륨 + S3 이미지 저장소*

</div>

---

## 🕘 Lab 정보
**시간**: 14:00-14:50 (50분)
**목표**: EC2, EBS, S3를 통합한 웹 서비스 구축
**방식**: AWS Web Console 실습
**예상 비용**: $0.15

## 🎯 학습 목표
- [ ] EC2에 Nginx 웹 서버 구축
- [ ] EBS 볼륨 추가 및 마운트
- [ ] S3 버킷 생성 및 이미지 업로드
- [ ] 웹 페이지에서 S3 이미지 참조

---

## 🏗️ 구축할 아키텍처

### 📐 아키텍처 다이어그램
```
┌─────────────────────────────────────────┐
│           AWS Cloud (ap-northeast-2)    │
│  ┌───────────────────────────────────┐  │
│  │  VPC (기본 VPC)                   │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │ Public Subnet               │  │  │
│  │  │  ┌──────────────────────┐   │  │  │
│  │  │  │ EC2 (t3.micro)       │   │  │  │
│  │  │  │ - Nginx 웹 서버      │   │  │  │
│  │  │  │ - Public IP          │   │  │  │
│  │  │  └──────────────────────┘   │  │  │
│  │  │         │                    │  │  │
│  │  │         ├─ EBS gp3 8GB      │  │  │
│  │  │         │  (웹 콘텐츠)      │  │  │
│  │  └─────────┼────────────────────┘  │  │
│  └────────────┼───────────────────────┘  │
│               │                           │
│               └──> S3 Bucket              │
│                    (이미지 저장소)        │
└─────────────────────────────────────────┘
```

**사용된 AWS 서비스**:
- ![EC2](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Compute/48/Arch_Amazon-EC2_48.svg) **Amazon EC2**: Nginx 웹 서버
- ![EBS](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Storage/48/Arch_Amazon-Elastic-Block-Store_48.svg) **Amazon EBS**: 웹 콘텐츠 저장
- ![S3](../../../Asset-Package_01312023.d59bb3e1bf7860fb55d4d737779e7c6fce1e35ae/Architecture-Service-Icons_01312023/Arch_Storage/48/Arch_Amazon-Simple-Storage-Service_48.svg) **Amazon S3**: 이미지 저장소

### 🔗 참조 Session
**당일 Session**:
- [Session 1: EC2 심화](../session_1.md) - EC2 인스턴스 생성 및 관리
- [Session 2: EBS 스토리지](../session_2.md) - EBS 볼륨 추가 및 마운트
- [Session 3: S3 & CloudFront](../session_3.md) - S3 버킷 생성 및 관리

---

## 🛠️ Step 1: EC2 인스턴스 생성 (10분)

### 📋 이 단계에서 할 일
- EC2 인스턴스 생성 (t3.micro)
- Security Group 설정 (HTTP, SSH)
- Nginx 웹 서버 설치

### 🔗 참조 개념
- [Session 1: EC2 생명주기](../session_1.md#개념-1-ec2-인스턴스-생명주기-12분)

### 📝 실습 절차

#### 1-1. EC2 인스턴스 생성

**AWS Console 경로**:
```
AWS Console → EC2 → Instances → Launch instances
```

**설정 값**:
| 항목 | 값 | 설명 |
|------|-----|------|
| Name | week5-day2-web | 인스턴스 이름 |
| AMI | Amazon Linux 2023 | 최신 Amazon Linux |
| Instance type | t3.micro | 프리티어 |
| Key pair | week5-keypair | SSH 접속용 |
| Network | 기본 VPC | 기본 네트워크 |
| Subnet | 기본 Public Subnet | 퍼블릭 서브넷 |
| Auto-assign public IP | Enable | 공인 IP 자동 할당 |

**Security Group 설정**:
| Type | Protocol | Port | Source | 설명 |
|------|----------|------|--------|------|
| SSH | TCP | 22 | My IP | SSH 접속 |
| HTTP | TCP | 80 | 0.0.0.0/0 | 웹 접속 |

**User Data** (Advanced details):
```bash
#!/bin/bash
yum update -y
yum install -y nginx
systemctl start nginx
systemctl enable nginx
```

**⚠️ 주의사항**:
- Key pair는 안전한 곳에 보관
- Security Group의 SSH는 본인 IP만 허용
- User Data는 정확히 입력

#### 1-2. 인스턴스 상태 확인

**AWS Console 경로**:
```
EC2 → Instances → week5-day2-web 선택
```

**확인 사항**:
- Instance state: Running
- Status check: 2/2 checks passed
- Public IPv4 address: 확인

#### 1-3. 웹 서버 접속 테스트

**브라우저에서 접속**:
```
http://[EC2-Public-IP]
```

**예상 결과**:
```
Welcome to nginx!
```

### ✅ Step 1 검증

**검증 명령어**:
```bash
# SSH 접속
ssh -i week5-keypair.pem ec2-user@[EC2-Public-IP]

# Nginx 상태 확인
sudo systemctl status nginx
```

**예상 결과**:
```
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded
   Active: active (running)
```

**✅ 체크리스트**:
- [ ] EC2 인스턴스 Running 상태
- [ ] 브라우저에서 Nginx 페이지 확인
- [ ] SSH 접속 가능

---

## 🛠️ Step 2: EBS 볼륨 추가 및 마운트 (15분)

### 📋 이 단계에서 할 일
- EBS 볼륨 생성 (gp3 8GB)
- EC2 인스턴스에 연결
- 파일시스템 생성 및 마운트

### 🔗 참조 개념
- [Session 2: EBS 볼륨 타입](../session_2.md#개념-1-ebs-볼륨-타입-12분)

### 📝 실습 절차

#### 2-1. EBS 볼륨 생성

**AWS Console 경로**:
```
EC2 → Elastic Block Store → Volumes → Create volume
```

**설정 값**:
| 항목 | 값 | 설명 |
|------|-----|------|
| Volume type | gp3 | 범용 SSD |
| Size | 8 GiB | 웹 콘텐츠용 |
| IOPS | 3000 | 기본값 |
| Throughput | 125 MB/s | 기본값 |
| Availability Zone | EC2와 동일 | 같은 AZ 필수 |
| Tags | Name: week5-day2-web-data | 식별용 |

**⚠️ 주의사항**:
- Availability Zone은 EC2와 반드시 동일해야 함
- 다른 AZ의 볼륨은 연결 불가

#### 2-2. 볼륨 연결

**AWS Console 경로**:
```
Volumes → week5-day2-web-data 선택 → Actions → Attach volume
```

**설정 값**:
| 항목 | 값 | 설명 |
|------|-----|------|
| Instance | week5-day2-web | 대상 인스턴스 |
| Device name | /dev/sdf | 디바이스 이름 |

#### 2-3. 파일시스템 생성 및 마운트

**SSH 접속 후 실행**:
```bash
# 1. 볼륨 확인
lsblk

# 2. 파일시스템 생성 (최초 1회만)
sudo mkfs -t xfs /dev/nvme1n1

# 3. 마운트 포인트 생성
sudo mkdir /web-data

# 4. 마운트
sudo mount /dev/nvme1n1 /web-data

# 5. 자동 마운트 설정
echo '/dev/nvme1n1 /web-data xfs defaults,nofail 0 2' | sudo tee -a /etc/fstab

# 6. 권한 설정
sudo chown -R nginx:nginx /web-data
```

**예상 결과**:
```bash
lsblk
# NAME          MAJ:MIN RM SIZE RO TYPE MOUNTPOINTS
# nvme0n1       259:0    0   8G  0 disk 
# └─nvme0n1p1   259:1    0   8G  0 part /
# nvme1n1       259:2    0   8G  0 disk /web-data
```

### ✅ Step 2 검증

**검증 명령어**:
```bash
# 마운트 확인
df -h | grep web-data

# 쓰기 테스트
sudo touch /web-data/test.txt
ls -l /web-data/
```

**예상 결과**:
```
/dev/nvme1n1    8.0G   33M  8.0G   1% /web-data
-rw-r--r-- 1 root root 0 Oct 26 12:00 test.txt
```

**✅ 체크리스트**:
- [ ] EBS 볼륨 생성 완료
- [ ] EC2에 연결 완료
- [ ] 파일시스템 마운트 완료
- [ ] 쓰기 테스트 성공

---

## 🛠️ Step 3: S3 버킷 생성 및 이미지 업로드 (10분)

### 📋 이 단계에서 할 일
- S3 버킷 생성
- 퍼블릭 액세스 설정
- 샘플 이미지 업로드

### 🔗 참조 개념
- [Session 3: S3 스토리지 클래스](../session_3.md#개념-1-s3-스토리지-클래스-12분)

### 📝 실습 절차

#### 3-1. S3 버킷 생성

**AWS Console 경로**:
```
S3 → Buckets → Create bucket
```

**설정 값**:
| 항목 | 값 | 설명 |
|------|-----|------|
| Bucket name | week5-day2-images-[학번] | 고유한 이름 |
| Region | ap-northeast-2 | 서울 리전 |
| Block Public Access | 모두 해제 | 퍼블릭 액세스 허용 |
| Versioning | Disable | 버전 관리 비활성화 |

**⚠️ 주의사항**:
- 버킷 이름은 전 세계에서 고유해야 함
- 학번이나 이름을 추가하여 고유성 확보

#### 3-2. 버킷 정책 설정

**AWS Console 경로**:
```
S3 → week5-day2-images-[학번] → Permissions → Bucket policy
```

**정책 내용**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::week5-day2-images-[학번]/*"
    }
  ]
}
```

**⚠️ 주의사항**:
- `[학번]` 부분을 실제 버킷 이름으로 변경
- 퍼블릭 액세스 경고는 정상 (실습용)

#### 3-3. 샘플 이미지 업로드

**AWS Console 경로**:
```
S3 → week5-day2-images-[학번] → Upload
```

**업로드 파일**:
- 샘플 이미지 3개 (logo.png, banner.jpg, product.jpg)
- 또는 본인이 준비한 이미지

**업로드 후 URL 확인**:
```
https://week5-day2-images-[학번].s3.ap-northeast-2.amazonaws.com/logo.png
```

### ✅ Step 3 검증

**검증 방법**:
```bash
# 브라우저에서 이미지 URL 직접 접속
https://week5-day2-images-[학번].s3.ap-northeast-2.amazonaws.com/logo.png
```

**예상 결과**:
- 이미지가 브라우저에 표시됨

**✅ 체크리스트**:
- [ ] S3 버킷 생성 완료
- [ ] 버킷 정책 설정 완료
- [ ] 이미지 업로드 완료
- [ ] 브라우저에서 이미지 확인

---

## 🛠️ Step 4: 웹 페이지 구성 및 통합 (15분)

### 📋 이 단계에서 할 일
- HTML 페이지 작성
- S3 이미지 참조
- Nginx 설정 변경

### 📝 실습 절차

#### 4-1. HTML 페이지 작성

**SSH 접속 후 실행**:
```bash
# HTML 파일 생성
sudo tee /web-data/index.html > /dev/null <<'EOF'
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Week 5 Day 2 Lab 1</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            text-align: center;
        }
        .image-gallery {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }
        .image-card {
            text-align: center;
        }
        .image-card img {
            width: 100%;
            height: 200px;
            object-fit: cover;
            border-radius: 5px;
        }
        .info {
            margin-top: 30px;
            padding: 20px;
            background-color: #e8f5e9;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Week 5 Day 2 Lab 1</h1>
        <p style="text-align: center;">EC2 + EBS + S3 통합 실습</p>
        
        <div class="image-gallery">
            <div class="image-card">
                <img src="https://week5-day2-images-[학번].s3.ap-northeast-2.amazonaws.com/logo.png" alt="Logo">
                <p>Logo (S3)</p>
            </div>
            <div class="image-card">
                <img src="https://week5-day2-images-[학번].s3.ap-northeast-2.amazonaws.com/banner.jpg" alt="Banner">
                <p>Banner (S3)</p>
            </div>
            <div class="image-card">
                <img src="https://week5-day2-images-[학번].s3.ap-northeast-2.amazonaws.com/product.jpg" alt="Product">
                <p>Product (S3)</p>
            </div>
        </div>
        
        <div class="info">
            <h3>📊 아키텍처 정보</h3>
            <ul>
                <li><strong>웹 서버:</strong> EC2 (t3.micro) + Nginx</li>
                <li><strong>웹 콘텐츠:</strong> EBS (gp3 8GB) - /web-data</li>
                <li><strong>이미지 저장:</strong> S3 Standard</li>
                <li><strong>리전:</strong> ap-northeast-2 (서울)</li>
            </ul>
        </div>
    </div>
</body>
</html>
EOF
```

**⚠️ 주의사항**:
- `[학번]` 부분을 실제 S3 버킷 이름으로 변경
- 이미지 파일명도 실제 업로드한 파일명과 일치시킬 것

#### 4-2. Nginx 설정 변경

**SSH 접속 후 실행**:
```bash
# Nginx 설정 백업
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup

# 설정 파일 수정
sudo tee /etc/nginx/conf.d/web-data.conf > /dev/null <<'EOF'
server {
    listen 80;
    server_name _;
    
    root /web-data;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

# 기본 설정 비활성화
sudo rm -f /etc/nginx/sites-enabled/default

# 설정 테스트
sudo nginx -t

# Nginx 재시작
sudo systemctl restart nginx
```

**예상 결과**:
```
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

#### 4-3. 웹 페이지 확인

**브라우저에서 접속**:
```
http://[EC2-Public-IP]
```

**예상 결과**:
- HTML 페이지 표시
- S3 이미지 3개 표시
- 아키텍처 정보 표시

### ✅ Step 4 검증

**✅ 체크리스트**:
- [ ] HTML 페이지 작성 완료
- [ ] Nginx 설정 변경 완료
- [ ] 브라우저에서 페이지 확인
- [ ] S3 이미지 정상 표시

---

## 🧹 리소스 정리 (5분)

### ⚠️ 중요: 반드시 순서대로 삭제

**삭제 순서** (역순으로):
```
Step 4 (Nginx 설정) → Step 3 (S3) → Step 2 (EBS) → Step 1 (EC2)
```

### 🗑️ 삭제 절차

#### 1. S3 버킷 삭제

**AWS Console 경로**:
```
S3 → week5-day2-images-[학번] → Empty → Delete
```

**확인 사항**:
- [ ] 버킷 내 모든 객체 삭제
- [ ] 버킷 삭제 완료

#### 2. EBS 볼륨 삭제

**AWS Console 경로**:
```
EC2 → Volumes → week5-day2-web-data → Actions → Detach volume → Delete volume
```

**확인 사항**:
- [ ] 볼륨 분리 완료
- [ ] 볼륨 삭제 완료

#### 3. EC2 인스턴스 종료

**AWS Console 경로**:
```
EC2 → Instances → week5-day2-web → Instance state → Terminate instance
```

**확인 사항**:
- [ ] 인스턴스 종료 완료
- [ ] 연결된 EBS 루트 볼륨 자동 삭제 확인

### ✅ 정리 완료 확인

**확인 명령어**:
```bash
# AWS CLI로 확인 (선택사항)
aws ec2 describe-instances --filters "Name=tag:Name,Values=week5-day2-web"
aws ec2 describe-volumes --filters "Name=tag:Name,Values=week5-day2-web-data"
aws s3 ls | grep week5-day2-images
```

**예상 결과**:
```
(빈 결과 - 모든 리소스 삭제됨)
```

**✅ 최종 체크리스트**:
- [ ] S3 버킷 삭제
- [ ] EBS 볼륨 삭제
- [ ] EC2 인스턴스 종료
- [ ] Security Group 삭제 (선택)
- [ ] Key Pair 삭제 (선택)

---

## 💰 비용 확인

### 예상 비용 계산
| 리소스 | 사용 시간 | 단가 | 예상 비용 |
|--------|----------|------|-----------|
| EC2 t3.micro | 50분 | $0.0116/hour | $0.01 |
| EBS gp3 8GB | 50분 | $0.088/GB/month | $0.01 |
| S3 Standard | 3개 이미지 | $0.025/GB | $0.00 |
| 데이터 전송 | 1MB | $0.126/GB | $0.00 |
| **합계** | | | **$0.02** |

### 실제 비용 확인

**AWS Console 경로**:
```
Billing and Cost Management → Cost Explorer → Cost & Usage
```

**필터 설정**:
- Time range: Today
- Service: EC2, EBS, S3
- Tag: Name=week5-day2-*

---

## 🔍 트러블슈팅

### 문제 1: Nginx 페이지가 표시되지 않음

**증상**:
- 브라우저에서 "Connection refused" 또는 타임아웃

**원인**:
- Security Group에서 HTTP (80) 포트 미허용
- Nginx 서비스 미실행

**해결 방법**:
```bash
# Security Group 확인
EC2 Console → Security Groups → Inbound rules 확인

# Nginx 상태 확인
sudo systemctl status nginx

# Nginx 시작
sudo systemctl start nginx
```

### 문제 2: EBS 볼륨 마운트 실패

**증상**:
- `mount: wrong fs type` 오류

**원인**:
- 파일시스템 미생성
- 잘못된 디바이스 이름

**해결 방법**:
```bash
# 디바이스 확인
lsblk

# 파일시스템 생성 (최초 1회)
sudo mkfs -t xfs /dev/nvme1n1

# 마운트 재시도
sudo mount /dev/nvme1n1 /web-data
```

### 문제 3: S3 이미지가 표시되지 않음

**증상**:
- 이미지 영역이 깨져서 표시됨
- 403 Forbidden 오류

**원인**:
- 버킷 정책 미설정
- 잘못된 이미지 URL

**해결 방법**:
```bash
# 버킷 정책 확인
S3 Console → Permissions → Bucket policy

# 이미지 URL 확인
https://[버킷명].s3.ap-northeast-2.amazonaws.com/[파일명]

# 브라우저에서 직접 URL 테스트
```

---

## 💡 Lab 회고

### 🤝 페어 회고 (5분)
1. **가장 어려웠던 부분**: 
2. **새로 배운 점**:
3. **실무 적용 아이디어**:

### 📊 학습 성과
- **기술적 성취**: EC2 + EBS + S3 통합 아키텍처 구축
- **이해도 향상**: 정적/동적 콘텐츠 분리 개념
- **다음 Lab 준비**: Challenge 1 (WordPress 블로그)

---

## 🔗 관련 자료

### 📚 Session 복습
- [Session 1: EC2 심화](../session_1.md)
- [Session 2: EBS 스토리지](../session_2.md)
- [Session 3: S3 & CloudFront](../session_3.md)

### 📖 AWS 공식 문서
- [EC2 사용자 가이드](https://docs.aws.amazon.com/ec2/)
- [EBS 볼륨 관리](https://docs.aws.amazon.com/ebs/)
- [S3 버킷 정책](https://docs.aws.amazon.com/s3/latest/userguide/bucket-policies.html)

### 🎯 다음 Lab
- [Challenge 1: WordPress 블로그 플랫폼](../challenge_1.md) - Lab 1 기반 확장

---

<div align="center">

**✅ Lab 완료** • **🧹 리소스 정리 필수** • **💰 비용 확인**

*다음 Challenge로 이동하기 전 반드시 리소스 정리 확인*

</div>
