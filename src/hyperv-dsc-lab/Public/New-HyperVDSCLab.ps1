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
function New-HyperVDSCLab {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String[]]$VMs,

        [Parameter(Mandatory)]
        [PSCredential]$LocalCredential,

        [Parameter(Mandatory)]
        [PSCredential]$DomainCredential,

        [Parameter()]
        [int]$TimeoutMinutes = 5
    )

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
    }

    process {
        $Config = Get-DSCLabConfiguration

        Remove-DSCLabVM -VM $VMs

        New-LabVmVhd -VM $VMs

        $Splat = @{
            ConfigurationFile = $Config.HostConfiguration
            OutputPath        = $Config.MofPath
        }
        Initialize-DSCLabConfiguration @Splat
        Start-DscConfiguration -Computername 'localhost' -Path $config.MofPath

        Wait-DSCLabVM -VM $VMs -LocalCredential $LocalCredential

        New-LabVmCertificate -VM $VMs -Credential $LocalCredential

        $Splat = @{
            ConfigurationFile = $Config.VMConfiguration
            ConfigurationData = $Config.VMConfigurationDataPath
            OutputPath        = $Config.MofPath
            LocalCredential   = $LocalCredential
            DomainCredential  = $DomainCredential
        }
        Initialize-DSCLabConfiguration @Splat

        Update-Mof -VMs $VMs -Credential $LocalCredential
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END   :: $(Get-Date)"
    }
}