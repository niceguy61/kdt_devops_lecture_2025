# Session 7: 이미지 보안 및 스캐닝

## 📍 교과과정에서의 위치
이 세션은 **Week 1 > Day 4**의 일곱 번째 세션으로, Docker 이미지의 보안 강화와 취약점 스캐닝 기법을 학습합니다. 이전 세션에서 구축하고 배포한 이미지들의 보안성을 평가하고 강화하는 전문적인 보안 관리 방법론을 마스터합니다.

## 학습 목표 (5분)
- **컨테이너 이미지 보안** 모범 사례와 **위협 모델** 이해
- **취약점 스캐닝 도구** 활용과 **자동화된 보안 검사** 구현
- **보안 정책** 수립과 **컴플라이언스** 관리 기법 습득
- **런타임 보안** 강화와 **보안 모니터링** 시스템 구축

## 1. 컨테이너 보안 위협 모델 (15분)

### 컨테이너 보안 계층 구조

컨테이너 보안은 **다층 방어(Defense in Depth)** 전략을 통해 각 계층에서 보안을 강화해야 합니다.

![보안 스캐닝 파이프라인](../images/security-scanning-pipeline.svg)

```mermaid
graph TB
    subgraph "컨테이너 보안 계층"
        A[애플리케이션 계층<br/>코드, 의존성, 설정]
        B[컨테이너 이미지 계층<br/>베이스 이미지, 패키지]
        C[컨테이너 런타임 계층<br/>Docker, containerd]
        D[호스트 OS 계층<br/>커널, 시스템 서비스]
        E[인프라 계층<br/>네트워크, 스토리지]
    end
    
    subgraph "보안 위협"
        F[악성 코드 삽입]
        G[취약한 의존성]
        H[권한 상승]
        I[데이터 유출]
        J[서비스 거부]
    end
    
    subgraph "보안 대책"
        K[코드 스캐닝]
        L[이미지 스캐닝]
        M[런타임 보호]
        N[접근 제어]
        O[모니터링]
    end
    
    A --> F
    B --> G
    C --> H
    D --> I
    E --> J
    
    F --> K
    G --> L
    H --> M
    I --> N
    J --> O
    
    style A fill:#ffcdd2,stroke:#d32f2f
    style B fill:#fff3e0,stroke:#f57c00
    style C fill:#e8f5e8,stroke:#4caf50
    style D fill:#e1f5fe,stroke:#0277bd
    style E fill:#f3e5f5,stroke:#7b1fa2
```

### 주요 보안 위협 유형

| 위협 유형 | 설명 | 영향도 | 대응 방안 |
|-----------|------|--------|----------|
| **취약한 베이스 이미지** | 알려진 CVE가 포함된 이미지 | 높음 | 정기적 업데이트, 스캐닝 |
| **권한 상승** | 불필요한 root 권한 사용 | 높음 | 최소 권한 원칙 |
| **시크릿 노출** | 하드코딩된 패스워드/키 | 높음 | 시크릿 관리 시스템 |
| **악성 패키지** | 공급망 공격을 통한 악성 코드 | 중간 | 패키지 검증, 서명 확인 |
| **설정 오류** | 잘못된 보안 설정 | 중간 | 보안 정책 자동화 |

### 보안 모범 사례 체크리스트

```dockerfile
# ❌ 보안에 취약한 Dockerfile
FROM ubuntu:latest
RUN apt-get update && apt-get install -y curl
COPY . /app
USER root
EXPOSE 22
CMD ["/app/start.sh"]

# ✅ 보안이 강화된 Dockerfile
# 1. 특정 버전 태그 사용
FROM ubuntu:20.04@sha256:sha256:8ae9bafbb64f63a50caab98fd3a5e37b3eb837a3e0780b78e5218e63193961f9

# 2. 보안 업데이트 적용
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        curl=7.68.0-1ubuntu2.* \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 3. 비특권 사용자 생성
RUN groupadd -r appgroup && \
    useradd -r -g appgroup -s /bin/false appuser

# 4. 최소 권한으로 파일 복사
COPY --chown=appuser:appgroup --chmod=755 app/ /app/

# 5. 비특권 사용자로 실행
USER appuser

# 6. 필요한 포트만 노출
EXPOSE 8080

# 7. 보안 강화된 실행
CMD ["/app/start.sh"]
```

