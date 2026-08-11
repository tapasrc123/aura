function Get-AuMarkdownSummaryReport {
    <#
    .Synopsis
    Generates a compact markdown summary report with only result counters.

    .Description
    This markdown report is intended for quick sharing in pull requests, tickets,
    and workflow summaries where only the top-level result counts are needed.
    #>
    [CmdletBinding()]
    param(
        # The Aura test results returned from Invoke-Aura -PassThru
        [Parameter(Mandatory = $true, Position = 0)]
        [psobject] $AuraResults
    )

    $tenantDisplay = if (![string]::IsNullOrEmpty($AuraResults.TenantName)) {
        "$($AuraResults.TenantName) ($($AuraResults.TenantId))"
    } else {
        "Tenant ID: $($AuraResults.TenantId)"
    }

    $executedAt = $AuraResults.ExecutedAt

    $lines = @(
        '# Aura Test Results Summary'
        ''
        "**Tenant:** $tenantDisplay"
        "**Date:** $executedAt"
        ''
        '| Metric | Count |'
        '| - | -: |'
        "| Passed ✅ | $($AuraResults.PassedCount) |"
        "| Failed ❌ | $($AuraResults.FailedCount) |"
        "| Investigate 🕵️ | $($AuraResults.InvestigateCount) |"
        "| Skipped ⏭️ | $($AuraResults.SkippedCount) |"
        "| Error ⚠️ | $($AuraResults.ErrorCount) |"
        "| Not Run 🛑 | $($AuraResults.NotRunCount) |"
        "| Total 📊 | $($AuraResults.TotalCount) |"
    )

    return ($lines -join "`n")
}
