@echo off
REM ============================================================
REM Windows Technician Toolkit
REM Version history:
REM v1.0 - Original technician toolkit.
REM v1.1 - Organized menus, SCCM tools, unique Windows maintenance menu.
REM v1.2 - Safe temporary-file and Windows component cleanup.
REM v1.3 - Health check, centralized reports, improved SCCM diagnostics, and interactive cleanup.
REM ============================================================

net session >nul 2>&1
if errorlevel 1 (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"
set "TOOLKIT_VERSION=1.3"
set "TOOLKIT_RELEASE=Health checks and improved diagnostics"
set "REPORT_DIR=%~dp0Reports"
set "LOGFILE=%TEMP%\SystemResources_%COMPUTERNAME%.log"
set "REPORT=%REPORT_DIR%\SystemReport_%COMPUTERNAME%.txt"
set "HTML_REPORT=%REPORT_DIR%\SystemReport_%COMPUTERNAME%.html"
set "ASSET_CSV=%REPORT_DIR%\Asset_%COMPUTERNAME%.csv"
set "SOFTWARE_CSV=%REPORT_DIR%\Software_%COMPUTERNAME%.csv"
set "VERSION_LOG=%~dp0SystemResources_versions.log"

color 0A
for /F "delims=" %%e in ('echo prompt $E^| cmd') do set "ESC=%%e"
set "GREEN=!ESC![92m"
set "BLUE=!ESC![94m"
set "YELLOW=!ESC![93m"
set "RED=!ESC![91m"
set "CYAN=!ESC![96m"
set "RESET=!ESC![0m"

if not exist "%LOGFILE%" echo SystemResources started on %date% %time% > "%LOGFILE%"
if not exist "%VERSION_LOG%" echo %date% %time% - SystemResources v%TOOLKIT_VERSION% - %TOOLKIT_RELEASE% > "%VERSION_LOG%"
if not exist "%REPORT_DIR%" mkdir "%REPORT_DIR%"

:menu
cls
echo !YELLOW!================================================!RESET!
echo !YELLOW!       Windows Technician Toolkit v%TOOLKIT_VERSION%!RESET!
echo !YELLOW!================================================!RESET!
echo !BLUE!Computer: %COMPUTERNAME%  User: %USERNAME%!RESET!
echo !BLUE!Release: %TOOLKIT_RELEASE%!RESET!
echo.
echo !GREEN!1^) System information!RESET!
echo !GREEN!2^) Performance!RESET!
echo !GREEN!3^) Storage!RESET!
echo !GREEN!4^) Network!RESET!
echo !GREEN!5^) Windows maintenance!RESET!
echo !GREEN!6^) SCCM / Configuration Manager!RESET!
echo !GREEN!7^) Reports and exports!RESET!
echo !GREEN!8^) Power options!RESET!
echo !GREEN!9^) Security and administration!RESET!
echo !GREEN!10^) Windows tools!RESET!
echo !GREEN!11^) System health check!RESET!
echo !GREEN!0^) Exit!RESET!
echo.
set "option="
set /p "option=Choose an option: "
if "%option%"=="1" goto system_menu
if "%option%"=="2" goto performance_menu
if "%option%"=="3" goto storage_menu
if "%option%"=="4" goto network_menu
if "%option%"=="5" goto maintenance_menu
if "%option%"=="6" goto sccm_menu
if "%option%"=="7" goto report_menu
if "%option%"=="8" goto power_menu
if "%option%"=="9" goto security_menu
if "%option%"=="10" goto tools_menu
if "%option%"=="11" call :health_check & pause & goto menu
if "%option%"=="0" goto end
echo !RED!Invalid option.!RESET!
pause
goto menu

