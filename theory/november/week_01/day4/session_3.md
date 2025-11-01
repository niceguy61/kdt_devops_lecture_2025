# November Week 1 Day 4 Session 3: 고가용성 아키텍처

<div align="center">

**🔄 Multi-AZ** • **🚀 무중단 배포** • **🛡️ 장애 대응**

*고가용성 설계로 안정적인 서비스 제공*

</div>

---

## 🕘 세션 정보
**시간**: 10:00-10:20 (20분)
**목표**: Multi-AZ 고가용성 설계 및 무중단 배포 전략

---

## 📖 서비스 개요

### 1. 생성 배경 (Why?)

**문제 상황**:
- **단일 장애점**: 하나의 AZ 장애 시 전체 서비스 중단
- **배포 중 다운타임**: 새 버전 배포 시 서비스 중단
- **장애 복구 지연**: 수동 복구로 인한 긴 다운타임
- **데이터 손실 위험**: 백업 부족으로 데이터 손실

**AWS 고가용성 솔루션**:
- **Multi-AZ 배포**: 여러 AZ에 분산 배치
- **자동 Failover**: 장애 시 자동 전환
- **무중단 배포**: Blue-Green, Canary 배포
- **자동 백업**: 정기 백업 및 복구

---

### 2. 핵심 원리 (How?)

**Multi-AZ 고가용성 아키텍처**:

![Multi-AZ High Availability](./generated-diagrams/generated-diagrams/multi_az_ha.png)

*그림: Multi-AZ 고가용성 아키텍처 - 여러 AZ에 분산 배치로 장애 대응*

**작동 원리**:
1. **Multi-AZ 배포**: 최소 2개 AZ에 리소스 배치
2. **ALB 트래픽 분산**: 정상 AZ로만 트래픽 전송
3. **RDS Multi-AZ**: Primary-Standby 동기 복제
4. **자동 Failover**: 장애 AZ 감지 시 자동 전환
5. **Health Check**: 지속적인 상태 확인

**고가용성 계산**:
```
단일 AZ 가용성: 99.5%
Multi-AZ 가용성: 99.99%

연간 다운타임:
- 단일 AZ: 43.8시간
- Multi-AZ: 52.6분
```

---

### 3. 주요 사용 사례 (When?)

**적합한 경우**:
- ✅ 미션 크리티컬 서비스 (금융, 의료)
- ✅ 24/7 운영 필요
- ✅ SLA 99.9% 이상 요구
- ✅ 데이터 손실 불가

**실제 사례**:
- **Netflix**: Multi-Region 고가용성
- **Amazon**: Multi-AZ + Multi-Region
- **카카오**: 2022년 판교 데이터센터 화재 교훈

---

### 4. 비슷한 서비스 비교 (Which?)

**Blue-Green vs Canary vs Rolling Deployment**:

| 배포 방식 | Blue-Green | Canary | Rolling |
|----------|------------|--------|---------|
| **다운타임** | 없음 | 없음 | 없음 |
| **롤백 속도** | 즉시 | 빠름 | 느림 |
| **리소스 비용** | 2배 | 1.1배 | 1배 |
| **위험도** | 낮음 | 매우 낮음 | 중간 |
| **복잡도** | 낮음 | 높음 | 중간 |
| **사용 사례** | 대규모 변경 | 점진적 검증 | 일반 배포 |

**선택 기준**:
- **안전한 배포** → Blue-Green (즉시 롤백)
- **점진적 검증** → Canary (10% → 50% → 100%)
- **일반적인 경우** → Rolling (순차적 교체)

---

### 5. 장단점 분석

**Multi-AZ 장점**:
- ✅ 높은 가용성 (99.99%)
- ✅ 자동 Failover
- ✅ 데이터 손실 방지
- ✅ 지역적 장애 대응

**Multi-AZ 단점**:
- ⚠️ 비용 증가 (2배 이상)
- ⚠️ 복잡도 증가
- ⚠️ 네트워크 지연 (AZ 간)
- ⚠️ 데이터 동기화 오버헤드

---

### 6. 비용 구조 💰

**Multi-AZ 추가 비용**:
- **EC2**: 2배 (각 AZ에 인스턴스)
- **RDS Multi-AZ**: 2배 (Primary + Standby)
- **데이터 전송**: AZ 간 전송 $0.01/GB
- **ALB**: 동일 (Multi-AZ 기본)

**비용 최적화**:
- Reserved Instance로 장기 할인
- Spot Instance 혼합 사용
- 개발/테스트 환경은 단일 AZ

---

### 7. 최신 업데이트 🆕

**2024년 주요 변경사항**:
- Multi-AZ with Standby: RDS 읽기 성능 향상
- Cross-Region Replication: 재해 복구 강화
- Zonal Autoshift: 자동 AZ 전환

---

### 8. 잘 사용하는 방법 ✅

**베스트 프랙티스**:
1. **최소 2개 AZ**: 고가용성 기본
2. **3개 AZ 권장**: 더 높은 가용성
3. **Health Check 필수**: 장애 감지 자동화
4. **자동 백업**: 일일 백업 + 트랜잭션 로그
5. **재해 복구 계획**: DR 시나리오 및 테스트

---

### 9. 잘못 사용하는 방법 ❌

**흔한 실수**:
1. ❌ 단일 AZ 배포 (고가용성 부족)
2. ❌ 모든 리소스를 같은 AZ에 배치
3. ❌ Health Check 미설정 (장애 감지 불가)
4. ❌ 백업 미설정 (데이터 손실 위험)
5. ❌ Failover 테스트 안 함 (실제 장애 시 문제)

---

### 10. 구성 요소 상세

**주요 구성 요소**:

**1. Multi-AZ 배포**:
- **ALB**: 자동으로 모든 AZ에 배포
- **ASG**: 여러 AZ에 인스턴스 분산
- **RDS**: Primary (AZ-A) + Standby (AZ-B)
- **ElastiCache**: 자동 Failover 지원

**2. Blue-Green 배포**:
- **Blue 환경**: 현재 운영 중인 버전
- **Green 환경**: 새 버전 배포
- **전환**: ALB Target Group 전환
- **롤백**: Blue로 즉시 복귀

**3. Canary 배포**:
- **Phase 1**: 10% 트래픽 → 새 버전
- **Phase 2**: 50% 트래픽 → 새 버전
- **Phase 3**: 100% 트래픽 → 새 버전
- **모니터링**: 각 단계마다 메트릭 확인

---

### 11. 공식 문서 링크 (필수 5개)

**⚠️ 학생들이 직접 확인해야 할 공식 문서**:
- 📘 [AWS 고가용성 아키텍처](https://docs.aws.amazon.com/whitepapers/latest/real-time-communication-on-aws/high-availability-and-scalability-on-aws.html)
- 📗 [Multi-AZ 배포](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html)
- 📙 [Blue-Green 배포](https://docs.aws.amazon.com/whitepapers/latest/blue-green-deployments/welcome.html)
- 📕 [재해 복구](https://docs.aws.amazon.com/whitepapers/latest/disaster-recovery-workloads-on-aws/disaster-recovery-workloads-on-aws.html)
- 🆕 [AWS 아키텍처 센터](https://aws.amazon.com/architecture/)

---

<div align="center">

**🔄 Multi-AZ** • **🚀 무중단 배포** • **🛡️ 장애 대응**

*고가용성 아키텍처로 안정적인 서비스 제공*

</div>
