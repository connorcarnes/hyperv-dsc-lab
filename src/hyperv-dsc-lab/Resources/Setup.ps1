Set-SConfig -AutoLaunch `$false
Get-PackageProvider -name nuget -force
@(
    'PSDscResources'
    'ComputerManagementDsc'
    'ActiveDirectoryDsc'
    'NetworkingDsc'
).ForEach({Install-Module `$_ -confirm:`$false -force})

# Enable all DSC logs
# https://docs.microsoft.com/en-us/powershell/dsc/troubleshooting/troubleshooting?view=dsc-1.1&viewFallbackFrom=powershell-7.2
# https://devblogs.microsoft.com/powershell/using-event-logs-to-diagnose-errors-in-desired-state-configuration/
wevtutil.exe set-log "Microsoft-Windows-Dsc/Analytic" /q:true /e:true
wevtutil.exe set-log "Microsoft-Windows-Dsc/Debug" /q:true /e:true

# Reset auto logon count
# https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-shell-setup-autologon-logoncount#logoncount-known-issue
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoLogonCount -Value 0

Rename-Computer -NewName ${VmName} -Force -Restart