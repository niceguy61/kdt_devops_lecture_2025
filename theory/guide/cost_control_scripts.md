# 💰 비용 통제 자동화 스크립트

<div align="center">

**🎯 예산 초과 방지를 위한 자동화 도구** • **📊 실시간 모니터링**

*지원 예산 내에서 안전한 AWS 사용을 위한 스크립트 모음*

</div>

---

## 📋 스크립트 개요

### 🎯 목적
- 기본 프로젝트(20만원) / 심화 프로젝트(30만원) 예산 준수
- 예상치 못한 비용 발생 즉시 차단
- 일일 비용 모니터링 자동화
- 불필요한 리소스 자동 정리

---

## 🔧 1. 일일 비용 체크 스크립트

### daily_cost_check.sh
```bash
#!/bin/bash

# 일일 비용 체크 및 알림 스크립트
# 사용법: ./daily_cost_check.sh [basic|advanced]

PROJECT_TYPE=${1:-basic}
TODAY=$(date +%Y-%m-%d)
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d)

# 프로젝트별 예산 설정
if [ "$PROJECT_TYPE" = "basic" ]; then
    MONTHLY_BUDGET=150  # $150 (20만원)
    DAILY_LIMIT=5       # $5/일
elif [ "$PROJECT_TYPE" = "advanced" ]; then
    MONTHLY_BUDGET=225  # $225 (30만원)
    DAILY_LIMIT=7       # $7/일
else
    echo "사용법: $0 [basic|advanced]"
    exit 1
fi

echo "=== 일일 비용 체크 ($PROJECT_TYPE 프로젝트) ==="
echo "날짜: $TODAY"
echo "예산: \$$MONTHLY_BUDGET/월, \$$DAILY_LIMIT/일"
echo ""

# 어제 비용 조회
YESTERDAY_COST=$(aws ce get-cost-and-usage \
    --time-period Start=$YESTERDAY,End=$TODAY \
    --granularity DAILY \
    --metrics BlendedCost \
    --query 'ResultsByTime[0].Total.BlendedCost.Amount' \
    --output text)

# 이번 달 누적 비용 조회
MONTH_START=$(date +%Y-%m-01)
MONTH_COST=$(aws ce get-cost-and-usage \
    --time-period Start=$MONTH_START,End=$TODAY \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --query 'ResultsByTime[0].Total.BlendedCost.Amount' \
    --output text)

# 비용 분석
YESTERDAY_COST_ROUNDED=$(printf "%.2f" $YESTERDAY_COST)
MONTH_COST_ROUNDED=$(printf "%.2f" $MONTH_COST)
BUDGET_USAGE=$(echo "scale=1; $MONTH_COST * 100 / $MONTHLY_BUDGET" | bc)

echo "어제 비용: \$$YESTERDAY_COST_ROUNDED"
echo "이번 달 누적: \$$MONTH_COST_ROUNDED"
echo "예산 사용률: $BUDGET_USAGE%"
echo ""

# 경고 체크
if (( $(echo "$YESTERDAY_COST > $DAILY_LIMIT" | bc -l) )); then
    echo "🚨 경고: 일일 한도 초과! (\$$YESTERDAY_COST_ROUNDED > \$$DAILY_LIMIT)"
    echo "리소스 점검이 필요합니다."
    
    # 강사에게 알림 (실제 구현 시 이메일/Slack 연동)
    echo "김선우 강사에게 알림 발송 중... (010-8507-7220)"
fi

if (( $(echo "$BUDGET_USAGE > 70" | bc -l) )); then
    echo "⚠️ 주의: 월 예산의 70% 초과"
    echo "새로운 리소스 생성을 자제해주세요."
fi

if (( $(echo "$BUDGET_USAGE > 85" | bc -l) )); then
    echo "🚨 위험: 월 예산의 85% 초과"
    echo "즉시 리소스 정리가 필요합니다."
    
    # 자동 리소스 정리 실행
    echo "자동 정리 스크립트 실행 중..."
    ./cleanup_resources.sh
fi

echo "=== 비용 체크 완료 ==="
```

---

## 🧹 2. 자동 리소스 정리 스크립트

