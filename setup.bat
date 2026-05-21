@echo off
echo.
echo  ============================================
echo   PIE - Powernet Industrial Engineering
echo   Work Analysis System Setup
echo  ============================================
echo.

:: Check source file
if not exist "%~dp0PIE.html" (
    echo  [ERROR] PIE.html not found in same folder as setup.bat
    pause
    exit /b 1
)

:: Create install folder and copy file
set "APP=%LOCALAPPDATA%\PIE"
if not exist "%APP%" mkdir "%APP%"
copy /Y "%~dp0PIE.html" "%APP%\PIE.html" >nul
if errorlevel 1 (
    echo  [ERROR] File copy failed.
    pause
    exit /b 1
)
echo  [1/2] Installed: %APP%\PIE.html

:: Get real Desktop path via PowerShell (handles OneDrive + Korean Windows)
for /f "usebackq delims=" %%a in (`powershell -noprofile -c "[Environment]::GetFolderPath(47)"`) do set "DESK=%%a"
if "%DESK%"=="" set "DESK=%USERPROFILE%\Desktop"

:: Create desktop shortcut via VBScript
set "VBS=%TEMP%\pie_lnk.vbs"
(
echo Set ws = CreateObject("WScript.Shell"^)
echo Set lnk = ws.CreateShortcut("%DESK%\PIE.lnk"^)
echo lnk.TargetPath = "%APP%\PIE.html"
echo lnk.Description = "PIE - Powernet Industrial Engineering"
echo lnk.Save
) > "%VBS%"
cscript //nologo "%VBS%"
del "%VBS%" >nul 2>&1
echo  [2/2] Desktop shortcut created: %DESK%\PIE.lnk

echo.
echo  Setup complete!
echo  Open PIE from the shortcut on your Desktop.
echo  A license key is required on first launch.
echo  Contact: lovekhl83@gmail.com
echo.
pause