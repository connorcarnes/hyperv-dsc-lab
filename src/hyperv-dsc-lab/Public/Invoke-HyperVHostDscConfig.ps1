<#
    .SYNOPSIS
"https://www.google.com/search?as_q=words&as_epq=exact&as_oq=any&as_eq=none&as_nlo=startrange&as_nhi=endrange&lr=&cr=&as_qdr=d&as_sitesearch=domain&as_occt=any&safe=images&as_filetype=&tbs=" -split '&'

    .DESCRIPTION
    Long description

    .PARAMETER ParameterName
    Explain the parameter

    .EXAMPLE
    Example usage
    Output
    Explanation of what the example does

    .OUTPUTS
    Output (if any)

    .NOTES
    General notes

    .LINK
    Link to other documentation
#>
function Invoke-HyperVHostDscConfig {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ParameterType]$ParameterName
    )

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
    }

    process {
        $Session = New-PSSession -UseWindowsPowerShell
        Invoke-Command -Session $Session -ScriptBlock {
            & C:\code\hyperv-dsc-lab\src\hyperv-dsc-lab\Resources\host\HyperVHost.ps1
        }
        $Session | Remove-PSSession
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END :: $(Get-Date)"
    }
}