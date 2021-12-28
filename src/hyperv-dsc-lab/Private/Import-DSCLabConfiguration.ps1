<#
    .SYNOPSIS
    Loads a DSC Configuration using a Windows PowerShell session.

    .DESCRIPTION
    Loads a DSC Configuration using a Windows PowerShell session.

    .PARAMETER ConfigurationPath
    Path to DSC configuration.

    .EXAMPLE
    Example

    .OUTPUTS
    [void]
#>
function Import-DSCLabConfiguration {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String[]]$ConfigurationPath,

        [Parameter()]
        [PSCredential]$LocalCredential,

        [Parameter()]
        [PSCredential]$DomainCredential
    )

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
    }

    process {

    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END :: $(Get-Date)"
    }
}