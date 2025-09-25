# Week 1 Day 3 Session 3: Docker 네트워킹과 볼륨 관리

<div align="center">

**🌐 컨테이너 네트워킹** • **💾 데이터 영속성**

*마이크로서비스 통신과 데이터 관리의 실전 기법*

</div>

---

## 🕘 세션 정보

**시간**: 11:00-11:50 (50분)  
**목표**: Docker 네트워킹과 데이터 영속성 완전 마스터  
**방식**: 실습 중심 + 실무 시나리오 + 문제 해결

---

## 🎯 세션 목표

### 📚 학습 목표
- **이해 목표**: Docker 네트워킹 모델과 데이터 영속성 관리 완전 이해
- **적용 목표**: 컨테이너 간 통신과 데이터 보존 실무 기법 습득
- **협업 목표**: 3-tier 아키텍처 설계를 통한 실전 네트워킹 경험

### 🤔 왜 필요한가? (5분)

**실무 필수 시나리오**:
- 💼 **마이크로서비스**: 웹서버 ↔ API서버 ↔ 데이터베이스 통신
- 🏠 **일상 비유**: 아파트 단지의 내부 통신망과 개별 창고 시스템
- 📊 **확장성**: Netflix, Uber 같은 대규모 서비스의 기반 기술

**학습 전후 비교**:
```mermaid
graph LR
    A[학습 전<br/>단일 컨테이너만] --> B[학습 후<br/>복합 시스템 구축]
    
    style A fill:#ffebee
    style B fill:#e8f5e8
```

---

## 📖 핵심 개념 (35분)

### 🔍 개념 1: Docker 네트워킹 완전 정복 (12분)

> **정의**: 컨테이너 간 안전하고 효율적인 통신을 위한 네트워크 시스템

**🌐 네트워크 드라이버 종류와 실무 활용**
```mermaid
graph TB
    subgraph "Docker 네트워크 생태계"
        A[bridge<br/>기본 네트워크<br/>단일 호스트] --> E[컨테이너 통신]
        B[host<br/>호스트 네트워크<br/>최고 성능] --> E
        C[none<br/>네트워크 격리<br/>보안 중시] --> F[격리된 환경]
        D[overlay<br/>멀티 호스트<br/>클러스터 환경] --> G[분산 시스템]
        H[macvlan<br/>물리 네트워크<br/>레거시 연동] --> E
    end
    
    style A fill:#e8f5e8
    style B fill:#fff3e0
    style C fill:#ffebee
    style D fill:#e3f2fd
    style H fill:#f3e5f5
```

**📊 네트워크 타입별 실무 사용 사례**
| 네트워크 타입 | 사용 시나리오 | 성능 | 보안 | 복잡도 |
|---------------|---------------|------|------|--------|
| **bridge** | 개발환경, 단순 앱 | ⭐⭐⭐ | ⭐⭐⭐ | ⭐ |
| **host** | 고성능 요구, 모니터링 | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐ |
| **none** | 보안 중요, 배치 작업 | ⭐ | ⭐⭐⭐⭐⭐ | ⭐ |
| **overlay** | 마이크로서비스, 클러스터 | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

**🔧 실전 네트워킹 명령어**
```bash
# 1. 커스텀 네트워크 생성
docker network create --driver bridge myapp-network

# 2. 네트워크 상세 정보 확인
docker network inspect myapp-network

# 3. 서브넷과 게이트웨이 지정
docker network create --driver bridge \
  --subnet=172.20.0.0/16 \
  --ip-range=172.20.240.0/20 \
  --gateway=172.20.0.1 \
  custom-network

# 4. 네트워크에 컨테이너 연결
docker run -d --name web --network myapp-network nginx
docker run -d --name api --network myapp-network node:alpine

# 5. 실행 중인 컨테이너를 네트워크에 연결
docker network connect myapp-network existing-container
```

