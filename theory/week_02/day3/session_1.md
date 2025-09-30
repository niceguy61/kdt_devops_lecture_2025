# Week 2 Day 3 Session 1: 컨테이너 보안 기초

<div align="center">

**🔒 컨테이너 보안** • **🛡️ 위협 모델** • **🔍 취약점 스캔**

*실무에서 필수인 컨테이너 보안 위협 이해와 대응 방안*

</div>

---

## 🕘 세션 정보
**시간**: 09:00-09:50 (50분)
**목표**: 컨테이너 환경의 보안 위협과 대응 방안 완전 이해
**방식**: 이론 학습 + 페어 토론 + 실습 준비

## 🎯 세션 목표
### 📚 학습 목표
- **이해 목표**: 컨테이너 환경의 보안 위협과 대응 방안 완전 이해
- **적용 목표**: 실무에서 사용할 수 있는 보안 도구와 기법 습득
- **협업 목표**: 팀원들과 보안 정책 수립 및 적용 전략 토론

### 🤔 왜 필요한가? (5분)

**현실 문제 상황**:
- 💼 **보안 사고**: 컨테이너 취약점으로 인한 실제 보안 사고 급증
- 🏠 **일상 비유**: 집의 문은 잠갔지만 창문을 열어둔 것과 같은 위험
- 📊 **시장 동향**: DevSecOps로의 패러다임 전환, 보안의 Shift-Left

**학습 전후 비교**:
```mermaid
graph LR
    A[학습 전<br/>보안 무관심] --> B[학습 후<br/>보안 전문가]
    
    style A fill:#ffebee
    style B fill:#e8f5e8
```

## 📖 핵심 개념 (35분)

### 🔍 개념 1: 컨테이너 보안 위협 모델 (12분)
> **정의**: 컨테이너 환경에서 발생할 수 있는 다양한 보안 위협과 공격 벡터

**컨테이너 보안 계층**:
```mermaid
graph TB
    subgraph "컨테이너 보안 계층"
        A[애플리케이션 보안<br/>Application Security] --> B[컨테이너 런타임 보안<br/>Runtime Security]
        B --> C[이미지 보안<br/>Image Security]
        C --> D[호스트 보안<br/>Host Security]
        D --> E[네트워크 보안<br/>Network Security]
    end
    
    subgraph "주요 위협"
        F[취약한 이미지<br/>Vulnerable Images] --> A
        G[권한 상승<br/>Privilege Escalation] --> B
        H[컨테이너 탈출<br/>Container Escape] --> C
        I[호스트 침해<br/>Host Compromise] --> D
        J[네트워크 공격<br/>Network Attacks] --> E
    end
    
    style A fill:#ffebee
    style B fill:#ffebee
    style C fill:#ffebee
    style D fill:#ffebee
    style E fill:#ffebee
    style F fill:#f44336
    style G fill:#f44336
    style H fill:#f44336
    style I fill:#f44336
    style J fill:#f44336
```

**주요 보안 위협**:
- **취약한 베이스 이미지**: 알려진 CVE가 포함된 이미지 사용
- **과도한 권한**: root 권한으로 실행되는 컨테이너
- **시크릿 노출**: 하드코딩된 패스워드나 API 키
- **네트워크 노출**: 불필요한 포트 개방
- **리소스 남용**: 무제한 리소스 사용으로 인한 DoS

### 🔍 개념 2: 이미지 보안 스캔 (12분)
> **정의**: 컨테이너 이미지의 취약점을 자동으로 검사하고 보고하는 프로세스

**보안 스캔 워크플로우**:
```mermaid
graph LR
    A[이미지 빌드] --> B[취약점 스캔<br/>Vulnerability Scan]
    B --> C{보안 정책<br/>통과?}
    C -->|Yes| D[레지스트리 푸시]
    C -->|No| E[빌드 실패<br/>수정 필요]
    E --> A
    D --> F[배포 승인]
    
    style A fill:#e3f2fd
    style B fill:#fff3e0
    style C fill:#ffeb3b
    style D fill:#4caf50
    style E fill:#f44336
    style F fill:#2196f3
```

**주요 스캔 도구**:
- **Trivy**: 오픈소스 취약점 스캐너
- **Clair**: CoreOS의 정적 분석 도구
- **Snyk**: 상용 보안 플랫폼
- **Anchore**: 엔터프라이즈 이미지 스캔

**스캔 실습 예시**:
```bash
# Trivy로 이미지 스캔
trivy image nginx:latest

# 심각도별 필터링
trivy image --severity HIGH,CRITICAL nginx:latest

# JSON 형태로 결과 출력
trivy image --format json nginx:latest > scan-result.json
```

