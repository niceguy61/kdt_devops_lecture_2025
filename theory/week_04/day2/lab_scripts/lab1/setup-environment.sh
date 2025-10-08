#!/bin/bash

# Week 4 Day 2 Lab 1: 시스템 환경 준비
# 사용법: ./setup-environment.sh

echo "=========================================="
echo "  Week 4 Day 2 Lab 1: 시스템 환경 준비"
echo "  필수 도구 설치 및 환경 확인"
echo "=========================================="
echo ""

# OS 감지
OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    OS="windows"
fi

echo "🖥️  감지된 운영체제: $OS"
echo ""

# 필수 도구 확인 및 설치
echo "🔍 필수 도구 확인 중..."
echo ""

# Docker 확인
echo "1. Docker 확인 중..."
if command -v docker &> /dev/null; then
    docker_version=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
    echo "✅ Docker 설치됨 (버전: $docker_version)"
    
    # Docker 실행 상태 확인
    if docker info &> /dev/null; then
        echo "✅ Docker 서비스 실행 중"
    else
        echo "⚠️  Docker 서비스가 실행되지 않음"
        echo "   Docker Desktop을 시작하거나 Docker 서비스를 시작하세요"
        if [[ "$OS" == "linux" ]]; then
            echo "   sudo systemctl start docker"
        fi
    fi
else
    echo "❌ Docker가 설치되지 않음"
    echo "   Docker 설치 가이드:"
    if [[ "$OS" == "macos" ]]; then
        echo "   - Docker Desktop for Mac: https://docs.docker.com/desktop/mac/install/"
        echo "   - Homebrew: brew install --cask docker"
    elif [[ "$OS" == "linux" ]]; then
        echo "   - Ubuntu/Debian: sudo apt-get install docker.io"
        echo "   - CentOS/RHEL: sudo yum install docker"
    elif [[ "$OS" == "windows" ]]; then
        echo "   - Docker Desktop for Windows: https://docs.docker.com/desktop/windows/install/"
    fi
fi
echo ""

# jq 확인
echo "2. jq (JSON 파서) 확인 중..."
if command -v jq &> /dev/null; then
    jq_version=$(jq --version)
    echo "✅ jq 설치됨 ($jq_version)"
else
    echo "❌ jq가 설치되지 않음"
    echo "   jq 설치 방법:"
    if [[ "$OS" == "macos" ]]; then
        echo "   - Homebrew: brew install jq"
    elif [[ "$OS" == "linux" ]]; then
        echo "   - Ubuntu/Debian: sudo apt-get install jq"
        echo "   - CentOS/RHEL: sudo yum install jq"
    elif [[ "$OS" == "windows" ]]; then
        echo "   - Chocolatey: choco install jq"
        echo "   - 또는 https://stedolan.github.io/jq/download/"
    fi
    
    # 자동 설치 시도 (macOS/Linux)
    if [[ "$OS" == "macos" ]] && command -v brew &> /dev/null; then
        read -p "   Homebrew로 jq를 설치하시겠습니까? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            brew install jq
        fi
    elif [[ "$OS" == "linux" ]] && command -v apt-get &> /dev/null; then
        read -p "   apt-get으로 jq를 설치하시겠습니까? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo apt-get update && sudo apt-get install -y jq
        fi
    fi
fi
echo ""

# curl 확인
echo "3. curl 확인 중..."
if command -v curl &> /dev/null; then
    curl_version=$(curl --version | head -1 | cut -d' ' -f2)
    echo "✅ curl 설치됨 (버전: $curl_version)"
else
    echo "❌ curl이 설치되지 않음"
    echo "   curl 설치 방법:"
    if [[ "$OS" == "macos" ]]; then
        echo "   - 기본 설치되어 있어야 함. Xcode Command Line Tools 설치: xcode-select --install"
    elif [[ "$OS" == "linux" ]]; then
        echo "   - Ubuntu/Debian: sudo apt-get install curl"
        echo "   - CentOS/RHEL: sudo yum install curl"
    elif [[ "$OS" == "windows" ]]; then
        echo "   - Windows 10 1803+ 기본 포함"
        echo "   - 또는 Git Bash 사용"
    fi
fi
echo ""

# 네트워크 포트 확인
echo "4. 필요한 포트 사용 가능 여부 확인 중..."
required_ports=(8000 8001 8002 8500 3001 3002 3003 5432 27017 6379)
port_conflicts=()

for port in "${required_ports[@]}"; do
    if lsof -i :$port &> /dev/null; then
        port_conflicts+=($port)
        echo "⚠️  포트 $port: 사용 중"
    else
        echo "✅ 포트 $port: 사용 가능"
    fi
