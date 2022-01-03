# this psm1 is for local testing and development use only

# dot source the parent import for local development variables
. $PSScriptRoot\Imports.ps1

# discover all ps1 file(s) in Public and Private paths

$itemSplat = @{
    Filter      = '*.ps1'
    Recurse     = $true
    ErrorAction = 'Stop'
}
try {
    $public = @(Get-ChildItem -Path "$PSScriptRoot\Public" @itemSplat)
    $private = @(Get-ChildItem -Path "$PSScriptRoot\Private" @itemSplat)
}
catch {
    Write-Error $_
    throw "Unable to get get file information from Public & Private src."
}

# dot source all .ps1 file(s) found
foreach ($file in @($public + $private)) {
    try {
        . $file.FullName
    }
    catch {
        throw "Unable to dot source [$($file.FullName)]"

    }
}

$VarParams = @{
    Name        = 'REQ_CONFIG_PROPS'
    Description = 'Required configuration properties'
    Scope       = 'Script'
    Force       = $True
    Option      = 'readonly'
    Value       = @(
        "CertificatePath",
        "VHDPath",
        "MofPath",
        "SetupScriptPath",
        "BaseVHDPath",
        "VMConfigurationDataPath",
        "VMConfiguration",
        "HostConfiguration"
    )
}
Set-Variable @VarParams

$VarParams = @{
    Name        = 'LAB_CONFIG'
    Description = 'Required configuration properties'
    Scope       = 'Script'
    Force       = $True
    Option      = 'readonly'
    Value       = Get-LabConfiguration
}
Set-Variable @VarParams

# export all public functions
Export-ModuleMember -Function $public.Basename