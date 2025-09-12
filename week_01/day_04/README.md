# Week 1 - Day 4: Docker 이미지 관리

## 📅 일정 개요
- **날짜**: Week 1, Day 4
- **주제**: Docker 이미지 관리
- **총 세션**: 8개 (각 50분)
- **실습 비중**: 60%

## 🎯 학습 목표
- Docker 이미지의 구조와 레이어 시스템 완전 이해
- Dockerfile 작성 및 최적화 기법 마스터
- 이미지 빌드, 태깅, 배포 전략 습득
- 멀티 스테이지 빌드와 보안 모범 사례 적용
- 이미지 레지스트리 활용 및 관리

## 📚 세션 구성

### [Session 1: Docker 이미지 아키텍처 심화](./session_01.md)
- 이미지 레이어 시스템의 내부 구조
- Union File System과 Copy-on-Write 메커니즘
- 이미지 메타데이터와 매니페스트 구조

### [Session 2: Dockerfile 기초 및 명령어](./session_02.md)
- Dockerfile 문법과 명령어 상세 분석
- 베이스 이미지 선택 전략
- 효율적인 레이어 구성 방법

### [Session 3: Dockerfile 최적화 기법](./session_03.md)
- 이미지 크기 최소화 전략
- 빌드 캐시 활용 최적화
- .dockerignore 활용법

### [Session 4: 멀티 스테이지 빌드](./session_04.md)
- 멀티 스테이지 빌드 개념과 장점
- 프로덕션 이미지 최적화
- 빌드 도구와 런타임 분리

### [Session 5: 이미지 태깅 및 버전 관리](./session_05.md)
- 태깅 전략과 네이밍 컨벤션
- 시맨틱 버저닝 적용
- 이미지 라이프사이클 관리

### [Session 6: Docker Registry 활용](./session_06.md)
- Docker Hub와 프라이빗 레지스트리
- 이미지 푸시/풀 전략
- 레지스트리 보안 및 인증

### [Session 7: 이미지 보안 및 스캐닝](./session_07.md)
- 컨테이너 이미지 보안 모범 사례
- 취약점 스캐닝 도구 활용
- 보안 정책 및 컴플라이언스

### [Session 8: 종합 실습 - 프로덕션 이미지 구축](./session_08.md)
- 실제 애플리케이션 이미지 구축
- CI/CD 파이프라인 통합
- 성능 모니터링 및 최적화

## 🛠 실습 환경
- Docker Desktop 또는 Docker Engine
- 텍스트 에디터 (VS Code 권장)
- Docker Hub 계정
- Git (버전 관리용)

## 📋 평가 요소
- Dockerfile 작성 능력
- 이미지 최적화 수준
- 보안 모범 사례 적용
- 실습 과제 완성도

## 🔗 참고 자료
- [Docker 공식 문서 - 이미지](https://docs.docker.com/engine/reference/builder/)
- [Dockerfile 모범 사례](https://docs.docker.com/develop/dev-best-practices/)
- [Docker Hub](https://hub.docker.com/)
- [Container Security](https://docs.docker.com/engine/security/)

## 📝 과제
각 세션별 실습 과제를 통해 Docker 이미지 관리 능력을 단계적으로 향상시킵니다.

---
*이 과정을 통해 프로덕션 환경에서 사용할 수 있는 고품질 Docker 이미지를 구축하는 능력을 습득하게 됩니다.*