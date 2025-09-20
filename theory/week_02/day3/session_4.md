# Week 2 Day 3 Session 4: CLI 모니터링 실습

<div align="center">
**🛠️ 실전 모니터링** • **🔍 문제 해결**
*부하 테스트 환경에서 CLI 도구를 활용한 실시간 모니터링과 문제 해결*
</div>

---

## 🕘 세션 정보
**시간**: 13:00-16:00 (3시간)
**목표**: CLI 모니터링 도구를 활용한 실전 문제 해결
**방식**: 개인별 실습 + 부하 테스트 + 문제 진단

## 🎯 세션 목표
### 📚 학습 목표
- **통합 모니터링**: Docker + 시스템 도구 종합 활용
- **부하 테스트**: 실제 부하 상황에서 모니터링 경험
- **문제 진단**: 성능 병목과 오류 원인 실시간 분석
- **자동화**: 모니터링 스크립트 작성과 활용

---

## 🛠️ 실습 챌린지 (3시간)

### 🎯 챌린지 개요
**목표**: 웹 애플리케이션에 부하를 가하면서 CLI 도구로 실시간 모니터링하고 문제점 발견

### 📋 Phase 1: 실습 환경 구성 (30분)

#### 🔧 테스트 애플리케이션 준비
**간단한 웹 애플리케이션 생성**:
```bash
# 작업 디렉토리 생성
mkdir monitoring-lab && cd monitoring-lab

# 간단한 Flask 애플리케이션 생성
cat > app.py << 'EOF'
from flask import Flask, request
import time
import random
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

@app.route('/')
def home():
    return "Hello World! Server is running."

@app.route('/cpu-intensive')
def cpu_intensive():
    # CPU 집약적 작업 시뮬레이션
    start = time.time()
    result = 0
    for i in range(1000000):
        result += i * i
    duration = time.time() - start
    app.logger.info(f"CPU intensive task completed in {duration:.2f}s")
    return f"CPU task completed in {duration:.2f} seconds"

@app.route('/memory-intensive')
def memory_intensive():
    # 메모리 집약적 작업 시뮬레이션
    app.logger.info("Starting memory intensive task")
    data = []
    for i in range(100000):
        data.append(f"Data item {i}" * 10)
    app.logger.info(f"Created {len(data)} items in memory")
    return f"Memory allocated for {len(data)} items"

@app.route('/slow-response')
def slow_response():
    # 느린 응답 시뮬레이션
    delay = random.uniform(1, 5)
    app.logger.warning(f"Slow response: sleeping for {delay:.2f}s")
    time.sleep(delay)
    return f"Response after {delay:.2f} seconds"

@app.route('/error')
def error():
    # 에러 시뮬레이션
    if random.choice([True, False]):
        app.logger.error("Simulated error occurred!")
        return "Internal Server Error", 500
    return "Success"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
EOF

# Dockerfile 생성
cat > Dockerfile << 'EOF'
FROM python:3.9-slim
WORKDIR /app
RUN pip install flask
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
EOF
```

#### 🚀 컨테이너 실행
```bash
# 이미지 빌드
docker build -t monitoring-test-app .

# 컨테이너 실행 (메모리 제한 설정)
docker run -d --name test-app -p 5000:5000 --memory=512m monitoring-test-app

# 애플리케이션 동작 확인
curl http://localhost:5000
```

#### ✅ Phase 1 체크포인트
- [ ] Flask 애플리케이션 생성 완료
- [ ] Docker 이미지 빌드 성공
- [ ] 컨테이너 정상 실행 확인
- [ ] 웹 애플리케이션 접속 확인

### 🌟 Phase 2: 기본 모니터링 설정 (45분)

