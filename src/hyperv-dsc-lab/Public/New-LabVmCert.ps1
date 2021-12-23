$vms = 'DC00','DC01'

$vms | ForEach-Object -Parallel {
    $Session = New-PSSession $_ -Credential $using:icred

    $Cert = Invoke-Command -Session $Session -ScriptBlock {
        $Splat = @{
            Type          = 'DocumentEncryptionCertLegacyCsp'
            DnsName       = "$env:computername-DSC"
            HashAlgorithm = 'SHA256'
        }
        New-SelfSignedCertificate @Splat
    }

    $Path = "C:\code\local-hyperv-dsc-lab\certs\$_-DscPubKey.cer"
    [void](Export-Certificate -Cert $Cert -FilePath $Path)
    [void](Import-Certificate -FilePath $Path -CertStoreLocation Cert:\LocalMachine\My)
}
