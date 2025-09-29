#!/bin/bash

# Week 2 Day 2 Lab 2: 백업 시스템 자동 구축
# 사용법: ./setup_backup_system.sh

echo "=== 백업 시스템 자동 구축 시작 ==="

# 현재 디렉토리 확인
if [ ! -d "~/wordpress-stack" ]; then
    echo "WordPress 스택 디렉토리로 이동 중..."
    cd ~/wordpress-stack 2>/dev/null || {
        echo "WordPress 스택 디렉토리를 찾을 수 없습니다. Lab 1을 먼저 완료해주세요."
        exit 1
    }
fi

# Lab 1 환경 확인
echo "1. Lab 1 환경 확인 중..."
if ! docker ps | grep -q "mysql-wordpress"; then
    echo "❌ MySQL 컨테이너가 실행되지 않았습니다. Lab 1을 먼저 완료해주세요."
    exit 1
fi

if ! docker ps | grep -q "wordpress-app"; then
    echo "❌ WordPress 컨테이너가 실행되지 않았습니다. Lab 1을 먼저 완료해주세요."
    exit 1
fi

echo "✅ Lab 1 환경 확인 완료"

# 2. 디렉토리 구조 생성
echo "2. 백업 디렉토리 구조 생성 중..."
mkdir -p backup/{daily,weekly,monthly,scripts,logs,restore}
mkdir -p remote/{s3,gdrive,ftp}

# 3. 백업 설정 파일 생성
echo "3. 백업 설정 파일 생성 중..."
cat > backup/scripts/backup-config.conf << 'EOF'
# 백업 설정
BACKUP_ROOT="$(pwd)/backup"
MYSQL_CONTAINER="mysql-wordpress"
WORDPRESS_CONTAINER="wordpress-app"
MYSQL_USER="wpuser"
MYSQL_PASSWORD="wppassword"
MYSQL_DATABASE="wordpress"

# 보관 정책
DAILY_RETENTION=7
WEEKLY_RETENTION=4
MONTHLY_RETENTION=12

# 원격 저장소
S3_BUCKET="company-wordpress-backup"
S3_REGION="ap-northeast-2"
GDRIVE_FOLDER="WordPress_Backups"
FTP_HOST="backup.company.com"
FTP_USER="backup_user"
EOF

# 4. 메인 백업 스크립트 생성
echo "4. 메인 백업 스크립트 생성 중..."
cat > backup/scripts/backup-main.sh << 'EOF'
#!/bin/bash
source $(dirname $0)/backup-config.conf

BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_TYPE=${1:-daily}
LOG_FILE="${BACKUP_ROOT}/logs/backup_${BACKUP_DATE}.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a ${LOG_FILE}
}

backup_database() {
    log "Starting database backup..."
    
    # 데이터베이스 연결 확인
    if ! docker exec ${MYSQL_CONTAINER} mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SELECT 1;" >/dev/null 2>&1; then
        log "ERROR: Cannot connect to database"
        exit 1
    fi
    
    # 백업 실행
    docker exec ${MYSQL_CONTAINER} mysqldump \
        --single-transaction \
        --routines \
        --triggers \
        --add-drop-database \
        --databases ${MYSQL_DATABASE} \
        -u ${MYSQL_USER} -p${MYSQL_PASSWORD} \
        > ${BACKUP_ROOT}/${BACKUP_TYPE}/mysql_${BACKUP_DATE}.sql
    
    if [ $? -eq 0 ] && [ -f "${BACKUP_ROOT}/${BACKUP_TYPE}/mysql_${BACKUP_DATE}.sql" ]; then
        # 백업 파일 크기 확인 (압축 전)
        UNCOMPRESSED_SIZE=$(stat -c%s "${BACKUP_ROOT}/${BACKUP_TYPE}/mysql_${BACKUP_DATE}.sql" 2>/dev/null || echo 0)
        log "Uncompressed database backup size: ${UNCOMPRESSED_SIZE} bytes"
        
        if [ $UNCOMPRESSED_SIZE -gt 100 ]; then
            gzip ${BACKUP_ROOT}/${BACKUP_TYPE}/mysql_${BACKUP_DATE}.sql
            log "Database backup completed successfully"
        else
            log "ERROR: Database backup file is too small (${UNCOMPRESSED_SIZE} bytes)"
            log "This might indicate an empty database or connection issues"
            exit 1
        fi
    else
        log "ERROR: Database backup failed"
        exit 1
    fi
}

