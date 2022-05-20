$VerbosePreference = 'Continue'
Set-Location "C:\Windows\Panther"
$log = New-Item -Path ".\bootstrap-$((Get-Date).Ticks).txt" -Type File -Force
Write-Verbose "START :: $(Get-Date)" *>> $log.FullName
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -Verbose *>> $log.FullName
Install-PackageProvider Nuget -Force -Verbose *>> $log.FullName
$Splat = @{
    Repository = 'PSGallery'
    Force      = $true
    Verbose    = $true
}
Install-Module -Name PowerShellGet @Splat *>> $log.FullName
Update-Module -Name PowerShellGet -Verbose *>> $log.FullName
Install-Module -Name PSDesiredStateConfiguration -MaximumVersion 2.99 @Splat *>> $log.FullName
Enable-ExperimentalFeature PSDesiredStateConfiguration.InvokeDscResource -Confirm:$false *>> $log.FullName
Install-Module -Name ComputerManagementDsc @Splat *>> $log.FullName
Install-Module -Name NetworkingDsc @Splat *>> $log.FullName
Install-Module -Name ActiveDirectoryDsc @Splat *>> $log.FullName

$true | Export-Clixml C:\Windows\Panther\BootStrappedTrue.xml

Write-Verbose "END   :: $(Get-Date)" *>> $log.FullName