:system_menu
cls
echo !YELLOW!=== System information ===!RESET!
echo !GREEN!1^) Computer identity!RESET!
echo !GREEN!2^) Windows version and build!RESET!
echo !GREEN!3^) Logged-on user and domain!RESET!
echo !GREEN!4^) Uptime and last boot!RESET!
echo !GREEN!0^) Main menu!RESET!
set "choice="
set /p "choice=Choose an option: "
if "%choice%"=="1" call :computer_identity
if "%choice%"=="2" ver & powershell -NoProfile -Command "Get-CimInstance Win32_OperatingSystem | Select Caption,Version,BuildNumber,OSArchitecture | Format-List"
if "%choice%"=="3" whoami /all
if "%choice%"=="4" call :uptime
if "%choice%"=="0" goto menu
if not "%choice%"=="0" pause
goto system_menu

:performance_menu
cls
echo !YELLOW!=== Performance ===!RESET!
echo !GREEN!1^) Memory usage!RESET!
echo !GREEN!2^) Physical memory modules!RESET!
echo !GREEN!3^) CPU information!RESET!
echo !GREEN!4^) Top processes!RESET!
echo !GREEN!5^) Open Task Manager!RESET!
echo !GREEN!0^) Main menu!RESET!
set "choice="
set /p "choice=Choose an option: "
if "%choice%"=="1" call :memory
if "%choice%"=="2" powershell -NoProfile -Command "Get-CimInstance Win32_PhysicalMemory | Select BankLabel,Manufacturer,@{N='CapacityGB';E={[math]::Round($_.Capacity/1GB,2)}},Speed,PartNumber | Format-Table -AutoSize"
if "%choice%"=="3" powershell -NoProfile -Command "Get-CimInstance Win32_Processor | Select Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed | Format-List"
if "%choice%"=="4" powershell -NoProfile -Command "Get-Process | Sort CPU -Descending -ErrorAction SilentlyContinue | Select -First 15 Name,Id,CPU,@{N='RAM_MB';E={[math]::Round($_.WorkingSet64/1MB,1)}} | Format-Table -AutoSize"
if "%choice%"=="5" start "" taskmgr.exe
if "%choice%"=="0" goto menu
if not "%choice%"=="0" pause
goto performance_menu

:storage_menu
cls
echo !YELLOW!=== Storage ===!RESET!
echo !GREEN!1^) Disk space!RESET!
echo !GREEN!2^) Disk health and status!RESET!
echo !GREEN!3^) Scan system drive with CHKDSK!RESET!
echo !GREEN!4^) Windows Disk Cleanup!RESET!
echo !GREEN!5^) Open Disk Management!RESET!
echo !GREEN!6^) Clean temporary and unnecessary files!RESET!
echo !GREEN!7^) Preview cleanup space!RESET!
echo !GREEN!0^) Main menu!RESET!
set "choice="
set /p "choice=Choose an option: "
if "%choice%"=="1" powershell -NoProfile -Command "Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | Select DeviceID,VolumeName,@{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}},@{N='FreeGB';E={[math]::Round($_.FreeSpace/1GB,2)}},@{N='FreePercent';E={[math]::Round($_.FreeSpace/$_.Size*100,1)}} | Format-Table -AutoSize"
if "%choice%"=="2" powershell -NoProfile -Command "Get-PhysicalDisk | Select FriendlyName,MediaType,HealthStatus,OperationalStatus,@{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}} | Format-Table -AutoSize"
if "%choice%"=="3" chkdsk %SystemDrive% /scan
if "%choice%"=="4" cleanmgr.exe /verylowdisk
if "%choice%"=="5" start "" diskmgmt.msc
if "%choice%"=="6" call :disk_cleanup
if "%choice%"=="7" call :disk_cleanup_preview
if "%choice%"=="0" goto menu
if not "%choice%"=="0" pause
goto storage_menu