**🔍 포트 매핑과 서비스 디스커버리**
```mermaid
sequenceDiagram
    participant Client as 클라이언트
    participant Host as 호스트 (포트 8080)
    participant Web as 웹 컨테이너 (포트 80)
    participant API as API 컨테이너 (포트 3000)
    participant DB as DB 컨테이너 (포트 5432)
    
    Client->>Host: HTTP 요청 :8080
    Host->>Web: 포트 매핑 :80
    Web->>API: 내부 통신 api:3000
    API->>DB: 데이터 조회 db:5432
    DB->>API: 결과 반환
    API->>Web: JSON 응답
    Web->>Host: HTML 응답
    Host->>Client: 최종 응답
```

### 🔍 개념 2: 데이터 영속성과 볼륨 관리 (12분)

> **정의**: 컨테이너 생명주기와 독립적인 데이터 저장 및 관리 시스템

**💾 스토리지 옵션 심화 비교**
```mermaid
graph TB
    subgraph "Docker 스토리지 전략"
        A[Named Volumes<br/>docker volume create<br/>Docker 완전 관리] --> D[프로덕션 데이터]
        B[Anonymous Volumes<br/>임시 볼륨<br/>컨테이너와 함께 삭제] --> E[캐시 데이터]
        C[Bind Mounts<br/>호스트 경로 직접<br/>개발 환경] --> F[소스 코드]
        G[tmpfs Mounts<br/>메모리 저장<br/>민감한 임시 데이터] --> H[보안 데이터]
    end
    
    style A fill:#4caf50
    style B fill:#ff9800
    style C fill:#2196f3
    style G fill:#9c27b0
```

**🛠️ 실전 볼륨 관리 명령어**
```bash
# 1. Named Volume 생성 및 관리
docker volume create myapp-data
docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=192.168.1.100,rw \
  --opt device=:/path/to/dir \
  nfs-volume

# 2. 볼륨 상세 정보 확인
docker volume inspect myapp-data
docker volume ls

# 3. 데이터베이스 컨테이너에 볼륨 연결
docker run -d \
  --name postgres-db \
  --network myapp-network \
  -v myapp-data:/var/lib/postgresql/data \
  -e POSTGRES_DB=myapp \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=secret \
  postgres:13

# 4. Bind Mount로 개발 환경 구성
docker run -d \
  --name dev-web \
  --network myapp-network \
  -v $(pwd)/src:/usr/share/nginx/html \
  -p 8080:80 \
  nginx

# 5. tmpfs로 임시 데이터 처리
docker run -d \
  --name secure-app \
  --tmpfs /tmp:rw,noexec,nosuid,size=100m \
  myapp:latest
```

**📊 볼륨 백업과 복원 전략**
```bash
# 볼륨 백업
docker run --rm \
  -v myapp-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/myapp-backup.tar.gz -C /data .

# 볼륨 복원
docker run --rm \
  -v myapp-data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/myapp-backup.tar.gz -C /data

# 볼륨 간 데이터 복사
docker run --rm \
  -v old-volume:/from \
  -v new-volume:/to \
  alpine sh -c "cd /from && cp -av . /to"
```

### 🔍 개념 3: 실전 3-Tier 아키텍처 구축 (11분)

> **정의**: 웹서버, 애플리케이션 서버, 데이터베이스로 구성된 실무 표준 아키텍처

**🏗️ 3-Tier 아키텍처 설계**
```mermaid
graph TB
    subgraph "프론트엔드 티어"
        A[Nginx<br/>웹서버<br/>포트: 80, 443]
        A1[정적 파일 서빙]
        A2[리버스 프록시]
        A3[로드 밸런싱]
    end
    
    subgraph "애플리케이션 티어"
        B[Node.js API<br/>애플리케이션 서버<br/>포트: 3000]
        B1[비즈니스 로직]
        B2[API 엔드포인트]
        B3[인증/인가]
    end
    
    subgraph "데이터 티어"
        C[PostgreSQL<br/>데이터베이스<br/>포트: 5432]
        C1[데이터 저장]
        C2[트랜잭션 처리]
        C3[데이터 무결성]
    end
    
    subgraph "네트워크 & 스토리지"
        D[frontend-network<br/>외부 접근]
        E[backend-network<br/>내부 통신]
        F[db-volume<br/>데이터 영속성]
        G[app-logs<br/>로그 저장]
    end
    
    A --> B
    B --> C
    A -.-> D
    B -.-> E
    C -.-> E
    C -.-> F
    A -.-> G
    B -.-> G
    
    style A fill:#e3f2fd
    style B fill:#e8f5e8
    style C fill:#fff3e0
    style D,E fill:#f3e5f5
    style F,G fill:#ffebee
```

