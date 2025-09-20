# Week 2 Day 3 Session 4: 보안 & 최적화 통합 실습

<div align="center">
**🛠️ 통합 실습** • **🔒 보안 강화** • **⚡ 성능 최적화**
*보안이 강화되고 성능이 최적화된 컨테이너 시스템 구축*
</div>

---

## 🕘 세션 정보
**시간**: 13:00-17:30 (4.5시간)
**목표**: 보안이 강화되고 성능이 최적화된 컨테이너 시스템 구축
**방식**: 팀 기반 통합 실습

## 🎯 실습 목표
### 📚 실습 목표
- 보안이 강화된 컨테이너 이미지 구축
- 성능 최적화된 애플리케이션 배포
- 포괄적인 모니터링 시스템 구축

---

## 📋 실습 준비 (15분)
**환경 설정**:
- 보안 스캔 도구 설치 (Trivy)
- 모니터링 스택 준비 (Prometheus, Grafana)
- 팀 구성 (3-4명씩)

---

## 🚀 Phase 1: 보안 강화 실습 (120분)

### 🔧 보안 스캔 및 이미지 강화
**Step 1: 취약점 스캔 및 분석**
```bash
# 기존 이미지 스캔
trivy image node:16

# 취약점이 많은 이미지와 적은 이미지 비교
trivy image node:16 > node16-scan.txt
trivy image node:18-alpine > node18-alpine-scan.txt

# 결과 비교 분석
diff node16-scan.txt node18-alpine-scan.txt
```

**Step 2: 보안 강화 Dockerfile 작성**
```dockerfile
# Dockerfile.secure
FROM node:18-alpine AS builder

# 보안: 패키지 업데이트
RUN apk update && apk upgrade && apk add --no-cache dumb-init

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

FROM node:18-alpine
RUN apk update && apk upgrade && apk add --no-cache dumb-init

# 보안: 비root 사용자 생성
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001 -G nodejs

WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --chown=nextjs:nodejs . .

# 보안: 비root 사용자로 전환
USER nextjs

# 보안: 불필요한 파일 제거
RUN rm -rf /app/tests /app/docs /app/*.md

EXPOSE 3000
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]
```

**Step 3: 보안 정책 적용**
```bash
# 보안 강화된 컨테이너 실행
docker run -d \
  --name secure-app \
  --read-only \
  --tmpfs /tmp \
  --tmpfs /var/run \
  --no-new-privileges \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  --memory="256m" \
  --cpus="0.5" \
  -p 3000:3000 \
  myapp:secure

# 보안 설정 확인
docker inspect secure-app | jq '.[] | {ReadonlyRootfs, SecurityOpt, CapAdd, CapDrop}'
```

### ✅ Phase 1 체크포인트
- [ ] 취약점 스캔 결과 분석 완료
- [ ] 보안 강화 이미지 빌드 성공
- [ ] 런타임 보안 정책 적용 확인
- [ ] 보안 설정 검증 완료

---

## 🌟 Phase 2: 성능 최적화 실습 (120분)

### 🔧 이미지 최적화 및 성능 튜닝
**Step 1: 멀티스테이지 빌드 최적화**
```dockerfile
# Dockerfile.optimized
FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine AS runner
WORKDIR /app
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001 -G nodejs

COPY --from=deps --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nextjs:nodejs /app/dist ./dist
COPY --from=builder --chown=nextjs:nodejs /app/public ./public

USER nextjs
EXPOSE 3000
CMD ["node", "dist/server.js"]
```

**Step 2: 이미지 크기 분석 및 최적화**
```bash
# 이미지 크기 비교
docker images | grep myapp

# 레이어 분석
docker history myapp:latest
docker history myapp:optimized

# dive 도구로 상세 분석 (설치 필요)
# dive myapp:optimized
```