:network_menu
cls
echo !YELLOW!=== Network ===!RESET!
echo !GREEN!1^) Full network configuration!RESET!
echo !GREEN!2^) Test gateway, DNS and Internet!RESET!
echo !GREEN!3^) Flush DNS cache!RESET!
echo !GREEN!4^) Force Group Policy update!RESET!
echo !GREEN!5^) Release and renew IP address!RESET!
echo !GREEN!6^) Reset Winsock and TCP/IP!RESET!
echo !GREEN!7^) Show route and ARP table!RESET!
echo !GREEN!8^) Restart a network adapter!RESET!
echo !GREEN!0^) Main menu!RESET!
set "choice="
set /p "choice=Choose an option: "
if "%choice%"=="1" ipconfig /all
if "%choice%"=="2" call :network_test
if "%choice%"=="3" ipconfig /flushdns
if "%choice%"=="4" gpupdate /force
if "%choice%"=="5" ipconfig /release & ipconfig /renew
if "%choice%"=="6" netsh int ip reset & netsh winsock reset
if "%choice%"=="7" route print & arp -a
if "%choice%"=="8" call :adapter_restart
if "%choice%"=="0" goto menu
if not "%choice%"=="0" pause
goto network_menu

:maintenance_menu
cls
echo !GREEN!1^) System File Checker: SFC /scannow!RESET!
echo !GREEN!2^) DISM component store repair!RESET!
echo !GREEN!3^) Windows Update service status!RESET!
echo !GREEN!4^) Start Windows Update scan!RESET!
echo !GREEN!5^) Restart Windows Update services!RESET!
echo !GREEN!6^) Clear Windows Update cache!RESET!
echo !GREEN!7^) Create system restore point!RESET!
echo !GREEN!0^) Main menu!RESET!
set "choice="
set /p "choice=Choose an option: "
if "%choice%"=="1" call :admin_required sfc /scannow
if "%choice%"=="2" call :admin_required DISM /Online /Cleanup-Image /RestoreHealth
if "%choice%"=="3" powershell -NoProfile -Command "Get-Service wuauserv,bits,cryptsvc | Select Name,Status,StartType | Format-Table -AutoSize"
if "%choice%"=="4" powershell -NoProfile -Command "UsoClient StartScan"
if "%choice%"=="5" call :update_services
if "%choice%"=="6" call :update_cache
if "%choice%"=="7" powershell -NoProfile -Command "Checkpoint-Computer -Description 'Technician Toolkit Restore Point' -RestorePointType MODIFY_SETTINGS"
if "%choice%"=="0" goto menu
if not "%choice%"=="0" pause
goto maintenance_menu

:sccm_menu
cls
echo !YELLOW!=== SCCM / Configuration Manager ===!RESET!
echo !GREEN!1^) Client service and version!RESET!
echo !GREEN!2^) Client health summary!RESET!
echo !GREEN!3^) Trigger machine policy cycle!RESET!
echo !GREEN!4^) Trigger hardware inventory cycle!RESET!
echo !GREEN!5^) Trigger software inventory cycle!RESET!
echo !GREEN!6^) Trigger software update scan!RESET!
echo !GREEN!7^) Show CCMCache size and information!RESET!
echo !GREEN!8^) Open SCCM logs folder!RESET!
echo !GREEN!9^) Repair SCCM client!RESET!
echo !GREEN!0^) Main menu!RESET!
set "choice="
set /p "choice=Choose an option: "
if "%choice%"=="1" call :sccm_client_info
if "%choice%"=="2" call :sccm_health
if "%choice%"=="3" call :sccm_trigger "{00000000-0000-0000-0000-000000000021}" "Machine policy request"
if "%choice%"=="4" call :sccm_trigger "{00000000-0000-0000-0000-000000000001}" "Hardware inventory"
if "%choice%"=="5" call :sccm_trigger "{00000000-0000-0000-0000-000000000002}" "Software inventory"
if "%choice%"=="6" call :sccm_trigger "{00000000-0000-0000-0000-000000000113}" "Software update scan"
if "%choice%"=="7" powershell -NoProfile -Command "$cache=Get-CimInstance -Namespace root\ccm\SoftMgmtAgent -ClassName CCM_CacheConfig -ErrorAction SilentlyContinue; if($cache){$size=[math]::Round((Get-ChildItem $cache.Location -Force -Recurse -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum/1GB,2); [PSCustomObject]@{Location=$cache.Location; SizeGB=$size; MaxCacheGB=[math]::Round($cache.Size/1024,2)} | Format-List}else{Write-Output 'SCCM cache information unavailable.'}"
if "%choice%"=="8" start "" "%windir%\CCM\Logs"
if "%choice%"=="9" call :sccm_repair
if "%choice%"=="0" goto menu
if not "%choice%"=="0" pause
goto sccm_menu

