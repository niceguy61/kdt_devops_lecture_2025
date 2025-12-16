# Day 5: Istio 서비스 메시

## 🎯 학습 목표
- Istio 서비스 메시 아키텍처 이해
- 사이드카 프록시를 통한 트래픽 관리
- Gateway, VirtualService를 통한 라우팅 제어
- 관측성 및 보안 기능 활용

## ⏰ 세션 구성 (총 2시간)

### Session 1: Istio 설치 및 기본 설정 (50분)
- **이론** (15분): Service Mesh 개념, Istio 아키텍처
- **실습** (35분): Istio 설치, 사이드카 주입

### Session 2: 트래픽 관리 및 관측성 (50분)
- **실습** (35분): Gateway, Virtual Service 설정
- **실습** (15분): Kiali 대시보드 확인

## 📁 세션별 자료

- [Session 1: Istio 설치 및 기본 설정](./session1.md)
- [Session 2: 트래픽 관리 및 관측성](./session2.md)
- [실습 예제 모음](./examples.md)

## 🛠️ 제공 파일

- `istio-configs/` - Istio 설정 파일들
- `manifests/` - 서비스 메시 적용 매니페스트
- `scripts/` - Istio 설치 및 설정 자동화 스크립트

## 🚨 트러블슈팅

### 자주 발생하는 문제들

#### 1. Istio 설치 문제
```bash
# 에러: istioctl command not found
# 해결: Istio CLI 설치
curl -L https://istio.io/downloadIstio | sh -
export PATH=$PWD/istio-*/bin:$PATH
```

#### 2. 사이드카 주입 실패
```bash
# 에러: sidecar not injected
# 해결: 네임스페이스 라벨 확인
kubectl label namespace production istio-injection=enabled
```

#### 3. Gateway 접근 불가
```bash
# 에러: gateway not accessible
# 해결: LoadBalancer IP 확인
kubectl get service istio-ingressgateway -n istio-system
```

## 📝 과제 및 다음 준비사항

### 오늘 완료해야 할 것
- Istio 서비스 메시 구성 완료
- 트래픽 라우팅 및 로드 밸런싱 경험
- 관측성 도구를 통한 서비스 모니터링

### 향후 학습 방향
- 고급 트래픽 관리 (카나리 배포, 서킷 브레이커)
- 보안 정책 (mTLS, 인증/인가)
- 성능 최적화 및 튜닝

## 📚 참고 자료
- [Istio 공식 문서](https://istio.io/latest/docs/)
- [서비스 메시 패턴](https://istio.io/latest/docs/concepts/traffic-management/)
- [Kiali 관측성 가이드](https://kiali.io/docs/)
