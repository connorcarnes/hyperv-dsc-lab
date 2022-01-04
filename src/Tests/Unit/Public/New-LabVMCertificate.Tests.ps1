Set-Location -Path $PSScriptRoot
# If the module is already in memory, remove it
$ModuleName     = 'hyperv-dsc-lab'
$PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
if (Get-Module -Name $ModuleName -ErrorAction 'SilentlyContinue') {
    Remove-Module -Name $ModuleName -Force
}
Import-Module $PathToManifest -Force

InModuleScope 'hyperv-dsc-lab' {
    Describe 'New-LabVMCertificate' -Tag Unit {
        BeforeAll {
            # Load mock objects in '\src\Tests\Unit\UnitTestData.ps1'
            $ModuleBase            = (Get-Module -Name 'hyperv-dsc-lab').ModuleBase
            . $ModuleBase.Replace('\src\hyperv-dsc-lab','\src\Tests\Unit\UnitTestData.ps1')
            $WarningPreference     = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
            Mock Test-LabConfiguration     -MockWith {$true}
            Mock ForEach-Object            -MockWith {}
            Mock New-PSSession             -MockWith {}
            Mock Invoke-Command            -MockWith {}
            Mock New-SelfSignedCertificate -MockWith {}
            Mock Export-Certificate        -MockWith {}
            Mock Import-Certificate        -MockWith {}
            Mock Remove-PSSession          -MockWith {}
        }
        It 'Creates the certificate directory if it does not exist' {
            Mock Test-Path -MockWith {$false}
            Mock New-Item  -MockWith {}
            New-LabVMCertificate -VMs 'MockVM' -Credential $MockCred
            Should -Invoke New-Item -Times 1 -Exactly
        }
    }
}
