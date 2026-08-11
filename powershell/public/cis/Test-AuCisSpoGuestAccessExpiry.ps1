function Test-AuCisSpoGuestAccessExpiry {
    <#
    .SYNOPSIS
        Ensure guest access to a site or OneDrive will expire automatically

    .DESCRIPTION
        7.2.9 (L1) Ensure guest access to a site or OneDrive will expire automatically
        CIS Microsoft 365 Foundations Benchmark v6.0.1

    .EXAMPLE
        Test-AuCisSpoGuestAccessExpiry

        Returns true if guest access expiration is enabled and set to 30 days or less

    .LINK
        https://aura.onetapas.com/docs/commands/Test-AuCisSpoGuestAccessExpiry
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    Write-Verbose "Testing guest access expiration settings in SharePoint Online..."

    if (!(Test-AuConnection SharePointOnline)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedSharePoint
        return $null
    }

    $return = $true
    try {
        $spoTenant = Get-AuSpo
        if ($spoTenant.ExternalUserExpirationRequired -eq $true -and $spoTenant.ExternalUserExpireInDays -gt 0 -and $spoTenant.ExternalUserExpireInDays -le 30) {
            $testResult = "Well done. Guest access expiration is enabled and set to 30 days or less ($($spoTenant.ExternalUserExpireInDays) days)."
        } else {
            $testResult = "Guest access expiration is not enabled or set to more than 30 days."
            $return = $false
        }
        Add-AuTestResultDetail -Result $testResult
        return $return
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}
