# eksctl 최신 버전 업데이트 스크립트 (Windows PowerShell)

Write-Host "🔄 eksctl 업데이트 시작..." -ForegroundColor Green

# 현재 버전 확인
Write-Host "📋 현재 eksctl 버전:" -ForegroundColor Yellow
eksctl version

# Chocolatey로 업데이트 시도
Write-Host "🍫 Chocolatey로 업데이트 시도..." -ForegroundColor Cyan
try {
    choco upgrade eksctl -y
    Write-Host "✅ Chocolatey 업데이트 완료!" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Chocolatey 업데이트 실패, 수동 설치로 진행..." -ForegroundColor Yellow
    
    # 수동 다운로드 및 설치
    Write-Host "📥 최신 eksctl 다운로드 중..." -ForegroundColor Cyan
    
    # 임시 디렉토리 생성
    $tempDir = "$env:TEMP\eksctl-update"
    New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
    
    # 최신 버전 다운로드
    $downloadUrl = "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Windows_amd64.zip"
    $zipFile = "$tempDir\eksctl.zip"
    
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile
    
    # 압축 해제
    Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force
    
    # 기존 eksctl 백업 (있다면)
    $eksctlPath = (Get-Command eksctl -ErrorAction SilentlyContinue).Source
    if ($eksctlPath) {
        Copy-Item $eksctlPath "$eksctlPath.backup" -Force
        Write-Host "💾 기존 eksctl 백업 완료: $eksctlPath.backup" -ForegroundColor Blue
    }
    
    # 새 버전 설치
    $newEksctl = "$tempDir\eksctl.exe"
    $installPath = "C:\Program Files\eksctl\eksctl.exe"
    
    # 설치 디렉토리 생성
    $installDir = Split-Path $installPath
    New-Item -ItemType Directory -Force -Path $installDir | Out-Null
    
    # 파일 복사
    Copy-Item $newEksctl $installPath -Force
    
    # PATH에 추가 (필요한 경우)
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    if ($currentPath -notlike "*$installDir*") {
        [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$installDir", "Machine")
        Write-Host "🔧 PATH에 eksctl 경로 추가됨" -ForegroundColor Blue
    }
    
    # 임시 파일 정리
    Remove-Item $tempDir -Recurse -Force
    
    Write-Host "✅ 수동 설치 완료!" -ForegroundColor Green
}

# 업데이트된 버전 확인
Write-Host "`n📋 업데이트된 eksctl 버전:" -ForegroundColor Yellow
eksctl version

Write-Host "`n🎉 eksctl 업데이트 완료! 새 PowerShell 세션을 시작하세요." -ForegroundColor Green
