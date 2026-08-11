function Test-AuCisaAuditLog {
    <#
    .SYNOPSIS
    Checks state of purview

    .DESCRIPTION
    Microsoft Purview Audit (Standard) logging SHALL be enabled.

    .EXAMPLE
    Test-AuCisaAuditLog

    Returns true if audit log enabled

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaAuditLog
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if(!(Test-AuConnection ExchangeOnline)){
        Add-AuTestResultDetail -SkippedBecause NotConnectedExchange
        return $null
    }elseif(!(Test-AuConnection SecurityCompliance)){
        Add-AuTestResultDetail -SkippedBecause NotConnectedSecurityCompliance
        return $null
    }

    $config = Get-AdminAuditLogConfig

    $testResult = $config.UnifiedAuditLogIngestionEnabled

    $portalLink = "https://purview.microsoft.com/audit/auditsearch"

    if ($testResult) {
        $testResultMarkdown = "Well done. Your tenant has [unified audit log enabled]($portalLink)."
    } else {
        $testResultMarkdown = "Your tenant does not have [unified audit log enabled]($portalLink)."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
