function Test-AuCisaMailboxAuditing {
    <#
    .SYNOPSIS
    Checks state of mailbox auditing

    .DESCRIPTION
    Mailbox auditing SHALL be enabled.

    .EXAMPLE
    Test-AuCisaMailboxAuditing

    Returns true if mailbox auditing is enabled.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaMailboxAuditing
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if(!(Test-AuConnection ExchangeOnline)){
        Add-AuTestResultDetail -SkippedBecause NotConnectedExchange
        return $null
    }

    $config = Get-AuExo -Request OrganizationConfig

    $testResult = (-not $config.AuditDisabled)

    if ($testResult) {
        $testResultMarkdown = "Well done. Your tenant has mailbox auditing enabled.`n`n%TestResult%"
        $result = "✅ Pass"
    } else {
        $testResultMarkdown = "Your tenant does not have mailbox auditing enabled.`n`n%TestResult%"
        $result = "❌ Fail"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
