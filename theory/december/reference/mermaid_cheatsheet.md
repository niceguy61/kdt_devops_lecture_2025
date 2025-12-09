# Mermaid 치트시트

## 개요

이 문서는 Mermaid 다이어그램 작성을 위한 빠른 참조 가이드입니다. 가장 자주 사용하는 문법과 패턴을 정리했습니다.

---

## 순서도 (Flowchart)

### 기본 문법

```mermaid
flowchart TD
    Start[시작] --> Process[프로세스]
    Process --> Decision{의사결정}
    Decision -->|Yes| End1[종료 1]
    Decision -->|No| End2[종료 2]
```

### 노드 타입

| 문법 | 모양 | 용도 |
|------|------|------|
| `[텍스트]` | 직사각형 | 프로세스, 작업 |
| `([텍스트])` | 둥근 직사각형 | 시작/종료 |
| `{텍스트}` | 마름모 | 의사결정 |
| `((텍스트))` | 원 | 연결점 |
| `[(텍스트)]` | 원통 | 데이터베이스 |
| `[/텍스트/]` | 평행사변형 | 입력/출력 |

### 연결선 스타일

| 문법 | 모양 | 용도 |
|------|------|------|
| `-->` | 실선 화살표 | 일반 흐름 |
| `-.->` | 점선 화살표 | 선택적 흐름 |
| `==>` | 굵은 화살표 | 강조 흐름 |
| `--텍스트-->` | 레이블 있는 화살표 | 조건 표시 |
| `---|텍스트|` | 레이블 있는 선 | 관계 표시 |

### 방향 지정

```
flowchart TD  %% Top to Down (위에서 아래)
flowchart LR  %% Left to Right (왼쪽에서 오른쪽)
flowchart RL  %% Right to Left (오른쪽에서 왼쪽)
flowchart BT  %% Bottom to Top (아래에서 위)
```

### 일반적인 패턴

#### 순차 프로세스
```mermaid
flowchart LR
    A[단계 1] --> B[단계 2] --> C[단계 3]
```

#### 조건부 분기
```mermaid
flowchart TD
    A[시작] --> B{조건}
    B -->|참| C[작업 A]
    B -->|거짓| D[작업 B]
    C --> E[종료]
    D --> E
```

#### 병렬 처리
```mermaid
flowchart TD
    A[시작] --> B[작업 1]
    A --> C[작업 2]
    A --> D[작업 3]
    B --> E[통합]
    C --> E
    D --> E
```

---

## 시퀀스 다이어그램 (Sequence Diagram)

### 기본 문법

```mermaid
sequenceDiagram
    participant A as 사용자
    participant B as 서버
    participant C as 데이터베이스
    
    A->>B: 요청
    B->>C: 쿼리
    C-->>B: 결과
    B-->>A: 응답
```

### 화살표 타입

| 문법 | 모양 | 용도 |
|------|------|------|
| `->>` | 실선 화살표 | 동기 메시지 |
| `-->>` | 점선 화살표 | 응답 메시지 |
| `-x` | X 끝 | 비동기 메시지 |
| `-)` | 열린 화살표 | 비동기 응답 |

### 활성화 박스

```mermaid
sequenceDiagram
    A->>+B: 요청
    B->>+C: 쿼리
    C-->>-B: 결과
    B-->>-A: 응답
```

### 노트 추가

```mermaid
sequenceDiagram
    A->>B: 메시지
    Note right of B: 이것은 노트입니다
    Note over A,B: 여러 참여자에 걸친 노트
```

### 루프와 조건

```mermaid
sequenceDiagram
    loop 매일
        A->>B: 체크
    end
    
    alt 성공
        B->>A: 성공 응답
    else 실패
        B->>A: 에러 응답
    end
```

---

## 아키텍처 다이어그램

### 기본 구조

```mermaid
graph TB
    subgraph "VPC"
        subgraph "Public Subnet"
            ALB[Application Load Balancer]
        end
        subgraph "Private Subnet"
            EC2[EC2 Instances]
            RDS[(RDS Database)]
        end
    end
    
    Internet((Internet)) --> ALB
    ALB --> EC2
    EC2 --> RDS
```

