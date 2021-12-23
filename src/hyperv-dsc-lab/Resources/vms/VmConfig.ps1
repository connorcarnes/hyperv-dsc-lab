$Password = ConvertTo-SecureString '#Password1' -AsPlainText -Force

Configuration VmConfig
{
    [CmdletBinding()]
    param
    (
        [pscredential]$LocalCred = (New-Object System.Management.Automation.PSCredential ('Administrator', $Password)),
        [pscredential]$DomainCred = (New-Object System.Management.Automation.PSCredential ('lab\Administrator', $Password))
    )

    Import-DscResource -ModuleName 'PackageManagement'
    Import-DscResource -ModuleName 'NetworkingDsc'
    Import-DscResource -ModuleName 'ComputerManagementDsc'
    Import-DscResource -ModuleName 'PSDscResources'
    Import-DscResource -ModuleName 'ActiveDirectoryDsc'

    node $AllNodes.NodeName
    {
        LocalConfigurationManager {
            CertificateID        = (Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.Subject -eq "CN=$($Node.NodeName)-DSC" }).Thumbprint
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

        PackageManagement ActiveDirectoryDsc
        {
            Ensure    = "Present"
            Name      = "ActiveDirectoryDsc"
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
            Address        = '172.24.160.1'
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

    Node DC00
    {
        Computer DC00 {
            Name = 'DC00'
        }

        WindowsFeature 'ADDS' {
            Name   = 'AD-Domain-Services'
            Ensure = 'Present'
        }

        WindowsFeature 'RSAT' {
            Name      = 'RSAT-AD-PowerShell'
            Ensure    = 'Present'
            DependsOn = '[WindowsFeature]ADDS'
        }

        ADDomain 'ADDomainInstall' {
            DomainName                    = 'lab.local'
            Credential                    = $LocalCred
            SafemodeAdministratorPassword = $LocalCred
            ForestMode                    = 'WinThreshold'
            DependsOn                     = '[WindowsFeature]ADDS'
        }
    }

    Node DC01
    {
        WindowsFeature 'ADDS' {
            Name   = 'AD-Domain-Services'
            Ensure = 'Present'
        }

        WindowsFeature 'RSAT' {
            Name      = 'RSAT-AD-PowerShell'
            Ensure    = 'Present'
            DependsOn = '[WindowsFeature]ADDS'
        }

        WaitForADDomain 'WaitForADDomain' {
            DomainName = 'lab.local'
            Credential = $DomainCred
            DependsOn  = '[WindowsFeature]RSAT'
        }

        Computer DC01 {
            Name       = 'DC01'
            DomainName = 'lab.local'
            Credential = $DomainCred
            Server     = 'DC00.lab.local'
        }

        ADDomainController 'DomainController' {
            DomainName                    = 'lab.local'
            Credential                    = $DomainCred
            SafeModeAdministratorPassword = $DomainCred
            InstallDns                    = $true
            DependsOn                     = '[WaitForADDomain]WaitForADDomain', '[Computer]DC01'
        }
    }
}
$DefaultGateway = (get-netadapter -Name 'vEthernet (Default Switch)' | Get-NetIpConfiguration).IPv4Address.IPAddress
$DC00IP = "$($DefaultGateway.TrimEnd('.1')).10"
$DC01IP = "$($DefaultGateway.TrimEnd('.1')).11"
$ConfigData = @{
    AllNodes = @(
        @{
            NodeName             = "*"
            RebootNodeIfNeeded   = $true
            PSDscAllowDomainUser = $true
        },
        @{
            NodeName        = 'DC00'
            DNSAddresses    = '127.0.0.1', '172.24.160.11', '8.8.8.8', '1.1.1.1'
            IPAddress       = '172.24.160.10'
            CertificateFile = "C:\code\local-hyperv-dsc-lab\certs\DC00-DscPubKey.cer"
        },
        @{
            NodeName             = 'DC01'
            DNSAddresses         = '127.0.0.1', '172.24.160.10', '8.8.8.8', '1.1.1.1'
            IPAddress            = '172.24.160.11'
            CertificateFile      = "C:\code\local-hyperv-dsc-lab\certs\DC01-DscPubKey.cer"
        }
    )
}
VmConfig -Configuration $ConfigData