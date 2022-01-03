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
    Describe 'Get-DSCLabConfiguration' -Tag Unit {
        BeforeAll {
            # Import UnitTestData.ps1
            # . ([System.IO.Path]::Combine('..', "UnitTestData.ps1"))
            $WarningPreference     = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
        } #beforeAll
        Context 'Warning' {

            It 'should warn and return if the configuration file is not found' {
                Mock Test-Path -MockWith { $false }
                $Message = "DSC lab configuration file not found at C:\FakePath. Use Set-LabConfiguration to create one."
                Get-LabConfiguration -LabConfigurationFilePath 'C:\FakePath' -WarningVariable Warning
                $Warning | Should -Be $Message
            }
        }
        # Need to revist this. It should loop through required config props and check if they are set, but
        # -ErrorVariable seems to not be working for some reason.
        #Context 'Error' {
        #    It 'errors if <_> is not set' -ForEach $REQ_CONFIG_PROPS {
        #        $TempJson    = $VALID_CONFIG_JSON | ConvertFrom-Json
        #        $TempJson.$_ = ''
        #        $TempJson    = $TempJson | ConvertTo-Json
        #        Mock Get-Content -MockWith { $TempJson }
        #        Mock Test-Path -MockWith { $true }
        #        Get-LabConfiguration-ErrorVariable Err
        #        $DebugPreference = 'inquire'
        #        write-debug 'test'
        #        $debugpreference = 'silentlycontinue'
        #        $Err | Should -Be "Required DSC Lab Configuration property $_ is not set."
        #    }
        # }
    } #describe_Get-DSCLabConfiguration
} #inModule
