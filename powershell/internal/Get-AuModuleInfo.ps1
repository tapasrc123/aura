function Get-AuModuleInfo {
<#
.SYNOPSIS
    Returns the module details from the psd1 file.
#>
    [CmdletBinding()]
    [OutputType([PSObject])]
    param()
    $AuModuleInfo = $MyInvocation.MyCommand.Module
    $AuModuleInfo | ConvertTo-Json -Depth 5 | Write-Debug
    return $AuModuleInfo
}
