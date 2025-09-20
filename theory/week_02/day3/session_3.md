# Week 2 Day 3 Session 3: 로그 분석과 문제 해결

<div align="center">
**📝 로그 마스터** • **🔍 문제 해결사**
*로그 분석을 통한 체계적인 문제 진단과 해결 방법*
</div>

---

## 🕘 세션 정보
**시간**: 11:00-11:50 (50분)
**목표**: 로그 분석을 통한 문제 해결 능력 개발
**방식**: 개인별 로그 분석 + 문제 해결 실습

## 🎯 세션 목표
### 📚 학습 목표
- **로그 이해**: Docker 로그 시스템과 드라이버 이해
- **분석 기법**: grep, awk, sed를 활용한 고급 로그 분석
- **패턴 인식**: 일반적인 오류 패턴과 해결 방법
- **문제 해결**: 로그를 통한 체계적인 문제 진단 프로세스

### 🤔 왜 필요한가? (5분)
**로그의 중요성**:
```
로그 = 시스템의 블랙박스
- 무엇이 일어났는지 (What)
- 언제 일어났는지 (When)  
- 어디서 일어났는지 (Where)
- 왜 일어났는지 (Why)
```

**실무에서의 로그 분석**:
- **장애 대응**: 문제 발생 시 가장 먼저 확인하는 정보
- **성능 최적화**: 병목 지점과 개선 포인트 발견
- **보안 분석**: 비정상적인 접근이나 공격 탐지
- **비즈니스 인사이트**: 사용자 행동 패턴 분석

---

## 📖 핵심 개념 (35분)

### 🔍 개념 1: Docker 로그 시스템 이해 (12분)

> **정의**: Docker가 컨테이너 로그를 수집, 저장, 관리하는 시스템

**Docker 로그 드라이버**:
```bash
# 현재 로그 드라이버 확인
docker info | grep "Logging Driver"

# 컨테이너별 로그 드라이버 확인
docker inspect container_name | grep LoggingDriver
```

**주요 로그 드라이버 종류**:
- **json-file** (기본): JSON 형태로 로컬 파일에 저장
- **syslog**: 시스템 syslog로 전송
- **journald**: systemd journal로 전송
- **none**: 로그 수집 안함

**로그 파일 위치**:
```bash
# 기본 로그 파일 위치
/var/lib/docker/containers/[container-id]/[container-id]-json.log

# 실제 로그 파일 찾기
docker inspect container_name | grep LogPath

# 로그 파일 직접 확인
sudo tail -f /var/lib/docker/containers/$(docker inspect --format='{{.Id}}' container_name)/$(docker inspect --format='{{.Id}}' container_name)-json.log
```

**로그 설정 옵션**:
```bash
# 로그 크기 제한
docker run --log-opt max-size=10m --log-opt max-file=3 nginx

# 로그 드라이버 변경
docker run --log-driver=syslog nginx

# 로그 비활성화
docker run --log-driver=none nginx
```

### 🔍 개념 2: 고급 로그 분석 기법 (12분)

> **정의**: grep, awk, sed 등을 활용한 효율적인 로그 분석 방법

**grep을 활용한 로그 필터링**:
```bash
# 에러 로그만 추출
docker logs container_name 2>&1 | grep -i error

# 특정 시간대 로그 필터링
docker logs -t container_name | grep "2024-01-01T14"

# 여러 패턴 동시 검색
docker logs container_name | grep -E "(error|warning|fail)"

# 대소문자 구분 없이 검색
docker logs container_name | grep -i "exception"

# 특정 패턴 제외
docker logs container_name | grep -v "INFO"

# 패턴 앞뒤 라인 포함
docker logs container_name | grep -A 5 -B 5 "ERROR"
```

**awk를 활용한 로그 분석**:
```bash
# 특정 필드만 추출 (공백으로 구분)
docker logs container_name | awk '{print $1, $4}'

# 조건부 필터링
docker logs container_name | awk '/ERROR/ {print $0}'

# 통계 계산 (에러 개수)
docker logs container_name | awk '/ERROR/ {count++} END {print "Errors:", count}'

# 시간대별 로그 개수
docker logs -t container_name | awk '{print substr($1,1,13)}' | sort | uniq -c
```

**sed를 활용한 로그 가공**:
```bash
# 특정 문자열 치환
docker logs container_name | sed 's/ERROR/[ERROR]/g'

# 특정 라인 삭제
docker logs container_name | sed '/DEBUG/d'

# 특정 패턴 라인만 출력
docker logs container_name | sed -n '/ERROR/p'
```

**복합 명령어 조합**:
```bash
# 시간대별 에러 통계
docker logs -t container_name | grep ERROR | awk '{print substr($1,1,13)}' | sort | uniq -c

# 가장 많이 발생한 에러 TOP 10
docker logs container_name | grep ERROR | sort | uniq -c | sort -nr | head -10

# 특정 시간 범위의 에러만 추출
docker logs -t container_name | awk '$1 >= "2024-01-01T10:00:00" && $1 <= "2024-01-01T11:00:00" && /ERROR/'
```

### 🔍 개념 3: 일반적인 오류 패턴과 해결 방법 (11분)

