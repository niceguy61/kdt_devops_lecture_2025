# Week 2 Day 3 Session 2: 시스템 모니터링 도구

<div align="center">
**🖥️ 시스템 분석** • **🔍 성능 진단**
*htop, iotop, netstat 등 시스템 모니터링 도구로 깊이 있는 성능 분석*
</div>

---

## 🕘 세션 정보
**시간**: 10:00-10:50 (50분)
**목표**: 시스템 레벨 모니터링 도구 활용법 습득
**방식**: 개인별 실습 + 도구 비교 분석

## 🎯 세션 목표
### 📚 학습 목표
- **시스템 도구**: htop, iotop, netstat 등 핵심 도구 활용
- **성능 분석**: CPU, 메모리, 디스크, 네트워크 종합 분석
- **병목 진단**: 시스템 성능 병목 지점 발견 방법
- **컨테이너 연계**: 시스템 리소스와 컨테이너 관계 이해

### 🤔 왜 필요한가? (5분)
**Docker만으로는 부족한 이유**:
```
Docker stats: 컨테이너 관점의 리소스 사용량
시스템 도구: 호스트 전체 관점의 성능 분석

예시:
- Docker stats에서는 정상으로 보이지만
- 실제로는 호스트 시스템에 문제가 있을 수 있음
```

**시스템 모니터링의 중요성**:
- **전체적 관점**: 호스트 시스템 전반의 상태 파악
- **근본 원인**: 컨테이너 문제의 실제 원인 발견
- **예방적 관리**: 문제 발생 전 사전 감지
- **용량 계획**: 시스템 확장 시점 판단

---

## 📖 핵심 개념 (35분)

### 🔍 개념 1: htop - 고급 프로세스 모니터링 (12분)

> **정의**: top 명령어의 향상된 버전으로 시각적이고 상호작용적인 프로세스 모니터링 도구

**설치 및 기본 사용**:
```bash
# Ubuntu/Debian
sudo apt install htop

# CentOS/RHEL
sudo yum install htop

# 실행
htop
```

**htop 화면 구성**:
```
CPU 사용률 막대그래프 (코어별)
메모리/스왑 사용률 표시
실행 중인 프로세스 목록 (PID, 사용자, CPU%, MEM%, 명령어)
```

**주요 단축키**:
- **F1**: 도움말
- **F2**: 설정
- **F3**: 검색 (프로세스명으로 검색)
- **F4**: 필터 (특정 조건으로 필터링)
- **F5**: 트리 뷰 (프로세스 계층 구조)
- **F6**: 정렬 기준 변경
- **F9**: 프로세스 종료 (kill)
- **F10**: 종료

**컨테이너 관련 분석**:
```bash
# Docker 관련 프로세스만 필터링
htop에서 F4 누르고 "docker" 입력

# 메모리 사용량 기준 정렬
htop에서 F6 누르고 "PERCENT_MEM" 선택

# CPU 사용량 기준 정렬  
htop에서 F6 누르고 "PERCENT_CPU" 선택
```

### 🔍 개념 2: iotop - 디스크 I/O 모니터링 (12분)

> **정의**: 프로세스별 디스크 I/O 사용량을 실시간으로 모니터링하는 도구

**설치 및 기본 사용**:
```bash
# Ubuntu/Debian
sudo apt install iotop

# CentOS/RHEL
sudo yum install iotop

# 실행 (root 권한 필요)
sudo iotop
```

**주요 옵션**:
```bash
# 실제 I/O가 있는 프로세스만 표시
sudo iotop -o

# 누적 I/O 표시
sudo iotop -a

# 특정 프로세스만 모니터링
sudo iotop -p PID

# 배치 모드 (스크립트에서 사용)
sudo iotop -b -n 1
```

**출력 정보 해석**:
```
Total DISK READ: 12.34 M/s | Total DISK WRITE: 5.67 M/s
  TID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN     IO>    COMMAND
 1234  be/4  root       11.2 M/s     0.00 B/s  0.00 %  85.2%  docker-containerd
```

**컨테이너 I/O 분석**:
```bash
# Docker 컨테이너의 I/O 패턴 분석
sudo iotop -o | grep docker

# 특정 컨테이너의 I/O 모니터링
docker exec container_name pidof process_name
sudo iotop -p PID
```

### 🔍 개념 3: 네트워크 모니터링 도구들 (11분)

> **정의**: 네트워크 연결 상태와 트래픽을 모니터링하는 다양한 도구들

