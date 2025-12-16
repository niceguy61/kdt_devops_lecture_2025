# Day 4: 애플리케이션 배포

## 🎯 학습 목표
- 컨테이너 이미지 빌드 및 레지스트리 관리
- ECR (Elastic Container Registry) 활용
- 멀티 티어 애플리케이션 아키텍처 구성
- 실제 웹 애플리케이션 배포 및 연동

## ⏰ 세션 구성 (총 2시간)

### Session 1: 컨테이너 이미지 관리 (50분)
- **이론** (15분): ECR, 이미지 전략
- **실습** (35분): ECR 연동, 이미지 푸시

### Session 2: 멀티 티어 앱 배포 (50분)
- **실습** (40분): DB + API + Frontend 배포
- **정리** (10분): 애플리케이션 상태 확인

## 📁 세션별 자료

- [Session 1: 컨테이너 이미지 관리](./session1.md)
- [Session 2: 멀티 티어 앱 배포](./session2.md)
- [실습 예제 모음](./examples.md)

## 🛠️ 제공 파일

- `apps/` - 샘플 애플리케이션 소스코드
- `dockerfiles/` - 다양한 Dockerfile 예제
- `manifests/` - 멀티 티어 애플리케이션 매니페스트
- `scripts/` - 빌드 및 배포 자동화 스크립트

## 🚨 트러블슈팅

### 자주 발생하는 문제들

#### 1. ECR 인증 문제
```bash
# 에러: no basic auth credentials
# 해결: ECR 로그인 토큰 갱신
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin ACCOUNT.dkr.ecr.ap-northeast-2.amazonaws.com
```

#### 2. 이미지 푸시 실패
```bash
# 에러: repository does not exist
# 해결: ECR 저장소 생성
aws ecr create-repository --repository-name my-app --region ap-northeast-2
```

#### 3. Pod 이미지 풀 실패
```bash
# 에러: ErrImagePull
# 해결: 노드 그룹 IAM 역할에 ECR 권한 확인
aws iam list-attached-role-policies --role-name eksctl-my-eks-cluster-nodegroup-worker-nodes-NodeInstanceRole
```

## 📝 과제 및 다음 준비사항

### 오늘 완료해야 할 것
- ECR 저장소 생성 및 이미지 푸시 경험
- 멀티 티어 애플리케이션 배포 완료
- 서비스 간 통신 및 데이터베이스 연동 확인

### 다음 세션 준비
- Istio 서비스 메시 기본 개념
- 마이크로서비스 트래픽 관리 이해

## 📚 참고 자료
- [Amazon ECR 사용 설명서](https://docs.aws.amazon.com/ecr/)
- [Docker 이미지 최적화](https://docs.docker.com/develop/dev-best-practices/)
- [Kubernetes 멀티 티어 애플리케이션](https://kubernetes.io/docs/tutorials/stateful-application/)
