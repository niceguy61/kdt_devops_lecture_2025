#!/bin/bash

# Week 2 Day 2 Lab 2: 재해 복구 시스템 자동 구축
# 사용법: ./setup_disaster_recovery.sh

echo "=== 재해 복구 시스템 자동 구축 시작 ==="

# 1. 재해 복구 메인 스크립트 생성
echo "1. 재해 복구 메인 스크립트 생성 중..."
cat > backup/scripts/disaster-recovery.sh << 'EOF'
#!/bin/bash
source /backup/scripts/backup-config.conf

RECOVERY_DATE=${1:-latest}
RECOVERY_TYPE=${2:-daily}
LOG_FILE="/backup/logs/recovery_$(date +%Y%m%d_%H%M%S).log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a ${LOG_FILE}
}

find_backup_files() {
    log "Searching for backup files..."
    
    if [ "$RECOVERY_DATE" = "latest" ]; then
        DB_BACKUP=$(ls -t ${BACKUP_ROOT}/${RECOVERY_TYPE}/mysql_*.sql.gz 2>/dev/null | head -1)
        WP_BACKUP=$(ls -t ${BACKUP_ROOT}/${RECOVERY_TYPE}/wp-content_*.tar.gz 2>/dev/null | head -1)
        CONFIG_BACKUP=$(ls -t ${BACKUP_ROOT}/${RECOVERY_TYPE}/wp-config_*.tar.gz 2>/dev/null | head -1)
    else
        DB_BACKUP=$(ls ${BACKUP_ROOT}/${RECOVERY_TYPE}/mysql_*${RECOVERY_DATE}*.sql.gz 2>/dev/null | head -1)
        WP_BACKUP=$(ls ${BACKUP_ROOT}/${RECOVERY_TYPE}/wp-content_*${RECOVERY_DATE}*.tar.gz 2>/dev/null | head -1)
        CONFIG_BACKUP=$(ls ${BACKUP_ROOT}/${RECOVERY_TYPE}/wp-config_*${RECOVERY_DATE}*.tar.gz 2>/dev/null | head -1)
    fi
    
    if [ -z "$DB_BACKUP" ] || [ -z "$WP_BACKUP" ]; then
        log "ERROR: Required backup files not found"
        exit 1
    fi
    
    log "Found backup files:"
    log "  Database: $DB_BACKUP"
    log "  WordPress: $WP_BACKUP"
    log "  Config: $CONFIG_BACKUP"
}

cleanup_existing() {
    log "Cleaning up existing environment..."
    
    docker-compose -f ~/wordpress-stack/docker-compose.yml down -v
    docker volume rm wp-content wp-config mysql-data 2>/dev/null || true
    
    log "Cleanup completed"
}

restore_database() {
    log "Restoring database..."
    
    docker-compose -f ~/wordpress-stack/docker-compose.yml up -d mysql
    
    log "Waiting for MySQL to be ready..."
    sleep 30
    
    gunzip -c "$DB_BACKUP" | docker exec -i mysql-wordpress mysql -u root -prootpassword
    
    if [ $? -eq 0 ]; then
        log "Database restore completed successfully"
    else
        log "ERROR: Database restore failed"
        exit 1
    fi
}

restore_wordpress() {
    log "Restoring WordPress files..."
    
    docker run --rm \
        -v wp-content:/data \
        -v "$(dirname $WP_BACKUP):/backup:ro" \
        alpine sh -c "cd /data && tar xzf /backup/$(basename $WP_BACKUP)"
    
    if [ -n "$CONFIG_BACKUP" ]; then
        docker run --rm \
            -v wp-config:/config \
            -v "$(dirname $CONFIG_BACKUP):/backup:ro" \
            alpine sh -c "cd /config && tar xzf /backup/$(basename $CONFIG_BACKUP)"
    fi
    
    log "WordPress files restore completed"
}

start_and_verify() {
    log "Starting WordPress services..."
    
    docker-compose -f ~/wordpress-stack/docker-compose.yml up -d
    
    log "Waiting for services to be ready..."
    sleep 60
    
    if curl -f http://localhost:8080 >/dev/null 2>&1; then
        log "WordPress is accessible at http://localhost:8080"
        log "Recovery completed successfully!"
    else
        log "WARNING: WordPress may not be fully ready yet"
        log "Please check manually at http://localhost:8080"
    fi
}

main() {
    log "=== Disaster Recovery Started ==="
    log "Recovery Date: $RECOVERY_DATE"
    log "Recovery Type: $RECOVERY_TYPE"
    
    find_backup_files
    
    read -p "This will destroy current data. Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Recovery cancelled by user"
        exit 0
    fi
    
    cleanup_existing
    restore_database
    restore_wordpress
    start_and_verify
    
    log "=== Disaster Recovery Completed ==="
}

main
EOF

# 2. 백업 상태 모니터링 스크립트 생성
echo "2. 백업 상태 모니터링 스크립트 생성 중..."
cat > backup/scripts/backup-status.sh << 'EOF'
#!/bin/bash

echo "=== WordPress 백업 시스템 상태 ==="
echo

echo "📁 최근 백업 파일:"
echo "일일 백업:"
ls -lt /backup/daily/*.gz 2>/dev/null | head -3
echo
echo "주간 백업:"
ls -lt /backup/weekly/*.gz 2>/dev/null | head -2
echo
echo "월간 백업:"
ls -lt /backup/monthly/*.gz 2>/dev/null | head -2
echo

echo "💾 백업 디스크 사용량:"
du -sh /backup/*
echo

echo "📋 최근 백업 로그:"
tail -10 /backup/logs/backup_*.log 2>/dev/null | tail -5
echo

echo "⏰ 예약된 백업 작업:"
crontab -l | grep backup
echo

echo "🔧 WordPress 서비스 상태:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "wordpress|mysql"
echo
EOF

# 3. 실행 권한 설정
echo "3. 실행 권한 설정 중..."
chmod +x backup/scripts/disaster-recovery.sh backup/scripts/backup-status.sh

echo ""
echo "=== 재해 복구 시스템 구축 완료 ==="
echo ""
echo "생성된 구성 요소:"
echo "- 재해 복구: backup/scripts/disaster-recovery.sh"
echo "- 상태 모니터링: backup/scripts/backup-status.sh"
echo ""
echo "사용법:"
echo "  ./backup/scripts/disaster-recovery.sh latest daily"
echo "  ./backup/scripts/backup-status.sh"
echo ""
echo "다음 단계: ./test_backup_system.sh 실행"