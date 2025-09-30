#!/bin/bash

# Week 2 Day 3 Lab 2: Grafana 통합 대시보드 설정
# 사용법: ./setup_grafana_dashboards.sh

echo "=== Grafana 통합 관측성 대시보드 설정 시작 ==="

cd ~/docker-tracing-lab

# Grafana 프로비저닝 디렉토리 생성
echo "1. Grafana 프로비저닝 디렉토리 생성 중..."
mkdir -p grafana/provisioning/{datasources,dashboards}

# 데이터소스 설정
echo "2. 데이터소스 설정 생성 중..."
cat > grafana/provisioning/datasources/datasources.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true

  - name: Jaeger
    type: jaeger
    access: proxy
    url: http://jaeger:16686
    editable: true
    
  - name: OTEL Metrics
    type: prometheus
    access: proxy
    url: http://otel-collector:8889
    editable: true
EOF

# 대시보드 프로비저닝 설정
echo "3. 대시보드 프로비저닝 설정 생성 중..."
cat > grafana/provisioning/dashboards/dashboards.yml << 'EOF'
apiVersion: 1

providers:
  - name: 'observability'
    orgId: 1
    folder: 'Observability'
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards
EOF

# 통합 관측성 대시보드 생성
echo "4. 통합 관측성 대시보드 생성 중..."
cat > grafana/provisioning/dashboards/observability-dashboard.json << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "Complete Observability Stack - Metrics & Tracing",
    "tags": ["observability", "tracing", "metrics", "opentelemetry"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "🚀 Request Rate (RPS)",
        "type": "stat",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total[5m]))",
            "legendFormat": "Total RPS",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "thresholds"
            },
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 10},
                {"color": "red", "value": 50}
              ]
            },
            "unit": "reqps"
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 0, "y": 0}
      },
      {
        "id": 2,
        "title": "⚡ Response Time P95",
        "type": "stat",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))",
            "legendFormat": "P95 Latency",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "thresholds"
            },
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 0.5},
                {"color": "red", "value": 1}
              ]
            },
            "unit": "s"
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 6, "y": 0}
      },
      {
        "id": 3,
        "title": "❌ Error Rate",
        "type": "stat",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total{status=~\"5..\"}[5m])) / sum(rate(http_requests_total[5m])) * 100",
            "legendFormat": "Error Rate %",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "thresholds"
            },
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 1},
                {"color": "red", "value": 5}
              ]
            },
            "unit": "percent"
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 12, "y": 0}
      },
      {
        "id": 4,
        "title": "🔄 Active Services",
        "type": "stat",
        "targets": [
          {
            "expr": "count(up == 1)",
            "legendFormat": "Services Up",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "thresholds"
            },
            "thresholds": {
              "steps": [
                {"color": "red", "value": null},
                {"color": "yellow", "value": 3},
                {"color": "green", "value": 5}
              ]
            }
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 18, "y": 0}
      },
      {
        "id": 5,
        "title": "📊 Request Rate by Service",
        "type": "timeseries",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total[5m])) by (job)",
            "legendFormat": "{{job}}",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "custom": {
              "drawStyle": "line",
              "lineInterpolation": "linear",
              "barAlignment": 0,
              "lineWidth": 2,
              "fillOpacity": 10,
              "gradientMode": "none",
              "spanNulls": false,
              "insertNulls": false,
              "showPoints": "never",
              "pointSize": 5,
              "stacking": {
                "mode": "none",
                "group": "A"
              },
              "axisPlacement": "auto",
              "axisLabel": "",
              "scaleDistribution": {
                "type": "linear"
              },
              "hideFrom": {
                "legend": false,
                "tooltip": false,
                "vis": false
              },
              "thresholdsStyle": {
                "mode": "off"
              }
            },
            "color": {
              "mode": "palette-classic"
            },
            "unit": "reqps"
          }
        },
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 8}
      },
      {
        "id": 6,
        "title": "⏱️ Response Time Distribution",
        "type": "timeseries",
        "targets": [
          {
            "expr": "histogram_quantile(0.50, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, job))",
            "legendFormat": "P50 - {{job}}",
            "refId": "A"
          },
          {
            "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, job))",
            "legendFormat": "P95 - {{job}}",
            "refId": "B"
          },
          {
            "expr": "histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, job))",
            "legendFormat": "P99 - {{job}}",
            "refId": "C"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "palette-classic"
            },
            "unit": "s"
          }
        },
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 8}
      },
      {
        "id": 7,
        "title": "🔍 Jaeger Tracing Integration",
        "type": "text",
        "options": {
          "content": "## 🔍 Distributed Tracing with Jaeger\n\n**Quick Links:**\n- [Jaeger UI](http://localhost:16686) - View distributed traces\n- [Service Map](http://localhost:16686/search) - Explore service dependencies\n- [Trace Search](http://localhost:16686/search) - Find specific traces\n\n**Key Features:**\n- ✅ End-to-end request tracing\n- ✅ Service dependency mapping  \n- ✅ Performance bottleneck identification\n- ✅ Error propagation tracking\n\n**Usage Tips:**\n1. Generate traffic using the test script\n2. Search for traces by service name\n3. Analyze trace timeline for bottlenecks\n4. Compare normal vs error traces",
          "mode": "markdown"
        },
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 16}
      },
      {
        "id": 8,
        "title": "📈 Database Queries",
        "type": "timeseries",
        "targets": [
          {
            "expr": "sum(rate(user_service_db_queries_total[5m]))",
            "legendFormat": "DB Queries/sec",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "palette-classic"
            },
            "unit": "qps"
          }
        },
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 16}
      },
      {
        "id": 9,
        "title": "🌐 Service Health Status",
        "type": "table",
        "targets": [
          {
            "expr": "up",
            "legendFormat": "{{job}}",
            "refId": "A",
            "format": "table",
            "instant": true
          }
        ],
        "fieldConfig": {
          "defaults": {
            "custom": {
              "align": "auto",
              "displayMode": "auto"
            },
            "mappings": [
              {
                "options": {
                  "0": {
                    "text": "❌ Down",
                    "color": "red"
                  },
                  "1": {
                    "text": "✅ Up",
                    "color": "green"
                  }
                },
                "type": "value"
              }
            ]
          }
        },
        "gridPos": {"h": 8, "w": 24, "x": 0, "y": 24}
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "5s",
    "schemaVersion": 37,
    "version": 1
  }
}
EOF

