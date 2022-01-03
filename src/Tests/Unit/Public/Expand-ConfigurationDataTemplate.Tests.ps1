Set-Location -Path $PSScriptRoot
$ModuleName = 'hyperv-dsc-lab'
$PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
# If the module is already in memory, remove it
if (Get-Module -Name $ModuleName -ErrorAction 'SilentlyContinue') {
    Remove-Module -Name $ModuleName -Force
}
Import-Module $PathToManifest -Force

InModuleScope 'hyperv-dsc-lab' {
    Describe 'Expand-ConfigurationDataTemplate' -Tag Unit {
        BeforeAll {
            $WarningPreference     = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
        }
}
