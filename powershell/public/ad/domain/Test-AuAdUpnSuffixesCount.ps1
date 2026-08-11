function Test-AuAdUpnSuffixesCount {
    <#
    .SYNOPSIS
    Retrieves the count of UPN (User Principal Name) suffixes configured in the forest.

    .DESCRIPTION
    This test retrieves the count of UPN suffixes configured in the Active Directory forest.
    UPN suffixes allow users to log on with a user principal name in the format user@suffix.
    Multiple UPN suffixes are often used in organizations with multiple domains or brands,
    or during mergers and acquisitions.

    .EXAMPLE
    Test-AuAdUpnSuffixesCount

    Returns $true if UPN suffix data is accessible.
    The test result includes the count of configured UPN suffixes.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdUpnSuffixesCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdUpnSuffixesCount"

    # Get AD domain state data (uses cached data if available)
    $adState = Get-AuADDomainState

    # If unable to retrieve AD data, skip the test
    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }

    $forest = $adState.Forest
    $upnSuffixes = $forest.UPNSuffixes
    $suffixCount = ($upnSuffixes | Measure-Object).Count

    # Test passes if we successfully retrieved forest data
    $testResult = $null -ne $upnSuffixes

    # Generate markdown results
    if ($testResult) {
        $result = "| Property | Value |" + "`n"
        $result += "| --- | --- |" + "`n"
        $result += "| UPN Suffix Count | $suffixCount |" + "`n"
        $result += "| Forest Name | $($forest.Name) |" + "`n"

        if ($suffixCount -gt 0) {
            $result += "| UPN Suffixes | $($upnSuffixes -join ', ') |" + "`n"
        } else {
            $result += "| UPN Suffixes | (none configured - using default forest domain) |" + "`n"
        }

        $testResultMarkdown = "The Active Directory forest UPN suffixes have been analyzed successfully.`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    } else {
        $testResultMarkdown = "Unable to retrieve Active Directory UPN suffix information. Ensure you have appropriate permissions and the Active Directory module is installed."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
