@echo off
chcp 65001 >nul
echo ========================================
echo KT Cloud TECH UP 2025 - LMS Builder
echo ========================================
echo.

REM Python check
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python not installed.
    echo Please install Python 3.7+
    pause
    exit /b 1
)

REM Mermaid CLI check
where mmdc >nul 2>nul
if %errorlevel% neq 0 (
    echo WARNING: Mermaid CLI not installed.
    echo Install with: npm install -g @mermaid-js/mermaid-cli
    echo.
    echo Continue? (Y/N)
    set /p continue=
    if /i not "%continue%"=="Y" (
        exit /b 1
    )
)

echo Starting LMS build...
echo.

REM Run build script
python "%~dp0build_lms_integrated.py"

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo Build Complete!
    echo ========================================
    echo.
    echo Output: lms/
    echo Images: theory/week_XX/images/
    echo.
) else (
    echo.
    echo ========================================
    echo Build Failed!
    echo ========================================
    echo.
)

pause