# Week 2 Day 4 Session 4: 오케스트레이션 체험 실습

<div align="center">
**🛠️ 실습 체험** • **🎼 오케스트레이션 실감**
*이론을 실제로 체험하며 오케스트레이션의 가치 확인*
</div>

---

## 🕘 세션 정보
**시간**: 13:00-16:00 (3시간)
**목표**: 오케스트레이션의 실제 가치를 체험으로 확인
**방식**: 3단계 실습 (문제 체험 → 해결 체험 → 미래 준비)

## 🎯 실습 목표
### 📚 학습 목표
- **문제 체험**: 단일 컨테이너 운영의 실제 한계 체감
- **해결 체험**: Docker Swarm을 통한 자동화 효과 확인
- **미래 준비**: Kubernetes 학습을 위한 환경과 마음가짐 준비

### 🤝 협업 목표
- **팀 실습**: 3-4명 팀으로 함께 문제 해결
- **역할 분담**: 각자 다른 역할로 오케스트레이션 체험
- **지식 공유**: 실습 과정에서 발견한 인사이트 공유

---

## 🛠️ Phase 1: 단일 컨테이너 장애 시나리오 체험 (90분)

### 🎯 Phase 1 목표
**"단일 컨테이너 운영이 왜 문제인지 몸으로 체험하기"**

### 📋 실습 환경 준비 (15분)
#### 🔧 기본 환경 설정
```bash
# 실습용 디렉토리 생성
mkdir -p ~/orchestration-lab/phase1
cd ~/orchestration-lab/phase1

# 간단한 웹 애플리케이션 준비
cat > app.py << 'EOF'
from flask import Flask
import os
import time
import random

app = Flask(__name__)

@app.route('/')
def hello():
    hostname = os.environ.get('HOSTNAME', 'unknown')
    # 가끔 느린 응답 시뮬레이션
    if random.random() < 0.1:
        time.sleep(2)
    return f'''
    <h1>Hello from {hostname}</h1>
    <p>Request processed successfully!</p>
    <p>Time: {time.strftime('%Y-%m-%d %H:%M:%S')}</p>
    '''

@app.route('/health')
def health():
    return 'OK'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

# Dockerfile 생성
cat > Dockerfile << 'EOF'
FROM python:3.9-slim
WORKDIR /app
COPY app.py .
RUN pip install flask
EXPOSE 5000
CMD ["python", "app.py"]
EOF

# 이미지 빌드
docker build -t simple-web:v1 .
```

### 🚀 실습 1: 단일 컨테이너 배포 (25분)
#### 📝 팀 역할 분담
- **👨💻 개발자**: 애플리케이션 배포 담당
- **🔧 운영자**: 모니터링 및 문제 대응
- **📊 테스터**: 부하 테스트 및 성능 측정
- **📋 기록자**: 문제 상황과 대응 과정 기록

#### 🔧 단일 컨테이너 실행
```bash
# 단일 컨테이너 실행
docker run -d --name web-app -p 8080:5000 simple-web:v1

# 상태 확인
docker ps
curl http://localhost:8080
```

#### 📊 정상 상태 확인
```bash
# 기본 성능 테스트
for i in {1..10}; do
    curl -s http://localhost:8080 | grep "Hello"
    sleep 1
done

# 리소스 사용량 확인
docker stats web-app --no-stream
```

### ⚡ 실습 2: 부하 테스트와 성능 한계 (25분)
#### 🔥 부하 테스트 도구 설치
```bash
# Apache Bench 설치 (Ubuntu/Debian)
sudo apt-get update && sudo apt-get install -y apache2-utils

# 또는 간단한 스크립트 사용
cat > load_test.sh << 'EOF'
#!/bin/bash
echo "Starting load test..."
for i in {1..100}; do
    curl -s http://localhost:8080 > /dev/null &
done
wait
echo "Load test completed"
EOF
chmod +x load_test.sh
```

#### 📈 부하 테스트 실행
```bash
# 가벼운 부하 테스트
ab -n 100 -c 10 http://localhost:8080/

# 리소스 사용량 실시간 모니터링
docker stats web-app
```

