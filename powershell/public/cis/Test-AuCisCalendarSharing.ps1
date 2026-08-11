function Test-AuCisCalendarSharing {
    <#
    .SYNOPSIS
    Checks state of sharing policies

    .DESCRIPTION
    Calendar details SHALL NOT be shared with all domains.
    CIS Microsoft 365 Foundations Benchmark v6.0.1

    .EXAMPLE
    Test-AuCisCalendarSharing

    Returns true if no sharing policies allow uncontrolled calendar sharing.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisCalendarSharing
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (!(Test-AuConnection ExchangeOnline)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedExchange
        return $null
    }

    try {
        Write-Verbose 'Get Calendar sharing policy'
        $policies = Get-AuExo -Request SharingPolicy

        Write-Verbose 'Get Calendars where sharing policy is enabled and allows anonymous sharing'
        $resultPolicies = $policies | Where-Object {
            $_.Enabled -and ($_.Domains -like "`*:*CalendarSharing*" -or $_.Domains -like 'Anonymous:*CalendarSharing*')
        }

        $testResult = ($resultPolicies | Measure-Object).Count -eq 0
        if ($testResult) {
            $testResultMarkdown = "Well done. Your tenant does not allow uncontrolled calendar sharing.`n`n%TestResult%"
        } else {
            $testResultMarkdown = "Your tenant allows uncontrolled calendar sharing.`n`n%TestResult%"
        }

        $result = "| Policy Name | Test Result |`n"
        $result += "| --- | --- |`n"
        foreach ($item in $policies | Sort-Object -Property Name) {
            $portalLink = "https://admin.exchange.microsoft.com/#/individualsharing/:/individualsharingdetails/$($item.ExchangeObjectId)/managedomain"
            $itemResult = '✅ Pass'
            if ($item.ExchangeObjectId -in $resultPolicies.ExchangeObjectId) {
                $itemResult = '❌ Fail'
            }
            $result += "| [$($item.Name)]($portalLink) | $($itemResult) |`n"
        }
        $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $result

        Add-AuTestResultDetail -Result $testResultMarkdown
        return $testResult
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}
