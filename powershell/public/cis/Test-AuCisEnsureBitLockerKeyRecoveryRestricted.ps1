function Test-AuCisEnsureBitLockerKeyRecoveryRestricted {
    <#
    .SYNOPSIS
        Checks if non-admin users are restricted from recovering BitLocker keys for their owned devices.

    .DESCRIPTION
        Non-admin users should not be able to view or copy the BitLocker recovery key(s) for devices they own.
        CIS Microsoft 365 Foundations Benchmark v6.0.1

    .EXAMPLE
        Test-AuCisEnsureBitLockerKeyRecoveryRestricted

        Returns true if non-admin users are restricted from recovering their own BitLocker keys.

    .LINK
        https://aura.onetapas.com/docs/commands/Test-AuCisEnsureBitLockerKeyRecoveryRestricted
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (!(Test-AuConnection Graph)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedGraph
        return $null
    }

    try {
        Write-Verbose 'Getting authorization policy settings...'
        $settings = (Invoke-AuGraphRequest -RelativeUri "policies/authorizationPolicy" -DisableCache).defaultUserRolePermissions

        Write-Verbose 'Executing checks'
        $testResult = $settings.allowedToReadBitlockerKeysForOwnedDevice -eq $false

        if ($testResult) {
            $testResultMarkdown = "Well done. Your tenant settings comply with CIS recommendations.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "Your tenant settings do not comply with CIS recommendations.`n`n%TestResult%"
        }

        $resultMd = "| Setting | Result |`n"
        $resultMd += "| --- | --- |`n"

        if ($testResult) {
            $checkResult = '✅ Pass'
        }
        else {
            $checkResult = '❌ Fail'
        }

        $resultMd += "| Non-admin users are restricted from recovering BitLocker keys | $checkResult |`n"

        $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $resultMd

        Add-AuTestResultDetail -Result $testResultMarkdown
        return $testResult
    }
    catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}
