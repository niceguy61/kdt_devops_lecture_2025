# Week 3 Day 3 Challenge 2: 네트워킹 & 스토리지 아키텍처 구현 챌린지 (선택사항, 90분)

<div align="center">

**🌐 네트워킹 설계** • **💾 스토리지 전략** • **📊 시각화 분석**

*Service, Ingress, PV/PVC를 활용한 3-Tier 애플리케이션 아키텍처 구현*

</div>

---

## 🎯 Challenge 목표

### 📚 학습 목표
- **네트워킹 설계**: Service 타입별 특징과 Ingress 라우팅 전략
- **스토리지 관리**: PV/PVC와 StorageClass 활용
- **실무 문서화**: 네트워크 토폴로지와 데이터 플로우 분석

### 🛠️ 구현 목표
- **GitHub Repository**: 네트워킹과 스토리지 설정의 체계적 관리
- **클러스터 시각화**: 서비스 메시와 데이터 플로우 시각화
- **분석 보고서**: 네트워크 성능과 스토리지 전략 분석

---

## 🌐 도메인 준비 (필수)

### 📋 도메인 발급 가이드
**Ingress 실습을 위해 도메인이 필요합니다.**

👉 **[무료 도메인 발급 가이드](../../shared/free-domain-guide.md)** 참조

### 🚀 빠른 시작 옵션
```bash
# Option 1: 로컬 테스트 (가장 빠름)
sudo nano /etc/hosts
# 추가: 192.168.49.2 shop.example.com api.example.com

# Option 2: 무료 도메인 (실제 도메인)
# Freenom에서 mylab.tk 발급 후 DNS 설정
```

---

## 🏗️ 구현 시나리오

### 📖 비즈니스 상황
**"E-Commerce 플랫폼의 마이크로서비스 네트워킹 설계"**

온라인 쇼핑몰이 급성장하면서 기존 모놀리식 아키텍처에서 
마이크로서비스로 전환합니다. 안정적인 네트워킹과 데이터 관리가 필요합니다.

### 🛒 서비스 구성 요구사항
1. **Frontend (React)**: 사용자 인터페이스
2. **User API**: 사용자 관리 서비스
3. **Product API**: 상품 관리 서비스  
4. **Order API**: 주문 처리 서비스
5. **PostgreSQL**: 사용자/주문 데이터
6. **MongoDB**: 상품 카탈로그 데이터
7. **Redis**: 세션 및 캐시

### 📋 네트워킹 요구사항
- **외부 접근**: `shop.example.com` 도메인으로 Frontend 접근
- **API 라우팅**: `api.example.com/users`, `/products`, `/orders`
- **내부 통신**: 마이크로서비스 간 ClusterIP 통신
- **데이터베이스**: 외부 접근 차단, 내부 서비스만 접근
- **캐시**: Redis 클러스터 구성

### 💾 스토리지 요구사항
- **PostgreSQL**: 고성능 SSD 스토리지 (20GB)
- **MongoDB**: 대용량 표준 스토리지 (50GB)
- **Redis**: 메모리 기반, 영속성 불필요
- **로그 수집**: 모든 서비스 로그 중앙 저장 (10GB)
- **백업**: 데이터베이스 백업 스토리지 (100GB)

---

## 📁 GitHub Repository 구조

### 필수 디렉토리 구조
```
ecommerce-k8s-platform/
├── README.md                           # 프로젝트 개요
├── k8s-manifests/                      # Kubernetes 매니페스트
│   ├── namespaces/
│   │   ├── frontend-ns.yaml
│   │   ├── backend-ns.yaml
│   │   └── data-ns.yaml
│   ├── networking/
│   │   ├── frontend-service.yaml
│   │   ├── api-services.yaml
│   │   ├── database-services.yaml
│   │   └── ingress.yaml
│   ├── storage/
│   │   ├── storage-classes.yaml
│   │   ├── postgres-pvc.yaml
│   │   ├── mongodb-pvc.yaml
│   │   └── logs-pvc.yaml
│   └── workloads/
│       ├── frontend-deployment.yaml
│       ├── api-deployments.yaml
│       └── database-statefulsets.yaml
├── docs/                               # 분석 문서
│   ├── network-storage-analysis.md    # 네트워크 & 스토리지 분석
│   └── screenshots/                   # 시각화 캡처
│       ├── network-topology.png
│       ├── service-mesh.png
│       └── storage-usage.png
└── scripts/                           # 배포/관리 스크립트
    ├── deploy-networking.sh           # 네트워킹 설정
    ├── deploy-storage.sh              # 스토리지 설정
    └── test-connectivity.sh           # 연결 테스트
```

