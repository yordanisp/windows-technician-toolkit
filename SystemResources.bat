@echo off
REM Version history:
REM v1.0 - Core system, network, disk, repair, security, and technician tools.
REM v1.1 - HTML reporting, hardware/software exports, printer diagnostics, and release display.
net session >nul 2>&1
if errorlevel 1 (
	powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
	exit /b
)
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"
set "TOOLKIT_VERSION=1.1"
set "TOOLKIT_RELEASE=v1.1 - Reporting and asset diagnostics"
color 0A
for /F "delims=" %%e in ('echo prompt $E^| cmd') do set "ESC=%%e"
set "GREEN=!ESC![92m"
set "BLUE=!ESC![94m"
set "YELLOW=!ESC![93m"
set "RED=!ESC![91m"
set "CYAN=!ESC![96m"
set "RESET=!ESC![0m"

set "LOGFILE=%TEMP%\SystemResources_%COMPUTERNAME%.log"
set "REPORT=%TEMP%\SystemReport_%COMPUTERNAME%.txt"
set "HTML_REPORT=%TEMP%\SystemReport_%COMPUTERNAME%.html"
set "ASSET_CSV=%TEMP%\Asset_%COMPUTERNAME%.csv"
set "SOFTWARE_CSV=%TEMP%\Software_%COMPUTERNAME%.csv"

if not exist "%LOGFILE%" echo SystemResources started on %date% %time% > "%LOGFILE%"

:menu
cls
echo !YELLOW!============================================!RESET!
echo !YELLOW!      Windows Technician Toolkit v%TOOLKIT_VERSION%!RESET!
echo !YELLOW!============================================!RESET!
echo !BLUE!Computer: %COMPUTERNAME%  User: %USERNAME%!RESET!
echo !BLUE!Release: %TOOLKIT_RELEASE%!RESET!
echo !BLUE!Log: %LOGFILE%!RESET!
echo.
echo !GREEN!1^) System information!RESET!
echo !GREEN!2^) Memory and CPU!RESET!
echo !GREEN!3^) Disk tools!RESET!
echo !GREEN!4^) Network tools!RESET!
echo !GREEN!5^) Windows repair!RESET!
echo !GREEN!6^) Security and administration!RESET!
echo !GREEN!7^) Generate technician report!RESET!
echo !GREEN!8^) Restart / shutdown!RESET!
echo !GREEN!9^) Open Windows tools!RESET!
echo !GREEN!0^) Exit!RESET!
echo !YELLOW!============================================!RESET!
set "option="
set /p "option=Choose an option: "
if "%option%"=="1" goto system_menu
if "%option%"=="2" goto performance_menu
if "%option%"=="3" goto disk_menu
if "%option%"=="4" goto network_menu
if "%option%"=="5" goto repair_menu
if "%option%"=="6" goto admin_menu
if "%option%"=="7" goto report_menu
if "%option%"=="8" goto power_menu
if "%option%"=="9" goto tools_menu
if "%option%"=="0" goto end
echo !RED!Invalid option.!RESET!
pause
goto menu

:system_menu
cls
echo !YELLOW!=== System information ===!RESET!
echo !GREEN!1^) Complete system summary!RESET!
echo !GREEN!2^) Windows version and build!RESET!
echo !GREEN!3^) Computer serial number and model!RESET!
echo !GREEN!4^) Logged-on user and domain!RESET!
echo !GREEN!5^) Uptime and last boot!RESET!
echo !GREEN!0^) Return!RESET!
set "choice="
set /p "choice=Choose an option: "
if "%choice%"=="1" call :system_summary
if "%choice%"=="2" ver & powershell -NoProfile -Command "Get-CimInstance Win32_OperatingSystem | Select Caption,Version,BuildNumber,OSArchitecture | Format-List"
if "%choice%"=="3" powershell -NoProfile -Command "$computer=Get-CimInstance Win32_ComputerSystem; $bios=Get-CimInstance Win32_BIOS; [PSCustomObject]@{Manufacturer=$computer.Manufacturer; Model=$computer.Model; SerialNumber=$bios.SerialNumber} | Format-List"
if "%choice%"=="4" whoami /all
if "%choice%"=="5" call :uptime
if "%choice%"=="0" goto menu
if not "%choice%"=="0" pause
goto system_menu

