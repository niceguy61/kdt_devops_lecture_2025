# Week 3.5 보충 강좌 실습 환경 설정 가이드

## 🎯 목적
이 문서는 Kubernetes 핵심 개념 보충 강좌(Week 3.5)를 위한 로컬 실습 환경 설정 가이드입니다. 실습 시작 전에 반드시 모든 요구사항을 확인하고 설정을 완료해주세요.

## ⚠️ 중요 사항
- **실습 전 필수 완료**: 모든 설정은 Day 1 Session 1 시작 전에 완료되어야 합니다
- **로컬 환경**: 별도의 클라우드 비용 없이 개인 PC에서 실습 가능
- **Kind 사용**: Kubernetes in Docker를 사용한 경량 클러스터 구성
- **리소스 요구사항**: 충분한 메모리와 디스크 공간 필요

---

## 📋 시스템 요구사항

### 운영체제
- **Windows**: Windows 10/11 (64-bit)
  - WSL2 필수 (Docker Desktop 사용 시)
- **macOS**: macOS 11 Big Sur 이상 (Intel 또는 Apple Silicon)
- **Linux**: Ubuntu 20.04+, Fedora 35+, Debian 11+

### 하드웨어
- **CPU**: 2 코어 이상 (권장 4 코어)
- **RAM**: 최소 8GB (권장 16GB)
  - Docker: 4GB 할당
  - Kind 클러스터: 2GB
  - 여유 메모리: 2GB
- **디스크**: 최소 20GB 여유 공간 (권장 40GB)
  - Docker 이미지: ~5GB
  - Kind 클러스터: ~2GB
  - 실습 데이터: ~3GB
- **가상화 지원**: CPU 가상화 기능 활성화 필요
  - Intel: VT-x
  - AMD: AMD-V

---

## 🛠️ 필수 도구 설치

### 1. Docker 설치

Kind는 Docker 컨테이너 안에서 Kubernetes를 실행하므로 Docker가 필수입니다.

#### Windows

**1. WSL2 설치**
```powershell
# PowerShell 관리자 권한으로 실행

# WSL 활성화 및 Ubuntu 설치
wsl --install

# 재부팅 필요
Restart-Computer

# 재부팅 후 WSL2 버전 확인
wsl --list --verbose
wsl --set-default-version 2
```

**2. Docker Desktop 설치**
```powershell
# 다운로드: https://www.docker.com/products/docker-desktop/

# 또는 winget 사용
winget install Docker.DockerDesktop

# 또는 Chocolatey 사용
choco install docker-desktop
```

**3. Docker Desktop 설정**
1. Docker Desktop 실행
2. **Settings** → **Resources** → **Memory**: 4GB 이상 할당
3. **Settings** → **Resources** → **CPUs**: 2개 이상 할당
4. **Settings** → **Kubernetes**: **비활성화** (Kind 사용하므로 불필요)
5. **Apply & Restart**

---

#### macOS

```bash
# Homebrew 사용 (권장)
brew install --cask docker

# 수동 설치
# Intel Mac: https://desktop.docker.com/mac/main/amd64/Docker.dmg
# Apple Silicon: https://desktop.docker.com/mac/main/arm64/Docker.dmg

# Docker Desktop 실행 후 설정
# Settings → Resources → Memory: 4GB 이상
# Settings → Resources → CPUs: 2개 이상
# Settings → Kubernetes: 비활성화 (Kind 사용)
```

---

#### Linux (Ubuntu)

```bash
# 1. 이전 Docker 버전 제거
sudo apt-get remove docker docker-engine docker.io containerd runc

# 2. Docker 저장소 설정
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Docker 공식 GPG 키 추가
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Docker 저장소 추가
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 3. Docker Engine 설치
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 4. Docker 서비스 시작 및 자동 시작 설정
sudo systemctl start docker
sudo systemctl enable docker

# 5. 현재 사용자를 docker 그룹에 추가 (sudo 없이 사용)
sudo usermod -aG docker $USER

# 6. 변경사항 적용 (로그아웃 후 재로그인 또는)
newgrp docker

# 7. 설치 확인
docker --version
docker run hello-world
```

---

### 2. kubectl 설치

Kubernetes 클러스터를 관리하기 위한 CLI 도구입니다.

#### Windows