:report_menu
cls
echo !YELLOW!=== Reports and exports ===!RESET!
echo !GREEN!1^) Generate text report!RESET!
echo !GREEN!2^) Generate HTML report!RESET!
echo !GREEN!3^) Export hardware asset CSV!RESET!
echo !GREEN!4^) Export installed software CSV!RESET!
echo !GREEN!5^) Printer diagnostics!RESET!
echo !GREEN!6^) Open report folder!RESET!
echo !GREEN!0^) Main menu!RESET!
set "choice="
set /p "choice=Choose an option: "
if "%choice%"=="1" call :generate_report
if "%choice%"=="2" call :generate_html_report
if "%choice%"=="3" call :export_asset_csv
if "%choice%"=="4" call :export_software_csv
if "%choice%"=="5" call :printer_diagnostics
if "%choice%"=="6" start "" "%REPORT_DIR%"
if "%choice%"=="0" goto menu
if not "%choice%"=="0" pause
goto report_menu

:power_menu
cls
echo !YELLOW!=== Power options ===!RESET!
echo !GREEN!1^) Restart in 30 seconds!RESET!
echo !GREEN!2^) Shutdown in 30 seconds!RESET!
echo !GREEN!3^) Cancel pending restart or shutdown!RESET!
echo !GREEN!0^) Main menu!RESET!
set "choice="
set /p "choice=Choose an option: "
if "%choice%"=="1" shutdown /r /t 30 /c "Restart requested by technician"
if "%choice%"=="2" shutdown /s /t 30 /c "Shutdown requested by technician"
if "%choice%"=="3" shutdown /a
if "%choice%"=="0" goto menu
if not "%choice%"=="0" pause
goto power_menu

:security_menu
cls
echo !YELLOW!=== Security and administration ===!RESET!
echo !GREEN!1^) Windows Defender status!RESET!
echo !GREEN!2^) Run Defender quick scan!RESET!
echo !GREEN!3^) Windows Firewall profiles!RESET!
echo !GREEN!4^) Local users!RESET!
echo !GREEN!5^) Recent system errors!RESET!
echo !GREEN!6^) Active sessions!RESET!
echo !GREEN!7^) Enable built-in Local Administrator!RESET!
echo !GREEN!8^) Set built-in Local Administrator password!RESET!
echo !GREEN!9^) Disable built-in Local Administrator!RESET!
echo !GREEN!0^) Main menu!RESET!
set "choice="
set /p "choice=Choose an option: "
if "%choice%"=="1" powershell -NoProfile -Command "Get-MpComputerStatus | Select AMServiceEnabled,AntivirusEnabled,RealTimeProtectionEnabled,QuickScanAge,FullScanAge | Format-List"
if "%choice%"=="2" call :admin_required powershell -NoProfile -Command "Start-MpScan -ScanType QuickScan"
if "%choice%"=="3" netsh advfirewall show allprofiles
if "%choice%"=="4" powershell -NoProfile -Command "Get-LocalUser | Select Name,Enabled,PasswordRequired,LastLogon | Format-Table -AutoSize"
if "%choice%"=="5" powershell -NoProfile -Command "Get-WinEvent -FilterHashtable @{LogName='System';Level=2} -MaxEvents 20 | Select TimeCreated,ProviderName,Id,Message | Format-List"
if "%choice%"=="6" qwinsta
if "%choice%"=="7" call :enable_local_admin
if "%choice%"=="8" call :set_local_admin_password
if "%choice%"=="9" call :disable_local_admin
if "%choice%"=="0" goto menu
if not "%choice%"=="0" pause
goto security_menu

