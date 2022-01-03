Set-Location -Path $PSScriptRoot
# If the module is already in memory, remove it
$ModuleName = 'hyperv-dsc-lab'
$PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
if (Get-Module -Name $ModuleName -ErrorAction 'SilentlyContinue') {
    Remove-Module -Name $ModuleName -Force
}
Import-Module $PathToManifest -Force

InModuleScope 'hyperv-dsc-lab' {
    Describe 'Test-LabConfiguration' -Tag Unit {
        BeforeAll {
            $WarningPreference        = 'SilentlyContinue'
            $ErrorActionPreference    = 'SilentlyContinue'
            $ModuleBase               = (Get-Module -Name 'hyperv-dsc-lab').ModuleBase
            $LabConfigurationFilePath = "$ModuleBase\LabConfiguration.json"
        }
        BeforeEach {
            # Load mock objects in UnitTestData.ps1 before each test in loop below
            #$ModuleBase = (Get-Module 'hyperv-dsc-lab').ModuleBase
            # $ModuleBase.Replace('\src\hyperv-dsc-lab','\src\Tests\Unit\UnitTestData.ps1')
            # . "$ModuleBase\src\Tests\Unit\UnitTestData.ps1"
            . ([System.IO.Path]::Combine('..',  'UnitTestData.ps1'))
        }
        Context 'Error' {
            It 'Errors if <_> is not set' -ForEach $REQ_CONFIG_PROPS {
                $LAB_CONFIG      = $MOCK_CONFIG_OBJ
                $LAB_CONFIG.$_   = ''
                $ExpectedMessage = "The following required lab configuration properties are not set: $_"
                { Test-LabConfiguration -ErrorAction 'Stop' } |
                    Should -Throw -ExpectedMessage $ExpectedMessage
            }
            It 'Errors if config file does not exist' {
                Mock Test-Path -MockWith {$false}
                $ExpectedMessage = "$LabConfigurationFilePath does not exist. Run Set-LabConfiguration and try again."
                { Test-LabConfiguration } |
                    Should -Throw -ExpectedMessage $ExpectedMessage
            }
            It 'Errors if $LAB_CONFIG script variable is not set' {
                Mock Test-Path -MockWith {$true}
                $LAB_CONFIG      = $null
                $ExpectedMessage = "`$LAB_CONFIG script variable is not present. Run Set-LabConfiguration, ensure $LabConfigurationFilePath exists and try again."
                { Test-LabConfiguration } |
                    Should -Throw -ExpectedMessage $ExpectedMessage
            }
        }
    }
}
