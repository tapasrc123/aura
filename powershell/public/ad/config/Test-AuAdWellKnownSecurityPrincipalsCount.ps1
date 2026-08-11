function Test-AuAdWellKnownSecurityPrincipalsCount {
    <#
    .SYNOPSIS
    Counts the number of well-known security principal objects in Active Directory.

    .DESCRIPTION
    This test retrieves the Active Directory configuration data for the collection of
    well-known security principals (default expected count: 27) and reports how many
    objects are present.

    .EXAMPLE
    Test-AuAdWellKnownSecurityPrincipalsCount

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdWellKnownSecurityPrincipalsCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdWellKnownSecurityPrincipalsCount"

    # Get AD domain state data (uses cached data if available)
    $adState = Get-AuADDomainState

    # If unable to retrieve AD data, skip the test
    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }

    $config = $adState.Configuration

    $expectedCount = 27
    $wellKnownPrincipals = $config.WellKnownSecurityPrincipals
    $wellKnownPrincipalsCount = @($wellKnownPrincipals).Count
    $hasData = $null -ne $config.WellKnownSecurityPrincipals

    # Return $true if configuration data was retrieved successfully.
    # Compliance with the default expected count is reported in the markdown output.
    $testResult = $hasData
    $meetsExpectedCount = $wellKnownPrincipalsCount -eq $expectedCount

    # Generate markdown results
    if ($hasData) {
        $result = "| Metric | Value |" + "`n"
        $result += "| --- | --- |" + "`n"
        $result += "| WellKnownSecurityPrincipals Count | $wellKnownPrincipalsCount |" + "`n"
        $result += "| Expected Count | $expectedCount |" + "`n"
        $result += "| Matches Expected Count | $meetsExpectedCount |`n\n"

        $testResultMarkdown = "Active Directory well-known security principals have been counted. $wellKnownPrincipalsCount well-known security principal(s) were found (expected: $expectedCount).`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    } else {
        $testResultMarkdown = "Unable to retrieve Active Directory configuration data for WellKnownSecurityPrincipals. Ensure you have appropriate permissions and the Active Directory module is installed."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
