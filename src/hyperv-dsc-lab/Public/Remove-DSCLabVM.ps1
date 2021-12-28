<#
    .SYNOPSIS
    Deletes Lab VMs and associated files.

    .DESCRIPTION
    Deletes Lab VMs and associated files. The following items are deleted by default:

    - VM's VHD(s)
    - VM's virtual machine files
    - Certificates exported to cert:\localmachine\my and CertificatePath of Get-DSCLabConfiguration

    .PARAMETER VMs
    Array of Lab VMs to delete.

    .PARAMETER SkipVHDRemoval
    If this switch is specified the VM's VHD(s) are not deleted.

    .EXAMPLE
    $VMs = 'DC00','DC01'
    Remove-DSCLabVm -VMs $VMs

    Deletes Lab VMs DC00 and DC01, including their VHDs and associated certificates.

    .OUTPUTS
    [void]
#>
function Remove-DSCLabVM {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String[]]$VMs,

        [Parameter(HelpMessage="If this switch is specified the VM's VHD(s) are not deleted.")]
        [Switch]$SkipVHDRemoval
    )

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
    }

    process {
        $Config = Get-DSCLabConfiguration

        Write-Verbose "Stopping VM(s): $($VMs -join ', ')"
        $VMs | Stop-VM -Force -ErrorAction 'SilentlyContinue' -WarningAction 'SilentlyContinue'

        Write-Verbose "Removing VM(s): $($VMs -join ', ')"
        $VMs | Remove-VM -Force -ErrorAction 'SilentlyContinue' -WarningAction 'SilentlyContinue'

        Write-Verbose "Gathering items for deletion..."
        [System.Collections.ArrayList]$ItemsToRemove = @()
        $VMs | ForEach-Object -Process {
            $VM = $_
            Get-ChildItem -Path $Config.CertificatePath -Filter "$VM-DSC-Lab-PubKey.cer" |
                ForEach-Object {[void]($ItemsToRemove.Add($_.PSPath))}
            Get-ChildItem -Path "Cert:\LocalMachine\My" |
                Where-Object {$_.Subject -eq "CN=$VM-DSC-Lab" -and $_.EnhancedKeyUsageList.FriendlyName -eq 'Document Encryption'} |
                ForEach-Object {[void]($ItemsToRemove.Add($_.PSPath))}
            if (-not $SkipVHDremoval) {
                Get-ChildItem "$($Config.LabVHDPath)\$VM" |
                    ForEach-Object {[void]($ItemsToRemove.Add($_.PSPath))}
            }
        }

        Write-Verbose "Removing items:`n$($ItemsToRemove -join "`n")"
        $ItemsToRemove.ForEach{Remove-Item -PSPath $_}
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END :: $(Get-Date)"
    }
}