### cleanup_resources.sh
```bash
#!/bin/bash

# 불필요한 리소스 자동 정리 스크립트
# 예산 초과 위험 시 자동 실행

echo "=== 자동 리소스 정리 시작 ==="

# 1. 중지된 EC2 인스턴스 정리 (7일 이상)
echo "1. 중지된 EC2 인스턴스 정리 중..."
CUTOFF_DATE=$(date -d "7 days ago" --iso-8601)

aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=stopped" \
    --query "Reservations[].Instances[?LaunchTime<='$CUTOFF_DATE'].[InstanceId,LaunchTime]" \
    --output table

STOPPED_INSTANCES=$(aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=stopped" \
    --query "Reservations[].Instances[?LaunchTime<='$CUTOFF_DATE'].InstanceId" \
    --output text)

if [ ! -z "$STOPPED_INSTANCES" ]; then
    echo "7일 이상 중지된 인스턴스 종료 중: $STOPPED_INSTANCES"
    aws ec2 terminate-instances --instance-ids $STOPPED_INSTANCES
else
    echo "정리할 중지된 인스턴스가 없습니다."
fi

# 2. 사용하지 않는 EBS 볼륨 정리
echo "2. 미연결 EBS 볼륨 정리 중..."
UNATTACHED_VOLUMES=$(aws ec2 describe-volumes \
    --filters "Name=status,Values=available" \
    --query "Volumes[?CreateTime<='$CUTOFF_DATE'].VolumeId" \
    --output text)

if [ ! -z "$UNATTACHED_VOLUMES" ]; then
    echo "미연결 볼륨 삭제 중: $UNATTACHED_VOLUMES"
    for volume in $UNATTACHED_VOLUMES; do
        aws ec2 delete-volume --volume-id $volume
    done
else
    echo "정리할 미연결 볼륨이 없습니다."
fi

# 3. 오래된 스냅샷 정리 (30일 이상)
echo "3. 오래된 스냅샷 정리 중..."
SNAPSHOT_CUTOFF=$(date -d "30 days ago" --iso-8601)

OLD_SNAPSHOTS=$(aws ec2 describe-snapshots --owner-ids self \
    --query "Snapshots[?StartTime<='$SNAPSHOT_CUTOFF'].SnapshotId" \
    --output text)

if [ ! -z "$OLD_SNAPSHOTS" ]; then
    echo "30일 이상 된 스냅샷 삭제 중: $OLD_SNAPSHOTS"
    for snapshot in $OLD_SNAPSHOTS; do
        aws ec2 delete-snapshot --snapshot-id $snapshot
    done
else
    echo "정리할 오래된 스냅샷이 없습니다."
fi

# 4. 사용하지 않는 Elastic IP 정리
echo "4. 미사용 Elastic IP 정리 중..."
UNUSED_EIPS=$(aws ec2 describe-addresses \
    --query "Addresses[?!InstanceId].AllocationId" \
    --output text)

if [ ! -z "$UNUSED_EIPS" ]; then
    echo "미사용 Elastic IP 해제 중: $UNUSED_EIPS"
    for eip in $UNUSED_EIPS; do
        aws ec2 release-address --allocation-id $eip
    done
else
    echo "정리할 미사용 Elastic IP가 없습니다."
fi

# 5. 빈 S3 버킷 정리 (선택적)
echo "5. 빈 S3 버킷 확인 중..."
aws s3 ls | while read -r line; do
    bucket=$(echo $line | awk '{print $3}')
    if [ ! -z "$bucket" ]; then
        object_count=$(aws s3 ls s3://$bucket --recursive | wc -l)
        if [ $object_count -eq 0 ]; then
            echo "빈 버킷 발견: $bucket (수동 확인 필요)"
        fi
    fi
done

echo "=== 자동 리소스 정리 완료 ==="
```

---

## 🚨 3. 비용 폭탄 방지 스크립트

