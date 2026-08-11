function Test-AuCisaPermanentRoleAssignment {
    <#
    .SYNOPSIS
    Checks for permanent active role assignments

    .DESCRIPTION
    Permanent active role assignments SHALL NOT be allowed for highly privileged roles.

    .EXAMPLE
    Test-AuCisaPermanentRoleAssignment

    Returns true if no roles have permanent active assignments

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaPermanentRoleAssignment
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

    $roles = Get-AuRole -CisaHighlyPrivilegedRoles
    $roleAssignments = @()

    foreach ($role in $roles) {
        $principal = $null
        $roleAssignment = [PSCustomObject]@{
            role      = $role.displayName
            principal = $principal
        }
        $assignmentsSplat = @{
            ApiVersion      = "v1.0"
            RelativeUri     = "roleManagement/directory/roleAssignmentSchedules"
            Filter          = "roleDefinitionId eq '$($role.id)' and assignmentType eq 'Assigned'"
            QueryParameters = @{
                expand = "principal"
            }
        }
        $assignments = Invoke-AuGraphRequest @assignmentsSplat | Where-Object {`
                $_.scheduleInfo.expiration.type -eq "noExpiration" }

        $roleAssignment.principal = $assignments.principal

        $roleAssignments += $roleAssignment
    }

    $testResult = ($roleAssignments.principal | Measure-Object).Count -eq 0

    if ($testResult) {
        $testResultMarkdown = "Well done. Your tenant has no active assignments without expiration to privileged roles."
    } else {
        $testResultMarkdown = "Your tenant has active assignments without expiration to privileged roles.`n`n%TestResult%"
    }

    if (-not $testResult) {
        $result = "| Role | Principal Type | Display Name | Status |`n"
        $result += "| --- | --- | --- | --- |`n"
        foreach ($roleAssignment in ($roleAssignments | Where-Object { $_.principal })) {
            foreach ($principal in $roleAssignment.principal) {
                $result += "| $($roleAssignment.role) | $($principal.'@odata.type'.Split('.')[-1]) | $($principal.displayName ) | ❌ No Expiration |`n"
            }
        }
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
