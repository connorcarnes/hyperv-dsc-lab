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
function Invoke-DscLab {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ParameterType]$ParameterName
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