#### 📊 모니터링 스크립트 작성
**실시간 모니터링 스크립트**:
```bash
# monitor.sh 생성
cat > monitor.sh << 'EOF'
#!/bin/bash

CONTAINER_NAME="test-app"
LOG_FILE="monitoring.log"

echo "=== 모니터링 시작: $(date) ===" | tee -a $LOG_FILE

# 함수 정의
monitor_docker() {
    echo "--- Docker Stats ---" | tee -a $LOG_FILE
    docker stats --no-stream $CONTAINER_NAME | tee -a $LOG_FILE
}

monitor_system() {
    echo "--- System Resources ---" | tee -a $LOG_FILE
    echo "CPU Usage:" | tee -a $LOG_FILE
    top -bn1 | grep "Cpu(s)" | tee -a $LOG_FILE
    
    echo "Memory Usage:" | tee -a $LOG_FILE
    free -h | tee -a $LOG_FILE
    
    echo "Disk Usage:" | tee -a $LOG_FILE
    df -h / | tee -a $LOG_FILE
}

check_logs() {
    echo "--- Recent Container Logs ---" | tee -a $LOG_FILE
    docker logs --tail 10 $CONTAINER_NAME | tee -a $LOG_FILE
}

# 메인 모니터링 루프
while true; do
    echo "=== $(date) ===" | tee -a $LOG_FILE
    monitor_docker
    monitor_system
    check_logs
    echo "================================" | tee -a $LOG_FILE
    sleep 10
done
EOF

chmod +x monitor.sh
```

#### 🔍 개별 모니터링 도구 준비
```bash
# 터미널 1: 실시간 Docker 모니터링
docker stats test-app

# 터미널 2: 실시간 로그 모니터링
docker logs -f test-app

# 터미널 3: 시스템 리소스 모니터링
htop

# 터미널 4: 네트워크 모니터링
watch -n 1 'netstat -tulpn | grep :5000'
```

#### ✅ Phase 2 체크포인트
- [ ] 모니터링 스크립트 작성 완료
- [ ] 여러 터미널에서 실시간 모니터링 설정
- [ ] 기본 상태에서의 리소스 사용량 확인
- [ ] 로그 출력 정상 동작 확인

### 🏆 Phase 3: 부하 테스트 및 문제 진단 (90분)

#### 🚀 부하 테스트 도구 설치
```bash
# Apache Bench 설치 (Ubuntu/Debian)
sudo apt install apache2-utils

# 또는 curl을 이용한 간단한 부하 테스트
```

#### 📈 시나리오 1: CPU 부하 테스트 (20분)
```bash
# CPU 집약적 엔드포인트에 부하 생성
ab -n 100 -c 10 http://localhost:5000/cpu-intensive

# 또는 curl을 이용한 반복 요청
for i in {1..20}; do
    curl http://localhost:5000/cpu-intensive &
done
wait
```

**모니터링 포인트**:
- docker stats에서 CPU % 변화 관찰
- htop에서 시스템 전체 CPU 사용률 확인
- 컨테이너 로그에서 응답 시간 변화 분석

**분석 질문**:
1. CPU 사용률이 최대 몇 %까지 올라갔나요?
2. 응답 시간이 어떻게 변화했나요?
3. 시스템 전체에 미친 영향은 어떤가요?

#### 💾 시나리오 2: 메모리 부하 테스트 (20분)
```bash
# 메모리 집약적 엔드포인트에 부하 생성
for i in {1..10}; do
    curl http://localhost:5000/memory-intensive &
done
wait
```

**모니터링 포인트**:
- docker stats에서 MEM USAGE 변화 관찰
- free -h로 시스템 메모리 상태 확인
- 컨테이너가 메모리 제한(512MB)에 도달하는지 확인

**분석 질문**:
1. 메모리 사용량이 어떻게 증가했나요?
2. 메모리 제한에 도달했을 때 어떤 일이 발생했나요?
3. OOM(Out of Memory) 에러가 발생했나요?

#### 🐌 시나리오 3: 응답 지연 테스트 (20분)
```bash
# 느린 응답 엔드포인트 테스트
ab -n 50 -c 5 http://localhost:5000/slow-response
```

