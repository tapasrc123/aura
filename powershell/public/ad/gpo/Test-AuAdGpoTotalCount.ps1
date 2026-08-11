function Test-AuAdGpoTotalCount {
    <#
    .SYNOPSIS
    Counts the total number of Group Policy Objects in Active Directory.

    .DESCRIPTION
    This test retrieves the total count of Group Policy Objects (GPOs) in the Active Directory domain.
    Knowing the total number of GPOs helps administrators understand the scope of policy management
    and identify potential areas for consolidation or cleanup.

    .EXAMPLE
    Test-AuAdGpoTotalCount

    Returns $true if GPO data is accessible, $false otherwise.
    The test result includes the total count of GPOs.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdGpoTotalCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdGpoTotalCount"

    # Get AD GPO state data (uses cached data if available)
    $gpoState = Get-AuADGpoState

    # If unable to retrieve GPO data, skip the test
    if ($null -eq $gpoState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }

    $gpos = $gpoState.GPOs

    # Count total GPOs
    $totalCount = ($gpos | Measure-Object).Count

    # Test passes only if we successfully retrieved the GPO dataset
    $testResult = $null -ne $gpos

    # Generate markdown results
    if ($testResult) {
        $result = "| Metric | Value |" + "`n"
        $result += "| --- | --- |" + "`n"
        $result += "| Total GPOs | $totalCount |" + "`n"

        $testResultMarkdown = "Active Directory Group Policy Objects have been analyzed. The domain contains $totalCount GPO(s).`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    } else {
        $testResultMarkdown = "Unable to retrieve Active Directory Group Policy Objects. Ensure you have appropriate permissions and the Group Policy Management Console is installed."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
