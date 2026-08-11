function Test-AuAdOptionalFeatureCount {
    <#
    .SYNOPSIS
    Retrieves the count of Active Directory optional features.

    .DESCRIPTION
    Active Directory optional features provide additional functionality beyond the
    base Active Directory capabilities. Common optional features include:
    - Recycle Bin: Allows restoration of deleted objects
    - Privileged Access Management (PAM): Time-based group membership
    - Other forest or domain-specific features

    Understanding which optional features are available helps assess the
    capabilities and security posture of the Active Directory environment.

    .EXAMPLE
    Test-AuAdOptionalFeatureCount

    Returns $true if optional feature data is accessible.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdOptionalFeatureCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdOptionalFeatureCount"

    $adState = Get-AuADDomainState

    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }

    $optionalFeatures = $adState.OptionalFeatures
    $featureCount = ($optionalFeatures | Measure-Object).Count

    $testResult = $true

    $result = "| Property | Value |" + "`n"
    $result += "| --- | --- |" + "`n"
    $result += "| Total Optional Features | $featureCount |" + "`n"

    if ($featureCount -gt 0) {
        $result += "| Available Features | $(($optionalFeatures | ForEach-Object { $_.Name }) -join ', ') |" + "`n"
    }

    $testResultMarkdown = "Active Directory optional features have been enumerated. These features extend AD capabilities beyond base functionality.`n`n%TestResult%"
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
