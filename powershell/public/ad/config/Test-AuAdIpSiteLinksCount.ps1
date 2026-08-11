function Test-AuAdIpSiteLinksCount {
    <#
    .SYNOPSIS
    Counts the number of IP site links in Active Directory.

    .DESCRIPTION
    This test retrieves the Active Directory site link configuration and counts IP site links.
    IP site links are identified by having a replication frequency value.

    .EXAMPLE
    Test-AuAdIpSiteLinksCount

    Returns $true if IP site link data is accessible.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdIpSiteLinksCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdIpSiteLinksCount"

    # Get AD domain state data (uses cached data if available)
    $adState = Get-AuADDomainState

    # If unable to retrieve AD data, skip the test
    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }

    $config = $adState.Configuration
    $siteLinks = if ($null -ne $config -and $null -ne $config.SiteLinks) { @($config.SiteLinks) } else { @() }
    $ipSiteLinks = $siteLinks | Where-Object { $_.ReplicationFrequencyInMinutes }
    $ipSiteLinksCount = ($ipSiteLinks | Measure-Object).Count

    # Test passes if we successfully retrieved configuration data
    $testResult = $null -ne $config -and $null -ne $config.SiteLinks

    # Generate markdown results
    if ($testResult) {
        $result = "| Metric | Value |" + "`n"
        $result += "| --- | --- |" + "`n"
        $result += "| IP Site Links Count | $ipSiteLinksCount |" + "`n"

        $testResultMarkdown = "Active Directory IP site links have been analyzed. Found $ipSiteLinksCount IP site link(s).`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    } else {
        $testResultMarkdown = "Unable to retrieve Active Directory site link information. Ensure you have appropriate permissions and the Active Directory module is installed."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
