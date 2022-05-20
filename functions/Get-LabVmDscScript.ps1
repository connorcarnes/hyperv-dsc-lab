function Get-LabVmDscScript {
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
        [string[]]$VmName = @("DC00"),

        [Parameter()]#Mandatory, HelpMessage = "Param help")]
        [string]$ConfigurationDataPath = $ModuleConfig.ConfigDataPath,

        [Parameter()]#Mandatory, HelpMessage = "Param help")]
        [string]$PlainTextPassword = $ModuleConfig.PlainTextPassword
    )

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
    }

    process {
        $ConfigData = Import-PowerShellDataFile -Path $ConfigurationDataPath

        $DscScript = [System.Collections.ArrayList]::new()
        foreach ($Vm in $ConfigData['VMs'].Keys) {

            $IpAddress      = $ConfigData['Vms'][$Vm]['Ip']
            $DefaultGateway = $ConfigData['DefaultGateway']
            $DnsAddresses   = $ConfigData['DnsAddresses'] -join "','"

            $null = $DscScript.Add(@"
`$log = New-Item -Path 'C:\Windows\Panther\Dsc.log' -Type File -Force
`$Credential = [System.Management.Automation.PSCredential]::New(
    'Administrator',
    (ConvertTo-SecureString -String '$PlainTextPassword' -AsPlainText -Force)
)

"@)

            $null = $DscScript.Add(@"
`$Ip = @{
    Module   = 'NetworkingDsc'
    Name     = 'IPAddress'
    Method   = 'Set'
    Property = @{
        IPAddress      = '$IpAddress'
        InterfaceAlias = 'Ethernet'
        AddressFamily  = 'IPV4'
    }
}
Invoke-DscResource @Ip *>> `$log.FullName

"@)

            $null = $DscScript.Add(@"
`$DisableDHCP = @{
    Module   = 'NetworkingDsc'
    Name     = 'NetIPInterface'
    Method   = 'Set'
    Property = @{
        InterfaceAlias = 'Ethernet'
        AddressFamily  = 'IPv4'
        Dhcp           = 'Disabled'
    }
}
Invoke-DscResource @DisableDHCP *>> `$log.FullName

"@)

            $null = $DscScript.Add(@"
`$DefaultGateway = @{
    Module   = 'NetworkingDsc'
    Name     = 'DefaultGatewayAddress'
    Method   = 'Set'
    Property = @{
        Address        = '$DefaultGateway'
        InterfaceAlias = 'Ethernet'
        AddressFamily  = 'IPv4'
    }
}
Invoke-DscResource @DefaultGateway *>> `$log.FullName

"@)

            $null = $DscScript.Add(@"
`$DisableIpV6 = @{
    Module   = 'NetworkingDsc'
    Name     = 'NetAdapterBinding'
    Method   = 'Set'
    Property = @{
        InterfaceAlias = 'Ethernet'
        ComponentId    = 'ms_tcpip6'
        State          = 'Disabled'
    }
}
Invoke-DscResource @DisableIpV6 *>> `$log.FullName

"@)

            $null = $DscScript.Add(@"
`$Dns = @{
    Module   = 'NetworkingDsc'
    Name     = 'DnsServerAddress'
    Method   = 'Set'
    Property = @{
        Address        = '$DnsAddresses'
        InterfaceAlias = 'Ethernet'
        AddressFamily  = 'IPv4'
        Validate       = `$false
    }
}
Invoke-DscResource @Dns *>> `$log.FullName

"@)
        }
        if ($Vm -eq 'DC00') {
            $DomainName   = $ConfigData['DomainName']
            $null = $DscScript.Add(@"
`$ActiveDirectory = @{
    Module   = 'PsDesiredStateConfiguration'
    Name     = 'WindowsFeature'
    Method   = 'Set'
    Property = @{
        Name                 = 'AD-Domain-Services'
        Ensure               = 'Present'
        IncludeAllSubFeature = `$true
    }
}
Invoke-DscResource @ActiveDirectory *>> `$log.FullName

"@)

$null = $DscScript.Add(@"
`$RsatAd = @{
    Module   = 'PsDesiredStateConfiguration'
    Name     = 'WindowsFeature'
    Method   = 'Set'
    Property = @{
        Name                 = 'RSAT-AD-PowerShell'
        Ensure               = 'Present'
        IncludeAllSubFeature = `$true
    }
}
Invoke-DscResource @RsatAd *>> `$log.FullName

"@)

$null = $DscScript.Add(@"
Import-Module 'ADDSDeployment'
`$FirstDomainController = @{
    Module   = 'ActiveDirectoryDsc'
    Name     = 'ADDomain'
    Method   = 'Set'
    Property = @{
        DomainName                    = '$DomainName'
        Credential                    = `$Credential
        SafemodeAdministratorPassword = `$Credential
        ForestMode                    = 'WinThreshold'
    }
}
Invoke-DscResource @FirstDomainController *>> `$log.FullName

"@)
        }
        $DscScript
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END   :: $(Get-Date)"
    }
}