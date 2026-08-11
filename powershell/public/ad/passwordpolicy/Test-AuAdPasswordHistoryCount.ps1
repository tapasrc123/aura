function Test-AuAdPasswordHistoryCount {
    <#
    .SYNOPSIS
    Checks the password history count configured in the default domain password policy.

    .DESCRIPTION
    This test retrieves the password history count from the default domain password policy.
    Password history determines how many previous passwords are remembered to prevent users
    from reusing recent passwords. This is a critical security control for maintaining
    password hygiene.

    .EXAMPLE
    Test-AuAdPasswordHistoryCount

    Returns $true if the password policy is accessible, $false otherwise.
    The test result includes the configured password history count.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdPasswordHistoryCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdPasswordHistoryCount"

    # Get AD domain state data (uses cached data if available)
    $adState = Get-AuADDomainState

    # If unable to retrieve AD data, skip the test
    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }

    # Get the default domain password policy
    try {
        $passwordPolicy = Get-ADDefaultDomainPasswordPolicy -ErrorAction Stop
        $passwordHistoryCount = $passwordPolicy.PasswordHistoryCount
    } catch {
        Write-Error "Failed to retrieve password policy: $($_.Exception.Message)"
        return $null
    }

    # Test passes if we successfully retrieved the password policy
    $testResult = $null -ne $passwordHistoryCount

    # Generate markdown results
    if ($testResult) {
        $result = "| Metric | Value |" + "`n"
        $result += "| --- | --- |" + "`n"
        $result += "| Password History Count | $passwordHistoryCount |" + "`n"
        $result += "| Recommended Minimum | 24 |" + "`n"

        $recommendation = if ($passwordHistoryCount -ge 24) {
            "✅ Password history count meets or exceeds the recommended minimum of 24."
        } else {
            "⚠️ Password history count is below the recommended minimum of 24. Consider increasing this value to prevent password reuse."
        }

        $testResultMarkdown = "$recommendation`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    } else {
        $testResultMarkdown = "Unable to retrieve the default domain password policy. Ensure you have appropriate permissions and the Active Directory module is installed."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
