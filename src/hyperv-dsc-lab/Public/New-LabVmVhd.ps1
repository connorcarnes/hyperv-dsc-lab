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
function New-LabVMVHD {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String[]]$VMs
    )

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
    }

    process {
        $Config = Get-DSCLabConfiguration
        $VMVHDFolder = "$($Config.VHDPath)\`$_"
        $VMVHDPath = "$VMVHDFolder\`$_.vhdx"
        $BaseVHDPath = $Config.BaseVHDPath
        $SetupScriptPath = $Config.SetupScriptPath

        $ScriptBlock = @"
if (-not (Test-Path $VMVHDFolder)) {
    [void](New-Item -Type Directory -Path $VMVHDFolder)
}

Copy-Item -Path $BaseVHDPath -Destination $VMVHDPath

`$DriveLetter = ((Mount-VHD -Path $VMVHDPath -PassThru |
    Get-Disk |
    Get-Partition |
    Get-Volume).DriveLetter |
    Out-String).Trim()

# Reassign $_ here for string expansion in setup.ps1
`$VmName = `$_
`$ExecutionContext.InvokeCommand.ExpandString((Get-Content $SetupScriptPath -Raw)) |
    Set-Content "`$DriveLetter``:\Windows\Panther\Setup.ps1" -Force

Dismount-VHD $VMVHDPath
"@

        switch ($PSVersiontable.PSVersion.Major) {
            7 { $Splat = @{Parallel = [scriptblock]::Create($ScriptBlock) } }
            default { $Splat = @{Process = [scriptblock]::Create($ScriptBlock) } }
        }

        $VMs | ForEach-Object @Splat -Verbose
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END   :: $(Get-Date)"
    }
}