function Test-AuAdIntermediateCaCount {
    <#
    .SYNOPSIS
    Counts the intermediate certificate authorities configured in Active Directory.

    .DESCRIPTION
    This test retrieves the count of intermediate CAs from the AIA (Authority Information Access)
    container in Active Directory. Intermediate CAs are subordinate to root CAs in the PKI hierarchy.

    .EXAMPLE
    Test-AuAdIntermediateCaCount

    Returns $true if intermediate CA data is accessible, $false otherwise.
    The test result includes the count of intermediate CAs.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdIntermediateCaCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdIntermediateCaCount"

    # Get AD domain state data (uses cached data if available)
    $adState = Get-AuADDomainState

    # If unable to retrieve AD data, skip the test
    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }

    $config = $adState.Configuration
    $intermediateCAs = $config.IntermediateCAs
    $caCount = ($intermediateCAs | Measure-Object).Count

    # Test passes if we successfully retrieved the data
    $testResult = $null -ne $intermediateCAs

    # Generate markdown results
    if ($testResult) {
        $result = "| Metric | Value |" + "`n"
        $result += "| --- | --- |" + "`n"
        $result += "| Intermediate CAs | $caCount |" + "`n"

        $testResultMarkdown = "Active Directory intermediate CAs have been analyzed. $caCount intermediate CA(s) found.`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    } else {
        $testResultMarkdown = "Unable to retrieve intermediate CA information from Active Directory. Ensure you have appropriate permissions."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
