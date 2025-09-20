# Week 2 Day 2 Session 4: 컨테이너 취약점 스캔 실습

<div align="center">
**🔍 취약점 발견** • **🛠️ 즉시 수정**
*구버전 이미지에서 Critical 취약점을 찾고 최신 버전으로 해결하기*
</div>

---

## 🕘 세션 정보
**시간**: 13:00-16:00 (3시간)
**목표**: Trivy로 취약점 스캔하고 우선순위 판단 후 해결
**방식**: 개인별 실습 + 결과 분석

## 🎯 세션 목표
### 📚 학습 목표
- **취약점 스캔**: Trivy를 사용한 컨테이너 이미지 보안 스캔
- **우선순위 판단**: Critical/High 취약점 중 먼저 조치할 항목 식별
- **효과적 해결**: 최소한의 변경으로 최대 보안 효과 달성
- **스캔 결과 해석**: CVE 정보와 CVSS 점수 이해

---

## 🛠️ 실습 챌린지 (3시간)

### 🎯 챌린지 개요
**목표**: 구버전 nginx 이미지의 Critical 취약점을 찾고 최신 버전으로 해결

### 📋 Phase 1: 취약한 이미지 구축 (30분)

#### 🔧 실습 파일 준비
**Dockerfile.vulnerable**:
```dockerfile
# 🚨 취약한 Dockerfile - 의도적으로 구버전 사용
FROM nginx:1.14.0

# 🚨 Critical 취약점: 구버전 nginx (CVE-2019-20372, CVE-2021-23017 등)
COPY index.html /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/

# 🚨 보안 문제: root 사용자로 실행 (기본값)
EXPOSE 80
```

**index.html**:
```html
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>취약점 스캔 실습</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <h1>🔍 컨테이너 보안 취약점 스캔 실습</h1>
        <div class="info-box">
            <h2>실습 목표</h2>
            <p>이 웹사이트는 의도적으로 취약한 nginx:1.14.0을 사용합니다.</p>
            <p><strong>Trivy</strong>로 Critical 취약점을 찾아보세요!</p>
        </div>
        <div class="vulnerability-box">
            <h2>🚨 예상 취약점</h2>
            <ul>
                <li><strong>Critical:</strong> CVE-2019-20372</li>
                <li><strong>High:</strong> 구버전 Debian 패키지들</li>
                <li><strong>Medium:</strong> Root 사용자 실행</li>
            </ul>
        </div>
    </div>
</body>
</html>
```

#### ✅ Phase 1 체크포인트
```bash
# 1. 취약한 이미지 빌드
docker build -f Dockerfile.vulnerable -t vulnerable-web .

# 2. 컨테이너 실행 확인
docker run -d -p 8080:80 --name vulnerable-container vulnerable-web

# 3. 웹사이트 접속 확인
curl http://localhost:8080
```

### 🌟 Phase 2: 취약점 스캔 및 분석 (90분)

#### 🔧 Trivy 설치 및 스캔
```bash
# Trivy 설치 (Linux/WSL)
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# 전체 취약점 스캔
trivy image vulnerable-web

# Critical과 High만 필터링
trivy image --severity CRITICAL,HIGH vulnerable-web

# JSON 형태로 결과 저장
trivy image --format json vulnerable-web > scan-results.json
```

#### 📊 예상 스캔 결과
```
vulnerable-web (debian 9.13)
==========================
Total: 157 (UNKNOWN: 0, LOW: 89, MEDIUM: 43, HIGH: 22, CRITICAL: 3)

┌─────────────────────┬────────────────┬──────────┬───────────────────┬───────────────┬─────────────────────────────────────────────────────────┐
│       Library       │ Vulnerability  │ Severity │ Installed Version │ Fixed Version │                           Title                         │
├─────────────────────┼────────────────┼──────────┼───────────────────┼───────────────┼─────────────────────────────────────────────────────────┤
│ nginx               │ CVE-2019-20372 │ CRITICAL │ 1.14.0-1          │ 1.14.2-1      │ nginx: HTTP request smuggling via error_page            │
│ nginx               │ CVE-2021-23017 │ HIGH     │ 1.14.0-1          │ 1.20.0-1      │ nginx: Off-by-one in resolver                          │
└─────────────────────┴────────────────┴──────────┴───────────────────┴───────────────┴─────────────────────────────────────────────────────────┘
```

#### 🎯 우선순위 매트릭스 작성
**조치 우선순위 결정 기준**:
```
우선순위 = 심각도 × 수정 용이성 × 영향 범위

1순위: Critical + Fixed Version 있음 + 웹서버 직접 영향
2순위: High + Fixed Version 있음 + 시스템 전체 영향  
3순위: Medium + 수정 복잡 + 제한적 영향
```

**CVE-2019-20372 분석**:
- **CVSS 점수**: 9.8 (Critical)
- **공격 벡터**: 네트워크를 통한 HTTP Request Smuggling
- **수정 방법**: nginx 1.14.2 이상으로 업그레이드
- **조치 우선순위**: 🔴 **1순위** (즉시 조치 필요)

#### 🎯 개별 분석 활동
**분석 포인트**:
1. **Critical 취약점 식별**: CVE-2019-20372 등 즉시 조치 필요한 항목
2. **CVSS 점수 확인**: 9.0 이상의 Critical 취약점 우선 처리
3. **수정 가능성 평가**: Fixed Version이 있는 취약점부터 해결
4. **영향도 분석**: 웹 서버 취약점이 서비스에 미치는 실제 위험도

