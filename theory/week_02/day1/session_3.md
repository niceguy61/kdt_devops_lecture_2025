# Week 2 Day 1 Session 3: 네트워크 보안 & 방화벽 설정

<div align="center">

**🛡️ 네트워크 보안** • **🚪 접근 제어** • **🔒 방화벽 설정**

*보안 강화된 컨테이너 네트워크 환경 구축*

</div>

---

## 🕘 세션 정보

**시간**: 11:00-11:50 (50분)  
**목표**: 보안 강화된 컨테이너 네트워크 환경 구축  
**방식**: 보안 개념 + 실제 위협 사례 + 방어 실습

---

## 🎯 학습 목표

### 📚 학습 목표 (명확하고 측정 가능한 목표)
- **이해 목표**: 컨테이너 네트워크 보안 위협과 방어 메커니즘 완전 이해
- **적용 목표**: 방화벽 규칙과 네트워크 분리를 실제 구현할 수 있는 능력
- **협업 목표**: 보안 정책을 팀과 함께 설계하고 적용할 수 있는 역량

### 🤔 왜 필요한가? (5분 - 동기부여 및 맥락 제공)

**현실 문제 상황**:
- 💼 **실무 시나리오**: "해커가 웹 서버를 통해 데이터베이스에 무단 접근했어요!"
- 🏠 **일상 비유**: 집에 현관문, 방문, 금고까지 여러 단계의 보안 장치가 있는 것처럼, 컨테이너도 다층 보안이 필요합니다
- 📊 **시장 동향**: 컨테이너 보안 사고가 매년 30% 증가, 네트워크 보안은 필수

**학습 전후 비교**:
```mermaid
graph LR
    A[학습 전<br/>모든 포트 개방<br/>무분별한 접근 허용] --> B[학습 후<br/>최소 권한 원칙<br/>체계적 접근 제어]
    
    style A fill:#ffebee
    style B fill:#e8f5e8
```

---

## 📖 핵심 개념 (35분 - 체계적 지식 구축)

### 🔍 개념 1: 네트워크 분리와 격리 전략 (12분)

> **정의**: 서로 다른 보안 수준의 서비스를 별도 네트워크로 분리하여 보안 위험을 최소화하는 전략

**상세 설명**:
- **핵심 원리**: 네트워크 세그멘테이션을 통한 공격 범위 제한
- **주요 특징**: 
  - DMZ(비무장지대) 개념 적용
  - 프론트엔드, 백엔드, 데이터베이스 계층 분리
  - 최소 권한 원칙 (Principle of Least Privilege)
- **사용 목적**: 보안 침해 시 피해 범위 최소화

**네트워크 분리 아키텍처**:
```mermaid
graph TB
    subgraph "외부 네트워크"
        I[Internet<br/>인터넷]
    end
    
    subgraph "DMZ 네트워크 (공개)"
        W[Web Server<br/>nginx:80]
        LB[Load Balancer<br/>haproxy:80]
    end
    
    subgraph "내부 네트워크 (보호)"
        A[API Server<br/>app:3000]
        C[Cache<br/>redis:6379]
    end
    
    subgraph "데이터 네트워크 (격리)"
        DB[Database<br/>mysql:3306]
        BK[Backup<br/>backup:22]
    end
    
    I --> W
    I --> LB
    W --> A
    LB --> A
    A --> C
    A --> DB
    DB --> BK
    
    style I fill:#ffebee
    style W fill:#fff3e0
    style LB fill:#fff3e0
    style A fill:#e8f5e8
    style C fill:#e8f5e8
    style DB fill:#e3f2fd
    style BK fill:#e3f2fd
```

**실생활 비유**: 
은행에서 고객 상담 공간, 직원 업무 공간, 금고실을 분리하는 것처럼, 컨테이너도 보안 수준에 따라 네트워크를 분리합니다.

**네트워크 분리 실습**:
```bash
# 보안 수준별 네트워크 생성
docker network create --driver bridge \
  --subnet=10.1.0.0/24 \
  dmz-network

docker network create --driver bridge \
  --subnet=10.2.0.0/24 \
  --internal \
  backend-network

docker network create --driver bridge \
  --subnet=10.3.0.0/24 \
  --internal \
  database-network

# 각 계층별 컨테이너 배치
docker run -d --name web-server \
  --network dmz-network \
  -p 80:80 nginx

docker run -d --name api-server \
  --network backend-network \
  node:alpine

docker run -d --name database \
  --network database-network \
  mysql:8.0

# 네트워크 간 연결 (필요한 경우만)
docker network connect backend-network web-server
docker network connect database-network api-server
```

