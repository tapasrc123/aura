function Test-AuCisaMfa {
    <#
    .SYNOPSIS
    Checks if a Conditional Access policy requiring MFA is enabled

    .DESCRIPTION
    If phishing-resistant MFA has not been enforced, an alternative MFA method SHALL be enforced for all users

    .EXAMPLE
    Test-AuCisaMfa

    Returns true if at least one policy requires MFA

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaMfa
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
    }elseif(Test-AuCisaPhishResistant){
        Add-AuTestResultDetail -SkippedBecause Custom -SkippedCustomReason "Test-AuCisaPhishResistant Passed"
        return $null
    }

    $result = Get-AuConditionalAccessPolicy | Where-Object { $_.state -eq "enabled" }

    $policies = $result | Where-Object {`
        $_.conditions.applications.includeApplications -contains "All" -and `
        $_.conditions.users.includeUsers -contains "All" -and `
            ($_.grantControls.builtInControls -contains "mfa" -or `
            $_.grantControls.authenticationStrength.requirementsSatisfied -contains "mfa" ) }

    $testResult = ($policies|Measure-Object).Count -ge 1

    if ($testResult) {
        $testResultMarkdown = "Well done. Your tenant has one or more policies that require MFA:`n`n%TestResult%"
    } else {
        $testResultMarkdown = "Your tenant does not have any Conditional Access policies that require MFA."
    }
    Add-AuTestResultDetail -Result $testResultMarkdown -GraphObjectType ConditionalAccess -GraphObjects $policies

    return $testResult
}
