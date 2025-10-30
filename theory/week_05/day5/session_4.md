# Week 5 Day 5 Session 4: DevSecOps & 백업 전략 (12:00-12:50)

<div align="center">

**🔐 SAST/DAST** • **🛡️ 이미지 보안** • **🔒 IAM 정책** • **💾 백업 & 복구**

*프로덕션 환경의 자동화된 보안 파이프라인과 비즈니스 연속성*

</div>

---

## 🕘 세션 정보
**시간**: 12:00-12:50 (50분)
**목표**: CloudMart의 DevSecOps 파이프라인 구축 및 재해 복구 계획 수립
**방식**: 이론 설명 + 자동화 전략

## 🎯 세션 목표

### 📚 학습 목표
- **이해 목표**: SAST/DAST 보안 파이프라인과 IAM 정책의 역할 이해
- **적용 목표**: 자동화된 보안 스캔 및 최소 권한 원칙 적용 방법 습득
- **협업 목표**: 팀과 함께 DevSecOps 문화 및 재해 복구 시나리오 수립

### 🤔 왜 필요한가? (5분)

**현실 문제 상황**:
- 💼 **실무 시나리오**: "배포 후 CRITICAL 취약점이 발견되어 긴급 롤백했어요. 어떻게 사전에 막을 수 있나요?"
- 🏠 **일상 비유**: 집 짓기 전 설계 검토 + 시공 중 품질 검사 + 입주 후 보안 점검 → 다층 보안
- ☁️ **AWS 아키텍처**: SAST (코드 분석) + 이미지 스캔 (컨테이너) + DAST (실행 환경) + IAM (접근 제어)
- 📊 **시장 동향**: 2024년 데이터 유출 평균 피해액 $4.45M, 평균 탐지 시간 277일 (IBM 보고서)

**보안 없음 vs DevSecOps 비교**:
```mermaid
graph TB
    subgraph "보안 없음 (위험)"
        A1[코드 작성] --> B1[즉시 배포]
        B1 --> C1[취약점 발견<br/>배포 후]
        C1 --> D1[긴급 롤백<br/>서비스 중단]
        D1 --> E1[고객 이탈<br/>평판 손상]
    end
    
    subgraph "DevSecOps (안전)"
        A2[코드 작성] --> B2[SAST 스캔<br/>자동 검증]
        B2 --> C2[이미지 스캔<br/>취약점 차단]
        C2 --> D2[DAST 스캔<br/>실행 환경 검증]
        D2 --> E2[안전한 배포<br/>지속적 모니터링]
    end
    
    style A1 fill:#fff3e0
    style C1 fill:#ffebee
    style E1 fill:#ffebee
    style B2 fill:#e8f5e8
    style C2 fill:#e8f5e8
    style D2 fill:#e8f5e8
    style E2 fill:#e8f5e8
```

## 📖 핵심 개념 (35분)

### 🔄 Docker Compose vs AWS 보안 비교 (DevSecOps)

**Docker Compose + SAST/DAST 파이프라인 🔐**:
```mermaid
graph TB
    subgraph "개발 단계 (로컬)"
        DEV[개발자<br/>코드 작성]
        GIT[Git Push]
    end
    
    subgraph "CI/CD 파이프라인 (GitHub Actions)"
        SAST1[SonarQube<br/>정적 분석]
        SAST2[Trivy<br/>컨테이너 스캔]
        SAST3[Snyk<br/>의존성 스캔]
        BUILD[Docker Build]
        PUSH[ECR Push]
    end
    
    subgraph "배포 단계"
        DEPLOY[서버 배포]
        DAST1[OWASP ZAP<br/>동적 분석]
        DAST2[Nikto<br/>웹 취약점 스캔]
    end
    
    subgraph "운영 단계"
        RUNTIME[Falco<br/>런타임 보안]
        MONITOR[보안 모니터링]
    end
    
    subgraph "보안 리포트"
        S3[S3 Bucket<br/>스캔 결과 저장]
        SLACK[Slack 알림<br/>취약점 발견 시]
    end
    
    DEV --> GIT
    GIT --> SAST1
    GIT --> SAST2
    GIT --> SAST3
    
    SAST1 --> BUILD
    SAST2 --> BUILD
    SAST3 --> BUILD
    
    BUILD --> PUSH
    PUSH --> DEPLOY
    
    DEPLOY --> DAST1
    DEPLOY --> DAST2
    
    DAST1 --> RUNTIME
    DAST2 --> RUNTIME
    RUNTIME --> MONITOR
    
    SAST1 -.결과.-> S3
    SAST2 -.결과.-> S3
    SAST3 -.결과.-> S3
    DAST1 -.결과.-> S3
    DAST2 -.결과.-> S3
    
    S3 -.알림.-> SLACK
    
    style SAST1 fill:#e8f5e8
    style SAST2 fill:#e8f5e8
    style SAST3 fill:#e8f5e8
    style DAST1 fill:#fff3e0
    style DAST2 fill:#fff3e0
    style RUNTIME fill:#ffebee
    style S3 fill:#e3f2fd
```