## 2. 취약점 스캐닝 도구 활용 (20분)

### Docker Scout (공식 도구)

```bash
# Docker Scout 활성화
docker scout --help

# 이미지 취약점 스캔
docker scout cves myapp:latest

# 상세 스캔 결과
docker scout cves --format sarif myapp:latest > scan-results.sarif

# 권장사항 확인
docker scout recommendations myapp:latest

# 베이스 이미지 비교
docker scout compare --to ubuntu:22.04 ubuntu:20.04

# CI/CD 통합용 JSON 출력
docker scout cves --format json myapp:latest | jq '.vulnerabilities | length'
```

### Trivy (오픈소스 스캐너)

```bash
# Trivy 설치 (Linux)
sudo apt-get update
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy

# 기본 이미지 스캔
trivy image myapp:latest

# 심각도별 필터링
trivy image --severity HIGH,CRITICAL myapp:latest

# 특정 취약점 유형만 스캔
trivy image --vuln-type os myapp:latest
trivy image --vuln-type library myapp:latest

# JSON 형식 출력
trivy image --format json myapp:latest > trivy-results.json

# 시크릿 스캔
trivy fs --security-checks secret .

# Dockerfile 스캔
trivy config Dockerfile

# 종합 스캔 (이미지 + 설정 + 시크릿)
trivy image --security-checks vuln,config,secret myapp:latest
```

### Clair (CoreOS 스캐너)

```yaml
# docker-compose.yml - Clair 설정
version: '3.8'

services:
  postgres:
    image: postgres:13
    environment:
      POSTGRES_DB: clair
      POSTGRES_USER: clair
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  clair:
    image: quay.io/coreos/clair:v4.7.1
    depends_on:
      - postgres
    ports:
      - "6060:6060"
      - "6061:6061"
    volumes:
      - ./clair-config.yaml:/etc/clair/config.yaml
    command: ["clair", "-conf", "/etc/clair/config.yaml"]

  clairctl:
    image: quay.io/coreos/clair:v4.7.1
    depends_on:
      - clair
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    entrypoint: ["clairctl"]

volumes:
  postgres_data:
```

```yaml
# clair-config.yaml
http_listen_addr: ":6060"
introspection_addr: ":6061"
log_level: "info"

indexer:
  connstring: "postgres://clair:password@postgres:5432/clair?sslmode=disable"
  scanlock_retry: 10
  layer_scan_concurrency: 5
  migrations: true

matcher:
  connstring: "postgres://clair:password@postgres:5432/clair?sslmode=disable"
  max_conn_pool: 100
  migrations: true

notifier:
  connstring: "postgres://clair:password@postgres:5432/clair?sslmode=disable"
  migrations: true
  indexer_addr: "http://clair:6060"
```

```bash
# Clair 실행
docker-compose up -d

# 이미지 스캔
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  quay.io/coreos/clair:v4.7.1 clairctl \
  --config http://clair:6060 \
  report myapp:latest
```

### Snyk (상용 도구)

```bash
# Snyk CLI 설치
npm install -g snyk

# 인증
snyk auth

# 컨테이너 이미지 스캔
snyk container test myapp:latest

# Dockerfile 스캔
snyk iac test Dockerfile

# 모니터링 설정
snyk container monitor myapp:latest

# JSON 결과 출력
snyk container test myapp:latest --json > snyk-results.json

# 심각도 임계값 설정
snyk container test myapp:latest --severity-threshold=high
```

## 3. 자동화된 보안 파이프라인 (10분)

### GitHub Actions 보안 워크플로우

