function Test-AuCisSpoB2BIntegration {
    <#
    .SYNOPSIS
        Ensure SharePoint and OneDrive integration with Azure AD B2B is enabled

    .DESCRIPTION
        7.2.2 (L1) Ensure SharePoint and OneDrive integration with Azure AD B2B is enabled
        CIS Microsoft 365 Foundations Benchmark v6.0.1

    .EXAMPLE
        Test-AuCisSpoB2BIntegration

        Returns true if SharePoint and OneDrive integration with Azure AD B2B is enabled

    .LINK
        https://aura.onetapas.com/docs/commands/Test-AuCisSpoB2BIntegration
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    Write-Verbose "Testing SharePoint Entra B2B integration..."

    if (!(Test-AuConnection SharePointOnline)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedSharePoint
        return $null
    }

    $return = $true
    try {
        $spoTenant = Get-AuSpo
        if ($spoTenant.EnableAzureADB2BIntegration) {
            $testResult = "Well done. Your SharePoint tenant is integrated with Microsoft Entra B2B."
        } else {
            $testResult = "Your SharePoint tenant is not integrated with Microsoft Entra B2B."
            $return = $false
        }
        Add-AuTestResultDetail -Result $testResult
        return $return
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}
