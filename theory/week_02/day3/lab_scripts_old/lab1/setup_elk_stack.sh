#!/bin/bash

# Week 2 Day 3 Lab 1: ELK Stack 자동 구축
# 사용법: ./setup_elk_stack.sh

echo "=== ELK Stack 자동 구축 시작 ==="

# 1. ELK 설정 디렉토리 생성
echo "1. ELK 설정 디렉토리 생성 중..."
mkdir -p config/{elasticsearch,logstash,kibana,filebeat}

# 2. Elasticsearch 실행
echo "2. Elasticsearch 실행 중..."
docker run -d \
  --name elasticsearch \
  --restart=unless-stopped \
  -p 9200:9200 \
  -p 9300:9300 \
  -e "discovery.type=single-node" \
  -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
  -e "xpack.security.enabled=false" \
  -v elasticsearch-data:/usr/share/elasticsearch/data \
  --memory=1g \
  elasticsearch:7.17.0

# 3. Logstash 설정 파일 생성
echo "3. Logstash 설정 파일 생성 중..."
cat > config/logstash/logstash.conf << 'EOF'
input {
  beats {
    port => 5044
  }
}

filter {
  if [fields][service] == "nginx" {
    grok {
      match => { "message" => "%{COMBINEDAPACHELOG}" }
    }
    date {
      match => [ "timestamp", "dd/MMM/yyyy:HH:mm:ss Z" ]
    }
  }
  
  if [fields][service] == "mysql" {
    grok {
      match => { "message" => "%{TIMESTAMP_ISO8601:timestamp} %{NUMBER:thread_id} \\[%{WORD:level}\\] %{GREEDYDATA:mysql_message}" }
    }
  }
  
  if [fields][service] == "wordpress" {
    if [message] =~ /^\[/ {
      grok {
        match => { "message" => "\\[%{HTTPDATE:timestamp}\\] %{WORD:level}: %{GREEDYDATA:php_message}" }
      }
    }
  }
  
  # 공통 필드 추가
  mutate {
    add_field => { "environment" => "development" }
    add_field => { "cluster" => "docker-local" }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "logs-%{+YYYY.MM.dd}"
  }
  
  stdout {
    codec => rubydebug
  }
}
EOF

# 4. Elasticsearch 시작 대기
echo "4. Elasticsearch 시작 대기 중..."
sleep 30

# 5. Elasticsearch 상태 확인
echo "5. Elasticsearch 상태 확인 중..."
until curl -f http://localhost:9200/_cluster/health >/dev/null 2>&1; do
    echo "Elasticsearch 시작 대기 중..."
    sleep 10
done
echo "✅ Elasticsearch 정상 실행 중"

# 6. Logstash 실행
echo "6. Logstash 실행 중..."
docker run -d \
  --name logstash \
  --restart=unless-stopped \
  -p 5044:5044 \
  -v $(pwd)/config/logstash:/usr/share/logstash/pipeline \
  --link elasticsearch:elasticsearch \
  --memory=1g \
  logstash:7.17.0

# 7. Kibana 실행
echo "7. Kibana 실행 중..."
docker run -d \
  --name kibana \
  --restart=unless-stopped \
  -p 5601:5601 \
  -e ELASTICSEARCH_HOSTS=http://elasticsearch:9200 \
  --link elasticsearch:elasticsearch \
  --memory=512m \
  kibana:7.17.0

# 8. Filebeat 설정 파일 생성
echo "8. Filebeat 설정 파일 생성 중..."
cat > config/filebeat/filebeat.yml << 'EOF'
filebeat.inputs:
- type: container
  paths:
    - '/var/lib/docker/containers/*/*.log'
  processors:
    - add_docker_metadata:
        host: "unix:///var/run/docker.sock"

output.logstash:
  hosts: ["logstash:5044"]

logging.level: info
logging.to_files: true
logging.files:
  path: /var/log/filebeat
  name: filebeat
  keepfiles: 7
  permissions: 0644
EOF

# 9. Filebeat 실행
echo "9. Filebeat 실행 중..."
docker run -d \
  --name filebeat \
  --restart=unless-stopped \
  --user=root \
  -v $(pwd)/config/filebeat/filebeat.yml:/usr/share/filebeat/filebeat.yml:ro \
  -v /var/lib/docker/containers:/var/lib/docker/containers:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  --link logstash:logstash \
  --memory=256m \
  elastic/filebeat:7.17.0 filebeat -e -strict.perms=false

# 10. 서비스 상태 확인
echo "10. ELK Stack 서비스 상태 확인 중..."
sleep 60

echo "배포된 ELK Stack 서비스:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(elasticsearch|logstash|kibana|filebeat)"

# 11. Kibana 접속 확인
echo "11. Kibana 접속 확인 중..."
if curl -f http://localhost:5601 >/dev/null 2>&1; then
    echo "✅ Kibana 정상 실행 중"
else
    echo "⚠️ Kibana가 아직 시작 중입니다. 잠시 후 다시 확인하세요."
fi

echo ""
echo "=== ELK Stack 구축 완료 ==="
echo ""
echo "접속 정보:"
echo "- Elasticsearch: http://localhost:9200"
echo "- Kibana: http://localhost:5601"
echo "- Logstash: localhost:5044 (Beats input)"
echo ""
echo "다음 단계: ./setup_alerting_test.sh 실행"