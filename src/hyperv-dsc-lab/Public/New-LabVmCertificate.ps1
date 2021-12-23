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

        $Nodes | ForEach-Object -Parallel {
            $Session = New-PSSession $_ -Credential $Using:Credential
            $Cert = Invoke-Command -Session $Session -ScriptBlock {
                $Splat = @{
                    Type          = 'DocumentEncryptionCertLegacyCsp'
                    Subject       = "$env:computername-DSC-Lab"
                    HashAlgorithm = 'SHA256'
                }
                New-SelfSignedCertificate @Splat
            }
            $Path = "$Using:CertPath\$_-DSC-Lab-PubKey.cer"
            [void](Export-Certificate -Cert $Cert -FilePath $Path)
            [void](Import-Certificate -FilePath $Path -CertStoreLocation Cert:\LocalMachine\My)
            $Session | Remove-PSSession
        }
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END :: $(Get-Date)"
    }
}