#### ✅ Phase 2 체크포인트
- [ ] Trivy 설치 완료
- [ ] 취약점 스캔 실행
- [ ] Critical 취약점 3개 이상 발견
- [ ] 우선순위 매트릭스 작성 (심각도 × 수정용이성)
- [ ] 조치 계획 수립

### 🏆 Phase 3: 보안 강화 및 재스캔 (90분)

#### 🔧 보안 강화된 Dockerfile 작성
**Dockerfile.secure**:
```dockerfile
# ✅ 보안이 강화된 Dockerfile
FROM nginx:1.25.3-alpine

# ✅ 최신 nginx 버전 사용 (보안 패치 적용)
# ✅ Alpine 베이스로 공격 표면 최소화

COPY index.html /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/

# ✅ 보안 개선: 비root 사용자로 실행
RUN addgroup -g 101 -S nginx && \
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx

USER nginx
EXPOSE 8080

# ✅ 보안 개선: 비특권 포트 사용
CMD ["nginx", "-g", "daemon off;"]
```

#### 🔧 보안 강화된 이미지 구축 및 테스트
```bash
# 1. 보안 강화된 이미지 빌드
docker build -f Dockerfile.secure -t secure-web .

# 2. 새 컨테이너 실행
docker run -d -p 8081:8080 --name secure-container secure-web

# 3. 웹사이트 접속 확인
curl http://localhost:8081

# 4. 보안 강화된 이미지 스캔
trivy image --severity CRITICAL,HIGH secure-web
```

#### 📊 개선 결과 비교
```bash
# 취약점 개수 비교
echo "=== 취약한 이미지 ==="
trivy image --severity CRITICAL,HIGH --format table vulnerable-web | grep Total

echo "=== 보안 강화된 이미지 ==="
trivy image --severity CRITICAL,HIGH --format table secure-web | grep Total

# 이미지 크기 비교
docker images | grep -E "(vulnerable-web|secure-web)"
```

#### ✅ Phase 3 체크포인트
- [ ] 보안 강화된 이미지 빌드 완료
- [ ] Critical 취약점 0개 달성
- [ ] High 취약점 현저히 감소
- [ ] 비root 사용자 실행 확인

### 📊 결과 분석 및 정리 (30분)

#### 개인별 분석 결과 정리
**정리 내용**:
1. **발견한 취약점**: Critical/High 취약점 목록과 CVSS 점수
2. **우선순위 결정**: 어떤 기준으로 조치 순서를 정했는지
3. **개선 효과**: Before/After 취약점 개수 비교
4. **학습 포인트**: 취약점 스캔에서 얻은 인사이트

#### 🏆 성공 기준
- ✅ **Critical 취약점**: 0개 달성
- ✅ **High 취약점**: 50% 이상 감소
- ✅ **이미지 크기**: Alpine으로 크기 최적화
- ✅ **보안 설정**: 비root 사용자 실행

---

## 💡 실습 팁

### 🟢 초급자를 위한 가이드
```bash
# 단계별 명령어 (복사해서 사용)
# 1단계: 취약한 이미지
docker build -f Dockerfile.vulnerable -t vulnerable-web .
docker run -d -p 8080:80 vulnerable-web

# 2단계: 스캔
trivy image vulnerable-web

# 3단계: 보안 강화
docker build -f Dockerfile.secure -t secure-web .
trivy image secure-web
```

### 🟡 중급자 도전 과제
```bash
# 특정 CVE 상세 정보 조회
trivy image --format json vulnerable-web | jq '.Results[].Vulnerabilities[] | select(.VulnerabilityID=="CVE-2019-20372")'

# 심각도별 취약점 개수 통계
trivy image vulnerable-web --format json | jq '.Results[].Vulnerabilities | group_by(.Severity) | map({severity: .[0].Severity, count: length})'
```

### 🔴 고급자 심화 학습
```bash
# 취약점 트렌드 분석
trivy image --format json vulnerable-web | jq '.Results[].Vulnerabilities[] | select(.PublishedDate > "2020-01-01") | .VulnerabilityID'

# 수정 가능한 취약점만 필터링
trivy image vulnerable-web --format table --severity CRITICAL,HIGH | grep -v "(no fix available)"
```

---

## 🔑 핵심 키워드
- **Trivy**: 컨테이너 이미지 보안 스캔 도구
- **CVE**: Common Vulnerabilities and Exposures (공통 취약점 식별자)
- **CVSS**: Common Vulnerability Scoring System (취약점 점수 체계)
- **Critical/High/Medium/Low**: 취약점 심각도 분류 (9.0+/7.0+/4.0+/0.1+)
- **Fixed Version**: 취약점이 수정된 패키지 버전
- **Alpine Linux**: 보안과 크기 최적화된 베이스 이미지
- **Attack Vector**: 공격 경로 (Network/Adjacent/Local/Physical)

---

## 📝 세션 마무리

### ✅ 오늘 세션 성과
- 실제 취약점을 직접 발견하고 우선순위 판단 능력
- Trivy 도구 사용법과 결과 해석 능력 습득
- 효율적인 보안 강화 전략 수립 경험
- CVE와 CVSS 점수 기반 위험도 평가 능력

### 🎯 다음 세션 준비
- **Session 5**: 보안 전문가 멘토링에서 더 깊은 보안 주제 다룰 예정
- **복습**: 오늘 사용한 Trivy 명령어들 정리
- **예습**: 컨테이너 런타임 보안에 대해 생각해보기

<div align="center">
**🎉 축하합니다! Critical 취약점 0개 달성! 🎉**
*취약점 스캔과 우선순위 판단 능력을 완전히 습득했습니다!*
</div>