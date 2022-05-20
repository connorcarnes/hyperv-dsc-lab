function New-LabVm {
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
        [string]$BaseVHDPath = $ModuleConfig.BaseVHDPath,

        [Parameter()]#Mandatory, HelpMessage = "Param help")]
        [string]$LabPath = $ModuleConfig.LabPath,

        [Parameter()]#Mandatory, HelpMessage = "Param help")]
        [string]$VmName = "DC00"
    )

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
    }

    process {
        Write-Verbose "Testing path: $BaseVHDPath"
        $BaseVHDPathTest = Test-Path $BaseVHDPath
        if (-not $BaseVHDPathTest) {
            throw "Base VHD Path does not exist"
        }

        $VmFolder = "$LabPath\$VmName"
        Write-Verbose "Testing path: $VmFolder"
        $LabPathTest = Test-Path $VmFolder
        if (-not $LabPathTest) {
            New-Item -Path $VmFolder -Type Directory -Force
            Write-Verbose "Created folder: $VmFolder"
        }

        $VmVhdPath = "$VmFolder\$VmName.vhdx"
        Write-Verbose "Copying $BaseVHDPath to $VmVhdPath "
        Copy-Item -Path $BaseVHDPath -Destination $VmVhdPath  -Force

        Write-Verbose "Updating launch scripts"
        $DriveLetter = ((Mount-VHD -Path $VmVhdPath  -PassThru |
            Get-Disk |
            Get-Partition |
            Get-Volume).DriveLetter |
            Out-String).Trim()

        Write-Verbose "Updating setup.ps1"
        $SetupScript = Get-Content -Path "$($ModuleConfig.ModulePath)\resources\setup.ps1" -Raw
        $SetupScript = $SetupScript -Replace '#NEWNAME#', $VmName
        $SetupScript |
            Set-Content -Path "$DriveLetter`:\Windows\Panther\setup.ps1" -Force

        Write-Verbose "Updating DscScript.ps1"
        Get-LabVmDscScript |
            Set-Content -Path "$DriveLetter`:\Windows\Panther\DscScript.ps1" -Force

        Write-Verbose "Updating Bootstrap.ps1"
        Get-Content -Path "$($ModuleConfig.ModulePath)\resources\Bootstrap.ps1" |
            Set-Content -Path "$DriveLetter`:\Windows\Panther\Bootstrap.ps1" -Force

        Dismount-VHD -Path $VmVhdPath

        Write-Verbose "Creating VM $VmName on host $($ENV:COMPUTERNAME)"
        $Splat = @{
            Module   = 'xHyper-V'
            Name     = 'xVMHyperV'
            Method   = 'Set'
            Property = @{
                Name                        = $VMName
                Generation                  = 2
                SwitchName                  = 'Default Switch'
                VhdPath                     = $VmVhdPath # "D:\virt\vhds\base-vhds\$Name.vhdx"
                Path                        = $LabPath
                ProcessorCount              = 2
                MaximumMemory               = 4GB
                MinimumMemory               = 1024MB
                RestartIfNeeded             = $true
                State                       = 'Running'
                WaitForIp                   = $false
                AutomaticCheckpointsEnabled = $false
                # DependsOn                   [string[]]
                # EnableGuestService          [bool]
                # Ensure                      [string]
                # MACAddress                  [string[]]
                # Notes                       [string]
                # PsDscRunAsCredential        [PSCredential]
                # SecureBoot                  [bool]
                # StartupMemory               [UInt64]
            }
        }
        $null = Invoke-DscResource @Splat

        Invoke-LabVmScript -ScriptPath 'C:\Windows\Panther\Bootstrap.ps1' -Verbose -Wait

        Invoke-LabVmScript -ScriptPath 'C:\Windows\Panther\DscScript.ps1' -Verbose -Wait
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END   :: $(Get-Date)"
    }
}
#New-LabVm -verbose