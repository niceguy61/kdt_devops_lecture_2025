# Week 3 Day 5 Challenge 2: 운영 & 고급 기능 아키텍처 구현 챌린지 (선택사항, 90분)

<div align="center">

**📊 모니터링 설계** • **🔄 자동화 구현** • **🚀 고급 기능**

*Prometheus, HPA, CRD를 활용한 프로덕션급 운영 플랫폼 구현*

</div>

---

## 🎯 Challenge 목표

### 📚 학습 목표
- **운영 설계**: 모니터링, 로깅, 오토스케일링 통합 구현
- **고급 기능**: CRD, Operator 패턴 체험
- **실무 문서화**: 운영 절차와 장애 대응 방안 수립

### 🛠️ 구현 목표
- **GitHub Repository**: 운영 도구와 설정의 체계적 관리
- **클러스터 시각화**: 모니터링 대시보드와 메트릭 시각화
- **분석 보고서**: 운영 효율성과 자동화 효과 분석

---

## 🌐 도메인 준비 (필요시)

### 📋 무료 도메인 발급 가이드
**Ingress 및 외부 접근 테스트를 위해 도메인을 준비하세요.**

👉 **[무료 도메인 발급 가이드](../../shared/free-domain-guide.md)** 참조

---

## 🏗️ 구현 시나리오

### 📖 비즈니스 상황
**"글로벌 스트리밍 서비스의 운영 플랫폼 구축"**

동영상 스트리밍 서비스가 급성장하면서 24/7 안정적인 서비스 운영이 
필수가 되었습니다. 자동화된 모니터링과 스케일링이 필요합니다.

### 🎬 서비스 구성 요구사항
1. **Video API**: 동영상 메타데이터 관리
2. **Streaming Service**: 실제 스트리밍 처리 (CPU 집약적)
3. **User Service**: 사용자 관리 및 인증
4. **Recommendation Engine**: AI 기반 추천 (메모리 집약적)
5. **CDN Gateway**: 콘텐츠 전송 최적화
6. **Analytics Service**: 실시간 시청 통계

### 📊 운영 요구사항
- **모니터링**: Prometheus + Grafana 스택
- **로깅**: ELK Stack (Elasticsearch, Logstash, Kibana)
- **자동 스케일링**: CPU/메모리 기반 HPA
- **커스텀 메트릭**: 동시 시청자 수 기반 스케일링
- **알림**: Slack/Email 통합 알림 시스템
- **백업**: 자동화된 데이터 백업

### 🔄 자동화 요구사항
- **트래픽 급증 대응**: 실시간 스케일링 (최대 100배)
- **장애 자동 복구**: 헬스체크 기반 자동 재시작
- **리소스 최적화**: 사용량 기반 자동 스케일 다운
- **배포 자동화**: GitOps 기반 무중단 배포
- **비용 최적화**: 야간 시간대 자동 스케일 다운

---

## 📁 GitHub Repository 구조

### 필수 디렉토리 구조
```
streaming-ops-platform/
├── README.md                           # 프로젝트 개요
├── k8s-manifests/                      # Kubernetes 매니페스트
│   ├── namespaces/
│   │   ├── streaming-ns.yaml
│   │   ├── monitoring-ns.yaml
│   │   └── logging-ns.yaml
│   ├── monitoring/
│   │   ├── prometheus/
│   │   │   ├── prometheus-config.yaml
│   │   │   ├── prometheus-deployment.yaml
│   │   │   └── service-monitors.yaml
│   │   ├── grafana/
│   │   │   ├── grafana-deployment.yaml
│   │   │   └── dashboards/
│   │   └── alertmanager/
│   │       ├── alertmanager-config.yaml
│   │       └── alert-rules.yaml
│   ├── logging/
│   │   ├── elasticsearch/
│   │   ├── logstash/
│   │   └── kibana/
│   ├── autoscaling/
│   │   ├── hpa-configs.yaml
│   │   ├── vpa-configs.yaml
│   │   └── custom-metrics.yaml
│   ├── advanced/
│   │   ├── crds/
│   │   │   └── streaming-crd.yaml
│   │   ├── operators/
│   │   │   └── streaming-operator.yaml
│   │   └── service-mesh/
│   │       └── istio-configs.yaml
│   └── workloads/
│       ├── video-api.yaml
│       ├── streaming-service.yaml
│       ├── user-service.yaml
│       ├── recommendation-engine.yaml
│       ├── cdn-gateway.yaml
│       └── analytics-service.yaml
├── docs/                               # 분석 문서
│   ├── operations-analysis.md         # 운영 분석 보고서
│   ├── monitoring-guide.md            # 모니터링 가이드
│   ├── troubleshooting.md             # 장애 대응 가이드
│   └── screenshots/                   # 시각화 캡처
│       ├── grafana-dashboard.png
│       ├── prometheus-metrics.png
│       ├── kibana-logs.png
│       └── hpa-scaling.png
└── scripts/                           # 배포/관리 스크립트
    ├── deploy-monitoring.sh           # 모니터링 스택 배포
    ├── deploy-logging.sh              # 로깅 스택 배포
    ├── setup-autoscaling.sh           # 오토스케일링 설정
    ├── load-test.sh                   # 부하 테스트
    └── backup-restore.sh              # 백업/복구
```

