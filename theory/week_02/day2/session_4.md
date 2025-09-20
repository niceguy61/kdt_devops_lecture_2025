# Week 2 Day 2 Session 4: 장애 시나리오 & 오케스트레이션 실습

<div align="center">

**🚨 장애 체험** • **🔄 오케스트레이션 실감**

*단일 컨테이너 장애를 직접 체험하고 오케스트레이션의 필요성 실감*

</div>

---

## 🕘 세션 정보

**시간**: 13:00-18:00 (5시간)  
**목표**: 단일 컨테이너 장애 상황을 직접 체험하고 오케스트레이션 효과 확인  
**방식**: 장애 시나리오 + 개별 Docker Swarm 실습 + 고급 오케스트레이션 체험

---

## 🎯 실습 목표

### 📚 실감 체험 목표
- 단일 컨테이너 장애 상황을 직접 체험
- Docker Swarm으로 문제 해결 경험
- 오케스트레이션의 필요성을 몸소 체감

---

## 📋 실습 준비 (15분)

### 환경 설정
- 단일 컨테이너 애플리케이션 준비
- 부하 테스트 도구 설치
- 개별 실습 환경 준비

---

## 🚀 Phase 1: 단일 컨테이너 장애 시나리오 체험 (120분)

### 🔧 장애 시나리오 구현

**Step 1: 취약한 단일 컨테이너 애플리케이션 배포**
```bash
# 메모리 누수가 있는 애플리케이션
docker run -d --name vulnerable-app \
  --memory=512m \
  -p 8080:3000 \
  memory-leak-app:latest

# 초기 상태 확인
curl http://localhost:8080/health
docker stats vulnerable-app
```

**Step 2: 부하 테스트로 장애 유발**
```bash
# Apache Bench로 부하 생성
ab -n 10000 -c 100 http://localhost:8080/

# 메모리 사용량 모니터링
watch -n 1 'docker stats --no-stream vulnerable-app'

# 애플리케이션 응답 시간 측정
while true; do
  curl -w "@curl-format.txt" -o /dev/null -s http://localhost:8080/
  sleep 1
done
```

**Step 3: 장애 상황 분석**
```bash
# 컨테이너 로그 확인
docker logs vulnerable-app

# 시스템 리소스 확인
docker exec vulnerable-app top
docker exec vulnerable-app free -h

# 장애 발생 시점 기록
echo "$(date): Container became unresponsive" >> failure-log.txt
```

### ✅ Phase 1 체크포인트
- [ ] 단일 컨테이너 장애 상황 직접 체험
- [ ] 메모리 누수로 인한 성능 저하 관찰
- [ ] 수동 복구의 어려움과 시간 소요 확인
- [ ] 서비스 중단 시간과 영향 범위 측정

---

## 🌟 Phase 2: Docker Swarm 기초 실습 (120분)

### 🔧 Swarm 클러스터 구축

**Step 1: Swarm 클러스터 초기화**
```bash
# Swarm 모드 초기화
docker swarm init --advertise-addr $(hostname -I | awk '{print $1}')

# 클러스터 상태 확인
docker node ls
docker info | grep Swarm
```

**Step 2: 고가용성 서비스 배포**
```bash
# 3개 복제본으로 서비스 생성
docker service create \
  --name web-service \
  --replicas 3 \
  --publish 8080:3000 \
  --update-delay 10s \
  --update-parallelism 1 \
  improved-app:latest

# 서비스 상태 확인
docker service ls
docker service ps web-service
```

**Step 3: 자동 복구 테스트**
```bash
# 컨테이너 강제 종료
docker kill $(docker ps -q --filter "label=com.docker.swarm.service.name=web-service" | head -1)

# 자동 복구 확인
watch -n 2 'docker service ps web-service'

# 서비스 가용성 확인
while true; do
  curl -s http://localhost:8080/health || echo "Service unavailable"
  sleep 1
done
```

**Step 4: 자동 스케일링 테스트**
```bash
# 부하 증가 시뮬레이션
ab -n 50000 -c 200 http://localhost:8080/ &

# 실시간 스케일링
docker service scale web-service=6

# 부하 감소 후 스케일 다운
docker service scale web-service=2
```

### ✅ Phase 2 체크포인트
- [ ] Docker Swarm 클러스터 구축 성공
- [ ] 자동 복구 기능 동작 확인
- [ ] 무중단 스케일링 체험
- [ ] 로드 밸런싱 동작 확인

---

## 🏆 Phase 3: 고급 오케스트레이션 시나리오 (90분)