:performance_menu
cls
echo !YELLOW!=== Memory and CPU ===!RESET!
echo !GREEN!1^) Memory usage!RESET!
echo !GREEN!2^) Physical RAM modules!RESET!
echo !GREEN!3^) CPU information!RESET!
echo !GREEN!4^) Top processes by CPU and RAM!RESET!
echo !GREEN!5^) Open Resource Monitor!RESET!
echo !GREEN!6^) Open Task Manager!RESET!
echo !GREEN!0^) Return!RESET!
set "choice="
set /p "choice=Choose an option: "
if "%choice%"=="1" call :memory
if "%choice%"=="2" powershell -NoProfile -Command "Get-CimInstance Win32_PhysicalMemory | Select BankLabel,Manufacturer,@{N='CapacityGB';E={[math]::Round($_.Capacity/1GB,2)}},Speed,PartNumber | Format-Table -AutoSize"
if "%choice%"=="3" powershell -NoProfile -Command "Get-CimInstance Win32_Processor | Select Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed | Format-List"
if "%choice%"=="4" powershell -NoProfile -Command "Get-Process | Sort CPU -Descending -ErrorAction SilentlyContinue | Select -First 15 Name,Id,CPU,@{N='RAM_MB';E={[math]::Round($_.WorkingSet64/1MB,1)}} | Format-Table -AutoSize"
if "%choice%"=="5" start "" resmon.exe
if "%choice%"=="6" start "" taskmgr.exe
if "%choice%"=="0" goto menu
if not "%choice%"=="0" pause
goto performance_menu

:disk_menu
cls
echo !YELLOW!=== Disk tools ===!RESET!
echo !GREEN!1^) Disk space!RESET!
echo !GREEN!2^) Disk health and status!RESET!
echo !GREEN!3^) Windows Disk Cleanup!RESET!
echo !GREEN!4^) Scan system drive with CHKDSK!RESET!
echo !GREEN!5^) Open Disk Management!RESET!
echo !GREEN!0^) Return!RESET!
set "choice="
set /p "choice=Choose an option: "
if "%choice%"=="1" powershell -NoProfile -Command "Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | Select DeviceID,VolumeName,@{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}},@{N='FreeGB';E={[math]::Round($_.FreeSpace/1GB,2)}},@{N='FreePercent';E={[math]::Round($_.FreeSpace/$_.Size*100,1)}} | Format-Table -AutoSize"
if "%choice%"=="2" powershell -NoProfile -Command "Get-PhysicalDisk | Select FriendlyName,MediaType,HealthStatus,OperationalStatus,@{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}} | Format-Table -AutoSize"
if "%choice%"=="3" cleanmgr.exe /verylowdisk
if "%choice%"=="4" chkdsk %SystemDrive% /scan
if "%choice%"=="5" start "" diskmgmt.msc
if "%choice%"=="0" goto menu
if not "%choice%"=="0" pause
goto disk_menu

:network_menu
cls
echo !YELLOW!=== Network tools ===!RESET!
echo !GREEN!1^) Full network configuration!RESET!
echo !GREEN!2^) Test gateway, DNS and Internet!RESET!
echo !GREEN!3^) Flush DNS cache!RESET!
echo !GREEN!4^) Force Group Policy update!RESET!
echo !GREEN!5^) Release and renew IP address!RESET!
echo !GREEN!6^) Reset Winsock and TCP/IP!RESET!
echo !GREEN!7^) Show route and ARP table!RESET!
echo !GREEN!8^) Restart a network adapter!RESET!
echo !GREEN!0^) Return!RESET!
set "choice="
set /p "choice=Choose an option: "
if "%choice%"=="1" ipconfig /all
if "%choice%"=="2" call :network_test
if "%choice%"=="3" ipconfig /flushdns
if "%choice%"=="4" gpupdate /force
if "%choice%"=="5" ipconfig /release & ipconfig /renew
if "%choice%"=="6" call :admin_required netsh int ip reset & netsh winsock reset
if "%choice%"=="7" route print & arp -a
if "%choice%"=="8" call :adapter_restart
if "%choice%"=="0" goto menu
if not "%choice%"=="0" pause
goto network_menu

