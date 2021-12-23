$vms | Stop-VM -Force -ErrorAction 'SilentlyContinue'
$vms | Remove-VM -Force -ErrorAction 'SilentlyContinue'
$vms | ForEach-Object { Remove-Item $VhdPath\$_\$_.vhdx }