<#
  FixlagByEpicPC.ps1 - Full standalone version
  - Chay menu chinh ngay khi mo
  - Khong hoi key/HWID/Internet
  - Tu dong yeu cau Administrator
#>

$ErrorActionPreference = 'Continue'

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    return ([Security.Principal.WindowsPrincipal]$id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    try {
        Start-Process -FilePath "powershell.exe" -Verb RunAs -ArgumentList @(
            "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$PSCommandPath`""
        ) | Out-Null
    } catch {
        Write-Host "Khong the yeu cau quyen Administrator." -ForegroundColor Yellow
        Read-Host "Nhan Enter de thoat" | Out-Null
    }
    exit
}

try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false } catch { }
try { $null = & "$env:ComSpec" /c "chcp 65001 >nul 2>&1" } catch { }

try {
    $Host.UI.RawUI.WindowTitle = "FixlagByEpicPC"
    $ws = $Host.UI.RawUI.WindowSize
    $ws.Width = 85; $ws.Height = 35
    $Host.UI.RawUI.WindowSize = $ws
} catch { }

function Get-Hwid {
    try { return [string]((Get-CimInstance Win32_ComputerSystemProduct -ErrorAction Stop).UUID) }
    catch { return "" }
}

function Invoke-RawBlock {
    param([string]$Body, [string]$Hwid)
    $tmp = Join-Path $env:TEMP ("epicfix_" + [guid]::NewGuid().ToString("N") + ".bat")
    $head = @'
@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
set "my_hwid={{HWID}}"
set "ESC="
for /f %%A in ('echo prompt $E ^| cmd') do set "ESC=%%A"
set "C=%ESC%[96m"
set "G=%ESC%[92m"
set "Y=%ESC%[93m"
set "W=%ESC%[97m"
set "D=%ESC%[90m"
set "R=%ESC%[0m"
set "B=%ESC%[1m"
'@
    $head = $head.Replace("{{HWID}}", $Hwid)
    $tail = "`r`nendlocal`r`nexit /b 0`r`n"
    try {
        [IO.File]::WriteAllText($tmp, ($head + "`r`n" + $Body + $tail), (New-Object Text.UTF8Encoding($false)))
        $p = Start-Process -FilePath "$env:ComSpec" -ArgumentList '/d','/c',("`"" + $tmp + "`"") -NoNewWindow -Wait -PassThru
        return $p.ExitCode
    } finally {
        Remove-Item $tmp -Force -ErrorAction SilentlyContinue
    }
}

function Invoke-Body([string]$Body) {
    Invoke-RawBlock $Body (Get-Hwid) | Out-Null
    Write-Host ""
    Read-Host "   Nhan Enter de quay lai" | Out-Null
}

# ======================= MENU MAIN =======================
$Menu_Main = @'
chcp 65001 >nul
mode con cols=85 lines=35
color 07
title FixagByEpic-Safe100%
set "ESC="
for /f %%A in ('echo prompt $E ^| cmd') do set "ESC=%%A"
set "C=%ESC%[96m"
set "G=%ESC%[92m"
set "Y=%ESC%[93m"
set "W=%ESC%[97m"
set "D=%ESC%[90m"
set "R=%ESC%[0m"
set "B=%ESC%[1m"
cls
echo.
echo %C%%B%        ███████╗██████╗ ██╗ ██████╗    ██████╗  ██████╗%R%
echo %C%%B%        ██╔════╝██╔══██╗██║██╔════╝    ██╔══██╗██╔════╝%R%
echo %C%%B%        █████╗  ██████╔╝██║██║         ██████╔╝██║     %R%
echo %C%%B%        ██╔══╝  ██╔═══╝ ██║██║         ██╔═══╝ ██║     %R%
echo %C%%B%        ███████╗██║     ██║╚██████╗    ██║     ╚██████╗%R%
echo %C%%B%        ╚══════╝╚═╝     ╚═╝ ╚═════╝    ╚═╝      ╚═════╝%R%
echo.
echo %D%   ┌─────────────────────────────────────────────────────────────────────────────┐%R%
echo %D%   │%W%%B%             SYSTEM OPTIMIZATION ^& PERFORMANCE BOOSTER v1.3                  %D%│%R%
echo %D%   ├─────────────────────────────────────────────────────────────────────────────┤%R%
echo %D%   │ %D%HWID:%W% %my_hwid%      %D%Status:%G% ACTIVATED PRO %D%      │%R%
echo %D%   └─────────────────────────────────────────────────────────────────────────────┘%R%
echo.
echo       %W%%B%[ DANH MUC TOI UU HE THONG ]%R%
echo.
echo       %C%[1]%R%  %W%Tweaks (PC / Laptop)%D%
echo       %C%[2]%R%  %W%Optimization CPU %D%
echo       %C%[3]%R%  %W%Optimization GPU %D%
echo       %C%[4]%R%  %W%FPS Boost   %D%
echo       %C%[5]%R%  %W%Power Manager  %D%
echo       %C%[6]%R%  %W%Emulater %D%
echo       %C%[7]%R%  %W%ALL-IN-ONE BOOST %D%
echo.
echo       %G%[9]%R%  %W%%B%Wedsite%R%
echo       %D%[0]%R%  %D%Exit%R%
echo.
echo %D%   ───────────────────────────────────────────────────────────────────────────────%R%
echo       %D%Support:0901258318(Tuan Nghi)   │  Website: epicsp247.netlify.app%R%
echo %D%   ───────────────────────────────────────────────────────────────────────────────%R%
echo.
'@

$Menu_T = @'
title FixlagByEpicPC
cls
echo.    ╔═══════════════════════════════════════════════════════════════╗
echo.    ║                    EpicPC - TWEAKS OPTIMIZER                  ║
echo.    ╚═══════════════════════════════════════════════════════════════╝
echo.
echo.            1N:PC                            2N:LAPTOP
echo.                             X:Menu
echo.
'@

$Menu_Cpu = @'
title FixlagByEpicPC
cls
echo.    ╔═══════════════════════════════════════════════════════════════╗
echo.    ║                    EpicPC - CPU OPTIMIZER                     ║
echo.    ╚═══════════════════════════════════════════════════════════════╝
echo.
echo.            A:intel                            B:AMD
echo.                             X:Menu
echo.
'@

$Menu_Gpu = @'
title FixlagByEpicPC
cls
echo.
echo.    ╔═══════════════════════════════════════════════════════════════╗
echo.    ║                    EpicPC - GPU OPTIMIZER                     ║
echo.    ╚═══════════════════════════════════════════════════════════════╝
echo.
echo.                C:NVIDIA       D:INTEL               E:AMD
echo.                              X:Menu
echo.
'@

$Menu_All = @'
chcp 65001 >nul
mode con cols=75 lines=35
color 3
title FixlagByEpicPC - All In One
cls
echo.    ╔═══════════════════════════════════════════════════════════════╗
echo.    ║                   EpicPC OPTIMIZER v1.2                       ║
echo.    ╠═══════════════════════════════════════════════════════════════╣
echo.    ║                                                               ║
echo.    ║    [1A]  Optimizer Services   [2A]  Disable Features          ║
echo.    ║                                                               ║
echo.    ║    [1B]  Optimizer Memory     [2B]  DISM Cleanup              ║
echo.    ║                                                               ║
echo.    ║    [1C]  Regedit Tweaks       [2C]  Remove Bloatware          ║
echo.    ║                                                               ║
echo.    ║    [1D]  Network Tweaks       [2D]  Optimizer Main            ║
echo.    ║                                                               ║
echo.    ║    [X]   Tro ve Menu chinh                                    ║
echo.    ║                                                               ║
echo.    ╚═══════════════════════════════════════════════════════════════╝
echo.
'@

# ======================= BODY 1N - PC =======================
$Body_P = @'
chcp 65001 >nul
mode con cols=75 lines=35
color 3
title EpicPC - PC Optimizer
cls
echo.
echo    ╔═══════════════════════════════════════════════════════════════╗
echo    ║                    EpicPC - DESKTOP PC TWEAKS                 ║
echo    ╚═══════════════════════════════════════════════════════════════╝
echo.
echo [1/8] Tat tiet kiem dien (Desktop luon cam dien)...
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 >nul 2>&1
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 >nul 2>&1
powercfg /setacvalueindex SCHEME_CURRENT SUB_DISK DISKIDLE 0 >nul 2>&1
powercfg /setacvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOIDLE 0 >nul 2>&1
powercfg /setactive SCHEME_CURRENT >nul 2>&1

echo [2/8] Tat Hibernate + Fast Startup...
powercfg -h off >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d 0 /f >nul 2>&1

echo [3/8] Tat USB Selective Suspend...
powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 >nul 2>&1
powercfg /setactive SCHEME_CURRENT >nul 2>&1

echo [4/8] Tat PCIe ASPM...
powercfg /setacvalueindex SCHEME_CURRENT SUB_PCIEXPRESS ASPM 0 >nul 2>&1
powercfg /setactive SCHEME_CURRENT >nul 2>&1

echo [5/8] Tat Core Parking (full core)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" /v "ValueMax" /t REG_DWORD /d 0 /f >nul 2>&1
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMINCORES 100 >nul 2>&1
powercfg /setactive SCHEME_CURRENT >nul 2>&1

echo [6/8] Tat Modern Standby...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "PlatformAoAcOverride" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "CsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1

echo [7/8] Toi uu Network cho Desktop...
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global rss=enabled >nul 2>&1
netsh int tcp set global ecncapability=disabled >nul 2>&1
netsh int tcp set global timestamps=disabled >nul 2>&1

echo [8/8] Toi uu GPU + Disk...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrDelay" /t REG_DWORD /d 60 /f >nul 2>&1
fsutil behavior set disablelastaccess 1 >nul 2>&1
fsutil behavior set memoryusage 2 >nul 2>&1

echo.
echo HOAN TAT TOI UU PC DESKTOP!
'@

# ======================= BODY 2N - LAPTOP =======================
$Body_L = @'
chcp 65001 >nul
mode con cols=75 lines=35
color 3
title EpicPC - Laptop Optimizer
cls
echo.
echo    ╔═══════════════════════════════════════════════════════════════╗
echo    ║                    EpicPC - LAPTOP TWEAKS                     ║
echo    ╚═══════════════════════════════════════════════════════════════╝
echo.
echo [1/9] Bat Battery Saver + Power Throttling...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "EnergyEstimationEnabled" /t REG_DWORD /d 1 /f >nul 2>&1
powercfg /setdcvalueindex SCHEME_CURRENT SUB_ENERGYSAVER ESBATTTHRESHOLD 20 >nul 2>&1
powercfg /setactive SCHEME_CURRENT >nul 2>&1

echo [2/9] Can bang CPU khi dung pin...
powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 80 >nul 2>&1
powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 5 >nul 2>&1
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 >nul 2>&1
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 5 >nul 2>&1
powercfg /setactive SCHEME_CURRENT >nul 2>&1

echo [3/9] Toi uu Thermal Policy...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "CoalescingTimerInterval" /t REG_DWORD /d 1000 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\intelppm\Parameters" /v "PerfBoostPolicy" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\intelppm\Parameters" /v "AllowPerfBoostPolicy" /t REG_DWORD /d 1 /f >nul 2>&1

echo [4/9] Giu Modern Standby (S0ix) cho Laptop...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "PlatformAoAcOverride" /t REG_DWORD /d 0 /f >nul 2>&1
powercfg /setdcvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 300 >nul 2>&1

echo [5/9] Toi uu Wi-Fi...
netsh int tcp set global autotuninglevel=restricted >nul 2>&1
netsh int tcp set global rss=enabled >nul 2>&1
netsh int tcp set global fastopen=enabled >nul 2>&1

echo [6/9] Bat USB Selective Suspend (tiet kiem pin)...
powercfg /setdcvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 1 >nul 2>&1
powercfg /setactive SCHEME_CURRENT >nul 2>&1

echo [7/9] Bat PCIe ASPM khi dung pin...
powercfg /setdcvalueindex SCHEME_CURRENT SUB_PCIEXPRESS ASPM 2 >nul 2>&1
powercfg /setactive SCHEME_CURRENT >nul 2>&1

echo [8/9] Disk timeout khi dung pin...
powercfg /change -disk-timeout-dc 10 >nul 2>&1
powercfg /change -disk-timeout-ac 0 >nul 2>&1

echo [9/9] Toi uu GPU + Memory...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrDelay" /t REG_DWORD /d 8 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 0 /f >nul 2>&1

echo.
echo HOAN TAT TOI UU LAPTOP!
'@

# ======================= BODY INTEL =======================
$Body_INTEL = @'
cls
echo.
echo.    ╔═══════════════════════════════════════════════════════════════╗
echo.    ║                    EpicPC - INTEL OPTIMIZER                   ║
echo.    ╚═══════════════════════════════════════════════════════════════╝
echo.
echo Dang toi uu CPU Intel...
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DistributeTimers" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DisableTsx" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\intelppm\Parameters" /v "IdleStateMaximum" /t REG_DWORD /d 8 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\intelppm\Parameters" /v "IdleStateMinimum" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\intelppm\Parameters" /v "C3PackageIdle" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\intelppm\Parameters" /v "C6PackageIdle" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\intelppm\Parameters" /v "C7PackageIdle" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\intelppm\Parameters" /v "PerfBoostPolicy" /t REG_DWORD /d 3 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\intelppm\Parameters" /v "AllowPerfBoostPolicy" /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "CoalescingTimerInterval" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d 3 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Throttle" /v "PerfEnablePackageIdle" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "EnergyEstimationEnabled" /t REG_DWORD /d "0" /f
echo.
echo Da toi uu CPU Intel thanh cong!
'@

# ======================= BODY AMD =======================
$Body_AMD = @'
cls
echo.
echo.    ╔═══════════════════════════════════════════════════════════════╗
echo.    ║                    EpicPC - AMD OPTIMIZER                     ║
echo.    ╚═══════════════════════════════════════════════════════════════╝
echo.
echo Dang toi uu CPU AMD...
powercfg /setACvalueindex scheme_current SUB_PROCESSOR SYSCOOLPOL 1
powercfg /setDCvalueindex scheme_current SUB_PROCESSOR SYSCOOLPOL 1
Powercfg -setacvalueindex scheme_current sub_processor PROCTHROTTLEMAX 100
Powercfg -setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN 100
powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100
powercfg -setacvalueindex scheme_current sub_processor THROTTLING 0
powercfg /setactive SCHEME_CURRENT
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\AmdPPM\Parameters" /v "PerfEnergyPreference" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\amdppm\Parameters" /v "C1eEnabled" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d 3 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DistributeTimers" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DynamicTick" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "CsEnabled" /t REG_DWORD /d "0" /f
echo.
echo Da toi uu CPU AMD thanh cong!
'@

# ======================= BODY NVIDIA =======================
$Body_NVIDIA = @'
cls
echo.
echo.    ╔═══════════════════════════════════════════════════════════════╗
echo.    ║                    EpicPC - NVIDIA OPTIMIZER                  ║
echo.    ╚═══════════════════════════════════════════════════════════════╝
echo.
echo Dang toi uu card do hoa NVIDIA...
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "QosManagesIdleProcessors" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v "DisplayPowerSaving" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\NVIDIA Corporation\Global\NVTweak" /v "DisplayPowerSaving" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "RmGpsPsEnablePerCpuCoreDpc" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "RmGpsPsEnablePerCpuCoreDpc" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "D3PCLatency" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "LOWLATENCY" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "Node3DLowLatency" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "2" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrDelay" /t REG_DWORD /d "8" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\NvTelemetryContainer" /v "Start" /t REG_DWORD /d 4 /f
Reg.exe add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID44231" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID64640" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID66610" /t REG_DWORD /d "0" /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemption" /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableCudaContextPreemption" /t REG_DWORD /d 1 /f
echo.
echo Da toi uu GPU NVIDIA thanh cong!
'@

# ======================= BODY AMD GPU =======================
$Body_AMD_GPU = @'
cls
echo.
echo.    ╔═══════════════════════════════════════════════════════════════╗
echo.    ║                    EpicPC - AMD GPU OPTIMIZER                 ║
echo.    ╚═══════════════════════════════════════════════════════════════╝
echo.
echo Dang toi uu card do hoa AMD...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableVceSwClockGating" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableUvdClockGating" /t REG_DWORD /d "1" /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableDMACopy" /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "StutterMode" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableUlps" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PP_ThermalAutoThrottlingEnable" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableDrmdmaPowerGating" /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "KMD_DeLagEnabled" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "2" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrDelay" /t REG_DWORD /d "8" /f
echo.
echo Da toi uu GPU AMD thanh cong!
'@

# ======================= BODY GPU CHUNG =======================
$Body_GPU_CHUNG = @'
cls
echo.
echo.    ╔═══════════════════════════════════════════════════════════════╗
echo.    ║                    EpicPC - GPU CHUNG                         ║
echo.    ╚═══════════════════════════════════════════════════════════════╝
echo.
echo Dang toi uu chung cho GPU...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "VsyncIdleTimeout" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrDelay" /t REG_DWORD /d "8" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrDdiDelay" /t REG_DWORD /d "8" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "MemoryPriority" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "PowerSettingEnable" /t REG_DWORD /d "0" /f >nul 2>&1
echo.
echo Da toi uu chung GPU thanh cong!
'@

# ======================= BODY FPS =======================
$Body_FPS = @'
cls
echo.
echo.    ╔═══════════════════════════════════════════════════════════════╗
echo.    ║                    EpicPC - FPS BOOSTER                       ║
echo.    ╚═══════════════════════════════════════════════════════════════╝
echo.
Reg.exe add "HKLM\SYSTEM\ControlSet001\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "38" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d "4294967295" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d "8" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d "6" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul 2>&1
Reg.exe add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Control Panel\Desktop" /v "AutoEndTasks" /t REG_SZ /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "2000" /f >nul 2>&1
echo.
echo HOAN TAT TOI UU FPS!
'@

# ======================= BODY POWER =======================
$Body_POWER = @'
cls
echo.
echo.    ╔═══════════════════════════════════════════════════════════════╗
echo.    ║                 DANG BAT HIEU SUAT CAO...                    ║
echo.    ╚═══════════════════════════════════════════════════════════════╝
echo.
set "UP_GUID=e9a42b02-d5df-448d-aa00-03f14749eb61"
set "TEMP1=bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"
set "TEMP2=eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"
echo [*] Dang tao power plan Ultimate Performance...
powercfg /duplicatescheme %UP_GUID% %TEMP1% >nul 2>&1
powercfg /setactive %TEMP1% >nul
powercfg /delete %TEMP2% >nul 2>&1
powercfg /duplicatescheme %UP_GUID% %TEMP2% >nul 2>&1
powercfg /setactive %TEMP2% >nul
powercfg /delete %TEMP1% >nul
echo [*] Dang ap dung tweaks hieu suat cao...
powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN 100 >nul
powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMAX 100 >nul
powercfg /setacvalueindex scheme_current sub_processor THROTTLING 0 >nul
powercfg /setacvalueindex scheme_current sub_processor PERFBOOSTMODE 1 >nul
powercfg /setacvalueindex scheme_current sub_processor PERFBOOSTPOL 100 >nul
powercfg /setacvalueindex scheme_current SUB_PCIEXPRESS ASPM 0 >nul
powercfg /setacvalueindex scheme_current sub_none DEVICEIDLE 0 >nul
powercfg /setacvalueindex scheme_current sub_none CONSOLELOCK 0 >nul
powercfg /setacvalueindex scheme_current 2a737441-1930-4402-8d77-b2bebba308a3 d4e98f31-5ffe-4ce1-be31-1b38b384c009 0 >nul
powercfg /setacvalueindex scheme_current 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 >nul
powercfg /setacvalueindex scheme_current SUB_SLEEP AWAYMODE 0 >nul
powercfg /setacvalueindex scheme_current SUB_SLEEP ALLOWSTANDBY 0 >nul
powercfg /setacvalueindex scheme_current SUB_SLEEP HYBRIDSLEEP 0 >nul
powercfg /setactive scheme_current >nul
echo.
echo HOAN TAT TOI UU POWER!
'@

# ======================= BODY EMULATOR =======================
$Body_EMU = @'
cls
echo.
echo.    ╔═══════════════════════════════════════════════════════════════╗
echo.    ║              DANG BAT HIEU NANG CAO NHAT...                   ║
echo.    ╚═══════════════════════════════════════════════════════════════╝
echo.
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Bluestacks.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\BstkSVC.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\HD-Agent.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\HD-Player.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\LdVBoxHeadless.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Nox.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\NoxVMHandle.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MEmu.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MEmuHeadless.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "3" /f
echo.
echo HOAN TAT TOI UU Emulator!
'@

# ======================= BODY S - MAIN OPTIMIZER =======================
$Body_S = @'
chcp 65001 >nul
mode con cols=75 lines=35
color 3
title optime Main
echo.
echo  ============================================================
echo  1. CPU SCHEDULING + TIMER
echo  ============================================================
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 0xFFFFFFFF /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "AlwaysOn" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NoLazyMode" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 31 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 8 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 40 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Kernel" /v "TimerResolution" /t REG_DWORD /d 5000 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Kernel" /v "GlobalTimerResolutionRequests" /t REG_DWORD /d 1 /f >nul 2>&1
echo.
echo  ============================================================
echo  2. MEMORY MANAGEMENT
echo  ============================================================
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "ClearPageFileAtShutdown" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargePageMinimum" /t REG_DWORD /d 4294967295 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisableMemoryCompression" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePageCombining" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PoolUsageMaximum" /t REG_DWORD /d 60 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
echo.
echo  ============================================================
echo  3. GPU
echo  ============================================================
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrDelay" /t REG_DWORD /d 60 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrDdiDelay" /t REG_DWORD /d 20 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "PowerSettingEnable" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f >nul 2>&1
echo.
echo  ============================================================
echo  4. GAME PRIORITY
echo  ============================================================
for %%G in (
    cs2.exe r5apex.exe VALORANT-Win64-Shipping.exe FortniteClient-Win64-Shipping.exe
    Overwatch.exe RainbowSix.exe bf1.exe bfv.exe bf2042.exe cod.exe
    GTA5.exe Cyberpunk2077.exe ForzaHorizon5.exe Minecraft.exe
    "League of Legends.exe" explorer.exe audiodg.exe dwm.exe
) do (
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%G\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d 3 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%G\PerfOptions" /v "IoPriority" /t REG_DWORD /d 4 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%G\PerfOptions" /v "PagePriority" /t REG_DWORD /d 5 /f >nul 2>&1
)
echo.
echo  ============================================================
echo  5. NETWORK
echo  ============================================================
netsh int tcp set global autotuninglevel=normal
netsh int tcp set global ecncapability=disabled
netsh int tcp set global timestamps=disabled
netsh int tcp set global rsc=disabled
netsh int tcp set global fastopen=enabled
netsh int tcp set heuristics disabled
netsh int udp set global uro=enabled
echo.
echo  ============================================================
echo  6. POWER
echo  ============================================================
powercfg -h off
powercfg -change -disk-timeout-ac 0
powercfg -setacvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOIDLE 0
powercfg -setacvalueindex SCHEME_CURRENT SUB_PCIEXPRESS ASPM 0
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFBOOSTMODE 1
powercfg -setactive SCHEME_CURRENT
echo.
echo  ============================================================
echo  7. BOOT + SYSTEM
echo  ============================================================
bcdedit /set bootux disabled >nul 2>&1
bcdedit /set quietboot yes >nul 2>&1
bcdedit /set noguiboot on >nul 2>&1
bcdedit /set debug off >nul 2>&1
bcdedit /set {current} bootstatuspolicy IgnoreAllFailures >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "2000" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "AutoEndTasks" /t REG_SZ /d "1" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t REG_SZ /d "1000" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d "2000" /f >nul 2>&1
echo.
echo  ============================================================
echo  8. FILE SYSTEM / DISK
echo  ============================================================
fsutil behavior set disable8dot3 1 >nul 2>&1
fsutil behavior set disablelastaccess 1 >nul 2>&1
fsutil behavior set memoryusage 2 >nul 2>&1
fsutil behavior set mftzone 4 >nul 2>&1
echo.
echo HOAN TAT TOI UU MAIN
'@

# ======================= BODY M - MEMORY =======================
$Body_M = @'
chcp 65001 >nul
mode con cols=75 lines=35
color 3
title Memory
Set "sum1=0"
set "sum2=0"
for /f %%a in ('wmic cpu get L2CacheSize ^| findstr /r "[0-9][0-9]"') do (
    set /a "sum1=%%a"
)
for /f %%a in ('wmic cpu get L3CacheSize ^| findstr /r "[0-9][0-9]"') do (
    set /a "sum2=%%a"
)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "SecondLevelDataCache" /t REG_DWORD /d "!sum1!" /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "ThirdLevelDataCache" /t REG_DWORD /d "!sum2!" /f >nul
set "mem=0"
for /f "tokens=2 delims==" %%a in ('wmic os get TotalVisibleMemorySize /format:value') do set mem=%%a
set /a ram=!mem! + 1024000
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "svchostsplitthresholdinkb" /t REG_DWORD /d "!ram!" /f >nul
echo    - Da cau hinh Cache L2/L3 va Nguong Svchost.
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "ClearPageFileAtShutdown" /t REG_DWORD /d "0" /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d "1" /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d "0" /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PoolUsageMaximum" /t REG_DWORD /d 60 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d "0" /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d "0" /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d "3" /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d "3" /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsDisable8dot3NameCreation" /t REG_DWORD /d "1" /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsDisableLastAccessUpdate" /t REG_DWORD /d "1" /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsMftZoneReservation" /t REG_DWORD /d "2" /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Executive" /v "AdditionalCriticalWorkerThreads" /t REG_DWORD /d 16 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Executive" /v "AdditionalDelayedWorkerThreads" /t REG_DWORD /d 16 /f >nul
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /va /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce" /va /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /va /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /va /f >nul 2>&1
del /f /q "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\*.*" >nul 2>&1
del /f /q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\*.*" >nul 2>&1
powercfg -h off >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
powershell -Command "[System.GC]::Collect(); [System.GC]::WaitForPendingFinalizers()" >nul 2>&1
taskkill /f /im explorer.exe >nul 2>&1
echo HOAN TAT TOI UU MEMORY!
'@

# ======================= BODY R - REGEDIT =======================
$Body_R = @'
chcp 65001 >nul
mode con cols=75 lines=35
color 3
title Regedit
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NoLazyMode" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "AlwaysOn" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 0xffffffff /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 38 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Control Panel\Keyboard" /v "KeyboardDelay" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Keyboard" /v "KeyboardSpeed" /t REG_SZ /d "31" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d 0 /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d 0 /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "AutoEndTasks" /t REG_SZ /d "1" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d "2000" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "2000" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCopilotButton" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocation" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\AppModel" /v "Start" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\Cellcore" /v "Start" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DataMarket" /v "Start" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DiagLog" /v "Start" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\SQMLogger" /v "Start" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\WdiContextLog" /v "Start" /t REG_DWORD /d 0 /f >nul 2>&1
echo HOAN TAT TOI UU REGEDIT!
'@

# ======================= BODY W - NETWORK =======================
$Body_W = @'
chcp 65001 >nul
mode con cols=75 lines=35
color 3
title Network
echo Dang toi uu hoa Network Stack cho Game...
ipconfig /flushdns >nul 2>&1
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global dca=enabled >nul 2>&1
netsh int tcp set global ecncapability=disabled >nul 2>&1
netsh int tcp set global timestamps=disabled >nul 2>&1
netsh int tcp set global rss=enabled >nul 2>&1
netsh int tcp set global fastopen=enabled >nul 2>&1
netsh int tcp set global heuristics=disabled >nul 2>&1
netsh int tcp set global sack=enabled >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /v "TCPNoDelay" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DisableTaskOffload" /t REG_DWORD /d "1" /f >nul 2>&1
echo HOAN TAT TOI UU NETWORK!
'@

# ======================= BODY DIS - DISABLE FEATURE =======================
$Body_DIS = @'
chcp 65001 >nul
mode con cols=75 lines=35
color 3
title Disable Features
echo Dang toi uu hoa Disable Features...
echo --- Disable Telemetry Tasks
schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Autochk\Proxy" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /Disable >nul 2>&1
echo --- Disable Location
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocation" /t REG_DWORD /d 1 /f >nul 2>&1
echo --- Disable Cortana
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaConsent" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f >nul 2>&1
echo --- Disable Edge Update
sc config "edgeupdate" start= disabled >nul 2>&1
sc stop "edgeupdate" >nul 2>&1
sc config "edgeupdatem" start= disabled >nul 2>&1
sc stop "edgeupdatem" >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "UpdateDefault" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "AutoUpdateCheckPeriodMinutes" /t REG_DWORD /d 0 /f >nul 2>&1
echo --- Disable Edge Copilot
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "HubsSidebarEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "CopilotPageContext" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "CopilotCDPPageContext" /t REG_DWORD /d 0 /f >nul 2>&1
echo --- Disable OneDrive
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d 1 /f >nul 2>&1
echo HOAN TAT TOI UU DISABLE FEATURES!
'@

# ======================= BODY DISM =======================
$Body_DISM = @'
chcp 65001 >nul
mode con cols=75 lines=35
color 3
title DISM OPTIMIZE
echo Dang don dep he thong...
del /s /f /q C:\Windows\Logs\*.log >nul 2>&1
del /f /s /q "C:\Windows\inf\*.log" >nul 2>&1
del /f /s /q "C:\ProgramData\Microsoft\Windows\WER\*.*" >nul 2>&1
rd /s /q "C:\ProgramData\Microsoft\Windows\WER\ReportArchive" >nul 2>&1
rd /s /q "C:\ProgramData\Microsoft\Windows\WER\ReportQueue" >nul 2>&1
del /f /s /q "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
del /f /s /q "%LocalAppData%\NVIDIA\DXCache\*.*" >nul 2>&1
del /f /s /q "%LocalAppData%\AMD\DXCache\*.*" >nul 2>&1
del /f /s /q "%TEMP%\*.*" >nul 2>&1
for /d %%D in ("%TEMP%\*") do rd /s /q "%%D" >nul 2>&1
del /f /s /q "C:\Windows\Temp\*.*" >nul 2>&1
for /d %%D in ("C:\Windows\Temp\*") do rd /s /q "%%D" >nul 2>&1
del /f /q "C:\Windows\Prefetch\*.*" >nul 2>&1
net stop wuauserv >nul 2>&1
rd /s /q "C:\Windows\SoftwareDistribution\Download" >nul 2>&1
md "C:\Windows\SoftwareDistribution\Download" >nul 2>&1
net start wuauserv >nul 2>&1
del /f /s /q "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache\*" >nul 2>&1
del /f /s /q "%AppData%\Microsoft\Windows\Recent\*" >nul 2>&1
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
net stop spooler >nul 2>&1
del /f /s /q "%windir%\System32\spool\PRINTERS\*.*" >nul 2>&1
net start spooler >nul 2>&1
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
echo HOAN TAT TOI UU DISM!
'@

# ======================= BODY RE - REMOVE APP (FULL) =======================
$Body_RE = @'
chcp 65001 >nul
mode con cols=75 lines=35
color 3
title Remove Bloatware Full
echo.
echo  ============================================================
echo   REMOVE ALL BLOATWARE APPS - FULL CLEAN
echo  ============================================================
echo.

echo [01] Windows Widgets (WebExperience)...
powershell -NoProfile -Command "Get-AppxPackage *WebExperience* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [02] Phone Companion...
powershell -NoProfile -Command "Get-AppxPackage *WindowsPhone* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [03] Microsoft Phone / CommsPhone...
powershell -NoProfile -Command "Get-AppxPackage *CommsPhone* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [04] Phone Link (YourPhone)...
powershell -NoProfile -Command "Get-AppxPackage *YourPhone* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [05] Cortana...
powershell -NoProfile -Command "Get-AppxPackage *549981C3F5F10* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [06] Get Help...
powershell -NoProfile -Command "Get-AppxPackage *GetHelp* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [07] Microsoft Tips...
powershell -NoProfile -Command "Get-AppxPackage *Getstarted* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [08] Microsoft Messaging...
powershell -NoProfile -Command "Get-AppxPackage *Messaging* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [09] Mixed Reality Portal...
powershell -NoProfile -Command "Get-AppxPackage *MixedReality.Portal* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [10] Feedback Hub...
powershell -NoProfile -Command "Get-AppxPackage *WindowsFeedbackHub* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [11] Windows Alarms and Clock...
powershell -NoProfile -Command "Get-AppxPackage *WindowsAlarms* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [12] Windows Camera...
powershell -NoProfile -Command "Get-AppxPackage *WindowsCamera* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [13] Windows Maps...
powershell -NoProfile -Command "Get-AppxPackage *WindowsMaps* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [14] Minecraft for Windows...
powershell -NoProfile -Command "Get-AppxPackage *MinecraftUWP* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [15] Microsoft People...
powershell -NoProfile -Command "Get-AppxPackage *Microsoft.People* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [16] Microsoft Pay (Wallet)...
powershell -NoProfile -Command "Get-AppxPackage *Wallet* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [17] Mobile Plans (OneConnect)...
powershell -NoProfile -Command "Get-AppxPackage *OneConnect* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [18] Solitaire Collection...
powershell -NoProfile -Command "Get-AppxPackage *MicrosoftSolitaireCollection* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [19] Sticky Notes...
powershell -NoProfile -Command "Get-AppxPackage *MicrosoftStickyNotes* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [20] Mail and Calendar...
powershell -NoProfile -Command "Get-AppxPackage *windowscommunicationsapps* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [21] Movies and TV...
powershell -NoProfile -Command "Get-AppxPackage *ZuneVideo* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [22] Windows Calculator...
powershell -NoProfile -Command "Get-AppxPackage *WindowsCalculator* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [23] Microsoft Photos...
powershell -NoProfile -Command "Get-AppxPackage *Windows.Photos* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [24] Skype...
powershell -NoProfile -Command "Get-AppxPackage *SkypeApp* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [25] GroupMe...
powershell -NoProfile -Command "Get-AppxPackage *GroupMe10* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [26] Windows Sound Recorder...
powershell -NoProfile -Command "Get-AppxPackage *WindowsSoundRecorder* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [27] Microsoft Remote Desktop...
powershell -NoProfile -Command "Get-AppxPackage *RemoteDesktop* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [28] Print 3D...
powershell -NoProfile -Command "Get-AppxPackage *Print3D* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1

echo --- Deprovision (chong cai lai khi tao user moi)...
powershell -NoProfile -Command "$prov = @('Microsoft.WindowsPhone','Microsoft.CommsPhone','Microsoft.YourPhone','Microsoft.549981C3F5F10','Microsoft.GetHelp','Microsoft.Getstarted','Microsoft.Messaging','Microsoft.MixedReality.Portal','Microsoft.WindowsFeedbackHub','Microsoft.WindowsAlarms','Microsoft.WindowsCamera','Microsoft.WindowsMaps','Microsoft.MinecraftUWP','Microsoft.People','Microsoft.Wallet','Microsoft.OneConnect','Microsoft.MicrosoftSolitaireCollection','Microsoft.MicrosoftStickyNotes','microsoft.windowscommunicationsapps','Microsoft.ZuneVideo','Microsoft.WindowsCalculator','Microsoft.Windows.Photos','Microsoft.SkypeApp','Microsoft.GroupMe10','Microsoft.WindowsSoundRecorder','Microsoft.RemoteDesktop','Microsoft.Print3D'); foreach ($p in $prov) { Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object DisplayName -eq $p | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null }" >nul 2>&1

echo --- Disable Windows Media Player...
powershell -NoProfile -Command "Disable-WindowsOptionalFeature -Online -FeatureName WindowsMediaPlayer -NoRestart -ErrorAction SilentlyContinue" >nul 2>&1

echo --- Disable OneDrive usage...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSync" /t REG_DWORD /d 1 /f >nul 2>&1

echo --- Disable Edge auto-update...
reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "UpdateDefault" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "AutoUpdateCheckPeriodMinutes" /t REG_DWORD /d 0 /f >nul 2>&1

echo.
echo ============================================================
echo   HOAN TAT XOA BLOATWARE!
echo ============================================================
'@

# ============================== MENU FUNCTIONS ==============================
function Read-MainChoice {
    Write-Host "   " -NoNewline
    Write-Host "EPIC PC" -ForegroundColor Cyan -NoNewline
    Write-Host " > " -ForegroundColor DarkGray -NoNewline
    Write-Host "CHON CHUC NANG (0-9): " -ForegroundColor White -NoNewline
    $r = Read-Host
    if ($null -eq $r) { return $null }
    return ([string]$r).Trim()
}

function Menu-T {
    while ($true) {
        Invoke-RawBlock $Menu_T (Get-Hwid) | Out-Null
        $c = Read-Host "     EpicPC @ Chon chuc nang (1N/2N/X)"
        if ($null -eq $c) { return }
        $c = ([string]$c).Trim().ToUpper()
        switch ($c) {
            "1N" { Invoke-Body $Body_P; return }
            "2N" { Invoke-Body $Body_L; return }
            "X"  { return }
        }
    }
}

function Menu-Cpu {
    while ($true) {
        Invoke-RawBlock $Menu_Cpu (Get-Hwid) | Out-Null
        $c = Read-Host "     EpicPC @ Chon chuc nang (A/B/X)"
        if ($null -eq $c) { return }
        $c = ([string]$c).Trim().ToUpper()
        switch ($c) {
            "A" { Invoke-Body $Body_INTEL; return }
            "B" { Invoke-Body $Body_AMD; return }
            "X" { return }
        }
    }
}

function Menu-Gpu {
    while ($true) {
        Invoke-RawBlock $Menu_Gpu (Get-Hwid) | Out-Null
        $c = Read-Host "     EpicPC @ Chon chuc nang (C/D/E/X)"
        if ($null -eq $c) { return }
        $c = ([string]$c).Trim().ToUpper()
        switch ($c) {
            "C" { Invoke-Body $Body_NVIDIA; return }
            "D" { Invoke-Body $Body_GPU_CHUNG; return }
            "E" { Invoke-Body $Body_AMD_GPU; return }
            "X" { return }
        }
    }
}

function Menu-All {
    while ($true) {
        Invoke-RawBlock $Menu_All (Get-Hwid) | Out-Null
        $c = Read-Host "     EpicPC @ Chon (1A-1D / 2A-2D / X)"
        if ($null -eq $c) { return }
        $c = ([string]$c).Trim().ToLower()
        switch ($c) {
            "1a" { Invoke-Body $Body_S }
            "1b" { Invoke-Body $Body_M }
            "1c" { Invoke-Body $Body_R }
            "1d" { Invoke-Body $Body_W }
            "2a" { Invoke-Body $Body_DIS }
            "2b" { Invoke-Body $Body_DISM }
            "2c" { Invoke-Body $Body_RE }
            "2d" { Invoke-Body $Body_S }
            "x"  { return }
        }
    }
}

function Menu-Main {
    while ($true) {
        Invoke-RawBlock $Menu_Main (Get-Hwid) | Out-Null
        $c = Read-MainChoice
        if ($null -eq $c) { return }
        switch ($c) {
            "1" { Menu-T }
            "2" { Menu-Cpu }
            "3" { Menu-Gpu }
            "4" { Invoke-Body $Body_FPS }
            "5" { Invoke-Body $Body_POWER }
            "6" { Invoke-Body $Body_EMU }
            "7" { Menu-All }
            "9" { Start-Process "https://epicsp247.netlify.app" | Out-Null }
            "0" { return }
        }
    }
}

Menu-Main
exit 0