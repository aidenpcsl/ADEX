@echo off
setlocal EnableExtensions DisableDelayedExpansion
rem ============================================================================
rem ADEX v1.1.0 - local Windows optimization and diagnostics utility
rem Runtime policy: no downloads, no remote scripts, no services, no telemetry.
rem ============================================================================

call :EnsureAdministrator
if errorlevel 1 goto :ExitNoAdmin
call :Initialize
call :DetectSystem
call :Log "ADEX started; administrator privileges confirmed."
goto :MainMenu

:Initialize
set "ADEX_VERSION=1.1.0"
set "APPDIR=%~dp0"
set "DATADIR=%APPDIR%ADEX-data"
set "BACKUPDIR=%DATADIR%\backups"
set "REPORTDIR=%DATADIR%\reports"
set "PROFILEDIR=%DATADIR%\profiles"
set "LOGDIR=%DATADIR%\logs"
set "LOGFILE=%LOGDIR%\adex.log"
set "UNDOLOG=%DATADIR%\undo-records.log"
set "PROFILEHISTORY=%PROFILEDIR%\history.log"
set "COLOR_THEME=0B"
for %%D in ("%DATADIR%" "%BACKUPDIR%" "%REPORTDIR%" "%PROFILEDIR%" "%LOGDIR%") do if not exist "%%~D" md "%%~D" >nul 2>&1
if not exist "%UNDOLOG%" type nul > "%UNDOLOG%"
if not exist "%PROFILEHISTORY%" type nul > "%PROFILEHISTORY%"
set "LIBRARY=WIN-0001 WIN-0002 WIN-0003 WIN-0004 GAME-0001 GAME-0002 GAME-0003 INPUT-0001 INPUT-0002 INPUT-0003 CPU-0001 GPU-0001 RAM-0001 RAM-0002 STOR-0001 STOR-0002 STOR-0003 STOR-0004 PWR-0001 PWR-0002 PWR-0003 NET-0001 NET-0002 NET-0003 NET-0004 START-0001 START-0002 SVC-0001 SVC-0002 TASK-0001 TASK-0002 UI-0001 UI-0002 UI-0003 UI-0004 UI-0005 UI-0006 PRIV-0001 PRIV-0002 PRIV-0003 PRIV-0004 PRIV-0005 CLEAN-0001 CLEAN-0002 CLEAN-0003 CLEAN-0004 DIAG-0001 DIAG-0002 DIAG-0003 DIAG-0004 DIAG-0005 DIAG-0006 DIAG-0007 REPAIR-0001 REPAIR-0002 REPAIR-0003 REPAIR-0004 REPAIR-0005 REPAIR-0006"
color %COLOR_THEME% >nul 2>&1
exit /b 0

:EnsureAdministrator
fltmc >nul 2>&1
if not errorlevel 1 (
 set "IS_ADMIN=YES"
 exit /b 0
)
echo.
echo  Administrator privileges are required for ADEX safety checks and changes.
echo  Elevation is requested through the local Windows UAC prompt only.
choice /c YN /n /m "Restart ADEX as Administrator"
if errorlevel 2 exit /b 1
powershell -NoProfile -Command "Start-Process -FilePath $env:ComSpec -Verb RunAs -ArgumentList '/d /c """"%~f0""""'" >nul 2>&1
if errorlevel 1 (
 echo.
 echo  Elevation was cancelled or failed. No changes were made.
 pause
 exit /b 1
)
exit /b 1

:DetectSystem
set "OS_NAME=Windows (undetected)"
set "OS_BUILD=0"
set "OS_ARCH=%PROCESSOR_ARCHITECTURE%"
set "OS_INSTALLATION=Unknown"
set "CPU_NAME=Unavailable"
set "RAM_GB=Unavailable"
set "GPU_NAME=Unavailable"
for /f "tokens=1,2,*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName 2^>nul ^| findstr /I /C:"ProductName"') do set "OS_NAME=%%C"
for /f "tokens=1,2,*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuildNumber 2^>nul ^| findstr /I /C:"CurrentBuildNumber"') do set "OS_BUILD=%%C"
for /f "tokens=1,2,*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v InstallationType 2^>nul ^| findstr /I /C:"InstallationType"') do set "OS_INSTALLATION=%%C"
for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "(Get-CimInstance Win32_Processor | Select-Object -First 1 -ExpandProperty Name).Trim()" 2^>nul`) do set "CPU_NAME=%%A"
for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "[math]::Round(((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB),1)" 2^>nul`) do set "RAM_GB=%%A GB"
for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "(Get-CimInstance Win32_VideoController | Select-Object -First 1 -ExpandProperty Name)" 2^>nul`) do set "GPU_NAME=%%A"
if "%OS_BUILD%"=="" set "OS_BUILD=0"
exit /b 0

:Header
cls
echo ============================================================================
echo   ADEX %ADEX_VERSION%  ^|  Windows Optimization and Diagnostics
 echo   Local-first. Evidence-led. Reversible where Windows permits.
echo ============================================================================
echo   Windows : %OS_NAME%  [build %OS_BUILD%]
echo   System  : %OS_ARCH%  ^|  CPU: %CPU_NAME%
echo   Memory  : %RAM_GB%  ^|  GPU: %GPU_NAME%
echo   Admin   : %IS_ADMIN%  ^|  Data: ADEX-data next to this script
echo ----------------------------------------------------------------------------
exit /b 0

:MainMenu
call :Header
echo.
echo   [ 1] Windows settings                 [12] Windows UI and Explorer
echo   [ 2] Gaming                           [13] Privacy
echo   [ 3] Input and responsiveness         [14] Cleanup
echo   [ 4] CPU and GPU                      [15] Diagnostics
echo   [ 5] Memory                           [16] Repair
echo   [ 6] Storage                          [17] Backup and Restore Point
echo   [ 7] Power and performance            [18] Undo Manager
echo   [ 8] Network                          [19] Profiles
echo   [ 9] Startup analysis                 [20] Search library
echo   [10] Services                         [21] Reports and benchmarks
echo   [11] Scheduled tasks                  [22] Settings and integrity
 echo.
 echo   [ 0] Exit
 echo ----------------------------------------------------------------------------
set "MENU="
set /p "MENU=Select an area: "
if "%MENU%"=="1" call :CategoryMenu WINDOWS
if "%MENU%"=="2" call :CategoryMenu GAMING
if "%MENU%"=="3" call :CategoryMenu INPUT
if "%MENU%"=="4" call :CpuGpuMenu
if "%MENU%"=="5" call :CategoryMenu MEMORY
if "%MENU%"=="6" call :CategoryMenu STORAGE
if "%MENU%"=="7" call :CategoryMenu POWER
if "%MENU%"=="8" call :CategoryMenu NETWORK
if "%MENU%"=="9" call :CategoryMenu STARTUP
if "%MENU%"=="10" call :CategoryMenu SERVICES
if "%MENU%"=="11" call :CategoryMenu TASKS
if "%MENU%"=="12" call :CategoryMenu UI
if "%MENU%"=="13" call :CategoryMenu PRIVACY
if "%MENU%"=="14" call :CategoryMenu CLEANUP
if "%MENU%"=="15" call :CategoryMenu DIAGNOSTICS
if "%MENU%"=="16" call :CategoryMenu REPAIR
if "%MENU%"=="17" call :BackupMenu
if "%MENU%"=="18" call :UndoMenu
if "%MENU%"=="19" call :ProfileMenu
if "%MENU%"=="20" call :SearchMenu
if "%MENU%"=="21" call :ReportMenu
if "%MENU%"=="22" call :SettingsMenu
if "%MENU%"=="0" goto :Exit
if not "%MENU%"=="" (
 echo Invalid selection.
 timeout /t 2 >nul
)
goto :MainMenu

:CpuGpuMenu
call :Header
echo   CPU and GPU operations
 echo ----------------------------------------------------------------------------
for %%I in (%LIBRARY%) do call :ListIfCategory %%I CPU
for %%I in (%LIBRARY%) do call :ListIfCategory %%I GPU
call :PromptOperation
exit /b

:CategoryMenu
call :Header
echo   %~1 operation library
 echo ----------------------------------------------------------------------------
for %%I in (%LIBRARY%) do call :ListIfCategory %%I %~1
call :PromptOperation
exit /b

:ListIfCategory
call :Meta %~1
if /I not "%T_CATEGORY%"=="%~2" exit /b
if /I "%T_MODE%"=="REG" call :DetectRegistry
if /I not "%T_MODE%"=="REG" call :DetectAction %T_ID%
echo   %T_ID%  [%T_RISK%]  %T_NAME%
echo             %T_CURRENT%
exit /b

:PromptOperation
 echo ----------------------------------------------------------------------------
echo   Enter an ID for full details, or B to return.
set "TSEL="
set /p "TSEL=Operation: "
if /I "%TSEL%"=="B" exit /b
if "%TSEL%"=="" exit /b
call :DispatchID "%TSEL%"
if not defined DISPATCHED (
 echo Unknown operation ID.
 timeout /t 2 >nul
)
set "DISPATCHED="
exit /b

:DispatchID
set "DISPATCHED="
if /I "%~1"=="WIN-0001" (set "DISPATCHED=1" & call :RunTweak WIN-0001 & exit /b)
if /I "%~1"=="WIN-0002" (set "DISPATCHED=1" & call :RunTweak WIN-0002 & exit /b)
if /I "%~1"=="WIN-0003" (set "DISPATCHED=1" & call :RunTweak WIN-0003 & exit /b)
if /I "%~1"=="WIN-0004" (set "DISPATCHED=1" & call :RunTweak WIN-0004 & exit /b)
if /I "%~1"=="GAME-0001" (set "DISPATCHED=1" & call :RunTweak GAME-0001 & exit /b)
if /I "%~1"=="GAME-0002" (set "DISPATCHED=1" & call :RunTweak GAME-0002 & exit /b)
if /I "%~1"=="GAME-0003" (set "DISPATCHED=1" & call :RunTweak GAME-0003 & exit /b)
if /I "%~1"=="INPUT-0001" (set "DISPATCHED=1" & call :RunTweak INPUT-0001 & exit /b)
if /I "%~1"=="INPUT-0002" (set "DISPATCHED=1" & call :RunTweak INPUT-0002 & exit /b)
if /I "%~1"=="INPUT-0003" (set "DISPATCHED=1" & call :RunTweak INPUT-0003 & exit /b)
if /I "%~1"=="CPU-0001" (set "DISPATCHED=1" & call :RunTweak CPU-0001 & exit /b)
if /I "%~1"=="GPU-0001" (set "DISPATCHED=1" & call :RunTweak GPU-0001 & exit /b)
if /I "%~1"=="RAM-0001" (set "DISPATCHED=1" & call :RunTweak RAM-0001 & exit /b)
if /I "%~1"=="RAM-0002" (set "DISPATCHED=1" & call :RunTweak RAM-0002 & exit /b)
if /I "%~1"=="STOR-0001" (set "DISPATCHED=1" & call :RunTweak STOR-0001 & exit /b)
if /I "%~1"=="STOR-0002" (set "DISPATCHED=1" & call :RunTweak STOR-0002 & exit /b)
if /I "%~1"=="STOR-0003" (set "DISPATCHED=1" & call :RunTweak STOR-0003 & exit /b)
if /I "%~1"=="STOR-0004" (set "DISPATCHED=1" & call :RunTweak STOR-0004 & exit /b)
if /I "%~1"=="PWR-0001" (set "DISPATCHED=1" & call :RunTweak PWR-0001 & exit /b)
if /I "%~1"=="PWR-0002" (set "DISPATCHED=1" & call :RunTweak PWR-0002 & exit /b)
if /I "%~1"=="PWR-0003" (set "DISPATCHED=1" & call :RunTweak PWR-0003 & exit /b)
if /I "%~1"=="NET-0001" (set "DISPATCHED=1" & call :RunTweak NET-0001 & exit /b)
if /I "%~1"=="NET-0002" (set "DISPATCHED=1" & call :RunTweak NET-0002 & exit /b)
if /I "%~1"=="NET-0003" (set "DISPATCHED=1" & call :RunTweak NET-0003 & exit /b)
if /I "%~1"=="NET-0004" (set "DISPATCHED=1" & call :RunTweak NET-0004 & exit /b)
if /I "%~1"=="START-0001" (set "DISPATCHED=1" & call :RunTweak START-0001 & exit /b)
if /I "%~1"=="START-0002" (set "DISPATCHED=1" & call :RunTweak START-0002 & exit /b)
if /I "%~1"=="SVC-0001" (set "DISPATCHED=1" & call :RunTweak SVC-0001 & exit /b)
if /I "%~1"=="SVC-0002" (set "DISPATCHED=1" & call :RunTweak SVC-0002 & exit /b)
if /I "%~1"=="TASK-0001" (set "DISPATCHED=1" & call :RunTweak TASK-0001 & exit /b)
if /I "%~1"=="TASK-0002" (set "DISPATCHED=1" & call :RunTweak TASK-0002 & exit /b)
if /I "%~1"=="UI-0001" (set "DISPATCHED=1" & call :RunTweak UI-0001 & exit /b)
if /I "%~1"=="UI-0002" (set "DISPATCHED=1" & call :RunTweak UI-0002 & exit /b)
if /I "%~1"=="UI-0003" (set "DISPATCHED=1" & call :RunTweak UI-0003 & exit /b)
if /I "%~1"=="UI-0004" (set "DISPATCHED=1" & call :RunTweak UI-0004 & exit /b)
if /I "%~1"=="UI-0005" (set "DISPATCHED=1" & call :RunTweak UI-0005 & exit /b)
if /I "%~1"=="UI-0006" (set "DISPATCHED=1" & call :RunTweak UI-0006 & exit /b)
if /I "%~1"=="PRIV-0001" (set "DISPATCHED=1" & call :RunTweak PRIV-0001 & exit /b)
if /I "%~1"=="PRIV-0002" (set "DISPATCHED=1" & call :RunTweak PRIV-0002 & exit /b)
if /I "%~1"=="PRIV-0003" (set "DISPATCHED=1" & call :RunTweak PRIV-0003 & exit /b)
if /I "%~1"=="PRIV-0004" (set "DISPATCHED=1" & call :RunTweak PRIV-0004 & exit /b)
if /I "%~1"=="PRIV-0005" (set "DISPATCHED=1" & call :RunTweak PRIV-0005 & exit /b)
if /I "%~1"=="CLEAN-0001" (set "DISPATCHED=1" & call :RunTweak CLEAN-0001 & exit /b)
if /I "%~1"=="CLEAN-0002" (set "DISPATCHED=1" & call :RunTweak CLEAN-0002 & exit /b)
if /I "%~1"=="CLEAN-0003" (set "DISPATCHED=1" & call :RunTweak CLEAN-0003 & exit /b)
if /I "%~1"=="CLEAN-0004" (set "DISPATCHED=1" & call :RunTweak CLEAN-0004 & exit /b)
if /I "%~1"=="DIAG-0001" (set "DISPATCHED=1" & call :RunTweak DIAG-0001 & exit /b)
if /I "%~1"=="DIAG-0002" (set "DISPATCHED=1" & call :RunTweak DIAG-0002 & exit /b)
if /I "%~1"=="DIAG-0003" (set "DISPATCHED=1" & call :RunTweak DIAG-0003 & exit /b)
if /I "%~1"=="DIAG-0004" (set "DISPATCHED=1" & call :RunTweak DIAG-0004 & exit /b)
if /I "%~1"=="DIAG-0005" (set "DISPATCHED=1" & call :RunTweak DIAG-0005 & exit /b)
if /I "%~1"=="DIAG-0006" (set "DISPATCHED=1" & call :RunTweak DIAG-0006 & exit /b)
if /I "%~1"=="DIAG-0007" (set "DISPATCHED=1" & call :RunTweak DIAG-0007 & exit /b)
if /I "%~1"=="REPAIR-0001" (set "DISPATCHED=1" & call :RunTweak REPAIR-0001 & exit /b)
if /I "%~1"=="REPAIR-0002" (set "DISPATCHED=1" & call :RunTweak REPAIR-0002 & exit /b)
if /I "%~1"=="REPAIR-0003" (set "DISPATCHED=1" & call :RunTweak REPAIR-0003 & exit /b)
if /I "%~1"=="REPAIR-0004" (set "DISPATCHED=1" & call :RunTweak REPAIR-0004 & exit /b)
if /I "%~1"=="REPAIR-0005" (set "DISPATCHED=1" & call :RunTweak REPAIR-0005 & exit /b)
if /I "%~1"=="REPAIR-0006" (set "DISPATCHED=1" & call :RunTweak REPAIR-0006 & exit /b)
exit /b

:RunTweak
call :Meta %~1
if errorlevel 1 (
 echo Unknown operation.
 exit /b 1
)
call :CheckCompatibility
if errorlevel 1 (
 echo.
 echo [UNSUPPORTED] %T_ID% is not supported on this installation.
 echo Requirement: %T_SUPPORT% ^| Current build: %OS_BUILD%
 call :Log "%T_ID% skipped: compatibility check failed."
 pause
 exit /b 1
)
call :CheckDependencies
if errorlevel 1 (
 echo.
 echo [DEPENDENCY REQUIRED] %T_ID% cannot run because a declared prerequisite is unavailable.
 echo Dependencies: %T_DEPENDENCIES%
 call :Log "%T_ID% skipped: dependency check failed."
 pause
 exit /b 1
)
call :CheckConflicts
if errorlevel 1 (
 echo.
 echo [CONFLICT] A known configuration conflict prevented %T_ID%.
 echo Conflicts: %T_CONFLICTS%
 call :Log "%T_ID% skipped: conflict check failed."
 pause
 exit /b 1
)
if /I "%T_MODE%"=="REG" (call :DetectRegistry) else (call :DetectAction %T_ID%)
if /I "%T_ID%"=="SVC-0002" call :PrepareServiceChoice
if /I "%T_ID%"=="SVC-0002" if errorlevel 1 exit /b 1
call :ShowTweak
if /I not "%PROFILE_MODE%"=="1" (
 echo.
 choice /c AC /n /m "A=apply or run; C=cancel"
 if errorlevel 2 (
  call :Log "%T_ID% cancelled by user."
  exit /b 0
 )
)
if /I "%T_MODE%"=="REG" (
 call :BackupRegistry
 if errorlevel 1 goto :TweakBackupFailed
 call :ApplyRegistry
 if errorlevel 1 goto :TweakApplyFailed
 call :ValidateRegistry
 if errorlevel 1 goto :TweakValidateFailed
) else (
 call :BackupAction %T_ID%
 if errorlevel 1 goto :TweakBackupFailed
 call :ApplyAction %T_ID%
 if errorlevel 1 goto :TweakApplyFailed
 call :ValidateAction %T_ID%
 if errorlevel 1 goto :TweakValidateFailed
)
echo.
echo [VALIDATED] %T_ID% completed.
if /I "%T_RESTART%"=="Yes" echo Restart Windows before expecting this setting to take effect.
call :Log "%T_ID% completed and validation passed."
if /I not "%PROFILE_MODE%"=="1" pause
exit /b 0
:TweakBackupFailed
echo.
echo [FAILED] Backup could not be created. No change was attempted.
call :Log "%T_ID% failed: backup error."
if /I not "%PROFILE_MODE%"=="1" pause
exit /b 1
:TweakApplyFailed
echo.
echo [FAILED] Windows did not accept the requested operation. Validation was not claimed.
call :Log "%T_ID% failed: apply/run returned an error."
if /I not "%PROFILE_MODE%"=="1" pause
exit /b 1
:TweakValidateFailed
echo.
echo [FAILED] Validation did not confirm the requested result.
call :Log "%T_ID% failed: validation error."
if /I not "%PROFILE_MODE%"=="1" pause
exit /b 1

:ShowTweak
echo.
echo ============================================================================
echo   %T_ID% - %T_NAME%
echo ============================================================================
echo Category       : %T_CATEGORY% / %T_SUBCATEGORY%
echo Risk           : %T_RISK%
echo Supported      : %T_SUPPORT%
echo Hardware       : %T_HARDWARE%
echo Current state  : %T_CURRENT%
echo Proposed       : %T_CHANGE%
echo Why it may help: %T_WHY%
echo Backup         : %T_BACKUP%
echo Apply          : %T_APPLY%
echo Validation     : %T_VALIDATE%
echo Revert         : %T_REVERT%
echo Dependencies   : %T_DEPENDENCIES%
echo Conflicts      : %T_CONFLICTS%
echo Error handling : %T_ERROR%
if /I "%T_RISK%"=="ADVANCED" echo WARNING: This is an advanced change. Read the proposed change carefully.
if /I "%T_RISK%"=="EXPERIMENTAL" echo WARNING: This is experimental/high-impact. It is not a performance promise.
echo ============================================================================
exit /b 0

:CheckCompatibility
if "%OS_BUILD%"=="0" exit /b 1
if /I "%OS_INSTALLATION%"=="Server" exit /b 1
set /a _buildcheck=%OS_BUILD% 2>nul
if %_buildcheck% LSS %T_MINBUILD% exit /b 1
exit /b 0

:CheckDependencies
if /I "%T_DEPENDENCIES%"=="None" exit /b 0
if /I "%IS_ADMIN%"=="YES" goto :CheckDependencyStorage
exit /b 1
:CheckDependencyStorage
echo %T_DEPENDENCIES% | findstr /I /C:"C: available" >nul
if not errorlevel 1 if not exist C:\ exit /b 1
echo %T_DEPENDENCIES% | findstr /I /C:"Task Scheduler" >nul
if errorlevel 1 goto :CheckDependencyPowerShell
sc query Schedule >nul 2>&1
if errorlevel 1 exit /b 1
:CheckDependencyPowerShell
echo %T_DEPENDENCIES% | findstr /I /C:"PowerShell" >nul
if errorlevel 1 goto :CheckDependenciesReady
where powershell.exe >nul 2>&1
if errorlevel 1 exit /b 1
:CheckDependenciesReady
exit /b 0

:CheckConflicts
rem v1.1.0 exposes all known trade-offs in metadata; no automatic pair conflict exists.
rem New incompatible pairs must be checked here before application.
exit /b 0

:DetectRegistry
set "T_EXISTS=0"
set "T_OLD_TYPE="
set "T_OLD_VALUE="
set "T_READ="
for /f "tokens=1,2,*" %%A in ('reg query "%T_KEY%" /v "%T_VALUE%" 2^>nul ^| findstr /I /C:"%T_VALUE%"') do (
 set "T_EXISTS=1"
 set "T_OLD_TYPE=%%B"
 set "T_OLD_VALUE=%%C"
)
if "%T_EXISTS%"=="0" (
 set "T_CURRENT=Not configured"
 exit /b 0
)
for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "$v=Get-ItemPropertyValue -LiteralPath 'Registry::%T_KEY%' -Name '%T_VALUE%' -ErrorAction Stop; [string]$v" 2^>nul`) do set "T_READ=%%A"
if "%T_READ%"=="%T_NEW%" (
 set "T_CURRENT=[ALREADY APPLIED] %T_VALUE% is %T_NEW%"
) else (
 set "T_CURRENT=Configured as %T_READ%"
)
exit /b 0

