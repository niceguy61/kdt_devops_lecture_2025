# Week 2 Day 1 Session 4: LAMP 스택 Docker Compose 실습

<div align="center">

**🏗️ 고전 웹 스택** • **🐘 PHP + MySQL + Nginx**

*Docker Compose로 구축하는 완전한 웹 개발 환경*

</div>

---

## 🕘 세션 정보

**시간**: 13:00-16:00 (3시간)  
**목표**: LAMP 스택을 Docker Compose로 구축하고 실제 웹 애플리케이션 개발  
**방식**: 단계별 구축 + 컨테이너 접근 + 애플리케이션 수정

---

## 🎯 세션 목표

### 📚 학습 목표
- **LAMP 스택 구축**: Nginx + PHP + MySQL을 Docker Compose로 완전 구성
- **컨테이너 조작**: 실행 중인 컨테이너에 접근하여 파일 수정
- **실무 워크플로우**: 개발 환경에서의 실제 작업 흐름 체험
- **Compose 활용**: 오전에 배운 고급 기능들을 실제 프로젝트에 적용

### 🤝 협업 목표
- **팀 개발**: 각자 다른 기능을 개발하여 하나의 웹사이트 완성
- **환경 공유**: 동일한 Docker Compose 환경에서 협업 개발
- **문제 해결**: 컨테이너 관련 문제를 팀으로 해결
- **지식 공유**: 웹 개발 경험과 Docker 활용 노하우 공유

---

## 🚀 Phase 1: LAMP 스택 기본 구축 (60분)

### 📋 Phase 1 목표
**Nginx + PHP-FPM + MySQL 완전한 웹 환경 구축**

#### Step 1: 프로젝트 구조 생성 (15분)
```bash
# 프로젝트 디렉토리 생성
mkdir lamp-stack && cd lamp-stack

# 디렉토리 구조 생성
mkdir -p {nginx/conf,php/src,mysql/data,mysql/init}

# 기본 파일 생성
touch docker-compose.yml .env
```

**프로젝트 구조**:
```
lamp-stack/
├── docker-compose.yml
├── .env
├── nginx/
│   └── conf/
│       └── default.conf
├── php/
│   └── src/
│       ├── index.php
│       ├── info.php
│       └── db-test.php
└── mysql/
    ├── data/
    └── init/
        └── init.sql
```

#### Step 2: Docker Compose 파일 작성 (20분)
```yaml
# docker-compose.yml
version: '3.8'

services:
  # Nginx 웹서버
  nginx:
    image: nginx:alpine
    container_name: lamp-nginx
    ports:
      - "${NGINX_PORT:-80}:80"
    volumes:
      - ./nginx/conf/default.conf:/etc/nginx/conf.d/default.conf
      - ./php/src:/var/www/html
    depends_on:
      - php
    networks:
      - lamp-network
    restart: unless-stopped

  # PHP-FPM
  php:
    image: php:8.2-fpm-alpine
    container_name: lamp-php
    volumes:
      - ./php/src:/var/www/html
    networks:
      - lamp-network
    restart: unless-stopped
    environment:
      - PHP_INI_SCAN_DIR=/usr/local/etc/php/conf.d:/usr/local/etc/php/custom.d
    command: >
      sh -c "
        docker-php-ext-install mysqli pdo pdo_mysql &&
        php-fpm
      "

  # MySQL 데이터베이스
  mysql:
    image: mysql:8.0
    container_name: lamp-mysql
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD:-rootpass}
      MYSQL_DATABASE: ${MYSQL_DATABASE:-lampdb}
      MYSQL_USER: ${MYSQL_USER:-lampuser}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD:-lamppass}
    volumes:
      - mysql-data:/var/lib/mysql
      - ./mysql/init:/docker-entrypoint-initdb.d
    ports:
      - "${MYSQL_PORT:-3306}:3306"
    networks:
      - lamp-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 20s
      retries: 10

  # phpMyAdmin (관리 도구)
  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: lamp-phpmyadmin
    environment:
      PMA_HOST: mysql
      PMA_PORT: 3306
      PMA_USER: ${MYSQL_USER:-lampuser}
      PMA_PASSWORD: ${MYSQL_PASSWORD:-lamppass}
    ports:
      - "${PMA_PORT:-8080}:80"
    depends_on:
      mysql:
        condition: service_healthy
    networks:
      - lamp-network
    restart: unless-stopped

networks:
  lamp-network:
    driver: bridge

volumes:
  mysql-data:
```

