<#
    .SYNOPSIS
    Updates and validates the lab configuration.

    .DESCRIPTION
    Updates and validates the lab configuration. Actions taken:

    - Creates LabConfiguration.json in the base module path if it doesn't exist.
    - Updates the lab configuration with values supplied in the parameters. This includes updating LabConfiguration.json as well as the
      script variable $LAB_CONFIG.
    - Validates the lab configuration and returns relevant errors if validation fails.
    - Returns the updated lab configuration.

    .PARAMETER ParameterName
    Explain the parameter

    .EXAMPLE
    Example usage
    Output
    Explanation of what the example does

    .OUTPUTS
    [PSObject]

    .NOTES
    General notes

    .LINK
    Link to other documentation
#>
function Set-LabConfiguration {
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "Certificate public keys from guest VMs will be exported here.")]
        [String]$CertificatePath,
        [Parameter(HelpMessage = "VHDs created for lab VMs will be saved here.")]
        [String]$VHDPath,
        [Parameter(HelpMessage = "MOF files for lab VMs will be saved here.")]
        [String]$MofPath,
        [Parameter(HelpMessage = "Path of script that will be copied to guest VMs and run on initial boot.")]
        [String]$SetupScriptPath,
        [Parameter(HelpMessage = "Path to base VHD that will be used to create lab VMs.")]
        [String]$BaseVHDPath,
        [Parameter(HelpMessage = "Hashtable of other properties to save in the configuration file.")]
        [hashtable]$Other,
        [Parameter(HelpMessage = "Path to psd1 file that contains DSC configuration data for lab VMs.")]
        [String]$VMConfigurationDataPath,
        [Parameter(HelpMessage = "Path to DSC Configuration for Lab VMs.")]
        [String]$VMConfiguration,
        [Parameter(HelpMessage = "Path to DSC Configuration for Lab Host.")]
        [String]$HostConfiguration
    )

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
    }

    process {
        $LabConfigurationFilePath = "$($MyInvocation.MyCommand.Module.ModuleBase)\LabConfiguration.json"
        if (-not (Test-Path $LabConfigurationFilePath)) {
            Write-Verbose "Configuration file not found at $LabConfigurationFilePath. Creating new configuration file."
            [void](New-Item -Path $LabConfigurationFilePath -ItemType File)
        }

        if (-not $LAB_CONFIG) {
            Write-Verbose "Configuration file is empty, creating blank config object"
            $CurrentConfig = [PSCustomObject]@{}
        }
        else {
            $CurrentConfig = $LAB_CONFIG
        }

        # Add all common parameters to an array so we can ignore them in the loop below
        [System.Collections.ArrayList]$CommonParams = @()
        [System.Management.Automation.PSCmdlet]::CommonParameters | ForEach-Object { [void]($CommonParams.Add($_)) }
        [System.Management.Automation.PSCmdlet]::OptionalCommonParameters | ForEach-Object { [void]($CommonParams.Add($_)) }

        foreach ($Key in $PSBoundParameters.Keys) {
            if ($Key -in $CommonParams) {
                Write-Verbose "Skipping common parameter $Key"
            }
            elseif (($CurrentConfig.$Key) -and ($CurrentConfig.$Key -ne $PSBoundParameters.$Key)) {
                Write-Verbose "Updating $Key from $($CurrentConfig.$Key) to $($PSBoundParameters.$Key)"
                $CurrentConfig.$Key = $PSBoundParameters.$Key
            }
            else {
                Write-Verbose "Setting $Key to $($PSBoundParameters.$Key)"
                $CurrentConfig | Add-Member -NotePropertyName $Key -NotePropertyValue $PSBoundParameters.$Key -Force
            }
        }

        # Save updated configuration as JSON
        $CurrentConfig | ConvertTo-Json | Out-File $LabConfigurationFilePath -Force

        # Set the script variable
        $VarParams = @{
            Name        = 'LAB_CONFIG'
            Description = 'Lab configuration object'
            Scope       = 'Script'
            Force       = $True
            Option      = 'readonly'
            Value       = $CurrentConfig
        }
        Set-Variable @VarParams

        Get-LabConfiguration
        [void](Test-LabConfiguration)
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END   :: $(Get-Date)"
    }
}