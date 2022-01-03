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

    $LabConfigurationFilePath = "$($MyInvocation.MyCommand.Module.ModuleBase)\LabConfiguration.json"
    if (-not (Test-Path $LabConfigurationFilePath)) {
        throw "$LabConfigurationFilePath does not exist. Run Set-LabConfiguration and try again."
    }

    if (-not $LAB_CONFIG)
    {
        throw "`$LAB_CONFIG script variable is not present. Run Set-LabConfiguration, ensure $LabConfigurationFilePath exists and try again."
    }

    # Ensure required properties are not null or empty
    [System.Collections.ArrayList]$MissingProperties = @()
    $REQ_CONFIG_PROPS.ForEach{
        if ([string]::IsNullOrEmpty($LAB_CONFIG.$_)) {
            [void]($MissingProperties.Add($_))
        }
    }

    # Error if missing required properties
    if ($MissingProperties.Count -ne 0) {
        Write-Error "The following required lab configuration properties are not set: $($MissingProperties -join ', ')"
    }
    else {
        $true
    }
}