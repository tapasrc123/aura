function Test-AuCisaPhishResistant {
    <#
    .SYNOPSIS
    Checks if a Conditional Access policy using Phishing-Resistant Authentication Strengths is enabled

    .DESCRIPTION
    Phishing-resistant MFA SHALL be enforced for all users

    .EXAMPLE
    Test-AuCisaPhishResistant

    Returns true if at least one policy is set to use the built-in phishing resistant authentication strengths

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaPhishResistant
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

    $result = Get-AuConditionalAccessPolicy | Where-Object { $_.state -eq "enabled" }

    $policies = $result | Where-Object {`
        $_.conditions.applications.includeApplications -contains "All" -and `
        $_.conditions.users.includeUsers -contains "All" -and `
        $_.grantControls.authenticationStrength.displayName -eq "Phishing-resistant MFA" }

    $testResult = ($policies|Measure-Object).Count -ge 1

    if ($testResult) {
        $testResultMarkdown = "Well done. Your tenant has one or more policies that require Phishing Resistant Authentication Strengths :`n`n%TestResult%"
    } else {
        $testResultMarkdown = "Your tenant does not have any Conditional Access policies that require Phishing Resistant Authentication Strengths."
    }
    Add-AuTestResultDetail -Result $testResultMarkdown -GraphObjectType ConditionalAccess -GraphObjects $policies

    return $testResult
}