:tools_menu
cls
echo !YELLOW!=== Windows tools ===!RESET!
echo !GREEN!1^) Event Viewer!RESET!
echo !GREEN!2^) Services!RESET!
echo !GREEN!3^) Device Manager!RESET!
echo !GREEN!4^) System Information!RESET!
echo !GREEN!5^) Computer Management!RESET!
echo !GREEN!6^) Resource Monitor!RESET!
echo !GREEN!0^) Main menu!RESET!
set "choice="
set /p "choice=Choose an option: "
if "%choice%"=="1" start "" eventvwr.msc
if "%choice%"=="2" start "" services.msc
if "%choice%"=="3" start "" devmgmt.msc
if "%choice%"=="4" start "" msinfo32.exe
if "%choice%"=="5" start "" compmgmt.msc
if "%choice%"=="6" start "" resmon.exe
if "%choice%"=="0" goto menu
if not "%choice%"=="0" pause
goto tools_menu

:computer_identity
powershell -NoProfile -Command "$computer=Get-CimInstance Win32_ComputerSystem; $bios=Get-CimInstance Win32_BIOS; [PSCustomObject]@{Manufacturer=$computer.Manufacturer; Model=$computer.Model; SerialNumber=$bios.SerialNumber; Domain=$computer.Domain} | Format-List"
exit /b

:memory
powershell -NoProfile -Command "$os=Get-CimInstance Win32_OperatingSystem; $total=[math]::Round($os.TotalVisibleMemorySize/1MB,2); $free=[math]::Round($os.FreePhysicalMemory/1MB,2); $used=[math]::Round($total-$free,2); Write-Output ('Total: {0} GB | Used: {1} GB | Free: {2} GB | Usage: {3}%%' -f $total,$used,$free,[math]::Round($used/$total*100,1))"
exit /b

:uptime
powershell -NoProfile -Command "$os=Get-CimInstance Win32_OperatingSystem; $u=(Get-Date)-$os.LastBootUpTime; Write-Output ('Last boot: {0} | Uptime: {1} days, {2} hours, {3} minutes' -f $os.LastBootUpTime,$u.Days,$u.Hours,$u.Minutes)"
exit /b

:network_test
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

:disk_cleanup
echo.
echo !YELLOW!This will remove temporary files, Windows error reports, and Recycle Bin contents.!RESET!
echo !YELLOW!Personal documents and inventory files will not be touched.!RESET!
set "confirm="
set /p "confirm=Type CLEAN to continue: "
if /I not "!confirm!"=="CLEAN" (
    echo !RED!Cleanup cancelled.!RESET!
    exit /b
)
powershell -NoProfile -Command "$drive=Get-PSDrive -Name $env:SystemDrive.Substring(0,1); $before=$drive.Free; $paths=@($env:TEMP,(Join-Path $env:WINDIR 'Temp'),(Join-Path $env:ProgramData 'Microsoft\Windows\WER\ReportArchive'),(Join-Path $env:ProgramData 'Microsoft\Windows\WER\ReportQueue')); foreach($path in $paths){if(Test-Path -LiteralPath $path){Get-ChildItem -LiteralPath $path -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue}}; Clear-RecycleBin -Force -ErrorAction SilentlyContinue; $after=(Get-PSDrive -Name $env:SystemDrive.Substring(0,1)).Free; $freed=[math]::Round(($after-$before)/1GB,2); Write-Output ('Cleanup completed. Space freed: {0} GB' -f $freed)"
exit /b

:disk_cleanup_preview
echo !CYAN!=== Cleanup preview ===!RESET!
powershell -NoProfile -Command "$paths=@($env:TEMP,(Join-Path $env:WINDIR 'Temp'),(Join-Path $env:ProgramData 'Microsoft\Windows\WER\ReportArchive'),(Join-Path $env:ProgramData 'Microsoft\Windows\WER\ReportQueue')); foreach($path in $paths){if(Test-Path $path){$size=[math]::Round((Get-ChildItem $path -Force -Recurse -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum/1MB,1); [PSCustomObject]@{Location=$path; SizeMB=$size}}} | Format-Table -AutoSize"
echo !YELLOW!Preview only. Use option 6 to clean these locations.!RESET!
exit /b

