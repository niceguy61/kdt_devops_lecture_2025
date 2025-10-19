# Challenge 1 힌트 가이드

> ⚠️ **주의**: 이 힌트는 20분 이상 시도한 후에도 해결이 어려울 때만 참고하세요!

---

## 🚨 문제 1: Saga 패턴 트랜잭션 실패

### 힌트 1-1: Job 상태 및 파일 확인
```bash
kubectl get jobs saga-orchestrator -n microservices-challenge
kubectl logs job/saga-orchestrator -n microservices-challenge
```

**무엇을 찾아야 하나요?**
- Job이 Failed 상태인가요?
- **broken-saga.yaml 파일을 열어보세요!**
- `🔧 FIX ME` 주석이 표시된 4곳을 찾으세요:
  1. **FIX ME 1**: backoffLimit을 3으로 변경
  2. **FIX ME 2**: URL을 FQDN으로 변경 (http://order-service.microservices-challenge.svc.cluster.local/api/orders)
  3. **FIX ME 3**: FAILED → SUCCESS, SKIPPED → SUCCESS, Failed → Completed
  4. **FIX ME 4**: exit 1 → exit 0
- 수정 후 Job을 삭제하고 재배포하세요!

### 힌트 1-2: ConfigMap 확인
```bash
kubectl get configmap order-service-config -n microservices-challenge -o yaml
```

**무엇을 찾아야 하나요?**
- Nginx location 블록에 세미콜론(;)이 빠진 곳이 있나요?
- JSON 응답 뒤에 세미콜론이 있어야 합니다!

### 힌트 1-3: Job 설정 확인
```bash
kubectl describe job saga-orchestrator -n microservices-challenge
```

**무엇을 찾아야 하나요?**
- `backoffLimit`이 0으로 설정되어 있나요?
- 재시도가 불가능하면 한 번 실패하면 끝입니다!

**⚠️ 중요**: Job은 수정할 수 없습니다 (immutable)!
```bash
# ❌ 이렇게 하면 오류 발생
kubectl edit job saga-orchestrator

# ✅ 반드시 삭제 후 재생성
kubectl delete job saga-orchestrator -n microservices-challenge
kubectl apply -f fixed-job.yaml
```

---

## 🚨 문제 2: CQRS 패턴 읽기/쓰기 분리 오류

### 힌트 2-1: Command Service 테스트
```bash
kubectl exec -n microservices-challenge deployment/command-service -- curl -s localhost/api/commands/create-user
```

**무엇을 찾아야 하나요?**
- JSON 형식이 올바른가요?
- 키 이름에 따옴표가 있나요? (예: `"command_id"` vs `command_id`)

### 힌트 2-2: Service 엔드포인트 확인
```bash
kubectl get endpoints command-service query-service -n microservices-challenge
```

**무엇을 찾아야 하나요?**
- 엔드포인트가 비어있나요?
- 포트 번호가 8080인데 실제 컨테이너는 80을 사용하나요?

### 힌트 2-3: Service Selector 확인
```bash
kubectl get svc command-service query-service -n microservices-challenge -o yaml | grep -A3 selector
```

**무엇을 찾아야 하나요?**
- selector의 app 라벨이 "wrong-"로 시작하나요?
- Pod의 실제 라벨과 일치하나요?

---

## 🚨 문제 3: Event Sourcing 이벤트 처리 중단

### 힌트 3-1: CronJob 스케줄 확인
```bash
kubectl get cronjobs event-processor -n microservices-challenge -o yaml | grep schedule
```

**무엇을 찾아야 하나요?**
- 스케줄 표현식이 올바른가요?
- Kubernetes CronJob은 5개 필드만 허용합니다!
- 형식: `분 시 일 월 요일` (예: `*/5 * * * *`)
- `*/5 * * * 0`은 "일요일에만 5분마다"라는 의미입니다!
- 올바른 형식: `*/5 * * * *` (매일 5분마다)

### 힌트 3-2: Event Store API 테스트
```bash
kubectl exec -n microservices-challenge deployment/event-store-api -- curl -s localhost/api/events
```

**무엇을 찾아야 하나요?**
- 404 Not Found 오류가 나나요?
- Nginx alias 경로가 실제 파일 위치와 일치하나요?

### 힌트 3-3: 볼륨 마운트 확인
```bash
kubectl describe deployment event-store-api -n microservices-challenge | grep -A5 "Mounts:"
```

**무엇을 찾아야 하나요?**
- event-data 볼륨이 `/usr/share/nginx/html/wrong-events`에 마운트되어 있나요?
- 올바른 경로는 `/usr/share/nginx/html`입니다!

---

## 🚨 문제 4: 네트워킹 및 서비스 디스커버리 장애

### 힌트 4-1: User Service 엔드포인트
```bash
kubectl get endpoints user-service -n microservices-challenge
```

**무엇을 찾아야 하나요?**
- 엔드포인트가 비어있나요?
- Service의 selector가 Pod 라벨과 일치하나요?

### 힌트 4-2: Ingress 설정 확인
```bash
kubectl get ingress ecommerce-ingress -n microservices-challenge -o yaml
```

**무엇을 찾아야 하나요?**
- backend service 이름이 "nonexistent-"로 시작하나요?
- 포트 번호가 8080인데 실제 서비스는 80을 사용하나요?

### 힌트 4-3: DNS 테스트
```bash
kubectl exec -n testing deployment/load-tester -- nslookup user-service.microservices-challenge.svc.cluster.local
```

**무엇을 찾아야 하나요?**
- DNS가 IP 주소를 반환하나요?
- Service가 제대로 생성되었나요?

---

## 💡 일반적인 디버깅 팁

### 1. Pod 상태 확인
```bash
kubectl get pods -n microservices-challenge
kubectl describe pod <pod-name> -n microservices-challenge
```

### 2. 로그 확인
```bash
kubectl logs <pod-name> -n microservices-challenge
kubectl logs deployment/<deployment-name> -n microservices-challenge
```

### 3. Service 연결 테스트
```bash
kubectl exec -n testing deployment/load-tester -- curl -v http://<service-name>.microservices-challenge.svc.cluster.local
```

### 4. ConfigMap 내용 확인
```bash
kubectl get configmap <configmap-name> -n microservices-challenge -o yaml
```

### 5. 변경 사항 적용
```bash
# ConfigMap 수정 후 Pod 재시작
kubectl rollout restart deployment/<deployment-name> -n microservices-challenge

# Job 재생성
kubectl delete job <job-name> -n microservices-challenge
kubectl apply -f <fixed-yaml-file>
```

---

## 🎯 체크리스트

해결하기 전에 다음을 확인하세요:

- [ ] 모든 Pod가 Running 상태인가요?
- [ ] Service 엔드포인트가 비어있지 않나요?
- [ ] ConfigMap의 JSON/Nginx 설정이 올바른가요?
- [ ] Job의 backoffLimit이 0보다 큰가요?
- [ ] CronJob 스케줄이 5개 필드인가요?
- [ ] 볼륨 마운트 경로가 올바른가요?
- [ ] Service selector와 Pod 라벨이 일치하나요?

---

**💪 힌트를 봤다면 다시 도전해보세요!**

여전히 어렵다면 `solutions.md`를 참고하세요.
