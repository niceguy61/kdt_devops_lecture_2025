#!/bin/bash

# Week 3 Day 2 Lab 1: 특수 워크로드 배포
# 사용법: ./deploy-special-workloads.sh

echo "=== 특수 워크로드 배포 시작 ==="

# 1. DaemonSet 배포 (로그 수집기)
echo "1. DaemonSet 배포 중 (로그 수집기)..."

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: log-collector
  labels:
    app: log-collector
    type: monitoring
spec:
  selector:
    matchLabels:
      name: log-collector
  template:
    metadata:
      labels:
        name: log-collector
        app: log-collector
        type: monitoring
    spec:
      tolerations:
      # 마스터 노드에도 배포 가능하도록 설정
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule
      containers:
      - name: fluent-bit
        image: fluent/fluent-bit:1.8
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
          limits:
            cpu: 100m
            memory: 128Mi
        volumeMounts:
        - name: varlog
          mountPath: /var/log
          readOnly: true
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
        env:
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
EOF

if [ $? -eq 0 ]; then
    echo "✅ DaemonSet 생성 완료"
else
    echo "❌ DaemonSet 생성 실패"
fi

# 2. Job 배포 (일회성 데이터 처리)
echo ""
echo "2. Job 배포 중 (데이터 처리 작업)..."

kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: data-processor
  labels:
    app: data-processor
    type: batch
spec:
  completions: 3
  parallelism: 2
  backoffLimit: 3
  template:
    metadata:
      labels:
        app: data-processor
        type: batch
    spec:
      containers:
      - name: processor
        image: busybox:1.35
        command: ["sh", "-c"]
        args:
        - |
          echo "=== 데이터 처리 작업 시작 ==="
          echo "작업 ID: \$HOSTNAME"
          echo "시작 시간: \$(date)"
          
          # 시뮬레이션: 데이터 처리
          for i in \$(seq 1 10); do
            echo "처리 중... \$i/10"
            sleep 3
          done
          
          echo "완료 시간: \$(date)"
          echo "=== 데이터 처리 작업 완료 ==="
        resources:
          requests:
            cpu: 100m
            memory: 64Mi
          limits:
            cpu: 200m
            memory: 128Mi
      restartPolicy: Never
EOF

if [ $? -eq 0 ]; then
    echo "✅ Job 생성 완료"
else
    echo "❌ Job 생성 실패"
fi

# 3. CronJob 배포 (주기적 백업 작업)
echo ""
echo "3. CronJob 배포 중 (주기적 백업 작업)..."

kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-job
  labels:
    app: backup-job
    type: scheduled
spec:
  schedule: "*/2 * * * *"  # 2분마다 실행
  jobTemplate:
    spec:
      template:
        metadata:
          labels:
            app: backup-job
            type: scheduled
        spec:
          containers:
          - name: backup
            image: busybox:1.35
            command: ["sh", "-c"]
            args:
            - |
              echo "=== 백업 작업 시작 ==="
              echo "백업 시간: \$(date)"
              echo "백업 대상: 데이터베이스"
              
              # 시뮬레이션: 백업 수행
              echo "백업 진행 중..."
              sleep 15
              
              echo "백업 완료: backup_\$(date +%Y%m%d_%H%M%S).sql"
              echo "=== 백업 작업 완료 ==="
            resources:
              requests:
                cpu: 50m
                memory: 32Mi
              limits:
                cpu: 100m
                memory: 64Mi
          restartPolicy: OnFailure
EOF

if [ $? -eq 0 ]; then
    echo "✅ CronJob 생성 완료"
else
    echo "❌ CronJob 생성 실패"
fi

# 배포 상태 확인
echo ""
echo "=== 특수 워크로드 상태 확인 ==="

echo ""
echo "4. DaemonSet 상태:"
kubectl get daemonsets
kubectl get pods -l name=log-collector -o wide

echo ""
echo "5. Job 상태:"
kubectl get jobs
kubectl get pods -l app=data-processor

echo ""
echo "6. CronJob 상태:"
kubectl get cronjobs
kubectl get jobs -l app=backup-job

echo ""
echo "7. 전체 특수 워크로드 요약:"
echo "- DaemonSet: 모든 노드에 로그 수집기 배포"
echo "- Job: 3개 완료, 2개 병렬 실행으로 데이터 처리"
echo "- CronJob: 2분마다 백업 작업 실행"

echo ""
echo "=== 특수 워크로드 배포 완료 ==="
