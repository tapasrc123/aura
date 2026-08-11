function Test-AuCisaBlockLegacyAuth {
    <#
    .SYNOPSIS
    Checks if Baseline Policies Legacy Authentication - MS.AAD.1.1v1 is set to 'blocked'

    .DESCRIPTION
    Legacy authentication SHALL be blocked.

    .EXAMPLE
    Test-AuCisaBlockLegacyAuth

    Returns true if one or more CA policies exist that block legacy authentication.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaBlockLegacyAuth
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

    $blockOther = $result | Where-Object {
        $_.grantControls.builtInControls -contains "block" -and
        $_.conditions.clientAppTypes -contains "other" -and
        $_.conditions.users.includeUsers -contains "All" -and
        $_.conditions.applications.includeApplications -contains "All"
    }

    $blockExchangeActiveSync = $result | Where-Object {
        $_.grantControls.builtInControls -contains "block" -and
        $_.conditions.clientAppTypes -contains "exchangeActiveSync" -and
        $_.conditions.users.includeUsers -contains "All" -and
        $_.conditions.applications.includeApplications -contains "All"
    }

    if (($blockOther | Measure-Object).Count -ge 1 -and ($blockExchangeActiveSync | Measure-Object).Count -ge 1) {
        $blockPolicies = @($blockOther) + @($blockExchangeActiveSync)  | Sort-Object id -Unique
    }

    $testResult = ($blockPolicies|Measure-Object).Count -ge 1

    if ($testResult) {
        $testResultMarkdown = "Your tenant has one or more policies that block legacy authentication:`n`n%TestResult%"
    } else {
        $testResultMarkdown = "Your tenant lacks sufficient Conditional Access policies that block legacy authentication for all cloud apps."
    }
    Add-AuTestResultDetail -Result $testResultMarkdown -GraphObjectType ConditionalAccess -GraphObjects $blockPolicies

    return $testResult
}