**SAST (Static Application Security Testing) - 정적 분석**:
```yaml
# .github/workflows/security-scan.yml
name: Security Scan

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  sast:
    runs-on: ubuntu-latest
    steps:
      # 1. SonarQube - 코드 품질 및 보안 취약점
      - name: SonarQube Scan
        uses: sonarsource/sonarqube-scan-action@master
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
      
      # 2. Trivy - 컨테이너 이미지 취약점 (상세 스캔)
      - name: Build Docker Image
        run: docker build -t cloudmart-backend:${{ github.sha }} .
      
      - name: Trivy Image Scan (Full Report)
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'cloudmart-backend:${{ github.sha }}'
          format: 'json'
          output: 'trivy-results.json'
          severity: 'UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL'
          vuln-type: 'os,library'
          scanners: 'vuln,secret,config'
      
      - name: Trivy Critical/High Only
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'cloudmart-backend:${{ github.sha }}'
          format: 'table'
          severity: 'CRITICAL,HIGH'
          exit-code: '1'  # CRITICAL/HIGH 발견 시 빌드 실패
      
      # 3. Trivy - Dockerfile 보안 검사
      - name: Trivy Dockerfile Scan
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'config'
          scan-ref: './Dockerfile'
          format: 'sarif'
          output: 'trivy-dockerfile.sarif'
      
      # 4. Trivy - 파일시스템 스캔 (시크릿 탐지)
      - name: Trivy Filesystem Scan
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          scanners: 'secret'
          format: 'json'
          output: 'trivy-secrets.json'
      
      # 5. Snyk - 의존성 취약점
      - name: Snyk Security Scan
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high
      
      # 6. 결과를 S3에 업로드
      - name: Upload Scan Results to S3
        run: |
          TIMESTAMP=$(date +%Y%m%d_%H%M%S)
          aws s3 cp trivy-results.json s3://cloudmart-security/sast/trivy/${TIMESTAMP}/
          aws s3 cp trivy-dockerfile.sarif s3://cloudmart-security/sast/dockerfile/${TIMESTAMP}/
          aws s3 cp trivy-secrets.json s3://cloudmart-security/sast/secrets/${TIMESTAMP}/
          aws s3 cp snyk-results.json s3://cloudmart-security/sast/snyk/${TIMESTAMP}/
      
      # 7. Trivy 결과 분석 및 리포트 생성
      - name: Generate Security Report
        run: |
          python3 scripts/analyze-trivy-results.py \
            --input trivy-results.json \
            --output security-report.html
          aws s3 cp security-report.html s3://cloudmart-security/reports/${TIMESTAMP}/
      
      # 8. 취약점 발견 시 Slack 알림
      - name: Slack Notification
        if: failure()
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: |
            🚨 보안 취약점 발견!
            - Repository: ${{ github.repository }}
            - Branch: ${{ github.ref }}
            - Commit: ${{ github.sha }}
            - 상세 리포트: s3://cloudmart-security/reports/${TIMESTAMP}/security-report.html
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

**Trivy 스캔 결과 예시**:
```json
{
  "Results": [
    {
      "Target": "cloudmart-backend:latest (alpine 3.18.4)",
      "Vulnerabilities": [
        {
          "VulnerabilityID": "CVE-2023-12345",
          "PkgName": "openssl",
          "InstalledVersion": "3.0.10-r0",
          "FixedVersion": "3.0.12-r0",
          "Severity": "CRITICAL",
          "Title": "OpenSSL Remote Code Execution",
          "Description": "A critical vulnerability in OpenSSL...",
          "References": [
            "https://nvd.nist.gov/vuln/detail/CVE-2023-12345"
          ]
        },
        {
          "VulnerabilityID": "CVE-2023-67890",
          "PkgName": "curl",
          "InstalledVersion": "8.1.2-r0",
          "FixedVersion": "8.4.0-r0",
          "Severity": "HIGH",
          "Title": "curl Buffer Overflow"
        }
      ]
    },
    {
      "Target": "Node.js Dependencies",
      "Vulnerabilities": [
        {
          "VulnerabilityID": "CVE-2023-11111",
          "PkgName": "express",
          "InstalledVersion": "4.17.1",
          "FixedVersion": "4.18.2",
          "Severity": "MEDIUM",
          "Title": "Express.js Path Traversal"
        }
      ]
    }
  ],
  "Secrets": [
    {
      "Target": "Dockerfile",
      "Secrets": [
        {
          "RuleID": "aws-access-key-id",
          "Category": "AWS",
          "Severity": "CRITICAL",
          "Title": "AWS Access Key",
          "Match": "AKIAIOSFODNN7EXAMPLE"
        }
      ]
    }
  ]
}
```

**Trivy 스캔 유형별 상세**:

**1. 이미지 취약점 스캔**:
```bash
# OS 패키지 취약점
trivy image --vuln-type os cloudmart-backend:latest

# 애플리케이션 라이브러리 취약점
trivy image --vuln-type library cloudmart-backend:latest

# 전체 스캔 (OS + Library)
trivy image cloudmart-backend:latest
```

**2. Dockerfile 보안 검사**:
```bash
# Dockerfile 베스트 프랙티스 검사
trivy config Dockerfile

# 검출 항목:
# - USER root 사용 (보안 위험)
# - COPY --chown 미사용
# - 불필요한 패키지 설치
# - 최신 베이스 이미지 미사용
```

**3. 시크릿 탐지**:
```bash
# 코드 내 하드코딩된 시크릿 탐지
trivy fs --scanners secret .

# 검출 항목:
# - AWS Access Key
# - API Keys
# - Private Keys
# - Passwords
# - JWT Tokens
```

**4. 설정 파일 검사**:
```bash
# Kubernetes YAML 보안 검사
trivy config k8s/

# Docker Compose 보안 검사
trivy config docker-compose.yml
```

---

**AWS ECR Image Scanning (자동화)**:

**ECR 스캔 활성화**:
```bash
# 1. ECR 리포지토리 생성 시 스캔 활성화
aws ecr create-repository \
  --repository-name cloudmart-backend \
  --image-scanning-configuration scanOnPush=true \
  --encryption-configuration encryptionType=KMS

