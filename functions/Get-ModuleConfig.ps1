function Get-ModuleConfig {
  <#
      .SYNOPSIS
      Function summary.

      .DESCRIPTION
      In depth description of function.

      .PARAMETER Param
      Description of Parameter.

      .EXAMPLE
      Example usage

      Explanation of example

      .OUTPUTS
      [void]

      .NOTES
      General notes

      .LINK
      google.com
  #>
  [CmdletBinding()]
  param (
      [Parameter(HelpMessage = "Param help")]
      [string]$ModuleConfigPath = "C:\code\hyperv-dsc-lab\resources\ModuleConfig.json"
  )

  begin {
      Write-Verbose "$($MyInvocation.MyCommand.Name) :: BEGIN :: $(Get-Date)"
  }

  process {
      $Script:ModuleConfig = Get-Content $ModuleConfigPath | ConvertFrom-Json
  }

  end {
      Write-Verbose "$($MyInvocation.MyCommand.Name) :: END   :: $(Get-Date)"
  }
}