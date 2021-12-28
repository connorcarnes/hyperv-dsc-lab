# https://dsccommunity.org/help/
# https://github.com/dsccommunity/xHyper-V
# https://mikefrobbins.com/2015/01/22/creating-hyper-v-vms-with-desired-state-configuration/
# $env:psmodulepath = 'C:\Program Files\WindowsPowerShell\Modules;C:\Windows\system32\WindowsPowerShell\v1.0\Modules;C:\Program Files (x86)\Windows Kits\10\Microsoft Application Virtualization\Sequencer\AppvPkgConverter;C:\Program Files (x86)\Windows Kits\10\Microsoft Application Virtualization\Sequencer\AppvSequencer;C:\Program Files (x86)\Windows Kits\10\Microsoft Application Virtualization\'
# Installing roles and features using PowerShell Desired State Configuration is supported only on Server SKU's. It is not supported on Client SKU.
# https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/user-guide/setup-nat-network
configuration HyperVHost
{
    param
    (
        [System.String[]]
        $NodeName = 'localhost',

        [System.String]
        $SwitchName = 'Default Switch',

        [System.String]
        $LabVHDPath = 'D:\virt\vhds'
    )

    #Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'xHyper-V'

    Node $NodeName
    {
        xVMHyperV DC00
        {
            Name            = 'DC00'
            Generation      = 2
            SwitchName      = $SwitchName
            VhdPath         = "$LabVHDPath\DC00\DC00.vhdx"
            ProcessorCount  = 2
            MaximumMemory   = 2GB
            MinimumMemory   = 512MB
            RestartIfNeeded = $true
            State           = 'Running'
            WaitForIp       = $false
        }

        xVMHyperV DC01
        {
            Name            = 'DC01'
            Generation      = 2
            SwitchName      = $SwitchName
            VhdPath         = "$LabVHDPath\DC01\DC01.vhdx"
            ProcessorCount  = 2
            MaximumMemory   = 2GB
            MinimumMemory   = 512MB
            RestartIfNeeded = $true
            State           = 'Running'
            WaitForIp       = $false
        }
    }
}
HyperVHost -OutputPath C:\virt\mofs\host
Start-DscConfiguration -Computername 'localhost' -Wait -Verbose -Force -Path C:\virt\mofs\host