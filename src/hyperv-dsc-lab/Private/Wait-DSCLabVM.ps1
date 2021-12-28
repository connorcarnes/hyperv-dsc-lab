<#
    .SYNOPSIS
    Waits for DSC Lab VMs to be ready.

    .DESCRIPTION
    Waits for DSC Lab VMs to be ready. The VM is considered ready when the Hyper-V VM name matches the hostname in the OS.

    .PARAMETER VMs
    Array of Hyper-V Lab VMs.

    .PARAMETER LocalCredential
    Local Credential used to connect to VMs.

    .PARAMETER TimeoutMinutes
    Timeout in minutes the command will wait. Error is thrown is timeout is reached. Default value is 5 minutes.

    .EXAMPLE
    Wait-DSCLabVM -VM $VMs -LocalCredential $LocalCredential

    Waits for DSC Lab VMs to be ready.

    .OUTPUTS
    [void]
#>
function Wait-DSCLabVM {
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
        [System.Collections.Arraylist]$VMsReady    = @()
        [System.Collections.Arraylist]$VMsNotReady = @()
        $VMs.ForEach{[void]($VMsNotReady.Add($_))}
        $Start   = Get-Date
        $Timeout = $Start.AddMinutes($TimeoutMinutes)

        # Compare-Object returns null when both objects are equal.
        while((Compare-Object -ReferenceObject $VMs -DifferenceObject $VMsReady)) {
            $Now = Get-Date
            if ($Now -gt $Timeout) {
                Throw "Reached $TimeoutMinutes minute timeout waiting for VMs to be ready"
            }

            $SecondsElapsed = ($Now - $Start).TotalSeconds.ToInt16($_)
            Write-Verbose "Waiting for VMs to be ready. Seconds elapsed: $SecondsElapsed"

            $VMsNotReady  | ForEach-Object {
                $Session = New-PSSession $_ -Credential $LocalCredential -ErrorAction 'SilentlyContinue'
                if ($Session) {
                    $OSName  = Invoke-Command -Session $Session -ErrorAction 'SilentlyContinue' -ScriptBlock {hostname}
                    if ($OSName -eq $_) {
                        Write-Verbose "VM $_ is ready. Time: $(Get-Date)"
                        [void]($VMsReady.Add($_))
                        [void]($VMsNotReady.Remove($_))
                    }
                }
                else {
                    Start-Sleep 5
                }
            }
        }
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END :: $(Get-Date)"
    }
}