# 2. 기존 리포지토리에 스캔 활성화
aws ecr put-image-scanning-configuration \
  --repository-name cloudmart-backend \
  --image-scanning-configuration scanOnPush=true

# 3. Enhanced Scanning (Inspector 통합) 활성화
aws ecr put-registry-scanning-configuration \
  --scan-type ENHANCED \
  --rules '[
    {
      "scanFrequency": "CONTINUOUS_SCAN",
      "repositoryFilters": [
        {"filter": "cloudmart-*", "filterType": "WILDCARD"}
      ]
    }
  ]'
```

**ECR 스캔 결과 조회**:
```bash
# 이미지 스캔 결과 조회
aws ecr describe-image-scan-findings \
  --repository-name cloudmart-backend \
  --image-id imageTag=latest

# 결과 예시:
{
  "imageScanFindings": {
    "findings": [
      {
        "name": "CVE-2023-12345",
        "severity": "CRITICAL",
        "uri": "https://nvd.nist.gov/vuln/detail/CVE-2023-12345",
        "attributes": [
          {
            "key": "package_name",
            "value": "openssl"
          },
          {
            "key": "package_version",
            "value": "3.0.10"
          }
        ]
      }
    ],
    "findingSeverityCounts": {
      "CRITICAL": 2,
      "HIGH": 5,
      "MEDIUM": 12,
      "LOW": 8
    }
  }
}
```

**ECR 스캔 자동 알림 (EventBridge + SNS)**:
```yaml
# CloudFormation 템플릿
Resources:
  # ECR 스캔 완료 이벤트 규칙
  ECRScanEventRule:
    Type: AWS::Events::Rule
    Properties:
      EventPattern:
        source:
          - aws.ecr
        detail-type:
          - ECR Image Scan
        detail:
          scan-status:
            - COMPLETE
          finding-severity-counts:
            CRITICAL:
              - { "numeric": [ ">", 0 ] }
      Targets:
        - Arn: !Ref SecurityAlertTopic
          Id: ECRScanAlert

  # SNS 토픽 (Slack 알림)
  SecurityAlertTopic:
    Type: AWS::SNS::Topic
    Properties:
      Subscription:
        - Endpoint: !Ref SlackWebhookURL
          Protocol: https

  # Lambda 함수 (상세 알림 생성)
  ECRScanAlertFunction:
    Type: AWS::Lambda::Function
    Properties:
      Runtime: python3.11
      Handler: index.handler
      Code:
        ZipFile: |
          import json
          import boto3
          
          def handler(event, context):
              detail = event['detail']
              repo = detail['repository-name']
              tag = detail['image-tags'][0]
              findings = detail['finding-severity-counts']
              
              message = f"""
              🚨 ECR 이미지 스캔 완료
              
              Repository: {repo}
              Tag: {tag}
              
              취약점 발견:
              - CRITICAL: {findings.get('CRITICAL', 0)}
              - HIGH: {findings.get('HIGH', 0)}
              - MEDIUM: {findings.get('MEDIUM', 0)}
              
              상세 확인: https://console.aws.amazon.com/ecr/repositories/{repo}
              """
              
              # Slack 알림 전송
              # ... (생략)
```

**💡 Trivy vs ECR Scan 상세 비교**:

| 기능 | Trivy (Docker Compose) | ECR Image Scanning |
|------|------------------------|-------------------|
| **스캔 시점** | CI/CD 파이프라인 (수동 트리거) | 이미지 푸시 시 자동 |
| **스캔 범위** | OS + Library + Secret + Config | OS + Library (Basic)<br/>OS + Library + Language (Enhanced) |
| **취약점 DB** | Trivy DB (매일 업데이트) | AWS CVE Database |
| **Dockerfile 검사** | ✅ 지원 | ❌ 미지원 |
| **시크릿 탐지** | ✅ 지원 (AWS Key, API Key 등) | ❌ 미지원 |
| **설정 파일 검사** | ✅ 지원 (K8s, Docker Compose) | ❌ 미지원 |
| **지속적 스캔** | ❌ 수동 재실행 필요 | ✅ Enhanced Scanning (자동) |
| **통합 대시보드** | 직접 구축 (S3 + Grafana) | Security Hub 자동 통합 |
| **알림** | GitHub Actions + Slack (수동) | EventBridge + SNS (자동) |
| **비용** | 무료 (오픈소스) | Basic: 무료<br/>Enhanced: $0.09/이미지/월 |
| **설정 복잡도** | 중간 (GitHub Actions 설정) | 낮음 (클릭 한 번) |
| **커스터마이징** | 매우 높음 (모든 옵션 제어) | 제한적 |
| **오프라인 사용** | ✅ 가능 | ❌ 불가능 (AWS 전용) |

**Trivy의 장점**:
- ✅ **포괄적 스캔**: OS, Library, Secret, Config 모두 검사
- ✅ **Dockerfile 검사**: 보안 베스트 프랙티스 검증
- ✅ **시크릿 탐지**: 하드코딩된 API Key, Password 발견
- ✅ **무료**: 오픈소스, 무제한 사용
- ✅ **유연성**: CI/CD 어디서든 사용 가능

**ECR Scan의 장점**:
- ✅ **자동화**: 이미지 푸시 시 자동 스캔
- ✅ **지속적 스캔**: Enhanced Scanning으로 새 취약점 자동 탐지
- ✅ **통합**: Security Hub, Inspector와 자동 통합
- ✅ **관리 불필요**: AWS가 DB 업데이트 및 스캔 관리
- ✅ **규정 준수**: AWS 규정 준수 프레임워크 통합

**🎯 Best Practice: 두 가지 모두 사용!**

```yaml
# .github/workflows/image-security.yml
name: Image Security Scan