### cost_bomb_prevention.sh
```bash
#!/bin/bash

# 고비용 리소스 생성 방지 및 모니터링

echo "=== 비용 폭탄 방지 체크 ==="

# 1. 대용량 인스턴스 체크
echo "1. 대용량 인스턴스 체크 중..."
LARGE_INSTANCES=$(aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query "Reservations[].Instances[?InstanceType!='t2.micro' && InstanceType!='t2.small' && InstanceType!='t3.micro' && InstanceType!='t3.small' && InstanceType!='t3.medium'].[InstanceId,InstanceType]" \
    --output table)

if [ ! -z "$LARGE_INSTANCES" ]; then
    echo "🚨 경고: 허용되지 않은 대용량 인스턴스 발견!"
    echo "$LARGE_INSTANCES"
    echo "즉시 강사에게 연락하세요!"
fi

# 2. RDS 인스턴스 체크
echo "2. RDS 인스턴스 체크 중..."
LARGE_RDS=$(aws rds describe-db-instances \
    --query "DBInstances[?DBInstanceClass!='db.t3.micro' && DBInstanceClass!='db.t3.small'].[DBInstanceIdentifier,DBInstanceClass]" \
    --output table)

if [ ! -z "$LARGE_RDS" ]; then
    echo "🚨 경고: 허용되지 않은 RDS 인스턴스 발견!"
    echo "$LARGE_RDS"
fi

# 3. 대용량 EBS 볼륨 체크
echo "3. 대용량 EBS 볼륨 체크 중..."
LARGE_VOLUMES=$(aws ec2 describe-volumes \
    --query "Volumes[?Size>100].[VolumeId,Size,VolumeType]" \
    --output table)

if [ ! -z "$LARGE_VOLUMES" ]; then
    echo "🚨 경고: 100GB 이상 EBS 볼륨 발견!"
    echo "$LARGE_VOLUMES"
fi

# 4. NAT Gateway 체크
echo "4. NAT Gateway 체크 중..."
NAT_GATEWAYS=$(aws ec2 describe-nat-gateways \
    --query "NatGateways[?State=='available'].[NatGatewayId,SubnetId]" \
    --output table)

if [ ! -z "$NAT_GATEWAYS" ]; then
    echo "💰 주의: NAT Gateway 사용 중 (고비용 서비스)"
    echo "$NAT_GATEWAYS"
    echo "꼭 필요한지 검토하세요."
fi

# 5. Load Balancer 체크
echo "5. Load Balancer 체크 중..."
LOAD_BALANCERS=$(aws elbv2 describe-load-balancers \
    --query "LoadBalancers[?State.Code=='active'].[LoadBalancerName,Type]" \
    --output table)

if [ ! -z "$LOAD_BALANCERS" ]; then
    echo "💰 주의: Load Balancer 사용 중"
    echo "$LOAD_BALANCERS"
    echo "강사 승인을 받았는지 확인하세요."
fi

echo "=== 비용 폭탄 방지 체크 완료 ==="
```

---

## 📊 4. 실시간 비용 대시보드 스크립트

### cost_dashboard.sh
```bash
#!/bin/bash

# 실시간 비용 대시보드 (터미널 기반)

PROJECT_TYPE=${1:-basic}

# 프로젝트별 설정
if [ "$PROJECT_TYPE" = "basic" ]; then
    BUDGET=150
    PROJECT_NAME="기본 프로젝트"
else
    BUDGET=225
    PROJECT_NAME="심화 프로젝트"
fi

clear
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    AWS 비용 대시보드                         ║"
echo "║                  $PROJECT_NAME ($BUDGET USD)                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# 현재 시간
echo "📅 업데이트 시간: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 이번 달 비용
MONTH_START=$(date +%Y-%m-01)
TODAY=$(date +%Y-%m-%d)

MONTH_COST=$(aws ce get-cost-and-usage \
    --time-period Start=$MONTH_START,End=$TODAY \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --query 'ResultsByTime[0].Total.BlendedCost.Amount' \
    --output text)

MONTH_COST_ROUNDED=$(printf "%.2f" $MONTH_COST)
USAGE_PERCENT=$(echo "scale=1; $MONTH_COST * 100 / $BUDGET" | bc)
REMAINING=$(echo "scale=2; $BUDGET - $MONTH_COST" | bc)

echo "💰 이번 달 사용 비용: \$$MONTH_COST_ROUNDED / \$$BUDGET"
echo "📊 예산 사용률: $USAGE_PERCENT%"
echo "💵 남은 예산: \$$REMAINING"
echo ""

# 진행률 바 표시
PROGRESS=$(echo "scale=0; $USAGE_PERCENT / 2" | bc)
printf "진행률: ["
for i in $(seq 1 50); do
    if [ $i -le $PROGRESS ]; then
        printf "█"
    else
        printf "░"
    fi
done
printf "] $USAGE_PERCENT%%\n"
echo ""

# 서비스별 비용 (상위 5개)
echo "🏷️  서비스별 비용 (상위 5개):"
aws ce get-cost-and-usage \
    --time-period Start=$MONTH_START,End=$TODAY \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --group-by Type=DIMENSION,Key=SERVICE \
    --query 'ResultsByTime[0].Groups[:5].[Keys[0],Metrics.BlendedCost.Amount]' \
    --output table

echo ""

# 경고 메시지
if (( $(echo "$USAGE_PERCENT > 85" | bc -l) )); then
    echo "🚨 위험: 예산의 85% 초과! 즉시 리소스 점검 필요"
elif (( $(echo "$USAGE_PERCENT > 70" | bc -l) )); then
    echo "⚠️  주의: 예산의 70% 초과! 신규 리소스 생성 자제"
elif (( $(echo "$USAGE_PERCENT > 50" | bc -l) )); then
    echo "📈 정보: 예산의 50% 사용 중"
else
    echo "✅ 양호: 예산 내 정상 사용 중"
fi

echo ""
echo "📞 문의: 예산 초과 위험 시 김선우 강사에게 연락 (010-8507-7220)"
echo "🔄 새로고침: 5분마다 자동 업데이트 권장"
```

