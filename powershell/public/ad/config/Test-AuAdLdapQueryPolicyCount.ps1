function Test-AuAdLdapQueryPolicyCount {
    <#
    .SYNOPSIS
    Counts Active Directory LDAP query policies.

    .DESCRIPTION
    Phase 14 (AD Configuration tests) - AD-CFG-06.
    This test retrieves $config.LdapQueryPolicies and returns the count of configured LDAP query policies.

    .EXAMPLE
    Test-AuAdLdapQueryPolicyCount

    Returns $true if configuration data is accessible.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdLdapQueryPolicyCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdLdapQueryPolicyCount"

    $adState = Get-AuADDomainState

    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }

    $config = $adState.Configuration
    $ldapQueryPolicies = if ($null -ne $config) { $config.LdapQueryPolicies } else { $null }
    $ldapQueryPoliciesSafe = if ($null -ne $ldapQueryPolicies) { @($ldapQueryPolicies) } else { @() }

    $ldapQueryPolicyCount = ($ldapQueryPoliciesSafe | Measure-Object).Count
    $testResult = $null -ne $config

    if ($testResult) {
        $result = "| Property | Value |" + "`n"
        $result += "| --- | --- |" + "`n"
        $result += "| LDAP Query Policies Count | $ldapQueryPolicyCount |" + "`n" + "`n"

        $testResultMarkdown = "Active Directory LDAP query policies have been counted.`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    }
    else {
        $testResultMarkdown = "Unable to retrieve Active Directory configuration. Ensure you have appropriate permissions and the Active Directory module is installed."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown
    return $testResult
}
