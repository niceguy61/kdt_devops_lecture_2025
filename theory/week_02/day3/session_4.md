# Week 2 Day 3 Session 4: Docker Swarm 심화 실습

<div align="center">

**🐝 Swarm 심화** • **🛠️ 실무 실습** • **🚀 클러스터 운영**

*Docker Swarm을 활용한 실무급 클러스터 구축과 운영*

</div>

---

## 🕘 세션 정보

**시간**: 13:00-16:00 (3시간)  
**목표**: Docker Swarm을 활용한 실무급 멀티 서비스 클러스터 구축  
**방식**: 팀 기반 실습 + 실무 시나리오 + 문제 해결

---

## 🎯 실습 목표

### 📚 실습 목표
- **구축 목표**: 멀티 노드 Docker Swarm 클러스터 구성
- **배포 목표**: 실무급 마이크로서비스 애플리케이션 배포
- **운영 목표**: 서비스 스케일링, 업데이트, 장애 복구 경험

### 🤝 협업 목표
- 팀별로 역할을 분담하여 클러스터 구축
- 서로 다른 서비스를 담당하여 통합 시스템 완성
- 장애 상황 시뮬레이션과 협력적 문제 해결

---

## 📋 실습 준비 (15분)

### 🔧 환경 설정
**팀 구성**: 3-4명씩 팀 구성
**역할 분담**:
- **클러스터 관리자**: Swarm 클러스터 초기화 및 노드 관리
- **서비스 개발자**: 애플리케이션 서비스 개발 및 배포
- **네트워크 엔지니어**: 네트워크 구성 및 로드 밸런싱
- **모니터링 담당자**: 서비스 모니터링 및 로그 관리

**실습 환경**:
```bash
# 가상 멀티 노드 환경 구성 (Docker-in-Docker 사용)
docker run -d --privileged --name swarm-manager \
  -p 2377:2377 -p 7946:7946 -p 4789:4789 \
  docker:dind

docker run -d --privileged --name swarm-worker1 docker:dind
docker run -d --privileged --name swarm-worker2 docker:dind
```

---

## 🚀 Phase 1: Swarm 클러스터 구축 (60분)

### 🔧 멀티 노드 클러스터 구성

**Step 1: Swarm 클러스터 초기화**
```bash
# Manager 노드에서 Swarm 초기화
docker exec swarm-manager docker swarm init --advertise-addr eth0

# Join 토큰 확인
docker exec swarm-manager docker swarm join-token worker
docker exec swarm-manager docker swarm join-token manager
```

**Step 2: Worker 노드 추가**
```bash
# Worker 노드들을 클러스터에 추가
WORKER_TOKEN=$(docker exec swarm-manager docker swarm join-token worker -q)
MANAGER_IP=$(docker exec swarm-manager hostname -i)

docker exec swarm-worker1 docker swarm join --token $WORKER_TOKEN $MANAGER_IP:2377
docker exec swarm-worker2 docker swarm join --token $WORKER_TOKEN $MANAGER_IP:2377

# 클러스터 상태 확인
docker exec swarm-manager docker node ls
```

**Step 3: 노드 레이블링 및 제약 조건 설정**
```bash
# 노드에 레이블 추가
docker exec swarm-manager docker node update --label-add type=frontend swarm-worker1
docker exec swarm-manager docker node update --label-add type=backend swarm-worker2
docker exec swarm-manager docker node update --label-add type=database swarm-manager

# 노드 정보 확인
docker exec swarm-manager docker node inspect swarm-worker1 --format '{{.Spec.Labels}}'
```

### ✅ Phase 1 체크포인트
- [ ] 3노드 Swarm 클러스터 구성 완료
- [ ] 모든 노드가 Ready 상태 확인
- [ ] 노드별 레이블 설정 완료
- [ ] 클러스터 네트워크 통신 확인

---

## 🌟 Phase 2: 마이크로서비스 애플리케이션 배포 (90분)

### 🔧 실무급 애플리케이션 스택 구축

