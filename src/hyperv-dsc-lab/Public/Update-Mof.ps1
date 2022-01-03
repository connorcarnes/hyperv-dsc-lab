<#
    .SYNOPSIS
    Copies MOF files generated on the host to VMs.

    .DESCRIPTION
    Copies MOF files generated on the host to VMs. Searches MofPath of Get-LabConfigurationfor MOF files. Files are copied
    via a Remote PowerShell session and Invoke-Command. Files ending in .mof are copied to "C:\Windows\System32\Configuration\Pending.mof"
    Files ending in .meta.mof are copied to "C:\Windows\System32\Configuration\MetaConfig.mof". MOF files stored in these locations are
    applied when the VM is rebooted.

    .PARAMETER VMs
    Array of VM names.

    .PARAMETER Credential
    PSCredential used to open a remote session on the VMs.

    .EXAMPLE
    $Credential = Get-Credential
    Update-Mof -VMs 'DC00','DC01' -Credential $Credential

    Opens a remote session for DC00 and DC01 and copies relevant MOF files to "C:\Windows\System32\Configuration" for each VM.

    .OUTPUTS
    [void]

    .LINK
    https://docs.microsoft.com/en-us/powershell/dsc/tutorials/bootstrapdsc?view=dsc-1.1
#>
function Update-Mof {
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
        $VMs | ForEach-Object -Parallel {
            $Session        = New-PSSession $_ -Credential $Using:Credential
            $MofContent     = Get-Content "$($Using:LAB_CONFIG.MofPath)\$_.mof" -Raw
            $MetaMofContent = Get-Content "$($Using:LAB_CONFIG.MofPath)\$_.meta.mof" -Raw
            Invoke-Command -Session $Session -ArgumentList $MofContent,$MetaMofContent -ScriptBlock {
                param($MofContent,$MetaMofContent)
                Set-Content -Path "C:\Windows\System32\Configuration\Pending.mof"    -Value $MofContent     -Force
                Set-Content -Path "C:\Windows\System32\Configuration\MetaConfig.mof" -Value $MetaMofContent -Force
            }
            $Session | Remove-PSSession
        }
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END   :: $(Get-Date)"
    }
}