---

## 📊 시각화 도구 활용

### 🛠️ 권장 시각화 도구
1. **Kubernetes Dashboard**: 서비스 메시 토폴로지
2. **K9s**: 실시간 네트워크 연결 상태
3. **kubectl tree**: Service와 Endpoint 관계
4. **Lens**: 스토리지 사용량 모니터링

### 📸 필수 캡처 항목
- **네트워크 토폴로지**: 서비스 간 연결 관계
- **Ingress 라우팅**: 외부 트래픽 라우팅 경로
- **스토리지 현황**: PV/PVC 바인딩 상태
- **데이터 플로우**: 애플리케이션 데이터 흐름

---

## 📝 분석 보고서 템플릿

### `docs/network-storage-analysis.md` 구조
```markdown
# E-Commerce 네트워킹 & 스토리지 분석 보고서

## 🎯 아키텍처 개요
### 전체 네트워크 토폴로지
[네트워크 다이어그램]

### 서비스 매핑
| 서비스 | Service 타입 | 포트 | 접근 방식 | 용도 |
|--------|--------------|------|-----------|------|
| Frontend | ClusterIP | 80 | Ingress | 웹 UI |
| User API | ClusterIP | 8080 | 내부 통신 | 사용자 관리 |
| Product API | ClusterIP | 8081 | 내부 통신 | 상품 관리 |
| Order API | ClusterIP | 8082 | 내부 통신 | 주문 처리 |
| PostgreSQL | ClusterIP | 5432 | 내부 전용 | 관계형 DB |
| MongoDB | ClusterIP | 27017 | 내부 전용 | 문서 DB |
| Redis | ClusterIP | 6379 | 내부 전용 | 캐시 |

## 🌐 네트워킹 설계 분석

### 1. Ingress 라우팅 전략
**도메인 기반 라우팅 구현:**
```yaml
# 구현한 Ingress 설정
spec:
  rules:
  - host: shop.example.com
    http:
      paths:
      - path: /
        backend:
          service:
            name: frontend-service
  - host: api.example.com
    http:
      paths:
      - path: /users
        backend:
          service:
            name: user-api-service
```

**라우팅 결정 이유:**
- 

### 2. 서비스 디스커버리
**ClusterIP 선택 이유:**
- 

**DNS 기반 통신 구현:**
- 

### 3. 보안 고려사항
**데이터베이스 격리 전략:**
- 

## 💾 스토리지 설계 분석

### 1. StorageClass 전략
**성능별 스토리지 분류:**
| 용도 | StorageClass | 크기 | 성능 특성 | 선택 이유 |
|------|--------------|------|-----------|----------|
| PostgreSQL | fast-ssd | 20GB | 고성능 | 트랜잭션 처리 |
| MongoDB | standard | 50GB | 표준 | 대용량 저장 |
| 로그 수집 | standard | 10GB | 표준 | 순차 쓰기 |
| 백업 | backup-storage | 100GB | 저비용 | 장기 보관 |

### 2. 데이터 영속성 전략
**StatefulSet vs Deployment 선택:**
- 

**백업 및 복구 계획:**
- 

### 3. 성능 최적화
**스토리지 성능 튜닝:**
- 

## 📈 성능 분석
### 네트워크 성능
1. **응답 시간**: 
2. **처리량**: 
3. **연결 안정성**: 

### 스토리지 성능
1. **IOPS**: 
2. **처리량**: 
3. **지연 시간**: 

## ⚠️ 제약사항 및 개선점
### 현재 제약사항
1. **단일 장애점**: 
2. **확장성 한계**: 
3. **보안 취약점**: 

### 개선 방안
#### 즉시 적용 (1주)
- [ ] 
- [ ] 

#### 단기 개선 (1개월)
- [ ] 
- [ ] 

#### 장기 개선 (3개월)
- [ ] 
- [ ] 

## 📊 시각화 결과 분석
### 네트워크 토폴로지
![네트워크 구조](screenshots/network-topology.png)
**분석**: 

### 서비스 메시
![서비스 연결](screenshots/service-mesh.png)
**분석**: 

### 스토리지 사용률
![스토리지 현황](screenshots/storage-usage.png)
**분석**: 

## 🎓 학습 인사이트
### 네트워킹 학습 포인트
- 

### 스토리지 학습 포인트
- 

### 실무 적용 고려사항
- 

## 🚀 확장 계획
### 트래픽 증가 대응
- 

### 데이터 증가 대응
- 
```