### 🔍 개념 2: 방화벽 규칙과 포트 제한 (12분)

> **정의**: iptables와 Docker의 방화벽 기능을 활용하여 불필요한 네트워크 접근을 차단하는 보안 메커니즘

**단계별 이해**:
1. **1단계 (기본)**: Docker의 기본 방화벽 규칙 이해
2. **2단계 (중급)**: 커스텀 iptables 규칙 적용
3. **3단계 (고급)**: 애플리케이션 레벨 방화벽 구현

**실무 연결**:
- **사용 사례**: 
  - 데이터베이스 포트를 특정 서버에서만 접근 허용
  - 관리 포트(SSH, 모니터링)를 내부 네트워크에서만 접근
  - 외부 API 호출을 화이트리스트 기반으로 제한
- **장단점**: 
  - ✅ 장점: 강력한 접근 제어, 세밀한 규칙 설정
  - ❌ 단점: 설정 복잡성, 성능 오버헤드
- **대안 기술**: 클라우드 보안 그룹, 네트워크 ACL, 서비스 메시

**방화벽 규칙 구조**:
```mermaid
sequenceDiagram
    participant C as Client
    participant F as Firewall/iptables
    participant S as Server Container
    
    C->>F: 1. 연결 요청 (IP:Port)
    F->>F: 2. 규칙 검사
    
    alt 허용된 접근
        F->>S: 3. 요청 전달
        S->>F: 4. 응답 반환
        F->>C: 5. 응답 전달
    else 차단된 접근
        F->>C: 3. 연결 거부
    end
    
    Note over C,S: 방화벽 기반 접근 제어
```

**실제 방화벽 설정**:
```bash
# Docker 컨테이너 방화벽 설정
# 1. 기본 정책: 모든 접근 차단
docker run -d --name secure-db \
  --network database-network \
  mysql:8.0

# 2. 특정 IP에서만 접근 허용
iptables -A DOCKER-USER -s 10.2.0.0/24 -d 10.3.0.2 -p tcp --dport 3306 -j ACCEPT
iptables -A DOCKER-USER -d 10.3.0.2 -p tcp --dport 3306 -j DROP

# 3. 포트 스캔 방지
iptables -A DOCKER-USER -p tcp --tcp-flags ALL NONE -j DROP
iptables -A DOCKER-USER -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP

# 4. DDoS 방지 (연결 수 제한)
iptables -A DOCKER-USER -p tcp --dport 80 -m connlimit --connlimit-above 20 -j DROP

# 5. 규칙 확인
iptables -L DOCKER-USER -n -v
```

### 🔍 개념 3: 보안 모니터링과 로그 관리 (11분)

> **정의**: 네트워크 트래픽과 접근 시도를 실시간으로 모니터링하고 로그를 분석하여 보안 위협을 조기 발견하는 시스템

**개념 간 관계**:
```mermaid
graph TB
    subgraph "보안 모니터링 시스템"
        NM[Network Monitor<br/>트래픽 감시]
        AL[Access Log<br/>접근 기록]
        FW[Firewall Log<br/>차단 기록]
    end
    
    subgraph "분석 및 대응"
        LA[Log Analysis<br/>로그 분석]
        AD[Anomaly Detection<br/>이상 탐지]
        AR[Auto Response<br/>자동 대응]
    end
    
    subgraph "알림 시스템"
        EM[Email Alert<br/>이메일 알림]
        SM[SMS Alert<br/>SMS 알림]
        DH[Dashboard<br/>실시간 대시보드]
    end
    
    NM --> LA
    AL --> LA
    FW --> LA
    
    LA --> AD
    AD --> AR
    
    AR --> EM
    AR --> SM
    AR --> DH
    
    style NM fill:#e8f5e8
    style AL fill:#e8f5e8
    style FW fill:#e8f5e8
    style LA fill:#fff3e0
    style AD fill:#fff3e0
    style AR fill:#fff3e0
    style EM fill:#ffebee
    style SM fill:#ffebee
    style DH fill:#ffebee
```

