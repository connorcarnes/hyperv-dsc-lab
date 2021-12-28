<#
    .SYNOPSIS
"https://www.google.com/search?as_q=words&as_epq=exact&as_oq=any&as_eq=none&as_nlo=startrange&as_nhi=endrange&lr=&cr=&as_qdr=d&as_sitesearch=domain&as_occt=any&safe=images&as_filetype=&tbs=" -split '&'

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
function Export-DSCConfigurationData {
    [CmdletBinding()]
    param ()

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
    }

    process {
        $LabConfiguration = Get-DSCLabConfiguration

        if ($LabConfiguration.Other) {
            $OtherProperties = ($LabConfiguration.Other |
                Get-Member |
                Where-Object {$_.MemberType -eq 'NoteProperty'}
            ).Name
            $OtherProperties.ForEach{
                Write-Verbose "Setting variable $_ to $($LabConfiguration.Other.$_)"
                Set-Variable -Name $_ -Value $LabConfiguration.Other.$_
            }
        }

        $REQ_DSC_LAB_CONFIG_PROPS.ForEach{
            Write-Verbose "Setting variable $_ to $($LabConfiguration.$_)"
            Set-Variable -Name $_ -Value $LabConfiguration.$_
        }

        Remove-Item $LabConfiguration.VMConfigurationDataPath -Force -ErrorAction 'SilentlyContinue'
        $ExecutionContext.InvokeCommand.ExpandString((Get-Content "C:\code\hyperv-dsc-lab\src\hyperv-dsc-lab\Resources\vms\VMConfigurationData.ps1" -Raw)) |
            Set-Content $LabConfiguration.VMConfigurationDataPath -Force
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END :: $(Get-Date)"
    }
}