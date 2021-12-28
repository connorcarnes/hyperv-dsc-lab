@{
    RootModule        = 'hyperv-dsc-lab.psm1'
    ModuleVersion     = '0.0.1'
    GUID              = '4eab66bf-268a-4a5e-92d4-e2787cef0769'
    Author            = 'Connor Carnes'
    CompanyName       = 'Unknown'
    Copyright         = '(c) Connor Carnes. All rights reserved.'
    Description       = 'for creating dsc labs'
    PowerShellVersion = '5.1'
    RequiredModules = @(
        @{
            ModuleName    = 'PSDscResources'
            ModuleVersion = '2.12.0'
        },
        @{
            ModuleName    = 'platyPS'
            ModuleVersion = '0.14.2'
        },
        @{
            ModuleName    = 'InvokeBuild'
            ModuleVersion = '5.8.7'
        },
        @{
            ModuleName    = 'PSScriptAnalyzer'
            ModuleVersion = '1.20.0'
        },
        @{
            ModuleName    = 'Pester'
            ModuleVersion = '5.3.1'
        }
    )
    FunctionsToExport = @(
        'Export-DSCConfigurationData',
        'Get-DSCLabConfiguration',
        'Invoke-DscLab',
        'Invoke-HyperVHostDscConfig',
        'New-LabVmCertificate',
        'New-LabVmVhd',
        'Remove-DscLab',
        'Set-DSCLabConfiguration',
        'Update-Mof'
    )
    PrivateData = @{
        PSData = @{
            Tags = @('dsc','hyper-v','lab')
        }
    }
}


