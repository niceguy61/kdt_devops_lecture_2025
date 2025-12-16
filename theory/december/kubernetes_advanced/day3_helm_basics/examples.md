# Day 3 실습 예제 모음

## 🎯 목적
Day 3 세션에서 사용하는 모든 Helm 명령어와 예제를 한 곳에 모아 챌린저들이 쉽게 참조할 수 있도록 합니다.

---

## 📋 Session 1 예제: Helm 기초 및 설치

### Helm 설치 및 설정

#### Helm 설치
```bash
# Helm 설치 스크립트 사용
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# 수동 설치 (Linux)
wget https://get.helm.sh/helm-v3.13.0-linux-amd64.tar.gz
tar -zxvf helm-v3.13.0-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm

# 설치 확인
helm version
helm version --short
```

#### Repository 관리
```bash
# 저장소 추가
helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# 저장소 목록 확인
helm repo list

# 저장소 업데이트
helm repo update

# 저장소 제거
helm repo remove stable

# Chart 검색
helm search repo nginx
helm search repo mysql
helm search hub wordpress  # Artifact Hub 검색
```

### Chart 정보 확인

#### Chart 정보 조회
```bash
# Chart 기본 정보
helm show chart bitnami/nginx

# Chart Values 확인
helm show values bitnami/nginx

# Chart README 확인
helm show readme bitnami/nginx

# 모든 정보 확인
helm show all bitnami/nginx
```

#### Chart 다운로드
```bash
# Chart 다운로드
helm pull bitnami/nginx

# 압축 해제하여 다운로드
helm pull bitnami/nginx --untar

# 특정 버전 다운로드
helm pull bitnami/nginx --version 13.2.23
```

### 기본 Chart 관리

#### Chart 설치
```bash
# 기본 설치
helm install my-release bitnami/nginx

# 네임스페이스 지정
helm install my-release bitnami/nginx -n my-namespace

# 네임스페이스 자동 생성
helm install my-release bitnami/nginx -n my-namespace --create-namespace

# Values 오버라이드
helm install my-release bitnami/nginx --set replicaCount=3

# Values 파일 사용
helm install my-release bitnami/nginx -f my-values.yaml

# Dry-run (실제 설치하지 않고 테스트)
helm install my-release bitnami/nginx --dry-run --debug
```

#### Release 관리
```bash
# Release 목록
helm list
helm list --all-namespaces
helm list -n my-namespace

# Release 상태 확인
helm status my-release
helm status my-release -n my-namespace

# Release 히스토리
helm history my-release
helm history my-release -n my-namespace

# Release 업그레이드
helm upgrade my-release bitnami/nginx --set replicaCount=5
helm upgrade my-release bitnami/nginx -f new-values.yaml

# Release 롤백
helm rollback my-release 1  # 버전 1로 롤백
helm rollback my-release     # 이전 버전으로 롤백

# Release 삭제
helm uninstall my-release
helm uninstall my-release -n my-namespace
```

---

## 📋 Session 2 예제: Chart 커스터마이징

### Chart 생성 및 구조

#### 새 Chart 생성
```bash
# Chart 생성
helm create my-app

# Chart 구조 확인
tree my-app/
find my-app/ -type f -name "*.yaml" -o -name "*.tpl"
```

#### Chart.yaml 예제
```yaml
apiVersion: v2
name: my-web-app
description: A Helm chart for my web application
type: application
version: 0.1.0
appVersion: "1.0.0"
keywords:
  - web
  - nginx
  - application
home: https://github.com/myorg/my-web-app
sources:
  - https://github.com/myorg/my-web-app
maintainers:
  - name: Developer Team
    email: dev@myorg.com
dependencies:
  - name: mysql
    version: 9.4.1
    repository: https://charts.bitnami.com/bitnami
    condition: mysql.enabled
```

### Values 파일 관리

