<#
    .SYNOPSIS
    Placeholder

    .DESCRIPTION
    Placeholder

    .PARAMETER LabConfigurationFilePath
    Path to JSON lab configuration file.

    .EXAMPLE
    Example

    .OUTPUTS
    [void]
#>
function Test-LabConfiguration {
    [CmdletBinding()]
    param (
        [Parameter(Position=0)]
        [PSObject]$LabConfigurationObject
    )

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
    }

    process {
        [System.Collections.ArrayList]$MissingProperties = @()
        $REQ_CONFIG_PROPS.ForEach{
            if ([string]::IsNullOrEmpty($LabConfigurationObject.$_)) {
                [void]($MissingProperties.Add($_))
            }
        }

        if ($MissingProperties.Count -ne 0) {
            Write-Error "The following required lab configuration properties are not set: $($MissingProperties -join ', ')"
        }
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END   :: $(Get-Date)"
    }
}