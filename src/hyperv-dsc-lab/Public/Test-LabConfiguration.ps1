<#
    .SYNOPSIS
    Validates the lab configuration.

    .DESCRIPTION
    Validates the lab configuration. Returns True if the lab configuration is valid. Returns an error message if required properties are missing.

    .EXAMPLE
    Test-LabConfiguration

    True

    Validates the lab configuration.

    .OUTPUTS
    [bool]
#>
function Test-LabConfiguration {
    [CmdletBinding()]
    param ()

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
    }

    process {
        [System.Collections.ArrayList]$MissingProperties = @()
        $REQ_CONFIG_PROPS.ForEach{
            if ([string]::IsNullOrEmpty($LAB_CONFIG.$_)) {
                [void]($MissingProperties.Add($_))
            }
        }

        if ($MissingProperties.Count -ne 0) {
            Write-Error "The following required lab configuration properties are not set: $($MissingProperties -join ', ')"
        }
        else {
            $true
        }
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END   :: $(Get-Date)"
    }
}