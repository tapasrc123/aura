function Test-AuAdSmtpSiteLinksCount {
    <#
    .SYNOPSIS
    Counts the number of SMTP site links in Active Directory.

    .DESCRIPTION
    This test retrieves the Active Directory site link configuration and counts SMTP site links.
    SMTP site links are identified by having a non-zero cost and lacking a replication frequency
    value.

    .EXAMPLE
    Test-AuAdSmtpSiteLinksCount

    Returns $true if SMTP site link data is accessible.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdSmtpSiteLinksCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdSmtpSiteLinksCount"

    # Get AD domain state data (uses cached data if available)
    $adState = Get-AuADDomainState

    # If unable to retrieve AD data, skip the test
    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }

    $config = $adState.Configuration
    $siteLinks = if ($null -ne $config -and $null -ne $config.SiteLinks) { @($config.SiteLinks) } else { @() }
    $smtpSiteLinks = $siteLinks | Where-Object { $_.cost -and -not $_.ReplicationFrequencyInMinutes }
    $smtpSiteLinksCount = ($smtpSiteLinks | Measure-Object).Count

    # Test passes if we successfully retrieved configuration data
    $testResult = $null -ne $config -and $null -ne $config.SiteLinks

    # Generate markdown results
    if ($testResult) {
        $result = "| Metric | Value |" + "`n"
        $result += "| --- | --- |" + "`n"
        $result += "| SMTP Site Links Count | $smtpSiteLinksCount |" + "`n"

        $testResultMarkdown = "Active Directory SMTP site links have been analyzed. Found $smtpSiteLinksCount SMTP site link(s).`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    } else {
        $testResultMarkdown = "Unable to retrieve Active Directory site link information. Ensure you have appropriate permissions and the Active Directory module is installed."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
