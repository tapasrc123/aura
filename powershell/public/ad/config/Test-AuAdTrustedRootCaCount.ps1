function Test-AuAdTrustedRootCaCount {
    <#
    .SYNOPSIS
    Counts the trusted root certificate authorities configured in Active Directory.

    .DESCRIPTION
    This test retrieves the count of trusted root CAs from the Certification Authorities
    container in Active Directory. Root CAs are the trust anchors for the PKI infrastructure.

    .EXAMPLE
    Test-AuAdTrustedRootCaCount

    Returns $true if trusted root CA data is accessible, $false otherwise.
    The test result includes the count of trusted root CAs.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdTrustedRootCaCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdTrustedRootCaCount"

    # Get AD domain state data (uses cached data if available)
    $adState = Get-AuADDomainState

    # If unable to retrieve AD data, skip the test
    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }

    $config = $adState.Configuration
    $rootCAs = $config.TrustedRootCAs
    $caCount = ($rootCAs | Measure-Object).Count

    # Test passes if we successfully retrieved the data
    $testResult = $null -ne $rootCAs

    # Generate markdown results
    if ($testResult) {
        $result = "| Metric | Value |" + "`n"
        $result += "| --- | --- |" + "`n"
        $result += "| Trusted Root CAs | $caCount |" + "`n"

        $testResultMarkdown = "Active Directory trusted root CAs have been analyzed. $caCount trusted root CA(s) found.`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    } else {
        $testResultMarkdown = "Unable to retrieve trusted root CA information from Active Directory. Ensure you have appropriate permissions."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
