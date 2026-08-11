function Test-AuAdForestDomainCount {
    <#
    .SYNOPSIS
    Counts the number of domains in the forest.

    .DESCRIPTION
    This test retrieves the count of domains in the Active Directory forest.
    Understanding your forest structure is essential for security planning,
    trust management, and administrative boundary definition.

    .EXAMPLE
    Test-AuAdForestDomainCount

    Returns $true if forest domain data is accessible.
    The test result includes the count of domains in the forest.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdForestDomainCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdForestDomainCount"

    # Get AD domain state data (uses cached data if available)
    $adState = Get-AuADDomainState

    # If unable to retrieve AD data, skip the test
    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }

    $forest = $adState.Forest
    $domains = $forest.Domains
    $domainCount = $domains.Count

    # Test passes if we successfully retrieved forest data
    $testResult = $domainCount -ge 1

    # Generate markdown results
    if ($testResult) {
        $result = "| Metric | Value |" + "`n"
        $result += "| --- | --- |" + "`n"
        $result += "| Total Domains | $domainCount |" + "`n"
        $result += "| Forest Name | $($forest.Name) |" + "`n"
        $result += "| Root Domain | $($forest.RootDomain) |" + "`n" + "`n"

        $result += "### Domain List" + "`n" + "`n"
        $result += "| Domain Name |" + "`n"
        $result += "| --- |" + "`n"
        foreach ($domain in ($domains | Sort-Object)) {
            $result += "| $domain |" + "`n"
        }

        $testResultMarkdown = "Active Directory forest domains have been counted. There are $domainCount domain(s) in the forest.`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    } else {
        $testResultMarkdown = "Unable to retrieve forest domain information. Ensure you have appropriate permissions and the Active Directory module is installed."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
