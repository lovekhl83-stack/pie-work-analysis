@echo off
chcp 65001 >nul 2>&1
title PIE - Powernet Industrial Engineering

if not exist "%~dp0PIE.html" (
    echo.
    echo  [오류] PIE.html 파일을 찾을 수 없습니다.
    echo  PIE_시작.bat와 PIE.html이 같은 폴더에 있어야 합니다.
    echo.
    pause
    exit /b 1
)

echo.
echo  PIE 작업분석 프로그램을 실행합니다...
echo.

start "" "%~dp0PIE.html"

exit