```powershell
# 방법 1: winget 사용 (권장)
winget install Kubernetes.kubectl

# 방법 2: Chocolatey 사용
choco install kubernetes-cli

# 방법 3: 수동 설치
curl.exe -LO "https://dl.k8s.io/release/v1.29.0/bin/windows/amd64/kubectl.exe"

# kubectl.exe를 PATH 디렉토리로 이동
New-Item -Path "C:\Program Files\kubectl" -ItemType Directory -Force
Move-Item -Path .\kubectl.exe -Destination "C:\Program Files\kubectl\"

# PATH 환경변수에 추가
$env:Path += ";C:\Program Files\kubectl"

# 영구 적용 (관리자 권한)
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\kubectl", "Machine")

# 설치 확인
kubectl version --client
```

---

#### macOS

```bash
# Homebrew 사용 (권장)
brew install kubectl

# 수동 설치
# Intel Mac
curl -LO "https://dl.k8s.io/release/v1.29.0/bin/darwin/amd64/kubectl"

# Apple Silicon (M1/M2/M3)
curl -LO "https://dl.k8s.io/release/v1.29.0/bin/darwin/arm64/kubectl"

# 실행 권한 부여 및 PATH로 이동
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# 설치 확인
kubectl version --client
```

---

#### Linux

```bash
# 최신 안정 버전 다운로드
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# 실행 권한 부여
chmod +x kubectl

# PATH로 이동
sudo mv kubectl /usr/local/bin/

# 설치 확인
kubectl version --client
```

---

### 3. Kind 설치

Kind (Kubernetes in Docker)는 Docker 컨테이너 안에서 Kubernetes 클러스터를 실행합니다.

#### Windows

```powershell
# 방법 1: Chocolatey 사용 (권장)
choco install kind

# 방법 2: winget 사용
winget install Kubernetes.kind

# 방법 3: 수동 설치
curl.exe -Lo kind-windows-amd64.exe https://kind.sigs.k8s.io/dl/latest/kind-windows-amd64

# kind.exe로 이름 변경 후 PATH로 이동
New-Item -Path "C:\Program Files\kind" -ItemType Directory -Force
Move-Item -Path .\kind-windows-amd64.exe -Destination "C:\Program Files\kind\kind.exe"

# PATH 환경변수에 추가
$env:Path += ";C:\Program Files\kind"

# 영구 적용 (관리자 권한)
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\kind", "Machine")

# 설치 확인
kind version
```

---

#### macOS

```bash
# Homebrew 사용 (권장)
brew install kind

# 수동 설치
# Intel Mac
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-darwin-amd64

# Apple Silicon (M1/M2/M3)
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-darwin-arm64

# 실행 권한 부여 및 PATH로 이동
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# 설치 확인
kind version
```

---

#### Linux

```bash
# 최신 버전 다운로드
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64

# 실행 권한 부여
chmod +x ./kind

# PATH로 이동
sudo mv ./kind /usr/local/bin/kind

# 설치 확인
kind version
```

---

## 🚀 Kind 클러스터 생성

### 1. 단일 노드 클러스터 생성 (권장 - 실습용)

```bash
# k8s-lab 이름으로 클러스터 생성
kind create cluster --name k8s-lab

# 생성 로그 예시:
# Creating cluster "k8s-lab" ...
#  ✓ Ensuring node image (kindest/node:v1.29.1) 🖼
#  ✓ Preparing nodes 📦
#  ✓ Writing configuration 📜
#  ✓ Starting control-plane 🕹️
#  ✓ Installing CNI 🔌
#  ✓ Installing StorageClass 💾
# Set kubectl context to "kind-k8s-lab"
# You can now use your cluster with:
# kubectl cluster-info --context kind-k8s-lab
```

---

### 2. 멀티 노드 클러스터 생성 (옵션 - 고급 실습)

실습 중 노드 관련 기능을 테스트하려면 멀티 노드 클러스터를 생성할 수 있습니다.

```bash
# 설정 파일 생성
cat <<EOF > kind-multi-node-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
EOF

# 멀티 노드 클러스터 생성
kind create cluster --name k8s-lab --config kind-multi-node-config.yaml
```

---

### 3. 클러스터 확인

```bash
# 생성된 클러스터 목록 확인
kind get clusters
# 출력: k8s-lab

# kubectl 컨텍스트 확인
kubectl config get-contexts
# 출력: kind-k8s-lab (현재 컨텍스트)

# 현재 컨텍스트 확인
kubectl config current-context
# 출력: kind-k8s-lab

# 클러스터 정보 확인
kubectl cluster-info --context kind-k8s-lab
# 출력:
# Kubernetes control plane is running at https://127.0.0.1:xxxxx
# CoreDNS is running at https://127.0.0.1:xxxxx/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

# 노드 상태 확인
kubectl get nodes
# 출력 (단일 노드):
# NAME                    STATUS   ROLES           AGE   VERSION
# k8s-lab-control-plane   Ready    control-plane   2m    v1.29.1

# 출력 (멀티 노드):
# NAME                    STATUS   ROLES           AGE   VERSION
# k8s-lab-control-plane   Ready    control-plane   2m    v1.29.1
# k8s-lab-worker          Ready    <none>          90s   v1.29.1
# k8s-lab-worker2         Ready    <none>          90s   v1.29.1
```

