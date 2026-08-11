function Test-AuCisaAttachmentFilter {
    <#
    .SYNOPSIS
    Checks state of preset security policies

    .DESCRIPTION
    Emails SHALL be filtered by attachment file types
    Emails SHALL be scanned for malware.

    .EXAMPLE
    Test-AuCisaAttachmentFilter

    Returns true if standard and strict protection is on

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaAttachmentFilter
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (!(Test-AuConnection ExchangeOnline)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedExchange
        return $null
    }

    $policies = Get-AuExoThreatPolicyMalware

    $failingPolicies = $policies | Where-Object { $_.IsEnabled -and -not $_.EnableFileFilter }
    $testResult = ($failingPolicies | Measure-Object).Count -eq 0

    $portalLink = "https://security.microsoft.com/antimalwarev2"
    $passResult = "✅ Pass"
    $failResult = "❌ Fail"
    $skipResult = "🗄️ Skip"

    $result = "| Policy name | Enabled | EnableFileFilter | Extensions | Result |`n"
    $result += "| --- | --- | --- | --- | --- |`n"
    foreach ($item in $policies) {
        if ($item.FileTypes) {
            $resultFilesList = ($item.FileTypes | Select-Object -First 5) -join ", "
            $resultFilesList += ", & $(($item.FileTypes|Measure-Object).Count -5) others"
        } else {
            $resultFilesList = ""
        }
        if (-not $item.IsEnabled) {
            $result += "| $($item.Identity) | $false | $($item.EnableFileFilter) | $resultFilesList | $($skipResult) |`n"
        } elseif ($item.EnableFileFilter) {
            $result += "| $($item.Identity) | $true | $($item.EnableFileFilter) | $resultFilesList | $($passResult) |`n"
        } else {
            $result += "| $($item.Identity) | $true | $($item.EnableFileFilter) | $resultFilesList | $($failResult) |`n"
        }
    }

    if ($testResult) {
        $testResultMarkdown = "Well done. All the anti-malware policies in your tenant has the common attachments filter enabled ($portalLink).`n`n%TestResult%"
    } else {
        $testResultMarkdown = "Your tenant does not have all the anti-malware policies with the common attachments filter enabled ($portalLink).`n`n%TestResult%"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