**보안 모니터링 도구**:
- **네트워크 모니터링**: tcpdump, Wireshark, ntopng
- **로그 수집**: Fluentd, Logstash, Filebeat
- **이상 탐지**: Fail2ban, OSSEC, Suricata
- **시각화**: Grafana, Kibana, Splunk

**종합 비교표**:
| 구분 | 네트워크 분리 | 방화벽 규칙 | 보안 모니터링 |
|------|---------------|-------------|---------------|
| **목적** | 공격 범위 제한 | 접근 차단 | 위협 탐지 |
| **특징** | 물리적 격리 | 규칙 기반 차단 | 실시간 감시 |
| **사용 시기** | 아키텍처 설계 | 서비스 배포 | 운영 단계 |
| **장점** | 근본적 보안 | 세밀한 제어 | 조기 발견 |
| **주의사항** | 복잡성 증가 | 성능 영향 | 오탐 관리 |

**실제 보안 모니터링 구현**:
```bash
# 1. 네트워크 트래픽 모니터링
docker run -d --name network-monitor \
  --network host \
  --cap-add NET_ADMIN \
  -v /var/log:/var/log \
  nicolaka/netshoot tcpdump -i any -w /var/log/network.pcap

# 2. 접근 로그 수집 (nginx 예시)
docker run -d --name web-server \
  --network dmz-network \
  -v /var/log/nginx:/var/log/nginx \
  -p 80:80 nginx

# 3. 실시간 로그 분석
docker run -d --name log-analyzer \
  --network backend-network \
  -v /var/log:/var/log \
  elastic/filebeat:7.15.0

# 4. 이상 접근 탐지 스크립트
cat > security_monitor.sh << 'EOF'
#!/bin/bash
# 비정상적인 접근 패턴 탐지
tail -f /var/log/nginx/access.log | while read line; do
    # 1분에 100회 이상 접근 시 차단
    ip=$(echo $line | awk '{print $1}')
    count=$(grep $ip /var/log/nginx/access.log | grep $(date +"%d/%b/%Y:%H:%M") | wc -l)
    
    if [ $count -gt 100 ]; then
        echo "Blocking suspicious IP: $ip"
        iptables -A DOCKER-USER -s $ip -j DROP
        echo "$(date): Blocked $ip for excessive requests" >> /var/log/security.log
    fi
done
EOF

chmod +x security_monitor.sh
./security_monitor.sh &
```

**🔑 핵심 키워드 정리**:
- **Network Segmentation (네트워크 세그멘테이션)**: 네트워크 분할 - 보안 수준별 네트워크 분리
- **DMZ (Demilitarized Zone)**: 비무장지대 - 내외부 네트워크 사이의 완충 구역
- **Firewall Rules (방화벽 규칙)**: 접근 제어 규칙 - 트래픽 허용/차단 정책
- **Intrusion Detection (침입 탐지)**: 보안 위협 탐지 - 비정상 접근 패턴 발견
- **Log Analysis (로그 분석)**: 기록 분석 - 보안 이벤트 패턴 분석

---

## 🔗 전체 연결 및 정리 (15분 - 학습 통합)

### 📚 3개 세션 통합 맵
```mermaid
graph TB
    subgraph "Session 1: 네트워킹 기초"
        A1[Bridge Network<br/>기본 연결]
        A2[Host Network<br/>직접 연결]
        A3[Custom Network<br/>맞춤 설계]
    end
    
    subgraph "Session 2: 통신 심화"
        B1[Container Communication<br/>컨테이너 간 통신]
        B2[Service Discovery<br/>서비스 발견]
        B3[Load Balancing<br/>부하 분산]
    end
    
    subgraph "Session 3: 보안 강화"
        C1[Network Isolation<br/>네트워크 격리]
        C2[Firewall Rules<br/>방화벽 규칙]
        C3[Security Monitoring<br/>보안 모니터링]
    end
    
    A1 --> B1 --> C1
    A2 --> B2 --> C2
    A3 --> B3 --> C3
    
    C1 --> D[실습 Lab 1<br/>멀티 컨테이너 네트워크]
    C2 --> D
    C3 --> E[실습 Lab 2<br/>보안 강화 환경]
    
    style A1 fill:#e8f5e8
    style A2 fill:#e8f5e8
    style A3 fill:#e8f5e8
    style B1 fill:#fff3e0
    style B2 fill:#fff3e0
    style B3 fill:#fff3e0
    style C1 fill:#f3e5f5
    style C2 fill:#f3e5f5
    style C3 fill:#f3e5f5
    style D fill:#ffebee
    style E fill:#ffebee
```

