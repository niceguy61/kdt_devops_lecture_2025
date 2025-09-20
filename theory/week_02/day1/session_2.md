# Week 2 Day 1 Session 2: 이미지 최적화와 성능 튜닝

<div align="center">

**⚡ 성능 최적화** • **📦 이미지 경량화**

*컨테이너 이미지 최적화와 실행 성능 향상 기법*

</div>

---

## 🕘 세션 정보

**시간**: 10:00-10:50 (50분)  
**목표**: 컨테이너 이미지 최적화 기법과 성능 튜닝 방법 이해  
**방식**: 최적화 기법 + 실제 측정 + 성능 비교

---

## 🎯 세션 목표

### 📚 학습 목표
- **이해 목표**: 컨테이너 이미지 최적화 기법과 성능 튜닝 방법 이해
- **적용 목표**: 이미지 크기 최소화와 실행 성능 향상 기술 습득
- **협업 목표**: 팀원들과 최적화 전략 수립 및 성능 측정 방법 토론

---

## 📖 핵심 개념 (35분)

### 🔍 개념 1: 이미지 크기 최적화 (12분)

> **정의**: 컨테이너 이미지의 크기를 최소화하여 배포 속도와 저장 효율성을 향상시키는 기법

**최적화 전략**:
```mermaid
graph TB
    subgraph "이미지 최적화 기법"
        A[Alpine Linux 사용<br/>경량 베이스 이미지] --> E[최적화된 이미지]
        B[멀티스테이지 빌드<br/>불필요한 파일 제거] --> E
        C[레이어 최소화<br/>RUN 명령어 결합] --> E
        D[.dockerignore<br/>불필요한 파일 제외] --> E
    end
    
    F[기존 이미지<br/>500MB+] --> G[최적화 적용]
    G --> H[최적화된 이미지<br/>50MB-]
    
    style A fill:#e8f5e8
    style B fill:#e8f5e8
    style C fill:#e8f5e8
    style D fill:#e8f5e8
    style E fill:#4caf50
    style H fill:#4caf50
    style F fill:#ffebee
```

**크기 비교 예시**:
| 베이스 이미지 | 크기 | 최적화 후 | 감소율 |
|---------------|------|-----------|--------|
| `ubuntu:20.04` | 72MB | `alpine:3.18` | 5MB (93% 감소) |
| `node:18` | 993MB | `node:18-alpine` | 174MB (82% 감소) |
| `python:3.9` | 885MB | `python:3.9-alpine` | 45MB (95% 감소) |

### 🔍 개념 2: 런타임 성능 최적화 (12분)

> **정의**: 컨테이너 실행 시 CPU, 메모리, I/O 성능을 최적화하는 방법

**성능 튜닝 영역**:
```mermaid
graph TB
    subgraph "성능 최적화 영역"
        A[CPU 최적화<br/>멀티코어 활용] --> E[성능 향상]
        B[메모리 최적화<br/>힙 크기 조정] --> E
        C[I/O 최적화<br/>디스크 성능] --> E
        D[네트워크 최적화<br/>연결 풀링] --> E
    end
    
    style A fill:#fff3e0
    style B fill:#fff3e0
    style C fill:#fff3e0
    style D fill:#fff3e0
    style E fill:#4caf50
```

### 🔍 개념 3: 빌드 최적화 (11분)

> **정의**: Docker 이미지 빌드 과정을 최적화하여 빌드 시간을 단축하는 방법

**최적화된 Dockerfile 예시**:
```dockerfile
# 멀티스테이지 빌드
FROM node:18-alpine AS builder

# 의존성 먼저 설치 (캐시 활용)
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# 소스 코드 복사
COPY . .
RUN npm run build

# 프로덕션 스테이지
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
RUN rm -rf /var/cache/apk/*

# 보안 설정
RUN adduser -D -s /bin/sh nginx
USER nginx

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

---

## 💭 함께 생각해보기 (15분)

### 🤝 페어 토론 (10분)

**토론 주제**:
1. **최적화 경험**: "애플리케이션 성능을 개선해본 경험이 있나요?"
2. **트레이드오프**: "이미지 크기와 기능성 사이의 균형을 어떻게 맞출까요?"
3. **측정 방법**: "성능 개선 효과를 어떻게 측정하고 검증할까요?"

### 🎯 전체 공유 (5분)

- **최적화 전략**: 효과적인 이미지 최적화 방안
- **성능 측정**: 성능 개선 효과 측정 방법

---

## 🔑 핵심 키워드

- **Multi-stage Build**: 멀티스테이지 빌드
- **Alpine Linux**: 경량 리눅스 배포판
- **Layer Caching**: 레이어 캐싱
- **Resource Limits**: 리소스 제한
- **Performance Profiling**: 성능 프로파일링

---

## 📝 세션 마무리

### ✅ 오늘 세션 성과
- [ ] 이미지 최적화 기법 습득
- [ ] 성능 튜닝 방법 이해
- [ ] 빌드 최적화 전략 학습

### 🎯 다음 세션 준비
- **주제**: CLI 기반 모니터링과 로깅
- **연결**: 최적화된 시스템의 모니터링 방법

---

<div align="center">

**⚡ 컨테이너 성능 최적화를 완전히 마스터했습니다!**

**다음**: [Session 3 - CLI 기반 모니터링과 로깅](./session_3.md)

</div>