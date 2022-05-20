# WIP

## Requirements
### [DSC V2](https://docs.microsoft.com/en-us/powershell/dsc/overview?view=dsc-2.0)

Install-Module -Name PSDesiredStateConfiguration -Repository PSGallery -MaximumVersion 2.99

### [Invoke-DSCResource](https://docs.microsoft.com/en-us/powershell/module/psdesiredstateconfiguration/invoke-dscresource?view=dsc-2.0#description))

Enable-ExperimentalFeature PSDesiredStateConfiguration.InvokeDscResource

### Dependencies

'PackageManagement'
'NetworkingDsc'
'ComputerManagementDsc'
'ActiveDirectoryDsc'

# Get ISO

# SYSPREP/ANSWERFILE/SETUP SCRIPT STEPS

# Add VMs to TrustedHosts

https://www.dtonias.com/add-computers-trustedhosts-list-powershell/
(Get-Item WSMan:\localhost\Client\TrustedHosts).value
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "$curList, Server01"
Set-Item WSMan:\localhost\Client\TrustedHosts -Concatenate -Value Server02

Now you can

Enter-PSSession -ComputerName YourVM -Credential (Get-Credential)