on:
  push:
    branches: [main]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      # 1. 빌드 전 Dockerfile 검사 (Trivy)
      - name: Scan Dockerfile
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'config'
          scan-ref: './Dockerfile'
      
      # 2. 이미지 빌드
      - name: Build Image
        run: docker build -t cloudmart-backend:${{ github.sha }} .
      
      # 3. 빌드 후 이미지 스캔 (Trivy - 상세)
      - name: Trivy Full Scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'cloudmart-backend:${{ github.sha }}'
          format: 'json'
          scanners: 'vuln,secret,config'
          exit-code: '1'  # CRITICAL 발견 시 중단
      
      # 4. ECR 푸시 (자동 스캔 트리거)
      - name: Push to ECR
        run: |
          aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_REGISTRY
          docker tag cloudmart-backend:${{ github.sha }} $ECR_REGISTRY/cloudmart-backend:${{ github.sha }}
          docker push $ECR_REGISTRY/cloudmart-backend:${{ github.sha }}
      
      # 5. ECR 스캔 결과 대기 및 확인
      - name: Wait for ECR Scan
        run: |
          sleep 60  # ECR 스캔 완료 대기
          aws ecr describe-image-scan-findings \
            --repository-name cloudmart-backend \
            --image-id imageTag=${{ github.sha }}
```

**결론**:
- **개발 단계**: Trivy로 빠른 피드백 (Dockerfile, Secret, Config)
- **배포 단계**: ECR Scan으로 자동 검증 및 지속적 모니터링
- **운영 단계**: Security Hub로 통합 관리

---

**DAST (Dynamic Application Security Testing) - 동적 분석**:
```yaml
# .github/workflows/dast-scan.yml
name: DAST Scan

on:
  deployment_status:

jobs:
  dast:
    runs-on: ubuntu-latest
    if: github.event.deployment_status.state == 'success'
    
    steps:
      # 1. OWASP ZAP - 웹 애플리케이션 취약점 스캔
      - name: OWASP ZAP Scan
        uses: zaproxy/action-baseline@v0.7.0
        with:
          target: 'https://cloudmart.example.com'
          rules_file_name: '.zap/rules.tsv'
          cmd_options: '-a'
      
      # 2. Nikto - 웹 서버 취약점 스캔
      - name: Nikto Scan
        run: |
          docker run --rm \
            -v $(pwd):/tmp \
            sullo/nikto \
            -h https://cloudmart.example.com \
            -o /tmp/nikto-results.json \
            -Format json
      
      # 3. 결과를 S3에 업로드
      - name: Upload to S3
        run: |
          aws s3 cp zap-results.json s3://cloudmart-security/dast/$(date +%Y%m%d)/
          aws s3 cp nikto-results.json s3://cloudmart-security/dast/$(date +%Y%m%d)/
      
      # 4. 취약점 발견 시 Slack 알림
      - name: Slack Notification
        if: failure()
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: '🚨 운영 환경에서 보안 취약점 발견! DAST 스캔 결과를 확인하세요.'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

**런타임 보안 (Falco)**:
```yaml
# docker-compose.yml (각 서버)
version: '3.8'
services:
  # 기존 애플리케이션 서비스들...
  
  # Falco - 런타임 보안 모니터링
  falco:
    image: falcosecurity/falco:latest
    privileged: true
    volumes:
      - /var/run/docker.sock:/host/var/run/docker.sock
      - /dev:/host/dev
      - /proc:/host/proc:ro
      - /boot:/host/boot:ro
      - /lib/modules:/host/lib/modules:ro
      - /usr:/host/usr:ro
      - ./falco/falco.yaml:/etc/falco/falco.yaml
      - ./falco/rules:/etc/falco/rules.d
    environment:
      - FALCO_GRPC_ENABLED=true
      - FALCO_GRPC_BIND_ADDRESS=0.0.0.0:5060
    ports:
      - "5060:5060"
```

**Falco 보안 규칙 예시**:
```yaml
# falco/rules/custom-rules.yaml
- rule: Unauthorized Process in Container
  desc: Detect unauthorized process execution
  condition: >
    spawned_process and
    container and
    not proc.name in (node, npm, sh, bash)
  output: >
    Unauthorized process started in container
    (user=%user.name command=%proc.cmdline container=%container.name)
  priority: WARNING

- rule: Write to Sensitive Directory
  desc: Detect writes to sensitive directories
  condition: >
    open_write and
    container and
    fd.name startswith /etc
  output: >
    Write to sensitive directory
    (user=%user.name file=%fd.name container=%container.name)
  priority: ERROR

- rule: Outbound Connection to Suspicious IP
  desc: Detect connections to known malicious IPs
  condition: >
    outbound and
    fd.sip in (suspicious_ips)
  output: >
    Suspicious outbound connection
    (user=%user.name ip=%fd.sip container=%container.name)
  priority: CRITICAL
```

**💡 Docker vs AWS 보안 비교**:
| 항목 | Docker + SAST/DAST | AWS 보안 서비스 |
|------|-------------------|-----------------|
| **SAST (정적 분석)** | SonarQube, Trivy, Snyk (수동 설정) | CodeGuru, Inspector (자동) |
| **DAST (동적 분석)** | OWASP ZAP, Nikto (수동 설정) | Inspector, Penetration Testing |
| **컨테이너 스캔** | Trivy, Clair (수동) | ECR Image Scanning (자동) |
| **의존성 스캔** | Snyk, Dependabot (수동) | Inspector (자동) |
| **런타임 보안** | Falco (수동 설정) | GuardDuty (자동) |
| **네트워크 보안** | iptables, 방화벽 (수동) | Security Groups, NACL (관리형) |
| **시크릿 관리** | Vault, 환경변수 (수동) | Secrets Manager (관리형) |
| **규정 준수** | 수동 감사 | Config, Security Hub (자동) |
| **위협 탐지** | 수동 로그 분석 | GuardDuty, Macie (자동) |
| **설정 복잡도** | 매우 높음 | 낮음 (자동) |
| **비용** | 도구 라이선스 + 인력 | 서비스 사용량당 |

