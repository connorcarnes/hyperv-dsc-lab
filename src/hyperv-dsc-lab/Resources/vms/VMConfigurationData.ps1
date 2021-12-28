@{
    AllNodes = @(
        @{
            NodeName             = "*"
            RebootNodeIfNeeded   = `$true
            PSDscAllowDomainUser = `$true
            DNSAddresses         = '${DC00IP}', '${DC01IP}', '8.8.8.8', '1.1.1.1'
            DefaultGateway       = '${DefaultGateway}'
        },
        @{
            NodeName        = 'DC00'
            IPAddress       = '${DC00IP}'
            CertificateFile = '${CertificatePath}\DC00-DSC-Lab-PubKey.cer'
            Role            = 'Domain Controller'
        },
        @{
            NodeName        = 'DC01'
            IPAddress       = '${DC01IP}'
            CertificateFile = '${CertificatePath}\DC01-DSC-Lab-PubKey.cer'
            Role            = 'Domain Controller'
        }
    )
    DomainInfo = @{
        DomainName = 'lab.local'
        PrimaryDC  = 'DC00'
    }
}