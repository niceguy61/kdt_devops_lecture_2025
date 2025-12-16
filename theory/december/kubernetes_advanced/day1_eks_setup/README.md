# Day 1: EKS 클러스터 생성

## 🎯 학습 목표
- EKS 아키텍처 이해
- eksctl을 사용한 클러스터 생성
- 노드 그룹 설정 및 IAM 역할 구성

## ⏰ 세션 구성 (총 2시간)

### Session 1: EKS 기초 + 클러스터 생성 (50분)
- **이론** (20분): EKS 아키텍처 핵심 개념
- **실습** (30분): eksctl로 클러스터 생성

### Session 2: 노드 그룹 + 접근 설정 (50분)
- **실습** (40분): 노드 그룹 설정, IAM 역할
- **정리** (10분): 체크포인트 확인

## 📁 세션별 자료

- [Session 1: EKS 기초 + 클러스터 생성](./session1.md)
- [Session 2: 노드 그룹 + 접근 설정](./session2.md)
- [실습 예제 모음](./examples.md)

## 🛠️ 제공 파일

- `cluster-config.yaml` - EKS 클러스터 설정 파일
- `setup-check.sh` - 환경 설정 확인 스크립트
- `cleanup.sh` - 클러스터 정리 스크립트
- `tools-and-utilities.md` - EKS 관리 도구 가이드
- `eks-system-components.md` - EKS 시스템 컴포넌트 상세 가이드

## 🚨 트러블슈팅

### 자주 발생하는 문제들

#### 1. AWS 권한 부족
```bash
# 에러: User is not authorized to perform: eks:CreateCluster
# 해결: IAM 사용자에 EKS 관련 권한 추가
```

#### 2. 리전 설정 문제
```bash
# 에러: No cluster found for name: my-eks-cluster
# 해결: AWS CLI 기본 리전 확인
aws configure get region
```

#### 3. 노드 그룹 생성 실패
```bash
# 에러: Cannot create node group
# 해결: 서브넷 가용 영역 확인
aws ec2 describe-availability-zones --region ap-northeast-2
```

## 📝 과제 및 다음 준비사항

### 오늘 완료해야 할 것
- EKS 클러스터 생성 완료
- 기본 kubectl 명령어 숙지
- AWS 콘솔에서 생성된 리소스 확인

### 다음 세션 준비
- kubectl 기본 명령어 복습
- Kubernetes 기본 오브젝트 개념 정리

## 📚 참고 자료
- [AWS EKS 사용 설명서](https://docs.aws.amazon.com/eks/)
- [eksctl 공식 문서](https://eksctl.io/)
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