:health_check
echo !CYAN!=== System health check ===!RESET!
powershell -NoProfile -Command "$os=Get-CimInstance Win32_OperatingSystem; $disk=Get-CimInstance Win32_LogicalDisk -Filter \"DeviceID='$env:SystemDrive'\"; $defender=Get-MpComputerStatus -ErrorAction SilentlyContinue; $updates=Get-Service wuauserv -ErrorAction SilentlyContinue; $sccm=Get-Service CcmExec -ErrorAction SilentlyContinue; [PSCustomObject]@{Computer=$env:COMPUTERNAME; OS=$os.Caption; SystemDriveFreeGB=[math]::Round($disk.FreeSpace/1GB,2); Defender=if($defender){if($defender.RealTimeProtectionEnabled){'Enabled'}else{'Disabled'}}else{'Unavailable'}; WindowsUpdate=if($updates){$updates.Status}else{'Unavailable'}; SCCM=if($sccm){$sccm.Status}else{'Not installed'}; PendingReboot=(Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending')} | Format-List"
exit /b

:sccm_client_info
powershell -NoProfile -Command "$service=Get-Service CcmExec -ErrorAction SilentlyContinue; $client=Get-CimInstance -Namespace root\ccm -ClassName SMS_Client -ErrorAction SilentlyContinue; $version=(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client' -ErrorAction SilentlyContinue).ClientVersion; [PSCustomObject]@{Service=if($service){$service.Status}else{'Not installed'}; ClientVersion=$version; WmiClient=if($client){'Available'}else{'Unavailable'}} | Format-List"
exit /b

:sccm_health
powershell -NoProfile -Command "$checks=@(); $service=Get-Service CcmExec -ErrorAction SilentlyContinue; $checks += [PSCustomObject]@{Check='CcmExec service'; Status=if($service){$service.Status}else{'Not installed'}}; $namespace=Get-CimInstance -Namespace root\ccm -ClassName SMS_Client -ErrorAction SilentlyContinue; $checks += [PSCustomObject]@{Check='Client WMI provider'; Status=if($namespace){'Available'}else{'Unavailable'}}; $cache=Get-CimInstance -Namespace root\ccm\SoftMgmtAgent -ClassName CCM_CacheConfig -ErrorAction SilentlyContinue; $checks += [PSCustomObject]@{Check='Client cache'; Status=if($cache){'Available'}else{'Unavailable'}}; $checks | Format-Table -AutoSize"
exit /b

:sccm_trigger
powershell -NoProfile -Command "$client=Get-CimInstance -Namespace root\ccm -ClassName SMS_Client -ErrorAction Stop; Invoke-CimMethod -InputObject $client -MethodName TriggerSchedule -Arguments @{sScheduleID='%~1'} | Out-Null; Write-Output 'SCCM cycle triggered: %~2'"
if errorlevel 1 echo !RED!SCCM client not available or cycle failed.!RESET!
exit /b

:sccm_repair
echo !YELLOW!SCCM client repair will restart the client service.!RESET!
set "confirm="
set /p "confirm=Type REPAIR to continue: "
if /I not "!confirm!"=="REPAIR" (
    echo !RED!Operation cancelled.!RESET!
    exit /b
)
if exist "%windir%\CCM\ccmrepair.exe" (
    start "" /wait "%windir%\CCM\ccmrepair.exe"
    echo !GREEN!SCCM repair command completed.!RESET!
) else (
    echo !RED!ccmrepair.exe was not found. SCCM may not be installed.!RESET!
)
exit /b