:repair_menu
cls
echo !YELLOW!=== Windows repair ===!RESET!
echo !GREEN!1^) System File Checker: SFC /scannow!RESET!
echo !GREEN!2^) DISM component store repair!RESET!
echo !GREEN!3^) Restart Windows Update services!RESET!
echo !GREEN!4^) Clear Windows Update cache!RESET!
echo !GREEN!5^) Create system restore point!RESET!
echo !GREEN!6^) Check Windows Update status!RESET!
echo !GREEN!0^) Return!RESET!
set "choice="
set /p "choice=Choose an option: "
if "%choice%"=="1" call :admin_required sfc /scannow
if "%choice%"=="2" call :admin_required DISM /Online /Cleanup-Image /RestoreHealth
if "%choice%"=="3" call :update_services
if "%choice%"=="4" call :update_cache
if "%choice%"=="5" powershell -NoProfile -Command "Checkpoint-Computer -Description 'Technician Toolkit Restore Point' -RestorePointType MODIFY_SETTINGS"
if "%choice%"=="6" powershell -NoProfile -Command "Get-Service wuauserv,bits,cryptsvc | Select Name,Status,StartType | Format-Table -AutoSize"
if "%choice%"=="0" goto menu
if not "%choice%"=="0" pause
goto repair_menu

:admin_menu
cls
echo !YELLOW!=== Security and administration ===!RESET!
echo !GREEN!1^) Windows Defender status!RESET!
echo !GREEN!2^) Run Defender quick scan!RESET!
echo !GREEN!3^) Windows Firewall profiles!RESET!
echo !GREEN!4^) Local users!RESET!
echo !GREEN!5^) Installed applications!RESET!
echo !GREEN!6^) Recent system errors!RESET!
echo !GREEN!7^) Active sessions!RESET!
echo !GREEN!8^) Enable built-in Local Administrator!RESET!
echo !GREEN!9^) Set password for built-in Local Administrator!RESET!
echo !GREEN!10^) Disable built-in Local Administrator!RESET!
echo !GREEN!11^) Printer diagnostics!RESET!
echo !GREEN!0^) Return!RESET!
set "choice="
set /p "choice=Choose an option: "
if "%choice%"=="1" powershell -NoProfile -Command "Get-MpComputerStatus | Select AMServiceEnabled,AntivirusEnabled,RealTimeProtectionEnabled,QuickScanAge,FullScanAge | Format-List"
if "%choice%"=="2" call :admin_required powershell -NoProfile -Command "Start-MpScan -ScanType QuickScan"
if "%choice%"=="3" netsh advfirewall show allprofiles
if "%choice%"=="4" powershell -NoProfile -Command "Get-LocalUser | Select Name,Enabled,PasswordRequired,LastLogon,Description | Format-Table -AutoSize"
if "%choice%"=="5" powershell -NoProfile -Command "Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*,HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue | Where DisplayName | Select DisplayName,DisplayVersion,Publisher | Sort DisplayName | Format-Table -AutoSize"
if "%choice%"=="6" powershell -NoProfile -Command "Get-WinEvent -FilterHashtable @{LogName='System';Level=2} -MaxEvents 20 | Select TimeCreated,ProviderName,Id,Message | Format-List"
if "%choice%"=="7" qwinsta
if "%choice%"=="8" call :enable_local_admin
if "%choice%"=="9" call :set_local_admin_password
if "%choice%"=="10" call :disable_local_admin
if "%choice%"=="11" call :printer_diagnostics
if "%choice%"=="0" goto menu
if not "%choice%"=="0" pause
goto admin_menu

