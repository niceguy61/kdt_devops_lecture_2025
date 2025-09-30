#!/bin/bash

# Week 2 Day 3 Lab 2: 실습 환경 정리
# 사용법: ./cleanup.sh

echo "=== Lab 2 실습 환경 정리 시작 ==="

# 1. 사용자 확인
read -p "모든 Swarm 클러스터와 서비스를 정리하시겠습니까? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "정리를 취소했습니다."
    exit 0
fi

# 2. 배포된 스택 제거
echo "1. 배포된 스택 제거 중..."
if docker stack ls >/dev/null 2>&1; then
    STACKS=$(docker stack ls --format "{{.Name}}")
    
    if [ -n "$STACKS" ]; then
        echo "제거할 스택: $STACKS"
        for stack in $STACKS; do
            echo "스택 $stack 제거 중..."
            docker stack rm $stack
        done
        
        # 스택 제거 완료 대기
        echo "스택 제거 완료 대기 중..."
        sleep 30
        
        # 남은 서비스 강제 제거
        REMAINING_SERVICES=$(docker service ls -q 2>/dev/null)
        if [ -n "$REMAINING_SERVICES" ]; then
            echo "남은 서비스 강제 제거 중..."
            docker service rm $REMAINING_SERVICES 2>/dev/null
        fi
        
        echo "✅ 모든 스택 제거 완료"
    else
        echo "⏭️ 제거할 스택이 없습니다."
    fi
else
    echo "⏭️ Swarm 모드가 활성화되지 않았습니다."
fi

# 3. Docker Config 및 Secret 정리
echo "2. Docker Config 및 Secret 정리 중..."
CONFIGS=$(docker config ls -q 2>/dev/null)
if [ -n "$CONFIGS" ]; then
    echo "Config 제거 중..."
    docker config rm $CONFIGS 2>/dev/null || echo "일부 Config 제거 실패 (사용 중일 수 있음)"
fi

SECRETS=$(docker secret ls -q 2>/dev/null)
if [ -n "$SECRETS" ]; then
    echo "Secret 제거 중..."
    docker secret rm $SECRETS 2>/dev/null || echo "일부 Secret 제거 실패 (사용 중일 수 있음)"
fi

# 4. 가상 노드 컨테이너 제거
echo "3. 가상 노드 컨테이너 제거 중..."
VIRTUAL_NODES="manager-2 manager-3 worker-1 worker-2 worker-3"

for node in $VIRTUAL_NODES; do
    if docker ps -a --format "{{.Names}}" | grep -q "^${node}$"; then
        echo "$node 제거 중..."
        docker rm -f $node 2>/dev/null
    fi
done

echo "✅ 가상 노드 컨테이너 제거 완료"

# 5. Swarm 클러스터 해제
echo "4. Swarm 클러스터 해제 중..."
if docker info --format '{{.Swarm.LocalNodeState}}' | grep -q active; then
    docker swarm leave --force
    echo "✅ Swarm 클러스터 해제 완료"
else
    echo "⏭️ Swarm 클러스터가 이미 비활성화되어 있습니다."
fi

# 6. 오버레이 네트워크 정리
echo "5. 오버레이 네트워크 정리 중..."
OVERLAY_NETWORKS=$(docker network ls --filter driver=overlay --format "{{.Name}}" | grep -v ingress)

if [ -n "$OVERLAY_NETWORKS" ]; then
    for network in $OVERLAY_NETWORKS; do
        echo "네트워크 $network 제거 중..."
        docker network rm $network 2>/dev/null || echo "네트워크 $network 제거 실패"
    done
    echo "✅ 오버레이 네트워크 정리 완료"
else
    echo "⏭️ 제거할 오버레이 네트워크가 없습니다."
fi

# 7. 볼륨 정리 (선택적)
echo "6. 볼륨 정리 옵션..."
read -p "Swarm 관련 볼륨을 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    SWARM_VOLUMES=$(docker volume ls --format "{{.Name}}" | grep -E "(mysql-data|wp-content|prometheus-data|grafana-data)")
    
    if [ -n "$SWARM_VOLUMES" ]; then
        echo "Swarm 관련 볼륨 제거 중..."
        for volume in $SWARM_VOLUMES; do
            echo "볼륨 $volume 제거 중..."
            docker volume rm $volume 2>/dev/null || echo "볼륨 $volume 제거 실패 (사용 중일 수 있음)"
        done
        echo "✅ Swarm 볼륨 정리 완료"
    else
        echo "⏭️ 제거할 Swarm 볼륨이 없습니다."
    fi