**모니터링 포인트**:
- docker logs에서 응답 시간 로그 확인
- netstat으로 대기 중인 연결 수 확인
- 전체적인 시스템 응답성 변화 관찰

**분석 질문**:
1. 평균 응답 시간은 얼마나 되나요?
2. 동시 연결 수가 증가할 때 어떤 변화가 있나요?
3. 다른 엔드포인트에도 영향을 미치나요?

#### ❌ 시나리오 4: 에러 발생 상황 분석 (20분)
```bash
# 에러가 발생하는 엔드포인트 테스트
for i in {1..50}; do
    curl -s -o /dev/null -w "%{http_code}\n" http://localhost:5000/error
done | sort | uniq -c
```

**모니터링 포인트**:
- docker logs에서 에러 로그 패턴 분석
- 에러 발생 빈도와 패턴 확인
- 시스템 리소스와 에러 발생의 상관관계 분석

**분석 질문**:
1. 에러 발생률은 얼마나 되나요?
2. 에러 발생 시 특별한 패턴이 있나요?
3. 에러가 시스템 성능에 미치는 영향은?

#### 🔧 시나리오 5: 종합 부하 테스트 (10분)
```bash
# 모든 엔드포인트에 동시 부하 생성
ab -n 30 -c 3 http://localhost:5000/ &
ab -n 20 -c 2 http://localhost:5000/cpu-intensive &
ab -n 15 -c 2 http://localhost:5000/memory-intensive &
ab -n 25 -c 3 http://localhost:5000/slow-response &
ab -n 20 -c 2 http://localhost:5000/error &
wait
```

**종합 분석**:
- 모든 모니터링 도구의 데이터를 종합하여 분석
- 가장 큰 병목 지점 식별
- 시스템 한계점 파악

#### ✅ Phase 3 체크포인트
- [ ] 각 시나리오별 부하 테스트 완료
- [ ] 모니터링 데이터 수집 및 분석
- [ ] 성능 병목 지점 식별
- [ ] 에러 패턴 및 원인 분석

### 🎤 결과 분석 및 개선 방안 (15분)

#### 📊 수집된 데이터 정리
**모니터링 결과 요약**:
```bash
# 로그 파일에서 주요 지표 추출
echo "=== CPU 사용률 최대값 ==="
grep "CPU %" monitoring.log | awk '{print $3}' | sort -n | tail -1

echo "=== 메모리 사용량 최대값 ==="
grep "MEM USAGE" monitoring.log | awk '{print $4}' | sort -n | tail -1

echo "=== 에러 발생 횟수 ==="
docker logs test-app | grep -c "ERROR"

echo "=== 평균 응답 시간 ==="
docker logs test-app | grep "completed in" | awk '{print $NF}' | sed 's/s//' | awk '{sum+=$1; count++} END {print sum/count}'
```

#### 🔧 개선 방안 도출
**발견된 문제점과 해결책**:
1. **CPU 병목**: 
   - 문제: CPU 집약적 작업 시 응답 지연
   - 해결: CPU 제한 설정, 비동기 처리

2. **메모리 부족**:
   - 문제: 메모리 제한 도달 시 컨테이너 종료
   - 해결: 메모리 제한 증가, 메모리 효율적 코드

3. **응답 지연**:
   - 문제: 동기 처리로 인한 전체 성능 저하
   - 해결: 비동기 처리, 캐싱 적용