**Step 1: 오버레이 네트워크 생성**
```bash
# 프론트엔드 네트워크
docker exec swarm-manager docker network create \
  --driver overlay \
  --subnet 10.1.0.0/24 \
  frontend-net

# 백엔드 네트워크
docker exec swarm-manager docker network create \
  --driver overlay \
  --subnet 10.2.0.0/24 \
  backend-net

# 데이터베이스 네트워크 (내부 전용)
docker exec swarm-manager docker network create \
  --driver overlay \
  --internal \
  --subnet 10.3.0.0/24 \
  database-net
```

**Step 2: 데이터베이스 서비스 배포**
```bash
# PostgreSQL 데이터베이스 서비스
docker exec swarm-manager docker service create \
  --name postgres-db \
  --network database-net \
  --constraint 'node.labels.type==database' \
  --replicas 1 \
  --env POSTGRES_DB=myapp \
  --env POSTGRES_USER=admin \
  --env POSTGRES_PASSWORD=secret123 \
  --mount type=volume,source=postgres-data,target=/var/lib/postgresql/data \
  postgres:13-alpine

# Redis 캐시 서비스
docker exec swarm-manager docker service create \
  --name redis-cache \
  --network backend-net \
  --replicas 1 \
  --constraint 'node.labels.type==backend' \
  redis:7-alpine
```

**Step 3: 백엔드 API 서비스 배포**
```bash
# Node.js API 서비스
docker exec swarm-manager docker service create \
  --name api-service \
  --network backend-net \
  --network database-net \
  --constraint 'node.labels.type==backend' \
  --replicas 3 \
  --env DATABASE_URL=postgresql://admin:secret123@postgres-db:5432/myapp \
  --env REDIS_URL=redis://redis-cache:6379 \
  --publish 3000:3000 \
  --update-delay 10s \
  --update-parallelism 1 \
  --rollback-parallelism 1 \
  node:18-alpine sh -c "
    npm init -y && 
    npm install express pg redis && 
    echo 'const express = require(\"express\"); const app = express(); app.get(\"/\", (req, res) => res.json({service: \"api\", version: \"1.0\", node: process.env.HOSTNAME})); app.listen(3000);' > server.js && 
    node server.js
  "
```

**Step 4: 프론트엔드 웹 서비스 배포**
```bash
# Nginx 웹 서버 + 로드 밸런서
docker exec swarm-manager docker service create \
  --name web-frontend \
  --network frontend-net \
  --network backend-net \
  --constraint 'node.labels.type==frontend' \
  --replicas 2 \
  --publish 80:80 \
  --config source=nginx-config,target=/etc/nginx/nginx.conf \
  nginx:alpine

# Nginx 설정 파일 생성 (간단한 프록시 설정)
docker exec swarm-manager sh -c "
cat > /tmp/nginx.conf << 'EOF'
events { worker_connections 1024; }
http {
    upstream api {
        server api-service:3000;
    }
    server {
        listen 80;
        location / {
            return 200 'Frontend Service - Node: \$hostname\n';
            add_header Content-Type text/plain;
        }
        location /api/ {
            proxy_pass http://api/;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }
    }
}
EOF
"

# 설정을 Docker Config로 생성
docker exec swarm-manager docker config create nginx-config /tmp/nginx.conf
```

**Step 5: 모니터링 서비스 배포**
```bash
# Prometheus 모니터링
docker exec swarm-manager docker service create \
  --name prometheus \
  --network backend-net \
  --replicas 1 \
  --publish 9090:9090 \
  --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
  prom/prometheus:latest

# Grafana 대시보드
docker exec swarm-manager docker service create \
  --name grafana \
  --network backend-net \
  --replicas 1 \
  --publish 3001:3000 \
  --env GF_SECURITY_ADMIN_PASSWORD=admin \
  grafana/grafana:latest
```

### ✅ Phase 2 체크포인트
- [ ] 모든 서비스가 정상적으로 배포됨
- [ ] 네트워크 간 통신이 올바르게 작동
- [ ] 로드 밸런싱이 정상 동작
- [ ] 외부에서 웹 서비스 접근 가능

---

## 🏆 Phase 3: 서비스 운영 및 관리 (45분)

### 🔧 실무 운영 시나리오

