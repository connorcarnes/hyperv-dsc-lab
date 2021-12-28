@{
    AllNodes = @(
        @{
            NodeName             = "*"
            RebootNodeIfNeeded   = $true
            PSDscAllowDomainUser = $true
            DNSAddresses         = '172.21.64.10', '172.21.64.11', '8.8.8.8', '1.1.1.1'
            DefaultGateway       = '172.21.64.1'
        },
        @{
            NodeName        = 'DC00'
            IPAddress       = '172.21.64.10'
            CertificateFile = '\DC00-DSC-Lab-PubKey.cer'
            Role            = 'Domain Controller'
        },
        @{
            NodeName        = 'DC01'
            IPAddress       = '172.21.64.11'
            CertificateFile = '\DC01-DSC-Lab-PubKey.cer'
            Role            = 'Domain Controller'
        }
    )
    DomainInfo = @{
        DomainName = 'lab.local'
        PrimaryDC  = 'DC00'
    }
}
