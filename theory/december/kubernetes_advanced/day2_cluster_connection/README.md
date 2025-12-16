# Day 2: 클러스터 연결 및 기본 설정

## 🎯 학습 목표
- kubectl 고급 설정 및 관리
- Kubernetes 기본 오브젝트 배포
- 네임스페이스 및 RBAC 기초
- 실제 워크로드 배포 및 관리

## ⏰ 세션 구성 (총 2시간)

### Session 1: kubectl 설정 및 관리 (50분)
- **이론** (15분): kubectl, kubeconfig 심화 개념
- **실습** (35분): 클러스터 연결, 컨텍스트 관리

### Session 2: 기본 워크로드 배포 (50분)
- **실습** (40분): Pod, Service, Deployment 배포
- **정리** (10분): 체크포인트 확인

## 📁 세션별 자료

- [Session 1: kubectl 설정 및 관리](./session1.md)
- [Session 2: 기본 워크로드 배포](./session2.md)
- [실습 예제 모음](./examples.md)

## 🛠️ 제공 파일

- `kubeconfig-examples/` - 다양한 kubeconfig 설정 예제
- `manifests/` - Kubernetes 매니페스트 파일들
- `scripts/` - 유틸리티 스크립트들

## 🚨 트러블슈팅

### 자주 발생하는 문제들

#### 1. kubeconfig 설정 문제
```bash
# 에러: The connection to the server localhost:8080 was refused
# 해결: kubeconfig 파일 경로 확인
export KUBECONFIG=~/.kube/config
```

#### 2. 권한 부족 문제
```bash
# 에러: User cannot get resource "pods" in API group
# 해결: RBAC 설정 확인
kubectl auth can-i get pods
```

#### 3. 네임스페이스 문제
```bash
# 에러: No resources found in default namespace
# 해결: 올바른 네임스페이스 지정
kubectl get pods -n kube-system
```

## 📝 과제 및 다음 준비사항

### 오늘 완료해야 할 것
- kubectl 컨텍스트 관리 숙지
- 기본 Kubernetes 오브젝트 배포 경험
- 네임스페이스 개념 이해

### 다음 세션 준비
- Helm 기본 개념 학습
- 패키지 관리 도구 필요성 이해

## 📚 참고 자료
- [kubectl 치트시트](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Kubernetes 오브젝트 관리](https://kubernetes.io/docs/concepts/overview/working-with-objects/)
- [네임스페이스 가이드](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
