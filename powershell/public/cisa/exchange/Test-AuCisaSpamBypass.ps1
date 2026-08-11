function Test-AuCisaSpamBypass {
    <#
    .SYNOPSIS
    Checks state of spam filter

    .DESCRIPTION
    Allowed domains SHALL NOT be added to inbound anti-spam protection policies.

    .EXAMPLE
    Test-AuCisaSpamBypass

    Returns true if spam filter enabled

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaSpamBypass
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

    $policies = Get-AuExo -Request HostedContentFilterPolicy

    $resultPolicies = $policies | Where-Object { `
        $_.AllowedSenderDomains
    }

    $standard = $policies | Where-Object { `
        $_.RecommendedPolicyType -eq "Standard"
    }

    $strict = $policies | Where-Object { `
        $_.RecommendedPolicyType -eq "Strict"
    }

    $testResult = $standard -and $strict -and (($resultPolicies|Measure-Object).Count -eq 0)

    $portalLink = "https://security.microsoft.com/presetSecurityPolicies"
    $passResult = "✅ Pass"
    $failResult = "❌ Fail"

    if ($testResult) {
        $testResultMarkdown = "Well done. Your tenant has [standard and strict preset security policies]($portalLink).`n`n%TestResult%"
    } else {
        $testResultMarkdown = "Your tenant does not have [standard and strict preset security policies]($portalLink).`n`n%TestResult%"
    }

    $result = "| Policy | Status |`n"
    $result += "| --- | --- |`n"
    if ($standard) {
        $result += "| Standard | $passResult |`n"
    } else {
        $result += "| Standard | $failResult |`n"
    }
    if ($strict) {
        $result += "| Strict | $passResult |`n`n"
    } else {
        $result += "| Strict | $failResult |`n`n"
    }

    $result += "| Policy Name | Policy Result | Allowed Domains |`n"
    $result += "| --- | --- | --- |`n"
    foreach($item in $policies | Sort-Object -Property Identity){
        if($item.Guid -notin $resultPolicies.Guid){
            $result += "| $($item.Identity) | $passResult | $($item.AllowedSenderDomains) |`n"
        }else{
            $result += "| $($item.Identity) | $failResult | $($item.AllowedSenderDomains) |`n"
        }
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