### 🔍 개념 3: 런타임 보안 강화 (11분)
> **정의**: 컨테이너 실행 시점에서 적용하는 보안 조치와 모니터링

**런타임 보안 기법**:
```mermaid
graph TB
    subgraph "런타임 보안 조치"
        A[비root 사용자<br/>Non-root User] --> D[보안 강화]
        B[읽기 전용 파일시스템<br/>Read-only Filesystem] --> D
        C[리소스 제한<br/>Resource Limits] --> D
    end
    
    subgraph "보안 모니터링"
        E[파일 시스템 감시<br/>File System Monitoring] --> F[실시간 탐지]
        G[네트워크 트래픽 분석<br/>Network Analysis] --> F
        H[프로세스 모니터링<br/>Process Monitoring] --> F
    end
    
    D --> F
    
    style A fill:#e8f5e8
    style B fill:#e8f5e8
    style C fill:#e8f5e8
    style D fill:#4caf50
    style E fill:#fff3e0
    style G fill:#fff3e0
    style H fill:#fff3e0
    style F fill:#2196f3
```

**보안 강화 Dockerfile 예시**:
```dockerfile
FROM node:18-alpine

# 보안 강화: 비root 사용자 생성
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# 애플리케이션 파일 복사
COPY --chown=nextjs:nodejs . .

# 비root 사용자로 전환
USER nextjs

# 읽기 전용 파일시스템 (docker run 시 --read-only 옵션)
# 리소스 제한 (docker run 시 --memory, --cpus 옵션)

EXPOSE 3000
CMD ["node", "server.js"]
```

## 💭 함께 생각해보기 (10분)

**🤝 페어 토론** (5분):
**토론 주제**:
1. **보안 vs 편의성**: "보안을 강화하면서도 개발 편의성을 유지하는 방법은?"
2. **보안 정책**: "우리 조직에 맞는 컨테이너 보안 정책은 어떻게 수립해야 할까요?"
3. **자동화**: "보안 검사를 CI/CD 파이프라인에 어떻게 통합할까요?"

**페어 활동 가이드**:
- 👥 **자유 페어링**: 관심사나 이해도가 비슷한 사람끼리
- 🔄 **역할 교대**: 5분씩 설명자/질문자 역할 바꾸기
- 📝 **핵심 정리**: 대화 내용 중 중요한 점 메모하기

**🎯 전체 공유** (5분):
- **인사이트 공유**: 페어 토론에서 나온 좋은 아이디어
- **질문 수집**: 아직 이해가 어려운 부분
- **다음 연결**: 다음 세션과의 연결고리 확인

**💡 이해도 체크 질문**:
- ✅ "컨테이너 보안 위협의 주요 계층을 설명할 수 있나요?"
- ✅ "이미지 스캔이 왜 중요한지 이해했나요?"
- ✅ "런타임 보안 강화 방법을 실무에 적용할 수 있나요?"

## 🔑 핵심 키워드

### 🔤 기본 용어
- **CVE (Common Vulnerabilities and Exposures)**: 공통 취약점 및 노출 데이터베이스
- **SAST (Static Application Security Testing)**: 정적 애플리케이션 보안 테스트
- **DAST (Dynamic Application Security Testing)**: 동적 애플리케이션 보안 테스트

### 🔤 기술 용어
- **Container Escape**: 컨테이너에서 호스트로 탈출하는 공격
- **Privilege Escalation**: 권한 상승 공격
- **Supply Chain Attack**: 공급망 공격

### 🔤 도구 및 플랫폼
- **Trivy**: 오픈소스 취약점 스캐너
- **Falco**: 런타임 보안 모니터링 도구
- **OPA (Open Policy Agent)**: 정책 엔진

## 📝 세션 마무리
### ✅ 오늘 세션 성과
- 컨테이너 보안 위협 모델 완전 이해
- 이미지 보안 스캔의 중요성과 실습 방법 습득
- 런타임 보안 강화 기법 학습

### 🎯 다음 세션 준비
- **Session 2**: 이미지 최적화 & 성능 튜닝
- **연결고리**: 보안 강화된 이미지를 성능 최적화하는 방법
- **실습 준비**: 보안 스캔 도구 설치 및 환경 준비

---

<div align="center">

**🔒 보안 위협 이해** • **🛡️ 스캔 도구 활용** • **🔍 런타임 보안**

*컨테이너 보안의 기초를 완전히 마스터했습니다*

</div>