:BackupRegistry
call :MakeStamp
set "T_BACKUP_FILE=%BACKUPDIR%\%T_ID%_%STAMP%.reg"
reg export "%T_KEY%" "%T_BACKUP_FILE%" /y >nul 2>&1
if not errorlevel 1 goto :BackupRegistryRecorded
reg query "%T_KEY%" >nul 2>&1
if not errorlevel 1 exit /b 1
>"%T_BACKUP_FILE%" echo ADEX note: registry key did not exist before %T_ID%; no .reg export was possible.
:BackupRegistryRecorded
>>"%UNDOLOG%" echo %T_ID%^|REG^|%T_KEY%^|%T_VALUE%^|%T_EXISTS%^|%T_OLD_TYPE%^|%T_OLD_VALUE%^|%T_BACKUP_FILE%^|%STAMP%
call :Log "%T_ID% registry backup created: %T_BACKUP_FILE%"
exit /b 0

:ApplyRegistry
if /I "%T_CURRENT:~0,17%"=="[ALREADY APPLIED]" (
 echo [ALREADY APPLIED] No registry write was needed.
 exit /b 0
)
reg add "%T_KEY%" /v "%T_VALUE%" /t "%T_REGTYPE%" /d "%T_NEW%" /f >nul 2>&1
exit /b

