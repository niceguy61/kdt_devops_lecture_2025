@echo off
REM 누락된 Mermaid 이미지 생성 배치 스크립트

echo === Mermaid 이미지 생성 도구 ===
echo.

REM Mermaid CLI 설치 확인
echo 1. Mermaid CLI 설치 확인 중...
where mmdc >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Mermaid CLI가 설치되지 않았습니다.
    echo.
    echo 설치 방법:
    echo npm install -g @mermaid-js/mermaid-cli
    echo.
    echo 설치 후 다시 실행해주세요.
    pause
    exit /b 1
)

echo ✅ Mermaid CLI 설치 확인됨
echo.

REM Python 스크립트 실행
echo 2. 누락된 이미지 파일 생성 중...
python scripts\generate_missing_images.py

echo.
echo === 작업 완료 ===
echo.
echo 생성된 이미지는 다음 위치에서 확인하세요:
echo - theory\week_01\images\
echo - theory\week_02\images\
echo - theory\week_03\images\
echo - theory\week_04\images\
echo - theory\week_05\images\
echo - theory\week_06\images\
echo.

pause