```yaml
# .github/workflows/security-scan.yml
name: Security Scan

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 2 * * *'  # 매일 새벽 2시 스캔

jobs:
  security-scan:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Build Docker image
      run: |
        docker build -t ${{ github.repository }}:${{ github.sha }} .
        docker tag ${{ github.repository }}:${{ github.sha }} ${{ github.repository }}:latest

    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: '${{ github.repository }}:${{ github.sha }}'
        format: 'sarif'
        output: 'trivy-results.sarif'

    - name: Upload Trivy scan results to GitHub Security tab
      uses: github/codeql-action/upload-sarif@v2
      if: always()
      with:
        sarif_file: 'trivy-results.sarif'

    - name: Run Docker Scout
      uses: docker/scout-action@v1
      with:
        command: cves
        image: ${{ github.repository }}:${{ github.sha }}
        sarif-file: scout-results.sarif

    - name: Snyk Container Scan
      uses: snyk/actions/docker@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        image: ${{ github.repository }}:${{ github.sha }}
        args: --severity-threshold=high

    - name: Security Gate
      run: |
        # 심각한 취약점이 발견되면 빌드 실패
        CRITICAL_VULNS=$(docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
          aquasec/trivy image --severity CRITICAL --format json \
          ${{ github.repository }}:${{ github.sha }} | \
          jq '.Results[]?.Vulnerabilities | length')
        
        if [ "$CRITICAL_VULNS" -gt 0 ]; then
          echo "❌ Critical vulnerabilities found: $CRITICAL_VULNS"
          exit 1
        else
          echo "✅ No critical vulnerabilities found"
        fi

    - name: Generate Security Report
      run: |
        cat > security-report.md << 'EOF'
        # Security Scan Report
        
        **Image:** ${{ github.repository }}:${{ github.sha }}
        **Scan Date:** $(date)
        
        ## Scan Results
        - Trivy: [View Results](trivy-results.sarif)
        - Docker Scout: [View Results](scout-results.sarif)
        - Snyk: Check Actions logs
        
        ## Security Status
        ✅ All security checks passed
        EOF

    - name: Comment PR with security results
      if: github.event_name == 'pull_request'
      uses: actions/github-script@v6
      with:
        script: |
          const fs = require('fs');
          const report = fs.readFileSync('security-report.md', 'utf8');
          
          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: report
          });
```

### Jenkins 보안 파이프라인

```groovy
// Jenkinsfile - 보안 스캔 파이프라인
pipeline {
    agent any
    
    environment {
        IMAGE_NAME = "${env.JOB_NAME}:${env.BUILD_NUMBER}"
        REGISTRY = "your-registry.com"
    }
    
    stages {
        stage('Build') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}")
                }
            }
        }
        
        stage('Security Scan') {
            parallel {
                stage('Trivy Scan') {
                    steps {
                        script {
                            sh """
                                trivy image --format json --output trivy-results.json ${IMAGE_NAME}
                                trivy image --severity HIGH,CRITICAL ${IMAGE_NAME}
                            """
                        }
                    }
                }
                
                stage('Docker Scout') {
                    steps {
                        script {
                            sh """
                                docker scout cves ${IMAGE_NAME}
                                docker scout cves --format sarif --output scout-results.sarif ${IMAGE_NAME}
                            """
                        }
                    }
                }
                
                stage('Dockerfile Lint') {
                    steps {
                        script {
                            sh """
                                docker run --rm -i hadolint/hadolint < Dockerfile
                            """
                        }
                    }
                }
            }
        }
        
        stage('Security Gate') {
            steps {
                script {
                    def criticalVulns = sh(
                        script: """
                            jq '.Results[]?.Vulnerabilities | select(. != null) | map(select(.Severity == "CRITICAL")) | length' trivy-results.json | jq -s 'add'
                        """,
                        returnStdout: true
                    ).trim()
                    
                    if (criticalVulns.toInteger() > 0) {
                        error("Critical vulnerabilities found: ${criticalVulns}")
                    }
                }
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                script {
                    docker.withRegistry("https://${REGISTRY}") {
                        docker.image("${IMAGE_NAME}").push()
                        docker.image("${IMAGE_NAME}").push("latest")
                    }
                }
            }
        }
    }
    
    post {
        always {
            publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: '.',
                reportFiles: 'trivy-results.json',
                reportName: 'Trivy Security Report'
            ])
            
            archiveArtifacts artifacts: '*.json,*.sarif', fingerprint: true
        }
        
        failure {
            emailext (
                subject: "Security Scan Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: "Security vulnerabilities detected in ${IMAGE_NAME}. Check the build logs for details.",
                to: "${env.CHANGE_AUTHOR_EMAIL}"
            )
        }
    }
}
```