**🚀 실전 구축 스크립트**
```bash
#!/bin/bash
# 3-Tier 아키텍처 자동 구축 스크립트

# 1. 네트워크 생성
docker network create frontend-network
docker network create backend-network

# 2. 볼륨 생성
docker volume create postgres-data
docker volume create app-logs

# 3. 데이터베이스 티어 (가장 먼저 시작)
docker run -d \
  --name postgres-db \
  --network backend-network \
  -v postgres-data:/var/lib/postgresql/data \
  -e POSTGRES_DB=myapp \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=secret123 \
  postgres:13

# 4. 애플리케이션 티어
docker run -d \
  --name api-server \
  --network backend-network \
  -v app-logs:/app/logs \
  -e DATABASE_URL=postgresql://admin:secret123@postgres-db:5432/myapp \
  -e NODE_ENV=production \
  myapp-api:latest

# 5. 프론트엔드 티어
docker run -d \
  --name web-server \
  --network frontend-network \
  -p 80:80 \
  -p 443:443 \
  -v app-logs:/var/log/nginx \
  nginx:alpine

# 6. API 서버를 프론트엔드 네트워크에도 연결
docker network connect frontend-network api-server

# 7. 헬스체크 및 상태 확인
echo "🔍 서비스 상태 확인 중..."
sleep 10

docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
docker network ls
docker volume ls

echo "✅ 3-Tier 아키텍처 구축 완료!"
echo "🌐 웹사이트: http://localhost"
echo "📊 API 상태: http://localhost/api/health"
```

**🔧 고급 네트워킹 설정**
```bash
# 1. 네트워크 별칭 설정
docker run -d \
  --name api-server \
  --network backend-network \
  --network-alias api \
  --network-alias backend \
  myapp-api:latest

# 2. 포트 범위 매핑
docker run -d \
  --name load-balancer \
  -p 8080-8090:8080-8090 \
  nginx:alpine

# 3. 특정 IP 할당
docker run -d \
  --name static-ip-container \
  --network custom-network \
  --ip 172.20.0.100 \
  nginx:alpine

# 4. DNS 설정
docker run -d \
  --name web-with-dns \
  --network myapp-network \
  --dns 8.8.8.8 \
  --dns-search example.com \
  nginx:alpine

# 5. 네트워크 트래픽 제한
docker run -d \
  --name limited-container \
  --network myapp-network \
  --memory 512m \
  --cpus 0.5 \
  nginx:alpine
```

---

## 💭 함께 생각해보기 (10분)

### 🤝 페어 실습 (7분)
**실습 미션**:
1. **네트워크 설계**: "3-tier 아키텍처에서 보안을 위한 네트워크 분리 전략은?"
2. **데이터 관리**: "데이터베이스 컨테이너가 재시작되어도 데이터를 보존하려면?"
3. **성능 최적화**: "컨테이너 간 통신 성능을 향상시키는 방법은?"

**페어 활동 가이드**:
- 👥 **역할 분담**: 한 명은 네트워크 전문가, 한 명은 스토리지 전문가
- 🔄 **실습 진행**: 간단한 명령어로 네트워크와 볼륨 생성해보기
- 📝 **결과 공유**: 발견한 문제점과 해결 방안 정리

