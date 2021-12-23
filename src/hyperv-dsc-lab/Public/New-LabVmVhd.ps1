$vms     = 'DC00', 'DC01'
$VhdPath = 'C:\virt\vhds'
$vms | Stop-VM -Force -ErrorAction 'SilentlyContinue'
$vms | Remove-VM -Force -ErrorAction 'SilentlyContinue'
$vms | ForEach-Object { Remove-Item $VhdPath\$_\$_.vhdx }

$vms | Foreach-Object -Parallel {
    $VmName = $_
    $VhdPath         = 'C:\virt\vhds'
    $BaseVHD         = "$VhdPath\gold-imgs\test.vhdx"
    $SetupScript     = "C:\code\local-hyperv-dsc-lab\Setup.ps1"
    $NewCertFunction = "C:\code\local-hyperv-dsc-lab\New-SelfSignedCertificateEx.ps1"
    $Path            = "$VhdPath\$VmName"

    if (-not (Test-Path $Path)) {
        New-Item -Type Directory -Path $Path
    }

    Copy-Item -Path $BaseVHD -Destination "$VhdPath\$VmName\$VmName.vhdx"

    $DriveLetter = ((Mount-VHD -Path "C:\virt\vhds\$VmName\$VmName.vhdx" -PassThru |
        Get-Disk |
        Get-Partition |
        Get-Volume).DriveLetter |
        Out-String).Trim()

    $ExecutionContext.InvokeCommand.ExpandString((Get-Content $SetupScript -Raw)) |
        Set-Content "$DriveLetter`:\Windows\Panther\Setup.ps1" -Force

    #Copy-Item -Path $SetupScript -Destination "$DriveLetter`:\Windows\Panther\Setup.ps1" -Force
    Copy-Item -Path $NewCertFunction -Destination "$DriveLetter`:\Windows\Panther\New-SelfSignedCertificateEx.ps1" -Force

    Dismount-VHD "C:\virt\vhds\$VmName\$VmName.vhdx"
}