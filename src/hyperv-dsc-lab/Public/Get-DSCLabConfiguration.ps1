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
function Get-DSCLabConfiguration {
    [CmdletBinding()]
    param (
        [Parameter(Position=0)]
        [string]$DSCLabConfigurationFilePath = "$($MyInvocation.MyCommand.Module.ModuleBase)\DSCLabConfiguration.json"
    )

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
    }

    process {
        if (-not (Test-Path $DSCLabConfigurationFilePath)) {
            Write-Warning "DSC lab configuration file not found at $DSCLabConfigurationFilePath. Use Set-DSCLabConfiguration to create one."
            return
        }

        $Configuration = Get-Content -Path $DSCLabConfigurationFilePath -Raw |
            ConvertFrom-Json

        # Ensure required properties are present
        $REQ_DSC_LAB_CONFIG_PROPS.ForEach{
            if ([string]::IsNullOrEmpty($Configuration.$_)) {
                Write-Error "Required DSC Lab Configuration property $_ is not set."
            }
        }

        $Configuration
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END :: $(Get-Date)"
    }
}