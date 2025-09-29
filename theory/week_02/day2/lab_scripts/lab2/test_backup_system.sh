#!/bin/bash

# Week 2 Day 2 Lab 2: 백업 시스템 종합 테스트
# 사용법: ./test_backup_system.sh

echo "=== 백업 시스템 종합 테스트 시작 ==="

# 현재 디렉토리 확인
if [ ! -f "backup/scripts/backup-config.conf" ]; then
    echo "❌ 백업 설정 파일을 찾을 수 없습니다. 이전 단계를 먼저 완료해주세요."
    exit 1
fi

source backup/scripts/backup-config.conf

TEST_LOG="${BACKUP_ROOT}/logs/system_test_$(date +%Y%m%d_%H%M%S).log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a ${TEST_LOG}
}

# 테스트 결과 추적
TESTS_PASSED=0
TESTS_FAILED=0
TOTAL_TESTS=0

test_result() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    if [ $1 -eq 0 ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        log "✅ $2 - 성공"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        log "❌ $2 - 실패"
    fi
}

# 1. 환경 검증 테스트
test_environment() {
    log "=== 환경 검증 테스트 ==="
    
    # Docker 컨테이너 상태 확인
    docker ps | grep -q "${MYSQL_CONTAINER}"
    test_result $? "MySQL 컨테이너 실행 상태"
    
    docker ps | grep -q "${WORDPRESS_CONTAINER}"
    test_result $? "WordPress 컨테이너 실행 상태"
    
    # 볼륨 존재 확인
    docker volume ls | grep -q "wp-content"
    test_result $? "wp-content 볼륨 존재"
    
    docker volume ls | grep -q "mysql-data"
    test_result $? "mysql-data 볼륨 존재"
    
    # 백업 디렉토리 구조 확인
    [ -d "${BACKUP_ROOT}/daily" ]
    test_result $? "일일 백업 디렉토리 존재"
    
    [ -d "${BACKUP_ROOT}/weekly" ]
    test_result $? "주간 백업 디렉토리 존재"
    
    [ -d "${BACKUP_ROOT}/monthly" ]
    test_result $? "월간 백업 디렉토리 존재"
    
    [ -d "${BACKUP_ROOT}/scripts" ]
    test_result $? "스크립트 디렉토리 존재"
    
    [ -d "${BACKUP_ROOT}/logs" ]
    test_result $? "로그 디렉토리 존재"
}

# 2. 백업 기능 테스트
test_backup_functionality() {
    log "=== 백업 기능 테스트 ==="
    
    # 백업 스크립트 실행 가능성 확인
    [ -x "${BACKUP_ROOT}/scripts/backup-main.sh" ]
    test_result $? "백업 메인 스크립트 실행 권한"
    
    # 일일 백업 실행 테스트
    log "일일 백업 테스트 실행 중..."
    ${BACKUP_ROOT}/scripts/backup-main.sh daily >> ${TEST_LOG} 2>&1
    test_result $? "일일 백업 실행"
    
    # 백업 파일 생성 확인
    LATEST_DB_BACKUP=$(ls -t ${BACKUP_ROOT}/daily/mysql_*.sql.gz 2>/dev/null | head -1)
    [ -f "$LATEST_DB_BACKUP" ]
    test_result $? "데이터베이스 백업 파일 생성"
    
    LATEST_WP_BACKUP=$(ls -t ${BACKUP_ROOT}/daily/wp-content_*.tar.gz 2>/dev/null | head -1)
    [ -f "$LATEST_WP_BACKUP" ]
    test_result $? "WordPress 파일 백업 생성"
    
    # 체크섬 파일 확인
    LATEST_CHECKSUM=$(ls -t ${BACKUP_ROOT}/daily/checksums_*.md5 2>/dev/null | head -1)
    [ -f "$LATEST_CHECKSUM" ]
    test_result $? "체크섬 파일 생성"
    
    # 백업 파일 크기 확인
    if [ -f "$LATEST_DB_BACKUP" ]; then
        DB_SIZE=$(stat -c%s "$LATEST_DB_BACKUP")
        [ $DB_SIZE -gt 1000 ]
        test_result $? "데이터베이스 백업 파일 크기 적절성"
    fi
    
    if [ -f "$LATEST_WP_BACKUP" ]; then
        WP_SIZE=$(stat -c%s "$LATEST_WP_BACKUP")
        [ $WP_SIZE -gt 1000 ]
        test_result $? "WordPress 백업 파일 크기 적절성"
    fi
}

