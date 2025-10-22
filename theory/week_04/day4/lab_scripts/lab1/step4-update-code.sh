#!/bin/bash

# Week 4 Day 4 Lab 1: 코드 변경 및 재배포
# 설명: 애플리케이션 코드 변경 후 자동 재배포 테스트
# 사용법: cd cicd-lab && ../step4-update-code.sh

set -e

echo "=== 코드 업데이트 및 재배포 시작 ==="

# 현재 디렉토리 확인
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ docker-compose.yml을 찾을 수 없습니다."
    echo "cicd-lab 디렉토리에서 실행하세요: cd cicd-lab"
    exit 1
fi

# 1. 버전 업데이트
echo "1/5 버전 업데이트 중..."
sed -i 's/Version 1.0.0/Version 1.1.0/g' frontend/src/App.js
sed -i "s/version: '1.0.0'/version: '1.1.0'/g" backend/src/index.js
sed -i 's/"1.0.0"/"1.1.0"/g' backend/src/index.test.js

echo "✅ 버전 1.0.0 → 1.1.0 업데이트 완료"

# 2. 새로운 기능 추가 (Backend)
echo "2/5 Backend에 새 기능 추가 중..."
cat >> backend/src/index.js << 'EOF'

// Get user by ID (새로운 기능)
app.get('/api/users/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('SELECT * FROM users WHERE id = $1', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ error: err.message });
  }
});
EOF

echo "✅ Backend에 GET /api/users/:id 엔드포인트 추가"

# 3. 재빌드 및 재배포
echo "3/5 재빌드 및 재배포 중..."
docker-compose build
docker-compose up -d

# 4. 헬스체크
echo "4/5 헬스체크 중..."
sleep 10
HEALTH=$(curl -s http://localhost/api/health)
echo "Response: $HEALTH"

if echo "$HEALTH" | grep -q "1.1.0"; then
    echo "✅ 버전 업데이트 확인 완료"
else
    echo "❌ 버전 업데이트 실패"
    exit 1
fi

# 5. 새 기능 테스트
echo "5/5 새 기능 테스트 중..."
USER=$(curl -s http://localhost/api/users/1)
echo "Response: $USER"

if echo "$USER" | grep -q "Alice"; then
    echo "✅ 새 기능 동작 확인"
else
    echo "❌ 새 기능 테스트 실패"
    exit 1
fi

echo ""
echo "=== 코드 업데이트 및 재배포 완료 ==="
echo ""
echo "변경 사항:"
echo "- 버전: 1.0.0 → 1.1.0"
echo "- 새 기능: GET /api/users/:id 엔드포인트 추가"
echo ""
echo "테스트:"
echo "- Health Check: curl http://localhost/api/health"
echo "- New Endpoint: curl http://localhost/api/users/1"
