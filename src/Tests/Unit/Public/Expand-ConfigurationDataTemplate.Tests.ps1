Set-Location -Path $PSScriptRoot
# If the module is already in memory, remove it
$ModuleName = 'hyperv-dsc-lab'
$PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
if (Get-Module -Name $ModuleName -ErrorAction 'SilentlyContinue') {
    Remove-Module -Name $ModuleName -Force
}
Import-Module $PathToManifest -Force
# Load mock objects in UnitTestData.ps1
. ([System.IO.Path]::Combine('..',  'UnitTestData.ps1'))

InModuleScope 'hyperv-dsc-lab' {
    Describe 'Expand-ConfigurationDataTemplate' -Tag Unit {
        BeforeAll {
            $WarningPreference     = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
            Mock Test-LabConfiguration -MockWith {$true}
        }
        Context 'Error' {
            It 'should error if .psd1 fails to load' {
                Mock Set-Variable -MockWith {''}
                Mock Get-Content -MockWith {''}
                Mock Set-Content -MockWith {''}
                Mock Import-PowerShellDataFile -MockWith { throw 'Mock Error' }
                $Splat = @{
                    ConfigurationDataTemplate = "C:\MockPath"
                    OutputPath                = "C:\MockPath"
                    ErrorAction               = "Stop"
                }
                { Expand-ConfigurationDataTemplate @Splat } | Should -Throw
            }
        }
    }
}