---

## ✅ 환경 테스트 및 검증

### 1. Docker 설치 확인

```bash
# Docker 버전 확인
docker --version
# 예상 출력: Docker version 24.0.x, build xxxxx

# Docker 실행 확인
docker run hello-world
# 예상 출력: Hello from Docker! ...

# Docker 정보 확인
docker info | grep -i "running"
# 예상 출력: Containers: X Running: X
```

---

### 2. Kind 클러스터 확인

```bash
# Kind 버전 확인
kind version
# 예상 출력: kind v0.20.0 go1.21.3 ...

# 클러스터 목록 확인
kind get clusters
# 예상 출력: k8s-lab

# Docker에서 Kind 컨테이너 확인
docker ps
# 예상 출력:
# CONTAINER ID   IMAGE                  ...   NAMES
# xxxxxxxxx      kindest/node:v1.29.1   ...   k8s-lab-control-plane
```

---

### 3. kubectl 동작 확인

```bash
# kubectl 버전 확인
kubectl version --client
# 예상 출력: Client Version: v1.29.0 ...

# 클러스터 버전 확인
kubectl version
# 예상 출력:
# Client Version: v1.29.0
# Server Version: v1.29.1

# 노드 상태 확인
kubectl get nodes
# 예상 출력:
# NAME                    STATUS   ROLES           AGE   VERSION
# k8s-lab-control-plane   Ready    control-plane   5m    v1.29.1

# 시스템 Pod 확인
kubectl get pods -n kube-system
# 예상 출력:
# NAME                                            READY   STATUS    RESTARTS   AGE
# coredns-xxxxx                                   1/1     Running   0          5m
# coredns-xxxxx                                   1/1     Running   0          5m
# etcd-k8s-lab-control-plane                      1/1     Running   0          5m
# kindnet-xxxxx                                   1/1     Running   0          5m
# kube-apiserver-k8s-lab-control-plane            1/1     Running   0          5m
# kube-controller-manager-k8s-lab-control-plane   1/1     Running   0          5m
# kube-proxy-xxxxx                                1/1     Running   0          5m
# kube-scheduler-k8s-lab-control-plane            1/1     Running   0          5m
```

---

### 4. 간단한 Pod 테스트

```bash
# 테스트 Pod 생성
kubectl run test-nginx --image=nginx:1.25.3

# Pod 상태 확인 (Running 될 때까지 대기)
kubectl get pods
# 예상 출력:
# NAME         READY   STATUS    RESTARTS   AGE
# test-nginx   1/1     Running   0          30s

# Pod 상세 정보 확인
kubectl describe pod test-nginx

# Pod 로그 확인
kubectl logs test-nginx

# Pod 내부 명령어 실행 테스트
kubectl exec test-nginx -- nginx -v
# 예상 출력: nginx version: nginx/1.25.3

# Pod 삭제
kubectl delete pod test-nginx
# 예상 출력: pod "test-nginx" deleted
```

---

## 🚨 문제 해결 가이드

### 1. Docker 관련 문제

#### 문제: "Cannot connect to the Docker daemon"

**원인**: Docker 서비스가 실행 중이지 않음

**해결방법**:

**Windows/macOS**:
```bash
# Docker Desktop이 실행 중인지 확인
# 작업 표시줄/메뉴바에서 Docker 아이콘 확인

# Docker Desktop 재시작
```

**Linux**:
```bash
# Docker 서비스 상태 확인
sudo systemctl status docker

# Docker 서비스 시작
sudo systemctl start docker

# Docker 서비스 자동 시작 설정
sudo systemctl enable docker
```

---

#### 문제: "permission denied while trying to connect to the Docker daemon socket"

**원인**: 현재 사용자가 docker 그룹에 없음

**해결방법 (Linux)**:
```bash
# 현재 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER

# 로그아웃 후 재로그인 또는
newgrp docker

# 권한 확인
docker ps
```

---

### 2. Kind 클러스터 생성 문제

#### 문제: "ERROR: failed to create cluster: ... image not found"

