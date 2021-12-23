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
function Invoke-DscLab {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String[]]$Nodes,
        [Parameter(Mandatory)]
        [PSCredential]$Credential
    )

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"

        switch ($PSVersiontable.PSVersion.Major) {
            7       { $Splat = @{Parallel = $null} }
            default { $Splat = @{Process  = $null} }
        }
    }

    process {
        $CertPath    = (Get-LabConfiguration).CertificateExportPath
        $ScriptBlock = {
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
        }

        switch ($Splat.Keys) {
            Parallel { $Splat['Parallel'] = $ScriptBlock }
            Process  { $Splat['Process']  = $ScriptBlock }
        }

        $Nodes | ForEach-Object @Splat
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END :: $(Get-Date)"
    }
}