---

## ⚙️ 5. 설치 및 설정 스크립트

### setup_cost_monitoring.sh
```bash
#!/bin/bash

# 비용 모니터링 시스템 설치 및 설정

echo "=== AWS 비용 모니터링 시스템 설치 ==="

# 1. 필요한 도구 설치 확인
echo "1. 필요한 도구 확인 중..."

if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI가 설치되지 않았습니다."
    echo "설치 방법: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html"
    exit 1
fi

if ! command -v bc &> /dev/null; then
    echo "bc 계산기 설치 중..."
    # Ubuntu/Debian
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y bc
    # CentOS/RHEL
    elif command -v yum &> /dev/null; then
        sudo yum install -y bc
    # macOS
    elif command -v brew &> /dev/null; then
        brew install bc
    fi
fi

# 2. 스크립트 실행 권한 설정
echo "2. 스크립트 실행 권한 설정 중..."
chmod +x daily_cost_check.sh
chmod +x cleanup_resources.sh
chmod +x cost_bomb_prevention.sh
chmod +x cost_dashboard.sh

# 3. cron 작업 설정 (일일 체크)
echo "3. 자동 실행 스케줄 설정 중..."
SCRIPT_DIR=$(pwd)

# 기존 cron 작업 제거
crontab -l | grep -v "daily_cost_check.sh" | crontab -

# 새로운 cron 작업 추가 (매일 오전 9시)
(crontab -l 2>/dev/null; echo "0 9 * * * $SCRIPT_DIR/daily_cost_check.sh basic >> $SCRIPT_DIR/cost_check.log 2>&1") | crontab -

echo "✅ 설치 완료!"
echo ""
echo "📋 사용 방법:"
echo "  - 일일 체크: ./daily_cost_check.sh [basic|advanced]"
echo "  - 대시보드: ./cost_dashboard.sh [basic|advanced]"
echo "  - 리소스 정리: ./cleanup_resources.sh"
echo "  - 비용 폭탄 방지: ./cost_bomb_prevention.sh"
echo ""
echo "🔄 자동 실행: 매일 오전 9시에 자동으로 비용 체크"
echo "📄 로그 파일: cost_check.log"
```

---

## 📋 사용 가이드

### 🚀 빠른 시작
```bash
# 1. 스크립트 다운로드 및 설정
chmod +x *.sh
./setup_cost_monitoring.sh

# 2. 프로젝트 타입에 맞는 일일 체크
./daily_cost_check.sh basic      # 기본 프로젝트
./daily_cost_check.sh advanced   # 심화 프로젝트

# 3. 실시간 대시보드 확인
./cost_dashboard.sh basic
```

### 📊 정기 점검 루틴
- **매일 오전**: 자동 비용 체크 (cron)
- **매주 월요일**: 수동 대시보드 확인
- **예산 70% 도달**: 리소스 사용 검토
- **예산 85% 도달**: 자동 정리 실행

### 🆘 비상 상황 대응
1. **예산 95% 초과**: 모든 리소스 즉시 중지
2. **강사 연락**: 상황 보고 및 조치 방안 논의
3. **원인 분석**: 비용 급증 원인 파악
4. **재발 방지**: 정책 강화 및 모니터링 개선

---

<div align="center">

**💰 예산 준수** • **🔍 실시간 모니터링** • **🚨 자동 알림** • **🛡️ 비용 폭탄 방지**

*안전하고 경제적인 AWS 프로젝트 운영을 위한 완벽한 도구*

</div>