## 4. 런타임 보안 강화 (10분)

### 보안 컨텍스트 설정

```yaml
# secure-deployment.yaml - Kubernetes 보안 설정
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: secure-app
  template:
    metadata:
      labels:
        app: secure-app
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
        seccompProfile:
          type: RuntimeDefault
      
      containers:
      - name: app
        image: myapp:latest
        
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
          capabilities:
            drop:
            - ALL
            add:
            - NET_BIND_SERVICE
        
        resources:
          limits:
            memory: "512Mi"
            cpu: "500m"
          requests:
            memory: "256Mi"
            cpu: "250m"
        
        volumeMounts:
        - name: tmp-volume
          mountPath: /tmp
        - name: cache-volume
          mountPath: /app/cache
      
      volumes:
      - name: tmp-volume
        emptyDir: {}
      - name: cache-volume
        emptyDir: {}
```

### Docker 런타임 보안 옵션

```bash
# 보안 강화된 컨테이너 실행
docker run -d \
  --name secure-app \
  --user 1000:1000 \
  --read-only \
  --tmpfs /tmp \
  --tmpfs /var/run \
  --no-new-privileges \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  --security-opt no-new-privileges:true \
  --security-opt seccomp=seccomp-profile.json \
  --memory 512m \
  --cpus 0.5 \
  --pids-limit 100 \
  myapp:latest

# AppArmor 프로필 적용 (Linux)
docker run -d \
  --security-opt apparmor:docker-default \
  myapp:latest

# SELinux 컨텍스트 설정 (RHEL/CentOS)
docker run -d \
  --security-opt label=type:container_runtime_t \
  myapp:latest
```

## 5. 실습: 종합 보안 스캐닝 시스템 (5분)

### 실습 프로젝트: 자동화된 보안 검사 시스템

