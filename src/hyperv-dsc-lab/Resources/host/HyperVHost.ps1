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