### 🎯 전체 공유 (3분)
- **네트워크 보안**: 프로덕션 환경에서의 네트워크 격리 전략
- **데이터 백업**: 볼륨 백업 자동화 방안
- **모니터링**: 네트워크와 스토리지 성능 모니터링 방법

---

## 🚨 실무 트러블슈팅 가이드

### 🔧 자주 발생하는 네트워크 문제
```bash
# 1. 컨테이너 간 통신 안 됨
docker network ls
docker network inspect [network-name]
docker exec [container] nslookup [target-container]

# 2. 포트 충돌 문제
docker ps --format "table {{.Names}}\t{{.Ports}}"
netstat -tulpn | grep [port]

# 3. DNS 해석 문제
docker exec [container] cat /etc/resolv.conf
docker exec [container] ping [target-container]

# 4. 네트워크 성능 문제
docker exec [container] iperf3 -c [target-container]
docker stats [container]
```

### 💾 볼륨 관련 문제 해결
```bash
# 1. 볼륨 마운트 실패
docker volume inspect [volume-name]
docker run --rm -v [volume]:/data alpine ls -la /data

# 2. 권한 문제
docker exec [container] ls -la /mounted/path
docker exec [container] id
docker run --user $(id -u):$(id -g) [image]

# 3. 디스크 공간 부족
docker system df
docker volume prune
docker system prune -a

# 4. 볼륨 데이터 손실
docker volume ls -f dangling=true
docker run --rm -v [volume]:/backup alpine tar -czf /backup.tar.gz /data
```

---

## 🔑 핵심 키워드

### 네트워킹
- **Bridge Network**: 기본 네트워크, 컨테이너 간 통신
- **Custom Network**: 사용자 정의 네트워크, 서비스 디스커버리
- **Port Mapping**: 호스트-컨테이너 포트 연결 (-p 옵션)
- **Network Alias**: 컨테이너의 네트워크 별칭
- **Service Discovery**: 컨테이너명으로 자동 DNS 해석

### 데이터 관리
- **Named Volume**: Docker 관리 영구 볼륨
- **Bind Mount**: 호스트 디렉토리 직접 마운트
- **tmpfs Mount**: 메모리 기반 임시 저장소
- **Volume Driver**: 볼륨 백엔드 드라이버 (local, nfs 등)
- **Data Persistence**: 컨테이너 독립적 데이터 영속성

### 아키텍처
- **3-Tier Architecture**: 프레젠테이션-애플리케이션-데이터 계층
- **Microservices**: 서비스별 독립적 컨테이너 구성
- **Load Balancing**: 트래픽 분산 처리
- **Reverse Proxy**: 백엔드 서비스 프록시

---

## 📝 세션 마무리

### ✅ 오늘 세션 성과
- [ ] Docker 네트워킹 모델 완전 이해 및 실습
- [ ] 데이터 영속성 관리 방법 습득
- [ ] 3-Tier 아키텍처 설계 및 구축 경험
- [ ] 실무 트러블슈팅 능력 향상
- [ ] 다음 실습을 위한 완벽한 준비

### 🎯 실습 연계 준비
- **연결고리**: 네트워킹과 볼륨 이론 → Dockerfile 빌드 → 멀티 컨테이너 실습
- **실습 내용**: 오늘 배운 네트워크와 볼륨을 활용한 실전 애플리케이션 구축
- **준비사항**: 커스텀 네트워크와 볼륨을 활용한 컨테이너 연결 실습

### 🚀 다음 단계 예고
- **Lab 1**: Dockerfile 작성 → 커스텀 이미지 빌드
- **Lab 2**: 네트워크와 볼륨을 활용한 멀티 컨테이너 구성
- **통합 프로젝트**: 3-Tier 웹 애플리케이션 완전 구축

---

<div align="center">

**🌐 Docker 네트워킹과 데이터 관리 마스터 완료**

*실무 수준의 컨테이너 통신과 데이터 영속성 완전 습득*

**다음**: [Lab 1 - Dockerfile 빌드 실습](./lab_1.md)

</div>