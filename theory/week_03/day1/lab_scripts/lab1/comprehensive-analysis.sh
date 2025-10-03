#!/bin/bash

# 종합 클러스터 분석 스크립트
# 목적: Kubernetes 클러스터의 전체적인 상태와 구성을 종합 분석
# 사용법: ./comprehensive-analysis.sh

set -e
trap 'echo "❌ 종합 분석 중 오류 발생"' ERR

echo "=== Comprehensive Kubernetes Cluster Analysis ==="
echo "🔍 클러스터의 모든 측면을 종합적으로 분석합니다..."

# 분석 결과 저장 디렉토리
ANALYSIS_DIR="analysis-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$ANALYSIS_DIR"
echo "📁 분석 결과 저장 위치: $ANALYSIS_DIR/"

echo ""
echo "🏗️ 1. Cluster Architecture Analysis"
echo "================================================"

# 클러스터 기본 정보
echo "📊 클러스터 기본 정보 수집 중..."
{
    echo "=== Cluster Information ==="
    kubectl cluster-info
    echo ""
    echo "=== Kubernetes Version ==="
    kubectl version --short 2>/dev/null || kubectl version
    echo ""
    echo "=== API Resources ==="
    kubectl api-resources --verbs=list --namespaced -o name | wc -l | xargs echo "Namespaced Resources:"
    kubectl api-resources --verbs=list --namespaced=false -o name | wc -l | xargs echo "Cluster-wide Resources:"
} > "$ANALYSIS_DIR/cluster-info.txt"

echo "   ✅ 클러스터 정보 저장: $ANALYSIS_DIR/cluster-info.txt"

echo ""
echo "🖥️ 2. Node Analysis"
echo "================================================"

# 노드 상세 분석
echo "🔍 노드 상태 분석 중..."
{
    echo "=== Node Overview ==="
    kubectl get nodes -o wide
    echo ""
    echo "=== Node Resource Capacity ==="
    kubectl describe nodes | grep -A 5 "Capacity:\|Allocatable:"
    echo ""
    echo "=== Node Conditions ==="
    kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}'
} > "$ANALYSIS_DIR/node-analysis.txt"

echo "   ✅ 노드 분석 저장: $ANALYSIS_DIR/node-analysis.txt"

echo ""
echo "🏷️ 3. Namespace & Resource Analysis"
echo "================================================"

# 네임스페이스별 리소스 분석
echo "📋 네임스페이스별 리소스 분석 중..."
{
    echo "=== Namespace Overview ==="
    kubectl get namespaces
    echo ""
    echo "=== Pods per Namespace ==="
    kubectl get pods --all-namespaces --no-headers | awk '{print $1}' | sort | uniq -c | sort -nr
    echo ""
    echo "=== Services per Namespace ==="
    kubectl get services --all-namespaces --no-headers | awk '{print $1}' | sort | uniq -c | sort -nr
    echo ""
    echo "=== ConfigMaps per Namespace ==="
    kubectl get configmaps --all-namespaces --no-headers | awk '{print $1}' | sort | uniq -c | sort -nr
} > "$ANALYSIS_DIR/namespace-analysis.txt"

echo "   ✅ 네임스페이스 분석 저장: $ANALYSIS_DIR/namespace-analysis.txt"

echo ""
echo "🔐 4. Security Analysis"
echo "================================================"

# 보안 설정 분석
echo "🛡️ 보안 설정 분석 중..."
{
    echo "=== Service Accounts ==="
    kubectl get serviceaccounts --all-namespaces | wc -l | xargs echo "Total Service Accounts:"
    echo ""
    echo "=== Roles and RoleBindings ==="
    kubectl get roles --all-namespaces | wc -l | xargs echo "Total Roles:"
    kubectl get rolebindings --all-namespaces | wc -l | xargs echo "Total RoleBindings:"
    echo ""
    echo "=== ClusterRoles and ClusterRoleBindings ==="
    kubectl get clusterroles | wc -l | xargs echo "Total ClusterRoles:"
    kubectl get clusterrolebindings | wc -l | xargs echo "Total ClusterRoleBindings:"
    echo ""
    echo "=== Secrets ==="
    kubectl get secrets --all-namespaces | wc -l | xargs echo "Total Secrets:"
    echo ""
    echo "=== Network Policies ==="
    kubectl get networkpolicies --all-namespaces 2>/dev/null | wc -l | xargs echo "Total Network Policies:" || echo "Network Policies: Not supported or none found"
} > "$ANALYSIS_DIR/security-analysis.txt"

