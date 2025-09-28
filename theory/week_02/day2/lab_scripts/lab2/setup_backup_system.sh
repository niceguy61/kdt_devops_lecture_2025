#!/bin/bash

# Week 2 Day 2 Lab 2: 백업 시스템 자동 구축
# 사용법: ./setup_backup_system.sh

echo "=== 백업 시스템 자동 구축 시작 ==="

# 1. 디렉토리 구조 생성
echo "1. 백업 디렉토리 구조 생성 중..."
mkdir -p backup/{daily,weekly,monthly,scripts,logs,restore}
mkdir -p remote/{s3,gdrive,ftp}

# 2. 백업 설정 파일 생성
echo "2. 백업 설정 파일 생성 중..."
cat > backup/scripts/backup-config.conf << 'EOF'
# 백업 설정
BACKUP_ROOT="/backup"
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

# 3. 메인 백업 스크립트 생성
echo "3. 메인 백업 스크립트 생성 중..."
cat > backup/scripts/backup-main.sh << 'EOF'
#!/bin/bash
source /backup/scripts/backup-config.conf

BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_TYPE=${1:-daily}
LOG_FILE="/backup/logs/backup_${BACKUP_DATE}.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a ${LOG_FILE}
}

backup_database() {
    log "Starting database backup..."
    
    docker exec ${MYSQL_CONTAINER} mysqldump \
        --single-transaction \
        --routines \
        --triggers \
        --add-drop-database \
        --databases ${MYSQL_DATABASE} \
        -u ${MYSQL_USER} -p${MYSQL_PASSWORD} \
        > ${BACKUP_ROOT}/${BACKUP_TYPE}/mysql_${BACKUP_DATE}.sql
    
    if [ $? -eq 0 ]; then
        gzip ${BACKUP_ROOT}/${BACKUP_TYPE}/mysql_${BACKUP_DATE}.sql
        log "Database backup completed successfully"
    else
        log "ERROR: Database backup failed"
        exit 1
    fi
}

backup_wordpress() {
    log "Starting WordPress files backup..."
    
    docker run --rm \
        -v wp-content:/data:ro \
        -v ${BACKUP_ROOT}/${BACKUP_TYPE}:/backup \
        alpine tar czf /backup/wp-content_${BACKUP_DATE}.tar.gz -C /data .
    
    docker run --rm \
        -v wp-config:/config:ro \
        -v ${BACKUP_ROOT}/${BACKUP_TYPE}:/backup \
        alpine tar czf /backup/wp-config_${BACKUP_DATE}.tar.gz -C /config .
    
    log "WordPress files backup completed"
}

verify_backup() {
    log "Verifying backup integrity..."
    
    DB_SIZE=$(stat -c%s "${BACKUP_ROOT}/${BACKUP_TYPE}/mysql_${BACKUP_DATE}.sql.gz")
    WP_SIZE=$(stat -c%s "${BACKUP_ROOT}/${BACKUP_TYPE}/wp-content_${BACKUP_DATE}.tar.gz")
    
    if [ $DB_SIZE -lt 1000 ] || [ $WP_SIZE -lt 1000 ]; then
        log "ERROR: Backup files are too small"
        exit 1
    fi
    
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

# 4. Cron 설정 스크립트 생성
echo "4. Cron 스케줄 설정 스크립트 생성 중..."
cat > backup/scripts/setup-cron.sh << 'EOF'
#!/bin/bash

crontab -l > /tmp/crontab.backup 2>/dev/null

cat >> /tmp/crontab.backup << 'CRON'
# WordPress 백업 스케줄
0 2 * * * /backup/scripts/backup-main.sh daily >> /backup/logs/cron.log 2>&1
0 3 * * 0 /backup/scripts/backup-main.sh weekly >> /backup/logs/cron.log 2>&1
0 4 1 * * /backup/scripts/backup-main.sh monthly >> /backup/logs/cron.log 2>&1
0 5 * * * /backup/scripts/sync-remote.sh >> /backup/logs/sync.log 2>&1
0 6 * * 6 /backup/scripts/cleanup-old.sh >> /backup/logs/cleanup.log 2>&1
CRON

crontab /tmp/crontab.backup
echo "Cron jobs installed successfully"
EOF

# 5. 실행 권한 설정
echo "5. 실행 권한 설정 중..."
chmod +x backup/scripts/*.sh

echo ""
echo "=== 백업 시스템 자동 구축 완료 ==="
echo ""
echo "생성된 구성 요소:"
echo "- 백업 디렉토리: backup/{daily,weekly,monthly}"
echo "- 설정 파일: backup/scripts/backup-config.conf"
echo "- 메인 스크립트: backup/scripts/backup-main.sh"
echo "- Cron 설정: backup/scripts/setup-cron.sh"
echo ""
echo "다음 단계: ./setup_remote_storage.sh 실행"