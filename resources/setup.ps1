$VerbosePreference = 'continue'

Set-Location "C:\Windows\Panther\"
$log = New-Item -Path ".\lablog-$((Get-Date).Ticks).txt" -Type File -Force

Write-Verbose "START :: $(Get-Date)" *>> $log.FullName

Write-Verbose "Downloading PowerShell-7.2.3-win-x64.msi" *>> $log.FullName
$WebClient = [System.Net.WebClient]::New()
$Url       = 'https://github.com/PowerShell/PowerShell/releases/download/v7.2.3/PowerShell-7.2.3-win-x64.msi'
$Path      = 'C:\Windows\Panther\PowerShell-7.2.3-win-x64.msi'
$WebClient.DownloadFile($Url,$Path)

# https://powershellexplained.com/2016-10-21-powershell-installing-msi-files/
Write-Verbose "Installing PowerShell-7.2.3-win-x64" *>> $log.FullName
$PwshLog = New-Item -Path ".\pwsh-$($log.Name)" -Type File -Force
$MSIArgs = @(
    "/package"
    "PowerShell-7.2.3-win-x64.msi"
    "/quiet"
    "/norestart"
    "/L*v"
    $PwshLog
    "ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1"
    "ENABLE_PSREMOTING=1"
    "REGISTER_MANIFEST=1"
    "USE_MU=1"
    "ENABLE_MU=1"
)
Start-Process msiexec.exe -Verbose -Wait -ArgumentList $MSIArgs *>> $log.FullName

Write-Verbose "Renaming and restarting" *>> $log.FullName
Rename-Computer -NewName '#NEWNAME#' -Force -Restart *>> $log.FullName

Write-Verbose "END   :: $(Get-Date)" *>> $log.FullName