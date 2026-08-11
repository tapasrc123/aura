function Test-AuAdPasswordMaxAge {
    <#
    .SYNOPSIS
    Checks the maximum password age configured in the default domain password policy.

    .DESCRIPTION
    This test retrieves the maximum password age from the default domain password policy.
    Maximum password age determines how long users can keep the same password before being
    required to change it. Regular password changes help limit the window of opportunity
    for attackers who have obtained password hashes.

    .EXAMPLE
    Test-AuAdPasswordMaxAge

    Returns $true if the password policy is accessible, $false otherwise.
    The test result includes the configured maximum password age in days.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdPasswordMaxAge
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdPasswordMaxAge"

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
        $maxPasswordAge = $passwordPolicy.MaxPasswordAge
    } catch {
        Write-Error "Failed to retrieve password policy: $($_.Exception.Message)"
        return $null
    }

    # Test passes if we successfully retrieved the password policy
    $testResult = $null -ne $maxPasswordAge

    # Generate markdown results
    if ($testResult) {
        $maxPasswordAgeDays = $maxPasswordAge.Days

        $result = "| Metric | Value |" + "`n"
        $result += "| --- | --- |" + "`n"
        $result += "| Maximum Password Age | $maxPasswordAgeDays days |" + "`n"
        $result += "| Recommended Maximum | 90 days or less |" + "`n"

        $recommendation = if ($maxPasswordAgeDays -gt 0 -and $maxPasswordAgeDays -le 90) {
            "✅ Maximum password age meets the recommendation of 90 days or less."
        } elseif ($maxPasswordAgeDays -eq 0) {
            "⚠️ Passwords never expire. This is not recommended as it allows compromised credentials to remain valid indefinitely."
        } else {
            "⚠️ Maximum password age exceeds 90 days. Consider reducing this to limit the window of opportunity for attackers."
        }

        $testResultMarkdown = "$recommendation`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    } else {
        $testResultMarkdown = "Unable to retrieve the default domain password policy. Ensure you have appropriate permissions and the Active Directory module is installed."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
