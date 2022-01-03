<#
    .SYNOPSIS
    Short descripton

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
function Get-LabConfiguration {
    [CmdletBinding()]
    param (
        [Parameter(Position=0)]
        [string]$LabConfigurationFilePath = "$($MyInvocation.MyCommand.Module.ModuleBase)\LabConfiguration.json"
    )

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
    }

    process {
        if (-not (Test-Path $LabConfigurationFilePath)) {
            Write-Warning "DSC lab configuration file not found at $LabConfigurationFilePath. Use Set-LabConfiguration to create one."
            return
        }

        Get-Content -Path $LabConfigurationFilePath -Raw | ConvertFrom-Json
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END   :: $(Get-Date)"
    }
}