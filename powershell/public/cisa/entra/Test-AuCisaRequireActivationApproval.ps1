function Test-AuCisaRequireActivationApproval {
    <#
    .SYNOPSIS
    Checks for approval requirement on activation of Global Admin role

    .DESCRIPTION
    Activation of the Global Administrator role SHALL require approval.

    .EXAMPLE
    Test-AuCisaRequireActivationApproval

    Returns true if the Global Administrator role requires approval on activation

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaRequireActivationApproval
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (!(Test-AuConnection Graph)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedGraph
        return $null
    }

    $EntraIDPlan = Get-AuLicenseInformation -Product EntraID
    $pim = $EntraIDPlan -eq "P2" -or $EntraIDPlan -eq "Governance"
    if (-not $pim) {
        Add-AuTestResultDetail -SkippedBecause NotLicensedEntraIDP2OrGovernance
        return $null
    }

    $globalAdministratorsRole = Get-AuRole | Where-Object {`
            $_.id -eq "62e90394-69f5-4237-9190-012177145e10" }

    $policySplat = @{
        ApiVersion      = "v1.0"
        RelativeUri     = "policies/roleManagementPolicyAssignments"
        Filter          = "scopeId eq '/' and scopeType eq 'DirectoryRole' and roleDefinitionId eq '$($globalAdministratorsRole.id)'"
        QueryParameters = @{
            expand = "policy(expand=rules)"
        }
    }
    $policy = Invoke-AuGraphRequest @policySplat

    $testResult = ($policy.policy.rules | Where-Object {`
                $_.'@odata.type' -eq "#microsoft.graph.unifiedRoleManagementPolicyApprovalRule"
        }).setting.isApprovalRequired -eq $true

    if ($testResult) {
        $testResultMarkdown = "Well done. Your tenant requires approval for the activation of the Global Administrator role."
    } else {
        $testResultMarkdown = "Your tenant does not require approval for the activation of the Global Administrator role"
    }
    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
