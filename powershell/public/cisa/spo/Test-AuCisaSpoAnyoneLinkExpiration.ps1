function Test-AuCisaSpoAnyoneLinkExpiration {
    <#
    .SYNOPSIS
    Checks state of Anyone link expiration for SharePoint Online

    .DESCRIPTION
    An expiration date SHALL be set for Anyone links.

    .EXAMPLE
    Test-AuCisaSpoAnyoneLinkExpiration

    Returns true if Anyone links have an expiration set

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaSpoAnyoneLinkExpiration
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (!(Test-AuConnection SharePointOnline)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedSharePoint
        return $null
    }

    try {
        $spoTenant = Get-AuSpo

        if ($spoTenant.SharingCapability -ne "ExternalUserAndGuestSharing") {
            Add-AuTestResultDetail -SkippedBecause Custom -SkippedCustomReason "Anyone links are not enabled. This test only applies when sharing is set to Anyone."
            return $null
        }

        # RequireAnonymousLinksExpireInDays: 0 = no expiration, >0 = days until expiry
        # CISA requires >= 1 AND <= 30 days
        $days = $spoTenant.RequireAnonymousLinksExpireInDays
        $testResult = $days -ge 1 -and $days -le 30

        if ($testResult) {
            $testResultMarkdown = "Well done. Anyone links expire after $days day(s)."
        } elseif ($days -eq 0) {
            $testResultMarkdown = "Anyone links do not have an expiration date set."
        } else {
            $testResultMarkdown = "Anyone links expiration is set to $days day(s), which exceeds the 30-day maximum."
        }

        Add-AuTestResultDetail -Result $testResultMarkdown -Severity 'High'

        return $testResult
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}