**netstat - 네트워크 연결 상태**:
```bash
# 모든 연결 표시
netstat -tulpn

# TCP 연결만 표시
netstat -tln

# UDP 연결만 표시  
netstat -uln

# 특정 포트 확인
netstat -tulpn | grep :80

# 연결 통계
netstat -s
```

**ss - netstat의 현대적 대안**:
```bash
# 모든 연결 표시 (netstat보다 빠름)
ss -tulpn

# TCP 연결 상태별 통계
ss -s

# 특정 포트 리스닝 확인
ss -tlnp | grep :3306
```

**iftop - 실시간 네트워크 트래픽**:
```bash
# 설치
sudo apt install iftop

# 실행 (특정 인터페이스)
sudo iftop -i eth0

# 포트별 트래픽 표시
sudo iftop -P
```

**컨테이너 네트워크 분석**:
```bash
# 컨테이너의 네트워크 네임스페이스 확인
docker exec container_name ip addr show

# 컨테이너 포트 매핑 확인
docker port container_name

# 컨테이너 간 네트워크 연결 확인
docker network ls
docker network inspect bridge
```

---

## 💭 함께 생각해보기 (10분)

### 🎯 종합 분석 시나리오
**상황**: 웹 애플리케이션의 응답 속도가 급격히 느려졌습니다.

**단계별 진단 과정**:

**1단계: 전체 시스템 상태 확인**
```bash
# CPU와 메모리 전반적 상태
htop

# 시스템 로드 평균 확인
uptime
```

**2단계: 디스크 I/O 분석**
```bash
# 디스크 I/O 병목 확인
sudo iotop -o

# 디스크 사용량 확인
df -h
```

**3단계: 네트워크 상태 분석**
```bash
# 네트워크 연결 상태
ss -tulpn

# 네트워크 트래픽 (설치된 경우)
sudo iftop -i eth0
```

**4단계: 컨테이너별 상세 분석**
```bash
# 컨테이너 리소스 사용량
docker stats --no-stream

# 문제 컨테이너 로그 확인
docker logs problematic_container
```

### 🤝 개별 분석 활동
**분석 체크리스트**:
- [ ] **CPU 사용률**: 80% 이상인 프로세스가 있는가?
- [ ] **메모리 사용률**: 스왑이 발생하고 있는가?
- [ ] **디스크 I/O**: 읽기/쓰기 속도가 비정상적으로 높은가?
- [ ] **네트워크**: 대기 중인 연결이 많은가?
- [ ] **프로세스**: 좀비 프로세스나 무한 루프가 있는가?

### 💡 이해도 체크 질문
- ✅ "htop에서 Load average가 CPU 코어 수보다 높으면 무엇을 의미하나요?"
- ✅ "iotop에서 SWAPIN이 높게 나타나면 어떤 문제인가요?"
- ✅ "netstat에서 TIME_WAIT 상태가 많으면 무엇을 의미하나요?"
- ✅ "컨테이너 성능 문제를 진단할 때 어떤 순서로 확인해야 하나요?"

---

## 🔑 핵심 키워드
- **htop**: 향상된 프로세스 모니터링 도구
- **iotop**: 디스크 I/O 모니터링 도구
- **netstat/ss**: 네트워크 연결 상태 확인 도구
- **iftop**: 실시간 네트워크 트래픽 모니터링
- **Load Average**: 시스템 부하 평균
- **I/O Wait**: 디스크 I/O 대기 시간
- **네트워크 소켓**: TCP/UDP 연결 상태
- **시스템 병목**: 성능 제한 요소

---

## 📝 세션 마무리

### ✅ 오늘 세션 성과
- 시스템 레벨 모니터링 도구 활용법 습득
- CPU, 메모리, 디스크, 네트워크 종합 분석 능력
- 성능 병목 지점 진단 방법론 학습
- 컨테이너와 호스트 시스템 관계 이해

### 🎯 다음 세션 준비
- **Session 3**: 로그 분석과 문제 해결에서 더 깊은 로그 분석 기법 학습
- **복습**: htop, iotop, netstat 명령어 실습
- **예습**: 로그 파일 위치와 로그 분석 도구에 대해 생각해보기

<div align="center">
**🖥️ 시스템의 모든 것을 꿰뚫어 보는 눈을 갖추었습니다! 🖥️**
*이제 어떤 성능 문제도 숨을 수 없습니다!*
</div>