**원인**: Docker에서 Kind 이미지를 다운로드하지 못함

**해결방법**:
```bash
# 1. 인터넷 연결 확인
ping 8.8.8.8

# 2. Docker Hub 접근 확인
docker pull kindest/node:v1.29.1

# 3. 프록시 설정 (회사 네트워크)
# Docker Desktop: Settings → Resources → Proxies

# 4. 기존 클러스터 삭제 후 재생성
kind delete cluster --name k8s-lab
kind create cluster --name k8s-lab
```

---

#### 문제: "ERROR: failed to create cluster: ... port is already allocated"

**원인**: 다른 프로세스가 이미 포트를 사용 중

**해결방법**:
```bash
# 1. 기존 클러스터 확인 및 삭제
kind get clusters
kind delete cluster --name k8s-lab

# 2. Docker 컨테이너 확인 및 정리
docker ps -a | grep kind
docker rm -f $(docker ps -aq --filter "name=kind")

# 3. 클러스터 재생성
kind create cluster --name k8s-lab
```

---

### 3. kubectl 관련 문제

#### 문제: "The connection to the server localhost:8080 was refused"

**원인**: kubeconfig 설정 오류 또는 클러스터 미실행

**해결방법**:
```bash
# 1. 클러스터 실행 확인
kind get clusters
docker ps | grep kind

# 2. kubeconfig 확인
kubectl config get-contexts

# 3. 컨텍스트 변경
kubectl config use-context kind-k8s-lab

# 4. 클러스터 재시작 (필요 시)
kind delete cluster --name k8s-lab
kind create cluster --name k8s-lab
```

---

#### 문제: "Unable to connect to the server: dial tcp ... i/o timeout"

**원인**: 네트워크 문제 또는 방화벽

**해결방법**:
```bash
# 1. Docker 네트워크 확인
docker network ls

# 2. Kind 컨테이너 재시작
docker restart k8s-lab-control-plane

# 3. 클러스터 재생성
kind delete cluster --name k8s-lab
kind create cluster --name k8s-lab
```

---

### 4. 이미지 Pull 실패

#### 문제: "ImagePullBackOff" 또는 "ErrImagePull"

**원인**: Docker Hub 접근 불가 또는 네트워크 문제

**해결방법**:
```bash
# 1. Pod 상세 정보 확인
kubectl describe pod <pod-name>

# 2. Docker에서 직접 이미지 Pull 테스트
docker pull nginx:1.25.3

# 3. 인터넷 연결 확인
ping registry-1.docker.io

# 4. 프록시 설정 (회사 네트워크)
# Docker Desktop: Settings → Resources → Proxies
```

---

### 5. 메모리 부족 문제

#### 문제: Pod가 Pending 상태로 유지되거나 "Insufficient memory" 오류

**원인**: Docker에 할당된 메모리 부족

**해결방법**:

**Docker Desktop (Windows/macOS)**:
1. **Settings** → **Resources** → **Memory**를 6GB 이상으로 증가
2. **Apply & Restart**

**Linux**:
```bash
# Docker 메모리 사용량 확인
docker stats

# 불필요한 컨테이너/이미지 정리
docker system prune -a
```

---

### 6. 회사/기관 네트워크 제한

#### 문제: Docker Hub 접근 불가

**증상**:
- 이미지 다운로드 실패
- "dial tcp: lookup registry-1.docker.io: no such host"

**해결방법**:

**1. IT 관리자에게 요청**:
- `registry-1.docker.io` 도메인 화이트리스트 추가
- `*.docker.io`, `*.docker.com` 허용
- HTTPS(443) 아웃바운드 허용

**2. 프록시 설정**:

**Docker Desktop (Windows/macOS)**:
1. **Settings** → **Resources** → **Proxies**
2. **Manual proxy configuration** 선택
3. HTTP/HTTPS 프록시 주소 입력
4. **Apply & Restart**

**Linux**:
```bash
# Docker 데몬 프록시 설정
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo nano /etc/systemd/system/docker.service.d/http-proxy.conf

# 다음 내용 추가:
[Service]
Environment="HTTP_PROXY=http://proxy.company.com:8080"
Environment="HTTPS_PROXY=http://proxy.company.com:8080"
Environment="NO_PROXY=localhost,127.0.0.1"

# 설정 적용
sudo systemctl daemon-reload
sudo systemctl restart docker
```

---

## 🔄 클러스터 관리 명령어

### 클러스터 시작/중지

