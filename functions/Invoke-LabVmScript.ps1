function Invoke-LabVmScript {
    <#
        .SYNOPSIS
        Function summary.

        .DESCRIPTION
        In depth description of function.

        .PARAMETER Param
        Description of Parameter.

        .EXAMPLE
        Example usage

        Explanation of example

        .OUTPUTS
        [void]

        .NOTES
        General notes

        .LINK
        google.com
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, HelpMessage = "Path where script is located on the VM.")]
        [string]$ScriptPath,

        [Parameter()]#Mandatory, HelpMessage = "Param help")]
        [string]$VmName = "DC00",

        [Parameter(HelpMessage = "Waits for remote process to exit before returning.")]
        [switch]$Wait
    )

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
    }

    process {
        #$debugpreference = "inquire"
        #write-debug 'test'
        $ScriptSession = New-LabVmPsSession -VmName $VmName
        Write-Verbose "Executing $ScriptPath on $VMName"
        # Get-Runspace | Where-Object {$_.ConnectionInfo.CustomPipeName -eq 'DscScript'}
        $ScriptProcess = Invoke-Command -Session $ScriptSession -ScriptBlock {
            $ScriptContent = Get-Content $Using:ScriptPath -Raw
            $ScriptBlock   = [ScriptBlock]::Create($ScriptContent)
            $ArgumentList  = "-CustomPipeName DscScript -ExecutionPolicy Bypass -NoProfile -Command $ScriptBlock"
            $Splat = @{
                PassThru     = $true
                Wait         = $Using:Wait
                WindowStyle  = 'Hidden'
                ArgumentList = $ArgumentList
                FilePath     = 'pwsh'
            }
            Start-Process @Splat
        }

        Write-Verbose "PROCESS ID :: $($ScriptProcess.Id)"

        Write-Verbose "Removing PSSession"
        Remove-PSSession $ScriptSession

        # Output
        #$ScriptProcess
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END   :: $(Get-Date)"
    }
}