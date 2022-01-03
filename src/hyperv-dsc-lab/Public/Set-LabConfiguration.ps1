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
function Set-LabConfiguration {
    [CmdletBinding()]
    param (
        [Parameter(Position=0)]
        [string]$LabConfigurationFilePath = "$($MyInvocation.MyCommand.Module.ModuleBase)\LabConfiguration.json",
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
        if (-not (Test-Path $LabConfigurationFilePath)) {
            Write-Verbose "Configuration file not found at $LabConfigurationFilePath. Creating new configuration file."
            [void](New-Item -Path $LabConfigurationFilePath -ItemType File)
        }

        $Configuration = Get-LabConfiguration -LabConfigurationFilePath $LabConfigurationFilePath -ErrorAction 'SilentlyContinue'

        if (-not $Configuration) {
            Write-Verbose "Configuration file is empty, creating blank config object"
            $Configuration = [PSCustomObject]@{}
        }

        [System.Collections.ArrayList]$CommonParams = @()
        [System.Management.Automation.PSCmdlet]::CommonParameters | Foreach-Object {[void]($CommonParams.Add($_))}
        [System.Management.Automation.PSCmdlet]::OptionalCommonParameters | Foreach-Object {[void]($CommonParams.Add($_))}
        foreach ($Key in $PSBoundParameters.Keys) {
            if ($Key -in $CommonParams) {
                Write-Verbose "Skipping common parameter $Key"
            }
            elseif (($Configuration.$Key) -and ($Configuration.$Key -ne $PSBoundParameters.$Key)) {
                Write-Verbose "Updating $Key from $($Configuration.$Key) to $($PSBoundParameters.$Key)"
                $Configuration.$Key = $PSBoundParameters.$Key
            }
            else {
                Write-Verbose "Setting $Key to $($PSBoundParameters.$Key)"
                $Configuration | Add-Member -NotePropertyName $Key -NotePropertyValue $PSBoundParameters.$Key -Force
            }
        }

        $Configuration | ConvertTo-Json | Out-File $LabConfigurationFilePath -Force

        Test-LabConfiguration $Configuration

        $Configuration
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END   :: $(Get-Date)"
    }
}