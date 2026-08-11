function Test-AuCisThirdPartyApplicationsDisallowed {
    <#
    .SYNOPSIS
        Checks if users are not allowed to register applications.

    .DESCRIPTION
        Users should not be allowed to register applications in the tenant.
        CIS Microsoft 365 Foundations Benchmark v6.0.1

    .EXAMPLE
        Test-AuCisThirdPartyApplicationsDisallowed

        Returns true if users are not allowed to register applications in the tenant.

    .LINK
        https://aura.onetapas.com/docs/commands/Test-AuCisThirdPartyApplicationsDisallowed
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
        $settings = (Invoke-AuGraphRequest -RelativeUri "policies/authorizationPolicy" -DisableCache).defaultUserRolePermissions

        Write-Verbose 'Executing checks'
        $checkAllowedToCreateApps = $settings | Where-Object { $_.allowedToCreateApps -eq $false }

        $testResult = (($checkAllowedToCreateApps | Measure-Object).Count -ge 1)

        if ($testResult) {
            $testResultMarkdown = "Well done. Your tenant settings comply with CIS recommendations.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "Your tenant settings do not comply with CIS recommendations.`n`n%TestResult%"
        }

        $resultMd = "| Setting | Result |`n"
        $resultMd += "| --- | --- |`n"

        if ($checkAllowedToCreateApps) {
            $checkAllowedToCreateAppsResult = '✅ Pass'
        }
        else {
            $checkAllowedToCreateAppsResult = '❌ Fail'
        }

        $resultMd += "| Users can register applications | $checkAllowedToCreateAppsResult |`n"

        $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $resultMd

        Add-AuTestResultDetail -Result $testResultMarkdown
        return $testResult
    }
    catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}
