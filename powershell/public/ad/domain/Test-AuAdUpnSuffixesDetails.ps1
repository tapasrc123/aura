function Test-AuAdUpnSuffixesDetails {
    <#
    .SYNOPSIS
    Retrieves detailed information about UPN (User Principal Name) suffixes configured in the forest.

    .DESCRIPTION
    This test retrieves detailed information about UPN suffixes configured in the Active Directory forest.
    UPN suffixes allow users to log on with a user principal name in the format user@suffix.
    Understanding the configured UPN suffixes helps assess the authentication landscape and
    identify potential misconfigurations or unused suffixes.

    .EXAMPLE
    Test-AuAdUpnSuffixesDetails

    Returns $true if UPN suffix data is accessible.
    The test result includes detailed information about configured UPN suffixes.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdUpnSuffixesDetails
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Clarity in using plural')]
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdUpnSuffixesDetails"

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
        $result += "| Forest Name | $($forest.Name) |" + "`n"
        $result += "| Root Domain | $($forest.RootDomain) |" + "`n"
        $result += "| UPN Suffix Count | $suffixCount |" + "`n"

        if ($suffixCount -gt 0) {
            $result += "`n### Configured UPN Suffixes" + "`n" + "`n"
            $result += "| # | UPN Suffix |" + "`n"
            $result += "| --- | --- |" + "`n"
            for ($i = 0; $i -lt $upnSuffixes.Count; $i++) {
                $result += "| $($i + 1) | $($upnSuffixes[$i]) |" + "`n"
            }
        } else {
            $result += "`n**Note:** No custom UPN suffixes are configured. Users will use the default forest domain as their UPN suffix." + "`n"
        }

        $testResultMarkdown = "The Active Directory forest UPN suffix details have been retrieved successfully.`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    } else {
        $testResultMarkdown = "Unable to retrieve Active Directory UPN suffix information. Ensure you have appropriate permissions and the Active Directory module is installed."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