echo "   ✅ 보안 분석 저장: $ANALYSIS_DIR/security-analysis.txt"

echo ""
echo "🌐 5. Network Analysis"
echo "================================================"

# 네트워크 설정 분석
echo "🔗 네트워크 설정 분석 중..."
{
    echo "=== Services Overview ==="
    kubectl get services --all-namespaces -o wide
    echo ""
    echo "=== Endpoints ==="
    kubectl get endpoints --all-namespaces | head -20
    echo ""
    echo "=== Ingress Resources ==="
    kubectl get ingress --all-namespaces 2>/dev/null || echo "No Ingress resources found"
    echo ""
    echo "=== CNI Plugin Pods ==="
    kubectl get pods -n kube-system | grep -E "(calico|flannel|weave|kindnet|cilium)" || echo "CNI plugin pods not clearly identifiable"
} > "$ANALYSIS_DIR/network-analysis.txt"

echo "   ✅ 네트워크 분석 저장: $ANALYSIS_DIR/network-analysis.txt"

echo ""
echo "💾 6. Storage Analysis"
echo "================================================"

# 스토리지 분석
echo "🗄️ 스토리지 설정 분석 중..."
{
    echo "=== Storage Classes ==="
    kubectl get storageclasses 2>/dev/null || echo "No Storage Classes found"
    echo ""
    echo "=== Persistent Volumes ==="
    kubectl get pv 2>/dev/null || echo "No Persistent Volumes found"
    echo ""
    echo "=== Persistent Volume Claims ==="
    kubectl get pvc --all-namespaces 2>/dev/null || echo "No PVCs found"
    echo ""
    echo "=== Volume Snapshots ==="
    kubectl get volumesnapshots --all-namespaces 2>/dev/null || echo "Volume Snapshots not supported or none found"
} > "$ANALYSIS_DIR/storage-analysis.txt"

echo "   ✅ 스토리지 분석 저장: $ANALYSIS_DIR/storage-analysis.txt"

echo ""
echo "📊 7. Resource Usage Analysis"
echo "================================================"

# 리소스 사용량 분석
echo "⚡ 리소스 사용량 분석 중..."
{
    echo "=== Node Resource Usage ==="
    kubectl top nodes 2>/dev/null || echo "Metrics server not available - resource usage data unavailable"
    echo ""
    echo "=== Pod Resource Usage (Top 20) ==="
    kubectl top pods --all-namespaces 2>/dev/null | head -20 || echo "Metrics server not available - pod usage data unavailable"
    echo ""
    echo "=== Resource Quotas ==="
    kubectl get resourcequotas --all-namespaces 2>/dev/null || echo "No Resource Quotas found"
    echo ""
    echo "=== Limit Ranges ==="
    kubectl get limitranges --all-namespaces 2>/dev/null || echo "No Limit Ranges found"
} > "$ANALYSIS_DIR/resource-usage.txt"

echo "   ✅ 리소스 사용량 저장: $ANALYSIS_DIR/resource-usage.txt"

echo ""
echo "🔧 8. Workload Analysis"
echo "================================================"

# 워크로드 분석
echo "🚀 워크로드 분석 중..."
{
    echo "=== Deployments ==="
    kubectl get deployments --all-namespaces -o wide
    echo ""
    echo "=== ReplicaSets ==="
    kubectl get replicasets --all-namespaces | head -20
    echo ""
    echo "=== DaemonSets ==="
    kubectl get daemonsets --all-namespaces
    echo ""
    echo "=== StatefulSets ==="
    kubectl get statefulsets --all-namespaces 2>/dev/null || echo "No StatefulSets found"
    echo ""
    echo "=== Jobs ==="
    kubectl get jobs --all-namespaces 2>/dev/null || echo "No Jobs found"
    echo ""
    echo "=== CronJobs ==="
    kubectl get cronjobs --all-namespaces 2>/dev/null || echo "No CronJobs found"
} > "$ANALYSIS_DIR/workload-analysis.txt"

