# Week 2 Day 3 Session 1: Docker 모니터링 명령어

<div align="center">
**📊 CLI 모니터링** • **⚡ 실시간 분석**
*Docker 기본 명령어로 컨테이너 상태를 실시간으로 모니터링하는 방법*
</div>

---

## 🕘 세션 정보
**시간**: 09:00-09:50 (50분)
**목표**: Docker 기본 모니터링 명령어 완전 습득
**방식**: 개인별 실습 + 명령어 연습

## 🎯 세션 목표
### 📚 학습 목표
- **기본 명령어**: docker stats, docker logs 완전 활용
- **리소스 분석**: CPU, 메모리, 네트워크 사용량 해석
- **실시간 모니터링**: 지속적인 시스템 상태 추적
- **문제 발견**: 명령어를 통한 이상 징후 조기 발견

### 🤔 왜 필요한가? (5분)
**실무 상황**:
```
상황: 웹 서비스가 갑자기 느려짐
문제: 어떤 컨테이너가 문제인지 모름
해결: CLI 명령어로 즉시 원인 파악!
```

**CLI 모니터링의 장점**:
- **즉시 사용**: 별도 도구 설치 없이 바로 사용
- **가벼움**: 시스템 리소스를 거의 사용하지 않음
- **정확함**: 실시간 정확한 데이터 제공
- **범용성**: 모든 Docker 환경에서 동일하게 작동

---

## 📖 핵심 개념 (35분)

### 🔍 개념 1: docker stats - 실시간 리소스 모니터링 (12분)

> **정의**: 실행 중인 컨테이너의 리소스 사용량을 실시간으로 표시하는 명령어

**기본 사용법**:
```bash
# 모든 컨테이너 실시간 모니터링
docker stats

# 특정 컨테이너만 모니터링
docker stats web-server db-server

# 한 번만 출력 (지속 모니터링 안함)
docker stats --no-stream

# 포맷 지정
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

**출력 정보 해석**:
```
CONTAINER ID   NAME       CPU %     MEM USAGE / LIMIT     MEM %     NET I/O           BLOCK I/O         PIDS
a1b2c3d4e5f6   web-app    15.23%    256.7MiB / 2GiB      12.54%    1.2MB / 890kB     12.3MB / 4.56MB   23
```

**각 항목 의미**:
- **CPU %**: CPU 사용률 (전체 시스템 대비)
- **MEM USAGE / LIMIT**: 현재 메모리 사용량 / 제한량
- **MEM %**: 메모리 사용률
- **NET I/O**: 네트워크 입출력 (받은 데이터 / 보낸 데이터)
- **BLOCK I/O**: 디스크 입출력 (읽기 / 쓰기)
- **PIDS**: 컨테이너 내 프로세스 수

### 🔍 개념 2: docker logs - 로그 분석과 추적 (12분)

> **정의**: 컨테이너에서 생성된 로그를 확인하고 분석하는 명령어

**기본 사용법**:
```bash
# 전체 로그 출력
docker logs web-container

# 실시간 로그 추적 (tail -f와 유사)
docker logs -f web-container

# 최근 100줄만 출력
docker logs --tail 100 web-container

# 특정 시간 이후 로그
docker logs --since "2024-01-01T10:00:00" web-container

# 타임스탬프 포함
docker logs -t web-container
```

**로그 분석 기법**:
```bash
# 에러 로그만 필터링
docker logs web-container 2>&1 | grep -i error

# 특정 패턴 검색
docker logs web-container | grep "404\|500\|error"

# 로그 통계 (에러 개수)
docker logs web-container | grep -c "ERROR"

# 시간대별 로그 분석
docker logs -t web-container | grep "2024-01-01T14"
```

### 🔍 개념 3: 고급 모니터링 명령어 (11분)

> **정의**: docker stats와 logs 외에 상세한 정보를 제공하는 추가 명령어들

**docker inspect - 상세 정보 조회**:
```bash
# 컨테이너 전체 정보
docker inspect web-container

# 특정 정보만 추출
docker inspect --format='{{.State.Status}}' web-container
docker inspect --format='{{.NetworkSettings.IPAddress}}' web-container
docker inspect --format='{{.HostConfig.Memory}}' web-container
```

**docker top - 컨테이너 내 프로세스**:
```bash
# 컨테이너 내 실행 중인 프로세스
docker top web-container

# 상세한 프로세스 정보
docker top web-container aux
```

**docker exec - 컨테이너 내부 명령 실행**:
```bash
# 컨테이너 내부 쉘 접속
docker exec -it web-container /bin/bash

# 특정 명령어 실행
docker exec web-container ps aux
docker exec web-container df -h
docker exec web-container netstat -tulpn
```

**실시간 모니터링 조합**:
```bash
# 여러 명령어를 조합한 모니터링
watch -n 1 'docker stats --no-stream'

# 스크립트로 자동화
#!/bin/bash
while true; do
    echo "=== $(date) ==="
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemPerc}}"
    sleep 5
done
```

---

## 💭 함께 생각해보기 (10분)

### 🎯 실습 시나리오
**상황**: 웹 서버 컨테이너가 느려지고 있다는 신고가 들어왔습니다.

**실습 단계**:
1. **현재 상태 확인**: docker stats로 리소스 사용량 체크
2. **로그 분석**: docker logs로 에러 메시지 확인
3. **상세 조사**: docker exec로 컨테이너 내부 상태 점검
4. **원인 파악**: 수집한 정보를 바탕으로 문제점 분석

### 🤝 개별 분석 활동
**분석 포인트**:
1. **리소스 사용 패턴**: CPU/메모리 사용량이 정상 범위인가?
2. **로그 패턴**: 에러나 경고 메시지가 증가하고 있는가?
3. **네트워크 상태**: 네트워크 I/O가 비정상적으로 높은가?
4. **프로세스 상태**: 컨테이너 내 프로세스들이 정상 동작하는가?

### 💡 이해도 체크 질문
- ✅ "docker stats에서 CPU %가 100%라면 무엇을 의미하나요?"
- ✅ "메모리 사용률이 90%를 넘으면 어떤 문제가 발생할까요?"
- ✅ "docker logs -f와 docker logs의 차이점은 무엇인가요?"
- ✅ "컨테이너가 갑자기 종료되었을 때 원인을 어떻게 찾을까요?"

---

## 🔑 핵심 키워드
- **docker stats**: 실시간 리소스 사용량 모니터링
- **docker logs**: 컨테이너 로그 조회 및 분석
- **docker inspect**: 컨테이너 상세 정보 조회
- **docker top**: 컨테이너 내 프로세스 목록
- **docker exec**: 컨테이너 내부 명령 실행
- **실시간 모니터링**: 지속적인 시스템 상태 추적
- **로그 분석**: 로그를 통한 문제 진단 및 해결

---

## 📝 세션 마무리

### ✅ 오늘 세션 성과
- Docker 기본 모니터링 명령어 완전 습득
- 리소스 사용량 데이터 해석 능력 개발
- 로그 분석을 통한 문제 진단 기법 학습
- 실시간 모니터링 워크플로우 구축

### 🎯 다음 세션 준비
- **Session 2**: 시스템 모니터링 도구에서 더 깊은 분석 도구 학습
- **복습**: 오늘 배운 docker stats, logs 명령어 연습
- **예습**: htop, iotop 같은 시스템 도구에 대해 생각해보기

<div align="center">
**📊 CLI 명령어로 시스템을 완전히 파악하는 첫걸음! 📊**
*간단한 명령어가 강력한 모니터링 도구가 됩니다!*
</div>