backup_wordpress() {
    log "Starting WordPress files backup..."
    
    # wp-content 백업
    docker run --rm \
        -v wp-content:/data:ro \
        -v ${BACKUP_ROOT}/${BACKUP_TYPE}:/backup \
        alpine tar czf /backup/wp-content_${BACKUP_DATE}.tar.gz -C /data .
    
    # WordPress 설정 백업 (볼륨이 있는 경우만)
    if docker volume ls | grep -q wp-config; then
        docker run --rm \
            -v wp-config:/config:ro \
            -v ${BACKUP_ROOT}/${BACKUP_TYPE}:/backup \
            alpine tar czf /backup/wp-config_${BACKUP_DATE}.tar.gz -C /config .
    fi
    
    log "WordPress files backup completed"
}

verify_backup() {
    log "Verifying backup integrity..."
    
    # 파일 크기 확인
    DB_SIZE=$(stat -c%s "${BACKUP_ROOT}/${BACKUP_TYPE}/mysql_${BACKUP_DATE}.sql.gz" 2>/dev/null || echo 0)
    WP_SIZE=$(stat -c%s "${BACKUP_ROOT}/${BACKUP_TYPE}/wp-content_${BACKUP_DATE}.tar.gz" 2>/dev/null || echo 0)
    
    log "Backup file sizes - DB: ${DB_SIZE} bytes, WP: ${WP_SIZE} bytes"
    
    # 현실적인 임계값 설정
    if [ $DB_SIZE -lt 100 ]; then
        log "ERROR: Database backup file is too small (${DB_SIZE} bytes)"
        log "Expected at least 100 bytes for a valid compressed database backup"
        exit 1
    fi
    
    if [ $WP_SIZE -lt 1000 ]; then
        log "ERROR: WordPress backup file is too small (${WP_SIZE} bytes)"
        log "Expected at least 1000 bytes for wp-content backup"
        exit 1
    fi
    
    log "✅ Backup file sizes are acceptable"
    
    # 압축 파일 무결성 확인
    if ! gzip -t "${BACKUP_ROOT}/${BACKUP_TYPE}/mysql_${BACKUP_DATE}.sql.gz" 2>/dev/null; then
        log "ERROR: Database backup is corrupted"
        exit 1
    else
        log "✅ Database backup integrity verified"
    fi
    
    if ! tar -tzf "${BACKUP_ROOT}/${BACKUP_TYPE}/wp-content_${BACKUP_DATE}.tar.gz" >/dev/null 2>&1; then
        log "ERROR: WordPress backup is corrupted"
        exit 1
    else
        log "✅ WordPress backup integrity verified"
    fi
    
    # 체크섬 생성
    cd ${BACKUP_ROOT}/${BACKUP_TYPE}
    md5sum *_${BACKUP_DATE}.* > checksums_${BACKUP_DATE}.md5
    
    log "Backup verification completed successfully"
}

main() {
    log "=== Backup started (Type: ${BACKUP_TYPE}) ==="
    backup_database
    backup_wordpress
    verify_backup
    log "=== Backup completed successfully ==="
}

main
EOF

# 5. Cron 설정 스크립트 생성
echo "5. Cron 스케줄 설정 스크립트 생성 중..."
cat > backup/scripts/setup-cron.sh << 'EOF'
#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 현재 crontab 백업
crontab -l > /tmp/crontab.backup 2>/dev/null || touch /tmp/crontab.backup

# 기존 WordPress 백업 작업 제거
grep -v "WordPress 백업" /tmp/crontab.backup > /tmp/crontab.new
grep -v "backup-main.sh" /tmp/crontab.new > /tmp/crontab.backup