**AWS 보안 서비스 상세**:

**1. AWS CodeGuru (SAST)**:
```yaml
# buildspec.yml
version: 0.2
phases:
  pre_build:
    commands:
      # CodeGuru Reviewer 자동 실행
      - echo "CodeGuru Reviewer analyzing code..."
  build:
    commands:
      - docker build -t cloudmart-backend .
  post_build:
    commands:
      # CodeGuru Security 스캔
      - aws codeguru-security create-scan --scan-name cloudmart-scan
```

**2. Amazon Inspector (컨테이너 + 인프라 스캔)**:
```bash
# ECR 이미지 자동 스캔 (푸시 시 자동 실행)
aws ecr put-image-scanning-configuration \
  --repository-name cloudmart-backend \
  --image-scanning-configuration scanOnPush=true

# EC2 인스턴스 자동 스캔
aws inspector2 enable \
  --resource-types EC2 ECR
```

**3. AWS GuardDuty (런타임 위협 탐지)**:
```bash
# GuardDuty 활성화 (자동 위협 탐지)
aws guardduty create-detector --enable

# 의심스러운 활동 자동 탐지:
# - 비정상적인 API 호출
# - 알려진 악성 IP 통신
# - 크립토마이닝 활동
# - 권한 상승 시도
```

**4. AWS Security Hub (통합 보안 대시보드)**:
```bash
# Security Hub 활성화
aws securityhub enable-security-hub

# 자동으로 통합되는 서비스:
# - GuardDuty (위협 탐지)
# - Inspector (취약점 스캔)
# - Macie (데이터 보안)
# - IAM Access Analyzer (권한 분석)
# - Config (규정 준수)
```

**보안 파이프라인 비교**:

**Docker Compose 방식**:
```
개발 → Git Push → GitHub Actions
  ↓
SAST (SonarQube, Trivy, Snyk) - 수동 설정
  ↓
Docker Build → ECR Push
  ↓
서버 배포
  ↓
DAST (OWASP ZAP, Nikto) - 수동 실행
  ↓
Falco 런타임 모니터링 - 수동 설정
  ↓
S3 결과 저장 + Slack 알림 - 수동 설정
```

**AWS 방식**:
```
개발 → Git Push → CodePipeline
  ↓
CodeGuru (SAST) - 자동 실행
  ↓
Docker Build → ECR Push
  ↓
Inspector (이미지 스캔) - 자동 실행
  ↓
ECS/EC2 배포
  ↓
Inspector (인프라 스캔) - 자동 실행
  ↓
GuardDuty (런타임 위협 탐지) - 자동 실행
  ↓
Security Hub (통합 대시보드) - 자동 통합
  ↓
EventBridge → SNS/Lambda - 자동 알림
```

**🎯 핵심 인사이트**:
> "Docker Compose + GitHub Actions로 SAST/DAST 파이프라인을 구축할 수 있지만, 각 도구를 개별적으로 설정하고 통합해야 하는 복잡도가 매우 높습니다. AWS는 CodeGuru, Inspector, GuardDuty, Security Hub를 통해 **자동화된 DevSecOps 파이프라인**을 제공하며, 모든 보안 이벤트가 하나의 대시보드에 통합됩니다. **보안은 자동화되어야 효과적입니다!**"

---

**💡 셀프 호스팅 관점: Docker Compose의 가치**

**언제 Docker Compose 보안 스택이 적합한가?**

**1. 비용 민감형 스타트업**:
```
AWS 보안 서비스 비용 (월간):
- CodeGuru: $0.75/100 lines (코드 리뷰)
- Inspector: $0.09/이미지/월 (Enhanced)
- GuardDuty: $4.60/GB (VPC Flow Logs)
- Security Hub: $0.0010/check
---
예상 월 비용: $200-500

Docker Compose 셀프 호스팅:
- 서버 비용: $50-100/월 (모니터링 서버)
- 도구 비용: $0 (모두 오픈소스)
- 관리 인력: 개발자 겸임
---
예상 월 비용: $50-100 (60-80% 절감)
```

**2. 데이터 주권 및 규정 준수**:
```yaml
# 민감한 데이터를 외부로 보내지 않음
보안 스캔 결과:
  - 모든 데이터가 자체 서버에 저장
  - 외부 클라우드로 전송 없음
  - GDPR, HIPAA 등 규정 준수 용이

코드 분석:
  - 소스 코드가 외부로 나가지 않음
  - 지적 재산권 보호
  - 내부 보안 정책 완전 제어
```

**3. 완전한 커스터마이징**:
```yaml
# 자체 보안 정책 적용
Trivy 커스텀 정책:
  - 회사 내부 보안 기준 적용
  - 특정 CVE 무시 (False Positive)
  - 자체 취약점 DB 추가

Falco 커스텀 규칙:
  - 회사 특화 런타임 정책
  - 내부 프로세스 화이트리스트
  - 맞춤형 알림 규칙
```

**4. 멀티 클라우드 전략**:
```yaml
# 클라우드 벤더 종속 회피
동일한 보안 파이프라인:
  - AWS, Azure, GCP 모두 동일
  - 온프레미스 환경도 동일
  - 하이브리드 클라우드 지원

이식성:
  - Docker Compose 파일만 있으면 어디서든 실행
  - 클라우드 마이그레이션 용이
  - 벤더 락인 없음
```

