function Test-AuCisCreateTenantDisallowed {
    <#
    .SYNOPSIS
        Checks if non-admin users are restricted from creating tenants

    .DESCRIPTION
        Non-admin users should be restricted from creating tenants.
        CIS Microsoft 365 Foundations Benchmark v6.0.1

    .EXAMPLE
        Test-AuCisCreateTenantDisallowed

        Returns true if non-admin users are restricted from creating tenants.

    .LINK
        https://aura.onetapas.com/docs/commands/Test-AuCisCreateTenantDisallowed
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
        $checkAllowedToCreateTenants = $settings | Where-Object { $_.allowedToCreateTenants -eq $false }

        $testResult = (($checkAllowedToCreateTenants | Measure-Object).Count -ge 1)

        if ($testResult) {
            $testResultMarkdown = "Well done. Your tenant settings comply with CIS recommendations.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "Your tenant settings do not comply with CIS recommendations.`n`n%TestResult%"
        }

        $resultMd = "| Setting | Result |`n"
        $resultMd += "| --- | --- |`n"

        if ($checkAllowedToCreateTenants) {
            $checkAllowedToCreateTenantsResult = '✅ Pass'
        }
        else {
            $checkAllowedToCreateTenantsResult = '❌ Fail'
        }

        $resultMd += "| Restrict non-admin users from creating tenants | $checkAllowedToCreateTenantsResult |`n"

        $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $resultMd

        Add-AuTestResultDetail -Result $testResultMarkdown
        return $testResult
    }
    catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}
