function Set-LabConfigFile {
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
        [Parameter()]#Mandatory, HelpMessage = "Param help")]
        [string]$Source = "$($ModuleConfig.ModulePath)\configurations\ConfigurationData.psd1",

        [Parameter()]#Mandatory, HelpMessage = "Param help")]
        [string]$Destination = $ModuleConfig.ConfigDataPath,

        [Parameter()]#Mandatory, HelpMessage = "Param help")]
        [string]$DefaultGateway = (Get-NetIpAddress -InterfaceAlias 'vEthernet (Default Switch)' -AddressFamily IPv4).IPAddress
    )

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
    }

    process {
        $SourceConfig = Import-PowerShellDataFile -Path $Source
        $Split        = $DefaultGateway -split '\.'

        $Ips = [System.Collections.ArrayList]::New()
        $Dns = [System.Collections.ArrayList]::New()
        foreach ($Vm in $SourceConfig['Vms'].Keys) {
            $Temp    = $Split
            $Temp[3] = $SourceConfig['VMs'][$Vm]['LastOctet']
            $Ip      = $Temp -join '.'
            $null = $Ips.Add(
                [PSCustomObject]@{
                    Vm = $Vm
                    Ip = $Ip
                }
            )
            if ($Vm -like "DC*") {
                $null = $Dns.Add($Ip)
            }
        }

        '1.1.1.1','8.8.8.8' | ForEach-Object {$null = $Dns.Add($_)}

        $ConfigDataContent = Get-Content $Source -Raw
        $ConfigDataContent = $ConfigDataContent -Replace '#DEFAULTGATEWAY#', $DefaultGateway
        $ConfigDataContent = $ConfigDataContent -Replace "#DNSADDRESSES#", $($dns -join "','")

        foreach ($Ip in $Ips) {
            $ConfigDataContent = $ConfigDataContent -Replace "#$($Ip.VM)#", $Ip.Ip
        }

        $ConfigDataContent | Set-Content $Destination -Force
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END   :: $(Get-Date)"
    }
}
