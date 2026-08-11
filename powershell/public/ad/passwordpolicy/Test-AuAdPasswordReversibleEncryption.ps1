function Test-AuAdPasswordReversibleEncryption {
    <#
    .SYNOPSIS
    Checks whether reversible encryption is enabled for passwords in the default domain password policy.

    .DESCRIPTION
    This test retrieves the reversible encryption setting from the default domain password policy.
    Reversible encryption stores passwords in a format that can be decrypted, which is a significant
    security risk. This setting should never be enabled except for very specific legacy application
    requirements, and even then, alternative solutions should be explored.

    .EXAMPLE
    Test-AuAdPasswordReversibleEncryption

    Returns $true if the password policy is accessible, $false otherwise.
    The test result includes whether reversible encryption is enabled.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdPasswordReversibleEncryption
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdPasswordReversibleEncryption"

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
        $reversibleEncryption = $passwordPolicy.ReversibleEncryptionEnabled
    } catch {
        Write-Error "Failed to retrieve password policy: $($_.Exception.Message)"
        return $null
    }

    # Test passes if we successfully retrieved the password policy
    $testResult = $null -ne $reversibleEncryption

    # Generate markdown results
    if ($testResult) {
        $encryptionStatus = if ($reversibleEncryption) { "Enabled" } else { "Disabled" }

        $result = "| Metric | Value |" + "`n"
        $result += "| --- | --- |" + "`n"
        $result += "| Reversible Encryption | $encryptionStatus |" + "`n"
        $result += "| Recommended Setting | Disabled |" + "`n"

        $recommendation = if ($reversibleEncryption) {
            "❌ Reversible encryption is enabled. This is a critical security risk as passwords can be decrypted. Disable this setting immediately unless absolutely required for legacy applications."
        } else {
            "✅ Reversible encryption is disabled. This is the secure configuration as passwords are stored using one-way hashing."
        }

        $testResultMarkdown = "$recommendation`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    } else {
        $testResultMarkdown = "Unable to retrieve the default domain password policy. Ensure you have appropriate permissions and the Active Directory module is installed."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
