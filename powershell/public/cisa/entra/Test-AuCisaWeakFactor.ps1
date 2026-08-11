function Test-AuCisaWeakFactor {
    <#
    .SYNOPSIS
    Checks if weak Authentication Methods are disabled

    .DESCRIPTION
    The authentication methods SMS, Voice Call, and Email One-Time Passcode (OTP) SHALL be disabled.

    .EXAMPLE
    Test-AuCisaWeakFactor

    Returns true if weak Authentication Methods are disabled

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaWeakFactor
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if(!(Test-AuConnection Graph)){
        Add-AuTestResultDetail -SkippedBecause NotConnectedGraph
        return $null
    }

    $EntraIDPlan = Get-AuLicenseInformation -Product EntraID
    if($EntraIDPlan -eq "Free"){
        Add-AuTestResultDetail -SkippedBecause NotLicensedEntraIDP1
        return $null
    }

    $weakFactors = @(
        "Sms",
        "Voice",
        "Email"
    )

    $result = Get-AuAuthenticationMethodPolicyConfig

    $weakAuthMethods = $result | Where-Object { $_.id -in $weakFactors }

    $enabledWeakMethods = $weakAuthMethods | Where-Object { $_.state -eq "enabled" }

    $testResult = (($enabledWeakMethods|Measure-Object).Count -eq 0)

    if ($testResult) {
        $testResultMarkdown = "Well done. All weak authentication methods are disabled in your tenant.`n`n%TestResult%"
    } else {
        $testResultMarkdown = "One or more weak methods are enabled in your tenant, or migration to Authentication Methods is incomplete.`n`n%TestResult%"
    }

    # Auth method does not support deep links.
    $authMethodsLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/AuthenticationMethodsMenuBlade/~/AdminAuthMethods"

    $result = "| Authentication Method | State | Test Result |`n"
    $result += "| --- | --- | --- |`n"
    foreach ($item in $weakAuthMethods) {
        $methodResult = "✅ Pass"
        if ($item.state -eq "enabled") {
            $methodResult = "❌ Fail"
        }
        $result += "| [$($item.id)]($authMethodsLink) | $($item.state) | $($methodResult) |`n"
    }
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
