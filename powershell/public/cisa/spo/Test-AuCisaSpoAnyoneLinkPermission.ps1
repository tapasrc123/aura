function Test-AuCisaSpoAnyoneLinkPermission {
    <#
    .SYNOPSIS
    Checks state of Anyone link permissions for SharePoint Online

    .DESCRIPTION
    Anyone link permissions SHALL be limited to View only.

    .EXAMPLE
    Test-AuCisaSpoAnyoneLinkPermission

    Returns true if Anyone links are limited to View

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaSpoAnyoneLinkPermission
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

        $testResult = $spoTenant.FileAnonymousLinkType -eq 'View' -and $spoTenant.FolderAnonymousLinkType -eq 'View'

        if ($testResult) {
            $testResultMarkdown = "Well done. Anyone link permissions are limited to View only."
        } else {
            $testResultMarkdown = "Anyone link permissions are not limited to View only.`n`n* File Anyone link type: ``$($spoTenant.FileAnonymousLinkType)``  `n* Folder Anyone link type: ``$($spoTenant.FolderAnonymousLinkType)``"
        }

        Add-AuTestResultDetail -Result $testResultMarkdown -Severity Medium

        return $testResult
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}
