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
function Set-DSCLabConfiguration {
    [CmdletBinding()]
    param (
        [Parameter(Position=0)]
        [string]$DSCLabConfigurationFilePath = "$($MyInvocation.MyCommand.Module.ModuleBase)\DSCLabConfiguration.json",
        [Parameter(HelpMessage = "Certificate public keys from guest VMs will be exported here.")]
        [String]$CertificatePath,
        [Parameter(HelpMessage = "VHDs created for lab VMs will be saved here.")]
        [String]$LabVHDPath,
        [Parameter(HelpMessage = "MOF files for lab VMs will be saved here.")]
        [String]$MofPath,
        [Parameter(HelpMessage = "Path of script that will be copied to guest VMs and run on initial boot.")]
        [String]$SetupScriptPath,
        [Parameter(HelpMessage = "Path to base VHD that will be used to create lab VMs.")]
        [String]$BaseVHDPath,
        [Parameter(HelpMessage = "Hashtable of other properties to save in the configuration file.")]
        [hashtable]$Other,
        [Parameter(HelpMessage = "Path to psd1 file that contains DSC configuration data for lab VMs.")]
        [String]$VMConfigurationDataPath
    )

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
    }

    process {
        if (-not (Test-Path $DSCLabConfigurationFilePath)) {
            Write-Verbose "Configuration file not found at $DSCLabConfigurationFilePath. Creating new configuration file."
            [void](New-Item -Path $DSCLabConfigurationFilePath -ItemType File)
        }

        try {
            $CurrentConfig = Get-DSCLabConfiguration -DSCLabConfigurationFilePath $DSCLabConfigurationFilePath -ErrorAction 'Stop'
        }
        catch {
            if ($_.exception.message -like "Required DSC Lab Configuration property*") {
                Write-Verbose "Handling error: $($_.exception.message). It will be thrown later if required."
            }
            else {
                throw $_
            }
        }

        if (-not $CurrentConfig) {
            Write-Verbose "Configuration file is empty, creating blank config object"
            $CurrentConfig = [PSCustomObject]@{}
        }

        [System.Collections.ArrayList]$CommonParams = @()
        [System.Management.Automation.PSCmdlet]::CommonParameters | Foreach-Object {[void]($CommonParams.Add($_))}
        [System.Management.Automation.PSCmdlet]::OptionalCommonParameters | Foreach-Object {[void]($CommonParams.Add($_))}
        foreach ($Key in $PSBoundParameters.Keys) {
            Write-Verbose "Setting $Key"
            if ($Key -in $CommonParams) {
                Write-Verbose "Skipping common parameter $Key"
            }
            else {
                $CurrentConfig | Add-Member -NotePropertyName $Key -NotePropertyValue $PSBoundParameters.$Key -Force
            }
        }

        $CurrentConfig | ConvertTo-Json | Out-File $DSCLabConfigurationFilePath -Force

        $Configuration = Get-DSCLabConfiguration -DSCLabConfigurationFilePath $DSCLabConfigurationFilePath -ErrorVariable ErrVar

        foreach ($Err in $ErrVar) {
            Write-Error $Err.Exception.Message
        }

        $Configuration
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END :: $(Get-Date)"
    }
}