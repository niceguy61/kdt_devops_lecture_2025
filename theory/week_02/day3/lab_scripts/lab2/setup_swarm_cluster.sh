#!/bin/bash

# Week 2 Day 3 Lab 2: Swarm 클러스터 자동 구성
# 사용법: ./setup_swarm_cluster.sh

echo "=== Docker Swarm 클러스터 자동 구성 시작 ==="

# 1. 기존 Swarm 상태 확인 및 정리
echo "1. 기존 Swarm 상태 확인 중..."
if docker info --format '{{.Swarm.LocalNodeState}}' | grep -q active; then
    echo "⚠️ 기존 Swarm 클러스터가 활성화되어 있습니다."
    read -p "기존 클러스터를 제거하고 새로 구성하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "기존 Swarm 클러스터 해제 중..."
        docker swarm leave --force 2>/dev/null || true
        
        # 기존 가상 노드들 정리
        docker rm -f manager-2 manager-3 worker-1 worker-2 worker-3 2>/dev/null || true
    else
        echo "기존 클러스터를 유지합니다."
        exit 0
    fi
fi

# 2. 네트워크 준비
echo "2. 클러스터 네트워크 준비 중..."
docker network create --driver bridge swarm-net 2>/dev/null || echo "네트워크가 이미 존재합니다."

# 3. Swarm 클러스터 초기화
echo "3. Swarm 클러스터 초기화 중..."
MANAGER_IP=$(hostname -I | awk '{print $1}')
echo "Manager IP: $MANAGER_IP"

docker swarm init --advertise-addr $MANAGER_IP

if [ $? -eq 0 ]; then
    echo "✅ Swarm 클러스터 초기화 완료"
else
    echo "❌ Swarm 클러스터 초기화 실패"
    exit 1
fi

# 4. 조인 토큰 획득
echo "4. 조인 토큰 획득 중..."
MANAGER_TOKEN=$(docker swarm join-token manager -q)
WORKER_TOKEN=$(docker swarm join-token worker -q)

echo "Manager Token: $MANAGER_TOKEN"
echo "Worker Token: $WORKER_TOKEN"

# 5. 가상 Manager 노드 추가 (시뮬레이션)
echo "5. 추가 Manager 노드 생성 중..."

for i in 2 3; do
    echo "Manager-$i 노드 생성 중..."
    
    docker run -d \
        --name manager-$i \
        --hostname manager-$i \
        --privileged \
        --network swarm-net \
        -v /var/lib/docker \
        -e DOCKER_TLS_CERTDIR="" \
        docker:dind
    
    # Docker 데몬 시작 대기
    sleep 15
    
    # Swarm 조인
    docker exec manager-$i docker swarm join \
        --token $MANAGER_TOKEN $MANAGER_IP:2377
    
    if [ $? -eq 0 ]; then
        echo "✅ Manager-$i 조인 완료"
    else
        echo "❌ Manager-$i 조인 실패"
    fi
done

# 6. Worker 노드 추가 (시뮬레이션)
echo "6. Worker 노드 생성 중..."

for i in 1 2 3; do
    echo "Worker-$i 노드 생성 중..."
    
    docker run -d \
        --name worker-$i \
        --hostname worker-$i \
        --privileged \
        --network swarm-net \
        -v /var/lib/docker \
        -e DOCKER_TLS_CERTDIR="" \
        docker:dind
    
    # Docker 데몬 시작 대기
    sleep 15
    
    # Swarm 조인
    docker exec worker-$i docker swarm join \
        --token $WORKER_TOKEN $MANAGER_IP:2377
    
    if [ $? -eq 0 ]; then
        echo "✅ Worker-$i 조인 완료"
    else
        echo "❌ Worker-$i 조인 실패"
    fi
done

# 7. 노드 레이블링
echo "7. 노드 레이블링 중..."

# 잠시 대기 (노드 등록 완료 대기)
sleep 10

# 노드 역할별 레이블 설정
docker node update --label-add role=web worker-1 2>/dev/null || echo "Worker-1 레이블 설정 실패"
docker node update --label-add role=api worker-2 2>/dev/null || echo "Worker-2 레이블 설정 실패"
docker node update --label-add role=database worker-3 2>/dev/null || echo "Worker-3 레이블 설정 실패"
docker node update --label-add storage=ssd worker-3 2>/dev/null || echo "Worker-3 스토리지 레이블 설정 실패"

# Manager 노드 레이블
docker node update --label-add role=manager $(docker node ls --filter role=manager --format "{{.Hostname}}" | head -1) 2>/dev/null

# 8. 클러스터 상태 확인
echo "8. 클러스터 상태 확인 중..."
sleep 5

echo ""
echo "📊 Swarm 클러스터 상태:"
docker node ls

echo ""
echo "🏷️ 노드 레이블 확인:"
for node in $(docker node ls --format "{{.Hostname}}"); do
    labels=$(docker node inspect $node --format '{{range $k, $v := .Spec.Labels}}{{$k}}={{$v}} {{end}}' 2>/dev/null)
    if [ -n "$labels" ]; then
        echo "  $node: $labels"
    else
        echo "  $node: (레이블 없음)"
    fi
done

# 9. 네트워크 생성 준비
echo ""
echo "9. 오버레이 네트워크 생성 준비 중..."
cat > create-networks.sh << 'EOF'
#!/bin/bash
echo "오버레이 네트워크 생성 중..."

docker network create --driver overlay --attachable frontend-net
docker network create --driver overlay --attachable backend-net
docker network create --driver overlay --attachable database-net
docker network create --driver overlay --attachable monitoring-net

echo "생성된 네트워크:"
docker network ls --filter driver=overlay
EOF

chmod +x create-networks.sh

# 10. 클러스터 정보 저장
echo "10. 클러스터 정보 저장 중..."
cat > cluster-info.txt << EOF
=== Docker Swarm 클러스터 정보 ===

Manager IP: $MANAGER_IP
Manager Token: $MANAGER_TOKEN
Worker Token: $WORKER_TOKEN

생성 시간: $(date)

노드 구성:
- Manager 노드: 3개 (manager-1, manager-2, manager-3)
- Worker 노드: 3개 (worker-1, worker-2, worker-3)

노드 역할:
- worker-1: role=web
- worker-2: role=api  
- worker-3: role=database, storage=ssd

다음 단계:
1. ./create-networks.sh - 오버레이 네트워크 생성
2. ./deploy_service_stack.sh - 서비스 스택 배포
EOF

echo ""
echo "=== Docker Swarm 클러스터 구성 완료 ==="
echo ""
echo "📋 클러스터 요약:"
echo "- Manager 노드: 3개"
echo "- Worker 노드: 3개"
echo "- 총 노드: 6개"
echo ""
echo "📁 생성된 파일:"
echo "- cluster-info.txt: 클러스터 정보"
echo "- create-networks.sh: 네트워크 생성 스크립트"
echo ""
echo "🔗 다음 단계:"
echo "1. ./create-networks.sh"
echo "2. ./deploy_service_stack.sh"
echo ""
echo "📊 클러스터 상태 확인:"
echo "  docker node ls"
echo "  docker info --format '{{.Swarm.LocalNodeState}}'"