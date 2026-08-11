function Test-AuAdCrlDistributionPointsCount {
    <#
    .SYNOPSIS
    Counts the CRL distribution points configured in Active Directory.

    .DESCRIPTION
    This test retrieves the count of CRL (Certificate Revocation List) distribution points
    configured in the Active Directory Public Key Services container. CRL distribution points
    are essential for publishing certificate revocation information.

    .EXAMPLE
    Test-AuAdCrlDistributionPointsCount

    Returns $true if CRL distribution point data is accessible, $false otherwise.
    The test result includes the count of CRL distribution points.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdCrlDistributionPointsCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdCrlDistributionPointsCount"

    # Get AD domain state data (uses cached data if available)
    $adState = Get-AuADDomainState

    # If unable to retrieve AD data, skip the test
    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }

    $config = $adState.Configuration
    $cdpObjects = $config.CrlDistributionPoints
    $cdpCount = ($cdpObjects | Measure-Object).Count

    # Test passes if we successfully retrieved the data
    $testResult = $null -ne $cdpObjects

    # Generate markdown results
    if ($testResult) {
        $result = "| Metric | Value |" + "`n"
        $result += "| --- | --- |" + "`n"
        $result += "| CRL Distribution Points | $cdpCount |" + "`n"

        $testResultMarkdown = "Active Directory CRL distribution points have been analyzed. $cdpCount CRL distribution point(s) found.`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    } else {
        $testResultMarkdown = "Unable to retrieve CRL distribution point information from Active Directory. Ensure you have appropriate permissions."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