---

## 📊 시각화 도구 활용

### 🛠️ 권장 시각화 도구
1. **Grafana**: 메트릭 대시보드 및 알림
2. **Kibana**: 로그 분석 및 시각화
3. **Prometheus UI**: 메트릭 쿼리 및 탐색
4. **K9s**: 실시간 클러스터 상태 모니터링

### 📸 필수 캡처 항목
- **Grafana 대시보드**: 전체 시스템 메트릭
- **Prometheus 메트릭**: 커스텀 메트릭 수집 현황
- **Kibana 로그**: 중앙화된 로그 분석
- **HPA 스케일링**: 자동 스케일링 동작 과정

---

## 📝 분석 보고서 템플릿

### `docs/operations-analysis.md` 구조
```markdown
# 스트리밍 플랫폼 운영 아키텍처 분석 보고서

## 🎯 운영 아키텍처 개요
### 전체 운영 스택
[운영 아키텍처 다이어그램]

### 운영 도구 매핑
| 영역 | 도구 | 목적 | 메트릭 | 알림 |
|------|------|------|--------|------|
| 메트릭 수집 | Prometheus | 시계열 데이터 | CPU, Memory, Custom | AlertManager |
| 시각화 | Grafana | 대시보드 | 비즈니스 메트릭 | Slack, Email |
| 로그 수집 | Fluent Bit | 로그 집계 | 로그 볼륨 | ELK Stack |
| 로그 분석 | ELK Stack | 로그 검색/분석 | 에러율 | Watcher |
| 자동 스케일링 | HPA/VPA | 리소스 최적화 | 사용률 | K8s Events |

## 📊 모니터링 설계 분석

### 1. Prometheus 메트릭 수집
**커스텀 메트릭 정의:**
```yaml
# 구현한 ServiceMonitor 예시
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: streaming-metrics
spec:
  selector:
    matchLabels:
      app: streaming-service
  endpoints:
  - port: metrics
    path: /metrics
    interval: 30s