**Step 1: 서비스 스케일링**
```bash
# 트래픽 증가 시나리오 - API 서비스 스케일 아웃
docker exec swarm-manager docker service scale api-service=5

# 프론트엔드 서비스 스케일 아웃
docker exec swarm-manager docker service scale web-frontend=4

# 스케일링 결과 확인
docker exec swarm-manager docker service ls
docker exec swarm-manager docker service ps api-service
```

**Step 2: 롤링 업데이트**
```bash
# API 서비스 업데이트 (새 버전 배포)
docker exec swarm-manager docker service update \
  --image node:18-alpine \
  --update-delay 30s \
  --update-parallelism 2 \
  --env-add VERSION=2.0 \
  api-service

# 업데이트 진행 상황 모니터링
watch "docker exec swarm-manager docker service ps api-service"
```

**Step 3: 장애 복구 시뮬레이션**
```bash
# 노드 장애 시뮬레이션 - Worker 노드 중단
docker stop swarm-worker1

# 서비스 재배치 확인
docker exec swarm-manager docker service ps web-frontend
docker exec swarm-manager docker node ls

# 노드 복구
docker start swarm-worker1

# 복구 후 상태 확인
sleep 30
docker exec swarm-manager docker node ls
```

**Step 4: 서비스 헬스 체크 및 자동 복구**
```bash
# 헬스 체크가 포함된 서비스 업데이트
docker exec swarm-manager docker service update \
  --health-cmd "curl -f http://localhost:3000/ || exit 1" \
  --health-interval 30s \
  --health-retries 3 \
  --health-timeout 10s \
  api-service

# 헬스 체크 상태 확인
docker exec swarm-manager docker service ps api-service
```

### ✅ Phase 3 체크포인트
- [ ] 서비스 스케일링 성공적 수행
- [ ] 무중단 롤링 업데이트 완료
- [ ] 노드 장애 시 자동 복구 확인
- [ ] 헬스 체크 기반 자동 복구 동작

---

## 🎤 결과 발표 및 공유 (30분)

### 📊 팀별 발표 (7분×4팀)
**발표 내용**:
1. **클러스터 아키텍처**: 구축한 Swarm 클러스터의 구조와 특징
2. **서비스 배포 전략**: 마이크로서비스 배포 방식과 네트워크 설계
3. **운영 경험**: 스케일링, 업데이트, 장애 복구 경험
4. **팀 협업**: 역할 분담과 협업 과정에서 배운 점
5. **실무 적용**: Docker Swarm의 실무 활용 가능성과 한계
6. **개선 아이디어**: 더 나은 클러스터 운영을 위한 아이디어

---

## 📝 실습 마무리

### ✅ 실습 성과
- [ ] 멀티 노드 Docker Swarm 클러스터 구축 완료
- [ ] 실무급 마이크로서비스 애플리케이션 배포 성공
- [ ] 서비스 스케일링과 롤링 업데이트 경험
- [ ] 장애 상황 대응과 자동 복구 메커니즘 이해
- [ ] 팀 협업을 통한 복잡한 시스템 구축 경험
- [ ] Docker Swarm의 실무 활용 가능성과 한계점 파악

### 🎯 다음 세션 준비
- **주제**: 개별 멘토링 및 학습 회고
- **연결**: Docker Swarm 경험을 바탕으로 한 오케스트레이션 이해

### 🚀 실무 연계 포인트
- **소규모 클러스터**: 중소기업에서 활용 가능한 간단한 오케스트레이션
- **개발 환경**: 로컬 개발 환경에서의 멀티 서비스 테스트
- **CI/CD 통합**: 지속적 배포 파이프라인과의 연계
- **모니터링**: 클러스터 상태와 서비스 성능 모니터링

### 🔮 Week 3 Kubernetes 준비
- **개념 연결**: Swarm Service → Kubernetes Deployment
- **네트워킹**: Overlay Network → Kubernetes Networking
- **스케일링**: Swarm Scale → Kubernetes HPA
- **배포**: Stack Deploy → Kubernetes Manifests

---

<div align="center">

**🐝 Docker Swarm 심화 실습을 성공적으로 완료했습니다!**

*이제 컨테이너 오케스트레이션의 기본기가 탄탄해졌습니다*

**다음**: [Session 5 - 개별 멘토링 & 학습 회고](./session_5.md)

</div>