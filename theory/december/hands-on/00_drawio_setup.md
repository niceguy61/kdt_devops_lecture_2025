# Draw.io 설정 가이드

## 목표

Draw.io를 설정하고 기본 사용법을 익혀 실습 과제를 수행할 준비를 합니다.

## 1. Draw.io 접속

### 웹 버전 (권장)
- URL: https://app.diagrams.net
- 브라우저에서 바로 사용 가능
- 별도 설치 불필요
- 파일 저장 위치 선택 가능 (로컬, Google Drive, OneDrive 등)

### 데스크톱 버전 (선택사항)
- 다운로드: https://github.com/jgraph/drawio-desktop/releases
- 오프라인 작업 가능
- 더 빠른 성능

**실습에서는 웹 버전을 사용합니다.**

## 2. 첫 다이어그램 만들기

1. https://app.diagrams.net 접속
2. "Create New Diagram" 클릭
3. 저장 위치 선택 (Device 권장)
4. 템플릿 선택 화면에서 "Blank Diagram" 선택
5. 파일명 입력 후 "Create" 클릭

## 3. AWS 라이브러리 추가

AWS 아키텍처 다이어그램을 그리려면 AWS 아이콘 라이브러리를 추가해야 합니다.

### 단계별 가이드

1. 왼쪽 패널 하단의 **"More Shapes..."** 클릭
2. 검색창에 "AWS" 입력
3. 다음 라이브러리 체크:
   - **AWS 19** (최신 AWS 아이콘)
   - **AWS Architecture 2021** (공식 아키텍처 아이콘)
4. "Apply" 클릭

### 자주 사용하는 AWS 아이콘

라이브러리 추가 후 왼쪽 패널에서 다음 아이콘을 찾을 수 있습니다:

**네트워킹**
- VPC
- Subnet
- Internet Gateway
- NAT Gateway
- Route 53

**컴퓨팅**
- EC2
- Lambda
- Auto Scaling
- Elastic Load Balancing (ALB, NLB)

**스토리지**
- S3
- EBS
- EFS

**데이터베이스**
- RDS
- DynamoDB
- ElastiCache

**컨테이너**
- ECS
- EKS
- ECR

## 4. 기본 조작법

### 도형 추가
- 왼쪽 패널에서 도형을 드래그하여 캔버스에 배치
- 또는 도형을 더블클릭하여 자동 배치

### 연결선 추가
1. 도형 위에 마우스를 올리면 파란색 화살표 표시
2. 화살표를 클릭하고 드래그하여 다른 도형에 연결
3. 또는 도형을 선택하고 Ctrl 키를 누른 채 다른 도형 클릭

### 텍스트 편집
- 도형을 더블클릭하여 텍스트 입력/수정
- 도형 외부를 클릭하여 편집 완료

### 도형 크기 조정
- 도형을 선택하면 모서리에 핸들 표시
- 핸들을 드래그하여 크기 조정
- Shift 키를 누른 채 드래그하면 비율 유지

### 도형 이동
- 도형을 클릭하고 드래그하여 이동
- 여러 도형 선택: Ctrl 키를 누른 채 클릭

### 정렬 및 배치
- 상단 메뉴의 "Arrange" 사용
- 정렬: Align Left, Center, Right, Top, Middle, Bottom
- 분산: Distribute Horizontally, Vertically
- 레이어: Bring to Front, Send to Back

## 5. 필수 단축키

### 기본 조작
- **Ctrl + C**: 복사
- **Ctrl + V**: 붙여넣기
- **Ctrl + D**: 복제 (선택한 도형을 바로 복제)
- **Ctrl + Z**: 실행 취소
- **Ctrl + Y**: 다시 실행
- **Delete**: 삭제

### 그룹화 및 정렬
- **Ctrl + G**: 그룹화
- **Ctrl + Shift + G**: 그룹 해제
- **Ctrl + Shift + F**: 맨 앞으로 가져오기
- **Ctrl + Shift + B**: 맨 뒤로 보내기

### 보기
- **Ctrl + +**: 확대
- **Ctrl + -**: 축소
- **Ctrl + 0**: 100% 크기로
- **Ctrl + Shift + F**: 페이지에 맞춤

