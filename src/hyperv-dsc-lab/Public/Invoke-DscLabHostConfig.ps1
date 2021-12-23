$Session = New-PSSession -UseWindowsPowerShell
Invoke-Command -Session $Session -ScriptBlock {
    & C:\code\hyperv-dsc-lab\src\hyperv-dsc-lab\Resources\host\HyperVHost.ps1
}
$Session | Remove-PSSession