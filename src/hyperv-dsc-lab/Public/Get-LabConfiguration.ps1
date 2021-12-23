<#
    .SYNOPSIS
    Short descripton

    .DESCRIPTION
    Long description

    .PARAMETER ParameterName
    Explain the parameter

    .EXAMPLE
    Example usage
    Output
    Explanation of what the example does

    .OUTPUTS
    Output (if any)

    .NOTES
    General notes

    .LINK
    Link to other documentation
#>
function Get-LabConfiguration {
    [CmdletBinding()]
    param ()
    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
    }

    process {
        [PSCustomObject]@{
            CertificateExportPath = "C:\virt\certs"
            VMHostVHDPath         = (Get-VMHost).VirtualHardDiskPath
            MofExportPath         = "C:\virt\mofs"
            SetupScriptPath       = "C:\code\hyperv-dsc-lab\src\hyperv-dsc-lab\Resources\Setup.ps1"
            BaseVHDPath           = "C:\virt\vhds\gold-imgs\test.vhdx"
        }
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END :: $(Get-Date)"
    }
}