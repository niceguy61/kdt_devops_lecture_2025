# Week 3: Kubernetes 기초

## 학습 목표
- Kubernetes 아키텍처 및 핵심 개념 이해
- 클러스터 구성 및 기본 오브젝트 학습
- kubectl 명령어 마스터
- Pod, Service, Deployment 실습

## 주간 일정

### Day 1: Kubernetes 개념 및 아키텍처
**세션 1-2**: Kubernetes란 무엇인가? Docker와의 차이점
**세션 3-4**: 마스터 노드와 워커 노드 아키텍처
**세션 5-6**: etcd, API Server, Scheduler, Controller Manager
**세션 7-8**: kubelet, kube-proxy, Container Runtime

### Day 2: 로컬 Kubernetes 환경 구성
**세션 1-2**: Minikube 설치 및 설정
**세션 3-4**: kubectl 설치 및 기본 명령어
**세션 5-6**: Kind, k3s 등 대안 도구 소개
**세션 7-8**: 실습: 첫 번째 클러스터 생성 및 접근

### Day 3: Pod와 기본 오브젝트
**세션 1-2**: Pod 개념 및 생명주기
**세션 3-4**: YAML 매니페스트 작성법
**세션 5-6**: 라벨과 셀렉터 활용
**세션 7-8**: 실습: Pod 생성, 수정, 삭제

### Day 4: Service와 네트워킹
**세션 1-2**: Service 타입별 특징 (ClusterIP, NodePort, LoadBalancer)
**세션 3-4**: Endpoint와 서비스 디스커버리
**세션 5-6**: DNS 및 네트워크 정책
**세션 7-8**: 실습: 서비스를 통한 Pod 노출

### Day 5: Deployment와 ReplicaSet
**세션 1-2**: Deployment 개념 및 롤링 업데이트
**세션 3-4**: ReplicaSet과 스케일링
**세션 5-6**: 롤백 및 히스토리 관리
**세션 7-8**: 종합 실습: 완전한 애플리케이션 배포