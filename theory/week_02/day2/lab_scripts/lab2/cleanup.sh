#!/bin/bash

# Week 2 Day 2 Lab 2: 실습 환경 정리
# 사용법: ./cleanup.sh

echo "=== Lab 2 실습 환경 정리 시작 ==="

# 1. 사용자 확인
read -p "모든 실습 환경을 정리하시겠습니까? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "정리를 취소했습니다."
    exit 0
fi

# 2. 백업 스케줄 제거
echo "1. 백업 스케줄 제거 중..."
if crontab -l 2>/dev/null | grep -q backup; then
    crontab -l | grep -v backup > /tmp/crontab.clean
    crontab /tmp/crontab.clean
    rm /tmp/crontab.clean
    echo "✅ 백업 스케줄 제거 완료"
else
    echo "⏭️ 설정된 백업 스케줄이 없습니다."
fi

# 3. 실행 중인 프로세스 정리
echo "2. 실행 중인 백업 프로세스 정리 중..."
pkill -f "backup-main.sh" 2>/dev/null
pkill -f "health-check.sh" 2>/dev/null
echo "✅ 백그라운드 프로세스 정리 완료"

# 4. 컨테이너 정리 (선택적)
echo "3. 컨테이너 정리 옵션..."
read -p "WordPress 시스템도 함께 정리하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "WordPress 시스템 정리 중..."
    
    # 컨테이너 중지 및 제거
    docker stop wordpress-app nginx-proxy mysql-wordpress redis-session 2>/dev/null
    docker rm wordpress-app nginx-proxy mysql-wordpress redis-session 2>/dev/null
    
    # 볼륨 제거 (데이터 손실 주의)
    read -p "데이터 볼륨도 삭제하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker volume rm wp-content wp-config mysql-data mysql-config redis-data nginx-logs 2>/dev/null
        echo "✅ 데이터 볼륨 삭제 완료"
    else
        echo "⏭️ 데이터 볼륨은 보존됩니다."
    fi
    
    echo "✅ WordPress 시스템 정리 완료"
else
    echo "⏭️ WordPress 시스템은 유지됩니다."
fi

# 5. 백업 파일 정리 (선택적)
echo "4. 백업 파일 정리 옵션..."
if [ -d "backup" ]; then
    read -p "생성된 백업 파일을 삭제하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf backup/
        echo "✅ 백업 파일 삭제 완료"
    else
        echo "⏭️ 백업 파일은 보존됩니다."
    fi
else
    echo "⏭️ 백업 디렉토리가 없습니다."
fi

# 6. 설정 파일 정리 (선택적)
echo "5. 설정 파일 정리 옵션..."
if [ -d "config" ]; then
    read -p "생성된 설정 파일을 삭제하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf config/
        echo "✅ 설정 파일 삭제 완료"
    else
        echo "⏭️ 설정 파일은 보존됩니다."
    fi
else
    echo "⏭️ 설정 디렉토리가 없습니다."
fi

# 7. 스크립트 파일 정리 (선택적)
echo "6. 스크립트 파일 정리 옵션..."
if [ -d "scripts" ]; then
    read -p "생성된 스크립트 파일을 삭제하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf scripts/
        echo "✅ 스크립트 파일 삭제 완료"
    else
        echo "⏭️ 스크립트 파일은 보존됩니다."
    fi
else
    echo "⏭️ 스크립트 디렉토리가 없습니다."
fi

# 8. 로그 파일 정리
echo "7. 로그 파일 정리 중..."
rm -f health.log nohup.out 2>/dev/null
echo "✅ 로그 파일 정리 완료"

# 9. Docker 시스템 정리 (선택적)
echo "8. Docker 시스템 정리 옵션..."
read -p "사용하지 않는 Docker 리소스를 정리하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker system prune -f
    echo "✅ Docker 시스템 정리 완료"
else
    echo "⏭️ Docker 시스템 정리를 건너뜁니다."
fi

# 10. 정리 완료 확인
echo ""
echo "=== Lab 2 실습 환경 정리 완료 ==="
echo ""
echo "정리된 항목:"
echo "- ✅ 백업 스케줄 (cron jobs)"
echo "- ✅ 백그라운드 프로세스"
echo "- ✅ 로그 파일"
echo ""
echo "현재 상태:"
echo "실행 중인 컨테이너:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo "남은 볼륨:"
docker volume ls | grep -E "(wp-|mysql-|redis-|nginx-)" || echo "관련 볼륨 없음"
echo ""
echo "실습 환경 정리가 완료되었습니다!"
echo "수고하셨습니다! 🎉"