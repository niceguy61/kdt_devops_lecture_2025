# Week 2 Day 4 Session 2: 실무 Docker 워크플로우와 베스트 프랙티스

<div align="center">
**🏢 실무 워크플로우** • **⚙️ 베스트 프랙티스**
*실제 업무 환경에서 사용되는 Docker 워크플로우 완전 이해*
</div>

---

## 🕘 세션 정보
**시간**: 10:00-10:50 (50분)
**목표**: 실제 업무 환경에서 사용되는 Docker 워크플로우 완전 이해
**방식**: 이론 강의 + 페어 토론

## 🎯 세션 목표
### 📚 학습 목표
- **이해 목표**: 실제 업무 환경에서 사용되는 Docker 워크플로우 완전 이해
- **적용 목표**: 엔터프라이즈급 Docker 운영 방법론 습득
- **협업 목표**: 개별 학습 후 경험 공유 및 질의응답

## 📖 핵심 개념 (35분)

### 🔍 개념 1: 엔터프라이즈 Docker 워크플로우 (12분)
> **정의**: 대규모 조직에서 사용되는 체계적이고 안전한 Docker 운영 프로세스

**엔터프라이즈 워크플로우**:
```mermaid
graph TB
    subgraph "개발 단계"
        A[로컬 개발<br/>Docker Desktop] --> B[코드 커밋<br/>Git]
        B --> C[CI 파이프라인<br/>자동 빌드]
    end
    
    subgraph "보안 & 품질"
        D[이미지 스캔<br/>취약점 검사] --> E[품질 게이트<br/>정책 검증]
        E --> F[승인 프로세스<br/>코드 리뷰]
    end
    
    subgraph "배포 단계"
        G[스테이징 배포<br/>테스트 환경] --> H[프로덕션 배포<br/>운영 환경]
        H --> I[모니터링<br/>운영 관리]
    end
    
    C --> D
    F --> G
    I --> J[피드백<br/>지속적 개선]
    J --> A
    
    style A fill:#e8f5e8
    style B fill:#e8f5e8
    style C fill:#e8f5e8
    style D fill:#fff3e0
    style E fill:#fff3e0
    style F fill:#fff3e0
    style G fill:#f3e5f5
    style H fill:#f3e5f5
    style I fill:#f3e5f5
    style J fill:#4caf50
```

**워크플로우 단계별 상세**:

**1. 개발 단계**
- **로컬 개발**: Docker Desktop + VS Code Dev Containers
- **환경 일관성**: 개발/테스트/운영 환경 동일성 보장
- **빠른 피드백**: Hot reload와 실시간 디버깅

**2. CI/CD 통합**
- **자동 빌드**: Git push 시 자동 이미지 빌드
- **병렬 처리**: 멀티스테이지 빌드로 빌드 시간 단축
- **아티팩트 관리**: 이미지 태깅과 버전 관리

**3. 보안 통합**
- **Shift-Left**: 개발 초기 단계부터 보안 검사
- **자동화**: 파이프라인에 보안 스캔 통합
- **정책 적용**: 조직 보안 정책 자동 적용

### 🔍 개념 2: Docker 이미지 라이프사이클 관리 (12분)
> **정의**: 이미지 생성부터 폐기까지의 전체 생명주기를 체계적으로 관리하는 방법

**이미지 라이프사이클**:
```mermaid
graph LR
    subgraph "생성 단계"
        A[베이스 이미지<br/>선택] --> B[Dockerfile<br/>작성]
        B --> C[이미지 빌드<br/>최적화]
    end
    
    subgraph "관리 단계"
        D[레지스트리<br/>저장] --> E[태깅<br/>버전 관리]
        E --> F[스캔<br/>보안 검사]
    end
    
    subgraph "운영 단계"
        G[배포<br/>실행] --> H[모니터링<br/>성능 추적]
        H --> I[업데이트<br/>패치 적용]
    end
    
    subgraph "폐기 단계"
        J[사용 중단<br/>Deprecated] --> K[정리<br/>Clean up]
    end
    
    C --> D
    F --> G
    I --> J
    
    style A fill:#e8f5e8
    style B fill:#e8f5e8
    style C fill:#e8f5e8
    style D fill:#fff3e0
    style E fill:#fff3e0
    style F fill:#fff3e0
    style G fill:#f3e5f5
    style H fill:#f3e5f5
    style I fill:#f3e5f5
    style J fill:#ffebee
    style K fill:#ffebee
```

**라이프사이클 관리 도구**:
- **Harbor**: 엔터프라이즈 레지스트리
- **Notary**: 이미지 서명과 검증
- **Trivy**: 취약점 스캔
- **Portainer**: 컨테이너 관리 UI