:report_menu
cls
echo !YELLOW!=== Technician report ===!RESET!
echo !GREEN!1^) Generate report!RESET!
echo !GREEN!2^) Generate HTML report!RESET!
echo !GREEN!3^) Export hardware asset CSV!RESET!
echo !GREEN!4^) Export installed software CSV!RESET!
echo !GREEN!5^) Open report folder!RESET!
echo !GREEN!0^) Return!RESET!
set "choice="
set /p "choice=Choose an option: "
if "%choice%"=="1" call :generate_report
if "%choice%"=="2" call :generate_html_report
if "%choice%"=="3" call :export_asset_csv
if "%choice%"=="4" call :export_software_csv
if "%choice%"=="5" start "" "%TEMP%"
if "%choice%"=="0" goto menu
if not "%choice%"=="0" pause
goto report_menu

:power_menu
cls
echo !YELLOW!=== Restart / shutdown ===!RESET!
echo !GREEN!1^) Restart in 30 seconds!RESET!
echo !GREEN!2^) Shutdown in 30 seconds!RESET!
echo !GREEN!3^) Cancel pending shutdown or restart!RESET!
echo !GREEN!0^) Return!RESET!
set "choice="
set /p "choice=Choose an option: "
if "%choice%"=="1" shutdown /r /t 30 /c "Restart requested by technician"
if "%choice%"=="2" shutdown /s /t 30 /c "Shutdown requested by technician"
if "%choice%"=="3" shutdown /a
if "%choice%"=="0" goto menu
if not "%choice%"=="0" pause
goto power_menu

:tools_menu
cls
echo !YELLOW!=== Open Windows tools ===!RESET!
echo !GREEN!1^) Event Viewer!RESET!
echo !GREEN!2^) Services!RESET!
echo !GREEN!3^) Device Manager!RESET!
echo !GREEN!4^) System Information!RESET!
echo !GREEN!5^) Computer Management!RESET!
echo !GREEN!6^) Windows Update!RESET!
echo !GREEN!0^) Return!RESET!
set "choice="
set /p "choice=Choose an option: "
if "%choice%"=="1" start "" eventvwr.msc
if "%choice%"=="2" start "" services.msc
if "%choice%"=="3" start "" devmgmt.msc
if "%choice%"=="4" start "" msinfo32.exe
if "%choice%"=="5" start "" compmgmt.msc
if "%choice%"=="6" start "" ms-settings:windowsupdate
if "%choice%"=="0" goto menu
if not "%choice%"=="0" pause
goto tools_menu

:system_summary
echo !CYAN!=== System summary ===!RESET!
hostname
whoami
ver
powershell -NoProfile -Command "Get-CimInstance Win32_ComputerSystem | Select Manufacturer,Model,Domain,TotalPhysicalMemory | Format-List"
powershell -NoProfile -Command "Get-CimInstance Win32_BIOS | Select SerialNumber,SMBIOSBIOSVersion | Format-List"
call :uptime
exit /b

:memory
echo !CYAN!=== Memory usage ===!RESET!
powershell -NoProfile -Command "$os=Get-CimInstance Win32_OperatingSystem; $total=[math]::Round($os.TotalVisibleMemorySize/1MB,2); $free=[math]::Round($os.FreePhysicalMemory/1MB,2); $used=[math]::Round($total-$free,2); Write-Output ('Total: {0} GB | Used: {1} GB | Free: {2} GB | Usage: {3}%%' -f $total,$used,$free,[math]::Round($used/$total*100,1))"
exit /b

:uptime
powershell -NoProfile -Command "$os=Get-CimInstance Win32_OperatingSystem; $u=(Get-Date)-$os.LastBootUpTime; Write-Output ('Last boot: {0} | Uptime: {1} days, {2} hours, {3} minutes' -f $os.LastBootUpTime,$u.Days,$u.Hours,$u.Minutes)"
exit /b

