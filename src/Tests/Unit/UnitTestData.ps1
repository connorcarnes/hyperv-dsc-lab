$TEST_CONFIG = [PSCustomObject]@{
    Other                   = @{KeyOne='ValueOne'; KeyTwo='ValueTwo'}
    BaseVHDPath             = 'C:\Path\BaseVHD.vhdx'
    CertificatePath         = 'C:\Path'
    VMConfiguration         = 'C:\Path\Configuration.ps1'
    MofPath                 = 'C:\Path'
    LabVHDPath              = 'C:\Path'
    SetupScriptPath         = 'C:\Path\Setup.ps1'
    VMConfigurationDataPath = 'C:\Path\ConfigData.psd1'
    HostConfiguration       = 'C:\Path\Configuration.ps1'
}

$VALID_CONFIG_JSON = @"
{
    "Other": {
      "KeyTwo": "ValueTwo",
      "KeyOne": "ValueOne"
    },
    "BaseVHDPath": "C:\\Path\\BaseVHD.vhdx",
    "CertificatePath": "C:\\Path",
    "VMConfiguration": "C:\\Path\\Configuration.ps1",
    "MofPath": "C:\\Path",
    "LabVHDPath": "C:\\Path",
    "SetupScriptPath": "C:\\Path\\Setup.ps1",
    "VMConfigurationDataPath": "C:\\Path\\ConfigData.psd1",
    "HostConfiguration": "C:\\Path\\Configuration.ps1"
}
"@

$INVALID_CONFIG_JSON = @"
{
    "Other": {
      "KeyTwo": "ValueTwo",
      "KeyOne": "ValueOne"
    },
    "BaseVHDPath": "C:\\Path\\BaseVHD.vhdx",
    "CertificatePath": "C:\\Path",
    "VMConfiguration": "C:\\Path\\Configuration.ps1",
    "MofPath": "C:\\Path",
    "LabVHDPath": "",
    "SetupScriptPath": "C:\\Path\\Setup.ps1",
    "VMConfigurationDataPath": "C:\\Path\\ConfigData.psd1",
    "HostConfiguration": "C:\\Path\\Configuration.ps1"
}
"@