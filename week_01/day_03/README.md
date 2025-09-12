# Week 1 - Day 3: Docker 기본 명령어

## 📅 일정 개요
- **날짜**: Week 1, Day 3
- **주제**: Docker 기본 명령어 마스터
- **목표**: Docker CLI를 활용한 컨테이너 기본 조작 능력 습득

## 🎯 학습 목표
- Docker CLI의 기본 구조와 사용법 이해
- 이미지 관리 명령어 완전 습득
- 컨테이너 생성, 실행, 관리 명령어 마스터
- 실무에서 자주 사용되는 Docker 옵션들 학습
- 컨테이너 디버깅과 문제 해결 기법 습득

## 📚 세션 구성

### [Session 1: Docker CLI 기초](./session_01.md) (50분)
- Docker CLI 구조와 명령어 체계
- 도움말 시스템 활용법
- 기본 명령어 패턴과 옵션 구조
- **실습**: CLI 탐색과 기본 명령어 실행

### [Session 2: 이미지 관리 명령어](./session_02.md) (50분)
- docker pull, push, images 명령어
- 이미지 검색과 태그 관리
- 이미지 삭제와 정리
- **실습**: 다양한 이미지 다운로드와 관리

### [Session 3: 컨테이너 생성과 실행](./session_03.md) (50분)
- docker run의 다양한 옵션들
- 포그라운드 vs 백그라운드 실행
- 컨테이너 이름 지정과 관리
- **실습**: 웹 서버 컨테이너 실행

### [Session 4: 컨테이너 상태 관리](./session_04.md) (50분)
- docker ps, start, stop, restart 명령어
- 컨테이너 일시 중지와 재개
- 컨테이너 삭제와 정리
- **실습**: 컨테이너 라이프사이클 관리

### [Session 5: 포트와 네트워크](./session_05.md) (50분)
- 포트 매핑과 포워딩
- 네트워크 모드 이해
- 컨테이너 간 통신
- **실습**: 웹 애플리케이션 포트 매핑

### [Session 6: 볼륨과 데이터 관리](./session_06.md) (50분)
- 볼륨 마운트와 바인드 마운트
- 데이터 영속성 관리
- 컨테이너 간 데이터 공유
- **실습**: 데이터베이스 컨테이너 데이터 보존

### [Session 7: 컨테이너 디버깅](./session_07.md) (50분)
- docker exec으로 컨테이너 접속
- 로그 확인과 모니터링
- 컨테이너 내부 파일 시스템 탐색
- **실습**: 문제 상황 진단과 해결

### [Session 8: 종합 실습 및 정리](./session_08.md) (50분)
- 실무 시나리오 기반 종합 실습
- 명령어 조합과 워크플로우
- 문제 해결 실습
- **프로젝트**: 멀티 컨테이너 애플리케이션 구성

## 🛠 실습 환경
- **Docker Desktop**: 최신 버전 설치 필수
- **터미널**: Windows PowerShell, macOS Terminal, Linux Shell
- **텍스트 에디터**: VS Code 권장
- **브라우저**: 웹 애플리케이션 테스트용

## 📋 사전 준비사항
- [ ] Docker Desktop 정상 동작 확인
- [ ] 기본 터미널 명령어 숙지 (ls, cd, pwd 등)
- [ ] 인터넷 연결 상태 확인 (이미지 다운로드용)
- [ ] 디스크 여유 공간 5GB 이상 확보

## 🎯 학습 성과
이 날의 학습을 완료하면 다음을 할 수 있게 됩니다:
- Docker CLI를 자유자재로 사용하여 컨테이너 관리
- 이미지 다운로드부터 컨테이너 실행까지 전체 워크플로우 수행
- 포트 매핑과 볼륨 마운트를 활용한 실용적인 컨테이너 구성
- 컨테이너 문제 상황 진단과 해결
- 실무에서 바로 활용 가능한 Docker 운영 능력

## 📚 참고 자료
- [Docker CLI Reference](https://docs.docker.com/engine/reference/commandline/cli/)
- [Docker Run Reference](https://docs.docker.com/engine/reference/run/)
- [Docker Best Practices](https://docs.docker.com/develop/best-practices/)
- [Docker Networking](https://docs.docker.com/network/)
- [Docker Volumes](https://docs.docker.com/storage/volumes/)

---
**다음**: [Session 1: Docker CLI 기초](./session_01.md)