done

if [ ${#port_conflicts[@]} -gt 0 ]; then
    echo ""
    echo "⚠️  포트 충돌 발견: ${port_conflicts[*]}"
    echo "   실습 전에 해당 포트를 사용하는 프로세스를 종료하세요"
    echo "   포트 사용 프로세스 확인: lsof -i :<포트번호>"
fi
echo ""

# Docker 이미지 사전 다운로드
echo "5. Docker 이미지 사전 다운로드 (선택사항)..."
if command -v docker &> /dev/null && docker info &> /dev/null; then
    read -p "   실습에 필요한 Docker 이미지를 미리 다운로드하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "   Docker 이미지 다운로드 중..."
        images=(
            "consul:1.15"
            "kong:3.4"
            "postgres:13"
            "mongo:5"
            "redis:7-alpine"
            "node:16-alpine"
        )
        
        for image in "${images[@]}"; do
            echo "   - $image 다운로드 중..."
            docker pull $image &> /dev/null &
        done
        
        # 모든 다운로드 완료 대기
        wait
        echo "   ✅ 모든 이미지 다운로드 완료"
    fi
else
    echo "   ⚠️  Docker가 실행되지 않아 이미지 다운로드를 건너뜁니다"
fi
echo ""

# 디스크 공간 확인
echo "6. 디스크 공간 확인 중..."
if [[ "$OS" == "macos" || "$OS" == "linux" ]]; then
    available_space=$(df -h . | awk 'NR==2 {print $4}')
    echo "✅ 사용 가능한 디스크 공간: $available_space"
    
    # 최소 2GB 권장
    available_gb=$(df . | awk 'NR==2 {print int($4/1024/1024)}')
    if [ $available_gb -lt 2 ]; then
        echo "⚠️  디스크 공간 부족 (최소 2GB 권장)"
    fi
fi
echo ""

# 메모리 확인
echo "7. 시스템 메모리 확인 중..."
if [[ "$OS" == "macos" ]]; then
    total_mem=$(sysctl -n hw.memsize | awk '{print int($1/1024/1024/1024)}')
    echo "✅ 총 메모리: ${total_mem}GB"
elif [[ "$OS" == "linux" ]]; then
    total_mem=$(free -g | awk 'NR==2{print $2}')
    echo "✅ 총 메모리: ${total_mem}GB"
fi

if [ $total_mem -lt 4 ]; then
    echo "⚠️  메모리 부족 (최소 4GB 권장)"
fi
echo ""

# 환경 준비 완료 확인
echo "=========================================="
echo "🔍 환경 준비 상태 요약"
echo "=========================================="

all_ready=true

# 필수 도구 체크
if ! command -v docker &> /dev/null; then
    echo "❌ Docker: 설치 필요"
    all_ready=false
else
    if docker info &> /dev/null; then
        echo "✅ Docker: 준비 완료"
    else
        echo "⚠️  Docker: 서비스 시작 필요"
        all_ready=false
    fi
fi

if ! command -v jq &> /dev/null; then
    echo "❌ jq: 설치 필요"
    all_ready=false
else
    echo "✅ jq: 준비 완료"
fi

if ! command -v curl &> /dev/null; then
    echo "❌ curl: 설치 필요"
    all_ready=false
else
    echo "✅ curl: 준비 완료"
fi

# 포트 충돌 체크
if [ ${#port_conflicts[@]} -gt 0 ]; then
    echo "⚠️  포트 충돌: ${#port_conflicts[@]}개 포트 사용 중"
    all_ready=false
else
    echo "✅ 포트: 모두 사용 가능"
fi

echo ""
if [ "$all_ready" = true ]; then
    echo "🎉 환경 준비 완료!"
    echo ""
    echo "다음 단계:"
    echo "1. 전체 실습 환경 구축: ./setup-all-services.sh"
    echo "2. 또는 단계별 실행:"
    echo "   - ./setup-network.sh"
    echo "   - ./setup-consul.sh"
    echo "   - ./deploy-user-service.sh"
    echo "   - ..."
else
    echo "⚠️  환경 준비 미완료"
    echo ""
    echo "해결해야 할 사항:"
    echo "1. 위에 표시된 ❌ 항목들을 설치/해결하세요"
    echo "2. Docker 서비스가 실행 중인지 확인하세요"
    echo "3. 포트 충돌이 있다면 해당 프로세스를 종료하세요"
    echo ""
    echo "모든 문제 해결 후 다시 실행하세요: ./setup-environment.sh"
fi

echo "=========================================="