### 🔧 복잡한 장애 시나리오 실습

**Step 1: 네트워크 분할 시뮬레이션**
```bash
# 네트워크 지연 시뮬레이션
sudo tc qdisc add dev eth0 root netem delay 100ms 20ms

# 패킷 손실 시뮬레이션
sudo tc qdisc change dev eth0 root netem loss 5%

# 서비스 응답 시간 모니터링
while true; do
  curl -w "Time: %{time_total}s\n" -o /dev/null -s http://localhost:8080/
  sleep 1
done
```

**Step 2: 롤링 업데이트 실습**
```bash
# 새 버전 이미지 빌드
docker build -t improved-app:v2 .

# 무중단 롤링 업데이트
docker service update \
  --image improved-app:v2 \
  --update-delay 30s \
  --update-parallelism 1 \
  web-service

# 업데이트 진행 상황 모니터링
watch -n 2 'docker service ps web-service'
```

**Step 3: 헬스체크 기반 자동 복구**
```bash
# 헬스체크가 포함된 서비스 생성
docker service create \
  --name health-service \
  --replicas 5 \
  --health-cmd "curl -f http://localhost:3000/health || exit 1" \
  --health-interval 10s \
  --health-retries 3 \
  --health-timeout 5s \
  --publish 8081:3000 \
  health-app:latest

# 헬스체크 실패 시뮬레이션
docker exec $(docker ps -q --filter "label=com.docker.swarm.service.name=health-service" | head -1) \
  pkill -f "node"

# 자동 복구 과정 관찰
watch -n 1 'docker service ps health-service --format "table {{.Name}}\t{{.CurrentState}}\t{{.Error}}"'
```

### ✅ Phase 3 체크포인트
- [ ] 네트워크 장애 상황에서의 서비스 동작 확인
- [ ] 무중단 롤링 업데이트 성공적 수행
- [ ] 헬스체크 기반 자동 복구 메커니즘 이해
- [ ] 복잡한 장애 상황에서의 오케스트레이션 효과 체험

---

## 🎯 Phase 4: 오케스트레이션 필요성 실감 (30분)

### 🤝 개별 종합 분석

**비교 항목**:
1. **가용성**: 단일 vs 오케스트레이션 환경에서의 서비스 가용 시간
2. **복구 시간**: 장애 발생 후 서비스 정상화까지 소요 시간
3. **운영 부담**: 수동 관리 vs 자동 관리의 운영자 개입 정도
4. **확장성**: 트래픽 증가 시 대응 능력

**결과 정리**:
```markdown
## 오케스트레이션 효과 분석

### 가용성 비교
- 단일 컨테이너: 장애 시 100% 서비스 중단
- Docker Swarm: 장애 시에도 66% 서비스 유지 (3개 중 2개 정상)

### 복구 시간 비교
- 단일 컨테이너: 수동 개입 필요 (5-10분)
- Docker Swarm: 자동 복구 (30초 이내)

### 운영 부담 비교
- 단일 컨테이너: 24/7 모니터링 필요
- Docker Swarm: 자동 관리로 운영 부담 80% 감소
```

---

## 🎤 결과 발표 및 공유 (40분)

### 개별 결과 공유 (40분)
- 단일 컨테이너 vs 오케스트레이션 장애 대응 비교
- 복잡한 장애 시나리오에서의 자동 복구 효과
- 롤링 업데이트와 헬스체크의 실무적 가치
- Kubernetes 학습 전 Docker Swarm으로 얻은 인사이트
- 실무 환경에서의 오케스트레이션 도입 전략

---

## 📝 실습 마무리

### ✅ 실습 성과
- [ ] 단일 컨테이너 운영의 한계점 직접 체험
- [ ] 오케스트레이션의 핵심 개념과 가치 완전 이해
- [ ] Docker Swarm 기초부터 고급 기능까지 실습 완료
- [ ] 복잡한 장애 상황에서의 자동 복구 메커니즘 체험
- [ ] 무중단 배포와 헬스체크 시스템 구축 경험
- [ ] 오케스트레이션 필요성에 대한 확신 획득

### 🎯 다음 단계 준비
- **내일 주제**: Kubernetes 아키텍처 & 핵심 개념
- **연결**: Docker Swarm 경험을 바탕으로 한 Kubernetes 학습

---

<div align="center">

**🚨 오케스트레이션의 필요성을 완전히 체감했습니다!**

**다음**: [Session 5 - 개별 멘토링 & 회고](./session_5.md)

</div>