**이미지 태깅 전략**:
```bash
# 시맨틱 버저닝
myapp:1.2.3
myapp:1.2
myapp:1
myapp:latest

# Git 기반 태깅
myapp:main-abc123f
myapp:feature-new-ui-def456a

# 환경별 태깅
myapp:1.2.3-dev
myapp:1.2.3-staging
myapp:1.2.3-prod
```

### 🔍 개념 3: 운영 모니터링과 관측성 (11분)
> **정의**: 컨테이너 환경에서의 포괄적인 관측성 확보 방안

**관측성 3요소**:
```mermaid
graph TB
    subgraph "관측성 (Observability)"
        A[메트릭<br/>Metrics] --> D[완전한 가시성]
        B[로그<br/>Logs] --> D
        C[추적<br/>Traces] --> D
    end
    
    subgraph "Docker 특화 도구"
        E[cAdvisor<br/>컨테이너 메트릭] --> A
        F[Docker Logs<br/>로그 수집] --> B
        G[Jaeger<br/>분산 추적] --> C
    end
    
    D --> H[문제 진단]
    D --> I[성능 최적화]
    D --> J[용량 계획]
    
    style A fill:#e8f5e8
    style B fill:#e8f5e8
    style C fill:#e8f5e8
    style D fill:#fff3e0
    style E fill:#f3e5f5
    style F fill:#f3e5f5
    style G fill:#f3e5f5
    style H fill:#4caf50
    style I fill:#4caf50
    style J fill:#4caf50
```

**모니터링 베스트 프랙티스**:
- **SLI/SLO 정의**: 서비스 수준 지표와 목표
- **알림 전략**: 중요도별 알림 체계
- **대시보드**: 역할별 맞춤 대시보드
- **자동 대응**: 임계치 기반 자동 스케일링

**엔터프라이즈 Docker 운영 전략**:

**1. 컨테이너 레지스트리 전략**:
```yaml
# Harbor 레지스트리 설정
apiVersion: v1
kind: ConfigMap
metadata:
  name: harbor-config
data:
  harbor.yml: |
    hostname: registry.company.com
    http:
      port: 80
    https:
      port: 443
      certificate: /data/cert/server.crt
      private_key: /data/cert/server.key
    
    # 데이터베이스 설정
    database:
      password: harbor_password
      max_idle_conns: 50
      max_open_conns: 1000
    
    # 레디스 설정
    redis:
      password: redis_password
    
    # 스토리지 설정
    storage_service:
      s3:
        region: us-west-1
        bucket: harbor-storage
        accesskey: AKIAIOSFODNN7EXAMPLE
        secretkey: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
    
    # 보안 스캔 설정
    trivy:
      ignore_unfixed: false
      skip_update: false
      insecure: false
```

**2. 컨테이너 라이프사이클 관리**:
```bash
#!/bin/bash
# container-lifecycle-manager.sh

# 컨테이너 라이프사이클 관리 스크립트

LOG_FILE="/var/log/container-lifecycle.log"
REGISTRY="registry.company.com"
NAMESPACE="production"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# 1. 이미지 보안 스캔
scan_image() {
    local image=$1
    log "Scanning image: $image"
    
    # Trivy 스캔
    trivy image --severity HIGH,CRITICAL --format json $image > /tmp/scan-result.json
    
    # 취약점 개수 확인
    vulnerabilities=$(jq '.Results[].Vulnerabilities | length' /tmp/scan-result.json 2>/dev/null || echo 0)
    
    if [ "$vulnerabilities" -gt 0 ]; then
        log "WARNING: $vulnerabilities vulnerabilities found in $image"
        return 1
    else
        log "SUCCESS: No high/critical vulnerabilities in $image"
        return 0
    fi
}

# 2. 이미지 배포
deploy_image() {
    local image=$1
    local deployment=$2
    
    log "Deploying image: $image to deployment: $deployment"
    
    # 보안 스캔 수행
    if scan_image $image; then
        # Kubernetes 배포 업데이트
        kubectl set image deployment/$deployment container=$image -n $NAMESPACE
        
        # 배포 상태 확인
        kubectl rollout status deployment/$deployment -n $NAMESPACE --timeout=300s
        
        if [ $? -eq 0 ]; then
            log "SUCCESS: Deployment $deployment updated successfully"
        else
            log "ERROR: Deployment $deployment failed, rolling back"
            kubectl rollout undo deployment/$deployment -n $NAMESPACE
        fi
    else
        log "ERROR: Security scan failed for $image, deployment aborted"
        return 1
    fi
}

# 3. 오래된 이미지 정리
cleanup_old_images() {
    log "Starting cleanup of old images"
    
    # 30일 이상 된 이미지 삭제
    docker image prune -a --filter "until=720h" --force
    
    # 레지스트리에서 오래된 이미지 삭제
    # Harbor API 사용
    curl -X DELETE \
        -H "Authorization: Basic $(echo -n admin:Harbor12345 | base64)" \
        "https://$REGISTRY/api/v2.0/projects/library/repositories/myapp/artifacts?q=push_time%3C$(date -d '30 days ago' +%s)"
    
    log "Cleanup completed"
}

# 4. 성능 모니터링
monitor_performance() {
    log "Monitoring container performance"
    
    # CPU 사용률 체크
    high_cpu_containers=$(docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}" | \
        awk 'NR>1 && $2+0 > 80 {print $1}')
    
    if [ ! -z "$high_cpu_containers" ]; then
        log "WARNING: High CPU usage detected in containers: $high_cpu_containers"
        # Slack 알림 전송
        send_slack_alert "High CPU usage detected" "$high_cpu_containers"
    fi
    
    # 메모리 사용률 체크
    high_memory_containers=$(docker stats --no-stream --format "table {{.Container}}\t{{.MemPerc}}" | \
        awk 'NR>1 && $2+0 > 85 {print $1}')
    
    if [ ! -z "$high_memory_containers" ]; then
        log "WARNING: High memory usage detected in containers: $high_memory_containers"
        send_slack_alert "High memory usage detected" "$high_memory_containers"
    fi
}

# Slack 알림 전송
send_slack_alert() {
    local title="$1"
    local message="$2"
    
    curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"$title: $message\"}" \
        $SLACK_WEBHOOK_URL
}

# 메인 실행 루프
case "$1" in
    scan)
        scan_image "$2"
        ;;
    deploy)
        deploy_image "$2" "$3"
        ;;
    cleanup)
        cleanup_old_images
        ;;
    monitor)
        monitor_performance
        ;;
    *)
        echo "Usage: $0 {scan|deploy|cleanup|monitor} [args...]"
        exit 1
        ;;
esac
```