else
    echo "⏭️ 볼륨은 보존됩니다."
fi

# 8. 생성된 파일 정리 (선택적)
echo "7. 생성된 파일 정리 옵션..."
read -p "실습 중 생성된 파일들을 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # 스택 디렉토리 제거
    if [ -d "stacks" ]; then
        rm -rf stacks/
        echo "✅ stacks/ 디렉토리 제거 완료"
    fi
    
    # 설정 디렉토리 제거
    if [ -d "configs" ]; then
        rm -rf configs/
        echo "✅ configs/ 디렉토리 제거 완료"
    fi
    
    # 생성된 스크립트 파일 제거
    GENERATED_FILES="create-networks.sh cluster-info.txt load-balancing-test.sh"
    for file in $GENERATED_FILES; do
        if [ -f "$file" ]; then
            rm "$file"
            echo "✅ $file 제거 완료"
        fi
    done
else
    echo "⏭️ 생성된 파일들은 보존됩니다."
fi

# 9. Lab 1 모니터링 컨테이너 정리 (선택적)
echo "8. Lab 1 모니터링 컨테이너 정리 옵션..."
read -p "Lab 1에서 생성한 모니터링 컨테이너도 정리하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    LAB1_CONTAINERS="prometheus grafana alertmanager elasticsearch logstash kibana filebeat cadvisor node-exporter mysql-exporter webhook"
    
    echo "Lab 1 모니터링 컨테이너 제거 중..."
    for container in $LAB1_CONTAINERS; do
        if docker ps -a --format "{{.Names}}" | grep -q "^${container}$"; then
            echo "$container 제거 중..."
            docker rm -f $container 2>/dev/null
        fi
    done
    
    # Lab 1 관련 볼륨 제거
    LAB1_VOLUMES="prometheus-data grafana-data elasticsearch-data"
    for volume in $LAB1_VOLUMES; do
        if docker volume ls --format "{{.Name}}" | grep -q "^${volume}$"; then
            echo "볼륨 $volume 제거 중..."
            docker volume rm $volume 2>/dev/null || echo "볼륨 $volume 제거 실패"
        fi
    done
    
    echo "✅ Lab 1 모니터링 컨테이너 정리 완료"
else
    echo "⏭️ Lab 1 모니터링 컨테이너는 보존됩니다."
fi

# 10. 네트워크 정리
echo "9. 추가 네트워크 정리 중..."
CUSTOM_NETWORKS=$(docker network ls --format "{{.Name}}" | grep -E "swarm-net")

if [ -n "$CUSTOM_NETWORKS" ]; then
    for network in $CUSTOM_NETWORKS; do
        echo "네트워크 $network 제거 중..."
        docker network rm $network 2>/dev/null || echo "네트워크 $network 제거 실패"
    done
fi

# 11. Docker 시스템 정리 (선택적)
echo "10. Docker 시스템 정리 옵션..."
read -p "사용하지 않는 Docker 리소스를 정리하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Docker 시스템 정리 중..."
    docker system prune -f
    echo "✅ Docker 시스템 정리 완료"
else
    echo "⏭️ Docker 시스템 정리를 건너뜁니다."
fi

# 12. 정리 완료 확인
echo ""
echo "=== Lab 2 실습 환경 정리 완료 ==="
echo ""

# 현재 상태 확인
echo "📊 정리 후 상태:"
echo ""

echo "Swarm 상태:"
SWARM_STATE=$(docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null)
echo "  $SWARM_STATE"

echo ""
echo "실행 중인 컨테이너:"
RUNNING_CONTAINERS=$(docker ps --format "{{.Names}}" | wc -l)
if [ "$RUNNING_CONTAINERS" -eq 0 ]; then
    echo "  없음"
else
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
fi

echo ""
echo "Docker 볼륨:"
VOLUMES=$(docker volume ls --format "{{.Name}}" | wc -l)
if [ "$VOLUMES" -eq 0 ]; then
    echo "  없음"
else
    docker volume ls --format "table {{.Name}}\t{{.Driver}}"
fi

echo ""
echo "Docker 네트워크:"
NETWORKS=$(docker network ls --format "{{.Name}}" | grep -v -E "^(bridge|host|none)$" | wc -l)
if [ "$NETWORKS" -eq 0 ]; then
    echo "  기본 네트워크만 존재"
else
    docker network ls --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}" | grep -v -E "^(bridge|host|none)"
fi

echo ""
echo "🎉 실습 환경 정리가 완료되었습니다!"
echo "수고하셨습니다! 🎉"