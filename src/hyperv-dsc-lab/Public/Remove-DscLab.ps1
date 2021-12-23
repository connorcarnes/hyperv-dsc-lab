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
function Remove-DscLab {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String[]]$Nodes
    )

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
    }

    process {
        $Config = Get-LabConfiguration

        $Nodes | Stop-VM   -Force -ErrorAction 'SilentlyContinue' -WarningAction 'SilentlyContinue'
        $Nodes | Remove-VM -Force -ErrorAction 'SilentlyContinue' -WarningAction 'SilentlyContinue'
        $Nodes | ForEach-Object {Remove-Item "$($Config.VMHostVHDPath)\$_\$_.vhdx" -ErrorAction 'SilentlyContinue'}

        Get-ChildItem -Path $Config.CertificateExportPath | Remove-Item

        Get-ChildItem -Path "Cert:\LocalMachine\My" |
            Where-Object {$_.Subject -like "*-DSC-Lab" -and $_.EnhancedKeyUsageList.FriendlyName -eq 'Document Encryption'} |
            Remove-Item
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END :: $(Get-Date)"
    }
}
