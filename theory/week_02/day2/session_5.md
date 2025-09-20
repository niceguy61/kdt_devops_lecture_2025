# Week 2 Day 2 Session 5: 보안 사고 대응 시뮬레이션

<div align="center">
**🚨 보안 사고 발생** • **⚡ 신속 대응**
*실제 보안 사고 사례를 바탕으로 한 컨테이너 환경 사고 대응 훈련*
</div>

---

## 🕘 세션 정보
**시간**: 16:15-18:00 (105분)
**목표**: 실제 보안 사고 시나리오 기반 대응 훈련
**방식**: 개인별 사고 대응 + 사후 분석

## 🎯 세션 목표
### 📚 학습 목표
- **사고 인지**: 보안 사고 징후 조기 발견 능력
- **초기 대응**: 골든타임 내 피해 최소화 조치
- **증거 보전**: 포렌식을 위한 로그와 증거 수집
- **복구 계획**: 서비스 정상화를 위한 체계적 복구

### 🤔 왜 필요한가? (5분)
**최근 대형 보안 사고들**:
- **KT**: 개인정보 1,700만 건 유출 (2024.10)
- **SKT**: 고객 정보 접근 권한 오남용 (2024.09)
- **LG유플러스**: 내부자에 의한 정보 유출 (2024.08)
- **롯데카드**: 시스템 해킹으로 서비스 중단 (2024.07)

**공통 특징**:
- 초기 대응 지연으로 피해 확산
- 로그 부족으로 원인 분석 어려움
- 복구 계획 미비로 서비스 장기 중단
- 고객 신뢰도 급락과 막대한 손실

---

## 🚨 보안 사고 시뮬레이션 (105분)

### 📋 시나리오: "컨테이너 환경 침해 사고"

#### 🎬 사고 배경
**상황**: 금요일 오후 6시, 전자상거래 서비스 운영 중
**첫 징후**: 모니터링 시스템에서 이상 트래픽 감지
**환경**: Docker 컨테이너 기반 마이크로서비스 아키텍처

### Phase 1: 사고 발견 및 초기 대응 (30분)

#### 🔍 사고 징후 발견
**모니터링 알람**:
```bash
# 1. 비정상적인 네트워크 트래픽
[ALERT] Unusual outbound traffic detected
Source: web-container-01
Destination: 185.220.101.42 (TOR Exit Node)
Volume: 2.3GB in 10 minutes

# 2. 의심스러운 프로세스 실행
[ALERT] Suspicious process execution
Container: web-app-prod
Process: /tmp/.hidden/cryptominer
CPU Usage: 95%

# 3. 권한 상승 시도
[ALERT] Privilege escalation attempt
Container: api-server-02
Command: sudo -u root /bin/bash
Result: SUCCESS
```

#### ⚡ 초기 대응 체크리스트 (10분 내 완료)
```bash
# 1. 즉시 격리 (네트워크 차단)
docker network disconnect bridge web-container-01
iptables -A OUTPUT -s <container_ip> -j DROP

# 2. 컨테이너 상태 보존 (포렌식용)
docker commit web-container-01 evidence-web-container-01
docker save evidence-web-container-01 > /forensics/web-container-01.tar

# 3. 로그 수집
docker logs web-container-01 > /forensics/web-container-01.log
journalctl -u docker > /forensics/docker-daemon.log

# 4. 프로세스 정보 수집
docker exec web-container-01 ps aux > /forensics/processes.txt
docker exec web-container-01 netstat -tulpn > /forensics/network.txt
```

#### 🎯 개인별 초기 대응 실습
**실습 내용**:
1. **사고 인지**: 알람 분석하여 실제 사고인지 판단
2. **격리 조치**: 의심 컨테이너 네트워크 격리
3. **증거 보전**: 컨테이너 이미지와 로그 백업
4. **상황 보고**: 사고 현황을 간단히 정리

### Phase 2: 사고 분석 및 원인 규명 (45분)

#### 🔍 포렌식 분석
**컨테이너 이미지 분석**:
```bash
# 1. 취약점 스캔
trivy image evidence-web-container-01

# 2. 파일 시스템 변경 사항 확인
docker diff web-container-01

# 3. 의심스러운 파일 검사
docker exec web-container-01 find / -name "*.sh" -mtime -1
docker exec web-container-01 find /tmp -type f -executable
```

#### 📊 실제 사고 분석 결과 (시뮬레이션)
```
=== 침해 경로 분석 ===
1. 초기 침입: CVE-2019-20372 (nginx 취약점) 악용
2. 권한 상승: 컨테이너 root 권한으로 실행되어 호스트 접근
3. 지속성 확보: /tmp/.hidden/ 디렉토리에 백도어 설치
4. 데이터 유출: 고객 DB 접근 후 외부 서버로 전송

=== 피해 규모 ===
- 유출된 개인정보: 약 50만 건
- 서비스 중단 시간: 4시간 30분
- 예상 손실: 약 15억원 (매출 손실 + 복구 비용)
```

#### 🎯 개인별 분석 실습
**분석 포인트**:
1. **침해 경로**: 어떻게 공격자가 시스템에 침입했는가?
2. **권한 상승**: 어떤 방법으로 관리자 권한을 획득했는가?
3. **피해 범위**: 어떤 데이터가 유출되었고 영향 범위는?
4. **지속성**: 공격자가 재침입할 수 있는 백도어가 있는가?

