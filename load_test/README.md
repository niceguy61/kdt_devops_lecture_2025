# Load Test Script

## 설치
```bash
pip install pyyaml requests
```

## 빠른 실행
```bash
./run.sh
```

## 설정
`requests.yaml` 파일에서 설정:
```yaml
config:
  workers: 100      # 동시 요청 수
  iterations: 5000  # 반복 횟수
  token: "your-token"

requests:
  - url: https://api.example.com/endpoint
    method: GET
  - url: https://api.example.com/create
    method: POST
    body:
      key: value
```

## 프리셋 (presets.yaml)
- **light**: workers=5, iterations=100
- **medium**: workers=20, iterations=500
- **heavy**: workers=50, iterations=1000
- **extreme**: workers=100, iterations=5000

## 최적화
- ✅ Keep-Alive 연결 재사용
- ✅ 세션 풀링
- ✅ ulimit 자동 설정
- ✅ 실시간 진행률 표시

## 결과
- 초당 요청 수 (RPS)
- 최소/평균/최대 응답 시간
- 성공/실패 통계
- 상태 코드 분포