:ValidateRegistry
set "T_READ="
for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "$v=Get-ItemPropertyValue -LiteralPath 'Registry::%T_KEY%' -Name '%T_VALUE%' -ErrorAction Stop; [string]$v" 2^>nul`) do set "T_READ=%%A"
if "%T_READ%"=="%T_NEW%" exit /b 0
exit /b 1

:DetectAction
set "T_CURRENT=Ready to run on demand"
if /I "%~1"=="PWR-0001" call :DetectActivePower
if /I "%~1"=="PWR-0003" call :DetectHibernation
if /I "%~1"=="CLEAN-0001" set "T_CURRENT=Preview required: %TEMP%"
if /I "%~1"=="CLEAN-0002" set "T_CURRENT=Preview required: %WINDIR%\Temp"
if /I "%~1"=="CLEAN-0003" set "T_CURRENT=Preview required: %LOCALAPPDATA%\D3DSCache"
if /I "%~1"=="CLEAN-0004" set "T_CURRENT=Preview required: Recycle Bin"
exit /b 0

:DetectActivePower
set "ACTIVE_POWER="
for /f "tokens=3" %%A in ('powercfg /getactivescheme 2^>nul') do set "ACTIVE_POWER=%%A"
if defined ACTIVE_POWER set "T_CURRENT=Active scheme GUID: %ACTIVE_POWER%"
exit /b 0

:DetectHibernation
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v HibernateEnabled 2>nul | findstr /I "0x1" >nul
if not errorlevel 1 set "T_CURRENT=Hibernation is enabled"
if errorlevel 1 set "T_CURRENT=Hibernation is disabled or unavailable"
exit /b 0

:BackupAction
if /I "%~1"=="PWR-0001" goto :BackupPowerPlan
if /I "%~1"=="PWR-0003" goto :BackupHibernation
if /I "%~1"=="SVC-0002" call :BackupServiceChoice
if errorlevel 1 exit /b 1
exit /b 0

:BackupPowerPlan
set "PREVIOUS_POWER="
for /f "tokens=3" %%A in ('powercfg /getactivescheme 2^>nul') do set "PREVIOUS_POWER=%%A"
if not defined PREVIOUS_POWER exit /b 1
call :MakeStamp
>>"%UNDOLOG%" echo PWR-0001^|POWER^|%PREVIOUS_POWER%^|^|^|^|^|^|%STAMP%
call :Log "PWR-0001 saved active scheme %PREVIOUS_POWER%."
exit /b 0

:BackupHibernation
set "HIBER_OLD=0"
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v HibernateEnabled 2>nul | findstr /I "0x1" >nul && set "HIBER_OLD=1"
call :MakeStamp
>>"%UNDOLOG%" echo PWR-0003^|HIBER^|%HIBER_OLD%^|^|^|^|^|^|%STAMP%
call :Log "PWR-0003 recorded hibernation state %HIBER_OLD%."
exit /b 0

:ApplyAction
if /I "%~1"=="CPU-0001" goto :ActionCpuInspect
if /I "%~1"=="RAM-0001" goto :ActionMemoryInspect
if /I "%~1"=="RAM-0002" goto :ActionMemoryDiagnostic
if /I "%~1"=="STOR-0001" goto :ActionTrimCheck
if /I "%~1"=="STOR-0002" goto :ActionOptimizeVolume
if /I "%~1"=="STOR-0003" goto :ActionSmartCheck
if /I "%~1"=="STOR-0004" goto :ActionCheckDisk
if /I "%~1"=="PWR-0001" goto :ActionPowerHighPerformance
if /I "%~1"=="PWR-0002" goto :ActionPowerCapabilities
if /I "%~1"=="PWR-0003" goto :ActionHibernateOff
if /I "%~1"=="NET-0001" goto :ActionFlushDns
if /I "%~1"=="NET-0002" goto :ActionNetworkConfig
if /I "%~1"=="NET-0003" goto :ActionNetworkTest
if /I "%~1"=="NET-0004" goto :ActionNetworkReport
if /I "%~1"=="START-0001" goto :ActionStartupInventory
if /I "%~1"=="START-0002" goto :ActionStartupTasks
if /I "%~1"=="SVC-0001" goto :ActionServiceInspect
if /I "%~1"=="SVC-0002" goto :ActionServiceConfigure
if /I "%~1"=="TASK-0001" goto :ActionTaskInventory
if /I "%~1"=="TASK-0002" goto :ActionTaskExport
if /I "%~1"=="CLEAN-0001" goto :ActionCleanUserTemp
if /I "%~1"=="CLEAN-0002" goto :ActionCleanWindowsTemp
if /I "%~1"=="CLEAN-0003" goto :ActionCleanShaderCache
if /I "%~1"=="CLEAN-0004" goto :ActionCleanRecycleBin
if /I "%~1"=="DIAG-0001" goto :ActionSystemSummary
if /I "%~1"=="DIAG-0002" goto :ActionComponentCheck
if /I "%~1"=="DIAG-0003" goto :ActionSfcVerify
if /I "%~1"=="DIAG-0004" goto :ActionRecentEvents
if /I "%~1"=="DIAG-0005" goto :ActionDriverList
if /I "%~1"=="DIAG-0006" goto :ActionBatteryReport
if /I "%~1"=="DIAG-0007" goto :ActionStutterDiagnostics
if /I "%~1"=="REPAIR-0001" goto :ActionComponentScan
if /I "%~1"=="REPAIR-0002" goto :ActionComponentRepair
if /I "%~1"=="REPAIR-0003" goto :ActionSfcRepair
if /I "%~1"=="REPAIR-0004" goto :ActionWinsockReset
if /I "%~1"=="REPAIR-0005" goto :ActionIpReset
if /I "%~1"=="REPAIR-0006" goto :ActionFirewallReset
echo No action handler is available.
exit /b 1

:ActionCpuInspect
powercfg /q SCHEME_CURRENT SUB_PROCESSOR
goto :ReturnActionResult
:ActionMemoryInspect
powershell -NoProfile -Command "Get-CimInstance Win32_ComputerSystem | Select-Object AutomaticManagedPagefile; Get-CimInstance Win32_PageFileSetting | Format-Table Name,InitialSize,MaximumSize -AutoSize"
goto :ReturnActionResult
:ActionMemoryDiagnostic
start "Windows Memory Diagnostic" mdsched.exe
goto :ReturnActionResult
:ActionTrimCheck
fsutil behavior query DisableDeleteNotify
goto :ReturnActionResult
:ActionOptimizeVolume
defrag C: /O /U /V
goto :ReturnActionResult
:ActionSmartCheck
powershell -NoProfile -Command "Get-CimInstance -Namespace root\wmi -ClassName MSStorageDriver_FailurePredictStatus -ErrorAction SilentlyContinue | Select-Object InstanceName,PredictFailure,Reason | Format-Table -AutoSize; if(-not (Get-CimInstance -Namespace root\wmi -ClassName MSStorageDriver_FailurePredictStatus -ErrorAction SilentlyContinue)){Write-Host 'No compatible SMART prediction data was exposed.'}"
goto :ReturnActionResult
:ActionCheckDisk
chkdsk C:
goto :ReturnActionResult
:ActionPowerHighPerformance
powercfg /setactive SCHEME_MIN
goto :ReturnActionResult
:ActionPowerCapabilities
powercfg /a
goto :ReturnActionResult
:ActionHibernateOff
powercfg /hibernate off
goto :ReturnActionResult
:ActionFlushDns
ipconfig /flushdns
goto :ReturnActionResult
:ActionNetworkConfig
ipconfig /all
goto :ReturnActionResult
:ActionNetworkTest
powershell -NoProfile -Command "Resolve-DnsName www.microsoft.com -ErrorAction Continue | Select-Object -First 3; Test-NetConnection www.microsoft.com -InformationLevel Detailed"
goto :ReturnActionResult
:ActionStartupInventory
call :StartupReport
goto :ReturnActionResult
:ActionStartupTasks
powershell -NoProfile -Command "Get-ScheduledTask -ErrorAction Stop | Where-Object {$_.Triggers.CimClass.CimClassName -match 'Task(Logon|Boot)Trigger'} | Select-Object TaskName,TaskPath,State | Format-Table -AutoSize"
goto :ReturnActionResult
:ActionServiceInspect
call :InspectService
goto :ReturnActionResult
:ActionServiceConfigure
call :ApplyServiceChoice
goto :ReturnActionResult
:ActionTaskInventory
schtasks /query /fo TABLE /nh
goto :ReturnActionResult
:ActionTaskExport
call :ExportTask
goto :ReturnActionResult
:ActionCleanUserTemp
call :CleanFolder "%TEMP%" "user TEMP"
goto :ReturnActionResult
:ActionCleanWindowsTemp
call :CleanFolder "%WINDIR%\Temp" "Windows Temp"
goto :ReturnActionResult
:ActionCleanShaderCache
call :CleanFolder "%LOCALAPPDATA%\D3DSCache" "DirectX shader cache"
goto :ReturnActionResult
:ActionCleanRecycleBin
call :CleanRecycleBin
goto :ReturnActionResult
:ActionSystemSummary
powershell -NoProfile -Command "Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,BuildNumber,OSArchitecture; Get-CimInstance Win32_Processor | Select-Object -First 1 Name,NumberOfCores,NumberOfLogicalProcessors; Get-CimInstance Win32_VideoController | Select-Object Name,DriverVersion; Get-CimInstance Win32_ComputerSystem | Select-Object @{n='MemoryGB';e={[math]::Round($_.TotalPhysicalMemory/1GB,1)}} | Format-List"
goto :ReturnActionResult
:ActionComponentCheck
DISM /Online /Cleanup-Image /CheckHealth
goto :ReturnActionResult
:ActionSfcVerify
sfc /verifyonly
goto :ReturnActionResult
:ActionRecentEvents
powershell -NoProfile -Command "Get-WinEvent -FilterHashtable @{LogName='System';Level=2;StartTime=(Get-Date).AddDays(-1)} -MaxEvents 25 -ErrorAction SilentlyContinue | Select-Object TimeCreated,ProviderName,Id,LevelDisplayName,Message | Format-Table -Wrap -AutoSize"
goto :ReturnActionResult
:ActionDriverList
driverquery /fo table
goto :ReturnActionResult
:ActionComponentScan
DISM /Online /Cleanup-Image /ScanHealth
goto :ReturnActionResult
:ActionComponentRepair
DISM /Online /Cleanup-Image /RestoreHealth
goto :ReturnActionResult
:ActionSfcRepair
sfc /scannow
goto :ReturnActionResult
:ActionWinsockReset
netsh winsock reset
goto :ReturnActionResult
:ActionIpReset
netsh int ip reset
goto :ReturnActionResult
:ActionFirewallReset
echo WARNING: This removes custom Windows Firewall rules.
choice /c YN /n /m "Confirm Windows Firewall policy reset"
if errorlevel 2 exit /b 1
netsh advfirewall reset
goto :ReturnActionResult

:ActionStutterDiagnostics
call :MakeStamp
set "STUTTER_REPORT=%REPORTDIR%\stutter_diagnostics_%STAMP%.txt"
powershell -NoProfile -Command "$out=$env:STUTTER_REPORT; & {$findings=@(); Write-Output 'ADEX Windows Stutter Diagnostics'; Write-Output ('Generated: '+(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')); Write-Output ''; $os=Get-CimInstance Win32_OperatingSystem; $cs=Get-CimInstance Win32_ComputerSystem; $uptime=(Get-Date)-$os.LastBootUpTime; Write-Output ('Windows: {0} {1} build {2}' -f $os.Caption,$os.Version,$os.BuildNumber); Write-Output ('Uptime: {0:dd}d {0:hh}h {0:mm}m' -f $uptime); $cpuSample=Get-CimInstance Win32_PerfFormattedData_PerfOS_Processor -ErrorAction SilentlyContinue | Where-Object {$_.Name -eq '_Total'}; if($cpuSample){$cpuLoad=[math]::Round($cpuSample.PercentProcessorTime,1); Write-Output ('CPU utilization sample: {0} percent' -f $cpuLoad); if($cpuLoad -ge 90){$findings+='High CPU utilization was sampled. Identify the active workload before changing settings.'}}else{Write-Output 'CPU utilization sample: unavailable'}; $totalMB=[math]::Round($cs.TotalPhysicalMemory/1MB,0); $freeMB=[math]::Round($os.FreePhysicalMemory/1KB,0); $freePct=[math]::Round(($freeMB/$totalMB)*100,1); Write-Output ('Memory: {0} MB available of {1} MB ({2} percent free)' -f $freeMB,$totalMB,$freePct); if($freePct -lt 10){$findings+='Low available physical memory was sampled; memory pressure can contribute to interruptions.'}; $disk=Get-CimInstance Win32_PerfFormattedData_PerfDisk_PhysicalDisk -ErrorAction SilentlyContinue | Where-Object {$_.Name -eq '_Total'}; if($disk){$diskBusy=[math]::Round($disk.PercentDiskTime,1); $diskRate=[math]::Round($disk.DiskBytesPersec/1MB,2); Write-Output ('Disk activity sample: {0} percent busy, {1} MB/s' -f $diskBusy,$diskRate); if($diskBusy -ge 90){$findings+='High aggregate disk busy time was sampled. Check the active disk workload.'}}else{Write-Output 'Disk activity sample: unavailable'}; $plan=(powercfg /getactivescheme 2>$null) -join ' '; Write-Output ('Power plan: '+$plan); $hags=(Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -Name HwSchMode -ErrorAction SilentlyContinue).HwSchMode; $hagsText=switch($hags){2{'Enabled'};1{'Disabled'};0{'Default'};default{'Not configured or unavailable'}}; Write-Output ('Hardware-accelerated GPU scheduling: '+$hagsText); $gm=(Get-ItemProperty -Path 'HKCU:\Software\Microsoft\GameBar' -Name AutoGameModeEnabled -ErrorAction SilentlyContinue).AutoGameModeEnabled; $dvr=(Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR' -Name AppCaptureEnabled -ErrorAction SilentlyContinue).AppCaptureEnabled; Write-Output ('Game Mode preference: '+$(if($gm -eq 1){'Enabled'}elseif($null -eq $gm){'Not configured'}else{'Disabled'})); Write-Output ('Background game capture preference: '+$(if($dvr -eq 1){'Enabled'}elseif($null -eq $dvr){'Not configured'}else{'Disabled'})); $autoPage=(Get-CimInstance Win32_ComputerSystem).AutomaticManagedPagefile; Write-Output ('Automatic page-file management: '+$autoPage); Write-Output ''; Write-Output 'GPU and driver indicators:'; Get-CimInstance Win32_VideoController | Select-Object Name,DriverVersion,AdapterRAM | Format-Table -AutoSize; try{$gpuSamples=Get-Counter '\GPU Engine(*)\Utilization Percentage' -ErrorAction Stop | Select-Object -ExpandProperty CounterSamples | Where-Object {$_.CookedValue -gt 0} | Sort-Object CookedValue -Descending | Select-Object -First 5; if($gpuSamples){Write-Output 'Active GPU-engine samples:'; $gpuSamples | ForEach-Object {Write-Output ('  {0}: {1:N1} percent' -f $_.InstanceName,$_.CookedValue)}}else{Write-Output 'Active GPU-engine samples: none at this sample'}}catch{Write-Output 'GPU-engine utilization samples: unavailable'}; Write-Output ''; $runCount=0; foreach($path in @('HKCU:\Software\Microsoft\Windows\CurrentVersion\Run','HKLM:\Software\Microsoft\Windows\CurrentVersion\Run','HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run')){if(Test-Path $path){$runCount+=@((Get-ItemProperty -Path $path).PSObject.Properties | Where-Object {$_.Name -notmatch '^PS'}).Count}}; try{$taskCount=@(Get-ScheduledTask -ErrorAction Stop | Where-Object {$_.Triggers.CimClass.CimClassName -match 'Task(Logon|Boot)Trigger'}).Count}catch{$taskCount='unavailable'}; Write-Output ('Startup indicators: {0} Run values; {1} logon or boot tasks' -f $runCount,$taskCount); Write-Output 'Top processes by accumulated CPU time (not instantaneous CPU):'; Get-Process -ErrorAction SilentlyContinue | Sort-Object CPU -Descending | Select-Object -First 8 ProcessName,Id,@{n='CPUSeconds';e={[math]::Round($_.CPU,1)}},@{n='WorkingSetMB';e={[math]::Round($_.WorkingSet64/1MB,1)}} | Format-Table -AutoSize; Write-Output ''; if($findings.Count -gt 0){Write-Output 'Indicators to investigate:'; $findings | ForEach-Object {Write-Output ('- '+$_)}}else{Write-Output 'No high-threshold CPU, memory, or disk indicator was sampled at this instant.'}; Write-Output ''; Write-Output 'Interpretation: this read-only snapshot identifies possible configuration and load indicators. It does not prove a root cause and does not apply stutter fixes.'} | Tee-Object -FilePath $out"
if errorlevel 1 exit /b %errorlevel%
if not exist "%STUTTER_REPORT%" exit /b 1
echo Stutter diagnostics report saved: %STUTTER_REPORT%
call :Log "DIAG-0007 stutter diagnostics report created: %STUTTER_REPORT%"
exit /b 0

:ReturnActionResult
exit /b %errorlevel%

:ActionNetworkReport
call :MakeStamp
set "NETREPORT=%REPORTDIR%\network_%STAMP%.txt"
(echo ADEX network report %STAMP%& ipconfig /all& powershell -NoProfile -Command "Get-NetAdapter | Format-Table Name,Status,LinkSpeed,MacAddress -AutoSize") > "%NETREPORT%"
if not exist "%NETREPORT%" exit /b 1
echo Report written: %NETREPORT%
exit /b 0

:ActionBatteryReport
call :MakeStamp
powercfg /batteryreport /output "%REPORTDIR%\battery_%STAMP%.html"
exit /b

:ValidateAction
if /I "%~1"=="PWR-0001" goto :ValidatePowerPlan
if /I "%~1"=="PWR-0003" goto :ValidateHibernation
if /I "%~1"=="SVC-0002" goto :ValidateSelectedService
rem Read-only, diagnostic, cleanup, and repair commands are validated by native exit code.
exit /b 0

:ValidatePowerPlan
powercfg /getactivescheme | findstr /I "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" >nul
goto :ReturnValidationResult

:ValidateHibernation
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v HibernateEnabled 2>nul | findstr /I "0x0" >nul
goto :ReturnValidationResult

:ValidateSelectedService
call :ValidateServiceChoice
goto :ReturnValidationResult

:ReturnValidationResult
exit /b %errorlevel%

:CleanRecycleBin
powershell -NoProfile -Command "$x=Get-PSDrive -PSProvider FileSystem | ForEach-Object {Get-ChildItem -LiteralPath ($_.Root+'$Recycle.Bin') -Force -ErrorAction SilentlyContinue}; $s=($x | Measure-Object -Property Length -Sum).Sum; Write-Host ('Preview Recycle Bin: {0:N2} MB' -f ($s/1MB))"
choice /c YN /n /m "Irreversibly empty the Recycle Bin"
if errorlevel 2 exit /b 1
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction Stop"
exit /b

:CleanFolder
set "CLEAN_PATH=%~1"
set "CLEAN_LABEL=%~2"
echo.
powershell -NoProfile -Command "$p=$env:CLEAN_PATH; if(Test-Path -LiteralPath $p){$x=Get-ChildItem -LiteralPath $p -Force -ErrorAction SilentlyContinue; $s=($x | Measure-Object -Property Length -Sum).Sum; Write-Host ('Preview '+$env:CLEAN_LABEL+': {0} items, {1:N2} MB' -f @($x).Count,($s/1MB))}else{Write-Host 'Folder does not exist.'}" 
choice /c YN /n /m "Irreversible delete of deletable items from this location"
if errorlevel 2 exit /b 1
powershell -NoProfile -Command "$p=$env:CLEAN_PATH; if(-not (Test-Path -LiteralPath $p)){exit 0}; $errs=@(); Get-ChildItem -LiteralPath $p -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue -ErrorVariable +errs; $remaining=@(Get-ChildItem -LiteralPath $p -Force -ErrorAction SilentlyContinue).Count; Write-Host ('Cleanup remaining items: {0}' -f $remaining); if($errs.Count -gt 0){exit 1}else{exit 0}"
exit /b

:StartupReport
echo.
echo === Registry Run locations ===
for %%K in ("HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run") do (
 echo --- %%~K
 reg query "%%~K" 2>nul
)
echo.
echo === Startup folders ===
echo User: %APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
dir /b "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup" 2>nul
echo Common: %ProgramData%\Microsoft\Windows\Start Menu\Programs\StartUp
dir /b "%ProgramData%\Microsoft\Windows\Start Menu\Programs\StartUp" 2>nul
exit /b 0

:InspectService
set "SERVICE_NAME="
set /p "SERVICE_NAME=Service name (not display name): "
if "%SERVICE_NAME%"=="" exit /b 1
sc query "%SERVICE_NAME%" >nul 2>&1
if errorlevel 1 (
 echo Service was not found.
 exit /b 1
)
echo.
sc query "%SERVICE_NAME%"
sc qc "%SERVICE_NAME%"
echo Dependencies:
sc enumdepend "%SERVICE_NAME%"
exit /b 0

:PrepareServiceChoice
set "SERVICE_NAME="
set "SERVICE_NEW_START="
set "SERVICE_OLD_START="
set "SERVICE_OLD_STATE="
set /p "SERVICE_NAME=Service name to configure (Manual or Automatic only): "
if "%SERVICE_NAME%"=="" exit /b 1
call :IsProtectedService "%SERVICE_NAME%"
if "%PROTECTED_SERVICE%"=="1" (
 echo This protected service cannot be changed by ADEX.
 exit /b 1
)
sc qc "%SERVICE_NAME%" >nul 2>&1
if errorlevel 1 (
 echo Service was not found.
 exit /b 1
)
for /f "tokens=3" %%A in ('sc qc "%SERVICE_NAME%" ^| findstr /I "START_TYPE"') do set "SERVICE_OLD_START=%%A"
for /f "tokens=4" %%A in ('sc query "%SERVICE_NAME%" ^| findstr /I "STATE"') do set "SERVICE_OLD_STATE=%%A"
if not defined SERVICE_OLD_START exit /b 1
echo.
echo Current startup code: %SERVICE_OLD_START%  Current state: %SERVICE_OLD_STATE%
echo Dependent services:
sc enumdepend "%SERVICE_NAME%"
choice /c MAC /n /m "M=Manual, A=Automatic, C=Cancel"
if errorlevel 3 exit /b 1
if errorlevel 2 set "SERVICE_NEW_START=auto"
if errorlevel 1 if not errorlevel 2 set "SERVICE_NEW_START=demand"
if not defined SERVICE_NEW_START exit /b 1
set "T_CURRENT=Service %SERVICE_NAME% startup code %SERVICE_OLD_START%; state %SERVICE_OLD_STATE%"
set "T_CHANGE=Set service %SERVICE_NAME% startup to %SERVICE_NEW_START%"
set "T_BACKUP=Captured service startup type and running state"
exit /b 0

:BackupServiceChoice
if not defined SERVICE_NAME exit /b 1
if not defined SERVICE_NEW_START exit /b 1
call :MakeStamp
>>"%UNDOLOG%" echo SVC-0002^|SERVICE^|%SERVICE_NAME%^|%SERVICE_OLD_START%^|%SERVICE_OLD_STATE%^|^|^|^|%STAMP%
call :Log "SVC-0002 saved service state for %SERVICE_NAME%."
exit /b 0

:ApplyServiceChoice
sc config "%SERVICE_NAME%" start= %SERVICE_NEW_START% >nul
exit /b

:ValidateServiceChoice
if /I "%SERVICE_NEW_START%"=="auto" set "SERVICE_EXPECT=2"
if /I "%SERVICE_NEW_START%"=="demand" set "SERVICE_EXPECT=3"
sc qc "%SERVICE_NAME%" | findstr /R /C:"START_TYPE.*%SERVICE_EXPECT%" >nul
exit /b

:IsProtectedService
set "PROTECTED_SERVICE=0"
for %%S in (RpcSs DcomLaunch PlugPlay EventLog WinDefend SecurityHealthService wuauserv BITS CryptSvc Schedule TrustedInstaller) do if /I "%~1"=="%%S" set "PROTECTED_SERVICE=1"
exit /b 0

:ExportTask
set "TASK_NAME="
set /p "TASK_NAME=Full task path (example: \Microsoft\Windows\...): "
if "%TASK_NAME%"=="" exit /b 1
call :MakeStamp
set "TASKBACKUP=%BACKUPDIR%\task_%STAMP%.xml"
schtasks /query /tn "%TASK_NAME%" /xml > "%TASKBACKUP%"
if not errorlevel 1 goto :TaskExportSucceeded
del /q "%TASKBACKUP%" >nul 2>&1
exit /b 1
:TaskExportSucceeded
echo Task XML exported to: %TASKBACKUP%
exit /b 0

:BackupMenu
call :Header
echo   Backup and Windows System Restore
 echo ----------------------------------------------------------------------------
echo   ADEX creates value-level backups automatically for reversible changes.
echo   Windows restore points can help restore system files, registry, and drivers,
echo   but are not a complete backup and cannot guarantee recovery of personal data.
echo.
echo   [1] Create Windows restore point now
 echo   [2] Open ADEX backup folder
 echo   [3] Show ADEX backup records
 echo   [B] Back
set "BM="
set /p "BM=Select: "
if /I "%BM%"=="1" call :CreateRestorePoint
if /I "%BM%"=="2" start "ADEX backups" "%BACKUPDIR%"
if /I "%BM%"=="3" type "%UNDOLOG%" & pause
exit /b

:CreateRestorePoint
call :Header
echo A restore point is a Windows snapshot facility. It may restore system settings,
echo registry state, and drivers, but it is not a substitute for file backups.
choice /c YN /n /m "Create a restore point"
if errorlevel 2 exit /b
call :MakeStamp
powershell -NoProfile -Command "Checkpoint-Computer -Description 'ADEX %STAMP%' -RestorePointType MODIFY_SETTINGS" 
if errorlevel 1 (
 echo Windows did not create a restore point. It may be disabled, unavailable, or rate-limited.
 call :Log "Restore point request failed."
) else (
 echo Restore point request completed.
 call :Log "Restore point requested."
)
pause
exit /b

:UndoMenu
call :Header
echo   Undo Manager
 echo ----------------------------------------------------------------------------
echo   Backups are retained in ADEX-data. Undo restores the last captured state
 echo   for a selected reversible ADEX operation; it never restores generic defaults.
echo.
echo   [1] Undo one registry, power, hibernation, or service operation by ID
 echo   [2] Restore the most recently applied ADEX profile
 echo   [3] View recorded backup operations
 echo   [B] Back
set "UM="
set /p "UM=Select: "
if /I "%UM%"=="1" call :UndoOne
if /I "%UM%"=="2" call :UndoLatestProfile
if /I "%UM%"=="3" type "%UNDOLOG%" & pause
exit /b

:UndoOne
set "UNDO_ID="
set /p "UNDO_ID=Operation ID to revert: "
if "%UNDO_ID%"=="" exit /b
set "UNDO_LINE="
for /f "usebackq tokens=1-9 delims=|" %%A in ("%UNDOLOG%") do (
 if /I "%%A"=="%UNDO_ID%" if /I not "%%B"=="UNDO" set "UNDO_LINE=%%A|%%B|%%C|%%D|%%E|%%F|%%G|%%H|%%I"
)
if not defined UNDO_LINE (
 echo No reversible ADEX backup record was found for that ID.
 pause
 exit /b
)
for /f "tokens=1-9 delims=|" %%A in ("%UNDO_LINE%") do (
 set "UNDO_TYPE=%%B"
 set "UNDO_A=%%C"
 set "UNDO_B=%%D"
 set "UNDO_C=%%E"
 set "UNDO_D=%%F"
 set "UNDO_E=%%G"
)
echo.
echo Latest backup record: %UNDO_LINE%
choice /c YN /n /m "Restore this captured state"
if errorlevel 2 exit /b
if /I "%UNDO_TYPE%"=="REG" call :UndoRegistry
if /I "%UNDO_TYPE%"=="POWER" call :UndoPower
if /I "%UNDO_TYPE%"=="HIBER" call :UndoHiber
if /I "%UNDO_TYPE%"=="SERVICE" call :UndoService
if errorlevel 1 goto :UndoOneFailed
goto :UndoOneSucceeded
:UndoOneFailed
echo Undo did not validate. Review the log and backup file.
call :Log "%UNDO_ID% undo failed."
pause
exit /b 1
:UndoOneSucceeded
echo [VALIDATED] Previous state restored.
call :MakeStamp
>>"%UNDOLOG%" echo %UNDO_ID%^|UNDO^|%UNDO_TYPE%^|%STAMP%
call :Log "%UNDO_ID% undo completed."
pause
exit /b 0

:UndoRegistry
set "UKEY=%UNDO_A%"
set "UVAL=%UNDO_B%"
set "U_EXISTS=%UNDO_C%"
set "U_TYPE=%UNDO_D%"
set "U_DATA=%UNDO_E%"
if "%U_EXISTS%"=="1" goto :UndoRegistryExisting
goto :UndoRegistryAbsent

:UndoRegistryExisting
call :UndoRegistryValueMatches
if not errorlevel 1 (
 echo [ALREADY REVERTED] Captured registry value is already present.
 exit /b 0
)
reg add "%UKEY%" /v "%UVAL%" /t "%U_TYPE%" /d "%U_DATA%" /f >nul
if errorlevel 1 exit /b 1
call :UndoRegistryValueMatches
exit /b %errorlevel%

:UndoRegistryAbsent
reg query "%UKEY%" /v "%UVAL%" >nul 2>&1
if errorlevel 1 (
 echo [ALREADY REVERTED] Registry value is already absent.
 exit /b 0
)
reg delete "%UKEY%" /v "%UVAL%" /f >nul 2>&1
if errorlevel 1 exit /b 1
reg query "%UKEY%" /v "%UVAL%" >nul 2>&1
if errorlevel 1 exit /b 0
exit /b 1

:UndoRegistryValueMatches
powershell -NoProfile -Command "$v=Get-ItemPropertyValue -LiteralPath 'Registry::%UKEY%' -Name '%UVAL%' -ErrorAction Stop; $e='%U_DATA%'; if('%U_TYPE%' -eq 'REG_DWORD'){$e=[Convert]::ToUInt32($e.Substring(2),16)}; if([string]$v -eq [string]$e){exit 0}else{exit 1}" 2>nul
exit /b %errorlevel%

:UndoPower
powercfg /setactive %UNDO_A%
if errorlevel 1 exit /b 1
powercfg /getactivescheme | findstr /I "%UNDO_A%" >nul
exit /b

:UndoHiber
if "%UNDO_A%"=="1" goto :UndoHiberEnable
if "%UNDO_A%"=="0" goto :UndoHiberDisable
exit /b 1
:UndoHiberEnable
powercfg /hibernate on
if errorlevel 1 exit /b 1
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v HibernateEnabled 2>nul | findstr /I "0x1" >nul
exit /b %errorlevel%
:UndoHiberDisable
powercfg /hibernate off
if errorlevel 1 exit /b 1
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v HibernateEnabled 2>nul | findstr /I "0x0" >nul
exit /b %errorlevel%

:UndoService
set "USVC=%UNDO_A%"
set "USTART=%UNDO_B%"
set "USTATE=%UNDO_C%"
set "URESTORE="
if "%USTART%"=="2" set "URESTORE=auto"
if "%USTART%"=="3" set "URESTORE=demand"
if "%USTART%"=="4" set "URESTORE=disabled"
if not defined URESTORE exit /b 1
sc config "%USVC%" start= %URESTORE% >nul
if errorlevel 1 exit /b 1
sc qc "%USVC%" | findstr /R /C:"START_TYPE.*%USTART%" >nul
if errorlevel 1 exit /b 1
if "%USTATE%"=="4" goto :UndoServiceRunning
exit /b 0
:UndoServiceRunning
sc start "%USVC%" >nul 2>&1
sc query "%USVC%" | findstr /R /C:"STATE.*4" >nul
exit /b %errorlevel%

:UndoLatestProfile
set "LAST_PROFILE="
for /f "usebackq tokens=1-3 delims=|" %%A in ("%PROFILEHISTORY%") do set "LAST_PROFILE=%%A|%%B|%%C"
if not defined LAST_PROFILE (
 echo No applied profile history was found.
 pause
 exit /b
)
for /f "tokens=1-3 delims=|" %%A in ("%LAST_PROFILE%") do (
 set "RESTORE_PROFILE_NAME=%%B"
 set "RESTORE_PROFILE_IDS=%%C"
)
echo Latest profile: %RESTORE_PROFILE_NAME%
echo Operations: %RESTORE_PROFILE_IDS%
choice /c YN /n /m "Attempt to restore each latest captured state"
if errorlevel 2 exit /b
for %%I in (%RESTORE_PROFILE_IDS%) do (
 set "UNDO_ID=%%I"
 call :UndoOneNoPrompt
)
echo Profile restore attempt completed. Inspect the log for individual results.
pause
exit /b

:UndoOneNoPrompt
set "UNDO_LINE="
for /f "usebackq tokens=1-9 delims=|" %%A in ("%UNDOLOG%") do (
 if /I "%%A"=="%UNDO_ID%" if /I not "%%B"=="UNDO" set "UNDO_LINE=%%A|%%B|%%C|%%D|%%E|%%F|%%G|%%H|%%I"
)
if not defined UNDO_LINE exit /b 1
for /f "tokens=1-9 delims=|" %%A in ("%UNDO_LINE%") do (
 set "UNDO_TYPE=%%B"
 set "UNDO_A=%%C"
 set "UNDO_B=%%D"
 set "UNDO_C=%%E"
 set "UNDO_D=%%F"
 set "UNDO_E=%%G"
)
if /I "%UNDO_TYPE%"=="REG" call :UndoRegistry
if /I "%UNDO_TYPE%"=="POWER" call :UndoPower
if /I "%UNDO_TYPE%"=="HIBER" call :UndoHiber
if /I "%UNDO_TYPE%"=="SERVICE" call :UndoService
call :Log "%UNDO_ID% profile restore return code %errorlevel%."
exit /b

:ProfileMenu
call :Header
echo   Profiles
 echo ----------------------------------------------------------------------------
echo   Profiles contain curated operations only. ADEX never offers an apply-everything profile.
echo.
echo   [1] SAFE       - transparency, taskbar animation, Game Mode, advertising ID
echo   [2] GAMING     - Game Mode and background capture settings
 echo   [3] PERFORMANCE- visual animations plus High performance power plan
 echo   [4] PRIVACY    - advertising, tailored experiences, suggestions, feedback
 echo   [5] CLEANUP    - previews of disposable caches; extra confirmation per location
 echo   [6] CUSTOM     - add, remove, save, and apply selected IDs
 echo   [B] Back
set "PM="
set /p "PM=Select: "
if /I "%PM%"=="1" call :ApplyProfile SAFE "WIN-0001 UI-0001 UI-0002 GAME-0001 PRIV-0001"
if /I "%PM%"=="2" call :ApplyProfile GAMING "GAME-0001 GAME-0002 GAME-0003"
if /I "%PM%"=="3" call :ApplyProfile PERFORMANCE "WIN-0001 UI-0001 UI-0002 PWR-0001"
if /I "%PM%"=="4" call :ApplyProfile PRIVACY "PRIV-0001 PRIV-0002 PRIV-0003 PRIV-0004 PRIV-0005"
if /I "%PM%"=="5" call :ApplyProfile CLEANUP "CLEAN-0001 CLEAN-0002 CLEAN-0003"
if /I "%PM%"=="6" call :CustomProfile
exit /b

:ApplyProfile
set "PROFILE_NAME=%~1"
set "PROFILE_IDS=%~2"
call :Header
echo   Profile preview: %PROFILE_NAME%
echo ----------------------------------------------------------------------------
for %%I in (%PROFILE_IDS%) do call :PreviewProfileOne %%I
echo ----------------------------------------------------------------------------
choice /c AC /n /m "A=apply this previewed profile; C=cancel"
if errorlevel 2 exit /b
set "PROFILE_MODE=1"
for %%I in (%PROFILE_IDS%) do call :RunTweak %%I
set "PROFILE_MODE="
call :MakeStamp
>>"%PROFILEHISTORY%" echo %STAMP%^|%PROFILE_NAME%^|%PROFILE_IDS%
call :Log "Profile %PROFILE_NAME% applied: %PROFILE_IDS%"
echo.
echo Profile processing completed. Individual failures, if any, are in the activity log.
pause
exit /b

:PreviewProfileOne
call :Meta %~1
if /I "%T_MODE%"=="REG" call :DetectRegistry
if /I not "%T_MODE%"=="REG" call :DetectAction %T_ID%
echo   %T_ID%  ^| %T_NAME%
echo       Current: %T_CURRENT%
echo       New: %T_CHANGE%
echo       Risk: %T_RISK% ^| Backup: %T_BACKUP%
exit /b

:CustomProfile
set "CUSTOM_FILE=%PROFILEDIR%\custom.profile"
if exist "%CUSTOM_FILE%" set /p CUSTOM_IDS=<"%CUSTOM_FILE%"
if not defined CUSTOM_IDS set "CUSTOM_IDS="
:CustomProfileLoop
call :Header
echo   Custom Profile
 echo ----------------------------------------------------------------------------
echo Current IDs: %CUSTOM_IDS%
echo.
echo   [1] Add an operation ID
 echo   [2] Remove an operation ID
 echo   [3] Preview and apply
 echo   [4] Save
 echo   [5] Clear
 echo   [B] Back
set "CM="
set /p "CM=Select: "
if /I "%CM%"=="1" goto :CustomAdd
if /I "%CM%"=="2" goto :CustomRemove
if /I "%CM%"=="3" goto :CustomApply
if /I "%CM%"=="4" goto :CustomSave
if /I "%CM%"=="5" goto :CustomClear
if /I "%CM%"=="B" exit /b
goto :CustomProfileLoop

:CustomAdd
set "CUSTOM_ADD="
set /p "CUSTOM_ADD=ID to add: "
call :IsKnown "%CUSTOM_ADD%"
if /I "%KNOWN%"=="1" set "CUSTOM_IDS=%CUSTOM_IDS% %CUSTOM_ADD%"
if /I not "%KNOWN%"=="1" echo Unknown ID.
set "KNOWN="
goto :CustomProfileLoop

:CustomRemove
set "CUSTOM_REMOVE="
set /p "CUSTOM_REMOVE=ID to remove: "
call :IsKnown "%CUSTOM_REMOVE%"
if /I "%KNOWN%"=="1" set "CUSTOM_IDS=%CUSTOM_IDS:%CUSTOM_REMOVE%=%"
if /I not "%KNOWN%"=="1" echo Unknown ID.
set "KNOWN="
goto :CustomProfileLoop

:CustomApply
if not defined CUSTOM_IDS (
 echo Add at least one valid ID first.
 timeout /t 2 >nul
 goto :CustomProfileLoop
)
call :ApplyProfile CUSTOM "%CUSTOM_IDS%"
goto :CustomProfileLoop

:CustomSave
>"%CUSTOM_FILE%" echo %CUSTOM_IDS%
echo Saved to %CUSTOM_FILE%
timeout /t 2 >nul
goto :CustomProfileLoop

:CustomClear
set "CUSTOM_IDS="
echo Custom profile cleared in memory. Save to persist the empty list.
timeout /t 2 >nul
goto :CustomProfileLoop

:IsKnown
set "KNOWN="
if /I "%~1"=="WIN-0001" set "KNOWN=1"
if /I "%~1"=="WIN-0002" set "KNOWN=1"
if /I "%~1"=="WIN-0003" set "KNOWN=1"
if /I "%~1"=="WIN-0004" set "KNOWN=1"
if /I "%~1"=="GAME-0001" set "KNOWN=1"
if /I "%~1"=="GAME-0002" set "KNOWN=1"
if /I "%~1"=="GAME-0003" set "KNOWN=1"
if /I "%~1"=="INPUT-0001" set "KNOWN=1"
if /I "%~1"=="INPUT-0002" set "KNOWN=1"
if /I "%~1"=="INPUT-0003" set "KNOWN=1"
if /I "%~1"=="CPU-0001" set "KNOWN=1"
if /I "%~1"=="GPU-0001" set "KNOWN=1"
if /I "%~1"=="RAM-0001" set "KNOWN=1"
if /I "%~1"=="RAM-0002" set "KNOWN=1"
if /I "%~1"=="STOR-0001" set "KNOWN=1"
if /I "%~1"=="STOR-0002" set "KNOWN=1"
if /I "%~1"=="STOR-0003" set "KNOWN=1"
if /I "%~1"=="STOR-0004" set "KNOWN=1"
if /I "%~1"=="PWR-0001" set "KNOWN=1"
if /I "%~1"=="PWR-0002" set "KNOWN=1"
if /I "%~1"=="PWR-0003" set "KNOWN=1"
if /I "%~1"=="NET-0001" set "KNOWN=1"
if /I "%~1"=="NET-0002" set "KNOWN=1"
if /I "%~1"=="NET-0003" set "KNOWN=1"
if /I "%~1"=="NET-0004" set "KNOWN=1"
if /I "%~1"=="START-0001" set "KNOWN=1"
if /I "%~1"=="START-0002" set "KNOWN=1"
if /I "%~1"=="SVC-0001" set "KNOWN=1"
if /I "%~1"=="SVC-0002" set "KNOWN=1"
if /I "%~1"=="TASK-0001" set "KNOWN=1"
if /I "%~1"=="TASK-0002" set "KNOWN=1"
if /I "%~1"=="UI-0001" set "KNOWN=1"
if /I "%~1"=="UI-0002" set "KNOWN=1"
if /I "%~1"=="UI-0003" set "KNOWN=1"
if /I "%~1"=="UI-0004" set "KNOWN=1"
if /I "%~1"=="UI-0005" set "KNOWN=1"
if /I "%~1"=="UI-0006" set "KNOWN=1"
if /I "%~1"=="PRIV-0001" set "KNOWN=1"
if /I "%~1"=="PRIV-0002" set "KNOWN=1"
if /I "%~1"=="PRIV-0003" set "KNOWN=1"
if /I "%~1"=="PRIV-0004" set "KNOWN=1"
if /I "%~1"=="PRIV-0005" set "KNOWN=1"
if /I "%~1"=="CLEAN-0001" set "KNOWN=1"
if /I "%~1"=="CLEAN-0002" set "KNOWN=1"
if /I "%~1"=="CLEAN-0003" set "KNOWN=1"
if /I "%~1"=="CLEAN-0004" set "KNOWN=1"
if /I "%~1"=="DIAG-0001" set "KNOWN=1"
if /I "%~1"=="DIAG-0002" set "KNOWN=1"
if /I "%~1"=="DIAG-0003" set "KNOWN=1"
if /I "%~1"=="DIAG-0004" set "KNOWN=1"
if /I "%~1"=="DIAG-0005" set "KNOWN=1"
if /I "%~1"=="DIAG-0006" set "KNOWN=1"
if /I "%~1"=="DIAG-0007" set "KNOWN=1"
if /I "%~1"=="REPAIR-0001" set "KNOWN=1"
if /I "%~1"=="REPAIR-0002" set "KNOWN=1"
if /I "%~1"=="REPAIR-0003" set "KNOWN=1"
if /I "%~1"=="REPAIR-0004" set "KNOWN=1"
if /I "%~1"=="REPAIR-0005" set "KNOWN=1"
if /I "%~1"=="REPAIR-0006" set "KNOWN=1"
exit /b

:SearchMenu
call :Header
echo   Search by ID, name, category, or risk keyword. Search is local and case-insensitive.
echo   Examples: GPU  ^|  SAFE  ^|  Game Mode  ^|  PRIV-0001
set "QUERY="
set /p "QUERY=Search: "
if "%QUERY%"=="" exit /b
echo.
set "SEARCH_COUNT=0"
for %%I in (%LIBRARY%) do call :SearchOne %%I "%QUERY%"
if "%SEARCH_COUNT%"=="0" echo No local catalog matches.
echo.
echo Enter a matching ID to open it, or press Enter to return.
set "TSEL="
set /p "TSEL=Operation: "
if not "%TSEL%"=="" call :DispatchID "%TSEL%"
set "DISPATCHED="
exit /b

:SearchOne
call :Meta %~1
(echo %T_ID% %T_NAME% %T_CATEGORY% %T_SUBCATEGORY% %T_RISK% %T_SUPPORT% build-%T_MINBUILD% %T_DESC%) | findstr /I /C:"%~2" >nul
if not errorlevel 1 (
 echo   %T_ID%  [%T_RISK%]  %T_CATEGORY% - %T_NAME%
 set /a SEARCH_COUNT+=1
)
exit /b

:ReportMenu
call :Header
echo   Reports and benchmarking
 echo ----------------------------------------------------------------------------
echo   [1] Generate privacy-conscious system report
 echo   [2] Run native Windows System Assessment disk benchmark for C:
 echo   [3] Open report folder
 echo   [4] Show current ADEX activity log
 echo   [B] Back
set "RM="
set /p "RM=Select: "
if /I "%RM%"=="1" call :GenerateReport
if /I "%RM%"=="2" call :RunBenchmark
if /I "%RM%"=="3" start "ADEX reports" "%REPORTDIR%"
if /I "%RM%"=="4" type "%LOGFILE%" & pause
exit /b

:GenerateReport
call :MakeStamp
set "SYSREPORT=%REPORTDIR%\system_%STAMP%.txt"
>"%SYSREPORT%" echo ADEX System Report
>>"%SYSREPORT%" echo Generated: %STAMP%
>>"%SYSREPORT%" echo ADEX version: %ADEX_VERSION%
>>"%SYSREPORT%" echo.
>>"%SYSREPORT%" echo Windows: %OS_NAME%
>>"%SYSREPORT%" echo Build: %OS_BUILD%
>>"%SYSREPORT%" echo Architecture: %OS_ARCH%
>>"%SYSREPORT%" echo CPU: %CPU_NAME%
>>"%SYSREPORT%" echo Memory: %RAM_GB%
>>"%SYSREPORT%" echo GPU: %GPU_NAME%
>>"%SYSREPORT%" echo.
>>"%SYSREPORT%" echo Applied/recorded ADEX operations:
>>"%SYSREPORT%" type "%UNDOLOG%"
>>"%SYSREPORT%" echo.
>>"%SYSREPORT%" echo Recent ADEX activity:
>>"%SYSREPORT%" type "%LOGFILE%"
if not exist "%SYSREPORT%" (
 echo Report could not be created.
 call :Log "System report creation failed."
 pause
 exit /b 1
)
echo Report written: %SYSREPORT%
call :Log "System report created: %SYSREPORT%"
pause
exit /b 0

:RunBenchmark
call :Header
echo This invokes Windows System Assessment for the C: disk only. It measures current
 echo conditions; ADEX does not infer that a setting caused any result.
choice /c YN /n /m "Run winsat disk benchmark"
if errorlevel 2 exit /b
call :MakeStamp
winsat disk -drive C > "%REPORTDIR%\winsat_disk_%STAMP%.txt" 2>&1
if errorlevel 1 (
 echo winsat was unavailable or returned an error. No result was fabricated.
) else (
 echo Benchmark output saved in %REPORTDIR%\winsat_disk_%STAMP%.txt
)
pause
exit /b

:SettingsMenu
call :Header
echo   Settings and integrity
 echo ----------------------------------------------------------------------------
echo   [1] Display ADEX.cmd SHA-256 (accidental-corruption check)
 echo   [2] Toggle console color theme
 echo   [3] Open ADEX data folder
 echo   [4] Show runtime policy
 echo   [5] Aiden PC Services - About and community
 echo   [B] Back
set "SM="
set /p "SM=Select: "
if /I "%SM%"=="1" certutil -hashfile "%~f0" SHA256 & pause
if /I "%SM%"=="2" call :ToggleTheme
if /I "%SM%"=="3" start "ADEX data" "%DATADIR%"
if /I "%SM%"=="4" call :RuntimePolicy
if /I "%SM%"=="5" call :AboutCredits
exit /b

:ToggleTheme
if "%COLOR_THEME%"=="0B" (set "COLOR_THEME=07") else (set "COLOR_THEME=0B")
color %COLOR_THEME%
exit /b

:RuntimePolicy
cls
echo ADEX runtime policy
 echo ----------------------------------------------------------------------------
echo - No downloads, remote scripts, telemetry, installed services, or agents.
echo - Only native Windows commands and inline local PowerShell are invoked.
echo - Registry changes receive exported-key plus value-level backup records.
echo - Cleanup is previewed and requires extra confirmation; personal folders are not targets.
echo - Security protections, Windows Update, Defender, SmartScreen, boot configuration,
echo   and generic service disabling are intentionally outside this tool.
pause
exit /b

:AboutCredits
cls
echo ============================================================================
echo   ADEX - About and Credits
echo ============================================================================
echo   ADEX is an original Windows optimization project founded and developed
echo   by Aiden under the Aiden PC Services ecosystem.
echo.
echo   Official website : https://aidenpcsl.netlify.app
echo   Creator GitHub   : https://github.com/aidenpcsl
echo   YouTube          : https://youtube.com/@aidenpcsl
echo   Instagram        : https://instagram.com/aidenpcsl
echo   TikTok           : https://tiktok.com/@aidenpcsl
echo   Facebook         : https://facebook.com/aidenpcsl
echo   Discord          : @aidenpcsl
echo   Discord Server   : https://discord.gg/8WNCmAqXg
echo   Project contact  : aidenpcservices@gmail.com
echo.
echo   These links are optional community and contact channels. ADEX requires
echo   no account, network connection, or external service to operate.
echo ============================================================================
pause
exit /b

:MakeStamp
set "STAMP="
for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "Get-Date -Format 'yyyyMMdd_HHmmss'" 2^>nul`) do set "STAMP=%%A"
if not defined STAMP set "STAMP=%RANDOM%%RANDOM%"
exit /b

