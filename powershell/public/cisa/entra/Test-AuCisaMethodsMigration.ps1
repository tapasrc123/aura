function Test-AuCisaMethodsMigration {
    <#
    .SYNOPSIS
    Checks if migration to Authentication Methods is complete

    .DESCRIPTION
    The Authentication Methods Manage Migration feature SHALL be set to Migration Complete.

    .EXAMPLE
    Test-AuCisaMethodsMigration

    Returns true if policyMigrationState is migrationComplete

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaMethodsMigration
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

    #4/28/2024 - Select OData query option not supported
    $result = Invoke-AuGraphRequest -RelativeUri "policies/authenticationmethodspolicy" -ApiVersion "v1.0"

    $migrationState = $result.policyMigrationState

    $testResult = $migrationState -eq "migrationComplete" -or $null -eq $migrationState # Can be 'null' in new tenants that never had legacy settings to migrate from.

    if ($testResult) {
        $testResultMarkdown = "Well done. Your tenant has completed the migration to Authentication Methods."
    } else {
        $testResultMarkdown = "Your tenant has not completed the migration to Authentication Methods."
    }
    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