> **정의**: 컨테이너 환경에서 자주 발생하는 오류 패턴과 대응 방법

**메모리 관련 오류**:
```bash
# OOM (Out of Memory) 오류 패턴
docker logs container_name | grep -i "out of memory\|oom\|killed"

# 해결 방법
docker run -m 512m your_image  # 메모리 제한 설정
docker stats container_name    # 메모리 사용량 모니터링
```

**네트워크 관련 오류**:
```bash
# 연결 오류 패턴
docker logs container_name | grep -i "connection refused\|timeout\|network"

# 해결 방법
docker port container_name     # 포트 매핑 확인
docker network ls              # 네트워크 설정 확인
netstat -tulpn | grep PORT     # 포트 사용 상태 확인
```

**파일 시스템 오류**:
```bash
# 디스크 공간 부족 패턴
docker logs container_name | grep -i "no space left\|disk full\|permission denied"

# 해결 방법
df -h                          # 디스크 사용량 확인
docker system df               # Docker 디스크 사용량
docker system prune            # 불필요한 데이터 정리
```

**애플리케이션 오류**:
```bash
# 일반적인 애플리케이션 오류 패턴
docker logs container_name | grep -E "(500|404|exception|stack trace|fatal)"

# 로그 레벨별 분석
docker logs container_name | grep -E "(DEBUG|INFO|WARN|ERROR|FATAL)" | sort | uniq -c
```

**성능 관련 패턴**:
```bash
# 응답 시간 분석 (웹 서버 로그)
docker logs container_name | awk '{print $(NF-1)}' | sort -n | tail -10

# 느린 쿼리 패턴 (데이터베이스)
docker logs container_name | grep -i "slow query\|long query"
```

---

## 💭 함께 생각해보기 (10분)

### 🎯 실전 로그 분석 시나리오
**상황**: 웹 애플리케이션에서 간헐적으로 500 에러가 발생하고 있습니다.

**단계별 분석 과정**:

**1단계: 에러 발생 빈도 확인**
```bash
# 500 에러 발생 횟수
docker logs web-container | grep "500" | wc -l

# 시간대별 500 에러 분포
docker logs -t web-container | grep "500" | awk '{print substr($1,1,13)}' | sort | uniq -c
```

**2단계: 에러 패턴 분석**
```bash
# 500 에러와 함께 나타나는 다른 로그
docker logs web-container | grep -A 5 -B 5 "500"

# 특정 URL이나 기능에서 집중 발생하는지 확인
docker logs web-container | grep "500" | awk '{print $7}' | sort | uniq -c
```

**3단계: 근본 원인 추적**
```bash
# 메모리 부족 여부 확인
docker logs web-container | grep -i "memory\|oom"

# 데이터베이스 연결 문제 확인
docker logs web-container | grep -i "database\|connection\|timeout"

# 외부 API 호출 문제 확인
docker logs web-container | grep -i "api\|http\|request"
```

### 🤝 개별 분석 활동
**로그 분석 체크리스트**:
- [ ] **에러 빈도**: 에러가 언제, 얼마나 자주 발생하는가?
- [ ] **에러 패턴**: 특정 조건이나 시간에 집중되는가?
- [ ] **연관 로그**: 에러 전후에 다른 이상 징후가 있는가?
- [ ] **리소스 상태**: 메모리, CPU, 디스크 문제와 연관되는가?
- [ ] **외부 의존성**: 네트워크, 데이터베이스, API 문제인가?

### 💡 이해도 체크 질문
- ✅ "로그에서 'Connection refused' 에러가 나타나면 어떤 문제인가요?"
- ✅ "OOM Killer가 동작했다는 로그를 발견했을 때 어떻게 대응해야 하나요?"
- ✅ "로그 파일이 너무 커서 분석이 어려울 때 어떤 방법을 사용하나요?"
- ✅ "여러 컨테이너의 로그를 동시에 분석해야 할 때는 어떻게 하나요?"

---

## 🔑 핵심 키워드
- **Docker 로그 드라이버**: json-file, syslog, journald 등
- **로그 분석 도구**: grep, awk, sed, tail, head
- **로그 패턴**: 에러, 경고, 성능 관련 패턴
- **정규표현식**: 복잡한 패턴 매칭을 위한 표현식
- **로그 로테이션**: 로그 파일 크기 관리
- **중앙화 로깅**: 여러 컨테이너 로그 통합 관리
- **실시간 모니터링**: tail -f를 통한 실시간 로그 추적

---

## 📝 세션 마무리

### ✅ 오늘 세션 성과
- Docker 로그 시스템 완전 이해
- 고급 로그 분석 기법 습득 (grep, awk, sed)
- 일반적인 오류 패턴 인식 능력 개발
- 체계적인 문제 해결 프로세스 구축

### 🎯 다음 세션 준비
- **Session 4**: CLI 모니터링 실습에서 지금까지 배운 모든 기법을 종합 활용
- **복습**: 로그 분석 명령어들 실습
- **예습**: 부하 테스트 도구와 성능 측정에 대해 생각해보기

<div align="center">
**📝 로그가 말하는 모든 것을 이해하는 전문가가 되었습니다! 📝**
*이제 어떤 문제든 로그를 통해 해결할 수 있습니다!*
</div>