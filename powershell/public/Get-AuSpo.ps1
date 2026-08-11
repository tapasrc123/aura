function Get-AuSpo {
    <#
    .SYNOPSIS
    Retrieves SharePoint Online tenant settings via PnP with session caching.

    .DESCRIPTION
    Returns the full SPO tenant configuration from Get-PnPTenant.
    Results are cached in $__AuSession.SpoCache for the duration of the session.
    Use -ClearCache to force a fresh retrieval.

    .EXAMPLE
    Get-AuSpo

    Returns the cached (or freshly retrieved) SPO tenant settings.

    .EXAMPLE
    Get-AuSpo -ClearCache

    Clears the cached settings and retrieves fresh data from Get-PnPTenant.

    .LINK
    https://aura.onetapas.com/docs/commands/Get-AuSpo
    #>
    [CmdletBinding()]
    param(
        # Clear the cached SPO tenant settings and retrieve fresh data.
        [switch]$ClearCache
    )

    if ($ClearCache) {
        $__AuSession.SpoCache = @{}
        Write-Verbose "SPO cache cleared."
    }

    if ($null -eq $__AuSession.SpoCache['SpoTenant']) {
        Write-Verbose "SPO tenant settings not in cache, requesting."
        $response = Get-PnPTenant -ErrorAction Stop
        $__AuSession.SpoCache['SpoTenant'] = $response
    } else {
        Write-Verbose "SPO tenant settings in cache."
        $response = $__AuSession.SpoCache['SpoTenant']
    }

    return $response
}
