#!/bin/bash

# Week 4 Day 2 Hands-on 1: JWT 인증 설정
# 사용법: ./configure-jwt-auth.sh

echo "=== JWT 인증 설정 시작 ==="

# 1. JWT 인증 정책 설정
echo "1. JWT 인증 정책 설정 중..."
kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: RequestAuthentication
metadata:
  name: jwt-auth
spec:
  selector:
    matchLabels:
      app: user-service
  jwtRules:
  - issuer: "testing@secure.istio.io"
    jwksUri: "https://raw.githubusercontent.com/istio/istio/release-1.20/security/tools/jwt/samples/jwks.json"
EOF

# 2. JWT 기반 인가 정책
echo "2. JWT 기반 인가 정책 설정 중..."
kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: require-jwt
spec:
  selector:
    matchLabels:
      app: user-service
  rules:
  - from:
    - source:
        requestPrincipals: ["testing@secure.istio.io/testing@secure.istio.io"]
EOF

# 3. 테스트용 JWT 토큰 생성
echo "3. 테스트용 JWT 토큰 준비 중..."
cat > jwt-token.txt << 'EOF'
eyJhbGciOiJSUzI1NiIsImtpZCI6IkRIRmJwb0lVcXJZOHQyenBBMnFYZkNtcjVWTzVaRXI0UnpIVV8tZW52dlEiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjQ2ODU5ODk3MDAsImZvbyI6ImJhciIsImlhdCI6MTUzMjM4OTcwMCwiaXNzIjoidGVzdGluZ0BzZWN1cmUuaXN0aW8uaW8iLCJzdWIiOiJ0ZXN0aW5nQHNlY3VyZS5pc3Rpby5pbyJ9.CfNnxWP2tcnR9q0vxyxweaF3ovQYHYZl82hAUsn21bwQd9zP7c-LS9qd_vpdLG4Tn1A15NxfCjp5f7QNBUo-KC9PJqYpgGbaXhaGx7bEdFWjcwv3nZzvc7M__ZpaCERdwU7igUmJqYGBYQ51vr2njU9ZimyKkfDe3axcyiBZde7G6dabliUosJvvKOPcKIWPccCgefSj_GNfwIip3-SsFdlR7BtbVUcqR-yv-XOxJ3Ry4c5p_-jpmHcMiKFyZnPczOavs2uSTyGiuFBfABRHZ9GhizOsgEGGCCgtfMpHjgJqiCOHdAhcHuWw
EOF

# 4. JWT 테스트 스크립트 생성
echo "4. JWT 테스트 스크립트 생성 중..."
cat > test-jwt.sh << 'EOF'
#!/bin/bash

echo "=== JWT 인증 테스트 ==="

# 포트 포워딩 시작
kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80 &
PF_PID=$!
sleep 5

TOKEN=$(cat jwt-token.txt)

echo "1. JWT 없이 요청 (실패해야 함):"
response=$(curl -s -w "%{http_code}" -H "Host: api.example.com" http://localhost:8080/users -o /dev/null)
echo "응답 코드: $response"
if [ "$response" = "403" ]; then
    echo "✅ JWT 없는 요청 차단됨 (정상)"
else
    echo "❌ JWT 없는 요청이 허용됨 (비정상)"
fi

echo ""
echo "2. 유효한 JWT와 함께 요청 (성공해야 함):"
response=$(curl -s -w "%{http_code}" -H "Host: api.example.com" -H "Authorization: Bearer $TOKEN" http://localhost:8080/users -o /dev/null)
echo "응답 코드: $response"
if [ "$response" = "200" ]; then
    echo "✅ 유효한 JWT 요청 허용됨 (정상)"
else
    echo "❌ 유효한 JWT 요청이 차단됨 (비정상)"
fi

echo ""
echo "3. 잘못된 JWT와 함께 요청 (실패해야 함):"
response=$(curl -s -w "%{http_code}" -H "Host: api.example.com" -H "Authorization: Bearer invalid-token" http://localhost:8080/users -o /dev/null)
echo "응답 코드: $response"
if [ "$response" = "401" ] || [ "$response" = "403" ]; then
    echo "✅ 잘못된 JWT 요청 차단됨 (정상)"
else
    echo "❌ 잘못된 JWT 요청이 허용됨 (비정상)"
fi

# 정리
kill $PF_PID 2>/dev/null
echo ""
echo "JWT 인증 테스트 완료"
EOF

chmod +x test-jwt.sh

# 5. 설정 확인
echo "5. 설정 확인 중..."
sleep 10

echo "RequestAuthentication 확인:"
kubectl get requestauthentication jwt-auth -o yaml | grep -A 5 "jwtRules"

echo ""
echo "AuthorizationPolicy 확인:"
kubectl get authorizationpolicy require-jwt -o yaml | grep -A 10 "rules"

echo ""
echo "=== JWT 인증 설정 완료 ==="
echo ""
echo "설정된 JWT 인증:"
echo "- Issuer: testing@secure.istio.io"
echo "- JWKS URI: Istio 공식 테스트 키"
echo "- 적용 대상: user-service"
echo ""
echo "테스트 실행:"
echo "./test-jwt.sh"
echo ""
echo "JWT 토큰 파일: jwt-token.txt"
echo "다음 단계: ./setup-advanced-metrics.sh"
