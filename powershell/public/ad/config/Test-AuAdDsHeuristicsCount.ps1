function Test-AuAdDsHeuristicsCount {
    <#
    .SYNOPSIS
    Counts Active Directory dSHeuristics configuration settings.

    .DESCRIPTION
    Phase 14 (AD Configuration tests) - AD-CFG-02.
    This test retrieves $config.DsHeuristics and calculates the count as (string length / 2).
    If dSHeuristics is null, the count is 0.

    .EXAMPLE
    Test-AuAdDsHeuristicsCount

    Returns $true if configuration data is accessible.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdDsHeuristicsCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdDsHeuristicsCount"

    $adState = Get-AuADDomainState

    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }

    $config = $adState.Configuration
    $dsHeuristics = if ($null -ne $config) { $config.DsHeuristics } else { $null }

    $dsHeuristicsCount = if ($null -ne $dsHeuristics) { [int]($dsHeuristics.Length / 2) } else { 0 }
    $testResult = $null -ne $config

    if ($testResult) {
        $result = "| Property | Value |" + "`n"
        $result += "| --- | --- |" + "`n"
        $result += "| dSHeuristics | $dsHeuristics |" + "`n"
        $result += "| dSHeuristics Count (length/2) | $dsHeuristicsCount |" + "`n" + "`n"

        $testResultMarkdown = "Active Directory dSHeuristics configuration has been analyzed.`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    }
    else {
        $testResultMarkdown = "Unable to retrieve Active Directory configuration. Ensure you have appropriate permissions and the Active Directory module is installed."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown
    return $testResult
}
