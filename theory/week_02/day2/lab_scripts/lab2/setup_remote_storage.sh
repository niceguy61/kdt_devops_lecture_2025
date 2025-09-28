#!/bin/bash

# Week 2 Day 2 Lab 2: 원격 저장소 연동 자동 설정
# 사용법: ./setup_remote_storage.sh

echo "=== 원격 저장소 연동 자동 설정 시작 ==="

# 1. AWS S3 동기화 스크립트 생성
echo "1. AWS S3 동기화 스크립트 생성 중..."
cat > backup/scripts/sync-s3.sh << 'EOF'
#!/bin/bash
source /backup/scripts/backup-config.conf

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

sync_to_s3() {
    log "Starting S3 sync..."
    
    if ! command -v aws &> /dev/null; then
        log "Installing AWS CLI..."
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
    fi
    
    aws s3 sync /backup/daily/ s3://${S3_BUCKET}/daily/ \
        --exclude "*.log" \
        --storage-class STANDARD_IA
    
    aws s3 sync /backup/weekly/ s3://${S3_BUCKET}/weekly/ \
        --exclude "*.log" \
        --storage-class GLACIER
    
    aws s3 sync /backup/monthly/ s3://${S3_BUCKET}/monthly/ \
        --exclude "*.log" \
        --storage-class DEEP_ARCHIVE
    
    log "S3 sync completed"
}

sync_to_s3
EOF

# 2. Google Drive 동기화 스크립트 생성
echo "2. Google Drive 동기화 스크립트 생성 중..."
cat > backup/scripts/sync-gdrive.sh << 'EOF'
#!/bin/bash
source /backup/scripts/backup-config.conf

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

sync_to_gdrive() {
    log "Starting Google Drive sync..."
    
    if ! command -v rclone &> /dev/null; then
        log "Installing rclone..."
        curl https://rclone.org/install.sh | sudo bash
    fi
    
    rclone sync /backup/daily/ gdrive:${GDRIVE_FOLDER}/daily/ \
        --exclude "*.log" \
        --progress
    
    log "Google Drive sync completed"
}

sync_to_gdrive
EOF

# 3. 통합 원격 동기화 스크립트 생성
echo "3. 통합 원격 동기화 스크립트 생성 중..."
cat > backup/scripts/sync-remote.sh << 'EOF'
#!/bin/bash

LOG_FILE="/backup/logs/sync_$(date +%Y%m%d_%H%M%S).log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a ${LOG_FILE}
}

log "=== Remote sync started ==="

if /backup/scripts/sync-s3.sh >> ${LOG_FILE} 2>&1; then
    log "S3 sync successful"
else
    log "ERROR: S3 sync failed"
fi

if /backup/scripts/sync-gdrive.sh >> ${LOG_FILE} 2>&1; then
    log "Google Drive sync successful"
else
    log "ERROR: Google Drive sync failed"
fi

log "=== Remote sync completed ==="
EOF

# 4. 백업 정리 스크립트 생성
echo "4. 백업 정리 스크립트 생성 중..."
cat > backup/scripts/cleanup-old.sh << 'EOF'
#!/bin/bash
source /backup/scripts/backup-config.conf

LOG_FILE="/backup/logs/cleanup_$(date +%Y%m%d_%H%M%S).log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a ${LOG_FILE}
}

cleanup_daily() {
    log "Cleaning up daily backups older than ${DAILY_RETENTION} days..."
    find ${BACKUP_ROOT}/daily -name "*" -type f -mtime +${DAILY_RETENTION} -delete
    log "Daily cleanup completed"
}

cleanup_weekly() {
    log "Cleaning up weekly backups older than ${WEEKLY_RETENTION} weeks..."
    find ${BACKUP_ROOT}/weekly -name "*" -type f -mtime +$((${WEEKLY_RETENTION} * 7)) -delete
    log "Weekly cleanup completed"
}

cleanup_monthly() {
    log "Cleaning up monthly backups older than ${MONTHLY_RETENTION} months..."
    find ${BACKUP_ROOT}/monthly -name "*" -type f -mtime +$((${MONTHLY_RETENTION} * 30)) -delete
    log "Monthly cleanup completed"
}

cleanup_logs() {
    log "Cleaning up old log files..."
    find /backup/logs -name "*.log" -type f -mtime +30 -delete
    log "Log cleanup completed"
}

main() {
    log "=== Backup Cleanup Started ==="
    cleanup_daily
    cleanup_weekly
    cleanup_monthly
    cleanup_logs
    
    log "Current backup disk usage:"
    du -sh ${BACKUP_ROOT}/* | tee -a ${LOG_FILE}
    
    log "=== Backup Cleanup Completed ==="
}

main
EOF

# 5. 실행 권한 설정
echo "5. 실행 권한 설정 중..."
chmod +x backup/scripts/sync-*.sh backup/scripts/cleanup-old.sh

echo ""
echo "=== 원격 저장소 연동 설정 완료 ==="
echo ""
echo "생성된 구성 요소:"
echo "- S3 동기화: backup/scripts/sync-s3.sh"
echo "- Google Drive 동기화: backup/scripts/sync-gdrive.sh"
echo "- 통합 동기화: backup/scripts/sync-remote.sh"
echo "- 백업 정리: backup/scripts/cleanup-old.sh"
echo ""
echo "다음 단계: ./setup_disaster_recovery.sh 실행"