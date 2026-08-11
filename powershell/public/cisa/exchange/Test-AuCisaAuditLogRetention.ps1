function Test-AuCisaAuditLogRetention {
    <#
    .SYNOPSIS
    Checks state of purview

    .DESCRIPTION
    Audit logs SHALL be maintained for at least the minimum duration dictated by OMB M-21-31 (Appendix C).

    .EXAMPLE
    Test-AuCisaAuditLogRetention

    Returns true if audit log retention enabled

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaAuditLogRetention
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
    }elseif($null -eq (Get-AuLicenseInformation -Product AdvAudit)){
        Add-AuTestResultDetail -SkippedBecause NotLicensedAdvAudit
        return $null
    }

    $policies = Get-UnifiedAuditLogRetentionPolicy

    $resultPolicies = $policies | Where-Object { `
        $_.Enabled -and `
        $_.RecordTypes -contains "ExchangeAdmin" -and `
        $_.RecordTypes -contains "ExchangeItem" -and `
        $_.RecordTypes -contains "ExchangeItemGroup" -and `
        $_.RecordTypes -contains "ExchangeAggregatedOperation" -and `
        $_.RecordTypes -contains "ExchangeItemAggregated" -and `
        ($_.RetentionDuration -eq "TwelveMonths" -or `
        $_.RetentionDuration -like "*Years")
    }

    $testResult = ($resultPolicies|Measure-Object).Count -ge 1

    $portalLink = "https://purview.microsoft.com/audit/auditpolicies"

    if ($testResult) {
        $testResultMarkdown = "Well done. Your tenant has [Exchange Online audit retention enabled]($portalLink)."
    } else {
        $testResultMarkdown = "Your tenant does not have [Exchange Online audit retention enabled]($portalLink)."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
