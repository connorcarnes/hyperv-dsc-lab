<#
    .SYNOPSIS
    Waits for DSC Lab VMs to be ready.

    .DESCRIPTION
    Waits for DSC Lab VMs to be ready. The VM is considered ready when the Hyper-V VM name matches the hostname in the OS. This is checked by repeatedly attempting to connect to the VM via
    PowerShell Session and comparing the VM OS name with the name supplied in the -VMs parameter.

    .PARAMETER VMs
    Array of Hyper-V Lab VMs names.

    .PARAMETER LocalCredential
    Local Credential used to connect to VMs.

    .PARAMETER TimeoutMinutes
    Timeout in minutes the command will wait. Error is thrown is timeout is reached. Default value is 5 minutes.

    .EXAMPLE
    Wait-LabVM -VM $VMs -LocalCredential $LocalCredential

    Waits for DSC Lab VMs to be ready.

    .OUTPUTS
    [void]
#>
function Wait-LabVM {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String[]]$VMs,

        [Parameter(Mandatory)]
        [PSCredential]$LocalCredential,

        [Parameter()]
        [int]$TimeoutMinutes = 5
    )

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
    }

    process {
        [System.Collections.Arraylist]$VMsNotReady = @()
        $VMs.ForEach{[void]($VMsNotReady.Add($_))}
        $Start   = Get-Date
        $Timeout = $Start.AddMinutes($TimeoutMinutes)

        while ($VMsNotReady.Count -gt 0) {
            $Now            = Get-Date
            $SecondsElapsed = [math]::Round(($Now - $Start).TotalSeconds)
            Write-Verbose "Waiting for VMs $($VMsNotReady -join ', ') to be ready. Seconds elapsed: $SecondsElapsed"

            if ($Now -gt $Timeout) {
                Throw "Reached $TimeoutMinutes minute timeout waiting for VMs to be ready"
            }
            else {
                $VMsNotReady | ForEach-Object {
                    $Session = New-PSSession $_ -Credential $LocalCredential -ErrorAction 'SilentlyContinue'
                    if ($Session) {
                        $OSName = Invoke-Command -Session $Session -ErrorAction 'SilentlyContinue' -ScriptBlock {hostname}
                        if ($OSName -eq $_) {
                            Write-Verbose "VM $_ is ready. Time: $(Get-Date)"
                            [void]($VMsNotReady.Remove($_))
                        }
                    }
                    else {
                        Start-Sleep 2
                    }
                }
            }
        }

        Write-Verbose "VMs are ready. Waiting 10 more seconds..."
        Start-Sleep 10
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END   :: $(Get-Date)"
    }
}