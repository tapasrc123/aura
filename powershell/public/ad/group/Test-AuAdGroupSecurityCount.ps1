function Test-AuAdGroupSecurityCount {
    <#
    .SYNOPSIS
    Counts the number of security groups in Active Directory.

    .DESCRIPTION
    This test counts security groups in Active Directory, which are used for access control
    and permissions management. Security groups can be assigned permissions to resources
    and contain both users and computers. Understanding the number and distribution of
    security groups is essential for assessing the security posture and access management
    complexity of your Active Directory environment.

    .EXAMPLE
    Test-AuAdGroupSecurityCount

    Returns $true if group data is accessible, $false otherwise.
    The test result includes counts of security groups.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdGroupSecurityCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdGroupSecurityCount"

    # Get AD domain state data (uses cached data if available)
    $adState = Get-AuADDomainState

    # If unable to retrieve AD data, skip the test
    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }

    $groups = $adState.Groups

    # Count security groups (GroupCategory = "Security")
    $securityGroups = $groups | Where-Object { $_.GroupCategory -eq "Security" }
    $securityCount = ($securityGroups | Measure-Object).Count
    $totalCount = ($groups | Measure-Object).Count

    # Test passes if we successfully retrieved group data
    $testResult = $totalCount -gt 0

    # Generate markdown results
    if ($testResult) {
        $percentage = if ($totalCount -gt 0) {
            [Math]::Round(($securityCount / $totalCount) * 100, 2)
        } else {
            0
        }

        $result = "| Metric | Value |" + "`n"
        $result += "| --- | --- |" + "`n"
        $result += "| Total Groups | $totalCount |" + "`n"
        $result += "| Security Groups | $securityCount |" + "`n"
        $result += "| Security Percentage | $percentage% |" + "`n" + "`n"

        $testResultMarkdown = "Active Directory group objects have been analyzed. $securityCount out of $totalCount groups ($percentage%) are security groups (used for access control).`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    } else {
        $testResultMarkdown = "Unable to retrieve Active Directory group objects. Ensure you have appropriate permissions and the Active Directory module is installed."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