# 3. 백업 무결성 테스트
test_backup_integrity() {
    log "=== 백업 무결성 테스트 ==="
    
    # 압축 파일 무결성 확인
    LATEST_DB_BACKUP=$(ls -t ${BACKUP_ROOT}/daily/mysql_*.sql.gz 2>/dev/null | head -1)
    if [ -f "$LATEST_DB_BACKUP" ]; then
        gzip -t "$LATEST_DB_BACKUP"
        test_result $? "데이터베이스 백업 압축 무결성"
    fi
    
    LATEST_WP_BACKUP=$(ls -t ${BACKUP_ROOT}/daily/wp-content_*.tar.gz 2>/dev/null | head -1)
    if [ -f "$LATEST_WP_BACKUP" ]; then
        tar -tzf "$LATEST_WP_BACKUP" >/dev/null
        test_result $? "WordPress 백업 압축 무결성"
    fi
    
    # 체크섬 검증
    LATEST_CHECKSUM=$(ls -t ${BACKUP_ROOT}/daily/checksums_*.md5 2>/dev/null | head -1)
    if [ -f "$LATEST_CHECKSUM" ]; then
        cd $(dirname "$LATEST_CHECKSUM")
        md5sum -c $(basename "$LATEST_CHECKSUM") >/dev/null 2>&1
        test_result $? "체크섬 검증"
    fi
}

# 4. 원격 저장소 연동 테스트
test_remote_storage() {
    log "=== 원격 저장소 연동 테스트 ==="
    
    # 원격 동기화 스크립트 실행 가능성 확인
    [ -x "${BACKUP_ROOT}/scripts/sync-remote.sh" ]
    test_result $? "원격 동기화 스크립트 실행 권한"
    
    # 원격 동기화 실행 테스트
    log "원격 동기화 테스트 실행 중..."
    ${BACKUP_ROOT}/scripts/sync-remote.sh >> ${TEST_LOG} 2>&1
    test_result $? "원격 동기화 실행"
    
    # S3 시뮬레이션 디렉토리 확인
    [ -d "${BACKUP_ROOT}/../remote/s3" ]
    test_result $? "S3 시뮬레이션 디렉토리 생성"
    
    # Google Drive 시뮬레이션 디렉토리 확인
    [ -d "${BACKUP_ROOT}/../remote/gdrive" ]
    test_result $? "Google Drive 시뮬레이션 디렉토리 생성"
    
    # FTP 시뮬레이션 디렉토리 확인
    [ -d "${BACKUP_ROOT}/../remote/ftp" ]
    test_result $? "FTP 시뮬레이션 디렉토리 생성"
    
    # 원격 저장소에 파일 동기화 확인
    S3_FILES=$(find ${BACKUP_ROOT}/../remote/s3 -name "*.gz" 2>/dev/null | wc -l)
    [ $S3_FILES -gt 0 ]
    test_result $? "S3에 백업 파일 동기화"
}

# 5. 재해 복구 시스템 테스트
test_disaster_recovery() {
    log "=== 재해 복구 시스템 테스트 ==="
    
    # 재해 복구 스크립트 실행 가능성 확인
    [ -x "${BACKUP_ROOT}/scripts/disaster-recovery.sh" ]
    test_result $? "재해 복구 스크립트 실행 권한"
    
    # 백업 정리 스크립트 실행 가능성 확인
    [ -x "${BACKUP_ROOT}/scripts/cleanup-old.sh" ]
    test_result $? "백업 정리 스크립트 실행 권한"
    
    # 복구 테스트 스크립트 실행 가능성 확인
    [ -x "${BACKUP_ROOT}/scripts/recovery-test.sh" ]
    test_result $? "복구 테스트 스크립트 실행 권한"
    
    # 백업 정리 기능 테스트
    log "백업 정리 기능 테스트 실행 중..."
    ${BACKUP_ROOT}/scripts/cleanup-old.sh >> ${TEST_LOG} 2>&1
    test_result $? "백업 정리 기능 실행"
}

# 6. 모니터링 및 로깅 테스트
test_monitoring_logging() {
    log "=== 모니터링 및 로깅 테스트 ==="
    
    # 로그 파일 생성 확인
    [ -f "${TEST_LOG}" ]
    test_result $? "테스트 로그 파일 생성"
    
    # 백업 로그 파일 존재 확인
    BACKUP_LOGS=$(find ${BACKUP_ROOT}/logs -name "backup_*.log" 2>/dev/null | wc -l)
    [ $BACKUP_LOGS -gt 0 ]
    test_result $? "백업 로그 파일 존재"
    
    # 동기화 로그 파일 존재 확인
    SYNC_LOGS=$(find ${BACKUP_ROOT}/logs -name "sync_*.log" 2>/dev/null | wc -l)
    [ $SYNC_LOGS -gt 0 ]
    test_result $? "동기화 로그 파일 존재"
    
    # 상태 확인 스크립트 실행 가능성
    [ -x "${BACKUP_ROOT}/scripts/backup-status.sh" ]
    test_result $? "백업 상태 확인 스크립트 실행 권한"
    
    # 원격 저장소 상태 확인 스크립트 실행 가능성
    [ -x "${BACKUP_ROOT}/scripts/remote-status.sh" ]
    test_result $? "원격 저장소 상태 확인 스크립트 실행 권한"
}

