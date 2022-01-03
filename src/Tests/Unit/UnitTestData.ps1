$Script:MOCK_CONFIG_OBJ = [PSCustomObject]@{
    Other                   = @{KeyOne='ValueOne'; KeyTwo='ValueTwo'}
    BaseVHDPath             = 'C:\Path\BaseVHD.vhdx'
    CertificatePath         = 'C:\Path'
    VMConfiguration         = 'C:\Path\Configuration.ps1'
    MofPath                 = 'C:\Path'
    VHDPath                 = 'C:\Path'
    SetupScriptPath         = 'C:\Path\Setup.ps1'
    VMConfigurationDataPath = 'C:\Path\ConfigData.psd1'
    HostConfiguration       = 'C:\Path\Configuration.ps1'
}

$Script:VALID_CONFIG_JSON = @"
{
    "Other": {
      "KeyTwo": "ValueTwo",
      "KeyOne": "ValueOne"
    },
    "BaseVHDPath": "C:\\Path\\BaseVHD.vhdx",
    "CertificatePath": "C:\\Path",
    "VMConfiguration": "C:\\Path\\Configuration.ps1",
    "MofPath": "C:\\Path",
    "VHDPath": "C:\\Path",
    "SetupScriptPath": "C:\\Path\\Setup.ps1",
    "VMConfigurationDataPath": "C:\\Path\\ConfigData.psd1",
    "HostConfiguration": "C:\\Path\\Configuration.ps1"
}
"@

$Script:INVALID_CONFIG_JSON = @"
{
    "Other": {
      "KeyTwo": "ValueTwo",
      "KeyOne": "ValueOne"
    },
    "BaseVHDPath": "C:\\Path\\BaseVHD.vhdx",
    "CertificatePath": "C:\\Path",
    "VMConfiguration": "C:\\Path\\Configuration.ps1",
    "MofPath": "C:\\Path",
    "VHDPath": "",
    "SetupScriptPath": "C:\\Path\\Setup.ps1",
    "VMConfigurationDataPath": "C:\\Path\\ConfigData.psd1",
    "HostConfiguration": "C:\\Path\\Configuration.ps1"
}
"@