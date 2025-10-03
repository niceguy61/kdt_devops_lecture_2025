# 🚀 Week 3 Kubernetes 명령어 레퍼런스

<div align="center">

**📋 kubectl 완전 정복** • **🐧 Linux 필수 명령어** • **🔧 실무 중심 가이드**

*Week 3 실습에서 사용할 모든 명령어를 한 곳에 정리*

</div>

---

## 📋 목차

1. [kubectl 기본 명령어](#kubectl-기본-명령어)
2. [리소스 관리 명령어](#리소스-관리-명령어)
3. [디버깅 & 트러블슈팅](#디버깅--트러블슈팅)
4. [네트워킹 & 서비스](#네트워킹--서비스)
5. [스토리지 & 볼륨](#스토리지--볼륨)
6. [보안 & RBAC](#보안--rbac)
7. [모니터링 & 로깅](#모니터링--로깅)
8. [Linux 시스템 명령어](#linux-시스템-명령어)
9. [Docker & 컨테이너](#docker--컨테이너)
10. [ETCD 명령어](#etcd-명령어)

---

## 🎯 kubectl 기본 명령어

### 클러스터 정보 및 상태 확인
```bash
# 클러스터 정보 확인
kubectl cluster-info
kubectl cluster-info dump

# 버전 정보
kubectl version
kubectl version --client

# API 리소스 확인
kubectl api-resources
kubectl api-versions

# 컨텍스트 관리
kubectl config current-context
kubectl config get-contexts
kubectl config use-context <context-name>
kubectl config set-context --current --namespace=<namespace>
```

### 노드 관리
```bash
# 노드 목록 및 상태
kubectl get nodes
kubectl get nodes -o wide
kubectl describe node <node-name>

# 노드 라벨 관리
kubectl label nodes <node-name> <key>=<value>
kubectl label nodes <node-name> <key>-  # 라벨 제거

# 노드 스케줄링 제어
kubectl cordon <node-name>     # 스케줄링 비활성화
kubectl uncordon <node-name>   # 스케줄링 활성화
kubectl drain <node-name>      # Pod 대피 후 스케줄링 비활성화
```

### 네임스페이스 관리
```bash
# 네임스페이스 조회
kubectl get namespaces
kubectl get ns

# 네임스페이스 생성/삭제
kubectl create namespace <namespace-name>
kubectl delete namespace <namespace-name>

# 네임스페이스별 리소스 확인
kubectl get all -n <namespace>
kubectl get all --all-namespaces
```

---

## 🔧 리소스 관리 명령어

### Pod 관리
```bash
# Pod 조회
kubectl get pods
kubectl get pods -o wide
kubectl get pods --all-namespaces
kubectl get pods -l <label-selector>
kubectl get pods --field-selector status.phase=Running

# Pod 생성
kubectl run <pod-name> --image=<image>
kubectl run <pod-name> --image=<image> --dry-run=client -o yaml

# Pod 상세 정보
kubectl describe pod <pod-name>
kubectl get pod <pod-name> -o yaml
kubectl get pod <pod-name> -o json

# Pod 삭제
kubectl delete pod <pod-name>
kubectl delete pods --all
kubectl delete pod <pod-name> --force --grace-period=0
```

### Deployment 관리
```bash
# Deployment 생성
kubectl create deployment <name> --image=<image>
kubectl create deployment <name> --image=<image> --replicas=3

# Deployment 조회
kubectl get deployments
kubectl get deploy
kubectl describe deployment <name>

# 스케일링
kubectl scale deployment <name> --replicas=5
kubectl autoscale deployment <name> --min=2 --max=10 --cpu-percent=80

# 롤링 업데이트
kubectl set image deployment/<name> <container>=<new-image>
kubectl rollout status deployment/<name>
kubectl rollout history deployment/<name>
kubectl rollout undo deployment/<name>
kubectl rollout restart deployment/<name>
```

### ReplicaSet 관리
```bash
# ReplicaSet 조회
kubectl get replicasets
kubectl get rs
kubectl describe rs <name>

# ReplicaSet 스케일링
kubectl scale rs <name> --replicas=3
```

### Service 관리
```bash
# Service 생성
kubectl expose deployment <name> --port=80 --target-port=8080
kubectl expose pod <name> --port=80 --type=NodePort
kubectl create service clusterip <name> --tcp=80:8080

# Service 조회
kubectl get services
kubectl get svc
kubectl describe service <name>
kubectl get endpoints
kubectl get ep
```

### ConfigMap & Secret
```bash
# ConfigMap 생성
kubectl create configmap <name> --from-literal=<key>=<value>
kubectl create configmap <name> --from-file=<file>
kubectl create configmap <name> --from-env-file=<file>

# Secret 생성
kubectl create secret generic <name> --from-literal=<key>=<value>
kubectl create secret tls <name> --cert=<cert-file> --key=<key-file>
kubectl create secret docker-registry <name> --docker-server=<server> --docker-username=<user> --docker-password=<pass>

# 조회
kubectl get configmaps
kubectl get secrets
kubectl describe configmap <name>
kubectl describe secret <name>
```

---

## 🔍 디버깅 & 트러블슈팅

### 로그 확인
```bash
# Pod 로그
kubectl logs <pod-name>
kubectl logs <pod-name> -c <container-name>  # 멀티 컨테이너
kubectl logs <pod-name> --previous           # 이전 컨테이너 로그
kubectl logs <pod-name> -f                   # 실시간 로그
kubectl logs <pod-name> --tail=50            # 마지막 50줄
kubectl logs <pod-name> --since=1h           # 1시간 전부터

# Deployment 로그
kubectl logs deployment/<name>
kubectl logs -l <label-selector>

# 시스템 컴포넌트 로그
kubectl logs -n kube-system <pod-name>
kubectl logs -n kube-system -l component=kube-apiserver
```

### 리소스 상태 확인
```bash
# 이벤트 확인
kubectl get events
kubectl get events --sort-by='.lastTimestamp'
kubectl get events --field-selector type=Warning

# 리소스 사용량
kubectl top nodes
kubectl top pods
kubectl top pods --all-namespaces

# 상세 정보
kubectl describe <resource-type> <resource-name>
kubectl get <resource> -o yaml
kubectl get <resource> -o json
```

### 실행 및 디버깅
```bash
# Pod 내부 접속
kubectl exec -it <pod-name> -- /bin/bash
kubectl exec -it <pod-name> -- /bin/sh
kubectl exec -it <pod-name> -c <container> -- /bin/bash

# 명령어 실행
kubectl exec <pod-name> -- <command>
kubectl exec <pod-name> -c <container> -- <command>

# 파일 복사
kubectl cp <pod-name>:<path> <local-path>
kubectl cp <local-path> <pod-name>:<path>

# 포트 포워딩
kubectl port-forward <pod-name> <local-port>:<pod-port>
kubectl port-forward service/<service-name> <local-port>:<service-port>
```

### 임시 Pod 생성 (디버깅용)
```bash
# 임시 Pod 생성
kubectl run debug --image=busybox --rm -it --restart=Never -- /bin/sh
kubectl run debug --image=nicolaka/netshoot --rm -it --restart=Never

# 네트워크 테스트용 Pod
kubectl run nettest --image=busybox --rm -it --restart=Never -- /bin/sh
# 내부에서: wget, nslookup, ping 등 사용

# 특정 노드에서 실행
kubectl run debug --image=busybox --rm -it --restart=Never --overrides='{"spec":{"nodeName":"<node-name>"}}' -- /bin/sh
```

---

## 🌐 네트워킹 & 서비스

### Service 관련
```bash
# Service 타입별 생성
kubectl expose deployment <name> --type=ClusterIP --port=80
kubectl expose deployment <name> --type=NodePort --port=80
kubectl expose deployment <name> --type=LoadBalancer --port=80

# Endpoints 확인
kubectl get endpoints <service-name>
kubectl describe endpoints <service-name>

# DNS 테스트
kubectl run dns-test --image=busybox --rm -it --restart=Never -- nslookup <service-name>
kubectl run dns-test --image=busybox --rm -it --restart=Never -- nslookup <service-name>.<namespace>.svc.cluster.local
```

### Ingress 관리
```bash
# Ingress 조회
kubectl get ingress
kubectl get ing
kubectl describe ingress <name>

# Ingress Controller 확인
kubectl get pods -n ingress-nginx
kubectl logs -n ingress-nginx <ingress-controller-pod>
```

### 네트워크 정책
```bash
# Network Policy 조회
kubectl get networkpolicies
kubectl get netpol
kubectl describe networkpolicy <name>
```

---

## 💾 스토리지 & 볼륨

### PersistentVolume & PersistentVolumeClaim
```bash
# PV/PVC 조회
kubectl get persistentvolumes
kubectl get pv
kubectl get persistentvolumeclaims
kubectl get pvc

# 상세 정보
kubectl describe pv <name>
kubectl describe pvc <name>

# StorageClass 확인
kubectl get storageclasses
kubectl get sc
kubectl describe storageclass <name>
```

### 볼륨 관련 디버깅
```bash
# 볼륨 마운트 확인
kubectl describe pod <pod-name> | grep -A 10 -B 10 -i volume

# 스토리지 이벤트 확인
kubectl get events --field-selector involvedObject.kind=PersistentVolumeClaim
```

---

## 🔐 보안 & RBAC

### ServiceAccount 관리
```bash
# ServiceAccount 조회
kubectl get serviceaccounts
kubectl get sa
kubectl describe sa <name>

# 토큰 생성 (Kubernetes 1.24+)
kubectl create token <service-account-name>
kubectl create token <service-account-name> --duration=3600s
```

### RBAC 관리
```bash
# Role & RoleBinding
kubectl get roles
kubectl get rolebindings
kubectl describe role <name>
kubectl describe rolebinding <name>

# ClusterRole & ClusterRoleBinding
kubectl get clusterroles
kubectl get clusterrolebindings
kubectl describe clusterrole <name>

# 권한 확인
kubectl auth can-i <verb> <resource>
kubectl auth can-i create pods
kubectl auth can-i create pods --as=<user>
kubectl auth can-i create pods --as=system:serviceaccount:<namespace>:<sa-name>
```

### 보안 컨텍스트
```bash
# Pod 보안 정책 확인
kubectl get podsecuritypolicies
kubectl get psp
kubectl describe psp <name>

# Security Context 확인
kubectl get pod <name> -o yaml | grep -A 10 securityContext
```

---

## 📊 모니터링 & 로깅

### 리소스 모니터링
```bash
# 리소스 사용량 실시간 확인
kubectl top nodes
kubectl top pods
kubectl top pods --all-namespaces
kubectl top pods -l <label-selector>

# 리소스 사용량 정렬
kubectl top pods --sort-by=cpu
kubectl top pods --sort-by=memory
```

### 이벤트 모니터링
```bash
# 이벤트 확인
kubectl get events
kubectl get events --sort-by='.lastTimestamp'
kubectl get events --field-selector type=Warning
kubectl get events --field-selector involvedObject.name=<resource-name>

# 실시간 이벤트 모니터링
kubectl get events -w
```

### 애플리케이션 상태 확인
```bash
# 헬스체크 상태
kubectl get pods --field-selector status.phase=Failed
kubectl get pods --field-selector status.phase=Pending

# 재시작 횟수 확인
kubectl get pods --sort-by='.status.containerStatuses[0].restartCount'
```

---

## 🐧 Linux 시스템 명령어

### 시스템 상태 확인
```bash
# 프로세스 확인
ps aux | grep -E "(kube|etcd|docker|containerd)"
ps -ef | grep kubelet
pgrep -f kube-apiserver

# 시스템 서비스 상태
systemctl status kubelet
systemctl status docker
systemctl status containerd
journalctl -u kubelet -f
journalctl -u kubelet --since "1 hour ago"
```

### 네트워크 진단
```bash
# 포트 사용 현황
ss -tlnp | grep -E "(6443|2379|2380|10250)"
netstat -tlnp | grep -E "(6443|2379|2380|10250)"  # 구버전
lsof -i :6443
lsof -i :2379

# 네트워크 인터페이스
ip addr show
ip route show
ip link show

# 네트워크 연결 테스트
ping <ip-address>
telnet <ip> <port>
nc -zv <ip> <port>
curl -k https://<ip>:<port>/healthz
```

### 파일 시스템 & 권한
```bash
# 디렉토리 및 파일 확인
ls -la /etc/kubernetes/
ls -la /var/lib/kubelet/
ls -la /etc/cni/net.d/

# 파일 권한 확인
stat /etc/kubernetes/pki/apiserver.crt
ls -la /etc/kubernetes/pki/

# 디스크 사용량
df -h
du -sh /var/lib/etcd
du -sh /var/lib/kubelet
```

### 로그 분석
```bash
# 시스템 로그
journalctl -u kubelet
journalctl -u docker
journalctl -u containerd
journalctl --since "1 hour ago" -u kubelet

# 로그 필터링
journalctl -u kubelet | grep -i error
journalctl -u kubelet | grep -i warning
tail -f /var/log/syslog | grep kube
```

---

## 🐳 Docker & 컨테이너

### Docker 명령어 (Kind 환경)
```bash
# 컨테이너 목록
docker ps
docker ps -a

# Kind 클러스터 노드 접속
docker exec -it <node-name> bash
docker exec -it lab-cluster-control-plane bash

# 컨테이너 로그
docker logs <container-id>
docker logs <container-name>

# 이미지 관리
docker images
docker pull <image>
docker rmi <image>
```

### containerd 명령어 (실제 클러스터)
```bash
# 컨테이너 목록 (crictl)
crictl ps
crictl ps -a

# 이미지 목록
crictl images

# 컨테이너 로그
crictl logs <container-id>

# Pod 목록
crictl pods
```

---

## 🗄️ ETCD 명령어

### ETCD 기본 조작
```bash
# ETCD Pod 접속
kubectl exec -it -n kube-system <etcd-pod> -- sh

# 환경 변수 설정 (ETCD Pod 내부)
export ETCDCTL_API=3
export ETCDCTL_ENDPOINTS=https://127.0.0.1:2379
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key

# 클러스터 상태 확인
etcdctl endpoint health
etcdctl endpoint status --write-out=table

# 데이터 조회
etcdctl get / --prefix --keys-only
etcdctl get /registry/pods/default/ --prefix
etcdctl get /registry/namespaces/default

# 실시간 모니터링
etcdctl watch /registry/pods/<namespace>/ --prefix
```

### ETCD 백업 & 복원
```bash
# 백업
etcdctl snapshot save backup.db

# 백업 상태 확인
etcdctl snapshot status backup.db --write-out=table

# 복원
etcdctl snapshot restore backup.db --data-dir=/var/lib/etcd-restore
```

---

## 🔍 고급 kubectl 명령어

### 리소스 편집 및 패치
```bash
# 리소스 편집
kubectl edit <resource-type> <resource-name>
kubectl edit deployment <name>
kubectl edit service <name>

# 패치 적용
kubectl patch deployment <name> -p '{"spec":{"replicas":5}}'
kubectl patch service <name> -p '{"spec":{"type":"NodePort"}}'

# 라벨 및 어노테이션
kubectl label pods <name> <key>=<value>
kubectl annotate pods <name> <key>=<value>
```

### 리소스 대기 및 조건 확인
```bash
# 조건 대기
kubectl wait --for=condition=ready pod/<name>
kubectl wait --for=condition=available deployment/<name>
kubectl wait --for=delete pod/<name> --timeout=60s

# 조건부 조회
kubectl get pods --field-selector status.phase=Running
kubectl get pods --field-selector spec.nodeName=<node-name>
```

### 출력 형식 및 정렬
```bash
# 출력 형식
kubectl get pods -o wide
kubectl get pods -o yaml
kubectl get pods -o json
kubectl get pods -o jsonpath='{.items[*].metadata.name}'
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase

# 정렬
kubectl get pods --sort-by=.metadata.creationTimestamp
kubectl get pods --sort-by=.status.startTime
kubectl get events --sort-by=.lastTimestamp
```

---

## 🎯 실습별 주요 명령어 그룹

### Day 1: 클러스터 아키텍처
```bash
# 클러스터 구축
kind create cluster --config <config-file>
kubectl cluster-info
kubectl get nodes

# 컴포넌트 확인
kubectl get pods -n kube-system
kubectl logs -n kube-system -l component=kube-apiserver
kubectl exec -n kube-system <etcd-pod> -- etcdctl endpoint health

# 네트워크 분석
docker exec -it <node> ss -tlnp
kubectl proxy --port=8080
```

### Day 2: 워크로드 관리
```bash
# 워크로드 생성
kubectl create deployment <name> --image=<image>
kubectl expose deployment <name> --port=80
kubectl scale deployment <name> --replicas=3

# 스케줄링 제어
kubectl label nodes <node> <key>=<value>
kubectl taint nodes <node> <key>=<value>:NoSchedule
kubectl get pods -o wide
```

### Day 3: 네트워킹 & 스토리지
```bash
# 서비스 관리
kubectl get svc
kubectl get endpoints
kubectl describe service <name>

# 스토리지 관리
kubectl get pv
kubectl get pvc
kubectl describe pvc <name>

# Ingress 관리
kubectl get ingress
kubectl describe ingress <name>
```

### Day 4: 보안 & 관리
```bash
# RBAC 확인
kubectl get roles
kubectl get rolebindings
kubectl auth can-i <verb> <resource>

# 인증서 관리
kubectl get csr
kubectl certificate approve <csr-name>

# 클러스터 업그레이드
kubectl drain <node>
kubectl uncordon <node>
```

### Day 5: 운영 & 모니터링
```bash
# 모니터링
kubectl top nodes
kubectl top pods
kubectl get events

# 오토스케일링
kubectl autoscale deployment <name> --min=2 --max=10
kubectl get hpa

# 고급 기능
kubectl get crd
kubectl get <custom-resource>
```

---

## 💡 명령어 조합 팁

### 파이프라인 활용
```bash
# 특정 상태의 Pod만 조회
kubectl get pods --all-namespaces | grep -E "(Pending|Failed|Error)"

# 리소스 사용량 높은 Pod 찾기
kubectl top pods --all-namespaces | sort -k3 -nr

# 최근 생성된 Pod 확인
kubectl get pods --sort-by=.metadata.creationTimestamp | tail -5

# 특정 노드의 Pod 목록
kubectl get pods --all-namespaces -o wide | grep <node-name>
```

### 반복 작업 자동화
```bash
# 여러 네임스페이스에서 동일 작업
for ns in $(kubectl get ns -o name | cut -d/ -f2); do
  echo "Namespace: $ns"
  kubectl get pods -n $ns
done

# 모든 노드에 라벨 추가
kubectl get nodes -o name | xargs -I {} kubectl label {} <key>=<value>

# 실시간 모니터링
watch kubectl get pods
watch kubectl top nodes
```

---

## 🚀 실무 활용 스크립트 예제

### 클러스터 상태 체크 스크립트
```bash
#!/bin/bash
echo "=== Cluster Health Check ==="
kubectl get nodes
kubectl get pods --all-namespaces | grep -v Running
kubectl get events --field-selector type=Warning
kubectl top nodes
```

### 리소스 정리 스크립트
```bash
#!/bin/bash
# 완료된 Job 정리
kubectl delete jobs --field-selector status.successful=1

# Evicted Pod 정리
kubectl get pods --all-namespaces --field-selector status.phase=Failed -o name | xargs kubectl delete

# 사용하지 않는 ConfigMap/Secret 찾기
kubectl get configmaps --all-namespaces
kubectl get secrets --all-namespaces
```

---

<div align="center">

**📋 명령어 마스터** • **🔧 실무 준비 완료** • **🚀 효율적 운영**

*이 레퍼런스로 Week 3의 모든 실습을 완벽하게 수행하세요!*

</div>