# 7. 성능 및 용량 테스트
test_performance_capacity() {
    log "=== 성능 및 용량 테스트 ==="
    
    # 백업 디렉토리 총 용량 확인
    BACKUP_SIZE=$(du -s ${BACKUP_ROOT} 2>/dev/null | cut -f1)
    [ $BACKUP_SIZE -gt 0 ]
    test_result $? "백업 디렉토리 용량 확인"
    
    # 디스크 여유 공간 확인 (최소 1GB)
    AVAILABLE_SPACE=$(df ${BACKUP_ROOT} | tail -1 | awk '{print $4}')
    [ $AVAILABLE_SPACE -gt 1048576 ]  # 1GB in KB
    test_result $? "충분한 디스크 여유 공간"
    
    # 백업 실행 시간 측정
    log "백업 성능 테스트 실행 중..."
    START_TIME=$(date +%s)
    ${BACKUP_ROOT}/scripts/backup-main.sh daily >> ${TEST_LOG} 2>&1
    END_TIME=$(date +%s)
    BACKUP_DURATION=$((END_TIME - START_TIME))
    
    # 백업 시간이 5분(300초) 이내인지 확인
    [ $BACKUP_DURATION -lt 300 ]
    test_result $? "백업 실행 시간 적절성 (${BACKUP_DURATION}초)"
}

# 8. 보안 및 권한 테스트
test_security_permissions() {
    log "=== 보안 및 권한 테스트 ==="
    
    # 백업 파일 권한 확인 (644 또는 600)
    LATEST_DB_BACKUP=$(ls -t ${BACKUP_ROOT}/daily/mysql_*.sql.gz 2>/dev/null | head -1)
    if [ -f "$LATEST_DB_BACKUP" ]; then
        PERM=$(stat -c "%a" "$LATEST_DB_BACKUP")
        [[ "$PERM" =~ ^[67][04][04]$ ]]
        test_result $? "데이터베이스 백업 파일 권한 적절성"
    fi
    
    # 스크립트 실행 권한 확인
    SCRIPT_PERM=$(stat -c "%a" "${BACKUP_ROOT}/scripts/backup-main.sh")
    [[ "$SCRIPT_PERM" =~ ^[7][5][5]$ ]]
    test_result $? "백업 스크립트 실행 권한 적절성"
    
    # 로그 디렉토리 권한 확인
    LOG_DIR_PERM=$(stat -c "%a" "${BACKUP_ROOT}/logs")
    [[ "$LOG_DIR_PERM" =~ ^[7][5][5]$ ]]
    test_result $? "로그 디렉토리 권한 적절성"
}

# 종합 테스트 실행
run_comprehensive_test() {
    log "=== 백업 시스템 종합 테스트 시작 ==="
    
    test_environment
    test_backup_functionality
    test_backup_integrity
    test_remote_storage
    test_disaster_recovery
    test_monitoring_logging
    test_performance_capacity
    test_security_permissions
    
    log "=== 백업 시스템 종합 테스트 완료 ==="
}

# 테스트 결과 요약
show_test_summary() {
    echo ""
    echo "======================================"
    echo "       백업 시스템 테스트 결과"
    echo "======================================"
    echo ""
    echo "📊 테스트 통계:"
    echo "  - 총 테스트: ${TOTAL_TESTS}개"
    echo "  - 성공: ${TESTS_PASSED}개"
    echo "  - 실패: ${TESTS_FAILED}개"
    echo "  - 성공률: $(( TESTS_PASSED * 100 / TOTAL_TESTS ))%"
    echo ""
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo "🎉 모든 테스트가 성공했습니다!"
        echo "✅ 백업 시스템이 정상적으로 구축되었습니다."
        echo ""
        echo "🔧 시스템 상태:"
        ${BACKUP_ROOT}/scripts/backup-status.sh
        echo ""
        echo "☁️ 원격 저장소 상태:"
        ${BACKUP_ROOT}/scripts/remote-status.sh
    else
        echo "⚠️  일부 테스트가 실패했습니다."
        echo "❌ 실패한 테스트를 확인하고 문제를 해결해주세요."
        echo ""
        echo "📋 상세 로그: ${TEST_LOG}"
    fi
    
    echo ""
    echo "📁 생성된 백업 파일:"
    ls -la ${BACKUP_ROOT}/daily/ | head -10
    echo ""
    echo "📋 테스트 로그: ${TEST_LOG}"
    echo ""
}

# 메인 실행
main() {
    log "백업 시스템 종합 테스트 시작 - $(date)"
    
    run_comprehensive_test
    show_test_summary
    
    if [ $TESTS_FAILED -eq 0 ]; then
        log "🎉 모든 테스트 성공 - 백업 시스템 구축 완료!"
        exit 0
    else
        log "⚠️  일부 테스트 실패 - 문제 해결 필요"
        exit 1
    fi
}

main