### 🎯 실습 챌린지 준비
- **Lab 1 연결**: 네트워킹 기초 + 통신 설정 → 3-tier 아키텍처 구현
- **Lab 2 연결**: 보안 강화 + 모니터링 → 프로덕션급 보안 환경 구축

### 📋 학습 점검 체크리스트
- [ ] **기본 개념 이해**: Bridge, Host, Custom 네트워크와 통신 방법을 설명할 수 있다
- [ ] **실무 연계 파악**: 언제 어떤 보안 설정을 적용해야 하는지 안다
- [ ] **문제 해결 준비**: 네트워크 보안 문제 상황에 대응할 수 있다
- [ ] **실습 준비 완료**: 오후 실습에 필요한 모든 지식을 갖췄다

### 🔮 다음 학습 예고
- **내일 연결**: 네트워킹 보안 → 데이터 보안 (스토리지 & 백업)
- **주간 목표**: Docker 심화 기술 완성 → Kubernetes 준비
- **장기 비전**: 클라우드 네이티브 아키텍처의 네트워크 보안 전문가

---

## 💭 함께 생각해보기 (10분 - 상호작용 및 이해도 확인)

### 🤝 페어 토론 (5분)

**토론 주제**:
1. **개념 적용**: "우리 프로젝트에서 어떤 보안 위협이 있고, 어떻게 방어하시겠어요?"
2. **문제 해결**: "해킹 시도가 발견되었을 때 어떤 순서로 대응하시겠어요?"
3. **경험 공유**: "보안 사고나 네트워크 보안 관련 경험이 있다면 공유해주세요"

**페어 활동 가이드**:
- 👥 **자유 페어링**: 관심사나 이해도가 비슷한 사람끼리
- 🔄 **역할 교대**: 5분씩 설명자/질문자 역할 바꾸기
- 📝 **핵심 정리**: 대화 내용 중 중요한 점 메모하기

### 🎯 전체 공유 (5분)

- **인사이트 공유**: 페어 토론에서 나온 좋은 아이디어
- **질문 수집**: 아직 이해가 어려운 부분
- **다음 연결**: 오후 실습 "보안 강화된 네트워크 환경 구축"과의 연결고리 확인

**💡 이해도 체크 질문**:
- ✅ "네트워크 분리가 왜 중요한지 설명할 수 있나요?"
- ✅ "방화벽 규칙을 어떻게 설정해야 하는지 아시나요?"
- ✅ "보안 모니터링에서 어떤 것들을 확인해야 하는지 아시나요?"

---

## 🔑 핵심 키워드

- **Network Segmentation (네트워크 세그멘테이션)**: 보안 수준별 네트워크 분리
- **DMZ (Demilitarized Zone)**: 내외부 네트워크 사이의 완충 구역
- **Firewall Rules (방화벽 규칙)**: 트래픽 허용/차단 정책
- **iptables**: Linux 방화벽 관리 도구
- **Security Monitoring (보안 모니터링)**: 실시간 보안 위협 탐지

---

## 📝 세션 마무리

### ✅ 오늘 세션 성과
- [ ] 네트워크 분리와 격리 전략 완전 이해
- [ ] 방화벽 규칙과 포트 제한 설정 방법 습득
- [ ] 보안 모니터링과 로그 관리 개념 파악

### 🎯 다음 세션 준비
- **주제**: Lab 1 - 멀티 컨테이너 네트워크 구성
- **연결**: 오늘 배운 모든 네트워킹 지식을 실제로 구현

---

<div align="center">

**🛡️ 네트워크 보안의 모든 것을 마스터했습니다!**

**다음**: [Lab 1 - 멀티 컨테이너 네트워크 구성](./lab_1.md)

</div>