### Phase 3: 복구 및 재발 방지 (30분)

#### 🛠️ 즉시 복구 조치
```bash
# 1. 침해된 컨테이너 완전 제거
docker stop web-container-01
docker rm web-container-01
docker rmi vulnerable-web-image

# 2. 보안 강화된 이미지로 재배포
docker build -f Dockerfile.secure -t secure-web-image .
docker run -d --name web-container-new \
  --user 1000:1000 \
  --read-only \
  --tmpfs /tmp \
  --cap-drop ALL \
  secure-web-image

# 3. 네트워크 보안 강화
# 불필요한 포트 차단
iptables -A INPUT -p tcp --dport 22 -j DROP
# 아웃바운드 트래픽 제한
iptables -A OUTPUT -d 185.220.101.0/24 -j DROP
```

#### 📋 재발 방지 대책
**기술적 대책**:
```bash
# 1. 정기적 취약점 스캔 자동화
# crontab -e
0 2 * * * trivy image --severity CRITICAL,HIGH production-images

# 2. 컨테이너 보안 정책 강화
# seccomp 프로파일 적용
docker run --security-opt seccomp=secure-profile.json app

# 3. 실시간 모니터링 강화
# Falco 룰 추가
- rule: Detect crypto mining
  condition: spawned_process and proc.name in (cryptominer, xmrig)
  output: Crypto mining detected (command=%proc.cmdline)
```

**관리적 대책**:
- 정기적 보안 교육 실시
- 사고 대응 매뉴얼 업데이트
- 모의 훈련 정기 실시
- 보안 담당자 24시간 대기 체계

#### 🎯 개인별 복구 계획 수립
**계획 수립 항목**:
1. **즉시 조치**: 30분 내 완료해야 할 긴급 조치
2. **단기 복구**: 24시간 내 서비스 정상화 방안
3. **중장기 대책**: 재발 방지를 위한 보안 강화 계획
4. **비용 산정**: 복구 및 보안 강화에 필요한 예산

---

## 📊 사고 대응 평가 기준

### ⏱️ 대응 시간 평가
- **골든타임 (10분)**: 초기 격리 및 증거 보전
- **복구 시간 (4시간)**: 서비스 정상화
- **완전 복구 (24시간)**: 보안 강화 완료

### 🎯 대응 품질 평가
- **사고 인지**: 징후를 얼마나 빨리 파악했는가?
- **초기 대응**: 피해 확산을 막았는가?
- **증거 보전**: 포렌식에 필요한 증거를 확보했는가?
- **복구 계획**: 체계적이고 실현 가능한 계획인가?

---

## 💡 실무 팁

### 🚨 사고 대응 골든룰
1. **침착함 유지**: 당황하지 말고 체계적으로 대응
2. **격리 우선**: 피해 확산 방지가 최우선
3. **증거 보전**: 삭제하기 전에 반드시 백업
4. **소통 강화**: 관련 부서와 지속적 소통
5. **문서화**: 모든 대응 과정을 상세히 기록

### 📋 사고 대응 체크리스트
```
□ 사고 발생 시각 기록
□ 초기 징후 스크린샷 저장
□ 의심 시스템 네트워크 격리
□ 관련 로그 파일 백업
□ 컨테이너/이미지 증거 보전
□ 상급자 및 관련 부서 보고
□ 고객 공지 준비 (필요시)
□ 복구 계획 수립 및 실행
□ 사후 분석 보고서 작성
□ 재발 방지 대책 수립
```

---

## 🔑 핵심 키워드
- **골든타임**: 사고 발생 후 초기 대응이 가능한 중요한 시간
- **격리(Isolation)**: 침해된 시스템을 네트워크에서 분리
- **증거 보전**: 포렌식 분석을 위한 디지털 증거 수집
- **IOC**: Indicator of Compromise (침해 지표)
- **TTP**: Tactics, Techniques, Procedures (공격자 행동 패턴)
- **복구 시간 목표(RTO)**: Recovery Time Objective
- **복구 지점 목표(RPO)**: Recovery Point Objective

---

## 📝 세션 마무리

### ✅ 오늘 세션 성과
- 실제 보안 사고 시나리오 기반 대응 경험
- 컨테이너 환경에서의 사고 대응 절차 습득
- 포렌식 기초 기법과 증거 보전 방법 학습
- 체계적인 복구 계획 수립 능력 개발

### 🎯 실무 적용 방안
- 소속 조직의 사고 대응 매뉴얼 검토
- 정기적인 모의 훈련 참여
- 보안 모니터링 도구 활용법 학습
- 사고 대응팀과의 협업 체계 구축

### 📚 추가 학습 자료
- **NIST Cybersecurity Framework**: 사고 대응 표준
- **SANS Incident Response**: 사고 대응 방법론
- **KISA 사이버위기 대응 매뉴얼**: 국내 대응 가이드
- **Docker Security Best Practices**: 컨테이너 보안 가이드

---

<div align="center">
**🛡️ 보안 사고는 예방이 최선이지만, 대응 준비는 필수입니다! 🛡️**
*오늘 배운 사고 대응 능력으로 더 안전한 시스템을 만들어가세요!*
</div>