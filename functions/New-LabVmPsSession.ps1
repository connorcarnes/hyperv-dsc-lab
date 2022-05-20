function New-LabVmPsSession {
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
        [Parameter()]#Mandatory, HelpMessage = "Param help")]
        [string]$VmName = "DC00",

        [Parameter(HelpMessage = "Enter the timeout in minutes.")]
        [int]$TimeoutMinutes = 3
    )

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
    }

    process {
        $Start    = Get-Date
        $Timeout  = $Start.AddMinutes($TimeoutMinutes)
        $Password = ConvertTo-SecureString $ModuleConfig.PlainTextPassword -AsPlainText -Force
        $Cred     = [System.Management.Automation.PSCredential]::New(
            'Administrator',
            (ConvertTo-SecureString $ModuleConfig.PlainTextPassword -AsPlainText -Force)
        )

        while (-not $Session) {
            $Now            = Get-Date
            $SecondsElapsed = [math]::Round(($Now - $Start).TotalSeconds)
            Write-Verbose "Waiting for $VMName. Seconds elapsed: $SecondsElapsed"
            if ($Now -gt $Timeout) {
                Throw "Reached $TimeoutMinutes minute timeout waiting for VMs to be ready"
            }
            else {
                $Session = New-PSSession $VMName -ConfigurationName 'PowerShell.7.2.3' -Credential $Cred -ErrorAction 'SilentlyContinue'
            }
        }

        Write-Verbose "Session established"
        $Session
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END   :: $(Get-Date)"
    }
}