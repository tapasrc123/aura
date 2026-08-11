function Test-AuAdPasswordComplexityRequired {
    <#
    .SYNOPSIS
    Checks whether password complexity is required in the default domain password policy.

    .DESCRIPTION
    This test retrieves the password complexity setting from the default domain password policy.
    Password complexity requires that passwords contain characters from three of the following
    categories: uppercase letters, lowercase letters, numbers, and special characters. This
    requirement helps prevent the use of common, easily guessable passwords.

    .EXAMPLE
    Test-AuAdPasswordComplexityRequired

    Returns $true if the password policy is accessible, $false otherwise.
    The test result includes whether complexity is enabled.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdPasswordComplexityRequired
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdPasswordComplexityRequired"

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
        $complexityEnabled = $passwordPolicy.ComplexityEnabled
    } catch {
        Write-Error "Failed to retrieve password policy: $($_.Exception.Message)"
        return $null
    }

    # Test passes if we successfully retrieved the password policy
    $testResult = $null -ne $complexityEnabled

    # Generate markdown results
    if ($testResult) {
        $complexityStatus = if ($complexityEnabled) { "Enabled" } else { "Disabled" }

        $result = "| Metric | Value |" + "`n"
        $result += "| --- | --- |" + "`n"
        $result += "| Password Complexity | $complexityStatus |" + "`n"
        $result += "| Recommended Setting | Enabled |" + "`n"

        $recommendation = if ($complexityEnabled) {
            "✅ Password complexity is enabled. This helps prevent the use of common, easily guessable passwords."
        } else {
            "⚠️ Password complexity is disabled. This allows users to create simple passwords that are vulnerable to brute-force and dictionary attacks. Enable complexity requirements."
        }

        $testResultMarkdown = "$recommendation`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    } else {
        $testResultMarkdown = "Unable to retrieve the default domain password policy. Ensure you have appropriate permissions and the Active Directory module is installed."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
