#!/bin/bash

# Week 2 Day 3 Lab 2: 서비스 배포 및 스케일링 자동 실행
# 사용법: ./deploy_and_scale_services.sh

echo "=== 서비스 배포 및 스케일링 자동 실행 시작 ==="

# 1. 현재 서비스 상태 확인
echo "1. 현재 서비스 상태 확인 중..."
if ! docker service ls >/dev/null 2>&1; then
    echo "❌ Swarm 서비스를 찾을 수 없습니다."
    echo "먼저 ./deploy_service_stack.sh를 실행하세요."
    exit 1
fi

echo "현재 배포된 서비스:"
docker service ls --format "table {{.Name}}\t{{.Replicas}}\t{{.Image}}"

# 2. 서비스 스케일링 테스트
echo ""
echo "2. 서비스 스케일링 테스트 중..."

# WordPress 서비스 스케일 업
echo "WordPress 서비스 스케일 업 (2 -> 3)..."
docker service scale web_wordpress=3

# Nginx 서비스 스케일 업
echo "Nginx 서비스 스케일 업 (2 -> 4)..."
docker service scale web_nginx=4

# 스케일링 완료 대기
echo "스케일링 완료 대기 중..."
sleep 30

echo "스케일링 후 서비스 상태:"
docker service ls --format "table {{.Name}}\t{{.Replicas}}\t{{.Image}}"

# 3. 서비스 업데이트 테스트
echo ""
echo "3. 서비스 업데이트 테스트 중..."

# WordPress 이미지 업데이트 (롤링 업데이트)
echo "WordPress 롤링 업데이트 실행 중..."
docker service update \
    --image wordpress:6.1 \
    --update-delay 30s \
    --update-parallelism 1 \
    --update-failure-action rollback \
    web_wordpress

# 업데이트 진행 상황 모니터링
echo "업데이트 진행 상황 모니터링 중..."
for i in {1..10}; do
    echo "업데이트 상태 확인 ($i/10):"
    docker service ps web_wordpress --format "table {{.Name}}\t{{.Image}}\t{{.CurrentState}}\t{{.Node}}"
    sleep 15
done

# 4. 로드 밸런싱 테스트
echo ""
echo "4. 로드 밸런싱 테스트 중..."

# 부하 테스트 스크립트 생성
cat > load-balancing-test.sh << 'EOF'
#!/bin/bash

echo "🔄 로드 밸런싱 테스트 시작"

