function New-Lab {
    <#
        .SYNOPSIS
        Function summary.

        .DESCRIPTION
        In depth description of function.

        .PARAMETER Param
        Description of Parameter.

        .EXAMPLE
        Example usage

        Explanation of example

        .OUTPUTS
        [void]

        .NOTES
        General notes

        .LINK
        google.com
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, HelpMessage = "Param help")]
        [string]$Param
    )

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
    }

    process {
        # Process
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END   :: $(Get-Date)"
    }
}