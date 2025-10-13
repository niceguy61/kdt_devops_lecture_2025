# Challenge 1 힌트 가이드

💡 **막혔을 때만 참고하세요!** 먼저 스스로 문제를 찾아보는 것이 중요합니다.

---

## 🔍 일반적인 디버깅 순서

1. **현재 상태 파악**
   ```bash
   kubectl get pods -n day1-challenge
   kubectl get svc -n day1-challenge
   ```

2. **접근 테스트**
   ```bash
   curl http://localhost:30080  # Frontend 테스트
   curl http://localhost:30081  # API 테스트
   ```

3. **상세 정보 확인**
   ```bash
   kubectl describe pod <pod-name> -n day1-challenge
   kubectl describe svc <service-name> -n day1-challenge
   ```

---

## 💭 시나리오별 약한 힌트

### 시나리오 1: 웹사이트 접근 불가
**증상**: `curl http://localhost:30080` 실패

**힌트**:
- Pod는 정상 실행 중인가요?
- Service의 포트 설정을 확인해보세요
- Pod가 실제로 사용하는 포트는 무엇인가요?
- Service가 올바른 포트로 트래픽을 전달하고 있나요?

**확인 명령어**:
```bash
kubectl get pods -l app=frontend -n day1-challenge
kubectl describe svc frontend-service -n day1-challenge
kubectl describe pod <frontend-pod> -n day1-challenge
```

### 시나리오 2: API 서버 응답 없음
**증상**: API 엔드포인트에서 데이터베이스 연결 오류

**힌트**:
- Pod의 로그를 확인해보세요
- 환경변수 설정이 올바른가요?
- 데이터베이스 서비스 이름을 확인해보세요
- 다른 서비스들은 어떤 이름을 사용하고 있나요?

**확인 명령어**:
```bash
kubectl logs -l app=api-server -n day1-challenge
kubectl describe pod <api-pod> -n day1-challenge
kubectl get svc -n day1-challenge | grep database
```

### 시나리오 3: Pod 시작 실패
**증상**: Pod가 `ErrImagePull` 또는 `ImagePullBackOff` 상태

**힌트**:
- Pod의 이벤트를 확인해보세요
- 이미지 이름과 태그가 올바른가요?
- Docker Hub에서 해당 이미지가 존재하는지 확인해보세요
- 다른 정상 동작하는 Pod는 어떤 이미지를 사용하나요?

**확인 명령어**:
```bash
kubectl describe pod <pod-name> -n day1-challenge
kubectl get pods -n day1-challenge -o wide
```

### 시나리오 4: 서비스 연결 실패
**증상**: Service는 있지만 연결되지 않음

**힌트**:
- Service에 Endpoints가 있나요?
- Service의 selector와 Pod의 labels가 일치하나요?
- 라벨 이름에 오타는 없나요?
- 다른 정상 동작하는 Service는 어떻게 설정되어 있나요?

**확인 명령어**:
```bash
kubectl get endpoints -n day1-challenge
kubectl get pods --show-labels -n day1-challenge
kubectl describe svc backend-service -n day1-challenge
```

---

## 🛠️ 유용한 디버깅 명령어

### 전체 상태 한눈에 보기
```bash
kubectl get all -n day1-challenge
```

### 특정 리소스 상세 정보
```bash
kubectl describe <resource-type> <resource-name> -n day1-challenge
```

### 실시간 로그 확인
```bash
kubectl logs -f <pod-name> -n day1-challenge
```

### 라벨로 리소스 필터링
```bash
kubectl get pods -l app=frontend -n day1-challenge
kubectl get pods --show-labels -n day1-challenge
```

### 포트 포워딩으로 직접 테스트
```bash
kubectl port-forward <pod-name> 8080:80 -n day1-challenge
```

### 임시 테스트 Pod 생성
```bash
kubectl run test --image=busybox -it --rm -n day1-challenge -- /bin/sh
```

---

## 🎯 문제 해결 후 확인사항

각 문제를 해결한 후에는 다음을 확인하세요:

1. **Pod 상태**: 모든 Pod가 `Running` 상태인가?
2. **Service 연결**: 모든 Service에 Endpoints가 있는가?
3. **접근 테스트**: 웹사이트와 API가 정상 응답하는가?
4. **로그 확인**: 에러 메시지가 사라졌는가?

---

## 💡 막혔을 때 시도해볼 것들

1. **다시 처음부터**: 증상을 정확히 파악하고 단계별로 접근
2. **비교 분석**: 정상 동작하는 리소스와 문제 리소스 비교
3. **로그 분석**: 에러 메시지에서 단서 찾기
4. **설정 검토**: YAML 파일의 모든 값들을 꼼꼼히 확인
5. **네트워크 테스트**: 포트 포워딩으로 직접 연결 테스트

---

**🚨 주의**: 이 힌트들은 정답을 직접 알려주지 않습니다. 스스로 문제를 찾고 해결하는 과정이 가장 중요한 학습입니다!