```bash
# 프로젝트 디렉토리 생성
mkdir security-scanning-demo && cd security-scanning-demo

# 종합 보안 스캔 스크립트 작성
cat > comprehensive-security-scan.sh << 'EOF'
#!/bin/bash

set -e

IMAGE_NAME=${1:-myapp:latest}
REPORT_DIR="security-reports"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

echo "=== 종합 보안 스캔 시작 ==="
echo "이미지: $IMAGE_NAME"
echo "시간: $(date)"

# 보고서 디렉토리 생성
mkdir -p $REPORT_DIR

# 1. Trivy 스캔
echo "1. Trivy 취약점 스캔 실행 중..."
if command -v trivy &> /dev/null; then
    trivy image --format json --output $REPORT_DIR/trivy-$TIMESTAMP.json $IMAGE_NAME
    trivy image --format table $IMAGE_NAME > $REPORT_DIR/trivy-$TIMESTAMP.txt
    
    # 심각도별 통계
    CRITICAL=$(jq '.Results[]?.Vulnerabilities | select(. != null) | map(select(.Severity == "CRITICAL")) | length' $REPORT_DIR/trivy-$TIMESTAMP.json | jq -s 'add // 0')
    HIGH=$(jq '.Results[]?.Vulnerabilities | select(. != null) | map(select(.Severity == "HIGH")) | length' $REPORT_DIR/trivy-$TIMESTAMP.json | jq -s 'add // 0')
    MEDIUM=$(jq '.Results[]?.Vulnerabilities | select(. != null) | map(select(.Severity == "MEDIUM")) | length' $REPORT_DIR/trivy-$TIMESTAMP.json | jq -s 'add // 0')
    
    echo "   - Critical: $CRITICAL"
    echo "   - High: $HIGH" 
    echo "   - Medium: $MEDIUM"
else
    echo "   Trivy not installed, skipping..."
fi

# 2. Docker Scout 스캔
echo "2. Docker Scout 스캔 실행 중..."
if docker scout --help &> /dev/null; then
    docker scout cves $IMAGE_NAME > $REPORT_DIR/scout-$TIMESTAMP.txt 2>&1 || true
    echo "   Docker Scout 스캔 완료"
else
    echo "   Docker Scout not available, skipping..."
fi

# 3. Dockerfile 보안 검사
echo "3. Dockerfile 보안 검사 실행 중..."
if [ -f "Dockerfile" ]; then
    # Hadolint 검사
    if command -v hadolint &> /dev/null; then
        hadolint Dockerfile > $REPORT_DIR/hadolint-$TIMESTAMP.txt 2>&1 || true
        echo "   Hadolint 검사 완료"
    else
        echo "   Hadolint not installed, using Docker..."
        docker run --rm -i hadolint/hadolint < Dockerfile > $REPORT_DIR/hadolint-$TIMESTAMP.txt 2>&1 || true
    fi
else
    echo "   Dockerfile not found, skipping..."
fi

# 4. 시크릿 스캔
echo "4. 시크릿 스캔 실행 중..."
if command -v trivy &> /dev/null; then
    trivy fs --security-checks secret . > $REPORT_DIR/secrets-$TIMESTAMP.txt 2>&1 || true
    echo "   시크릿 스캔 완료"
fi

# 5. 이미지 구성 분석
echo "5. 이미지 구성 분석 실행 중..."
cat > $REPORT_DIR/image-analysis-$TIMESTAMP.txt << EOL
=== 이미지 구성 분석 ===
이미지: $IMAGE_NAME
분석 시간: $(date)

== 기본 정보 ==
$(docker image inspect $IMAGE_NAME | jq '.[0] | {
  Id: .Id,
  Created: .Created,
  Size: .Size,
  Architecture: .Architecture,
  Os: .Os
}')

== 레이어 정보 ==
$(docker history $IMAGE_NAME --format "table {{.CreatedBy}}\t{{.Size}}")

== 환경 변수 ==
$(docker image inspect $IMAGE_NAME | jq '.[0].Config.Env[]?')

== 노출 포트 ==
$(docker image inspect $IMAGE_NAME | jq '.[0].Config.ExposedPorts // {}')

== 실행 사용자 ==
$(docker image inspect $IMAGE_NAME | jq '.[0].Config.User // "root"')

== 작업 디렉토리 ==
$(docker image inspect $IMAGE_NAME | jq '.[0].Config.WorkingDir // "/"')
EOL

# 6. 보안 점수 계산
echo "6. 보안 점수 계산 중..."
SECURITY_SCORE=100

# Trivy 결과 기반 점수 차감
if [ -f "$REPORT_DIR/trivy-$TIMESTAMP.json" ]; then
    SECURITY_SCORE=$((SECURITY_SCORE - CRITICAL * 20))
    SECURITY_SCORE=$((SECURITY_SCORE - HIGH * 10))
    SECURITY_SCORE=$((SECURITY_SCORE - MEDIUM * 5))
fi

# 최소 점수 보장
if [ $SECURITY_SCORE -lt 0 ]; then
    SECURITY_SCORE=0
fi

# 7. 종합 보고서 생성
echo "7. 종합 보고서 생성 중..."
cat > $REPORT_DIR/security-summary-$TIMESTAMP.md << EOL
# 보안 스캔 종합 보고서

**이미지:** $IMAGE_NAME  
**스캔 시간:** $(date)  
**보안 점수:** $SECURITY_SCORE/100

## 취약점 요약
- Critical: $CRITICAL
- High: $HIGH
- Medium: $MEDIUM

## 보안 권장사항
$(if [ $CRITICAL -gt 0 ]; then echo "🔴 Critical 취약점이 발견되었습니다. 즉시 조치가 필요합니다."; fi)
$(if [ $HIGH -gt 0 ]; then echo "🟡 High 취약점이 발견되었습니다. 우선적으로 조치하세요."; fi)
$(if [ $SECURITY_SCORE -ge 80 ]; then echo "✅ 전반적으로 양호한 보안 상태입니다."; fi)

## 상세 보고서
- [Trivy 스캔 결과](trivy-$TIMESTAMP.txt)
- [Docker Scout 결과](scout-$TIMESTAMP.txt)
- [Dockerfile 검사](hadolint-$TIMESTAMP.txt)
- [시크릿 스캔](secrets-$TIMESTAMP.txt)
- [이미지 분석](image-analysis-$TIMESTAMP.txt)
EOL

echo "=== 보안 스캔 완료 ==="
echo "보안 점수: $SECURITY_SCORE/100"
echo "보고서 위치: $REPORT_DIR/"

# 8. 보안 게이트 체크
if [ $CRITICAL -gt 0 ]; then
    echo "❌ Critical 취약점 발견으로 인한 빌드 실패"
    exit 1
elif [ $SECURITY_SCORE -lt 70 ]; then
    echo "⚠️  보안 점수가 낮습니다 ($SECURITY_SCORE/100)"
    exit 1
else
    echo "✅ 보안 검사 통과"
fi
EOF

chmod +x comprehensive-security-scan.sh

# 테스트용 취약한 Dockerfile 생성
cat > Dockerfile.vulnerable << 'EOF'
FROM ubuntu:latest
RUN apt-get update && apt-get install -y curl
COPY . /app
USER root
EXPOSE 22 80 443
ENV SECRET_KEY=hardcoded-secret-123
CMD ["/bin/bash"]
EOF

# 보안 강화된 Dockerfile 생성
cat > Dockerfile.secure << 'EOF'
FROM ubuntu:20.04@sha256:8ae9bafbb64f63a50caab98fd3a5e37b3eb837a3e0780b78e5218e63193961f9

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -r appgroup && \
    useradd -r -g appgroup -s /bin/false appuser

COPY --chown=appuser:appgroup app.sh /app/
RUN chmod +x /app/app.sh

USER appuser
EXPOSE 8080
CMD ["/app/app.sh"]
EOF

# 샘플 애플리케이션 스크립트
cat > app.sh << 'EOF'
#!/bin/bash
echo "Secure application starting..."
while true; do
    echo "Application running at $(date)"
    sleep 60
done
EOF

# 실행 예제
echo "=== 취약한 이미지 빌드 및 스캔 ==="
docker build -f Dockerfile.vulnerable -t vulnerable-app:latest .
./comprehensive-security-scan.sh vulnerable-app:latest

echo -e "\n=== 보안 강화된 이미지 빌드 및 스캔 ==="
docker build -f Dockerfile.secure -t secure-app:latest .
./comprehensive-security-scan.sh secure-app:latest

echo -e "\n=== 스캔 결과 비교 ==="
ls -la security-reports/
```

## 핵심 키워드 정리
- **취약점 스캐닝**: Trivy, Docker Scout, Clair 등을 활용한 자동화된 보안 검사
- **보안 게이트**: CI/CD 파이프라인에서 보안 기준 미달 시 배포 차단
- **최소 권한 원칙**: 비특권 사용자 실행과 불필요한 권한 제거
- **다층 방어**: 이미지, 런타임, 네트워크 등 각 계층별 보안 강화
- **보안 모니터링**: 지속적인 취약점 추적과 보안 상태 관리

## 참고 자료
- [Docker 보안 모범 사례](https://docs.docker.com/engine/security/)
- [Trivy 공식 문서](https://trivy.dev/)
- [NIST 컨테이너 보안 가이드](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-190.pdf)
- [CIS Docker 벤치마크](https://www.cisecurity.org/benchmark/docker)

---
*다음 세션에서는 종합 실습을 통해 프로덕션 환경에 적합한 완전한 이미지를 구축합니다.*