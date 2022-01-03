<#
    .SYNOPSIS
    Loads and compiles a DSC Configuration within a Windows PowerShell session.

    .DESCRIPTION
    Loads and compiles a DSC Configuration within a Windows PowerShell session.

    .PARAMETER ConfigurationFile
    Path to DSC configuration file.

    .PARAMETER OutputPath
    Path where MOF files will be saved.

    .PARAMETER ConfigurationSplat
    Parameter splat to pass to DSC configuration. Use if you need to pass parameters to the configuration. Must be in the form of a hashtable.

    .EXAMPLE
    $Splat = @{
        ConfigurationFile  = 'C:\DSC\Configs\MyConfig.ps1'
        OutputPath         = 'C:\DSC\MOFs\'
        ConfigurationSplat = @{SomeParameter = 'SomeValue'}
    }
    Initialize-DSCConfiguration @Splat

    Loads and compiles the configuration MyConfig.ps1 in a Windows PowerShell session. Resulting MOF(s) are saved to C:\DSC\MOFs\.
    MyConfig.ps1 requires a value for the parameter 'SomeParameter', so the ConfigurationSplat parameter of this function is used
    to pass the value.

    .OUTPUTS
    [void]

    .NOTES
    General notes

    .LINK
    https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.language.configurationdefinitionast?view=powershellsdk-7.0.0

    .LINK
    https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.language.parameterast?view=powershellsdk-7.0.0
#>
function Initialize-DSCConfiguration {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,HelpMessage = "Path to file containing DSC configuration definition")]
        [string]$ConfigurationFile,

        [Parameter(Mandatory,HelpMessage = "Path where MOF files will be saved")]
        [string]$OutputPath,

        [Parameter(HelpMessage = "Parameter splat to pass to DSC configuration. Use if you need to pass parameters to the configuration.")]
        [hashtable]$ConfigurationSplat
    )

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
    }

    process {
        write-debug 'test'
        $Config = Get-DSCLabConfiguration

        # Use AST to get the configuration name. Alternatively you could trim the file name but it's not
        # guaranteed that the file name will be the same as the configuration name.
        $Ast = [ScriptBlock]::Create((Get-Content -Path $ConfigurationFile -Raw))
        $ConfigurationName = $Ast.Ast.FindAll({
            $args[0] -is [Management.Automation.Language.ConfigurationDefinitionAst]
          }, $false).InstanceName.Value

        if ($ConfigurationName.Count -eq 1) {
            Write-Verbose "Found exactly one configuration in $ConfigurationFile. Name of configuration: $ConfigurationName"
        }
        elseif ($ConfigurationName.Count -eq 0) {
            throw "ConfigurationFile does not contain any DSC configuration definitions. Review file and try again: $ConfigurationFile"
        }
        else {
            throw "Found more than one configuration definition in ConfigurationFile. One configuration per file is expected. Review file and try again: $ConfigurationFile"
        }

        # Use AST to get params.
        $ParamAst = $Ast.Ast.FindAll({
            $args[0] -is [Management.Automation.Language.ParameterAst]
          }, $true)

        $Splat = @{OutputPath=$OutputPath}
        if ($ConfigurationSplat) {
            $Splat += $ConfigurationSplat
        }

        try {
            $Session = New-PSSession -UseWindowsPowerShell -ErrorAction 'Stop'
            [void](Invoke-Command -ErrorAction 'Stop' -Session $Session -ScriptBlock {
                . $Using:ConfigurationFile
                . $Using:ConfigurationName @Using:Splat
            })
            $Session | Remove-PSSession -ErrorAction 'Stop'
        }
        catch {
            throw $_
        }
    }

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name) :: END   :: $(Get-Date)"
    }
}