### 편집
- **F2**: 텍스트 편집 모드
- **Esc**: 선택 해제

## 6. 스타일 적용

### 색상 변경
1. 도형 선택
2. 오른쪽 패널의 "Style" 탭 사용
3. Fill: 채우기 색상
4. Line: 테두리 색상

### 스타일 복사
1. 스타일을 복사할 도형 선택
2. **Ctrl + Shift + C**: 스타일 복사
3. 적용할 도형 선택
4. **Ctrl + Shift + V**: 스타일 붙여넣기

### 선 스타일
- 연결선 선택
- 오른쪽 패널에서 선 스타일 변경:
  - Solid (실선)
  - Dashed (점선)
  - Dotted (점선)
- 화살표 스타일 변경 가능

## 7. 레이어 사용

복잡한 다이어그램에서 요소를 구조화하는 데 유용합니다.

1. 하단의 "Layers" 아이콘 클릭
2. "+" 버튼으로 새 레이어 추가
3. 레이어 이름 지정 (예: Background, Network, Services)
4. 레이어를 선택하여 활성화
5. 활성 레이어에 도형 추가

**팁**: 배경 요소(VPC, 서브넷)는 별도 레이어에 배치하면 관리가 쉽습니다.

## 8. 파일 저장 및 내보내기

### 저장
- **Ctrl + S**: 저장
- 자동 저장 기능 활성화 권장

### 내보내기 (제출용)
1. 상단 메뉴에서 **File > Export as > PNG** 선택
2. 설정:
   - **Zoom**: 100%
   - **Border Width**: 10px (여백)
   - **Transparent Background**: 체크 해제 (흰색 배경)
3. "Export" 클릭
4. 파일명 규칙: `이름_과제번호.png` (예: `홍길동_01.png`)

### PDF 내보내기 (선택사항)
- File > Export as > PDF
- 고해상도 출력 필요 시 사용

## 9. 유용한 팁

### 그리드 및 스냅
- View > Grid: 그리드 표시/숨김
- View > Snap to Grid: 그리드에 맞춰 정렬
- 정확한 배치에 유용

### 컨테이너 사용
- VPC나 서브넷 같은 경계를 표현할 때:
  1. 사각형 도형 추가
  2. 배경색 설정 (연한 색상)
  3. 테두리 스타일 설정
  4. 내부에 다른 도형 배치

### 텍스트 레이블
- 연결선에 레이블 추가:
  1. 연결선 더블클릭
  2. 텍스트 입력
  3. 레이블 위치 조정 가능

### 템플릿 활용
- 반복되는 패턴은 한 번 만들어서 복사
- 예: EC2 인스턴스 + 보안 그룹 조합

## 10. 일반적인 문제 해결

### 도형이 연결되지 않음
- 도형의 연결점(파란색 X)에 정확히 연결했는지 확인
- 연결선 끝을 도형 위로 드래그하면 자동으로 연결점 찾기

### 텍스트가 잘림
- 도형 크기를 늘리거나
- 텍스트 크기를 줄이거나
- Word Wrap 활성화 (오른쪽 패널 > Text 탭)

### 정렬이 안 맞음
- 여러 도형 선택 후 Arrange > Align 사용
- 그리드 스냅 활성화

### 파일이 저장되지 않음
- 브라우저 쿠키/캐시 확인
- 다른 저장 위치 시도 (Device, Google Drive 등)

## 다음 단계

이제 Draw.io 기본 사용법을 익혔습니다. 다음 실습 과제로 넘어가세요:

1. [실습 1: AWS 3계층 아키텍처](01_aws_3tier.md)
2. [실습 2: Kubernetes 배포](02_k8s_deployment.md)
3. [실습 3: CI/CD 파이프라인](03_cicd_pipeline.md)
4. [실습 4: 로직 플로우](04_logic_flow.md)

## 참고 자료

- [Draw.io 공식 문서](https://www.diagrams.net/doc/)
- [AWS 아이콘 가이드](../reference/aws_icons_guide.md)
- [Draw.io 단축키](../reference/drawio_shortcuts.md)
