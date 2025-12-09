# 다이어그램 작성 워크샵 (2시간)

## 워크샵 개요

이 워크샵은 초급 DevOps 엔지니어가 **Mermaid**와 **Draw.io**를 사용하여 아키텍처 다이어그램을 작성하는 실용적인 기술을 습득하도록 설계되었습니다. 다이어그램을 통해 시스템을 빠르게 이해하고, 실제 인프라 구축을 위한 기초 자료를 만드는 방법을 학습합니다.

## 학습 목표

이 워크샵을 완료하면 다음을 할 수 있습니다:
- ✅ 다이어그램의 중요성과 기본 원칙 이해
- ✅ Mermaid로 간단한 다이어그램 작성
- ✅ Draw.io로 AWS 아키텍처 다이어그램 작성
- ✅ Draw.io로 Kubernetes 배포 다이어그램 작성
- ✅ Draw.io로 CI/CD 파이프라인 다이어그램 작성
- ✅ Draw.io로 로직 플로우 다이어그램 작성

## 워크샵 일정

### 📚 1부: 강의 (50분)

| 시간 | 주제 | 내용 |
|------|------|------|
| 10분 | [다이어그램 기초](lecture/01_diagram_basics.md) | 다이어그램의 중요성, 유형, 품질 원칙 |
| 10분 | [Mermaid 소개](lecture/02_mermaid_intro.md) | Mermaid 기본 문법 및 예제 |
| 10분 | [AWS 다이어그램](lecture/03_aws_diagrams.md) | AWS 아키텍처 패턴 및 표현 기법 |
| 10분 | [Kubernetes 다이어그램](lecture/04_kubernetes_diagrams.md) | Kubernetes 리소스 및 배포 패턴 |
| 10분 | [CI/CD & 로직 플로우](lecture/05_cicd_logic_flow.md) | 파이프라인 및 로직 플로우 작성법 |

### ☕ 휴식 (10분)

### 💻 2부: 실습 (60분)

| 시간 | 과제 | 내용 |
|------|------|------|
| 10분 | [Draw.io 설정](hands-on/00_drawio_setup.md) | Draw.io 기본 사용법 및 AWS 라이브러리 추가 |
| 15분 | [실습 1: AWS 3계층](hands-on/01_aws_3tier.md) | VPC, ALB, EC2, RDS를 포함한 웹 애플리케이션 |
| 15분 | [실습 2: K8s 배포](hands-on/02_k8s_deployment.md) | Ingress, Service, Deployment를 포함한 배포 |
| 10분 | [실습 3: CI/CD 파이프라인](hands-on/03_cicd_pipeline.md) | 빌드-테스트-배포 파이프라인 |
| 10분 | [실습 4: 로직 플로우](hands-on/04_logic_flow.md) | 사용자 인증 로직 플로우 |

## 준비물

### 필수
- 💻 노트북 (Windows, Mac, Linux)
- 🌐 웹 브라우저 (Chrome, Firefox, Edge 등)
- 📱 Discord 계정 (과제 제출용)

### 권장
- Draw.io 데스크톱 앱 (선택사항, 웹 버전으로도 충분)
- 기본적인 AWS 및 Kubernetes 지식

## 사전 요구사항

### 기술적 지식
- ✅ 기본적인 클라우드 개념 이해
- ✅ AWS 서비스 기본 지식 (EC2, VPC, RDS 등)
- ✅ Kubernetes 기본 개념 (Pod, Service, Deployment)
- ✅ CI/CD 파이프라인 기본 이해

### 도구 접근
- Draw.io 웹 버전: https://app.diagrams.net
- Mermaid Live Editor: https://mermaid.live (참고용)

## 콘텐츠 구조

```
theory/december/
├── README.md                           # 이 파일
├── lecture/                            # 강의 자료 (50분)
│   ├── 01_diagram_basics.md
│   ├── 02_mermaid_intro.md
│   ├── 03_aws_diagrams.md
│   ├── 04_kubernetes_diagrams.md
│   └── 05_cicd_logic_flow.md
├── hands-on/                           # 실습 과제 (60분)
│   ├── README.md
│   ├── 00_drawio_setup.md
│   ├── 01_aws_3tier.md
│   ├── 02_k8s_deployment.md
│   ├── 03_cicd_pipeline.md
│   └── 04_logic_flow.md
├── examples/                           # 예제 및 참고 자료
│   ├── mermaid/                        # Mermaid 코드
│   │   ├── aws_3tier.mmd
│   │   ├── k8s_deployment.mmd
│   │   ├── cicd_pipeline.mmd
│   │   └── logic_flow.mmd
│   └── images/                         # 렌더링된 다이어그램
│       ├── aws_3tier.png
│       ├── k8s_deployment.png
│       ├── cicd_pipeline.png
│       └── logic_flow.png
├── reference/                          # 참고 자료
│   ├── mermaid_cheatsheet.md
│   ├── drawio_shortcuts.md
│   └── aws_icons_guide.md
└── submission/                         # 제출 가이드
    └── guidelines.md
```

## 빠른 시작