#### Step 3: 환경 설정 파일 (10분)
```bash
# .env
# 포트 설정
NGINX_PORT=80
MYSQL_PORT=3306
PMA_PORT=8080

# MySQL 설정
MYSQL_ROOT_PASSWORD=rootpass123
MYSQL_DATABASE=lampdb
MYSQL_USER=lampuser
MYSQL_PASSWORD=lamppass123
```

#### Step 4: Nginx 설정 (15분)
```nginx
# nginx/conf/default.conf
server {
    listen 80;
    server_name localhost;
    root /var/www/html;
    index index.php index.html;

    # PHP 파일 처리
    location ~ \.php$ {
        fastcgi_pass php:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    # 정적 파일 처리
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # 보안 설정
    location ~ /\.ht {
        deny all;
    }

    # 에러 페이지
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
}
```

### ✅ Phase 1 체크포인트
- [ ] 프로젝트 구조 생성 완료
- [ ] Docker Compose 파일 작성 완료
- [ ] Nginx 설정 파일 구성 완료
- [ ] 환경 변수 설정 완료

---

## 🐘 Phase 2: PHP 애플리케이션 개발 (75분)

### 📋 Phase 2 목표
**실제 동작하는 웹 애플리케이션 개발**

#### Step 1: 기본 PHP 파일 생성 (20분)
```php
<?php
// php/src/index.php
?>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LAMP Stack Demo</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .card { border: 1px solid #ddd; padding: 20px; margin: 20px 0; border-radius: 5px; }
        .success { background-color: #d4edda; border-color: #c3e6cb; }
        .info { background-color: #d1ecf1; border-color: #bee5eb; }
        button { background: #007bff; color: white; padding: 10px 20px; border: none; border-radius: 3px; cursor: pointer; }
        button:hover { background: #0056b3; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🐘 LAMP Stack with Docker Compose</h1>
        
        <div class="card success">
            <h2>✅ 환영합니다!</h2>
            <p>Docker Compose로 구축된 LAMP 스택이 정상 동작 중입니다.</p>
            <p><strong>현재 시간:</strong> <?php echo date('Y-m-d H:i:s'); ?></p>
            <p><strong>서버 정보:</strong> <?php echo $_SERVER['SERVER_SOFTWARE'] ?? 'Unknown'; ?></p>
        </div>

        <div class="card info">
            <h2>🔗 링크</h2>
            <p><a href="info.php" target="_blank">📊 PHP 정보 보기</a></p>
            <p><a href="db-test.php" target="_blank">🗄️ 데이터베이스 연결 테스트</a></p>
            <p><a href="http://localhost:8080" target="_blank">🛠️ phpMyAdmin 관리도구</a></p>
        </div>

        <div class="card">
            <h2>📝 방명록</h2>
            <form action="guestbook.php" method="post">
                <input type="text" name="name" placeholder="이름" required style="padding: 5px; margin: 5px;">
                <input type="text" name="message" placeholder="메시지" required style="padding: 5px; margin: 5px; width: 300px;">
                <button type="submit">등록</button>
            </form>
        </div>
    </div>
</body>
</html>
```

```php
<?php
// php/src/info.php
phpinfo();
?>
```

