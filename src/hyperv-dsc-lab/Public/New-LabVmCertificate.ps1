<#
    .SYNOPSIS
        Short descripton
    .DESCRIPTION
        Long description
    .PARAMETER ParamterOne
        Explain the parameter
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    .OUTPUTS
        Output (if any)
    .NOTES
        General notes
    .LINK
        Link to other documentation
#>
function New-LabVmCertificate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String[]]$Nodes,
        [Parameter(Mandatory)]
        [PSCredential]$Credential
    )

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
    }

    process {
        $CertPath = (Get-LabConfiguration).CertificateExportPath
        if (-not (Test-Path $CertPath)) {
            [void](New-Item -Path $CertPath -ItemType Directory)
        }

        $Nodes | ForEach-Object -Process {
            $Session     = New-PSSession $_ -Credential $Credential
            $CertSubject = "$_-DSC-Lab"

            # Remove old lab certificates from host
            Get-ChildItem -Path "Cert:\LocalMachine\My" |
                Where-Object {$_.Subject -eq "CN=$CertSubject" -and $_.EnhancedKeyUsageList.FriendlyName -eq 'Document Encryption'} |
                Remove-Item

            $Cert = Invoke-Command -Session $Session -ScriptBlock {
                # Remove old lab certificates from vm
                [void](Get-ChildItem Cert:\LocalMachine\My |
                    Where-Object {$_.Subject -eq "CN=$Using:CertSubject"} |
                    Remove-Item)
                # Create new cert
                $Splat = @{
                    Type          = 'DocumentEncryptionCertLegacyCsp'
                    Subject       = "$Using:CertSubject"
                    HashAlgorithm = 'SHA256'
                }
                New-SelfSignedCertificate @Splat
            }

            # Export cert from vm and import to host
            $Path = "$CertPath\$CertSubject-PubKey.cer"
            [void](Export-Certificate -Cert $Cert -FilePath $Path)
            [void](Import-Certificate -FilePath $Path -CertStoreLocation Cert:\LocalMachine\My)
            $Session | Remove-PSSession
        }
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END :: $(Get-Date)"
    }
}
