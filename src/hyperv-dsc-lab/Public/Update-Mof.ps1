$vms     = 'DC00', 'DC01'
$VhdPath = 'C:\virt\vhds'

$vms | Foreach-Object -Parallel {
    $VmName  = $_
    $VhdPath = 'C:\virt\vhds'

    $DriveLetter = ((Mount-VHD -Path "$VhdPath\$VmName\$VmName.vhdx" -PassThru |
        Get-Disk |
        Get-Partition |
        Get-Volume).DriveLetter |
        Out-String).Trim()

    $Source      = "C:\code\local-hyperv-dsc-lab\VmConfig"
    $Destination = "$DriveLetter`:\Windows\System32\Configuration"

    Copy-Item -Path "$Source\$VmName.mof" -Destination "$Destination\Pending.mof" -Force
    Copy-Item -Path "$Source\$VmName.meta.mof" -Destination "$Destination\MetaConfig.mof" -Force

    Dismount-VHD "C:\virt\vhds\$VmName\$VmName.vhdx"
}