echo "   ✅ 워크로드 분석 저장: $ANALYSIS_DIR/workload-analysis.txt"

echo ""
echo "📈 9. Events Analysis"
echo "================================================"

# 이벤트 분석
echo "📋 최근 이벤트 분석 중..."
{
    echo "=== Recent Events (Last 50) ==="
    kubectl get events --all-namespaces --sort-by='.lastTimestamp' | tail -50
    echo ""
    echo "=== Warning Events ==="
    kubectl get events --all-namespaces --field-selector type=Warning
    echo ""
    echo "=== Error Events ==="
    kubectl get events --all-namespaces --field-selector type=Error 2>/dev/null || echo "No Error events found"
} > "$ANALYSIS_DIR/events-analysis.txt"

echo "   ✅ 이벤트 분석 저장: $ANALYSIS_DIR/events-analysis.txt"

echo ""
echo "🎯 10. Health Summary Generation"
echo "================================================"

# 종합 상태 요약 생성
echo "📊 종합 상태 요약 생성 중..."

# 각종 카운트 수집
NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)
READY_NODES=$(kubectl get nodes --no-headers | grep " Ready " | wc -l)
NAMESPACE_COUNT=$(kubectl get namespaces --no-headers | wc -l)
POD_COUNT=$(kubectl get pods --all-namespaces --no-headers | wc -l)
RUNNING_PODS=$(kubectl get pods --all-namespaces --no-headers | grep " Running " | wc -l)
SERVICE_COUNT=$(kubectl get services --all-namespaces --no-headers | wc -l)

{
    echo "=== Cluster Health Summary ==="
    echo "Generated on: $(date)"
    echo ""
    echo "📊 Infrastructure:"
    echo "   • Nodes: $READY_NODES/$NODE_COUNT Ready"
    echo "   • Namespaces: $NAMESPACE_COUNT"
    echo ""
    echo "🚀 Workloads:"
    echo "   • Pods: $RUNNING_PODS/$POD_COUNT Running"
    echo "   • Services: $SERVICE_COUNT"
    echo ""
    echo "🏥 Health Status:"
    if [ "$READY_NODES" -eq "$NODE_COUNT" ] && [ "$RUNNING_PODS" -gt 0 ]; then
        echo "   ✅ Cluster appears healthy"
    else
        echo "   ⚠️ Cluster may have issues"
    fi
    echo ""
    echo "📁 Analysis Files Generated:"
    echo "   • cluster-info.txt - Basic cluster information"
    echo "   • node-analysis.txt - Node status and capacity"
    echo "   • namespace-analysis.txt - Resource distribution"
    echo "   • security-analysis.txt - Security configuration"
    echo "   • network-analysis.txt - Network setup"
    echo "   • storage-analysis.txt - Storage configuration"
    echo "   • resource-usage.txt - Resource utilization"
    echo "   • workload-analysis.txt - Application workloads"
    echo "   • events-analysis.txt - Recent cluster events"
    echo ""
    echo "🎓 Next Steps:"
    echo "   • Review each analysis file for detailed insights"
    echo "   • Compare with Kubernetes best practices"
    echo "   • Identify optimization opportunities"
    echo "   • Plan capacity and security improvements"
} > "$ANALYSIS_DIR/health-summary.txt"

echo "   ✅ 종합 요약 저장: $ANALYSIS_DIR/health-summary.txt"

echo ""
echo "🎉 Comprehensive Analysis Complete!"
echo "================================================"
echo "📁 모든 분석 결과가 '$ANALYSIS_DIR/' 디렉토리에 저장되었습니다."
echo ""
echo "📋 생성된 파일 목록:"
ls -la "$ANALYSIS_DIR/"

echo ""
echo "🎓 분석 결과 활용 방법:"
echo "   1. health-summary.txt부터 읽어보세요"
echo "   2. 각 분석 파일을 순서대로 검토하세요"
echo "   3. 발견된 이슈나 개선점을 기록하세요"
echo "   4. 정기적으로 분석을 실행하여 변화를 추적하세요"

echo ""
echo "✅ 종합 분석 완료!"
