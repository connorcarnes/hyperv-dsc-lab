# Work In Progress
## HyperV-DSC-Lab

This repo is good for two things:

1. Learning the basics of DSC.
2. Creating Hyper-V lab environments on your local workstation.

It contains two DSC configurations that create a domain and two domain controllers. Functions are included to handle DSC configuration data, securing the mof files with certificates, destroying the lab, etc. It's made to be simple and expandable.

>I originally wrote this with the idea it'd be PowerShell 7 only and haven't made it fully compatible with Windows PowerShell yet. Both WindowsPowerShell and PowerShell 7 are required but the module should be run from a PowerShell 7 session.

## Overview

There is a DSC configuration for the host and one for the VMs (`HostConfig.ps1` and `VMConfig.ps1`). `HostConfig.ps1` creates the VMs on your workstation. For simplicity they leverage the NAT capabilities of the Windows 10 Hyper-V Default Switch for internet connectivity. `VMConfig.ps1` creates the domain and configures the VMs as domain controllers.

Some important functions to get familiar with are `Set-LabConfiguration`, `Get-LabConfiguration` and `New-HyperVDSCLab`. `Set-LabConfiguration` and `Get-LabConfiguration` will be discussed later. `New-HyperVDSCLab` is detailed below.

Steps taken by `New-HyperVDSCLab`:

1. A base VHD is created. The VHD contains an answerfile that runs a setup script on first boot (base VHD and answerfile not included atm, will be added later). The setup script does a few key things:

    - Updates Nuget and PowerShellGet
    - Installs required DSC modules
    - Enables all DSC logging
    - Updates the hostname of the VM

2. `New-LabVMVHD` copies the base VHD and updates the setup script with the appropriate hostname.

3. `HostConfig.ps1` is compiled and applied to your workstation. The VHDs copied in the previous step are used for the VMs.

4. `Wait-LabVM` waits for the VMs to boot and run the setup script.

5. `New-LabVMCertificate` remotes into each VM, creates a self signed certificate and exports it to the host. These certificates are leveraged in `VmConfig.ps1` to encrypt credentials in the mof files.

6. `VmConfig.ps1` is compiled (but not applied) on the host. It generates a .mof and a .meta.mof file for each VM.

7. Update-Mof copies the .mof files to their respective VM. The .mof file is copied to `C:\Windows\System32\Configuration\Pending.mof` and the .meta.mof file is copied to `C:\Windows\System32\Configuration\MetaConfig.mof`. Mofs stored in these locations are applied when Windows boots.

8. Reboot the VMs, wait for the mofs to be applied and your lab is ready.

9. `Remove-LabVM` can be used to delete a lab VM, it's VHD and it's relevant certificates stored on the host. It's run at the very start of `New-HyperVDSCLab` and can be run ad hoc.

## Pre Reqs

Experience with Windows PowerShell and PowerShell, basic understanding of DSC, Hyper-V installed, PowerShell 7 installed, a base or "golden" VHD file that runs a setup script on first boot (base VHD is not included atm, will add it or steps to create it later)

The following DSC modules installed:

'xHyper-V'
'PackageManagement'
'NetworkingDsc'
'ComputerManagementDsc'
'PSDscResources'
'ActiveDirectoryDsc'

## Get Started

Open an elevated PowerShell 7 session, clone this repo and import the module.

```PowerShell
$RootDir = 'YourDirectoryHere'
Set-Location $RootDir
git clone https://github.com/connorcarnes/hyperv-dsc-lab
Set-Location .\hyperv-dsc-lab
Import-Module .\src\hyperv-dsc-lab\hyperv-dsc-lab.psd1
```

You'll get a warning about needing to run Set-LabConfiguration. Set-LabConfiguration does a few things:

- Updates `$RootDir\hyperv-dsc-lab\src\hyperv-dsc-lab\LabConfiguration.json` with values you provide.
- Converts LabConfiguration.json to a PSObject and loads it as `$Script:LAB_CONFIG`.
- Tests your configuration and lets you know if any required properties are missing.

Once your lab configuration is set ensure you can load the DSC configurations.

```PowerShell
$RootDir = 'YourDirectoryHere'
Set-Location $RootDir
. src\hyperv-dsc-lab\Resources\host\HyperVHost.ps1
. src\hyperv-dsc-lab\Resources\vms\VmConfig.ps1
```

You may get an error stating multiple versions of a module were found. You will either need to remove the duplicate version(s) from `$ENV:PSModulePath` or version pin the module to the latest version in the DSC configuration file. For example if you have PackageManagement versions 1.0.0.1 and 1.4.7 installed, update the line `Import-DscResource -ModuleName 'PackageManagement'` in `VMConfig.ps1` to `Import-DscResource -ModuleName 'PackageManagement' -ModuleVersion '1.4.7'`.