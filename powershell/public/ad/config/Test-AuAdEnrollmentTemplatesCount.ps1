function Test-AuAdEnrollmentTemplatesCount {
    <#
    .SYNOPSIS
    Counts the number of certificate templates available for enrollment.

    .DESCRIPTION
    This test retrieves the Active Directory configuration data for enrollment templates
    and reports how many templates are available for enrollment.

    .EXAMPLE
    Test-AuAdEnrollmentTemplatesCount

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdEnrollmentTemplatesCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdEnrollmentTemplatesCount"

    # Get AD domain state data (uses cached data if available)
    $adState = Get-AuADDomainState

    # If unable to retrieve AD data, skip the test
    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }

    $config = $adState.Configuration
    $enrollmentTemplates = $config.EnrollmentTemplates
    $enrollmentTemplatesCount = @($enrollmentTemplates).Count
    $hasData = $null -ne $config.EnrollmentTemplates

    # Test passes when configuration data is available
    $testResult = $hasData -and ($enrollmentTemplatesCount -ge 0)

    # Generate markdown results
    if ($hasData) {
        $result = "| Metric | Value |" + "`n"
        $result += "| --- | --- |" + "`n"
        $result += "| Enrollment Templates Count | $enrollmentTemplatesCount |" + "`n"
        $testResultMarkdown = "Active Directory enrollment templates have been counted. $enrollmentTemplatesCount enrollment template(s) were found.`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    } else {
        $testResultMarkdown = "Unable to retrieve Active Directory configuration data for EnrollmentTemplates. Ensure you have appropriate permissions and the Active Directory module is installed."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
