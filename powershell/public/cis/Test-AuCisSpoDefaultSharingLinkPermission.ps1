function Test-AuCisSpoDefaultSharingLinkPermission {
    <#
    .SYNOPSIS
        Ensure the SharePoint default sharing link permission is set

    .DESCRIPTION
        7.2.11 (L1) Ensure the SharePoint default sharing link permission is set
        CIS Microsoft 365 Foundations Benchmark v6.0.1

    .EXAMPLE
        Test-AuCisSpoDefaultSharingLinkPermission

        Returns true if the SharePoint default sharing link permission is set to View

    .LINK
        https://aura.onetapas.com/docs/commands/Test-AuCisSpoDefaultSharingLinkPermission
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    Write-Verbose "Testing default sharing link permission in SharePoint Online..."

    if (!(Test-AuConnection SharePointOnline)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedSharePoint
        return $null
    }

    $return = $true
    try {
        $spoTenant = Get-AuSpo
        if ($spoTenant.DefaultLinkPermission -eq "View") {
            $testResult = "Well done. Default sharing link permission is set to View."
        } else {
            $testResult = "Default sharing link permission is not set to View."
            $return = $false
        }
        Add-AuTestResultDetail -Result $testResult
        return $return
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}
