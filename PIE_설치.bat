@echo off
chcp 65001 > nul 2>&1
setlocal EnableDelayedExpansion

:: PIE 설치 프로그램 — PowerShell GUI 방식
:: 이 파일과 PIE.html 이 같은 폴더에 있어야 합니다.

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "& { ^
    Add-Type -AssemblyName System.Windows.Forms; ^
    Add-Type -AssemblyName System.Drawing; ^
    ^
    $srcHtml = Join-Path '%SCRIPT_DIR%' 'PIE.html'; ^
    if (-not (Test-Path $srcHtml)) { ^
      [System.Windows.Forms.MessageBox]::Show('PIE.html 파일을 찾을 수 없습니다.' + [char]10 + '이 설치 파일과 PIE.html이 같은 폴더에 있어야 합니다.','PIE 설치 오류',[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null; ^
      exit 1; ^
    } ^
    ^
    $form = New-Object System.Windows.Forms.Form; ^
    $form.Text = 'PIE 설치 프로그램'; ^
    $form.Size = New-Object System.Drawing.Size(520,420); ^
    $form.StartPosition = 'CenterScreen'; ^
    $form.BackColor = [System.Drawing.Color]::FromArgb(15,23,42); ^
    $form.FormBorderStyle = 'FixedDialog'; ^
    $form.MaximizeBox = $false; ^
    $form.MinimizeBox = $false; ^
    ^
    $banner = New-Object System.Windows.Forms.Label; ^
    $banner.Text = 'PIE'; ^
    $banner.Font = New-Object System.Drawing.Font('Segoe UI',32,[System.Drawing.FontStyle]::Bold); ^
    $banner.ForeColor = [System.Drawing.Color]::FromArgb(59,130,246); ^
    $banner.Location = New-Object System.Drawing.Point(30,24); ^
    $banner.AutoSize = $true; ^
    $form.Controls.Add($banner); ^
    ^
    $sub = New-Object System.Windows.Forms.Label; ^
    $sub.Text = 'Powernet Industrial Engineering'; ^
    $sub.Font = New-Object System.Drawing.Font('Segoe UI',10); ^
    $sub.ForeColor = [System.Drawing.Color]::FromArgb(100,116,139); ^
    $sub.Location = New-Object System.Drawing.Point(32,78); ^
    $sub.AutoSize = $true; ^
    $form.Controls.Add($sub); ^
    ^
    $sep = New-Object System.Windows.Forms.Label; ^
    $sep.BorderStyle = 'Fixed3D'; ^
    $sep.Location = New-Object System.Drawing.Point(30,108); ^
    $sep.Size = New-Object System.Drawing.Size(445,2); ^
    $sep.BackColor = [System.Drawing.Color]::FromArgb(51,65,85); ^
    $form.Controls.Add($sep); ^
    ^
    $lbDir = New-Object System.Windows.Forms.Label; ^
    $lbDir.Text = '설치 위치'; ^
    $lbDir.Font = New-Object System.Drawing.Font('Segoe UI',9,[System.Drawing.FontStyle]::Bold); ^
    $lbDir.ForeColor = [System.Drawing.Color]::FromArgb(148,163,184); ^
    $lbDir.Location = New-Object System.Drawing.Point(30,124); ^
    $lbDir.AutoSize = $true; ^
    $form.Controls.Add($lbDir); ^
    ^
    $defaultDir = Join-Path $env:LOCALAPPDATA 'PIE_WorkAnalysis'; ^
    $tbDir = New-Object System.Windows.Forms.TextBox; ^
    $tbDir.Text = $defaultDir; ^
    $tbDir.Font = New-Object System.Drawing.Font('Consolas',9); ^
    $tbDir.BackColor = [System.Drawing.Color]::FromArgb(30,41,59); ^
    $tbDir.ForeColor = [System.Drawing.Color]::FromArgb(226,232,240); ^
    $tbDir.BorderStyle = 'FixedSingle'; ^
    $tbDir.Location = New-Object System.Drawing.Point(30,148); ^
    $tbDir.Size = New-Object System.Drawing.Size(360,24); ^
    $form.Controls.Add($tbDir); ^
    ^
    $btnBrowse = New-Object System.Windows.Forms.Button; ^
    $btnBrowse.Text = '찾아보기'; ^
    $btnBrowse.Font = New-Object System.Drawing.Font('Segoe UI',9); ^
    $btnBrowse.BackColor = [System.Drawing.Color]::FromArgb(30,41,59); ^
    $btnBrowse.ForeColor = [System.Drawing.Color]::FromArgb(148,163,184); ^
    $btnBrowse.FlatStyle = 'Flat'; ^
    $btnBrowse.Location = New-Object System.Drawing.Point(400,147); ^
    $btnBrowse.Size = New-Object System.Drawing.Size(76,26); ^
    $btnBrowse.Add_Click({ ^
      $fbd = New-Object System.Windows.Forms.FolderBrowserDialog; ^
      $fbd.Description = '설치 폴더를 선택하세요'; ^
      $fbd.SelectedPath = $tbDir.Text; ^
      if ($fbd.ShowDialog() -eq 'OK') { $tbDir.Text = $fbd.SelectedPath + '\PIE_WorkAnalysis' } ^
    }); ^
    $form.Controls.Add($btnBrowse); ^
    ^
    $lbShort = New-Object System.Windows.Forms.Label; ^
    $lbShort.Text = '바로가기 생성'; ^
    $lbShort.Font = New-Object System.Drawing.Font('Segoe UI',9,[System.Drawing.FontStyle]::Bold); ^
    $lbShort.ForeColor = [System.Drawing.Color]::FromArgb(148,163,184); ^
    $lbShort.Location = New-Object System.Drawing.Point(30,190); ^
    $lbShort.AutoSize = $true; ^
    $form.Controls.Add($lbShort); ^
    ^
    $cbDesktop = New-Object System.Windows.Forms.CheckBox; ^
    $cbDesktop.Text = '바탕화면'; ^
    $cbDesktop.Checked = $true; ^
    $cbDesktop.Font = New-Object System.Drawing.Font('Segoe UI',9); ^
    $cbDesktop.ForeColor = [System.Drawing.Color]::FromArgb(226,232,240); ^
    $cbDesktop.BackColor = [System.Drawing.Color]::Transparent; ^
    $cbDesktop.Location = New-Object System.Drawing.Point(30,214); ^
    $cbDesktop.AutoSize = $true; ^
    $form.Controls.Add($cbDesktop); ^
    ^
    $cbStart = New-Object System.Windows.Forms.CheckBox; ^
    $cbStart.Text = '시작 메뉴'; ^
    $cbStart.Checked = $true; ^
    $cbStart.Font = New-Object System.Drawing.Font('Segoe UI',9); ^
    $cbStart.ForeColor = [System.Drawing.Color]::FromArgb(226,232,240); ^
    $cbStart.BackColor = [System.Drawing.Color]::Transparent; ^
    $cbStart.Location = New-Object System.Drawing.Point(140,214); ^
    $cbStart.AutoSize = $true; ^
    $form.Controls.Add($cbStart); ^
    ^
    $lbInfo = New-Object System.Windows.Forms.Label; ^
    $lbInfo.Text = 'PIE는 단일 HTML 파일로 동작합니다. 설치 후 인터넷 없이도 사용 가능하며,' + [char]10 + 'Google Sheets 연동 · AI 비전 분析은 인터넷 연결 시 자동 활성화됩니다.'; ^
    $lbInfo.Font = New-Object System.Drawing.Font('Segoe UI',8.5); ^
    $lbInfo.ForeColor = [System.Drawing.Color]::FromArgb(71,85,105); ^
    $lbInfo.Location = New-Object System.Drawing.Point(30,250); ^
    $lbInfo.Size = New-Object System.Drawing.Size(445,40); ^
    $form.Controls.Add($lbInfo); ^
    ^
    $progress = New-Object System.Windows.Forms.ProgressBar; ^
    $progress.Minimum = 0; ^
    $progress.Maximum = 100; ^
    $progress.Value = 0; ^
    $progress.Style = 'Continuous'; ^
    $progress.Location = New-Object System.Drawing.Point(30,302); ^
    $progress.Size = New-Object System.Drawing.Size(445,18); ^
    $progress.BackColor = [System.Drawing.Color]::FromArgb(30,41,59); ^
    $form.Controls.Add($progress); ^
    ^
    $lbStatus = New-Object System.Windows.Forms.Label; ^
    $lbStatus.Text = '설치 준비 완료'; ^
    $lbStatus.Font = New-Object System.Drawing.Font('Segoe UI',8.5); ^
    $lbStatus.ForeColor = [System.Drawing.Color]::FromArgb(100,116,139); ^
    $lbStatus.Location = New-Object System.Drawing.Point(30,325); ^
    $lbStatus.Size = New-Object System.Drawing.Size(445,18); ^
    $form.Controls.Add($lbStatus); ^
    ^
    $btnCancel = New-Object System.Windows.Forms.Button; ^
    $btnCancel.Text = '취소'; ^
    $btnCancel.Font = New-Object System.Drawing.Font('Segoe UI',9); ^
    $btnCancel.BackColor = [System.Drawing.Color]::FromArgb(30,41,59); ^
    $btnCancel.ForeColor = [System.Drawing.Color]::FromArgb(148,163,184); ^
    $btnCancel.FlatStyle = 'Flat'; ^
    $btnCancel.Location = New-Object System.Drawing.Point(280,356); ^
    $btnCancel.Size = New-Object System.Drawing.Size(90,32); ^
    $btnCancel.DialogResult = 'Cancel'; ^
    $form.Controls.Add($btnCancel); ^
    ^
    $btnInstall = New-Object System.Windows.Forms.Button; ^
    $btnInstall.Text = '설치 시작'; ^
    $btnInstall.Font = New-Object System.Drawing.Font('Segoe UI',9,[System.Drawing.FontStyle]::Bold); ^
    $btnInstall.BackColor = [System.Drawing.Color]::FromArgb(29,78,216); ^
    $btnInstall.ForeColor = [System.Drawing.Color]::White; ^
    $btnInstall.FlatStyle = 'Flat'; ^
    $btnInstall.Location = New-Object System.Drawing.Point(384,356); ^
    $btnInstall.Size = New-Object System.Drawing.Size(90,32); ^
    $form.Controls.Add($btnInstall); ^
    ^
    $btnInstall.Add_Click({ ^
      $installDir = $tbDir.Text.Trim(); ^
      if (-not $installDir) { ^
        [System.Windows.Forms.MessageBox]::Show('설치 경로를 입력하세요.','오류',[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Warning) | Out-Null; ^
        return; ^
      } ^
      $btnInstall.Enabled = $false; ^
      $btnCancel.Enabled = $false; ^
      $tbDir.Enabled = $false; ^
      $btnBrowse.Enabled = $false; ^
      try { ^
        $lbStatus.Text = '[1/5] 설치 폴더 생성 중...'; ^
        $progress.Value = 10; ^
        $form.Refresh(); ^
        if (-not (Test-Path $installDir)) { New-Item -ItemType Directory -Force -Path $installDir | Out-Null } ^
        ^
        $lbStatus.Text = '[2/5] PIE.html 복사 중...'; ^
        $progress.Value = 30; ^
        $form.Refresh(); ^
        Copy-Item -Path $srcHtml -Destination (Join-Path $installDir 'PIE.html') -Force; ^
        ^
        $lbStatus.Text = '[3/5] 제거 프로그램 복사 중...'; ^
        $progress.Value = 50; ^
        $form.Refresh(); ^
        $uninstSrc = Join-Path '%SCRIPT_DIR%' 'PIE_제거.bat'; ^
        if (Test-Path $uninstSrc) { Copy-Item -Path $uninstSrc -Destination (Join-Path $installDir 'PIE_제거.bat') -Force } ^
        ^
        $ws = New-Object -ComObject WScript.Shell; ^
        $targetHtml = Join-Path $installDir 'PIE.html'; ^
        ^
        if ($cbDesktop.Checked) { ^
          $lbStatus.Text = '[4/5] 바탕화면 바로가기 생성 중...'; ^
          $progress.Value = 70; ^
          $form.Refresh(); ^
          $s = $ws.CreateShortcut([System.IO.Path]::Combine([Environment]::GetFolderPath('Desktop'),'PIE 작업分析.lnk')); ^
          $s.TargetPath = $targetHtml; ^
          $s.Description = 'PIE - Powernet Industrial Engineering'; ^
          $s.Save(); ^
        } ^
        ^
        if ($cbStart.Checked) { ^
          $lbStatus.Text = '[5/5] 시작 메뉴 바로가기 생성 중...'; ^
          $progress.Value = 88; ^
          $form.Refresh(); ^
          $smDir = Join-Path ([Environment]::GetFolderPath('Programs')) 'PIE'; ^
          if (-not (Test-Path $smDir)) { New-Item -ItemType Directory -Force -Path $smDir | Out-Null } ^
          $s2 = $ws.CreateShortcut(Join-Path $smDir 'PIE 작업分析.lnk'); ^
          $s2.TargetPath = $targetHtml; ^
          $s2.Description = 'PIE - Powernet Industrial Engineering'; ^
          $s2.Save(); ^
          $s3 = $ws.CreateShortcut(Join-Path $smDir 'PIE 제거.lnk'); ^
          $s3.TargetPath = Join-Path $installDir 'PIE_제거.bat'; ^
          $s3.Description = 'PIE 제거'; ^
          $s3.Save(); ^
        } ^
        ^
        $regPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\PIE_WorkAnalysis'; ^
        New-Item -Path $regPath -Force | Out-Null; ^
        Set-ItemProperty -Path $regPath -Name 'DisplayName' -Value 'PIE - Powernet Industrial Engineering'; ^
        Set-ItemProperty -Path $regPath -Name 'DisplayVersion' -Value '1.0'; ^
        Set-ItemProperty -Path $regPath -Name 'Publisher' -Value 'Powernet'; ^
        Set-ItemProperty -Path $regPath -Name 'InstallLocation' -Value $installDir; ^
        Set-ItemProperty -Path $regPath -Name 'UninstallString' -Value (Join-Path $installDir 'PIE_제거.bat'); ^
        Set-ItemProperty -Path $regPath -Name 'NoModify' -Value 1; ^
        Set-ItemProperty -Path $regPath -Name 'NoRepair' -Value 1; ^
        ^
        $progress.Value = 100; ^
        $lbStatus.ForeColor = [System.Drawing.Color]::FromArgb(74,222,128); ^
        $lbStatus.Text = '설치 완료!'; ^
        $form.Refresh(); ^
        Start-Sleep -Milliseconds 500; ^
        ^
        $msg = 'PIE 설치가 완료되었습니다!' + [char]10 + [char]10 + '설치 경로: ' + $installDir + [char]10 + [char]10 + '바탕화면의 [PIE 작업分析] 아이콘을 클릭해 시작하세요.'; ^
        [System.Windows.Forms.MessageBox]::Show($msg,'설치 완료',[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null; ^
        $form.Close(); ^
      } catch { ^
        $lbStatus.ForeColor = [System.Drawing.Color]::FromArgb(248,113,113); ^
        $lbStatus.Text = '오류: ' + $_.Exception.Message; ^
        $btnInstall.Enabled = $true; ^
        $btnCancel.Enabled = $true; ^
        $tbDir.Enabled = $true; ^
        $btnBrowse.Enabled = $true; ^
      } ^
    }); ^
    ^
    $form.AcceptButton = $btnInstall; ^
    $form.CancelButton = $btnCancel; ^
    [void]$form.ShowDialog(); ^
  }"

endlocal
