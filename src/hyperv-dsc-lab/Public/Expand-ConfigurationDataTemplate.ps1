<#
    .SYNOPSIS
    Helps with creating .psd1 files to be used as DSC ConfigurationData.

    .DESCRIPTION
    Takes a template with unexpanded strings and uses values from Get-LabConfigurationto expand them and create a valid .psd1 file.

    This function relies on the $ExecutionContext.InvokeCommand.ExpandString method. Therefore, variables in the template file must be properly escaped.

    See \Resources\vms\VMConfigurationDataTemplate.ps1 for an example template file.

    .EXAMPLE
    $Splat = @{
        ConfigurationDataTemplate = ".\src\hyperv-dsc-lab\Resources\vms\VMConfigurationDataTemplate.ps1"
        OutputPath                = ".\src\hyperv-dsc-lab\Resources\vms\VMConfigurationData.psd1"
    }
    Expand-ConfigurationDataTemplate @Splat

    Creates a .psd1 file that can be used as DSC ConfigurationData.

    .OUTPUTS
    [void]

    .NOTES
    General notes

    .LINK
    https://stackoverflow.com/questions/1667023/expanding-variables-in-file-contents

    .LINK
    https://stackoverflow.com/questions/42536935/how-to-expand-file-content-with-powershell

    .LINK
    https://docs.microsoft.com/en-us/powershell/dsc/configurations/separatingenvdata?view=dsc-1.1
#>
function Expand-ConfigurationDataTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            HelpMessage = "Path to the template file to use for the configuration data.")]
        [string]$ConfigurationDataTemplate,

        [Parameter(Mandatory,
            HelpMessage = "Path where .psd1 will be saved. Existing file content will be overwritten.")]
        [string]$OutputPath
    )

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
        Test-LabConfiguration -ErrorAction 'Stop'
    }

    process {
        $LAB_CONFIG = Get-DSCLabConfiguration

        Write-Verbose "Setting mandatory property variables."
        $REQ_CONFIG_PROPS.ForEach{
            Write-Verbose "Setting variable $_ to $($LAB_CONFIG.$_)"
            Set-Variable -Name $_ -Value $LAB_CONFIG.$_
        }

        if ($LAB_CONFIG.Other) {
            Write-Verbose "Setting other property variables."
            $OtherProperties = ($LAB_CONFIG.Other |
                Get-Member |
                Where-Object {$_.MemberType -eq 'NoteProperty'}
            ).Name
            $OtherProperties.ForEach{
                Write-Verbose "Setting variable $_ to $($LAB_CONFIG.Other.$_)"
                Set-Variable -Name $_ -Value $LAB_CONFIG.Other.$_
            }
        }

        Write-Verbose "Loading template file contents."
        $TemplateContent  = Get-Content -Path $ConfigurationDataTemplate -Raw

        Write-Verbose "Expanding template file contents."
        $ExpandedTemplate = $ExecutionContext.InvokeCommand.ExpandString($TemplateContent)

        Write-Verbose "Setting content of $OutputPath."
        Set-Content -Path $OutputPath -Value $ExpandedTemplate

        try {
            [void](Import-PowerShellDataFile -Path $OutputPath -ErrorAction 'Stop')
        }
        catch {
            Write-Error "Command 'Import-PowerShellDataFile -Path $($OutputPath)' failed. This indicates the exported .psd1 file is invalid. Error message was: '$($_.Exception.Message)'"
        }

    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END   :: $(Get-Date)"
    }
}