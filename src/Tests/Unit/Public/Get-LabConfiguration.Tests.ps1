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
            $WarningPreference        = 'SilentlyContinue'
            $ErrorActionPreference    = 'SilentlyContinue'
            $ModuleBase               = (Get-Module -Name 'hyperv-dsc-lab').ModuleBase
            $LabConfigurationFilePath = "$ModuleBase\LabConfiguration.json"
        }
        Context 'Warning' {
            It 'should warn and return if the configuration file is not found' {
                Mock Test-Path -MockWith { $false }
                $Message = "Lab configuration file not found at $LabConfigurationFilePath. Use Set-LabConfiguration to create one."
                Get-LabConfiguration -WarningVariable Warning
                $Warning | Should -Be $Message
            }
        }
    }
}