**5. 학습 및 실험 환경**:
```yaml
# 보안 도구 학습
로컬 환경:
  - 비용 걱정 없이 실험
  - 다양한 도구 테스트
  - 보안 전문가 양성

교육 목적:
  - 보안 파이프라인 구축 경험
  - DevSecOps 문화 이해
  - 실무 역량 강화
```

**셀프 호스팅 성공 사례**:

**사례 1: 핀테크 스타트업 (직원 20명)**
```yaml
상황:
  - 금융 데이터 외부 전송 불가
  - AWS 보안 서비스 비용 부담 ($500/월)
  - 자체 보안 정책 필요

해결:
  - Docker Compose 보안 스택 구축
  - SonarQube + Trivy + Falco
  - 자체 서버 운영 ($80/월)

결과:
  - 비용 84% 절감
  - 데이터 주권 확보
  - 맞춤형 보안 정책 적용
```

**사례 2: 오픈소스 프로젝트**
```yaml
상황:
  - 공개 프로젝트 (GitHub)
  - AWS 비용 지불 불가
  - 커뮤니티 기여자 다수

해결:
  - GitHub Actions + Trivy
  - 무료 SonarCloud
  - 자체 호스팅 Falco

결과:
  - 완전 무료 보안 파이프라인
  - 커뮤니티 신뢰도 향상
  - 보안 취약점 사전 차단
```

**사례 3: 글로벌 SaaS 기업 (멀티 클라우드)**
```yaml
상황:
  - AWS, Azure, GCP 모두 사용
  - 통일된 보안 정책 필요
  - 클라우드별 도구 관리 복잡

해결:
  - Docker Compose 통합 보안 스택
  - 모든 클라우드에 동일 배포
  - 중앙 집중식 Security Hub

결과:
  - 일관된 보안 정책
  - 관리 복잡도 감소
  - 벤더 독립성 확보
```

**💡 Docker Compose vs AWS: 선택 기준**

| 기준 | Docker Compose 선택 | AWS 선택 |
|------|-------------------|----------|
| **예산** | 월 $100 미만 | 월 $500+ 가능 |
| **팀 규모** | 개발자 5-20명 | 개발자 50명+ |
| **데이터 민감도** | 매우 높음 (금융, 의료) | 일반적 |
| **커스터마이징** | 높은 수준 필요 | 기본 설정으로 충분 |
| **클라우드 전략** | 멀티/하이브리드 | AWS 중심 |
| **보안 전문성** | 팀 내 보유 | 외부 의존 가능 |
| **규정 준수** | 자체 감사 필요 | AWS 인증 활용 |
| **운영 부담** | 감수 가능 | 최소화 필요 |

**🎯 Best Practice: 하이브리드 접근**

```yaml
# 단계별 전환 전략
Phase 1 (스타트업 초기):
  - Docker Compose 셀프 호스팅
  - 비용 최소화
  - 보안 파이프라인 구축 경험

Phase 2 (성장기):
  - 핵심 보안: Docker Compose 유지
  - 편의 기능: AWS 서비스 도입
  - 하이브리드 운영

Phase 3 (성숙기):
  - 비용 대비 효율 분석
  - 선택적 AWS 전환
  - 또는 셀프 호스팅 고도화

결론:
  - 정답은 없음, 상황에 따라 선택
  - 셀프 호스팅도 충분히 프로덕션급
  - 중요한 것은 "보안 자동화"
```

**💪 셀프 호스팅 성공을 위한 조건**:
1. ✅ **자동화**: 수동 작업 최소화 (GitHub Actions)
2. ✅ **모니터링**: 보안 이벤트 실시간 추적
3. ✅ **백업**: 스캔 결과 및 설정 백업 (S3)
4. ✅ **문서화**: 팀원 온보딩 및 유지보수
5. ✅ **지속적 개선**: 도구 업데이트 및 정책 개선

**🎯 최종 인사이트**:
> "AWS 관리형 서비스는 편리하지만, Docker Compose 셀프 호스팅도 **비용 효율성, 데이터 주권, 완전한 제어**라는 명확한 가치를 제공합니다. 중요한 것은 **자동화된 보안 파이프라인**을 구축하는 것이며, 이는 두 방식 모두 달성 가능합니다. 팀의 상황과 우선순위에 따라 현명하게 선택하세요!"

---

### 🔍 개념 1: IAM 정책 & 역할 설계 (12분)

> **정의**: AWS 리소스에 대한 접근 권한을 세밀하게 제어하는 서비스

**IAM 구성 요소**:
```mermaid
graph TB
    subgraph "IAM 계층 구조"
        A[AWS Account<br/>Root User]
        A --> B1[IAM User<br/>개발자 개인]
        A --> B2[IAM Group<br/>개발팀]
        A --> B3[IAM Role<br/>EC2, Lambda]
        
        B2 --> C1[Policy<br/>권한 정의]
        B3 --> C2[Policy<br/>권한 정의]
        
        C1 --> D1[Allow/Deny<br/>특정 작업]
        C2 --> D2[Allow/Deny<br/>특정 작업]
    end
    
    style A fill:#ffebee
    style B1 fill:#fff3e0
    style B2 fill:#e8f5e8
    style B3 fill:#e8f5e8
```