:generate_report
echo !BLUE!Generating report at %REPORT%...!RESET!
(
echo Windows Technician Report
echo Version: v%TOOLKIT_VERSION%
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
powershell -NoProfile -Command "$computer=Get-CimInstance Win32_ComputerSystem; $bios=Get-CimInstance Win32_BIOS; $os=Get-CimInstance Win32_OperatingSystem; $data=[PSCustomObject]@{Computer=$env:COMPUTERNAME; User=$env:USERNAME; Manufacturer=$computer.Manufacturer; Model=$computer.Model; SerialNumber=$bios.SerialNumber; OS=$os.Caption; Version=$os.Version; LastBoot=$os.LastBootUpTime}; $data | ConvertTo-Html -Title 'Windows Technician Report' -PreContent '<h1>Windows Technician Report v%TOOLKIT_VERSION%</h1>' | Out-File -FilePath '%HTML_REPORT%' -Encoding UTF8"
echo !GREEN!HTML report saved to: %HTML_REPORT%!RESET!
start "" "%HTML_REPORT%"
exit /b

:export_asset_csv
powershell -NoProfile -Command "$computer=Get-CimInstance Win32_ComputerSystem; $bios=Get-CimInstance Win32_BIOS; $os=Get-CimInstance Win32_OperatingSystem; $cpu=Get-CimInstance Win32_Processor | Select-Object -First 1; [PSCustomObject]@{AssetTag=$env:COMPUTERNAME; ComputerName=$env:COMPUTERNAME; Manufacturer=$computer.Manufacturer; Model=$computer.Model; SerialNumber=$bios.SerialNumber; OperatingSystem=$os.Caption; OSVersion=$os.Version; CPU=$cpu.Name; RAMGB=[math]::Round($computer.TotalPhysicalMemory/1GB,2); User=$env:USERNAME; ExportedAt=(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')} | Export-Csv -Path '%ASSET_CSV%' -NoTypeInformation -Encoding UTF8"
echo !GREEN!Asset CSV saved to: %ASSET_CSV%!RESET!
exit /b

:export_software_csv
powershell -NoProfile -Command "Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue | Where-Object DisplayName | Select DisplayName,DisplayVersion,Publisher,InstallDate | Sort DisplayName | Export-Csv -Path '%SOFTWARE_CSV%' -NoTypeInformation -Encoding UTF8"
echo !GREEN!Software CSV saved to: %SOFTWARE_CSV%!RESET!
exit /b

:printer_diagnostics
powershell -NoProfile -Command "Get-CimInstance Win32_Printer | Select Name,Default,PrinterStatus,WorkOffline,DriverName,PortName | Format-Table -AutoSize"
exit /b

:enable_local_admin
set "confirm="
set /p "confirm=Type ENABLE to continue: "
if /I not "!confirm!"=="ENABLE" exit /b
call :admin_required powershell -NoProfile -Command "$user=Get-CimInstance Win32_UserAccount -Filter 'LocalAccount=True' | Where-Object SID -like '*-500'; if ($user) { net user $user.Name /active:yes }"
exit /b

:set_local_admin_password
call :admin_required powershell -NoProfile -Command "$user=Get-LocalUser | Where-Object { $_.SID.Value -like '*-500' }; if (-not $user) { Write-Error 'Built-in local Administrator account was not found.'; exit 1 }; $password=Read-Host ('New password for ' + $user.Name) -AsSecureString; Set-LocalUser -Name $user.Name -Password $password"
exit /b

:disable_local_admin
set "confirm="
set /p "confirm=Type DISABLE to continue: "
if /I not "!confirm!"=="DISABLE" exit /b
call :admin_required powershell -NoProfile -Command "$user=Get-CimInstance Win32_UserAccount -Filter 'LocalAccount=True' | Where-Object SID -like '*-500'; if ($user) { net user $user.Name /active:no }"
exit /b

:admin_required
net session >nul 2>&1
if not errorlevel 1 goto admin_run
echo !RED!This action requires Administrator privileges.!RESET!
exit /b 1
:admin_run
%*
exit /b

:end
echo !BLUE!Exiting Windows Technician Toolkit v%TOOLKIT_VERSION%.!RESET!
endlocal
exit /b 0