```

**비즈니스 메트릭:**
- `concurrent_viewers_total`: 동시 시청자 수
- `video_quality_score`: 영상 품질 점수
- `buffering_events_total`: 버퍼링 발생 횟수
- `recommendation_accuracy`: 추천 정확도

### 2. Grafana 대시보드 설계
**대시보드 구성:**
1. **시스템 개요**: 전체 클러스터 상태
2. **서비스별 메트릭**: 각 마이크로서비스 성능
3. **비즈니스 메트릭**: 시청자, 매출, 품질 지표
4. **인프라 메트릭**: 노드, 네트워크, 스토리지

**알림 규칙:**
- 동시 시청자 수 > 10,000명: 스케일링 준비
- 에러율 > 1%: 즉시 알림
- 응답시간 > 500ms: 성능 경고

### 3. 로깅 전략
**로그 수집 및 분석:**
```yaml
# 구현한 Fluent Bit 설정
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluent-bit-config
data:
  fluent-bit.conf: |
    [INPUT]
        Name tail
        Path /var/log/containers/*streaming*.log
        Parser docker
        Tag streaming.*
    [OUTPUT]
        Name es
        Match streaming.*
        Host elasticsearch.logging-ns
```

**로그 분류:**
- **액세스 로그**: 사용자 요청 패턴
- **에러 로그**: 장애 원인 분석
- **성능 로그**: 응답시간, 처리량
- **보안 로그**: 인증, 권한 이벤트

## 🔄 자동화 설계 분석

### 1. HPA 설정 전략
**CPU/메모리 기반 스케일링:**
```yaml
# 구현한 HPA 설정
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: streaming-service-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: streaming-service
  minReplicas: 3
  maxReplicas: 100
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Pods
    pods:
      metric:
        name: concurrent_viewers
      target:
        type: AverageValue
        averageValue: "1000"
```

**커스텀 메트릭 스케일링:**
- 동시 시청자 수 기반 스케일링
- 네트워크 대역폭 사용률
- 스토리지 I/O 부하

### 2. VPA 리소스 최적화
**자동 리소스 조정:**
- 

### 3. 스케일링 정책
**시간대별 스케일링:**
- 

## 🚀 고급 기능 분석

### 1. Custom Resource Definition
**스트리밍 서비스 CRD:**
```yaml
# 구현한 CRD 예시
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: streamingservices.streaming.io
spec:
  group: streaming.io
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              maxViewers:
                type: integer
              qualityProfile:
                type: string
```

**Operator 패턴 구현:**
- 

### 2. Service Mesh (선택사항)
**Istio 적용:**
- 

## 📈 성능 및 효율성 분석
### 자동화 효과
1. **스케일링 응답시간**: 
2. **리소스 사용률 개선**: 
3. **장애 복구 시간**: 
4. **운영 비용 절감**: 

### 모니터링 효과
1. **장애 감지 시간**: 
2. **근본 원인 분석**: 
3. **예방적 대응**: 

## ⚠️ 운영 이슈 및 개선점
### 현재 제약사항
1. **스케일링 지연**: 
2. **메트릭 정확도**: 
3. **알림 피로도**: 

### 개선 방안
#### 즉시 적용 (1주)
- [ ] 
- [ ] 

#### 단기 개선 (1개월)
- [ ] 
- [ ] 

#### 장기 개선 (3개월)
- [ ] 
- [ ] 

## 📊 시각화 결과 분석
### Grafana 대시보드
![시스템 대시보드](screenshots/grafana-dashboard.png)
**분석**: 

### Prometheus 메트릭
![메트릭 수집](screenshots/prometheus-metrics.png)
**분석**: 

### Kibana 로그 분석
![로그 분석](screenshots/kibana-logs.png)
**분석**: 

### HPA 스케일링
![자동 스케일링](screenshots/hpa-scaling.png)
**분석**: 

## 🎓 학습 인사이트
### 모니터링 학습 포인트
- 

### 자동화 학습 포인트
- 

### 고급 기능 학습 포인트
- 

### 실무 운영 고려사항
- 

## 🚀 운영 로드맵
### 단계별 운영 성숙도
1. **Level 1**: 기본 모니터링 및 수동 대응
2. **Level 2**: 자동화된 스케일링 및 알림
3. **Level 3**: 예측적 분석 및 자동 복구
4. **Level 4**: AI 기반 운영 최적화
```

---

## 📋 제출 방법

### 1. GitHub Repository 생성
- **Repository 이름**: `w3d5-streaming-ops-platform`
- **Public Repository**로 설정
- **README.md**에 운영 아키텍처 개요 작성

### 2. Discord 제출
```
📝 제출 형식:
**팀명**: [팀 이름]
**GitHub**: [Repository URL]
**완료 시간**: [HH:MM]
**모니터링 특징**: [Prometheus/Grafana 구성 포인트]
**자동화 특징**: [HPA/VPA 설정 포인트]
**고급 기능**: [CRD/Operator 구현 여부]
**운영 인사이트**: [가장 인상적인 운영 기능]
```

---

## ⏰ 진행 일정

### 📅 시간 배분
```
1. 운영 설계 (15분)
   - 모니터링 스택 설계
   - 자동화 전략 수립

2. 모니터링 구현 (35분)
   - Prometheus + Grafana 배포
   - 커스텀 메트릭 설정
   - 대시보드 구성

3. 자동화 구현 (25분)
   - HPA/VPA 설정
   - 로깅 스택 배포
   - 알림 설정

4. 고급 기능 (10분)
   - CRD 생성 (선택사항)
   - Service Mesh 체험 (선택사항)

5. 문서화 및 제출 (5분)
   - 운영 가이드 작성
   - GitHub 정리 및 제출
```

---

## 🏆 성공 기준

### ✅ 필수 달성 목표
- [ ] Prometheus + Grafana 모니터링 스택 구축
- [ ] 커스텀 메트릭 기반 HPA 동작 확인
- [ ] 중앙화된 로깅 시스템 구축
- [ ] 알림 시스템 동작 확인
- [ ] 운영 분석 보고서 완성

### 🌟 우수 달성 목표
- [ ] CRD 및 Operator 패턴 구현
- [ ] Service Mesh 적용
- [ ] 고급 스케일링 정책 구현
- [ ] 예측적 모니터링 및 알림
- [ ] 상세한 운영 절차 문서화

---

## 💡 힌트 및 팁

### 📊 모니터링 팁
- **Prometheus 쿼리**: `rate(http_requests_total[5m])`로 요청률 계산
- **Grafana 변수**: `$namespace`, `$service`로 동적 대시보드
- **AlertManager**: 알림 그룹핑으로 스팸 방지

### 🔄 자동화 팁
- **HPA 테스트**: `kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh`
- **메트릭 확인**: `kubectl get hpa -w`로 실시간 스케일링 관찰
- **VPA 권장사항**: `kubectl describe vpa`에서 추천 리소스 확인

---

<div align="center">

**📊 운영 전문성** • **🔄 자동화 마스터리** • **🚀 고급 기능** • **📈 성능 최적화**

*프로덕션급 스트리밍 서비스 운영 플랫폼 구축*

</div>
