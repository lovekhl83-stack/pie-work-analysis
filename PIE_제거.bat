@echo off
chcp 65001 > nul 2>&1
setlocal EnableDelayedExpansion

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "& { ^
    Add-Type -AssemblyName System.Windows.Forms; ^
    Add-Type -AssemblyName System.Drawing; ^
    ^
    $regPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\PIE_WorkAnalysis'; ^
    $installDir = $null; ^
    if (Test-Path $regPath) { ^
      $installDir = (Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue).InstallLocation; ^
    } ^
    if (-not $installDir) { ^
      $installDir = Join-Path $env:LOCALAPPDATA 'PIE_WorkAnalysis'; ^
    } ^
    ^
    $result = [System.Windows.Forms.MessageBox]::Show( ^
      'PIE를 제거하시겠습니까?' + [char]10 + [char]10 + '제거 항목:' + [char]10 + '  - 설치 폴더: ' + $installDir + [char]10 + '  - 바탕화면 바로가기' + [char]10 + '  - 시작 메뉴 바로가기' + [char]10 + '  - 프로그램 등록 정보' + [char]10 + [char]10 + '(사용자 데이터는 삭제되지 않습니다)', ^
      'PIE 제거', ^
      [System.Windows.Forms.MessageBoxButtons]::YesNo, ^
      [System.Windows.Forms.MessageBoxIcon]::Warning ^
    ); ^
    ^
    if ($result -ne 'Yes') { exit 0 } ^
    ^
    $ws = New-Object -ComObject WScript.Shell; ^
    ^
    $desktopLnk = Join-Path ([Environment]::GetFolderPath('Desktop')) 'PIE 작업分析.lnk'; ^
    if (Test-Path $desktopLnk) { Remove-Item -Path $desktopLnk -Force -ErrorAction SilentlyContinue } ^
    ^
    $smDir = Join-Path ([Environment]::GetFolderPath('Programs')) 'PIE'; ^
    if (Test-Path $smDir) { Remove-Item -Path $smDir -Recurse -Force -ErrorAction SilentlyContinue } ^
    ^
    if (Test-Path $regPath) { Remove-Item -Path $regPath -Recurse -Force -ErrorAction SilentlyContinue } ^
    ^
    if (Test-Path $installDir) { ^
      Remove-Item -Path $installDir -Recurse -Force -ErrorAction SilentlyContinue; ^
    } ^
    ^
    [System.Windows.Forms.MessageBox]::Show( ^
      'PIE가 성공적으로 제거되었습니다.' + [char]10 + [char]10 + '사용해 주셔서 감사합니다.', ^
      '제거 완료', ^
      [System.Windows.Forms.MessageBoxButtons]::OK, ^
      [System.Windows.Forms.MessageBoxIcon]::Information ^
    ) | Out-Null; ^
  }"

endlocal