:network_test
echo !CYAN!=== Network test ===!RESET!
for /f "tokens=2 delims=:" %%G in ('ipconfig ^| findstr /i "Default Gateway"') do if not "%%G"=="" set "gateway=%%G"
set "gateway=!gateway: =!"
echo Gateway: !gateway!
if defined gateway ping -n 2 !gateway!
echo DNS:
nslookup www.microsoft.com
echo Internet:
ping -n 2 1.1.1.1
exit /b

:adapter_restart
echo Available adapters:
powershell -NoProfile -Command "Get-NetAdapter | Select Name,Status,LinkSpeed,MacAddress | Format-Table -AutoSize"
set "adapter="
set /p "adapter=Enter adapter name to restart: "
powershell -NoProfile -Command "Restart-NetAdapter -Name '%adapter%' -Confirm:$false"
exit /b

:update_services
call :admin_required net stop wuauserv
call :admin_required net stop bits
call :admin_required net stop cryptsvc
call :admin_required net start cryptsvc
call :admin_required net start bits
call :admin_required net start wuauserv
exit /b

:update_cache
call :admin_required net stop wuauserv
call :admin_required net stop bits
if exist "%windir%\SoftwareDistribution.old" rmdir /s /q "%windir%\SoftwareDistribution.old"
call :admin_required ren "%windir%\SoftwareDistribution" SoftwareDistribution.old
call :admin_required net start bits
call :admin_required net start wuauserv
exit /b

:generate_report
echo !BLUE!Generating report at %REPORT%...!RESET!
(
echo Windows Technician Report
echo Date: %date% %time%
echo Computer: %COMPUTERNAME%
echo User: %USERNAME%
echo.
hostname
whoami
ver
ipconfig /all
systeminfo
) > "%REPORT%"
echo !GREEN!Report saved to: %REPORT%!RESET!
start "" notepad.exe "%REPORT%"
exit /b

:generate_html_report
echo !BLUE!Generating HTML report at %HTML_REPORT%...!RESET!
powershell -NoProfile -Command "$computer=Get-CimInstance Win32_ComputerSystem; $bios=Get-CimInstance Win32_BIOS; $os=Get-CimInstance Win32_OperatingSystem; $data=[PSCustomObject]@{Computer=$env:COMPUTERNAME; User=$env:USERNAME; Manufacturer=$computer.Manufacturer; Model=$computer.Model; SerialNumber=$bios.SerialNumber; OS=$os.Caption; Version=$os.Version; LastBoot=$os.LastBootUpTime}; $data | ConvertTo-Html -Title 'Windows Technician Report' -PreContent '<h1>Windows Technician Report</h1>' | Out-File -FilePath '%HTML_REPORT%' -Encoding UTF8"
echo !GREEN!HTML report saved to: %HTML_REPORT%!RESET!
start "" "%HTML_REPORT%"
exit /b

:export_asset_csv
echo !BLUE!Exporting hardware asset data to %ASSET_CSV%...!RESET!
powershell -NoProfile -Command "$computer=Get-CimInstance Win32_ComputerSystem; $bios=Get-CimInstance Win32_BIOS; $os=Get-CimInstance Win32_OperatingSystem; $cpu=Get-CimInstance Win32_Processor | Select-Object -First 1; $ram=[math]::Round($computer.TotalPhysicalMemory/1GB,2); [PSCustomObject]@{AssetTag=$env:COMPUTERNAME; ComputerName=$env:COMPUTERNAME; Manufacturer=$computer.Manufacturer; Model=$computer.Model; SerialNumber=$bios.SerialNumber; OperatingSystem=$os.Caption; OSVersion=$os.Version; CPU=$cpu.Name; RAMGB=$ram; User=$env:USERNAME; ExportedAt=(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')} | Export-Csv -Path '%ASSET_CSV%' -NoTypeInformation -Encoding UTF8"
echo !GREEN!Asset CSV saved to: %ASSET_CSV%!RESET!
exit /b

