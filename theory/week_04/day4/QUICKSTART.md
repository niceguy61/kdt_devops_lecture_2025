# Week 4 Day 4 빠른 시작 가이드

## 🚀 5분 안에 시작하기

### 📋 사전 준비
```bash
# 1. 필수 도구 확인
git --version
docker --version
docker-compose --version

# 2. GitHub 계정 준비
# - https://github.com 가입
# - Personal Access Token 생성
#   https://github.com/settings/tokens
#   Scopes: repo 전체 선택
```

### ⚡ 빠른 실행
```bash
# 1. 실습 디렉토리로 이동
cd theory/week_04/day4/lab_scripts/lab1

# 2. GitHub 저장소 설정 (15분)
./step0-github-setup.sh

# 3. 로컬 환경 실행 (10분)
./step1-run-local.sh

# 4. API 테스트 (10분)
./step2-test-api.sh

# 5. 코드 업데이트 (10분)
./step3-update-code.sh

# 6. CI/CD 자동화 (15분)
./step4-push-cicd.sh

# 7. 전체 검증 (10분)
./step5-test-cicd.sh

# 8. 정리
./cleanup.sh
```

## 📚 학습 순서

### 오전 - 이론 (2.5시간)
```
09:00-09:50  Session 1: GitOps 철학과 ArgoCD
10:00-10:50  Session 2: 고급 배포 전략
11:00-11:50  Session 3: 클라우드 네이티브 CI/CD
```

### 오후 - 실습 (2.5시간)
```
12:00-12:50  Lab 1: Docker Compose CI/CD 파이프라인
```

## 🎯 핵심 학습 포인트

### Session 1 핵심
- ✅ GitOps 4대 원칙
- ✅ ArgoCD 아키텍처
- ✅ Git 기반 배포 워크플로우

### Session 2 핵심
- ✅ 카나리 배포 (점진적 트래픽 증가)
- ✅ 블루-그린 배포 (즉시 전환)
- ✅ 롤링 배포 (순차적 업데이트)

### Session 3 핵심
- ✅ Tekton (Kubernetes 네이티브 CI/CD)
- ✅ Flux (GitOps 도구)
- ✅ GitHub Actions (관리형 CI/CD)

### Lab 1 핵심
- ✅ 3-Tier 애플리케이션 구축
- ✅ GitHub Actions 워크플로우
- ✅ 자동 빌드/테스트/배포

## 🔧 트러블슈팅

### 문제 1: Docker 실행 오류
```bash
# 해결: Docker 데몬 시작
sudo systemctl start docker

# 또는 Docker Desktop 실행 (Windows/Mac)
```

### 문제 2: 포트 충돌
```bash
# 해결: 기존 컨테이너 정리
docker-compose down
docker ps -a
docker rm -f $(docker ps -aq)
```

### 문제 3: GitHub 인증 실패
```bash
# 해결: Personal Access Token 재생성
# 1. https://github.com/settings/tokens
# 2. "Generate new token (classic)"
# 3. Scopes: repo 전체 선택
# 4. Token 복사 후 스크립트 재실행
```

### 문제 4: 스크립트 실행 권한 없음
```bash
# 해결: 실행 권한 부여
chmod +x *.sh
```

## 📖 추가 학습 자료

### 공식 문서
- **ArgoCD**: https://argo-cd.readthedocs.io/
- **GitHub Actions**: https://docs.github.com/actions
- **Docker Compose**: https://docs.docker.com/compose/

### 추천 학습 경로
1. **기초**: Docker Compose 기본 사용법
2. **중급**: GitHub Actions 워크플로우 작성
3. **고급**: ArgoCD를 활용한 GitOps 구현

## 💡 실습 팁

### 효율적인 학습
1. **이론 먼저**: 세션 자료를 먼저 읽고 개념 이해
2. **스크립트 실행**: 자동화 스크립트로 빠르게 환경 구축
3. **수동 실행**: 핵심 명령어를 직접 실행하며 개념 학습
4. **FAQ 활용**: 궁금한 점은 FAQ에서 먼저 확인

### 팀 협업
1. **페어 프로그래밍**: 2명씩 짝을 지어 실습
2. **역할 교대**: Driver/Navigator 역할 교대
3. **결과 공유**: 팀별 결과물 발표 및 공유
4. **상호 학습**: 어려운 부분 서로 도움

## ✅ 체크리스트

### 이론 학습
- [ ] Session 1 완료 (GitOps & ArgoCD)
- [ ] Session 2 완료 (배포 전략)
- [ ] Session 3 완료 (CI/CD 도구)
- [ ] FAQ 10개씩 복습

### 실습 완료
- [ ] Step 0: GitHub 저장소 설정
- [ ] Step 1: 로컬 환경 실행
- [ ] Step 2: API 테스트
- [ ] Step 3: 코드 업데이트
- [ ] Step 4: CI/CD 자동화
- [ ] Step 5: 전체 검증

### 이해도 확인
- [ ] GitOps 4대 원칙 설명 가능
- [ ] 배포 전략 3가지 비교 가능
- [ ] CI/CD 도구 선택 기준 이해
- [ ] GitHub Actions 워크플로우 작성 가능

## 🎓 다음 단계

### Week 4 Day 5 준비
- FinOps와 클라우드 비용 최적화
- CI/CD 파이프라인 비용 효율화
- 리소스 최적화 전략

### 실무 프로젝트 적용
- GitOps 기반 배포 자동화 도입
- 멀티 환경 배포 전략 수립
- 고급 배포 패턴 적용

## 📞 도움 받기

### 질문하기
1. **FAQ 확인**: 각 세션의 FAQ 섹션
2. **팀원 도움**: 페어 프로그래밍 활용
3. **강사 질문**: 이해 안 되는 부분 즉시 질문

### 추가 자료
- **GitHub**: 실습 코드 저장소
- **문서**: 각 세션 마크다운 파일
- **스크립트**: lab_scripts/lab1/ 디렉토리

---

<div align="center">

**🚀 빠른 시작** • **📚 체계적 학습** • **🛠️ 실전 실습** • **💡 효율적 학습**

*Week 4 Day 4 - GitOps 마스터 되기*

</div>