#### Step 2: 데이터베이스 연결 테스트 (25분)
```php
<?php
// php/src/db-test.php
$host = 'mysql';
$dbname = 'lampdb';
$username = 'lampuser';
$password = 'lamppass123';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "<h1>✅ 데이터베이스 연결 성공!</h1>";
    echo "<p>호스트: $host</p>";
    echo "<p>데이터베이스: $dbname</p>";
    echo "<p>사용자: $username</p>";
    
    // 테이블 생성
    $sql = "CREATE TABLE IF NOT EXISTS guestbook (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        message TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    $pdo->exec($sql);
    echo "<p>✅ guestbook 테이블 생성 완료</p>";
    
    // 샘플 데이터 삽입
    $stmt = $pdo->prepare("INSERT INTO guestbook (name, message) VALUES (?, ?)");
    $stmt->execute(['Docker', 'LAMP 스택 테스트 메시지입니다!']);
    echo "<p>✅ 샘플 데이터 삽입 완료</p>";
    
    // 데이터 조회
    $stmt = $pdo->query("SELECT * FROM guestbook ORDER BY created_at DESC");
    $messages = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "<h2>📝 방명록 데이터</h2>";
    foreach ($messages as $msg) {
        echo "<div style='border: 1px solid #ddd; padding: 10px; margin: 10px 0;'>";
        echo "<strong>{$msg['name']}</strong>: {$msg['message']}";
        echo "<br><small>{$msg['created_at']}</small>";
        echo "</div>";
    }
    
} catch (PDOException $e) {
    echo "<h1>❌ 데이터베이스 연결 실패</h1>";
    echo "<p>오류: " . $e->getMessage() . "</p>";
}
?>
```

#### Step 3: 방명록 기능 구현 (30분)
```php
<?php
// php/src/guestbook.php
$host = 'mysql';
$dbname = 'lampdb';
$username = 'lampuser';
$password = 'lamppass123';

if ($_POST) {
    try {
        $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        
        $stmt = $pdo->prepare("INSERT INTO guestbook (name, message) VALUES (?, ?)");
        $stmt->execute([$_POST['name'], $_POST['message']]);
        
        header('Location: index.php');
        exit;
    } catch (PDOException $e) {
        $error = $e->getMessage();
    }
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>방명록 등록</title>
</head>
<body>
    <?php if (isset($error)): ?>
        <p style="color: red;">오류: <?php echo $error; ?></p>
    <?php endif; ?>
    <p>방명록이 등록되었습니다!</p>
    <a href="index.php">돌아가기</a>
</body>
</html>
```

### ✅ Phase 2 체크포인트
- [ ] 기본 PHP 애플리케이션 생성 완료
- [ ] 데이터베이스 연결 테스트 성공
- [ ] 방명록 기능 구현 완료
- [ ] 웹 애플리케이션 정상 동작 확인

---

## 🔧 Phase 3: 컨테이너 접근 및 실시간 수정 (60분)

### 📋 Phase 3 목표
**실행 중인 컨테이너에 접근하여 애플리케이션 수정**

#### Step 1: LAMP 스택 실행 (15분)
```bash
# Docker Compose 실행
docker-compose up -d

# 서비스 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs -f

# 브라우저에서 확인
# http://localhost - 메인 페이지
# http://localhost:8080 - phpMyAdmin
```

#### Step 2: 컨테이너 접근 및 파일 수정 (25분)
```bash
# PHP 컨테이너 접근
docker exec -it lamp-php sh

# 컨테이너 내부에서 파일 확인
ls -la /var/www/html/

# vi 설치 (Alpine Linux)
apk add --no-cache vim

# 파일 수정
vim /var/www/html/index.php
```

**실시간 수정 실습**:
1. **스타일 변경**: CSS 스타일을 수정하여 색상 변경
2. **내용 추가**: 새로운 섹션이나 기능 추가
3. **PHP 코드 수정**: 동적 콘텐츠 변경

```php
// index.php에 추가할 새로운 섹션
<div class="card">
    <h2>🚀 실시간 수정 테스트</h2>
    <p>이 내용은 컨테이너 내부에서 직접 수정했습니다!</p>
    <p><strong>수정 시간:</strong> <?php echo date('Y-m-d H:i:s'); ?></p>
    <p><strong>컨테이너 ID:</strong> <?php echo gethostname(); ?></p>
</div>
```