:export_software_csv
echo !BLUE!Exporting installed software to %SOFTWARE_CSV%...!RESET!
powershell -NoProfile -Command "Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue | Where-Object DisplayName | Select-Object DisplayName,DisplayVersion,Publisher,InstallDate | Sort-Object DisplayName | Export-Csv -Path '%SOFTWARE_CSV%' -NoTypeInformation -Encoding UTF8"
echo !GREEN!Software CSV saved to: %SOFTWARE_CSV%!RESET!
exit /b

:printer_diagnostics
echo !CYAN!=== Printer diagnostics ===!RESET!
powershell -NoProfile -Command "Get-CimInstance Win32_Printer | Select-Object Name,Default,PrinterStatus,WorkOffline,DriverName,PortName | Format-Table -AutoSize"
exit /b

:enable_local_admin
echo.
echo !RED!WARNING: This enables the built-in local Administrator account.!RESET!
echo !YELLOW!Use a strong password and disable the account when it is no longer needed.!RESET!
set "confirm="
set /p "confirm=Type ENABLE to continue: "
if /I not "!confirm!"=="ENABLE" (
	echo !RED!Operation cancelled.!RESET!
	exit /b 1
)
call :admin_required powershell -NoProfile -Command "$user=Get-CimInstance Win32_UserAccount -Filter 'LocalAccount=True' | Where-Object SID -like '*-500'; if ($user) { net user $user.Name /active:yes; Write-Output ('Enabled built-in local administrator: ' + $user.Name) } else { Write-Error 'Built-in local Administrator account was not found.'; exit 1 }"
if not errorlevel 1 call :audit "Enabled built-in local Administrator"
exit /b

:set_local_admin_password
echo.
echo !YELLOW!The password will be entered securely and will not be displayed.!RESET!
echo !YELLOW!This changes the password of the built-in local Administrator account.!RESET!
call :admin_required powershell -NoProfile -Command "$user=Get-LocalUser | Where-Object { $_.SID.Value -like '*-500' }; if (-not $user) { Write-Error 'Built-in local Administrator account was not found.'; exit 1 }; $password=Read-Host ('New password for ' + $user.Name) -AsSecureString; $confirm=Read-Host 'Confirm new password' -AsSecureString; $bstr1=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($password); $bstr2=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($confirm); try { $plain1=[Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr1); $plain2=[Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr2); if ($plain1 -cne $plain2) { Write-Error 'Passwords do not match.'; exit 1 } } finally { if ($bstr1 -ne [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr1) }; if ($bstr2 -ne [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr2) } }; Set-LocalUser -Name $user.Name -Password $password; Write-Output ('Password updated for built-in local Administrator: ' + $user.Name)"
if not errorlevel 1 call :audit "Changed built-in local Administrator password"
exit /b

:disable_local_admin
echo.
echo !RED!WARNING: This disables the built-in local Administrator account.!RESET!
set "confirm="
set /p "confirm=Type DISABLE to continue: "
if /I not "!confirm!"=="DISABLE" (
	echo !RED!Operation cancelled.!RESET!
	exit /b 1
)
call :admin_required powershell -NoProfile -Command "$user=Get-CimInstance Win32_UserAccount -Filter 'LocalAccount=True' | Where-Object SID -like '*-500'; if ($user) { net user $user.Name /active:no; Write-Output ('Disabled built-in local administrator: ' + $user.Name) } else { Write-Error 'Built-in local Administrator account was not found.'; exit 1 }"
if not errorlevel 1 call :audit "Disabled built-in local Administrator"
exit /b

:audit
>>"%LOGFILE%" echo %date% %time% - %USERNAME% on %COMPUTERNAME% - %~1
exit /b

:admin_required
net session >nul 2>&1
if not errorlevel 1 goto admin_run
echo !RED!This action requires Administrator privileges.!RESET!
echo !YELLOW!Right-click the BAT file and choose Run as administrator.!RESET!
exit /b 1
:admin_run
%*
exit /b

:end
echo !BLUE!Exiting.!RESET!
endlocal
exit /b 0