:Log
call :MakeStamp
>>"%LOGFILE%" echo [%STAMP%] %~1
exit /b

:Meta
set "T_ID=%~1"
set "T_NAME="
set "T_CATEGORY="
set "T_SUBCATEGORY="
set "T_DESC="
set "T_CHANGE="
set "T_WHY="
set "T_RISK="
set "T_SUPPORT="
set "T_MINBUILD=0"
set "T_HARDWARE="
set "T_CURRENT="
set "T_BACKUP="
set "T_APPLY="
set "T_VALIDATE="
set "T_REVERT="
set "T_DEPENDENCIES="
set "T_CONFLICTS="
set "T_ERROR="
set "T_MODE="
set "T_KEY="
set "T_VALUE="
set "T_REGTYPE="
set "T_NEW="
set "T_RESTART=No"
if /I "%~1"=="WIN-0001" (
 set "T_ID=WIN-0001"
 set "T_NAME=Disable transparency effects"
 set "T_CATEGORY=WINDOWS"
 set "T_SUBCATEGORY=Visual effects"
 set "T_DESC=Turns off Windows transparency for the current user."
 set "T_CHANGE=Sets EnableTransparency to 0."
 set "T_WHY=May reduce compositing work on lower-end hardware; visual preference only."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=REG"
 set "T_KEY=HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
 set "T_VALUE=EnableTransparency"
 set "T_REGTYPE=REG_DWORD"
 set "T_NEW=0"
 set "T_RESTART=No"
 set "T_BACKUP=Exact registry value state plus exported containing key"
 set "T_APPLY=reg add after preview and confirmation"
 set "T_VALIDATE=Read the exact value using the registry provider"
 set "T_REVERT=Restore captured value or remove newly-created value"
 set "T_DEPENDENCIES=None"
 set "T_CONFLICTS=None"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="WIN-0002" (
 set "T_ID=WIN-0002"
 set "T_NAME=Restrict background app activity"
 set "T_CATEGORY=WINDOWS"
 set "T_SUBCATEGORY=Background activity"
 set "T_DESC=Requests that legacy background applications not run globally for this user."
 set "T_CHANGE=Sets GlobalUserDisabled to 1."
 set "T_WHY=Can reduce background work; affected apps may not update in the background."
 set "T_RISK=ADVANCED"
 set "T_SUPPORT=Windows 10 1903+; Windows 11 behavior varies"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=REG"
 set "T_KEY=HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
 set "T_VALUE=GlobalUserDisabled"
 set "T_REGTYPE=REG_DWORD"
 set "T_NEW=1"
 set "T_RESTART=No"
 set "T_BACKUP=Exact registry value state plus exported containing key"
 set "T_APPLY=reg add after preview and confirmation"
 set "T_VALIDATE=Read the exact value using the registry provider"
 set "T_REVERT=Restore captured value or remove newly-created value"
 set "T_DEPENDENCIES=User sign-in"
 set "T_CONFLICTS=May reduce background notifications"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="WIN-0003" (
 set "T_ID=WIN-0003"
 set "T_NAME=Disable Delivery Optimization peer sharing"
 set "T_CATEGORY=WINDOWS"
 set "T_SUBCATEGORY=Update delivery"
 set "T_DESC=Keeps Delivery Optimization downloads local or Microsoft-hosted rather than peer-to-peer."
 set "T_CHANGE=Sets DODownloadMode to 0."
 set "T_WHY=Reduces peer upload/download activity; it does not disable Windows Update."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=REG"
 set "T_KEY=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config"
 set "T_VALUE=DODownloadMode"
 set "T_REGTYPE=REG_DWORD"
 set "T_NEW=0"
 set "T_RESTART=No"
 set "T_BACKUP=Exact registry value state plus exported containing key"
 set "T_APPLY=reg add after preview and confirmation"
 set "T_VALIDATE=Read the exact value using the registry provider"
 set "T_REVERT=Restore captured value or remove newly-created value"
 set "T_DEPENDENCIES=Administrator"
 set "T_CONFLICTS=None"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="WIN-0004" (
 set "T_ID=WIN-0004"
 set "T_NAME=Disable lock-screen app status"
 set "T_CATEGORY=WINDOWS"
 set "T_SUBCATEGORY=Lock screen"
 set "T_DESC=Prevents apps from showing detailed status on the lock screen for the current user."
 set "T_CHANGE=Sets NoLockScreenAppNotifications to 1."
 set "T_WHY=Reduces lock-screen background notifications; primarily a preference."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=REG"
 set "T_KEY=HKCU\Software\Policies\Microsoft\Windows\System"
 set "T_VALUE=NoLockScreenAppNotifications"
 set "T_REGTYPE=REG_DWORD"
 set "T_NEW=1"
 set "T_RESTART=No"
 set "T_BACKUP=Exact registry value state plus exported containing key"
 set "T_APPLY=reg add after preview and confirmation"
 set "T_VALIDATE=Read the exact value using the registry provider"
 set "T_REVERT=Restore captured value or remove newly-created value"
 set "T_DEPENDENCIES=None"
 set "T_CONFLICTS=May hide useful status"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="GAME-0001" (
 set "T_ID=GAME-0001"
 set "T_NAME=Enable Windows Game Mode"
 set "T_CATEGORY=GAMING"
 set "T_SUBCATEGORY=Game scheduling"
 set "T_DESC=Enables the Windows Game Mode preference for the current user."
 set "T_CHANGE=Sets AutoGameModeEnabled to 1."
 set "T_WHY=Lets Windows apply its supported Game Mode behavior to recognized games; no FPS guarantee."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=REG"
 set "T_KEY=HKCU\Software\Microsoft\GameBar"
 set "T_VALUE=AutoGameModeEnabled"
 set "T_REGTYPE=REG_DWORD"
 set "T_NEW=1"
 set "T_RESTART=No"
 set "T_BACKUP=Exact registry value state plus exported containing key"
 set "T_APPLY=reg add after preview and confirmation"
 set "T_VALIDATE=Read the exact value using the registry provider"
 set "T_REVERT=Restore captured value or remove newly-created value"
 set "T_DEPENDENCIES=None"
 set "T_CONFLICTS=None"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="GAME-0002" (
 set "T_ID=GAME-0002"
 set "T_NAME=Disable background game capture"
 set "T_CATEGORY=GAMING"
 set "T_SUBCATEGORY=Capture"
 set "T_DESC=Disables application capture through the Windows Game DVR setting for the current user."
 set "T_CHANGE=Sets AppCaptureEnabled to 0."
 set "T_WHY=Can prevent background capture overhead; recording features will be unavailable until reverted."
 set "T_RISK=ADVANCED"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=REG"
 set "T_KEY=HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR"
 set "T_VALUE=AppCaptureEnabled"
 set "T_REGTYPE=REG_DWORD"
 set "T_NEW=0"
 set "T_RESTART=No"
 set "T_BACKUP=Exact registry value state plus exported containing key"
 set "T_APPLY=reg add after preview and confirmation"
 set "T_VALIDATE=Read the exact value using the registry provider"
 set "T_REVERT=Restore captured value or remove newly-created value"
 set "T_DEPENDENCIES=None"
 set "T_CONFLICTS=Disables Windows app capture"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="GAME-0003" (
 set "T_ID=GAME-0003"
 set "T_NAME=Disable Game Bar startup panel"
 set "T_CATEGORY=GAMING"
 set "T_SUBCATEGORY=Game Bar"
 set "T_DESC=Stops the Game Bar startup panel from being shown automatically."
 set "T_CHANGE=Sets ShowStartupPanel to 0."
 set "T_WHY=Reduces unsolicited overlay prompts; it does not uninstall Game Bar."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=REG"
 set "T_KEY=HKCU\Software\Microsoft\GameBar"
 set "T_VALUE=ShowStartupPanel"
 set "T_REGTYPE=REG_DWORD"
 set "T_NEW=0"
 set "T_RESTART=No"
 set "T_BACKUP=Exact registry value state plus exported containing key"
 set "T_APPLY=reg add after preview and confirmation"
 set "T_VALIDATE=Read the exact value using the registry provider"
 set "T_REVERT=Restore captured value or remove newly-created value"
 set "T_DEPENDENCIES=None"
 set "T_CONFLICTS=None"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="INPUT-0001" (
 set "T_ID=INPUT-0001"
 set "T_NAME=Disable Enhance Pointer Precision"
 set "T_CATEGORY=INPUT"
 set "T_SUBCATEGORY=Mouse"
 set "T_DESC=Turns off the Windows mouse acceleration control."
 set "T_CHANGE=Sets MouseSpeed to 0."
 set "T_WHY=Provides a fixed pointer response preferred by some users; it is a preference, not a latency claim."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=REG"
 set "T_KEY=HKCU\Control Panel\Mouse"
 set "T_VALUE=MouseSpeed"
 set "T_REGTYPE=REG_SZ"
 set "T_NEW=0"
 set "T_RESTART=No"
 set "T_BACKUP=Exact registry value state plus exported containing key"
 set "T_APPLY=reg add after preview and confirmation"
 set "T_VALIDATE=Read the exact value using the registry provider"
 set "T_REVERT=Restore captured value or remove newly-created value"
 set "T_DEPENDENCIES=None"
 set "T_CONFLICTS=Changes pointer feel"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="INPUT-0002" (
 set "T_ID=INPUT-0002"
 set "T_NAME=Set short keyboard repeat delay"
 set "T_CATEGORY=INPUT"
 set "T_SUBCATEGORY=Keyboard"
 set "T_DESC=Sets the keyboard repeat delay to the shortest Windows setting."
 set "T_CHANGE=Sets KeyboardDelay to 0."
 set "T_WHY=May feel more responsive when holding keys; does not change hardware input latency."
 set "T_RISK=ADVANCED"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=REG"
 set "T_KEY=HKCU\Control Panel\Keyboard"
 set "T_VALUE=KeyboardDelay"
 set "T_REGTYPE=REG_SZ"
 set "T_NEW=0"
 set "T_RESTART=No"
 set "T_BACKUP=Exact registry value state plus exported containing key"
 set "T_APPLY=reg add after preview and confirmation"
 set "T_VALIDATE=Read the exact value using the registry provider"
 set "T_REVERT=Restore captured value or remove newly-created value"
 set "T_DEPENDENCIES=None"
 set "T_CONFLICTS=Changes typing behavior"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="INPUT-0003" (
 set "T_ID=INPUT-0003"
 set "T_NAME=Set faster keyboard repeat rate"
 set "T_CATEGORY=INPUT"
 set "T_SUBCATEGORY=Keyboard"
 set "T_DESC=Sets the keyboard repeat rate to the fastest Windows setting."
 set "T_CHANGE=Sets KeyboardSpeed to 31."
 set "T_WHY=May suit users who prefer rapid held-key repeat; changes typing behavior."
 set "T_RISK=ADVANCED"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=REG"
 set "T_KEY=HKCU\Control Panel\Keyboard"
 set "T_VALUE=KeyboardSpeed"
 set "T_REGTYPE=REG_SZ"
 set "T_NEW=31"
 set "T_RESTART=No"
 set "T_BACKUP=Exact registry value state plus exported containing key"
 set "T_APPLY=reg add after preview and confirmation"
 set "T_VALIDATE=Read the exact value using the registry provider"
 set "T_REVERT=Restore captured value or remove newly-created value"
 set "T_DEPENDENCIES=None"
 set "T_CONFLICTS=Changes typing behavior"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="CPU-0001" (
 set "T_ID=CPU-0001"
 set "T_NAME=Inspect processor power policy"
 set "T_CATEGORY=CPU"
 set "T_SUBCATEGORY=Power diagnostics"
 set "T_DESC=Displays the active power scheme and processor power settings."
 set "T_CHANGE=Reads native powercfg settings without modifying them."
 set "T_WHY=Provides evidence before changing processor power behavior."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=powercfg"
 set "T_CONFLICTS=None"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="GPU-0001" (
 set "T_ID=GPU-0001"
 set "T_NAME=Enable hardware-accelerated GPU scheduling"
 set "T_CATEGORY=GPU"
 set "T_SUBCATEGORY=Graphics scheduling"
 set "T_DESC=Requests Hardware-accelerated GPU scheduling where Windows and the display driver support it."
 set "T_CHANGE=Sets HwSchMode to 2."
 set "T_WHY=Can alter graphics scheduling on compatible systems; effects vary and a restart is required."
 set "T_RISK=ADVANCED"
 set "T_SUPPORT=Windows 10 version 2004+ and Windows 11"
 set "T_MINBUILD=19041"
 set "T_HARDWARE=WDDM driver with Windows HAGS support"
 set "T_MODE=REG"
 set "T_KEY=HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
 set "T_VALUE=HwSchMode"
 set "T_REGTYPE=REG_DWORD"
 set "T_NEW=2"
 set "T_RESTART=Yes"
 set "T_BACKUP=Exact registry value state plus exported containing key"
 set "T_APPLY=reg add after preview and confirmation"
 set "T_VALIDATE=Read the exact value using the registry provider"
 set "T_REVERT=Restore captured value or remove newly-created value"
 set "T_DEPENDENCIES=Administrator; supported GPU driver"
 set "T_CONFLICTS=Graphics driver compatibility"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="RAM-0001" (
 set "T_ID=RAM-0001"
 set "T_NAME=Inspect virtual memory configuration"
 set "T_CATEGORY=MEMORY"
 set "T_SUBCATEGORY=Virtual memory"
 set "T_DESC=Reports automatic paging-file configuration and configured page files."
 set "T_CHANGE=Reads Win32_PageFileSetting and ComputerSystem properties only."
 set "T_WHY=Helps avoid unsafe page-file myths by exposing the current state."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=PowerShell CIM"
 set "T_CONFLICTS=None"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="RAM-0002" (
 set "T_ID=RAM-0002"
 set "T_NAME=Launch Windows Memory Diagnostic"
 set "T_CATEGORY=MEMORY"
 set "T_SUBCATEGORY=Memory diagnostics"
 set "T_DESC=Starts the built-in Windows Memory Diagnostic scheduler."
 set "T_CHANGE=Invokes mdsched.exe; the user chooses whether to restart."
 set "T_WHY=Uses Microsoft native diagnostics when memory instability is suspected."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=Yes"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=User confirmation"
 set "T_CONFLICTS=Requires reboot to test"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="STOR-0001" (
 set "T_ID=STOR-0001"
 set "T_NAME=Check TRIM status"
 set "T_CATEGORY=STORAGE"
 set "T_SUBCATEGORY=SSD diagnostics"
 set "T_DESC=Queries the Windows DisableDeleteNotify status for NTFS and ReFS."
 set "T_CHANGE=Runs fsutil behavior query DisableDeleteNotify without changing configuration."
 set "T_WHY=Confirms whether Windows reports TRIM notifications as enabled."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=SSD optional"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=Administrator"
 set "T_CONFLICTS=None"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="STOR-0002" (
 set "T_ID=STOR-0002"
 set "T_NAME=Run volume optimization on C"
 set "T_CATEGORY=STORAGE"
 set "T_SUBCATEGORY=Storage maintenance"
 set "T_DESC=Runs the native Optimize Drives command for C:."
 set "T_CHANGE=Runs defrag C: /O; Windows selects the appropriate optimization for the volume."
 set "T_WHY=Requests supported maintenance rather than applying SSD myths; completion time varies."
 set "T_RISK=ADVANCED"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=C: volume"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=Administrator; C: available"
 set "T_CONFLICTS=May be lengthy"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="STOR-0003" (
 set "T_ID=STOR-0003"
 set "T_NAME=Inspect disk health status"
 set "T_CATEGORY=STORAGE"
 set "T_SUBCATEGORY=Storage diagnostics"
 set "T_DESC=Displays MSStorageDriver failure prediction status when the provider exposes it."
 set "T_CHANGE=Reads WMI storage prediction data only."
 set "T_WHY=May reveal a reported SMART failure prediction; it is not a complete disk-health diagnosis."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=Storage provider support"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=PowerShell CIM"
 set "T_CONFLICTS=Some devices expose no data"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="STOR-0004" (
 set "T_ID=STOR-0004"
 set "T_NAME=Check file-system status on C"
 set "T_CATEGORY=STORAGE"
 set "T_SUBCATEGORY=File system diagnostics"
 set "T_DESC=Runs a read-only CHKDSK scan status query for C:."
 set "T_CHANGE=Runs chkdsk C: without repair switches."
 set "T_WHY=Reports file-system information without scheduling destructive repair."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=C: volume"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=Administrator; C: available"
 set "T_CONFLICTS=None"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="PWR-0001" (
 set "T_ID=PWR-0001"
 set "T_NAME=Activate High performance power plan"
 set "T_CATEGORY=POWER"
 set "T_SUBCATEGORY=Power plan"
 set "T_DESC=Switches to the built-in High performance plan if it is available."
 set "T_CHANGE=Runs powercfg /setactive SCHEME_MIN and saves the previous scheme GUID."
 set "T_WHY=Prefers performance-oriented power policy; may increase heat, noise, and battery use."
 set "T_RISK=ADVANCED"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=High performance scheme available"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=Previous active scheme GUID"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Restore captured active scheme"
 set "T_DEPENDENCIES=Administrator; powercfg"
 set "T_CONFLICTS=Higher power consumption"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="PWR-0002" (
 set "T_ID=PWR-0002"
 set "T_NAME=Inspect sleep and hibernation capabilities"
 set "T_CATEGORY=POWER"
 set "T_SUBCATEGORY=Power diagnostics"
 set "T_DESC=Shows sleep states supported by the current system."
 set "T_CHANGE=Runs powercfg /a without modifying settings."
 set "T_WHY=Helps users make informed sleep or hibernation choices."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=powercfg"
 set "T_CONFLICTS=None"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="PWR-0003" (
 set "T_ID=PWR-0003"
 set "T_NAME=Disable hibernation"
 set "T_CATEGORY=POWER"
 set "T_SUBCATEGORY=Power behavior"
 set "T_DESC=Disables hibernation and therefore typically disables Fast Startup."
 set "T_CHANGE=Runs powercfg /hibernate off after recording the former registry state."
 set "T_WHY=Can reclaim hiberfil.sys disk space when hibernation is not needed."
 set "T_RISK=ADVANCED"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=Administrator"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=Yes"
 set "T_BACKUP=Prior hibernation state"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Restore former hibernation state"
 set "T_DEPENDENCIES=Administrator"
 set "T_CONFLICTS=Removes hibernate and Fast Startup until reverted"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="NET-0001" (
 set "T_ID=NET-0001"
 set "T_NAME=Flush DNS resolver cache"
 set "T_CATEGORY=NETWORK"
 set "T_SUBCATEGORY=Network maintenance"
 set "T_DESC=Clears the local DNS client resolver cache."
 set "T_CHANGE=Runs ipconfig /flushdns."
 set "T_WHY=Useful when troubleshooting stale local DNS answers; it does not promise lower latency."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=Network stack"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=Administrator"
 set "T_CONFLICTS=None"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="NET-0002" (
 set "T_ID=NET-0002"
 set "T_NAME=Show adapter and DNS configuration"
 set "T_CATEGORY=NETWORK"
 set "T_SUBCATEGORY=Network diagnostics"
 set "T_DESC=Displays adapter addresses, DNS servers, and interface configuration."
 set "T_CHANGE=Runs ipconfig /all for on-screen review only."
 set "T_WHY=Supports evidence-led troubleshooting without making network changes."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=Network adapter"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=None"
 set "T_CONFLICTS=Output can contain local network details; it is not logged"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="NET-0003" (
 set "T_ID=NET-0003"
 set "T_NAME=Test DNS and internet reachability"
 set "T_CATEGORY=NETWORK"
 set "T_SUBCATEGORY=Network diagnostics"
 set "T_DESC=Tests DNS resolution and a basic HTTPS reachability request."
 set "T_CHANGE=Uses Resolve-DnsName and Test-NetConnection; no settings are changed."
 set "T_WHY=Separates name-resolution and connectivity issues."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=Network connection"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=PowerShell"
 set "T_CONFLICTS=Requires an internet connection for external reachability"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="NET-0004" (
 set "T_ID=NET-0004"
 set "T_NAME=Export network configuration report"
 set "T_CATEGORY=NETWORK"
 set "T_SUBCATEGORY=Network diagnostics"
 set "T_DESC=Writes an ipconfig and adapter summary to the ADEX report folder."
 set "T_CHANGE=Runs native ipconfig and Get-NetAdapter into a timestamped local text report."
 set "T_WHY=Creates a shareable troubleshooting artifact; review it before sharing."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=Network adapter"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=Report folder writable"
 set "T_CONFLICTS=Report may include local network details"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="START-0001" (
 set "T_ID=START-0001"
 set "T_NAME=Inspect startup registrations"
 set "T_CATEGORY=STARTUP"
 set "T_SUBCATEGORY=Startup analysis"
 set "T_DESC=Lists common Run registry locations and Startup folders."
 set "T_CHANGE=Reads startup registry keys and lists startup folders only."
 set "T_WHY=Helps users review launch points without automatically disabling applications."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=None"
 set "T_CONFLICTS=None"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="START-0002" (
 set "T_ID=START-0002"
 set "T_NAME=Inspect scheduled startup tasks"
 set "T_CATEGORY=STARTUP"
 set "T_SUBCATEGORY=Startup analysis"
 set "T_DESC=Lists scheduled tasks configured for logon or boot triggers."
 set "T_CHANGE=Queries schtasks and filters display locally."
 set "T_WHY=Adds scheduled task context to startup review; no task is disabled."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=Task Scheduler"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=schtasks"
 set "T_CONFLICTS=None"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="SVC-0001" (
 set "T_ID=SVC-0001"
 set "T_NAME=Inspect a Windows service"
 set "T_CATEGORY=SERVICES"
 set "T_SUBCATEGORY=Service analysis"
 set "T_DESC=Prompts for a service name and shows configuration, status, and dependent services."
 set "T_CHANGE=Uses sc query, sc qc, and sc enumdepend without changing the service."
 set "T_WHY=Supports conservative, evidence-based service review."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=Service exists"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=Administrator"
 set "T_CONFLICTS=None"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="SVC-0002" (
 set "T_ID=SVC-0002"
 set "T_NAME=Set a service to Manual or Automatic"
 set "T_CATEGORY=SERVICES"
 set "T_SUBCATEGORY=Service configuration"
 set "T_DESC=Allows an explicit service to be set to Manual or Automatic after review."
 set "T_CHANGE=Backs up startup type and running state; it intentionally offers no disable option."
 set "T_WHY=Can restore a user-selected service policy without promoting blanket service disabling."
 set "T_RISK=ADVANCED"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=Service exists"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=Operation-specific backup"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=Administrator; service must not be protected"
 set "T_CONFLICTS=Critical services are blocked"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="TASK-0001" (
 set "T_ID=TASK-0001"
 set "T_NAME=Inspect scheduled tasks"
 set "T_CATEGORY=TASKS"
 set "T_SUBCATEGORY=Task analysis"
 set "T_DESC=Lists registered scheduled tasks for review."
 set "T_CHANGE=Runs schtasks /query without modifying tasks."
 set "T_WHY=Supports task inventory before any manual Windows administration."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=Task Scheduler"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=schtasks"
 set "T_CONFLICTS=None"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="TASK-0002" (
 set "T_ID=TASK-0002"
 set "T_NAME=Export a scheduled task XML"
 set "T_CATEGORY=TASKS"
 set "T_SUBCATEGORY=Task backup"
 set "T_DESC=Exports a selected task definition to the ADEX backup folder."
 set "T_CHANGE=Runs schtasks /query /xml for the supplied task name."
 set "T_WHY=Creates a portable backup before manual task administration; it does not disable a task."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=Task exists"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=Task Scheduler"
 set "T_CONFLICTS=The supplied task name must be valid"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="UI-0001" (
 set "T_ID=UI-0001"
 set "T_NAME=Disable window minimize and maximize animations"
 set "T_CATEGORY=UI"
 set "T_SUBCATEGORY=Visual effects"
 set "T_DESC=Turns off the legacy window animation preference for the current user."
 set "T_CHANGE=Sets MinAnimate to 0."
 set "T_WHY=Can reduce visible animation; it is a visual preference."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=REG"
 set "T_KEY=HKCU\Control Panel\Desktop\WindowMetrics"
 set "T_VALUE=MinAnimate"
 set "T_REGTYPE=REG_SZ"
 set "T_NEW=0"
 set "T_RESTART=No"
 set "T_BACKUP=Exact registry value state plus exported containing key"
 set "T_APPLY=reg add after preview and confirmation"
 set "T_VALIDATE=Read the exact value using the registry provider"
 set "T_REVERT=Restore captured value or remove newly-created value"
 set "T_DEPENDENCIES=None"
 set "T_CONFLICTS=Changes visual behavior"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="UI-0002" (
 set "T_ID=UI-0002"
 set "T_NAME=Disable taskbar animations"
 set "T_CATEGORY=UI"
 set "T_SUBCATEGORY=Visual effects"
 set "T_DESC=Turns off taskbar animation preference for the current user."
 set "T_CHANGE=Sets TaskbarAnimations to 0."
 set "T_WHY=Can make taskbar interactions appear more immediate; no responsiveness guarantee."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=REG"
 set "T_KEY=HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
 set "T_VALUE=TaskbarAnimations"
 set "T_REGTYPE=REG_DWORD"
 set "T_NEW=0"
 set "T_RESTART=No"
 set "T_BACKUP=Exact registry value state plus exported containing key"
 set "T_APPLY=reg add after preview and confirmation"
 set "T_VALIDATE=Read the exact value using the registry provider"
 set "T_REVERT=Restore captured value or remove newly-created value"
 set "T_DEPENDENCIES=None"
 set "T_CONFLICTS=Changes visual behavior"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="UI-0003" (
 set "T_ID=UI-0003"
 set "T_NAME=Show file name extensions"
 set "T_CATEGORY=UI"
 set "T_SUBCATEGORY=Explorer"
 set "T_DESC=Shows extensions for known file types in File Explorer."
 set "T_CHANGE=Sets HideFileExt to 0."
 set "T_WHY=Improves file-type visibility and can help users identify suspicious files."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=REG"
 set "T_KEY=HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
 set "T_VALUE=HideFileExt"
 set "T_REGTYPE=REG_DWORD"
 set "T_NEW=0"
 set "T_RESTART=No"
 set "T_BACKUP=Exact registry value state plus exported containing key"
 set "T_APPLY=reg add after preview and confirmation"
 set "T_VALIDATE=Read the exact value using the registry provider"
 set "T_REVERT=Restore captured value or remove newly-created value"
 set "T_DEPENDENCIES=None"
 set "T_CONFLICTS=None"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="UI-0004" (
 set "T_ID=UI-0004"
 set "T_NAME=Show hidden files"
 set "T_CATEGORY=UI"
 set "T_SUBCATEGORY=Explorer"
 set "T_DESC=Shows hidden files in File Explorer."
 set "T_CHANGE=Sets Hidden to 1."
 set "T_WHY=Useful for administration; system-protected files remain separately protected."
 set "T_RISK=ADVANCED"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=REG"
 set "T_KEY=HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
 set "T_VALUE=Hidden"
 set "T_REGTYPE=REG_DWORD"
 set "T_NEW=1"
 set "T_RESTART=No"
 set "T_BACKUP=Exact registry value state plus exported containing key"
 set "T_APPLY=reg add after preview and confirmation"
 set "T_VALIDATE=Read the exact value using the registry provider"
 set "T_REVERT=Restore captured value or remove newly-created value"
 set "T_DEPENDENCIES=None"
 set "T_CONFLICTS=May expose files that should not be edited"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="UI-0005" (
 set "T_ID=UI-0005"
 set "T_NAME=Disable search highlights"
 set "T_CATEGORY=UI"
 set "T_SUBCATEGORY=Search"
 set "T_DESC=Turns off search highlights for the current user."
 set "T_CHANGE=Sets EnableDynamicContentInWSB to 0."
 set "T_WHY=Reduces dynamic content in Windows search; functionality remains available."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 22H2 and Windows 11"
 set "T_MINBUILD=19045"
 set "T_HARDWARE=None"
 set "T_MODE=REG"
 set "T_KEY=HKCU\Software\Microsoft\Windows\CurrentVersion\SearchSettings"
 set "T_VALUE=EnableDynamicContentInWSB"
 set "T_REGTYPE=REG_DWORD"
 set "T_NEW=0"
 set "T_RESTART=No"
 set "T_BACKUP=Exact registry value state plus exported containing key"
 set "T_APPLY=reg add after preview and confirmation"
 set "T_VALIDATE=Read the exact value using the registry provider"
 set "T_REVERT=Restore captured value or remove newly-created value"
 set "T_DEPENDENCIES=None"
 set "T_CONFLICTS=Feature availability varies by build"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="UI-0006" (
 set "T_ID=UI-0006"
 set "T_NAME=Disable notification suggestions"
 set "T_CATEGORY=UI"
 set "T_SUBCATEGORY=Notifications"
 set "T_DESC=Turns off Windows notification suggestions for the current user."
 set "T_CHANGE=Sets SoftLandingEnabled to 0."
 set "T_WHY=Reduces promotional or setup suggestion notifications."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=REG"
 set "T_KEY=HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
 set "T_VALUE=SoftLandingEnabled"
 set "T_REGTYPE=REG_DWORD"
 set "T_NEW=0"
 set "T_RESTART=No"
 set "T_BACKUP=Exact registry value state plus exported containing key"
 set "T_APPLY=reg add after preview and confirmation"
 set "T_VALIDATE=Read the exact value using the registry provider"
 set "T_REVERT=Restore captured value or remove newly-created value"
 set "T_DEPENDENCIES=None"
 set "T_CONFLICTS=None"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="PRIV-0001" (
 set "T_ID=PRIV-0001"
 set "T_NAME=Disable advertising ID"
 set "T_CATEGORY=PRIVACY"
 set "T_SUBCATEGORY=Advertising privacy"
 set "T_DESC=Turns off apps using the current user advertising ID."
 set "T_CHANGE=Sets AdvertisingInfo Enabled to 0."
 set "T_WHY=Limits ad personalization within supported Windows apps; does not affect all advertising."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=REG"
 set "T_KEY=HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
 set "T_VALUE=Enabled"
 set "T_REGTYPE=REG_DWORD"
 set "T_NEW=0"
 set "T_RESTART=No"
 set "T_BACKUP=Exact registry value state plus exported containing key"
 set "T_APPLY=reg add after preview and confirmation"
 set "T_VALIDATE=Read the exact value using the registry provider"
 set "T_REVERT=Restore captured value or remove newly-created value"
 set "T_DEPENDENCIES=None"
 set "T_CONFLICTS=None"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="PRIV-0002" (
 set "T_ID=PRIV-0002"
 set "T_NAME=Disable tailored experiences from diagnostics"
 set "T_CATEGORY=PRIVACY"
 set "T_SUBCATEGORY=Diagnostic data privacy"
 set "T_DESC=Turns off tailored experiences based on diagnostic data for the current user."
 set "T_CHANGE=Sets DisableTailoredExperiencesWithDiagnosticData to 1."
 set "T_WHY=Reduces this personalization channel without disabling Windows security features."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=REG"
 set "T_KEY=HKCU\Software\Policies\Microsoft\Windows\CloudContent"
 set "T_VALUE=DisableTailoredExperiencesWithDiagnosticData"
 set "T_REGTYPE=REG_DWORD"
 set "T_NEW=1"
 set "T_RESTART=No"
 set "T_BACKUP=Exact registry value state plus exported containing key"
 set "T_APPLY=reg add after preview and confirmation"
 set "T_VALIDATE=Read the exact value using the registry provider"
 set "T_REVERT=Restore captured value or remove newly-created value"
 set "T_DEPENDENCIES=None"
 set "T_CONFLICTS=None"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="PRIV-0003" (
 set "T_ID=PRIV-0003"
 set "T_NAME=Disable suggested app content"
 set "T_CATEGORY=PRIVACY"
 set "T_SUBCATEGORY=Content suggestions"
 set "T_DESC=Turns off a Windows content suggestion subscription for the current user."
 set "T_CHANGE=Sets SubscribedContent-338393Enabled to 0."
 set "T_WHY=Reduces suggested app content; exact content varies across builds."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=REG"
 set "T_KEY=HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
 set "T_VALUE=SubscribedContent-338393Enabled"
 set "T_REGTYPE=REG_DWORD"
 set "T_NEW=0"
 set "T_RESTART=No"
 set "T_BACKUP=Exact registry value state plus exported containing key"
 set "T_APPLY=reg add after preview and confirmation"
 set "T_VALIDATE=Read the exact value using the registry provider"
 set "T_REVERT=Restore captured value or remove newly-created value"
 set "T_DEPENDENCIES=None"
 set "T_CONFLICTS=Feature availability varies"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="PRIV-0004" (
 set "T_ID=PRIV-0004"
 set "T_NAME=Disable feedback notification prompts"
 set "T_CATEGORY=PRIVACY"
 set "T_SUBCATEGORY=Feedback privacy"
 set "T_DESC=Suppresses feedback notification prompts for the current user."
 set "T_CHANGE=Sets DoNotShowFeedbackNotifications to 1."
 set "T_WHY=Reduces feedback prompts without disabling diagnostics or security."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=REG"
 set "T_KEY=HKCU\Software\Microsoft\Siuf\Rules"
 set "T_VALUE=DoNotShowFeedbackNotifications"
 set "T_REGTYPE=REG_DWORD"
 set "T_NEW=1"
 set "T_RESTART=No"
 set "T_BACKUP=Exact registry value state plus exported containing key"
 set "T_APPLY=reg add after preview and confirmation"
 set "T_VALIDATE=Read the exact value using the registry provider"
 set "T_REVERT=Restore captured value or remove newly-created value"
 set "T_DEPENDENCIES=None"
 set "T_CONFLICTS=None"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="PRIV-0005" (
 set "T_ID=PRIV-0005"
 set "T_NAME=Disable app launch tracking"
 set "T_CATEGORY=PRIVACY"
 set "T_SUBCATEGORY=Activity privacy"
 set "T_DESC=Turns off tracking of app launches for the current user."
 set "T_CHANGE=Sets Start_TrackProgs to 0."
 set "T_WHY=Limits this Start-menu personalization input; recently used app behavior may change."
 set "T_RISK=ADVANCED"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=REG"
 set "T_KEY=HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
 set "T_VALUE=Start_TrackProgs"
 set "T_REGTYPE=REG_DWORD"
 set "T_NEW=0"
 set "T_RESTART=No"
 set "T_BACKUP=Exact registry value state plus exported containing key"
 set "T_APPLY=reg add after preview and confirmation"
 set "T_VALIDATE=Read the exact value using the registry provider"
 set "T_REVERT=Restore captured value or remove newly-created value"
 set "T_DEPENDENCIES=None"
 set "T_CONFLICTS=Changes Start-menu personalization"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="CLEAN-0001" (
 set "T_ID=CLEAN-0001"
 set "T_NAME=Preview and clean user temporary files"
 set "T_CATEGORY=CLEANUP"
 set "T_SUBCATEGORY=Temporary files"
 set "T_DESC=Shows the current TEMP folder count and size, then deletes files it can safely remove after confirmation."
 set "T_CHANGE=Removes contents of the current user TEMP folder; locked files are skipped."
 set "T_WHY=Can reclaim disposable temporary space; operation is irreversible."
 set "T_RISK=ADVANCED"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=TEMP folder"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=User confirmation"
 set "T_CONFLICTS=Irreversible; locked files may remain"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="CLEAN-0002" (
 set "T_ID=CLEAN-0002"
 set "T_NAME=Preview and clean Windows temporary files"
 set "T_CATEGORY=CLEANUP"
 set "T_SUBCATEGORY=Temporary files"
 set "T_DESC=Shows the Windows Temp folder count and size, then removes deletable items after confirmation."
 set "T_CHANGE=Removes contents of the Windows Temp folder; locked files are skipped."
 set "T_WHY=Can reclaim disposable temporary space; operation is irreversible."
 set "T_RISK=ADVANCED"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=Administrator"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=Administrator; user confirmation"
 set "T_CONFLICTS=Irreversible; locked files may remain"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="CLEAN-0003" (
 set "T_ID=CLEAN-0003"
 set "T_NAME=Preview and clean DirectX shader cache"
 set "T_CATEGORY=CLEANUP"
 set "T_SUBCATEGORY=Graphics cache"
 set "T_DESC=Shows and removes the user DirectX shader cache after confirmation."
 set "T_CHANGE=Removes contents of the DirectX shader cache folder; the cache is recreated by Windows."
 set "T_WHY=Can resolve stale cache issues or reclaim small amounts of space; games may rebuild shaders."
 set "T_RISK=ADVANCED"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=DirectX cache folder"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=User confirmation"
 set "T_CONFLICTS=Irreversible; shaders may rebuild"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="CLEAN-0004" (
 set "T_ID=CLEAN-0004"
 set "T_NAME=Empty Recycle Bin"
 set "T_CATEGORY=CLEANUP"
 set "T_SUBCATEGORY=Cleanup"
 set "T_DESC=Shows the Recycle Bin size and empties it after an additional confirmation."
 set "T_CHANGE=Uses Clear-RecycleBin -Force through local PowerShell."
 set "T_WHY=Reclaims space from items the user previously deleted; the action is irreversible."
 set "T_RISK=ADVANCED"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=Recycle Bin"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=Explicit confirmation"
 set "T_CONFLICTS=Irreversible"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="DIAG-0001" (
 set "T_ID=DIAG-0001"
 set "T_NAME=Display system summary"
 set "T_CATEGORY=DIAGNOSTICS"
 set "T_SUBCATEGORY=System diagnostics"
 set "T_DESC=Displays Windows, CPU, memory, and GPU summary data."
 set "T_CHANGE=Reads local CIM and registry data only."
 set "T_WHY=Provides a concise baseline for troubleshooting."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=PowerShell CIM"
 set "T_CONFLICTS=None"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="DIAG-0002" (
 set "T_ID=DIAG-0002"
 set "T_NAME=Check component store health"
 set "T_CATEGORY=DIAGNOSTICS"
 set "T_SUBCATEGORY=System integrity"
 set "T_DESC=Runs DISM CheckHealth and reports its native result."
 set "T_CHANGE=Runs DISM /Online /Cleanup-Image /CheckHealth; no repair is attempted."
 set "T_WHY=Checks whether component-store corruption has already been flagged."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=Administrator"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=Administrator; DISM"
 set "T_CONFLICTS=None"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="DIAG-0003" (
 set "T_ID=DIAG-0003"
 set "T_NAME=Verify protected system files"
 set "T_CATEGORY=DIAGNOSTICS"
 set "T_SUBCATEGORY=System integrity"
 set "T_DESC=Runs SFC verification without repairing files."
 set "T_CHANGE=Runs sfc /verifyonly."
 set "T_WHY=Checks protected system files before choosing a repair action."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=Administrator"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=Administrator; SFC"
 set "T_CONFLICTS=Can take time"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="DIAG-0004" (
 set "T_ID=DIAG-0004"
 set "T_NAME=Show recent System event errors"
 set "T_CATEGORY=DIAGNOSTICS"
 set "T_SUBCATEGORY=Event logs"
 set "T_DESC=Displays up to 25 System log error events from the last 24 hours."
 set "T_CHANGE=Reads the System event log through Get-WinEvent only."
 set "T_WHY=Surfaces recent error context without modifying logs."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=Event Log service"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=PowerShell"
 set "T_CONFLICTS=Some events may require administrative access"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="DIAG-0005" (
 set "T_ID=DIAG-0005"
 set "T_NAME=List installed drivers"
 set "T_CATEGORY=DIAGNOSTICS"
 set "T_SUBCATEGORY=Driver diagnostics"
 set "T_DESC=Displays installed driver names, types, and dates."
 set "T_CHANGE=Runs driverquery locally; no drivers are changed."
 set "T_WHY=Supports driver inventory during troubleshooting."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=driverquery"
 set "T_CONFLICTS=None"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="DIAG-0006" (
 set "T_ID=DIAG-0006"
 set "T_NAME=Create battery report"
 set "T_CATEGORY=DIAGNOSTICS"
 set "T_SUBCATEGORY=Battery diagnostics"
 set "T_DESC=Writes a Windows battery report to the ADEX report directory."
 set "T_CHANGE=Runs powercfg /batteryreport with a local output path."
 set "T_WHY=Uses Windows native battery history where a battery is present."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=Battery hardware optional"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only or intentionally irreversible operation"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=powercfg"
 set "T_CONFLICTS=Desktop systems may have no battery data"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="DIAG-0007" (
 set "T_ID=DIAG-0007"
 set "T_NAME=Run Windows Stutter Diagnostics"
 set "T_CATEGORY=DIAGNOSTICS"
 set "T_SUBCATEGORY=System performance indicators"
 set "T_DESC=Captures a local, read-only snapshot of common load and configuration indicators associated with micro-stuttering."
 set "T_CHANGE=Reads CPU, memory, disk, power, graphics, gaming, startup, process, driver, and system indicators; creates a local report."
 set "T_WHY=Helps identify areas to investigate without claiming that any indicator is the cause or that a setting will fix stuttering."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=None; GPU counters are optional"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=No state backup: read-only diagnostic report"
 set "T_APPLY=Runs inline local PowerShell and native powercfg queries after confirmation"
 set "T_VALIDATE=Confirms that the timestamped local diagnostics report was created"
 set "T_REVERT=Not applicable: no system configuration is changed"
 set "T_DEPENDENCIES=PowerShell"
 set "T_CONFLICTS=None"
 set "T_ERROR=Stops and logs a failure if the diagnostic command or report creation fails; unavailable counters are reported as unavailable."
 exit /b 0
)
if /I "%~1"=="REPAIR-0001" (
 set "T_ID=REPAIR-0001"
 set "T_NAME=Scan component store"
 set "T_CATEGORY=REPAIR"
 set "T_SUBCATEGORY=Component repair"
 set "T_DESC=Scans the Windows component store for corruption."
 set "T_CHANGE=Runs DISM /Online /Cleanup-Image /ScanHealth."
 set "T_WHY=Provides a deeper integrity scan before attempting repair."
 set "T_RISK=SAFE"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=Administrator"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=Operation-specific backup"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=Administrator; DISM"
 set "T_CONFLICTS=Can take time"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="REPAIR-0002" (
 set "T_ID=REPAIR-0002"
 set "T_NAME=Repair component store"
 set "T_CATEGORY=REPAIR"
 set "T_SUBCATEGORY=Component repair"
 set "T_DESC=Attempts to repair the Windows component store."
 set "T_CHANGE=Runs DISM /Online /Cleanup-Image /RestoreHealth."
 set "T_WHY=Uses the supported Microsoft repair path; it may use configured repair sources or Windows Update."
 set "T_RISK=ADVANCED"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=Administrator; source availability"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=Operation-specific backup"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=Administrator; DISM; network or repair source may be needed"
 set "T_CONFLICTS=May require a repair source or network"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="REPAIR-0003" (
 set "T_ID=REPAIR-0003"
 set "T_NAME=Repair protected system files"
 set "T_CATEGORY=REPAIR"
 set "T_SUBCATEGORY=System repair"
 set "T_DESC=Runs System File Checker repair."
 set "T_CHANGE=Runs sfc /scannow."
 set "T_WHY=Repairs protected Windows files where supported by the component store."
 set "T_RISK=ADVANCED"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=Administrator"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=Operation-specific backup"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=Administrator; SFC"
 set "T_CONFLICTS=Can take time; review native result"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="REPAIR-0004" (
 set "T_ID=REPAIR-0004"
 set "T_NAME=Reset Winsock catalog"
 set "T_CATEGORY=REPAIR"
 set "T_SUBCATEGORY=Network repair"
 set "T_DESC=Resets the Winsock catalog and requests a restart."
 set "T_CHANGE=Runs netsh winsock reset."
 set "T_WHY=Can address damaged Winsock configuration; it is a repair, not a ping optimization."
 set "T_RISK=ADVANCED"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=Administrator"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=Yes"
 set "T_BACKUP=Operation-specific backup"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=Administrator; restart"
 set "T_CONFLICTS=May affect network software until restart"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="REPAIR-0005" (
 set "T_ID=REPAIR-0005"
 set "T_NAME=Reset TCP/IP stack"
 set "T_CATEGORY=REPAIR"
 set "T_SUBCATEGORY=Network repair"
 set "T_DESC=Resets TCP/IP configuration and requests a restart."
 set "T_CHANGE=Runs netsh int ip reset."
 set "T_WHY=Can address corrupted TCP/IP settings; it is a repair, not a performance tweak."
 set "T_RISK=ADVANCED"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=Administrator"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=Yes"
 set "T_BACKUP=Operation-specific backup"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=Administrator; restart"
 set "T_CONFLICTS=May alter manually configured network parameters"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
if /I "%~1"=="REPAIR-0006" (
 set "T_ID=REPAIR-0006"
 set "T_NAME=Reset Windows Firewall policy"
 set "T_CATEGORY=REPAIR"
 set "T_SUBCATEGORY=Firewall repair"
 set "T_DESC=Restores Windows Defender Firewall policy to its default state."
 set "T_CHANGE=Runs netsh advfirewall reset after explicit confirmation."
 set "T_WHY=Useful only for firewall-policy troubleshooting; custom firewall rules are removed."
 set "T_RISK=EXPERIMENTAL"
 set "T_SUPPORT=Windows 10 1903+ and Windows 11"
 set "T_MINBUILD=18362"
 set "T_HARDWARE=Administrator"
 set "T_MODE=ACTION"
 set "T_KEY="
 set "T_VALUE="
 set "T_REGTYPE="
 set "T_NEW="
 set "T_RESTART=No"
 set "T_BACKUP=Operation-specific backup"
 set "T_APPLY=Native Windows command after preview and confirmation"
 set "T_VALIDATE=Native command exit status and operation-specific check"
 set "T_REVERT=Not applicable for read-only or irreversible operation"
 set "T_DEPENDENCIES=Administrator; explicit confirmation"
 set "T_CONFLICTS=Removes custom firewall rules"
 set "T_ERROR=Stops on command or validation failure; records the failure in the activity log."
 exit /b 0
)
exit /b 1

:ExitNoAdmin
endlocal
exit /b 1

:Exit
call :Log "ADEX exited."
cls
echo ADEX has exited. Logs, reports, and backups remain in ADEX-data.
endlocal
exit /b 0
