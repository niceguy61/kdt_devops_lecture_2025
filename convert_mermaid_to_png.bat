@echo off
echo Mermaid 차트를 PNG로 변환 중...

REM Mermaid CLI 설치 확인
where mmdc >nul 2>nul
if %errorlevel% neq 0 (
    echo Mermaid CLI가 설치되지 않았습니다.
    echo 다음 명령어로 설치하세요: npm install -g @mermaid-js/mermaid-cli
    pause
    exit /b 1
)

REM 각 week별 images 폴더의 .mmd 파일을 PNG로 변환
for /d %%d in (theory\week_*) do (
    if exist "%%d\images\*.mmd" (
        echo 변환 중: %%d\images\
        for %%f in (%%d\images\*.mmd) do (
            mmdc -i "%%f" -o "%%~dpnf.png" -t neutral -b white
        )
    )
)

REM 루트 images 폴더 처리
if exist "images\*.mmd" (
    echo 변환 중: images\
    for %%f in (images\*.mmd) do (
        mmdc -i "%%f" -o "%%~dpnf.png" -t neutral -b white
    )
)

echo 변환 완료!
pause