#### Step 3: MySQL 데이터 직접 조작 (20분)
```bash
# MySQL 컨테이너 접근
docker exec -it lamp-mysql mysql -u lampuser -p

# 데이터베이스 사용
USE lampdb;

# 테이블 확인
SHOW TABLES;

# 데이터 조회
SELECT * FROM guestbook;

# 새 데이터 추가
INSERT INTO guestbook (name, message) VALUES ('Docker Admin', '컨테이너에서 직접 추가한 메시지입니다!');

# 데이터 수정
UPDATE guestbook SET message = '수정된 메시지입니다!' WHERE id = 1;

# 종료
EXIT;
```

### ✅ Phase 3 체크포인트
- [ ] LAMP 스택 정상 실행 확인
- [ ] PHP 컨테이너 접근 및 파일 수정 성공
- [ ] MySQL 컨테이너 접근 및 데이터 조작 완료
- [ ] 실시간 변경사항 웹에서 확인

---

## 🎨 Phase 4: 팀 협업 개발 (30분)

### 📋 Phase 4 목표
**팀별로 다른 기능을 개발하여 하나의 웹사이트 완성**

#### 팀별 개발 과제
**팀 1**: 사용자 관리 시스템
```php
// users.php
<?php
// 사용자 등록/로그인 기능 구현
?>
```

**팀 2**: 게시판 시스템
```php
// board.php
<?php
// 게시글 작성/조회 기능 구현
?>
```

**팀 3**: 파일 업로드 시스템
```php
// upload.php
<?php
// 이미지 업로드/갤러리 기능 구현
?>
```

#### 협업 워크플로우
1. **개발 환경 공유**: 모든 팀이 동일한 Docker Compose 환경 사용
2. **기능별 개발**: 각 팀이 담당 기능 개발
3. **통합 테스트**: 개발된 기능들을 메인 페이지에 통합
4. **결과 공유**: 완성된 웹사이트 시연

### ✅ Phase 4 체크포인트
- [ ] 팀별 기능 개발 완료
- [ ] 메인 페이지에 기능 통합
- [ ] 전체 시스템 동작 테스트
- [ ] 팀별 결과 발표 준비

---

## 📝 세션 마무리

### ✅ LAMP 스택 실습 완주 성과
- [ ] **완전한 웹 환경 구축**: Nginx + PHP + MySQL 스택 완성 ✅
- [ ] **실무 워크플로우**: 컨테이너 접근 및 실시간 수정 경험 ✅
- [ ] **데이터베이스 연동**: PHP와 MySQL 완전 연동 구현 ✅
- [ ] **팀 협업 개발**: 여러 기능을 통합한 웹사이트 완성 ✅
- [ ] **Docker Compose 활용**: 오전 이론을 실제 프로젝트에 적용 ✅

### 🎯 실무 역량 완성
- **웹 개발 환경**: Docker로 구축하는 완전한 개발 환경
- **컨테이너 조작**: 실행 중인 컨테이너 직접 관리 능력
- **데이터베이스 관리**: 컨테이너화된 DB 운영 경험
- **협업 개발**: 동일 환경에서의 팀 개발 워크플로우

### 🔮 다음 세션 준비
- **성과 정리**: 오늘 구축한 LAMP 스택을 포트폴리오에 추가
- **경험 공유**: 컨테이너 개발 환경의 장점과 활용 방안
- **개선 아이디어**: 더 나은 개발 환경을 위한 개선 방안

---

<div align="center">

**🐘 LAMP 스택 Docker Compose 실습 완벽 완주!**

*고전 웹 스택부터 현대적 컨테이너 개발까지 완전 정복*

**이전**: [Session 3 - 서비스 의존성과 헬스체크](./session_3.md) | **다음**: [Session 5 - 개별 멘토링 & 포트폴리오 확장](./session_5.md)

</div>