#### 📊 성능 한계 확인
**체크포인트**:
- [ ] CPU 사용률 90% 이상 도달
- [ ] 응답 시간 증가 확인
- [ ] 일부 요청 실패 발생
- [ ] 단일 컨테이너의 처리 한계 체감

### 💥 실습 3: 장애 시뮬레이션 (25분)
#### 🚨 컨테이너 강제 종료
```bash
# 컨테이너 강제 종료 (장애 시뮬레이션)
docker kill web-app

# 서비스 상태 확인
curl http://localhost:8080
# 결과: Connection refused

# 서비스 중단 시간 측정
echo "Service down at: $(date)"
```

#### 🔧 수동 복구 과정
```bash
# 1. 문제 인지 (사람이 직접 확인)
docker ps -a | grep web-app

# 2. 원인 분석
docker logs web-app

# 3. 수동 재시작
docker start web-app

# 4. 복구 확인
curl http://localhost:8080
echo "Service restored at: $(date)"
```

#### 📋 문제점 정리
**팀별 토론 (10분)**:
1. **다운타임**: 장애 인지부터 복구까지 소요 시간
2. **수동 작업**: 사람의 개입이 필요한 모든 단계
3. **확장성**: 트래픽 증가 시 대응의 어려움
4. **단일 장애점**: 하나 실패하면 전체 실패

---

## 🐳 Phase 2: Docker Swarm 기초 실습 (90분)

### 🎯 Phase 2 목표
**"오케스트레이션이 어떻게 문제를 해결하는지 직접 체험하기"**

### 🔧 실습 4: Docker Swarm 클러스터 구성 (30분)
#### 🏗️ Swarm 클러스터 초기화
```bash
# 새 디렉토리로 이동
mkdir -p ~/orchestration-lab/phase2
cd ~/orchestration-lab/phase2

# Swarm 클러스터 초기화
docker swarm init

# 클러스터 상태 확인
docker node ls
docker info | grep Swarm
```

#### 📝 서비스 정의 파일 생성
```yaml
# docker-compose.yml 생성
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  web:
    image: simple-web:v1
    ports:
      - "8080:5000"
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
    networks:
      - webnet

networks:
  webnet:
    driver: overlay
EOF
```

### 🚀 실습 5: 서비스 배포와 자동 확장 (30분)
#### 🎼 오케스트레이션 배포
```bash
# 스택 배포
docker stack deploy -c docker-compose.yml webapp

# 서비스 상태 확인
docker service ls
docker service ps webapp_web

# 컨테이너 분산 확인
docker ps | grep webapp_web
```

#### 📈 자동 스케일링 테스트
```bash
# 서비스 스케일 업
docker service scale webapp_web=5

# 스케일링 과정 관찰
watch docker service ps webapp_web

# 로드 밸런싱 확인
for i in {1..10}; do
    curl -s http://localhost:8080 | grep "Hello from"
done
```

### 🛡️ 실습 6: 자동 복구 체험 (30분)
#### 💥 장애 시뮬레이션
```bash
# 실행 중인 컨테이너 확인
docker ps | grep webapp_web

# 컨테이너 하나 강제 종료
CONTAINER_ID=$(docker ps | grep webapp_web | head -1 | awk '{print $1}')
docker kill $CONTAINER_ID

# 자동 복구 과정 관찰
watch docker service ps webapp_web
```

#### ✨ 자동 복구 확인
```bash
# 서비스 가용성 확인 (중단 없이 계속 응답)
while true; do
    curl -s http://localhost:8080 | grep "Hello from" || echo "Failed"
    sleep 1
done
```

#### 🔄 롤링 업데이트 체험
```bash
# 새 버전 이미지 빌드 (app.py 수정)
sed -i 's/Hello from/Greetings from/g' ../phase1/app.py
cd ../phase1
docker build -t simple-web:v2 .
cd ../phase2

# 롤링 업데이트 실행
docker service update --image simple-web:v2 webapp_web

# 업데이트 과정 관찰
watch docker service ps webapp_web
```

---

## ☸️ Phase 3: Kubernetes 개념 이해와 준비 (30분)

### 🎯 Phase 3 목표
**"Week 3 Kubernetes 학습을 위한 환경과 마음가짐 준비"**

