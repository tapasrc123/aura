function Test-AuCisSpoDefaultSharingLink {
    <#
    .SYNOPSIS
        Ensure link sharing is restricted in SharePoint and OneDrive

    .DESCRIPTION
        7.2.7 (L1) Ensure link sharing is restricted in SharePoint and OneDrive
        CIS Microsoft 365 Foundations Benchmark v6.0.1

    .EXAMPLE
        Test-AuCisSpoDefaultSharingLink

        Returns true if link sharing is restricted in SharePoint and OneDrive

    .LINK
        https://aura.onetapas.com/docs/commands/Test-AuCisSpoDefaultSharingLink
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    Write-Verbose "Testing default sharing link type in SharePoint Online..."

    if (!(Test-AuConnection SharePointOnline)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedSharePoint
        return $null
    }

    $return = $true
    try {
        $spoTenant = Get-AuSpo
        if ($spoTenant.DefaultSharingLinkType -eq "Direct" -or $spoTenant.DefaultSharingLinkType -eq "Internal") {
            $testResult = "Well done. Default sharing link type is set to a restrictive option."
        } else {
            $testResult = "Default sharing link type is not set to a restrictive option."
            $return = $false
        }
        Add-AuTestResultDetail -Result $testResult
        return $return
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}
