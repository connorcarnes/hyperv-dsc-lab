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
        Test-LabConfiguration -ErrorAction 'Stop'
    }

    process {
        Remove-LabVM -VM $VMs

        New-LabVMVHD -VM $VMs

        $Splat = @{
            ConfigurationFile = $LAB_CONFIG.HostConfiguration
            OutputPath        = $LAB_CONFIG.MofPath
        }
        Initialize-DSCConfiguration @Splat
        Start-DscConfiguration -ComputerName 'localhost' -Path $LAB_CONFIG.MofPath

        Wait-LabVM -VM $VMs -LocalCredential $LocalCredential

        New-LabVMCertificate -VM $VMs -Credential $LocalCredential

        $Splat = @{
            ConfigurationFile = $LAB_CONFIG.VMConfiguration
            ConfigurationData = $LAB_CONFIG.VMConfigurationDataPath
            OutputPath        = $LAB_CONFIG.MofPath
            LocalCredential   = $LocalCredential
            DomainCredential  = $DomainCredential
        }
        Initialize-DSCConfiguration @Splat

        Update-Mof -VMs $VMs -Credential $LocalCredential
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END   :: $(Get-Date)"
    }
}