```bash
# 클러스터 중지 (Docker 컨테이너 중지)
docker stop k8s-lab-control-plane

# 클러스터 재시작
docker start k8s-lab-control-plane

# 클러스터 완전 삭제
kind delete cluster --name k8s-lab
```

---

### 클러스터 상태 확인

```bash
# Kind 클러스터 목록
kind get clusters

# Docker에서 실행 중인 Kind 컨테이너 확인
docker ps --filter "name=kind"

# 클러스터 노드 상태
kubectl get nodes

# 모든 네임스페이스의 Pod 상태
kubectl get pods --all-namespaces
```

---

### 이미지 로드 (오프라인 환경)

```bash
# 로컬 이미지를 Kind 클러스터로 로드
kind load docker-image nginx:1.25.3 --name k8s-lab

# tar 파일에서 이미지 로드 후 Kind로 전송
docker load -i nginx.tar
kind load docker-image nginx:1.25.3 --name k8s-lab
```

---

## 📝 최종 체크리스트

실습 시작 전에 다음 항목들을 모두 확인해주세요:

### 도구 설치 확인
- [ ] Docker 설치 완료 (`docker --version`)
- [ ] kubectl 설치 완료 (`kubectl version --client`)
- [ ] Kind 설치 완료 (`kind version`)

### Kind 클러스터 확인
- [ ] 클러스터 생성 완료 (`kind create cluster --name k8s-lab`)
- [ ] 클러스터 목록 확인 (`kind get clusters` → k8s-lab)
- [ ] Docker 컨테이너 실행 확인 (`docker ps` → k8s-lab-control-plane)

### kubectl 동작 확인
- [ ] kubectl 컨텍스트 확인 (`kubectl config current-context` → kind-k8s-lab)
- [ ] 노드 상태 Ready 확인 (`kubectl get nodes`)
- [ ] 시스템 Pod Running 확인 (`kubectl get pods -n kube-system`)

### 기본 동작 테스트
- [ ] 테스트 Pod 생성 성공 (`kubectl run test-nginx --image=nginx:1.25.3`)
- [ ] Pod Running 상태 확인 (`kubectl get pods`)
- [ ] Pod 삭제 성공 (`kubectl delete pod test-nginx`)

### 시스템 리소스 확인
- [ ] 메모리: 최소 8GB (Docker에 4GB 할당)
- [ ] 디스크: 20GB 이상 여유 공간
- [ ] CPU: 2 코어 이상 (Docker에 2 코어 할당)

### 네트워크 확인
- [ ] 인터넷 연결 정상 (`ping 8.8.8.8`)
- [ ] Docker Hub 접근 가능 (`docker pull hello-world`)
- [ ] (프록시 사용 시) 프록시 설정 완료

---

## 🆘 추가 지원

### 유용한 참고 자료
- [Kind 공식 문서](https://kind.sigs.k8s.io/)
- [Docker 공식 문서](https://docs.docker.com/)
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [kubectl 치트시트](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

### Kind 관련 유용한 명령어
```bash
# Kind 도움말
kind --help

# 클러스터 생성 옵션 보기
kind create cluster --help

# Kind 버전 확인
kind version

# 클러스터 로그 확인
kind export logs --name k8s-lab
```

---

## 📚 다음 단계

환경 구성이 완료되면:
1. **Day 1 Session 1**: Pod vs Container vs Deployment 완전 정복
2. 실습 파일 다운로드 (`week_03_supplement/day1/session1/labs/` 디렉토리)
3. 편한 터미널 에디터 준비 (VS Code, vim, nano 등)

---

## 💡 Kind 사용 팁

### 장점
- ✅ **초경량**: Docker만 있으면 바로 실행 가능
- ✅ **빠른 시작**: 클러스터 생성이 1-2분 내 완료
- ✅ **멀티 노드**: 여러 노드 클러스터 쉽게 구성 가능
- ✅ **일회용**: 테스트 후 간단히 삭제하고 재생성
- ✅ **무료**: 완전 무료, 오픈소스

### 단점
- ❌ **프로덕션 부적합**: 로컬 개발/테스트용으로만 사용
- ❌ **영속성 제한**: 클러스터 삭제 시 모든 데이터 손실
- ❌ **리소스 제한**: Docker 리소스 제한을 받음

---

**⚠️ 중요**: 이 체크리스트의 모든 항목이 완료된 후에만 실습을 시작하세요. 미완료 항목이 있으면 실습 중 문제가 발생할 수 있습니다.

**🚀 실습 준비 완료!** Kind 클러스터가 정상적으로 실행되고 있다면, 이제 Week 3.5 보충 강좌를 시작할 준비가 되었습니다!
