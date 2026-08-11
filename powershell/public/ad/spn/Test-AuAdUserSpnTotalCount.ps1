function Test-AuAdUserSpnTotalCount {
    <#
    .SYNOPSIS
    Counts the total number of SPNs configured on user accounts.

    .DESCRIPTION
    This test retrieves all Service Principal Names (SPNs) configured on user objects.
    User accounts with SPNs are particularly sensitive as they can be targets for
    Kerberoasting attacks. This test provides visibility into the scope of user SPNs
    in the environment.

    .EXAMPLE
    Test-AuAdUserSpnTotalCount

    Returns $true if SPN data is accessible, $false otherwise.
    The test result includes the total count of user SPNs.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdUserSpnTotalCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdUserSpnTotalCount"

    # Get AD domain state data (uses cached data if available)
    $adState = Get-AuADDomainState

    # If unable to retrieve AD data, skip the test
    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }

    $users = $adState.Users

    # Extract all SPNs from user objects
    $allSpns = $users | Where-Object { $null -ne $_.servicePrincipalName } | ForEach-Object { $_.servicePrincipalName } | ForEach-Object { $_ }

    $totalSpnCount = ($allSpns | Measure-Object).Count
    $usersWithSpns = ($users | Where-Object { $null -ne $_.servicePrincipalName } | Measure-Object).Count
    $totalUsers = ($users | Measure-Object).Count

    # Test passes if we successfully retrieved SPN data
    $testResult = $true

    # Generate markdown results
    if ($testResult) {
        $result = "| Metric | Value |" + "`n"
        $result += "| --- | --- |" + "`n"
        $result += "| Total User SPNs | $totalSpnCount |" + "`n"
        $result += "| Users with SPNs | $usersWithSpns |" + "`n"
        $result += "| Total Users | $totalUsers |" + "`n"

        if ($totalUsers -gt 0) {
            $percentage = [Math]::Round(($usersWithSpns / $totalUsers) * 100, 2)
            $result += "| Users with SPNs Percentage | $percentage% |" + "`n"
        }

        $testResultMarkdown = "Active Directory user SPN analysis found $totalSpnCount SPNs across $usersWithSpns user accounts.`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    } else {
        $testResultMarkdown = "Unable to retrieve Active Directory user SPN data. Ensure you have appropriate permissions and the Active Directory module is installed."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
