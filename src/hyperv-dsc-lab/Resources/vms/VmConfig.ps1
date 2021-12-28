Configuration VmConfig
{
    [CmdletBinding()]
    param
    (
        [pscredential]$LocalCredential,
        [pscredential]$DomainCredential
    )

    Import-DscResource -ModuleName 'PackageManagement'
    Import-DscResource -ModuleName 'NetworkingDsc'
    Import-DscResource -ModuleName 'ComputerManagementDsc'
    Import-DscResource -ModuleName 'PSDscResources'
    Import-DscResource -ModuleName 'ActiveDirectoryDsc'

    node $AllNodes.NodeName
    {
        LocalConfigurationManager {
            CertificateID        = (Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.Subject -eq "CN=$($Node.NodeName)-DSC-Lab" }).Thumbprint
            RebootNodeIfNeeded   = $true
        }

        PackageManagementSource SourceRepository
        {
            Ensure             = "Present"
            Name               = "Nuget"
            ProviderName       = "Nuget"
            SourceUri          = "http://nuget.org/api/v2/"
            InstallationPolicy = "Trusted"
        }

        PackageManagementSource PSGallery
        {
            Ensure             = "Present"
            Name               = "PSGallery"
            ProviderName       = "PowerShellGet"
            SourceUri          = "https://www.powershellgallery.com/api/v2"
            InstallationPolicy = "Trusted"
        }

        PackageManagement PSDscResources
        {
            Ensure    = "Present"
            Name      = "PSDscResources"
            Source    = "PSGallery"
            DependsOn = "[PackageManagementSource]PSGallery"
        }

        PackageManagement ComputerManagementDsc
        {
            Ensure    = "Present"
            Name      = "ComputerManagementDsc"
            Source    = "PSGallery"
            DependsOn = "[PackageManagementSource]PSGallery"
        }

        PackageManagement NetworkingDsc
        {
            Ensure    = "Present"
            Name      = "NetworkingDsc"
            Source    = "PSGallery"
            DependsOn = "[PackageManagementSource]PSGallery"
        }

        NetIPInterface DisableDhcp
        {
            InterfaceAlias = 'Ethernet'
            AddressFamily  = 'IPv4'
            Dhcp           = 'Disabled'
            DependsOn      = "[PackageManagement]NetworkingDsc"
        }

        IPAddress NewIPv4Address
        {
            IPAddress      = $Node.IPAddress
            InterfaceAlias = 'Ethernet'
            AddressFamily  = 'IPV4'
            DependsOn      = "[PackageManagement]NetworkingDsc"
        }

        DefaultGatewayAddress SetDefaultGateway
        {
            Address        = $DefaultGateway
            InterfaceAlias = 'Ethernet'
            AddressFamily  = 'IPv4'
            DependsOn      = "[PackageManagement]NetworkingDsc"
        }

        NetAdapterBinding DisableIPv6
        {
            InterfaceAlias = 'Ethernet'
            ComponentId    = 'ms_tcpip6'
            State          = 'Disabled'
			DependsOn      = "[PackageManagement]NetworkingDsc"
        }

        DnsServerAddress DnsServerAddress
        {
            Address        = $Node.DNSAddresses
            InterfaceAlias = 'Ethernet'
            AddressFamily  = 'IPv4'
            Validate       = $false
			DependsOn      = "[PackageManagement]NetworkingDsc"
        }
    }

    Node $AllNodes.Where{$_.Role -eq 'Domain Controller'}.NodeName
    {
        PackageManagement ActiveDirectoryDsc
        {
            Ensure    = "Present"
            Name      = "ActiveDirectoryDsc"
            Source    = "PSGallery"
        }

        WindowsFeature 'ADDS' {
            Name   = 'AD-Domain-Services'
            Ensure = 'Present'
        }

        WindowsFeature 'RSAT' {
            Name      = 'RSAT-AD-PowerShell'
            Ensure    = 'Present'
        }
    }

    Node DC00
    {
        Computer DC00 {
            Name = 'DC00'
        }

        ADDomain 'ADDomainInstall' {
            DomainName                    = $ConfigurationData.DomainInfo.DomainName
            Credential                    = $LocalCredential
            SafemodeAdministratorPassword = $LocalCredential
            ForestMode                    = 'WinThreshold'
        }
    }

    Node DC01
    {
        WaitForADDomain 'WaitForADDomain' {
            DomainName              = $ConfigurationData.DomainInfo.DomainName
            Credential              = $DomainCredential
            WaitForValidCredentials = $true
            RestartCount            = 4
        }

        Computer DC01 {
            Name       = 'DC01'
            DomainName = $ConfigurationData.DomainInfo.DomainName
            Credential = $DomainCredential
            Server     = $ConfigurationData.DomainInfo.PrimaryDC
        }

        ADDomainController 'DomainController' {
            DomainName                    = $ConfigurationData.DomainInfo.DomainName
            Credential                    = $DomainCredential
            SafeModeAdministratorPassword = $DomainCredential
            InstallDns                    = $true
            DependsOn                     = '[Computer]DC01'
        }
    }
}
