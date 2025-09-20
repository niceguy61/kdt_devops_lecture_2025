# Week 2 Day 1 Session 4: 보안-최적화-모니터링 통합 실습

<div align="center">

**🛠️ 통합 실습** • **🔒 보안 + ⚡ 최적화 + 📊 모니터링**

*Docker 심화 기술을 통합적으로 활용하는 실무 실습*

</div>

---

## 🕘 세션 정보

**시간**: 13:00-16:00 (3시간)  
**목표**: 보안, 최적화, 모니터링을 통합한 실무급 시스템 구축  
**방식**: 개별 실습 + 단계별 구현 + 성과 측정

---

## 🎯 실습 목표

### 📚 통합 실습 목표
- 오전 3개 세션에서 배운 모든 개념을 종합 적용
- 개별 실습을 통한 문제 해결 경험
- 실무와 유사한 시나리오 기반 실습

---

## 📋 실습 준비 (15분)

### 환경 설정
- 보안 스캔 도구 설치 (Trivy, Docker Scout)
- 모니터링 도구 준비
- 개별 실습 환경 준비

---

## 🚀 Phase 1: 보안 취약점 스캔 및 수정 (90분)

### 🔧 구현 단계

**Step 1: 취약한 이미지 분석**
```bash
# 의도적으로 취약한 이미지 생성
FROM ubuntu:18.04
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    python2.7 \
    nodejs=8.10.0~dfsg-2ubuntu0.4

COPY app.py /app/
WORKDIR /app
EXPOSE 8080
CMD ["python2.7", "app.py"]
```

**Step 2: 보안 스캔 실행**
```bash
# Trivy로 이미지 스캔
trivy image vulnerable-app:latest

# Docker Scout 스캔
docker scout cves vulnerable-app:latest

# 취약점 리포트 분석
docker scout recommendations vulnerable-app:latest
```

**Step 3: 보안 취약점 수정**
```dockerfile
# 보안이 강화된 Dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y \
    curl \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# 비root 사용자 생성
RUN useradd -m -u 1001 appuser
USER appuser

COPY --chown=appuser:appuser app.py /app/
WORKDIR /app
EXPOSE 8080
CMD ["python3", "app.py"]
```

### ✅ Phase 1 체크포인트
- [ ] 취약점 스캔 도구 사용법 습득
- [ ] Critical/High 취약점 식별 및 분석
- [ ] 보안 강화된 이미지 빌드 성공
- [ ] 취약점 수정 전후 비교 분석

---

## 🌟 Phase 2: 이미지 최적화 실습 (90분)

### 🔧 최적화 구현

**Step 1: 기본 이미지 크기 측정**
```bash
# 이미지 크기 확인
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# 이미지 레이어 분석
docker history myapp:basic
```

**Step 2: 멀티스테이지 빌드 적용**
```dockerfile
# 최적화된 Node.js 애플리케이션
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

# 프로덕션 스테이지
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./

RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001
USER nextjs

EXPOSE 3000
CMD ["npm", "start"]
```

**Step 3: 성능 벤치마크**
```bash
# 빌드 시간 측정
time docker build -t myapp:optimized .

# 이미지 크기 비교
docker images | grep myapp

# 컨테이너 시작 시간 측정
time docker run -d --name test-container myapp:optimized
```

### ✅ Phase 2 체크포인트
- [ ] 이미지 크기 50% 이상 감소 달성
- [ ] 빌드 시간 단축 확인
- [ ] 멀티스테이지 빌드 완전 이해
- [ ] 성능 벤치마크 결과 분석

---

## 🏆 Phase 3: 모니터링 대시보드 구축 (15분)

### 🤝 팀별 모니터링 시스템 구축

**개별 선택 실습**:
- **옵션 1**: 리소스 모니터링 스크립트
- **옵션 2**: 로그 분석 도구
- **옵션 3**: 알림 시스템
- **옵션 4**: 성능 대시보드
- **옵션 5**: 통합 모니터링 대시보드
- **옵션 6**: 자동화 스크립트

*각자 관심사에 따라 선택하여 실습*

**통합 모니터링 구성**:
```bash
#!/bin/bash
# integrated-monitoring.sh

# 실시간 모니터링 대시보드
watch -n 5 '
echo "=== Container Stats ==="
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

echo -e "\n=== Security Status ==="
trivy image --severity HIGH,CRITICAL myapp:latest | grep Total

echo -e "\n=== Performance Metrics ==="
docker inspect myapp --format="{{.State.Status}} {{.State.StartedAt}}"
'
```

---

## 🎤 결과 발표 및 공유 (30분)

### 개별 결과 공유 (30분)
- 발견한 보안 취약점과 해결 방법
- 이미지 최적화 결과와 성능 개선 효과
- 구축한 모니터링 시스템과 특징
- 통합 워크플로우에서 배운 점
- 어려웠던 부분과 해결 과정

---

## 📝 실습 마무리

### ✅ 실습 성과
- [ ] 보안 스캔과 취약점 수정 완료
- [ ] 이미지 최적화를 통한 성능 향상
- [ ] 통합 모니터링 시스템 구축
- [ ] 개별 실습을 통한 문제 해결

### 🎯 다음 단계 준비
- **내일 주제**: 컨테이너 오케스트레이션 개념
- **연결**: 오늘 최적화한 컨테이너들의 관리 방법

---

<div align="center">

**🛠️ Docker 심화 기술 통합 실습을 성공적으로 완료했습니다!**

**다음**: [Session 5 - 개별 멘토링 & 회고](./session_5.md)

</div>