# 여러 요청을 보내서 로드 밸런싱 확인
for i in {1..20}; do
    response=$(curl -s -w "%{http_code}" http://localhost/health -o /dev/null)
    if [ "$response" = "200" ]; then
        echo "요청 $i: ✅ 성공 (HTTP $response)"
    else
        echo "요청 $i: ❌ 실패 (HTTP $response)"
    fi
    sleep 0.5
done

echo "로드 밸런싱 테스트 완료"
EOF

chmod +x load-balancing-test.sh
./load-balancing-test.sh

# 5. 서비스 배치 확인
echo ""
echo "5. 서비스 배치 확인 중..."

echo "📍 서비스별 노드 배치 현황:"
for service in $(docker service ls --format "{{.Name}}"); do
    echo ""
    echo "🔧 $service:"
    docker service ps $service --format "  {{.Name}} -> {{.Node}} ({{.CurrentState}})"
done

# 6. 네트워크 연결성 테스트
echo ""
echo "6. 네트워크 연결성 테스트 중..."

# 서비스 간 통신 테스트
echo "서비스 간 네트워크 연결성 확인:"

# WordPress에서 MySQL 연결 테스트
WP_CONTAINER=$(docker ps --filter "label=com.docker.swarm.service.name=web_wordpress" --format "{{.Names}}" | head -1)
if [ -n "$WP_CONTAINER" ]; then
    echo "WordPress -> MySQL 연결 테스트:"
    docker exec $WP_CONTAINER sh -c "nc -z mysql 3306" && echo "  ✅ MySQL 연결 성공" || echo "  ❌ MySQL 연결 실패"
else
    echo "  ⚠️ WordPress 컨테이너를 찾을 수 없습니다."
fi

# 7. 장애 시뮬레이션 및 복구 테스트
echo ""
echo "7. 장애 시뮬레이션 및 복구 테스트..."

read -p "노드 장애 시뮬레이션을 실행하시겠습니까? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Worker 노드 장애 시뮬레이션 실행 중..."
    
    # Worker 노드 중 하나를 drain 상태로 변경
    WORKER_NODE=$(docker node ls --filter role=worker --format "{{.Hostname}}" | head -1)
    
    if [ -n "$WORKER_NODE" ]; then
        echo "노드 $WORKER_NODE를 drain 상태로 변경..."
        docker node update --availability drain $WORKER_NODE
        
        echo "서비스 재배치 대기 중..."
        sleep 30
        
        echo "재배치 후 서비스 상태:"
        docker service ps web_wordpress --format "table {{.Name}}\t{{.Node}}\t{{.CurrentState}}"
        
        # 노드 복구
        echo "노드 $WORKER_NODE 복구 중..."
        docker node update --availability active $WORKER_NODE
        
        echo "✅ 장애 복구 시뮬레이션 완료"
    else
        echo "⚠️ Worker 노드를 찾을 수 없습니다."
    fi
else
    echo "장애 시뮬레이션을 건너뜁니다."
fi

# 8. 성능 메트릭 수집
echo ""
echo "8. 성능 메트릭 수집 중..."

# 서비스별 리소스 사용량 확인
echo "📊 서비스별 리소스 사용량:"
for service in $(docker service ls --format "{{.Name}}"); do
    replicas=$(docker service ls --filter name=$service --format "{{.Replicas}}")
    echo "  $service: $replicas 복제본"
done

# cAdvisor에서 메트릭 확인
if curl -f http://localhost:8080/metrics >/dev/null 2>&1; then
    echo "✅ cAdvisor 메트릭 수집 중"
    
    # 컨테이너 CPU 사용률 샘플
    cpu_metrics=$(curl -s http://localhost:8080/metrics | grep "container_cpu_usage_seconds_total" | wc -l)
    echo "  수집된 CPU 메트릭: $cpu_metrics개"
else
    echo "⚠️ cAdvisor 메트릭 수집 실패"
fi

# 9. 서비스 로그 확인
echo ""
echo "9. 서비스 로그 확인 중..."

echo "📝 최근 서비스 로그 (최근 10줄):"
for service in web_nginx web_wordpress database_mysql; do
    if docker service ls --filter name=$service --format "{{.Name}}" | grep -q $service; then
        echo ""
        echo "🔍 $service 로그:"
        docker service logs $service --tail 5 2>/dev/null || echo "  로그를 가져올 수 없습니다."
    fi
done

# 10. 최종 상태 리포트
echo ""
echo "=== 서비스 배포 및 스케일링 완료 ==="
echo ""

# 최종 서비스 상태
echo "📊 최종 서비스 상태:"
docker service ls --format "table {{.Name}}\t{{.Replicas}}\t{{.Image}}\t{{.Ports}}"

echo ""
echo "🏷️ 노드 상태:"
docker node ls --format "table {{.Hostname}}\t{{.Status}}\t{{.Availability}}\t{{.ManagerStatus}}"

echo ""
echo "🌐 접속 테스트:"
if curl -f http://localhost/health >/dev/null 2>&1; then
    echo "✅ 웹 서비스: http://localhost/ (정상)"
else
    echo "⚠️ 웹 서비스: http://localhost/ (확인 필요)"
fi

if curl -f http://localhost:9090/-/healthy >/dev/null 2>&1; then
    echo "✅ Prometheus: http://localhost:9090 (정상)"
else
    echo "⚠️ Prometheus: http://localhost:9090 (확인 필요)"
fi

if curl -f http://localhost:3000 >/dev/null 2>&1; then
    echo "✅ Grafana: http://localhost:3000 (정상)"
else
    echo "⚠️ Grafana: http://localhost:3000 (확인 필요)"
fi

echo ""
echo "🔧 유용한 명령어:"
echo "- 서비스 스케일링: docker service scale <service>=<replicas>"
echo "- 서비스 업데이트: docker service update --image <image> <service>"
echo "- 서비스 롤백: docker service rollback <service>"
echo "- 노드 관리: docker node update --availability <active|pause|drain> <node>"
echo "- 로그 확인: docker service logs <service>"
echo ""
echo "📁 생성된 파일:"
echo "- load-balancing-test.sh: 로드 밸런싱 테스트 스크립트"