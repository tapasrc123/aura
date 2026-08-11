function Test-AuCaAzureDevOps {
    <#
    .Synopsis
    Checks if any Conditional Access policy explicitly includes Azure DevOps

    .Description
    Azure DevOps will no longer rely on the Azure Resource Manager (ARM) resource during sign-in or token refresh flows.
    Organizations must update their Conditional Access policies to explicitly include Azure DevOps to maintain secure access.

    .Example
    Test-AuCaAzureDevOps

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCaAzureDevOps
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Allow')]
    param ()

    if (!(Test-AuConnection Graph)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedGraph
        return $null
    }
    if ((Get-AuLicenseInformation EntraID) -eq 'Free') {
        Add-AuTestResultDetail -SkippedBecause NotLicensedEntraIDP1
        return $null
    }

    Write-Verbose 'Checking for Conditional Access policies that explicitly include Azure DevOps...'

    $azureDevOpsAppId = '499b84ac-1321-427f-aa17-267ca6975798'

    try {
        $azureDevOpsServicePrincipal = Invoke-AuGraphRequest -RelativeUri 'servicePrincipals' -ApiVersion v1.0 -Filter "appId eq '$azureDevOpsAppId'" -Select id
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }

    if (-not $azureDevOpsServicePrincipal) {
        Add-AuTestResultDetail -SkippedBecause Custom -SkippedCustomReason "Azure DevOps app (App ID: $azureDevOpsAppId) is not available in this tenant."
        return $null
    }

    try {

        $policies = Get-AuConditionalAccessPolicy | Where-Object { $_.state -eq 'enabled' }
        $policiesResult = New-Object System.Collections.ArrayList
        $result = $false

        foreach ($policy in $policies) {
            if ($azureDevOpsAppId -in $policy.conditions.applications.includeApplications) {
                $result = $true
                $policiesResult.Add($policy) | Out-Null
            }
        }
        if (($policiesResult | Measure-Object).Count -ne 0) {
            $testResult = "Well done! There are Conditional Access policies that explicitly include Azure DevOps.`n`n%TestResult%"
            Add-AuTestResultDetail -Result $testResult -GraphObjects $policiesResult -GraphObjectType ConditionalAccess
        } else {
            $testResult = 'There are no Conditional Access policies that explicitly target Azure DevOps.'
            Add-AuTestResultDetail -Result $testResult
        }
        return $result
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}
