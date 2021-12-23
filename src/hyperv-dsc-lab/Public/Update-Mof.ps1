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
function Update-Mof {
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
        $Config = Get-LabConfiguration

        $ScriptBlock = {
            $Session = New-PSSession $_ -Credential $Using:Credential
            Invoke-Command -Session $Session -ScriptBlock {
                $PendingMofPath    = "C:\Windows\System32\Configuration\Pending.mof"
                $MetaConfigMofPath = "C:\Windows\System32\Configuration\MetaConfig.mof"
                Copy-Item -Path "$($Using:Config.MofExportPath)\$_.mof"      -Destination $PendingMofPath    -Force
                Copy-Item -Path "$($Using:Config.MofExportPath)\$_.meta.mof" -Destination $MetaConfigMofPath -Force
            }
            $Session | Remove-PSSession
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