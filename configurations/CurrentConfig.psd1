@{
    Generic = @{
        DisableIPv6 = $true
        DisableDhcp = $true
    }
    DomainName            = "first.local"
    DomainCredential      = ""
    DomainSafemodeAdminPw = ""
    ForestMode            = 'WinThreshold'
    DefaultGateway        = '172.19.160.1'
    DnsAddresses          = '172.19.160.10','1.1.1.1'
    Vms = @{
        DC00 = @{
            Ip              = '172.19.160.10'
            WindowsFeatures = 'AD-Domain-Services'
            LastOctet       = '10'
        }
        #DC01   = "10.0.0.11"
        #WEB00  = "10.0.10.10"
        #WEB01  = "10.0.10.11"
        #SQL00  = "10.0.20.10"
        #SQL01  = "10.0.20.11"
        #FILE00 = "10.0.30.10"
        #FILE01 = "10.0.30.11"
        #APP00  = "10.0.40.10"
        #APP01  = "10.0.40.11"
    }
}
