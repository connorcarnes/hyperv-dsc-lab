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

        [Parameter()]
        [int]$TimeoutMinutes = 5
    )

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
    }

    process {
        Remove-DSCLabVM -VM $VMs

        New-LabVmVhd -VM $VMs

        Invoke-DSCLabHostConfiguration

        Wait-DSCLabVM -VM $VMs -LocalCredential $LocalCredential
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END :: $(Get-Date)"
    }
}