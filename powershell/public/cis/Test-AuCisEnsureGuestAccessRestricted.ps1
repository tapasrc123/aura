function Test-AuCisEnsureGuestAccessRestricted {
    <#
    .SYNOPSIS
        Checks if guest user access is restricted.

    .DESCRIPTION
        Guest user access should be restricted to only necessary resources.
        CIS Microsoft 365 Foundations Benchmark v6.0.1

    .EXAMPLE
        Test-AuCisEnsureGuestAccessRestricted

        Returns true if guest user access is restricted.

    .LINK
        https://aura.onetapas.com/docs/commands/Test-AuCisEnsureGuestAccessRestricted
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (!(Test-AuConnection Graph)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedGraph
        return $null
    }

    try {
        Write-Verbose 'Getting settings...'
        $settings = Invoke-AuGraphRequest -RelativeUri "policies/authorizationPolicy" -DisableCache

        $testResult = $settings.guestUserRoleId -eq "10dae51f-b6af-4016-8d66-8c2a99b929b3" -or $settings.guestUserRoleId -eq "2af84b1e-32c8-42b7-82bc-daa82404023b"

        if ($testResult) {
            $testResultMarkdown = "Well done. Your tenant settings comply with CIS recommendations."
        }
        else {
            $testResultMarkdown = "Your tenant settings do not comply with CIS recommendations."
        }

        Add-AuTestResultDetail -Result $testResultMarkdown
        return $testResult
    }
    catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}
