# EKS 실습 환경 체크 스크립트 (PowerShell)
# 사용법: .\check-environment.ps1

Write-Host "🔍 EKS 실습 환경 체크를 시작합니다..." -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 체크 결과 저장
$script:Errors = 0
$script:Warnings = 0

# 함수 정의
function Test-Command {
    param([string]$CommandName)
    
    try {
        Get-Command $CommandName -ErrorAction Stop | Out-Null
        Write-Host "✓ $CommandName 설치됨" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "✗ $CommandName 설치되지 않음" -ForegroundColor Red
        return $false
    }
}

function Test-AwsPermission {
    param(
        [string]$ServiceName,
        [string]$Command
    )
    
    try {
        Invoke-Expression $Command 2>$null | Out-Null
        Write-Host "✓ $ServiceName 권한 확인됨" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "✗ $ServiceName 권한 없음" -ForegroundColor Red
        return $false
    }
}

Write-Host "`n1. 필수 도구 설치 확인" -ForegroundColor Yellow
Write-Host "------------------------"

# AWS CLI 확인
if (Test-Command "aws") {
    try {
        $awsVersion = (aws --version 2>&1) -split "/" | Select-Object -Index 1 | ForEach-Object { $_.Split(" ")[0] }
        Write-Host "   버전: $awsVersion"
        
        if ($awsVersion.StartsWith("2.")) {
            Write-Host "   ✓ AWS CLI v2 사용 중" -ForegroundColor Green
        }
        else {
            Write-Host "   ⚠ AWS CLI v1 감지됨. v2 권장" -ForegroundColor Yellow
            $script:Warnings++
        }
    }
    catch {
        Write-Host "   버전 확인 실패" -ForegroundColor Yellow
        $script:Warnings++
    }
}
else {
    Write-Host "   설치 방법: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    $script:Errors++
}

# eksctl 확인
if (Test-Command "eksctl") {
    try {
        $eksctlVersion = eksctl version 2>&1
        Write-Host "   버전: $eksctlVersion"
    }
    catch {
        Write-Host "   버전 확인 실패" -ForegroundColor Yellow
    }
}
else {
    Write-Host "   설치 방법: https://eksctl.io/installation/"
    $script:Errors++
}

# kubectl 확인
if (Test-Command "kubectl") {
    try {
        $kubectlVersion = kubectl version --client --short 2>&1 | Where-Object { $_ -notmatch "WARNING" }
        Write-Host "   버전: $kubectlVersion"
    }
    catch {
        Write-Host "   버전 확인 실패" -ForegroundColor Yellow
    }
}
else {
    Write-Host "   설치 방법: https://kubernetes.io/docs/tasks/tools/"
    $script:Errors++
}

Write-Host "`n2. AWS 자격 증명 확인" -ForegroundColor Yellow
Write-Host "----------------------"

# AWS 자격 증명 확인
try {
    $callerIdentity = aws sts get-caller-identity 2>$null | ConvertFrom-Json
    Write-Host "✓ AWS 자격 증명 설정됨" -ForegroundColor Green
    
    Write-Host "   계정 ID: $($callerIdentity.Account)"
    Write-Host "   사용자: $($callerIdentity.Arn)"
    
    try {
        $region = aws configure get region 2>$null
        if ($region) {
            Write-Host "   기본 리전: $region"
            if ($region -ne "ap-northeast-2") {
                Write-Host "   ⚠ 실습용 리전(ap-northeast-2)과 다름" -ForegroundColor Yellow
                $script:Warnings++
            }
        }
        else {
            Write-Host "   기본 리전: 설정되지 않음"
            Write-Host "   ⚠ 기본 리전이 설정되지 않음. ap-northeast-2 권장" -ForegroundColor Yellow
            $script:Warnings++
        }
    }
    catch {
        Write-Host "   기본 리전: 확인 실패" -ForegroundColor Yellow
        $script:Warnings++
    }
}
catch {
    Write-Host "✗ AWS 자격 증명 설정되지 않음" -ForegroundColor Red
    Write-Host "   해결 방법: aws configure 명령어 실행"
    $script:Errors++
}

Write-Host "`n3. AWS 권한 확인" -ForegroundColor Yellow
Write-Host "----------------"

# EKS 권한 확인
if (-not (Test-AwsPermission "EKS" "aws eks list-clusters --region ap-northeast-2")) {
    Write-Host "   필요 권한: eks:ListClusters"
    $script:Errors++
}

# EC2 권한 확인
if (-not (Test-AwsPermission "EC2" "aws ec2 describe-vpcs --region ap-northeast-2 --max-items 1")) {
    Write-Host "   필요 권한: ec2:DescribeVpcs"
    $script:Errors++
}

# IAM 권한 확인
if (-not (Test-AwsPermission "IAM" "aws iam list-roles --max-items 1")) {
    Write-Host "   필요 권한: iam:ListRoles"
    $script:Errors++
}

# CloudFormation 권한 확인
if (-not (Test-AwsPermission "CloudFormation" "aws cloudformation list-stacks --region ap-northeast-2 --max-items 1")) {
    Write-Host "   필요 권한: cloudformation:ListStacks"
    $script:Errors++
}

Write-Host "`n4. 네트워크 연결 확인" -ForegroundColor Yellow
Write-Host "--------------------"

# AWS API 연결 테스트
try {
    $response = Invoke-WebRequest -Uri "https://eks.ap-northeast-2.amazonaws.com" -Method Head -TimeoutSec 10 -ErrorAction Stop
    Write-Host "✓ AWS EKS API 연결 가능" -ForegroundColor Green
}
catch {
    Write-Host "✗ AWS EKS API 연결 실패" -ForegroundColor Red
    Write-Host "   방화벽 또는 프록시 설정 확인 필요"
    $script:Errors++
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "🏁 환경 체크 완료" -ForegroundColor Cyan

if ($script:Errors -eq 0 -and $script:Warnings -eq 0) {
    Write-Host "✅ 모든 요구사항이 충족되었습니다!" -ForegroundColor Green
    Write-Host "EKS 실습을 시작할 수 있습니다."
    exit 0
}
elseif ($script:Errors -eq 0) {
    Write-Host "⚠️  경고 $($script:Warnings)개가 있지만 실습 진행 가능합니다." -ForegroundColor Yellow
    Write-Host "가능하면 경고 사항을 해결한 후 진행하세요."
    exit 0
}
else {
    Write-Host "❌ 오류 $($script:Errors)개, 경고 $($script:Warnings)개가 발견되었습니다." -ForegroundColor Red
    Write-Host ""
    Write-Host "다음 문서를 참조하여 문제를 해결해주세요:"
    Write-Host "📖 requirements.md - 상세한 설정 가이드"
    Write-Host ""
    Write-Host "주요 해결 방법:"
    Write-Host "• 도구 미설치: requirements.md의 '필수 도구 설치' 섹션 참조"
    Write-Host "• 자격 증명 오류: aws configure 명령어로 설정"
    Write-Host "• 권한 오류: AWS 관리자에게 EKS 관련 권한 요청"
    exit 1
}