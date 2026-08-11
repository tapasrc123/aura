function Test-AuAdOptionalFeaturesCount {
    <#
    .SYNOPSIS
    Counts the number of Active Directory optional features.

    .DESCRIPTION
    This test retrieves all optional features available in Active Directory and returns the total count.
    Optional features are used to represent forest and domain capabilities such as the Recycle Bin feature.

    .EXAMPLE
    Test-AuAdOptionalFeaturesCount

    Returns $true if optional feature data is accessible.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdOptionalFeaturesCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdOptionalFeaturesCount"

    # Get AD domain state data (uses cached data if available)
    $adState = Get-AuADDomainState

    # If unable to retrieve AD data, skip the test
    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }

    $optionalFeatures = if ($null -ne $adState.OptionalFeatures) { @($adState.OptionalFeatures) } else { @() }
    $optionalFeaturesCount = ($optionalFeatures | Measure-Object).Count

    # Test passes if we successfully retrieved optional feature data
    $testResult = $null -ne $adState.OptionalFeatures

    # Generate markdown results
    if ($testResult) {
        $result = "| Metric | Value |" + "`n"
        $result += "| --- | --- |" + "`n"
        $result += "| Optional Features Count | $optionalFeaturesCount |" + "`n"

        $testResultMarkdown = "Active Directory optional features have been analyzed. Found $optionalFeaturesCount optional feature(s).`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    } else {
        $testResultMarkdown = "Unable to retrieve Active Directory optional features. Ensure you have appropriate permissions and the Active Directory module is installed."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
