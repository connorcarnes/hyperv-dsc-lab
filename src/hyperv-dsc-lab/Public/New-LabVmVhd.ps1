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
        $Config = Get-LabConfiguration

        $ScriptBlock = {
            $VMVHDFolder = "$($Using:Config.VMHostVHDPath)\$_"
            if (-not (Test-Path $VMVHDFolder) {
                [void](New-Item -Type Directory -Path $VMVHDFolder)
            }

            Copy-Item -Path $($Using:Config.BaseVHDPath) -Destination "$VMVHDFolder\$_.vhdx"

            $DriveLetter = ((Mount-VHD -Path "$VMVHDFolder\$_.vhdx" -PassThru |
                Get-Disk |
                Get-Partition |
                Get-Volume).DriveLetter |
                Out-String).Trim()

            # Reassign $_ here for string expansion in setup.ps1
            $VmName = $_
            $ExecutionContext.InvokeCommand.ExpandString((Get-Content $SetupScript -Raw)) |
                Set-Content "$DriveLetter`:\Windows\Panther\Setup.ps1" -Force

            Dismount-VHD "C:\virt\vhds\$VmName\$VmName.vhdx"
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