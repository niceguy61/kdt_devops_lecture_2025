# 무료 도메인 발급 가이드

## 🌐 개요
Kubernetes Ingress 실습을 위해 무료 도메인을 발급받는 방법을 안내합니다.

---

## 🆓 무료 도메인 서비스 옵션

### 1. **Freenom** (추천)
**장점**: 완전 무료, 1년 사용 가능, 갱신 가능
**도메인**: .tk, .ml, .ga, .cf

#### 발급 절차
1. **사이트 접속**: https://www.freenom.com
2. **도메인 검색**: 원하는 도메인명 입력
3. **무료 도메인 선택**: .tk, .ml, .ga, .cf 중 선택
4. **기간 설정**: 최대 12개월 무료
5. **계정 생성**: 이메일 인증 필요
6. **DNS 설정**: 나중에 설정 가능

### 2. **Duck DNS** (동적 DNS)
**장점**: 설정 간단, API 지원, 무제한 사용
**도메인**: yourname.duckdns.org

#### 발급 절차
1. **사이트 접속**: https://www.duckdns.org
2. **로그인**: GitHub, Google, Reddit 계정으로 로그인
3. **서브도메인 생성**: yourname.duckdns.org
4. **토큰 발급**: API 토큰 자동 생성
5. **IP 업데이트**: 수동 또는 자동 업데이트

### 3. **No-IP** (동적 DNS)
**장점**: 안정적, 30일마다 갱신 필요
**도메인**: yourname.ddns.net, yourname.hopto.org

#### 발급 절차
1. **사이트 접속**: https://www.noip.com
2. **무료 계정 생성**: 이메일 인증
3. **호스트네임 생성**: 최대 3개 무료
4. **30일 갱신**: 이메일 링크 클릭으로 갱신

---

## 🔧 실습용 권장 설정

### Option 1: Freenom 사용 (실제 도메인)
```bash
# 예시 도메인: mylab.tk
# Ingress에서 사용할 도메인들
- frontend.mylab.tk
- api.mylab.tk
- admin.mylab.tk
```

### Option 2: Duck DNS 사용 (서브도메인)
```bash
# 예시: mylab.duckdns.org
# 서브도메인 구성
- frontend-mylab.duckdns.org
- api-mylab.duckdns.org
- admin-mylab.duckdns.org
```

### Option 3: 로컬 테스트 (hosts 파일)
```bash
# /etc/hosts 파일 수정 (로컬 테스트용)
127.0.0.1 frontend.local
127.0.0.1 api.local
127.0.0.1 admin.local
```

---

## 📋 DNS 설정 방법

### Freenom DNS 설정
1. **Freenom 대시보드** 접속
2. **Manage Domain** → **Manage Freenom DNS**
3. **A 레코드 추가**:
   ```
   Name: frontend
   Type: A
   TTL: 3600
   Target: [NodePort IP 또는 LoadBalancer IP]
   ```

### Duck DNS 설정
```bash
# API로 IP 업데이트
curl "https://www.duckdns.org/update?domains=mylab&token=your-token&ip=your-ip"

# 또는 웹 인터페이스에서 IP 직접 입력
```

### 로컬 hosts 파일 설정
```bash
# Linux/macOS
sudo nano /etc/hosts

# Windows
# C:\Windows\System32\drivers\etc\hosts 파일 편집

# 추가할 내용 (NodePort 사용 시)
192.168.49.2 frontend.local  # minikube ip
192.168.49.2 api.local
192.168.49.2 admin.local
```

---

## 🛠️ Kubernetes 설정 예시

### Ingress 설정 (실제 도메인)
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: frontend.mylab.tk  # Freenom 도메인
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
  - host: api.mylab.tk
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 8080
```

### Ingress 설정 (로컬 테스트)
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress-local
spec:
  rules:
  - host: frontend.local  # hosts 파일 설정
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
```

---

## 🔍 테스트 및 검증

### DNS 해석 확인
```bash
# 도메인 해석 테스트
nslookup frontend.mylab.tk
dig frontend.mylab.tk

# 로컬 테스트
ping frontend.local
```

### Ingress 동작 확인
```bash
# 브라우저 또는 curl로 테스트
curl http://frontend.mylab.tk
curl http://api.mylab.tk

# 로컬 테스트
curl http://frontend.local
```

### Kubernetes 상태 확인
```bash
# Ingress 상태 확인
kubectl get ingress
kubectl describe ingress web-ingress

# Service 확인
kubectl get svc
```

---

## ⚠️ 주의사항

### Freenom 사용 시
- **정기 갱신**: 만료 전 갱신 필요
- **DNS 전파**: 설정 후 최대 24시간 소요
- **트래픽 제한**: 과도한 트래픽 시 제한 가능

### Duck DNS 사용 시
- **IP 업데이트**: 공인 IP 변경 시 수동 업데이트
- **서브도메인 제한**: 하나의 도메인만 무료

### 로컬 테스트 시
- **hosts 파일**: 로컬에서만 동작
- **팀 공유**: 각자 hosts 파일 설정 필요
- **실제 배포**: 실제 도메인 필요

---

## 🚀 실습별 권장 방법

### Lab 1 (기본 실습)
- **로컬 테스트**: hosts 파일 사용
- **빠른 시작**: 도메인 발급 시간 절약

### Lab 2 (심화 실습)
- **실제 도메인**: Freenom 또는 Duck DNS
- **실무 경험**: 실제 DNS 설정 경험

### Challenge
- **실제 도메인**: 포트폴리오용 실제 도메인
- **GitHub 연동**: 실제 접속 가능한 데모

---

## 💡 팁 및 트러블슈팅

### 일반적인 문제
1. **DNS 전파 지연**: 24시간까지 소요 가능
2. **캐시 문제**: `ipconfig /flushdns` (Windows) 또는 `sudo dscacheutil -flushcache` (macOS)
3. **방화벽**: NodePort 포트 개방 확인

### 빠른 해결책
```bash
# DNS 캐시 초기화
# Linux
sudo systemctl restart systemd-resolved

# macOS
sudo dscacheutil -flushcache

# Windows
ipconfig /flushdns
```

### 대안 방법
- **ngrok**: 로컬 서비스를 임시 공개 도메인으로 노출
- **localhost.run**: 무료 터널링 서비스
- **Cloudflare Tunnel**: 무료 터널링 (설정 복잡)

---

<div align="center">

**🌐 무료 도메인** • **🔧 간편 설정** • **🚀 실습 최적화**

*Kubernetes Ingress 실습을 위한 완벽한 도메인 가이드*

</div>
