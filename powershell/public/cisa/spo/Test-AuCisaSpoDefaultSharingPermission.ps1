function Test-AuCisaSpoDefaultSharingPermission {
    <#
    .SYNOPSIS
    Checks state of default SharePoint Online sharing permission

    .DESCRIPTION
    Default file and folder sharing permission SHOULD be set to View.

    .EXAMPLE
    Test-AuCisaSpoDefaultSharingPermission

    Returns true if default sharing permission is set to View

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaSpoDefaultSharingPermission
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

        # DefaultLinkPermission: None = not explicitly set, View = View only, Edit = Edit
        # CISA requires an explicit View choice — None (never set) should fail.
        $testResult = $spoTenant.DefaultLinkPermission -eq 'View'

        if ($testResult) {
            $testResultMarkdown = "Well done. Your tenant default sharing permission is set to View."
        } else {
            $testResultMarkdown = "Your tenant default sharing permission is not set to View.`n`n* Current setting: ``$($spoTenant.DefaultLinkPermission)``"
        }

        Add-AuTestResultDetail -Result $testResultMarkdown -Severity Low

        return $testResult
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}