---

## 📋 제출 방법

### 1. GitHub Repository 생성
- **Repository 이름**: `w3d3-ecommerce-networking-storage`
- **Public Repository**로 설정
- **README.md**에 아키텍처 개요 작성

### 2. Discord 제출
```
📝 제출 형식:
**팀명**: [팀 이름]
**GitHub**: [Repository URL]
**완료 시간**: [HH:MM]
**네트워킹 특징**: [Ingress/Service 설계 포인트]
**스토리지 특징**: [PV/PVC 전략 포인트]
**도전했던 점**: [가장 복잡했던 설정]
```

---

## ⏰ 진행 일정

### 📅 시간 배분
```
1. 아키텍처 설계 (15분)
   - 네트워크 토폴로지 설계
   - 스토리지 전략 수립

2. 네트워킹 구현 (30분)
   - Service 및 Ingress 설정
   - 연결 테스트

3. 스토리지 구현 (25분)
   - StorageClass 및 PVC 생성
   - StatefulSet 배포

4. 시각화 및 분석 (15분)
   - 네트워크/스토리지 상태 캡처
   - 분석 보고서 작성

5. 문서화 및 제출 (5분)
   - GitHub 정리 및 제출
```

---

## 🏆 성공 기준

### ✅ 필수 달성 목표
- [ ] 모든 서비스 정상 통신 확인
- [ ] Ingress를 통한 외부 접근 성공
- [ ] 데이터베이스 데이터 영속성 확인
- [ ] 네트워크/스토리지 시각화 완료
- [ ] 분석 보고서 작성 완료

### 🌟 우수 달성 목표
- [ ] 고급 네트워킹 기능 적용 (Network Policy 등)
- [ ] 스토리지 성능 최적화 구현
- [ ] 보안 강화 설정 적용
- [ ] 상세한 성능 분석 및 개선 방안

---

## 💡 힌트 및 팁

### 🌐 네트워킹 팁
- **Service 확인**: `kubectl get svc -o wide`
- **Endpoint 확인**: `kubectl get endpoints`
- **Ingress 상태**: `kubectl describe ingress`
- **연결 테스트**: `kubectl exec -it pod -- curl service-name`

### 💾 스토리지 팁
- **PV 상태**: `kubectl get pv`
- **PVC 바인딩**: `kubectl get pvc`
- **StorageClass**: `kubectl get storageclass`
- **볼륨 마운트**: `kubectl describe pod`에서 Volumes 섹션 확인

---

<div align="center">

**🌐 네트워크 마스터리** • **💾 스토리지 전문성** • **📊 시각적 분석** • **🚀 실무 역량**

*네트워킹과 스토리지 학습을 통합한 E-Commerce 플랫폼 구축*

</div>

### 📖 비즈니스 상황
**"E-Commerce 플랫폼의 마이크로서비스 네트워킹 설계"**

온라인 쇼핑몰이 급성장하면서 기존 모놀리식 아키텍처에서 
마이크로서비스로 전환합니다. 안정적인 네트워킹과 데이터 관리가 필요합니다.

### 🛒 서비스 구성 요구사항
1. **Frontend (React)**: 사용자 인터페이스
2. **User API**: 사용자 관리 서비스
3. **Product API**: 상품 관리 서비스  
4. **Order API**: 주문 처리 서비스
5. **PostgreSQL**: 사용자/주문 데이터
6. **MongoDB**: 상품 카탈로그 데이터
7. **Redis**: 세션 및 캐시

### 📋 네트워킹 요구사항
- **외부 접근**: `shop.example.com` 도메인으로 Frontend 접근
- **API 라우팅**: `api.example.com/users`, `/products`, `/orders`
- **내부 통신**: 마이크로서비스 간 ClusterIP 통신
- **데이터베이스**: 외부 접근 차단, 내부 서비스만 접근
- **캐시**: Redis 클러스터 구성

### 💾 스토리지 요구사항
- **PostgreSQL**: 고성능 SSD 스토리지 (20GB)
- **MongoDB**: 대용량 표준 스토리지 (50GB)
- **Redis**: 메모리 기반, 영속성 불필요
- **로그 수집**: 모든 서비스 로그 중앙 저장 (10GB)
- **백업**: 데이터베이스 백업 스토리지 (100GB)