### 서브그래프 (그룹화)

```mermaid
graph LR
    subgraph "Frontend"
        A[React App]
    end
    subgraph "Backend"
        B[API Server]
        C[Worker]
    end
    subgraph "Data"
        D[(Database)]
    end
    
    A --> B
    B --> C
    B --> D
    C --> D
```

---

## 스타일링

### 노드 스타일

```mermaid
flowchart LR
    A[기본]
    B[강조]
    C[경고]
    
    style B fill:#bbf,stroke:#333,stroke-width:4px
    style C fill:#f9f,stroke:#333,stroke-width:2px,stroke-dasharray: 5 5
```

### 클래스 정의

```mermaid
flowchart TD
    A[노드 1]:::important
    B[노드 2]:::warning
    
    classDef important fill:#bbf,stroke:#333,stroke-width:4px
    classDef warning fill:#f96,stroke:#333,stroke-width:2px
```

---

## 실전 팁

### 1. 가독성 향상
- 노드 ID는 짧게, 레이블은 명확하게
- 복잡한 다이어그램은 서브그래프로 분리
- 일관된 방향 사용 (보통 TD 또는 LR)

### 2. 성능 최적화
- 너무 많은 노드는 피하기 (20-30개 이하 권장)
- 복잡한 다이어그램은 여러 개로 분리

### 3. 협업 팁
- 의미 있는 노드 ID 사용
- 주석으로 설명 추가
- 버전 관리 시스템에 코드 저장

---

## 일반적인 패턴

### CI/CD 파이프라인

```mermaid
flowchart LR
    A([코드 커밋]) --> B[빌드]
    B --> C[테스트]
    C --> D{테스트 통과?}
    D -->|Yes| E[배포]
    D -->|No| F[알림]
    E --> G([완료])
    F --> G
```

### 마이크로서비스 아키텍처

```mermaid
graph TB
    subgraph "클라이언트"
        Web[웹 앱]
        Mobile[모바일 앱]
    end
    
    subgraph "API Gateway"
        Gateway[API Gateway]
    end
    
    subgraph "서비스"
        Auth[인증 서비스]
        User[사용자 서비스]
        Order[주문 서비스]
    end
    
    subgraph "데이터"
        DB1[(Auth DB)]
        DB2[(User DB)]
        DB3[(Order DB)]
    end
    
    Web --> Gateway
    Mobile --> Gateway
    Gateway --> Auth
    Gateway --> User
    Gateway --> Order
    Auth --> DB1
    User --> DB2
    Order --> DB3
```

### 사용자 인증 플로우

```mermaid
flowchart TD
    Start([로그인 시도]) --> Email{이메일 유효?}
    Email -->|No| Error1[에러: 잘못된 형식]
    Email -->|Yes| UserExists{사용자 존재?}
    UserExists -->|No| Error2[에러: 사용자 없음]
    UserExists -->|Yes| Password{비밀번호 일치?}
    Password -->|No| Error3[에러: 잘못된 비밀번호]
    Password -->|Yes| TwoFA{2FA 활성화?}
    TwoFA -->|No| Success[세션 생성]
    TwoFA -->|Yes| Code{코드 유효?}
    Code -->|No| Error4[에러: 잘못된 코드]
    Code -->|Yes| Success
    Success --> End([로그인 완료])
    Error1 --> End
    Error2 --> End
    Error3 --> End
    Error4 --> End
```

---

## 추가 리소스

- **공식 문서**: https://mermaid.js.org/
- **라이브 에디터**: https://mermaid.live/
- **GitHub 지원**: GitHub 마크다운에서 기본 지원

---

## 빠른 시작 템플릿

### 간단한 순서도
```
flowchart TD
    Start([시작]) --> Process[프로세스]
    Process --> End([종료])
```

### 간단한 시퀀스
```
sequenceDiagram
    A->>B: 요청
    B-->>A: 응답
```

### 간단한 아키텍처
```
graph LR
    Client[클라이언트] --> Server[서버]
    Server --> DB[(데이터베이스)]
```

이 치트시트를 참고하여 빠르게 Mermaid 다이어그램을 작성하세요!
