function Test-AuAdSubnetTotalCount {
    <#
    .SYNOPSIS
    Counts the total number of Active Directory subnets.

    .DESCRIPTION
    This test retrieves the total count of subnets configured in Active Directory.
    Subnets define the network boundaries for Active Directory sites and are used
    to determine which site a client belongs to for authentication and replication.

    .EXAMPLE
    Test-AuAdSubnetTotalCount

    Returns $true if subnet data is accessible.
    The test result includes the total count of subnets.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdSubnetTotalCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdSubnetTotalCount"

    # Get AD domain state data (uses cached data if available)
    $adState = Get-AuADDomainState

    # If unable to retrieve AD data, skip the test
    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }

    $subnets = $adState.Subnets
    $subnetCount = ($subnets | Measure-Object).Count

    # Test passes if we successfully retrieved subnet data
    $testResult = $subnetCount -ge 0

    # Generate markdown results
    if ($testResult) {
        $result = "| Metric | Value |" + "`n"
        $result += "| --- | --- |" + "`n"
        $result += "| Total Subnets | $subnetCount |" + "`n"

        $testResultMarkdown = "Active Directory subnets have been analyzed. There are $subnetCount subnet(s) configured in the domain.`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    } else {
        $testResultMarkdown = "Unable to retrieve Active Directory subnet information. Ensure you have appropriate permissions and the Active Directory module is installed."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