---

## 📁 GitHub Repository 구조

### 필수 디렉토리 구조
```
ecommerce-k8s-platform/
├── README.md                           # 프로젝트 개요
├── k8s-manifests/                      # Kubernetes 매니페스트
│   ├── namespaces/
│   │   ├── frontend-ns.yaml
│   │   ├── backend-ns.yaml
│   │   └── data-ns.yaml
│   ├── networking/
│   │   ├── frontend-service.yaml
│   │   ├── api-services.yaml
│   │   ├── database-services.yaml
│   │   └── ingress.yaml
│   ├── storage/
│   │   ├── storage-classes.yaml
│   │   ├── postgres-pvc.yaml
│   │   ├── mongodb-pvc.yaml
│   │   └── logs-pvc.yaml
│   └── workloads/
│       ├── frontend-deployment.yaml
│       ├── api-deployments.yaml
│       └── database-statefulsets.yaml
├── docs/                               # 분석 문서
│   ├── network-storage-analysis.md    # 네트워크 & 스토리지 분석
│   └── screenshots/                   # 시각화 캡처
│       ├── network-topology.png
│       ├── service-mesh.png
│       └── storage-usage.png
└── scripts/                           # 배포/관리 스크립트
    ├── deploy-networking.sh           # 네트워킹 설정
    ├── deploy-storage.sh              # 스토리지 설정
    └── test-connectivity.sh           # 연결 테스트
```

---

## 📊 시각화 도구 활용

### 🛠️ 권장 시각화 도구
1. **Kubernetes Dashboard**: 서비스 메시 토폴로지
2. **K9s**: 실시간 네트워크 연결 상태
3. **kubectl tree**: Service와 Endpoint 관계
4. **Lens**: 스토리지 사용량 모니터링

### 📸 필수 캡처 항목
- **네트워크 토폴로지**: 서비스 간 연결 관계
- **Ingress 라우팅**: 외부 트래픽 라우팅 경로
- **스토리지 현황**: PV/PVC 바인딩 상태
- **데이터 플로우**: 애플리케이션 데이터 흐름

---

## 📝 분석 보고서 템플릿

### `docs/network-storage-analysis.md` 구조
```markdown
# E-Commerce 네트워킹 & 스토리지 분석 보고서

## 🎯 아키텍처 개요
### 전체 네트워크 토폴로지
[네트워크 다이어그램]

### 서비스 매핑
| 서비스 | Service 타입 | 포트 | 접근 방식 | 용도 |
|--------|--------------|------|-----------|------|
| Frontend | ClusterIP | 80 | Ingress | 웹 UI |
| User API | ClusterIP | 8080 | 내부 통신 | 사용자 관리 |
| Product API | ClusterIP | 8081 | 내부 통신 | 상품 관리 |
| Order API | ClusterIP | 8082 | 내부 통신 | 주문 처리 |
| PostgreSQL | ClusterIP | 5432 | 내부 전용 | 관계형 DB |
| MongoDB | ClusterIP | 27017 | 내부 전용 | 문서 DB |
| Redis | ClusterIP | 6379 | 내부 전용 | 캐시 |

## 🌐 네트워킹 설계 분석

### 1. Ingress 라우팅 전략
**도메인 기반 라우팅 구현:**
```yaml
# 구현한 Ingress 설정
spec:
  rules:
  - host: shop.example.com
    http:
      paths:
      - path: /
        backend:
          service:
            name: frontend-service
  - host: api.example.com
    http:
      paths:
      - path: /users
        backend:
          service:
            name: user-api-service