**CloudMart IAM 설계**:
```yaml
# 1. EC2 Instance Role (Backend 서버용)
Role Name: CloudMart-Backend-Role
Policies:
  - RDS 접근 (읽기/쓰기)
  - ElastiCache 접근
  - S3 읽기 (설정 파일)
  - CloudWatch Logs 쓰기
  - Secrets Manager 읽기 (DB 비밀번호)

Policy Example:
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "rds:DescribeDBInstances",
        "rds:Connect"
      ],
      "Resource": "arn:aws:rds:ap-northeast-2:*:db:cloudmart-db"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticache:DescribeCacheClusters"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::cloudmart-config/*"
    }
  ]
}

# 2. Developer Group (개발자용)
Group Name: CloudMart-Developers
Policies:
  - EC2 읽기 전용
  - RDS 읽기 전용
  - CloudWatch 읽기
  - S3 읽기/쓰기 (특정 버킷만)

# 3. Admin Group (관리자용)
Group Name: CloudMart-Admins
Policies:
  - 모든 리소스 관리 권한
  - 단, IAM 정책 변경은 제한
```

**최소 권한 원칙 (Least Privilege)**:
```yaml
# ❌ 나쁜 예: 너무 많은 권한
{
  "Effect": "Allow",
  "Action": "*",
  "Resource": "*"
}

# ✅ 좋은 예: 필요한 권한만
{
  "Effect": "Allow",
  "Action": [
    "rds:DescribeDBInstances",
    "rds:Connect"
  ],
  "Resource": "arn:aws:rds:ap-northeast-2:123456789012:db:cloudmart-db",
  "Condition": {
    "IpAddress": {
      "aws:SourceIp": "10.0.0.0/16"
    }
  }
}
```

### 🔍 개념 2: 보안 그룹 최적화 (12분)

> **정의**: EC2 인스턴스 수준의 가상 방화벽으로 인바운드/아웃바운드 트래픽 제어

**CloudMart 보안 그룹 설계**:
```yaml
# 1. ALB Security Group
Name: CloudMart-ALB-SG
Inbound Rules:
  - Type: HTTP (80)
    Source: 0.0.0.0/0 (전 세계)
  - Type: HTTPS (443)
    Source: 0.0.0.0/0 (전 세계)
Outbound Rules:
  - Type: All Traffic
    Destination: CloudMart-Backend-SG

# 2. Backend Security Group
Name: CloudMart-Backend-SG
Inbound Rules:
  - Type: HTTP (8080)
    Source: CloudMart-ALB-SG (ALB만 접근)
  - Type: SSH (22)
    Source: Bastion-SG (Bastion만 접근)
Outbound Rules:
  - Type: PostgreSQL (5432)
    Destination: CloudMart-RDS-SG
  - Type: Redis (6379)
    Destination: CloudMart-Redis-SG
  - Type: HTTPS (443)
    Destination: 0.0.0.0/0 (외부 API 호출)

# 3. RDS Security Group
Name: CloudMart-RDS-SG
Inbound Rules:
  - Type: PostgreSQL (5432)
    Source: CloudMart-Backend-SG (Backend만 접근)
Outbound Rules:
  - None (필요 없음)

# 4. ElastiCache Security Group
Name: CloudMart-Redis-SG
Inbound Rules:
  - Type: Redis (6379)
    Source: CloudMart-Backend-SG (Backend만 접근)
Outbound Rules:
  - None (필요 없음)

# 5. Bastion Security Group
Name: CloudMart-Bastion-SG
Inbound Rules:
  - Type: SSH (22)
    Source: [회사 IP]/32 (특정 IP만)
Outbound Rules:
  - Type: SSH (22)
    Destination: CloudMart-Backend-SG
```

**보안 그룹 체인**:
```mermaid
graph LR
    A[인터넷<br/>0.0.0.0/0] --> B[ALB-SG<br/>80, 443]
    B --> C[Backend-SG<br/>8080]
    C --> D[RDS-SG<br/>5432]
    C --> E[Redis-SG<br/>6379]
    
    F[회사 IP] --> G[Bastion-SG<br/>22]
    G --> C
    
    style A fill:#ffebee
    style B fill:#fff3e0
    style C fill:#e8f5e8
    style D fill:#e8f5e8
    style E fill:#e8f5e8
    style F fill:#e3f2fd
    style G fill:#e8f5e8
```

**보안 강화 체크리스트**:
- [ ] RDS는 Private Subnet에만 배치
- [ ] DB 포트(5432)는 Backend SG에서만 접근
- [ ] SSH(22)는 Bastion을 통해서만 접근
- [ ] 모든 통신은 암호화 (TLS/SSL)
- [ ] 불필요한 포트는 모두 차단

### 🔍 개념 3: 백업 전략 & 재해 복구 (11분)

> **정의**: 데이터 손실 방지 및 장애 발생 시 신속한 복구를 위한 계획

**3-2-1 백업 규칙**:
```mermaid
graph TB
    A[원본 데이터] --> B[백업 복사본 3개]
    B --> C1[복사본 1<br/>EBS 스냅샷]
    B --> C2[복사본 2<br/>RDS 자동 백업]
    B --> C3[복사본 3<br/>S3 수동 백업]
    
    C1 --> D[2가지 다른<br/>저장 매체]
    C2 --> D
    
    C3 --> E[1개는 오프사이트<br/>다른 리전]
    
    style A fill:#4caf50
    style B fill:#fff3e0
    style C1 fill:#e8f5e8
    style C2 fill:#e8f5e8
    style C3 fill:#e8f5e8
    style D fill:#e3f2fd
    style E fill:#ffebee
```