**Step 3: 성능 벤치마크 테스트**
```bash
# Apache Bench로 성능 테스트
ab -n 10000 -c 100 http://localhost:3000/

# 리소스 사용량 모니터링
docker stats secure-app

# 성능 프로파일링
docker exec secure-app top
docker exec secure-app free -h
```

### ✅ Phase 2 체크포인트
- [ ] 멀티스테이지 빌드로 이미지 크기 50% 이상 감소
- [ ] 성능 벤치마크 테스트 완료
- [ ] 리소스 사용량 최적화 확인
- [ ] 응답 시간 개선 측정

---

## 🏆 Phase 3: 모니터링 시스템 구축 (90분)

### 🔧 통합 모니터링 스택 구축
**Step 1: Prometheus + Grafana 스택 배포**
```yaml
# monitoring-stack.yml
version: '3.8'
services:
  app:
    image: myapp:optimized
    ports:
      - "3000:3000"
    deploy:
      resources:
        limits:
          memory: 256M
          cpus: '0.5'
    
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - ./alerts.yml:/etc/prometheus/alerts.yml
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'
    
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-data:/var/lib/grafana
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./grafana/datasources:/etc/grafana/provisioning/datasources

volumes:
  grafana-data:
```

**Step 2: 커스텀 메트릭 구현**
```javascript
// app.js - 애플리케이션 메트릭 추가
const prometheus = require('prom-client');

// 기본 메트릭 수집
prometheus.collectDefaultMetrics();

// 커스텀 메트릭 정의
const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status']
});

const httpRequestTotal = new prometheus.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status']
});

// 메트릭 엔드포인트
app.get('/metrics', (req, res) => {
  res.set('Content-Type', prometheus.register.contentType);
  res.end(prometheus.register.metrics());
});
```

**Step 3: 대시보드 및 알림 설정**
```bash
# 모니터링 스택 시작
docker-compose -f monitoring-stack.yml up -d

# Grafana 접속 (admin/admin)
open http://localhost:3001

# Prometheus 접속
open http://localhost:9090

# 부하 테스트로 메트릭 생성
ab -n 5000 -c 50 http://localhost:3000/
```

### ✅ Phase 3 체크포인트
- [ ] Prometheus + Grafana 스택 정상 동작
- [ ] 애플리케이션 커스텀 메트릭 수집 확인
- [ ] 대시보드에서 실시간 메트릭 시각화
- [ ] 알림 규칙 설정 및 테스트 완료

---

## 🎤 결과 발표 및 공유 (40분)

### 📊 팀별 발표 (10분×4팀)
**발표 내용**:
1. **보안 강화 결과**: 취약점 스캔 결과와 보안 조치 효과
2. **성능 최적화 성과**: 이미지 크기 감소율과 성능 개선 지표
3. **모니터링 시스템**: 구축한 모니터링 대시보드와 핵심 메트릭
4. **통합 효과**: 보안, 성능, 모니터링의 통합적 효과
5. **실무 적용 계획**: 학습한 내용의 실무 적용 방안
6. **팀 협업 경험**: 협업 과정에서 배운 점과 시너지

---

## 📝 실습 마무리

### ✅ 실습 성과
- [ ] 컨테이너 보안 위협 모델 완전 이해
- [ ] 이미지 보안 스캔 및 런타임 보안 강화 실습 완료
- [ ] 이미지 최적화로 50% 이상 크기 감소 달성
- [ ] 성능 모니터링 및 튜닝 기법 습득
- [ ] Prometheus + Grafana 모니터링 스택 구축 완료
- [ ] SLI/SLO 기반 알림 시스템 설정 경험
- [ ] 보안-성능-모니터링 통합 접근법 체득

### 🎯 내일 준비사항
- **예습**: Week 1-2 전체 기술 스택 복습
- **복습**: 오늘 배운 보안, 최적화, 모니터링 개념 정리
- **환경**: 내일 통합 프로젝트를 위한 개발 환경 최종 점검

---

**다음**: [Day 4 - Week 1-2 종합 실습 & 프로젝트](../day4/README.md)