```

**라우팅 결정 이유:**
- 

### 2. 서비스 디스커버리
**ClusterIP 선택 이유:**
- 

**DNS 기반 통신 구현:**
- 

### 3. 보안 고려사항
**데이터베이스 격리 전략:**
- 

## 💾 스토리지 설계 분석

### 1. StorageClass 전략
**성능별 스토리지 분류:**
| 용도 | StorageClass | 크기 | 성능 특성 | 선택 이유 |
|------|--------------|------|-----------|----------|
| PostgreSQL | fast-ssd | 20GB | 고성능 | 트랜잭션 처리 |
| MongoDB | standard | 50GB | 표준 | 대용량 저장 |
| 로그 수집 | standard | 10GB | 표준 | 순차 쓰기 |
| 백업 | backup-storage | 100GB | 저비용 | 장기 보관 |

### 2. 데이터 영속성 전략
**StatefulSet vs Deployment 선택:**
- 

**백업 및 복구 계획:**
- 

### 3. 성능 최적화
**스토리지 성능 튜닝:**
- 

## 📈 성능 분석
### 네트워크 성능
1. **응답 시간**: 
2. **처리량**: 
3. **연결 안정성**: 

### 스토리지 성능
1. **IOPS**: 
2. **처리량**: 
3. **지연 시간**: 

## ⚠️ 제약사항 및 개선점
### 현재 제약사항
1. **단일 장애점**: 
2. **확장성 한계**: 
3. **보안 취약점**: 

### 개선 방안
#### 즉시 적용 (1주)
- [ ] 
- [ ] 

#### 단기 개선 (1개월)
- [ ] 
- [ ] 

#### 장기 개선 (3개월)
- [ ] 
- [ ] 

## 📊 시각화 결과 분석
### 네트워크 토폴로지
![네트워크 구조](screenshots/network-topology.png)
**분석**: 

### 서비스 메시
![서비스 연결](screenshots/service-mesh.png)
**분석**: 

### 스토리지 사용률
![스토리지 현황](screenshots/storage-usage.png)
**분석**: 

## 🎓 학습 인사이트
### 네트워킹 학습 포인트
- 

### 스토리지 학습 포인트
- 

### 실무 적용 고려사항
- 

## 🚀 확장 계획
### 트래픽 증가 대응
- 

### 데이터 증가 대응
- 
```

---

## 📋 제출 방법

### 1. GitHub Repository 생성
- **Repository 이름**: `w3d3-ecommerce-networking-storage`
- **Public Repository**로 설정
- **README.md**에 아키텍처 개요 작성

### 2. Discord 제출
```
📝 제출 형식:
**팀명**: [팀 이름]
**GitHub**: [Repository URL]
**완료 시간**: [HH:MM]
**네트워킹 특징**: [Ingress/Service 설계 포인트]
**스토리지 특징**: [PV/PVC 전략 포인트]
**도전했던 점**: [가장 복잡했던 설정]
```

---

## ⏰ 진행 일정

### 📅 시간 배분
```
1. 아키텍처 설계 (15분)
   - 네트워크 토폴로지 설계
   - 스토리지 전략 수립

2. 네트워킹 구현 (30분)
   - Service 및 Ingress 설정
   - 연결 테스트

3. 스토리지 구현 (25분)
   - StorageClass 및 PVC 생성
   - StatefulSet 배포

4. 시각화 및 분석 (15분)
   - 네트워크/스토리지 상태 캡처
   - 분석 보고서 작성

5. 문서화 및 제출 (5분)
   - GitHub 정리 및 제출
```

---

## 🏆 성공 기준

### ✅ 필수 달성 목표
- [ ] 모든 서비스 정상 통신 확인
- [ ] Ingress를 통한 외부 접근 성공
- [ ] 데이터베이스 데이터 영속성 확인
- [ ] 네트워크/스토리지 시각화 완료
- [ ] 분석 보고서 작성 완료

### 🌟 우수 달성 목표
- [ ] 고급 네트워킹 기능 적용 (Network Policy 등)
- [ ] 스토리지 성능 최적화 구현
- [ ] 보안 강화 설정 적용
- [ ] 상세한 성능 분석 및 개선 방안

---

## 💡 힌트 및 팁

### 🌐 네트워킹 팁
- **Service 확인**: `kubectl get svc -o wide`
- **Endpoint 확인**: `kubectl get endpoints`
- **Ingress 상태**: `kubectl describe ingress`
- **연결 테스트**: `kubectl exec -it pod -- curl service-name`

### 💾 스토리지 팁
- **PV 상태**: `kubectl get pv`
- **PVC 바인딩**: `kubectl get pvc`
- **StorageClass**: `kubectl get storageclass`
- **볼륨 마운트**: `kubectl describe pod`에서 Volumes 섹션 확인

---

<div align="center">

**🌐 네트워크 마스터리** • **💾 스토리지 전문성** • **📊 시각적 분석** • **🚀 실무 역량**

*네트워킹과 스토리지 학습을 통합한 E-Commerce 플랫폼 구축*

</div>
