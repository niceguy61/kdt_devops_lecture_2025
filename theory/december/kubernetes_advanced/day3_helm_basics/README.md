# Day 3: Helm 패키지 관리

## 🎯 학습 목표
- Helm 아키텍처 및 개념 이해
- Chart 구조 및 템플릿 시스템 학습
- Values 파일을 통한 설정 관리
- 실제 Chart 생성 및 배포

## ⏰ 세션 구성 (총 2시간)

### Session 1: Helm 기초 및 설치 (50분)
- **이론** (20분): Helm 개념, Chart 구조
- **실습** (30분): Helm 설치, 기본 Chart 생성

### Session 2: Chart 커스터마이징 및 배포 (50분)
- **실습** (40분): Values 파일 수정, 템플릿 커스터마이징
- **정리** (10분): 체크포인트 확인

## 📁 세션별 자료

- [Session 1: Helm 기초 및 설치](./session1.md)
- [Session 2: Chart 커스터마이징 및 배포](./session2.md)
- [실습 예제 모음](./examples.md)

## 🛠️ 제공 파일

- `charts/` - 예제 Helm Chart들
- `values/` - 다양한 환경별 Values 파일들
- `scripts/` - Helm 관련 유틸리티 스크립트들

## 🚨 트러블슈팅

### 자주 발생하는 문제들

#### 1. Helm 설치 문제
```bash
# 에러: helm: command not found
# 해결: Helm 바이너리 설치
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

#### 2. Chart 템플릿 오류
```bash
# 에러: YAML parse error
# 해결: 템플릿 문법 확인
helm template my-chart ./my-chart --debug
```

#### 3. Values 파일 문제
```bash
# 에러: unknown field in values
# 해결: Values 스키마 확인
helm show values my-chart
```

## 📝 과제 및 다음 준비사항

### 오늘 완료해야 할 것
- Helm Chart 생성 및 배포 경험
- Values 파일을 통한 설정 관리 이해
- 템플릿 시스템 기본 사용법 숙지

### 다음 세션 준비
- 컨테이너 이미지 빌드 및 레지스트리 개념
- ECR (Elastic Container Registry) 기본 지식

## 📚 참고 자료
- [Helm 공식 문서](https://helm.sh/docs/)
- [Chart 개발 가이드](https://helm.sh/docs/chart_template_guide/)
- [Helm 모범 사례](https://helm.sh/docs/chart_best_practices/)