# 마이크로서비스 상세 대시보드 생성
echo "5. 마이크로서비스 상세 대시보드 생성 중..."
cat > grafana/provisioning/dashboards/microservices-detail.json << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "Microservices Detail Dashboard",
    "tags": ["microservices", "detail", "performance"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "API Gateway Metrics",
        "type": "timeseries",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total{job=\"api-gateway\"}[5m])) by (status)",
            "legendFormat": "Status {{status}}",
            "refId": "A"
          }
        ],
        "gridPos": {"h": 8, "w": 8, "x": 0, "y": 0}
      },
      {
        "id": 2,
        "title": "User Service Metrics",
        "type": "timeseries",
        "targets": [
          {
            "expr": "sum(rate(user_service_requests_total[5m])) by (status)",
            "legendFormat": "Status {{status}}",
            "refId": "A"
          }
        ],
        "gridPos": {"h": 8, "w": 8, "x": 8, "y": 0}
      },
      {
        "id": 3,
        "title": "Order Service Metrics",
        "type": "timeseries",
        "targets": [
          {
            "expr": "sum(rate(order_service_requests_total[5m])) by (status)",
            "legendFormat": "Status {{status}}",
            "refId": "A"
          }
        ],
        "gridPos": {"h": 8, "w": 8, "x": 16, "y": 0}
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "5s",
    "schemaVersion": 37,
    "version": 1
  }
}
EOF

# Jaeger 연동 대시보드 생성
echo "6. Jaeger 연동 대시보드 생성 중..."
cat > grafana/provisioning/dashboards/jaeger-integration.json << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "Jaeger Tracing Integration",
    "tags": ["jaeger", "tracing", "distributed"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "🔍 Jaeger Service Map",
        "type": "text",
        "options": {
          "content": "<div style=\"text-align: center; padding: 20px;\">\n<h2>🔍 Distributed Tracing with Jaeger</h2>\n<p>Click the link below to explore distributed traces:</p>\n<a href=\"http://localhost:16686\" target=\"_blank\" style=\"display: inline-block; padding: 10px 20px; background-color: #3274d9; color: white; text-decoration: none; border-radius: 5px; margin: 10px;\">Open Jaeger UI</a>\n<br><br>\n<h3>📊 Key Tracing Features:</h3>\n<ul style=\"text-align: left; display: inline-block;\">\n<li>✅ End-to-end request tracing</li>\n<li>✅ Service dependency mapping</li>\n<li>✅ Performance bottleneck identification</li>\n<li>✅ Error propagation tracking</li>\n<li>✅ Distributed context propagation</li>\n</ul>\n</div>",
          "mode": "html"
        },
        "gridPos": {"h": 12, "w": 24, "x": 0, "y": 0}
      },
      {
        "id": 2,
        "title": "📈 Trace Statistics",
        "type": "stat",
        "targets": [
          {
            "expr": "sum(rate(traces_received_total[5m]))",
            "legendFormat": "Traces/sec",
            "refId": "A"
          }
        ],
        "gridPos": {"h": 6, "w": 12, "x": 0, "y": 12}
      },
      {
        "id": 3,
        "title": "🎯 Span Statistics",
        "type": "stat",
        "targets": [
          {
            "expr": "sum(rate(spans_received_total[5m]))",
            "legendFormat": "Spans/sec",
            "refId": "A"
          }
        ],
        "gridPos": {"h": 6, "w": 12, "x": 12, "y": 12}
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "5s",
    "schemaVersion": 37,
    "version": 1
  }
}
EOF

echo ""
echo "=== Grafana 통합 관측성 대시보드 설정 완료 ==="
echo ""
echo "생성된 대시보드:"
echo "- Complete Observability Stack: 메트릭 + 추적 통합 대시보드"
echo "- Microservices Detail: 서비스별 상세 메트릭"
echo "- Jaeger Integration: 분산 추적 연동 대시보드"
echo ""
echo "접속 정보:"
echo "- Grafana: http://localhost:3000 (admin/admin)"
echo "- Jaeger UI: http://localhost:16686"
echo ""
echo "다음 단계:"
echo "1. 서비스 시작: docker-compose up -d"
echo "2. 분산 추적 테스트: ./test_distributed_tracing.sh"