**CloudMart 백업 전략**:
```yaml
# 1. RDS 자동 백업
Automated Backup:
  Retention Period: 7 days
  Backup Window: 03:00-04:00 (새벽)
  Point-in-Time Recovery: Enabled (5분 단위)
  
Manual Snapshot:
  Frequency: 주 1회 (일요일)
  Retention: 30 days
  Cross-Region Copy: ap-northeast-1 (도쿄)

# 2. EBS 스냅샷
Snapshot Schedule:
  Frequency: 일 1회 (새벽 2시)
  Retention: 7 days
  Lifecycle Policy: 7일 후 자동 삭제

# 3. S3 버전 관리
Versioning: Enabled
Lifecycle Policy:
  - Current Version: 30 days
  - Previous Versions: 90 days
  - Glacier: 1 year
  - Delete: 2 years

# 4. 애플리케이션 코드
Git Repository:
  - GitHub (Primary)
  - GitLab (Mirror)
  - S3 (Backup)
```

**재해 복구 시나리오**:
```yaml
# 시나리오 1: RDS 장애
Problem: RDS Primary 장애
Solution:
  1. Multi-AZ 자동 Failover (1-2분)
  2. Standby가 Primary로 승격
  3. 애플리케이션 자동 재연결
Recovery Time: 2분
Data Loss: 0 (동기 복제)

# 시나리오 2: 전체 AZ 장애
Problem: ap-northeast-2a 전체 장애
Solution:
  1. ALB가 ap-northeast-2b로 트래픽 전환
  2. ASG가 ap-northeast-2b에 새 인스턴스 생성
  3. RDS Standby가 Primary로 승격
Recovery Time: 5-10분
Data Loss: 0

# 시나리오 3: 데이터 손상
Problem: 잘못된 쿼리로 데이터 삭제
Solution:
  1. RDS Point-in-Time Recovery
  2. 삭제 직전 시점으로 복원
  3. 새 RDS 인스턴스 생성
  4. 애플리케이션 연결 변경
Recovery Time: 30분
Data Loss: 최대 5분

# 시나리오 4: 리전 전체 장애
Problem: ap-northeast-2 전체 장애 (극히 드묾)
Solution:
  1. Route 53 Failover to ap-northeast-1
  2. Cross-Region RDS Replica 승격
  3. S3 Cross-Region Replication 활용
Recovery Time: 1-2시간
Data Loss: 최대 15분 (비동기 복제)
```

**RPO & RTO 목표**:
```yaml
CloudMart 목표:
  RPO (Recovery Point Objective):
    - Critical Data (주문, 결제): 0분 (동기 복제)
    - User Data (프로필): 5분 (Point-in-Time)
    - Logs: 15분 (비동기 복제)
  
  RTO (Recovery Time Objective):
    - AZ 장애: 5분
    - 데이터 손상: 30분
    - 리전 장애: 2시간
```

## 💭 함께 생각해보기 (10분)

### 🤝 페어 토론 (5분)

**토론 주제**:
1. **보안 vs 편의성**: "모든 포트를 막으면 안전하지만 불편해요. 어떻게 균형을 맞출까요?"
2. **백업 비용**: "백업을 많이 하면 안전하지만 비용이 늘어나요. 적정선은?"
3. **재해 복구 테스트**: "재해 복구 계획을 어떻게 테스트할 수 있을까요?"

**페어 활동 가이드**:
- 👥 **자유 페어링**: 보안 관심사가 비슷한 사람끼리
- 🔄 **역할 교대**: 3분씩 설명자/질문자 역할 바꾸기
- 📝 **핵심 정리**: 보안 체크리스트 작성

### 🎯 전체 공유 (5분)

**인사이트 공유**:
- 페어 토론에서 나온 보안 전략
- 실무에서 겪은 보안 사고 경험
- 효과적인 백업 및 복구 방법

**💡 이해도 체크 질문**:
- ✅ "IAM Role과 Security Group의 차이는 무엇인가요?"
- ✅ "3-2-1 백업 규칙은 무엇인가요?"
- ✅ "RPO와 RTO의 차이는 무엇인가요?"

## 🔑 핵심 키워드

### 🆕 새로운 용어
- **IAM (Identity and Access Management)**: AWS 리소스 접근 권한 관리
- **Least Privilege**: 최소 권한 원칙 - 필요한 권한만 부여
- **Defense in Depth**: 다층 방어 - 여러 보안 계층 구축

### 🔧 중요 개념
- **RPO (Recovery Point Objective)**: 데이터 손실 허용 시간
- **RTO (Recovery Time Objective)**: 복구 목표 시간
- **Point-in-Time Recovery**: 특정 시점으로 데이터 복원

### 💼 실무 용어
- **Bastion Host**: 외부에서 Private 리소스 접근을 위한 점프 서버
- **Secrets Manager**: 비밀번호, API 키 등 민감 정보 안전 저장
- **Cross-Region Replication**: 다른 리전으로 데이터 복제

## 📝 세션 마무리

### ✅ 오늘 세션 성과
- **보안 설계**: IAM 정책 및 보안 그룹 최적 구성 방법 습득
- **백업 전략**: 3-2-1 백업 규칙 및 자동화 방법 이해
- **재해 복구**: 다양한 장애 시나리오별 대응 계획 수립

### 🎯 점심 후 실습 준비
- **Lab 1**: CloudMart 전체 인프라 구축 (14:00-14:50)
- **Challenge**: 프로덕션급 완성도로 배포 (15:00-15:50)
- **준비사항**: 오전 4개 세션 내용 복습

### 🔗 실습 연계
- **Lab 1**: 오늘 배운 보안 설정을 실제로 적용
- **Challenge**: 백업 및 모니터링까지 완전한 시스템 구축

---

<div align="center">

**🔐 보안 강화 완료** • **💾 백업 전략 수립** • **🔄 재해 복구 준비**

*점심 후 실습에서 CloudMart를 완전히 배포해보겠습니다!*

</div>