#### 기본 values.yaml 구조
```yaml
# 애플리케이션 설정
app:
  name: my-web-app
  version: "1.0.0"
  environment: development

# 이미지 설정
image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "1.21"

# 레플리카 설정
replicaCount: 1

# 서비스 설정
service:
  type: ClusterIP
  port: 80
  targetPort: 8080

# 인그레스 설정
ingress:
  enabled: false
  className: ""
  annotations: {}
  hosts:
    - host: chart-example.local
      paths:
        - path: /
          pathType: Prefix
  tls: []

# 리소스 설정
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

# 오토스케일링 설정
autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80

# 노드 선택 및 톨러레이션
nodeSelector: {}
tolerations: []
affinity: {}

# 보안 컨텍스트
securityContext: {}
podSecurityContext: {}

# 서비스 어카운트
serviceAccount:
  create: true
  annotations: {}
  name: ""
```

#### 환경별 Values 파일 예제

**development.yaml**
```yaml
replicaCount: 1
image:
  tag: "latest"
service:
  type: ClusterIP
resources:
  requests:
    cpu: 100m
    memory: 128Mi
app:
  environment: development
  debug: true
```

**staging.yaml**
```yaml
replicaCount: 2
image:
  tag: "v1.0.0"
service:
  type: LoadBalancer
resources:
  requests:
    cpu: 250m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi
app:
  environment: staging
  debug: false
```

**production.yaml**
```yaml
replicaCount: 3
image:
  tag: "v1.0.0"
service:
  type: LoadBalancer
resources:
  requests:
    cpu: 500m
    memory: 512Mi
  limits:
    cpu: 1000m
    memory: 1Gi
autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
app:
  environment: production
  debug: false
```

### 템플릿 작성

