function Test-AuCisaBlockHighRiskUser {
    <#
    .SYNOPSIS
    Checks if User Risk Based Policies - MS.AAD.2.1 is set to 'blocked'

    .DESCRIPTION
    Users detected as high risk SHALL be blocked.

    .EXAMPLE
    Test-AuCisaBlockHighRiskUser

    Returns true if at least one policy is set to block high risk users.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaBlockHighRiskUser
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if(!(Test-AuConnection Graph)){
        Add-AuTestResultDetail -SkippedBecause NotConnectedGraph
        return $null
    }

    $EntraIDPlan = Get-AuLicenseInformation -Product EntraID
    if($EntraIDPlan -ne "P2"){
        Add-AuTestResultDetail -SkippedBecause NotLicensedEntraIDP2
        return $null
    }

    $result = Get-AuConditionalAccessPolicy | Where-Object { $_.state -eq "enabled" }

    $blockPolicies = $result | Where-Object {`
        $_.grantControls.builtInControls -contains "block" -and `
        $_.conditions.applications.includeApplications -contains "all" -and `
        $_.conditions.userRiskLevels -contains "high" -and `
        $_.conditions.users.includeUsers -contains "All" }

    $testResult = ($blockPolicies|Measure-Object).Count -ge 1

    if ($testResult) {
        $testResultMarkdown = "Well done. Your tenant has one or more policies that block high risk users :`n`n%TestResult%"
    } else {
        $testResultMarkdown = "Your tenant does not have any Conditional Access policies that block high risk users."
    }
    Add-AuTestResultDetail -Result $testResultMarkdown -GraphObjectType ConditionalAccess -GraphObjects $blockPolicies

    return $testResult
}
