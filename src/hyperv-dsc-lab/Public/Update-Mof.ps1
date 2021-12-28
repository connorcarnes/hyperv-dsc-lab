<#
    .SYNOPSIS
        Short descripton
    .DESCRIPTION
        Long description
    .PARAMETER ParamterOne
        Explain the parameter
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    .OUTPUTS
        Output (if any)
    .NOTES
        General notes
    .LINK
        Link to other documentation
#>
function Update-Mof {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String[]]$VMs,
        [Parameter(Mandatory)]
        [PSCredential]$LocalCredential,
        [Parameter(Mandatory)]
        [PSCredential]$DomainCredential
    )

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
    }

    process {
        $Config  = Get-DSCLabConfiguration

        $Session = New-PSSession -UseWindowsPowerShell
        $Splat = @{
            LocalCredential   = $LocalCredential
            DomainCredential  = $DomainCredential
            ConfigurationData = "$($Config.VMConfigurationDataPath)"
            OutputPath        = "$($Config.MofExportPath)\vms"
        }
        Invoke-Command -Session $Session -ScriptBlock {
            . C:\code\hyperv-dsc-lab\src\hyperv-dsc-lab\Resources\vms\VmConfig.ps1
            VmConfig @Using:Splat
        }
        $Session | Remove-PSSession


        $VMs | ForEach-Object -Parallel {
            $Session        = New-PSSession $_ -Credential $Using:LocalCredential
            $MofContent     = Get-Content "D:\virt\mofs\vms\$_.mof" -Raw
            $MetaMofContent = Get-Content "D:\virt\mofs\vms\$_.meta.mof" -Raw
            Invoke-Command -Session $Session -ArgumentList $MofContent,$MetaMofContent -ScriptBlock {
                param($MofContent,$MetaMofContent)
                Set-Content -Path "C:\Windows\System32\Configuration\Pending.mof"    -Value $MofContent     -Force
                Set-Content -Path "C:\Windows\System32\Configuration\MetaConfig.mof" -Value $MetaMofContent -Force
            }
            $Session | Remove-PSSession
        }
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END :: $(Get-Date)"
    }
}