#### Deployment 템플릿 예제
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "my-app.fullname" . }}
  labels:
    {{- include "my-app.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "my-app.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      annotations:
        checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
      labels:
        {{- include "my-app.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "my-app.serviceAccountName" . }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
        - name: {{ .Chart.Name }}
          securityContext:
            {{- toYaml .Values.securityContext | nindent 12 }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ .Values.service.targetPort }}
              protocol: TCP
          livenessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /ready
              port: http
            initialDelaySeconds: 5
            periodSeconds: 5
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          env:
            - name: ENVIRONMENT
              value: {{ .Values.app.environment | quote }}
            - name: DEBUG
              value: {{ .Values.app.debug | quote }}
          {{- if .Values.config }}
          envFrom:
            - configMapRef:
                name: {{ include "my-app.fullname" . }}-config
          {{- end }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
```

#### Service 템플릿 예제
```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ include "my-app.fullname" . }}
  labels:
    {{- include "my-app.labels" . | nindent 4 }}
  {{- with .Values.service.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
      protocol: TCP
      name: http
      {{- if and (eq .Values.service.type "NodePort") .Values.service.nodePort }}
      nodePort: {{ .Values.service.nodePort }}
      {{- end }}
  selector:
    {{- include "my-app.selectorLabels" . | nindent 4 }}
  {{- if eq .Values.service.type "LoadBalancer" }}
  {{- with .Values.service.loadBalancerIP }}
  loadBalancerIP: {{ . }}
  {{- end }}
  {{- with .Values.service.loadBalancerSourceRanges }}
  loadBalancerSourceRanges:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- end }}
```

#### ConfigMap 템플릿 예제
```yaml
{{- if .Values.config }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "my-app.fullname" . }}-config
  labels:
    {{- include "my-app.labels" . | nindent 4 }}
data:
  {{- range $key, $value := .Values.config }}
  {{ $key }}: {{ $value | quote }}
  {{- end }}
  {{- if .Values.configFiles }}
  {{- range $key, $value := .Values.configFiles }}
  {{ $key }}: |
    {{- $value | nindent 4 }}
  {{- end }}
  {{- end }}
{{- end }}
```

### 헬퍼 템플릿 (_helpers.tpl)

```yaml
{{/*
Expand the name of the chart.
*/}}
{{- define "my-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "my-app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "my-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "my-app.labels" -}}
helm.sh/chart: {{ include "my-app.chart" . }}
{{ include "my-app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "my-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "my-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "my-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "my-app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
```

---

## 🔧 유용한 Helm 명령어 모음

### Chart 개발 및 테스트

#### Chart 검증
```bash
# Chart 문법 검증
helm lint my-chart/

# 의존성 확인
helm dependency list my-chart/
helm dependency update my-chart/

# 템플릿 렌더링 테스트
helm template my-release my-chart/
helm template my-release my-chart/ --debug
helm template my-release my-chart/ -f values/production.yaml

# 특정 템플릿만 렌더링
helm template my-release my-chart/ -s templates/deployment.yaml

# Values 검증
helm template my-release my-chart/ --validate
```

#### Chart 패키징 및 배포
```bash
# Chart 패키징
helm package my-chart/

# 패키지 서명
helm package my-chart/ --sign --key mykey --keyring ~/.gnupg/secring.gpg

# 로컬 저장소 서버 시작
helm serve --repo-path ./charts

# Chart 인덱스 생성
helm repo index ./charts --url https://myrepo.com/charts
```

### 고급 Release 관리

#### 조건부 설치
```bash
# 조건부 업그레이드 (존재하지 않으면 설치)
helm upgrade --install my-release my-chart/

# 원자적 설치 (실패 시 자동 롤백)
helm install my-release my-chart/ --atomic

# 타임아웃 설정
helm install my-release my-chart/ --timeout 10m

# 대기 조건 설정
helm install my-release my-chart/ --wait --wait-for-jobs
```

#### Release 정보 확인
```bash
# Release 값 확인
helm get values my-release
helm get values my-release --all  # 기본값 포함

# Release 매니페스트 확인
helm get manifest my-release

# Release 훅 확인
helm get hooks my-release

# Release 노트 확인
helm get notes my-release
```

### 디버깅 및 트러블슈팅

#### 일반적인 문제 해결
```bash
# 템플릿 문법 오류 확인
helm template my-release my-chart/ --debug

# Values 파일 문법 확인
helm lint my-chart/ -f values/production.yaml

# 의존성 문제 해결
helm dependency update my-chart/

# Release 상태 문제 해결
helm status my-release --show-desc

# 실패한 Release 정리
helm uninstall my-release --no-hooks
```

#### 로그 및 이벤트 확인
```bash
# Helm 관련 Pod 로그 확인
kubectl logs -l app.kubernetes.io/managed-by=Helm

# Release 관련 이벤트 확인
kubectl get events --field-selector reason=FailedMount

# Chart 테스트 실행
helm test my-release
```

---

## 🚨 트러블슈팅 가이드

### 일반적인 문제들

#### Chart 템플릿 오류
```bash
# 문제: YAML 파싱 오류
# 해결: 템플릿 문법 확인
helm template my-release my-chart/ --debug

# 문제: 함수 사용 오류
# 해결: 헬퍼 함수 정의 확인
grep -r "define.*function-name" my-chart/templates/
```

#### Values 파일 문제
```bash
# 문제: Values 적용 안됨
# 해결: Values 파일 경로 및 문법 확인
helm template my-release my-chart/ -f values/dev.yaml --debug

# 문제: 기본값 오버라이드 안됨
# 해결: Values 우선순위 확인 (CLI > -f 파일 > values.yaml)
helm get values my-release --all
```

#### 의존성 문제
```bash
# 문제: 의존성 Chart 다운로드 실패
# 해결: 저장소 업데이트 및 의존성 업데이트
helm repo update
helm dependency update my-chart/

# 문제: 의존성 버전 충돌
# 해결: Chart.yaml의 의존성 버전 확인
helm dependency list my-chart/
```

#### Release 관리 문제
```bash
# 문제: Release 설치 실패
# 해결: 네임스페이스 및 권한 확인
kubectl auth can-i create deployments --namespace=my-namespace

# 문제: 업그레이드 실패
# 해결: 리소스 상태 및 충돌 확인
kubectl get all -l app.kubernetes.io/instance=my-release

# 문제: 롤백 실패
# 해결: 히스토리 확인 및 강제 삭제
helm history my-release
helm uninstall my-release --no-hooks
```

이 예제 모음을 통해 챌린저들이 Helm을 효과적으로 활용할 수 있을 것입니다!
