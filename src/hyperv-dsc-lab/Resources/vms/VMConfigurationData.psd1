@{
    AllNodes   = @(
        @{
            NodeName             = "*"
            RebootNodeIfNeeded   = $true
            PSDscAllowDomainUser = $true
            DNSAddresses         = '192.168.64.10', '192.168.64.11', '8.8.8.8', '1.1.1.1'
            DefaultGateway       = '192.168.64.1'
        },
        @{
            NodeName        = 'DC00'
            IPAddress       = '192.168.64.10'
            CertificateFile = 'D:\virt\certs\DC00-DSC-Lab-PubKey.cer'
            Role            = 'Domain Controller'
        },
        @{
            NodeName        = 'DC01'
            IPAddress       = '192.168.64.11'
            CertificateFile = 'D:\virt\certs\DC01-DSC-Lab-PubKey.cer'
            Role            = 'Domain Controller'
        }
    )
    DomainInfo = @{
        DomainName = 'lab.local'
        PrimaryDC  = 'DC00'
    }
}