### 1. 강의 자료 읽기
강의 시간에 따라 [lecture](lecture/) 디렉토리의 자료를 순서대로 읽으세요.

### 2. Draw.io 설정
실습 시작 전에 [Draw.io 설정 가이드](hands-on/00_drawio_setup.md)를 따라 환경을 준비하세요.

### 3. 실습 과제 수행
[hands-on](hands-on/) 디렉토리의 과제를 순서대로 완료하세요. 각 과제는:
- 📝 과제 설명 및 요구사항
- 📋 단계별 가이드
- ✅ 체크리스트
- 🖼️ 참고 예제

### 4. 과제 제출
완성된 다이어그램을 [제출 가이드](submission/guidelines.md)에 따라 Discord에 제출하세요.

## 실습 과제 목록

### 과제 1: AWS 3계층 아키텍처 (15분)
간단한 웹 애플리케이션을 위한 AWS 아키텍처를 작성합니다.
- VPC, 서브넷, Internet Gateway
- Application Load Balancer
- EC2 Auto Scaling Group
- RDS Multi-AZ
- S3

### 과제 2: Kubernetes 배포 (15분)
웹 애플리케이션의 Kubernetes 배포를 작성합니다.
- Namespace
- Ingress
- Frontend/Backend Service & Deployment
- ConfigMap & Secret

### 과제 3: CI/CD 파이프라인 (10분)
GitHub Actions를 사용한 CI/CD 파이프라인을 작성합니다.
- 빌드 → 테스트 → 보안 스캔
- 승인 게이트
- Dev/Prod 배포

### 과제 4: 로직 플로우 (10분)
사용자 로그인 프로세스의 로직 플로우를 작성합니다.
- 입력 검증
- 인증 확인
- 2FA 처리
- 세션 생성

## 참고 자료

### Mermaid
- [Mermaid 치트시트](reference/mermaid_cheatsheet.md) - 빠른 문법 참조
- [Mermaid 공식 문서](https://mermaid.js.org/)
- [Mermaid Live Editor](https://mermaid.live)

### Draw.io
- [Draw.io 단축키](reference/drawio_shortcuts.md) - 필수 단축키 및 팁
- [Draw.io 공식 사이트](https://www.diagrams.net/)

### AWS
- [AWS 아이콘 가이드](reference/aws_icons_guide.md) - 아이콘 사용법
- [AWS 아키텍처 센터](https://aws.amazon.com/architecture/)
- [AWS 아이콘 패키지](../../Asset-Package/) - 로컬 아이콘

### Kubernetes
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [Kubernetes 아키텍처](https://kubernetes.io/docs/concepts/architecture/)

## 평가 기준

각 실습 과제는 다음 기준으로 평가됩니다:

### 완전성 (40%)
- 모든 필수 구성 요소 포함
- 요구사항 충족

### 명확성 (30%)
- 레이블이 명확함
- 관계가 명시적으로 표현됨
- 데이터 흐름 방향이 명확함

### 일관성 (20%)
- 일관된 스타일 사용
- 일관된 명명 규칙
- 일관된 레이아웃

### 품질 (10%)
- 적절한 추상화 수준
- 혼잡하지 않음
- 전문적인 외관

## 팁 및 모범 사례

### ✅ 해야 할 것
- 모든 구성 요소에 명확한 레이블 추가
- 일관된 색상 및 스타일 사용
- 데이터 흐름 방향 표시
- 적절한 간격 유지
- 범례 추가 (필요시)

### ❌ 피해야 할 것
- 너무 많은 세부사항 포함
- 레이블 없는 구성 요소
- 불명확한 연결선
- 혼잡한 레이아웃
- 일관성 없는 스타일

## 문제 해결

### Draw.io 관련
- **AWS 아이콘이 안 보여요**: More Shapes → AWS Architecture 체크
- **정렬이 안 맞아요**: Arrange → Align 메뉴 사용
- **파일이 저장 안 돼요**: File → Export as → PNG 선택

### 일반적인 질문
- **시간이 부족해요**: 핵심 구성 요소에 집중하고 세부사항은 나중에
- **어떤 아이콘을 써야 하나요**: 예제 이미지 참고
- **다이어그램이 복잡해요**: 하위 다이어그램으로 분리 고려

## 추가 학습

워크샵 후 더 학습하고 싶다면:
- 📚 [주간 이론 자료](../) - DevOps 및 클라우드 네이티브 학습
- 🎨 [AWS 아이콘 패키지](../../Asset-Package/) - 공식 AWS 아이콘
- 💡 실제 프로젝트에 다이어그램 적용
- 🤝 팀원들과 다이어그램 리뷰 세션

## 피드백

워크샵에 대한 피드백은 언제든 환영합니다!
- 💬 Discord에서 질문 및 토론
- 📧 강사에게 직접 문의
- 🐛 개선 사항 제안

---

**준비되셨나요?** [강의 자료](lecture/01_diagram_basics.md)부터 시작하세요!

**질문이 있으신가요?** 강사 또는 동료 학생들에게 문의하세요.

**행운을 빕니다!** 🚀