#### 💡 모니터링 자동화 스크립트 개선
```bash
# 개선된 모니터링 스크립트
cat > advanced_monitor.sh << 'EOF'
#!/bin/bash

CONTAINER_NAME="test-app"
ALERT_CPU_THRESHOLD=80
ALERT_MEM_THRESHOLD=400

monitor_with_alerts() {
    # CPU 사용률 체크
    CPU_USAGE=$(docker stats --no-stream $CONTAINER_NAME --format "{{.CPUPerc}}" | sed 's/%//')
    if (( $(echo "$CPU_USAGE > $ALERT_CPU_THRESHOLD" | bc -l) )); then
        echo "🚨 ALERT: High CPU usage: ${CPU_USAGE}%"
    fi
    
    # 메모리 사용량 체크
    MEM_USAGE=$(docker stats --no-stream $CONTAINER_NAME --format "{{.MemUsage}}" | cut -d'/' -f1 | sed 's/MiB//')
    if (( $(echo "$MEM_USAGE > $ALERT_MEM_THRESHOLD" | bc -l) )); then
        echo "🚨 ALERT: High memory usage: ${MEM_USAGE}MiB"
    fi
    
    # 에러 로그 체크
    ERROR_COUNT=$(docker logs --since 1m $CONTAINER_NAME | grep -c "ERROR")
    if [ $ERROR_COUNT -gt 0 ]; then
        echo "🚨 ALERT: $ERROR_COUNT errors in the last minute"
    fi
}

while true; do
    monitor_with_alerts
    sleep 30
done
EOF

chmod +x advanced_monitor.sh
```

---

## 💡 실습 팁

### 🟢 초급자를 위한 가이드
```bash
# 기본 모니터링 명령어 조합
watch -n 2 'echo "=== Docker Stats ==="; docker stats --no-stream test-app; echo "=== System ==="; free -h; echo "=== Errors ==="; docker logs --tail 5 test-app | grep ERROR'
```

### 🟡 중급자 도전 과제
```bash
# 성능 데이터 수집 및 분석
#!/bin/bash
# 1분간 성능 데이터 수집
for i in {1..60}; do
    echo "$(date),$(docker stats --no-stream test-app --format '{{.CPUPerc}},{{.MemUsage}}')" >> performance.csv
    sleep 1
done

# CSV 데이터 분석
echo "Average CPU: $(awk -F',' '{sum+=$2; count++} END {print sum/count}' performance.csv)"
```

### 🔴 고급자 심화 학습
```bash
# 실시간 성능 대시보드 (간단한 버전)
watch -n 1 '
clear
echo "=== 실시간 성능 대시보드 ==="
echo "시간: $(date)"
echo "CPU: $(docker stats --no-stream test-app --format "{{.CPUPerc}}")"
echo "메모리: $(docker stats --no-stream test-app --format "{{.MemUsage}}")"
echo "네트워크: $(docker stats --no-stream test-app --format "{{.NetIO}}")"
echo "최근 에러: $(docker logs --tail 1 test-app | grep ERROR || echo "없음")"
'
```

---

## 🔑 핵심 키워드
- **부하 테스트**: Apache Bench (ab)를 이용한 성능 테스트
- **실시간 모니터링**: 여러 도구를 조합한 종합 모니터링
- **성능 병목**: CPU, 메모리, 네트워크 병목 지점 식별
- **자동화 스크립트**: 반복 작업을 위한 bash 스크립트
- **알림 시스템**: 임계값 기반 자동 알림
- **데이터 분석**: 수집된 모니터링 데이터 분석
- **문제 해결**: 모니터링 데이터 기반 문제 진단

---

## 📝 세션 마무리

### ✅ 오늘 세션 성과
- CLI 도구를 활용한 실전 모니터링 경험
- 부하 테스트 환경에서 성능 분석 능력 개발
- 실시간 문제 진단과 해결 프로세스 구축
- 모니터링 자동화 스크립트 작성 능력

### 🎯 다음 세션 준비
- **Session 5**: 성능 최적화 멘토링에서 개별 맞춤 지원
- **복습**: 오늘 작성한 모니터링 스크립트 개선
- **예습**: 컨테이너 성능 최적화 방법에 대해 생각해보기

<div align="center">
**🛠️ 실전 모니터링 전문가가 되었습니다! 🛠️**
*이제 어떤 성능 문제든 CLI로 해결할 수 있습니다!*
</div>