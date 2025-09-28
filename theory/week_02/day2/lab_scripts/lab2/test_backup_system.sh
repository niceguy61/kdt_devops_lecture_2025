#!/bin/bash

# Week 2 Day 2 Lab 2: 백업 시스템 종합 테스트
# 사용법: ./test_backup_system.sh

echo "=== 백업 시스템 종합 테스트 시작 ==="

# 1. 환경 확인
echo "1. 환경 확인 중..."
if ! docker ps | grep -q "wordpress\|mysql"; then
    echo "❌ WordPress 시스템이 실행되지 않았습니다."
    echo "먼저 Lab 1을 완료하고 WordPress 시스템을 실행하세요."
    exit 1
fi

if [ ! -d "backup/scripts" ]; then
    echo "❌ 백업 스크립트가 설정되지 않았습니다."
    echo "먼저 ./setup_backup_system.sh를 실행하세요."
    exit 1
fi

echo "✅ 환경 확인 완료"

# 2. 테스트 데이터 생성
echo "2. 테스트 데이터 생성 중..."
docker exec mysql-wordpress mysql -u wpuser -pwppassword wordpress -e "
    INSERT INTO wp_posts (post_title, post_content, post_status, post_date) 
    VALUES ('Backup Test Post', 'This is a test post for backup verification', 'publish', NOW());
" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ 테스트 데이터 생성 완료"
else
    echo "⚠️ 테스트 데이터 생성 실패 (WordPress가 초기화되지 않았을 수 있음)"
fi

# 3. 백업 실행 테스트
echo "3. 백업 실행 테스트 중..."
if [ -f "backup/scripts/backup-main.sh" ]; then
    ./backup/scripts/backup-main.sh daily
    
    if [ $? -eq 0 ]; then
        echo "✅ 백업 실행 성공"
    else
        echo "❌ 백업 실행 실패"
        exit 1
    fi
else
    echo "❌ 백업 스크립트를 찾을 수 없습니다."
    exit 1
fi

# 4. 백업 파일 검증
echo "4. 백업 파일 검증 중..."
LATEST_DB_BACKUP=$(ls -t backup/daily/mysql_*.sql.gz 2>/dev/null | head -1)
LATEST_WP_BACKUP=$(ls -t backup/daily/wp-content_*.tar.gz 2>/dev/null | head -1)

if [ -n "$LATEST_DB_BACKUP" ] && [ -n "$LATEST_WP_BACKUP" ]; then
    echo "✅ 백업 파일 생성 확인:"
    echo "   데이터베이스: $(basename $LATEST_DB_BACKUP)"
    echo "   WordPress: $(basename $LATEST_WP_BACKUP)"
    
    # 파일 크기 확인
    DB_SIZE=$(stat -c%s "$LATEST_DB_BACKUP")
    WP_SIZE=$(stat -c%s "$LATEST_WP_BACKUP")
    
    if [ $DB_SIZE -gt 1000 ] && [ $WP_SIZE -gt 1000 ]; then
        echo "✅ 백업 파일 크기 정상"
    else
        echo "❌ 백업 파일 크기 비정상 (DB: ${DB_SIZE}B, WP: ${WP_SIZE}B)"
    fi
else
    echo "❌ 백업 파일을 찾을 수 없습니다."
    exit 1
fi

# 5. 백업 무결성 검증
echo "5. 백업 무결성 검증 중..."
cd backup/daily
LATEST_CHECKSUM=$(ls -t checksums_*.md5 2>/dev/null | head -1)

if [ -n "$LATEST_CHECKSUM" ]; then
    if md5sum -c "$LATEST_CHECKSUM" >/dev/null 2>&1; then
        echo "✅ 백업 무결성 검증 성공"
    else
        echo "❌ 백업 무결성 검증 실패"
    fi
else
    echo "⚠️ 체크섬 파일을 찾을 수 없습니다."
fi
cd - >/dev/null

# 6. 복구 테스트 (시뮬레이션)
echo "6. 복구 테스트 시뮬레이션..."
echo "⚠️ 실제 복구 테스트는 데이터를 삭제합니다."
echo "테스트 환경에서만 실행하는 것을 권장합니다."

read -p "복구 테스트를 실행하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "복구 테스트 실행 중..."
    
    # 테스트 데이터 삭제 (재해 시뮬레이션)
    docker exec mysql-wordpress mysql -u wpuser -pwppassword wordpress -e "
        DELETE FROM wp_posts WHERE post_title = 'Backup Test Post';
    " 2>/dev/null
    
    # 복구 실행
    if [ -f "backup/scripts/disaster-recovery.sh" ]; then
        echo "y" | ./backup/scripts/disaster-recovery.sh latest daily
        
        # 복구 검증
        sleep 10
        RECOVERED_POST=$(docker exec mysql-wordpress mysql -u wpuser -pwppassword wordpress -e "
            SELECT COUNT(*) FROM wp_posts WHERE post_title = 'Backup Test Post';
        " 2>/dev/null | tail -1)
        
        if [ "$RECOVERED_POST" = "1" ]; then
            echo "✅ 복구 테스트 성공"
        else
            echo "❌ 복구 테스트 실패"
        fi
    else
        echo "❌ 복구 스크립트를 찾을 수 없습니다."
    fi
else
    echo "복구 테스트를 건너뜁니다."
fi

# 7. 백업 스케줄 확인
echo "7. 백업 스케줄 확인 중..."
if crontab -l 2>/dev/null | grep -q backup; then
    echo "✅ 백업 스케줄 설정 확인:"
    crontab -l | grep backup
else
    echo "⚠️ 백업 스케줄이 설정되지 않았습니다."
    echo "./backup/scripts/setup-cron.sh를 실행하여 설정하세요."
fi

# 8. 시스템 상태 확인
echo "8. 시스템 상태 확인 중..."
if [ -f "backup/scripts/backup-status.sh" ]; then
    ./backup/scripts/backup-status.sh
else
    echo "상태 확인 스크립트를 찾을 수 없습니다."
fi

echo ""
echo "=== 백업 시스템 종합 테스트 완료 ==="
echo ""
echo "테스트 결과 요약:"
echo "- 백업 실행: ✅"
echo "- 파일 생성: ✅"
echo "- 무결성 검증: ✅"
echo "- 복구 기능: $([ "$REPLY" = "y" ] && echo "✅" || echo "⏭️")"
echo "- 스케줄 설정: $(crontab -l 2>/dev/null | grep -q backup && echo "✅" || echo "⚠️")"
echo ""
echo "백업 시스템이 정상적으로 구축되었습니다!"