**3. 비용 최적화 전략**:
```yaml
# 비용 모니터링 대시보드
apiVersion: v1
kind: ConfigMap
metadata:
  name: cost-monitoring-config
data:
  config.yaml: |
    cost_allocation:
      # 태그 기반 비용 할당
      tag_keys:
        - "team"
        - "environment"
        - "project"
        - "cost-center"
      
      # 리소스 비용 계산
      resource_costs:
        cpu_hour: 0.05  # $0.05 per CPU hour
        memory_gb_hour: 0.01  # $0.01 per GB memory hour
        storage_gb_month: 0.10  # $0.10 per GB storage month
        network_gb: 0.09  # $0.09 per GB network transfer
      
      # 알림 임계값
      alerts:
        daily_budget: 1000  # $1000 daily budget
        monthly_budget: 25000  # $25000 monthly budget
        cost_spike_threshold: 0.2  # 20% increase alert
    
    optimization:
      # 자동 스케일링 설정
      auto_scaling:
        enabled: true
        min_replicas: 2
        max_replicas: 10
        target_cpu_utilization: 70
        target_memory_utilization: 80
      
      # 리소스 예약 인스턴스
      reserved_instances:
        enabled: true
        utilization_threshold: 0.75  # 75% 이상 사용 시 예약
        commitment_period: "1year"
```

**실무 모니터링 설정**:
```yaml
# docker-compose.monitoring.yml
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.retention.time=30d'
      - '--web.enable-lifecycle'
  
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning

volumes:
  grafana-data:
```

## 💭 함께 생각해보기 (15분)

### 🤝 페어 토론 (10분)
**토론 주제**:
1. **워크플로우 설계**: "우리 조직에 맞는 Docker 워크플로우는 어떻게 설계해야 할까요?"
2. **보안 통합**: "개발 속도와 보안 사이의 균형을 어떻게 맞출까요?"
3. **모니터링 전략**: "가장 중요하게 모니터링해야 할 지표는 무엇일까요?"

### 🎯 전체 공유 (5분)
- **실무 적용**: 효과적인 Docker 운영 전략
- **조직 적용**: 팀/조직별 맞춤 워크플로우

## 🔑 핵심 키워드
- **Enterprise Workflow**: 엔터프라이즈 워크플로우
- **Image Lifecycle**: 이미지 라이프사이클
- **Semantic Versioning**: 시맨틱 버저닝
- **Container Registry**: 컨테이너 레지스트리
- **Observability Stack**: 관측성 스택

## 📝 세션 마무리
### ✅ 오늘 세션 성과
- 엔터프라이즈급 Docker 워크플로우 완전 이해
- 이미지 라이프사이클 관리 방법론 습득
- 실무 모니터링 및 관측성 구축 방안 학습

### 🎯 다음 세션 준비
- **Session 3**: 오케스트레이션 준비 & 로드맵
- **연결**: Docker 전문가에서 오케스트레이션으로

---

**다음**: [Session 3 - 오케스트레이션 준비 & 로드맵](./session_3.md)