<#
    .SYNOPSIS
    Creates self-signed certificate on a VM and exports it to the host.

    .DESCRIPTION
    Creates self-signed certificate on a VM and exports it to the host. Certificate is created in a remote PSSession. Certificate public key is exported
    to the CertificatePath value of Get-LabConfigurationwith the name "<YourVMName>-DSC-Lab-PubKey.cer" and imported into the host's certificate store
    at Cert:\LocalMachine\My.

    Certificates are created via New-SelfSignedCertificate with the below parameters::

    Type          = 'DocumentEncryptionCertLegacyCsp'
    Subject       = '<YourVMName>-DSC-Lab'
    HashAlgorithm = 'SHA256'

    .PARAMETER VMs
    Array of VM names.

    .PARAMETER Credential
    PSCredential used to open a remote session on the VMs.

    .EXAMPLE
    $Credential = Get-Credential
    New-LabVMCertificate -VMs 'DC00','DC01' -Credential $Credential

    Opens a remote session for DC00 and DC01 and creates a self-signed certificate on each VM. The certificate public key is exported
    to the CertificatePath value of Get-LabConfigurationand imported into the host's certificate store at Cert:\LocalMachine\My.

    .OUTPUTS
    [void]

    .LINK
    https://docs.microsoft.com/en-us/powershell/dsc/pull-server/secureMOF?view=dsc-1.1
#>
function New-LabVMCertificate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,HelpMessage = "Array of VM names")]
        [String[]]$VMs,

        [Parameter(Mandatory,HelpMessage = "PSCredential used to open a remote session on the VMs")]
        [PSCredential]$Credential
    )

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
        [void](Test-LabConfiguration -ErrorAction 'Stop')
    }

    process {
        $CertPath = $LAB_CONFIG.CertificatePath
        if (-not (Test-Path $CertPath)) {
            Write-Verbose "Creating certificate directory: $CertPath"
            [void](New-Item -Path $CertPath -ItemType Directory)
        }

        Write-Verbose "Creating new self-signed certificate on VM(s): $($VMs -join ', ')"
        Write-Verbose "Public keys will be exported to $CertPath and imported to Cert:\LocalMachine\My on the host."
        $VMs | ForEach-Object -Process {
            $Session     = New-PSSession $_ -Credential $Credential
            $CertSubject = "$_-DSC-Lab"
            $Cert        = Invoke-Command -Session $Session -ScriptBlock {
                $Splat = @{
                    Type          = 'DocumentEncryptionCertLegacyCsp'
                    Subject       = "$Using:CertSubject"
                    HashAlgorithm = 'SHA256'
                }
                New-SelfSignedCertificate @Splat
            }

            # Export cert from vm and import to host certificate store.
            $Path = "$CertPath\$CertSubject-PubKey.cer"
            [void](Export-Certificate -Cert $Cert -FilePath $Path)
            [void](Import-Certificate -FilePath $Path -CertStoreLocation Cert:\LocalMachine\My)

            $Session | Remove-PSSession
        }
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END   :: $(Get-Date)"
    }
}
