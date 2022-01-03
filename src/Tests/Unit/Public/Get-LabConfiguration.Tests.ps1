#-------------------------------------------------------------------------
Set-Location -Path $PSScriptRoot
#-------------------------------------------------------------------------
$ModuleName = 'hyperv-dsc-lab'
$PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
#-------------------------------------------------------------------------
if (Get-Module -Name $ModuleName -ErrorAction 'SilentlyContinue') {
    #if the module is already in memory, remove it
    Remove-Module -Name $ModuleName -Force
}
Import-Module $PathToManifest -Force
#-------------------------------------------------------------------------

InModuleScope 'hyperv-dsc-lab' {
    Describe 'Get-LabConfiguration' -Tag Unit {
        BeforeAll {
            $WarningPreference     = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
        }
        Context 'Warning' {
            It 'should warn and return if the configuration file is not found' {
                Mock Test-Path -MockWith { $false }
                $Message = "DSC lab configuration file not found at C:\FakePath. Use Set-LabConfiguration to create one."
                Get-LabConfiguration -LabConfigurationFilePath 'C:\FakePath' -WarningVariable Warning
                $Warning | Should -Be $Message
            }
        }
    }
}