# 새로운 cron 작업 추가
cat >> /tmp/crontab.backup << CRON
# WordPress 백업 스케줄
0 2 * * * ${SCRIPT_DIR}/backup-main.sh daily >> ${SCRIPT_DIR}/../logs/cron.log 2>&1
0 3 * * 0 ${SCRIPT_DIR}/backup-main.sh weekly >> ${SCRIPT_DIR}/../logs/cron.log 2>&1
0 4 1 * * ${SCRIPT_DIR}/backup-main.sh monthly >> ${SCRIPT_DIR}/../logs/cron.log 2>&1
0 5 * * * ${SCRIPT_DIR}/sync-remote.sh >> ${SCRIPT_DIR}/../logs/sync.log 2>&1
0 6 * * 6 ${SCRIPT_DIR}/cleanup-old.sh >> ${SCRIPT_DIR}/../logs/cleanup.log 2>&1
CRON

# crontab 적용
crontab /tmp/crontab.backup
echo "Cron jobs installed successfully"
echo "현재 설정된 cron 작업:"
crontab -l | grep -A5 -B1 "WordPress 백업"
EOF

# 6. 백업 상태 확인 스크립트 생성
echo "6. 백업 상태 확인 스크립트 생성 중..."
cat > backup/scripts/backup-status.sh << 'EOF'
#!/bin/bash
source $(dirname $0)/backup-config.conf

echo "=== WordPress 백업 시스템 상태 ==="
echo

# 최근 백업 파일 확인
echo "📁 최근 백업 파일:"
echo "일일 백업:"
ls -lt ${BACKUP_ROOT}/daily/*.gz 2>/dev/null | head -3 || echo "  백업 파일 없음"
echo
echo "주간 백업:"
ls -lt ${BACKUP_ROOT}/weekly/*.gz 2>/dev/null | head -2 || echo "  백업 파일 없음"
echo
echo "월간 백업:"
ls -lt ${BACKUP_ROOT}/monthly/*.gz 2>/dev/null | head -2 || echo "  백업 파일 없음"
echo

# 디스크 사용량
echo "💾 백업 디스크 사용량:"
du -sh ${BACKUP_ROOT}/* 2>/dev/null || echo "  사용량 정보 없음"
echo

# 최근 로그 확인
echo "📋 최근 백업 로그:"
if ls ${BACKUP_ROOT}/logs/backup_*.log 1> /dev/null 2>&1; then
    tail -5 $(ls -t ${BACKUP_ROOT}/logs/backup_*.log | head -1)
else
    echo "  로그 파일 없음"
fi
echo

# Cron 작업 상태
echo "⏰ 예약된 백업 작업:"
crontab -l 2>/dev/null | grep backup || echo "  예약된 작업 없음"
echo

# 서비스 상태
echo "🔧 WordPress 서비스 상태:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "wordpress|mysql" || echo "  서비스가 실행되지 않음"
echo
EOF

# 7. 실행 권한 설정
echo "7. 실행 권한 설정 중..."
chmod +x backup/scripts/*.sh

# 8. 초기 백업 테스트
echo "8. 초기 백업 테스트 실행 중..."
./backup/scripts/backup-main.sh daily

if [ $? -eq 0 ]; then
    echo "✅ 초기 백업 테스트 성공"
else
    echo "❌ 초기 백업 테스트 실패"
    exit 1
fi

echo ""
echo "=== 백업 시스템 자동 구축 완료 ==="
echo ""
echo "생성된 구성 요소:"
echo "- 백업 디렉토리: backup/{daily,weekly,monthly}"
echo "- 설정 파일: backup/scripts/backup-config.conf"
echo "- 메인 스크립트: backup/scripts/backup-main.sh"
echo "- Cron 설정: backup/scripts/setup-cron.sh"
echo "- 상태 확인: backup/scripts/backup-status.sh"
echo ""
echo "백업 파일 확인:"
ls -la backup/daily/
echo ""
echo "다음 단계: ./lab_scripts/lab2/setup_remote_storage.sh 실행"