### 🔧 실습 7: Kubernetes 환경 준비 (20분)
#### 🛠️ minikube 설치 및 설정
```bash
# minikube 설치 (Linux)
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# kubectl 설치
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# minikube 시작
minikube start

# 클러스터 상태 확인
kubectl cluster-info
kubectl get nodes
```

#### 🎯 간단한 Kubernetes 체험
```bash
# 간단한 배포 생성
kubectl create deployment hello-k8s --image=simple-web:v1

# 서비스 노출
kubectl expose deployment hello-k8s --type=NodePort --port=5000

# 서비스 접근
minikube service hello-k8s --url
```

### 📚 실습 8: Week 3 학습 계획 수립 (10분)
#### 🎯 팀별 학습 목표 설정
**팀 토론 주제**:
1. **개인 목표**: Week 3에서 각자 집중하고 싶은 Kubernetes 기능
2. **팀 프로젝트**: 함께 구축하고 싶은 Kubernetes 기반 시스템
3. **역할 분담**: Kubernetes 학습에서의 개인별 역할
4. **도전 과제**: 어려울 것 같은 부분과 대응 방안

#### 📋 학습 준비 체크리스트
- [ ] Kubernetes 기본 환경 설치 완료
- [ ] Docker Swarm과 Kubernetes 차이점 이해
- [ ] Week 3 학습 목표 개인별 설정
- [ ] 팀 프로젝트 아이디어 구상
- [ ] 어려운 부분에 대한 상호 지원 계획

---

## 📊 실습 성과 측정

### ✅ Phase별 체크포인트

#### Phase 1 성과
- [ ] 단일 컨테이너의 성능 한계 직접 체험
- [ ] 장애 발생 시 수동 복구 과정 경험
- [ ] 확장성 문제와 운영 복잡성 실감
- [ ] 오케스트레이션 필요성 완전 공감

#### Phase 2 성과
- [ ] Docker Swarm 클러스터 구성 성공
- [ ] 자동 스케일링과 로드 밸런싱 확인
- [ ] 자동 복구 기능 체험
- [ ] 롤링 업데이트 과정 관찰

#### Phase 3 성과
- [ ] Kubernetes 환경 설치 완료
- [ ] 기본 Kubernetes 명령어 체험
- [ ] Week 3 학습 계획 수립
- [ ] 팀 협업 방안 논의

### 🎯 실습 후 인사이트 공유
**팀별 발표 (5분×6팀 = 30분)**:
1. **가장 인상적인 순간**: 실습에서 가장 놀랐던 부분
2. **문제 해결 경험**: 어려웠던 문제와 해결 과정
3. **오케스트레이션 가치**: 자동화의 실제 효과
4. **Kubernetes 기대**: Week 3 학습에 대한 기대와 계획

---

## 🔑 실습 핵심 키워드

### 🆕 체험한 개념
- **자동 복구(Auto Recovery)**: 장애 시 사람 개입 없이 자동 복구
- **로드 밸런싱(Load Balancing)**: 여러 컨테이너로 요청 분산
- **롤링 업데이트(Rolling Update)**: 서비스 중단 없는 업데이트
- **서비스 디스커버리(Service Discovery)**: 서비스 자동 발견

### 🔤 실습 도구
- **Docker Swarm**: Docker 내장 오케스트레이션
- **minikube**: 로컬 Kubernetes 클러스터
- **kubectl**: Kubernetes 명령줄 도구
- **Apache Bench (ab)**: 웹 서버 성능 테스트 도구

## 📝 실습 마무리

### ✅ 오늘 실습 성과
- [x] 단일 컨테이너 한계를 몸으로 체험
- [x] Docker Swarm으로 오케스트레이션 효과 확인
- [x] Kubernetes 환경 준비 완료
- [x] Week 3 학습 동기와 계획 수립

### 🎯 다음 세션 준비
**Session 5 연결점**:
- 실습에서 느낀 점과 어려웠던 부분 개별 상담
- Kubernetes 학습에 대한 개인별 맞춤 조언
- Week 3 성공적 학습을 위한 준비 상태 점검

**정리할 내용**:
- 실습 과정에서 발생한 오류와 해결 방법
- 오케스트레이션의 실제 가치와 한계
- Kubernetes 학습에 대한 기대와 우려사항