<#
    .SYNOPSIS
    Gets the lab configuration.

    .DESCRIPTION
    Gets the lab configuration. Lab configuration must be stored as a JSON file.

    .PARAMETER LabConfigurationFilePath
    Path to the JSON file containing the lab configuration. Default value is "$($MyInvocation.MyCommand.Module.ModuleBase)\LabConfiguration.json".

    .EXAMPLE
    Get-LabConfiguration

    Other                    : {DC00IP, DefaultGateway, DC01IP}
    VMConfiguration          : C:\code\hyperv-dsc-lab\src\hyperv-dsc-lab\Resources\vms\VmConfig.ps1
    VHDPath                  : D:\virt\vhds
    SetupScriptPath          : C:\code\hyperv-dsc-lab\src\hyperv-dsc-lab\Resources\Setup.ps1
    HostConfiguration        : C:\code\hyperv-dsc-lab\src\hyperv-dsc-lab\Resources\host\HyperVHost.ps1
    LabConfigurationFilePath : C:\code\hyperv-dsc-lab\src\hyperv-dsc-lab\LabConfiguration.json
    MofPath                  : D:\virt\mofs
    VMConfigurationDataPath  : C:\code\hyperv-dsc-lab\src\hyperv-dsc-lab\Resources\vms\VMConfigurationData.psd1
    CertificatePath          : D:\virt\certs
    BaseVHDPath              : D:\virt\vhds\base-vhds\win22.vhdx

    Returns lab configuration stored in the default location.

    .OUTPUTS
    [PSObject]
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
            Write-Warning "Lab configuration file not found at $LabConfigurationFilePath. Use Set-LabConfiguration to create one."
            return
        }

        Get-Content -Path $LabConfigurationFilePath -Raw | ConvertFrom-Json
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END   :: $(Get-Date)"
    }
}